
//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : deser_clk_gen_bufio2.v
//  -- 设计者       : 禹剑
//-------------------------------------------------------------------------------------------------
//
//  --修改记录  :
//
//  -- 作者         :| 修改日期				:|  修改说明
//---------------------------------------------------------------------------------------
//  -- 禹剑       	:| 02/25/2013			:|  初始版本
//  -- 邢海涛      	:| 2015/9/18 13:29:02	:|	重新规划解串时钟模块
//
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
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module  deser_clk_gen_bufio2 # (
	parameter	SER_DATA_RATE			= "DDR"				,	//"DDR" or "SDR" 串行数据的采样方式
	parameter	DESER_WIDTH				= 6						//每个通道解串宽度 2-8
	)
	(
	input						clkin_p				,	//串行时钟
	input                       clkin_n				,   //串行时钟
	output						clk_recover			,	//恢复出的慢速时钟
	output						clk_io				,	//高速串行时钟
	output						clk_io_inv			,	//高速串行时钟，反向，DDR的方式会用到
	output						serdesstrobe			//iserdes使用
	);

	//	ref signals

	wire				clk_p_ibufgds	;
	wire				clk_n_ibufgds	;
	wire				clk_ibufgds		;
	wire				clk_p_delay		;
	wire				clk_n_delay		;
	wire				clk_delay		;
	wire				clk_div			;


	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//  ref 差分时钟输入
	//  -------------------------------------------------------------------------------------
	generate
		if(SER_DATA_RATE=="DDR") begin
			IBUFGDS_DIFF_OUT ibufds_deser_clk_inst (
			.I				(clkin_p		),
			.IB				(clkin_n		),
			.O				(clk_p_ibufgds	),
			.OB				(clk_n_ibufgds	)
			);
		end
		else if(SER_DATA_RATE=="SDR") begin
			IBUFGDS ibufds_deser_clk_inst (
			.I    			(clkin_p		),
			.IB       		(clkin_n		),
			.O         		(clk_ibufgds	)
			);
		end
	endgenerate

	//  -------------------------------------------------------------------------------------
	//  ref 时钟延时
	//  -------------------------------------------------------------------------------------
	generate
		if(SER_DATA_RATE=="DDR") begin
			IODELAY2 # (
			.DATA_RATE      		("SDR"				),	//<SDR>, DDR
			.IDELAY_VALUE  			(0					),	//{0 ... 255}
			.IDELAY_TYPE   			("FIXED"			),	//"DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
			.COUNTER_WRAPAROUND 	("WRAPAROUND"		),	//<STAY_AT_LIMIT>, WRAPAROUND
			.DELAY_SRC     			("IDATAIN" 			),	//"IO", "IDATAIN", "ODATAIN"
			.SERDES_MODE   			("MASTER"			),	//<NONE>, MASTER, SLAVE
			.SIM_TAPDELAY_VALUE   	(49					) 	//
			)
			iodelay_deser_clkp_inst (
			// required datapath
			.IDATAIN  				(clk_p_ibufgds		),	//data from primary IOB
			.DATAOUT  				(clk_p_delay		),	//Output data 1 to ILOGIC/ISERDES2
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

			IODELAY2 # (
			.DATA_RATE      		("SDR"				),	//<SDR>, DDR
			.IDELAY_VALUE  			(0					),	//{0 ... 255}
			.IDELAY_TYPE   			("FIXED"			),	//"DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
			.COUNTER_WRAPAROUND 	("WRAPAROUND"		),	//<STAY_AT_LIMIT>, WRAPAROUND
			.DELAY_SRC     			("IDATAIN" 			),	//"IO", "IDATAIN", "ODATAIN"
			.SERDES_MODE   			("SLAVE"			),	//<NONE>, MASTER, SLAVE
			.SIM_TAPDELAY_VALUE   	(49					) 	//
			)
			iodelay_deser_clkn_inst (
			// required datapath
			.IDATAIN  				(clk_n_ibufgds		),	//data from primary IOB
			.DATAOUT  				(clk_n_delay		),	//Output data 1 to ILOGIC/ISERDES2
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
		end
		else if(SER_DATA_RATE=="SDR") begin
			IODELAY2 # (
			.DATA_RATE      		("SDR"				),	//<SDR>, DDR
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
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	ref 通过bufio2，驱动高速io时钟和慢速恢复时钟
	//	-------------------------------------------------------------------------------------
	generate
		if(SER_DATA_RATE=="DDR") begin
			//  -------------------------------------------------------------------------------------
			//  BUFIO2_2CLK 首先会对时钟做2倍频
			//  -------------------------------------------------------------------------------------
			BUFIO2_2CLK # (
			.DIVIDE					(DESER_WIDTH		)	//{3..8}
			)
			bufio2_2clk_deser_clk_inst
			(
			.I						(clk_p_delay		),	// Input source clock 0 degrees
			.IB						(clk_n_delay		),	// Input source clock 180 degrees
			.IOCLK					(clk_io				),	// Output Clock for IO
			.DIVCLK					(clk_div			),	// Output Divided Clock
			.SERDESSTROBE			(serdesstrobe		)	// Output SERDES strobe (Clock Enable)
			);

			// also generated the inverted clock
			BUFIO2 # (
			.DIVIDE_BYPASS 			("FALSE"			),
			.I_INVERT      			("FALSE"			),
			.USE_DOUBLER   			("FALSE"			),
			.DIVIDE        			(DESER_WIDTH		)
			)
			bufio2_inv_deser_clk_inst (
			.I            			(clk_n_delay		),
			.DIVCLK        			(					),
			.IOCLK        			(clk_io_inv			),
			.SERDESSTROBE 			(					)
			);
		end
		else if(SER_DATA_RATE=="SDR") begin
			BUFIO2 # (
			.DIVIDE_BYPASS 			("FALSE"			),
			.I_INVERT      			("FALSE"			),
			.USE_DOUBLER   			("FALSE"			),
			.DIVIDE        			(DESER_WIDTH		)
			)
			bufio2_deser_clk_inst (
			.I            			(clk_delay			),
			.DIVCLK        			(clk_div			),
			.IOCLK        			(clk_io				),
			.SERDESSTROBE 			(serdesstrobe		)
			);
			assign	clk_io_inv	= 1'b0;
		end
	endgenerate

	//  -------------------------------------------------------------------------------------
	//  ref BUFG 驱动慢速恢复时钟
	//  -------------------------------------------------------------------------------------
	BUFG bufg_recover_inst (
	.I			(clk_div			),	//随路串行时钟产生的并行数据时钟
	.O			(clk_recover		)
	);


endmodule
