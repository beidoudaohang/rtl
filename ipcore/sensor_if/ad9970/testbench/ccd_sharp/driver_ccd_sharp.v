//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : driver_ccd_sharp
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/8/10 10:17:40	:|  ��ʼ�汾
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
module driver_ccd_sharp ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	parameter	DATA_WIDTH		= `TESTCASE.CCD_SHARP_DATA_WIDTH	;
	parameter	IMAGE_WIDTH		= `TESTCASE.CCD_SHARP_IMAGE_WIDTH	;
	parameter	IMAGE_HEIGHT	= `TESTCASE.CCD_SHARP_IMAGE_HEIGHT	;
	parameter	BLACK_VFRONT	= `TESTCASE.CCD_SHARP_BLACK_VFRONT	;
	parameter	BLACK_VREAR		= `TESTCASE.CCD_SHARP_BLACK_VREAR	;
	parameter	BLACK_HFRONT	= `TESTCASE.CCD_SHARP_BLACK_HFRONT	;
	parameter	BLACK_HREAR		= `TESTCASE.CCD_SHARP_BLACK_HREAR	;
	parameter	DUMMY_VFRONT	= `TESTCASE.CCD_SHARP_DUMMY_VFRONT	;
	parameter	DUMMY_VREAR		= `TESTCASE.CCD_SHARP_DUMMY_VREAR	;
	parameter	DUMMY_HFRONT	= `TESTCASE.CCD_SHARP_DUMMY_HFRONT	;
	parameter	DUMMY_HREAR		= `TESTCASE.CCD_SHARP_DUMMY_HREAR	;

	parameter	DUMMY_INIT_VALUE	= `TESTCASE.CCD_SHARP_DUMMY_INIT_VALUE	;
	parameter	BLACK_INIT_VALUE	= `TESTCASE.CCD_SHARP_BLACK_INIT_VALUE	;
	parameter	IMAGE_SOURCE		= `TESTCASE.CCD_SHARP_IMAGE_SOURCE		;
	parameter	SOURCE_FILE_PATH	= `TESTCASE.CCD_SHARP_SOURCE_FILE_PATH		;

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------
	wire						xv1		;
	wire						xv2		;
	wire						xv3		;
	wire						xv4		;
	wire						hl		;
	wire						h1		;
	wire						h2		;
	wire						rs		;

	//	-------------------------------------------------------------------------------------
	//	���
	//	-------------------------------------------------------------------------------------
	wire	[DATA_WIDTH-1:0]	ov_pix_data	;

	//	ref ARCHITECTURE
	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------
	assign	xv1		= `TESTCASE.ccd_sharp_xv1	;
	assign	xv2		= `TESTCASE.ccd_sharp_xv2	;
	assign	xv3		= `TESTCASE.ccd_sharp_xv3	;
	assign	xv4		= `TESTCASE.ccd_sharp_xv4	;
	assign	xsg		= `TESTCASE.ccd_sharp_xsg	;
	assign	hl		= `TESTCASE.ccd_sharp_hl	;
	assign	h1		= `TESTCASE.ccd_sharp_h1	;
	assign	h2		= `TESTCASE.ccd_sharp_h2	;
	assign	rs		= `TESTCASE.ccd_sharp_rs	;

	//	-------------------------------------------------------------------------------------
	//	ccd sharp bfm
	//	-------------------------------------------------------------------------------------

	//	-------------------------------------------------------------------------------------
	//	ccd sharp ģ��
	//	-------------------------------------------------------------------------------------
	ccd_sharp_module # (
	.DATA_WIDTH			(DATA_WIDTH			),
	.IMAGE_WIDTH		(IMAGE_WIDTH		),
	.IMAGE_HEIGHT		(IMAGE_HEIGHT		),
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
	.IMAGE_SOURCE		(IMAGE_SOURCE    	),
	.SOURCE_FILE_PATH	(SOURCE_FILE_PATH	)
	)
	ccd_sharp_module_inst (
	.xv1			(xv1			),
	.xv2			(xv2			),
	.xv3			(xv3			),
	.xv4			(xv4			),
	.xsg			(xsg			),
	.hl				(hl				),
	.h1				(h1				),
	.h2				(h2				),
	.rs				(rs				),
	.ov_pix_data	(ov_pix_data	)
	);


endmodule
