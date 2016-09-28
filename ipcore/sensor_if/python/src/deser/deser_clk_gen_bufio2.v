
//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : deser_clk_gen_bufio2.v
//  -- �����       : ��
//-------------------------------------------------------------------------------------------------
//
//  --�޸ļ�¼  :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//---------------------------------------------------------------------------------------
//  -- ��       	:| 02/25/2013			:|  ��ʼ�汾
//  -- �Ϻ���      	:| 2015/9/18 13:29:02	:|	���¹滮�⴮ʱ��ģ��
//
//---------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module  deser_clk_gen_bufio2 # (
	parameter	SER_DATA_RATE			= "DDR"				,	//"DDR" or "SDR" �������ݵĲ�����ʽ
	parameter	DESER_WIDTH				= 6						//ÿ��ͨ���⴮��� 2-8
	)
	(
	input						clkin_p				,	//����ʱ��
	input                       clkin_n				,   //����ʱ��
	output						clk_recover			,	//�ָ���������ʱ��
	output						clk_io				,	//���ٴ���ʱ��
	output						clk_io_inv			,	//���ٴ���ʱ�ӣ�����DDR�ķ�ʽ���õ�
	output						serdesstrobe			//iserdesʹ��
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
	//  ref ���ʱ������
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
	//  ref ʱ����ʱ
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
	//	ref ͨ��bufio2����������ioʱ�Ӻ����ٻָ�ʱ��
	//	-------------------------------------------------------------------------------------
	generate
		if(SER_DATA_RATE=="DDR") begin
			//  -------------------------------------------------------------------------------------
			//  BUFIO2_2CLK ���Ȼ��ʱ����2��Ƶ
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
	//  ref BUFG �������ٻָ�ʱ��
	//  -------------------------------------------------------------------------------------
	BUFG bufg_recover_inst (
	.I			(clk_div			),	//��·����ʱ�Ӳ����Ĳ�������ʱ��
	.O			(clk_recover		)
	);


endmodule
