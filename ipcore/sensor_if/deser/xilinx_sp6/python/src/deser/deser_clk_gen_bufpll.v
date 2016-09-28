
//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : deser_clk_gen_bufpll.v
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  --�޸ļ�¼  :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//---------------------------------------------------------------------------------------
//  -- ��       	:| 02/25/2013			:|  ��ʼ�汾
//  -- �Ϻ���      	:| 2015/9/18 11:26:17	:|	���¹滮�⴮ʱ��ģ��
//  -- �Ϻ���      	:| 2016/3/1 11:02:14	:|	��� localparam ���������ʱ��Ƶ�ʹ��͵�����
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
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module  deser_clk_gen_bufpll # (
	parameter	DIFF_TERM				= "TRUE"			,	//Differential Termination
	parameter	IOSTANDARD				= "LVDS_33"			,	//Specifies the I/O standard for this buffer
	parameter	SER_DATA_RATE			= "DDR"				,	//"DDR" or "SDR" �������ݵĲ�����ʽ
	parameter	DESER_WIDTH				= 6					,	//ÿ��ͨ���⴮��� 2-8
	parameter	CLKIN_PERIOD_PS			= 3030					//����ʱ��Ƶ�ʣ�PSΪ��λ��ֻ��BUFPLL��ʽ�����á�
	)
	(
	input						reset				,	//����Ч��λ
	input						clkin_p				,	//����ʱ��
	input                       clkin_n				,   //����ʱ��
	output						clk_recover			,	//�ָ���������ʱ��
	output						clk_io				,	//���ٴ���ʱ��
	output						serdesstrobe		,	//iserdesʹ��
	output						bufpll_lock				//���BUFPLL�������ź�
	);
	//	ref signals

	//	-------------------------------------------------------------------------------------
	//	�������ʱ����DDR�ķ�ʽ����Ҫ������ʱ�ӱ�Ƶ
	//	-------------------------------------------------------------------------------------
	localparam		CLKFBOUT_MULT	= (SER_DATA_RATE=="DDR") ? 2 : 1;
	localparam		CLKIN_PERIOD_NS	= CLKIN_PERIOD_PS/1000.0;

	//	-------------------------------------------------------------------------------------
	//	VCO�ļ��㷽�������֣����շ����ķ�ʽ������
	//
	//	1.����ʱ����CLKOUT0
	//	fVCO		= (fIN �� CLKFBOUT_MULT �� CLKOUT0_DIVIDE)/DIVCLK_DIVIDE
	//
	//	2.����ʱ����CLKFB
	//	fVCO	= (fIN �� CLKFBOUT_MULT)/DIVCLK_DIVIDE
	//
	//	3.�������ַ�����ʽ�����ʱ��ֻ��fVCO�͸��Եķ�Ƶϵ����أ����� fCLKOUT0
	//	fCLKOUT0	= fVCO/CLKOUT0_DIVIDE
	//
	//	4.���⴮ģ�����ʹ��CLKOUT0�ķ�����ʽ
	//
	//	-------------------------------------------------------------------------------------
	//	PLL��VCOʱ�ӵ�Ƶ�ʷ�Χ�� 400.000000 - 1000.000000 MHz��
	//	1.��������ʱ��С��200MHz������2��Ƶ֮�󣬻����޷������������400MHz����˾���Ҫ�����2��Ƶ
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
	//  ref ���ʱ������
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
	//  ref ʱ����ʱ
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
	//  ref iserdes ����
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
	//  ref pll ��������ioʱ�Ӻ����ٻָ�ʱ��
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
	//  BUFPLL ��������ioʱ��
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
	//  BUFIO2FB ����
	//  -------------------------------------------------------------------------------------
	BUFIO2FB # (
	.DIVIDE_BYPASS	("TRUE"		)	// Bypass divider (TRUE/FALSE)
	)
	BUFIO2FB_pll_fb_inst (
	.I		(feedback	),	// 1-bit input: Feedback clock input (connect to input port)
	.O		(clk_fb		)	// 1-bit output: Output feedback clock (connect to feedback input of DCM/PLL)
	);

	//  -------------------------------------------------------------------------------------
	//  ref BUFG �������ٻָ�ʱ��
	//  -------------------------------------------------------------------------------------
	BUFG bufg_recover_inst (
	.I		(pllout_x1		),//��·����ʱ�Ӳ����Ĳ�������ʱ��
	.O		(clk_recover	)
	);

endmodule