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
	parameter	SENSOR_DAT_WIDTH	= 10	,	//sensor ���ݿ��
	parameter	WB_OFFSET_WIDTH		= 12	,	//��ƽ��ģ��ƫ��λ�üĴ������
	parameter	WB_GAIN_WIDTH		= 11	,	//��ƽ��ģ������Ĵ������
	parameter	WB_STATIS_WIDTH		= 29	,	//��ƽ��ģ��ͳ��ֵ���
	parameter	GREY_OFFSET_WIDTH	= 12	,	//�Ҷ�ͳ��ģ��ƫ��λ�üĴ������
	parameter	GREY_STATIS_WIDTH	= 48	,	//�Ҷ�ͳ��ģ��ͳ��ֵ���
	parameter	SHORT_REG_WD		= 16	,	//�̼Ĵ���λ��
	parameter	REG_WD				= 32	,	//�Ĵ���λ��
	parameter	DATA_WD				= 32		//�����������λ������ʹ��ͬһ���

	)
	(
	//Sensorʱ����
	input							clk_sensor_pix			,	//72MHz����·����ʱ��,�뱾��72MhzͬƵ����ͬ�࣬����Ϊ��ȫ�첽�������źţ����sensor��λ��sensor���ʱ�ӿ���ֹͣ�������FPGA�ڲ�ʱ�Ӳ�ֹͣ
	input							i_fval					,	//clk_sensor_pixʱ���򣬳���Ч�źţ���clk_sensor_pix�����ض��롣i_fval��������i_lval�����ض��룬i_fval�½�����i_lval�½��ض���
	input							i_lval					,	//clk_sensor_pixʱ��������Ч�źţ���clk_sensor_pix�����ض��롣i_fval��������i_lval�����ض��룬i_fval�½�����i_lval�½��ض��롣��i_fval��Ч�ڼ�Ҳ�п������
	input	[SENSOR_DAT_WIDTH-1:0]	iv_pix_data				,	//clk_sensor_pixʱ����ͼ�����ݣ���clk_sensor_pix�����ض��룬��·����sensor��10λ�����ߣ���2λ����û�н��뵽FPGA��
	//����ʱ����
	input							clk_pix					,	//��������ʱ�ӣ�72Mhz����clk_sensor_pixͬԴ�������
	input							reset_pix				,	//��������ʱ�ӵĸ�λ�ź�
	output							o_fval					,	//clk_pixʱ���򣬳���Ч������ͨ������ļӿ��ĳ��źš�
	output							o_pix_data_en			,	//clk_pixʱ����������Ч
	output	[DATA_WD-1:0]			ov_pix_data				,	//clk_pixʱ����ͼ������
	//�Ĵ�������
	input							i_acquisition_start		,	//clk_pixʱ���򣬿����źţ�0-ͣ�ɣ�1-����
	input							i_stream_enable			,	//clk_pixʱ������ʹ���źţ�0-ͣ�ɣ�1-����
	output							o_full_frame_state		,	//clk_pixʱ��������֡״̬,�üĴ���������֤ͣ��ʱ�������֡,0:ͣ��ʱ���Ѿ�������һ֡����,1:ͣ��ʱ�����ڴ���һ֡����
	input							i_encrypt_state			,	//clk_dnaʱ���򣬼���״̬���ϵ�󱣳ֲ��䣬������Ϊ����
	input							i_pulse_filter_en		,	//clk_pixʱ���򣬻���У������,0:��ʹ�ܻ���У��,1:ʹ�ܻ���У��
	input	[SHORT_REG_WD-1:0]		iv_roi_pic_width		,	//�п��
	input	[2:0]					iv_test_image_sel		,	//clk_pixʱ���򣬲���ͼѡ��Ĵ���,000:��ʵͼ,001:����ͼ��1�Ҷ�ֵ֡����,110:����ͼ��2��ֹ��б����,010:����ͼ��3������б����
	input	[REG_WD-1:0]			iv_pixel_format			,	//clk_pixʱ�������ظ�ʽ�Ĵ���
	output	[REG_WD-1:0]			ov_pixel_format			,	//clk_pixʱ���򣬸�����Ķ���ģ��ʹ�ã���֤ǰ��ģ������ݸ�ʽ��һ����

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
	//	����ͨ���̶�����
	//	-------------------------------------------------------------------------------------
	localparam						BAYER_PATTERN		= "GR"			;	//"GR" "RG" "GB" "BG"
	localparam						WB_RATIO			= 8				;	//��ƽ��������ӣ��˷�������Ҫ���ƶ���λ
	localparam						TIME_INTERVAL		= 3600000		;	//�жϼ��-50ms

	//	-------------------------------------------------------------------------------------
	//	�����ź�
	//	-------------------------------------------------------------------------------------
	wire							w_fval_sync			;	//sync_buffer��������ź�
	wire							w_lval_sync			;	//sync_buffer��������ź�
	wire	[SENSOR_DAT_WIDTH-1:0]	wv_pix_data_sync	;	//sync_buffer�����ͼ������
	wire							w_fval_filter		;	//pulse_filter��������ź�
	wire							w_lval_filter		;	//pulse_filter��������ź�
	wire	[SENSOR_DAT_WIDTH-1:0]	wv_pix_data_filter	;	//pulse_filter�����ͼ������
	wire							w_fval_pattern		;	//test_image��������ź�
	wire							w_lval_pattern		;	//test_image��������ź�
	wire	[SENSOR_DAT_WIDTH-1:0]	wv_pix_data_pattern	;	//test_image�����ͼ������
	wire							w_fval_wb			;	//raw_wb��������ź�
	wire							w_lval_wb			;	//raw_wb��������ź�
	wire	[SENSOR_DAT_WIDTH-1:0]	wv_pix_data_wb		;	//raw_wb�����ͼ������
	wire							w_interrupt_en_wb	;	//raw_wb������ж�ʹ��
	wire							w_fval_sel			;	//pixelformat_sel��������ź�
	wire							w_lval_sel			;	//pixelformat_sel��������ź�
	wire	[SENSOR_DAT_WIDTH-1:0]	wv_pix_data_sel		;	//pixelformat_sel�����ͼ������
	wire							w_fval_grey			;	//grey_statistics��������ź�
	wire							w_interrupt_en_grey	;	//grey_statistics������ж�ʹ��

	wire	[REG_WD-1:0]			wv_pixel_format		;	//sync_buffer ��������ظ�ʽ������ͨ����ģ�鶼Ҫʹ����һ���Ĵ������Ա�֤��������ͨ��ģ�����Чʱ����ͬ
	wire	[2:0]					wv_test_image_sel	;	//sync_buffer ����Ĳ���ͼѡ��Ĵ���������ͨ����ģ�鶼Ҫʹ����һ���Ĵ������Ա�֤��������ͨ��ģ�����Чʱ����ͬ

	//	ref ARCHITECTURE

	assign	ov_pixel_format	= wv_pixel_format;

	//  ===============================================================================================
	//	ref 1 ������
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ͬ�����壬����Sensorʱ�����FPGAʱ����
	//  -------------------------------------------------------------------------------------
	sync_buffer # (
	.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH		),
	.REG_WD					(REG_WD					)
	)
	sync_buffer_inst (
	.clk_sensor_pix			(clk_sensor_pix			),
	.i_fval					(i_fval					),
	.i_lval					(i_lval					),
	.iv_pix_data			(iv_pix_data			),
	.i_acquisition_start	(i_acquisition_start	),
	.i_stream_enable		(i_stream_enable		),
	.i_encrypt_state		(i_encrypt_state		),
	.iv_pixel_format		(iv_pixel_format		),
	.iv_test_image_sel		(iv_test_image_sel		),
	.o_full_frame_state		(o_full_frame_state		),
	.ov_pixel_format		(wv_pixel_format		),
	.ov_test_image_sel		(wv_test_image_sel		),
	.clk_pix				(clk_pix				),
	.o_fval					(w_fval_sync			),
	.o_lval					(w_lval_sync			),
	.ov_pix_data			(wv_pix_data_sync		)
	);

	//  -------------------------------------------------------------------------------------
	//	����У��ģ��
	//  -------------------------------------------------------------------------------------
	pulse_filter # (
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	),
	.SHORT_REG_WD		(SHORT_REG_WD		)
	)
	pulse_filter_inst (
	.clk				(clk_pix			),
	.i_fval				(w_fval_sync		),
	.i_lval				(w_lval_sync		),
	.iv_pix_data		(wv_pix_data_sync	),
	.i_pulse_filter_en	(i_pulse_filter_en	),
	.iv_roi_pic_width	(iv_roi_pic_width	),
	.o_fval				(w_fval_filter		),
	.o_lval				(w_lval_filter		),
	.ov_pix_data		(wv_pix_data_filter	)
	);

	//  -------------------------------------------------------------------------------------
	//	����ͼģ��
	//  -------------------------------------------------------------------------------------
	test_image # (
	.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH	)
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

	//  -------------------------------------------------------------------------------------
	//	��ƽ��ģ��
	//  -------------------------------------------------------------------------------------
	raw_wb # (
	.BAYER_PATTERN			(BAYER_PATTERN	),
	.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH	),
	.WB_OFFSET_WIDTH		(WB_OFFSET_WIDTH	),
	.WB_GAIN_WIDTH			(WB_GAIN_WIDTH		),
	.WB_STATIS_WIDTH		(WB_STATIS_WIDTH	),
	.WB_RATIO				(WB_RATIO			),
	.REG_WD					(REG_WD				)
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

	//  -------------------------------------------------------------------------------------
	//	����ѡ��ģ��--��ģ����ʱû���õ�������Ϊ��չ����
	//  -------------------------------------------------------------------------------------
	pixelformat_sel # (
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	),
	.REG_WD				(REG_WD				)
	)
	pixelformat_sel_inst (
	.clk				(clk_pix			),
	.i_fval				(w_fval_wb			),
	.i_lval				(w_lval_wb			),
	.iv_pix_data		(wv_pix_data_wb		),
	.iv_pixel_format	(wv_pixel_format	),
	.o_fval				(w_fval_sel			),
	.o_lval				(w_lval_sel			),
	.ov_pix_data		(wv_pix_data_sel	)
	);

	//  -------------------------------------------------------------------------------------
	//	����ѡ��ģ��--��ģ����ʱû���õ�������Ϊ��չ����
	//  -------------------------------------------------------------------------------------
	data_align # (
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	),
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
	.o_interrupt_en			(w_interrupt_en_grey	),
	.i_interrupt_pin		(o_interrupt			),
	.iv_test_image_sel		(wv_test_image_sel		),
	.iv_pixel_format		(wv_pixel_format		),
	.iv_grey_offset_x_start	(iv_grey_offset_x_start	),
	.iv_grey_offset_width	(iv_grey_offset_width	),
	.iv_grey_offset_y_start	(iv_grey_offset_y_start	),
	.iv_grey_offset_height	(iv_grey_offset_height	),
	.ov_grey_statis_sum		(ov_grey_statis_sum		),
	.ov_grey_offset_width	(ov_grey_offset_width	),
	.ov_grey_offset_height	(ov_grey_offset_height	),
	.o_fval					(w_fval_grey			)
	);

	//  -------------------------------------------------------------------------------------
	//	�ж�ģ��
	//  -------------------------------------------------------------------------------------
	interrupt # (
	.REG_WD					(REG_WD				),
	.TIME_INTERVAL			(TIME_INTERVAL		)
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


endmodule