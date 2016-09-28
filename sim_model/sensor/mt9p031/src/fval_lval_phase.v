//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : fval_lval_phase
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/4/10 14:13:37	:|  初始版本
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

module fval_lval_phase # (
	parameter			DATA_WIDTH	= 8			//数据宽度
	)
	(
	input						clk			,	//时钟
	input						reset		,	//复位
	input						i_fval		,	//场有效
	input						i_lval		,	//行有效
	input	[DATA_WIDTH-1:0]	iv_din		,	//输入数据
	output						o_fval		,	//场有效
	output						o_lval		,	//行有效
	output	[DATA_WIDTH-1:0]	ov_dout			//输出数据
	);

	//	ref signals
	reg		[5:0]					fval_shift		= 6'b0;
	reg		[2:0]					lval_shift		= 3'b0;
	reg		[DATA_WIDTH-1:0]		pix_data_dly0	= {DATA_WIDTH{1'b0}};
	reg		[DATA_WIDTH-1:0]		pix_data_dly1	= {DATA_WIDTH{1'b0}};
	reg		[DATA_WIDTH-1:0]		pix_data_dly2	= {DATA_WIDTH{1'b0}};
	
	
	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	处理行场信号和数据，使之对齐
	//  -------------------------------------------------------------------------------------
	//	-------------------------------------------------------------------------------------
	//	场信号总共延时6拍
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_shift	<= {fval_shift[4:0],i_fval};
	end

	//	-------------------------------------------------------------------------------------
	//	行信号总共延时3拍
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_shift	<= {lval_shift[1:0],i_lval};
	end

	//	-------------------------------------------------------------------------------------
	//	数据信号总共延时3拍
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		pix_data_dly0	<= iv_din;
		pix_data_dly1	<= pix_data_dly0;
		pix_data_dly2	<= pix_data_dly1;
	end

	assign	o_fval		= fval_shift[5] & i_fval;
	assign	o_lval		= lval_shift[2];
	assign	ov_dout		= pix_data_dly2;



endmodule
