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
//  -- �Ϻ���       :| 2015/3/30 15:23:39	:|  ��ʼ�汾
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
//`timescale 1ns/1ps
`timescale 1ns/1ns
//-------------------------------------------------------------------------------------------------

module testcase_1 ();

	//	ref signals

	//	-------------------------------------------------------------------------------------
	//	TESTCASE
	//	-------------------------------------------------------------------------------------
	parameter	TESTCASE_NUM			= "testcase_1"			;	//����ģ����Ҫʹ���ַ���

	//	-------------------------------------------------------------------------------------
	//	sensor model parameter
	//	-------------------------------------------------------------------------------------
	parameter	IMAGE_SRC				= "RANDOM"				;	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC"
	parameter	DATA_WIDTH				= 32					;	//8 10 12 max is 16
	parameter	SENSOR_CLK_DELAY_VALUE	= 3						;	//Sensor оƬ�ڲ���ʱ ��λns
	parameter	CLK_DATA_ALIGN			= "RISING"				;	//"RISING" - ���ʱ�ӵ������������ݶ��롣"FALLING" - ���ʱ�ӵ��½��������ݶ���
	parameter	DSP_IMPLEMENT			= "FLALSE"				;	//"TRUE" - ����ģʽ��ʹ�ó˷�����"FALSE" - ����ģʽ����ʹ�ܳ˷�����
	parameter	FVAL_LVAL_ALIGN			= "FALSE"				;	//"TRUE" - fval �� lval ֮��ľ���̶�Ϊ3��ʱ�ӡ�"FALSE" - fval �� lval ֮��ľ��������趨
	parameter	SOURCE_FILE_PATH		= "file/source_file/"	;	//����Դ�ļ�·��
	parameter	GEN_FILE_EN				= 1						;	//0-���ɵ�ͼ��д���ļ���1-���ɵ�ͼ��д���ļ�
	parameter	GEN_FILE_PATH			= "file/gen_file/"		;	//����������Ҫд���·��
	parameter	NOISE_EN				= 0						;	//0-������������1-��������

	//	-------------------------------------------------------------------------------------
	//	clock reset parameter
	//	-------------------------------------------------------------------------------------
	parameter		DDR3_MEMCLK_FREQ	= 320					;	//Memory data transfer clock frequency DDR3-640:3125 DDR3-660:3030 DDR3-720:2778 DDR3-800:2500

	//	-------------------------------------------------------------------------------------
	//	dut paramter
	//	-------------------------------------------------------------------------------------
	parameter		NUM_DQ_PINS			= 16					;	//External memory data width
	parameter		MEM_BANKADDR_WIDTH	= 3						;	//External memory bank address width
	parameter		MEM_ADDR_WIDTH		= 13					;	//External memory address width.
	//	parameter		DDR3_MEMCLK_FREQ	= 320					;	//Memory data transfer clock frequency DDR3-640:3125 DDR3-660:3030 DDR3-720:2778 DDR3-800:2500
	parameter		MEM_ADDR_ORDER		= "ROW_BANK_COLUMN"		;	//"ROW_BANK_COLUMN" or "BANK_ROW_COLUMN"
	parameter		SKIP_IN_TERM_CAL	= 1						;	//1-calib input term 0-not calib input term.1 will decrease power consumption
	parameter		DDR3_MEM_DENSITY	= "1Gb"					;	//DDR3 ���� "1Gb" "512Mb"
	parameter		DDR3_TCK_SPEED		= "15E"					;	//DDR3 speed "187E" "15E" "125"
	parameter		DDR3_SIMULATION		= "TRUE"				;	//����ģʽ������MCB�����ٶ�
	parameter		DDR3_CALIB_SOFT_IP	= "FALSE"				;	//ʹ��calibrationģ��
	//	parameter		DATA_WIDTH			= 32					;	//���ݿ��
	parameter		PTR_WIDTH			= 2						;	//��дָ���λ��1-���2֡ 2-���4֡ 3-���8֡ 4-���16֡ 5-���32֡
	parameter		FRAME_SIZE_WIDTH	= 25					;	//һ֡��Сλ����DDR3��1Gbitʱ�����������128Mbyte����mcb p3 ��λ����32ʱ��25λ���size���������㹻��
	parameter		TERRIBLE_TRAFFIC	= "FALSE"				;	//��д���������TRUE-ͬʱ��д��ͬ֡��ͬһ��ַ��FALSE-ͬʱ��дͬһ֡��ͬһ��ַ
	parameter		DDR3_16_DQ_MCB_8_DQ	= 0						;	//DDR3��16bit������MCBȴ��8bit

	//	-------------------------------------------------------------------------------------
	//	monitor paramter
	//	-------------------------------------------------------------------------------------
	parameter		MONITOR_OUTPUT_FILE_EN			= 0					;	//�Ƿ��������ļ�
	parameter		MONITOR_OUTPUT_FILE_PATH		= "file/frame_buffer_file/"		;	//����������Ҫд���·��
	parameter		CHK_INOUT_DATA_STOP_ON_ERROR	= 0						;
	parameter		CHK_PULSE_WIDTH_STOP_ON_ERROR	= 0						;

	//	-------------------------------------------------------------------------------------
	//	testcase parameter
	//	-------------------------------------------------------------------------------------
	parameter		CLK_PERIOD		= 25	;	//ʱ��Ƶ�ʣ�40MHz

	//	-------------------------------------------------------------------------------------
	//	reg wire
	//	-------------------------------------------------------------------------------------
	reg									clk_osc					= 1'b0	;
	wire								clk_mt9p031				;
	wire								o_fval_mt9p031				;
	wire								i_fval					;
	wire								i_lval					;
	wire	[DATA_WIDTH-1:0]			iv_image_din			;
	wire								clk_front				;
	wire								clk_back				;
	wire								clk_frame_buf			;
	wire								reset_frame_buf			;
	wire								async_rst				;
	wire								sysclk_2x				;
	wire								sysclk_2x_180			;
	wire								pll_ce_0				;
	wire								pll_ce_90				;
	wire								mcb_drp_clk				;
	wire								bufpll_mcb_lock			;
	
	//	ref ARCHITECTURE
	//	===============================================================================================
	//	ref ***tb ��ģ�鼤��***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	--ref ʱ�Ӹ�λ
	//	-------------------------------------------------------------------------------------
	always	#(CLK_PERIOD/2.0)	clk_osc	= !clk_osc;

	//	-------------------------------------------------------------------------------------
	//	--ref Sensor
	//	-------------------------------------------------------------------------------------
	assign	clk_mt9p031		= driver_clock_reset.clk_pix;
	assign	o_fval_mt9p031	= driver_mt9p031.o_fval;
	
	//	-------------------------------------------------------------------------------------
	//	--ref dut
	//	-------------------------------------------------------------------------------------
	assign	i_fval			= driver_mt9p031.o_fval;
	assign	i_lval			= driver_mt9p031.o_lval;
	assign	iv_image_din	= driver_mt9p031.ov_pix_data	;
	assign	clk_front		= driver_clock_reset.clk_pix	;
	assign	clk_back		= driver_clock_reset.clk_gpif	;
	assign	clk_frame_buf	= driver_clock_reset.clk_frame_buf		;
	assign	reset_frame_buf = driver_clock_reset.reset_frame_buf   ;
	assign	async_rst       = driver_clock_reset.async_rst         ;
	assign	sysclk_2x       = driver_clock_reset.sysclk_2x         ;
	assign	sysclk_2x_180   = driver_clock_reset.sysclk_2x_180     ;
	assign	pll_ce_0        = driver_clock_reset.pll_ce_0          ;
	assign	pll_ce_90       = driver_clock_reset.pll_ce_90         ;
	assign	mcb_drp_clk     = driver_clock_reset.mcb_drp_clk       ;
	assign	bufpll_mcb_lock = driver_clock_reset.bufpll_mcb_lock   ;


	//	-------------------------------------------------------------------------------------
	//	--ref ����ʱ��
	//	-------------------------------------------------------------------------------------
	initial begin
		#200
		repeat(6) @ (posedge harness.ov_image_dout[32]);
		#200
		$stop;
	end


	//	===============================================================================================
	//	ref ***����bfm task***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	--ref sensor bfm
	//	-------------------------------------------------------------------------------------
	initial begin
		#200;
		driver_mt9p031.bfm_mt9p031.reset_high();
		#200;
		wait(harness.o_calib_done==1'b1);
		#200;
		driver_mt9p031.bfm_mt9p031.reset_low();
	end

	//	-------------------------------------------------------------------------------------
	//	sensor pattern
	//	-------------------------------------------------------------------------------------
	initial begin
		driver_mt9p031.bfm_mt9p031.pattern_2para(16,16);
	end

	//	-------------------------------------------------------------------------------------
	//	--ref dut bfm
	//	-------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	֡�����
	//  -------------------------------------------------------------------------------------
	initial begin
		harness.bfm.frame_depth(2);
	end

	initial begin
		//		bfm.sti_se_start_fval();
		harness.bfm.se_low_high();
	end




endmodule
