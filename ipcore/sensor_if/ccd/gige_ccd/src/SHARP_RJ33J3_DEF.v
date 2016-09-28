//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : ICX274DEF
//  -- �����       : ��
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- ��         :| 2014/1/16			:|  ��ʼ�汾
//  -- ��Сƽ      	:| 07/29/2015   		:|  �����޸ģ���Ӧ��ICX445 sensor
//  -- �Ϻ���      	:| 2015/8/17 13:31:11	:|  �����޸ģ���Ӧ��sharp rj33j3 sensor
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1)  : sharp rj33j3 CCD�궨��
//
//-------------------------------------------------------------------------------------------------
//  ���浥λ/����
`timescale 1ns/100ps
//-------------------------------------------------------------------------------------------------

//  ===============================================================================================
//  1��λ����
//  ===============================================================================================

`define 	XV_WD							4													// XV�ź�λ��
`define 	XSG_WD							1       											// XSG�ź�λ��

//`define 	FRAME_WD						19													// ֡������λ��
`define 	FRAME_WD						16													// ֡������λ��

`define 	LINE_WD							11													// ����������λ��
`define 	XSG_LINE_WD						12													// XSG����������λ��
`define 	EXP_WD							30													// �ع����ظ���λ��
`define 	EXP_XSG_WD						12													// �ع�XSG����С�����ظ���λ��
`define 	FRAME_PIX_CNT_WD				22													// һ֡ͼ��������ܸ���
`define 	TEST_IO_WD						4													// IO����

//  ===============================================================================================
//	2��ˮƽ��������ز�������
//  ===============================================================================================

`define 	LINE_PIX					   	`LINE_WD'd1532	 									// ������:1532
`define 	LINE_PERIOD					   	`LINE_PIX-`LINE_WD'd1		 									// ������:1532-1
`define 	FRAME_PIXEL_CNT					`FRAME_PIX_CNT_WD'd1499828							// һ֡ͼ��������ܸ���,1532*979

//  ===============================================================================================
//	3��AD��ز�������
//  ===============================================================================================

`define 	HD_RISING					 	`LINE_WD'd88 										// HD����ܹ�100��HD������λ�� 78
`define 	HD_FALLING					 	`LINE_PIX-`LINE_WD'd13		  								// HD�½���λ�� 1512-12��

//�����ȴ��ڼ�VD����Ϊ��
`define 	VD_RISING					 	`FRAME_WD'H0003 									// VD������λ��
`define 	VD_FALLING					 	`FRAME_WD'H0001										// VD�½���λ��

//  ===============================================================================================
//	4��ˮƽ������ز�������
//  ===============================================================================================

//  ===============================================================================================
//	5����ֱ������ز�������
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//  ������ת
//  -------------------------------------------------------------------------------------

`define		XV_LINE_POSITION1			   	(`LINE_WD'd33+1) 									// �м�V�źű仯λ��1,��Ϊsub�½��ز�����Ϊ0��ֻ����Ϊ1�����xv��תλ�������ƶ�1������
`define 	XV_LINE_POSITION2			   	(`LINE_WD'd47+1) 									// �м�V�źű仯λ��2
`define 	XV_LINE_POSITION3			   	(`LINE_WD'd61+1) 									// �м�V�źű仯λ��3
`define 	XV_LINE_POSITION4			   	(`LINE_WD'd75+1) 									// �м�V�źű仯λ��4
`define 	XV_LINE_POSITION5			   	(`LINE_WD'd92+1) 									// �м�V�źű仯λ��5
`define 	XV_LINE_POSITION6			   	(`LINE_WD'd106+1) 									// �м�V�źű仯λ��6
`define 	XV_LINE_POSITION7			   	(`LINE_WD'd120+1) 									// �м�V�źű仯λ��7
`define 	XV_LINE_POSITION8			   	(`LINE_WD'd134+1) 									// �м�V�źű仯λ��8

`define 	XV_LINE_VALUE1				   	`XV_WD'B1000										// �м�V�źű仯λ�õ�ֵ1
`define 	XV_LINE_VALUE2				   	`XV_WD'B1001										// �м�V�źű仯λ�õ�ֵ2
`define 	XV_LINE_VALUE3				   	`XV_WD'B0001										// �м�V�źű仯λ�õ�ֵ3
`define 	XV_LINE_VALUE4				   	`XV_WD'B0011										// �м�V�źű仯λ�õ�ֵ4
`define 	XV_LINE_VALUE5				   	`XV_WD'B0010										// �м�V�źű仯λ�õ�ֵ5
`define 	XV_LINE_VALUE6				   	`XV_WD'B0110										// �м�V�źű仯λ�õ�ֵ6
`define 	XV_LINE_VALUE7				   	`XV_WD'B0100										// �м�V�źű仯λ�õ�ֵ7
`define 	XV_LINE_VALUE8				   	`XV_WD'B1100										// �м�V�źű仯λ�õ�ֵ8

`define 	XV_LINE_DEFAULT		   			`XV_WD'B1100										// XV�ź��������ڼ��Ĭ��ֵ

//  -------------------------------------------------------------------------------------
//  ���ٷ�ת
//  -------------------------------------------------------------------------------------

`define 	HEADBLANK_PERIOD			    `LINE_WD'd190									// ��ͷ�������� ,sharp rj33j3 191 * 8 =1528  ��total 1532
`define 	TAILBLANK_PERIOD			   	`LINE_WD'd190									// ��β��������

`define 	XV_HAEDBLANK_POSITION1			`LINE_WD'd0
`define 	XV_HAEDBLANK_POSITION2			`LINE_WD'd23
`define 	XV_HAEDBLANK_POSITION3			`LINE_WD'd46
`define 	XV_HAEDBLANK_POSITION4			`LINE_WD'd69
`define 	XV_HAEDBLANK_POSITION5			`LINE_WD'd92
`define 	XV_HAEDBLANK_POSITION6			`LINE_WD'd115
`define 	XV_HAEDBLANK_POSITION7			`LINE_WD'd138
`define 	XV_HAEDBLANK_POSITION8			`LINE_WD'd161

`define 	XV_TAILBLANK_POSITION1			`LINE_WD'd0
`define 	XV_TAILBLANK_POSITION2			`LINE_WD'd23
`define 	XV_TAILBLANK_POSITION3			`LINE_WD'd46
`define 	XV_TAILBLANK_POSITION4			`LINE_WD'd69
`define 	XV_TAILBLANK_POSITION5			`LINE_WD'd92
`define 	XV_TAILBLANK_POSITION6			`LINE_WD'd115
`define 	XV_TAILBLANK_POSITION7			`LINE_WD'd138
`define 	XV_TAILBLANK_POSITION8			`LINE_WD'd161


`define 	V_BLANKHEAD_VALUE1			   	`XV_WD'B1100							// ��ͷ״̬1��Vϵ���źŵ�ֵ
`define 	V_BLANKHEAD_VALUE2			   	`XV_WD'B1000							// ��ͷ״̬2��Vϵ���źŵ�ֵ
`define 	V_BLANKHEAD_VALUE3			   	`XV_WD'B1001							// ��ͷ״̬3��Vϵ���źŵ�ֵ
`define 	V_BLANKHEAD_VALUE4			   	`XV_WD'B0001							// ��ͷ״̬4��Vϵ���źŵ�ֵ
`define 	V_BLANKHEAD_VALUE5		   		`XV_WD'B0011							// ��ͷ״̬5��Vϵ���źŵ�ֵ
`define 	V_BLANKHEAD_VALUE6		   		`XV_WD'B0010							// ��ͷ״̬5��Vϵ���źŵ�ֵ
`define 	V_BLANKHEAD_VALUE7		   		`XV_WD'B0110							// ��ͷ״̬5��Vϵ���źŵ�ֵ
`define 	V_BLANKHEAD_VALUE8		   		`XV_WD'B0100							// ��ͷ״̬5��Vϵ���źŵ�ֵ
`define 	XV_BLANKHEAD_DEFAULT	   		`XV_WD'B1100							//

`define 	V_BLANKTAIL_VALUE1			   	`XV_WD'B1100							// ��β״̬1��Vϵ���źŵ�ֵ
`define 	V_BLANKTAIL_VALUE2			   	`XV_WD'B1000							// ��β״̬2��Vϵ���źŵ�ֵ
`define 	V_BLANKTAIL_VALUE3			   	`XV_WD'B1001							// ��β״̬3��Vϵ���źŵ�ֵ
`define 	V_BLANKTAIL_VALUE4			   	`XV_WD'B0001							// ��β״̬4��Vϵ���źŵ�ֵ
`define 	V_BLANKTAIL_VALUE5				`XV_WD'B0011							// ��β״̬5��Vϵ���źŵ�ֵ
`define 	V_BLANKTAIL_VALUE6				`XV_WD'B0010							// ��β״̬5��Vϵ���źŵ�ֵ
`define 	V_BLANKTAIL_VALUE7				`XV_WD'B0110							// ��β״̬5��Vϵ���źŵ�ֵ
`define 	V_BLANKTAIL_VALUE8				`XV_WD'B0100							// ��β״̬5��Vϵ���źŵ�ֵ
`define 	XV_BLANKTAIL_DEFAULT			`XV_WD'B1100							//

//  ===============================================================================================
//	6��SUB��ز�������
//  ===============================================================================================

`define 	SUB_RISING					   `LINE_WD'd31 									// SUB�ź�������λ��
`define 	SUB_FALLING					   `LINE_WD'd1 									// SUB�ź��½���λ��
`define 	SUB_PER_WIDTH 					`EXP_WD'd31										//

//  ===============================================================================================
//	7��֡��ת��ز�������
//  ===============================================================================================
`define XSG_WIDTH 							`EXP_WD'd420			//

`define XSG1_RISING						1		//xsg��ʼλ��
`define XSG1_FALLING					320		//XSG����λ��

//***********ICX274����û����Щ������
`define XV_XSG_POSITION1			   		`EXP_WD'd419
//`define XV_XSG_POSITION2			   		`EXP_WD'd18		//0+18
//`define XV_XSG_POSITION3			   		`EXP_WD'd156	//138+18
//`define XV_XSG_POSITION4			   		`EXP_WD'd174	//156+18

//`define XSG2A_RISING						`EXP_WD'd194		//174 + 20
//`define XSG3A_RISING						`EXP_WD'd211		//194 + 17
//`define XSG2B_RISING			   			`EXP_WD'd225		//211 + 14
//`define XSG3B_RISING						`EXP_WD'd242		//225 + 17
//`define XSG2A_FALLING						`EXP_WD'd256		//242 + 14
//`define XSG3A_FALLING						`EXP_WD'd273		//256 + 17
//`define XSG2B_FALLING			   			`EXP_WD'd287		//273 + 14
//`define XSG3B_FALLING						`EXP_WD'd304		//287 + 17

`define XSG_VALUE1                 			`XSG_WD'B0
`define XSG_VALUE2                 			`XSG_WD'B1
//`define XSG_VALUE3                 			`XSG_WD'B1000
//`define XSG_VALUE4                 			`XSG_WD'B0000
//`define XSG_VALUE5                 			`XSG_WD'B0001
//`define XSG_VALUE6                 			`XSG_WD'B0101
//`define XSG_VALUE7                 			`XSG_WD'B0111
//`define XSG_VALUE8                 			`XSG_WD'B1111

`define V_XSG_VALUE1				   		`XV_WD'B0100
`define V_XSG_VALUE2				   		`XV_WD'B1100
//`define V_XSG_VALUE3				   		`XV_WD'B101000
//`define V_XSG_VALUE4				   		`XV_WD'B111001
`define XV_XSG_DEFAULT			   			`XV_WD'B1100


//	-------------------------------------------------------------------------------------
//	�ع�ʱ�� 30ms
//	-------------------------------------------------------------------------------------
`define 	EXPOSURE_LINE_REG_DEFVALUE		`LINE_PIX								//
`define 	EXPOSURE_REG_DEFVALUE			(30000*45+131)							//
//`define 	EXPOSURE_REG_DEFVALUE			(50*45+131)							//
`define 	EXPOSURE_LINE_DEFVALUE			(`EXPOSURE_REG_DEFVALUE/`LINE_PIX)		//
`define 	EXPOSURE_START_LINE				(`FRAME_PERIOD_DEFVALUE - `EXPOSURE_LINE_DEFVALUE)	//

//////  ===============================================================================================
//////	8��֡��ģʽ�¼Ĵ���Ĭ��ֵ����
//////	ͼ��ߴ�	�� 	1600��980����Ч���سߴ磺 ,1292 * 964
//////	Ĭ��ʱ��	�� 	48MHz
//////	֡��		:	30֡/S
//////	�ع�Ĭ��ֵ	��
//////  ===============================================================================================
////
////`define		HEADBLANK_END_DEFVALUE			`FRAME_WD'd10										//
////`define 	VSYNC_START_DEFVALUE			`FRAME_WD'd12										//
////`define 	TAILBLANK_START_DEFVALUE		`FRAME_WD'd978										//
////`define		TAILBLANK_END_DEFVALUE			`FRAME_WD'd978										//
////`define 	FRAME_PERIOD_DEFVALUE			`FRAME_WD'd980										//
////
////`define 	HREF_START_DEFVALUE				`LINE_WD'd202										//
////`define 	HREF_END_DEFVALUE				`LINE_WD'd1560										//
////`define 	HREF_START_AD_DEFVALUE			`LINE_WD'd202										//
////`define 	HREF_END_AD_DEFVALUE			`LINE_WD'd1560										//
////
////`define 	EXPOSURE_LINE_DEFVALUE			`FRAME_WD'd2										//
////`define 	EXPOSURE_LINE_REG_DEFVALUE		`EXP_WD'd1600									//
////`define 	EXPOSURE_REG_DEFVALUE			`EXP_WD'd2075										//
////`define 	EXPOSURE_START_LINE				`FRAME_PERIOD_DEFVALUE - `EXPOSURE_LINE_DEFVALUE	//

//////  ===============================================================================================
//////	8��֡��ģʽ�¼Ĵ���Ĭ��ֵ����
//////	ͼ��ߴ�	�� 	1531x991����Ч���سߴ磺 ,1372 * 984
//////	Ĭ��ʱ��	�� 	45MHz
//////	֡��		:	30֡/S
//////	�ع�Ĭ��ֵ	��
//////  ===============================================================================================
////`define		HEADBLANK_END_DEFVALUE			`FRAME_WD'd4										//
////`define 	VSYNC_START_DEFVALUE			`FRAME_WD'd6										//
////`define 	TAILBLANK_START_DEFVALUE		`FRAME_WD'd990										//
////`define		TAILBLANK_END_DEFVALUE			`FRAME_WD'd990										//
////`define 	FRAME_PERIOD_DEFVALUE			`FRAME_WD'd992										//
////
////`define 	HREF_START_DEFVALUE				`LINE_WD'd26										//
////`define 	HREF_END_DEFVALUE				`LINE_WD'd1398										//
////`define 	HREF_START_AD_DEFVALUE			`LINE_WD'd26										//
////`define 	HREF_END_AD_DEFVALUE			`LINE_WD'd1398										//

//  ==============================================================================================
//	8��֡��ģʽ�¼Ĵ���Ĭ��ֵ����
//	ͼ��ߴ�	�� 	1532x979����Ч���سߴ磺 ,1292 * 964
//	Ĭ��ʱ��	�� 	45MHz
//	֡��		:	30֡/S
//	�ع�Ĭ��ֵ	��
//  ==============================================================================================
`define		HEADBLANK_END_DEFVALUE			`FRAME_WD'd3										//
`define 	VSYNC_START_DEFVALUE			`FRAME_WD'd11										//
`define 	TAILBLANK_START_DEFVALUE		`FRAME_WD'd975										//
`define		TAILBLANK_END_DEFVALUE			`FRAME_WD'd976										//
`define 	FRAME_PERIOD_DEFVALUE			`FRAME_WD'd978										//

//	-------------------------------------------------------------------------------------
//	��������������ccd���href vref��ʱ��
//	-------------------------------------------------------------------------------------
`define 	HREF_START_DEFVALUE				(`LINE_WD'd26+`LINE_WD'd70)									//
`define 	HREF_END_DEFVALUE				(`LINE_WD'd1398+`LINE_WD'd70)									//

//	-------------------------------------------------------------------------------------
//	��������������ad9970���ͬ����֮��ƫ��λ��
//	-------------------------------------------------------------------------------------
`define 	HREF_START_AD_DEFVALUE			`LINE_WD'd26										//
`define 	HREF_END_AD_DEFVALUE			`LINE_WD'd1398										//

