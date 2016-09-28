//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : ccd_sharp_module
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/8/10 10:18:16	:|  ��ʼ�汾
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

module ccd_sharp_module # (
	parameter	DATA_WIDTH			= 14				,	//��������λ��
	parameter	IMAGE_WIDTH			= 1320				,	//ͼ����
	parameter	IMAGE_HEIGHT		= 976				,	//ͼ��߶�
	parameter	BLACK_VFRONT		= 8					,	//��ͷ���и���
	parameter	BLACK_VREAR			= 2					,	//��β���и���
	parameter	BLACK_HFRONT		= 12				,	//��ͷ�����ظ���
	parameter	BLACK_HREAR			= 40				,	//��β�����ظ���
	parameter	DUMMY_VFRONT		= 2					,	//��ͷ���и���
	parameter	DUMMY_VREAR			= 0					,	//��β���и���
	parameter	DUMMY_HFRONT		= 4					,	//��ͷ�����ظ���
	parameter	DUMMY_HREAR			= 0					,	//��β�����ظ���
	parameter	DUMMY_INIT_VALUE	= 16				,	//DUMMY��ʼֵ
	parameter	BLACK_INIT_VALUE	= 32				,	//BLACK��ʼֵ
	parameter	IMAGE_SOURCE		= "RANDOM"			,	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC" or "PIX_INC"
	parameter	SOURCE_FILE_PATH	= "source_file/"		//����Դ�ļ�·��
	)
	(
	input							xv1			,	//��ֱ����
	input							xv2			,	//��ֱ����
	input							xv3			,	//��ֱ����
	input							xv4			,	//��ֱ����
	input							xsg			,	//�ع�����ź�

	input							hl			,	//ˮƽ����
	input							h1			,	//ˮƽ����
	input							h2			,	//ˮƽ����
	input							rs			,	//ˮƽ����

	output	[DATA_WIDTH-1:0]		ov_pix_data		//�����������
	);

	//	ref signals
	wire	w_line_change	;
	wire	w_frame_change	;

	//	ref ARCHITECTURE
	//	-------------------------------------------------------------------------------------
	//	��ֱ��תģ��
	//	-------------------------------------------------------------------------------------
	ccd_sharp_vshift ccd_sharp_vshift_inst (
	.xv1			(xv1			),
	.xv2			(xv2			),
	.xv3			(xv3			),
	.xv4			(xv4			),
	.xsg			(xsg			),
	.o_line_change	(w_line_change	),
	.o_frame_change	(w_frame_change	)
	);

	//	-------------------------------------------------------------------------------------
	//	ˮƽ��תģ��
	//	-------------------------------------------------------------------------------------
	ccd_sharp_hshift # (
	.DATA_WIDTH			(DATA_WIDTH			),
	.IMAGE_WIDTH		(IMAGE_WIDTH		),
	.BLACK_VFRONT		(BLACK_VFRONT		),
	.BLACK_VREAR		(BLACK_VREAR		),
	.BLACK_HFRONT		(BLACK_HFRONT		),
	.BLACK_HREAR		(BLACK_HREAR		),
	.DUMMY_VFRONT		(DUMMY_VFRONT		),
	.DUMMY_VREAR		(DUMMY_VREAR		),
	.DUMMY_HFRONT		(DUMMY_HFRONT		),
	.DUMMY_HREAR		(DUMMY_HREAR		),
	.DUMMY_INIT_VALUE	(DUMMY_INIT_VALUE	),
	.BLACK_INIT_VALUE	(BLACK_INIT_VALUE	),
	.IMAGE_SOURCE		(IMAGE_SOURCE		),
	.SOURCE_FILE_PATH	(SOURCE_FILE_PATH	)
	)
	ccd_sharp_hshift_inst (
	.i_line_change		(w_line_change		),
	.i_frame_change		(w_frame_change		),
	.hl					(hl					),
	.h1					(h1					),
	.h2					(h2					),
	.rs					(rs					),
	.ov_pix_data		(ov_pix_data		)
	);

endmodule
