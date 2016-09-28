//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : testcase_1
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/4/10 16:50:28	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : ���ڴ�С��16x16�������ź���Ч������ģʽ�µ�����״��
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

module testcase_1 ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	TESTCASE
	//	-------------------------------------------------------------------------------------
	parameter	TESTCASE_NUM			= "testcase_1"			;	//����ģ����Ҫʹ���ַ���
	//	-------------------------------------------------------------------------------------
	//	sensor model parameter
	//	-------------------------------------------------------------------------------------
	parameter	HISPI_PLL_INCLK_PERIOD		= 50000	;	//����ʱ��Ƶ�ʣ���λ��ps
	parameter	HISPI_PLL_CLKOUT0_DIVIDE	= 1		;	//CLK0��Ƶ
	parameter	HISPI_PLL_CLKOUT1_DIVIDE	= 8		;	//CLK1��Ƶ
	parameter	HISPI_PLL_CLKOUT2_DIVIDE	= 8		;	//CLK2��Ƶ
	parameter	HISPI_PLL_CLKOUT3_DIVIDE	= 8		;	//CLK3��Ƶ
	parameter	HISPI_PLL_CLKOUT4_DIVIDE	= 8		;	//CLK4��Ƶ
	parameter	HISPI_PLL_CLKOUT5_DIVIDE	= 8		;	//CLK5��Ƶ
	parameter	HISPI_PLL_CLKFBOUT_MULT		= 33	;	//����ʱ�ӱ�Ƶ����
	parameter	HISPI_PLL_DIVCLK_DIVIDE		= 1		;	//��Ƶ����

	parameter HISPI_MODE 					= "Packetized-SP"	;	//"Packetized-SP" or "Streaming-SP" or "Streaming-S" or "ActiveStart-SP8"
	parameter HISPI_WORD_WIDTH				= 12	;
	parameter HISPI_LANE_WIDTH				= 4		;

	//	-------------------------------------------------------------------------------------
	//	dut paramter
	//	-------------------------------------------------------------------------------------
	parameter	SER_FIRST_BIT			= "LSB"					;	//"LSB" or "MSB" , first bit to the receiver
	parameter	END_STYLE				= "LITTLE"				;	//"LITTLE" or "BIG" , "LITTLE" - {CHANNEL3 CHANNE2 CHANNEL1 CHANNEL0}. "BIG" - {CHANNEL0 CHANNEL1 CHANNEL2 CHANNEL3}.
	parameter	SER_DATA_RATE			= "DDR"					;	//"DDR" or "SDR" ����Ĵ���ʱ�Ӳ�����ʽ
	parameter	DESER_CLOCK_ARC			= "BUFPLL"				;	//"BUFPLL" or "BUFIO2" , deserializer clock achitecture
	parameter	DESER_WIDTH				= 6						;	//ÿ��ͨ���⴮��� 2-8
	parameter	CLKIN_PERIOD_PS			= 3030					;	//����ʱ��Ƶ�ʣ�PSΪ��λ��ֻ��BUFPLL��ʽ�����á�
	parameter	DATA_DELAY_TYPE			= "DIFF_PHASE_DETECTOR"		;	//"WITHOUT_IDELAY" "DIFF_PHASE_DETECTOR" "FIXED"
	parameter	DATA_DELAY_VALUE		= 0						;	//0-255������ܳ��� 1 UI
	parameter	BITSLIP_ENABLE			= "FALSE"				;	//"TRUE" "FALSE" iserdes �ֱ߽���빦��
	parameter	CHANNEL_NUM				= 4						;	//��������ͨ������
	parameter	SENSOR_DAT_WIDTH		= 12					;	//Sensor ���ݿ��

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
	parameter	CLK_PERIOD				= 50	;	//ʱ��Ƶ�ʣ�20MHz
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
	//	ref ***tb ��ģ�鼤��***
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
