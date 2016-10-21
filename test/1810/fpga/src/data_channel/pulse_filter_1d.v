//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : pulse_filter_1d
//  -- 设计者       : 张希伦
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 张希伦       :| 2016/8/17 18:52:08	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 坏点矫正模块
//              1)  : 一维矫正算法
//
//              2)  : 不考虑边界值的影响
//
//              3)  : 只去除亮点
//
//-------------------------------------------------------------------------------------------------
//`include			"pulse_filter_1d_def.v"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module pulse_filter_1d # (
	parameter	SENSOR_DAT_WIDTH	= 8	,//sensor 数据宽度
	parameter 	CHANNEL_NUM 		= 8	,//sensor 通道数量
	parameter 	SHORT_REG_WD		= 16 //短寄存器位宽
	)
	(
	//Sensor输入信号
	input												clk					,//像素时钟
	input												i_fval				,//clk时钟域，输入场信号
	input												i_lval				,//clk时钟域，输入行信号
	input		[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data			,//clk时钟域，输入数据信号
	//寄存器数据
	input												i_pulse_filter_en	,//clk时钟域，滤波使能信号
	input		[SHORT_REG_WD				 -1:0]		iv_roi_pic_width	,//clk时钟域，roi行宽
	//输出
	output												o_fval				,//clk时钟域，输出场信号
	output												o_lval				,//clk时钟域，输出行信号
	output		[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data			,//clk时钟域，输出数据
	output		[SHORT_REG_WD				 -1:0]		ov_pulse_num		 //clk时钟域，统计一帧坏点个数，每帧更新
	);

	//	ref signals
	//	LOG2函数 
	function integer log2 (input integer xx);
		integer x;
		begin
			x    = xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x    = x >> 1;
			end
		end
	endfunction
	//	固定参数
	localparam	SHIFT_NUM		=	log2(CHANNEL_NUM);					 						//提取通道移位数
	localparam  SHIFT_LENTH 	= 	(CHANNEL_NUM==1)?(9>>SHIFT_NUM    )	: ((9>>SHIFT_NUM)+ 1);	//移位寄存器宽度，因为9个clk才能进行一次运算，所以用9除以通道数，做向上取整处理
	localparam  LATCH_LENTH 	= 	(CHANNEL_NUM==8)?((4>>SHIFT_NUM)+1)	: (4>>SHIFT_NUM		);	//锁存寄存器宽度，因为前后各需要锁存4个数据，所以用4除以通道数，做向上取整处理
	localparam  THRESHOLD		= 	(SENSOR_DAT_WIDTH 	== 8)  	  ? 				25  	 : 	//坏点矫正阈值，8位对应25；10位对应100；12位对应400
									(SENSOR_DAT_WIDTH 	== 10) 	  ? 				100 	 :
									(SENSOR_DAT_WIDTH 	== 12) 	  ? 				400 	 :
														   	   	    				400 	 ;
	localparam	DELAY_LENTH		=	(CHANNEL_NUM 		== 1)  	  ? (SHIFT_LENTH	 )		 :	//行场信号延迟宽度，与通道个数有关
									(CHANNEL_NUM 		== 2)  	  ? (SHIFT_LENTH +  2)		 :
									(CHANNEL_NUM 		== 4)  	  ? (SHIFT_LENTH +  3)		 :
									(CHANNEL_NUM 		== 8)  	  ? (SHIFT_LENTH +  4)		 :
																  	(SHIFT_LENTH +  4)		 ; 
									 			   	   	
	reg[DELAY_LENTH						-1:0] fval_shift		  =	{SHIFT_LENTH					{1'b0}} ;//行信号移位寄存器，用于将行信号延迟输出
	reg[DELAY_LENTH						-1:0] lval_shift		  =	{SHIFT_LENTH					{1'b0}} ;//场信号移位寄存器，用于将场信号延迟输出
	reg 									  dataout_flag		  =									 1'b0	;//输出数据标志寄存器，用于控制cnt_out计数
	reg 									  dataout_flag_dly	  =									 1'b0	;//输出数据标志延迟寄存器，用于在8通道时控制cnt_out计数
	reg										  pulse_filter_en_int =									 1'b0	;//内部中断滤波使能寄存器，当场消隐时更新
	reg[SHORT_REG_WD					-1:0] cnt_pix			  =	{SHORT_REG_WD					{1'b0}}	;//输入行像素计数器，记录一行输入的像素个数，用于锁存边界数据。
	reg[SHORT_REG_WD					-1:0] cnt_out			  =	{SHORT_REG_WD					{1'b0}}	;//输出行像素计数器，记录一行输出的像素个数，用于控制像素的输出。
	reg[SHORT_REG_WD					-1:0] roi_data_lenth	  =	{SHORT_REG_WD					{1'b0}} ;//通过将roi行宽移位得到与通道数对应的数据行宽
	reg[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] pix_data_dly		  =	{SENSOR_DAT_WIDTH*CHANNEL_NUM	{1'b0}} ;//滤波使能无效时，输出的数据值
	reg[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] pix_data_dly1		  =	{SENSOR_DAT_WIDTH*CHANNEL_NUM	{1'b0}} ;//data_shift数组最高一个数据延迟1拍，对应2通道时，滤波使能无效时的输出数据
	reg[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] pix_data_dly2		  =	{SENSOR_DAT_WIDTH*CHANNEL_NUM	{1'b0}} ;//data_shift数组最高一个数据延迟2拍，对应4通道时，滤波使能无效时的输出数据
	reg[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] pix_data_dly3		  =	{SENSOR_DAT_WIDTH*CHANNEL_NUM	{1'b0}} ;//data_shift数组最高一个数据延迟3拍，对应8通道时，滤波使能无效时的输出数据
	reg[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] pix_data_reg		  =	{SENSOR_DAT_WIDTH*CHANNEL_NUM	{1'b0}} ;//根据位置存放运算并拼接好的数据或者边界锁存值
	reg[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] data_shift			[SHIFT_LENTH					 -1:0]	;//数据移位寄存器，用于存放一个clk内需要进行计算或参与计算的数据
	reg[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] data_front_latch		[LATCH_LENTH			 		 -1:0]	;//由于每行前4个数据自身不用进行计算，所以需要将其锁存，之后将原数据输出
	wire[SENSOR_DAT_WIDTH				-1:0] data_split	  		[SHIFT_LENTH*CHANNEL_NUM 		 -1:0]	;//将数据移位寄存器中的数据拆分成宽度为sensor数据宽度的数据，并存放在这个数组中，为了方便之后的计算
	reg[SENSOR_DAT_WIDTH				-1:0] data_split_dly		[CHANNEL_NUM			 		 -1:0]	;//将存放分割数据的数组延迟一拍
	reg[SENSOR_DAT_WIDTH				-1:0] data_split_dly2		[CHANNEL_NUM			 		 -1:0]	;//将存放分割数据的数组再延迟一拍
	reg[SENSOR_DAT_WIDTH				  :0] data_m				[CHANNEL_NUM			 		 -1:0]	;//计算中间值，对应算法文档中的M
	reg[SENSOR_DAT_WIDTH				  :0] data_n				[CHANNEL_NUM			 		 -1:0]	;//计算中间值，对应算法文档中的N
	reg[SENSOR_DAT_WIDTH				  :0] data_th 				[CHANNEL_NUM			 		 -1:0]	;//计算中间值，对应算法文档中的Th
	reg[SENSOR_DAT_WIDTH				-1:0] data_temp				[CHANNEL_NUM			 		 -1:0]	;//单个像素计算之后的值
	reg[SENSOR_DAT_WIDTH				-1:0] data_temp_dly			[CHANNEL_NUM			 		 -1:0]	;//将单个像素计算之后的值延迟一拍，用于8通道数据的拼接
	wire[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] data_cal												 		;//进行坏点矫正计算之后，并且拼接完成的值
	reg[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] data_tail_latch 		[LATCH_LENTH	 		 		 -1:0]	;//由于每行后4个数据自身不用进行计算，所以需要将其锁存，之后将原数据输出
	reg[SHORT_REG_WD					-1:0] pulse_num_reg			[CHANNEL_NUM					 -1:0]	;//统计多通道计算过程中，计算出的坏点个数，输入场信号上升沿清0					  
	reg[SHORT_REG_WD					-1:0] pulse_num_latch	  =	{SHORT_REG_WD					{1'b0}}	;//锁存一帧图像中的坏点个数，在输入场信号下降沿锁存					  
	wire 									  fval_rise														;//场信号上升沿，用于统计坏点个数 
	wire 									  fval_fall														;//场信号下降沿，用于锁存一帧的坏点个数
	
	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref ***打拍、取边沿、移位***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	行信号移位寄存器，用于将行信号延迟输出
	//	延迟长度根据通道数而定 
	//	获取输入场信号边沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_shift <= {fval_shift[DELAY_LENTH-2:0],i_fval}; 
	end
	assign o_fval 	 = fval_shift[DELAY_LENTH-1]; 
	assign fval_rise = i_fval & ~fval_shift[0];
	assign fval_fall = ~i_fval & fval_shift[0];
	//  -------------------------------------------------------------------------------------
	//	场信号移位寄存器，用于将场信号延迟输出
	//	延迟长度根据通道数而定
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_shift <= {lval_shift[DELAY_LENTH-2:0],i_lval}; 
	end
	assign o_lval = lval_shift[DELAY_LENTH-1];
	//  -------------------------------------------------------------------------------------
	//	输入数据打拍，为了支持多通道时，使能信号无效时，延迟输出与使能信号有效时相同的时间
	//	为了使帧率无抖动
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		pix_data_dly1 <= data_shift[SHIFT_LENTH-1];
		pix_data_dly2 <= pix_data_dly1;
		pix_data_dly3 <= pix_data_dly2;
	end 
	//  -------------------------------------------------------------------------------------
	//	通过将roi行宽移位得到与通道数对应的数据行宽
	//	因为之前的模块已经对roi的生效时机做了保护，这里不再重复进行
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		roi_data_lenth <= iv_roi_pic_width>>SHIFT_NUM;
	end
	//  ===============================================================================================
	//	ref ***生效时机***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	pulse_filter_en_int 使能信号，保证完整帧
	//	1.pulse_filter_en_int=o_fval 
	//	2.当o_fval=0时，pulse_filter_en_int=i_pulse_filter_en
	//	2.当o_fval=1时，pulse_filter_en_int保持不变
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_fval|o_fval) begin
			pulse_filter_en_int <= pulse_filter_en_int;
		end
		else begin
			pulse_filter_en_int <= i_pulse_filter_en;
		end
	end
	//  ===============================================================================================
	//	ref ***计数器***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	cnt_pix 记录一行输入的像素个数
	// 	1.i_lval行有效期间计数，可以用场信号进行保护
	//	2.计数到roi行宽后清0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(cnt_pix == roi_data_lenth) begin
			cnt_pix <= {SHORT_REG_WD{1'b0}};
		end
		else if(i_lval&i_fval) begin
			cnt_pix <= cnt_pix + 1'b1;
		end
		else begin
			cnt_pix <= {SHORT_REG_WD{1'b0}};
		end
	end
	//  -------------------------------------------------------------------------------------
	//	dataout_flag 数据输出标志位
	// 	1.数据的移位需要 SHIFT_LENTH 个clk
	//	2.数据的计算需要3个clk
	//	3.计算之后的第一个数据输出之前，还需要输出之前4个边界数据
	//	4.对于1通道数据，在 cnt_pix 计数到 SHIFT_LENTH-3 时，dataout_flag 置1，cnt_out开始计数
	//	  对于2通道数据，在 cnt_pix 计数到 SHIFT_LENTH-1 时，dataout_flag 置1，cnt_out开始计数
	//	  对于4通道数据，在 cnt_pix 计数到 SHIFT_LENTH   时，dataout_flag 置1，cnt_out开始计数
	//	  对于8通道数据，在 cnt_pix 计数到 SHIFT_LENTH   时，dataout_flag_dly 置1，cnt_out开始计数
	//	5.在cnt_out 计数到 roi_data_lenth 时置0，表示一行数据输出完毕
	//  -------------------------------------------------------------------------------------
	genvar i; 
	generate
		if(CHANNEL_NUM == 1) begin
			always @ (posedge clk) begin
				if(cnt_out == roi_data_lenth) begin
					dataout_flag <= 1'b0;
				end
				else if(cnt_pix == (SHIFT_LENTH - 3)) begin
					dataout_flag <= 1'b1;
				end
			end 
		end
		if(CHANNEL_NUM == 2) begin
			always @ (posedge clk) begin
				if(cnt_out == roi_data_lenth) begin
					dataout_flag <= 1'b0;
				end
				else if(cnt_pix == (SHIFT_LENTH - 1)) begin
					dataout_flag <= 1'b1;
				end
			end
		end
		if(CHANNEL_NUM == 4) begin
			always @ (posedge clk) begin
				if(cnt_out == roi_data_lenth) begin
					dataout_flag <= 1'b0;
				end
				else if(cnt_pix == SHIFT_LENTH) begin
					dataout_flag <= 1'b1;
				end
			end
		end
		if(CHANNEL_NUM == 8) begin
			always @ (posedge clk) begin
				if(cnt_out == roi_data_lenth) begin
					dataout_flag <= 1'b0;
				end
				else if(cnt_pix == SHIFT_LENTH) begin
					dataout_flag <= 1'b1; 
				end
			end
			always @ (posedge clk) begin
				if(cnt_out == roi_data_lenth) begin
					dataout_flag_dly <= 1'b0;
				end
				else if(dataout_flag) begin 
					dataout_flag_dly <= 1'b1;		
				end
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	cnt_out 输出数据计数器
	// 	1.dataout_flag为1时开始计数
	//	2.在cnt_out 计数到 roi_data_lenth 时置0，表示一行数据输出完毕
	//  -------------------------------------------------------------------------------------
	generate
		if((CHANNEL_NUM == 1)|(CHANNEL_NUM == 2)|(CHANNEL_NUM == 4)) begin
			always @ (posedge clk) begin
				if(cnt_out == roi_data_lenth) begin
					cnt_out <= {SHORT_REG_WD{1'b0}};
				end
				else if(dataout_flag) begin
					cnt_out <= cnt_out + 1'b1;
				end
			end
		end
		else if(CHANNEL_NUM == 8) begin
			always @ (posedge clk) begin
				if(cnt_out == roi_data_lenth) begin
					cnt_out <= {SHORT_REG_WD{1'b0}};
				end
				else if(dataout_flag_dly) begin
					cnt_out <= cnt_out + 1'b1;
				end
			end	
		end			
	endgenerate
	
	//  ===============================================================================================
	//	ref ***锁存边界值***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	data_front_latch 锁存行头4个像素值
	// 		对于1通道 cnt_pix = 1时，锁存每行开始4个数据，即为行头4个边界像素值
	//	  	对于1通道 cnt_pix = 2时，锁存每行开始2个数据，即为行头4个边界像素值
	//	  	对于1通道 cnt_pix = 4时，锁存每行开始1个数据，即为行头4个边界像素值
	//	  	对于1通道 cnt_pix = 8时，锁存每行开始1个数据的低4个数据，即为行头4个边界像素值
	//						___________________________
	//		lval_dly	____|                         |_	
	//						____________________	 
	//  	data_shift[0]	|d0||d1||d2||d3||d4|.....
	//  					￣￣￣￣￣￣￣￣￣￣     
	//					____________________			
	//		cnt_pix		 00||01||02||03||04|.........
	//					￣￣￣￣￣￣￣￣￣￣			
	//  -------------------------------------------------------------------------------------
	generate
		for(i=0;i<LATCH_LENTH;i=i+1) begin
			always @ (posedge clk) begin
				if(cnt_pix == i+1) begin
					data_front_latch[i] <=  data_shift[0];
				end
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	data_tail_latch 锁存行尾4个像素值
	//		对于1通道 cnt_out = roi_data_lenth -3 时，锁存每行最后4个数据，即为行尾4个边界像素值
	//	  	对于2通道 cnt_out = roi_data_lenth -1 时，锁存每行最后2个数据，即为行尾4个边界像素值
	//	  	对于4通道 cnt_out = roi_data_lenth    时，锁存每行最后1个数据，即为行尾4个边界像素值
	//	  	对于8通道 cnt_out = roi_data_lenth    时，锁存每行最后1个数据的高4个数据，即为行尾4个边界像素值
	//						_________________________________________________
	//		lval_dly	____|                                               |_	
	//						   	     ________________________________________
	//  	data_shift[0]	   ......|droi_data_lenth-2| |droi_data_lenth-1 |
	//  					   	     ￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣
	//						   	     ________________________________________
	//		cnt_pix			   ......| roi_data_lenth-1| |  roi_data_lenth  | 
	//						   	     ￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣
	//  -------------------------------------------------------------------------------------
	generate
		for(i=LATCH_LENTH;i>0;i=i-1) begin
			always @ (posedge clk) begin
				if(cnt_pix == roi_data_lenth - (i-1)) begin
					data_tail_latch[LATCH_LENTH-i] <=  data_shift[0];
				end
			end
		end
	endgenerate
	
	//  ===============================================================================================
	//	ref ***运算过程***
	//	1.在移位寄存器中移入足够数量的数据
	//	2.将移位寄存器中多通道的数据进行拆分，使拆分后数据的位宽与sensor位宽相同，之后按顺序存入数组中
	//	3.按公式进行比较 M=p1+abs(p1-p0) 和 N=p3+abs(p3-p4)
	//	4.按公式进行比较 Th=max(M,N)
	//	5.坏点判定 p2是否大于Th+THRESHOLD，是则为坏点，输出Th；否则不为坏点，输出p2
	//	6.第五步进行判定时，需要用到p2，但判断时已经过了2个clk，所以要把需要进行坏点矫正的值延迟2拍
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	data_shift 数据移位
	// 	1通道时，需要移9次
	//	2通道时，需要移5次
	//	4通道时，需要移3次
	//	8通道时，需要移2次
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		data_shift[0] <= iv_pix_data ;
	end
	generate
		for(i=1;i<SHIFT_LENTH;i=i+1) begin	
			always @ (posedge clk) begin
				data_shift[i] <= data_shift[i-1];
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	data_split 拆分 data_shift 移位寄存器中数据，使拆分后的数据均等于sensor数据长度
	// 	按顺序将拆分后的数据存入数组
	//	数组长度为 SHIFT_LENTH*CHANNEL_NUM
	//  -------------------------------------------------------------------------------------	
	genvar	j;
	generate
		for(i=SHIFT_LENTH;i>0;i=i-1) begin
			for(j=0;j<CHANNEL_NUM;j=j+1) begin
				assign data_split[(SHIFT_LENTH-i)*CHANNEL_NUM+j] = data_shift[i-1][SENSOR_DAT_WIDTH*(j+1)-1:SENSOR_DAT_WIDTH*j];
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	将data_split中需要进行坏点矫正计算的值延迟一个周期，目的是之后进行坏点矫正时数据同步
	// 	这里注意只需要将自身需要进行坏点矫正计算的数据进行延迟
	//  -------------------------------------------------------------------------------------
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			always @ (posedge clk) begin
				data_split_dly[i] <= data_split[i+4];
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	将data_split中需要进行坏点矫正计算的值再延迟一个周期，目的是之后进行坏点矫正时数据同步
	// 	这里注意只需要将自身需要进行坏点矫正计算的数据进行延迟
	//  -------------------------------------------------------------------------------------
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			always @ (posedge clk) begin
				data_split_dly2[i] <= data_split_dly[i];
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	按公式进行比较  M=p1+abs(p1-p0)
	//  -------------------------------------------------------------------------------------
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			always @ (posedge clk) begin
				if(data_split[i]>=data_split[i+2]) begin
					data_m[i] <= data_split[i+2] + data_split[i] - data_split[i+2];
				end
				else begin
					data_m[i] <= data_split[i+2] + data_split[i+2] - data_split[i];
				end
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	按公式进行比较  N=p3+abs(p3-p4)
	//  -------------------------------------------------------------------------------------
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			always @ (posedge clk) begin
				if(data_split[i+6]>=data_split[i+8]) begin
					data_n[i] <= data_split[i+6] + data_split[i+6] - data_split[i+8];
				end
				else begin
					data_n[i] <= data_split[i+6] + data_split[i+8] - data_split[i+6];
				end
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	按公式进行比较 Th=max(M,N)
	//  -------------------------------------------------------------------------------------
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			always @ (posedge clk) begin
				if(data_m[i]>=data_n[i]) begin
					data_th[i] <= data_m[i];
				end
				else begin
					data_th[i] <= data_n[i];
				end
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	坏点判定 p2是否大于Th+THRESHOLD，是则为坏点，输出Th；否则不为坏点，输出p2
	//  -------------------------------------------------------------------------------------
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			always @ (posedge clk) begin
				if(data_split_dly2[i]>(data_th[i]+THRESHOLD)) begin
					data_temp[i] <= data_th[i][SENSOR_DAT_WIDTH-1:0];
				end
				else begin
					data_temp[i] <= data_split_dly2[i];
				end
			end
		end
	endgenerate
	//  ===============================================================================================
	//	ref ***坏点个数统计***
	//	1.输入场信号上升沿时，清0各通道计数器，并开始计数坏点个数
	//	2.在输入场信号下降沿时，将计数器的数据锁存，并输出
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	判断出一个坏点，则计数器加1，计数器在场信号上升沿清0，场有效时计数
	//  -------------------------------------------------------------------------------------
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					pulse_num_reg[i] <= {SHORT_REG_WD{1'b0}};
				end
				else if(i_fval) begin
					if(data_split_dly2[i]>(data_th[i]+THRESHOLD)) begin
						pulse_num_reg[i] <= pulse_num_reg[i] + 1'b1; 
					end
				end
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	场信号下降沿时，将坏点个数统计计数器中的数据锁存
	//  ------------------------------------------------------------------------------------- 
	generate
		if(CHANNEL_NUM == 1) begin
			always @ (posedge clk) begin
				if(fval_fall) begin
					pulse_num_latch = pulse_num_reg[0];
				end
			end		
		end
		else if(CHANNEL_NUM == 2) begin
			always @ (posedge clk) begin
				if(fval_fall) begin
					pulse_num_latch = pulse_num_reg[0] + pulse_num_reg[1];
				end
			end		
		end
		else if(CHANNEL_NUM == 4) begin
			always @ (posedge clk) begin
				if(fval_fall) begin
					pulse_num_latch = pulse_num_reg[0] + pulse_num_reg[1] +pulse_num_reg[2] + pulse_num_reg[3];
				end
			end	
		end
		else if(CHANNEL_NUM == 8) begin
			always @ (posedge clk) begin
				if(fval_fall) begin
					pulse_num_latch = pulse_num_reg[0] + pulse_num_reg[1] +pulse_num_reg[2] + pulse_num_reg[3]+
									  pulse_num_reg[4] + pulse_num_reg[5] +pulse_num_reg[6] + pulse_num_reg[7];
				end
			end	
		end
	endgenerate 
	assign ov_pulse_num = pulse_filter_en_int ? pulse_num_latch : {SHORT_REG_WD{1'b0}};
	//  ===============================================================================================
	//	ref ***数据输出***
	//	1.将数据进行拼接
	//		对于1通道，不需要拼接
	//		对于2通道，只需将一次计算出的2个数值拼接到一起
	//		对于4通道，只需将一次计算出的4个数值拼接到一起
	//		对于8通道，只需将上个clk计算出的后4个数据与这个clk计算出的前4个clk拼接到一起
	//			所以8通道需要将上个clk计算出的值延迟一拍
	//	3.滤波使能有效时，输出计算后的数据，否则不经过坏点矫正，直接将输入的数据输出
	//	4.数据输出时，每行的开头和结尾都是输出4个边界像素数据，中间是计算后的数据，通过cnt_out来控制
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	8通道时，拼接数据的需要，需要将 data_temp 延迟一拍，只在8通道时有效
	//  -------------------------------------------------------------------------------------
	generate
		if(CHANNEL_NUM == 8) begin
			for(i=0;i<CHANNEL_NUM;i=i+1) begin
				always @ (posedge clk) begin
					data_temp_dly[i] <=  data_temp[i];
				end
			end
		end
	endgenerate 
	//  -------------------------------------------------------------------------------------
	//	数据拼接
	//  -------------------------------------------------------------------------------------
	generate
		if(CHANNEL_NUM == 1) begin
			assign data_cal = data_temp[0];
		end
		else if(CHANNEL_NUM == 2) begin
			assign data_cal = {data_temp[1],data_temp[0]};
		end
		else if(CHANNEL_NUM == 4) begin
			assign data_cal = {data_temp[3],data_temp[2],data_temp[1],data_temp[0]};
		end
		else if(CHANNEL_NUM == 8) begin
			assign data_cal = {data_temp[3],data_temp[2],data_temp[1],data_temp[0],
			data_temp_dly[7],data_temp_dly[6],data_temp_dly[5],data_temp_dly[4]};
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	数据输出，都是由cnt_out控制
	//	滤波使能无效时，延迟与滤波使能有效时相同的时间再输出数据，可以使帧率无抖动
	//	滤波使能有效时：
	//		cnt_out = 0时，表示没有在行有效期间，数据输出为0
	//		对于1通道，分别判断cnt_out前、后边缘的4个值，然后输出锁存值，其余时候输出计算值
	//		对于2通道，分别判断cnt_out前、后边缘的2个值，然后输出锁存值，其余时候输出计算值
	//		对于4通道，分别判断cnt_out前、后边缘的1个值，然后输出锁存值，其余时候输出计算值
	//		对于8通道，分别判断cnt_out前、后边缘的1个值，得出前1个值中的开头4个像素数据以及
	//		最后1个值中的结尾4个像素数据，分别将其与计算后的数据进行拼接后输出	
	//  -------------------------------------------------------------------------------------
	generate
		if(CHANNEL_NUM == 1) begin
			always @ (posedge clk) begin 
				if(cnt_out == 16'd0) begin
					pix_data_reg <= {SENSOR_DAT_WIDTH*CHANNEL_NUM{1'b0}};	
				end
				else if(cnt_out == 16'd1) begin
					pix_data_reg <= data_front_latch[0];
				end
				else if(cnt_out == 16'd2) begin
					pix_data_reg <= data_front_latch[1];
				end
				else if(cnt_out == 16'd3) begin
					pix_data_reg <= data_front_latch[2];
				end
				else if(cnt_out == 16'd4) begin
					pix_data_reg <= data_front_latch[3];
				end
				else if(cnt_out == (roi_data_lenth-3)) begin
					pix_data_reg <= data_tail_latch[0];
				end
				else if(cnt_out == (roi_data_lenth-2)) begin
					pix_data_reg <= data_tail_latch[1];
				end
				else if(cnt_out == (roi_data_lenth-1)) begin
					pix_data_reg <= data_tail_latch[2]; 
				end
				else if(cnt_out == roi_data_lenth) begin
					pix_data_reg <= data_tail_latch[3];
				end
				else begin
					pix_data_reg <= data_cal;
				end
			end 
		end
		else if(CHANNEL_NUM == 2) begin
			always @ (posedge clk) begin
				if(cnt_out == 16'd0) begin
					pix_data_reg <= {SENSOR_DAT_WIDTH*CHANNEL_NUM{1'b0}};	
				end
				else if(cnt_out == 16'd1) begin
					pix_data_reg <= data_front_latch[0];
				end
				else if(cnt_out == 16'd2) begin
					pix_data_reg <= data_front_latch[1];
				end
				else if(cnt_out == (roi_data_lenth-1)) begin
					pix_data_reg <= data_tail_latch[0];
				end
				else if(cnt_out == roi_data_lenth) begin
					pix_data_reg <= data_tail_latch[1];
				end
				else begin
					pix_data_reg <= data_cal;
				end
			end
		end
		else if(CHANNEL_NUM == 4) begin
			always @ (posedge clk) begin
				if(cnt_out == 16'd0) begin
					pix_data_reg <= {SENSOR_DAT_WIDTH*CHANNEL_NUM{1'b0}};	
				end
				else if(cnt_out == 16'd1) begin
					pix_data_reg <= data_front_latch[0];
				end
				else if(cnt_out == roi_data_lenth) begin
					pix_data_reg <= data_tail_latch[0];
				end
				else begin
					pix_data_reg <= data_cal;
				end
			end
		end
		else if(CHANNEL_NUM == 8) begin
			always @ (posedge clk) begin
				if(cnt_out == 16'd0) begin
					pix_data_reg <= {SENSOR_DAT_WIDTH*CHANNEL_NUM{1'b0}};	
				end
				else if(cnt_out == 16'd1) begin
					pix_data_reg <= {data_cal[SENSOR_DAT_WIDTH*8-1:SENSOR_DAT_WIDTH*4],data_front_latch[0][SENSOR_DAT_WIDTH*4-1:0]};
				end
				else if(cnt_out == roi_data_lenth) begin
					pix_data_reg <= {data_tail_latch[0][SENSOR_DAT_WIDTH*8-1:SENSOR_DAT_WIDTH*4],data_cal[SENSOR_DAT_WIDTH*4-1:0]};
				end
				else begin
					pix_data_reg <= data_cal;
				end
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	滤波使能无效时，输出的数据值
	//  -------------------------------------------------------------------------------------
	generate
		always @ (posedge clk) begin
			if(CHANNEL_NUM == 1) begin
				pix_data_dly <= data_shift[SHIFT_LENTH-2];
			end
			else if(CHANNEL_NUM == 2) begin
				pix_data_dly <= pix_data_dly1;
			end
			else if(CHANNEL_NUM == 4) begin
				pix_data_dly <= pix_data_dly2;
			end
			else if(CHANNEL_NUM == 8) begin
				pix_data_dly <= pix_data_dly3;
			end
		end
	endgenerate
	assign	ov_pix_data = pulse_filter_en_int ? pix_data_reg : pix_data_dly;

endmodule
  