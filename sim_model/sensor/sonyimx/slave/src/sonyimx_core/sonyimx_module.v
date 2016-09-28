//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : sonyimx_module
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/10/13 16:27:21	:|  ��ʼ�汾
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

module sonyimx_module # (
	parameter	DATA_WIDTH 		= 10	,
	parameter	CHANNEL_NUM		= 8		,
	parameter	CLKIN_PERIOD	= 27.778
	)
	(
	input									clk_para		,	//����ʱ��
	input									clk_ser			,	//����ʱ��
	input									i_fval			,
	input									i_lval			,
	input	[DATA_WIDTH*CHANNEL_NUM-1:0]	iv_pix_data		,
	output									o_clk_p			,
	output									o_clk_n			,
	output	[CHANNEL_NUM-1:0]				ov_data_p		,
	output	[CHANNEL_NUM-1:0]				ov_data_n		,
	output									o_fval			,
	output									o_lval
	);

	//	ref signals

	wire	[DATA_WIDTH*CHANNEL_NUM-1:0]			wv_pix_data_format  ;

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	���ͬ����
	//	-------------------------------------------------------------------------------------
	format_sonyimx # (
	.DATA_WIDTH		(DATA_WIDTH		),
	.CHANNEL_NUM	(CHANNEL_NUM	)
	)
	format_sonyimx_inst (
	.clk			(clk_para			),
	.i_fval			(i_fval			    ),
	.i_lval			(i_lval			    ),
	.iv_pix_data	(iv_pix_data		),
	.o_fval			(o_fval				),
	.o_lval			(o_lval				),
	.ov_pix_data	(wv_pix_data_format	)
	);

	//	-------------------------------------------------------------------------------------
	//	���л�
	//	-------------------------------------------------------------------------------------
	serializer_sonyimx # (
	.DATA_WIDTH		(DATA_WIDTH			),
	.CHANNEL_NUM	(CHANNEL_NUM		),
	.CLKIN_PERIOD	(CLKIN_PERIOD		)
	)
	serializer_sonyimx_inst (
	.clk			(clk_ser				),
	.iv_pix_data	(wv_pix_data_format		),
	.o_clk_p		(o_clk_p				),
	.o_clk_n		(o_clk_n				),
	.ov_data_p		(ov_data_p				),
	.ov_data_n		(ov_data_n				)
	);


endmodule
