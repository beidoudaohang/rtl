/**********************************************************************************************
-- Module		: CCD_Controler
-- File 		: CCD_Controler.v
-- Description 	: It is one module of the CCD_Top
-- Simulator 	: Modelsim 6.2c / Windows XP2
-- Synthesizer 	: Synplify8.0 / Windows XP2
-- Author / Designer 	: Song Weiming (songwm@daheng-image.com)
-- Copyright (c) notice : Daheng image Vision 2007-2010
--------------------------------------------------------------------
--------------------------------------------------------------------
-- Revision Number 	: 1
-- Modifier 		: LuDawei (ludw@daheng-image.com)
-- Description 		: Initial Design
//----------------------------------------------------------------------------
// Modification history :
// 2007-
// 2008-01-18 : LuDawei: finished
***********************************************************************************************/
`timescale 1ns/1ns
`include "RJ33J3DEF.v"
/**********************************************************************************************
1、模块实体及端口定义
Pixclk                         : 象素时钟
Reset                          : 全局复位信号
HD,VD                          : 输出给AD的行同步和帧同步信号，下降沿有效
XV,XSUB                    	: 输出给垂直驱动芯片的V系列信号、帧翻转信号和SUB信号（适用于3400）
HBLK,PBLK,CLPOB,CLPDM          : 输出给AD的钳位信号，用于AD的从模式
Frame_period                   : 帧周期，由上层CPU给出
HeadBlank_number               : 场头空跑次数寄存器，由上层CPU给出
Exp_start,Exp_end              : 曝光开始和曝光结束寄存器，由上层CPU给出
HeadBlank_start                ：场头空跑开始寄存器，由上层CPU给出
Vsync_start                    : 场有效开始(场头空跑结束)寄存器，由上层CPU给出
TailBlank_start                : 场尾空跑开始(场有效结束)寄存器，由上层CPU给出
Exposure_flag                  : 曝光标志信号
Hcount                         : 水平计数器
Vcount                         ：垂直计数器，由顶层模块传入
Href_start                     ：行有效开始寄存器，由顶层模块传入
Href_end                       ：行有效结束寄存器，由顶层模块传入
Href                           : 行有效信号，输出信号
Vsync                          : 场有效信号，输出信号
Hend                           ：行结束标志信号
***********************************************************************************************/
module       ccd_controler (
	input                       pixclk                 		,		//像素时钟
	input                       reset                		,       //复位
	input                       i_exposure_flag        		,       //曝光标志
	input                       i_waitflag             		,       //等待标志
	input                       i_xsg_start            		,       //帧翻转阶段开始标志
	input						i_xsub_last                 ,       //补充SUB信号
	input       [`REG_WD-1:0]   iv_href_start          		,       //行有效开始寄存器
	input       [`REG_WD-1:0]   iv_href_end            		,       //行有效结束寄存器
	input       [`REG_WD-1:0]   iv_frame_period        		,       //帧周期寄存器
	input		[`REG_WD-1:0]	iv_hperiod					,       //行周期寄存器
	input       [`REG_WD-1:0]   iv_headblank_number    		,       //场头空跑个数寄存器
	input       [`REG_WD-1:0]   iv_headblank_start     		,       //场头空跑开始寄存器
	input       [`REG_WD-1:0]   iv_vsync_start 	        	,       //场有效开始寄存器
	input       [`REG_WD-1:0]   iv_vsync_fpga_start     	,       //场有效输出开始寄存器
	input       [`REG_WD-1:0]   iv_tailblank_start     		,       //场尾空跑起始寄存器
	input       [`REG_WD-1:0]   iv_tailblank_number    		,       //场尾空跑个数
	input       [`REG_WD-1:0]   iv_tailblank_end    		,       //场尾空跑结束寄存器
	input       [`REG_WD-1:0]   iv_vcount              		,       //行计数器
	input						i_triggersel				,		//触发模式
	
	input						i_xsb_falling_direc			,		//xsub下降沿补偿的方向，0提前，1滞后
	input       [`REG_WD-1:0]   iv_xsb_falling_compensation ,		//xsub补偿的数值
	input						i_xsb_rising_direc			,		//xsub上升沿补偿的方向，0提前，1滞后
	input       [`REG_WD-1:0]   iv_xsb_rising_compensation	,		//xsub补偿的数值
	
	
	output                      o_xsub						,       //SUB信号
	output  reg                	o_hd                        ,       //AD驱动信号HD
	output  reg                	o_vd       			        ,       //AD驱动信号VD
	output	reg [`XSG_WD-1:0]	ov_xsg       				,       //帧翻转信号
	output  reg           		o_hend						,       //行尾信号
	output	reg					o_href						,       //行有效
	output						o_vsync       				,       //场有效
	output      [`V_WIDTH-1:0]	ov_xv                       ,       //垂直翻转信号
	output	reg					o_xsg_flag                  ,      //帧翻转标志
	output	reg					o_xsg_clear					,
	output		[`REG_WD-1:0]	ov_hcount
	);

	/**********************************************************************************************
	2、寄存器及线网定义
	***********************************************************************************************/
	reg                         headblank_flag          ;
	reg                         tailblank_flag          ;
	reg                         tailline_flag			;
	reg                         vsync_flag				;
	reg                         vsync_fpga_flag			;
	reg         [`V_WIDTH-1:0]  xv_line					;
	reg         [`V_WIDTH-1:0]  xv_xsg					;
	wire        [`V_WIDTH-1:0]  xv_headblank			;
	wire        [`V_WIDTH-1:0]  xv_tailblank			;
	wire        [`REG_WD-1:0]	xsgcount				;
	reg			[2:0]			triggersel_shift		;
	reg                         xsub_line      			;
	reg							hclear					;
	wire		[`REG_WD-1:0]	hcount					;
	reg							vsync_mask				;

	reg							vsync_flag_dly 		= 1'b0;
	reg		[1:0]				exposure_flag_shift = 2'b11;
	/***************************************************************************************************************
	3、例化各个模块,各模块定义如下：
	Counter_HeadBlank：场头空跑计数器模块
	Counter_TailBlank：场尾空跑计数器模块
	Counter_H        ：水平计数器模块
	Counter_V        ：垂直计数器模块
	Counter_Xsg      ：帧翻转计数器模块
	Head_BlankRun    ：场头空跑模块
	Tail_BlankRun    ：场尾空跑模块
	注：各个模块的详细端口定义详见各模块文件说明
	****************************************************************************************************************/
	counter  counter_h_inst (
	.clk		(pixclk				),
	.hend		(1'b1				),
	.i_clk_en	(1'b1				),
	.i_aclr		(hclear				),
	.ov_q       (hcount				)
	);

	counter  counter_xsg_inst (
	.clk		(pixclk				),
	.hend		(1'b1				),
	.i_clk_en	(1'b1				),
	.i_aclr		(!o_xsg_flag		),
	.ov_q       (xsgcount			)
	);

	blank_run # (
	.LINE_START_POSITION	(`HEADBLANK_LINE_START_POSITION	),
	.LINE_END_POSITION		(`HEADBLANK_LINE_END_POSITION	),
	.STATE_WIDTH			(`HEADBLANK_STATE_WIDTH			),
	.XV_DEFAULT_VALUE		(`XV_BLANKHEAD_DEFAULTVALUE		),
	.XV_VALUE1				(`V_BLANKHEAD_VALUE1			),
	.XV_VALUE2				(`V_BLANKHEAD_VALUE2			),
	.XV_VALUE3				(`V_BLANKHEAD_VALUE3			),
	.XV_VALUE4				(`V_BLANKHEAD_VALUE4			),
	.XV_VALUE5				(`V_BLANKHEAD_VALUE5			),
	.XV_VALUE6				(`V_BLANKHEAD_VALUE6			),
	.XV_VALUE7				(`V_BLANKHEAD_VALUE7			),
	.XV_VALUE8				(`V_BLANKHEAD_VALUE8			)
	)
	headblank_inst (
	.clk					(pixclk							),
	.reset					(reset							),
	.iv_hcount				(hcount							),
	.i_blank_flag			(headblank_flag					),
	.iv_blank_number		(iv_headblank_number			),
	.ov_xv					(xv_headblank					)
	);

	blank_run # (
	.LINE_START_POSITION	(`TAILBLANK_LINE_START_POSITION	),
	.LINE_END_POSITION		(`TAILBLANK_LINE_END_POSITION	),
	.STATE_WIDTH			(`TAILBLANK_STATE_WIDTH			),
	.XV_DEFAULT_VALUE		(`XV_BLANKTAIL_DEFAULTVALUE		),
	.XV_VALUE1				(`V_BLANKTAIL_VALUE1			),
	.XV_VALUE2				(`V_BLANKTAIL_VALUE2			),
	.XV_VALUE3				(`V_BLANKTAIL_VALUE3			),
	.XV_VALUE4				(`V_BLANKTAIL_VALUE4			),
	.XV_VALUE5				(`V_BLANKTAIL_VALUE5			),
	.XV_VALUE6				(`V_BLANKTAIL_VALUE6			),
	.XV_VALUE7				(`V_BLANKTAIL_VALUE7			),
	.XV_VALUE8				(`V_BLANKTAIL_VALUE8			)
	)
	tailblank_inst (
	.clk					(pixclk					),
	.reset					(reset				),
	.iv_hcount				(hcount					),
	.i_blank_flag			(tailblank_flag			),
	.iv_blank_number		(iv_tailblank_number	),
	.ov_xv					(xv_tailblank			)
	);

	/***************************************************************************************************************
	4、水平计数器：
	Hend       :水平计数器复位信号 1-reset
	****************************************************************************************************************/
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			hclear	<= 1'b1;
		end
		else begin
			if(hcount == iv_hperiod) begin
				hclear	<= 1'b1;
			end
			else begin
				hclear	<= 1'b0;
			end
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_hend	<= 1'b1;
		end
		else begin
			//if (hcount==`REG_WD'h30)
			if(hcount == `REG_WD'h1) begin
				o_hend	<= 1'b1;
			end
			else begin
				o_hend	<= 1'b0;
			end
		end
	end
	assign	ov_hcount	= hcount;
	/***************************************************************************************************************
	6、生成场头场尾空跑、场正程以及帧翻转的标志信号：
	****************************************************************************************************************/
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triggersel_shift <=	3'b000;
		end
		else begin
			triggersel_shift <=	{triggersel_shift[1:0],i_triggersel};
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			vsync_mask	<= 1'b1;
		end
		else if(triggersel_shift == 3'b100) begin		//由触发切换到连续模式，将屏蔽标志拉低
			vsync_mask	<= 1'b0;
		end
		else if(o_xsg_clear) begin						//进行一次完整曝光后（或者一帧时间后）去除屏蔽
			vsync_mask	<= 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	添加vsync_flag_dly信号，原因是之前的hend是在hcount在0x30的产生，现在hend在hcount等于0x1的时候产生
	//	在0x1-0x30的时候，产生sub信号，为了使vsync原理sub信号，需要延迟vsync信号产生的时间
	//  -------------------------------------------------------------------------------------
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			vsync_flag_dly	<= 1'b0;
		end
		//	else if((vsync_flag == 1'b1)&&(hcount==`REG_WD'h30)) begin
//		else if((vsync_fpga_flag == 1'b1)&&(hcount==`REG_WD'h30)) begin
		else if((vsync_fpga_flag == 1'b1)&&(hcount==`REG_WD'h64)) begin
			vsync_flag_dly	<= 1'b1;
		end
		//	else if(!vsync_flag) begin
//		else if((!vsync_fpga_flag)&&(hcount==`REG_WD'h30)) begin
		else if((!vsync_fpga_flag)&&(hcount==`REG_WD'h64)) begin
			vsync_flag_dly	<=	1'b0;
		end
	end

	//assign  o_vsync= vsync_flag & vsync_mask;
	assign  o_vsync	= vsync_flag_dly & vsync_mask;

//	always@(posedge pixclk or posedge reset) begin
//		if(reset) begin
//			headblank_flag	<= 1'b0;
//			tailblank_flag	<= 1'b0;
//			vsync_flag    	<= 1'b0;
//			vsync_fpga_flag	<= 1'b0;
//			tailblank_flag	<= 1'b0;
//			tailline_flag	<= 1'b0;
//		end
//		else if(o_hend) begin
//			case(iv_vcount)
//				iv_headblank_start			:	begin	headblank_flag	<=1'b1;	end
//				iv_vsync_start				:	begin	headblank_flag	<=1'b0;
//														vsync_flag		<=1'b1;	end
//				iv_vsync_fpga_start			:	begin	vsync_fpga_flag	<=1'b1;	end
//	
//				iv_tailblank_start			:	begin	vsync_flag    	<=1'b0;
//														vsync_fpga_flag	<=1'b0;
//				tailblank_flag	<=1'b1;	end
//				iv_tailblank_end			:	begin	tailblank_flag	<=1'b0;
//														tailline_flag	<=1'b1;
//				end
//				iv_frame_period-16'h0001	:	begin	tailline_flag	<=1'b0;	end
//				default:	;
//			endcase
//		end
//	end
	
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			headblank_flag	<= 1'b0;
		end
		else if(o_hend) begin
			if(iv_vcount == iv_headblank_start) begin
				headblank_flag	<= 1'b1;
			end
			else if(iv_vcount == iv_vsync_start) begin
				headblank_flag	<= 1'b0;
			end
		end
	end
	
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			tailblank_flag	<= 1'b0;
		end
		else if(o_hend) begin
			if(iv_vcount == iv_tailblank_start) begin
				tailblank_flag	<= 1'b1;
			end
			else if(iv_vcount == iv_tailblank_end) begin
				tailblank_flag	<= 1'b0;
			end
		end
	end
	
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			vsync_flag    	<= 1'b0;
		end
		else if(o_hend) begin
			if(iv_vcount == iv_vsync_start) begin
				vsync_flag	<= 1'b1;
			end
			else if(iv_vcount == iv_tailblank_start) begin
				vsync_flag	<= 1'b0;
			end
		end
	end
	
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			vsync_fpga_flag	<= 1'b0;
		end
		else if(o_hend) begin
			if(iv_vcount == iv_vsync_fpga_start) begin
				vsync_fpga_flag	<= 1'b1;
			end
			else if(iv_vcount == iv_tailblank_start) begin
				vsync_fpga_flag	<= 1'b0;
			end
		end
	end
	
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			tailline_flag	<= 1'b0;
		end
		else if(o_hend) begin
			if(iv_vcount == iv_tailblank_end) begin
				tailline_flag	<= 1'b1;
			end
			else if(iv_vcount == (iv_frame_period-16'h0001)) begin
				tailline_flag	<= 1'b0;
			end
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_vd	<= 1'b1;
		end
		else begin
			if(iv_vcount == `VD_RISING) begin
				o_vd	<= 1'b1;
			end
			else if(iv_vcount == `VD_FALLING) begin
				o_vd	<= 1'b0;
			end
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_hd	<= 1'b1;
		end
		else begin
			if(hcount == `HD_RISING) begin
				o_hd	<= 1'b1;
			end
			else if(hcount == `HD_FALLING) begin
				o_hd	<= 1'b0;
			end
		end
	end
	
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			xv_line	<= `XV_LINE_DEFAULTVALUE;
			
		end
		else begin
			case(hcount)
				`XV_LINE_POSITION1	: xv_line	<= `V_LINE_VALUE1;
				`XV_LINE_POSITION2	: xv_line	<= `V_LINE_VALUE2;
				`XV_LINE_POSITION3	: xv_line	<= `V_LINE_VALUE3;
				`XV_LINE_POSITION4	: xv_line	<= `V_LINE_VALUE4;
				`XV_LINE_POSITION5	: xv_line	<= `V_LINE_VALUE5;
				`XV_LINE_POSITION6	: xv_line	<= `V_LINE_VALUE6;
				`XV_LINE_POSITION7	: xv_line	<= `V_LINE_VALUE7;
				`XV_LINE_POSITION8	: xv_line	<= `V_LINE_VALUE8;
				default	:	;
			endcase
		end
	end
	
//	always@(posedge pixclk or posedge reset) begin
//		if(reset) begin
//			xsub_line	<= 1'b1;
//		end
//		else begin
//			case(hcount)
//				`SUB_FALLING	: xsub_line	<= 1'b0;
//				`SUB_RISING		: xsub_line	<= 1'b1;
//				default	:	;
//			endcase
//		end
//	end	
	
	//xsub 做补偿
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			xsub_line	<= 1'b1;
		end
		else begin
			if(i_xsb_falling_direc == 1'b0) begin	//xsub 下降沿的位置往前移动
				if(iv_xsb_falling_compensation == `REG_WD'b0) begin	//当所补偿的数值时0时，减法所得的数值时1513，hount到不了这个数值
					if(hcount == `SUB_FALLING) begin
						xsub_line	<= 1'b0;
					end
				end
				else begin
					if(hcount == `LINE_PIX - iv_xsb_falling_compensation) begin	//当所补偿的数值非0时，1513-reg即为xsub下降沿的位置
						xsub_line	<= 1'b0;
					end
				end
			end
			else begin								//xsub 下降沿的位置往后移动
				if(hcount == `SUB_FALLING + iv_xsb_falling_compensation) begin
					xsub_line	<= 1'b0;
				end
			end
			
			if(i_xsb_rising_direc == 1'b0) begin	//xsub 上升沿的位置往前移动
				if(hcount == `SUB_RISING - iv_xsb_rising_compensation) begin
					xsub_line	<= 1'b1;
				end
			end
			else begin								//xsub 上升沿的位置往后移动
				if(hcount == `SUB_RISING + iv_xsb_rising_compensation) begin
					xsub_line	<= 1'b1;
				end
			end
		end
	end	
	
	
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_href	<= 1'b0;
		end
		else begin
			if(hcount == iv_href_start) begin
				o_href	<= 1'b1;
			end
			else if(hcount == iv_href_end) begin
				o_href	<= 1'b0;
			end
		end
	end
	/***************************************************************************************************************
	10、帧翻转：
	****************************************************************************************************************/
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_xsg_flag	<= 1'b0;
		end
		else if(o_xsg_clear) begin
			o_xsg_flag	<= 1'b0;
		end
		else if(i_xsg_start) begin
			o_xsg_flag	<= 1'b1;
		end
	end

//	always@(posedge pixclk or posedge reset) begin
//		if(reset) begin
//			xv_xsg		<= `XV_XSG_DEFAULTVALUE;
//			ov_xsg		<= {`XSG_WD{1'B1}};
//			o_xsg_clear	<= 1'b0;
//		end
//		else begin
//			case(xsgcount)
//				`XV_XSG_POSITION1   :	xv_xsg 		<= `V_XSG_VALUE1;
//				`XV_XSG_POSITION2   :	xv_xsg  	<= `V_XSG_VALUE2;
//				`XSG1_RISING    	:	ov_xsg		<= `XSG_VALUE1;
//				`XSG1_FALLING    	:	ov_xsg		<= `XSG_VALUE2;
//				`XSGCOUNT_LENGTH    :	o_xsg_clear	<= 1'b0;
//				default				:   o_xsg_clear	<= 1'b1;
//			endcase
//		end
//	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			xv_xsg	<= `XV_XSG_DEFAULTVALUE;
		end
		else begin
			if(xsgcount == `XV_XSG_POSITION1) begin
				xv_xsg	<= `V_XSG_VALUE1;
			end
			else if(xsgcount == `XV_XSG_POSITION2) begin
				xv_xsg	<= `V_XSG_VALUE2;
			end
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			ov_xsg	<= {`XSG_WD{1'B1}};
		end
		else begin
			if(xsgcount == `XSG1_RISING) begin
				ov_xsg	<= `XSG_VALUE1;
			end
			else if(xsgcount == `XSG1_FALLING) begin
				ov_xsg	<= `XSG_VALUE2;
			end
		end
	end
	
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_xsg_clear	<= 1'b0;
		end
		else begin
			if(xsgcount == `XSGCOUNT_LENGTH) begin
				o_xsg_clear	<= 1'b1;
			end
			else begin
				o_xsg_clear	<= 1'b0;
			end
		end
	end

	/***************************************************************************************************************
	11、曝光逻辑：
	曝光分为行曝光和小数曝光，不足一行的曝光时间用小数曝光来表示
	****************************************************************************************************************/
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			exposure_flag_shift	<= 2'b11;
		end
		else begin
			exposure_flag_shift	<= {exposure_flag_shift[0],i_exposure_flag};
		end
	end

	assign o_xsub =	(exposure_flag_shift[1]	== 1'b1) ? i_xsub_last:
	(o_xsg_flag	== 1'b1) ? 1'b1:
	xsub_line ;

	/***************************************************************************************************************
	12、生成V系列信号和SUB信号输出：
	****************************************************************************************************************/
	assign ov_xv   =(headblank_flag	== 1'b1)     ?  xv_headblank	:
	(vsync_flag        	== 1'b1)     ?  xv_line     	:
	(o_xsg_flag         == 1'b1)     ?  xv_xsg			:
	(tailblank_flag    	== 1'b1)     ?  xv_tailblank	:
	(i_waitflag      	== 1'b1)     ?  xv_line			:
	(tailline_flag     	== 1'b1)     ?  xv_line			:
	`XV_DEFVALUE;




endmodule