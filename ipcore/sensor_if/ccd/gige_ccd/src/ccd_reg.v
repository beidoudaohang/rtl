
//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : ccd_reg.v
//  -- 设计者       : 禹剑
//-------------------------------------------------------------------------------------------------
//
//  --修改记录  :
//
//  -- 作者         :| 修改日期     :|  修改说明
//---------------------------------------------------------------------------------------
//  -- 禹剑       	:| 09/16/2013   :|  初始版本
//  -- 陈小平      	:| 04/29/2015   :|  进行修改，适应于ICX445 sensor
//
//---------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale      1ns/100ps
//-------------------------------------------------------------------------------------------------

`include "SHARP_RJ33J3_DEF.v"

module ccd_reg (
	input                                   		clk      			,   //时钟
	input											reset				,	//复位，高有效
	input                                   		i_reg_active    	,   //
	input		[`FRAME_WD-1:0]						iv_frame_period		,   //帧周期寄存器
	input		[`FRAME_WD-1:0]						iv_headblank_end	,   //
	input		[`FRAME_WD-1:0]						iv_vref_start		,   //ROI开始行数
	input		[`FRAME_WD-1:0]						iv_tailblank_start	,   //ROI结束行数
	input		[`FRAME_WD-1:0]						iv_tailblank_end	,   //
	input		[`FRAME_WD-1:0]						iv_exp_line			,	//
	input		[`EXP_WD-1:0]						iv_exp_reg			,   //曝光阶段时钟个数寄存器

	output	reg	[`FRAME_WD-1:0]						ov_frame_period		,   //帧周期寄存器
	output	reg	[`FRAME_WD-1:0]						ov_headblank_end	,   //帧周期寄存器
	output	reg	[`FRAME_WD-1:0]						ov_vref_start		,   //ROI开始行数
	output	reg	[`FRAME_WD-1:0]						ov_tailblank_start	,   //ROI结束行数
	output	reg	[`FRAME_WD-1:0]						ov_tailblank_end	,   //帧周期寄存器
	output	reg	[22:0]								ov_tailblank_num	,	//
	output	reg	[22:0]								ov_headblank_num	,	//
	output	reg	[`FRAME_WD-1:0]						ov_exp_start_reg	,	//曝光起始行位置寄存器
	output	reg	[`EXP_WD-1:0]						ov_exp_line_reg		,	//曝光整行时钟个数寄存器
	output	reg	[`EXP_WD-1:0]						ov_exp_reg			,   //曝光时钟个数寄存器
	output	reg	[`EXP_WD-1:0]						ov_exp_xsg_reg			//曝光xsg时钟个数寄存器
	);

	//  ===============================================================================================
	//  第一部分：模块设计中要用到的信号
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  寄存器、线网定义
	//  -------------------------------------------------------------------------------------
	reg										reg_active_dly_0	;
	wire		[`FRAME_WD-1:0]				frame_period		;
	wire		[`EXP_WD-1:0]				exp_line_reg		;
	wire		[22:0]						wv_headblank_num	;
	wire		[22:0]						wv_tailblank_num	;

	//  ===============================================================================================
	//  第二部分：模块实例化
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  功能说明： 行曝光结束，使用乘法器（输出延后1个周期）
	//  -------------------------------------------------------------------------------------
	line_exp_mult line_exp_mult_inst (
	.clk					(clk									), 	//时钟
	.a						({3'b0,iv_exp_line}						), 	//整行数
	.b						(`LINE_PIX								), 	//行周期
	.p						(exp_line_reg							)	//曝光整行时钟个数寄存器
	);

	//  -------------------------------------------------------------------------------------
	//  功能说明： 场头空翻个数
	//  -------------------------------------------------------------------------------------
	blank_mult headblank_mult_inst (
	.clk					(clk									), 	//时钟
	.a						({3'b0,(ov_headblank_end - `FRAME_WD'd8)}		), 		//ICX445, XSG(2) + DUMMY(2) 整行数,黑像素行的第6行开始进行快翻
	.b						(4'd8									), 	//
	.p						(wv_headblank_num						)	//
	);

	//  -------------------------------------------------------------------------------------
	//  功能说明： 场尾空翻个数
	//  -------------------------------------------------------------------------------------
	blank_mult tailblank_mult_inst (
	.clk					(clk									), 	//时钟
	.a						({3'b0,(iv_tailblank_end - iv_tailblank_start)}	), 	//整行数
	.b						(4'd8									), 	//
	.p						(wv_tailblank_num						)	//
	);

	//  ===============================================================================================
	//  第三部分：逻辑
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  功能说明：延时打拍
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			reg_active_dly_0 	<= 1'b0;
		end
		else begin
			reg_active_dly_0 	<= i_reg_active;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  功能说明：readout锁存寄存器
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//  针对icx445，开始几行：2(XSG)+2(DUMMY)+8(BLACK)   ，因此我们将黑像素的第10行开始进行快翻
	//                    使用场头黑像素进行黑像素钳位，针对bug  ID148，
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			ov_headblank_end 	<= 	`HEADBLANK_END_DEFVALUE;
			ov_vref_start 		<= 	`VSYNC_START_DEFVALUE;
			ov_tailblank_start 	<= 	`TAILBLANK_START_DEFVALUE;
			ov_tailblank_end 	<= 	`TAILBLANK_END_DEFVALUE;
			ov_tailblank_num	<=	23'd0;
			ov_headblank_num	<=	23'd0;
		end
		else if(reg_active_dly_0) begin
			ov_headblank_end 	<= 	iv_headblank_end + `FRAME_WD'd6;	//黑像素14行后开始进行快翻 ，
			ov_vref_start 		<= 	iv_vref_start;
			ov_tailblank_start 	<= 	iv_tailblank_start;
			ov_tailblank_end 	<= 	iv_tailblank_end;
			ov_headblank_num	<=	wv_headblank_num;
			ov_tailblank_num	<=	wv_tailblank_num;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  功能说明：曝光相关寄存器
	//  当曝光时间和帧周期相等时，曝光起始信号不能从xsg开始，xsg占用了4行，
	//  -------------------------------------------------------------------------------------

	//		assign	frame_period	=	(iv_exp_line >= iv_frame_period)	?	(iv_exp_line + `FRAME_WD'd4)	:	(iv_frame_period + `FRAME_WD'd4)	;
	assign	frame_period	=	((iv_exp_line + `FRAME_WD'd4) >= iv_frame_period)	?	(iv_exp_line + `FRAME_WD'd4)	:	iv_frame_period 	;

	always @ (posedge clk) begin
		if(reset) begin
			ov_frame_period 	<= 	`FRAME_PERIOD_DEFVALUE;
			ov_exp_start_reg	<=	`EXPOSURE_START_LINE;
		end
		else if(reg_active_dly_0) begin
			ov_frame_period 	<= 	frame_period;
			ov_exp_start_reg 	<= 	frame_period - iv_exp_line;
		end
	end

	always @ (posedge clk) begin
		if(reset) begin
			ov_exp_line_reg		<= 	`EXPOSURE_LINE_REG_DEFVALUE;
			ov_exp_reg			<= 	`EXPOSURE_REG_DEFVALUE;
			ov_exp_xsg_reg		<=	`EXPOSURE_REG_DEFVALUE - `EXPOSURE_LINE_REG_DEFVALUE;
		end
		else if(reg_active_dly_0) begin
			ov_exp_line_reg		<= 	exp_line_reg;
			ov_exp_reg			<= 	iv_exp_reg;
			ov_exp_xsg_reg		<= 	iv_exp_reg - exp_line_reg;
		end
	end

endmodule