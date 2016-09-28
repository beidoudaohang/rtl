//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : driver_sonyimx
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
module driver_sonyimx ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	parameter	IMAGE_SRC				= `TESTCASE.SONYIMX_IMAGE_SRC			;
	parameter	DATA_WIDTH				= `TESTCASE.SONYIMX_DATA_WIDTH			;
	parameter	SOURCE_FILE_PATH		= `TESTCASE.SONYIMX_SOURCE_FILE_PATH		;
	parameter	GEN_FILE_EN				= `TESTCASE.SONYIMX_GEN_FILE_EN			;
	parameter	GEN_FILE_PATH			= `TESTCASE.SONYIMX_GEN_FILE_PATH		;
	parameter	NOISE_EN				= `TESTCASE.SONYIMX_NOISE_EN				;
	parameter	CHANNEL_NUM				= `TESTCASE.SONYIMX_CHANNEL_NUM				;

	localparam	CLKIN_PERIOD			= 27.778;	//��Ҫ��FPGA�����sensor��Ƶ��һ��

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------
	wire							clk_sonyimx	;
	wire							o_fval_bfm	;

	//	-------------------------------------------------------------------------------------
	//	���
	//	-------------------------------------------------------------------------------------
	wire								o_clk_p	;
	wire								o_clk_n	;
	wire	[CHANNEL_NUM-1:0]			ov_data_p	;
	wire	[CHANNEL_NUM-1:0]			ov_data_n	;

	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------

	wire									pwr_reset	;
	wire									locked	;
	wire									clk_ser	;
	wire									clk_para	;
	reg		[3:0]							clk_divx_cnt	= 4'b0;
	wire									clk_en	;
	wire									w_fval				;
	wire									w_lval				;
	wire	[DATA_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data			;
	wire									o_fval				;
	wire									o_lval				;
	wire									w_clk_p				;
	wire									w_clk_n		        ;
	//	ref ARCHITECTURE
	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------
	//  ===============================================================================================
	//	ref ***����***
	//  ===============================================================================================
	assign	clk_sonyimx		= `TESTCASE.clk_sonyimx	;
	assign	o_fval_bfm		= w_fval	;

	//  -------------------------------------------------------------------------------------
	//	���� bfm ģ��
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
	.clk						(clk_para		),
	.o_fval						(o_fval_bfm		)
	);

	//  -------------------------------------------------------------------------------------
	//	����ʱ��
	//  -------------------------------------------------------------------------------------
	dcm_sonyimx # (
	.DATA_WIDTH		(DATA_WIDTH		),
	.CLKIN_PERIOD	(CLKIN_PERIOD	)
	)
	dcm_sonyimx_inst (
	.clk_in		(clk_sonyimx		),
	.dcm_reset	(pwr_reset	|	!bfm_sonyimx.pll_init_done	),
	.clk0_out	(clk_ser		),
	.clk1_out	(clk_para		),
	.locked		(locked			)
	);

	//  -------------------------------------------------------------------------------------
	//	�ϵ縴λ�߼�
	//	1.fpga ���سɹ�֮�󣬻�� dcm pll������λ�źţ���λ�źſ����8��ʱ������
	//  -------------------------------------------------------------------------------------
	reg		[3:0]		pwr_cnt	= 4'b0;
	always @ (posedge clk_sonyimx) begin
		if(pwr_cnt[3] == 1'b0) begin
			pwr_cnt	<= pwr_cnt + 1'b1;
		end
	end
	assign	pwr_reset	= !pwr_cnt[3];

	//	-------------------------------------------------------------------------------------
	//	��Ƶ��
	//	--����ʱ��Ƶ���ǲ���ʱ��Ƶ�ʵ�8��
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_ser) begin
		if(clk_divx_cnt==DATA_WIDTH-1) begin
			clk_divx_cnt	<= 4'd0;
		end
		else begin
			clk_divx_cnt	<= clk_divx_cnt + 1'b1;
		end
	end
	assign	clk_en	= (clk_divx_cnt==DATA_WIDTH-1) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	����Sensorģ��
	//  -------------------------------------------------------------------------------------
	mt9p031_model # (
	.IMAGE_SRC					(IMAGE_SRC				),
	.DATA_WIDTH					(DATA_WIDTH				),
	.CHANNEL_NUM				(CHANNEL_NUM			),
	.SENSOR_CLK_DELAY_VALUE		(0						),
	.CLK_DATA_ALIGN				("FALLING"				),
	.FVAL_LVAL_ALIGN			("TRUE"					),
	.SOURCE_FILE_PATH			(SOURCE_FILE_PATH		),
	.GEN_FILE_EN				(GEN_FILE_EN			),
	.GEN_FILE_PATH				(GEN_FILE_PATH			),
	.NOISE_EN					(NOISE_EN				)
	)
	mt9p031_model_inst (
	.clk						(clk_para						),
	.reset						(bfm_sonyimx.reset				),
	.i_pause_en					(bfm_sonyimx.i_pause_en			),
	.i_continue_lval			(bfm_sonyimx.i_continue_lval	),
	.iv_width					(bfm_sonyimx.iv_width			),
	.iv_line_hide				(bfm_sonyimx.iv_line_hide		),
	.iv_height					(bfm_sonyimx.iv_height			),
	.iv_frame_hide				(bfm_sonyimx.iv_frame_hide		),
	.iv_front_porch				(bfm_sonyimx.iv_front_porch		),
	.iv_back_porch				(bfm_sonyimx.iv_back_porch		),
	.o_clk_pix					(clk_sensor_pix					),
	.o_fval						(w_fval							),
	.o_lval						(w_lval							),
	.ov_dout					(wv_pix_data					)
	);

	//	-------------------------------------------------------------------------------------
	//	sonyimx ����ģ��
	//	-------------------------------------------------------------------------------------
	sonyimx_module # (
	.DATA_WIDTH		(DATA_WIDTH		),
	.CHANNEL_NUM	(CHANNEL_NUM	),
	.CLKIN_PERIOD	(CLKIN_PERIOD	)
	)
	sonyimx_module_inst (
	.clk_para		(clk_para		),
	.clk_ser		(clk_ser		),
//	.i_init_done	(bfm_sonyimx.data_init_done	),
	.i_clk_en		(clk_en			),
	.i_fval			(w_fval			),
	.i_lval			(w_lval			),
	.iv_pix_data	(wv_pix_data	),
	.o_clk_p		(o_clk_p		),
	.o_clk_n		(o_clk_n		),
	.o_fval			(o_fval			),
	.o_lval			(o_lval			),
	.ov_data_p		(ov_data_p		),
	.ov_data_n		(ov_data_n		)
	);


endmodule
