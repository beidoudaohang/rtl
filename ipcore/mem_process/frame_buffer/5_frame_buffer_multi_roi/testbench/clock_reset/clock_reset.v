//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : clock_reset
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/6/5 14:07:54	:|  初始版本
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

module clock_reset # (
	parameter		DDR3_MEMCLK_FREQ	= 320	//Memory data transfer clock frequency DDR3-640:3125 DDR3-660:3030 DDR3-720:2778 DDR3-800:2500
	)
	(
	//  -------------------------------------------------------------------------------------
	//	外部晶振输入
	//  -------------------------------------------------------------------------------------
	input			clk_osc				,	//输入引脚，40MHz，接外部晶振
	//  -------------------------------------------------------------------------------------
	//	时钟复位输出
	//  -------------------------------------------------------------------------------------
	//mcb
	output			async_rst			,	//异步复位，只提供给MCB
	output			sysclk_2x			,	//高速时钟，只提供给MCB
	output			sysclk_2x_180		,	//高速时钟，只提供给MCB
	output 			pll_ce_0			,	//高速片选，只提供给MCB
	output 			pll_ce_90			,	//高速片选，只提供给MCB
	output			mcb_drp_clk			,	//calib逻辑时钟，只提供给MCB
	output			bufpll_mcb_lock		,	//bufpll_mcb 锁定信号，只提供给MCB
	//frame buf
	output			clk_frame_buf		,	//帧存时钟，与gpif时钟是同一个源头，为了保证模块独立性，帧存还是使用单独的时钟名称
	output			reset_frame_buf			//帧存时钟的复位信号，与gpif时钟域的复位信号是同一个源头
	);

	//	ref signals

	//PLL的参数
	parameter	DDR3_PLL_CLKIN_PERIOD	= 25000;
	parameter	DDR3_PLL_CLKOUT0_DIVIDE	= 1;
	parameter	DDR3_PLL_CLKOUT1_DIVIDE	= 1;
	parameter	DDR3_PLL_CLKOUT2_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 16	: ((DDR3_MEMCLK_FREQ==360) ? 16	: ((DDR3_MEMCLK_FREQ==330) ? 16	: ((DDR3_MEMCLK_FREQ==320) ? 16	: 16)));
	parameter	DDR3_PLL_CLKOUT3_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 5	: ((DDR3_MEMCLK_FREQ==360) ? 4	: ((DDR3_MEMCLK_FREQ==330) ? 5	: ((DDR3_MEMCLK_FREQ==320) ? 5	: 5)));
	parameter	DDR3_PLL_CLKOUT4_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 5	: ((DDR3_MEMCLK_FREQ==360) ? 5	: ((DDR3_MEMCLK_FREQ==330) ? 8	: ((DDR3_MEMCLK_FREQ==320) ? 5	: 5)));
	parameter	DDR3_PLL_CLKOUT5_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 5	: ((DDR3_MEMCLK_FREQ==360) ? 5	: ((DDR3_MEMCLK_FREQ==330) ? 8	: ((DDR3_MEMCLK_FREQ==320) ? 5	: 5)));
	parameter	DDR3_PLL_CLKFBOUT_MULT	= (DDR3_MEMCLK_FREQ==400) ? 20	: ((DDR3_MEMCLK_FREQ==360) ? 18	: ((DDR3_MEMCLK_FREQ==330) ? 33	: ((DDR3_MEMCLK_FREQ==320) ? 16	: 16)));
	parameter	DDR3_PLL_DIVCLK_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 1	: ((DDR3_MEMCLK_FREQ==360) ? 1	: ((DDR3_MEMCLK_FREQ==330) ? 2	: ((DDR3_MEMCLK_FREQ==320) ? 1	: 1)));

	wire				clk_osc_ibufg		;
	wire				clk_osc_bufio2		;
	reg		[3:0]		pwr_cnt				= 4'b0;
	wire				pwr_reset			;
	wire				pll_lock			;

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***输入时钟和上电复位***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	先经过ibufg缓冲器
	//  -------------------------------------------------------------------------------------
	IBUFG ibufg_osc_inst (
	.I	(clk_osc		),
	.O	(clk_osc_ibufg	)
	);

	//  -------------------------------------------------------------------------------------
	//	再经过bufio2缓冲器，20MHz
	//  -------------------------------------------------------------------------------------
	BUFIO2 #(
	.DIVIDE			(1				),	// DIVCLK divider (1,3-8)
	.DIVIDE_BYPASS	("TRUE"			),	// Bypass the divider circuitry (TRUE/FALSE)
	.I_INVERT		("FALSE"		),	// Invert clock (TRUE/FALSE)
	.USE_DOUBLER	("FALSE"		)	// Use doubler circuitry (TRUE/FALSE)
	)
	BUFIO2_inst (
	.I				(clk_osc_ibufg	),	// 1-bit input: Clock input (connect to IBUFG)
	.DIVCLK			(clk_osc_bufio2	),	// 1-bit output: Divided clock output
	.IOCLK			(				),	// 1-bit output: I/O output clock
	.SERDESSTROBE	(				)	// 1-bit output: Output SERDES strobe (connect to ISERDES2/OSERDES2)
	);

	//  -------------------------------------------------------------------------------------
	//	上电复位逻辑
	//	1.fpga 加载成功之后，会对 dcm pll产生复位信号，复位信号宽度是8个时钟周期
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_osc_ibufg) begin
		if(pwr_cnt[3] == 1'b0) begin
			pwr_cnt	<= pwr_cnt + 1'b1;
		end
	end
	assign	pwr_reset	= !pwr_cnt[3];

	//  ===============================================================================================
	//	ref ***PLL & DCM***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref ddr3 pll
	//	1.该PLL主要用于生成MCB所需要的时钟， sysclk_2x sysclk_2x_180 是高速时钟，普通逻辑不可用
	//	2.mcb_drp_clk 是慢速时钟，MCB中的Calibration逻辑使用的时钟，最高频率可以达到100MHz左右，其他逻辑也可以使用
	//	3.clk_out3 4 5 是PLL的其他输出端口，目前没有用到
	//  -------------------------------------------------------------------------------------
	infrastructure # (
	.C_INCLK_PERIOD  		(DDR3_PLL_CLKIN_PERIOD		),
	.C_CLKOUT0_DIVIDE		(DDR3_PLL_CLKOUT0_DIVIDE	),
	.C_CLKOUT1_DIVIDE		(DDR3_PLL_CLKOUT1_DIVIDE	),
	.C_CLKOUT2_DIVIDE		(DDR3_PLL_CLKOUT2_DIVIDE	),
	.C_CLKOUT3_DIVIDE		(DDR3_PLL_CLKOUT3_DIVIDE	),
	.C_CLKOUT4_DIVIDE		(DDR3_PLL_CLKOUT4_DIVIDE	),
	.C_CLKOUT5_DIVIDE		(DDR3_PLL_CLKOUT5_DIVIDE	),
	.C_CLKFBOUT_MULT 		(DDR3_PLL_CLKFBOUT_MULT		),
	.C_DIVCLK_DIVIDE 		(DDR3_PLL_DIVCLK_DIVIDE		)
	)
	ddr3_pll_inst (
	.sys_clk				(clk_osc_bufio2				),
	.sys_rst				(pwr_reset					),
	.async_rst				(async_rst					),
	.sysclk_2x				(sysclk_2x					),
	.sysclk_2x_180			(sysclk_2x_180				),
	.pll_ce_0				(pll_ce_0					),
	.pll_ce_90				(pll_ce_90					),
	.mcb_drp_clk			(mcb_drp_clk				),
	.bufpll_mcb_lock		(bufpll_mcb_lock			),
	.pll_lock				(pll_lock					),
	.clk_out3				(							),
	.clk_out4				(							),
	.clk_out5				(							)
	);



	//  ===============================================================================================
	//	ref ***复位管理***
	//	1.采用异步复位、同步释放的处理方法
	//  ===============================================================================================


	//  ===============================================================================================
	//	ref ***时钟输出***
	//  ===============================================================================================
	//  ===============================================================================================
	//	ref ***复位输出***
	//  ===============================================================================================




endmodule