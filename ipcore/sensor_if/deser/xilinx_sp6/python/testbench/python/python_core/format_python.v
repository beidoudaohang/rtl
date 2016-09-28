//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : format_python
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

module format_python # (
	parameter			DATA_WIDTH			= 8		,	//数据位宽
	parameter			CHANNEL_NUM			= 4			//通道数
	)
	(
	input										clk							,	//时钟
	input										i_fval						,	//场有效
	input										i_lval						,	//行有效
	input	[DATA_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data					,	//像素数据
	output										o_fval						,	//场有效
	output										o_lval						,	//行有效
	output	[DATA_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data						//像素数据
	);


	//	ref signals

	localparam		TR	= (DATA_WIDTH==10) ? 10'h3a6 : 8'he9;

	reg		[DATA_WIDTH*CHANNEL_NUM-1:0]		data_reg	= 'b0;
	reg											fval_dly	= 1'b0;
	reg											lval_dly	= 1'b0;


	//	ref ARCHITECTURE

	always @ (posedge clk) begin
		if(i_fval==1'b0 || i_lval==1'b0) begin
			data_reg	<= {CHANNEL_NUM{TR}};
		end
		else begin
			data_reg	<= iv_pix_data;
		end
	end
	assign	ov_pix_data	= data_reg;

	always @ (posedge clk) begin
		fval_dly	<= i_fval;
	end
	assign	o_fval	= fval_dly;

	always @ (posedge clk) begin
		lval_dly	<= i_lval;
	end
	assign	o_lval	= lval_dly;


endmodule
