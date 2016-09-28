//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : driver_hispi
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/9/16 17:46:01	:|  初始版本
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
`define		TESTCASE	testcase_1
module driver_hispi ();

	//	ref signals

	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	parameter	HISPI_PLL_INCLK_PERIOD			= `TESTCASE.HISPI_PLL_INCLK_PERIOD				;
	parameter	HISPI_PLL_CLKOUT0_DIVIDE		= `TESTCASE.HISPI_PLL_CLKOUT0_DIVIDE			;
	parameter	HISPI_PLL_CLKOUT1_DIVIDE		= `TESTCASE.HISPI_PLL_CLKOUT1_DIVIDE			;
	parameter	HISPI_PLL_CLKOUT2_DIVIDE		= `TESTCASE.HISPI_PLL_CLKOUT2_DIVIDE			;
	parameter	HISPI_PLL_CLKOUT3_DIVIDE		= `TESTCASE.HISPI_PLL_CLKOUT3_DIVIDE			;
	parameter	HISPI_PLL_CLKOUT4_DIVIDE		= `TESTCASE.HISPI_PLL_CLKOUT4_DIVIDE			;
	parameter	HISPI_PLL_CLKOUT5_DIVIDE		= `TESTCASE.HISPI_PLL_CLKOUT5_DIVIDE			;
	parameter	HISPI_PLL_CLKFBOUT_MULT			= `TESTCASE.HISPI_PLL_CLKFBOUT_MULT				;
	parameter	HISPI_PLL_DIVCLK_DIVIDE			= `TESTCASE.HISPI_PLL_DIVCLK_DIVIDE				;

	parameter	HISPI_MODE						= `TESTCASE.HISPI_MODE						;
	parameter	HISPI_WORD_WIDTH				= `TESTCASE.HISPI_WORD_WIDTH				;
	parameter	HISPI_LANE_WIDTH				= `TESTCASE.HISPI_LANE_WIDTH				;


	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	输入
	//	-------------------------------------------------------------------------------------
	wire				sys_clk	;
	wire				rstn	;
	wire	[11:0]		vd_active_width	;
	wire	[11:0]		vd_blank_width	;
	wire	[11:0]		vd_active_height	;
	wire	[11:0]		vd_blank_height	;

	//	-------------------------------------------------------------------------------------
	//	输出
	//	-------------------------------------------------------------------------------------
	wire				pll_lock	;
	wire				clk_out0	;
	wire				sclk_o	;
	wire	[3:0]		sdata_o	;

	//	-------------------------------------------------------------------------------------
	//	连接
	//	-------------------------------------------------------------------------------------
	wire	sclk	;

	//	ref ARCHITECTURE
	//	-------------------------------------------------------------------------------------
	//	引用
	//	-------------------------------------------------------------------------------------
	//  ===============================================================================================
	//	ref ***引用***
	//  ===============================================================================================
	assign	sys_clk				= `TESTCASE.hispi_clk_in			;
	assign	rstn				= `TESTCASE.hispi_sensor_reset_n	;

	assign	vd_active_width		= `TESTCASE.hispi_active_width	;
	assign	vd_blank_width		= `TESTCASE.hispi_blank_width	;
	assign	vd_active_height	= `TESTCASE.hispi_active_height	;
	assign	vd_blank_height		= `TESTCASE.hispi_blank_height	;


	//	-------------------------------------------------------------------------------------
	//	串行时钟倍频
	//	-------------------------------------------------------------------------------------
	pll_hispi # (
	.C_INCLK_PERIOD		(HISPI_PLL_INCLK_PERIOD		),
	.C_CLKOUT0_DIVIDE	(HISPI_PLL_CLKOUT0_DIVIDE	),
	.C_CLKOUT1_DIVIDE	(HISPI_PLL_CLKOUT1_DIVIDE	),
	.C_CLKOUT2_DIVIDE	(HISPI_PLL_CLKOUT2_DIVIDE	),
	.C_CLKOUT3_DIVIDE	(HISPI_PLL_CLKOUT3_DIVIDE	),
	.C_CLKOUT4_DIVIDE	(HISPI_PLL_CLKOUT4_DIVIDE	),
	.C_CLKOUT5_DIVIDE	(HISPI_PLL_CLKOUT5_DIVIDE	),
	.C_CLKFBOUT_MULT	(HISPI_PLL_CLKFBOUT_MULT	),
	.C_DIVCLK_DIVIDE	(HISPI_PLL_DIVCLK_DIVIDE	)
	)
	pll_hispi_inst (
	.sys_clk			(sys_clk	),
	.pll_lock			(pll_lock	),
	.clk_out0			(sclk		)
	);

	//	-------------------------------------------------------------------------------------
	//	hispi 仿真模型
	//	-------------------------------------------------------------------------------------
	hispi_stim # (
	.c_HISPI_MODE		(HISPI_MODE			),
	.c_WORD_WIDTH		(HISPI_WORD_WIDTH	),
	.c_LANE_WIDTH		(HISPI_LANE_WIDTH	)
	)
	hispi_stim_inst (
	.vd_active_width	(vd_active_width	),
	.vd_blank_width		(vd_blank_width		),
	.vd_active_height	(vd_active_height	),
	.vd_blank_height	(vd_blank_height	),
	.rstn				(rstn				),
	.sclk				(sclk				),
	.sclk_o				(sclk_o				),
	.sdata_o			(sdata_o			)
	);


endmodule
