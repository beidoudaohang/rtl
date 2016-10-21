//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : driver_clock_reset
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 	:|  ��ʼ�汾
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

module driver_u3v_format ();


	//	ref signals
	parameter	PIX_CLK_FREQ_KHZ			= `TESTCASE.PIX_CLK_FREQ_KHZ			;
	parameter	FVAL_TS_STABLE_NS			= `TESTCASE.FVAL_TS_STABLE_NS			;
	parameter	DATA_WD						= `TESTCASE.DATA_WD						;
	parameter	SHORT_REG_WD				= `TESTCASE.SHORT_REG_WD				;
	parameter	REG_WD						= `TESTCASE.REG_WD						;
	parameter	LONG_REG_WD					= `TESTCASE.LONG_REG_WD					;
	parameter	MROI_MAX_NUM				= `TESTCASE.MROI_MAX_NUM				;


	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------
	wire											clk							;
	wire											reset						;
	wire											i_fval						;
	wire											i_data_valid				;
	wire	[DATA_WD-1:0]							iv_data						;
	wire											i_stream_enable				;
	wire											i_acquisition_start			;
	wire	[REG_WD-1:0]							iv_pixel_format				;
	wire											i_chunk_mode_active			;
	wire											i_chunkid_en_ts				;
	wire											i_chunkid_en_fid			;
	wire	[LONG_REG_WD-1:0]						iv_timestamp				;
	wire	[REG_WD-1:0]							iv_chunk_size_img			;
	wire											i_multi_roi_global_en		;
	wire	[MROI_MAX_NUM-1:0]						iv_multi_roi_single_en		;
	wire	[REG_WD*MROI_MAX_NUM-1:0]				iv_chunk_size_img_mroi		;
	wire	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_offset_x_mroi			;
	wire	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_offset_y_mroi			;
	wire	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_size_x_mroi				;
	wire	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_size_y_mroi				;
	wire	[REG_WD*MROI_MAX_NUM-1:0]				iv_trailer_size_y_mroi		;

	//	-------------------------------------------------------------------------------------
	//	���
	//	-------------------------------------------------------------------------------------
	wire											o_fval						;
	wire											o_data_valid				;
	wire											o_leader_flag				;
	wire											o_image_flag				;
	wire											o_chunk_flag				;
	wire											o_trailer_flag				;
	wire											o_trailer_final_flag		;
	wire	[DATA_WD-1:0]							ov_data						;


	//	ref ARCHITECTURE


	//	-------------------------------------------------------------------------------------
	//	���������ź�
	//	-------------------------------------------------------------------------------------
	assign	clk							= `TESTCASE.clk_u3v;
	assign	reset						= `TESTCASE.reset_u3v;

	assign	i_fval						= `TESTCASE.i_fval_u3v;
	assign	i_data_valid				= `TESTCASE.i_data_valid_u3v;
	assign	iv_data						= `TESTCASE.iv_data_u3v;

	assign	i_stream_enable				= `TESTCASE.i_stream_enable;
	assign	i_acquisition_start			= `TESTCASE.i_acquisition_start;
	assign	iv_pixel_format				= `TESTCASE.iv_pixel_format;
	assign	i_chunk_mode_active			= `TESTCASE.i_chunk_mode_active;
	assign	i_chunkid_en_ts				= `TESTCASE.i_chunkid_en_ts;
	assign	i_chunkid_en_fid			= `TESTCASE.i_chunkid_en_fid;

	assign	iv_chunk_size_img			= `TESTCASE.iv_chunk_size_img;
	assign	i_multi_roi_global_en		= `TESTCASE.i_multi_roi_global_en;
	assign	iv_multi_roi_single_en		= `TESTCASE.iv_multi_roi_single_en;
	assign	iv_chunk_size_img_mroi		= `TESTCASE.iv_chunk_size_img_mroi;
	assign	iv_offset_x_mroi			= `TESTCASE.iv_offset_x_mroi;
	assign	iv_offset_y_mroi			= `TESTCASE.iv_offset_y_mroi;
	assign	iv_size_x_mroi				= `TESTCASE.iv_size_x_mroi;
	assign	iv_size_y_mroi				= `TESTCASE.iv_size_y_mroi;
	assign	iv_trailer_size_y_mroi		= {16'b0,`TESTCASE.iv_size_y_mroi};

	assign	iv_timestamp				= `TESTCASE.iv_timestamp_u3v;


	//	-------------------------------------------------------------------------------------
	//  u3v_format ����
	//	-------------------------------------------------------------------------------------
	u3v_format # (
	.PIX_CLK_FREQ_KHZ					(PIX_CLK_FREQ_KHZ			),
	.FVAL_TS_STABLE_NS					(FVAL_TS_STABLE_NS			),
	.DATA_WD							(DATA_WD					),
	.SHORT_REG_WD						(SHORT_REG_WD				),
	.REG_WD								(REG_WD						),
	.LONG_REG_WD						(LONG_REG_WD				),
	.MROI_MAX_NUM						(MROI_MAX_NUM				)
	)
	u3v_format_inst (
	.clk								(clk						),
	.reset								(reset						),
	.i_fval								(i_fval						),
	.i_data_valid						(i_data_valid				),
	.iv_data							(iv_data					),
	.i_stream_enable					(i_stream_enable			),
	.i_acquisition_start				(i_acquisition_start		),
	.iv_pixel_format					(iv_pixel_format			),
	.i_chunk_mode_active				(i_chunk_mode_active		),
	.i_chunkid_en_ts					(i_chunkid_en_ts			),
	.i_chunkid_en_fid					(i_chunkid_en_fid			),
	.iv_timestamp						(iv_timestamp				),
	.iv_chunk_size_img					(iv_chunk_size_img			),
	.i_multi_roi_global_en				(i_multi_roi_global_en		),
	.iv_multi_roi_single_en				(iv_multi_roi_single_en		),
	.iv_chunk_size_img_mroi				(iv_chunk_size_img_mroi		),
	.iv_offset_x_mroi					(iv_offset_x_mroi			),
	.iv_offset_y_mroi					(iv_offset_y_mroi			),
	.iv_size_x_mroi						(iv_size_x_mroi				),
	.iv_size_y_mroi						(iv_size_y_mroi				),
	.iv_trailer_size_y_mroi				(iv_trailer_size_y_mroi		),
	.o_fval								(o_fval						),
	.o_data_valid						(o_data_valid				),
	.o_leader_flag						(o_leader_flag				),
	.o_image_flag						(o_image_flag				),
	.o_chunk_flag						(o_chunk_flag				),
	.o_trailer_flag						(o_trailer_flag				),
	.o_trailer_final_flag				(o_trailer_final_flag		),
	.ov_data							(ov_data					)
	);










endmodule
