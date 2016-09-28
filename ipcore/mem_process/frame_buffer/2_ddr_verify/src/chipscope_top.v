//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : chipscope_top
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/10/27 10:21:13	:|  初始版本
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

module chipscope_top (
	input				CLK			,
	input	[34:0]		TRIG0
	);

	//	ref signals
	wire	[35:0]			CONTROL0	;

	//	ref ARCHITECTURE
	chipscope_icon_user1_1port chipscope_icon_user1_1port_inst (
	.CONTROL0	(CONTROL0	)
	);

	chipscope_ila_w35_d1k chipscope_ila_w35_d1k_inst (
	.CONTROL	(CONTROL0	),
	.CLK		(CLK		),
	.TRIG0		(TRIG0		)
	);


endmodule
