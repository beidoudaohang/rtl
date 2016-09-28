//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : idelay_top
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/4/29 13:17:12	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : Sensor引脚接收输入延时模块
//              1)  : 可以使能延时，或者不使能延时
//
//              2)  : 延时在IOB 的 idelay2 模块中实现，延时数值可以通过参数传递进来
//
//              3)  : 如果延时模块不使能，该模块相当于透传，并不会影响时序
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module idelay_top # (
	parameter			SENSOR_DAT_WIDTH			= 10	,	//sensor 数据宽度
	parameter			SENSOR_DAT_IDELAY_EN		= 1		,	//idelay使能
	parameter			SENSOR_DAT_IDELAY_VALUE		= 0			//idelay延时值
	)
	(
	input	[SENSOR_DAT_WIDTH-1:0]		iv_pix_data			,	//Sensor时钟域，输入像素数据
	input								i_fval				,	//Sensor时钟域，输入场有效
	input								i_lval				,	//Sensor时钟域，输入行有效
	output	[SENSOR_DAT_WIDTH-1:0]		ov_pix_data_delay	,	//Sensor时钟域，经过idelay延时之后的像素数据
	output								o_fval_delay		,	//Sensor时钟域，经过idelay延时之后的场有效
	output								o_lval_delay			//Sensor时钟域，经过idelay延时之后的行有效
	);

	//	ref signals


	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***数据通道的延时***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	sensor 数据 idelay 延时
	//  -------------------------------------------------------------------------------------
	genvar pin_count;
	generate
		if(SENSOR_DAT_IDELAY_EN == 1) begin
			for (pin_count = 0; pin_count < SENSOR_DAT_WIDTH; pin_count = pin_count + 1) begin
				IODELAY2 # (
				.DATA_RATE      		("SDR"							)	,// <SDR>, DDR
				.IDELAY_VALUE  			(SENSOR_DAT_IDELAY_VALUE		)	,// {0 ... 255}
				.IDELAY_TYPE   			("FIXED"						)	,// "DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
				.COUNTER_WRAPAROUND 	("STAY_AT_LIMIT"				)	,// <STAY_AT_LIMIT>, WRAPAROUND
				.DELAY_SRC     			("IDATAIN" 						)	,// "IO", "IDATAIN", "ODATAIN"
				.SERDES_MODE   			("NONE"							)	,// <NONE>, MASTER, SLAVE
				.SIM_TAPDELAY_VALUE   	(49								)	 //
				)
				iodelay_data_inst (
				.IDATAIN  				(iv_pix_data[pin_count]			)	,// data from primary IOB
				.TOUT     				(								)	,// tri-state signal to IOB
				.DOUT     				(								)	,// output data to IOB
				.T        				(1'b1							)	,// tri-state control from OLOGIC/OSERDES2
				.ODATAIN  				(1'b0							)	,// data from OLOGIC/OSERDES2
				.DATAOUT  				(ov_pix_data_delay[pin_count]	)	,// Output data 1 to ILOGIC/ISERDES2
				.DATAOUT2 				(								)	,// Output data 2 to ILOGIC/ISERDES2
				.IOCLK0                 (1'b0							)	,// High speed clock for calibration for SDR/DDR
				.IOCLK1                 (1'b0							)	,// High speed clock for calibration for DDR
				.CLK                    (1'b0							)	,// Fabric clock for control signals
				.CAL      				(1'b0							)	,// Calibrate control signal
				.INC      				(1'b0							)	,// Increment counter
				.CE       				(1'b0							)	,// Clock Enable
				.RST      				(1'b0							)	,// Reset delay line
				.BUSY      				(								)	 // output signal indicating sync circuit has finished / calibration has finished
				);
			end
		end
		else begin
			for (pin_count = 0; pin_count < SENSOR_DAT_WIDTH; pin_count = pin_count + 1) begin
				assign	ov_pix_data_delay[pin_count]	= iv_pix_data[pin_count];
			end
		end
	endgenerate

	//  -------------------------------------------------------------------------------------
	//	sensor fval idelay 延时
	//  -------------------------------------------------------------------------------------
	generate
		if(SENSOR_DAT_IDELAY_EN == 1) begin
			IODELAY2 # (
			.DATA_RATE      		("SDR"							)	,// <SDR>, DDR
			.IDELAY_VALUE  			(SENSOR_DAT_IDELAY_VALUE		)	,// {0 ... 255}
			.IDELAY_TYPE   			("FIXED"						)	,// "DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
			.COUNTER_WRAPAROUND 	("STAY_AT_LIMIT"				)	,// <STAY_AT_LIMIT>, WRAPAROUND
			.DELAY_SRC     			("IDATAIN" 						)	,// "IO", "IDATAIN", "ODATAIN"
			.SERDES_MODE   			("NONE"							)	,// <NONE>, MASTER, SLAVE
			.SIM_TAPDELAY_VALUE   	(49								)	 //
			)
			iodelay_vsync_inst (
			.IDATAIN  				(i_fval						)	,// data from primary IOB
			.TOUT     				(								)	,// tri-state signal to IOB
			.DOUT     				(								)	,// output data to IOB
			.T        				(1'b1							)	,// tri-state control from OLOGIC/OSERDES2
			.ODATAIN  				(1'b0							)	,// data from OLOGIC/OSERDES2
			.DATAOUT  				(o_fval_delay					)	,// Output data 1 to ILOGIC/ISERDES2
			.DATAOUT2 				(								)	,// Output data 2 to ILOGIC/ISERDES2
			.IOCLK0                 (1'b0							)	,// High speed clock for calibration for SDR/DDR
			.IOCLK1                 (1'b0							)	,// High speed clock for calibration for DDR
			.CLK                    (1'b0							)	,// Fabric clock for control signals
			.CAL      				(1'b0							)	,// Calibrate control signal
			.INC      				(1'b0							)	,// Increment counter
			.CE       				(1'b0							)	,// Clock Enable
			.RST      				(1'b0							)	,// Reset delay line
			.BUSY      				(								)	 // output signal indicating sync circuit has finished / calibration has finished
			);
		end
		else begin
			assign	o_fval_delay	= i_fval;
		end
	endgenerate

	//  -------------------------------------------------------------------------------------
	//	sensor lval idelay 延时
	//  -------------------------------------------------------------------------------------
	generate
		if(SENSOR_DAT_IDELAY_EN == 1) begin
			IODELAY2 # (
			.DATA_RATE      		("SDR"							)	,// <SDR>, DDR
			.IDELAY_VALUE  			(SENSOR_DAT_IDELAY_VALUE		)	,// {0 ... 255}
			.IDELAY_TYPE   			("FIXED"						)	,// "DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
			.COUNTER_WRAPAROUND 	("STAY_AT_LIMIT"				)	,// <STAY_AT_LIMIT>, WRAPAROUND
			.DELAY_SRC     			("IDATAIN" 						)	,// "IO", "IDATAIN", "ODATAIN"
			.SERDES_MODE   			("NONE"							)	,// <NONE>, MASTER, SLAVE
			.SIM_TAPDELAY_VALUE   	(49								)	 //
			)
			iodelay_href_inst (
			.IDATAIN  				(i_lval							)	,// data from primary IOB
			.TOUT     				(								)	,// tri-state signal to IOB
			.DOUT     				(								)	,// output data to IOB
			.T        				(1'b1							)	,// tri-state control from OLOGIC/OSERDES2
			.ODATAIN  				(1'b0							)	,// data from OLOGIC/OSERDES2
			.DATAOUT  				(o_lval_delay					)	,// Output data 1 to ILOGIC/ISERDES2
			.DATAOUT2 				(								)	,// Output data 2 to ILOGIC/ISERDES2
			.IOCLK0                 (1'b0							)	,// High speed clock for calibration for SDR/DDR
			.IOCLK1                 (1'b0							)	,// High speed clock for calibration for DDR
			.CLK                    (1'b0							)	,// Fabric clock for control signals
			.CAL      				(1'b0							)	,// Calibrate control signal
			.INC      				(1'b0							)	,// Increment counter
			.CE       				(1'b0							)	,// Clock Enable
			.RST      				(1'b0							)	,// Reset delay line
			.BUSY      				(								)	 // output signal indicating sync circuit has finished / calibration has finished
			);
		end
		else begin
			assign	o_lval_delay	= i_lval;
		end
	endgenerate





endmodule
