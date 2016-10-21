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
	//	spi master parameter
	//	-------------------------------------------------------------------------------------
	parameter	SPI_FIRST_DATA		= "MSB"		;	//"MSB" or "LSB"
	parameter	SPI_CS_POL			= "LOW"		;	//"HIGH" or "LOW" ，cs有效时的电平
	parameter	SPI_LEAD_TIME		= 1			;	//开始时，CS 与 CLK 的距离，单位是时钟周期，可选 1 2 3
	parameter	SPI_LAG_TIME		= 1			;	//结束时，CS 与 CLK 的距离，单位是时钟周期，可选 1 2 3
	parameter	SPI_DEBUG			= 0			;	//是否输出打印信息

	//	-------------------------------------------------------------------------------------
	//	dut paramter
	//	-------------------------------------------------------------------------------------
	//	-------------------------------------------------------------------------------------
	//	Sensor相关参数
	//	-------------------------------------------------------------------------------------
	parameter	SENSOR_DAT_WIDTH			= 12					;	//Sensor 数据宽度
	parameter	PHY_NUM						= 2						;	//HiSPi PHY的数量
	parameter	PHY_CH_NUM					= 4						;	//每路HiSPi PHY的数据通道数
	parameter	PIX_CLK_FREQ_KHZ			= 55000					;	//像素时钟频率，单位KHZ，很多模块用该时钟作为定时器，因此必须写明像素时钟的频率
	parameter	BAYER_PATTERN				= "GR"					;	//"GR" "RG" "GB" "BG"
	parameter	SENSOR_MAX_WIDTH			= 4912					;	//Sensor最大的行有效宽度，以像素时钟为单位
	parameter	SENSOR_MAX_HEIGHT			= 3684					;	//Sensor最大的有效行个数，以行为单位
	parameter	SHORT_LINE_LENGTH_PCK		= 5568					;	//Sensor行周期
	//	-------------------------------------------------------------------------------------
	//	解串相关的参数
	//	-------------------------------------------------------------------------------------
	parameter	DIFF_TERM					= "TRUE"				;	//Differential Termination
	parameter	IOSTANDARD					= "LVDS_33"				;	//Specifies the I/O standard for this buffer
	parameter	SER_FIRST_BIT				= "LSB"					;	//"LSB" or "MSB" , first bit to the receiver
	parameter	END_STYLE					= "LITTLE"				;	//"LITTLE" or "BIG" , "LITTLE" - {CHANNEL3 CHANNE2 CHANNEL1 CHANNEL0}. "BIG" - {CHANNEL0 CHANNEL1 CHANNEL2 CHANNEL3}.
	parameter	SER_DATA_RATE				= "DDR"					;	//"DDR" or "SDR" 输入的串行时钟采样方式
	parameter	DESER_CLOCK_ARC				= "BUFIO2"				;	//"BUFPLL" or "BUFIO2" , deserializer clock achitecture
	parameter	DESER_WIDTH					= 6						;	//每个通道解串宽度 2-8
	parameter	CLKIN_PERIOD_PS				= 3030					;	//输入时钟频率，PS为单位。只在BUFPLL方式下有用。
	parameter	DATA_DELAY_TYPE				= "DIFF_PHASE_DETECTOR"	;	//"DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
	parameter	DATA_DELAY_VALUE			= 0						;	//0-255，最大不能超过 1 UI
	parameter	BITSLIP_ENABLE				= "FALSE"				;	//"TRUE" "FALSE" iserdes 字边界对齐功能
	parameter	PLL_RESET_SIMULATION		= "TRUE"				;	//解串PLL复位，使能仿真模式，复位时间变短，加速仿真
	//	-------------------------------------------------------------------------------------
	//	DDR3的参数
	//	-------------------------------------------------------------------------------------
	parameter	NUM_DQ_PINS					= 16 				;	//DDR3数据宽度
	parameter	MEM_ADDR_WIDTH				= 13 				;	//DDR3地址宽度
	parameter	MEM_BANKADDR_WIDTH			= 3  				;	//DDR3bank宽度
	parameter	DDR3_MEMCLK_FREQ			= 320				;	//DDR3时钟频率
	parameter	MEM_ADDR_ORDER				= "ROW_BANK_COLUMN"	;	//DDR3地址排布顺序
	parameter 	DDR3_RST_ACT_LOW          	= 0					;   // # = 1 for active low reset,# = 0 for active high reset.
	parameter	DDR3_MEM_DENSITY			= "1Gb"				;	//DDR3容量
	parameter	DDR3_TCK_SPEED				= "15E"				;	//DDR3的速度等级
	parameter	DDR3_SIMULATION				= "TRUE"			;	//打开仿真可以加速仿真速度，但是实际布局布线时，不能打开仿真。
	parameter	DDR3_P0_MASK_SIZE			= 8					;	//p0口mask size
	parameter	DDR3_P1_MASK_SIZE			= 8					;	//p1口mask size
	parameter	DDR3_CALIB_SOFT_IP			= "FALSE"			;	//仿真时，可以不使能校准逻辑
	//	-------------------------------------------------------------------------------------
	//	GPIF引脚位宽
	//	-------------------------------------------------------------------------------------
	parameter	GPIF_DAT_WIDTH				= 32				;	//GPIF数据宽度
	//	-------------------------------------------------------------------------------------
	//	GPIO输入引脚位宽，用于触发
	//	-------------------------------------------------------------------------------------
	parameter	NUM_GPIO					= 2					;	//GPIO个数
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
	//	spi master signal
	//	-------------------------------------------------------------------------------------
	parameter	CLK_PERIOD_SPI			= 100	;	//时钟频率，10MHz

	wire								spi_master_i_spi_miso	;
	wire								spi_master_clk_fifo	;
	wire								spi_master_reset_fifo	;
	reg									spi_master_spi_clk	= 1'b0;

	wire								i_usb_spi_sck	;
	wire								i_usb_spi_mosi	;
	wire								i_spi_cs_n_fpga	;

	//	-------------------------------------------------------------------------------------
	//	dut signal
	//	-------------------------------------------------------------------------------------
	parameter	CLK_PERIOD				= 25	;	//时钟频率，40MHz
	reg									clk_osc			= 1'b0;

	wire	[PHY_NUM-1:0]				pix_clk_p					;
	wire	[PHY_NUM-1:0]				pix_clk_n					;
	wire	[PHY_CH_NUM*PHY_NUM-1:0]	iv_pix_data_p				;
	wire	[PHY_CH_NUM*PHY_NUM-1:0]	iv_pix_data_n				;

	reg									i_sensor_strobe	= 1'b0;
	reg									i_optocoupler	= 1'b0;
	reg		[NUM_GPIO-1:0]				iv_gpio	= 'b0;
	reg									i_flash_hold	= 1'b0;

	//	-------------------------------------------------------------------------------------
	//	testbench signal
	//	-------------------------------------------------------------------------------------
	wire	[15:0]			senor_active_width	;
	wire	[15:0]			senor_blank_width	;
	wire	[15:0]			senor_active_height	;
	wire	[15:0]			senor_blank_height	;

	wire	[1:0]			pixel_byte	;
	wire	[7:0]			leader_size	;
	wire	[7:0]			trailer_size	;
	wire	[31:0]			payload_size	;
	wire	[31:0]			si_payload_transfer_size	;
	wire	[31:0]			si_payload_transfer_count	;
	wire	[31:0]			si_payload_final_transfer1_size	;
	wire	[31:0]			si_payload_final_transfer2_size	;

	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***tb 子模块激励***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	--ref Sensor
	//	-------------------------------------------------------------------------------------
	assign	hispi_clk_in	= harness.mer_1810_21u3x_inst.clock_reset_inst.clk_sensor;

	initial begin
		hispi_sensor_reset_n	= 1'b0;
		#200;
		hispi_sensor_reset_n	= 1'b1;
	end

//	assign	hispi_active_width		= senor_active_width/4+4	;	//	4608/4=1152
	assign	hispi_active_width		= (senor_active_width/2)/4+4	;	//	4608/4=1152
	assign	hispi_blank_width		= (senor_blank_width/2)/4-4		;
	assign	hispi_active_height		= senor_active_height[11:0]	;
	assign	hispi_blank_height		= senor_blank_height[11:0]	;

	//	-------------------------------------------------------------------------------------
	//	--ref SPI master
	//	-------------------------------------------------------------------------------------
	assign	spi_master_i_spi_miso	= harness.o_usb_spi_miso;
	assign	spi_master_clk_fifo		= spi_master_spi_clk;
	assign	spi_master_reset_fifo	= 1'b0;
	always	#(CLK_PERIOD_SPI/2.0)	spi_master_spi_clk	= !spi_master_spi_clk;

	assign	i_usb_spi_sck			= driver_spi_master.o_spi_clk;
	assign	i_usb_spi_mosi			= driver_spi_master.o_spi_mosi;
	assign	i_spi_cs_n_fpga			= driver_spi_master.o_spi_cs;

	//	-------------------------------------------------------------------------------------
	//	--ref DUT
	//	-------------------------------------------------------------------------------------
	always	#(CLK_PERIOD/2.0)		clk_osc		= !clk_osc;

	assign	pix_clk_p				= {driver_hispi.sclk_o,driver_hispi.sclk_o};
	assign	pix_clk_n				= {~driver_hispi.sclk_o,~driver_hispi.sclk_o};
	assign	iv_pix_data_p			= {driver_hispi.sdata_o,driver_hispi.sdata_o};
	assign	iv_pix_data_n			= {~driver_hispi.sdata_o,~driver_hispi.sdata_o};

	//	-------------------------------------------------------------------------------------
	//	--ref testbench
	//	-------------------------------------------------------------------------------------
	assign	senor_active_width		= 16'd4912	;
	assign	senor_blank_width		= 16'd658;
	assign	senor_active_height		= 16'd16	;
	assign	senor_blank_height		= 16'd4	;

	assign	pixel_byte				= 1;
	assign	leader_size				= 52;
	assign	trailer_size			= 32;
	assign	payload_size			= senor_active_width*senor_active_height*pixel_byte;

	assign	si_payload_transfer_size	= 31'd1048576;		//1Mbyte
	assign	si_payload_transfer_count	= payload_size/1048576;
	assign	si_payload_final_transfer1_size	= (payload_size-si_payload_transfer_count*1048576)/1024;
	assign	si_payload_final_transfer2_size	= 31'd1024;

	//	===============================================================================================
	//	ref ***调用bfm task***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	--ref spi 操作
	//	-------------------------------------------------------------------------------------
	initial begin

//		wait(harness.mer_1520_13u3x_inst.clock_reset_inst.dcm100_locked==1'b1)
		#10000

		harness.bfm_spi_cmd.wr_dna(64'h4702_2000_00000220);

		harness.bfm_spi_cmd.wr_sensor_init_done;
		harness.bfm_spi_cmd.wr_roi(0,0,senor_active_width,senor_active_height);
		harness.bfm_spi_cmd.wr_payload_size(payload_size);
		if(pixel_byte==1) begin
			harness.bfm_spi_cmd.wr_pixel_format_gr8;
		end
		else begin
			harness.bfm_spi_cmd.wr_pixel_format_gr12;
		end
		harness.bfm_spi_cmd.wr_si_size(si_payload_transfer_size,si_payload_transfer_count,
		si_payload_final_transfer1_size,si_payload_final_transfer2_size);
		harness.bfm_spi_cmd.wr_group_en;
		harness.bfm_spi_cmd.set_transit_on;
		#500000
		$stop;
	end






endmodule
