//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : sonyimx_module
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/10/13 16:27:21	:|  初始版本
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

module sonyimx_module # (
	parameter	DATA_WIDTH 		= 10	,
	parameter	CHANNEL_NUM		= 8		,
	parameter	CLKIN_PERIOD	= 27.778
	)
	(
	input									clk_para		,	//并行时钟
	input									clk_ser			,	//串行时钟
	input									i_fval			,
	input									i_lval			,
	input	[DATA_WIDTH*CHANNEL_NUM-1:0]	iv_pix_data		,
	output									o_clk_p			,
	output									o_clk_n			,
	output	[CHANNEL_NUM-1:0]				ov_data_p		,
	output	[CHANNEL_NUM-1:0]				ov_data_n		,
	output									o_fval			,
	output									o_lval
	);

	//	ref signals

	wire	[DATA_WIDTH*CHANNEL_NUM-1:0]			wv_pix_data_format  ;

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	添加同步字
	//	-------------------------------------------------------------------------------------
	format_sonyimx # (
	.DATA_WIDTH		(DATA_WIDTH		),
	.CHANNEL_NUM	(CHANNEL_NUM	)
	)
	format_sonyimx_inst (
	.clk			(clk_para			),
	.i_fval			(i_fval			    ),
	.i_lval			(i_lval			    ),
	.iv_pix_data	(iv_pix_data		),
	.o_fval			(o_fval				),
	.o_lval			(o_lval				),
	.ov_pix_data	(wv_pix_data_format	)
	);

	//	-------------------------------------------------------------------------------------
	//	串行化
	//	-------------------------------------------------------------------------------------
	serializer_sonyimx # (
	.DATA_WIDTH		(DATA_WIDTH			),
	.CHANNEL_NUM	(CHANNEL_NUM		),
	.CLKIN_PERIOD	(CLKIN_PERIOD		)
	)
	serializer_sonyimx_inst (
	.clk			(clk_ser				),
	.iv_pix_data	(wv_pix_data_format		),
	.o_clk_p		(o_clk_p				),
	.o_clk_n		(o_clk_n				),
	.ov_data_p		(ov_data_p				),
	.ov_data_n		(ov_data_n				)
	);


endmodule
