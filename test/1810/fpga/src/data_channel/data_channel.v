//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : data_channel
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/12/4 13:39:53	:|  ��ʼ�汾
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

module data_channel # (
	//	-------------------------------------------------------------------------------------
	//	�⴮��صĲ���
	//	-------------------------------------------------------------------------------------
	parameter	PLL_CHECK_CLK_PERIOD_NS	= 25				,	//pll���ʱ�ӵ�����
	parameter	SER_FIRST_BIT		= "LSB"					,	//"LSB" or "MSB" , first bit to the receiver
	parameter	END_STYLE			= "LITTLE"				,	//"LITTLE" or "BIG" , "LITTLE" - {CHANNEL3 CHANNE2 CHANNEL1 CHANNEL0}. "BIG" - {CHANNEL0 CHANNEL1 CHANNEL2 CHANNEL3}.
	parameter	SER_DATA_RATE		= "DDR"					,	//"DDR" or "SDR" ����Ĵ���ʱ�Ӳ�����ʽ
	parameter	DESER_CLOCK_ARC		= "BUFPLL"				,	//"BUFPLL" or "BUFIO2" , deserializer clock achitecture
	parameter	DESER_WIDTH			= 6						,	//ÿ��ͨ���⴮��� 2-8
	parameter	CLKIN_PERIOD_PS		= 3030					,	//����ʱ��Ƶ�ʣ�PSΪ��λ��ֻ��BUFPLL��ʽ�����á�
	parameter	DATA_DELAY_TYPE		= "DIFF_PHASE_DETECTOR"	,	//"DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
	parameter	DATA_DELAY_VALUE	= 0						,	//0-255������ܳ��� 1 UI
	parameter	BITSLIP_ENABLE		= "TRUE"				,	//"TRUE" "FALSE" iserdes �ֱ߽���빦��
	parameter	PLL_RESET_SIMULATION= "FALSE"				,	//�⴮PLL��λ��ʹ�ܷ���ģʽ����λʱ���̣����ٷ���
	parameter	PHY_NUM				= 2						,	//HiSPi PHY������
	parameter	PHY_CH_NUM			= 4						,	//ÿ·HiSPi PHY����ͨ��������
	parameter	DIFF_TERM			= "TRUE"				,	//Differential Termination
	parameter	IOSTANDARD			= "LVDS_33"				,	//Specifies the I/O standard for this buffer
	//	-------------------------------------------------------------------------------------
	//	��������ͨ���Ĳ���
	//	-------------------------------------------------------------------------------------
	parameter	BAYER_PATTERN		= "GR"					,	//"GR" "RG" "GB" "BG"
	parameter	SENSOR_DAT_WIDTH	= 12					,	//sensor ���ݿ��
	parameter	WB_OFFSET_WIDTH		= 12					,	//��ƽ��ģ��ƫ��λ�üĴ������
	parameter	WB_GAIN_WIDTH		= 11					,	//��ƽ��ģ������Ĵ������
	parameter	WB_STATIS_WIDTH		= 29					,	//��ƽ��ģ��ͳ��ֵ���
	parameter	WB_RATIO			= 8						,	//��ƽ��������ӣ��˷�������Ҫ���ƶ���λ
	parameter	GREY_OFFSET_WIDTH	= 12					,	//�Ҷ�ͳ��ģ��ƫ��λ�üĴ������
	parameter	GREY_STATIS_WIDTH	= 48					,	//�Ҷ�ͳ��ģ��ͳ��ֵ���
	parameter	SHORT_REG_WD		= 16					,	//�̼Ĵ���λ��
	parameter	REG_WD				= 32					,	//�Ĵ���λ��
	parameter	DATA_WD				= 128					,	//�������λ��
	parameter	PIX_CLK_FREQ_KHZ	= 55000					,	//����ʱ��Ƶ�ʣ���λKHZ���ܶ�ģ���ø�ʱ����Ϊ��ʱ������˱���д������ʱ�ӵ�Ƶ��
	parameter	INT_TIME_INTERVAL_MS= 50					,	//�жϼ��
	parameter	TRIGGER_STATUS_INTERVAL=1100				,	//data_maskģ��trigger_status=1��ʱʱ��
	parameter	SENSOR_MAX_WIDTH	=	4912
	)
	(
	//  -------------------------------------------------------------------------------------
	//	Sensor�ӿ�
	//  -------------------------------------------------------------------------------------
	input		[PHY_NUM-1:0]		pix_clk_p				,	//�������ţ�Sensor������330MHz��HiSpi���ʱ��
	input		[PHY_NUM-1:0]		pix_clk_n				,	//�������ţ�Sensor������330MHz��HiSpi���ʱ��
	input		[PHY_CH_NUM*PHY_NUM-1:0]	iv_pix_data_p			,	//�������ţ�Sensor������HiSpi������ݽӿ�
	input		[PHY_CH_NUM*PHY_NUM-1:0]	iv_pix_data_n			,	//�������ţ�Sensor������HiSpi������ݽӿ�
	//  -------------------------------------------------------------------------------------
	//	���ʱ����
	//  -------------------------------------------------------------------------------------
	input							clk_pll_check			,	//���pll lockʱ��
	//  -------------------------------------------------------------------------------------
	//	�⴮ʱ����
	//  -------------------------------------------------------------------------------------
	output                          o_fval_deser            ,   //�⴮ʱ����hispi_if����ĳ��ź�
	output                          o_lval_deser            ,   //�⴮ʱ����hispi_if��������ź�
	output							o_trigger_mode_data_mask,	//�⴮ʱ����data_mask�����trigger_mode�ź�
	output							o_trigger_status		,	//�⴮ʱ����1-�д����ź��Ҵ���֡δ�����ϣ�0-�޴����źŻ򴥷�֡������
	//  -------------------------------------------------------------------------------------
	//	����ʱ����
	//  -------------------------------------------------------------------------------------
	input							clk_pix					,	//��������ʱ�ӣ�55Mhz��
	input							reset_pix				,	//��������ʱ�ӵĸ�λ�ź�
	output							o_fval					,	//clk_pix_2xʱ���򣬳���Ч������ͨ������ļӿ��ĳ��źš�
	output							o_pix_data_en			,	//clk_pix_2xʱ����������Ч
	output	[DATA_WD-1:0]			ov_pix_data				,	//clk_pix_2xʱ����ͼ������
	//�Ĵ�������
	input							i_trigger_start			,	//clk_pixʱ����55MHz��i2c_topģ�鿪ʼ���ʹ�������
	input							i_trigger_mode			,	//clk_pixʱ���򣬴���ģʽ�Ĵ���
	output							o_deser_pll_lock		,	//�⴮ģ��pll_lock
	output							o_bitslip_done			,	//�⴮ģ�鲢��ʱ��ʱ����1��ʾ�߽��Ѿ�����,�̼���⵽���ź�Ϊ1֮����ܿ�ʼͼ��ɼ�
	input							i_sensor_init_done		,	//clk_osc_bufgʱ����sensor�Ĵ�����ʼ�����
	input							i_acquisition_start		,	//clk_pixʱ���򣬿����źţ�0-ͣ�ɣ�1-����
	input							i_stream_enable			,	//clk_pixʱ������ʹ���źţ�0-ͣ�ɣ�1-����
	output							o_full_frame_state		,	//clk_pixʱ��������֡״̬,�üĴ���������֤ͣ��ʱ�������֡,0:ͣ��ʱ���Ѿ�������һ֡����,1:ͣ��ʱ�����ڴ���һ֡����
	input							i_encrypt_state			,	//clk_dnaʱ���򣬼���״̬���ϵ�󱣳ֲ��䣬������Ϊ����
	input							i_pulse_filter_en		,	//clk_pixʱ���򣬻���У������,0:��ʹ�ܻ���У��,1:ʹ�ܻ���У��
	input	[SHORT_REG_WD-1:0]		iv_roi_pic_width		,	//�п��
	input	[2:0]					iv_test_image_sel		,	//clk_pixʱ���򣬲���ͼѡ��Ĵ���,000:��ʵͼ,001:����ͼ��1�Ҷ�ֵ֡����,110:����ͼ��2��ֹ��б����,010:����ͼ��3������б����
	input	[REG_WD-1:0]			iv_pixel_format			,	//clk_pixʱ�������ظ�ʽ�Ĵ���
	output	[REG_WD-1:0]			ov_pixel_format			,	//clk_pixʱ���򣬸�����Ķ���ģ��ʹ�ã���֤ǰ��ģ������ݸ�ʽ��һ����
	output							o_sync_buffer_error		,	//sync_bufferģ������������ţ�����ͬ��phy��������lval��ͬʱ��������1

	input	[SHORT_REG_WD-1:0]		iv_offset_x				,	//ROI��ʼx
	input	[SHORT_REG_WD-1:0]		iv_offset_width			,	//ROI���

	input	[WB_OFFSET_WIDTH-1:0]	iv_wb_offset_x_start	,	//clk_pixʱ���򣬰�ƽ��ͳ�������x������ʼ�㣬�̼����õĸüĴ���ֵӦ���������ROI��ƫ��
	input	[WB_OFFSET_WIDTH-1:0]	iv_wb_offset_width		,	//clk_pixʱ���򣬰�ƽ��ͳ������Ŀ��
	input	[WB_OFFSET_WIDTH-1:0]	iv_wb_offset_y_start	,	//clk_pixʱ���򣬰�ƽ��ͳ�������y������ʼ�㣬�̼����õĸüĴ���ֵӦ���������ROI��ƫ��
	input	[WB_OFFSET_WIDTH-1:0]	iv_wb_offset_height		,	//clk_pixʱ���򣬰�ƽ��ͳ������ĸ߶�
	input	[WB_GAIN_WIDTH-1:0]		iv_wb_gain_r			,	//clk_pixʱ���򣬰�ƽ��R������R����С������256��Ľ����ȡֵ��Χ[0:2047]
	input	[WB_GAIN_WIDTH-1:0]		iv_wb_gain_g			,	//clk_pixʱ���򣬰�ƽ��G������G����С������256��Ľ����ȡֵ��Χ[0:2047]
	input	[WB_GAIN_WIDTH-1:0]		iv_wb_gain_b			,	//clk_pixʱ���򣬰�ƽ��B������B����С������256��Ľ����ȡֵ��Χ[0:2047]
	output	[WB_STATIS_WIDTH-1:0]	ov_wb_statis_r			,	//clk_pixʱ����������ظ�ʽΪ8bit����ֵΪͼ��R����8bitͳ��ֵ��������ظ�ʽΪ����8bit����ֵΪͼ��R������8bitͳ��ֵ��
	output	[WB_STATIS_WIDTH-1:0]	ov_wb_statis_g			,	//clk_pixʱ����������ظ�ʽΪ8bit����ֵΪͼ��G����8bitͳ��ֵ����2�Ľ����������ظ�ʽΪ����8bit����ֵΪͼ��G������8bitͳ��ֵ����2�Ľ����
	output	[WB_STATIS_WIDTH-1:0]	ov_wb_statis_b			,	//clk_pixʱ����������ظ�ʽΪ8bit����ֵΪͼ��B����8bitͳ��ֵ��������ظ�ʽΪ����8bit����ֵΪͼ��B������8bitͳ��ֵ��
	output	[WB_OFFSET_WIDTH-1:0]	ov_wb_offset_width		,	//clk_pixʱ����������ͳ�ƴ��ڣ���ƽ��ͳ������Ŀ��
	output	[WB_OFFSET_WIDTH-1:0]	ov_wb_offset_height		,	//clk_pixʱ����������ͳ�ƴ��ڣ���ƽ��ͳ������ĸ߶�

	input	[GREY_OFFSET_WIDTH-1:0]	iv_grey_offset_x_start	,	//clk_pixʱ���򣬻Ҷ�ֵͳ�������x������ʼ�㣬�̼����õĸüĴ���ֵӦ���������ROI��ƫ��
	input	[GREY_OFFSET_WIDTH-1:0]	iv_grey_offset_width	,	//clk_pixʱ���򣬻Ҷ�ֵͳ������Ŀ��
	input	[GREY_OFFSET_WIDTH-1:0]	iv_grey_offset_y_start	,	//clk_pixʱ���򣬻Ҷ�ֵͳ�������y������ʼ�㣬�̼����õĸüĴ���ֵӦ���������ROI��ƫ��
	input	[GREY_OFFSET_WIDTH-1:0]	iv_grey_offset_height	,	//clk_pixʱ���򣬻Ҷ�ֵͳ������ĸ߶�
	output	[GREY_STATIS_WIDTH-1:0]	ov_grey_statis_sum		,	//clk_pixʱ���򣬸üĴ���ֵΪͼ��Ҷ�ͳ��ֵ�ܺ͡�������ظ�ʽΪ8bit����ֵΪ����8bitͳ��ֵ��������ظ�ʽΪ10bit����ֵΪ����10bitͳ��ֵ��
	output	[GREY_OFFSET_WIDTH-1:0]	ov_grey_offset_width	,	//clk_pixʱ����������ͳ�ƴ��ڣ��Ҷ�ֵͳ������Ŀ��
	output	[GREY_OFFSET_WIDTH-1:0]	ov_grey_offset_height	,	//clk_pixʱ����������ͳ�ƴ��ڣ��Ҷ�ֵͳ������ĸ߶�

	input	[1:0]					iv_interrupt_en			,	//clk_pixʱ����bit0-2a�ж�ʹ�ܣ�bit1-��ƽ���ж�ʹ�ܡ�����Ч
	input	[1:0]					iv_interrupt_clear		,	//clk_pixʱ�����ж��������źţ�����Ч������ͨ�������㣬bit0-��2a�жϣ�bit1-���ƽ���ж�
	output	[1:0]					ov_interrupt_state		,	//clk_pixʱ�����ж�״̬�����ж�ʹ�ܶ�Ӧ������Ч��bit0-2a�ж�״̬��bit1-��ƽ���ж�״̬
	output							o_interrupt					//clk_pixʱ���򣬷����ⲿ���ж��źţ��ж�Ƶ��20Hz���¡�����Ч�����������100ns

	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	���س���
	//	-------------------------------------------------------------------------------------
	localparam	CHANNEL_NUM	=	PHY_NUM*PHY_CH_NUM;//HiSPi����ͨ��������
	//	-------------------------------------------------------------------------------------
	//	�����ź�
	//	-------------------------------------------------------------------------------------
	wire	[PHY_NUM-1:0]						clk_recover			;	//�ָ�ʱ��
	wire	[PHY_NUM-1:0]						reset_recover		;	//�ָ�ʱ�ӵĸ�λ�ź�
	wire	[DESER_WIDTH*PHY_CH_NUM-1:0]		wv_data_recover[PHY_NUM-1:0]		;	//�ָ����ݣ�����
	wire										w_interrupt_en_pll	;	//pll_reset������ж�ʹ��
	wire										w_pll_reset			;	//�⴮pll��λ�ź�
	wire										w_sync_buf_en		;	//sync buffer ʹ���ź�
	wire										w_fifo_reset		;	//sync buffer �ڲ� fifo ��λ�ź�
	wire	[PHY_NUM-1:0]						wv_clk_en_recover	;	//�ָ�ʱ��ʹ���ź�
	wire	[PHY_NUM-1:0]						wv_fval_deser		;	//hispi_if��������ź�
	wire	[PHY_NUM-1:0]						wv_lval_deser		;	//hispi_if��������ź�
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_deser	;	//hispi_if�����ͼ������
	wire	[PHY_NUM-1:0]						wv_bitslip_done		;	//�⴮ģ�鲢��ʱ��ʱ����1��ʾ�߽��Ѿ�����,�̼���⵽���ź�Ϊ1֮����ܿ�ʼͼ��ɼ�
	wire										w_fval_mask			;	//data_mask��������ź�
	wire										w_lval_mask			;	//data_mask��������ź�
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_mask	;	//data_mask�����ͼ������
	wire										w_fval_cut			;	//width_cut��������ź�
	wire										w_lval_cut			;	//width_cut��������ź�
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_cut		;	//width_cut�����ͼ������
	wire										w_fval_filter		;	//pulse_filter_1d��������ź�
	wire										w_lval_filter		;	//pulse_filter_1d��������ź�
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_filter	;	//pulse_filter_1d�����ͼ������
	wire										w_fval_sync			;	//sync_buffer��������ź�
	wire										w_lval_sync			;	//sync_buffer��������ź�
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_sync	;	//sync_buffer�����ͼ������
	wire										w_fval_ctrl			;	//stream_ctrl��������ź�
	wire										w_lval_ctrl			;	//stream_ctrl��������ź�
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_ctrl	;	//stream_ctrl�����ͼ������
	wire										w_fval_pattern		;	//test_image��������ź�
	wire										w_lval_pattern		;	//test_image��������ź�
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_pattern	;	//test_image�����ͼ������
	wire										w_fval_wb			;	//raw_wb��������ź�
	wire										w_lval_wb			;	//raw_wb��������ź�
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_wb		;	//raw_wb�����ͼ������
	wire										w_interrupt_en_wb	;	//raw_wb������ж�ʹ��
	wire										w_fval_sel			;	//pixelformat_sel��������ź�
	wire										w_lval_sel			;	//pixelformat_sel��������ź�
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_sel		;	//pixelformat_sel�����ͼ������

	wire										w_fval_grey			;	//grey_statistics��������ź�
	wire										w_interrupt_en_grey	;	//grey_statistics������ж�ʹ��

	wire	[REG_WD-1:0]						wv_pixel_format		;	//sync_buffer ��������ظ�ʽ������ͨ����ģ�鶼Ҫʹ����һ���Ĵ������Ա�֤��������ͨ��ģ�����Чʱ����ͬ
	wire	[2:0]								wv_test_image_sel	;	//sync_buffer ����Ĳ���ͼѡ��Ĵ���������ͨ����ģ�鶼Ҫʹ����һ���Ĵ������Ա�֤��������ͨ��ģ�����Чʱ����ͬ


	//	ref ARCHITECTURE

	assign	ov_pixel_format	= wv_pixel_format;
	assign  o_fval_deser    = wv_fval_deser[0];
	assign  o_lval_deser    = wv_lval_deser[0];
	//  ===============================================================================================
	//	ref 1 ������
	//  ===============================================================================================

	wire[PHY_NUM-1:0]	w_deser_pll_lock;
	genvar	i;
	generate
		for(i=0;i<PHY_NUM;i=i+1)begin:DESERi
			if(i==0) begin
				//	-------------------------------------------------------------------------------------
				//	�⴮ģ��
				//	-------------------------------------------------------------------------------------
				deserializer # (
				.DIFF_TERM			(DIFF_TERM			),
				.IOSTANDARD			(IOSTANDARD			),
				.SER_FIRST_BIT		(SER_FIRST_BIT		),
				.END_STYLE			(END_STYLE			),
				.SER_DATA_RATE		(SER_DATA_RATE		),
				.DESER_CLOCK_ARC	("BUFIO2"),//(DESER_CLOCK_ARC	),
				.CHANNEL_NUM		(PHY_CH_NUM			),
				.DESER_WIDTH		(DESER_WIDTH		),
				.CLKIN_PERIOD_PS	(CLKIN_PERIOD_PS	),
				.DATA_DELAY_TYPE	(DATA_DELAY_TYPE	),
				.DATA_DELAY_VALUE	(DATA_DELAY_VALUE	),
				.BITSLIP_ENABLE		(BITSLIP_ENABLE		)
				)
				deserializer_inst (
				.i_clk_p			(pix_clk_p[i]					),
				.i_clk_n			(pix_clk_n[i]					),
				.iv_data_p			(iv_pix_data_p[PHY_CH_NUM*(i+1)-1:PHY_CH_NUM*i]),
				.iv_data_n			(iv_pix_data_n[PHY_CH_NUM*(i+1)-1:PHY_CH_NUM*i]),
				.reset				(w_pll_reset				),
				.iv_bitslip			({PHY_CH_NUM{1'b0}}			),
				.o_bufpll_lock		(w_deser_pll_lock[i]		),
				.clk_recover		(clk_recover[i]				),
				.reset_recover		(reset_recover[i]			),
				.ov_data_recover	(wv_data_recover[i]			)
				);
			end
			else begin
				//	-------------------------------------------------------------------------------------
				//	�⴮ģ��
				//	-------------------------------------------------------------------------------------
				deserializer # (
				.DIFF_TERM			(DIFF_TERM			),
				.IOSTANDARD			(IOSTANDARD			),
				.SER_FIRST_BIT		(SER_FIRST_BIT		),
				.END_STYLE			(END_STYLE			),
				.SER_DATA_RATE		(SER_DATA_RATE		),
				.DESER_CLOCK_ARC	("BUFPLL"			),
				.CHANNEL_NUM		(PHY_CH_NUM			),
				.DESER_WIDTH		(DESER_WIDTH		),
				.CLKIN_PERIOD_PS	(CLKIN_PERIOD_PS	),
				.DATA_DELAY_TYPE	(DATA_DELAY_TYPE	),
				.DATA_DELAY_VALUE	(DATA_DELAY_VALUE	),
				.BITSLIP_ENABLE		(BITSLIP_ENABLE		)
				)
				deserializer_inst (
				.i_clk_p			(pix_clk_p[i]					),
				.i_clk_n			(pix_clk_n[i]					),
				.iv_data_p			(iv_pix_data_p[PHY_CH_NUM*(i+1)-1:PHY_CH_NUM*i]),
				.iv_data_n			(iv_pix_data_n[PHY_CH_NUM*(i+1)-1:PHY_CH_NUM*i]),
				.reset				(w_pll_reset				),
				.iv_bitslip			({PHY_CH_NUM{1'b0}}			),
				.o_bufpll_lock		(w_deser_pll_lock[i]		),
				.clk_recover		(clk_recover[i]				),
				.reset_recover		(reset_recover[i]			),
				.ov_data_recover	(wv_data_recover[i]			)
				);
			end
			//  -------------------------------------------------------------------------------------
			//	hispi ����ģ��
			//  -------------------------------------------------------------------------------------
			hispi_if # (
			.SER_FIRST_BIT			(SER_FIRST_BIT		),
			.DESER_WIDTH			(DESER_WIDTH		),
			.CHANNEL_NUM			(PHY_CH_NUM			),
			.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH	)
			)
			hispi_if_inst (
			.clk					(clk_recover[i]			),
			.reset					(reset_recover[i]		),
			.iv_data				(wv_data_recover[i]		),
			.o_first_frame_detect	(wv_bitslip_done[i]		),
			.o_clk_en				(wv_clk_en_recover[i]	),
			.o_fval					(wv_fval_deser[i]		),
			.o_lval					(wv_lval_deser[i]		),
			.ov_pix_data			(wv_pix_data_deser[SENSOR_DAT_WIDTH*PHY_CH_NUM*(i+1)-1:SENSOR_DAT_WIDTH*PHY_CH_NUM*i])
			);
		end
	endgenerate
	assign o_bitslip_done = wv_bitslip_done[1];

	//	-------------------------------------------------------------------------------------
	//	PLL ��λģ��
	//	-------------------------------------------------------------------------------------
	pll_reset # (
	.PLL_CHECK_CLK_PERIOD_NS	(PLL_CHECK_CLK_PERIOD_NS	),
	.PLL_RESET_SIMULATION		(PLL_RESET_SIMULATION		)
	)
	pll_reset_inst (
	.clk				(clk_pll_check		),
	.i_pll_lock			(o_deser_pll_lock	),
	.i_sensor_init_done	(i_sensor_init_done	),
	.o_pll_reset		(w_pll_reset		)
	);
	assign	o_deser_pll_lock	=	w_deser_pll_lock[1];

	//  -------------------------------------------------------------------------------------
	//	ͬ�����壬����Sensorʱ�����FPGAʱ����
	//  -------------------------------------------------------------------------------------
	sync_buffer # (
	.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH		),
	.PHY_NUM				(PHY_NUM				),
	.PHY_CH_NUM				(PHY_CH_NUM				)
	)
	sync_buffer_inst (
	.clk_recover			(clk_recover			),
	.reset_recover			(reset_recover			),
	.iv_clk_en				(wv_clk_en_recover		),
	.iv_fval				(wv_fval_deser			),
	.iv_lval				(wv_lval_deser			),
	.iv_pix_data			(wv_pix_data_deser		),
	.i_fifo_reset			(1'b0					),
	.clk_pix				(clk_pix				),
	.o_fval					(w_fval_sync			),
	.o_lval					(w_lval_sync			),
	.ov_pix_data			(wv_pix_data_sync		),
	.o_sync_buffer_error	(o_sync_buffer_error	)
	);

	//  -------------------------------------------------------------------------------------
	//	������ģ��
	//  -------------------------------------------------------------------------------------
	stream_ctrl # (
	.SENSOR_DAT_WIDTH			(SENSOR_DAT_WIDTH		),
	.CHANNEL_NUM				(CHANNEL_NUM			),
	.REG_WD						(REG_WD					)
	)
	stream_ctrl_inst (
	.clk						(clk_pix				),
	.i_fval				    	(w_fval_sync			),
	.i_lval						(w_lval_sync			),
	.iv_pix_data				(wv_pix_data_sync		),
	.o_fval				    	(w_fval_ctrl			),
	.o_lval						(w_lval_ctrl			),
	.ov_pix_data				(wv_pix_data_ctrl		),
	.i_acquisition_start		(i_acquisition_start	),
	.i_stream_enable			(i_stream_enable		),
	.i_encrypt_state			(i_encrypt_state		),
	.iv_pixel_format			(iv_pixel_format		),
	.iv_test_image_sel	    	(iv_test_image_sel		),
	.o_full_frame_state	    	(o_full_frame_state		),
	.ov_pixel_format			(wv_pixel_format		),
	.ov_test_image_sel	    	(wv_test_image_sel		)
	);

	//  -------------------------------------------------------------------------------------
	//	data_mask
	//	�����ɼ�ģʽ��������ͼ��
	//	�����ɼ�ģʽ��ֻͨ������֡����������ͼ������
	//  -------------------------------------------------------------------------------------
	data_mask # (
	.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH			),
	.CHANNEL_NUM			(CHANNEL_NUM				),
	.CLK_FREQ_KHZ			(PIX_CLK_FREQ_KHZ			),
	.TRIGGER_STATUS_INTERVAL(TRIGGER_STATUS_INTERVAL	)
	)
	data_mask_inst (
	.clk					(clk_pix					),
	.i_pll_lock				(o_deser_pll_lock			),
	.i_acquisition_start	(i_acquisition_start		),
	.i_stream_enable		(i_stream_enable			),
	.i_trigger_start		(i_trigger_start			),
	.i_trigger_mode			(i_trigger_mode				),
	.i_fval					(w_fval_ctrl				),
	.i_lval					(w_lval_ctrl				),
	.iv_pix_data			(wv_pix_data_ctrl			),
	.o_trigger_mode			(o_trigger_mode_data_mask	),
	.o_trigger_status		(o_trigger_status			),
	.o_fval					(w_fval_mask				),
	.o_lval					(w_lval_mask				),
	.ov_pix_data			(wv_pix_data_mask			)
	);

	//  -------------------------------------------------------------------------------------
	//	�ؿ�ģ��
	//  -------------------------------------------------------------------------------------
	width_cut # (
	.SENSOR_DAT_WIDTH			(SENSOR_DAT_WIDTH		),
	.CHANNEL_NUM				(CHANNEL_NUM			),
	.SENSOR_MAX_WIDTH			(SENSOR_MAX_WIDTH		),
	.SHORT_REG_WD				(SHORT_REG_WD			)
	)
	width_cut_inst (
	.clk						(clk_pix				),
	.i_fval				    	(w_fval_mask			),
	.i_lval				    	(w_lval_mask			),
	.iv_data					(wv_pix_data_mask		),
	.iv_offset_x			   	(iv_offset_x			),
	.iv_offset_width	    	(iv_offset_width		),
	.o_fval				    	(w_fval_cut				),
	.o_lval				    	(w_lval_cut				),
	.ov_pix_data		 		(wv_pix_data_cut		)
	);
	//  -------------------------------------------------------------------------------------
	//	�������
	//  -------------------------------------------------------------------------------------
	pulse_filter_1d # (
	.SENSOR_DAT_WIDTH			(SENSOR_DAT_WIDTH		),
	.CHANNEL_NUM				(CHANNEL_NUM			),
	.SHORT_REG_WD				(SHORT_REG_WD			)
	)                       	
	pulse_filter_1d_inst (  	
	.clk						(clk_pix				),
	.i_fval						(w_fval_cut				),
	.i_lval						(w_lval_cut				),
	.iv_pix_data				(wv_pix_data_cut		),
	.i_pulse_filter_en			(i_pulse_filter_en		), 
	.iv_roi_pic_width			(iv_roi_pic_width		),
	.o_fval						(w_fval_filter			),
	.o_lval						(w_lval_filter			),
	.ov_pix_data				(wv_pix_data_filter		)
	);

	//	//  -------------------------------------------------------------------------------------
	//	//	����ͼģ��
	//	//  -------------------------------------------------------------------------------------
	test_image # (
	.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH		),
	.CHANNEL_NUM			(CHANNEL_NUM			)
	)
	test_image_inst (
	.clk					(clk_pix				),
	.i_fval					(w_fval_filter			),
	.i_lval					(w_lval_filter			),
	.iv_pix_data			(wv_pix_data_filter		),
	.iv_test_image_sel		(wv_test_image_sel		),
	.o_fval					(w_fval_pattern			),
	.o_lval					(w_lval_pattern			),
	.ov_pix_data			(wv_pix_data_pattern	)
	);
	//	assign	w_fval_pattern			= w_fval_cut;
	//	assign	w_lval_pattern			= w_lval_cut;
	//	assign	wv_pix_data_pattern		= wv_pix_data_cut;

	//  -------------------------------------------------------------------------------------
	//	��ƽ��ģ��
	//  -------------------------------------------------------------------------------------
	raw_wb # (
	.BAYER_PATTERN			(BAYER_PATTERN			),
	.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH		),
	.CHANNEL_NUM			(CHANNEL_NUM			),
	.WB_OFFSET_WIDTH		(WB_OFFSET_WIDTH		),
	.WB_GAIN_WIDTH			(WB_GAIN_WIDTH			),
	.WB_STATIS_WIDTH		(WB_STATIS_WIDTH		),
	.WB_RATIO				(WB_RATIO				),
	.REG_WD					(REG_WD					)
	)
	raw_wb_inst (
	.clk					(clk_pix				),
	.i_fval					(w_fval_pattern			),
	.i_lval					(w_lval_pattern			),
	.iv_pix_data			(wv_pix_data_pattern	),
	.iv_test_image_sel		(wv_test_image_sel		),
	.iv_pixel_format		(wv_pixel_format		),
	.i_interrupt_en			(iv_interrupt_en[1]		),
	.o_interrupt_en			(w_interrupt_en_wb		),
	.i_interrupt_pin		(o_interrupt			),
	.iv_wb_offset_x_start	(iv_wb_offset_x_start	),
	.iv_wb_offset_width		(iv_wb_offset_width		),
	.iv_wb_offset_y_start	(iv_wb_offset_y_start	),
	.iv_wb_offset_height	(iv_wb_offset_height	),
	.iv_wb_gain_r			(iv_wb_gain_r			),
	.iv_wb_gain_g			(iv_wb_gain_g			),
	.iv_wb_gain_b			(iv_wb_gain_b			),
	.ov_wb_statis_r			(ov_wb_statis_r			),
	.ov_wb_statis_g			(ov_wb_statis_g			),
	.ov_wb_statis_b			(ov_wb_statis_b			),
	.ov_wb_offset_width		(ov_wb_offset_width		),
	.ov_wb_offset_height	(ov_wb_offset_height	),
	.o_fval					(w_fval_wb				),
	.o_lval					(w_lval_wb				),
	.ov_pix_data			(wv_pix_data_wb			)
	);

	//	assign	w_fval_wb			= w_fval_pattern;
	//	assign	w_lval_wb			= w_lval_pattern;
	//	assign	wv_pix_data_wb		= wv_pix_data_pattern;

	//  -------------------------------------------------------------------------------------
	//	����ѡ��ģ��--��ģ����ʱû���õ�������Ϊ��չ���ã����ݲ����κδ���ֱ�����
	//  -------------------------------------------------------------------------------------
	pixelformat_sel # (
	.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH		),
	.CHANNEL_NUM			(CHANNEL_NUM			),
	.REG_WD					(REG_WD					)
	)
	pixelformat_sel_inst (
	.clk					(clk_pix				),
	.i_fval					(w_fval_wb				),
	.i_lval					(w_lval_wb				),
	.iv_pix_data			(wv_pix_data_wb			),
	.iv_pixel_format		(wv_pixel_format		),
	.o_fval					(w_fval_sel				),
	.o_lval					(w_lval_sel				),
	.ov_pix_data			(wv_pix_data_sel		)
	);

	//  -------------------------------------------------------------------------------------
	//	ģ�����������λ��Ϊ128bit
	//  -------------------------------------------------------------------------------------
	data_align # (
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	),
	.CHANNEL_NUM		(CHANNEL_NUM		),
	.REG_WD				(REG_WD				),
	.DATA_WD			(DATA_WD			)
	)
	data_align_inst (
	.clk				(clk_pix			),
	.i_fval				(w_fval_sel			),
	.i_lval				(w_lval_sel			),
	.iv_pix_data		(wv_pix_data_sel	),
	.iv_pixel_format	(wv_pixel_format	),
	.o_fval				(o_fval				),
	.o_pix_data_en		(o_pix_data_en		),
	.ov_pix_data		(ov_pix_data		)
	);

	//  ===============================================================================================
	//	ref 2 ����ģ��
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	2aģ�飬ͳ�ƻҶ�ֵ
	//  -------------------------------------------------------------------------------------
	grey_statistics # (
	.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH	),
	.CHANNEL_NUM			(CHANNEL_NUM		),
	.GREY_OFFSET_WIDTH		(GREY_OFFSET_WIDTH	),
	.GREY_STATIS_WIDTH		(GREY_STATIS_WIDTH	),
	.REG_WD					(REG_WD				)
	)
	grey_statistics_inst (
	.clk					(clk_pix				),
	.i_fval					(w_fval_sel				),
	.i_lval					(w_lval_sel				),
	.iv_pix_data			(wv_pix_data_sel		),
	.i_interrupt_en			(iv_interrupt_en[0]		),
	.iv_test_image_sel		(wv_test_image_sel		),
	.iv_grey_offset_x_start	(iv_grey_offset_x_start	),
	.iv_grey_offset_width	(iv_grey_offset_width	),
	.iv_grey_offset_y_start	(iv_grey_offset_y_start	),
	.iv_grey_offset_height	(iv_grey_offset_height	),
	.ov_grey_statis_sum		(ov_grey_statis_sum		),
	.ov_grey_offset_width	(ov_grey_offset_width	),
	.ov_grey_offset_height	(ov_grey_offset_height	),
	.o_interrupt_en			(w_interrupt_en_grey	),
	.i_interrupt_pin		(o_interrupt			),
	.o_fval					(w_fval_grey			)
	);

	//  -------------------------------------------------------------------------------------
	//	�ж�ģ��
	//  -------------------------------------------------------------------------------------
	interrupt # (
	.REG_WD					(REG_WD					),
	.INT_TIME_INTERVAL_MS	(INT_TIME_INTERVAL_MS	),
	.CLK_FREQ_KHZ			(PIX_CLK_FREQ_KHZ		)
	)
	interrupt_inst (
	.clk					(clk_pix				),
	.i_fval					(w_fval_grey			),
	.i_acquisition_start	(i_acquisition_start	),
	.i_stream_enable		(i_stream_enable		),
	.i_interrupt_en_grey	(w_interrupt_en_grey	),
	.i_interrupt_en_wb		(w_interrupt_en_wb		),
	.iv_interrupt_clear		(iv_interrupt_clear		),
	.ov_interrupt_state		(ov_interrupt_state		),
	.o_interrupt			(o_interrupt			)
	);
	//	assign	o_interrupt	= 1'b0;

endmodule