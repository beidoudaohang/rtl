//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : ctrl_insert_python
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/10/14 11:52:11	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module ctrl_insert_python # (
	parameter			DATA_WIDTH			= 8		,	//数据位宽
	parameter			CHANNEL_NUM			= 4			//通道数
	)
	(
	input										clk							,	//时钟
	input										i_init_done					,	//数据寄存器配置完成
	input										i_fval						,	//场有效
	input										i_lval						,	//行有效
	input	[DATA_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data					,	//像素数据
	output										o_fval						,	//场有效
	output										o_lval						,	//行有效
	output	[DATA_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data					,	//像素数据
	output	[DATA_WIDTH-1:0]					ov_ctrl_data					//控制通道
	);

	//	ref signals

	localparam	FS		= (DATA_WIDTH==10) ? 10'h2aa : 8'haa	;
	localparam	FSS		= (DATA_WIDTH==10) ? 10'h22a : 8'h8a	;
	localparam	FE		= (DATA_WIDTH==10) ? 10'h32a : 8'hca	;
	localparam	FSE		= (DATA_WIDTH==10) ? 10'h3aa : 8'hea	;
	localparam	TR		= (DATA_WIDTH==10) ? 10'h3a6 : 8'he9	;
	localparam	LS		= (DATA_WIDTH==10) ? 10'h0aa : 8'h2a	;
	localparam	LE		= (DATA_WIDTH==10) ? 10'h12a : 8'h4a	;
	localparam	IMG		= (DATA_WIDTH==10) ? 10'h035 : 8'h0d	;
	localparam	BL		= (DATA_WIDTH==10) ? 10'h015 : 8'h05	;
	localparam	CRC		= (DATA_WIDTH==10) ? 10'h059 : 8'h16	;
	localparam	ID		= (DATA_WIDTH==10) ? 10'h000 : 8'h00	;
	localparam	ALL_ZERO		= (DATA_WIDTH==10) ? 10'h000 : 8'h00	;

	reg											fval_dly	= 1'b0;
	wire										fval_rise	;
	wire										fval_fall	;
	reg											lval_dly	= 1'b0;
	wire										lval_rise	;
	wire										lval_fall	;
	reg											fval_rise_dly0	= 1'b0;
	reg											fval_rise_dly1	= 1'b0;
	reg											lval_rise_dly0	= 1'b0;
	reg											lval_rise_dly1	= 1'b0;
	reg											lval_rise_dly2	= 1'b0;
	reg											lval_fall_dly0	= 1'b0;
	reg											lval_fall_dly1	= 1'b0;
	reg		[2:0]								fval_shift	= 3'b0;
	reg		[2:0]								lval_shift	= 3'b0;
	reg		[DATA_WIDTH*CHANNEL_NUM-1:0]		pix_data_dly0	;
	reg		[DATA_WIDTH*CHANNEL_NUM-1:0]		pix_data_dly1	;
	reg		[DATA_WIDTH*CHANNEL_NUM-1:0]		pix_data_dly2	;
	reg		[DATA_WIDTH:0]						ctrl_data_reg	= 'b0;


	//	ref ARCHITECTURE



	//	-------------------------------------------------------------------------------------
	//         		  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___
	//	clk  		__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__
	//
	//					   ________________________________________________________________________________________________
	//	i_fval		_______|                                                                                              |_________
	//                     _________________________________________              _________________________________________
	//	i_lval		_______|                                       |______________|                                       |_________
	//
	//	pix_cnt		-------< 0 >< 1 >< 2 >< 3 >< 0 >< 1 >< 2 >< 3 >< 0            >< 0 >< 1 >< 2 >< 3 >< 0 >< 1 >< 2 >< 3 >
	//
	//	data		<TR   ><d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 ><CRC><TR       ><d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 ><CRC><TR   >
	//
	//	ctrl		<TR   ><FS ><ID ><IMG               ><LE ><ID ><CRC><TR       ><LS ><ID ><IMG               ><FE ><ID ><CRC><TR   >
	//
	//                     _____                                                                                           _____
	//	fval_rise_fall ____|   |___________________________________________________________________________________________|   |_______
	//                     _____                                   _____           _____                                   _____
	//	lval_rise_fall ____|   |___________________________________|   |___________|   |___________________________________|   |_______
	//
	//	ctrl_out	<TR                  ><FS ><ID ><IMG               ><LE ><ID ><CRC><TR       ><LS ><ID ><IMG               ><FE ><ID ><CRC><TR   >
	//
	//	data		<TR                  ><d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 ><CRC><TR       ><d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 ><CRC><TR   >
	//
	//					                  ________________________________________________________________________________________________
	//	fval_dly2	______________________|                                                                                              |_________
	//                                    _________________________________________              _________________________________________
	//	lval_dly2	______________________|                                       |______________|                                       |_________
	//         		  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___  ___
	//	clk_en		__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__| |__
	//
	//	-------------------------------------------------------------------------------------


	//	===============================================================================================
	//	ref ***提取边沿 延时***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	fval上升沿
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_dly	<= i_fval;
	end
	assign	fval_rise	= (fval_dly==1'b0 && i_fval==1'b1) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_dly==1'b1 && i_fval==1'b0) ? 1'b1 : 1'b0;

	always @ (posedge clk) begin
		fval_rise_dly0	<= fval_rise;
		fval_rise_dly1	<= fval_rise_dly0;
	end

	//	-------------------------------------------------------------------------------------
	//	lval上升沿
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_dly	<= i_lval;
	end
	assign	lval_rise	= (lval_dly==1'b0 && i_lval==1'b1) ? 1'b1 : 1'b0;
	assign	lval_fall	= (lval_dly==1'b1 && i_lval==1'b0) ? 1'b1 : 1'b0;

	always @ (posedge clk) begin
		lval_rise_dly0	<= lval_rise;
		lval_rise_dly1	<= lval_rise_dly0;
		lval_rise_dly2	<= lval_rise_dly1;
	end

	always @ (posedge clk) begin
		lval_fall_dly0	<= lval_fall;
		lval_fall_dly1	<= lval_fall_dly0;
	end

	//	-------------------------------------------------------------------------------------
	//	fval lval 延时
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_shift	<= {fval_shift[1:0],i_fval};
	end
	assign	o_fval	= fval_shift[2];

	always @ (posedge clk) begin
		lval_shift	<= {lval_shift[1:0],i_lval};
	end
	assign	o_lval	= lval_shift[2];

	//	-------------------------------------------------------------------------------------
	//	数据延时3拍
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		pix_data_dly0	<= iv_pix_data;
		pix_data_dly1	<= pix_data_dly0;
		if(i_init_done) begin
			pix_data_dly2	<= pix_data_dly1;
		end
		else begin
			pix_data_dly2	<= ALL_ZERO;
		end
	end
	assign	ov_pix_data	= pix_data_dly2;

	//	===============================================================================================
	//	ref ***生成控制通道***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	fval上升沿
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_init_done) begin
			if(fval_rise_dly1) begin
				ctrl_data_reg	<= FS;
			end
			else if(lval_rise_dly1) begin
				ctrl_data_reg	<= LS;
			end
			else if(lval_rise_dly2) begin
				ctrl_data_reg	<= ID;
			end

			else if(fval_fall) begin
				ctrl_data_reg	<= FE;
			end
			else if(lval_fall) begin
				ctrl_data_reg	<= LE;
			end
			else if(lval_fall_dly0) begin
				ctrl_data_reg	<= ID;
			end
			else if(lval_fall_dly1) begin
				ctrl_data_reg	<= CRC;
			end
			else if(fval_shift[1]&lval_shift[1]) begin
				ctrl_data_reg	<= IMG;
			end
			else begin
				ctrl_data_reg	<= TR;
			end
		end
		else begin
			ctrl_data_reg	<= ALL_ZERO;
		end
	end
	assign	ov_ctrl_data	= ctrl_data_reg;



endmodule
