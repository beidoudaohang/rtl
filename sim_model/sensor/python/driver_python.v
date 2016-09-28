//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : driver_python
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
module driver_python ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	parameter	IMAGE_SRC				= `TESTCASE.PYTHON_IMAGE_SRC			;
	parameter	DATA_WIDTH				= `TESTCASE.PYTHON_DATA_WIDTH			;
	parameter	SOURCE_FILE_PATH		= `TESTCASE.PYTHON_SOURCE_FILE_PATH		;
	parameter	GEN_FILE_EN				= `TESTCASE.PYTHON_GEN_FILE_EN			;
	parameter	GEN_FILE_PATH			= `TESTCASE.PYTHON_GEN_FILE_PATH		;
	parameter	NOISE_EN				= `TESTCASE.PYTHON_NOISE_EN				;

	localparam	CHANNEL_NUM				= 4	;

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------
	wire							clk_python	;
	wire							o_fval_bfm	;

	//	-------------------------------------------------------------------------------------
	//	���
	//	-------------------------------------------------------------------------------------
	wire								o_clk_p	;
	wire								o_clk_n	;
	wire	[CHANNEL_NUM-1:0]			ov_data_p	;
	wire	[CHANNEL_NUM-1:0]			ov_data_n	;
	wire								o_ctrl_p	;
	wire								o_ctrl_n	;

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


	//	ref ARCHITECTURE
	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------
	//  ===============================================================================================
	//	ref ***����***
	//  ===============================================================================================
	assign	clk_python		= `TESTCASE.clk_python	;
	assign	o_fval_bfm		= w_fval	;

	//  -------------------------------------------------------------------------------------
	//	���� bfm ģ��
	//  -------------------------------------------------------------------------------------
	bfm_python # (
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
	bfm_python (
	.clk						(clk_para		),
	.o_fval						(o_fval_bfm		)
	);

	//  -------------------------------------------------------------------------------------
	//	����ʱ��
	//  -------------------------------------------------------------------------------------
	dcm_python # (
	.DATA_WIDTH	(DATA_WIDTH		)
	)
	dcm_python_inst (
	.clk_in		(clk_python		),
	.dcm_reset	(pwr_reset	|	!bfm_python.pll_init_done	),
	.clk0_out	(clk_para		),
	.clk_fx_out	(clk_ser		),
	.locked		(locked			)
	);

	//  -------------------------------------------------------------------------------------
	//	�ϵ縴λ�߼�
	//	1.fpga ���سɹ�֮�󣬻�� dcm pll������λ�źţ���λ�źſ����8��ʱ������
	//  -------------------------------------------------------------------------------------
	reg		[3:0]		pwr_cnt	= 4'b0;
	always @ (posedge clk_python) begin
		if(pwr_cnt[3] == 1'b0) begin
			pwr_cnt	<= pwr_cnt + 1'b1;
		end
	end
	assign	pwr_reset	= !pwr_cnt[3];

	//	-------------------------------------------------------------------------------------
	//	��Ƶ��
	//	--����ʱ��Ƶ���ǲ���ʱ��Ƶ�ʵ�10�� 8��
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
	.reset						(bfm_python.reset				),
	.i_pause_en					(bfm_python.i_pause_en			),
	.i_continue_lval			(bfm_python.i_continue_lval	),
	.iv_width					(bfm_python.iv_width			),
	.iv_line_hide				(bfm_python.iv_line_hide		),
	.iv_height					(bfm_python.iv_height			),
	.iv_frame_hide				(bfm_python.iv_frame_hide		),
	.iv_front_porch				(bfm_python.iv_front_porch		),
	.iv_back_porch				(bfm_python.iv_back_porch		),
	.o_clk_pix					(clk_sensor_pix					),
	.o_fval						(w_fval							),
	.o_lval						(w_lval							),
	.ov_dout					(wv_pix_data					)
	);

	//	-------------------------------------------------------------------------------------
	//	python ����ģ��
	//	-------------------------------------------------------------------------------------
	python_module # (
	.DATA_WIDTH		(DATA_WIDTH		),
	.CHANNEL_NUM	(CHANNEL_NUM	)
	)
	python_module_inst (
	.clk_para		(clk_para		),
	.clk_ser		(clk_ser		),
	.i_init_done	(bfm_python.data_init_done	),
	.i_clk_en		(clk_en			),
	.i_fval			(w_fval			),
	.i_lval			(w_lval			),
	.iv_pix_data	(wv_pix_data	),
	.o_clk_p		(o_clk_p		),
	.o_clk_n		(o_clk_n		),
	.ov_data_p		(ov_data_p		),
	.ov_data_n		(ov_data_n		),
	.o_ctrl_p		(o_ctrl_p		),
	.o_ctrl_n		(o_ctrl_n		)
	);


endmodule
