/**********************************************************************************************
-- Module		: CCD_Top
-- File			: CCD_Top.v
-- Description	: It is a general top document of the CCD module
-- Simulator	: Modelsim 6.2c / Windows XP2
-- Synthesizer	: Synplify8.0 / Windows XP2
-- Author / Designer	: Song Weiming (songwm@daheng-image.com)
-- Copyright (c) notice : Daheng image Vision 2007-2010
--------------------------------------------------------------------
--------------------------------------------------------------------
-- Revision Number	: 1
-- Modifier			: LuDawei (ludw@daheng-image.com)
-- Description		: Initial Design
-- Revision Number	: 2
-- Modifier			: 刘海军 (liuhj@daheng-image.com)
-- Description		: CCD_Top模块修改。分为3部分：3-1连续模式；3-2触发模式；3-3模式切换
//----------------------------------------------------------------------------
// Modification history :
// 2007-12-28 : quartus-V1
// 2008-01-18 : LuDawei: finished
// 2012-06-01 ：刘海军：V2
***********************************************************************************************/
`timescale 1ns/1ns
`include "RJ33J3DEF.v"

module			ccd_top (
	input						pixclk			    		,	//像素时钟
	input						reset		        		,	//复位
	input                       i_triggerin					,	//给CCD模块的触发信号
	input						i_triggersel				,	//采集模式选择信号
	input		[`REG_WD-1:0]	iv_href_start				,	//行有效开始寄存器
	input		[`REG_WD-1:0]	iv_href_end					,	//行有效结束寄存器
	input		[`EXP_WD-1:0]	iv_exposure_reg				,	//曝光寄存器，单位像素时钟
	input		[`REG_WD-1:0]	iv_exposure_linereg			,	//行曝光寄存器，单位行周期
	input		[`REG_WD-1:0]	iv_frame_period				,	//帧周期寄存器
//	input		[`REG_WD-1:0]	iv_hperiod					,	//行周期寄存器
	input		[`REG_WD-1:0]	iv_headblank_number			,	//场头空跑次数寄存器
	//	input		[`REG_WD-1:0]	iv_headblank_start			,	//场头空跑开始寄存器
	input		[`REG_WD-1:0]	iv_vsync_start				,	//场有效开始(场头空跑结束)寄存器
	//	input		[`REG_WD-1:0]	iv_vsync_fpga_start			,	//场有效输出开始(场头空跑结束)寄存器
	input		[`REG_WD-1:0]	iv_tailblank_start			,	//场尾空跑开始(场有效结束)寄存器
	input		[`REG_WD-1:0]	iv_tailblank_number			,	//场尾空跑个数
	input		[`REG_WD-1:0]	iv_tailblank_end			,	//场尾空跑结束(场有效结束)寄存器
	//	input						i_xsb_falling_direc			,	//xsub下降沿补偿的方向，0提前，1滞后
	//	input       [`REG_WD-1:0]   iv_xsb_falling_compensation ,	//xsub补偿的数值
	//	input						i_xsb_rising_direc			,	//xsub上升沿补偿的方向，0提前，1滞后
	//	input       [`REG_WD-1:0]   iv_xsb_rising_compensation	,	//xsub补偿的数值
	output						o_strobe					,	//闪光灯信号
	output						o_integration				,	//积分信号
	output						o_triggerready				,	//触发屏蔽信号，低电平有效
	output						o_xsub						,	//SUB信号
	output						o_hd						,	//AD驱动信号HD
	output						o_vd						,	//AD驱动信号VD
	output		[`XSG_WD-1:0]	ov_xsg						,	//帧翻转信号
	output						o_href						,	//行有效信号
	output						o_vsync						,	//场有效信号
	output		[`V_WIDTH-1:0]	ov_xv						,	//垂直翻转信号
	output		[`V_WIDTH-1:0]	ov_xvs							//垂直翻转信号
	);

	//************************************

	/**********************************************************************************************
	1、寄存器及线网定义
	exposure_flag**				：触发曝光系列信号
	***********************************************************************************************/
	wire						w_exposure_start		;
	wire						w_exposure_preflag	;
	wire             			w_exp_over			;
	wire						w_xsg_start			;
	wire						w_hend				;
	wire						w_xsub_last_m			;
	wire		[`REG_WD-1 :0]	wv_frame_period_m		;
	wire		[`REG_WD-1 :0]	wv_hperiod			;
	wire		[`REG_WD-1 :0]	wv_headblank_number_m	;
	wire		[`REG_WD-1 :0]	wv_headblank_start_m	;
	wire		[`REG_WD-1 :0]	wv_tailblank_start_m	;
	wire		[`REG_WD-1 :0]	wv_tailblank_number_m	;
	wire		[`REG_WD-1 :0]	wv_tailblank_end_m		;
	wire		[`REG_WD-1 :0]	wv_vsync_start_m	;
	wire		[`REG_WD-1 :0]	wv_vsync_fpga_start_m	;
	wire		[`REG_WD-1 :0]	wv_href_start_m		;
	wire		[`REG_WD-1 :0]	wv_href_end_m			;
	wire		[`EXP_WD-1 :0]	wv_exposure_reg_m		;
	wire		[`REG_WD-1 :0]	wv_exposure_linereg_m	;
	wire						w_triggersel_m		;
	wire		[`REG_WD-1 :0]	wv_vcount				;
	wire		[`REG_WD-1 :0]	wv_hcount				;
	wire						w_vcount_clear		;
//	wire		[`REG_WD-1 :0]	wv_triggerenreg_m		;
	reg			[`REG_WD-1 :0]	wv_triggerenreg_m		;
//	wire		[`REG_WD-1 :0]	wv_contlineexp_start	;
	reg			[`REG_WD-1 :0]	wv_contlineexp_start	;
	wire						w_xsg_flag			;
	wire						w_xsg_clear			;

	wire						w_xsb_falling_direc			;
	wire		[`REG_WD-1 :0]	wv_xsb_falling_compensation ;
	wire						w_xsb_rising_direc          ;
	wire		[`REG_WD-1 :0]	wv_xsb_rising_compensation  ;

	//	assign		wv_triggerenreg_m		= wv_frame_period_m-wv_exposure_linereg_m + 1'b1;		//触发位置太靠前，下一帧不能触发成功,如果加2则不能保证纯小数曝光触发成功
	//	assign 		wv_contlineexp_start 	= wv_frame_period_m-wv_exposure_linereg_m + 1'b1;		//让曝光落后一点，保证场尾空跑完成才进入xsg_flag
	//	-------------------------------------------------------------------------------------
	//	增强时序性，打一拍
	//	-------------------------------------------------------------------------------------
	always @ (posedge pixclk) begin
		wv_triggerenreg_m		<= wv_frame_period_m-wv_exposure_linereg_m + 1'b1;		//触发位置太靠前，下一帧不能触发成功,如果加2则不能保证纯小数曝光触发成功
		wv_contlineexp_start 	= wv_frame_period_m-wv_exposure_linereg_m + 1'b1;		//让曝光落后一点，保证场尾空跑完成才进入xsg_flag
	end

	assign		ov_xvs					= w_xsg_flag ? `XV_DEFVALUE : ov_xv;		//帧翻转阶段保持默认值，其他阶段和XV相同
	/**********************************************************************************************
	2、模块例化,各模块定义如下：
	ccd_contr
	counter_triggerdelay
	counter_lineexp
	***********************************************************************************************/
	ccd_controler ccd_controler_inst (
	.pixclk					(pixclk					),
	.reset					(reset					),
	.ov_xv					(ov_xv					),
	.ov_xsg					(ov_xsg					),
	.o_xsub					(o_xsub					),
	.o_hd					(o_hd					),
	.o_vd					(o_vd					),
	.iv_frame_period		(wv_frame_period_m		),
	.iv_hperiod				(wv_hperiod				),
	.iv_headblank_start		(wv_headblank_start_m	),
	.iv_tailblank_start		(wv_tailblank_start_m	),
	.iv_tailblank_number	(wv_tailblank_number_m	),
	.iv_tailblank_end		(wv_tailblank_end_m		),
	.iv_vsync_start			(wv_vsync_start_m		),
	.iv_vsync_fpga_start	(wv_vsync_fpga_start_m	),
	.iv_headblank_number	(wv_headblank_number_m	),
	.i_exposure_flag		(w_exposure_preflag		),
	.i_xsub_last			(w_xsub_last_m			),
	.iv_href_start			(wv_href_start_m		),
	.iv_href_end			(wv_href_end_m			),
	.iv_vcount				(wv_vcount				),
	.i_xsg_start			(w_xsg_start			),
	.i_waitflag				(w_waitflag				),
	.i_triggersel			(w_triggersel_m			),

	.i_xsb_falling_direc		(w_xsb_falling_direc			),
	.iv_xsb_falling_compensation(wv_xsb_falling_compensation	),
	.i_xsb_rising_direc			(w_xsb_rising_direc				),
	.iv_xsb_rising_compensation	(wv_xsb_rising_compensation		),

	.o_href					(o_href					),
	.o_vsync				(o_vsync				),
	.o_xsg_flag				(w_xsg_flag				),
	.o_xsg_clear			(w_xsg_clear			),
	.o_hend					(w_hend					),
	.ov_hcount				(wv_hcount				)
	);

	counter	 counter_v_inst		(
	.clk					(pixclk					),
	.hend					(w_hend					),
	.i_clk_en				(1'b1					),
	.i_aclr					(w_vcount_clear			),
	.ov_q					(wv_vcount				)
	);


	ccd_reg	ccd_reg_inst (
	.pixclk							(pixclk 				),
	.reset							(reset					),
	.iv_vcount						(wv_vcount 				),
	.i_integration					(o_integration			),
	.i_triggersel					(i_triggersel			),
	.iv_href_start					(iv_href_start			),
	.iv_href_end					(iv_href_end			),
	.iv_exposure_reg				(iv_exposure_reg		),
	.iv_exposure_linereg			(iv_exposure_linereg	),
	.iv_frame_period				(iv_frame_period		),
//	.iv_hperiod						(iv_hperiod				),
	.iv_headblank_number			(iv_headblank_number	),
	//	.iv_headblank_start				(iv_headblank_start		),
	.iv_tailblank_start				(iv_tailblank_start		),
	.iv_tailblank_number			(iv_tailblank_number	),
	.iv_tailblank_end				(iv_tailblank_end		),
	.iv_vsync_start					(iv_vsync_start			),
	//	.iv_vsync_fpga_start			(iv_vsync_fpga_start	),
	//	.i_xsb_falling_direc			(i_xsb_falling_direc			),
	//	.iv_xsb_falling_compensation	(iv_xsb_falling_compensation	),
	//	.i_xsb_rising_direc				(i_xsb_rising_direc				),
	//	.iv_xsb_rising_compensation		(iv_xsb_rising_compensation		),
	.o_triggersel_act				(w_triggersel_m			),
	.ov_frame_period_m				(wv_frame_period_m		),
	.ov_hperiod						(wv_hperiod				),
	.ov_headblank_number_m			(wv_headblank_number_m 	),
	.ov_headblank_start_m			(wv_headblank_start_m	),
	.ov_tailblank_start_m			(wv_tailblank_start_m	),
	.ov_tailblank_number_m			(wv_tailblank_number_m	),
	.ov_tailblank_end_m				(wv_tailblank_end_m		),
	.ov_vsync_start_m				(wv_vsync_start_m	),
	.ov_vsync_fpga_start_m			(wv_vsync_fpga_start_m	),
	.ov_href_start_m				(wv_href_start_m		),
	.ov_href_end_m					(wv_href_end_m			),
	.ov_exposure_reg_m				(wv_exposure_reg_m		),
	.ov_exposure_linereg_m			(wv_exposure_linereg_m 	),
	.o_xsb_falling_direc_m			(w_xsb_falling_direc			),
	.ov_xsb_falling_compensation_m	(wv_xsb_falling_compensation	),
	.o_xsb_rising_direc_m			(w_xsb_rising_direc				),
	.ov_xsb_rising_compensation_m	(wv_xsb_rising_compensation		)
	);

	ccd_trig ccd_trig_inst		(
	.pixclk					(pixclk					),
	.reset					(reset					),
	.i_triggerin			(i_triggerin			),
	.iv_triggerenreg_m		(wv_triggerenreg_m		),
	.iv_contlineexp_start  	(wv_contlineexp_start  	),
	.i_hend					(w_hend					),
	.i_triggersel_m			(w_triggersel_m			),
	.iv_frame_period_m		(wv_frame_period_m		),
	.iv_vcount				(wv_vcount				),
	.iv_hcount				(wv_hcount				),
	.o_exposure_start		(w_exposure_start		),
	.o_triggerready       	(o_triggerready       	)
	);

	ccd_exp ccd_exp_inst		(
	.pixclk					(pixclk					),
	.reset					(reset					),
	.i_triggersel_m			(w_triggersel_m			),
	.i_exposure_start		(w_exposure_start		),
	.i_waitflag				(w_waitflag				),
	.iv_exposure_reg_m		(wv_exposure_reg_m		),
	.iv_vcount				(wv_vcount				),
	.o_xsg_start			(w_xsg_start			),
	.o_xsub_last_m			(w_xsub_last_m			),
	.o_strobe				(o_strobe				),
	.o_exposure_preflag		(w_exposure_preflag		),
	.o_exp_over		 		(w_exp_over		    	),
	.o_integration        	(o_integration        	)
	);

	ccd_vclear ccd_vclear_inst	(
	.pixclk					(pixclk					),
	.reset					(reset					),
	.iv_frame_period_m		(wv_frame_period_m		),
	.iv_vcount				(wv_vcount				),
	.i_xsg_clear			(w_xsg_clear			),
	.i_xsg_start    		(w_xsg_start			),
	.i_triggersel_m			(w_triggersel_m			),
	.i_hend					(w_hend					),
	.o_vcount_clear			(w_vcount_clear			),
	.o_waitflag		    	(w_waitflag				)
	);

endmodule