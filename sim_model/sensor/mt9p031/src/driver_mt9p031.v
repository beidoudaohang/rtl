//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : driver_mt9p031
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
module driver_mt9p031 ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	parameter	IMAGE_SRC				= `TESTCASE.IMAGE_SRC             ;
	parameter	DATA_WIDTH				= `TESTCASE.DATA_WIDTH            ;
	parameter	SENSOR_CLK_DELAY_VALUE	= `TESTCASE.SENSOR_CLK_DELAY_VALUE;
	parameter	CLK_DATA_ALIGN			= `TESTCASE.CLK_DATA_ALIGN        ;
	parameter	FVAL_LVAL_ALIGN			= `TESTCASE.FVAL_LVAL_ALIGN       ;
	parameter	SOURCE_FILE_PATH		= `TESTCASE.SOURCE_FILE_PATH      ;
	parameter	GEN_FILE_EN				= `TESTCASE.GEN_FILE_EN			  ;
	parameter	GEN_FILE_PATH			= `TESTCASE.GEN_FILE_PATH         ;
	parameter	NOISE_EN				= `TESTCASE.NOISE_EN			  ;

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	输入
	//	-------------------------------------------------------------------------------------
	wire							clk_mt9p031	;
	wire							o_fval_bfm	;

	//	-------------------------------------------------------------------------------------
	//	输出
	//	-------------------------------------------------------------------------------------
	wire							clk_sensor_pix		;
	wire							o_fval				;
	wire							o_lval				;
	wire	[DATA_WIDTH-1:0]		ov_pix_data			;


	//	ref ARCHITECTURE
	//	-------------------------------------------------------------------------------------
	//	引用
	//	-------------------------------------------------------------------------------------
	//  ===============================================================================================
	//	ref ***引用***
	//  ===============================================================================================
	assign	clk_mt9p031		= `TESTCASE.clk_mt9p031	;
	assign	o_fval_bfm		= `TESTCASE.o_fval_mt9p031	;
	
	//  -------------------------------------------------------------------------------------
	//	调用 bfm 模型
	//  -------------------------------------------------------------------------------------
	bfm_mt9p031 # (
	.IMAGE_SRC					(IMAGE_SRC					),
	.DATA_WIDTH					(DATA_WIDTH					),
	.SENSOR_CLK_DELAY_VALUE		(SENSOR_CLK_DELAY_VALUE		),
	.CLK_DATA_ALIGN				(CLK_DATA_ALIGN				),
	.FVAL_LVAL_ALIGN			(FVAL_LVAL_ALIGN			),
	.SOURCE_FILE_PATH			(SOURCE_FILE_PATH			),
	.GEN_FILE_EN				(GEN_FILE_EN				),
	.GEN_FILE_PATH				(GEN_FILE_PATH				),
	.NOISE_EN					(NOISE_EN					)
	)
	bfm_mt9p031 (
	.clk						(clk_mt9p031	),
	.o_fval						(o_fval_bfm		)
	);

	//  -------------------------------------------------------------------------------------
	//	例化Sensor模型
	//  -------------------------------------------------------------------------------------
	mt9p031_model # (
	.IMAGE_SRC					(IMAGE_SRC				),
	.DATA_WIDTH					(DATA_WIDTH				),
	.SENSOR_CLK_DELAY_VALUE		(SENSOR_CLK_DELAY_VALUE	),
	.CLK_DATA_ALIGN				(CLK_DATA_ALIGN			),
	.FVAL_LVAL_ALIGN			(FVAL_LVAL_ALIGN		),
	.SOURCE_FILE_PATH			(SOURCE_FILE_PATH		),
	.GEN_FILE_EN				(GEN_FILE_EN			),
	.GEN_FILE_PATH				(GEN_FILE_PATH			),
	.NOISE_EN					(NOISE_EN				)
	)
	mt9p031_model_inst (
	.clk						(clk_mt9p031			),
	.reset						(bfm_mt9p031.reset		),
	.i_pause_en					(bfm_mt9p031.i_pause_en			),
	.i_continue_lval			(bfm_mt9p031.i_continue_lval	),
	.iv_width					(bfm_mt9p031.iv_width			),
	.iv_line_hide				(bfm_mt9p031.iv_line_hide		),
	.iv_height					(bfm_mt9p031.iv_height			),
	.iv_frame_hide				(bfm_mt9p031.iv_frame_hide		),
	.iv_front_porch				(bfm_mt9p031.iv_front_porch		),
	.iv_back_porch				(bfm_mt9p031.iv_back_porch		),
	.o_clk_pix					(clk_sensor_pix			),
	.o_fval						(o_fval					),
	.o_lval						(o_lval					),
	.ov_dout					(ov_pix_data			)
	);






endmodule
