
//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : ccd_controller.v
//  -- 设计者       : 禹剑
//-------------------------------------------------------------------------------------------------
//
//  --修改记录  :
//
//  -- 作者         :| 修改日期     :|  修改说明
//---------------------------------------------------------------------------------------
//  -- 禹剑       	:| 09/17/2013   :|  初始版本
//  -- 陈小平      	:| 04/29/2015   :|  进行修改，适应于ICX445 sensor
//
//---------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : 生成CCD、AD标志信号
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale      1ns/100ps
//-------------------------------------------------------------------------------------------------

`include "SHARP_RJ33J3_DEF.v"

module  ccd_controller # (
	parameter	XV_WIDTH						= 4			;
	parameter	HB_XV_DEFAULT_VALUE				= 4'b1100	;
	parameter	HB_XV_VALUE1					= 4'b1100	;
	parameter	HB_XV_VALUE2					= 4'b1000	;
	parameter	HB_XV_VALUE3					= 4'b1001	;
	parameter	HB_XV_VALUE4					= 4'b0001	;
	parameter	HB_XV_VALUE5					= 4'b0011	;
	parameter	HB_XV_VALUE6					= 4'b0010	;
	parameter	HB_XV_VALUE7					= 4'b0110	;
	parameter	HB_XV_VALUE8					= 4'b0100	;
	parameter	HB_LINE_START_POS				= 40		;	//每一行开始翻转的时间点
	parameter	LINE_PERIOD						= 1532		;	//行周期
	parameter	ONE_LINE_BLANK_NUM				= 4			;	//每一行快翻的行数
	parameter	ONE_BLANK_STATE_NUM				= 8			;	//每一次快翻的状态个数

	)
	(
	input                                   		clk      			,   //时钟
	input											reset				,	//时钟复位，高有效
	input											i_acquisition_start		,	//clk_pix时钟域，开采信号，0-停采，1-开采
	input											i_stream_enable			,	//clk_pix时钟域，流使能信号，0-停采，1-开采
	input											i_triggermode		,   //给CCD模块的采集模式信号
	input											i_trigger			,   //给CCD模块的触发信号

	input		[`LINE_WD-1:0]						iv_href_start		,   //行有效开始寄存器
	input		[`LINE_WD-1:0]						iv_href_end			,   //行有效结束寄存器
	input		[`LINE_WD-1:0]						iv_hd_rising		,   //hd有效开始寄存器
	input		[`LINE_WD-1:0]						iv_hd_falling		,   //hd有效结束寄存器
	input		[`LINE_WD-1:0]						iv_sub_rising		,   //sub有效开始寄存器
	input		[`LINE_WD-1:0]						iv_sub_falling		,   //sub有效结束寄存器
	input		[`FRAME_WD-1:0]						iv_vd_rising		,   //vd有效开始寄存器
	input		[`FRAME_WD-1:0]						iv_vd_falling		,   //vd有效结束寄存器
	input		[`EXP_WD-1:0]						iv_xsg_width		,	//XSG宽度
	input		[`FRAME_WD-1:0]						iv_frame_period		,   //帧周期寄存器
	input		[`FRAME_WD-1:0]						iv_headblank_end	,   //
	input		[22:0]								iv_headblank_num	,	//
	input		[`FRAME_WD-1:0]						iv_vref_start		,   //ROI开始行数
	input		[`FRAME_WD-1:0]						iv_tailblank_start	,   //ROI结束行数
	input		[22:0]								iv_tailblank_num	,	//
	input		[`FRAME_WD-1:0]						iv_tailblank_end	,   //
	input		[`EXP_WD-1:0]						iv_exp_reg			,   //曝光阶段时钟个数寄存器
	input		[`EXP_WD-1:0]						iv_exp_line_reg		,	//曝光整行时钟个数寄存器
	input		[`FRAME_WD-1:0]						iv_exp_start_reg	,	//
	input		[`EXP_WD-1:0]						iv_exp_xsg_reg		,	//
	//内部信号
	input											i_ad_parm_valid		,	//
	input											i_ccd_stop_flag		,	//
	output											o_trigger_mask		,	//屏蔽标志
	output    										o_integration       ,	//积分信号
	output											o_reg_active		,	//
	output											o_exposure_end		,	//
	output											o_href				,   //场有效信号
	output											o_vref				,   //场有效信号
	//AD 接口信号
	output											o_hd				,   //AD驱动信号HD
	output											o_vd				,   //AD驱动信号VD
	//CCD 接口信号
	output											o_sub				,   //SUB信号
	output		[`XSG_WD-1:0]						ov_xsg				,   //帧翻转信号
	output		[`XV_WD-1:0]						ov_xv					//垂直翻转信号
	);

	//  ===============================================================================================
	//  第一部分：模块设计中要用到的信号
	//  ===============================================================================================
	wire											w_headblank_flag	;
	wire											w_tailblank_flag	;
	wire											w_xsg_flag			;
	wire											w_exp_line_end		;	//行曝光结束标志，用于启动帧翻转
	wire											w_readout_flag		;
	wire  		[`FRAME_WD-1:0]						wv_vcount			;
	wire											w_hend				;
	wire		[12:0]								wv_hcount			;
	wire		[`XV_WD-1:0]						wv_xv_xsg			;
	wire		[`XV_WD-1:0]						wv_xv_tailblank		;
	wire		[`XV_WD-1:0]						wv_xv_headblank		;


	//  ===============================================================================================
	//  第二部分：实例化模块
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  ccd_readout 模块 : 生成ccd读出周期标志
	//  -------------------------------------------------------------------------------------
	ccd_readout ccd_readout_inst (
	.clk					(clk									),
	.reset					(reset									),
	.iv_frame_period		(iv_frame_period						),
	.i_exp_line_end			(w_exp_line_end							),
	.i_ccd_stop_flag		(i_ccd_stop_flag						),
	.i_hend					(w_hend									),
	.o_readout_flag			(w_readout_flag							),
	.o_xsg_flag				(w_xsg_flag								),
	.ov_vcount				(wv_vcount								)
	);

	//  -------------------------------------------------------------------------------------
	//  ccd_blank 模块 : 生成场头快速翻转
	//  -------------------------------------------------------------------------------------
	ccd_blank # (
	.XV_WIDTH				(XV_WIDTH				),
	.XV_DEFAULT_VALUE		(HB_XV_DEFAULT_VALUE	),
	.XV_VALUE1				(HB_XV_VALUE1			),
	.XV_VALUE2				(HB_XV_VALUE2			),
	.XV_VALUE3				(HB_XV_VALUE3			),
	.XV_VALUE4				(HB_XV_VALUE4			),
	.XV_VALUE5				(HB_XV_VALUE5			),
	.XV_VALUE6				(HB_XV_VALUE6			),
	.XV_VALUE7				(HB_XV_VALUE7			),
	.XV_VALUE8				(HB_XV_VALUE8			),
	.LINE_START_POS			(HB_LINE_START_POS		),
	.LINE_PERIOD			(LINE_PERIOD			),
	.ONE_LINE_BLANK_NUM		(ONE_LINE_BLANK_NUM		),
	.ONE_BLANK_STATE_NUM	(ONE_BLANK_STATE_NUM	),
	)
	ccd_blank_hb_inst (
	.clk					(clk					),
	.reset					(reset					),
	.iv_hcount				(wv_hcount				),
	.i_blank_flag			(w_headblank_flag		),
	.iv_blank_num			(iv_headblank_num		),
	.ov_xv					(wv_xv_headblank		)
	);

	//  -------------------------------------------------------------------------------------
	//  ccd_blank 模块 : 生成场尾快速翻转
	//  -------------------------------------------------------------------------------------
	ccd_blank # (
	.XV_WIDTH				(XV_WIDTH				),
	.XV_DEFAULT_VALUE		(TB_XV_DEFAULT_VALUE	),
	.XV_VALUE1				(TB_XV_VALUE1			),
	.XV_VALUE2				(TB_XV_VALUE2			),
	.XV_VALUE3				(TB_XV_VALUE3			),
	.XV_VALUE4				(TB_XV_VALUE4			),
	.XV_VALUE5				(TB_XV_VALUE5			),
	.XV_VALUE6				(TB_XV_VALUE6			),
	.XV_VALUE7				(TB_XV_VALUE7			),
	.XV_VALUE8				(TB_XV_VALUE8			),
	.LINE_START_POS			(TB_LINE_START_POS		),
	.LINE_PERIOD			(LINE_PERIOD			),
	.ONE_LINE_BLANK_NUM		(ONE_LINE_BLANK_NUM		),
	.ONE_BLANK_STATE_NUM	(ONE_BLANK_STATE_NUM	),
	)
	ccd_blank_tb_inst (
	.clk					(clk					),
	.reset					(reset					),
	.iv_hcount				(wv_hcount				),
	.i_blank_flag			(w_tailblank_flag		),
	.iv_blank_num			(iv_tailblank_num		),
	.ov_xv					(wv_xv_tailblank		)
	);

	//  -------------------------------------------------------------------------------------
	//  ccd_exp 模块 : ccd曝光控制模块
	//  -------------------------------------------------------------------------------------
	ccd_exp	ccd_exp_inst (
	.clk					(clk									),	//时钟
	.reset					(reset									),	//复位，高有效
	.iv_exp_reg	    		(iv_exp_reg								),	//曝光时钟个数寄存器
	.iv_exp_line_reg		(iv_exp_line_reg						),	//曝光整行时钟个数寄存器
	.iv_exp_start_reg		(iv_exp_start_reg						),	//曝光开始行位置寄存器
	.iv_vcount				(wv_vcount								), 	//帧周期计数器
	.i_readout_flag			(w_readout_flag							), 	//ccd读出标志，此标志有效下，不能打断hcount
	.i_start_acquisit		(i_start_acquisit						), 	//给CCD模块的开采信号
	.i_triggermode			(i_triggermode							), 	//给CCD模块的采集模式信号
	.i_trigger				(i_trigger								),  //给CCD模块的触发信号
	.i_xsg_flag				(w_xsg_flag								),  //帧翻转阶段标志
	.i_exposure_end	   	 	(o_exposure_end							),	//曝光结束标志
	.o_reg_active			(o_reg_active							),	//寄存器生效标志
	.ov_hcount				(wv_hcount								), 	//行周期计数器
	.o_hend					(w_hend									), 	//行周期标记
	.o_exp_line_end			(w_exp_line_end							),	//行曝光结束标志，用于启动帧翻转阶段
	.o_trigger_mask			(o_trigger_mask							),  //屏蔽标志
	.o_integration			(o_integration							)	//积分信号
	);

	//  -------------------------------------------------------------------------------------
	//  ccd_xsg 模块 : ccd xsg阶段控制模块
	//  -------------------------------------------------------------------------------------
	ccd_xsg	ccd_xsg_inst (
	.clk					(clk									),	//时钟
	.reset					(reset									),	//复位，高有效
	.iv_exp_xsg_reg			(iv_exp_xsg_reg							),	//
	.iv_xsg_width			(iv_xsg_width							),	//
	.i_xsg_flag				(w_xsg_flag								),	//帧翻转阶段标志
	.o_exposure_end	   	 	(o_exposure_end							),	//曝光结束标志
	.ov_xv_xsg				(wv_xv_xsg								),	//XSG信号
	.ov_xsg					(ov_xsg									)   //帧翻转阶段XV
	);

	//  -------------------------------------------------------------------------------------
	//  ccd_flag 模块 : 产生ccd、ad标志
	//  -------------------------------------------------------------------------------------
	ccd_flag ccd_flag_inst (
	.clk					(clk									),	//时钟
	.reset					(reset									),	//复位，高有效
	.iv_href_start			(iv_href_start							),	//行有效开始寄存器
	.iv_href_end	   	 	(iv_href_end							),	//行有效结束寄存器
	.iv_hd_rising	   	 	(iv_hd_rising							),	//hd有效结束寄存器
	.iv_hd_falling	   	 	(iv_hd_falling							),	//hd有效结束寄存器
	.iv_vd_rising	   	 	(iv_vd_rising							),	//行有效结束寄存器
	.iv_vd_falling	   	 	(iv_vd_falling							),	//行有效结束寄存器
	.iv_sub_rising			(iv_sub_rising							), 	//sub有效开始寄存器
	.iv_sub_falling			(iv_sub_falling							), 	//sub有效结束寄存器
	.iv_headblank_end		(iv_headblank_end						),	//
	.iv_vref_start			(iv_vref_start							),	//行有效开始寄存器
	.iv_tailblank_start		(iv_tailblank_start						),	//ROI结束行数
	.iv_tailblank_end		(iv_tailblank_end						),	//ROI结束行数
	.iv_xv_tailblank		(wv_xv_tailblank						),	//
	.iv_xv_headblank		(wv_xv_headblank						),	//
	.iv_xv_xsg				(wv_xv_xsg								),	//
	.iv_vcount				(wv_vcount								), 	//帧周期计数器
	.iv_hcount				(wv_hcount								), 	//行周期计数器
	.i_readout_flag			(w_readout_flag							),	//ccd读出标志，此标志有效下，不能打断hcount
	.i_xsg_flag				(w_xsg_flag								),	//
	.i_ad_parm_valid		(i_ad_parm_valid						),	//
	.i_integration			(o_integration							),	//
	.o_headblank_flag		(w_headblank_flag						),	//
	.o_tailblank_flag		(w_tailblank_flag						),	//
	.o_href					(o_href									),	//帧翻转阶段标志
	.o_vref					(o_vref									),	//帧翻转结束，启动ccd readout状态机
	.o_vd					(o_vd									),	//
	.o_hd					(o_hd									),  //
	.o_sub					(o_sub									),  //SUB信号
	.ov_xv					(ov_xv									)
	);

endmodule