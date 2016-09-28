//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : ad9970_module
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/7/15 10:48:46	:|  ��ʼ�汾
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

module ad9970_module # (
	parameter	CLK_UNIT_VENDOR		= "xilinx"	,	//ʱ��������"xilinx" "lattice"
	parameter	CLK_FREQ_MHZ		= 45			//����ʱ��Ƶ��
	)
	(
	//AD9970�����ź�
	input				cli					,	//����ʱ��
	input				i_vd				,	//ad9970��VD�ź�
	input				i_hd				,	//ad9970��HD�ź�

	//ad9970���üĴ���
	input				i_lvds_pattern_en	,	//lvds������ʹ��
	input	[15:0]		iv_lvds_pattern		,	//lvds������
	input				i_sync_align_loc	,	//ͬ����λ�ã�0���ұߣ�1�����
	input	[12:0]		iv_sync_start_loc	,	//ͬ������ʼλ��
	input	[15:0]		iv_sync_word0		,	//Synchronization Word 0 data bits.
	input	[15:0]		iv_sync_word1		,	//Synchronization Word 1 data bits.
	input	[15:0]		iv_sync_word2		,	//Synchronization Word 2 data bits.
	input	[15:0]		iv_sync_word3		,	//Synchronization Word 3 data bits.
	input	[15:0]		iv_sync_word4		,	//Synchronization Word 4 data bits.
	input	[15:0]		iv_sync_word5		,	//Synchronization Word 5 data bits.
	input	[15:0]		iv_sync_word6		,	//Synchronization Word 6 data bits.

	input	[12:0]		iv_hblk_tog1		,	//hblk���
	input	[12:0]		iv_hblk_tog2		,	//hblk�յ�
	input				i_hl_mask_pol		,	//hblk��Чʱ��hl�ĵ�ƽ
	input				i_h1_mask_pol		,	//hblk��Чʱ��h1�ĵ�ƽ
	input				i_h2_mask_pol		,	//hblk��Чʱ��h2�ĵ�ƽ

	input	[3:0]		iv_tclk_delay		,	//TCLK rising edge delay,0 = default with no delay,1 LSB = 1/16 cycle of internal TCLK when operating in double port mode,1 LSB = 1/8 cycle of internal TCLK when operating in single port mode
	
	//ˮƽ����
	output				o_hl				,	//hlˮƽ����
	output				o_h1				,	//h1ˮƽ����
	output				o_h2				,	//h2ˮƽ����
	output				o_rg				,	//rgˮƽ����
	input	[13:0]		iv_pix_data			,	//��������
	//lvds�˿�
	output				o_tckp				,	//���ʱ�� p��
	output				o_tckn				,	//���ʱ�� n��
	output				o_dout0p			,	//�������0 p��
	output				o_dout0n			,	//�������0 n��
	output				o_dout1p			,	//�������1 p��
	output				o_dout1n				//�������1 n��
	);

	//	ref signals
	wire				clk				;
	wire				clk_ser			;
	wire				lock			;
	wire				reset_ser		;
	wire				w_sync_word_sel	;
	wire	[15:0]		wv_sync_word	;

	wire	[13:0]		wv_pix_data_adc	;
	wire	[15:0]		wv_pix_data_latch	;


	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***ad9970 ����ģ��***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	ʱ�Ӵ���ģ��
	//	-------------------------------------------------------------------------------------
	ad_clock_unit # (
	.CLK_UNIT_VENDOR	(CLK_UNIT_VENDOR	)
	)
	ad_clock_unit_inst (
	.cli				(cli				),
	.clk				(clk				),
	.clk_ser			(clk_ser			),
	.reset_ser			(reset_ser			)
	);

	//	-------------------------------------------------------------------------------------
	//	ʱ�����ģ��
	//	-------------------------------------------------------------------------------------
	ad_timing_generation ad_timing_generation_inst (
	.clk				(clk				),
	.i_vd				(i_vd				),
	.i_hd				(i_hd				),
	.i_sync_align_loc	(i_sync_align_loc	),
	.iv_sync_start_loc	(iv_sync_start_loc	),
	.iv_sync_word0		(iv_sync_word0		),
	.iv_sync_word1		(iv_sync_word1		),
	.iv_sync_word2		(iv_sync_word2		),
	.iv_sync_word3		(iv_sync_word3		),
	.iv_sync_word4		(iv_sync_word4		),
	.iv_sync_word5		(iv_sync_word5		),
	.iv_sync_word6		(iv_sync_word6		),
	.o_sync_word_sel	(w_sync_word_sel	),
	.ov_sync_word		(wv_sync_word		),
	.iv_hblk_tog1		(iv_hblk_tog1		),
	.iv_hblk_tog2		(iv_hblk_tog2		),
	.o_hblk_n			(w_hblk_n      		)
	);

	//	-------------------------------------------------------------------------------------
	//	ˮƽ����
	//	-------------------------------------------------------------------------------------
	ad_horizontal_driver ad_horizontal_driver_inst (
	.clk				(clk_ser			),
	.reset				(reset_ser			),
	.i_hl_mask_pol		(i_hl_mask_pol		),
	.i_h1_mask_pol		(i_h1_mask_pol		),
	.i_h2_mask_pol		(i_h2_mask_pol		),
	.i_hblk_n			(w_hblk_n			),
	.o_hl				(o_hl				),
	.o_h1				(o_h1				),
	.o_h2				(o_h2				),
	.o_rg				(o_rg				)
	);

	//	===============================================================================================
	//	ref ***ad9970 ����ͨ��***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	14bit adc
	//	-------------------------------------------------------------------------------------
	ad_14bit_adc ad_14bit_adc_inst (
	.clk				(clk				),
	.iv_pix_data		(iv_pix_data		),
	.ov_pix_data		(wv_pix_data_adc	)
	);

	//	-------------------------------------------------------------------------------------
	//	output latch
	//	-------------------------------------------------------------------------------------
	ad_output_latch ad_output_latch_inst (
	.clk				(clk				),
	.iv_pix_data		(wv_pix_data_adc	),
	.i_lvds_pattern_en	(i_lvds_pattern_en	),
	.iv_lvds_pattern	(iv_lvds_pattern	),
	.i_sync_word_sel	(w_sync_word_sel	),
	.iv_sync_word		(wv_sync_word		),
	.ov_pix_data		(wv_pix_data_latch	)
	);

	//	-------------------------------------------------------------------------------------
	//	lvds serializer
	//	-------------------------------------------------------------------------------------
	ad_lvds_serializer ad_lvds_serializer_inst (
	.clk				(clk_ser			),
	.reset				(reset_ser			),
	.iv_pix_data		(wv_pix_data_latch	),
	.o_tckp				(o_tckp				),
	.o_tckn				(o_tckn				),
	.o_dout0p			(o_dout0p			),
	.o_dout0n			(o_dout0n			),
	.o_dout1p			(o_dout1p			),
	.o_dout1n			(o_dout1n			)
	);

endmodule
