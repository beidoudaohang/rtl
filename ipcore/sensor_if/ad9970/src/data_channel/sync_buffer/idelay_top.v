//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : idelay_top
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/4/29 13:17:12	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : Sensor���Ž���������ʱģ��
//              1)  : ����ʹ����ʱ�����߲�ʹ����ʱ
//
//              2)  : ��ʱ��IOB �� idelay2 ģ����ʵ�֣���ʱ��ֵ����ͨ���������ݽ���
//
//              3)  : �����ʱģ�鲻ʹ�ܣ���ģ���൱��͸����������Ӱ��ʱ��
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module idelay_top # (
	parameter			SENSOR_DAT_WIDTH			= 10	,	//sensor ���ݿ��
	parameter			SENSOR_DAT_IDELAY_EN		= 1		,	//idelayʹ��
	parameter			SENSOR_DAT_IDELAY_VALUE		= 0			//idelay��ʱֵ
	)
	(
	input	[SENSOR_DAT_WIDTH-1:0]		iv_pix_data			,	//Sensorʱ����������������
	input								i_fval				,	//Sensorʱ�������볡��Ч
	input								i_lval				,	//Sensorʱ������������Ч
	output	[SENSOR_DAT_WIDTH-1:0]		ov_pix_data_delay	,	//Sensorʱ���򣬾���idelay��ʱ֮�����������
	output								o_fval_delay		,	//Sensorʱ���򣬾���idelay��ʱ֮��ĳ���Ч
	output								o_lval_delay			//Sensorʱ���򣬾���idelay��ʱ֮�������Ч
	);

	//	ref signals


	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***����ͨ������ʱ***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	sensor ���� idelay ��ʱ
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
	//	sensor fval idelay ��ʱ
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
	//	sensor lval idelay ��ʱ
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
