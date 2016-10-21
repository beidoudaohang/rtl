//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : testcase_1
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
	//	sensor model parameter
	//	-------------------------------------------------------------------------------------
	parameter	HISPI_PLL_INCLK_PERIOD		= 50000	;	//输入时钟频率，单位是ps
	parameter	HISPI_PLL_CLKOUT0_DIVIDE	= 1		;	//CLK0分频
	parameter	HISPI_PLL_CLKOUT1_DIVIDE	= 8		;	//CLK1分频
	parameter	HISPI_PLL_CLKOUT2_DIVIDE	= 8		;	//CLK2分频
	parameter	HISPI_PLL_CLKOUT3_DIVIDE	= 8		;	//CLK3分频
	parameter	HISPI_PLL_CLKOUT4_DIVIDE	= 8		;	//CLK4分频
	parameter	HISPI_PLL_CLKOUT5_DIVIDE	= 8		;	//CLK5分频
	parameter	HISPI_PLL_CLKFBOUT_MULT		= 33	;	//反馈时钟倍频因子
	parameter	HISPI_PLL_DIVCLK_DIVIDE		= 1		;	//分频因子

	parameter HISPI_MODE 					= "Packetized-SP"	;	//"Packetized-SP" or "Streaming-SP" or "Streaming-S" or "ActiveStart-SP8"
	parameter HISPI_WORD_WIDTH				= 12	;
	parameter HISPI_LANE_WIDTH				= 4		;

	//	-------------------------------------------------------------------------------------
	//	dut paramter
	//	-------------------------------------------------------------------------------------
	parameter	SER_FIRST_BIT			= "LSB"					;	//"LSB" or "MSB" , first bit to the receiver
	parameter	END_STYLE				= "LITTLE"				;	//"LITTLE" or "BIG" , "LITTLE" - {CHANNEL3 CHANNE2 CHANNEL1 CHANNEL0}. "BIG" - {CHANNEL0 CHANNEL1 CHANNEL2 CHANNEL3}.
	parameter	SER_DATA_RATE			= "DDR"					;	//"DDR" or "SDR" 输入的串行时钟采样方式
	parameter	DESER_CLOCK_ARC			= "BUFPLL"				;	//"BUFPLL" or "BUFIO2" , deserializer clock achitecture
	parameter	DESER_WIDTH				= 6						;	//每个通道解串宽度 2-8
	parameter	CLKIN_PERIOD_PS			= 3030					;	//输入时钟频率，PS为单位。只在BUFPLL方式下有用。
	parameter	DATA_DELAY_TYPE			= "DIFF_PHASE_DETECTOR"		;	//"WITHOUT_IDELAY" "DIFF_PHASE_DETECTOR" "FIXED"
	parameter	DATA_DELAY_VALUE		= 0						;	//0-255，最大不能超过 1 UI
	parameter	BITSLIP_ENABLE			= "FALSE"				;	//"TRUE" "FALSE" iserdes 字边界对齐功能
	parameter	CHANNEL_NUM				= 4						;	//串行数据通道数量
	parameter	SENSOR_DAT_WIDTH		= 12					;	//Sensor 数据宽度

	//	-------------------------------------------------------------------------------------
	//	testcase parameter
	//	-------------------------------------------------------------------------------------


	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	sensor signal
	//	-------------------------------------------------------------------------------------
	wire							hispi_clk_in		;
	reg								hispi_sensor_reset_n		;
	wire	[11:0]					hispi_active_width	;
	wire	[11:0]					hispi_blank_width	;
	wire	[11:0]					hispi_active_height	;
	wire	[11:0]					hispi_blank_height	;

	//	-------------------------------------------------------------------------------------
	//	dut signal
	//	-------------------------------------------------------------------------------------
	parameter	CLK_PERIOD				= 50	;	//时钟频率，20MHz
	reg									clk_osc			= 1'b0;

	wire								pix_clk_p	;
	wire								pix_clk_n	;
	wire	[CHANNEL_NUM-1:0]			iv_pix_data_p	;
	wire	[CHANNEL_NUM-1:0]			iv_pix_data_n	;

	reg									reset	= 1'b1;


	//	-------------------------------------------------------------------------------------
	//	testbench signal
	//	-------------------------------------------------------------------------------------
	wire	[15:0]			senor_active_width	;
	wire	[15:0]			senor_blank_width	;
	wire	[15:0]			senor_active_height	;
	wire	[15:0]			senor_blank_height	;

	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***tb 子模块激励***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	--ref Sensor
	//	-------------------------------------------------------------------------------------
	assign	hispi_clk_in	= clk_osc;

	initial begin
		hispi_sensor_reset_n	= 1'b0;
		#200;
		hispi_sensor_reset_n	= 1'b1;
	end

	assign	hispi_active_width		= senor_active_width/4+4	;	//	4608/4=1152
	assign	hispi_blank_width		= senor_blank_width/4-4		;
	assign	hispi_active_height		= senor_active_height[11:0]	;
	assign	hispi_blank_height		= senor_blank_height[11:0]	;

	//	-------------------------------------------------------------------------------------
	//	--ref DUT
	//	-------------------------------------------------------------------------------------
	always	#(CLK_PERIOD/2.0)		clk_osc		= !clk_osc;

	assign	pix_clk_p				= driver_hispi.sclk_o;
	assign	pix_clk_n				= ~driver_hispi.sclk_o;
	assign	iv_pix_data_p			= driver_hispi.sdata_o;
	assign	iv_pix_data_n			= ~driver_hispi.sdata_o;

	//	-------------------------------------------------------------------------------------
	//	--ref testbench
	//	-------------------------------------------------------------------------------------
	assign	senor_active_width		= 16'd4608	;
	//	assign	senor_active_width		= 16'd2000	;
	assign	senor_blank_width		= 16'd308	;
	assign	senor_active_height		= 16'd8	;
	assign	senor_blank_height		= 16'd2	;



	initial begin
		#300000
		$stop;
	end


	initial begin
		//$display("** ");
		//#1000000
		reset	= 1'b1;
		#2010
		reset	= 1'b0;
	end



endmodule
