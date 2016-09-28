//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : format_sonyimx
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/10/14 11:40:28	:|  初始版本
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

module format_sonyimx # (
	parameter			DATA_WIDTH			= 10		,	//数据位宽
	parameter			CHANNEL_NUM			= 8			//通道数
	)
	(
	input											clk							,	//时钟
	input											i_fval						,	//场有效
	input											i_lval						,	//行有效
	input		[DATA_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data					,	//像素数据
	output											o_fval						,	//场有效
	output											o_lval						,	//行有效
	output	reg [DATA_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data						//像素数据
	);


	//	ref signals

	localparam		SAV_1_V		= (DATA_WIDTH==10) ? 10'h3FF : 12'hFFF;
	localparam		SAV_2_V		= (DATA_WIDTH==10) ? 10'h000 : 12'h000;
	localparam		SAV_3_V		= (DATA_WIDTH==10) ? 10'h000 : 12'h000;
	localparam		SAV_4_V		= (DATA_WIDTH==10) ? 10'h200 : 12'h800;

	localparam		EAV_1_V		= (DATA_WIDTH==10) ? 10'h3FF : 12'hFFF;
	localparam		EAV_2_V		= (DATA_WIDTH==10) ? 10'h000 : 12'h000;
	localparam		EAV_3_V		= (DATA_WIDTH==10) ? 10'h000 : 12'h000;
	localparam		EAV_4_V		= (DATA_WIDTH==10) ? 10'h274 : 12'h9D0;

	localparam		SAV_1_IV	= (DATA_WIDTH==10) ? 10'h3FF : 12'hFFF;
	localparam		SAV_2_IV	= (DATA_WIDTH==10) ? 10'h000 : 12'h000;
	localparam		SAV_3_IV	= (DATA_WIDTH==10) ? 10'h000 : 12'h000;
	localparam		SAV_4_IV	= (DATA_WIDTH==10) ? 10'h2AC : 12'hAB0;

	localparam		EAV_1_IV	= (DATA_WIDTH==10) ? 10'h3FF : 12'hFFF;
	localparam		EAV_2_IV	= (DATA_WIDTH==10) ? 10'h000 : 12'h000;
	localparam		EAV_3_IV	= (DATA_WIDTH==10) ? 10'h000 : 12'h000;
	localparam		EAV_4_IV	= (DATA_WIDTH==10) ? 10'h2DB : 12'hD60;
//	localparam		SAV_1_V		= 10'h3FF;
//	localparam		SAV_2_V		= 10'h000;
//	localparam		SAV_3_V		= 10'h000;
//	localparam		SAV_4_V		= 10'h200;
//
//	localparam		EAV_1_V		= 10'h3FF;
//	localparam		EAV_2_V		= 10'h000;
//	localparam		EAV_3_V		= 10'h000;
//	localparam		EAV_4_V		= 10'h274;
//
//	localparam		SAV_1_IV	= 10'h3FF;
//	localparam		SAV_2_IV	= 10'h000;
//	localparam		SAV_3_IV	= 10'h000;
//	localparam		SAV_4_IV	= 10'h2AC;
//
//	localparam		EAV_1_IV	= 10'h3FF;
//	localparam		EAV_2_IV	= 10'h000;
//	localparam		EAV_3_IV	= 10'h000;
//	localparam		EAV_4_IV	= 10'h2DB;

	reg		[DATA_WIDTH*CHANNEL_NUM-1:0]		data_reg[3:0];
	reg		[8:0]								fval_shift;
	reg		[8:0]								lval_shift;


	//	ref ARCHITECTURE

	always @ (posedge clk) begin
		fval_shift	<=	{fval_shift[7:0],i_fval};
		lval_shift	<=	{lval_shift[7:0],i_lval};
	end

	always @ (posedge clk) begin
		data_reg[0]	<= iv_pix_data;
		data_reg[1]	<= data_reg[0];
		data_reg[2]	<= data_reg[1];
		data_reg[3]	<= data_reg[2];
	end

	always @ (posedge clk) begin
		case({i_fval,{lval_shift}})
			10'b1000000001	:		ov_pix_data	<= {{SAV_1_V},{SAV_1_V},{SAV_1_V},{SAV_1_V},{SAV_1_V},{SAV_1_V},{SAV_1_V},{SAV_1_V}};
			10'b1000000011	:		ov_pix_data	<= {{SAV_2_V},{SAV_2_V},{SAV_2_V},{SAV_2_V},{SAV_2_V},{SAV_2_V},{SAV_2_V},{SAV_2_V}};
			10'b1000000111	:		ov_pix_data	<= {{SAV_3_V},{SAV_3_V},{SAV_3_V},{SAV_3_V},{SAV_3_V},{SAV_3_V},{SAV_3_V},{SAV_3_V}};
			10'b1000001111	:		ov_pix_data	<= {{SAV_4_V},{SAV_4_V},{SAV_4_V},{SAV_4_V},{SAV_4_V},{SAV_4_V},{SAV_4_V},{SAV_4_V}};
			10'b1111100000	:		ov_pix_data	<= {{EAV_1_V},{EAV_1_V},{EAV_1_V},{EAV_1_V},{EAV_1_V},{EAV_1_V},{EAV_1_V},{EAV_1_V}};
			10'b1111000000	:		ov_pix_data	<= {{EAV_2_V},{EAV_2_V},{EAV_2_V},{EAV_2_V},{EAV_2_V},{EAV_2_V},{EAV_2_V},{EAV_2_V}};
			10'b1110000000	:		ov_pix_data	<= {{EAV_3_V},{EAV_3_V},{EAV_3_V},{EAV_3_V},{EAV_3_V},{EAV_3_V},{EAV_3_V},{EAV_3_V}};
			10'b1100000000	:		ov_pix_data	<= {{EAV_4_V},{EAV_4_V},{EAV_4_V},{EAV_4_V},{EAV_4_V},{EAV_4_V},{EAV_4_V},{EAV_4_V}};
			default			:		ov_pix_data	<= data_reg[3];
		endcase
	end



	assign	o_fval	= fval_shift[5];
	assign	o_lval	= lval_shift[5];


endmodule
