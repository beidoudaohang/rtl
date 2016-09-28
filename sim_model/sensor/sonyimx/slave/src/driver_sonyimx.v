//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : driver_sonyimx
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/4/3 15:06:43	:|  初始版本
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
`define		TESTCASE	testcase_1
module driver_sonyimx ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	parameter	IMAGE_SRC				= `TESTCASE.SONYIMX_IMAGE_SRC			;
	parameter	DATA_WIDTH				= `TESTCASE.SONYIMX_DATA_WIDTH			;
	parameter	VBLANK_LINE				= `TESTCASE.SONYIMX_VBLANK_LINE			;
	parameter	FRAME_INFO_LINE			= `TESTCASE.SONYIMX_FRAME_INFO_LINE		;
	parameter	IGNORE_OB_LINE			= `TESTCASE.SONYIMX_IGNORE_OB_LINE		;
	parameter	VEFFECT_OB_LINE			= `TESTCASE.SONYIMX_VEFFECT_OB_LINE		;
	parameter	SOURCE_FILE_PATH		= `TESTCASE.SONYIMX_SOURCE_FILE_PATH	;
	parameter	GEN_FILE_EN				= `TESTCASE.SONYIMX_GEN_FILE_EN			;
	parameter	GEN_FILE_PATH			= `TESTCASE.SONYIMX_GEN_FILE_PATH		;
	parameter	NOISE_EN				= `TESTCASE.SONYIMX_NOISE_EN			;
	parameter	CHANNEL_NUM				= `TESTCASE.SONYIMX_CHANNEL_NUM			;

	parameter	CLKIN_PERIOD			= `TESTCASE.SONYIMX_CLK_PERIOD			;


	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	输入
	//	-------------------------------------------------------------------------------------
	wire				clk_sonyimx	;
	wire				i_xtrig	;
	wire				i_xhs	;
	wire				i_xvs	;
	wire				i_xclr	;

	//	-------------------------------------------------------------------------------------
	//	输出
	//	-------------------------------------------------------------------------------------
	wire								o_clk_p	;
	wire								o_clk_n	;
	wire	[CHANNEL_NUM-1:0]			ov_data_p	;
	wire	[CHANNEL_NUM-1:0]			ov_data_n	;

	//	-------------------------------------------------------------------------------------
	//	交互
	//	-------------------------------------------------------------------------------------
	wire									clk_ser		;
	wire									clk_para	;
	wire									locked	;
	wire									w_fval		;
	wire									w_lval		;
	wire	[DATA_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data	;


	//	ref ARCHITECTURE
	//	-------------------------------------------------------------------------------------
	//	引用
	//	-------------------------------------------------------------------------------------
	//  ===============================================================================================
	//	ref ***引用***
	//  ===============================================================================================
	assign	clk_sonyimx		= `TESTCASE.clk_sonyimx	;
	assign	i_xtrig			= `TESTCASE.i_xtrig	;
	assign	i_xhs			= `TESTCASE.i_xhs	;
	assign	i_xvs			= `TESTCASE.i_xvs	;
	assign	i_xclr			= `TESTCASE.i_xclr	;

	//  -------------------------------------------------------------------------------------
	//	调用 bfm 模型
	//  -------------------------------------------------------------------------------------
	bfm_sonyimx # (
	.IMAGE_SRC					(IMAGE_SRC					),
	.DATA_WIDTH					(DATA_WIDTH					),
	.SENSOR_CLK_DELAY_VALUE		(0							),
	.CLK_DATA_ALIGN				("FALLING"					),
	.FVAL_LVAL_ALIGN			("TRUE"						),
	.SOURCE_FILE_PATH			(SOURCE_FILE_PATH			),
	.GEN_FILE_EN				(GEN_FILE_EN				),
	.GEN_FILE_PATH				(GEN_FILE_PATH				),
	.NOISE_EN					(NOISE_EN					)
	)
	bfm_sonyimx (
	.clk						(clk_para					),
	.o_fval						(w_fval						)
	);

	//  -------------------------------------------------------------------------------------
	//	时钟模块
	//  -------------------------------------------------------------------------------------
	pll_sonyimx # (
	.DATA_WIDTH					(DATA_WIDTH						),
	.CLKIN_PERIOD				(CLKIN_PERIOD					)
	)
	pll_sonyimx_inst (
	.clk_in						(clk_sonyimx					),
	.pll_reset					(bfm_sonyimx.pll_reset			),
	.clk0_out					(clk_ser						),
	.clk1_out					(clk_para						),
	.locked						(locked							)
	);

	//  -------------------------------------------------------------------------------------
	//	并行数据模块
	//  -------------------------------------------------------------------------------------
	mt9p031_slave_model # (
	.IMAGE_SRC					(IMAGE_SRC						),
	.DATA_WIDTH					(DATA_WIDTH						),
	.CHANNEL_NUM				(CHANNEL_NUM					),
	.VBLANK_LINE				(VBLANK_LINE					),
	.FRAME_INFO_LINE			(FRAME_INFO_LINE				),
	.IGNORE_OB_LINE				(IGNORE_OB_LINE					),
	.VEFFECT_OB_LINE			(VEFFECT_OB_LINE				),
	.SOURCE_FILE_PATH			(SOURCE_FILE_PATH				),
	.GEN_FILE_EN				(GEN_FILE_EN					),
	.GEN_FILE_PATH				(GEN_FILE_PATH					),
	.NOISE_EN					(NOISE_EN						)
	)
	mt9p031_slave_model_inst (
	.clk						(clk_para						),
	.reset						(bfm_sonyimx.reset				),
	.i_xtrig					(i_xtrig						),
	.i_xhs						(i_xhs							),
	.i_xvs						(i_xvs							),
	.i_xclr						(i_xclr							),
	.i_pause_en					(bfm_sonyimx.i_pause_en			),
	.i_continue_lval			(bfm_sonyimx.i_continue_lval	),
	.iv_width					(bfm_sonyimx.iv_width			),
	.iv_height					(bfm_sonyimx.iv_height			),
	.o_fval						(w_fval							),
	.o_lval						(w_lval							),
	.ov_dout					(wv_pix_data					)
	);


	//	-------------------------------------------------------------------------------------
	//	sonyimx模块
	//	-------------------------------------------------------------------------------------
	sonyimx_module # (
	.DATA_WIDTH			(DATA_WIDTH			),
	.CHANNEL_NUM		(CHANNEL_NUM		),
	.CLKIN_PERIOD		(CLKIN_PERIOD		)
	)
	sonyimx_module_inst (
	.clk_para			(clk_para			),
	.clk_ser			(clk_ser			),
	.i_fval				(w_fval				),
	.i_lval				(w_lval				),
	.iv_pix_data		(wv_pix_data		),
	.o_clk_p			(o_clk_p			),
	.o_clk_n			(o_clk_n			),
	.ov_data_p			(ov_data_p			),
	.ov_data_n			(ov_data_n			),
	.o_fval				(				),
	.o_lval				(				)
	);


endmodule
