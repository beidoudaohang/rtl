
//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : deser_clk_gen_bufpll.v
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  --修改记录  :
//
//  -- 作者         :| 修改日期				:|  修改说明
//---------------------------------------------------------------------------------------
//  -- 禹剑       	:| 02/25/2013			:|  初始版本
//  -- 邢海涛      	:| 2015/9/18 11:26:17	:|	重新规划解串时钟模块
//  -- 邢海涛      	:| 2016/3/1 11:02:14	:|	添加 localparam ，解决输入时钟频率过低的问题
//---------------------------------------------------------------------------------------
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
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module  deser_clk_gen_bufpll # (
	parameter	DIFF_TERM				= "TRUE"			,	//Differential Termination
	parameter	IOSTANDARD				= "LVDS_33"			,	//Specifies the I/O standard for this buffer
	parameter	SER_DATA_RATE			= "DDR"				,	//"DDR" or "SDR" 串行数据的采样方式
	parameter	DESER_WIDTH				= 6					,	//每个通道解串宽度 2-8
	parameter	CLKIN_PERIOD_PS			= 3030					//输入时钟频率，PS为单位。只在BUFPLL方式下有用。
	)
	(
	input						reset				,	//高有效复位
	input						clkin_p				,	//串行时钟
	input                       clkin_n				,   //串行时钟
	output						clk_recover			,	//恢复出的慢速时钟
	output						clk_io				,	//高速串行时钟
	output						serdesstrobe		,	//iserdes使用
	output						bufpll_lock				//输出BUFPLL的锁定信号
	);
	//	ref signals

	//	-------------------------------------------------------------------------------------
	//	如果输入时钟是DDR的方式，需要对输入时钟倍频
	//	-------------------------------------------------------------------------------------
	localparam		CLKFBOUT_MULT	= (SER_DATA_RATE=="DDR") ? 2 : 1;
	localparam		CLKIN_PERIOD_NS	= CLKIN_PERIOD_PS/1000.0;

	//	-------------------------------------------------------------------------------------
	//	VCO的计算方法有两种，按照反馈的方式来区分
	//
	//	1.反馈时钟是CLKOUT0
	//	fVCO		= (fIN × CLKFBOUT_MULT × CLKOUT0_DIVIDE)/DIVCLK_DIVIDE
	//
	//	2.反馈时钟是CLKFB
	//	fVCO	= (fIN × CLKFBOUT_MULT)/DIVCLK_DIVIDE
	//
	//	3.无论哪种反馈方式，输出时钟只与fVCO和各自的分频系数相关，比如 fCLKOUT0
	//	fCLKOUT0	= fVCO/CLKOUT0_DIVIDE
	//
	//	4.本解串模块必须使用CLKOUT0的反馈方式
	//
	//	-------------------------------------------------------------------------------------
	//	PLL的VCO时钟的频率范围是 400.000000 - 1000.000000 MHz。
	//	1.如果输入的时钟小于200MHz，即便2倍频之后，还是无法到达最低下限400MHz，因此就需要额外的2倍频
	//	-------------------------------------------------------------------------------------
	localparam		CLKOUT0_DIVIDE	= (CLKIN_PERIOD_PS>=5000) ? 2 : 1;
	localparam		CLKOUT1_DIVIDE	= (CLKIN_PERIOD_PS>=5000) ? DESER_WIDTH*2 : DESER_WIDTH;


	wire		clk_ibufgds		;
	wire		clk_delay		;
	wire		clk_iserdes		;
	wire		feedback		;
	wire		clk_bufio2		;
	wire		clk_fb			;
	wire		pll_lock		;
	wire		pllout_xn		;
	wire    	pllout_x1 		;	// pll generated x1 clock

	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//  ref 差分时钟输入
	//  -------------------------------------------------------------------------------------
	IBUFGDS # (
	.DIFF_TERM	(DIFF_TERM		),	// Differential Termination
	.IOSTANDARD	(IOSTANDARD		)	// Specifies the I/O standard for this buffer
	)
	ibufds_deser_clk_inst (
	.I    		(clkin_p		),
	.IB       	(clkin_n		),
	.O         	(clk_ibufgds	)
	);

	//  -------------------------------------------------------------------------------------
	//  ref 时钟延时
	//  -------------------------------------------------------------------------------------
	IODELAY2 # (
	.DATA_RATE      		(SER_DATA_RATE		),	//<SDR>, DDR
	.IDELAY_VALUE  			(0					),	//{0 ... 255}
	.IDELAY_TYPE   			("FIXED"			),	//"DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
	.COUNTER_WRAPAROUND 	("WRAPAROUND"		),	//<STAY_AT_LIMIT>, WRAPAROUND
	.DELAY_SRC     			("IDATAIN" 			),	//"IO", "IDATAIN", "ODATAIN"
	.SERDES_MODE   			("NONE"				),	//<NONE>, MASTER, SLAVE
	.SIM_TAPDELAY_VALUE   	(49					) 	//
	)
	iodelay_deser_clk_inst (
	// required datapath
	.IDATAIN  				(clk_ibufgds		),	//data from primary IOB
	.DATAOUT  				(clk_delay			),	//Output data 1 to ILOGIC/ISERDES2
	.T        				(1'b1				),	//tri-state control from OLOGIC/OSERDES2
	// inactive data connections
	.DATAOUT2 				(					),	//Output data 2 to ILOGIC/ISERDES2
	.DOUT     				(					),	//output data to IOB
	.ODATAIN  				(1'b0				),	//data from OLOGIC/OSERDES2
	.TOUT     				(					),	//tri-state signal to IOB
	// tie off the clocks
	.IOCLK0                 (1'b0				),	//High speed clock for calibration for SDR/DDR
	.IOCLK1                 (1'b0				),	//High speed clock for calibration for DDR
	// Tie of the variable delay programming
	.CLK                    (1'b0				),	//Fabric clock for control signals
	.CAL      				(1'b0				),	//Calibrate control signal
	.INC      				(1'b0				),	//Increment counter
	.CE       				(1'b0				),	//Clock Enable
	.RST      				(1'b0				),	//Reset delay line
	.BUSY      				(					) 	//output signal indicating sync circuit has finished / calibration has finished
	);

	//  -------------------------------------------------------------------------------------
	//  ref iserdes 驱动
	//	-- clk input path : clk_in -> ibufds -> idelay -> iserdes -> bufio2 -> pll_in
	//	-- clk feedback path : pll_out -> bufpll -> iserdes -> bufio2_fb -> pll_fb_in
	//  -------------------------------------------------------------------------------------
	ISERDES2 #(
	.DATA_WIDTH     	(1			), 	// SERDES word width.  This should match the setting is BUFPLL
	.DATA_RATE      	("SDR"		), 	// <SDR>, DDR
	.BITSLIP_ENABLE 	("FALSE"	), 	// <FALSE>, TRUE
	.SERDES_MODE    	("NONE"		), 	// <DEFAULT>, MASTER, SLAVE
	.INTERFACE_TYPE 	("RETIMED"	)	// NETWORKING, NETWORKING_PIPELINED, <RETIMED>
	)
	iserdes_clk (
	.D       			(clk_delay	),
	.CE0     			(1'b1		),
	.CLK0    			(clk_io		),
	.CLK1    			(1'b0		),
	.IOCE    			(1'b1		),	//must be 1
	.RST     			(1'b0		),
	.CLKDIV  			(clk_recover),
	.SHIFTIN 			(1'b0		),
	.BITSLIP 			(1'b0		),
	.FABRICOUT 			(			),
	.DFB 				(clk_iserdes),
	.CFB0 				(feedback	),
	.CFB1 				(			),
	.Q4  				(			),
	.Q3  				(			),
	.Q2  				(			),
	.Q1  				(			),
	.VALID 				(			),
	.INCDEC 			(			),
	.SHIFTOUT 			(			)
	);

	//  -------------------------------------------------------------------------------------
	//  bufio2
	//	--used for clk in
	//  -------------------------------------------------------------------------------------
	BUFIO2 # (
	.DIVIDE					(1						),	// The DIVCLK divider divide-by value
	.I_INVERT				("FALSE"				),
	.DIVIDE_BYPASS			("TRUE"					),
	.USE_DOUBLER			("FALSE"				)
	)
	bufio2_deser_clk_inst (
	.I						(clk_iserdes			),	// Input source clock 0 degrees
	.IOCLK					(						),	// Output Clock for IO
	.DIVCLK					(clk_bufio2				),	// Output Divided Clock
	.SERDESSTROBE			(						) 	// Output SERDES strobe (Clock Enable)
	);

	//  -------------------------------------------------------------------------------------
	//  ref pll 产生高速io时钟和慢速恢复时钟
	//  -------------------------------------------------------------------------------------
	PLL_BASE # (
	.BANDWIDTH              ("OPTIMIZED"			),
	.CLK_FEEDBACK           ("CLKOUT0"				),
	.COMPENSATION           ("SOURCE_SYNCHRONOUS"	),
	.DIVCLK_DIVIDE          (1						),
	.CLKFBOUT_MULT          (CLKFBOUT_MULT			),
	.CLKFBOUT_PHASE         (0.000					),
	.CLKOUT0_DIVIDE         (CLKOUT0_DIVIDE			),
	.CLKOUT0_PHASE          (0.000					),
	.CLKOUT0_DUTY_CYCLE     (0.500					),
	.CLKOUT1_DIVIDE         (CLKOUT1_DIVIDE			),
	.CLKOUT1_PHASE          (0.000					),
	.CLKOUT1_DUTY_CYCLE     (0.500					),
	.CLKIN_PERIOD           (CLKIN_PERIOD_NS		),
	.REF_JITTER             (0.010					)
	)
	pll_base_deser_clk_inst (
	.CLKFBOUT              (						),
	.CLKOUT0               (pllout_xn				),
	.CLKOUT1               (pllout_x1				),
	.CLKOUT2               (						),
	.CLKOUT3               (						),
	.CLKOUT4               (						),
	.CLKOUT5               (						),
	// Status and control signals
	.LOCKED                (pll_lock				),
	.RST                   (reset					),
	// Input clock control
	.CLKFBIN               (clk_fb					),
	.CLKIN                 (clk_bufio2				)
	);

	//  -------------------------------------------------------------------------------------
	//  BUFPLL 驱动高速io时钟
	//  -------------------------------------------------------------------------------------
	BUFPLL # (
	.DIVIDE        		(DESER_WIDTH	),
	.ENABLE_SYNC		("TRUE"			)
	)
	bufpll_clk_io_inst (
	.PLLIN        		(pllout_xn		),
	.GCLK         		(clk_recover	),	// GCLK must be driven by BUFG
	.LOCKED       		(pll_lock		),
	.IOCLK        		(clk_io			),
	.SERDESSTROBE 		(serdesstrobe	),
	.LOCK         		(bufpll_lock	)
	);

	//  -------------------------------------------------------------------------------------
	//  BUFIO2FB 反馈
	//  -------------------------------------------------------------------------------------
	BUFIO2FB # (
	.DIVIDE_BYPASS	("TRUE"		)	// Bypass divider (TRUE/FALSE)
	)
	BUFIO2FB_pll_fb_inst (
	.I		(feedback	),	// 1-bit input: Feedback clock input (connect to input port)
	.O		(clk_fb		)	// 1-bit output: Output feedback clock (connect to feedback input of DCM/PLL)
	);

	//  -------------------------------------------------------------------------------------
	//  ref BUFG 驱动慢速恢复时钟
	//  -------------------------------------------------------------------------------------
	BUFG bufg_recover_inst (
	.I		(pllout_x1		),//随路串行时钟产生的并行数据时钟
	.O		(clk_recover	)
	);

endmodule