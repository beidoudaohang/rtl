//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : ctrl_channel
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/12/12 10:37:21	:|  ��ʼ�汾
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

module ctrl_channel # (
	parameter				WB_OFFSET_WIDTH			= 12	,	//��ƽ��ģ��ƫ��λ�üĴ������
	parameter				WB_GAIN_WIDTH			= 11	,	//��ƽ��ģ������Ĵ������
	parameter				WB_STATIS_WIDTH			= 31	,	//��ƽ��ģ��ͳ��ֵ���
	parameter				GREY_OFFSET_WIDTH		= 12	,	//�Ҷ�ͳ��ģ��ƫ��λ�üĴ���
	parameter				GREY_STATIS_WIDTH		= 48	,	//�Ҷ�ͳ��ģ��ͳ��ֵ���
	parameter				TRIG_FILTER_WIDTH		= 19	,	//�����ź��˲�ģ��Ĵ������
	parameter				TRIG_DELAY_WIDTH		= 28	,	//�����ź���ʱģ��Ĵ������
	parameter				LED_CTRL_WIDTH			= 5		,	//LED CTRL �Ĵ������
	parameter				SHORT_REG_WD			= 16	,	//�̼Ĵ���λ��
	parameter				REG_WD					= 32	,	//�Ĵ���λ��
	parameter				LONG_REG_WD				= 64	,	//���Ĵ���λ��
	parameter				BUF_DEPTH_WD			= 4		,	//֡�����λ��,�������֧��8֡��ȣ���һλ��λλ
	parameter				REG_INIT_VALUE			= "FALSE"	//�Ĵ����Ƿ��г�ʼֵ
	)
	(
	//  ===============================================================================================
	//	�����ź�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spiʱ����
	//  -------------------------------------------------------------------------------------
	input								i_spi_clk			,	//spiʱ�ӣ������ز����� ʱ�ӵĸߵ�ƽ��������� ��ʱ������ ��3��
	input								i_spi_cs_n			,	//spiƬѡ������Ч
	input								i_spi_mosi			,	//spi��������
	output								o_spi_miso_data		,	//spi�������
	output								o_spi_miso_data_en	,	//spi miso��Ч�źţ�0-spi����mosi ��̬ 1-�������
	//  -------------------------------------------------------------------------------------
	//	40MHzʱ��
	//  -------------------------------------------------------------------------------------
	input								clk_osc_bufg		,	//40MHzʱ�ӣ�ȫ�ֻ���������ʱ���ģ��ʹ��
	input								reset_osc_bufg		,	//40MHzʱ�ӵĸ�λ�ź�
	//  -------------------------------------------------------------------------------------
	//	pix ʱ����
	//  -------------------------------------------------------------------------------------
	input								clk_pix				,	//��������ʱ�ӣ�72Mhz
	input								reset_pix			,	//��������ʱ�ӵĸ�λ�ź�
	input								i_fval				,	//clk_pixʱ���򣬳���Ч�źţ������±�������ʱ���
	//  -------------------------------------------------------------------------------------
	//	frame buf ʱ����
	//  -------------------------------------------------------------------------------------
	input								clk_frame_buf		,	//֡��ʱ��100MHz
	input								reset_frame_buf		,	//֡��ʱ�ӵĸ�λ�ź�
	//  -------------------------------------------------------------------------------------
	//	gpif ʱ����
	//  -------------------------------------------------------------------------------------
	input								clk_gpif			,	//gpif ʱ�ӣ�100MHz
	input								reset_gpif			,	//gpif ʱ�ӵĸ�λ�ź�
	//  ===============================================================================================
	//	���������ǼĴ���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ͨ��
	//  -------------------------------------------------------------------------------------
	output								o_stream_enable_pix			,	//clk_pixʱ������ʹ���ź�
	output								o_acquisition_start_pix		,	//clk_pixʱ����ͣ�����ź�
	output								o_stream_enable_frame_buf	,	//clk_frame_bufʱ������ʹ���ź�
	output								o_stream_enable_gpif		,	//clk_gpifʱ������ʹ���ź�
	//  -------------------------------------------------------------------------------------
	//	clk reset top
	//  -------------------------------------------------------------------------------------
	output								o_reset_sensor			,	//clk_osc_bufgʱ���򣬸�λSensor�Ĵ���
	input								i_sensor_reset_done		,	//clk_osc_bufgʱ����Sensor��λ��ɼĴ���
	//  -------------------------------------------------------------------------------------
	//	io channel
	//  -------------------------------------------------------------------------------------
	output								o_trigger_mode			,	//clk_pixʱ���򣬴���ģʽ�Ĵ���
	output	[3:0]						ov_trigger_source		,	//clk_pixʱ���򣬴���Դ�Ĵ���
	output								o_trigger_soft			,	//clk_pixʱ���������Ĵ���
	output								o_trigger_active		,	//clk_pixʱ���򣬴�����Ч�ؼĴ���
	output	[TRIG_FILTER_WIDTH-1:0]		ov_trigger_filter_rise	,	//clk_pixʱ���������ش����˲��Ĵ���
	output	[TRIG_FILTER_WIDTH-1:0]		ov_trigger_filter_fall	,	//clk_pixʱ�����½��ش����˲��Ĵ���
	output	[TRIG_DELAY_WIDTH-1:0]		ov_trigger_delay		,	//clk_pixʱ���򣬴����ӳټĴ���
	output	[2:0]						ov_useroutput_level		,	//clk_pixʱ�����û��Զ�������Ĵ���
	output								o_line2_mode			,	//clk_pixʱ����line2�������ģʽ�Ĵ���
	output								o_line3_mode			,	//clk_pixʱ����line3�������ģʽ�Ĵ���
	output								o_line0_invert			,	//clk_pixʱ����line0���ԼĴ���
	output								o_line1_invert			,	//clk_pixʱ����line1���ԼĴ���
	output								o_line2_invert			,	//clk_pixʱ����line2���ԼĴ���
	output								o_line3_invert			,	//clk_pixʱ����line3���ԼĴ���
	output	[2:0]						ov_line_source1			,	//clk_pixʱ����line1�����Դѡ��Ĵ���
	output	[2:0]						ov_line_source2			,	//clk_pixʱ����line2�����Դѡ��Ĵ���
	output	[2:0]						ov_line_source3			,	//clk_pixʱ����line3�����Դѡ��Ĵ���
	input	[3:0]						iv_line_status			,	//clk_pixʱ����line״̬�Ĵ���
	output	[LED_CTRL_WIDTH-1:0]		ov_led_ctrl				,	//clk_pixʱ����˫ɫ�ƿ��ƼĴ���
	
	//������
	input	[15:0]						iv_linein_sel_rise_cnt		,	//i_linein_sel�������ؼ�����
	input	[15:0]						iv_linein_sel_fall_cnt		,	//i_linein_sel���½��ؼ�����
	input	[15:0]						iv_linein_filter_rise_cnt	,	//i_linein_filter�������ؼ�����
	input	[15:0]						iv_linein_filter_fall_cnt	,	//i_linein_filter���½��ؼ�����
	input	[15:0]						iv_linein_active_cnt		,	//i_linein_active�������ؼ�����
	input	[15:0]						iv_trigger_n_rise_cnt		,	//i_trigger_n�������ؼ�����
	input	[15:0]						iv_trigger_soft_cnt			,	//i_trigger_soft�ļ�����
	input	[12:0]						iv_strobe_length_reg		,	//������strobe���

	//  -------------------------------------------------------------------------------------
	//	data channel
	//  -------------------------------------------------------------------------------------
	output	[REG_WD-1:0]				ov_pixel_format			,	//clk_pixʱ�������ظ�ʽ�Ĵ���
	input								i_full_frame_state		,	//clk_pixʱ��������֡״̬�ź�
	output								o_encrypt_state			,	//clk_dnaʱ���򣬼���״̬���ϵ�󱣳ֲ��䣬������Ϊ����
	output								o_pulse_filter_en		,	//clk_pixʱ���򣬻���У���Ĵ���
	output	[2:0]						ov_test_image_sel		,	//clk_pixʱ���򣬲���ͼѡ��Ĵ���
	output	[1:0]						ov_interrupt_en			,	//clk_pixʱ�����ж�ʹ�ܼĴ���
	input	[1:0]						iv_interrupt_state		,	//clk_pixʱ�����ж�״̬�Ĵ���
	output	[1:0]						ov_interrupt_clear		,	//clk_pixʱ�����ж�����Ĵ�����������
	output	[WB_OFFSET_WIDTH-1:0]		ov_wb_offset_x_start	,	//clk_pixʱ���򣬰�ƽ�������Ĵ���
	output	[WB_OFFSET_WIDTH-1:0]		ov_wb_offset_width		,	//clk_pixʱ���򣬰�ƽ���ȼĴ���
	output	[WB_OFFSET_WIDTH-1:0]		ov_wb_offset_y_start	,	//clk_pixʱ���򣬰�ƽ��������Ĵ���
	output	[WB_OFFSET_WIDTH-1:0]		ov_wb_offset_height		,	//clk_pixʱ���򣬰�ƽ��߶ȼĴ���
	output	[WB_GAIN_WIDTH-1:0]			ov_wb_gain_r			,	//clk_pixʱ���򣬰�ƽ����������Ĵ���
	output	[WB_GAIN_WIDTH-1:0]			ov_wb_gain_g			,	//clk_pixʱ���򣬰�ƽ���̷�������Ĵ���
	output	[WB_GAIN_WIDTH-1:0]			ov_wb_gain_b			,	//clk_pixʱ���򣬰�ƽ������������Ĵ���
	input	[WB_STATIS_WIDTH-1:0]		iv_wb_statis_r			,	//clk_pixʱ���򣬰�ƽ�������Ҷ�ֵͳ�ƼĴ���
	input	[WB_STATIS_WIDTH-1:0]		iv_wb_statis_g			,	//clk_pixʱ���򣬰�ƽ���̷����Ҷ�ֵͳ�ƼĴ���
	input	[WB_STATIS_WIDTH-1:0]		iv_wb_statis_b			,	//clk_pixʱ���򣬰�ƽ���������Ҷ�ֵͳ�ƼĴ���
	input	[WB_OFFSET_WIDTH-1:0]		iv_wb_offset_width		,	//clk_pixʱ���򣬰�ƽ���ȼĴ���
	input	[WB_OFFSET_WIDTH-1:0]		iv_wb_offset_height		,	//clk_pixʱ���򣬰�ƽ��߶ȼĴ���
	output	[GREY_OFFSET_WIDTH-1:0]		ov_grey_offset_x_start	,	//clk_pixʱ���򣬻Ҷ�ֵͳ�����������Ĵ���
	output	[GREY_OFFSET_WIDTH-1:0]		ov_grey_offset_width	,	//clk_pixʱ���򣬻Ҷ�ֵͳ�������ȼĴ���
	output	[GREY_OFFSET_WIDTH-1:0]		ov_grey_offset_y_start	,	//clk_pixʱ���򣬻Ҷ�ֵͳ������������Ĵ���
	output	[GREY_OFFSET_WIDTH-1:0]		ov_grey_offset_height	,	//clk_pixʱ���򣬻Ҷ�ֵͳ������߶ȼĴ���
	input	[GREY_STATIS_WIDTH-1:0]		iv_grey_statis_sum		,	//clk_pixʱ���򣬵ĻҶ�ֵͳ�ƼĴ�������Ҷ�ͳ��ֵ����ͬ��һ֡
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_width	,	//clk_pixʱ���򣬻Ҷ�ֵͳ�������ȼĴ�������Ҷ�ͳ��ֵͬ��һ֡
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_height	,	//clk_pixʱ���򣬻Ҷ�ֵͳ������߶ȼĴ�������Ҷ�ͳ��ֵͬ��һ֡
	
	//������
	input	[3:0]						iv_fval_state			,	//fval ״̬
		
	//  -------------------------------------------------------------------------------------
	//	u3v format
	//  -------------------------------------------------------------------------------------
	output								o_chunk_mode_active		,	//clk_pixʱ����chunk���ؼĴ���
	output								o_chunkid_en_ts			,	//clk_pixʱ����ʱ������ؼĴ���
	output								o_chunkid_en_fid		,	//clk_pixʱ����frame id���ؼĴ���
	output	[REG_WD-1:0]				ov_chunk_size_img		,	//clk_pixʱ����chunk image��С
	output	[REG_WD-1:0]				ov_payload_size_pix		,	//clk_pixʱ�������ݵĴ�С��������ͷ��β����Э��Ҫ��64bit������ֻ����32bit���ɣ���32bit��0
	output	[SHORT_REG_WD-1:0]			ov_roi_offset_x			,	//clk_pixʱ����ͷ���е�ˮƽƫ��
	output	[SHORT_REG_WD-1:0]			ov_roi_offset_y			,	//clk_pixʱ����ͷ���еĴ�ֱƫ��
	output	[SHORT_REG_WD-1:0]			ov_roi_pic_width		,	//clk_pixʱ����ͷ���еĴ��ڿ��
	output	[SHORT_REG_WD-1:0]			ov_roi_pic_height		,	//clk_pixʱ����ͷ���еĴ��ڸ߶�
	output	[LONG_REG_WD-1:0]			ov_timestamp_u3			,	//clk_osc_bufgʱ�����ڳ��ź�����������ʱ������������4��clk_osc_bufgʱ������ȶ�����pixʱ���������8��ʱ��֮������ȶ�
	//  -------------------------------------------------------------------------------------
	//	frame buffer
	//  -------------------------------------------------------------------------------------
	output	[REG_WD-1:0]				ov_payload_size_frame_buf		,	//clk_frame_bufʱ�������ݵĴ�С��������ͷ��β����Э��Ҫ��64bit������ֻ����32bit���ɣ���32bit��0
	output	[BUF_DEPTH_WD-1:0]			ov_frame_buffer_depth			,	//clk_frame_bufʱ����֡����ȣ�2-8
	output								o_chunk_mode_active_frame_buf	,	//clk_frame_bufʱ����chunk���ؼĴ���
	input								i_ddr_init_done					,	//frame_bufferģ�������mcb_drp_clkʱ����MCB����ĳ�ʼ�������źš�
	input								i_ddr_error						,	//frame_bufferģ�������ʱ����δ֪����MCBӲ����أ�DDR�����ź�
	//  -------------------------------------------------------------------------------------
	//	u3 interface
	//  -------------------------------------------------------------------------------------
	output	[REG_WD-1:0]				ov_si_payload_transfer_size			,	//clk_gpifʱ���򣬵������ݿ��С
	output	[REG_WD-1:0]				ov_si_payload_transfer_count		,	//clk_gpifʱ���򣬵������ݿ����
	output	[REG_WD-1:0]				ov_si_payload_final_transfer1_size	,	//clk_gpifʱ����transfer1��С
	output	[REG_WD-1:0]				ov_si_payload_final_transfer2_size	,	//clk_gpifʱ����transfer2��С
	output	[REG_WD-1:0]				ov_payload_size_gpif				,	//clk_gpifʱ�������ݵĴ�С��������ͷ��β����Э��Ҫ��64bit������ֻ����32bit���ɣ���32bit��0
	output								o_chunk_mode_active_gpif			,	//clk_gpifʱ����chunk���ؼĴ���
	//������
	input	[4:0]						iv_gpif_state							//GPIF ״̬
	);

	//	ref signals

	//	-------------------------------------------------------------------------------------
	//	�̶�����
	//	-------------------------------------------------------------------------------------
	localparam			SPI_CMD_LENGTH		= 8			;	//spi ����ĳ���
	localparam			SPI_CMD_WR			= 8'h80		;	//spi д����
	localparam			SPI_CMD_RD			= 8'h81		;	//spi ������
	localparam			SPI_ADDR_LENGTH		= 16		;	//spi ��ַ�ĳ���

	wire							clk_spi_sample		;	//spi ����ʱ��
	wire							w_wr_en				;	//spi_slave�����clk_sampleʱ����дʹ��
	wire							w_rd_en				;	//spi_slave�����clk_sampleʱ���򣬶�ʹ��
	wire							w_cmd_is_rd			;	//spi_slave�����clk_sampleʱ���򣬶���������
	wire	[SPI_ADDR_LENGTH-1:0]	wv_addr				;	//spi_slave�����clk_sampleʱ���򣬶�д��ַ
	wire	[SHORT_REG_WD-1:0]		wv_wr_data			;	//spi_slave�����clk_sampleʱ����д����

	wire							w_pix_sel			;	//pix ʱ����ѡ���ź�
	wire	[SHORT_REG_WD-1:0]		wv_pix_rd_data		;	//pix ʱ�����������
	wire							w_frame_buf_sel		;	//frame buf ʱ����ѡ���ź�
	wire	[SHORT_REG_WD-1:0]		wv_frame_buf_rd_data;	//frame buf ʱ�����������
	wire							w_gpif_sel			;	//gpif ʱ����ѡ���ź�
	wire	[SHORT_REG_WD-1:0]		wv_gpif_rd_data		;	//gpif ʱ�����������
	wire							w_osc_bufg_sel		;	//osc bufg ʱ����ѡ���ź�
	wire	[SHORT_REG_WD-1:0]		wv_osc_bufg_rd_data	;	//osc bufg ʱ�����������
	wire							w_fix_sel			;	//fix ʱ����ѡ���źţ�����spi ����ʱ��
	wire	[SHORT_REG_WD-1:0]		wv_fix_rd_data		;	//fix ʱ�����������������spi ����ʱ��

	wire							w_timestamp_load	;	//mer_reg�����clk_osc_bufgʱ����ʱ��������źţ�������
	wire	[LONG_REG_WD-1:0]		wv_timestamp_reg	;	//timestamp�����clk_osc_bufgʱ����ʱ���
	wire	[LONG_REG_WD-1:0]		wv_dna_reg			;	//dna�����clk_osc_bufgʱ����dna����
	wire	[LONG_REG_WD-1:0]		wv_encrypt_reg		;	//mer_reg�����clk_osc_bufgʱ���򣬹̼����õļ���ֵ

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	ȷ��spi����ʱ��
	//	-------------------------------------------------------------------------------------
	assign	clk_spi_sample	= clk_gpif	;
	//  ===============================================================================================
	//	spi ����ģ��
	//  ===============================================================================================
	spi_slave # (
	.SPI_CMD_LENGTH			(SPI_CMD_LENGTH			),
	.SPI_CMD_WR				(SPI_CMD_WR				),
	.SPI_CMD_RD				(SPI_CMD_RD				),
	.SPI_ADDR_LENGTH		(SPI_ADDR_LENGTH		),
	.SPI_DATA_LENGTH		(SHORT_REG_WD			)
	)
	spi_slave_inst (
	.clk_spi_sample			(clk_spi_sample			),
	.i_spi_clk				(i_spi_clk				),
	.i_spi_cs_n				(i_spi_cs_n				),
	.i_spi_mosi				(i_spi_mosi				),
	.o_spi_miso_data		(o_spi_miso_data		),
	.o_spi_miso_data_en		(o_spi_miso_data_en		),
	.o_wr_en				(w_wr_en				),
	.o_rd_en				(w_rd_en				),
	.o_cmd_is_rd			(w_cmd_is_rd			),
	.ov_addr				(wv_addr				),
	.ov_wr_data				(wv_wr_data				),
	.i_pix_sel				(w_pix_sel				),
	.iv_pix_rd_data			(wv_pix_rd_data			),
	.i_frame_buf_sel		(w_frame_buf_sel		),
	.iv_frame_buf_rd_data	(wv_frame_buf_rd_data	),
	.i_gpif_sel				(w_gpif_sel				),
	.iv_gpif_rd_data		(wv_gpif_rd_data		),
	.i_osc_bufg_sel			(w_osc_bufg_sel			),
	.iv_osc_bufg_rd_data	(wv_osc_bufg_rd_data	),
	.i_fix_sel				(w_fix_sel				),
	.iv_fix_rd_data			(wv_fix_rd_data			)
	);

	//  ===============================================================================================
	//	reg �б�
	//  ===============================================================================================
	mer_reg # (
	.SPI_ADDR_LENGTH		(SPI_ADDR_LENGTH		),
	.WB_OFFSET_WIDTH		(WB_OFFSET_WIDTH		),
	.WB_GAIN_WIDTH			(WB_GAIN_WIDTH			),
	.WB_STATIS_WIDTH		(WB_STATIS_WIDTH		),
	.GREY_STATIS_WIDTH		(GREY_STATIS_WIDTH		),
	.TRIG_FILTER_WIDTH		(TRIG_FILTER_WIDTH		),
	.TRIG_DELAY_WIDTH		(TRIG_DELAY_WIDTH		),
	.LED_CTRL_WIDTH			(LED_CTRL_WIDTH			),
	.SHORT_REG_WD			(SHORT_REG_WD			),
	.REG_WD					(REG_WD					),
	.LONG_REG_WD			(LONG_REG_WD			),
	.BUF_DEPTH_WD			(BUF_DEPTH_WD			),
	.REG_INIT_VALUE			(REG_INIT_VALUE			)
	)
	mer_reg_inst (
	//  ===============================================================================================
	//	�����ź�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spiʱ����
	//  -------------------------------------------------------------------------------------
	.i_wr_en						(w_wr_en				),
	.i_rd_en						(w_rd_en				),
	.i_cmd_is_rd					(w_cmd_is_rd			),
	.iv_addr						(wv_addr				),
	.iv_wr_data						(wv_wr_data				),
	//  -------------------------------------------------------------------------------------
	//	pix ʱ����
	//  -------------------------------------------------------------------------------------
	.clk_pix						(clk_pix				),
	.reset_pix						(reset_pix				),
	.o_pix_sel						(w_pix_sel				),
	.ov_pix_rd_data					(wv_pix_rd_data			),
	//  -------------------------------------------------------------------------------------
	//	frame buf ʱ����
	//  -------------------------------------------------------------------------------------
	.clk_frame_buf					(clk_frame_buf			),
	.reset_frame_buf				(reset_frame_buf		),
	.o_frame_buf_sel				(w_frame_buf_sel		),
	.ov_frame_buf_rd_data			(wv_frame_buf_rd_data	),
	//  -------------------------------------------------------------------------------------
	//	gpif ʱ����
	//  -------------------------------------------------------------------------------------
	.clk_gpif						(clk_gpif				),
	.reset_gpif						(reset_gpif				),
	.o_gpif_sel						(w_gpif_sel				),
	.ov_gpif_rd_data				(wv_gpif_rd_data		),
	//  -------------------------------------------------------------------------------------
	//	40MHz ʱ����
	//  -------------------------------------------------------------------------------------
	.clk_osc_bufg					(clk_osc_bufg			),
	.reset_osc_bufg					(reset_osc_bufg			),
	.o_osc_bufg_sel					(w_osc_bufg_sel			),
	.ov_osc_bufg_rd_data			(wv_osc_bufg_rd_data	),
	//  -------------------------------------------------------------------------------------
	//	�̶���ƽ
	//  -------------------------------------------------------------------------------------
	.o_fix_sel						(w_fix_sel				),
	.ov_fix_rd_data					(wv_fix_rd_data			),
	//  ===============================================================================================
	//	���������ǼĴ���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ͨ��
	//  -------------------------------------------------------------------------------------
	.o_stream_enable_pix			(o_stream_enable_pix		),
	.o_acquisition_start_pix		(o_acquisition_start_pix	),
	.o_stream_enable_frame_buf		(o_stream_enable_frame_buf	),
	.o_stream_enable_gpif			(o_stream_enable_gpif		),
	//  -------------------------------------------------------------------------------------
	//	clk reset top
	//  -------------------------------------------------------------------------------------
	.i_sensor_reset_done			(i_sensor_reset_done	),
	.o_reset_sensor					(o_reset_sensor			),
	//  -------------------------------------------------------------------------------------
	//	io channel
	//  -------------------------------------------------------------------------------------
	.o_trigger_mode					(o_trigger_mode			),
	.ov_trigger_source				(ov_trigger_source		),
	.o_trigger_soft					(o_trigger_soft			),
	.o_trigger_active				(o_trigger_active		),
	.ov_trigger_filter_rise			(ov_trigger_filter_rise	),
	.ov_trigger_filter_fall			(ov_trigger_filter_fall	),
	.ov_trigger_delay				(ov_trigger_delay		),
	.ov_useroutput_level			(ov_useroutput_level	),
	.o_line2_mode					(o_line2_mode			),
	.o_line3_mode					(o_line3_mode			),
	.o_line0_invert					(o_line0_invert			),
	.o_line1_invert					(o_line1_invert			),
	.o_line2_invert					(o_line2_invert			),
	.o_line3_invert					(o_line3_invert			),
	.ov_line_source1				(ov_line_source1		),
	.ov_line_source2				(ov_line_source2		),
	.ov_line_source3				(ov_line_source3		),
	.iv_line_status					(iv_line_status			),
	.ov_led_ctrl					(ov_led_ctrl			),
	
	//������
	.iv_linein_sel_rise_cnt		(iv_linein_sel_rise_cnt		),
	.iv_linein_sel_fall_cnt		(iv_linein_sel_fall_cnt		),
	.iv_linein_filter_rise_cnt	(iv_linein_filter_rise_cnt	),
	.iv_linein_filter_fall_cnt	(iv_linein_filter_fall_cnt	),
	.iv_linein_active_cnt		(iv_linein_active_cnt		),
	.iv_trigger_n_rise_cnt		(iv_trigger_n_rise_cnt		),
	.iv_trigger_soft_cnt		(iv_trigger_soft_cnt		),
	.iv_strobe_length_reg		(iv_strobe_length_reg		),

	//  -------------------------------------------------------------------------------------
	//	data channel
	//  -------------------------------------------------------------------------------------
	.ov_pixel_format				(ov_pixel_format		),
	.i_full_frame_state				(i_full_frame_state		),
	.o_pulse_filter_en				(o_pulse_filter_en		),
	.ov_test_image_sel				(ov_test_image_sel		),
	.ov_interrupt_en				(ov_interrupt_en		),
	.iv_interrupt_state				(iv_interrupt_state		),
	.ov_interrupt_clear				(ov_interrupt_clear		),
	.ov_wb_offset_x_start			(ov_wb_offset_x_start	),
	.ov_wb_offset_width				(ov_wb_offset_width		),
	.ov_wb_offset_y_start			(ov_wb_offset_y_start	),
	.ov_wb_offset_height			(ov_wb_offset_height	),
	.ov_wb_gain_r					(ov_wb_gain_r			),
	.ov_wb_gain_g					(ov_wb_gain_g			),
	.ov_wb_gain_b					(ov_wb_gain_b			),
	.iv_wb_statis_r					(iv_wb_statis_r			),
	.iv_wb_statis_g					(iv_wb_statis_g			),
	.iv_wb_statis_b					(iv_wb_statis_b			),
	.iv_wb_offset_width				(iv_wb_offset_width		),
	.iv_wb_offset_height			(iv_wb_offset_height	),
	.ov_grey_offset_x_start			(ov_grey_offset_x_start	),
	.ov_grey_offset_width			(ov_grey_offset_width	),
	.ov_grey_offset_y_start			(ov_grey_offset_y_start	),
	.ov_grey_offset_height			(ov_grey_offset_height	),
	.iv_grey_statis_sum				(iv_grey_statis_sum		),
	.iv_grey_offset_width			(iv_grey_offset_width	),
	.iv_grey_offset_height			(iv_grey_offset_height	),
	
	//������
	.iv_fval_state					(iv_fval_state			),
	
	//  -------------------------------------------------------------------------------------
	//	u3v format
	//  -------------------------------------------------------------------------------------
	.o_chunk_mode_active			(o_chunk_mode_active	),
	.o_chunkid_en_ts				(o_chunkid_en_ts		),
	.o_chunkid_en_fid				(o_chunkid_en_fid		),
	.ov_chunk_size_img				(ov_chunk_size_img		),
	.ov_payload_size_pix			(ov_payload_size_pix	),
	.ov_roi_offset_x				(ov_roi_offset_x		),
	.ov_roi_offset_y				(ov_roi_offset_y		),
	.ov_roi_pic_width				(ov_roi_pic_width		),
	.ov_roi_pic_height				(ov_roi_pic_height		),
	//  -------------------------------------------------------------------------------------
	//	frame buffer
	//  -------------------------------------------------------------------------------------
	.ov_payload_size_frame_buf			(ov_payload_size_frame_buf		),
	.ov_frame_buffer_depth				(ov_frame_buffer_depth			),
	.o_chunk_mode_active_frame_buf		(o_chunk_mode_active_frame_buf	),
	.i_ddr_init_done					(i_ddr_init_done				),
	.i_ddr_error						(i_ddr_error					),
	//  -------------------------------------------------------------------------------------
	//	u3 interface
	//  -------------------------------------------------------------------------------------
	.ov_si_payload_transfer_size		(ov_si_payload_transfer_size		),
	.ov_si_payload_transfer_count		(ov_si_payload_transfer_count		),
	.ov_si_payload_final_transfer1_size	(ov_si_payload_final_transfer1_size	),
	.ov_si_payload_final_transfer2_size	(ov_si_payload_final_transfer2_size	),
	.ov_payload_size_gpif				(ov_payload_size_gpif				),
	.o_chunk_mode_active_gpif			(o_chunk_mode_active_gpif			),
	
	//������
	.iv_gpif_state						(iv_gpif_state						),

	//  -------------------------------------------------------------------------------------
	//	ʱ��� 40MHz ʱ����
	//  -------------------------------------------------------------------------------------
	.o_timestamp_load					(w_timestamp_load		),
	.iv_timestamp						(wv_timestamp_reg		),
	//  -------------------------------------------------------------------------------------
	//	DNA 1MHz ʱ����
	//  -------------------------------------------------------------------------------------
	.iv_dna_reg							(wv_dna_reg				),
	.ov_encrypt_reg						(wv_encrypt_reg			),
	.i_encrypt_state					(o_encrypt_state		)
	);

	//  ===============================================================================================
	//	ʱ���
	//  ===============================================================================================
	timestamp # (
	.LONG_REG_WD		(LONG_REG_WD		)
	)
	timestamp_inst (
	.clk				(clk_osc_bufg		),
	.reset				(reset_osc_bufg		),
	.i_fval				(i_fval				),
	.ov_timestamp_u3	(ov_timestamp_u3	),
	.i_timestamp_load	(w_timestamp_load	),
	.ov_timestamp_reg	(wv_timestamp_reg	)
	);

	//  ===============================================================================================
	//	DNA
	//  ===============================================================================================
	dna # (
	.LONG_REG_WD		(LONG_REG_WD		),
	.REG_INIT_VALUE		(REG_INIT_VALUE		)
	)
	dna_inst (
	.clk				(clk_osc_bufg		),
	.reset				(reset_osc_bufg		),
	.ov_dna_reg			(wv_dna_reg			),
	.iv_encrypt_reg		(wv_encrypt_reg		),
	.o_encrypt_state	(o_encrypt_state	)
	);


endmodule