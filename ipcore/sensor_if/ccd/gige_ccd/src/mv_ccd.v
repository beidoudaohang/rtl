
//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : mv_ccd.v
//  -- 设计者       : 禹剑
//-------------------------------------------------------------------------------------------------
//
//  --修改记录  :
//
//  -- 作者         :| 修改日期     :|  修改说明
//---------------------------------------------------------------------------------------
//  -- 禹剑       	:| 09/17/2013   :|  初始版本
//  -- 陈小平      	:| 04/29/2015   :|  进行修改，适应于ICX445 sensor
//  -- 邢海涛      	:| 2015/12/7    :|  移植到u3平台
//---------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  :
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale      1ns/100ps
//-------------------------------------------------------------------------------------------------

`include "SHARP_RJ33J3_DEF.v"

module mv_ccd (
	input                                   		clk      				,   //时钟
	input											reset					,	//时钟复位，高有效
	input											i_acquisition_start		,	//clk_pix时钟域，开采信号，0-停采，1-开采
	input											i_stream_enable			,	//clk_pix时钟域，流使能信号，0-停采，1-开采
	input											i_trigger				,   //给CCD模块的触发信号
	input											i_triggermode			,   //给CCD模块的采集模式信号
	input		[`LINE_WD-1:0]						iv_href_start			,   //行有效开始寄存器
	input		[`LINE_WD-1:0]						iv_href_end				,   //行有效结束寄存器
	input		[`LINE_WD-1:0]						iv_hd_rising			,   //hd有效开始寄存器
	input		[`LINE_WD-1:0]						iv_hd_falling			,   //hd有效结束寄存器
	input		[`LINE_WD-1:0]						iv_sub_rising			,   //sub有效开始寄存器
	input		[`LINE_WD-1:0]						iv_sub_falling			,   //sub有效结束寄存器
	input		[`FRAME_WD-1:0]						iv_vd_rising			,   //vd有效开始寄存器
	input		[`FRAME_WD-1:0]						iv_vd_falling			,   //vd有效结束寄存器
	input		[`EXP_WD-1:0]						iv_xsg_width			,	//XSG宽度
	input		[`FRAME_WD-1:0]						iv_frame_period			,   //帧周期寄存器
	input		[`FRAME_WD-1:0]						iv_headblank_end		,   //
	input		[`FRAME_WD-1:0]						iv_vref_start			,   //ROI开始行数
	input		[`FRAME_WD-1:0]						iv_tailblank_start		,   //ROI结束行数
	input		[`FRAME_WD-1:0]						iv_tailblank_end		,   //
	input		[`FRAME_WD-1:0]						iv_exp_line				,	//曝光阶段整行部分行数寄存器
	input		[`EXP_WD-1:0]						iv_exp_reg				,   //曝光阶段时钟个数寄存器

	//内部信号
	input											i_ad_parm_valid			,	//
	output											o_strobe				,   //闪光灯信号
	output											o_integration			,   //积分信号
	output											o_href					,   //行有效信号
	output											o_vref					,   //场有效信号
	output	reg										o_ccd_stop_flag			,	//
	output	reg										o_exposure_end			,	//
	output	reg										o_trigger_mask			,	//屏蔽触发标志
	output											o_trigger_mask_flag		,	//屏蔽

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

	wire                                   			w_reg_active    	;   //

	wire		[`FRAME_WD-1:0]						wv_frame_period		;   //生效时机后的帧周期寄存器
	wire		[`FRAME_WD-1:0]						wv_headblank_end	;   //
	wire		[`FRAME_WD-1:0]						wv_vref_start		;   //生效时机后的ROI开始行数
	wire		[`FRAME_WD-1:0]						wv_tailblank_start	;   //生效时机后的ROI结束行数
	wire		[`FRAME_WD-1:0]						wv_tailblank_end	;   //生效时机后的场尾结束行数
	wire		[22:0]								wv_tailblank_num	;	//
	wire		[22:0]								wv_headblank_num	;	//

	wire		[`FRAME_WD-1:0]						wv_exp_start_reg	;	//
	wire		[`EXP_WD-1:0]						wv_exp_reg			;   //曝光阶段时钟个数寄存器
	wire		[`EXP_WD-1:0]						wv_exp_line_reg		;	//曝光整行时钟个数寄存器
	wire		[`EXP_WD-1:0]						wv_exp_xsg_reg		;	//
	reg			[1:0]								start_acquisit_shift	;	//
	reg			[`FRAME_PIX_CNT_WD-1:0] 			ccd_stop_cnt			;	//
	reg												stop_a_frame_flag		;	//
	reg			[1:0]								stop_a_frame_flag_shift	;	//
	wire											w_exposure_end			;	//
	reg												exposure_end_dly1		;
	reg												exposure_end_dly2		;
	reg												exposure_end_dly3		;


	//  ===============================================================================================
	//  第二部分：实例化模块
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  ccd_controller 模块 : 生成CCD、AD标志信号
	//  -------------------------------------------------------------------------------------
	ccd_controller ccd_controller_inst (
	.clk					(clk									),
	.reset					(reset									),
	.i_acquisition_start	(i_acquisition_start					),
	.i_stream_enable		(i_stream_enable						),
	.i_triggermode			(i_triggermode							),
	.i_trigger				(i_trigger								),
	.iv_href_start			(iv_href_start							),
	.iv_href_end			(iv_href_end							),
	.iv_hd_rising			(iv_hd_rising							),
	.iv_hd_falling			(iv_hd_falling							),
	.iv_vd_rising			(iv_vd_rising							),
	.iv_vd_falling			(iv_vd_falling							),
	.iv_sub_rising			(iv_sub_rising							),
	.iv_sub_falling			(iv_sub_falling							),
	.iv_xsg_width			(iv_xsg_width							),
	.iv_frame_period		(wv_frame_period						),
	.iv_headblank_end		(wv_headblank_end						),
	.iv_headblank_num		(wv_headblank_num						),
	.iv_vref_start	   		(wv_vref_start							),
	.iv_tailblank_start		(wv_tailblank_start						),
	.iv_tailblank_end		(wv_tailblank_end						),
	.iv_tailblank_num		(wv_tailblank_num						),
	.iv_exp_start_reg		(wv_exp_start_reg						),
	.iv_exp_line_reg		(wv_exp_line_reg						),
	.iv_exp_reg				(wv_exp_reg								),
	.iv_exp_xsg_reg			(wv_exp_xsg_reg							),

	.i_ad_parm_valid		(i_ad_parm_valid						),
	.i_ccd_stop_flag		(o_ccd_stop_flag						),
	.o_trigger_mask			(o_trigger_mask_flag					),
	.o_integration			(o_integration							),
	.o_exposure_end			(w_exposure_end							),
	.o_reg_active			(w_reg_active							),

	.o_vd					(o_vd									),
	.o_hd					(o_hd									),
	.o_vref					(o_vref									),
	.o_href					(o_href									),
	.o_sub                 	(o_sub									),
	.ov_xsg                 (ov_xsg									),
	.ov_xv                 	(ov_xv									)
	);

	//  -------------------------------------------------------------------------------------
	//  ccd_reg 模块 : ccd寄存器生效控制模块
	//  -------------------------------------------------------------------------------------
	ccd_reg	ccd_reg_inst (
	.clk					(clk									),
	.reset					(reset									),
	.i_reg_active   		(w_reg_active							),
	.iv_frame_period		(iv_frame_period						),
	.iv_headblank_end		(iv_headblank_end						),
	.iv_vref_start	   		(iv_vref_start							),
	.iv_tailblank_start		(iv_tailblank_start						),
	.iv_tailblank_end		(iv_tailblank_end						),
	.iv_exp_line			(iv_exp_line							),
	.iv_exp_reg				(iv_exp_reg								),
	.ov_frame_period		(wv_frame_period						),
	.ov_headblank_end		(wv_headblank_end						),
	.ov_headblank_num		(wv_headblank_num						),
	.ov_vref_start	   		(wv_vref_start							),
	.ov_tailblank_start		(wv_tailblank_start						),
	.ov_tailblank_num		(wv_tailblank_num						),
	.ov_tailblank_end		(wv_tailblank_end						),
	.ov_exp_start_reg		(wv_exp_start_reg						),
	.ov_exp_line_reg		(wv_exp_line_reg						),
	.ov_exp_reg				(wv_exp_reg								),
	.ov_exp_xsg_reg			(wv_exp_xsg_reg							)
	);

	//  ===============================================================================================
	//  第三部分：停采后等一个帧周期逻辑，ICX618 8.32MS,
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	i_start_acquisit 取沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		start_acquisit_shift	<= {start_acquisit_shift[0],i_start_acquisit};
	end

	//  -------------------------------------------------------------------------------------
	//	stop_a_frame_flag 取沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		stop_a_frame_flag_shift	<={stop_a_frame_flag_shift[0],stop_a_frame_flag};
	end

	//  -------------------------------------------------------------------------------------
	//	停采后等8.32ms: stop_a_frame_flag
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			stop_a_frame_flag	<=	1'b0;
		end
		else if(ccd_stop_cnt == `FRAME_PIXEL_CNT) begin
			stop_a_frame_flag	<=	1'b0;
		end
		else if(start_acquisit_shift == 2'b10) begin
			stop_a_frame_flag	<=  1'b1;
		end
	end

	always @ (posedge clk) begin
		if(reset) begin
			ccd_stop_cnt	<=	`FRAME_PIX_CNT_WD'd0;
		end
		else if(stop_a_frame_flag) begin
			ccd_stop_cnt	<=	ccd_stop_cnt + 1'b1;
		end
		else begin
			ccd_stop_cnt 	<=  `FRAME_PIX_CNT_WD'd0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	停采后等70ms: o_ccd_stop_flag
	//  -------------------------------------------------------------------------------------
	always @ ( posedge clk ) begin
		if(reset) begin
			o_ccd_stop_flag	<=	1'b1;
		end
		else if(start_acquisit_shift == 2'b01) begin
			o_ccd_stop_flag	<=	1'b0;
		end
		else if(stop_a_frame_flag_shift == 2'b10) begin
			o_ccd_stop_flag	<=  1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	产生触发屏蔽有效信号。在屏蔽期间，接收到第一个触发信号后，触发屏蔽信号有效
	//	在屏蔽期间内，如果有多个触发信号被屏蔽，则只产生一个屏蔽事件（第一个产生）。
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset)
		o_trigger_mask	<=	1'b0;
		else if(o_trigger_mask_flag)
		begin
			if(!o_trigger_mask && i_trigger)
			o_trigger_mask	<=	1'b1;
		end
		else
		o_trigger_mask	<=  1'b0;
	end

	//  ===============================================================================================
	//  第四部分：曝光结束信号加宽
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	曝光结束信号加宽
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		exposure_end_dly1	<=	w_exposure_end;
		exposure_end_dly2	<=	exposure_end_dly1;
		exposure_end_dly3	<=	exposure_end_dly2;
	end

	always @ (posedge clk) begin
		o_exposure_end	<=	 exposure_end_dly3 || exposure_end_dly2 || exposure_end_dly1 || w_exposure_end;
	end

endmodule