//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : harness
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/3/9 17:18:50	:|  ��ʼ�汾
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
`define		TESTCASE	testcase1
module harness ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	parameter	NUM_DQ_PINS					= `TESTCASE.NUM_DQ_PINS				;
	parameter	MEM_BANKADDR_WIDTH			= `TESTCASE.MEM_BANKADDR_WIDTH			;
	parameter	MEM_ADDR_WIDTH				= `TESTCASE.MEM_ADDR_WIDTH				;
	parameter	DDR3_MEMCLK_FREQ			= `TESTCASE.DDR3_MEMCLK_FREQ			;
	parameter	MEM_ADDR_ORDER				= `TESTCASE.MEM_ADDR_ORDER				;
	parameter	SKIP_IN_TERM_CAL			= `TESTCASE.SKIP_IN_TERM_CAL			;
	parameter	DDR3_MEM_DENSITY			= `TESTCASE.DDR3_MEM_DENSITY			;
	parameter	DDR3_TCK_SPEED				= `TESTCASE.DDR3_TCK_SPEED				;
	parameter	DDR3_SIMULATION				= `TESTCASE.DDR3_SIMULATION			;
	parameter	DDR3_CALIB_SOFT_IP			= `TESTCASE.DDR3_CALIB_SOFT_IP			;
	parameter	DATA_WD						= `TESTCASE.DATA_WD					;
	parameter	GPIF_DATA_WD				= `TESTCASE.GPIF_DATA_WD				;
	parameter	SHORT_REG_WD				= `TESTCASE.SHORT_REG_WD				;
	parameter	REG_WD						= `TESTCASE.REG_WD						;
	parameter	MROI_MAX_NUM				= `TESTCASE.MROI_MAX_NUM				;
	parameter	SENSOR_MAX_WIDTH			= `TESTCASE.SENSOR_MAX_WIDTH			;
	parameter	SENSOR_ALL_PIX_DIV4			= `TESTCASE.SENSOR_ALL_PIX_DIV4		;
	parameter	PTR_WIDTH					= `TESTCASE.PTR_WIDTH					;

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------

	wire										clk_in						;
	wire										i_fval						;
	wire										i_dval						;
	wire										i_leader_flag				;
	wire										i_image_flag				;
	wire										i_chunk_flag				;
	wire										i_trailer_flag				;
	wire	[DATA_WD-1:0]						iv_din						;
	wire										clk_out						;
	wire										i_buf_rd					;
	wire										clk_frame_buf				;
	wire										reset_frame_buf				;
	wire										i_stream_enable				;
	wire	[REG_WD-1:0]						iv_pixel_format				;
	wire	[SHORT_REG_WD-1:0]					iv_frame_depth				;
	wire										i_chunk_mode_active			;
	wire										i_multi_roi_global_en		;

	wire	[MROI_MAX_NUM*REG_WD-1:0]			iv_payload_size_mroi		;
	wire	[MROI_MAX_NUM*REG_WD-1:0]			iv_image_size_mroi			;
	wire	[MROI_MAX_NUM*SHORT_REG_WD-1:0]		iv_roi_pic_width			;
	wire	[MROI_MAX_NUM*SHORT_REG_WD-1:0]		iv_roi_pic_width_mroi		;
	wire	[MROI_MAX_NUM*REG_WD-1:0]			iv_start_mroi				;

	wire										i_async_rst					;
	wire										i_sysclk_2x					;
	wire										i_sysclk_2x_180				;
	wire										i_pll_ce_0					;
	wire										i_pll_ce_90					;
	wire										i_mcb_drp_clk				;
	wire										i_bufpll_mcb_lock			;


	//	-------------------------------------------------------------------------------------
	//	���
	//	-------------------------------------------------------------------------------------
	wire										o_front_fifo_overflow		;
	wire										o_back_buf_empty			;
	wire	[GPIF_DATA_WD-1:0]					ov_dout					;
	wire										o_calib_done				;
	wire										o_wr_error					;
	wire										o_rd_error					;
	wire	[NUM_DQ_PINS-1:0]					mcb1_dram_dq				;
	wire	[MEM_ADDR_WIDTH-1:0]				mcb1_dram_a				;
	wire	[MEM_BANKADDR_WIDTH-1:0]			mcb1_dram_ba				;
	wire										mcb1_dram_ras_n			;
	wire										mcb1_dram_cas_n			;
	wire										mcb1_dram_we_n				;
	wire										mcb1_dram_odt				;
	wire										mcb1_dram_reset_n			;
	wire										mcb1_dram_cke				;
	wire										mcb1_dram_dm				;
	wire										mcb1_dram_udqs				;
	wire										mcb1_dram_udqs_n			;
	wire										mcb1_rzq					;
	wire										mcb1_dram_udm				;
	wire										mcb1_dram_dqs				;
	wire										mcb1_dram_dqs_n			;
	wire										mcb1_dram_ck				;
	wire										mcb1_dram_ck_n				;



	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	���������ź�
	//	-------------------------------------------------------------------------------------
	assign	clk_sensor_pix		= `TESTCASE.clk_sensor_pix	;
	assign	i_fval				= `TESTCASE.o_fval_sensor	;
	assign	i_lval				= `TESTCASE.o_lval_sensor	;
	assign	iv_pix_data			= `TESTCASE.ov_pix_data_sensor	;
	assign	clk_pix				= `TESTCASE.clk_pix	;

	assign	clk_in				= `TESTCASE.clk_in	;
	assign	i_fval				= `TESTCASE.
	assign	i_dval              = `TESTCASE.
	assign	i_leader_flag       = `TESTCASE.
	assign	i_image_flag        = `TESTCASE.
	assign	i_chunk_flag        = `TESTCASE.
	assign	i_trailer_flag      = `TESTCASE.
	assign	iv_din						= `TESTCASE.
	assign	clk_out						= `TESTCASE.
	assign	i_buf_rd                    = `TESTCASE.
	assign	clk_frame_buf               = `TESTCASE.
	assign	reset_frame_buf             = `TESTCASE.
	assign	i_stream_enable             = `TESTCASE.
	assign	iv_pixel_format             = `TESTCASE.
	assign	iv_frame_depth              = `TESTCASE.
	assign	i_chunk_mode_active         = `TESTCASE.
	assign	i_multi_roi_global_en       = `TESTCASE.
	assign	iv_payload_size_mroi        = `TESTCASE.
	assign	iv_image_size_mroi          = `TESTCASE.
	assign	iv_roi_pic_width            = `TESTCASE.
	assign	iv_roi_pic_width_mroi       = `TESTCASE.
	assign	iv_start_mroi               = `TESTCASE.
	assign	i_async_rst                 = `TESTCASE.
	assign	i_sysclk_2x                 = `TESTCASE.
	assign	i_sysclk_2x_180             = `TESTCASE.
	assign	i_pll_ce_0                  = `TESTCASE.
	assign	i_pll_ce_90                 = `TESTCASE.
	assign	i_mcb_drp_clk               = `TESTCASE.
	assign	i_bufpll_mcb_lock           = `TESTCASE.




	assign	i_acquisition_start	= bfm_se_acq.i_acquisition_start	;
	assign	i_stream_enable		= bfm_se_acq.i_stream_enable	;
	assign	i_encrypt_state		= bfm_reg_common.i_encrypt_state	;
	assign	iv_pixel_format		= bfm_reg_common.iv_pixel_format	;
	assign	iv_test_image_sel	= bfm_reg_common.iv_test_image_sel	;

	//	-------------------------------------------------------------------------------------
	//	���� bfm ģ��
	//	-------------------------------------------------------------------------------------
	bfm_se_acq		bfm_se_acq();

	bfm_reg_common # (
	.REG_WD		(`TESTCASE.REG_WD	)
	)
	bfm_reg_common ();


	//	-------------------------------------------------------------------------------------
	//	���� sync_buffer ģ��
	//	-------------------------------------------------------------------------------------
	frame_buffer # (
	.NUM_DQ_PINS				(NUM_DQ_PINS				),
	.MEM_BANKADDR_WIDTH			(MEM_BANKADDR_WIDTH			),
	.MEM_ADDR_WIDTH				(MEM_ADDR_WIDTH				),
	.DDR3_MEMCLK_FREQ			(DDR3_MEMCLK_FREQ			),
	.MEM_ADDR_ORDER				(MEM_ADDR_ORDER				),
	.SKIP_IN_TERM_CAL			(SKIP_IN_TERM_CAL			),
	.DDR3_MEM_DENSITY			(DDR3_MEM_DENSITY			),
	.DDR3_TCK_SPEED				(DDR3_TCK_SPEED				),
	.DDR3_SIMULATION			(DDR3_SIMULATION			),
	.DDR3_CALIB_SOFT_IP			(DDR3_CALIB_SOFT_IP			),
	.DATA_WD					(DATA_WD					),
	.GPIF_DATA_WD				(GPIF_DATA_WD				),
	.SHORT_REG_WD				(SHORT_REG_WD				),
	.REG_WD						(REG_WD						),
	.MROI_MAX_NUM				(MROI_MAX_NUM				),
	.SENSOR_MAX_WIDTH			(SENSOR_MAX_WIDTH			),
	.SENSOR_ALL_PIX_DIV4		(SENSOR_ALL_PIX_DIV4		),
	.PTR_WIDTH					(PTR_WIDTH					)
	)
	frame_buffer_inst (
	.clk_in						(clk_in						),
	.i_fval						(i_fval						),
	.i_dval						(i_dval						),
	.i_leader_flag				(i_leader_flag				),
	.i_image_flag				(i_image_flag				),
	.i_chunk_flag				(i_chunk_flag				),
	.i_trailer_flag				(i_trailer_flag				),
	.iv_din						(iv_din						),
	.o_front_fifo_overflow		(o_front_fifo_overflow		),
	.clk_out					(clk_out					),
	.i_buf_rd					(i_buf_rd					),
	.o_back_buf_empty			(o_back_buf_empty			),
	.ov_dout					(ov_dout					),
	.clk_frame_buf				(clk_frame_buf				),
	.reset_frame_buf			(reset_frame_buf			),
	.i_stream_enable			(i_stream_enable			),
	.iv_pixel_format			(iv_pixel_format			),
	.iv_frame_depth				(iv_frame_depth				),
	.i_chunk_mode_active		(i_chunk_mode_active		),
	.i_multi_roi_global_en		(i_multi_roi_global_en		),
	.iv_payload_size_mroi		(iv_payload_size_mroi		),
	.iv_image_size_mroi			(iv_image_size_mroi			),
	.iv_roi_pic_width			(iv_roi_pic_width			),
	.iv_roi_pic_width_mroi		(iv_roi_pic_width_mroi		),
	.iv_start_mroi				(iv_start_mroi				),
	.i_async_rst				(i_async_rst				),
	.i_sysclk_2x				(i_sysclk_2x				),
	.i_sysclk_2x_180			(i_sysclk_2x_180			),
	.i_pll_ce_0					(i_pll_ce_0					),
	.i_pll_ce_90				(i_pll_ce_90				),
	.i_mcb_drp_clk				(i_mcb_drp_clk				),
	.i_bufpll_mcb_lock			(i_bufpll_mcb_lock			),
	.o_calib_done				(o_calib_done				),
	.o_wr_error					(o_wr_error					),
	.o_rd_error					(o_rd_error					),
	.mcb1_dram_dq				(mcb1_dram_dq				),
	.mcb1_dram_a				(mcb1_dram_a				),
	.mcb1_dram_ba				(mcb1_dram_ba				),
	.mcb1_dram_ras_n			(mcb1_dram_ras_n			),
	.mcb1_dram_cas_n			(mcb1_dram_cas_n			),
	.mcb1_dram_we_n				(mcb1_dram_we_n				),
	.mcb1_dram_odt				(mcb1_dram_odt				),
	.mcb1_dram_reset_n			(mcb1_dram_reset_n			),
	.mcb1_dram_cke				(mcb1_dram_cke				),
	.mcb1_dram_dm				(mcb1_dram_dm				),
	.mcb1_dram_udqs				(mcb1_dram_udqs				),
	.mcb1_dram_udqs_n			(mcb1_dram_udqs_n			),
	.mcb1_rzq					(mcb1_rzq					),
	.mcb1_dram_udm				(mcb1_dram_udm				),
	.mcb1_dram_dqs				(mcb1_dram_dqs				),
	.mcb1_dram_dqs_n			(mcb1_dram_dqs_n			),
	.mcb1_dram_ck				(mcb1_dram_ck				),
	.mcb1_dram_ck_n				(mcb1_dram_ck_n				)
	);


	//generate vcd file
	//initial begin
	//$dumpfile("test.vcd");
	//$dumpvars(1,top_frame_buffer_inst);
	//end

	//for lattice simulation
	//GSR   GSR_INST (.GSR (1'b1)); //< global reset sig>
	//PUR   PUR_INST (.PUR (1'b1)); //<powerup reset sig>



endmodule
