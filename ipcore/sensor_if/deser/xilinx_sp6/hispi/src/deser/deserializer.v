//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : deserializer
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/9/18 10:50:31	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 串行时钟数据解串模块
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

module deserializer # (
	parameter	DIFF_TERM				= "TRUE"			,	//Differential Termination
	parameter	IOSTANDARD				= "LVDS_33"			,	//Specifies the I/O standard for this buffer
	parameter	SER_FIRST_BIT			= "LSB"				,	//"LSB" or "MSB" , first bit to the receiver
	parameter	END_STYLE				= "LITTLE"			,	//"LITTLE" or "BIG" , "LITTLE" - {CHANNEL3 CHANNE2 CHANNEL1 CHANNEL0}. "BIG" - {CHANNEL0 CHANNEL1 CHANNEL2 CHANNEL3}.
	parameter	SER_DATA_RATE			= "DDR"				,	//"DDR" or "SDR" 输入的串行时钟采样方式
	parameter	DESER_CLOCK_ARC			= "BUFPLL"			,	//"BUFPLL" or "BUFIO2" , deserializer clock achitecture
	parameter	CHANNEL_NUM				= 4					,	//差分通道个数
	parameter	DESER_WIDTH				= 6					,	//每个通道解串宽度 2-8
	parameter	CLKIN_PERIOD_PS			= 3030				,	//输入时钟频率，PS为单位。只在BUFPLL方式下有用。
	parameter	DATA_DELAY_TYPE			= "DIFF_PHASE_DETECTOR"	,	//"DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
	parameter	DATA_DELAY_VALUE		= 0					,	//0-255，最大不能超过 1 UI
	parameter	BITSLIP_ENABLE			= "TRUE"				//"TRUE" "FALSE" iserdes 字边界对齐功能
	)
	(
	//	-------------------------------------------------------------------------------------
	//	差分串行时钟数据
	//	-------------------------------------------------------------------------------------
	input											i_clk_p				,	//差分时钟输入
	input											i_clk_n				,	//差分时钟输入
	input		[CHANNEL_NUM-1:0]					iv_data_p			,	//差分数据输入
	input		[CHANNEL_NUM-1:0]					iv_data_n			,	//差分数据输入
	//	-------------------------------------------------------------------------------------
	//	控制信号
	//	-------------------------------------------------------------------------------------
	input											reset				,	//复位信号，bufpll方式下，复位解串pll；bufio2方式下，复位xxxxxx
	input		[CHANNEL_NUM-1:0]					iv_bitslip			,	//字节边界对齐命令，每次上升沿移位一次
	output											o_bufpll_lock		,	//bufpll lock 信号
	//	-------------------------------------------------------------------------------------
	//	解串恢复并行时钟数据
	//	-------------------------------------------------------------------------------------
	output											clk_recover			,	//恢复时钟
	output											reset_recover		,	//恢复时钟域复位信号
	output		[DESER_WIDTH*CHANNEL_NUM-1:0]		ov_data_recover			//并行数据输出
	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	如果定义了BUFPLL解串时钟，则在数据ISERDES端，采样方式必须是SDR
	//	-------------------------------------------------------------------------------------
	localparam		SER_DATA_RATE_ISERDES	= (DESER_CLOCK_ARC=="BUFPLL") ? "SDR" : SER_DATA_RATE;

	wire				clk_io	;
	wire				clk_io_inv	;
	wire				serdesstrobe	;
	wire				bufpll_lock	;

	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//  实例化解串时钟结构： bufpll or bufio2
	//  -------------------------------------------------------------------------------------
	generate
		if(DESER_CLOCK_ARC=="BUFPLL") begin
			deser_clk_gen_bufpll # (
			.DIFF_TERM				(DIFF_TERM			),
			.IOSTANDARD				(IOSTANDARD			),
			.SER_DATA_RATE			(SER_DATA_RATE		),
			.DESER_WIDTH			(DESER_WIDTH		),
			.CLKIN_PERIOD_PS		(CLKIN_PERIOD_PS	)
			)
			deser_clk_gen_bufpll_inst (
			.clkin_p				(i_clk_p			),
			.clkin_n				(i_clk_n			),
			.reset					(reset				),
			.clk_recover			(clk_recover		),
			.clk_io					(clk_io				),
			.serdesstrobe			(serdesstrobe		),
			.bufpll_lock			(bufpll_lock		)
			);
			assign	clk_io_inv	= 1'b0;
		end
		else if(DESER_CLOCK_ARC=="BUFIO2") begin
			deser_clk_gen_bufio2 # (
			.DIFF_TERM				(DIFF_TERM			),
			.IOSTANDARD				(IOSTANDARD			),
			.SER_DATA_RATE			(SER_DATA_RATE		),
			.DESER_WIDTH			(DESER_WIDTH		)
			)
			deser_clk_gen_bufio2_inst (
			.clkin_p				(i_clk_p			),
			.clkin_n				(i_clk_n			),
			.clk_recover			(clk_recover		),
			.clk_io					(clk_io				),
			.clk_io_inv				(clk_io_inv			),
			.serdesstrobe			(serdesstrobe		)
			);
			assign	bufpll_lock	= !reset;
		end
	endgenerate
	assign	o_bufpll_lock	= bufpll_lock;

	//  -------------------------------------------------------------------------------------
	//  恢复时钟复位信号
	//  -------------------------------------------------------------------------------------
	reset_sync # (
	.INITIALISE		(2'b11	)
	)
	reset_sync_inst (
	.reset_in		(!bufpll_lock		),
	.clk			(clk_recover		),
	.enable			(1'b1				),
	.reset_out		(reset_recover		)
	);

	//  -------------------------------------------------------------------------------------
	//  实例化数据解串
	//  -------------------------------------------------------------------------------------
	deser_data # (
	.DIFF_TERM			(DIFF_TERM			),
	.IOSTANDARD			(IOSTANDARD			),
	.SER_FIRST_BIT		(SER_FIRST_BIT		),
	.END_STYLE			(END_STYLE			),
	.SER_DATA_RATE		(SER_DATA_RATE_ISERDES	),
	.CHANNEL_NUM		(CHANNEL_NUM		),
	.DESER_WIDTH		(DESER_WIDTH		),
	.DATA_DELAY_TYPE	(DATA_DELAY_TYPE	),
	.DATA_DELAY_VALUE	(DATA_DELAY_VALUE	),
	.BITSLIP_ENABLE		(BITSLIP_ENABLE		)
	)
	deser_data_inst (
	.iv_data_p			(iv_data_p			),
	.iv_data_n			(iv_data_n			),
	.clk_io				(clk_io				),
	.clk_io_inv			(clk_io_inv			),
	.serdesstrobe		(serdesstrobe		),
	.iv_bitslip			(iv_bitslip			),
	.clk_recover		(clk_recover		),
	.reset_recover		(reset_recover		),
	.ov_data_recover	(ov_data_recover	)
	);

endmodule
