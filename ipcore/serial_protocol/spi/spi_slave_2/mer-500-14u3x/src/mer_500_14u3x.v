//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : mer_500_14u3x
//  -- �����       : ��ǿ
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����     :|  �޸�˵��
//---------------------------------------------------------------------------------------
//  -- ��ǿ         :| 2014/11/25   :|  ���������ź�����
//	-- �Ϻ���		:| 2015/3/30 	:|	��д��Ķ���ģ�����Ͻ���
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1) 	: ��ģ����mer_500_14u3x����Ķ���ģ�飬��Ҫ������xxxx����ģ��
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
module mer_500_14u3x  # (
	parameter	SENSOR_DAT_WIDTH			= 10				,	//Sensor ���ݿ��
	parameter	GPIF_DAT_WIDTH				= 32				,	//GPIF���ݿ��
	parameter	NUM_GPIO					= 2					,	//GPIO����
	parameter	NUM_DQ_PINS					= 16 				,	//DDR3���ݿ��
	parameter	MEM_ADDR_WIDTH				= 13 				,	//DDR3��ַ���
	parameter	MEM_BANKADDR_WIDTH			= 3  				,	//DDR3bank���
	parameter	DDR3_MEMCLK_FREQ			= 320				,	//DDR3ʱ��Ƶ��
	parameter	DDR3_MEM_DENSITY			= "1Gb"				,	//DDR3����
	parameter	DDR3_TCK_SPEED				= "15E"				,	//DDR3���ٶȵȼ�
	parameter	DDR3_SIMULATION				= "FALSE"			,	//�򿪷�����Լ��ٷ����ٶȣ�����ʵ�ʲ��ֲ���ʱ�����ܴ򿪷��档
	parameter	DDR3_CALIB_SOFT_IP			= "TRUE"				//����ʱ�����Բ�ʹ��У׼�߼�
	)
	(
	//  ===============================================================================================
	//  ��һ���֣�����ʱ���ź�
	//  ===============================================================================================
	input									clk_osc				,	//�������ţ�40MHz�����ⲿ����
	//  ===============================================================================================
	//  �ڶ����֣�sensor�ӿ��ź�
	//  ===============================================================================================
	input									clk_sensor_pix		,	//�������ţ�Sensor������72MHz����·����ʱ��,�뱾��72MhzͬƵ����ͬ�࣬����Ϊ��ȫ�첽�������źţ����sensor��λ��sensor���ʱ�ӿ���ֹͣ�������FPGA�ڲ�ʱ�Ӳ�ֹͣ
	input		[SENSOR_DAT_WIDTH-1:0]		iv_pix_data			,	//�������ţ�Sensor������ͼ�����ݣ���clk_sensor_pix�����ض��룬��·����sensor��10λ�����ߣ���2λ����û�н��뵽FPGA��
	input									i_fval				,	//�������ţ�Sensor����������Ч�źţ���clk_sensor_pix�����ض��롣i_fval��������i_lval�����ض��룬i_fval�½�����i_lval�½��ض���
	input									i_lval				,	//�������ţ�Sensor����������Ч�źţ���clk_sensor_pix�����ض��롣i_fval��������i_lval�����ض��룬i_fval�½�����i_lval�½��ض��롣��i_fval��Ч�ڼ�Ҳ�п������
	input									i_sensor_strobe		,	//�������ţ�Sensor����������Ч��������źţ���clk_sensor_pix�����ض��룬sensor������bug����SW<=VB+H��ʱ��Ҳ����strobe�����������Ȳ�����һ�����ڣ�
	output									o_clk_sensor		,	//������ţ����ӵ�Sensor��Sensor��ʱ�ӣ�20Mhz����40M����������������MT9P031�ֲᣬ�ڸ�λ��ʱ��Sensor��Ҫ����ʱ��
	output									o_trigger_n			,	//������ţ����ӵ�Sensor��Sensor�Ĵ����źţ�����Ч����Ч���8192clk_pix��clk_pixʱ���򡣾������ԣ�SensorҪ�󴥷��źŵĿ������һ�е�ʱ��
	output									o_senser_reset_n	,	//������ţ����ӵ�Sensor��Sensor�ĸ�λ�źţ�����Ч��1ms��ȣ�FPGA������ɺ������������������в���λSensor
	input	[9:4]							iv_pix_data_mux		,	//���õ���������
	input									clk_sensor_pix_mux	,	//���õ���������
	input									i_fval_mux			,	//���õ���������
	input									i_lval_mux			,	//���õ���������
	input									i_sensor_strobe_mux	,	//���õ���������
	//  ===============================================================================================
	//  �ڶ����֣�GPIF�ӿ��ź�
	//  ===============================================================================================
	output									o_clk_usb_pclk		,	//������ţ����ӵ�3014��GPIF�ӿڵ�ʱ��100MHz��ʹ��ODDR�������FPGA �����ϣ�ʱ���½�����gpif���ݶ���
	output		[GPIF_DAT_WIDTH-1:0]		ov_usb_data			,	//������ţ����ӵ�3014��GPIF�ӿڵ����ݣ�clk_gpif ʱ������FPGA�����ϣ�o_clk_usb_pclk��ov_usb_data����
	output		[1:0]						ov_usb_fifoaddr		,	//������ţ����ӵ�3014��GPIF fifo��ַ��clk_gpif ʱ����00��11���棬��FPGA�����ϣ�o_clk_usb_pclk��ov_usb_data����
	output									o_usb_slwr_n		,	//������ţ����ӵ�3014��GPIF д�źţ�clk_gpif ʱ����
	output									o_usb_pktend_n		,	//������ţ����ӵ�3014��GPIF �������źţ�clk_gpif ʱ����
	input									i_usb_flagb_n		,	//�������ţ����ӵ�3014��3014������o_clk_usb_pclk ʱ����GPIF��ǰDMAbuffer���źţ��� clk_gpif ����λ���Ϊ���첽�źţ���Ҫ�� u3_interface ģ��������ʱ������
	//  ===============================================================================================
	//  �������֣�SPI�ӿ��ź�
	//  ===============================================================================================
	input									i_usb_spi_sck		,	//�������ţ�3014������SPIʱ�ӣ���������10Mhz���û�����463KhzƵ�ʣ�FPGA�趼���㡣���̼����û�����ʱ���ź�ռ�ձȿ��ܻ��нϴ�仯�����ź���С��ȱ�֤>384ns
	input									i_usb_spi_mosi		,	//�������ţ�3014������SPI�������룬�źſ�ȿ��ܻ��нϴ�仯�����ź���С��ȱ�֤>384ns
	input									i_spi_cs_n_fpga		,	//�������ţ�3014������SPI FPGAƬѡ���̼���һ���ܱ�ֻ֤�з���FPGAʱƬѡ�����ͣ�FPGA��Ҫ�����쳣��Ƭѡ
	output									o_usb_spi_miso		,	//������ţ����ӵ�3014���ⲿ��flash�����������SPI���������ֻ�ж�����ͨ��֮��������Ч���ݣ�������衣Ƭѡ��Чʱ����������
	//  ===============================================================================================
	//  ���Ĳ��֣�IO�ӿ��ź�
	//  ===============================================================================================
	input									i_optocoupler		,	//�������ţ�������������ȴ�0��������п��ܣ���������ë�̣���ȴ���֡����ʱ��Ҫ�����½��ص��󴥷����첽�ź�
	input		[NUM_GPIO-1:0]				iv_gpio				,	//�������ţ�������������˫��IO������ˣ���ȴ�0��������п��ܣ��������ܸ��ţ��첽�źš�˫��IO����Ϊ����ʱ������Ϊ0
	output									o_optocoupler		,	//������ţ����ӵ�������������·����ʱ��������ʱ7~44us��������ʱ9~35us
	output		[NUM_GPIO-1:0]				ov_gpio				,	//������ţ����ӵ������ܣ�˫��IO������ˣ���ʱ<1us,˫��IO����Ϊ����ʱ������Ϊ0
	output									o_f_led_gre			,	//������ţ����ӵ�LED����ɫָʾ�ƣ��ߵ�ƽ����
	output									o_f_led_red			,	//������ţ����ӵ�LED����ɫָʾ�ƣ��ߵ�ƽ����
	//  ===============================================================================================
	//  ���岿�֣�DDR3�ӿ��ź�
	//  ������ʹ���ź�����ddr3оƬ�ⲿ�ӿ��źţ������źŶ���ο���׼��ddr3�ӿ�
	//  ===============================================================================================
	inout  		[NUM_DQ_PINS-1:0]			mcb1_dram_dq		,	//DDR3������ţ������ź�
	output 		[MEM_ADDR_WIDTH-1:0]		mcb1_dram_a			,	//DDR3������ţ���ַ�ź�
	output 		[MEM_BANKADDR_WIDTH-1:0]	mcb1_dram_ba		,	//DDR3������ţ�Bank��ַ�ź�
	output									mcb1_dram_ras_n		,	//DDR3������ţ��е�ַѡͨ
	output									mcb1_dram_cas_n		,	//DDR3������ţ��е�ַѡͨ
	output									mcb1_dram_we_n		,	//DDR3������ţ�д�ź�
	output									mcb1_dram_odt		,	//DDR3������ţ��迹ƥ���ź�
	output									mcb1_dram_reset_n	,	//DDR3������ţ���λ�ź�
	output									mcb1_dram_cke		,	//DDR3������ţ�ʱ��ʹ���ź�
	output									mcb1_dram_dm		,	//DDR3������ţ����ֽ����������ź�
	inout 									mcb1_dram_udqs		,	//DDR3������ţ����ֽڵ�ַѡͨ�ź���
	inout 									mcb1_dram_udqs_n	,	//DDR3������ţ����ֽڵ�ַѡͨ�źŸ�
	inout 									mcb1_rzq			,	//DDR3������ţ�����У׼
	output									mcb1_dram_udm		,	//DDR3������ţ����ֽ����������ź�
	inout 									mcb1_dram_dqs		,	//DDR3������ţ����ֽ�����ѡͨ�ź���
	inout 									mcb1_dram_dqs_n		,	//DDR3������ţ����ֽ�����ѡͨ�źŸ�
	output									mcb1_dram_ck		,	//DDR3������ţ�ʱ����
	output									mcb1_dram_ck_n		,	//DDR3������ţ�ʱ�Ӹ�
	//  ===============================================================================================
	//  �������֣������ӿ��ź�
	//  ===============================================================================================
	input									i_flash_hold		,	//�����hold�ź�
	output									o_flash_hold		,	//�����hold�ź�
	output									o_usb_int			,	//������ţ����ӵ�3014����3014���ж��źţ��ߵ�ƽ��Ч��>100ns��clk_pixʱ����
	output		[3:0]						ov_test				,	//������ţ�PCB���к��㣬���Թܽ�
	output									o_unused_pin			//ԭ��ͼ��û�з�Ƶ���ţ�sensor�ϵĸ���������Ҫ���������
	);

	//	ref signals

	//  ===============================================================================================
	//	-- ref ���ز�������
	//  ===============================================================================================
	localparam		WB_OFFSET_WIDTH			= 12	;	//��ƽ��ģ��ƫ��λ�üĴ������
	localparam		WB_GAIN_WIDTH			= 11	;	//��ƽ��ģ������Ĵ������
	localparam		WB_STATIS_WIDTH			= 31	;	//��ƽ��ģ��ͳ��ֵ���
	localparam		GREY_OFFSET_WIDTH		= 12	;	//�Ҷ�ͳ��ģ��ƫ��λ�üĴ���
	localparam		GREY_STATIS_WIDTH		= 48	;	//�Ҷ�ͳ��ģ��ͳ��ֵ���
	localparam		TRIG_FILTER_WIDTH		= 19	;	//�����ź��˲�ģ��Ĵ������
	localparam		TRIG_DELAY_WIDTH		= 28	;	//�����ź���ʱģ��Ĵ������
	localparam		LED_CTRL_WIDTH			= 5     ;	//LED CTRL �Ĵ������
	localparam		DATA_WD					= 32	;	//�����������λ������ʹ��ͬһ���
	localparam		SHORT_REG_WD 			= 16	;	//�̼Ĵ���λ��
	localparam		REG_WD 					= 32	;	//�Ĵ���λ��
	localparam		LONG_REG_WD 			= 64	;	//���Ĵ���λ��
	localparam		BACK_FIFO_DEEP_WD 		= 8		;	//���FIFO���λ��
	localparam		DMA_SIZE		 		= 16'h2000	;	//DMA SIZE��С
	localparam		REG_INIT_VALUE			= "FALSE"	;	//�Ĵ�����Ĭ�ϵĳ�ʼֵ
	localparam		BUF_DEPTH_WD			= 4		;	//֡�����λ��,�������֧��8֡��ȣ���һλ��λλ

	//  ===============================================================================================
	//	-- ref ʱ�Ӹ�λģ�����
	//  ===============================================================================================
	wire							w_async_rst					;	//ʱ�Ӹ�λģ��������첽��λ��ֻ�ṩ��MCB
	wire							w_sysclk_2x					;	//ʱ�Ӹ�λģ�����������ʱ�ӣ�ֻ�ṩ��MCB
	wire							w_sysclk_2x_180				;	//ʱ�Ӹ�λģ�����������ʱ�ӣ�ֻ�ṩ��MCB
	wire							w_pll_ce_0					;	//ʱ�Ӹ�λģ�����������Ƭѡ��ֻ�ṩ��MCB
	wire							w_pll_ce_90					;	//ʱ�Ӹ�λģ�����������Ƭѡ��ֻ�ṩ��MCB
	wire							w_mcb_drp_clk				;	//ʱ�Ӹ�λģ�������calib�߼�ʱ�ӣ�ֻ�ṩ��MCB
	wire							w_bufpll_mcb_lock			;	//ʱ�Ӹ�λģ�������bufpll_mcb �����źţ�ֻ�ṩ��MCB
	wire							clk_osc_bufg				;	//ʱ�Ӹ�λģ�������40MHzʱ�ӣ�ȫ�ֻ�������
	wire							reset_osc_bufg				;	//ʱ�Ӹ�λģ�������40MHzʱ�ӵĸ�λ�ź�
	wire							clk_pix						;	//ʱ�Ӹ�λģ���������������ʱ�ӣ�72Mhz
	wire							reset_pix					;	//ʱ�Ӹ�λģ���������������ʱ�ӵĸ�λ�ź�
	wire							clk_frame_buf				;	//ʱ�Ӹ�λģ�������֡��ʱ�ӣ���gpifʱ����ͬһ��Դͷ��Ϊ�˱�֤ģ������ԣ�֡�滹��ʹ�õ�����ʱ������
	wire							reset_frame_buf				;	//ʱ�Ӹ�λģ�������֡��ʱ�ӵĸ�λ�źţ���gpifʱ����ĸ�λ�ź���ͬһ��Դͷ
	wire							clk_gpif					;	//ʱ�Ӹ�λģ�������gpif ʱ�ӣ�100MHz
	wire							reset_gpif					;	//ʱ�Ӹ�λģ�������gpif ʱ�ӵĸ�λ�ź�
	wire							reset_u3_interface			;	//ʱ�Ӹ�λģ�������u3 interface ģ�鸴λ
	wire							w_sensor_reset_done			;	//ʱ�Ӹ�λģ�������clk_osc_bufgʱ����sensor��λ����źţ����̼���ѯ���̼���ѯ���ñ�־���ܸ�λ
	//  ===============================================================================================
	//	-- ref ����ͨ��ģ�����
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	SPI ��̬
	//	-------------------------------------------------------------------------------------
	wire							w_spi_miso_data				;	//����ͨ�������spi_sampleʱ����spi����ź�
	wire							w_spi_miso_data_en			;	//����ͨ�������spi_sampleʱ����spi����ź�ʹ���źţ���ʹ���ź�Ϊ0ʱ��miso���Ÿ���

	//  -------------------------------------------------------------------------------------
	//	ͨ��
	//  -------------------------------------------------------------------------------------
	wire							w_stream_enable_pix			;	//����ͨ�������clk_pixʱ�����������źţ�û����Чʱ��
	wire							w_acquisition_start_pix		;	//����ͨ�������clk_pixʱ���򣬿����źţ�û����Чʱ��
	wire							w_stream_enable_frame_buf	;	//����ͨ�������clk_frame_bufʱ�����������źţ�û����Чʱ��
	wire							w_stream_enable_gpif		;	//����ͨ�������clk_gpifʱ�����������źţ�û����Чʱ��
	//  -------------------------------------------------------------------------------------
	//	����� clk reset top
	//  -------------------------------------------------------------------------------------
	wire							w_reset_sensor				;	//����ͨ�������clk_osc_bufgʱ���򣬸�λsensorʹ���źţ�1��ʱ�����ڿ��
	//  -------------------------------------------------------------------------------------
	//	����� io channel
	//  -------------------------------------------------------------------------------------
	wire							w_trigger_mode				;	//����ͨ·�����clk_pixʱ���򣬴���ģʽ�Ĵ�����û����Чʱ������
	wire	[3:0]					wv_trigger_source			;	//����ͨ·�����clk_pixʱ���򣬴���Դ�Ĵ�����û����Чʱ������
	wire							w_trigger_soft				;	//����ͨ·�����clk_pixʱ���������Ĵ���������ͨ�������㣬�����1��ʱ������
	wire							w_trigger_active			;	//����ͨ·�����clk_pixʱ���򣬴�����Ч�ؼĴ�����û����Чʱ������
	wire	[TRIG_FILTER_WIDTH-1:0]	wv_trigger_filter_rise		;	//����ͨ·�����clk_pixʱ���������ش����˲��Ĵ�����û����Чʱ�����ƣ�����֤������Ч
	wire	[TRIG_FILTER_WIDTH-1:0]	wv_trigger_filter_fall		;	//����ͨ·�����clk_pixʱ�����½��ش����˲��Ĵ�����û����Чʱ�����ƣ�����֤������Ч
	wire	[TRIG_DELAY_WIDTH-1:0]	wv_trigger_delay			;	//����ͨ·�����clk_pixʱ���򣬴����ӳټĴ�����û����Чʱ�����ƣ�����֤������Ч
	wire	[2:0]					wv_useroutput_level			;	//����ͨ·�����clk_pixʱ�����û��Զ�������Ĵ�����û����Чʱ������
	wire							w_line2_mode				;	//����ͨ�������clk_pixʱ����line2�������ģʽ�Ĵ���
	wire							w_line3_mode				;	//����ͨ�������clk_pixʱ����line3�������ģʽ�Ĵ���
	wire							w_line0_invert				;	//����ͨ�������clk_pixʱ����line0���ԼĴ���
	wire							w_line1_invert				;	//����ͨ�������clk_pixʱ����line1���ԼĴ���
	wire							w_line2_invert				;	//����ͨ�������clk_pixʱ����line2���ԼĴ���
	wire							w_line3_invert				;	//����ͨ�������clk_pixʱ����line3���ԼĴ���
	wire	[2:0]					wv_line_source1				;	//����ͨ�������clk_pixʱ����line1�����Դѡ��Ĵ���
	wire	[2:0]					wv_line_source2				;	//����ͨ�������clk_pixʱ����line2�����Դѡ��Ĵ���
	wire	[2:0]					wv_line_source3				;	//����ͨ�������clk_pixʱ����line3�����Դѡ��Ĵ���
	wire	[4:0]					wv_led_ctrl					;	//����ͨ�������clk_pixʱ����˫ɫ�ƿ��ƼĴ���
	//  -------------------------------------------------------------------------------------
	//	����� data channel
	//  -------------------------------------------------------------------------------------
	wire	[REG_WD-1:0]			wv_pixel_format				;	//����ͨ�������clk_pixʱ���򣬿���ͨ·��������ظ�ʽ�Ĵ�����û����Чʱ�����ƣ�0x01080001:Mono8��0x01100003:Mono10��0x01080008:BayerGR8��0x0110000C:BayerGR10
	wire							w_encrypt_state				;	//����ͨ�������clk_dnaʱ���򣬼���״̬���ϵ�󱣳ֲ��䣬������Ϊ����
	wire							w_pulse_filter_en			;	//����ͨ·�����clk_pixʱ���򣬻���У���Ĵ�����û����Чʱ������
	wire	[2:0]					wv_test_image_sel			;	//����ͨ·�����clk_pixʱ���򣬲���ͼѡ��Ĵ�����û����Чʱ�����ƣ�000:��ʵͼ,001:����ͼ��1�Ҷ�ֵ֡����,110:����ͼ��2��ֹ��б����,010:����ͼ��3������б����
	wire	[1:0]					wv_interrupt_en				;	//����ͨ·�����clk_pixʱ�����ж�ʹ�ܼĴ�����û����Чʱ������
	wire	[1:0]					wv_interrupt_clear			;	//����ͨ·�����clk_pixʱ�����ж�����Ĵ�����������Ч
	wire	[WB_OFFSET_WIDTH-1:0]	wv_wb_offset_x_start		;	//����ͨ·�����clk_pixʱ���򣬰�ƽ�������Ĵ�����û����Чʱ������
	wire	[WB_OFFSET_WIDTH-1:0]	wv_wb_offset_width			;	//����ͨ·�����clk_pixʱ���򣬰�ƽ���ȼĴ�����û����Чʱ������
	wire	[WB_OFFSET_WIDTH-1:0]	wv_wb_offset_y_start		;	//����ͨ·�����clk_pixʱ���򣬰�ƽ��������Ĵ�����û����Чʱ������
	wire	[WB_OFFSET_WIDTH-1:0]	wv_wb_offset_height			;	//����ͨ·�����clk_pixʱ���򣬰�ƽ��߶ȼĴ�����û����Чʱ������
	wire	[WB_GAIN_WIDTH-1:0]		wv_wb_gain_r				;	//����ͨ·�����clk_pixʱ���򣬰�ƽ����������Ĵ�����û����Чʱ������
	wire	[WB_GAIN_WIDTH-1:0]		wv_wb_gain_g				;	//����ͨ·�����clk_pixʱ���򣬰�ƽ���̷�������Ĵ�����û����Чʱ������
	wire	[WB_GAIN_WIDTH-1:0]		wv_wb_gain_b				;	//����ͨ·�����clk_pixʱ���򣬰�ƽ������������Ĵ�����û����Чʱ������
	wire	[GREY_OFFSET_WIDTH-1:0]	wv_grey_offset_x_start		;	//����ͨ·�����clk_pixʱ���򣬻Ҷ�ֵͳ�����������Ĵ�����û����Чʱ������
	wire	[GREY_OFFSET_WIDTH-1:0]	wv_grey_offset_width		;	//����ͨ·�����clk_pixʱ���򣬻Ҷ�ֵͳ�������ȼĴ�����û����Чʱ������
	wire	[GREY_OFFSET_WIDTH-1:0]	wv_grey_offset_y_start		;	//����ͨ·�����clk_pixʱ���򣬻Ҷ�ֵͳ������������Ĵ�����û����Чʱ������
	wire	[GREY_OFFSET_WIDTH-1:0]	wv_grey_offset_height		;	//����ͨ·�����clk_pixʱ���򣬻Ҷ�ֵͳ������߶ȼĴ�����û����Чʱ������
	//  -------------------------------------------------------------------------------------
	//	����� u3v format
	//  -------------------------------------------------------------------------------------
	wire							w_chunk_mode_active_pix		;	//����ͨ·�����clk_pixʱ����chunk���ؼĴ�����û����Чʱ������
	wire							w_chunkid_en_ts				;	//����ͨ·�����clk_pixʱ����ʱ������ؼĴ�����û����Чʱ������
	wire							w_chunkid_en_fid			;	//����ͨ·�����clk_pixʱ����frame id���ؼĴ�����û����Чʱ������
	wire	[REG_WD-1:0]			wv_chunk_size_img			;	//����ͨ·�����clk_pixʱ����chunk image��С��û����Чʱ������
	wire	[REG_WD-1:0]			wv_payload_size_pix			;	//����ͨ�������clk_pixʱ�������ݵĴ�С��������ͷ��β����Э��Ҫ��64bit������ֻ����32bit���ɣ���32bit��0
	wire	[SHORT_REG_WD-1:0]		wv_roi_offset_x				;	//����ͨ�������clk_pixʱ����ͷ���е�ˮƽƫ��
	wire	[SHORT_REG_WD-1:0]		wv_roi_offset_y				;	//����ͨ�������clk_pixʱ����ͷ���еĴ�ֱƫ��
	wire	[SHORT_REG_WD-1:0]		wv_roi_pic_width			;	//����ͨ�������clk_pixʱ����ͷ���еĴ��ڿ��
	wire	[SHORT_REG_WD-1:0]		wv_roi_pic_height			;	//����ͨ�������clk_pixʱ����ͷ���еĴ��ڸ߶�
	wire	[LONG_REG_WD-1:0]		wv_timestamp_u3				;	//����ͨ�������clk_osc_bufgʱ�����ڳ��ź�����������ʱ������������4��clk_osc_bufgʱ������ȶ�����pixʱ���������8��ʱ��֮������ȶ�
	//  -------------------------------------------------------------------------------------
	//	����� frame buffer
	//  -------------------------------------------------------------------------------------
	wire	[BUF_DEPTH_WD-1:0]		wv_frame_buffer_depth			;	//����ͨ�������֡����ȣ�2-8
	wire	[REG_WD-1:0]			wv_payload_size_frame_buf		;	//����ͨ�������clk_frame_bufʱ�������ݵĴ�С��������ͷ��β����Э��Ҫ��64bit������ֻ����32bit���ɣ���32bit��0
	wire							w_chunk_mode_active_frame_buf	;	//����ͨ�������clk_frame_bufʱ����chunk���ؼĴ���
	//  -------------------------------------------------------------------------------------
	//	����� u3 interface
	//  -------------------------------------------------------------------------------------
	wire	[REG_WD-1:0]			wv_si_payload_transfer_size	;	//����ͨ·�����clk_gpifʱ���򣬵������ݿ��С,����ͨ�������δ����Чʱ������
	wire	[REG_WD-1:0]			wv_si_payload_transfer_count;	//����ͨ·�����clk_gpifʱ���򣬵������ݿ����,����ͨ�������δ����Чʱ������
	wire	[REG_WD-1:0]			wv_si_payload_final_transfer1_size	;	//����ͨ·�����clk_gpifʱ����transfer1��С,����ͨ�������δ����Чʱ������
	wire	[REG_WD-1:0]			wv_si_payload_final_transfer2_size	;	//����ͨ·�����clk_gpifʱ����transfer2��С,����ͨ�������δ����Чʱ������
	wire	[REG_WD-1:0]			wv_payload_size_gpif		;	//����ͨ�������clk_gpifʱ�������ݵĴ�С��������ͷ��β����Э��Ҫ��64bit������ֻ����32bit���ɣ���32bit��0
	wire							w_chunk_mode_active_gpif	;	//����ͨ�������clk_gpifʱ����chunk���ؼĴ���
	//  ===============================================================================================
	//  -- ref io_channel ���
	//  ===============================================================================================
	wire	[3:0]					wv_line_status				;	//����ͨ�������clk_pixʱ����line״̬�Ĵ�����IOͨ�������ָʾIO����ѡ���״̬
	//  ===============================================================================================
	//  -- ref data_channel ���
	//  ===============================================================================================
	wire							w_fval_data_channel			;	//����ͨ·�����clk_pixʱ���򣬳���Ч�źţ�fval���ź��Ǿ�������ͨ���ӿ���ĳ��źţ���ͷ�������leader����������Ч��ͼ�����ݣ�ͣ���ڼ䱣�ֵ͵�ƽ
	wire							w_data_channel_dvalid		;	//����ͨ·�����clk_pixʱ����������Ч�źţ���־32λ����Ϊ��Ч����
	wire	[DATA_WD-1:0]			wv_data_channel_data		;	//����ͨ·�����clk_pixʱ����32bit���ݣ���������Ч���룬������ʱ�Ӷ���
	wire							w_full_frame_state			;	//����ͨ·�����clk_pixʱ��������֡״̬�źţ����̼���ѯ
	wire	[REG_WD-1:0]			wv_pixel_format_data_channel;	//����ͨ·�����clk_pixʱ����Ŀ�����ú�ģ��������ͨ�������ظ�ʽ����һ��
	wire	[WB_STATIS_WIDTH-1:0]	wv_wb_statis_r				;	//����ͨ·�����clk_pixʱ���򣬰�ƽ�������Ҷ�ֵͳ�ƼĴ�����������Чʱ������
	wire	[WB_STATIS_WIDTH-1:0]	wv_wb_statis_g				;	//����ͨ·�����clk_pixʱ���򣬰�ƽ���̷����Ҷ�ֵͳ�ƼĴ�����������Чʱ������
	wire	[WB_STATIS_WIDTH-1:0]	wv_wb_statis_b				;	//����ͨ·�����clk_pixʱ���򣬰�ƽ���������Ҷ�ֵͳ�ƼĴ�����������Чʱ������
	wire	[WB_OFFSET_WIDTH-1:0]	wv_wb_offset_width_valid	;	//����ͨ·�����clk_pixʱ���򣬰�ƽ���ȼĴ��������ƽ��ͳ��ֵͬ��һ֡ͼ��
	wire	[WB_OFFSET_WIDTH-1:0]	wv_wb_offset_height_valid	;	//����ͨ·�����clk_pixʱ���򣬰�ƽ��߶ȼĴ��������ƽ��ͳ��ֵͬ��һ֡ͼ��
	wire	[GREY_OFFSET_WIDTH-1:0]	wv_grey_offset_width_valid	;	//����ͨ·�����clk_pixʱ���򣬻Ҷ�ֵͳ�������ȼĴ�������Ҷ�ͳ��ֵͬ��һ֡
	wire	[GREY_OFFSET_WIDTH-1:0]	wv_grey_offset_height_valid	;	//����ͨ·�����clk_pixʱ���򣬻Ҷ�ֵͳ������߶ȼĴ�������Ҷ�ͳ��ֵͬ��һ֡
	wire	[GREY_STATIS_WIDTH-1:0]	wv_grey_statis_sum			;	//����ͨ·�����clk_pixʱ���򣬵ĻҶ�ֵͳ�ƼĴ�������Ҷ�ͳ��ֵ����ͬ��һ֡��������ظ�ʽΪ8bit����ֵΪ����8bitͳ��ֵ��������ظ�ʽΪ10bit����ֵΪ����10bitͳ��ֵ��
	wire	[1:0]					wv_interrupt_state			;	//����ͨ·�����clk_pixʱ�����ж�״̬�Ĵ���
	//  ===============================================================================================
	//  -- ref u3v_format ���
	//  ===============================================================================================
	wire							w_u3v_format_fval			;	//u3v_formatģ�������clk_pixʱ���򣬳���Ч�ź�
	wire							w_u3v_format_dvalid			;	//u3v_formatģ�������clk_pixʱ����������Ч�ź�
	wire	[DATA_WD-1:0]			wv_u3v_format_data			;	//u3v_formatģ�������clk_pixʱ��������
	//  ===============================================================================================
	//  -- ref frame_buffer ���
	//  ===============================================================================================
	wire	[DATA_WD-1:0]			wv_frame_buffer_data		;	//frame_bufferģ�������clk_frame_bufʱ����֡���FIFO������������32bit
	wire							w_frame_buffer_dvalid		;	//frame_bufferģ�������clk_frame_bufʱ����֡�����������Ч
	wire							w_ddr_init_done				;	//frame_bufferģ�������mcb_drp_clkʱ����MCB����ĳ�ʼ�������ź�
	wire							w_wr_error					;	//frame_bufferģ�������ʱ����δ֪����MCBӲ�������DDR�����ź�
	wire							w_rd_error					;	//frame_bufferģ�������ʱ����δ֪����MCBӲ�������DDR�����ź�
	wire							w_back_buf_empty			;	//frame_bufferģ�������clk_gpifʱ����֡����FIFO�ձ�־������ָʾ֡�����Ƿ������ݿɶ�
	//  ===============================================================================================
	//  -- ref u3_interface ���
	//  ===============================================================================================
	wire							w_buf_rd					;	//u3_interfaceģ�������clk_gpifʱ���򣬶�ȡ֡����FIFO�źţ���i_data_valid�źŹ�ָͬʾ������Ч
	wire							w_usb_wr_for_led			;	//GPIF д�ź� - ��led_ctrlģ��
	wire							w_usb_pktend_n_for_test		;	//GPIF �������źţ��������������
	wire	[1:0]					wv_usb_fifoaddr_reg			;	//GPIF ��ַ�źţ���������ԼĴ���
	//  ===============================================================================================
	//  -- ref ����
	//  ===============================================================================================
	wire							w_ddr_error					;	//frame_bufferģ�������ʱ����δ֪����MCBӲ����أ�DDR�����ź�
	wire	[4:0]					wv_gpif_state				;	//GPIF ״̬
	wire	[3:0]					wv_fval_state				;	//fval ״̬


	//  ===============================================================================================
	//  -- ref �����ź�
	//  ===============================================================================================
	wire	[15:0]					wv_linein_sel_rise_cnt		;
	wire	[15:0]					wv_linein_sel_fall_cnt		;
	wire	[15:0]					wv_linein_filter_rise_cnt	;
	wire	[15:0]					wv_linein_filter_fall_cnt	;
	wire	[15:0]					wv_linein_active_cnt		;
	wire	[15:0]					wv_trigger_n_rise_cnt		;
	wire	[15:0]					wv_trigger_soft_cnt			;
	wire	[12:0]					wv_strobe_length_reg		;
	wire							w_trailer_flag				;
	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref �ӿ��߼�
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	holdֱ������1
	//	-------------------------------------------------------------------------------------
	//	assign	o_flash_hold	= i_flash_hold;
	assign	o_flash_hold		= 1'b1;

	//	-------------------------------------------------------------------------------------
	//	spi ��˫������ڶ���ʵ��
	//	-------------------------------------------------------------------------------------
	assign	o_usb_spi_miso		= w_spi_miso_data_en ? w_spi_miso_data : 1'bz;

	//	-------------------------------------------------------------------------------------
	//	1.sensor��һЩ����ܽ��� 1��2 ����fpga��ֻ���õ�1����Ϊ�˵�·���ź������Կ��ǣ���һ��Ҳ��Ҫ�����������ţ���˾ͱ�����һ���߼�
	//	2.flash��hold����ܽţ�����
	//	-------------------------------------------------------------------------------------
	assign	o_unused_pin		= ^iv_pix_data_mux[9:4] ^ clk_sensor_pix_mux ^ i_fval_mux ^ i_lval_mux ^ i_sensor_strobe_mux ^ i_flash_hold;

	//	-------------------------------------------------------------------------------------
	//	���Թܽ�
	//	-------------------------------------------------------------------------------------
	assign	ov_test[0]		= w_usb_pktend_n_for_test;
	assign	ov_test[1]		= w_usb_wr_for_led;
	assign	ov_test[2]		= i_usb_flagb_n;
	assign	ov_test[3]		= o_trigger_n;

	//  ===============================================================================================
	//	ref �ڲ��߼�
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	ddr�Ĵ���ָʾ�ź�
	//	-------------------------------------------------------------------------------------
	assign	w_ddr_error			= w_wr_error | w_rd_error;

	//	-------------------------------------------------------------------------------------
	//	gpif�ӿڵ�״̬������ʹ��
	//	-------------------------------------------------------------------------------------
	assign	wv_gpif_state[4:0]	= {wv_usb_fifoaddr_reg[1:0],w_usb_pktend_n_for_test,w_usb_wr_for_led,i_usb_flagb_n};

	//	-------------------------------------------------------------------------------------
	//	fval state������ʹ��
	//	-------------------------------------------------------------------------------------

	assign	wv_fval_state[3:0]	= {w_back_buf_empty,w_u3v_format_fval,w_fval_data_channel,i_fval};

	//  ===============================================================================================
	//  clock_reset����
	//  ===============================================================================================
	clock_reset # (
	.DDR3_MEMCLK_FREQ		(DDR3_MEMCLK_FREQ		)
	)
	clock_reset_inst (
	.clk_osc				(clk_osc				),
	.i_reset_sensor			(w_reset_sensor			),
	.i_stream_enable		(w_stream_enable_gpif	),
	.clk_osc_bufg			(clk_osc_bufg			),
	.reset_osc_bufg			(reset_osc_bufg			),
	.async_rst				(w_async_rst			),
	.sysclk_2x				(w_sysclk_2x			),
	.sysclk_2x_180			(w_sysclk_2x_180		),
	.pll_ce_0				(w_pll_ce_0				),
	.pll_ce_90				(w_pll_ce_90			),
	.mcb_drp_clk			(w_mcb_drp_clk			),
	.bufpll_mcb_lock		(w_bufpll_mcb_lock		),
	.clk_frame_buf			(clk_frame_buf			),
	.reset_frame_buf		(reset_frame_buf		),
	.clk_pix				(clk_pix				),
	.reset_pix				(reset_pix				),
	.o_clk_sensor			(o_clk_sensor			),
	.o_reset_senser_n		(o_senser_reset_n		),
	.o_sensor_reset_done	(w_sensor_reset_done	),
	.o_clk_usb_pclk			(o_clk_usb_pclk			),
	.clk_gpif				(clk_gpif				),
	.reset_gpif				(reset_gpif				),
	.reset_u3_interface		(reset_u3_interface		)
	);

	//  ===============================================================================================
	//  ctrl_channel����
	//  ===============================================================================================
	ctrl_channel # (
	.WB_OFFSET_WIDTH		(WB_OFFSET_WIDTH	),
	.WB_GAIN_WIDTH			(WB_GAIN_WIDTH		),
	.WB_STATIS_WIDTH		(WB_STATIS_WIDTH	),
	.GREY_OFFSET_WIDTH		(GREY_OFFSET_WIDTH	),
	.GREY_STATIS_WIDTH		(GREY_STATIS_WIDTH	),
	.TRIG_FILTER_WIDTH		(TRIG_FILTER_WIDTH	),
	.TRIG_DELAY_WIDTH		(TRIG_DELAY_WIDTH	),
	.LED_CTRL_WIDTH			(LED_CTRL_WIDTH		),
	.SHORT_REG_WD			(SHORT_REG_WD		),
	.REG_WD					(REG_WD				),
	.LONG_REG_WD			(LONG_REG_WD		),
	.BUF_DEPTH_WD			(BUF_DEPTH_WD		),
	.REG_INIT_VALUE			(REG_INIT_VALUE		)
	)
	ctrl_channel_inst(
	//  ===============================================================================================
	//	�����ź�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spiʱ����
	//  -------------------------------------------------------------------------------------
	.i_spi_clk					(i_usb_spi_sck			),
	.i_spi_cs_n					(i_spi_cs_n_fpga		),
	.i_spi_mosi					(i_usb_spi_mosi			),
	.o_spi_miso_data			(w_spi_miso_data		),
	.o_spi_miso_data_en			(w_spi_miso_data_en		),
	//  -------------------------------------------------------------------------------------
	//	40MHzʱ��
	//  -------------------------------------------------------------------------------------
	.clk_osc_bufg				(clk_osc_bufg			),
	.reset_osc_bufg				(reset_osc_bufg			),
	//  -------------------------------------------------------------------------------------
	//	pix ʱ����
	//  -------------------------------------------------------------------------------------
	.clk_pix				    (clk_pix				),
	.reset_pix					(reset_pix				),
	.i_fval						(w_fval_data_channel	),
	//  -------------------------------------------------------------------------------------
	//	frame buf ʱ����
	//  -------------------------------------------------------------------------------------
	.clk_frame_buf			    (clk_frame_buf			),
	.reset_frame_buf			(reset_frame_buf		),
	//  -------------------------------------------------------------------------------------
	//	gpif ʱ����
	//  -------------------------------------------------------------------------------------
	.clk_gpif			        (clk_gpif				),
	.reset_gpif					(reset_gpif				),
	//  ===============================================================================================
	//	���������ǼĴ���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ͨ��
	//  -------------------------------------------------------------------------------------
	.o_stream_enable_pix		(w_stream_enable_pix		),
	.o_acquisition_start_pix	(w_acquisition_start_pix	),
	.o_stream_enable_frame_buf	(w_stream_enable_frame_buf	),
	.o_stream_enable_gpif		(w_stream_enable_gpif		),
	//  -------------------------------------------------------------------------------------
	//	clk reset top
	//  -------------------------------------------------------------------------------------
	.o_reset_sensor				(w_reset_sensor			),
	.i_sensor_reset_done		(w_sensor_reset_done	),
	//  -------------------------------------------------------------------------------------
	//	io channel
	//  -------------------------------------------------------------------------------------
	.o_trigger_mode				(w_trigger_mode			),
	.ov_trigger_source			(wv_trigger_source		),
	.o_trigger_soft				(w_trigger_soft			),
	.o_trigger_active			(w_trigger_active		),
	.ov_trigger_filter_rise		(wv_trigger_filter_rise	),
	.ov_trigger_filter_fall		(wv_trigger_filter_fall	),
	.ov_trigger_delay			(wv_trigger_delay		),
	.ov_useroutput_level		(wv_useroutput_level	),
	.o_line2_mode				(w_line2_mode			),
	.o_line3_mode				(w_line3_mode			),
	.o_line0_invert				(w_line0_invert			),
	.o_line1_invert				(w_line1_invert			),
	.o_line2_invert				(w_line2_invert			),
	.o_line3_invert				(w_line3_invert			),
	.ov_line_source1			(wv_line_source1		),
	.ov_line_source2			(wv_line_source2		),
	.ov_line_source3			(wv_line_source3		),
	.iv_line_status				(wv_line_status			),
	.ov_led_ctrl				(wv_led_ctrl			),
	//������
	.iv_linein_sel_rise_cnt		(wv_linein_sel_rise_cnt		),
	.iv_linein_sel_fall_cnt		(wv_linein_sel_fall_cnt		),
	.iv_linein_filter_rise_cnt	(wv_linein_filter_rise_cnt	),
	.iv_linein_filter_fall_cnt	(wv_linein_filter_fall_cnt	),
	.iv_linein_active_cnt		(wv_linein_active_cnt		),
	.iv_trigger_n_rise_cnt		(wv_trigger_n_rise_cnt		),
	.iv_trigger_soft_cnt		(wv_trigger_soft_cnt		),
	.iv_strobe_length_reg		(wv_strobe_length_reg		),

	//  -------------------------------------------------------------------------------------
	//	data channel
	//  -------------------------------------------------------------------------------------
	.ov_pixel_format			(wv_pixel_format				),
	.i_full_frame_state			(w_full_frame_state		    	),
	.o_encrypt_state			(w_encrypt_state				),
	.o_pulse_filter_en			(w_pulse_filter_en				),
	.ov_test_image_sel			(wv_test_image_sel		    	),
	.ov_interrupt_en			(wv_interrupt_en		    	),
	.iv_interrupt_state			(wv_interrupt_state		    	),
	.ov_interrupt_clear			(wv_interrupt_clear		    	),
	.ov_wb_offset_x_start		(wv_wb_offset_x_start	    	),
	.ov_wb_offset_width			(wv_wb_offset_width		    	),
	.ov_wb_offset_y_start		(wv_wb_offset_y_start	    	),
	.ov_wb_offset_height		(wv_wb_offset_height	    	),
	.ov_wb_gain_r				(wv_wb_gain_r			    	),
	.ov_wb_gain_g				(wv_wb_gain_g			    	),
	.ov_wb_gain_b				(wv_wb_gain_b			    	),
	.iv_wb_statis_r				(wv_wb_statis_r			    	),
	.iv_wb_statis_g				(wv_wb_statis_g			    	),
	.iv_wb_statis_b				(wv_wb_statis_b			    	),
	.iv_wb_offset_width			(wv_wb_offset_width_valid   	),
	.iv_wb_offset_height		(wv_wb_offset_height_valid  	),
	.ov_grey_offset_x_start		(wv_grey_offset_x_start	    	),
	.ov_grey_offset_width		(wv_grey_offset_width	    	),
	.ov_grey_offset_y_start		(wv_grey_offset_y_start	    	),
	.ov_grey_offset_height		(wv_grey_offset_height	    	),
	.iv_grey_statis_sum			(wv_grey_statis_sum		    	),
	.iv_grey_offset_width		(wv_grey_offset_width_valid 	),
	.iv_grey_offset_height		(wv_grey_offset_height_valid	),

	//������
	.iv_fval_state				(wv_fval_state					),

	//  -------------------------------------------------------------------------------------
	//	u3v format
	//  -------------------------------------------------------------------------------------
	.o_chunk_mode_active		(w_chunk_mode_active_pix		),
	.o_chunkid_en_ts			(w_chunkid_en_ts				),
	.o_chunkid_en_fid			(w_chunkid_en_fid				),
	.ov_chunk_size_img			(wv_chunk_size_img				),
	.ov_payload_size_pix		(wv_payload_size_pix			),
	.ov_roi_offset_x			(wv_roi_offset_x				),
	.ov_roi_offset_y			(wv_roi_offset_y				),
	.ov_roi_pic_width			(wv_roi_pic_width				),
	.ov_roi_pic_height			(wv_roi_pic_height				),
	.ov_timestamp_u3			(wv_timestamp_u3				),
	//  -------------------------------------------------------------------------------------
	//	frame buffer
	//  -------------------------------------------------------------------------------------
	.ov_payload_size_frame_buf		(wv_payload_size_frame_buf		),
	.ov_frame_buffer_depth			(wv_frame_buffer_depth			),
	.o_chunk_mode_active_frame_buf	(w_chunk_mode_active_frame_buf	),
	.i_ddr_init_done				(w_ddr_init_done				),
	.i_ddr_error					(w_ddr_error					),
	//  -------------------------------------------------------------------------------------
	//	u3 interface
	//  -------------------------------------------------------------------------------------
	.ov_si_payload_transfer_size			(wv_si_payload_transfer_size	    	),
	.ov_si_payload_transfer_count			(wv_si_payload_transfer_count	    	),
	.ov_si_payload_final_transfer1_size		(wv_si_payload_final_transfer1_size		),
	.ov_si_payload_final_transfer2_size		(wv_si_payload_final_transfer2_size		),
	.ov_payload_size_gpif					(wv_payload_size_gpif					),
	.o_chunk_mode_active_gpif				(w_chunk_mode_active_gpif				),

	//������
	.iv_gpif_state							(wv_gpif_state							)
	);

	//  ===============================================================================================
	//  io_channel����
	//  ===============================================================================================
	io_channel # (
	.TRIG_FILTER_WIDTH		(TRIG_FILTER_WIDTH		),
	.TRIG_DELAY_WIDTH		(TRIG_DELAY_WIDTH		),
	.LED_CTRL_WIDTH			(LED_CTRL_WIDTH			)
	)
	io_channel_inst(
	.clk					(clk_pix					),
	.i_trigger_mode			(w_trigger_mode				),
	.i_acquisition_start	(w_acquisition_start_pix	),
	.i_stream_enable		(w_stream_enable_pix		),
	.ov_line_status			(wv_line_status				),
	.i_line2_mode			(w_line2_mode				),
	.i_line3_mode			(w_line3_mode				),
	.i_line0_invert			(w_line0_invert				),
	.i_line1_invert			(w_line1_invert				),
	.i_line2_invert			(w_line2_invert				),
	.i_line3_invert			(w_line3_invert				),
	.iv_filter_rise			(wv_trigger_filter_rise		),
	.iv_filter_fall			(wv_trigger_filter_fall		),
	.i_trigger_soft			(w_trigger_soft				),
	.iv_trigger_source		(wv_trigger_source			),
	.i_trigger_active		(w_trigger_active			),
	.iv_trigger_delay		(wv_trigger_delay			),
	.iv_line_source1		(wv_line_source1			),
	.iv_line_source2		(wv_line_source2			),
	.iv_line_source3		(wv_line_source3			),
	.iv_useroutput_level	(wv_useroutput_level		),
	.iv_led_ctrl			(wv_led_ctrl				),
	.i_optocoupler			(i_optocoupler				),
	.iv_gpio				(iv_gpio					),
	.o_optocoupler			(o_optocoupler				),
	.ov_gpio				(ov_gpio					),
	.o_f_led_gre			(o_f_led_gre				),
	.o_f_led_red			(o_f_led_red				),
	.i_usb_slwr_n			(w_usb_wr_for_led			),
	.i_fval					(i_fval						),
	.i_lval					(i_lval						),
	.i_sensor_strobe		(i_sensor_strobe			),
	.o_trigger_n			(o_trigger_n				),

	.ov_linein_sel_rise_cnt		(wv_linein_sel_rise_cnt		),
	.ov_linein_sel_fall_cnt		(wv_linein_sel_fall_cnt		),
	.ov_linein_filter_rise_cnt	(wv_linein_filter_rise_cnt	),
	.ov_linein_filter_fall_cnt	(wv_linein_filter_fall_cnt	),
	.ov_linein_active_cnt		(wv_linein_active_cnt		),
	.ov_trigger_n_rise_cnt		(wv_trigger_n_rise_cnt		),
	.ov_trigger_soft_cnt		(wv_trigger_soft_cnt		),
	.ov_strobe_length_reg		(wv_strobe_length_reg		)

	);
	//  ===============================================================================================
	//  data_channel����
	//  ===============================================================================================
	data_channel # (
	.SENSOR_DAT_WIDTH			(SENSOR_DAT_WIDTH		),
	.WB_OFFSET_WIDTH			(WB_OFFSET_WIDTH		),
	.WB_GAIN_WIDTH				(WB_GAIN_WIDTH			),
	.WB_STATIS_WIDTH			(WB_STATIS_WIDTH		),
	.GREY_OFFSET_WIDTH			(GREY_OFFSET_WIDTH		),
	.GREY_STATIS_WIDTH			(GREY_STATIS_WIDTH		),
	.SHORT_REG_WD				(SHORT_REG_WD			),
	.REG_WD						(REG_WD					),
	.DATA_WD					(DATA_WD				)
	)
	data_channel_inst(
	.clk_sensor_pix				(clk_sensor_pix					),
	.i_fval						(i_fval							),
	.i_lval						(i_lval							),
	.iv_pix_data				(iv_pix_data					),
	.clk_pix					(clk_pix						),
	.reset_pix					(reset_pix						),
	.o_fval						(w_fval_data_channel			),
	.o_pix_data_en				(w_data_channel_dvalid			),
	.ov_pix_data				(wv_data_channel_data			),
	.i_acquisition_start		(w_acquisition_start_pix		),
	.i_stream_enable			(w_stream_enable_pix			),
	.o_full_frame_state			(w_full_frame_state				),
	.i_encrypt_state			(w_encrypt_state				),
	.i_pulse_filter_en			(w_pulse_filter_en				),
	.iv_roi_pic_width			(wv_roi_pic_width				),
	.iv_test_image_sel			(wv_test_image_sel				),
	.iv_pixel_format			(wv_pixel_format				),
	.ov_pixel_format			(wv_pixel_format_data_channel	),
	.iv_wb_offset_x_start		(wv_wb_offset_x_start			),
	.iv_wb_offset_width			(wv_wb_offset_width				),
	.iv_wb_offset_y_start		(wv_wb_offset_y_start			),
	.iv_wb_offset_height		(wv_wb_offset_height			),
	.iv_wb_gain_r				(wv_wb_gain_r					),
	.iv_wb_gain_g				(wv_wb_gain_g					),
	.iv_wb_gain_b				(wv_wb_gain_b					),
	.ov_wb_statis_r				(wv_wb_statis_r					),
	.ov_wb_statis_g				(wv_wb_statis_g					),
	.ov_wb_statis_b				(wv_wb_statis_b					),
	.ov_wb_offset_width			(wv_wb_offset_width_valid		),
	.ov_wb_offset_height		(wv_wb_offset_height_valid		),

	.iv_grey_offset_x_start		(wv_grey_offset_x_start			),
	.iv_grey_offset_width		(wv_grey_offset_width			),
	.iv_grey_offset_y_start		(wv_grey_offset_y_start			),
	.iv_grey_offset_height		(wv_grey_offset_height			),
	.ov_grey_statis_sum			(wv_grey_statis_sum				),
	.ov_grey_offset_width		(wv_grey_offset_width_valid		),
	.ov_grey_offset_height		(wv_grey_offset_height_valid	),

	.iv_interrupt_en			(wv_interrupt_en				),
	.iv_interrupt_clear			(wv_interrupt_clear				),
	.ov_interrupt_state			(wv_interrupt_state				),
	.o_interrupt				(o_usb_int						)
	);

	//  ===============================================================================================
	//  u3v_format����
	//  ===============================================================================================
	u3v_format # (
	.DATA_WD						(DATA_WD						),
	.SHORT_REG_WD 					(SHORT_REG_WD 					),
	.REG_WD 						(REG_WD 						),
	.LONG_REG_WD 					(LONG_REG_WD 					)
	)
	u3v_format_inst(
	.reset							(reset_pix						),
	.clk							(clk_pix						),
	.i_fval							(w_fval_data_channel			),
	.i_data_valid					(w_data_channel_dvalid			),
	.iv_data						(wv_data_channel_data			),
	.i_stream_enable				(w_stream_enable_pix			),
	.i_acquisition_start     		(w_acquisition_start_pix   		),
	.iv_pixel_format         		(wv_pixel_format_data_channel	),
	.i_chunk_mode_active     		(w_chunk_mode_active_pix   		),
	.i_chunkid_en_ts         		(w_chunkid_en_ts        		),
	.i_chunkid_en_fid        		(w_chunkid_en_fid       		),
	.iv_chunk_size_img       		(wv_chunk_size_img      		),
	.iv_timestamp					(wv_timestamp_u3				),
	.iv_offset_x					(wv_roi_offset_x				),
	.iv_offset_y					(wv_roi_offset_y				),
	.iv_size_x						(wv_roi_pic_width				),
	.iv_size_y						(wv_roi_pic_height				),
	.iv_trailer_size_y				({16'h0,wv_roi_pic_height}		),
	.o_trailer_flag					(w_trailer_flag					),
	.o_fval							(w_u3v_format_fval   			),
	.o_data_valid					(w_u3v_format_dvalid 			),
	.ov_data                 		(wv_u3v_format_data      		)
	);

	//  ===============================================================================================
	//  frame_buffer ����
	//  ===============================================================================================
	frame_buffer # (
	.BUF_DEPTH_WD					(BUF_DEPTH_WD				),
	.NUM_DQ_PINS					(NUM_DQ_PINS         		),
	.MEM_BANKADDR_WIDTH				(MEM_BANKADDR_WIDTH  		),
	.MEM_ADDR_WIDTH					(MEM_ADDR_WIDTH      		),
	.DDR3_MEMCLK_FREQ				(DDR3_MEMCLK_FREQ			),
	.MEM_ADDR_ORDER					("ROW_BANK_COLUMN"			),
	.SKIP_IN_TERM_CAL				(1							),
	.DDR3_MEM_DENSITY				(DDR3_MEM_DENSITY			),
	.DDR3_TCK_SPEED					(DDR3_TCK_SPEED				),
	.DDR3_SIMULATION				(DDR3_SIMULATION			),
	.DDR3_CALIB_SOFT_IP				(DDR3_CALIB_SOFT_IP			),
	.DATA_WD						(DATA_WD					),
	.REG_WD 						(REG_WD 					)
	)
	frame_buffer_inst(
	.clk_vin						(clk_pix							),
	.i_fval							(w_u3v_format_fval   				),
	.i_dval							(w_u3v_format_dvalid 				),
	.i_trailer_flag					(w_trailer_flag						),
	.iv_image_din					(wv_u3v_format_data  				),
	.i_stream_en_clk_in				(w_stream_enable_pix				),
	.clk_vout						(clk_gpif							),
	.i_buf_rd						(w_buf_rd							),
	.o_back_buf_empty				(w_back_buf_empty					),
	.ov_frame_dout					(wv_frame_buffer_data				),
	.o_frame_valid					(w_frame_buffer_dvalid				),
	.clk_frame_buf					(clk_frame_buf						),
	.reset_frame_buf				(reset_frame_buf					),
	.i_stream_en					(w_stream_enable_frame_buf			),
	.iv_frame_depth					(wv_frame_buffer_depth				),
	.iv_payload_size_frame_buf		(wv_payload_size_frame_buf[23:0]	),
	.iv_payload_size_pix			(wv_payload_size_pix[23:0]			),
	.i_chunkmodeactive				(w_chunk_mode_active_frame_buf		),
	.i_async_rst					(w_async_rst						),
	.i_sysclk_2x					(w_sysclk_2x						),
	.i_sysclk_2x_180				(w_sysclk_2x_180					),
	.i_pll_ce_0						(w_pll_ce_0							),
	.i_pll_ce_90					(w_pll_ce_90						),
	.i_mcb_drp_clk					(w_mcb_drp_clk						),
	.i_bufpll_mcb_lock				(w_bufpll_mcb_lock					),
	.o_calib_done					(w_ddr_init_done					),
	.o_wr_error						(w_wr_error							),
	.o_rd_error						(w_rd_error							),
	.mcb1_dram_dq					(mcb1_dram_dq						),
	.mcb1_dram_a         			(mcb1_dram_a         				),
	.mcb1_dram_ba        			(mcb1_dram_ba        				),
	.mcb1_dram_ras_n     			(mcb1_dram_ras_n     				),
	.mcb1_dram_cas_n     			(mcb1_dram_cas_n     				),
	.mcb1_dram_we_n      			(mcb1_dram_we_n      				),
	.mcb1_dram_odt       			(mcb1_dram_odt       				),
	.mcb1_dram_reset_n   			(mcb1_dram_reset_n   				),
	.mcb1_dram_cke       			(mcb1_dram_cke       				),
	.mcb1_dram_dm        			(mcb1_dram_dm        				),
	.mcb1_dram_udqs      			(mcb1_dram_udqs      				),
	.mcb1_dram_udqs_n    			(mcb1_dram_udqs_n    				),
	.mcb1_rzq            			(mcb1_rzq            				),
	.mcb1_dram_udm       			(mcb1_dram_udm       				),
	.mcb1_dram_dqs       			(mcb1_dram_dqs       				),
	.mcb1_dram_dqs_n     			(mcb1_dram_dqs_n     				),
	.mcb1_dram_ck        			(mcb1_dram_ck        				),
	.mcb1_dram_ck_n      			(mcb1_dram_ck_n      				)
	);

	//  ===============================================================================================
	//  u3_interface����
	//  ===============================================================================================
	u3_interface # (
	.DATA_WD      					(DATA_WD      						),
	.REG_WD 						(REG_WD 							),
	.DMA_SIZE						(DMA_SIZE							)
	)
	u3_interface_inst(
	.clk							(clk_gpif							),
	.reset							(reset_u3_interface					),
	.i_data_valid					(w_frame_buffer_dvalid				),
	.iv_data						(wv_frame_buffer_data				),
	.i_framebuffer_empty			(w_back_buf_empty					),
	.o_fifo_rd						(w_buf_rd							),
	.iv_payload_size				(wv_payload_size_gpif				),
	.i_chunkmodeactive				(w_chunk_mode_active_gpif			),
	.iv_transfer_count				(wv_si_payload_transfer_count      	),
	.iv_transfer_size				(wv_si_payload_transfer_size      	),
	.iv_transfer1_size				(wv_si_payload_final_transfer1_size	),
	.iv_transfer2_size				(wv_si_payload_final_transfer2_size	),
	.i_usb_flagb					(i_usb_flagb_n						),
	.ov_usb_fifoaddr				(ov_usb_fifoaddr					),
	.ov_usb_fifoaddr_reg			(wv_usb_fifoaddr_reg				),
	.o_usb_slwr_n					(o_usb_slwr_n						),
	.ov_usb_data					(ov_usb_data						),
	.o_usb_pktend_n					(o_usb_pktend_n						),
	.o_usb_pktend_n_for_test		(w_usb_pktend_n_for_test			),
	.o_usb_wr_for_led				(w_usb_wr_for_led					)
	);

endmodule
