/**********************************************************************************************
-- File			: ParameterDef.v
-- Description	: In the File define valuve of all register and parameter
-- Simulator	: Modelsim 6.2c / Windows XP2
-- Synthesizer 	: Synplify8.0 / Windows XP2
-- Author / Designer	: Song Weiming (songwm@daheng-image.com)
-- Copyright (c) notice : Daheng image Vision 2007-2010
***********************************************************************************************/
`timescale 1ns/1ns
/***************************************************************************************************************
1����ز���Ĭ��ֵ����
V_width						��Vϵ���źŵĿ�ȣ���ΪVϵ���źŵĸ���
XV_Defvalue					��Vϵ���źŵ�Ĭ��ֵ
REG_WD						: CCD�ڲ��Ĵ����Ŀ��
EXP_WD						: �ع�ʱ��Ĵ���λ��궨��
****************************************************************************************************************/
	`define V_WIDTH							4					//��VXϵ�к�VSXϵ�л�����ͬ�����Զ�Ϊ4
	`define XSG_WD							1					//XSG�źſ��
	`define XV_DEFVALUE						`V_WIDTH'B1100		//V4-1 �͵͸߸�ȡ��
	`define REG_WD							16					//CCD�ڲ��Ĵ����Ŀ��
	`define EXP_WD							32					//�ع�ʱ��Ĵ���λ��궨��

/***************************************************************************************************************
2����ͷ���ܲ�������
ע��Vϵ���źŵ����ɿ��Է�Ϊ8�Σ�����ͨ��״̬����ʵ�֣�ÿһ��״̬��Vϵ���ź���Ϊһ��������һ���̶���ֵ�����ַ�������
	Sonyϵ�е�CCD Sensor��ͨ�õ�
V_BlankHead_Value1			  ����ͷ״̬1��Vϵ���źŵ�ֵ
V_BlankHead_Value2			  ����ͷ״̬2��Vϵ���źŵ�ֵ
V_BlankHead_Value3			  ����ͷ״̬3��Vϵ���źŵ�ֵ
V_BlankHead_Value4			  ����ͷ״̬4��Vϵ���źŵ�ֵ
V_BlankHead_Value5			  ����ͷ״̬5��Vϵ���źŵ�ֵ
V_BlankHead_Value6			  ����ͷ״̬6��Vϵ���źŵ�ֵ
V_BlankHead_Value7			  ����ͷ״̬7��Vϵ���źŵ�ֵ
V_BlankHead_Value8			  ����ͷ״̬8��Vϵ���źŵ�ֵ
XV_BlankHead_defaultValue	  ����ͷ����Vϵ���źŵ�Ĭ��ֵ

HeadBlank_State_Width		  ����ͷ״̬�����
HeadBlank_period			  ����ͷ��������
****************************************************************************************************************/
	`define V_BLANKHEAD_VALUE1			   	`V_WIDTH'B1100	//
	`define V_BLANKHEAD_VALUE2			   	`V_WIDTH'B1000	//
	`define V_BLANKHEAD_VALUE3			   	`V_WIDTH'B1001	//
	`define V_BLANKHEAD_VALUE4			   	`V_WIDTH'B0001	//
	`define	V_BLANKHEAD_VALUE5			 	`V_WIDTH'B0011	//
	`define	V_BLANKHEAD_VALUE6			 	`V_WIDTH'B0010	//
	`define	V_BLANKHEAD_VALUE7			 	`V_WIDTH'B0110	//
	`define	V_BLANKHEAD_VALUE8			 	`V_WIDTH'B0100	//
	`define XV_BLANKHEAD_DEFAULTVALUE	   	`V_WIDTH'B1100	//

	`define HEADBLANK_STATE_WIDTH		  	`REG_WD'D0044 	//	(1513-40*2)/8/4=46
//	`define HEADBLANK_PERIOD			   	`REG_WD'D0374 	//47*8-2

	`define HEADBLANK_LINE_START_POSITION  	`REG_WD'D0040
	`define HEADBLANK_LINE_END_POSITION		((8 * `HEADBLANK_STATE_WIDTH * `HEADBLANK_NUM_PER_LINE) + `HEADBLANK_LINE_START_POSITION)
	`define HEADBLANK_NUM_PER_LINE		  	3'D4			//һ���������ĸ��췭

//	`define OFD_BLANK_RISING		   		`REG_WD'D0030 	//30??
//	`define OFD_BLANK_FALLING			   	`REG_WD'D0000 	//0??
/***************************************************************************************************************
3����β���ܲ�������
V_BLANKTAIL_VALUE1			  ����β״̬1��Vϵ���źŵ�ֵ
V_BLANKTAIL_VALUE2			  ����β״̬2��Vϵ���źŵ�ֵ
V_BLANKTAIL_VALUE3			  ����β״̬3��Vϵ���źŵ�ֵ
V_BLANKTAIL_VALUE4			  ����β״̬4��Vϵ���źŵ�ֵ
V_BLANKTAIL_VALUE5			  ����β״̬5��Vϵ���źŵ�ֵ
V_BLANKTAIL_VALUE6			  ����β״̬6��Vϵ���źŵ�ֵ
V_BLANKTAIL_VALUE7			  ����β״̬7��Vϵ���źŵ�ֵ
V_BLANKTAIL_VALUE8			  ����β״̬8��Vϵ���źŵ�ֵ
XV_BLANKTAIL_DEFAULTVALUE	  ����β����Vϵ���źŵ�Ĭ��ֵ

TAILBLANK_STATE_WIDTH		  ����β״̬�����
TAILBLANK_PERIOD			  ����β��������
****************************************************************************************************************/
	`define V_BLANKTAIL_VALUE1			   	`V_WIDTH'B1100			//1100			1000
	`define V_BLANKTAIL_VALUE2			   	`V_WIDTH'B1000			//1000          1001
	`define V_BLANKTAIL_VALUE3			   	`V_WIDTH'B1001			//1001          0001
	`define V_BLANKTAIL_VALUE4			   	`V_WIDTH'B0001			//0001          0011
	`define V_BLANKTAIL_VALUE5			   	`V_WIDTH'B0011			//0011          0010
	`define V_BLANKTAIL_VALUE6			   	`V_WIDTH'B0010			//0010          0110
	`define V_BLANKTAIL_VALUE7			   	`V_WIDTH'B0110			//0110          0100
	`define V_BLANKTAIL_VALUE8			   	`V_WIDTH'B0100			//0100          1100
	`define XV_BLANKTAIL_DEFAULTVALUE	   	`V_WIDTH'B1100			//1100          1100


 	`define TAILBLANK_STATE_WIDTH		   	`REG_WD'D0044 	//	(1513-40*2)/8/4=46
// 	`define TAILBLANK_PERIOD			   	`REG_WD'D0374 			//47*8-2

	`define TAILBLANK_LINE_START_POSITION  	`REG_WD'D0040
	`define TAILBLANK_LINE_END_POSITION		((8 * `TAILBLANK_STATE_WIDTH * `TAILBLANK_NUM_PER_LINE) + `TAILBLANK_LINE_START_POSITION)
	`define TAILBLANK_NUM_PER_LINE		  	3'D4			//һ���������ĸ��췭

/***************************************************************************************************************
4��ˮƽ��������ز�������
H_period					  ��ˮƽ���������ڣ���Ϊ������
****************************************************************************************************************/
//	`define H_PERIOD					   	`REG_WD'D1511	 		//1513-2
//	`define LINE_PIX						`REG_WD'D1513			//1513

//	`define H_PERIOD					   	`REG_WD'D1519	 		//1513-2
//	`define LINE_PIX						`REG_WD'D1521			//1513

//	`define H_PERIOD					   	`REG_WD'D1521	 		//1513-2
//	`define LINE_PIX						`REG_WD'D1523			//1513

//	`define H_PERIOD					   	`REG_WD'D1538	 		//1513-2
//	`define LINE_PIX						`REG_WD'D1540			//1513

	`define H_PERIOD					   	`REG_WD'D1530	 		//1513-2
	`define LINE_PIX						`REG_WD'D1532			//1513

/***************************************************************************************************************
5��AD��ز�������
HD_rising					  : HD������λ��
HD_falling					  : HD�½���λ��
VD_rising					  : VD������λ��
VD_falling					  ��VD�½���λ��
****************************************************************************************************************/
	`define HD_RISING					 	`REG_WD'D282			//300
	`define HD_FALLING					 	`LINE_PIX-`REG_WD'D18

	`define VD_RISING					 	`REG_WD'D2				//
	`define VD_FALLING					 	`REG_WD'D1

/***************************************************************************************************************
6��ˮƽ������ز�������
HBLK_RISING					  ��HBLK������λ��
HBLK_FALLING				  ��HBLK�½���λ��
PBLK_RISING					  ��PBLK������λ��
PBLK_FALLING				  ��PBLK�½���λ��
CLPOB_RISING				  ��CLPOB������λ��
CLPOB_FALLING				  ��CLPOB�½���λ��
CLPDM_RISING				  : CLPDM������λ��
CLPDM_FALLING				  : ��λ��
****************************************************************************************************************/
//	`define HBLK_RISING					   	`REG_WD'D136
//	`define HBLK_FALLING				   	`REG_WD'D0
//
//	`define PBLK_RISING					   	`REG_WD'D136
//	`define PBLK_FALLING				   	`REG_WD'D0
//
//	`define CLPOB_RISING				   	`REG_WD'D1466
//	`define CLPOB_FALLING				   	`REG_WD'D1486
//
//	`define CLPDM_RISING				   	`REG_WD'D0000
//	`define CLPDM_FALLING				   	`REG_WD'D0000
/***************************************************************************************************************
7����ֱ������ز�������
XV_Line_Position			 : �м�V�źű仯λ��
XV_Line_Value0				 : �м�V�źű仯λ�õ�ֵ
XV_Line_defaultValue		 : �м�V�ź�Ĭ��ֵ

SUB_rising					 ��SUB�ź�������λ��
SUB_falling					 ��SUB�ź��½���λ��
****************************************************************************************************************/

	`define XV_LINE_POSITION1			   	(`REG_WD'D0033 - `XV_FALLING_EDGE_COMPENSATION	)
	`define XV_LINE_POSITION2			   	(`REG_WD'D0047 - `XV_RISING_EDGE_COMPENSATION	)
	`define XV_LINE_POSITION3			   	(`REG_WD'D0061 - `XV_FALLING_EDGE_COMPENSATION	)
	`define XV_LINE_POSITION4			   	(`REG_WD'D0075 - `XV_RISING_EDGE_COMPENSATION	)
	`define XV_LINE_POSITION5			   	(`REG_WD'D0092 - `XV_FALLING_EDGE_COMPENSATION	)
	`define XV_LINE_POSITION6			   	(`REG_WD'D0106 - `XV_RISING_EDGE_COMPENSATION	)
	`define XV_LINE_POSITION7			   	(`REG_WD'D0120 - `XV_FALLING_EDGE_COMPENSATION	)
	`define XV_LINE_POSITION8			   	(`REG_WD'D0134 - `XV_RISING_EDGE_COMPENSATION	)


	`define V_LINE_VALUE1				   	`V_WIDTH'B1000		//
	`define V_LINE_VALUE2				   	`V_WIDTH'B1001		//
	`define V_LINE_VALUE3				   	`V_WIDTH'B0001		//
	`define V_LINE_VALUE4				   	`V_WIDTH'B0011		//
	`define V_LINE_VALUE5				   	`V_WIDTH'B0010		//
	`define V_LINE_VALUE6				   	`V_WIDTH'B0110		//
	`define V_LINE_VALUE7				   	`V_WIDTH'B0100		//
	`define V_LINE_VALUE8				   	`V_WIDTH'B1100		//
	`define XV_LINE_DEFAULTVALUE		   	`V_WIDTH'B1100		//

	`define SUB_RISING					   	`REG_WD'D0030	 	//30
	`define SUB_FALLING					   	`REG_WD'D0000	 	//0
	`define XSUB_WIDTH						`REG_WD'D0030	 	//30??
/***************************************************************************************************************
8��֡��ת��ز�������
XSG_DEFAULTVALUE			 ��֡��ת�ڼ�XSGϵ���źŵ�ֵ
XSG_WIDTH					 ��֡��ת�ڼ�XSG�źŵĿ��
XSGCOUNT_LENGTH				 : ֡��ת����������
XSUB_DECIMALSTART			 : С���ع��SUB�ź���ʼλ��
XSUB_DECIMALEND				 : С���ع��SUB�źŽ���λ�� XSUB_DecimalStart+`XSUB_Width

XV_XSG_POSITION1			 : ֡��ת�ڼ�Vϵ���źŵ�״̬1λ��
XV_XSG_POSITION2			 : ֡��ת�ڼ�Vϵ���źŵ�״̬2λ��
XV_XSG_POSITION3			 ��֡��ת�ڼ�Vϵ���źŵ�״̬3λ��
XV_XSG_POSITION4			 ��֡��ת�ڼ�Vϵ���źŵ�״̬4λ��
XV_XSG_POSITION5			 ��֡��ת�ڼ�Vϵ���źŵ�״̬5λ��
XV_XSG_POSITION6			 ��֡��ת�ڼ�Vϵ���źŵ�״̬6λ��
XV_XSG_POSITION7			 ��֡��ת�ڼ�Vϵ���źŵ�״̬7λ��
XV_XSG_POSITION8			 ��֡��ת�ڼ�Vϵ���źŵ�״̬8λ��

V_XSG_VALUE0				 : ֡��ת�ڼ�Vϵ���ź�״̬1��ֵ
V_XSG_VALUE1				 : ֡��ת�ڼ�Vϵ���ź�״̬2��ֵ
V_XSG_VALUE2				 : ֡��ת�ڼ�Vϵ���ź�״̬3��ֵ
V_XSG_VALUE3				 : ֡��ת�ڼ�Vϵ���ź�״̬4��ֵ
V_XSG_VALUE4				 : ֡��ת�ڼ�Vϵ���ź�״̬5��ֵ
V_XSG_VALUE5				 : ֡��ת�ڼ�Vϵ���ź�״̬6��ֵ
V_XSG_VALUE6				 : ֡��ת�ڼ�Vϵ���ź�״̬7��ֵ
V_XSG_VALUE7				 : ֡��ת�ڼ�Vϵ���ź�״̬8��ֵ
XV_XSG_DEFAULTVALUE		 	 : ֡��ת�ڼ�Vϵ���źŵ�Ĭ��ֵ
****************************************************************************************************************/
	`define XSG_DEFAULTVALUE				{`XSG_WD{1'B1}}					//
	`define XSGCOUNT_LENGTH				   	(`LINE_PIX*2) 					//


	`define XSG1_RISING						(`REG_WD'D0400 + `LINE_PIX)		//xsg��ʼλ�ò���������Ϊ������ǰ�ƶ���
	`define XSG1_FALLING					(`REG_WD'D0720 + `LINE_PIX + (`XV_FALLING_EDGE_COMPENSATION - `XV_RISING_EDGE_COMPENSATION))	//XSG����λ��������2��clk
	`define XSG_VALUE1                 		`XSG_WD'B0						//��ȷ�ϵ�·����
	`define XSG_VALUE2                 		`XSG_WD'B1

	`define XV_XSG_POSITION1			   	`REG_WD'D0001 			//����Ϊ�㣬��Ϊ��Ҫ��xsgcount==0ʱ��λo_xsg_clear
																	//��xsg countΪ1��ʱ��xv3�½���������ǰ�ˣ����ֻ����xsg������ʱ��������ʱ
	`define XV_XSG_POSITION2			   	(`REG_WD'D0820 + `LINE_PIX + (`XV_FALLING_EDGE_COMPENSATION - `XV_RISING_EDGE_COMPENSATION))	//XSG����λ��������2��clk

	`define V_XSG_VALUE1				   	`V_WIDTH'B0100					//
	`define V_XSG_VALUE2				   	`V_WIDTH'B1100					//
	`define XV_XSG_DEFAULTVALUE			   	`V_WIDTH'B1100					//

//	-------------------------------------------------------------------------------------
//	�ع�ʱ�� Ĭ��30ms
//	-------------------------------------------------------------------------------------
//	`define 	EXPOSURE_DEFVALUE			`EXP_WD'D1350000	//30000us
//	`define 	EXPOSURE_HREG_DEFVALUE		`REG_WD'h14			//30000us
//	`define 	EXPOSURE_LREG_DEFVALUE		`REG_WD'h9970		//30000us
//	`define 	EXPOSURE_LINEREG_DEFVALUE 	`REG_WD'h37c		//1350000/1513

//	`define 	EXPOSURE_DEFVALUE			`EXP_WD'D1350000									//30000us
	`define 	EXPOSURE_DEFVALUE			`EXP_WD'D2250										//50US
//	`define 	EXPOSURE_DEFVALUE			`EXP_WD'D1800										//40US
	`define 	EXPOSURE_HREG_DEFVALUE		(`EXPOSURE_DEFVALUE/65536)							//30000us
	`define 	EXPOSURE_LREG_DEFVALUE		(`EXPOSURE_DEFVALUE-`EXPOSURE_HREG_DEFVALUE*65536)	//30000us
	`define 	EXPOSURE_LINEREG_DEFVALUE 	(`EXPOSURE_DEFVALUE/`LINE_PIX)									//1350000/1521

////	-------------------------------------------------------------------------------------
////	30֡/s ֡��ģʽ�¼Ĵ���Ĭ��ֵ����
////	ͼ��ߴ磺		1320*976
////	Ĭ��ʱ�ӣ�		45MHz
////	֡�ʣ�			30֡/s
////	ÿ��ʱ�Ӹ�����	1513
////	һ֡��������	991
////	���㹫ʽ��45000000/(1513*991) = 30
////	-------------------------------------------------------------------------------------
//	`define 	HEADBLANK_START_DEFVALUE	`REG_WD'D0001		//����Ϊ0�������ڴ����ȴ��ڼ�ᴦ�ڳ�ͷ�շ��׶�
//	`define 	HEADBLANK_NUMBER_DEFVALUE	`REG_WD'D0009		//
//	`define 	VSYNC_START_DEFVALUE		`REG_WD'D0004		//2
//	`define 	VSYNC_START_FPGA_DEFVALUE	(`VSYNC_START_DEFVALUE+1)	//2
//	`define 	TAILBLANK_START_DEFVALUE	`REG_WD'D0981		//963
//	`define 	TAILBLANK_NUMBER_DEFVALUE	`REG_WD'D0001		//1024
//	`define 	TAILBLANK_END_DEFVALUE		`REG_WD'D0982		//980
//	`define 	FRAME_PERIOD_DEFVALUE		`REG_WD'D0989		//991-2
//	`define 	HREF_START_DEFVALUE			`REG_WD'D15			//
//	`define 	HREF_END_DEFVALUE			`REG_WD'D1335		//

////	-------------------------------------------------------------------------------------
////	30֡/s ֡��ģʽ�¼Ĵ���Ĭ��ֵ����
////	ͼ��ߴ磺		1372*982
////	Ĭ��ʱ�ӣ�		45MHz
////	֡�ʣ�			30֡/s
////	ÿ��ʱ�Ӹ�����	1513
////	һ֡��������	996
////	���㹫ʽ��45000000/(1513*996) = 29.86
////	-------------------------------------------------------------------------------------
//	`define 	HEADBLANK_START_DEFVALUE	`REG_WD'D0001		//����Ϊ0�������ڴ����ȴ��ڼ�ᴦ�ڳ�ͷ�շ��׶�
//	`define 	HEADBLANK_NUMBER_DEFVALUE	`REG_WD'D0005		//
//	`define 	VSYNC_START_DEFVALUE		`REG_WD'D0003		//2
//	`define 	VSYNC_START_FPGA_DEFVALUE	(`VSYNC_START_DEFVALUE+1)	//2
//	`define 	TAILBLANK_START_DEFVALUE	`REG_WD'D0986		//963
//	`define 	TAILBLANK_NUMBER_DEFVALUE	`REG_WD'D0001		//1024
//	`define 	TAILBLANK_END_DEFVALUE		`REG_WD'D0987		//980
//	`define 	FRAME_PERIOD_DEFVALUE		`REG_WD'D0994		//996-2
//	`define 	HREF_START_DEFVALUE			`REG_WD'D3			//
//	`define 	HREF_END_DEFVALUE			`REG_WD'D1375		//

//////	-------------------------------------------------------------------------------------
//////	30֡/s ֡��ģʽ�¼Ĵ���Ĭ��ֵ����
//////	ͼ��ߴ磺		1320*976
//////	Ĭ��ʱ�ӣ�		45MHz
//////	֡�ʣ�			30֡/s
//////	ÿ��ʱ�Ӹ�����	1513
//////	һ֡��������	986
//////	���㹫ʽ��45000000/(1513*991) = 30
//////	-------------------------------------------------------------------------------------
////	`define 	HEADBLANK_START_DEFVALUE	`REG_WD'D0001		//����Ϊ0�������ڴ����ȴ��ڼ�ᴦ�ڳ�ͷ�շ��׶�
////	`define 	HEADBLANK_NUMBER_DEFVALUE	`REG_WD'D0009		//
////	`define 	VSYNC_START_DEFVALUE		`REG_WD'D0004		//2
////	`define 	VSYNC_START_FPGA_DEFVALUE	(`VSYNC_START_DEFVALUE+1)	//2
////	`define 	TAILBLANK_START_DEFVALUE	`REG_WD'D0981		//963
////	`define 	TAILBLANK_NUMBER_DEFVALUE	`REG_WD'D0002		//1024
////	`define 	TAILBLANK_END_DEFVALUE		`REG_WD'D0982		//980
////	`define 	FRAME_PERIOD_DEFVALUE		`REG_WD'D0984		//991-2
////	`define 	HREF_START_DEFVALUE			`REG_WD'D15			//
////	`define 	HREF_END_DEFVALUE			`REG_WD'D1335		//


//////	-------------------------------------------------------------------------------------
//////	30֡/s ֡��ģʽ�¼Ĵ���Ĭ��ֵ����
//////	ͼ��ߴ磺		1280*960
//////	Ĭ��ʱ�ӣ�		45MHz
//////	֡�ʣ�			30֡/s
//////	ÿ��ʱ�Ӹ�����	1540
//////	һ֡��������	986
//////	���㹫ʽ��45000000/(1513*991) = 30
//////	-------------------------------------------------------------------------------------
////	`define 	HEADBLANK_START_DEFVALUE	`REG_WD'D0001		//����Ϊ0�������ڴ����ȴ��ڼ�ᴦ�ڳ�ͷ�շ��׶�
////	`define 	HEADBLANK_NUMBER_DEFVALUE	`REG_WD'D0009		//
////	`define 	VSYNC_START_DEFVALUE		`REG_WD'D0004		//2
////	`define 	VSYNC_START_FPGA_DEFVALUE	(`VSYNC_START_DEFVALUE+1)	//2
////	`define 	TAILBLANK_START_DEFVALUE	`REG_WD'D0965		//963
////	`define 	TAILBLANK_NUMBER_DEFVALUE	`REG_WD'D0019		//1024
////	`define 	TAILBLANK_END_DEFVALUE		`REG_WD'D0970		//980
////	`define 	FRAME_PERIOD_DEFVALUE		`REG_WD'D0972		//974-2
////	`define 	HREF_START_DEFVALUE			`REG_WD'D15			//
////	`define 	HREF_END_DEFVALUE			`REG_WD'D1295		//

//	-------------------------------------------------------------------------------------
//	30֡/s ֡��ģʽ�¼Ĵ���Ĭ��ֵ����
//	ͼ��ߴ磺		1292*964
//	Ĭ��ʱ�ӣ�		45MHz
//	֡�ʣ�			30֡/s
//	ÿ��ʱ�Ӹ�����	1532
//	һ֡��������	977
//	���㹫ʽ��45000000/(1513*991) = 30
//	-------------------------------------------------------------------------------------
	`define 	HEADBLANK_START_DEFVALUE	`REG_WD'D0001		//����Ϊ0�������ڴ����ȴ��ڼ�ᴦ�ڳ�ͷ�շ��׶�
	`define 	HEADBLANK_NUMBER_DEFVALUE	`REG_WD'D0015		//
	`define 	VSYNC_START_DEFVALUE		`REG_WD'D0005		//2
	`define 	VSYNC_START_FPGA_DEFVALUE	(`VSYNC_START_DEFVALUE+1)	//2
	`define 	TAILBLANK_START_DEFVALUE	`REG_WD'D0970		//963
	`define 	TAILBLANK_NUMBER_DEFVALUE	`REG_WD'D009		//1024
	`define 	TAILBLANK_END_DEFVALUE		`REG_WD'D0973		//980
	`define 	FRAME_PERIOD_DEFVALUE		`REG_WD'D0975		//977-2
	`define 	HREF_START_DEFVALUE			`REG_WD'D29			//
	`define 	HREF_END_DEFVALUE			`REG_WD'D1321		//

// cxd3400 �� xv����������ʱ23ns������½�����ʱ69ns���
// xv rising edge compensation 1clk
	`define 		XV_RISING_EDGE_COMPENSATION		0

// xv falling edge compensation 3clk
	`define 		XV_FALLING_EDGE_COMPENSATION	0

	`define 	TRIGGERDELAYREG_DEFVALUE	`REG_WD'D0000
	`define 	FILTER_REDGEVALUE			`REG_WD'H0000
	`define 	FILTER_FEDGEVALUE			`REG_WD'H0000