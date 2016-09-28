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
1、相关参数默认值定义
V_width						：V系列信号的宽度，亦为V系列信号的个数
XV_Defvalue					：V系列信号的默认值
REG_WD						: CCD内部寄存器的宽度
EXP_WD						: 曝光时间寄存器位宽宏定义
****************************************************************************************************************/
	`define V_WIDTH							4					//因VX系列和VSX系列基本相同，所以定为4
	`define XSG_WD							1					//XSG信号宽度
	`define XV_DEFVALUE						`V_WIDTH'B1100		//V4-1 低低高高取反
	`define REG_WD							16					//CCD内部寄存器的宽度
	`define EXP_WD							32					//曝光时间寄存器位宽宏定义

/***************************************************************************************************************
2、场头空跑参数定义
注：V系列信号的生成可以分为8段，我们通过状态机来实现，每一个状态下V系列信号作为一个整体有一个固定的值，此种方法对于
	Sony系列的CCD Sensor是通用的
V_BlankHead_Value1			  ：场头状态1下V系列信号的值
V_BlankHead_Value2			  ：场头状态2下V系列信号的值
V_BlankHead_Value3			  ：场头状态3下V系列信号的值
V_BlankHead_Value4			  ：场头状态4下V系列信号的值
V_BlankHead_Value5			  ：场头状态5下V系列信号的值
V_BlankHead_Value6			  ：场头状态6下V系列信号的值
V_BlankHead_Value7			  ：场头状态7下V系列信号的值
V_BlankHead_Value8			  ：场头状态8下V系列信号的值
XV_BlankHead_defaultValue	  ：场头空跑V系列信号的默认值

HeadBlank_State_Width		  ：场头状态机宽度
HeadBlank_period			  ：场头空跑周期
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
	`define HEADBLANK_NUM_PER_LINE		  	3'D4			//一行里面有四个快翻

//	`define OFD_BLANK_RISING		   		`REG_WD'D0030 	//30??
//	`define OFD_BLANK_FALLING			   	`REG_WD'D0000 	//0??
/***************************************************************************************************************
3、场尾空跑参数定义
V_BLANKTAIL_VALUE1			  ：场尾状态1下V系列信号的值
V_BLANKTAIL_VALUE2			  ：场尾状态2下V系列信号的值
V_BLANKTAIL_VALUE3			  ：场尾状态3下V系列信号的值
V_BLANKTAIL_VALUE4			  ：场尾状态4下V系列信号的值
V_BLANKTAIL_VALUE5			  ：场尾状态5下V系列信号的值
V_BLANKTAIL_VALUE6			  ：场尾状态6下V系列信号的值
V_BLANKTAIL_VALUE7			  ：场尾状态7下V系列信号的值
V_BLANKTAIL_VALUE8			  ：场尾状态8下V系列信号的值
XV_BLANKTAIL_DEFAULTVALUE	  ：场尾空跑V系列信号的默认值

TAILBLANK_STATE_WIDTH		  ：场尾状态机宽度
TAILBLANK_PERIOD			  ：场尾空跑周期
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
	`define TAILBLANK_NUM_PER_LINE		  	3'D4			//一行里面有四个快翻

/***************************************************************************************************************
4、水平计数器相关参数定义
H_period					  ：水平计数器周期，亦为行周期
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
5、AD相关参数定义
HD_rising					  : HD上升沿位置
HD_falling					  : HD下降沿位置
VD_rising					  : VD上升沿位置
VD_falling					  ：VD下降沿位置
****************************************************************************************************************/
	`define HD_RISING					 	`REG_WD'D282			//300
	`define HD_FALLING					 	`LINE_PIX-`REG_WD'D18

	`define VD_RISING					 	`REG_WD'D2				//
	`define VD_FALLING					 	`REG_WD'D1

/***************************************************************************************************************
6、水平驱动相关参数定义
HBLK_RISING					  ：HBLK上升沿位置
HBLK_FALLING				  ：HBLK下降沿位置
PBLK_RISING					  ：PBLK上升沿位置
PBLK_FALLING				  ：PBLK下降沿位置
CLPOB_RISING				  ：CLPOB上升沿位置
CLPOB_FALLING				  ：CLPOB下降沿位置
CLPDM_RISING				  : CLPDM上升沿位置
CLPDM_FALLING				  : 沿位置
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
7、垂直驱动相关参数定义
XV_Line_Position			 : 行间V信号变化位置
XV_Line_Value0				 : 行间V信号变化位置的值
XV_Line_defaultValue		 : 行间V信号默认值

SUB_rising					 ：SUB信号上升沿位置
SUB_falling					 ：SUB信号下降沿位置
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
8、帧翻转相关参数定义
XSG_DEFAULTVALUE			 ：帧翻转期间XSG系列信号的值
XSG_WIDTH					 ：帧翻转期间XSG信号的宽度
XSGCOUNT_LENGTH				 : 帧翻转计数器长度
XSUB_DECIMALSTART			 : 小数曝光的SUB信号起始位置
XSUB_DECIMALEND				 : 小数曝光的SUB信号结束位置 XSUB_DecimalStart+`XSUB_Width

XV_XSG_POSITION1			 : 帧翻转期间V系列信号的状态1位置
XV_XSG_POSITION2			 : 帧翻转期间V系列信号的状态2位置
XV_XSG_POSITION3			 ：帧翻转期间V系列信号的状态3位置
XV_XSG_POSITION4			 ：帧翻转期间V系列信号的状态4位置
XV_XSG_POSITION5			 ：帧翻转期间V系列信号的状态5位置
XV_XSG_POSITION6			 ：帧翻转期间V系列信号的状态6位置
XV_XSG_POSITION7			 ：帧翻转期间V系列信号的状态7位置
XV_XSG_POSITION8			 ：帧翻转期间V系列信号的状态8位置

V_XSG_VALUE0				 : 帧翻转期间V系列信号状态1的值
V_XSG_VALUE1				 : 帧翻转期间V系列信号状态2的值
V_XSG_VALUE2				 : 帧翻转期间V系列信号状态3的值
V_XSG_VALUE3				 : 帧翻转期间V系列信号状态4的值
V_XSG_VALUE4				 : 帧翻转期间V系列信号状态5的值
V_XSG_VALUE5				 : 帧翻转期间V系列信号状态6的值
V_XSG_VALUE6				 : 帧翻转期间V系列信号状态7的值
V_XSG_VALUE7				 : 帧翻转期间V系列信号状态8的值
XV_XSG_DEFAULTVALUE		 	 : 帧翻转期间V系列信号的默认值
****************************************************************************************************************/
	`define XSG_DEFAULTVALUE				{`XSG_WD{1'B1}}					//
	`define XSGCOUNT_LENGTH				   	(`LINE_PIX*2) 					//


	`define XSG1_RISING						(`REG_WD'D0400 + `LINE_PIX)		//xsg开始位置不补偿，因为不能往前移动了
	`define XSG1_FALLING					(`REG_WD'D0720 + `LINE_PIX + (`XV_FALLING_EDGE_COMPENSATION - `XV_RISING_EDGE_COMPENSATION))	//XSG结束位置往后推2个clk
	`define XSG_VALUE1                 		`XSG_WD'B0						//需确认电路连接
	`define XSG_VALUE2                 		`XSG_WD'B1

	`define XV_XSG_POSITION1			   	`REG_WD'D0001 			//不能为零，因为需要在xsgcount==0时置位o_xsg_clear
																	//在xsg count为1的时候，xv3下降，不能往前了，因此只能在xsg结束的时候，往后延时
	`define XV_XSG_POSITION2			   	(`REG_WD'D0820 + `LINE_PIX + (`XV_FALLING_EDGE_COMPENSATION - `XV_RISING_EDGE_COMPENSATION))	//XSG结束位置往后推2个clk

	`define V_XSG_VALUE1				   	`V_WIDTH'B0100					//
	`define V_XSG_VALUE2				   	`V_WIDTH'B1100					//
	`define XV_XSG_DEFAULTVALUE			   	`V_WIDTH'B1100					//

//	-------------------------------------------------------------------------------------
//	曝光时间 默认30ms
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
////	30帧/s 帧率模式下寄存器默认值定义
////	图像尺寸：		1320*976
////	默认时钟：		45MHz
////	帧率：			30帧/s
////	每行时钟个数：	1513
////	一帧的行数：	991
////	计算公式：45000000/(1513*991) = 30
////	-------------------------------------------------------------------------------------
//	`define 	HEADBLANK_START_DEFVALUE	`REG_WD'D0001		//不能为0，否则在触发等待期间会处于场头空翻阶段
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
////	30帧/s 帧率模式下寄存器默认值定义
////	图像尺寸：		1372*982
////	默认时钟：		45MHz
////	帧率：			30帧/s
////	每行时钟个数：	1513
////	一帧的行数：	996
////	计算公式：45000000/(1513*996) = 29.86
////	-------------------------------------------------------------------------------------
//	`define 	HEADBLANK_START_DEFVALUE	`REG_WD'D0001		//不能为0，否则在触发等待期间会处于场头空翻阶段
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
//////	30帧/s 帧率模式下寄存器默认值定义
//////	图像尺寸：		1320*976
//////	默认时钟：		45MHz
//////	帧率：			30帧/s
//////	每行时钟个数：	1513
//////	一帧的行数：	986
//////	计算公式：45000000/(1513*991) = 30
//////	-------------------------------------------------------------------------------------
////	`define 	HEADBLANK_START_DEFVALUE	`REG_WD'D0001		//不能为0，否则在触发等待期间会处于场头空翻阶段
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
//////	30帧/s 帧率模式下寄存器默认值定义
//////	图像尺寸：		1280*960
//////	默认时钟：		45MHz
//////	帧率：			30帧/s
//////	每行时钟个数：	1540
//////	一帧的行数：	986
//////	计算公式：45000000/(1513*991) = 30
//////	-------------------------------------------------------------------------------------
////	`define 	HEADBLANK_START_DEFVALUE	`REG_WD'D0001		//不能为0，否则在触发等待期间会处于场头空翻阶段
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
//	30帧/s 帧率模式下寄存器默认值定义
//	图像尺寸：		1292*964
//	默认时钟：		45MHz
//	帧率：			30帧/s
//	每行时钟个数：	1532
//	一帧的行数：	977
//	计算公式：45000000/(1513*991) = 30
//	-------------------------------------------------------------------------------------
	`define 	HEADBLANK_START_DEFVALUE	`REG_WD'D0001		//不能为0，否则在触发等待期间会处于场头空翻阶段
	`define 	HEADBLANK_NUMBER_DEFVALUE	`REG_WD'D0015		//
	`define 	VSYNC_START_DEFVALUE		`REG_WD'D0005		//2
	`define 	VSYNC_START_FPGA_DEFVALUE	(`VSYNC_START_DEFVALUE+1)	//2
	`define 	TAILBLANK_START_DEFVALUE	`REG_WD'D0970		//963
	`define 	TAILBLANK_NUMBER_DEFVALUE	`REG_WD'D009		//1024
	`define 	TAILBLANK_END_DEFVALUE		`REG_WD'D0973		//980
	`define 	FRAME_PERIOD_DEFVALUE		`REG_WD'D0975		//977-2
	`define 	HREF_START_DEFVALUE			`REG_WD'D29			//
	`define 	HREF_END_DEFVALUE			`REG_WD'D1321		//

// cxd3400 在 xv的上升沿延时23ns输出，下降沿延时69ns输出
// xv rising edge compensation 1clk
	`define 		XV_RISING_EDGE_COMPENSATION		0

// xv falling edge compensation 3clk
	`define 		XV_FALLING_EDGE_COMPENSATION	0

	`define 	TRIGGERDELAYREG_DEFVALUE	`REG_WD'D0000
	`define 	FILTER_REDGEVALUE			`REG_WD'H0000
	`define 	FILTER_FEDGEVALUE			`REG_WD'H0000