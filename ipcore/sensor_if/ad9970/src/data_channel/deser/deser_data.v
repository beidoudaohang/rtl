//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : deser_data
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/9/18 11:22:42	:|  初始版本
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

module deser_data # (
	parameter	SER_FIRST_BIT			= "LSB"				,	//"LSB" or "MSB" , first bit to the receiver
	parameter	END_STYLE				= "LITTLE"			,	//"LITTLE" or "BIG" , "LITTLE" - {CHANNEL3 CHANNE2 CHANNEL1 CHANNEL0}. "BIG" - {CHANNEL0 CHANNEL1 CHANNEL2 CHANNEL3}.
	parameter	SER_DATA_RATE			= "DDR"				,	//"DDR" or "SDR" 输入的串行时钟采样方式
	parameter	CHANNEL_NUM				= 4					,	//差分通道个数
	parameter	DESER_WIDTH				= 6					,	//每个通道解串宽度 2-8
	parameter	DATA_DELAY_TYPE			= "DIFF_PHASE_DETECTOR"	,	//"DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
	parameter	DATA_DELAY_VALUE		= 0					,	//0-255，最大不能超过 1 UI
	parameter	BITSLIP_ENABLE			= "TRUE"				//"TRUE" "FALSE" iserdes 字边界对齐功能
	)
	(
	//	-------------------------------------------------------------------------------------
	//	差分串行数据
	//	-------------------------------------------------------------------------------------
	input		[CHANNEL_NUM-1:0]					iv_data_p			,	//差分数据输入
	input		[CHANNEL_NUM-1:0]					iv_data_n			,	//差分数据输入
	//	-------------------------------------------------------------------------------------
	//	解串高速时钟
	//	-------------------------------------------------------------------------------------
	input											clk_io				,	//高速串行时钟
	input											clk_io_inv			,	//高速串行时钟，反向
	//	-------------------------------------------------------------------------------------
	//	控制信号
	//	-------------------------------------------------------------------------------------
	input											serdesstrobe		,	//iserdes使用
	input		[CHANNEL_NUM-1:0]					iv_bitslip			,	//字节边界对齐命令，每次上升沿移位一次
	//	-------------------------------------------------------------------------------------
	//	解串恢复时钟和数据
	//	-------------------------------------------------------------------------------------
	input											clk_recover			,	//恢复慢速时钟
	input											reset_recover		,	//恢复慢速时钟复位信号
	output		[CHANNEL_NUM*DESER_WIDTH-1:0]		ov_data_recover			//恢复出的并行数据，属于clk_recover时钟域
	);

	//	ref signals
	wire	[CHANNEL_NUM-1:0]			data_ibufds		;
	wire	[CHANNEL_NUM-1:0]			data_delay_m	;
	wire	[CHANNEL_NUM-1:0]			data_delay_s	;

	// local wire only for use in this generate loop
	wire 	[CHANNEL_NUM-1:0]			icascade		;
	wire	[7:0]						iserdes_q[CHANNEL_NUM-1:0]	;			//每个通道的位宽是8bit，一共有 CHANNEL_NUM 个通道
	wire	[DESER_WIDTH-1:0]			data_recover_array[CHANNEL_NUM-1:0]	;	//每个通道的位宽是DESER_WIDTH bit，一共有 CHANNEL_NUM 个通道

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
			//  实例化：IBUFDS模块
			//  -------------------------------------------------------------------------------------
			IBUFDS ibufds_inst (
			.I		(iv_data_p[ch_cnt]		),
			.IB		(iv_data_n[ch_cnt]		),
			.O		(data_ibufds[ch_cnt]	)
			);

			//  -------------------------------------------------------------------------------------
			//  ref idelay 模块例化
			//  实例化：IODELAY2 master模块
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
			//  实例化：IODELAY2 slave模块
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
			//  ref iserdes 模块例化
			//  实例化：ISERDES2 master模块
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
			//  实例化：ISERDES2 slave模块
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
			//	ref 数据拼接
			//	-------------------------------------------------------------------------------------
			//	ISERDES 解串方式 Q4 是最后接收到的数据
			//	--iserdes_q的排序默认按照MSB
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
			//	MSB 表示发送端先发送数据的高bit,LSB 表示发送端先发送数据的低bit
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
			//	不管是LSB还是MSB的发送方式， data_recover_array 的排列方式都是高bit在高位，低bit在低位
			//	因此上面的6bit窗口下，无论是MSB LSB ,  data_recover_array 的输出都是 6'b010101
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
			//	大小端对齐方式
			//	--deser data 模块输出时把所有的数据都拼接到一起输出，而不是分为几个通道输出
			//	--这样做的好处是通道数改变，不需要修改端口，只需要修改位宽
			//	--但是多个通道拼接到一起就有大小端的问题，大端"BIG"指的是高通道放在低byte，小端"LITTLE"指的是低通道放在低byte。
			//	--值得注意的是，无论是大端还是小端，每个通道中，还是高bit在高位，低bit在低位
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
	//  实例化动态相位调整功能模块
	//	phase_detector state machine 可以分时控制多路数据通道的延时。这样的话，可以节省资源。
	//  -------------------------------------------------------------------------------------
	generate
		if(DATA_DELAY_TYPE=="DIFF_PHASE_DETECTOR") begin
			phase_detector # (
			.D					(CHANNEL_NUM		)	 //外部输入数据线宽
			)
			phase_detector_inst (
			.use_phase_detector	(1'b1				),
			.busy				(pd_busy			),
			.valid				(pd_valid			),
			.inc_dec			(pd_inc_dec			),
			.reset				(reset_recover		),	//高有效复位
			.gclk				(clk_recover		),	//并行时钟
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