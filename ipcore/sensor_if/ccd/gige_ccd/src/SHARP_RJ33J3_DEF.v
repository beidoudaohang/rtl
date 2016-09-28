//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : ICX274DEF
//  -- 设计者       : 禹剑
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 禹剑         :| 2014/1/16			:|  初始版本
//  -- 陈小平      	:| 07/29/2015   		:|  进行修改，适应于ICX445 sensor
//  -- 邢海涛      	:| 2015/8/17 13:31:11	:|  进行修改，适应于sharp rj33j3 sensor
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : sharp rj33j3 CCD宏定义
//
//-------------------------------------------------------------------------------------------------
//  仿真单位/精度
`timescale 1ns/100ps
//-------------------------------------------------------------------------------------------------

//  ===============================================================================================
//  1、位宽定义
//  ===============================================================================================

`define 	XV_WD							4													// XV信号位宽
`define 	XSG_WD							1       											// XSG信号位宽

//`define 	FRAME_WD						19													// 帧内行数位宽
`define 	FRAME_WD						16													// 帧内行数位宽

`define 	LINE_WD							11													// 行内像素数位宽
`define 	XSG_LINE_WD						12													// XSG整数行行数位宽
`define 	EXP_WD							30													// 曝光像素个数位宽
`define 	EXP_XSG_WD						12													// 曝光XSG部分小数像素个数位宽
`define 	FRAME_PIX_CNT_WD				22													// 一帧图像的像素总个数
`define 	TEST_IO_WD						4													// IO个数

//  ===============================================================================================
//	2、水平计数器相关参数定义
//  ===============================================================================================

`define 	LINE_PIX					   	`LINE_WD'd1532	 									// 行周期:1532
`define 	LINE_PERIOD					   	`LINE_PIX-`LINE_WD'd1		 									// 行周期:1532-1
`define 	FRAME_PIXEL_CNT					`FRAME_PIX_CNT_WD'd1499828							// 一帧图像的像素总个数,1532*979

//  ===============================================================================================
//	3、AD相关参数定义
//  ===============================================================================================

`define 	HD_RISING					 	`LINE_WD'd88 										// HD宽度总共100，HD上升沿位置 78
`define 	HD_FALLING					 	`LINE_PIX-`LINE_WD'd13		  								// HD下降沿位置 1512-12，

//触发等待期间VD不能为低
`define 	VD_RISING					 	`FRAME_WD'H0003 									// VD上升沿位置
`define 	VD_FALLING					 	`FRAME_WD'H0001										// VD下降沿位置

//  ===============================================================================================
//	4、水平驱动相关参数定义
//  ===============================================================================================

//  ===============================================================================================
//	5、垂直驱动相关参数定义
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//  正常翻转
//  -------------------------------------------------------------------------------------

`define		XV_LINE_POSITION1			   	(`LINE_WD'd33+1) 									// 行间V信号变化位置1,因为sub下降沿不能设为0，只能设为1，因此xv翻转位置往后移动1个像素
`define 	XV_LINE_POSITION2			   	(`LINE_WD'd47+1) 									// 行间V信号变化位置2
`define 	XV_LINE_POSITION3			   	(`LINE_WD'd61+1) 									// 行间V信号变化位置3
`define 	XV_LINE_POSITION4			   	(`LINE_WD'd75+1) 									// 行间V信号变化位置4
`define 	XV_LINE_POSITION5			   	(`LINE_WD'd92+1) 									// 行间V信号变化位置5
`define 	XV_LINE_POSITION6			   	(`LINE_WD'd106+1) 									// 行间V信号变化位置6
`define 	XV_LINE_POSITION7			   	(`LINE_WD'd120+1) 									// 行间V信号变化位置7
`define 	XV_LINE_POSITION8			   	(`LINE_WD'd134+1) 									// 行间V信号变化位置8

`define 	XV_LINE_VALUE1				   	`XV_WD'B1000										// 行间V信号变化位置的值1
`define 	XV_LINE_VALUE2				   	`XV_WD'B1001										// 行间V信号变化位置的值2
`define 	XV_LINE_VALUE3				   	`XV_WD'B0001										// 行间V信号变化位置的值3
`define 	XV_LINE_VALUE4				   	`XV_WD'B0011										// 行间V信号变化位置的值4
`define 	XV_LINE_VALUE5				   	`XV_WD'B0010										// 行间V信号变化位置的值5
`define 	XV_LINE_VALUE6				   	`XV_WD'B0110										// 行间V信号变化位置的值6
`define 	XV_LINE_VALUE7				   	`XV_WD'B0100										// 行间V信号变化位置的值7
`define 	XV_LINE_VALUE8				   	`XV_WD'B1100										// 行间V信号变化位置的值8

`define 	XV_LINE_DEFAULT		   			`XV_WD'B1100										// XV信号行正程期间的默认值

//  -------------------------------------------------------------------------------------
//  快速翻转
//  -------------------------------------------------------------------------------------

`define 	HEADBLANK_PERIOD			    `LINE_WD'd190									// 场头空跑周期 ,sharp rj33j3 191 * 8 =1528  ，total 1532
`define 	TAILBLANK_PERIOD			   	`LINE_WD'd190									// 场尾空跑周期

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


`define 	V_BLANKHEAD_VALUE1			   	`XV_WD'B1100							// 场头状态1下V系列信号的值
`define 	V_BLANKHEAD_VALUE2			   	`XV_WD'B1000							// 场头状态2下V系列信号的值
`define 	V_BLANKHEAD_VALUE3			   	`XV_WD'B1001							// 场头状态3下V系列信号的值
`define 	V_BLANKHEAD_VALUE4			   	`XV_WD'B0001							// 场头状态4下V系列信号的值
`define 	V_BLANKHEAD_VALUE5		   		`XV_WD'B0011							// 场头状态5下V系列信号的值
`define 	V_BLANKHEAD_VALUE6		   		`XV_WD'B0010							// 场头状态5下V系列信号的值
`define 	V_BLANKHEAD_VALUE7		   		`XV_WD'B0110							// 场头状态5下V系列信号的值
`define 	V_BLANKHEAD_VALUE8		   		`XV_WD'B0100							// 场头状态5下V系列信号的值
`define 	XV_BLANKHEAD_DEFAULT	   		`XV_WD'B1100							//

`define 	V_BLANKTAIL_VALUE1			   	`XV_WD'B1100							// 场尾状态1下V系列信号的值
`define 	V_BLANKTAIL_VALUE2			   	`XV_WD'B1000							// 场尾状态2下V系列信号的值
`define 	V_BLANKTAIL_VALUE3			   	`XV_WD'B1001							// 场尾状态3下V系列信号的值
`define 	V_BLANKTAIL_VALUE4			   	`XV_WD'B0001							// 场尾状态4下V系列信号的值
`define 	V_BLANKTAIL_VALUE5				`XV_WD'B0011							// 场尾状态5下V系列信号的值
`define 	V_BLANKTAIL_VALUE6				`XV_WD'B0010							// 场尾状态5下V系列信号的值
`define 	V_BLANKTAIL_VALUE7				`XV_WD'B0110							// 场尾状态5下V系列信号的值
`define 	V_BLANKTAIL_VALUE8				`XV_WD'B0100							// 场尾状态5下V系列信号的值
`define 	XV_BLANKTAIL_DEFAULT			`XV_WD'B1100							//

//  ===============================================================================================
//	6、SUB相关参数定义
//  ===============================================================================================

`define 	SUB_RISING					   `LINE_WD'd31 									// SUB信号上升沿位置
`define 	SUB_FALLING					   `LINE_WD'd1 									// SUB信号下降沿位置
`define 	SUB_PER_WIDTH 					`EXP_WD'd31										//

//  ===============================================================================================
//	7、帧翻转相关参数定义
//  ===============================================================================================
`define XSG_WIDTH 							`EXP_WD'd420			//

`define XSG1_RISING						1		//xsg开始位置
`define XSG1_FALLING					320		//XSG结束位置

//***********ICX274当中没有这些参数。
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
//	曝光时间 30ms
//	-------------------------------------------------------------------------------------
`define 	EXPOSURE_LINE_REG_DEFVALUE		`LINE_PIX								//
`define 	EXPOSURE_REG_DEFVALUE			(30000*45+131)							//
//`define 	EXPOSURE_REG_DEFVALUE			(50*45+131)							//
`define 	EXPOSURE_LINE_DEFVALUE			(`EXPOSURE_REG_DEFVALUE/`LINE_PIX)		//
`define 	EXPOSURE_START_LINE				(`FRAME_PERIOD_DEFVALUE - `EXPOSURE_LINE_DEFVALUE)	//

//////  ===============================================================================================
//////	8、帧率模式下寄存器默认值定义
//////	图像尺寸	： 	1600×980，有效像素尺寸： ,1292 * 964
//////	默认时钟	： 	48MHz
//////	帧率		:	30帧/S
//////	曝光默认值	：
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
//////	8、帧率模式下寄存器默认值定义
//////	图像尺寸	： 	1531x991，有效像素尺寸： ,1372 * 984
//////	默认时钟	： 	45MHz
//////	帧率		:	30帧/S
//////	曝光默认值	：
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
//	8、帧率模式下寄存器默认值定义
//	图像尺寸	： 	1532x979，有效像素尺寸： ,1292 * 964
//	默认时钟	： 	45MHz
//	帧率		:	30帧/S
//	曝光默认值	：
//  ==============================================================================================
`define		HEADBLANK_END_DEFVALUE			`FRAME_WD'd3										//
`define 	VSYNC_START_DEFVALUE			`FRAME_WD'd11										//
`define 	TAILBLANK_START_DEFVALUE		`FRAME_WD'd975										//
`define		TAILBLANK_END_DEFVALUE			`FRAME_WD'd976										//
`define 	FRAME_PERIOD_DEFVALUE			`FRAME_WD'd978										//

//	-------------------------------------------------------------------------------------
//	这两个参数定义ccd输出href vref的时序
//	-------------------------------------------------------------------------------------
`define 	HREF_START_DEFVALUE				(`LINE_WD'd26+`LINE_WD'd70)									//
`define 	HREF_END_DEFVALUE				(`LINE_WD'd1398+`LINE_WD'd70)									//

//	-------------------------------------------------------------------------------------
//	这两个参数定义ad9970输出同步字之后偏移位置
//	-------------------------------------------------------------------------------------
`define 	HREF_START_AD_DEFVALUE			`LINE_WD'd26										//
`define 	HREF_END_AD_DEFVALUE			`LINE_WD'd1398										//

