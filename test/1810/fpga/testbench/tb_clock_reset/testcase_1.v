//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : testcase_4
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/4/10 16:50:28	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 窗口大小是16x16，开采信号有效，正常模式下的运行状况
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

module testcase_1 ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	TESTCASE
	//	-------------------------------------------------------------------------------------
	parameter	TESTCASE_NUM			= "testcase_1"			;	//其他模块需要使用字符串

	//	-------------------------------------------------------------------------------------
	//	monitor paramter
	//	-------------------------------------------------------------------------------------
	//	parameter	MONITOR_OUTPUT_FILE_EN			= 0						;	//是否产生输出文件
	//	parameter	MONITOR_OUTPUT_FILE_PATH		= "file/mer_file/"		;	//产生的数据要写入的路径
	//	parameter	CHK_INOUT_DATA_STOP_ON_ERROR	= 0						;
	//	parameter	CHK_PULSE_WIDTH_STOP_ON_ERROR	= 0						;

	//	-------------------------------------------------------------------------------------
	//	testcase parameter
	//	-------------------------------------------------------------------------------------
	parameter		DDR3_MEMCLK_FREQ	= 320		;	//Memory data transfer clock frequency DDR3-640:3125 DDR3-660:3030 DDR3-720:2778 DDR3-800:2500

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================


	//	-------------------------------------------------------------------------------------
	//	dut signal
	//	-------------------------------------------------------------------------------------
	parameter	CLK_PERIOD				= 25	;	//时钟频率，40MHz
	reg									clk_osc			= 1'b0;

	reg									i_reset_sensor	= 1'b0;
	reg									i_stream_enable	= 1'b0;



	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***tb 子模块激励***
	//	===============================================================================================

	//	-------------------------------------------------------------------------------------
	//	--ref DUT
	//	-------------------------------------------------------------------------------------
	always	#(CLK_PERIOD/2.0)		clk_osc		= !clk_osc;

	initial begin

		#500000
		#1000000
		$stop;
	end






endmodule
