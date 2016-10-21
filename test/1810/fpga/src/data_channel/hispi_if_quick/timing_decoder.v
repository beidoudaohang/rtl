//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : timing_decoder
//  -- 设计者       : 周金剑
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 周金剑       :| 2015/08/11 13:46:45	:|  初始版本
//  -- 邢海涛       :| 2015/10/27 13:13:44	:|  改为第一帧能够出图的版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : HiSPi数据处理模块
//              1)  : 检测同步字
//
//              2)  : 产生fval、lval和pixel_data信号,fval和lval在时序上是边沿对齐的
//				fval:____|--------------------------------------------|_____
//				lval:____|----|____|----|____|----|____|----|____|----|_____
//				data:____|<-->|____|<-->|____|<-->|____|<-->|____|<-->|_____
//
//				3)	: 模块不考虑残帧的情况，行有效数据必须是4的倍数
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ns
//-------------------------------------------------------------------------------------------------
module timing_decoder #(
	parameter		SER_FIRST_BIT			= "LSB"				,	//"LSB" or "MSB" , first bit to the receiver
	parameter		SENSOR_DAT_WIDTH		= 12				,
	parameter		CHANNEL_NUM				= 4					,
	//ADD
	parameter		TD_OFFSET_WIDTH			= 13
	//
	)
	(
	input												clk					,	//时钟
	input												reset				,	//复位信号
	input												i_clk_en			,	//时钟
	input												i_sync				,	//输入数据是控制字
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]			iv_data				,	//通道1输入数据
	output												o_first_frame_detect,	//检测到第一个完整帧
	output												o_clk_en			,
	output												o_fval				,	//输出场有效信号
	output												o_lval				,	//输出行有效信号
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]			ov_pix_data		 		//输出像素数据
	);

	//	-------------------------------------------------------------------------------------
	//	hispi 的关键字
	//	-------------------------------------------------------------------------------------
	localparam					SOF	= {{(SENSOR_DAT_WIDTH-4){1'b0}},4'b0011};
	localparam					SOL	= {{(SENSOR_DAT_WIDTH-4){1'b0}},4'b0001};
	localparam					EOF	= {{(SENSOR_DAT_WIDTH-4){1'b0}},4'b0111};
	localparam					EOL	= {{(SENSOR_DAT_WIDTH-4){1'b0}},4'b0101};

	localparam					SHIFT_WIDTH	= log2(CHANNEL_NUM)	;

	wire	[SENSOR_DAT_WIDTH-1:0]				wv_data_lane[CHANNEL_NUM-1:0]	;	//重新组合的通道1的数据
	reg		[SENSOR_DAT_WIDTH*3-1:0]			data_lane0_shift		= 'b0	;	//lan0通道移位寄存器
	reg											first_frame_detect		= 1'b0	;//第一次检测到帧头标志

	reg											lval_reg				= 1'b0	;
	reg											fval_reg				= 1'b0	;
	reg											clk_en_dly				= 1'b0	;
	wire										sof_flag				;//SOF标志
	wire										eol_flag				;//EOL标志
	wire										sol_flag				;//SOL标志
	wire										eof_flag				;//EOF标志
	reg		[SENSOR_DAT_WIDTH-1:0]				data_lane_output_dly0[CHANNEL_NUM-1:0]	;	//重新组合的通道1的数据
	reg		[SENSOR_DAT_WIDTH-1:0]				data_lane_output_dly1[CHANNEL_NUM-1:0]	;	//重新组合的通道1的数据
	reg		[SENSOR_DAT_WIDTH-1:0]				data_lane_output_dly2[CHANNEL_NUM-1:0]	;	//重新组合的通道1的数据
	reg		[SENSOR_DAT_WIDTH-1:0]				data_lane_output_dly3[CHANNEL_NUM-1:0]	;	//重新组合的通道1的数据


	//ADD
	reg											lval_roi				= 1'b0	;	//行有效控制信号
	reg		[TD_OFFSET_WIDTH-1:0]				width_cnt				=  'b0	;	//行宽度计数
	reg		[TD_OFFSET_WIDTH-1:0]				td_offset_x_start		=  'b0	;
	reg		[TD_OFFSET_WIDTH-1:0]				td_offset_width			=  'b0	;
	//

	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction
	//	===============================================================================================
	//	ref ***异步时钟域处理***
	//	===============================================================================================
	//	===============================================================================================
	//	ref ***检测关键字***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	划分通道
	//	--每个通道的位宽是 RATIO 个bit
	//	--大端，最高的通道在低byte。小端，最低的通道在低byte。
	//	-------------------------------------------------------------------------------------
	genvar	i;
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			assign	wv_data_lane[i]	= iv_data[SENSOR_DAT_WIDTH*(i+1)-1:SENSOR_DAT_WIDTH*i];
		end
	endgenerate

	//----------------------------------------------------------------------------------------
	//检测SOF、SOL、EOF、EOL标志
	//----------------------------------------------------------------------------------------
	assign	sof_flag	= (wv_data_lane[0]==SOF && i_sync==1'b1) ? 1'b1 : 1'b0;
	assign	sol_flag	= (wv_data_lane[0]==SOL && i_sync==1'b1) ? 1'b1 : 1'b0;
	assign	eof_flag	= (wv_data_lane[0]==EOF && i_sync==1'b1) ? 1'b1 : 1'b0;
	assign	eol_flag	= (wv_data_lane[0]==EOL && i_sync==1'b1) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	检测到 sof
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset) begin
			first_frame_detect	<=	1'b0;
		end
		else if(!first_frame_detect)begin
			if(sof_flag) begin
				first_frame_detect	<=	1'b1;
			end
		end
	end
	assign	o_first_frame_detect	= first_frame_detect;

	//	===============================================================================================
	//	ref ***输出***
	//	===============================================================================================

	reg		[3:0]		sof_flag_shift	= 4'b0;
	reg		[3:0]		sol_flag_shift	= 4'b0;
	always @ (posedge clk) begin
		if(i_clk_en==1'b1) begin
			sof_flag_shift	<= {sof_flag_shift[2:0],sof_flag};
			sol_flag_shift	<= {sol_flag_shift[2:0],sol_flag};
		end
	end





	//	-------------------------------------------------------------------------------------
	//	产生行信号		//CHANGED
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			lval_reg	<=	1'b0;
		end
		else begin
			if(i_clk_en==1'b1) begin
				if(sof_flag_shift[3] | sol_flag_shift[3]) begin	//CHANGED
					lval_reg	<=	1'b1;
				end
				else if(eof_flag | eol_flag) begin	//CHANGED
					lval_reg	<=	1'b0;
				end
			end
		end
	end


	assign	o_lval	= lval_reg;

	//	-------------------------------------------------------------------------------------
	//	产生场信号
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			fval_reg	<=	1'b0;
		end
		else begin
			if(i_clk_en==1'b1) begin
				if(sof_flag_shift[3]) begin
					fval_reg	<=	1'b1;
				end
				else if(eof_flag)
				fval_reg	<=	1'b0;
			end
		end
	end
	assign	o_fval	= fval_reg;

	//	-------------------------------------------------------------------------------------
	//	时钟分频使能
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		clk_en_dly	<= i_clk_en;
	end
	assign	o_clk_en	= clk_en_dly;

	//	-------------------------------------------------------------------------------------
	//	未对齐时，屏蔽输出为全1
	//	-------------------------------------------------------------------------------------
	genvar	j;
	generate
		for(j=0;j<CHANNEL_NUM;j=j+1) begin
			always @ (posedge clk)begin
				if(i_clk_en==1'b1) begin
					data_lane_output_dly0[j]	<= wv_data_lane[j];
					data_lane_output_dly1[j]	<= data_lane_output_dly0[j];
					data_lane_output_dly2[j]	<= data_lane_output_dly1[j];
					data_lane_output_dly3[j]	<= data_lane_output_dly2[j];
				end
			end
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	输出对齐后的数据，区分大小端
	//	-------------------------------------------------------------------------------------
	genvar	l;
	generate
		for(l=0;l<CHANNEL_NUM;l=l+1) begin
			assign	ov_pix_data[(l+1)*SENSOR_DAT_WIDTH-1:l*SENSOR_DAT_WIDTH]	= data_lane_output_dly3[l];
		end
	endgenerate

endmodule