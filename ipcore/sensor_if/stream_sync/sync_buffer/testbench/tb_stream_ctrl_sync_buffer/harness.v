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
	parameter	SENSOR_DAT_WIDTH	= `TESTCASE.SENSOR_DAT_WIDTH	;
	parameter	CHANNEL_NUM			= `TESTCASE.CHANNEL_NUM	;
	parameter	REG_WD				= `TESTCASE.REG_WD			;

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------
	wire											clk_sensor_pix	;
	wire											i_fval	;
	wire											i_lval	;
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data	;
	wire											clk_pix	;
	wire											i_acquisition_start	;
	wire											i_stream_enable	;
	wire											i_encrypt_state	;
	wire	[REG_WD-1:0]							iv_pixel_format	;
	wire	[2:0]									iv_test_image_sel	;
	//	-------------------------------------------------------------------------------------
	//	���
	//	-------------------------------------------------------------------------------------
	wire											o_fval				;
	wire											o_lval				;
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data			;

	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------
	wire											w_enable	;

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	���������ź�
	//	-------------------------------------------------------------------------------------
	assign	clk_sensor_pix		= `TESTCASE.clk_sensor_pix	;
	assign	i_clk_en			= `TESTCASE.i_clk_en	;
	assign	i_fval				= `TESTCASE.o_fval_sensor	;
	assign	i_lval				= `TESTCASE.o_lval_sensor	;
	assign	iv_pix_data			= `TESTCASE.ov_pix_data_sensor	;
	assign	clk_pix				= `TESTCASE.clk_pix	;

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
	//	���� stream_ctrl ģ��
	//	-------------------------------------------------------------------------------------
	stream_ctrl # (
	.REG_WD					(REG_WD				)
	)
	stream_ctrl_inst (
	.clk_pix				(clk_pix			),
	.i_fval					(i_fval				),
	.i_fval_sync			(o_fval				),
	.i_acquisition_start	(i_acquisition_start),
	.i_stream_enable		(i_stream_enable	),
	.i_encrypt_state		(i_encrypt_state	),
	.iv_pixel_format		(iv_pixel_format	),
	.iv_test_image_sel		(iv_test_image_sel	),
	.o_enable				(w_enable			),
	.o_full_frame_state		(	),
	.ov_pixel_format		(	),
	.ov_test_image_sel		(	)
	);

	//	-------------------------------------------------------------------------------------
	//	���� sync_buffer ģ��
	//	-------------------------------------------------------------------------------------
	sync_buffer # (
	.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH		),
	.CHANNEL_NUM			(CHANNEL_NUM			),
	.REG_WD					(REG_WD					)
	)
	sync_buffer_inst (
	.clk_sensor_pix			(clk_sensor_pix			),
	.i_clk_en				(i_clk_en				),
	.i_fval					(i_fval					),
	.i_lval					(i_lval					),
	.iv_pix_data			(iv_pix_data			),
	.i_enable				(w_enable				),
	.clk_pix				(clk_pix				),
	.o_fval					(o_fval					),
	.o_lval					(o_lval					),
	.ov_pix_data			(ov_pix_data			)
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