//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : dcm
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/5/12 14:40:14	:|  初始版本
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

module dcm (
	input         clk_in		,
	input         dcm_reset		,
	output        clk_fx_out	,
	output        clk_2x_out	,
	output        locked
	);


	wire 		[7:0]  	status_int		;
	wire 				clkfb			;
	wire 				clk0			;
	wire 				clkfx			;
	wire 				clk2x			;


	//	ref signals

	//	ref ARCHITECTURE

//  -------------------------------------------------------------------------------------
//	dcm 例化
//  -------------------------------------------------------------------------------------
	DCM_SP # (
	.CLKDV_DIVIDE          (2.000				),
	//72MHz
	.CLKFX_DIVIDE          (5					),
	.CLKFX_MULTIPLY        (9					),
//	//75MHz
//	.CLKFX_DIVIDE          (8					),
//	.CLKFX_MULTIPLY        (15					),
//	//73.846MHz
//	.CLKFX_DIVIDE          (13					),
//	.CLKFX_MULTIPLY        (24					),
//	//72.941MHz
//	.CLKFX_DIVIDE          (17					),
//	.CLKFX_MULTIPLY        (31					),
	.CLKIN_DIVIDE_BY_2     ("FALSE"				),
	.CLKIN_PERIOD          (25.0				),
	.CLKOUT_PHASE_SHIFT    ("NONE"				),
	.CLK_FEEDBACK          ("1X"				),
	.DESKEW_ADJUST         ("SYSTEM_SYNCHRONOUS"),
	.PHASE_SHIFT           (0					),
	.STARTUP_WAIT          ("FALSE"				)
	)
	dcm_sp_inst (
	// Input clocks
	.CLKIN                 (clk_in	),
	.CLKFB                 (clkfb	),
	// Output clocks
	.CLK0                  (clk0	),
	.CLK90                 (),
	.CLK180                (),
	.CLK270                (),
	.CLK2X                 (clk2x	),
	.CLK2X180              (),
	.CLKFX                 (clkfx	),
	.CLKFX180              (),
	.CLKDV                 (),
	// Ports for dynamic phase shift
	.PSCLK                 (1'b0	),
	.PSEN                  (1'b0	),
	.PSINCDEC              (1'b0	),
	.PSDONE                (),
	// Other control and status signals
	.LOCKED                (locked		),
	.STATUS                (status_int	),
	.RST                   (dcm_reset	),
	// Unused pin- tie low
	.DSSEN                 (1'b0		)
	);

	

//  -------------------------------------------------------------------------------------
//	时钟
//  -------------------------------------------------------------------------------------
	BUFG clkfb_bufg (
	.I		(clk0	),
	.O		(clkfb	)
	);

	BUFG clkfx_bufg (
	.I		(clkfx		),
	.O		(clk_fx_out	)
	);

	BUFG clk2x_bufg (
	.I		(clk2x		),
	.O		(clk_2x_out	)
	);

endmodule
