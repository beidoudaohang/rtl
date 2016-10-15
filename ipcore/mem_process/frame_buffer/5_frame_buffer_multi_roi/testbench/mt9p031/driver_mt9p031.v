//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : driver_mt9p031
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/4/3 15:06:43	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
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
	//	����
	//	-------------------------------------------------------------------------------------
	wire							clk_mt9p031	;
	wire							o_fval_bfm	;

	//	-------------------------------------------------------------------------------------
	//	���
	//	-------------------------------------------------------------------------------------
	wire							clk_sensor_pix		;
	wire							o_fval				;
	wire							o_lval				;
	wire	[DATA_WIDTH-1:0]		ov_pix_data			;


	//	ref ARCHITECTURE
	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------
	//  ===============================================================================================
	//	ref ***����***
	//  ===============================================================================================
	assign	clk_mt9p031		= `TESTCASE.clk_mt9p031	;
	assign	o_fval_bfm		= `TESTCASE.o_fval_mt9p031	;
	
	//  -------------------------------------------------------------------------------------
	//	���� bfm ģ��
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
	//	����Sensorģ��
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
