//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : driver_clock_reset
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 	:|  初始版本
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
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
module driver_clock_reset ();
	//  -------------------------------------------------------------------------------------
	//	调用 bfm 模型
	//  -------------------------------------------------------------------------------------
	bfm_clock_reset	bfm_clock_reset();

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	输出
	//	-------------------------------------------------------------------------------------
	wire				clk_osc_bufg		;
	wire				reset_osc_bufg		;
	wire				async_rst			;
	wire				sysclk_2x			;
	wire				sysclk_2x_180		;
	wire				pll_ce_0			;
	wire				pll_ce_90			;
	wire				mcb_drp_clk			;
	wire				bufpll_mcb_lock		;
	wire				clk_frame_buf		;
	wire				reset_frame_buf		;
	wire				clk_pix				;
	wire				reset_pix			;
	wire				o_clk_sensor		;
	wire				o_reset_senser_n	;
	wire				o_sensor_reset_done	;
	wire				o_clk_usb_pclk		;
	wire				clk_gpif			;
	wire				reset_gpif			;
	wire				reset_u3_interface	;


	//	ref ARCHITECTURE


	//  ===============================================================================================
	//  clock_reset例化
	//  ===============================================================================================
	clock_reset # (
	.DDR3_MEMCLK_FREQ		(bfm_clock_reset.DDR3_MEMCLK_FREQ		)
	)
	clock_reset_inst (
	.clk_osc				(bfm_clock_reset.clk_osc			),
	.i_reset_sensor			(bfm_clock_reset.i_reset_sensor		),
	.i_stream_enable		(bfm_clock_reset.i_stream_enable	),
	.clk_osc_bufg			(clk_osc_bufg			),
	.reset_osc_bufg			(reset_osc_bufg			),
	.async_rst				(async_rst				),
	.sysclk_2x				(sysclk_2x				),
	.sysclk_2x_180			(sysclk_2x_180			),
	.pll_ce_0				(pll_ce_0				),
	.pll_ce_90				(pll_ce_90				),
	.mcb_drp_clk			(mcb_drp_clk			),
	.bufpll_mcb_lock		(bufpll_mcb_lock		),
	.clk_frame_buf			(clk_frame_buf			),
	.reset_frame_buf		(reset_frame_buf		),
	.clk_pix				(clk_pix				),
	.reset_pix				(reset_pix				),
	.o_clk_sensor			(o_clk_sensor			),
	.o_reset_senser_n		(o_reset_senser_n		),
	.o_sensor_reset_done	(o_sensor_reset_done	),
	.o_clk_usb_pclk			(o_clk_usb_pclk			),
	.clk_gpif				(clk_gpif				),
	.reset_gpif				(reset_gpif				),
	.reset_u3_interface		(reset_u3_interface		)
	);

endmodule
