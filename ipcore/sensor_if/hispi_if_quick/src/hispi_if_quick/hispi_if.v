//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : hispi_if
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/10/27 13:37:39	:|  ��ʼ�汾
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

module hispi_if # (
	parameter		SER_FIRST_BIT			= "LSB"		,	//"LSB" or "MSB" , first bit to the receiver
	parameter		DESER_WIDTH				= 6			,	//�⴮����
	parameter		CHANNEL_NUM				= 4			,	//ͨ����
	parameter		SENSOR_DAT_WIDTH		= 12		,	//�������ݿ��
	parameter		TD_OFFSET_WIDTH			= 13		
	)
	(
	input										clk					,	//ʱ��
	input										reset				,	//��λ
	input	[DESER_WIDTH*CHANNEL_NUM-1:0]		iv_data				,	//���벢������
	input	[TD_OFFSET_WIDTH-1:0]				iv_td_offset_x_start,	//��ʼx
	input	[TD_OFFSET_WIDTH-1:0]				iv_td_offset_width	,	//���
	input	[TD_OFFSET_WIDTH-1:0]				iv_td_offset_y_start,	//��ʼy����δ�ã�
	input	[TD_OFFSET_WIDTH-1:0]				iv_td_offset_height	,	//�߶ȣ���δ�ã�
	output										o_first_frame_detect,	//��⵽��һ������֡
	output										o_clk_en			,	//ʱ��ʹ���ź�
	output										o_fval				,	//�������Ч�ź�
	output										o_lval				,	//�������Ч�ź�
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	ov_pix_data		 		//�����������

	);

	//	ref signals
	wire												w_clk_en	;
	wire												w_sync		;
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]			wv_data		;


	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	ͨ������ģ��
	//	-------------------------------------------------------------------------------------
	word_aligner_top # (
	.SER_FIRST_BIT	(SER_FIRST_BIT	),
	.DESER_WIDTH	(DESER_WIDTH	),
	.CHANNEL_NUM	(CHANNEL_NUM	)
	)
	word_aligner_top_inst (
	.clk			(clk			),
	.reset			(reset			),
	.iv_data		(iv_data		),
	.o_clk_en		(w_clk_en		),
	.o_sync			(w_sync			),
	.ov_data		(wv_data		)
	);

	//	-------------------------------------------------------------------------------------
	//	ʱ�����ģ��
	//	-------------------------------------------------------------------------------------
	timing_decoder # (
	.SER_FIRST_BIT			(SER_FIRST_BIT			),
	.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH		),
	.CHANNEL_NUM			(CHANNEL_NUM			),
	.TD_OFFSET_WIDTH		(TD_OFFSET_WIDTH		)
	)
	timing_decoder_inst (
	.clk					(clk					),
	.reset					(reset					),
	.i_clk_en				(w_clk_en				),
	.i_sync					(w_sync					),
	.iv_data				(wv_data				),
	.iv_td_offset_x_start	(iv_td_offset_x_start	),	//��ʼx
	.iv_td_offset_width		(iv_td_offset_width		),	//���
	.iv_td_offset_y_start	(iv_td_offset_y_start	),	//��ʼy����δ�ã�
	.iv_td_offset_height	(iv_td_offset_height	),	//�߶ȣ���δ�ã�
	.o_first_frame_detect	(o_first_frame_detect	),
	.o_clk_en				(o_clk_en				),
	.o_fval					(o_fval					),
	.o_lval					(o_lval					),
	.ov_pix_data			(ov_pix_data			)
	);


endmodule
