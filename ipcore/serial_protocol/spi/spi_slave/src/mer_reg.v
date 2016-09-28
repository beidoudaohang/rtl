//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : mer_reg
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/12/12 14:11:45	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : ��ģ������˹��������мĴ������ѼĴ�������ʱ���򻮷�Ϊ��5��ģ�飬�ֱ���
//						pixʱ����gpifʱ����frame_bufgʱ����osc_bufgʱ����͹̶�ʱ����
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

module mer_reg # (
	parameter		SPI_ADDR_LENGTH			= 16	,	//spi ��ַ�ĳ���
	parameter		WB_OFFSET_WIDTH			= 12	,	//��ƽ��ģ��ƫ��λ�üĴ������
	parameter		WB_GAIN_WIDTH			= 11	,	//��ƽ��ģ������Ĵ������
	parameter		WB_STATIS_WIDTH			= 31	,	//��ƽ��ģ��ͳ��ֵ���
	parameter		GREY_OFFSET_WIDTH		= 12	,	//�Ҷ�ͳ��ģ��ƫ��λ�üĴ���
	parameter		GREY_STATIS_WIDTH		= 48	,	//�Ҷ�ͳ��ģ��ͳ��ֵ���
	parameter		TRIG_FILTER_WIDTH		= 19	,	//�����ź��˲�ģ��Ĵ������
	parameter		TRIG_DELAY_WIDTH		= 28	,	//�����ź���ʱģ��Ĵ������
	parameter		LED_CTRL_WIDTH			= 5     ,	//LED CTRL �Ĵ������
	parameter		SHORT_REG_WD			= 16	,	//�̼Ĵ���λ��
	parameter		REG_WD					= 32	,	//�Ĵ���λ��
	parameter		LONG_REG_WD				= 64	,	//���Ĵ���λ��
	parameter		BUF_DEPTH_WD			= 4		,	//֡�����λ��,�������֧��8֡��ȣ���һλ��λλ
	parameter		REG_INIT_VALUE			= "TRUE"	//�Ĵ����Ƿ��г�ʼֵ
	)
	(
	//  ===============================================================================================
	//	�����ź�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spiʱ����
	//  -------------------------------------------------------------------------------------
	//����������ݣ���ʱ����
	input								i_wr_en					,	//дʹ�ܣ�clk_sampleʱ����
	input								i_rd_en					,	//��ʹ�ܣ�clk_sampleʱ����
	input								i_cmd_is_rd				,	//���������ˣ�clk_sampleʱ����
	input	[SPI_ADDR_LENGTH-1:0]		iv_addr					,	//��д��ַ��clk_sampleʱ����
	input	[SHORT_REG_WD-1:0]			iv_wr_data				,	//д���ݣ�clk_sampleʱ����

	//  -------------------------------------------------------------------------------------
	//	pix ʱ����
	//  -------------------------------------------------------------------------------------
	input								clk_pix					,	//��������ʱ�ӣ�72Mhz
	input								reset_pix				,	//��������ʱ�ӵĸ�λ�ź�
	output								o_pix_sel				,	//��������ʱ����ѡ��
	output	[SHORT_REG_WD-1:0]			ov_pix_rd_data			,	//������
	//  -------------------------------------------------------------------------------------
	//	frame buf ʱ����
	//  -------------------------------------------------------------------------------------
	input								clk_frame_buf			,	//֡��ʱ��100MHz
	input								reset_frame_buf			,	//֡��ʱ�ӵĸ�λ�ź�
	output								o_frame_buf_sel			,	//֡��ʱ����ѡ��
	output	[SHORT_REG_WD-1:0]			ov_frame_buf_rd_data	,	//������
	//  -------------------------------------------------------------------------------------
	//	gpif ʱ����
	//  -------------------------------------------------------------------------------------
	input								clk_gpif				,	//gpif ʱ�ӣ�100MHz
	input								reset_gpif				,	//gpif ʱ�ӵĸ�λ�ź�
	output								o_gpif_sel				,	//gpif ʱ����ѡ��
	output	[SHORT_REG_WD-1:0]			ov_gpif_rd_data			,	//������
	//  -------------------------------------------------------------------------------------
	//	40MHz ʱ����
	//  -------------------------------------------------------------------------------------
	input								clk_osc_bufg			,	//osc bufg ʱ�ӣ�40MHz
	input								reset_osc_bufg			,	//osc bufg ʱ�ӵĸ�λ�ź�
	output								o_osc_bufg_sel			,	//osc ʱ����ѡ��
	output	[SHORT_REG_WD-1:0]			ov_osc_bufg_rd_data		,	//������
	//  -------------------------------------------------------------------------------------
	//	�̶���ƽ
	//  -------------------------------------------------------------------------------------
	output								o_fix_sel				,	//�̶�ʱ����ѡ��
	output	[SHORT_REG_WD-1:0]			ov_fix_rd_data			,	//������
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
	input	[4:0]						iv_gpif_state						,	//GPIF ״̬
	
	//  -------------------------------------------------------------------------------------
	//	ʱ��� 40MHz ʱ����
	//  -------------------------------------------------------------------------------------
	output								o_timestamp_load	,	//clk_osc_bufgʱ����ʱ��������źţ�������
	input	[LONG_REG_WD-1:0]			iv_timestamp		,	//clk_osc_bufgʱ����ʱ���
	//  -------------------------------------------------------------------------------------
	//	DNA 1MHz ʱ����
	//  -------------------------------------------------------------------------------------
	input	[LONG_REG_WD-1:0]			iv_dna_reg			,	//clk_osc_bufgʱ����dna����
	output	[LONG_REG_WD-1:0]			ov_encrypt_reg		,	//clk_osc_bufgʱ���򣬹̼����õļ���ֵ
	input								i_encrypt_state			//clk_dnaʱ���򣬼���״̬
	);

	//	ref signals



	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	����ʱ����ļĴ���
	//  -------------------------------------------------------------------------------------
	pix_reg_list # (
	.SPI_ADDR_LENGTH	(SPI_ADDR_LENGTH	),
	.WB_OFFSET_WIDTH	(WB_OFFSET_WIDTH	),
	.WB_GAIN_WIDTH		(WB_GAIN_WIDTH		),
	.WB_STATIS_WIDTH	(WB_STATIS_WIDTH	),
	.GREY_OFFSET_WIDTH	(GREY_OFFSET_WIDTH	),
	.GREY_STATIS_WIDTH	(GREY_STATIS_WIDTH	),
	.TRIG_FILTER_WIDTH	(TRIG_FILTER_WIDTH	),
	.TRIG_DELAY_WIDTH	(TRIG_DELAY_WIDTH	),
	.LED_CTRL_WIDTH		(LED_CTRL_WIDTH		),
	.SHORT_REG_WD		(SHORT_REG_WD		),
	.REG_WD				(REG_WD				),
	.LONG_REG_WD		(LONG_REG_WD		),
	.REG_INIT_VALUE		(REG_INIT_VALUE		)
	)
	pix_reg_list_inst (
	//  ===============================================================================================
	//	�����ź�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spiʱ����
	//  -------------------------------------------------------------------------------------
	.i_wr_en					(i_wr_en				),
	.i_rd_en					(i_rd_en				),
	.i_cmd_is_rd				(i_cmd_is_rd			),
	.iv_addr					(iv_addr				),
	.iv_wr_data					(iv_wr_data				),
	//  -------------------------------------------------------------------------------------
	//	pix ʱ����
	//  -------------------------------------------------------------------------------------
	.clk_pix					(clk_pix				),
	.o_pix_sel					(o_pix_sel				),
	.ov_pix_rd_data				(ov_pix_rd_data			),
	//  ===============================================================================================
	//	����ʱ�����źţ���Ҫ�ͱ�ʱ������źŷ���һ���Ĵ�������
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	clk reset top
	//  -------------------------------------------------------------------------------------
	.i_sensor_reset_done		(i_sensor_reset_done	),
	//  -------------------------------------------------------------------------------------
	//	frame buffer
	//  -------------------------------------------------------------------------------------
	.i_ddr_init_done			(i_ddr_init_done		),
	.i_ddr_error				(i_ddr_error			),
	//  ===============================================================================================
	//	���������ǼĴ���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ͨ��
	//  -------------------------------------------------------------------------------------
	.o_stream_enable_pix		(o_stream_enable_pix	),
	.o_acquisition_start_pix	(o_acquisition_start_pix	),
	//  -------------------------------------------------------------------------------------
	//	io channel
	//  -------------------------------------------------------------------------------------
	.o_trigger_mode				(o_trigger_mode			),
	.ov_trigger_source			(ov_trigger_source		),
	.o_trigger_soft				(o_trigger_soft			),
	.o_trigger_active			(o_trigger_active		),
	.ov_trigger_filter_rise		(ov_trigger_filter_rise	),
	.ov_trigger_filter_fall		(ov_trigger_filter_fall	),
	.ov_trigger_delay			(ov_trigger_delay		),
	.ov_useroutput_level		(ov_useroutput_level	),
	.o_line2_mode				(o_line2_mode			),
	.o_line3_mode				(o_line3_mode			),
	.o_line0_invert				(o_line0_invert			),
	.o_line1_invert				(o_line1_invert			),
	.o_line2_invert				(o_line2_invert			),
	.o_line3_invert				(o_line3_invert			),
	.ov_line_source1			(ov_line_source1		),
	.ov_line_source2			(ov_line_source2		),
	.ov_line_source3			(ov_line_source3		),
	.iv_line_status				(iv_line_status			),
	.ov_led_ctrl				(ov_led_ctrl			),
	
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
	.ov_pixel_format			(ov_pixel_format		),
	.i_full_frame_state			(i_full_frame_state		),
	.o_pulse_filter_en			(o_pulse_filter_en		),
	.ov_test_image_sel			(ov_test_image_sel		),
	.ov_interrupt_en			(ov_interrupt_en		),
	.iv_interrupt_state			(iv_interrupt_state		),
	.ov_interrupt_clear			(ov_interrupt_clear		),
	.ov_wb_offset_x_start		(ov_wb_offset_x_start	),
	.ov_wb_offset_width			(ov_wb_offset_width		),
	.ov_wb_offset_y_start		(ov_wb_offset_y_start	),
	.ov_wb_offset_height		(ov_wb_offset_height	),
	
	//������
	.iv_fval_state				(iv_fval_state			),
	
	//  -------------------------------------------------------------------------------------
	//	u3v format
	//  -------------------------------------------------------------------------------------
	.ov_wb_gain_r				(ov_wb_gain_r			),
	.ov_wb_gain_g				(ov_wb_gain_g			),
	.ov_wb_gain_b				(ov_wb_gain_b			),
	.iv_wb_statis_r				(iv_wb_statis_r			),
	.iv_wb_statis_g				(iv_wb_statis_g			),
	.iv_wb_statis_b				(iv_wb_statis_b			),
	.iv_wb_offset_width			(iv_wb_offset_width		),
	.iv_wb_offset_height		(iv_wb_offset_height	),
	.ov_grey_offset_x_start		(ov_grey_offset_x_start	),
	.ov_grey_offset_width		(ov_grey_offset_width	),
	.ov_grey_offset_y_start		(ov_grey_offset_y_start	),
	.ov_grey_offset_height		(ov_grey_offset_height	),
	.iv_grey_statis_sum			(iv_grey_statis_sum		),
	.iv_grey_offset_width		(iv_grey_offset_width	),
	.iv_grey_offset_height		(iv_grey_offset_height	),
	//  -------------------------------------------------------------------------------------
	//	u3v format
	//  -------------------------------------------------------------------------------------
	.o_chunk_mode_active		(o_chunk_mode_active	),
	.o_chunkid_en_ts			(o_chunkid_en_ts		),
	.o_chunkid_en_fid			(o_chunkid_en_fid		),
	.ov_chunk_size_img			(ov_chunk_size_img		),
	.ov_payload_size_pix		(ov_payload_size_pix	),
	.ov_roi_offset_x			(ov_roi_offset_x		),
	.ov_roi_offset_y			(ov_roi_offset_y		),
	.ov_roi_pic_width			(ov_roi_pic_width		),
	.ov_roi_pic_height			(ov_roi_pic_height		)
	);

	//  -------------------------------------------------------------------------------------
	//	gpifʱ����ļĴ���
	//  -------------------------------------------------------------------------------------
	gpif_reg_list # (
	.SPI_ADDR_LENGTH	(SPI_ADDR_LENGTH	),
	.SHORT_REG_WD		(SHORT_REG_WD		),
	.REG_WD				(REG_WD				),
	.LONG_REG_WD		(LONG_REG_WD		),
	.REG_INIT_VALUE		(REG_INIT_VALUE		)
	)
	gpif_reg_list_inst (
	//  ===============================================================================================
	//	�����ź�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spiʱ����
	//  -------------------------------------------------------------------------------------
	.i_wr_en							(i_wr_en							),
	.i_rd_en							(i_rd_en							),
	.i_cmd_is_rd						(i_cmd_is_rd						),
	.iv_addr							(iv_addr							),
	.iv_wr_data							(iv_wr_data							),
	//  -------------------------------------------------------------------------------------
	//	gpif ʱ����
	//  -------------------------------------------------------------------------------------
	.clk_gpif							(clk_gpif							),
	.o_gpif_sel							(o_gpif_sel							),
	.ov_gpif_rd_data					(ov_gpif_rd_data					),
	//  ===============================================================================================
	//	���������ǼĴ���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ͨ��
	//  -------------------------------------------------------------------------------------
	.o_stream_enable_gpif				(o_stream_enable_gpif				),
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
	.iv_gpif_state						(iv_gpif_state						)
	);

	//  -------------------------------------------------------------------------------------
	//	frame bufʱ����ļĴ���
	//  -------------------------------------------------------------------------------------
	frame_buf_reg_list # (
	.SPI_ADDR_LENGTH				(SPI_ADDR_LENGTH				),
	.SHORT_REG_WD					(SHORT_REG_WD					),
	.REG_WD							(REG_WD							),
	.LONG_REG_WD					(LONG_REG_WD					),
	.BUF_DEPTH_WD					(BUF_DEPTH_WD					),
	.REG_INIT_VALUE					(REG_INIT_VALUE					)
	)
	frame_buf_reg_list_inst (
	//  ===============================================================================================
	//	�����ź�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spiʱ����
	//  -------------------------------------------------------------------------------------
	.i_wr_en						(i_wr_en						),
	.i_rd_en						(i_rd_en						),
	.i_cmd_is_rd					(i_cmd_is_rd					),
	.iv_addr						(iv_addr						),
	.iv_wr_data						(iv_wr_data						),
	//  -------------------------------------------------------------------------------------
	//	frame buf ʱ����
	//  -------------------------------------------------------------------------------------
	.clk_frame_buf					(clk_frame_buf					),
	.o_frame_buf_sel				(o_frame_buf_sel				),
	.ov_frame_buf_rd_data			(ov_frame_buf_rd_data			),
	//  ===============================================================================================
	//	���������ǼĴ���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ͨ��
	//  -------------------------------------------------------------------------------------
	.o_stream_enable_frame_buf		(o_stream_enable_frame_buf		),
	//  -------------------------------------------------------------------------------------
	//	frame buffer
	//  -------------------------------------------------------------------------------------
	.ov_payload_size_frame_buf		(ov_payload_size_frame_buf		),
	.ov_frame_buffer_depth			(ov_frame_buffer_depth			),
	.o_chunk_mode_active_frame_buf	(o_chunk_mode_active_frame_buf	)
	);

	//  -------------------------------------------------------------------------------------
	//	clk osc bufgʱ����ļĴ���
	//  -------------------------------------------------------------------------------------
	osc_bufg_reg_list # (
	.SPI_ADDR_LENGTH	(SPI_ADDR_LENGTH	),
	.SHORT_REG_WD		(SHORT_REG_WD		),
	.REG_WD				(REG_WD				),
	.LONG_REG_WD		(LONG_REG_WD		)
	)
	osc_bufg_reg_list_inst (
	//  ===============================================================================================
	//	�����ź�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spiʱ����
	//  -------------------------------------------------------------------------------------
	.i_wr_en				(i_wr_en			),
	.i_rd_en				(i_rd_en			),
	.i_cmd_is_rd			(i_cmd_is_rd		),
	.iv_addr				(iv_addr			),
	.iv_wr_data				(iv_wr_data			),
	//  -------------------------------------------------------------------------------------
	//	40MHz ʱ����
	//  -------------------------------------------------------------------------------------
	.clk_osc_bufg			(clk_osc_bufg		),
	.o_osc_bufg_sel			(o_osc_bufg_sel		),
	.ov_osc_bufg_rd_data	(ov_osc_bufg_rd_data),
	//  ===============================================================================================
	//	���������ǼĴ���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	clk reset top
	//  -------------------------------------------------------------------------------------
	.o_reset_sensor			(o_reset_sensor		),
	//  -------------------------------------------------------------------------------------
	//	ʱ��� 40MHz ʱ����
	//  -------------------------------------------------------------------------------------
	.o_timestamp_load		(o_timestamp_load	),
	.iv_timestamp			(iv_timestamp		),
	//  -------------------------------------------------------------------------------------
	//	clk_osc_bufgʱ����
	//  -------------------------------------------------------------------------------------
	.iv_dna_reg				(iv_dna_reg			),
	.ov_encrypt_reg			(ov_encrypt_reg		),
	.i_encrypt_state		(i_encrypt_state	)
	);

	//  -------------------------------------------------------------------------------------
	//	�̶���ƽʱ����ļĴ���
	//  -------------------------------------------------------------------------------------
	fix_reg_list # (
	.SPI_ADDR_LENGTH	(SPI_ADDR_LENGTH	),
	.SHORT_REG_WD		(SHORT_REG_WD		),
	.REG_WD				(REG_WD				),
	.LONG_REG_WD		(LONG_REG_WD		)
	)
	fix_reg_list_inst (
	//  ===============================================================================================
	//	�����ź�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spiʱ����
	//  -------------------------------------------------------------------------------------
	.i_rd_en			(i_rd_en			),
	.iv_addr			(iv_addr			),
	//  -------------------------------------------------------------------------------------
	//	�̶���ƽ
	//  -------------------------------------------------------------------------------------
	.o_fix_sel			(o_fix_sel			),
	.ov_fix_rd_data		(ov_fix_rd_data		)
	);

endmodule