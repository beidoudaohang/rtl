//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : harness
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/9 17:18:50	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`include "SHARP_RJ33B4_DEF.v"
`include "deserializer_def.v"
`include "DATA_CHANNEL_DEF.v"

`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
`define		TESTCASE	testcase1

module harness ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================


	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	输入
	//	-------------------------------------------------------------------------------------
	wire							clk					;
	wire							reset				;
	wire							i_start_acquisit	;
	wire							i_trigger			;
	wire							i_triggermode		;
	wire	[`LINE_WD - 1:0]		iv_href_start		;
	wire	[`LINE_WD - 1:0]		iv_href_end			;
	wire	[`LINE_WD - 1:0]		iv_hd_rising		;
	wire	[`LINE_WD - 1:0]		iv_hd_falling		;
	wire	[`LINE_WD - 1:0]		iv_sub_rising		;
	wire	[`LINE_WD - 1:0]		iv_sub_falling		;
	wire	[`FRAME_WD - 1:0]		iv_vd_rising		;
	wire	[`FRAME_WD - 1:0]		iv_vd_falling		;
	wire	[`EXP_WD - 1:0]			iv_xsg_width		;
	wire							i_ad_parm_valid		;

	wire							clk_p				;
	wire							clk_n				;
	wire	[`sys_w - 1:0]			iv_data_p			;
	wire	[`sys_w - 1:0]			iv_data_n			;


	//	-------------------------------------------------------------------------------------
	//	输出
	//	-------------------------------------------------------------------------------------
	wire							o_strobe	;
	wire							o_integration	;
	wire							o_href	;
	wire							o_vref	;
	wire							o_ccd_stop_flag	;
	wire							o_exposure_end	;
	wire							o_trigger_mask	;
	wire							o_trigger_mask_flag	;
	wire							o_hd	;
	wire							o_vd	;
	wire							o_sub	;
	wire	[`XSG_WD - 1:0]			ov_xsg	;
	wire	[`XV_WD - 1:0]			ov_xv	;

	wire							o_bitslip			;

	wire							w_vref_des			;
	wire							w_href_des			;
	wire	[`dev_w-1:0]			wv_data_des			;

	wire							w_dval_sel			;
	wire							w_fval_sel			;
	wire	[`PIX_WD-1:0]			wv_data_sel 		;	//12位数据

	wire							w_dval_image_cut  	;
	wire							w_fval_image_cut  	;
	wire	[`PIX_WD-1:0]			wv_data_image_cut 	;	//12位数据

	wire	[`XV_WD - 1:0]			ov_xv_inv	;
	wire							o_sub_inv	;
	wire							o_xsg_inv	;

	//	wire	[4:1]				ov_xv_cxd3400				;
	//	wire						o_ofd_cxd3400				;
	//	wire						o_xsg_cxd3400				;


	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	引入输入信号
	//	-------------------------------------------------------------------------------------
	assign	clk						= `TESTCASE.clk               ;
	assign	reset                   = `TESTCASE.reset             ;
	assign	i_start_acquisit        = `TESTCASE.i_start_acquisit  ;
	assign	i_trigger               = `TESTCASE.i_trigger         ;
	assign	i_triggermode           = `TESTCASE.i_triggermode     ;
	assign	iv_href_start           = `TESTCASE.iv_href_start     ;
	assign	iv_href_end             = `TESTCASE.iv_href_end       ;
	assign	iv_hd_rising            = `TESTCASE.iv_hd_rising      ;
	assign	iv_hd_falling           = `TESTCASE.iv_hd_falling     ;
	assign	iv_sub_rising           = `TESTCASE.iv_sub_rising     ;
	assign	iv_sub_falling          = `TESTCASE.iv_sub_falling    ;
	assign	iv_vd_rising            = `TESTCASE.iv_vd_rising      ;
	assign	iv_vd_falling           = `TESTCASE.iv_vd_falling     ;
	assign	iv_xsg_width            = `TESTCASE.iv_xsg_width      ;
	assign	i_ad_parm_valid         = `TESTCASE.i_ad_parm_valid   ;

	assign	clk_p					= `TESTCASE.clk_p			;
	assign	clk_n                   = `TESTCASE.clk_n           ;
	assign	iv_data_p               = `TESTCASE.iv_data_p       ;
	assign	iv_data_n               = `TESTCASE.iv_data_n       ;

	//	-------------------------------------------------------------------------------------
	//	例化 bfm 模块
	//	-------------------------------------------------------------------------------------
	bfm_ccd bfm_ccd ();

	//	-------------------------------------------------------------------------------------
	//	例化 ccd 模块
	//	-------------------------------------------------------------------------------------
	mv_ccd mv_ccd_inst (
	.clk					(clk					),
	.reset					(reset					),
	.i_start_acquisit		(i_start_acquisit		),
	.i_trigger				(i_trigger				),
	.i_triggermode			(i_triggermode			),
	.iv_href_start			(`HREF_START_DEFVALUE	),
	.iv_href_end			(`HREF_END_DEFVALUE		),
	.iv_hd_rising			(iv_hd_rising			),
	.iv_hd_falling			(iv_hd_falling			),
	.iv_sub_rising			(iv_sub_rising			),
	.iv_sub_falling			(iv_sub_falling			),
	.iv_vd_rising			(iv_vd_rising			),
	.iv_vd_falling			(iv_vd_falling			),
	.iv_xsg_width			(iv_xsg_width			),
		.iv_frame_period		(bfm_ccd.iv_frame_period		),
		.iv_headblank_end		(bfm_ccd.iv_headblank_end		),
		.iv_vref_start			(bfm_ccd.iv_vref_start			),
		.iv_tailblank_start		(bfm_ccd.iv_tailblank_start		),
		.iv_tailblank_end		(bfm_ccd.iv_tailblank_end		),
		.iv_exp_line			(bfm_ccd.iv_exp_line			),
		.iv_exp_reg				(bfm_ccd.iv_exp_reg				),

//	.iv_frame_period				(`FRAME_PERIOD_DEFVALUE					),	//
//	.iv_headblank_end				(`HEADBLANK_END_DEFVALUE				),	//
//	.iv_vref_start					(`VSYNC_START_DEFVALUE					),	//
//	.iv_tailblank_start				(`TAILBLANK_START_DEFVALUE				),	//
//	.iv_tailblank_end				(`TAILBLANK_END_DEFVALUE				),	//
//	.iv_exp_line					(`EXPOSURE_LINE_DEFVALUE				),	//
//	.iv_exp_reg						(`EXPOSURE_REG_DEFVALUE					),	//

	.i_ad_parm_valid		(i_ad_parm_valid		),
	.o_strobe				(o_strobe				),
	.o_integration			(o_integration			),
	.o_href					(o_href					),
	.o_vref					(o_vref					),
	.o_ccd_stop_flag		(o_ccd_stop_flag		),
	.o_exposure_end			(o_exposure_end			),
	.o_trigger_mask			(o_trigger_mask			),
	.o_trigger_mask_flag	(o_trigger_mask_flag	),
	.o_hd					(o_hd					),
	.o_vd					(o_vd					),
	.o_sub					(o_sub					),
	.ov_xsg					(ov_xsg					),
	.ov_xv					(ov_xv					),
	.ov_test_ccd			()
	);


	deserializer_top	deserializer_top_inst
	(
	.clk					(clk									),	//时钟
	.reset					(reset									),	//复位，高有效
	.i_bitslip_en			(o_hd									),	//使能bitslip功能
	.o_bitslip				(o_bitslip								),	//输出bitslip
	.clk_p					(clk_p									),	//差分时钟输入
	.clk_n					(clk_n									),	//差分时钟输入
	.iv_data_p				(iv_data_p								),	//差分数据输入
	.iv_data_n				(iv_data_n								),	//差分数据输入
	.iv_href_start			(bfm_ccd.iv_href_start					),	//行有效开始寄存器
	.iv_href_end			(bfm_ccd.iv_href_end					),	//行有效结束寄存器
	.i_vref					(o_vref									),	//
	.o_href					(w_href_des								),	//
	.o_vref					(w_vref_des								),	//
	.ov_data				(wv_data_des							)	//并行数据输出 16位数据
	//				.o_sensor_link_status	(o_sensor_link_status					)
	);

	signal_sel	signal_sel_inst
	(
	.clk					(clk									),	//时钟
	.reset					(reset									),	//复位，高有效
	.i_dval_ad            	(w_href_des          					),	//
	.i_fval_ad				(w_vref_des          					),	//
	.iv_data              	(wv_data_des[15:4]						),  //
	.i_dval_ccd				(o_href									),	//
	.i_fval_ccd				(o_vref          						),	//
	.iv_testimage_sel      	(2'b00			          				),	//
	.o_dval					(w_dval_sel								),
	.o_fval                 (w_fval_sel								),
	.ov_data                (wv_data_sel        					)
	);

	image_cut	image_cut_inst
	(
	.clk					(clk									),	//时钟
	.reset					(reset									),	//复位，高有效
	.i_dval           		(w_dval_sel          					),
	.i_fval					(w_fval_sel          					),
	.iv_data              	(wv_data_sel         					),
	.iv_roi_offet_x			(bfm_ccd.iv_roi_offset_x				),
	.iv_roi_offet_x_end		(bfm_ccd.iv_roi_offset_x_end			),
	.o_dval					(w_dval_image_cut						),
	.o_fval                 (w_fval_image_cut						),
	.ov_data                (wv_data_image_cut        				)
	);


	//	cxd3400_model cxd3400_model_inst (
	//	.iv_xv					(ov_xv			),
	//	.i_ofd					(o_xsub			),
	//	.i_xsg					(ov_xsg			),
	//	.ov_xv					(ov_xv_cxd3400	),
	//	.o_ofd					(o_ofd_cxd3400	),
	//	.o_xsg					(o_xsg_cxd3400	)
	//	);
	//
	assign	ov_xv_inv		= ~ov_xv	;
	assign	o_sub_inv		= ~o_sub	;
	assign	o_xsg_inv		= ~ov_xsg[0]	;
	//	assign	ov_xvs_n	= ~ov_xvs	;
	//	assign	ov_xsg_n	= ~ov_xsg	;

	//generate vcd file
	//initial begin
	//$dumpfile("test.vcd");
	//$dumpvars(1,top_frame_buffer_inst);
	//end

	//for lattice simulation
	//GSR   GSR_INST (.GSR (1'b1)); //< global reset sig>
	//PUR   PUR_INST (.PUR (1'b1)); //<powerup reset sig>



endmodule
