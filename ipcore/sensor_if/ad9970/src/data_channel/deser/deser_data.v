//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : deser_data
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/9/18 11:22:42	:|  ��ʼ�汾
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

module deser_data # (
	parameter	SER_FIRST_BIT			= "LSB"				,	//"LSB" or "MSB" , first bit to the receiver
	parameter	END_STYLE				= "LITTLE"			,	//"LITTLE" or "BIG" , "LITTLE" - {CHANNEL3 CHANNE2 CHANNEL1 CHANNEL0}. "BIG" - {CHANNEL0 CHANNEL1 CHANNEL2 CHANNEL3}.
	parameter	SER_DATA_RATE			= "DDR"				,	//"DDR" or "SDR" ����Ĵ���ʱ�Ӳ�����ʽ
	parameter	CHANNEL_NUM				= 4					,	//���ͨ������
	parameter	DESER_WIDTH				= 6					,	//ÿ��ͨ���⴮��� 2-8
	parameter	DATA_DELAY_TYPE			= "DIFF_PHASE_DETECTOR"	,	//"DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
	parameter	DATA_DELAY_VALUE		= 0					,	//0-255������ܳ��� 1 UI
	parameter	BITSLIP_ENABLE			= "TRUE"				//"TRUE" "FALSE" iserdes �ֱ߽���빦��
	)
	(
	//	-------------------------------------------------------------------------------------
	//	��ִ�������
	//	-------------------------------------------------------------------------------------
	input		[CHANNEL_NUM-1:0]					iv_data_p			,	//�����������
	input		[CHANNEL_NUM-1:0]					iv_data_n			,	//�����������
	//	-------------------------------------------------------------------------------------
	//	�⴮����ʱ��
	//	-------------------------------------------------------------------------------------
	input											clk_io				,	//���ٴ���ʱ��
	input											clk_io_inv			,	//���ٴ���ʱ�ӣ�����
	//	-------------------------------------------------------------------------------------
	//	�����ź�
	//	-------------------------------------------------------------------------------------
	input											serdesstrobe		,	//iserdesʹ��
	input		[CHANNEL_NUM-1:0]					iv_bitslip			,	//�ֽڱ߽�������ÿ����������λһ��
	//	-------------------------------------------------------------------------------------
	//	�⴮�ָ�ʱ�Ӻ�����
	//	-------------------------------------------------------------------------------------
	input											clk_recover			,	//�ָ�����ʱ��
	input											reset_recover		,	//�ָ�����ʱ�Ӹ�λ�ź�
	output		[CHANNEL_NUM*DESER_WIDTH-1:0]		ov_data_recover			//�ָ����Ĳ������ݣ�����clk_recoverʱ����
	);

	//	ref signals
	wire	[CHANNEL_NUM-1:0]			data_ibufds		;
	wire	[CHANNEL_NUM-1:0]			data_delay_m	;
	wire	[CHANNEL_NUM-1:0]			data_delay_s	;

	// local wire only for use in this generate loop
	wire 	[CHANNEL_NUM-1:0]			icascade		;
	wire	[7:0]						iserdes_q[CHANNEL_NUM-1:0]	;			//ÿ��ͨ����λ����8bit��һ���� CHANNEL_NUM ��ͨ��
	wire	[DESER_WIDTH-1:0]			data_recover_array[CHANNEL_NUM-1:0]	;	//ÿ��ͨ����λ����DESER_WIDTH bit��һ���� CHANNEL_NUM ��ͨ��

	wire 	[CHANNEL_NUM-1:0]			pd_edge			;
	wire 	[CHANNEL_NUM-1:0]			pd_busy			;
	wire 	[CHANNEL_NUM-1:0]			pd_data_inc		;
	wire 	[CHANNEL_NUM-1:0]			pd_data_ce		;
	wire 								pd_cal_master	;
	wire 								pd_cal_slave	;
	wire 								pd_cal_rst		;
	wire 	[CHANNEL_NUM-1:0]			pd_valid		;
	wire 	[CHANNEL_NUM-1:0]			pd_inc_dec		;

	//	ref ARCHITECTURE


	genvar ch_cnt;
	genvar bit_cnt;
	generate

		for (ch_cnt=0;ch_cnt<CHANNEL_NUM;ch_cnt=ch_cnt+1)	begin: channel
			//  -------------------------------------------------------------------------------------
			//  ʵ������IBUFDSģ��
			//  -------------------------------------------------------------------------------------
			IBUFDS ibufds_inst (
			.I		(iv_data_p[ch_cnt]		),
			.IB		(iv_data_n[ch_cnt]		),
			.O		(data_ibufds[ch_cnt]	)
			);

			//  -------------------------------------------------------------------------------------
			//  ref idelay ģ������
			//  ʵ������IODELAY2 masterģ��
			//  -------------------------------------------------------------------------------------
			IODELAY2 # (
			.DATA_RATE      		(SER_DATA_RATE				),	// <SDR>, DDR
			.IDELAY_VALUE  			(0							),	// {0 ... 255}
			.IDELAY_TYPE   			(DATA_DELAY_TYPE			),	// "DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
			.COUNTER_WRAPAROUND 	("WRAPAROUND"				),	// <STAY_AT_LIMIT>, WRAPAROUND
			.DELAY_SRC     			("IDATAIN" 					),	// "IO", "IDATAIN", "ODATAIN"
			.SERDES_MODE   			("MASTER"					),	// <NONE>, MASTER, SLAVE
			.SIM_TAPDELAY_VALUE   	(49							) 	//
			)
			iodelay_m (
			.IDATAIN  				(data_ibufds[ch_cnt]		),	// data from primary IOB
			.TOUT     				(							),	// tri-state signal to IOB
			.DOUT     				(							),	// output data to IOB
			.T        				(1'b1						),	// tri-state control from OLOGIC/OSERDES2
			.ODATAIN  				(1'b0						),	// data from OLOGIC/OSERDES2
			.DATAOUT  				(data_delay_m[ch_cnt]		),	// Output data 1 to ILOGIC/ISERDES2
			.DATAOUT2 				(							),	// Output data 2 to ILOGIC/ISERDES2
			.IOCLK0                 (clk_io						),	// High speed clock for calibration for SDR/DDR
			.IOCLK1                 (clk_io_inv					),	// High speed clock for calibration for DDR
			.CLK                    (clk_recover				),	// Fabric clock for control signals
			.CAL      				(pd_cal_master				),	// Calibrate control signal
			.INC      				(pd_data_inc[ch_cnt]		),	// Increment counter
			.CE       				(pd_data_ce[ch_cnt]			),	// Clock Enable
			.RST      				(pd_cal_rst					),	// Reset delay line
			.BUSY      				(							) 	// output signal indicating sync circuit has finished / calibration has finished
			);

			//  -------------------------------------------------------------------------------------
			//  ʵ������IODELAY2 slaveģ��
			//  -------------------------------------------------------------------------------------
			IODELAY2 # (
			.DATA_RATE      		(SER_DATA_RATE				),	// <SDR>, DDR
			.IDELAY_VALUE  			(0							),	// {0 ... 255}
			.IDELAY_TYPE   			(DATA_DELAY_TYPE			),	// "DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
			.COUNTER_WRAPAROUND 	("WRAPAROUND"				),	// <STAY_AT_LIMIT>, WRAPAROUND
			.DELAY_SRC     			("IDATAIN" 					),	// "IO", "IDATAIN", "ODATAIN"
			.SERDES_MODE   			("SLAVE"					),	// <NONE>, MASTER, SLAVE
			.SIM_TAPDELAY_VALUE   	(49							) 	//
			)
			iodelay_s (
			.IDATAIN 				(data_ibufds[ch_cnt]		),	// data from primary IOB
			.TOUT     				(							),	// tri-state signal to IOB
			.DOUT     				(							),	// output data to IOB
			.T        				(1'b1						),	// tri-state control from OLOGIC/OSERDES2
			.ODATAIN  				(1'b0						),	// data from OLOGIC/OSERDES2
			.DATAOUT  				(data_delay_s[ch_cnt]		),	// Output data 1 to ILOGIC/ISERDES2
			.DATAOUT2 				(							),	// Output data 2 to ILOGIC/ISERDES2
			.IOCLK0                 (clk_io						),	// High speed clock for calibration for SDR/DDR
			.IOCLK1                 (clk_io_inv					),	// High speed clock for calibration for DDR
			.CLK            		(clk_recover				),	// Fabric clock for control signals
			.CAL      				(pd_cal_slave				),	// Calibrate control signal
			.INC      				(pd_data_inc[ch_cnt]		),	// Increment counter
			.CE       				(pd_data_ce[ch_cnt]			),	// Clock Enable
			.RST      				(pd_cal_rst					),	// Reset delay line
			.BUSY      				(pd_busy[ch_cnt]			) 	// output signal indicating sync circuit has finished / calibration has finished
			);

			//  -------------------------------------------------------------------------------------
			//  ref iserdes ģ������
			//  ʵ������ISERDES2 masterģ��
			//  -------------------------------------------------------------------------------------
			ISERDES2 # (
			.BITSLIP_ENABLE 		(BITSLIP_ENABLE				),
			.DATA_RATE      		(SER_DATA_RATE				),
			.DATA_WIDTH     		(DESER_WIDTH				),
			.INTERFACE_TYPE 		("RETIMED"					),
			.SERDES_MODE    		("MASTER"					)
			) iserdes2_master (
			.Q4         			(iserdes_q[ch_cnt][0]		),
			.Q3         			(iserdes_q[ch_cnt][1]		),
			.Q2         			(iserdes_q[ch_cnt][2]		),
			.Q1         			(iserdes_q[ch_cnt][3]		),
			.SHIFTOUT   			(icascade[ch_cnt]			),	// 1-bit Cascade out signal for Master/Slave IO. In Phase Detector mode used to
			// send slave sampled data
			.INCDEC     			(pd_inc_dec[ch_cnt]			),	// 1-bit Output of Phase Detector (Dummy in slave)
			.VALID      			(pd_valid[ch_cnt]			),	// 1-bit Output of Phase Detector (Dummy in Slave). If the input data contains no
			// edges (no info for the phase detector to work with) the VALID signal will go
			// LOW to indicate that the fabric should ignore the INCDEC signal.
			.BITSLIP    			(iv_bitslip[ch_cnt]			),	// 1-bit Invoke Bitslip. This can be used with any DATA_WIDTH, cascaded or not.
			// The amount of bitslip is fixed by the DATA_WIDTH selection.
			.CE0        			(!reset_recover				),	// 1-bit Clock enable input
			.CLK0       			(clk_io						),	// 1-bit IO Clock network input. Optionally Invertible. This is the primary clock
			// input used when the clock doubler circuit is not engaged (see DATA_RATE attribute).
			.CLK1                 	(clk_io_inv					),	// 1-bit Optionally invertible IO Clock network input. Timing note: CLK1 should be 180 degrees out of phase with CLK0.
			.CLKDIV     			(clk_recover				),	// 1-bit Global clock network input. This is the clock for the fabric domain.
			.D          			(data_delay_m[ch_cnt]		),	// 1-bit Input signal from IOB.
			.IOCE       			(serdesstrobe				),	// 1-bit Data strobe signal derived from BUFIO CE. Strobes data capture for
			// NETWORKING and NETWORKING_PIPELINES alignment modes.
			.RST        			(reset_recover				),	// 1-bit Asynchronous reset only.
			.SHIFTIN    			(pd_edge[ch_cnt]			),
			// unused connections
			.FABRICOUT  			(),
			.CFB0       			(),
			.CFB1       			(),
			.DFB        			()
			);

			//  -------------------------------------------------------------------------------------
			//  ʵ������ISERDES2 slaveģ��
			//  -------------------------------------------------------------------------------------
			ISERDES2 # (
			.BITSLIP_ENABLE 		(BITSLIP_ENABLE				),
			.DATA_RATE      		(SER_DATA_RATE				),
			.DATA_WIDTH     		(DESER_WIDTH				),
			.INTERFACE_TYPE 		("RETIMED"					),
			.SERDES_MODE    		("SLAVE"					)
			) iserdes2_slave (
			.Q4         			(iserdes_q[ch_cnt][4]		),
			.Q3         			(iserdes_q[ch_cnt][5]		),
			.Q2         			(iserdes_q[ch_cnt][6]		),
			.Q1         			(iserdes_q[ch_cnt][7]		),
			.INCDEC     			(							),	// 1-bit Output of Phase Detector (Dummy in slave)
			.SHIFTOUT   			(pd_edge[ch_cnt]			),	// 1-bit Cascade out signal for Master/Slave IO. In Phase Detector mode used to
			// send slave sampled data.
			.VALID      			(							),	// 1-bit Output of Phase Detector (Dummy in Slave). If the input data contains no
			// edges (no info for the phase detector to work with) the VALID signal will go
			// LOW to indicate that the fabric should ignore the INCDEC signal.
			.BITSLIP    			(iv_bitslip[ch_cnt]			),	// 1-bit Invoke Bitslip. This can be used with any DATA_WIDTH, cascaded or not.
			// The amount of bitslip is fixed by the DATA_WIDTH selection.
			.CE0        			(!reset_recover				),	// 1-bit Clock enable input
			.CLK0       			(clk_io						),	// 1-bit IO Clock network input. Optionally Invertible. This is the primary clock
			// input used when the clock doubler circuit is not engaged (see DATA_RATE attribute).
			.CLK1                 	(clk_io_inv					),	// 1-bit Optionally invertible IO Clock network input. Timing note: CLK1 should be 180 degrees out of phase with CLK0.
			.CLKDIV     			(clk_recover				),	// 1-bit Global clock network input. This is the clock for the fabric domain.
			.D          			(data_delay_s[ch_cnt]		),	// 1-bit Input signal from IOB.
			.IOCE       			(serdesstrobe				),	// 1-bit Data strobe signal derived from BUFIO CE. Strobes data capture for
			// NETWORKING and NETWORKING_PIPELINES alignment modes.
			.RST        			(reset_recover				),	// 1-bit Asynchronous reset only.
			.SHIFTIN    			(icascade[ch_cnt]			),
			// unused connections
			.FABRICOUT  			(),
			.CFB0       			(),
			.CFB1       			(),
			.DFB        			()
			);

			//	-------------------------------------------------------------------------------------
			//	ref ����ƴ��
			//	-------------------------------------------------------------------------------------
			//	ISERDES �⴮��ʽ Q4 �������յ�������
			//	--iserdes_q������Ĭ�ϰ���MSB
			//	-------------------------------------------------------------------------------------
			//
			//		---ISERDES_MASTER---
			//	din-->		FF	-->	Q4	-->	iserdes_q[0]
			//					|
			//			---------
			//			|
			//			--	FF	-->	Q3	-->	iserdes_q[1]
			//					|
			//			---------
			//			|
			//			--	FF	-->	Q2	-->	iserdes_q[2]
			//					|
			//			---------
			//			|
			//			--	FF	-->	Q1	-->	iserdes_q[3]
			//					|
			//	-----------------
			//	|	cascade_out
			//	|
			//	|	---ISERDES_SLAVE---
			//	----->		FF	-->	Q4	-->	iserdes_q[4]
			//					|
			//			---------
			//			|
			//			--	FF	-->	Q3	-->	iserdes_q[5]
			//					|
			//			---------
			//			|
			//			--	FF	-->	Q2	-->	iserdes_q[6]
			//					|
			//			---------
			//			|
			//			--	FF	-->	Q1	-->	iserdes_q[7]
			//
			//	-------------------------------------------------------------------------------------
			//	MSB ��ʾ���Ͷ��ȷ������ݵĸ�bit,LSB ��ʾ���Ͷ��ȷ������ݵĵ�bit
			//	FOR EXAMPLE : 12 bit code 0xaaa, binary code is 101010101010
			//	--MSB :
			//		t0	t1	t2	t3	t4	t5	t6	t7	t8	t9	t10	t11
			//		1	0	1	0	1	0	1	0	1	0	1	0
			//	--LSB :			|					|
			//		t0	t1	t2	t3	t4	t5	t6	t7	t8	t9	t10	t11
			//		0	1	0	1	0	1	0	1	0	1	0	1
			//					|					|
			//					|--  6bit window  --|
			//
			//	������LSB����MSB�ķ��ͷ�ʽ�� data_recover_array �����з�ʽ���Ǹ�bit�ڸ�λ����bit�ڵ�λ
			//	��������6bit�����£�������MSB LSB ,  data_recover_array ��������� 6'b010101
			//
			//	-------------------------------------------------------------------------------------
			if(SER_FIRST_BIT=="MSB") begin
				assign	data_recover_array[ch_cnt][DESER_WIDTH-1:0]	= iserdes_q[ch_cnt][DESER_WIDTH-1:0];
			end
			else if(SER_FIRST_BIT=="LSB") begin
				for(bit_cnt=0;bit_cnt<DESER_WIDTH;bit_cnt=bit_cnt+1) begin
					assign	data_recover_array[ch_cnt][bit_cnt]	= iserdes_q[ch_cnt][DESER_WIDTH-bit_cnt-1];
				end
			end

			//	-------------------------------------------------------------------------------------
			//	��С�˶��뷽ʽ
			//	--deser data ģ�����ʱ�����е����ݶ�ƴ�ӵ�һ������������Ƿ�Ϊ����ͨ�����
			//	--�������ĺô���ͨ�����ı䣬����Ҫ�޸Ķ˿ڣ�ֻ��Ҫ�޸�λ��
			//	--���Ƕ��ͨ��ƴ�ӵ�һ����д�С�˵����⣬���"BIG"ָ���Ǹ�ͨ�����ڵ�byte��С��"LITTLE"ָ���ǵ�ͨ�����ڵ�byte��
			//	--ֵ��ע����ǣ������Ǵ�˻���С�ˣ�ÿ��ͨ���У����Ǹ�bit�ڸ�λ����bit�ڵ�λ
			//	-------------------------------------------------------------------------------------
			//	FOR EXAMPLE : 4 CHANNEL 8bit byte makes up an 32bit word
			//	--LITTLE ENDIAN ORDER :
			//			CH3 BYTE,CH2 BYTE,CH1 BYTE,CH0 BYTE
			//			|		 |		  |		   |	  |
			//		  bit31    bit23    bit15    bit7    bit0
			//
			//	--BIT ENDIAN ORDER :
			//			CH0 BYTE,CH1 BYTE,CH2 BYTE,CH3 BYTE
			//			|		 |		  |		   |	  |
			//		  bit31    bit23    bit15    bit7    bit0
			//
			//	-------------------------------------------------------------------------------------
			if(END_STYLE=="LITTLE") begin
				assign	ov_data_recover[(ch_cnt+1)*DESER_WIDTH-1:ch_cnt*DESER_WIDTH]	= data_recover_array[ch_cnt];
			end
			else if(END_STYLE=="BIG") begin
				assign	ov_data_recover[(ch_cnt+1)*DESER_WIDTH-1:ch_cnt*DESER_WIDTH]	= data_recover_array[CHANNEL_NUM-ch_cnt-1];
			end
		end

	endgenerate

	//  -------------------------------------------------------------------------------------
	//  ʵ������̬��λ��������ģ��
	//	phase_detector state machine ���Է�ʱ���ƶ�·����ͨ������ʱ�������Ļ������Խ�ʡ��Դ��
	//  -------------------------------------------------------------------------------------
	generate
		if(DATA_DELAY_TYPE=="DIFF_PHASE_DETECTOR") begin
			phase_detector # (
			.D					(CHANNEL_NUM		)	 //�ⲿ���������߿�
			)
			phase_detector_inst (
			.use_phase_detector	(1'b1				),
			.busy				(pd_busy			),
			.valid				(pd_valid			),
			.inc_dec			(pd_inc_dec			),
			.reset				(reset_recover		),	//����Ч��λ
			.gclk				(clk_recover		),	//����ʱ��
			.debug_in			(2'b00				),
			.debug				(					),
			.cal_master			(pd_cal_master		),
			.cal_slave			(pd_cal_slave		),
			.rst_out			(pd_cal_rst			),
			.ce					(pd_data_ce			),
			.inc				(pd_data_inc		)
			);
		end
		else begin
			assign	pd_cal_master	= 1'b0;
			assign	pd_cal_slave	= 1'b0;
			assign	pd_cal_rst		= 1'b0;
			assign	pd_data_ce		= {CHANNEL_NUM{1'b0}};
			assign	pd_data_inc		= {CHANNEL_NUM{1'b0}};
		end
	endgenerate

endmodule