//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : pix_reg_list
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/3/5 15:39:34	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : pixʱ����ļĴ����б�
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

module pix_reg_list # (
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
	parameter		LONG_REG_WD				= 64		//���Ĵ���λ��
	)
	(
	//  ===============================================================================================
	//	�����ź�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spiʱ����
	//  -------------------------------------------------------------------------------------
	input								i_wr_en				,	//дʹ�ܣ�clk_sampleʱ����
	input								i_rd_en				,	//��ʹ�ܣ�clk_sampleʱ����
	input								i_cmd_is_rd			,	//���������ˣ�clk_sampleʱ����
	input	[SPI_ADDR_LENGTH-1:0]		iv_addr				,	//��д��ַ��clk_sampleʱ����
	input	[SHORT_REG_WD-1:0]			iv_wr_data			,	//д���ݣ�clk_sampleʱ����
	//  -------------------------------------------------------------------------------------
	//	pix ʱ����
	//  -------------------------------------------------------------------------------------
	input								clk_pix				,	//����ʱ��
	output								o_pix_sel			,	//����ʱ����ѡ��
	output	[SHORT_REG_WD-1:0]			ov_pix_rd_data		,	//������

	//  ===============================================================================================
	//	����ʱ�����źţ���Ҫ�ͱ�ʱ������źŷ���һ���Ĵ�������
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	clk reset top
	//  -------------------------------------------------------------------------------------
	input								i_sensor_reset_done			,	//clk_osc_bufgʱ����Sensor��λ��ɼĴ���
	//  -------------------------------------------------------------------------------------
	//	i2c_top
	//  -------------------------------------------------------------------------------------
	output	[4:0]						ov_i2c_ram_addr		,
	output	[15:0]						ov_i2c_cmd_addr		,
	output	[15:0]						ov_i2c_cmd_data		,
	output								o_i2c_ram_wren		,
	output								o_i2c_ena			,
	input								i_state_idle		,
	//  -------------------------------------------------------------------------------------
	//	frame buffer
	//  -------------------------------------------------------------------------------------
	input								i_ddr_init_done				,	//frame_bufferģ�������mcb_drp_clkʱ����MCB����ĳ�ʼ�������źš�
	input								i_ddr_error					,	//frame_bufferģ�������ʱ����δ֪����MCBӲ����أ�DDR�����ź�
	input								i_frame_buffer_front_fifo_overflow,//֡��ǰ��FIFO��� 0:֡��ǰ��FIFOû����� 1:֡��ǰ��FIFO���ֹ����������
	//  -------------------------------------------------------------------------------------
	//	�⴮ģ��
	//  -------------------------------------------------------------------------------------
	input								i_deser_pll_lock			,	//�⴮ģ��pll_lock
	input								i_bitslip_done				,	//�⴮ģ�鲢��ʱ��ʱ����1��ʾ�߽��Ѿ�����,�̼���⵽���ź�Ϊ1֮����ܿ�ʼͼ��ɼ�
	//  ===============================================================================================
	//	���������ǼĴ���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ͨ��
	//  -------------------------------------------------------------------------------------
	output								o_stream_enable_pix			,	//clk_pixʱ������ʹ���ź�
	output								o_acquisition_start_pix		,	//clk_pixʱ����ͣ�����ź�
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
	output	[REG_WD-1:0]				ov_trigger_interval		,	//clk_pixʱ���򣬴����������λus
	input								i_sync_buffer_error			,	//sync_bufferģ������������ţ�����ͬ��phy��������lval��ͬʱ��������1
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
	output	[SHORT_REG_WD-1:0]			ov_roi_pic_height			//clk_pixʱ����ͷ���еĴ��ڸ߶�
	);

	//	ref signals
	//  ===============================================================================================
	//	���ƼĴ���
	//  ===============================================================================================
	reg		[2:0]									wr_en_shift			= 3'b0;
	wire											wr_en_rise			;
	reg		[SHORT_REG_WD:0]						data_out_reg		= {(SHORT_REG_WD+1){1'b0}};

	//  ===============================================================================================
	//	���������ǼĴ���
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------
	reg		[SHORT_REG_WD-1:0]						test_reg	= 16'h55aa;
	//  -------------------------------------------------------------------------------------
	//	ͨ��
	//  -------------------------------------------------------------------------------------
	reg												param_cfg_done			= 1'b0;
	reg												stream_enable_pix		= 1'b0;
	reg												acquisition_start_pix	= 1'b0;
	//  -------------------------------------------------------------------------------------
	//	i2c_top
	//  -------------------------------------------------------------------------------------
	reg												i2c_ena					= 1'b0	;	//1-FPGA����sensor��0-3014����sensor
	reg		[SHORT_REG_WD-1:0]						coarse_exp_time			= 16'b0	;	//���ع�ʱ��
	reg		[SHORT_REG_WD-1:0]						fine_exp_time			= 16'b0	;	//ϸ�ع�ʱ��
	reg		[SHORT_REG_WD-1:0]						line_length_pck			= 16'b0	;	//������
	reg		[SHORT_REG_WD-1:0]						frame_length_lines		= 16'b0	;	//֡����
	reg		[SHORT_REG_WD-1:0]						y_output_size			= 16'b0	;	//������ڵĸ߶�
	reg		[SHORT_REG_WD-1:0]						y_addr_start			= 16'b0	;	//������ڵ�Y���
	reg		[SHORT_REG_WD-1:0]						y_addr_end				= 16'b0	;	//������ڵ�Y�յ�
	reg		[SHORT_REG_WD-1:0]						x_output_size			= 16'b0	;	//������ڵĿ��
	reg		[SHORT_REG_WD-1:0]						x_addr_start			= 16'b0	;	//������ڵ�X���
	reg		[SHORT_REG_WD-1:0]						x_addr_end				= 16'b0	;	//������ڵ�X�յ�
	reg		[SHORT_REG_WD-1:0]						global_gain				= 16'b0	;	//����
	reg		[SHORT_REG_WD-1:0]						data_pedestal			= 16'b0	;	//�ڵ�ƽ
	reg		[SHORT_REG_WD-1:0]						reset_register			= 16'b0	;	//��λ restart �Ĵ���
	reg		[SHORT_REG_WD-1:0]						gain1					= 16'b0	;	//��������1
	reg		[SHORT_REG_WD-1:0]						gain2					= 16'b0	;	//��������2
	reg		[SHORT_REG_WD-1:0]						gain3					= 16'b0	;	//��������3

	reg												i2c_ena_lock			= 1'b0	;	//i2c_ena����ֵ
	reg												wr_en_rise_dly			= 1'b0	;	//дʹ����ʱһ�ģ�����i2c�Ĳ���
	reg												i2c_ram_addr_hit		= 1'b0	;	//i2c ram ��ַ���У�����i2c�Ĳ���
	reg												i2c_ram_wren			= 1'b0	;	//i2c ram дʹ�ܣ������i2c ram�˿�
	reg		[4:0]									i2c_ram_addr			= 5'b0	;	//i2c ram д��ַ�������i2c ram�˿�
	reg		[15:0]									i2c_cmd_addr			= 16'b0	;	//i2c ram д���ݵ�һ���֣������i2c ram�˿�
	reg		[15:0]									i2c_cmd_data			= 16'b0	;	//i2c ram д���ݵ�һ���֣������i2c ram�˿�
	//  -------------------------------------------------------------------------------------
	//	io channel
	//  -------------------------------------------------------------------------------------
	reg												trigger_mode			= 1'b0		;	//Ĭ�ϴ���ģʽ�ر�
	reg		[3:0]									trigger_source			= 4'b0001	;	//Ĭ��ѡ������
	reg												trigger_soft			= 1'b0		;
	reg												trigger_active			= 1'b1		;	//0-�½�����Ч��1��������Ч��Ĭ����������Ч
	reg		[TRIG_FILTER_WIDTH-SHORT_REG_WD-1:0]	trigger_filter_rise_h		= {(TRIG_FILTER_WIDTH-SHORT_REG_WD){1'b0}};
	reg		[TRIG_FILTER_WIDTH-SHORT_REG_WD-1:0]	trigger_filter_rise_h_group	= {(TRIG_FILTER_WIDTH-SHORT_REG_WD){1'b0}};
	reg		[SHORT_REG_WD-1:0]						trigger_filter_rise_l		= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]						trigger_filter_rise_l_group	= {SHORT_REG_WD{1'b0}};
	reg		[TRIG_FILTER_WIDTH-SHORT_REG_WD-1:0]	trigger_filter_fall_h		= {(TRIG_FILTER_WIDTH-SHORT_REG_WD){1'b0}};
	reg		[TRIG_FILTER_WIDTH-SHORT_REG_WD-1:0]	trigger_filter_fall_h_group	= {(TRIG_FILTER_WIDTH-SHORT_REG_WD){1'b0}};
	reg		[SHORT_REG_WD-1:0]						trigger_filter_fall_l		= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]						trigger_filter_fall_l_group	= {SHORT_REG_WD{1'b0}};
	reg		[TRIG_DELAY_WIDTH-SHORT_REG_WD-1:0]		trigger_delay_h			= {(TRIG_DELAY_WIDTH-SHORT_REG_WD){1'b0}};
	reg		[TRIG_DELAY_WIDTH-SHORT_REG_WD-1:0]		trigger_delay_h_group	= {(TRIG_DELAY_WIDTH-SHORT_REG_WD){1'b0}};
	reg		[SHORT_REG_WD-1:0]						trigger_delay_l			= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]						trigger_delay_l_group	= {SHORT_REG_WD{1'b0}};
	reg		[2:0]									useroutput_level		= 3'b0;
	//  -------------------------------------------------------------------------------------
	//	physic line bit define
	//	bit 0	: line mode		: 0-input	1-output
	//	bit 1	: line invert	: 0-keep	1-invert
	//	bit 4-2	: line source	: 000-no	001-strobe	010-user_output0(default)	011-user_output1	100-user_output2
	//  -------------------------------------------------------------------------------------
	reg		[4:0]						physic_line0			= 5'b00000	;	//line0 - bit0 ֻ����Ĭ��Ϊ0����˼������.bit4-2ֻ����Ĭ��Ϊ0.
	reg		[4:0]						physic_line1			= 5'b01001	;	//line1 - bit0 ֻ����Ĭ��Ϊ1����˼�����
	reg		[4:0]						physic_line2			= 5'b01000	;
	reg		[4:0]						physic_line3			= 5'b01000	;
	reg		[LED_CTRL_WIDTH-1:0]		led_ctrl				= {LED_CTRL_WIDTH{1'b0}};
	//  -------------------------------------------------------------------------------------
	//	data channel
	//  -------------------------------------------------------------------------------------
	reg		[SHORT_REG_WD-1:0]			pixel_format_h			= 16'h0108;
	reg		[SHORT_REG_WD-1:0]			pixel_format_h_group	= 16'h0108;
	reg		[SHORT_REG_WD-1:0]			pixel_format_l			= 16'h0001;
	reg		[SHORT_REG_WD-1:0]			pixel_format_l_group	= 16'h0001;
	reg									pulse_filter_en			= 1'b1;
	reg		[2:0]						test_image_sel			= 3'b0;
	reg		[1:0]						interrupt_en			= 2'b0;
	reg		[1:0]						interrupt_clear			= 2'b0;
	reg		[WB_OFFSET_WIDTH-1:0]		wb_offset_x_start		= {WB_OFFSET_WIDTH{1'b0}};
	reg		[WB_OFFSET_WIDTH-1:0]		wb_offset_width_reg		= {WB_OFFSET_WIDTH{1'b0}};	//��parameter ������һ������˼��Ϻ�׺ _reg
	reg		[WB_OFFSET_WIDTH-1:0]		wb_offset_y_start		= {WB_OFFSET_WIDTH{1'b0}};
	reg		[WB_OFFSET_WIDTH-1:0]		wb_offset_height		= {WB_OFFSET_WIDTH{1'b0}};
	reg		[WB_GAIN_WIDTH-1:0]			wb_gain_r				= 'h100;
	reg		[WB_GAIN_WIDTH-1:0]			wb_gain_g				= 'h100;
	reg		[WB_GAIN_WIDTH-1:0]			wb_gain_b				= 'h100;
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_x_start		= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_width_reg	= {GREY_OFFSET_WIDTH{1'b0}};	//��parameter ������һ������˼��Ϻ�׺ _reg
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_y_start		= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_height		= {GREY_OFFSET_WIDTH{1'b0}};

	reg		[REG_WD-1:0]				trigger_interval		= 32'd200_000;
	//  -------------------------------------------------------------------------------------
	//	u3v format
	//  -------------------------------------------------------------------------------------
	reg									chunk_mode_active		= 1'b0	;
	reg									chunkid_en_img			= 1'b1	;	//�üĴ���ֻ������Ϊ1
	reg									chunkid_en_fid			= 1'b0	;
	reg									chunkid_en_ts			= 1'b0	;
	reg		[SHORT_REG_WD-1:0]			chunk_size_img1			= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			chunk_size_img1_group	= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			chunk_size_img2			= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			chunk_size_img2_group	= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			payload_size_3			= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			payload_size_3_group	= {SHORT_REG_WD{1'b0}};


	reg		[SHORT_REG_WD-1:0]			payload_size_4			= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			payload_size_4_group	= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			trigger_interval1_group	= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			trigger_interval2_group	= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			roi_offset_x			= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			roi_offset_y			= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			roi_pic_width			= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			roi_pic_height			= {SHORT_REG_WD{1'b0}};

	//  ===============================================================================================
	//	�Ǳ�ʱ�����źţ�������ͬһ���Ĵ������У���Ҫ��ʱ������
	//  ===============================================================================================
	reg									sensor_reset_done_dly0	= 1'b0;
	reg									sensor_reset_done_dly1	= 1'b0;
	reg									ddr_error_dly0			= 1'b0;
	reg									ddr_error_dly1			= 1'b0;
	reg									ddr_init_done_dly0		= 1'b0;
	reg									ddr_init_done_dly1		= 1'b0;
	reg		[3:0]						fval_state_dly0			= 4'b0;
	reg		[3:0]						fval_state_dly1			= 4'b0;
	reg									deser_pll_lock_dly0		= 1'b0;
	reg									deser_pll_lock_dly1		= 1'b0;
	reg									bitslip_done_dly0		= 1'b0;
	reg									bitslip_done_dly1		= 1'b0;

	//  ===============================================================================================
	//	ֻ���Ĵ�������
	//  ===============================================================================================
	reg		[2:0]						cmd_is_rd_shift	= 3'b000;
	wire								cmd_is_rd_rise	;

	reg		[3:0]						line_status_latch			= 4'b0;
	reg		[WB_OFFSET_WIDTH-1:0]		wb_offset_width_latch		= {WB_OFFSET_WIDTH{1'b0}};
	reg		[WB_OFFSET_WIDTH-1:0]		wb_offset_height_latch		= {WB_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_width_latch		= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_height_latch	= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[SHORT_REG_WD-1:0]			state_latch					= {SHORT_REG_WD{1'b0}};
	reg		[1:0]						interrupt_state_latch		= 2'b0;
	reg		[WB_STATIS_WIDTH-1:0]		wb_statis_r_latch			= {WB_STATIS_WIDTH{1'b0}};
	reg		[WB_STATIS_WIDTH-1:0]		wb_statis_g_latch			= {WB_STATIS_WIDTH{1'b0}};
	reg		[WB_STATIS_WIDTH-1:0]		wb_statis_b_latch			= {WB_STATIS_WIDTH{1'b0}};
	reg		[GREY_STATIS_WIDTH-1:0]		grey_statis_sum_latch		= {GREY_STATIS_WIDTH{1'b0}};
	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------
	reg		[3:0]		fval_state_latch		= 4'b0;


	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***write process***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref write reg
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	��pix ʱ����ȡд�źŵ�������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		wr_en_shift	<= {wr_en_shift[1:0],i_wr_en};
	end
	assign	wr_en_rise	= (wr_en_shift[2:1]==2'b01) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	-- ref write reg opration
	//	�� wr_en_rise ��ʱ��iv_addr�Ѿ��ȶ�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(wr_en_rise) begin
			case(iv_addr[8:0])
				//  -------------------------------------------------------------------------------------
				//	����
				//  -------------------------------------------------------------------------------------
				9'h10	: test_reg					<= iv_wr_data[SHORT_REG_WD-1:0];
				//  -------------------------------------------------------------------------------------
				//	ͨ��
				//  -------------------------------------------------------------------------------------
				9'h20	: param_cfg_done			<= iv_wr_data[0];
				9'h30	: stream_enable_pix			<= iv_wr_data[0];
				9'h32	: acquisition_start_pix		<= iv_wr_data[0];
				//  -------------------------------------------------------------------------------------
				//	io channel
				//  -------------------------------------------------------------------------------------
				9'h50	: trigger_mode				<= iv_wr_data[0];
				9'h51	: trigger_source			<= iv_wr_data[3:0];
				9'h52	: trigger_soft				<= iv_wr_data[0];
				9'h53	: trigger_active			<= iv_wr_data[0];
				9'h54	: trigger_filter_rise_h		<= iv_wr_data[TRIG_FILTER_WIDTH-SHORT_REG_WD-1:0];
				9'h55	: trigger_filter_rise_l		<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h56	: trigger_filter_fall_h		<= iv_wr_data[TRIG_FILTER_WIDTH-SHORT_REG_WD-1:0];
				9'h57	: trigger_filter_fall_l		<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h60	: trigger_delay_h			<= iv_wr_data[TRIG_DELAY_WIDTH-SHORT_REG_WD-1:0];
				9'h61	: trigger_delay_l			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h62	: useroutput_level			<= iv_wr_data[2:0];
				9'h63	: physic_line0[1]			<= iv_wr_data[1];
				9'h64	: physic_line1[4:1]			<= iv_wr_data[4:1];
				9'h65	: physic_line2				<= iv_wr_data[4:0];
				9'h66	: physic_line3				<= iv_wr_data[4:0];
				9'h90	: led_ctrl					<= iv_wr_data[LED_CTRL_WIDTH-1:0];
				//  -------------------------------------------------------------------------------------
				//	data channel
				//  -------------------------------------------------------------------------------------
				9'h33	: pixel_format_h			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h34	: pixel_format_l			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h130	: pulse_filter_en			<= iv_wr_data[0];
				9'h39	: test_image_sel			<= iv_wr_data[2:0];
				9'h80	: interrupt_en				<= iv_wr_data[1:0];
				9'h83	: interrupt_clear			<= iv_wr_data[1:0];
				9'hf0	: wb_offset_x_start			<= iv_wr_data[WB_OFFSET_WIDTH-1:0];
				9'hf1	: wb_offset_width_reg		<= iv_wr_data[WB_OFFSET_WIDTH-1:0];
				9'hf2	: wb_offset_y_start			<= iv_wr_data[WB_OFFSET_WIDTH-1:0];
				9'hf3	: wb_offset_height			<= iv_wr_data[WB_OFFSET_WIDTH-1:0];
				9'hf4	: wb_gain_r					<= iv_wr_data[WB_GAIN_WIDTH-1:0];
				9'hf5	: wb_gain_g					<= iv_wr_data[WB_GAIN_WIDTH-1:0];
				9'hf6	: wb_gain_b					<= iv_wr_data[WB_GAIN_WIDTH-1:0];
				9'h120	: grey_offset_x_start		<= iv_wr_data[GREY_OFFSET_WIDTH-1:0];
				9'h121	: grey_offset_width_reg		<= iv_wr_data[GREY_OFFSET_WIDTH-1:0];
				9'h122	: grey_offset_y_start		<= iv_wr_data[GREY_OFFSET_WIDTH-1:0];
				9'h123	: grey_offset_height		<= iv_wr_data[GREY_OFFSET_WIDTH-1:0];
				9'h68	: trigger_interval[31:16]	<= iv_wr_data;
				9'h69	: trigger_interval[15:0]	<= iv_wr_data;
				//  -------------------------------------------------------------------------------------
				//	u3v format
				//  -------------------------------------------------------------------------------------
				9'ha0	: chunk_mode_active			<= iv_wr_data[0];
				9'ha2	: chunkid_en_fid			<= iv_wr_data[0];
				9'ha3	: chunkid_en_ts				<= iv_wr_data[0];
				9'ha4	: chunk_size_img1			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'ha5	: chunk_size_img2			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h37	: payload_size_3			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h38	: payload_size_4			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h40	: roi_offset_x				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h41	: roi_offset_y				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h42	: roi_pic_width				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h43	: roi_pic_height			<= iv_wr_data[SHORT_REG_WD-1:0];
				//  -------------------------------------------------------------------------------------
				//	i2c_top
				//  -------------------------------------------------------------------------------------
				9'h18f	: i2c_ena					<= iv_wr_data[0];
				9'h190	: coarse_exp_time			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h191	: fine_exp_time				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h192	: line_length_pck			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h193	: frame_length_lines		<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h194	: y_output_size				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h195	: y_addr_start				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h196	: y_addr_end				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h197	: x_output_size				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h198	: x_addr_start				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h199	: x_addr_end				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h19a	: global_gain				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h19b	: data_pedestal				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h19c	: reset_register			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h19d	: gain1						<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h19e	: gain2						<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h19f	: gain3						<= iv_wr_data[SHORT_REG_WD-1:0];
				default : ;
			endcase
		end
		else begin
			//������Ĵ���
			param_cfg_done		<= 1'b0;
			trigger_soft		<= 1'b0;
			interrupt_clear		<= 2'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	-- ref write i2c RAM
	//	wr_en_rise		:_______|--|___________________
	//	i2c_ena			:___|--------------------------
	//	wr_en_rise_dly	:__________|--|________________
	//	i2c_ram_addr_hit:__________|--|________________
	//	ov_i2c_ram_addr	:----------<---------->--------
	//	ov_i2c_cmd_addr	:----------<---------->--------
	//	ov_i2c_cmd_data	:----------<---------->--------
	//	o_i2c_ram_wren	:______________|--|____________
	//  -------------------------------------------------------------------------------------

	//	-------------------------------------------------------------------------------------
	//	i2c дʹ���źŴ�һ�ģ�Ŀ�����������źŶ���
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		wr_en_rise_dly	<= wr_en_rise;
	end

	//	-------------------------------------------------------------------------------------
	//	i2c ��ַ�����źš����i2c�ĵ�ַ��ramȡֵ��Χ֮�ڣ�������
	//	ֻ�е�ַ��0x190-0x19fʱ���ܲ���RAM��дʹ��
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(wr_en_rise) begin
			if(iv_addr[8:0]>9'h18f && iv_addr[8:0]<9'h1a0) begin
				i2c_ram_addr_hit	<= 1'b1;
			end
			else begin
				i2c_ram_addr_hit	<= 1'b0;
			end
		end
		else begin
			i2c_ram_addr_hit	<= 1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	i2c ram дʹ���ź�
	//	дʹ�����Ϊ1��������
	//	1.spi д��Ч
	//	2.spi д��ַ��i2c ram������֮��
	//	3.i2c_ena�Ĵ�����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		i2c_ram_wren	<= wr_en_rise_dly & i2c_ram_addr_hit & i2c_ena;
	end
	assign	o_i2c_ram_wren	= i2c_ram_wren;

	//	-------------------------------------------------------------------------------------
	//	i2c д���ݣ��� wr_en_rise ��ʱ�򣬱�������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(wr_en_rise) begin
			i2c_cmd_data	<= iv_wr_data[15:0];
		end
	end
	assign	ov_i2c_cmd_data	= i2c_cmd_data;

	//	-------------------------------------------------------------------------------------
	//	i2c д��ַ
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(wr_en_rise) begin
			//	-------------------------------------------------------------------------------------
			//	���д 0x19c �Ĵ����� ram ��ַҪ��5 ��Ϊ17
			//	-------------------------------------------------------------------------------------
			if(iv_addr[3:0]==4'hc) begin
				i2c_ram_addr[4:0]	<= iv_addr[3:0] + 5;
			end
			//	-------------------------------------------------------------------------------------
			//	���д 0x19d - 0x19f �Ĵ�����ram ��ַҪ��1 ��Ϊ 14 15 16
			//	-------------------------------------------------------------------------------------
			else if(iv_addr[3:0]==4'hd || iv_addr[3:0]==4'he || iv_addr[3:0]==4'hf) begin
				i2c_ram_addr[4:0]	<= iv_addr[3:0] + 1;
			end
			//	-------------------------------------------------------------------------------------
			//	����д���� 0x190 - 0x19b �Ĵ�����ram ��ַҪ��2 ��Ϊ 2 - 13
			//	-------------------------------------------------------------------------------------
			else begin
				i2c_ram_addr[4:0]	<= iv_addr[3:0] + 2;
			end
		end
	end
	assign	ov_i2c_ram_addr	= i2c_ram_addr;

	//  -------------------------------------------------------------------------------------
	//	RAM ���ݷֲ�
	//	��ַ		��ʼ������		˵��
	//  -------------------------------------------------------------------------------------
	//	0			00000000		RAM0��ַû���õ�
	//	1			301A801C		Sensor ��ʹ�ܣ�ʹ��HOLD����
	//	2			30120C58		�ع�ʱ��ֵ��Ĵ�������Ӧ��Sensor��ַΪ0x3012
	//	3			30140000		�ع�ʱ��ϸ���Ĵ�������Ӧ��Sensor��ַΪ0x3014
	//	4			300C15C0		�����ڣ���Ӧ��Sensor��ַΪ0x300c
	//	5			300A0EB1		֡���ڣ���Ӧ��Sensor��ַΪ0x300a
	//	6			034E0E64		���ͼ��߶ȣ���Ӧ��Sensor��ַΪ0x34e
	//	7			30020008		�߶���ʼ��ַ����Ӧ��Sensor��ַΪ0x3002
	//	8			30060E6D		�߶Ƚ�����ַ����Ӧ��Sensor��ַΪ0x3006
	//	9			034C1330		���ͼ���ȣ���Ӧ��Sensor��ַΪ0x34c
	//	10			30040008		�����ʼ��ַ����Ӧ��Sensor��ַΪ0x3004
	//	11			30081337		��Ƚ�����ַ����Ӧ��Sensor��ַΪ0x3008
	//	12			305E2001		���棬��Ӧ��Sensor��ַΪ0x305e
	//	13			301E00A8		�ڵ�ƽ����Ӧ��Sensor��ַΪ0x301e
	//	14			3ECC7368		����1��ֻ��AR1820��ʹ�ã���Ӧ��Sensor��ַΪ0x3ecc
	//	15			3F1A0F04		����2��ֻ��AR1820��ʹ�ã���Ӧ��Sensor��ַΪ0x3f1a
	//	16			3F440C0C		����3��ֻ��AR1820��ʹ�ã���Ӧ��Sensor��ַΪ0x3f44
	//	17			301A801E		���´���һ֡ͼ�񣬶�Ӧ��Sensor��ַΪ0x301a���üĴ���������ģʽ��Ҳ�ܸ�д�������ڴ���ģʽ�µ����ݱ�����0x801E
	//	18			301A001C		���HOLD�����Ӧ��Sensor��ַΪ0x301a
	//	19-31		00000000		û���õ�
	//  -------------------------------------------------------------------------------------

	//  -------------------------------------------------------------------------------------
	//	����FPGA�ڲ��Ĵ�����ַ����i2c�Ĵ����أ���Щ��ַ��RAM����˳���ŵ�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(wr_en_rise) begin
			case(iv_addr[8:0])
				9'h190	: i2c_cmd_addr	<= 16'h3012	;	//�ع�ֵ��Ĵ�����ַ��		����RAM��ַ1
				9'h191	: i2c_cmd_addr	<= 16'h3014	;	//�ع�ϸ���Ĵ�����ַ��		����RAM��ַ2
				9'h192	: i2c_cmd_addr	<= 16'h300C	;	//�����ڼĴ�����ַ��		����RAM��ַ3
				9'h193	: i2c_cmd_addr	<= 16'h300A	;	//֡���ڼĴ�����ַ��		����RAM��ַ4
				9'h194	: i2c_cmd_addr	<= 16'h34E	;	//���ͼ��߶ȼĴ�����ַ��	����RAM��ַ5
				9'h195	: i2c_cmd_addr	<= 16'h3002	;	//����ʼ��ַ�Ĵ�����ַ��	����RAM��ַ6
				9'h196	: i2c_cmd_addr	<= 16'h3006	;	//�н�����ַ�Ĵ�����ַ��	����RAM��ַ7
				9'h197	: i2c_cmd_addr	<= 16'h34C	;	//���ͼ���ȼĴ�����ַ��	����RAM��ַ8
				9'h198	: i2c_cmd_addr	<= 16'h3004	;	//����ʼ��ַ�Ĵ�����ַ��	����RAM��ַ9
				9'h199	: i2c_cmd_addr	<= 16'h3008	;	//�н�����ַ�Ĵ�����ַ��	����RAM��ַ10
				9'h19a	: i2c_cmd_addr	<= 16'h305E	;	//����Ĵ�����ַ��			����RAM��ַ11
				9'h19b	: i2c_cmd_addr	<= 16'h301E	;	//�ڵ�ƽ�Ĵ�����ַ��		����RAM��ַ12
				9'h19c	: i2c_cmd_addr	<= 16'h301A	;	//��λ�Ĵ�����ַ��			����RAM��ַ16  ***ע����������һ����ַ***
				9'h19d	: i2c_cmd_addr	<= 16'h3ECC	;	//gain1�Ĵ�����ַ��			����RAM��ַ13
				9'h19e	: i2c_cmd_addr	<= 16'h3F1A	;	//gain2�Ĵ�����ַ��			����RAM��ַ14
				9'h19f	: i2c_cmd_addr	<= 16'h3F44	;	//gain3�Ĵ�����ַ��			����RAM��ַ15
				default	: i2c_cmd_addr	<= 16'hFFFF	;
			endcase
		end
	end
	assign	ov_i2c_cmd_addr	= i2c_cmd_addr;

	//  -------------------------------------------------------------------------------------
	//	-- ref group enable
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	���ظ�ʽ������Ч
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(param_cfg_done) begin
			pixel_format_h_group	<= pixel_format_h;
			pixel_format_l_group	<= pixel_format_l;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	IO����������Ч
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(param_cfg_done) begin
			trigger_filter_rise_h_group	<= trigger_filter_rise_h;
			trigger_filter_rise_l_group	<= trigger_filter_rise_l;
			trigger_filter_fall_h_group	<= trigger_filter_fall_h;
			trigger_filter_fall_l_group	<= trigger_filter_fall_l;
			trigger_delay_h_group		<= trigger_delay_h;
			trigger_delay_l_group		<= trigger_delay_l;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	�����С������Ч
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(param_cfg_done) begin
			payload_size_3_group	<= payload_size_3;
			payload_size_4_group	<= payload_size_4;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	chunk size ������Ч
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(param_cfg_done) begin
			chunk_size_img1_group	<= chunk_size_img1;
			chunk_size_img2_group	<= chunk_size_img2;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	trigger_interval ������Ч
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(param_cfg_done) begin
			trigger_interval1_group	<= trigger_interval[31:16];
			trigger_interval2_group	<= trigger_interval[15:0];
		end
	end
	//  -------------------------------------------------------------------------------------
	//	-- ref output
	//  -------------------------------------------------------------------------------------
	assign	o_stream_enable_pix		= stream_enable_pix;
	assign	o_acquisition_start_pix	= acquisition_start_pix;
	//  -------------------------------------------------------------------------------------
	//	i2c_top
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix)begin
		if(i_state_idle)					//i2c_topģ�����ʱ����i2c_ena
		i2c_ena_lock	<=	i2c_ena;
		else
		i2c_ena_lock	<=	i2c_ena_lock;
	end
	assign	o_i2c_ena			= i2c_ena_lock;
	//  -------------------------------------------------------------------------------------
	//	io channel
	//  -------------------------------------------------------------------------------------
	assign	o_trigger_mode			= trigger_mode;
	assign	ov_trigger_source		= trigger_source;
	assign	o_trigger_soft			= trigger_soft;
	assign	o_trigger_active		= trigger_active;
	assign	ov_trigger_filter_rise	= {trigger_filter_rise_h_group,trigger_filter_rise_l_group};
	assign	ov_trigger_filter_fall	= {trigger_filter_fall_h_group,trigger_filter_fall_l_group};
	assign	ov_trigger_delay		= {trigger_delay_h_group,trigger_delay_l_group};
	assign	ov_useroutput_level		= useroutput_level;
	assign	o_line2_mode			= physic_line2[0];
	assign	o_line3_mode			= physic_line3[0];
	assign	o_line0_invert			= physic_line0[1];
	assign	o_line1_invert			= physic_line1[1];
	assign	o_line2_invert			= physic_line2[1];
	assign	o_line3_invert			= physic_line3[1];
	assign	ov_line_source1			= physic_line1[4:2];
	assign	ov_line_source2			= physic_line2[4:2];
	assign	ov_line_source3			= physic_line3[4:2];
	assign	ov_led_ctrl				= led_ctrl[LED_CTRL_WIDTH-1:0];
	//  -------------------------------------------------------------------------------------
	//	data channel
	//  -------------------------------------------------------------------------------------
	assign	ov_pixel_format			= {pixel_format_h_group,pixel_format_l_group};
	assign	o_pulse_filter_en		= pulse_filter_en;
	assign	ov_test_image_sel		= test_image_sel;
	assign	ov_interrupt_en			= interrupt_en;
	assign	ov_interrupt_clear		= interrupt_clear;
	assign	ov_wb_offset_x_start	= wb_offset_x_start;
	assign	ov_wb_offset_width		= wb_offset_width_reg;
	assign	ov_wb_offset_y_start	= wb_offset_y_start;
	assign	ov_wb_offset_height		= wb_offset_height;
	assign	ov_wb_gain_r			= wb_gain_r;
	assign	ov_wb_gain_g			= wb_gain_g;
	assign	ov_wb_gain_b			= wb_gain_b;
	assign	ov_grey_offset_x_start	= grey_offset_x_start;
	assign	ov_grey_offset_width	= grey_offset_width_reg;
	assign	ov_grey_offset_y_start	= grey_offset_y_start;
	assign	ov_grey_offset_height	= grey_offset_height;
	assign	ov_trigger_interval		= {trigger_interval1_group,trigger_interval2_group};
	//  -------------------------------------------------------------------------------------
	//	u3v format
	//  -------------------------------------------------------------------------------------
	assign	o_chunk_mode_active		= chunk_mode_active;
	assign	o_chunkid_en_ts			= chunkid_en_ts;
	assign	o_chunkid_en_fid		= chunkid_en_fid;
	assign	ov_chunk_size_img		= {chunk_size_img1_group,chunk_size_img2_group};
	assign	ov_payload_size_pix		= {payload_size_3_group,payload_size_4_group};
	assign	ov_roi_offset_x			= roi_offset_x;
	assign	ov_roi_offset_y			= roi_offset_y;
	assign	ov_roi_pic_width		= roi_pic_width;
	assign	ov_roi_pic_height		= roi_pic_height;

	//  ===============================================================================================
	//	ref ***read process***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref read reg operation
	//	��, data_out_reg ���bit˵���Ƿ�ѡ���˸�ʱ������������Ϊ�Ĵ�������
	//	�������Ǵ��첽�߼���i_rd_en iv_addr �����첽�źţ������ź��ȶ�֮�����Ҳ�ͻ��ȶ�
	//  -------------------------------------------------------------------------------------
	always @ ( * ) begin
		//������ַѡ�е�ʱ��sel����Ϊ��Ч
		if(i_rd_en) begin
			case(iv_addr[8:0])
				//  -------------------------------------------------------------------------------------
				//	����
				//  -------------------------------------------------------------------------------------
				9'h10	: data_out_reg	<= {1'b1,test_reg[SHORT_REG_WD-1:0]};
				//  -------------------------------------------------------------------------------------
				//	ͨ��
				//  -------------------------------------------------------------------------------------
				9'h20	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},param_cfg_done};
				9'h30	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},stream_enable_pix};
				9'h32	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},acquisition_start_pix};
				//  -------------------------------------------------------------------------------------
				//	io channel
				//  -------------------------------------------------------------------------------------
				9'h50	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},trigger_mode};
				9'h51	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-4){1'b0}},trigger_source[3:0]};
				9'h52	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},trigger_soft};
				9'h53	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},trigger_active};
				9'h54	: data_out_reg	<= {1'b1,{(REG_WD-TRIG_FILTER_WIDTH){1'b0}},trigger_filter_rise_h[TRIG_FILTER_WIDTH-SHORT_REG_WD-1:0]};
				9'h55	: data_out_reg	<= {1'b1,trigger_filter_rise_l[SHORT_REG_WD-1:0]};
				9'h56	: data_out_reg	<= {1'b1,{(REG_WD-TRIG_FILTER_WIDTH){1'b0}},trigger_filter_fall_h[TRIG_FILTER_WIDTH-SHORT_REG_WD-1:0]};
				9'h57	: data_out_reg	<= {1'b1,trigger_filter_fall_l[SHORT_REG_WD-1:0]};
				9'h60	: data_out_reg	<= {1'b1,{(REG_WD-TRIG_DELAY_WIDTH){1'b0}},trigger_delay_h[TRIG_DELAY_WIDTH-SHORT_REG_WD-1:0]};
				9'h61	: data_out_reg	<= {1'b1,trigger_delay_l[SHORT_REG_WD-1:0]};
				9'h62	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-3){1'b0}},useroutput_level[2:0]};
				9'h63	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-5){1'b0}},physic_line0[4:0]};
				9'h64	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-5){1'b0}},physic_line1[4:0]};
				9'h65	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-5){1'b0}},physic_line2[4:0]};
				9'h66	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-5){1'b0}},physic_line3[4:0]};
				9'h90	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-LED_CTRL_WIDTH){1'b0}},led_ctrl[LED_CTRL_WIDTH-1:0]};

				//read only
				9'h67	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-4){1'b0}},line_status_latch[3:0]};
				9'h78	: data_out_reg	<= {1'b1,{12'b0},fval_state_latch[3:0]};

				//  -------------------------------------------------------------------------------------
				//	data channel
				//  -------------------------------------------------------------------------------------
				//read write
				9'h33	: data_out_reg	<= {1'b1,pixel_format_h[SHORT_REG_WD-1:0]};
				9'h34	: data_out_reg	<= {1'b1,pixel_format_l[SHORT_REG_WD-1:0]};
				9'h130	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},pulse_filter_en};
				9'h39	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-3){1'b0}},test_image_sel[2:0]};
				9'h80	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-2){1'b0}},interrupt_en[1:0]};
				9'h83	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-2){1'b0}},interrupt_clear[1:0]};
				9'hf0	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-WB_OFFSET_WIDTH){1'b0}},wb_offset_x_start[WB_OFFSET_WIDTH-1:0]};
				9'hf1	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-WB_OFFSET_WIDTH){1'b0}},wb_offset_width_latch[WB_OFFSET_WIDTH-1:0]};
				9'hf2	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-WB_OFFSET_WIDTH){1'b0}},wb_offset_y_start[WB_OFFSET_WIDTH-1:0]};
				9'hf3	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-WB_OFFSET_WIDTH){1'b0}},wb_offset_height_latch[WB_OFFSET_WIDTH-1:0]};
				9'hf4	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-WB_GAIN_WIDTH){1'b0}},wb_gain_r[WB_GAIN_WIDTH-1:0]};
				9'hf5	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-WB_GAIN_WIDTH){1'b0}},wb_gain_g[WB_GAIN_WIDTH-1:0]};
				9'hf6	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-WB_GAIN_WIDTH){1'b0}},wb_gain_b[WB_GAIN_WIDTH-1:0]};
				9'h120	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-GREY_OFFSET_WIDTH){1'b0}},grey_offset_x_start[GREY_OFFSET_WIDTH-1:0]};
				9'h121	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-GREY_OFFSET_WIDTH){1'b0}},grey_offset_width_latch[GREY_OFFSET_WIDTH-1:0]};
				9'h122	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-GREY_OFFSET_WIDTH){1'b0}},grey_offset_y_start[GREY_OFFSET_WIDTH-1:0]};
				9'h123	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-GREY_OFFSET_WIDTH){1'b0}},grey_offset_height_latch[GREY_OFFSET_WIDTH-1:0]};
				9'h68	: data_out_reg	<= {1'b1,trigger_interval[31:16]};
				9'h69	: data_out_reg	<= {1'b1,trigger_interval[15:0]};
				//read only
				9'h31	: data_out_reg	<= {1'b1,state_latch};
				9'h82	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-2){1'b0}},interrupt_state_latch[1:0]};
				9'hf7	: data_out_reg	<= {1'b1,{(REG_WD-WB_STATIS_WIDTH){1'b0}},wb_statis_r_latch[WB_STATIS_WIDTH-1:SHORT_REG_WD]};
				9'hf8	: data_out_reg	<= {1'b1,wb_statis_r_latch[SHORT_REG_WD-1:0]};
				9'hf9	: data_out_reg	<= {1'b1,{(REG_WD-WB_STATIS_WIDTH){1'b0}},wb_statis_g_latch[WB_STATIS_WIDTH-1:SHORT_REG_WD]};
				9'hfa	: data_out_reg	<= {1'b1,wb_statis_g_latch[SHORT_REG_WD-1:0]};
				9'hfb	: data_out_reg	<= {1'b1,{(REG_WD-WB_STATIS_WIDTH){1'b0}},wb_statis_b_latch[WB_STATIS_WIDTH-1:SHORT_REG_WD]};
				9'hfc	: data_out_reg	<= {1'b1,wb_statis_b_latch[SHORT_REG_WD-1:0]};
				9'h124	: data_out_reg	<= {1'b1,{(3*SHORT_REG_WD-GREY_STATIS_WIDTH){1'b0}},grey_statis_sum_latch[GREY_STATIS_WIDTH-1:REG_WD]};	//�Ҷ�ͳ�ƽ��С��32bit
				9'h125	: data_out_reg	<= {1'b1,grey_statis_sum_latch[REG_WD-1:SHORT_REG_WD]};
				9'h126	: data_out_reg	<= {1'b1,grey_statis_sum_latch[SHORT_REG_WD-1:0]};
				//  -------------------------------------------------------------------------------------
				//	u3v format
				//  -------------------------------------------------------------------------------------
				//read write
				9'ha0	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},chunk_mode_active};
				9'ha1	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},chunkid_en_img};
				9'ha2	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},chunkid_en_fid};
				9'ha3	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},chunkid_en_ts};
				9'ha4	: data_out_reg	<= {1'b1,chunk_size_img1[SHORT_REG_WD-1:0]};
				9'ha5	: data_out_reg	<= {1'b1,chunk_size_img2[SHORT_REG_WD-1:0]};
				9'h35	: data_out_reg	<= {1'b1,{SHORT_REG_WD{1'b0}}};	//payload_size1
				9'h36	: data_out_reg	<= {1'b1,{SHORT_REG_WD{1'b0}}};	//payload_size2
				9'h37	: data_out_reg	<= {1'b1,payload_size_3[SHORT_REG_WD-1:0]};
				9'h38	: data_out_reg	<= {1'b1,payload_size_4[SHORT_REG_WD-1:0]};
				9'h40	: data_out_reg	<= {1'b1,roi_offset_x[SHORT_REG_WD-1:0]};
				9'h41	: data_out_reg	<= {1'b1,roi_offset_y[SHORT_REG_WD-1:0]};
				9'h42	: data_out_reg	<= {1'b1,roi_pic_width[SHORT_REG_WD-1:0]};
				9'h43	: data_out_reg	<= {1'b1,roi_pic_height[SHORT_REG_WD-1:0]};

				//  -------------------------------------------------------------------------------------
				//	i2c_top
				//  -------------------------------------------------------------------------------------
				//reaf only
				9'h18e	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},i2c_ena_lock};
				//read write
				9'h18f	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},i2c_ena};
				9'h190	: data_out_reg	<= {1'b1,coarse_exp_time[SHORT_REG_WD-1:0]};
				9'h191	: data_out_reg	<= {1'b1,fine_exp_time[SHORT_REG_WD-1:0]};
				9'h192	: data_out_reg	<= {1'b1,line_length_pck[SHORT_REG_WD-1:0]};
				9'h193	: data_out_reg	<= {1'b1,frame_length_lines[SHORT_REG_WD-1:0]};
				9'h194	: data_out_reg	<= {1'b1,y_output_size[SHORT_REG_WD-1:0]};
				9'h195	: data_out_reg	<= {1'b1,y_addr_start[SHORT_REG_WD-1:0]};
				9'h196	: data_out_reg	<= {1'b1,y_addr_end[SHORT_REG_WD-1:0]};
				9'h197	: data_out_reg	<= {1'b1,x_output_size[SHORT_REG_WD-1:0]};
				9'h198	: data_out_reg	<= {1'b1,x_addr_start[SHORT_REG_WD-1:0]};
				9'h199	: data_out_reg	<= {1'b1,x_addr_end[SHORT_REG_WD-1:0]};
				9'h19a	: data_out_reg	<= {1'b1,global_gain[SHORT_REG_WD-1:0]};
				9'h19b	: data_out_reg	<= {1'b1,data_pedestal[SHORT_REG_WD-1:0]};
				9'h19c	: data_out_reg	<= {1'b1,reset_register[SHORT_REG_WD-1:0]};
				9'h19d	: data_out_reg	<= {1'b1,gain1[SHORT_REG_WD-1:0]};
				9'h19e	: data_out_reg	<= {1'b1,gain2[SHORT_REG_WD-1:0]};
				9'h19f	: data_out_reg	<= {1'b1,gain3[SHORT_REG_WD-1:0]};
				default	: data_out_reg	<= {(SHORT_REG_WD+1){1'b0}};
			endcase
		end
		//����ʹ��ȡ����ʱ��sel���ܸ�λΪ0
		else begin
			data_out_reg	<= {(SHORT_REG_WD+1){1'b0}};
		end
	end
	assign	o_pix_sel		= data_out_reg[SHORT_REG_WD];
	assign	ov_pix_rd_data	= data_out_reg[SHORT_REG_WD-1:0];

	//  ===============================================================================================
	//	-- ref cross domain read
	//	������ͬһ���Ĵ������У���Ҫ��ʱ������
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	clk reset top
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		sensor_reset_done_dly0	<= 	i_sensor_reset_done;
		sensor_reset_done_dly1	<= 	sensor_reset_done_dly0;
	end

	//  -------------------------------------------------------------------------------------
	//	frame buffer
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		ddr_init_done_dly0	<= 	i_ddr_init_done;
		ddr_init_done_dly1	<= 	ddr_init_done_dly0;
	end

	always @ (posedge clk_pix) begin
		ddr_error_dly0	<= 	i_ddr_error;
		ddr_error_dly1	<= 	ddr_error_dly0;
	end

	//	-------------------------------------------------------------------------------------
	//	fval state �е�bit���� clk_pixʱ����ģ�һ�������ʱ
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		fval_state_dly0	<= iv_fval_state;
		fval_state_dly1	<= fval_state_dly0;
	end

	//	-------------------------------------------------------------------------------------
	//	�⴮ģ��pll
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		deser_pll_lock_dly0	<= i_deser_pll_lock;
		deser_pll_lock_dly1	<= deser_pll_lock_dly0;
	end

	//	-------------------------------------------------------------------------------------
	//	�⴮ģ�鲢��ʱ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		bitslip_done_dly0	<= i_bitslip_done;
		bitslip_done_dly1	<= bitslip_done_dly0;
	end

	//  ===============================================================================================
	//	-- ref read only reg-latch
	//	�ڶ�֮ǰ�������е�ֻ���Ĵ�����һ�ģ�����������
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	��ȡ�������������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		cmd_is_rd_shift	<= {cmd_is_rd_shift[1:0],i_cmd_is_rd};
	end
	assign	cmd_is_rd_rise	= (cmd_is_rd_shift[2:1]==2'b01) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	�ڶ����������������ֻ������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(cmd_is_rd_rise) begin
			line_status_latch			<= iv_line_status[3:0];
			wb_offset_width_latch		<= iv_wb_offset_width;
			wb_offset_height_latch		<= iv_wb_offset_height;
			grey_offset_width_latch		<= iv_grey_offset_width;
			grey_offset_height_latch	<= iv_grey_offset_height;
			state_latch					<= {{(SHORT_REG_WD-8){1'b0}},i_frame_buffer_front_fifo_overflow,i_sync_buffer_error,bitslip_done_dly1,deser_pll_lock_dly1,sensor_reset_done_dly1,i_full_frame_state,ddr_error_dly1,ddr_init_done_dly1};
			interrupt_state_latch		<= iv_interrupt_state;
			wb_statis_r_latch			<= iv_wb_statis_r;
			wb_statis_g_latch			<= iv_wb_statis_g;
			wb_statis_b_latch			<= iv_wb_statis_b;
			grey_statis_sum_latch		<= iv_grey_statis_sum;

			fval_state_latch			<= fval_state_dly1;
		end
	end


endmodule