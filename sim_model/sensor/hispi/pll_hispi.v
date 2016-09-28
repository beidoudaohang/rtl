//*****************************************************************************
// (c) Copyright 2010 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Version            : %version
//  \   \         Application        : MIG
//  /   /         Filename           : pll_hispi.v
// /___/   /\     Date Last Modified : $Date: 2011/06/02 07:17:09 $
// \   \  /  \    Date Created       : Mon Mar 2 2009
//  \___\/\___\
//
//Device           : Spartan-6
//Design Name      : DDR/DDR2/DDR3/LPDDR
//Purpose          : Clock generation/distribution and reset synchronization
//Reference        :
//Revision History :
//*****************************************************************************
//  -------------------------------------------------------------------------------------
//	2013/8/6 13:15:33 modified by xht
//  -------------------------------------------------------------------------------------

`timescale 1ns/1ps

module pll_hispi #	(
	parameter	C_INCLK_PERIOD		= 50000	,	//输入时钟频率，单位是ps
	parameter	C_CLKOUT0_DIVIDE	= 1		,	//CLK0分频
	parameter	C_CLKOUT1_DIVIDE	= 8		,	//CLK1分频
	parameter	C_CLKOUT2_DIVIDE	= 8		,	//CLK2分频
	parameter	C_CLKOUT3_DIVIDE	= 8		,	//CLK3分频
	parameter	C_CLKOUT4_DIVIDE	= 8		,	//CLK4分频
	parameter	C_CLKOUT5_DIVIDE	= 8		,	//CLK5分频
	parameter	C_CLKFBOUT_MULT		= 33	,	//反馈时钟倍频因子
	parameter	C_DIVCLK_DIVIDE		= 1			//分频因子
	)
	(
	input 					sys_clk			,	//时钟输入
	output 					pll_lock		,	//pll 锁定信号
	output					clk_out0			//pll clkout0
	);

	// # of clock cycles to delay deassertion of reset. Needs to be a fairly
	// high number not so much for metastability protection, but to give time
	// for reset (i.e. stable clock cycles) to propagate through all state
	// machines and to all control signals (i.e. not all control signals have
	// resets, instead they rely on base state logic being reset, and the effect
	// of that reset propagating through the logic). Need this because we may not
	// be getting stable clock cycles while reset asserted (i.e. since reset
	// depends on PLL/DCM lock status)

	localparam	CLK_PERIOD_NS		= C_INCLK_PERIOD / 1000.0;


	wire			clk0_bufg			;
	wire			clk0_bufg_in		;
	wire			sys_clk_ibufg		;
	wire			locked				;

	assign			pll_lock			= locked			;
	assign			sys_clk_ibufg		= sys_clk			;
	assign			clk_out0			= clk0_bufg			;

	//***************************************************************************
	// Global clock generation and distribution
	//***************************************************************************

	PLL_ADV # (
	.BANDWIDTH         		("OPTIMIZED"		),
	.CLKIN1_PERIOD     		(CLK_PERIOD_NS		),
	.CLKIN2_PERIOD     		(CLK_PERIOD_NS		),
	.CLKOUT0_DIVIDE    		(C_CLKOUT0_DIVIDE	),
	.CLKOUT1_DIVIDE    		(C_CLKOUT1_DIVIDE	),
	.CLKOUT2_DIVIDE    		(C_CLKOUT2_DIVIDE	),
	.CLKOUT3_DIVIDE    		(C_CLKOUT3_DIVIDE	),
	.CLKOUT4_DIVIDE    		(C_CLKOUT4_DIVIDE	),
	.CLKOUT5_DIVIDE    		(C_CLKOUT5_DIVIDE	),
	.CLKOUT0_PHASE     		(0.000				),
	.CLKOUT1_PHASE     		(0.000				),
	.CLKOUT2_PHASE     		(0.000				),
	.CLKOUT3_PHASE     		(0.000				),
	.CLKOUT4_PHASE     		(0.000				),
	.CLKOUT5_PHASE     		(0.000				),
	.CLKOUT0_DUTY_CYCLE		(0.500				),
	.CLKOUT1_DUTY_CYCLE		(0.500				),
	.CLKOUT2_DUTY_CYCLE		(0.500				),
	.CLKOUT3_DUTY_CYCLE		(0.500				),
	.CLKOUT4_DUTY_CYCLE		(0.500				),
	.CLKOUT5_DUTY_CYCLE		(0.500				),
	.SIM_DEVICE        		("SPARTAN6"			),
	.COMPENSATION      		("INTERNAL"			),
	.DIVCLK_DIVIDE     		(C_DIVCLK_DIVIDE	),
	.CLKFBOUT_MULT     		(C_CLKFBOUT_MULT	),
	.CLKFBOUT_PHASE    		(0.0				),
	.REF_JITTER        		(0.005000			)
	)
	inst_pll_adv (
	.CLKFBIN     			(clkfbout_clkfbin	),
	.CLKINSEL    			(1'b1				),
	.CLKIN1      			(sys_clk_ibufg		),
	.CLKIN2      			(1'b0				),
	.DADDR       			(5'b0				),
	.DCLK        			(1'b0				),
	.DEN         			(1'b0				),
	.DI          			(16'b0				),
	.DWE         			(1'b0				),
	.REL         			(1'b0				),
	.RST         			(sys_rst			),
	.CLKFBDCM    			(),
	.CLKFBOUT    			(clkfbout_clkfbin	),
	.CLKOUTDCM0  			(),
	.CLKOUTDCM1  			(),
	.CLKOUTDCM2  			(),
	.CLKOUTDCM3  			(),
	.CLKOUTDCM4  			(),
	.CLKOUTDCM5  			(),
	.CLKOUT0     			(clk0_bufg_in		),
	.CLKOUT1     			(		),
	.CLKOUT2     			(		),
	.CLKOUT3     			(		),
	.CLKOUT4     			(		),
	.CLKOUT5     			(		),
	.DO          			(),
	.DRDY        			(),
	.LOCKED      			(locked				)
	);

	BUFG inst_BUFG_clk0 (
	.I 		(clk0_bufg_in	),
	.O 		(clk0_bufg		)
	);

endmodule