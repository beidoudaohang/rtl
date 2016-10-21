//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : u3_transfer
//  -- 设计者       : 张强、周金剑
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 张强         :| 2014/11/28 17:40:36	:|  根据技术预研整理
//  -- 周金剑       :| 2016/9/22 14:29:57	:|  修改为支持multi-roi的版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module u3_transfer # (
	parameter						DATA_WD      		=32		,	//GPIF数据宽度
	parameter						REG_WD 				=32		,	//寄存器位宽
	parameter						SHORT_REG_WD 		=16		,	//短寄存器位宽
	parameter						PACKET_SIZE_WD		=24		,	//图像大小位宽,单位4字节,支持到最大64MB图像
	parameter						DMA_SIZE			=14'H2000	//DMA SIZE大小8192x32bit
	)
	(
	//  ===============================================================================================
	//  第一部分：时钟复位信号
	//  ===============================================================================================
	input							clk							,	//u3接口和framebuffer后端时钟
	input							reset						,	//复位信号，clk_usb_pclk时钟域，高有效
	//  ===============================================================================================
	//  第二部分：数据流控制信号
	//  ===============================================================================================
	output							o_fifo_rd					,	//读取帧存后端FIFO信号，clk_gpif时钟域,和i_data_valid信号共同指示数据有效，framebuffer后级模块读使能，高有效
	input		[DATA_WD		:0]	iv_data						,	//帧存读出的32位数据，clk_usb_pclk时钟域
	input							i_framebuffer_empty			,	//framebuffer后端FIFO空标志，高电平有效，clk_gpif时钟域,帧存图像累计后帧存空可能不会出现
	input							i_leader_flag				,	//leader包标志,clk_usb_pclk时钟域
	input							i_trailer_flag				,	//trailer包标志,clk_usb_pclk时钟域
	input							i_payload_flag				,	//payload包标志,clk_usb_pclk时钟域
	output	reg						o_change_flag				,	//leader、payload、trailer中切换标志，每个包发送完成后切换,单周期宽度
	output	reg	[7				 :0]ov_roi_num					,	//multi-roi模式输出的roi的num号
	//  ===============================================================================================
	//  第三部分：控制寄存器
	//  ===============================================================================================
	input		[REG_WD-1		 :0]iv_packet_size				,	//当前包对应的数据量大小，用于读出framebuffer中的数据包含leader+payload+trailer，固件内为64位宽，FPGA内部只使用低32位
	input		[REG_WD-1		 :0]iv_transfer_count			,	//等量数据块个数
	input		[REG_WD-1		 :0]iv_transfer_size			,	//等量数据块大小
	input		[REG_WD-1		 :0]iv_transfer1_size			,   //transfer1大小
	input		[REG_WD-1		 :0]iv_transfer2_size			,   //transfer2大小
	//  ===============================================================================================
	//  第四部分：GPIF接口信号
	//  ===============================================================================================
	input							i_usb_flagb					,	//USB满信号，发送完32k字节数据后3个时钟会拉低，切换DMA地址后标志指示当前FIFO状态，如果当前FIFO中没有数据FLAGB会拉高，如果PC阻塞，当前FIFO还没有读出，该标志可能长时间拉低
	output		[1				 :0]ov_usb_fifoaddr				,	//GPIF 线程地址 2bit，地址切换顺序要和固件保持一致，目前约定为2'b00,2'b11切换
	output	reg						o_usb_slwr_n				,	//GPIF 写信号，低电平有效
	output	reg	[DATA_WD-1		 :0]ov_usb_data					,	//GPIF 数据信号
	output							o_usb_pktend_n					//GPIF 包结束信号，低电平有效，有效时间持续1个时钟周期
	);

	//  ===============================================================================================
	//  第一部分：寄存器线网定义
	//  ===============================================================================================
	wire		[47				 :0]wv_pc_buffer_size			;	//PC端buffersize大小，位宽是乘法器两个乘数位宽的和
	reg         [13 			 :0]dma_cnt						;	//DMA计数器
	reg			[PACKET_SIZE_WD-1:0]sending_size_cnt			;	//当前包发送大小计数器
	reg			[REG_WD-1		 :0]require_size_cnt			;	//当前包发送大小计数器
	reg			[2				 :0]usb_flagb_shift				;	//i_flagb的移位寄存器
	reg								urb_enough_flag				;	//PC端开urb大于设备要发送数据量的标志
	wire							w_mult_en					;	//乘法器使能信号
	reg			[REG_WD-1		 :0]transfer_count_m			;	//生效时机之后，等量数据块个数
	reg			[REG_WD-1		 :0]transfer_size_m				;	//生效时机之后，等量数据块大小
	reg			[REG_WD-1		 :0]transfer1_size_m			;   //生效时机之后，transfer1大小
	reg			[REG_WD-1		 :0]transfer2_size_m			;   //生效时机之后，transfer2大小
	reg			[REG_WD-1		 :0]transfer12_size_m			;   //生效时机之后，transfer1和transfer2的和
	reg			[REG_WD-1		 :0]buffer_plus_transfer1		;	//生效时机之后，transfer_count*transfer_size和transfer1的和
	reg			[7 				 :0]current_state				;	//当前状态，比next_state延时1个时钟周期，负责状态跳转
	reg			[7 				 :0]next_state					;	//负责逻辑动作
	reg								usb_slwr_n_m1				;	//GPIF 写信号
	reg			[DATA_WD-1		 :0]usb_data_m1					;	//GPIF 数据信号
	reg			[1				 :0]usb_fifoaddr_reg	= 2'b0	;

	reg			[1				 :0]leader_flag_shift	= 2'b0	;	//i_leader_flag移位寄存器
	reg			[1				 :0]payload_flag_shift	= 2'b0	;	//i_payload_flag移位寄存器
	reg			[1				 :0]trailer_flag_shift	= 2'b0	;	//i_trailer_flag移位寄存器
	
	reg			[SHORT_REG_WD-1	 :0]urb_num_total		=	0	;	//urb的总个数
	reg			[SHORT_REG_WD-1	 :0]urb_num_total_reg	=	0	;	//urb的总个数，urb_num_total_reg=urb_num_total或者urb_num_total_reg=urb_num_total+1
	reg			[SHORT_REG_WD-1	 :0]urb_used_cnt		=	0	;	//当前图像数据使用的urb个数
	reg			[REG_WD-3		 :0]urb_size_cnt		=	0	;	//等量urb计数器
	wire 							urb_num0					;	//transfer1_size=0则为0，否则为1
	wire 							urb_num1					;	//transfer2_size=0则为0，否则为1

	//	-------------------------------------------------------------------------------------
	//	usb_pktend_n_reg 和 usb_pktend_n_for_test 的行为是一样的，如果不加约束，会优化掉
	//	usb_pktend_n_reg-输出到GPIF引脚上
	//	-------------------------------------------------------------------------------------
	reg			usb_pktend_n_reg			= 1'b1;

	//  ===============================================================================================
	//  第二部分：参数定义
	//  ===============================================================================================
	localparam 						IDLE 		= 8'b00000000	;	//空闲状态
	localparam 						PACKET_START= 8'b00000001	;	//包起始状态
	localparam 						DMA_SENDING	= 8'b00000010	;	//DMA发送状态
	localparam 						CHECK_FLAG	= 8'b00000100	;	//检查标志状态
	localparam 						PKT_END     = 8'b00001000	;	//包结束状态
	localparam 						DELAY		= 8'b00010000	;	//延时状态，短包到flag标志为低有3个时钟的延时
	localparam 						WAIT_FLAG	= 8'b00100000	;	//等待标志状态
	localparam						ADD_PKT_END = 8'b01000000	;	//添加包结束状态
	localparam						PACKET_STOP = 8'b10000000	;	//添加包结束状态
	//	-------------------------------------------------------------------------------------
	//	仿真用，便于仿真时看出状态机处于哪个状态
	//	-------------------------------------------------------------------------------------
	//FSM for sim
	// synthesis translate_off
	reg		[111:0]			current_state_ascii;
	reg		[111:0]			next_state_ascii;
	always @ ( * ) begin
		case(current_state)
			8'b00000000 :	current_state_ascii	<= "IDLE";
			8'b00000001 :	current_state_ascii	<= "PACKET_START";
			8'b00000010 :	current_state_ascii	<= "DMA_SENDING";
			8'b00000100 :	current_state_ascii	<= "CHECK_FLAG";
			8'b00001000 :	current_state_ascii	<= "PKT_END";
			8'b00010000 :	current_state_ascii	<= "DELAY";
			8'b00100000 :	current_state_ascii	<= "WAIT_FLAG"; 
			8'b01000000	:	current_state_ascii	<= "ADD_PKT_END";
			8'b10000000	:	current_state_ascii	<= "PACKET_STOP";
		endcase
	end
	
	always @ ( * ) begin
		case(next_state)
			8'b00000000 :	next_state_ascii	<= "IDLE";
			8'b00000001 :	next_state_ascii	<= "PACKET_START";
			8'b00000010 :	next_state_ascii	<= "DMA_SENDING";
			8'b00000100 :	next_state_ascii	<= "CHECK_FLAG";
			8'b00001000 :	next_state_ascii	<= "PKT_END";
			8'b00010000 :	next_state_ascii	<= "DELAY";
			8'b00100000 :	next_state_ascii	<= "WAIT_FLAG"; 
			8'b01000000	:	next_state_ascii	<= "ADD_PKT_END";
			8'b10000000	:	next_state_ascii	<= "PACKET_STOP";
		endcase
	end
	// synthesis translate_on
	//  ===============================================================================================
	//  第三部分辅助逻辑1:取i_usb_flagb信号的边沿
	//  ===============================================================================================

	always @ (posedge clk)begin
		usb_flagb_shift	<=	{usb_flagb_shift[1:0],i_usb_flagb}	;
	end

	always @ (posedge clk)begin
		leader_flag_shift	<=	{leader_flag_shift[0],i_leader_flag}	;
		payload_flag_shift	<=	{payload_flag_shift[0],i_payload_flag}	;
		trailer_flag_shift	<=	{trailer_flag_shift[0],i_trailer_flag}	;
	end

	//  ===============================================================================================
	//  第三部分辅助逻辑2:参数生效时机控制，所有配置参数只能在停采期间才能修改，采集期间保持不变
	//  ===============================================================================================
	assign urb_num0	=	transfer1_size_m ? 1 :0;
	assign urb_num1	=	transfer2_size_m ? 1 :0;
	
	always @ (posedge clk)begin
		if(reset)begin
			transfer_count_m	    <=	iv_transfer_count   ;
			transfer_size_m	    	<=	iv_transfer_size    ;
			transfer1_size_m	    <=	iv_transfer1_size   ;
			transfer2_size_m		<=	iv_transfer2_size	;
			urb_num_total			<=	iv_transfer_count	+	urb_num0	+	urb_num1;
		end
	end

	//  ===============================================================================================
	//  第三部分辅助逻辑3:计算PC URB大小，iv_transfer_size*iv_transfer_count++iv_transfer1_size+iv_transfer2_size
	//  支持的图像大小可以通过PACKET_SIZE_WD来设置，require_size_cnt的位宽应该至少是PACKET_SIZE_WD+2
	//  乘法器只允许在停采期间计算，开始采集后，需保持不变，所以使用reset取反做时钟使能，流水线延时5clk
	//  计算PC URB大小主要是用来判断是否添加短包
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  例化乘法器
	//  -------------------------------------------------------------------------------------
	urb_mult urb_mult_inst(
	.clk  (clk									),
	.ce   (w_mult_en							),
	.a    (transfer_size_m						),
	.b    (transfer_count_m[SHORT_REG_WD-1	:0]	),
	.p    (wv_pc_buffer_size					)
	);
	//	-------------------------------------------------------------------------------------
	//	复位期间才允许参数更改并计算	
	//	-------------------------------------------------------------------------------------
	assign	w_mult_en  = ~reset;		

	//	-------------------------------------------------------------------------------------
	//	较长组合逻辑打一排，有利于优化时序
	//	-------------------------------------------------------------------------------------
	always @ (posedge	clk)begin 		
		transfer12_size_m		<= transfer1_size_m 	+ 	transfer2_size_m;
	end
	
	always @ (posedge clk) begin
		buffer_plus_transfer1	<=	wv_pc_buffer_size	+	transfer1_size_m;
	end
	
	always @ (posedge clk)begin 		
		require_size_cnt		<= wv_pc_buffer_size[REG_WD-1:0] + transfer12_size_m;
	end
	//	-------------------------------------------------------------------------------------
	//	只有i_payload_flag标志期间才判断，leader、trailer数据只能是短包无需判断	
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk)begin		
		if (reset)
			urb_enough_flag	<=	1'b0;
		else if(i_payload_flag && ( require_size_cnt > iv_packet_size))
			urb_enough_flag	<=	1'b1;
		else
			urb_enough_flag	<=	1'b0;
	end
	//  ===============================================================================================
	//  第三部分辅助逻辑4统计使用urb的个数urb_used_cnt	
	//	统计使用urb个数逻辑说明
	//	1、sending_size_cnt<=(wv_pc_buffer_size>>2)-1时，每计满1个等量urb，urb_used_cnt+1
	//	2、sending_size_cnt==(buffer_plus_transfer1>>2)-1时，计满transfer1，urb_used_cnt+1
	//	3、sending_size_cnt==(iv_packet_size>>2)-1时，不管是否填满某个urb，urb_used_cnt+1
	//	===============================================================================================
	always @ (posedge clk) begin
		if(next_state==0)begin															//回到IDEL状态时
			urb_used_cnt	<=	0;														//urb_used_cnt清零
			urb_size_cnt	<=	0;														//urb_size_cnt清零
		end
		else if(i_payload_flag)begin													//状态机处于发送payload数据阶段
			if(next_state[1] & o_fifo_rd & (~iv_data[DATA_WD]))begin															//next_state=DMA_SENDING
				if(sending_size_cnt==iv_packet_size[PACKET_SIZE_WD+1:2]-1)begin				//计数器达到最大值
					urb_used_cnt	<=	urb_used_cnt	+	1'd1;							//urb_size_cnt加1
				end
				else if(sending_size_cnt==buffer_plus_transfer1[PACKET_SIZE_WD+1:2]-1)begin	//sending_size_cnt达到等量urb+transfer1的大小
					urb_used_cnt	<=	urb_used_cnt	+	1'd1;							//urb_used_cnt加1
				end
				else if(sending_size_cnt<=wv_pc_buffer_size[PACKET_SIZE_WD+1:2]-1)begin		//计数值小于等于等量urb的总和
					if(urb_size_cnt==transfer_size_m[PACKET_SIZE_WD+1:2]-1)begin			//urb_size_cnt计数值达到1个urb的大小
						urb_used_cnt	<=	urb_used_cnt	+	1'd1;						//urb_used_cnt加1
						urb_size_cnt	<=	0;												//urb_size清零
					end
					else begin																//否则
						urb_used_cnt	<=	urb_used_cnt;									//urb_used_cnt保持不变
						urb_size_cnt	<=	urb_size_cnt	+	1'd1;						//urb_size_cnt加1
					end
				end
			end
			else if(next_state[6])begin														//状态机处于发送短包阶段
				urb_used_cnt	<=	urb_used_cnt	+	1'd1;								//urb_used_cnt加1
			end
		end	
	end
	//  ===============================================================================================
	//	第三部分辅助逻辑5计算需要发送的短包个数，需要发送的短包个数为urb_num_total_reg-urb_used_cnt 
	//	计算需要发送的短包个数的逻辑说明
	//	当数据发送完毕
	//	1、iv_packet_size为1024的整数倍时，
	//		当urb_enough_flag=1时
	//		a、如果urb_size_cnt==(wv_transfer_size_m>>2)-1，则表示等量urb被填满，urb_num_total_reg=urb_num_total
	//		b、如果sending_size_cnt==(wv_pc_buffer_size+wv_transfer1_size_m)>>2-1，urb_num_total_reg=urb_num_total
	//		c、其他情况,urb_num_total_reg=urb_num_total+1
	//		当urb_enough_flag=0时
	//		urb_num_total_reg=urb_num_total
	//	2、iv_packet_size不是1024的整数倍时，
	//		urb_num_total_reg=urb_num_total
	//  ===============================================================================================
	always @ (posedge clk) begin
		if(next_state==0)begin
			urb_num_total_reg	<=	0;
		end
		else if(i_payload_flag==1 && next_state[1]==1 && sending_size_cnt==iv_packet_size[PACKET_SIZE_WD+1:2]-1)begin//i_payload_flag=1且next_state=DMA_SENDING
			if(iv_packet_size[9:2] == 8'h00)begin							//iv_packet_size为1024的整数倍
				if(urb_enough_flag)begin									//urb_size>payload_size
					if(urb_size_cnt==transfer_size_m[PACKET_SIZE_WD+1:2]-1)	//填满等量urb，不发送短包
						urb_num_total_reg	<=	urb_num_total;
					else if(sending_size_cnt==buffer_plus_transfer1[PACKET_SIZE_WD+1:2]-1)//填满transfer1，不发送短包
						urb_num_total_reg	<=	urb_num_total;
					else
						urb_num_total_reg	<=	urb_num_total	+	1'd1;
				end									
				else
					urb_num_total_reg	<=	urb_num_total;
			end
			else
				urb_num_total_reg	<=	urb_num_total;
		end
	end
	//  ===============================================================================================
	//  从leader提取roi_num
	//	leader的数据结构
	//	leader		:	-|32'h4c563355	|...........................................|byte4 byte3 byte2 byte1|  
	//	dma_cnt		:	-|		0		|		1		|............|		12		|			13			|
	//	o_fifo_rd	:	_|——————————————————————————————————————————————————————————————————————————————————|_
	//	byte4:8'h0
	//	byte3:8'h0
	//	byte2:1-last roi,0-others
	//	byte1:roi_num,range from 0 to 7
	//  ===============================================================================================
	always @ (posedge clk) begin
		if(i_leader_flag & (dma_cnt==13)) begin
			ov_roi_num	<=	iv_data[7:0];
		end
	end
	//  ===============================================================================================
	//  第四部分三段式状态机，可参考详细设计跳转流程图
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  状态机第一段
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset)
			current_state	<=	IDLE;
		else
			current_state	<=	next_state;
	end
	//  -------------------------------------------------------------------------------------
	//  状态机第二段
	//	详细参考详细设计状态机跳转图
	//  读逻辑存在隐患
	//  -------------------------------------------------------------------------------------
	always @ * begin
		next_state  =	IDLE		;
		case (current_state)
			IDLE 		:begin		
				if(leader_flag_shift==2'b01 || payload_flag_shift==2'b01 || trailer_flag_shift==2'b01)//只要有一个标志到来就跳转到包传输开始
					next_state	= PACKET_START;
				else
					next_state	= IDLE;
			end
			PACKET_START:begin			
				if(usb_flagb_shift[1])							//检查3014是否阻塞，没有阻塞才能跳转到下一状态
					next_state	= DMA_SENDING;
				else
					next_state	= PACKET_START;
			end
			DMA_SENDING	:begin		
				if(sending_size_cnt == iv_packet_size[PACKET_SIZE_WD+1:2])//当sending_size_cnt[12:0] == DMA_SIZE与本条件同时满足时，sending_size_cnt[12:0] == DMA_SIZE优先级高
					next_state	= PKT_END;		
				else if(dma_cnt== DMA_SIZE)					//dma_cnt发送数据量等于DMA_SIZE时，跳转到下一状态
					next_state	= CHECK_FLAG;
				else
					next_state	= DMA_SENDING;
			end
			CHECK_FLAG	:begin			
				if(usb_flagb_shift[2:1] == 2'b01)				//采用计数的方式，等待flagb恢复空之后再继续发送一组DMA_SIZE大小的数据
					next_state	= DMA_SENDING;
				else
					next_state	= CHECK_FLAG;
			end
			PKT_END		:begin			
				if(iv_packet_size[9:2] == 8'h00)begin			//iv_packet_size是1k的倍数				
					if(urb_enough_flag)							//iv_packet_size是1k的倍数且 PC URB总和大于设备发送数据量，需要添加短包
						next_state	= WAIT_FLAG;
					else
						next_state	= DELAY;					//否则不用添加短包
				end
				else begin										//iv_packet_size不是1k的倍数，添加完短包返回IDEL
					if(urb_used_cnt>=urb_num_total_reg)
						next_state	= DELAY;
					else
						next_state	= WAIT_FLAG;	
				end
			end
			WAIT_FLAG	:begin		
				if (usb_flagb_shift[2:1] == 2'b01)				//等待flagb上升沿，如果直接判断flagb，可能会因flagb没及时拉低误判
					next_state	= ADD_PKT_END;
				else
					next_state	= WAIT_FLAG;
			end
			ADD_PKT_END	:begin									//补发短包			
				if(i_payload_flag)begin
					if(urb_used_cnt==urb_num_total_reg)
						next_state	= DELAY;
					else
						next_state	= WAIT_FLAG;
				end
				else begin
					next_state	= DELAY;
				end
			end
			DELAY		:begin									//等待flagb上升沿，如果直接判断flagb，可能会因flagb有三个时钟的延时，没及时拉低状态机PACKET_START误判		
				if(usb_flagb_shift[2:1] == 2'b01)
					next_state	= PACKET_STOP;
				else
					next_state	= DELAY;
			end
			PACKET_STOP	:begin									//一个packet发送结束，用于生成change_flag			
				next_state	= IDLE;
			end
		endcase
	end

	//  -------------------------------------------------------------------------------------
	//  状态机第三段
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset)begin
			o_change_flag			<=	1'b0    ;
			usb_fifoaddr_reg		<=	2'b00	;
			usb_pktend_n_reg		<=	1'b1    ;
			dma_cnt					<=	14'h0   ;
			sending_size_cnt		<=	{PACKET_SIZE_WD{1'b0}};
		end
		else begin
			o_change_flag			<=	1'b0    ;				//信号默认状态
			usb_pktend_n_reg		<=	1'b1    ;
			dma_cnt					<=	14'h0   ;
			case (next_state)
				IDLE		:begin
					sending_size_cnt		<=	{PACKET_SIZE_WD{1'b0}};
				end
				DMA_SENDING	:begin
					if(o_fifo_rd & (~iv_data[DATA_WD]))begin							//3014未满，帧存后端非空，且没有记到DMASIZE，因读信号与数据有延迟，引入和数据对齐的valid信号					
						dma_cnt				<=  dma_cnt + 1;
						sending_size_cnt	<=	sending_size_cnt + 1;
					end
					else begin					
						dma_cnt				<=  dma_cnt;
						sending_size_cnt	<=	sending_size_cnt ;
					end								
				end
				CHECK_FLAG	:begin
					if(usb_flagb_shift[2:1] == 2'b10)begin		//flagb满时（下降沿）切换FIFO地址				
						usb_fifoaddr_reg	<=	~usb_fifoaddr_reg;
					end
				end
				PKT_END		:begin
					usb_pktend_n_reg		<= 1'b0;
				end
				DELAY		:begin
					if(usb_flagb_shift[2:1] == 2'b10)			//flagb满时（下降沿）切换FIFO地址
						usb_fifoaddr_reg		<=	~usb_fifoaddr_reg;
					else
						usb_fifoaddr_reg		<=	usb_fifoaddr_reg;
				end
				WAIT_FLAG	:begin
					if(usb_flagb_shift[2:1] == 2'b10)			//flagb满时（下降沿）切换FIFO地址
						usb_fifoaddr_reg		<=	~usb_fifoaddr_reg;
				end
				ADD_PKT_END	:begin
					usb_pktend_n_reg		<= 1'b0;					
				end
				PACKET_STOP	:begin
					o_change_flag			<= 1'b1;	
				end
				default		:;
			endcase
		end
	end

	//	-------------------------------------------------------------------------------------
	//	3014 FIFO地址
	//	-------------------------------------------------------------------------------------
	assign	ov_usb_fifoaddr			= usb_fifoaddr_reg;

	//	-------------------------------------------------------------------------------------
	//	包结束信号
	//	-------------------------------------------------------------------------------------
	assign	o_usb_pktend_n			= usb_pktend_n_reg;

	//  ===============================================================================================
	//  生成3014GPIF端口信号
	//	3014写信号等同于frame_buffer读信号，FIFO使用First-Word Fall-Through读信号和
	//  数据对齐，写信号和数据也要对齐，所以数据打一排
	//	读条件依赖于帧存后端FIFO设计，后端FIFO不能写入多余设计，否则会o_fifo_rd会读出多于数据
	//	最后一个短包数据读出之后延时一拍写入，此时输出短包信号，最后一个写和短包正好对齐
	//  ===============================================================================================
	//	此处只能是next_state== DMA_SENDING，否则读信号会宽1个时钟
	assign	o_fifo_rd = (next_state== DMA_SENDING) && usb_flagb_shift[1]  && (!i_framebuffer_empty) && (dma_cnt < DMA_SIZE);

	//	-------------------------------------------------------------------------------------
	//发送数据时，有可能会多写入4Byte的无效数据，需要将多写入的数据屏蔽
	//以下3种情况需要屏蔽最后4Byte的写入
	//1、发送leader数据
	//2、发送打开chunk的trailer数据
	//3、发送数据量是4的倍数而不是8的倍数的payload数据
	//	-------------------------------------------------------------------------------------

	//  ===============================================================================================
	//	头包长度52B实际写入后端fifo 56B，所以需要屏蔽4B；
	//	尾包chunk打开时写入36B，实际写入40B，因此需要屏蔽4B，当chunk关闭时写入32B，实际写入也是32B，不需屏蔽
	//	为减少其他代码改动，采用将写信号、和数据延时，短包信号相对位置保持不变的方法保证短包正确写入，多写入的数据正确屏蔽
	//  发送leader和打开chunk的trailer时需要屏蔽写信号，屏蔽逻辑借用短包信号延时一拍
	//  ===============================================================================================
	//	原有信号相对位置
	//	o_usb_slwr_n	———————————————————|______________________________|——————————————————
	//	ov_usb_data 	-------------------X==============================X------------------
	//	o_usb_pktend_n	————————————————————————————————————————————————|_|———————————————————
	//	o_usb_slwr_n	—————————————————————|____________________________|————————————————
	//	ov_usb_data 	---------------------X==============================X----------------
	//	o_usb_pktend_n	————————————————————————————————————————————————|_|——————————————————
	//	-------------------------------------------------------------------------------------
	//	写信号做延时处理,以便与o_usb_pktend_n在时序上对齐
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset)begin
			usb_slwr_n_m1	<=	1'b1;
		end
		else begin
			usb_slwr_n_m1	<=	~o_fifo_rd | iv_data[DATA_WD];
		end
	end
	
	always @ (posedge clk)begin
		if(reset) begin
			o_usb_slwr_n	<=	1'b1;
		end
		else begin
			o_usb_slwr_n	<=	usb_slwr_n_m1 && (!(next_state == ADD_PKT_END));
		end
	end
	//	-------------------------------------------------------------------------------------
	//数据做延时处理,以便与o_usb_slwr_n和o_usb_pktend_n在时序上对齐
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset)
			usb_data_m1	<=	32'h0;
		else
			usb_data_m1	<=	iv_data[DATA_WD-1:0];
	end
	
	always @ (posedge clk)begin
		if(reset)
			ov_usb_data		<=	32'h0;
		else if(~usb_slwr_n_m1)				
			ov_usb_data		<=	usb_data_m1;
		else//补发短包对应的数据为0					
			ov_usb_data		<=	32'h0;
	end

endmodule