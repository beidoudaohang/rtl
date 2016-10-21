//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : raw_wb
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/12/5 11:10:54	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : �Զ���ƽ��ģ�飬���ͳ����ɫ������У����ɫ�Ĺ���
//              1)  : ֻ����� �߼Ĵ�����������������꣬��Ϊ�̼�����ƽ��ֵ��ʱ��ֻ����aoiͼ���С
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
module raw_wb # (
	parameter						BAYER_PATTERN		= "GR"	,	//"GR" "RG" "GB" "BG"
	parameter						SENSOR_DAT_WIDTH	= 10	,	//sensor ���ݿ��
	parameter						CHANNEL_NUM			= 4		,	//ͨ����
	parameter						WB_OFFSET_WIDTH		= 12	,	//��ƽ��ģ��ƫ��λ�üĴ������
	parameter						WB_GAIN_WIDTH		= 11	,	//��ƽ��ģ������Ĵ������
	parameter						WB_STATIS_WIDTH		= 29	,	//��ƽ��ģ��ͳ��ֵ���
	parameter						WB_RATIO			= 8		,	//��ƽ��������ӣ��˷�������Ҫ���ƶ���λ
	parameter						REG_WD				= 32		//�Ĵ���λ��
	)
	(
	//Sensor�����ź�
	input											clk						,	//����ʱ��
	input											i_fval					,	//���ź�
	input											i_lval					,	//���ź�
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data				,	//ͼ������
	//��ƽ����ؼĴ���
	input											i_interrupt_en			,	//�Զ���ƽ���ж�ʹ�ܣ������ʹ�ܸ��жϣ����رհ�ƽ��ģ�飬�Խ�ʡ���ġ�0:�����Զ���ƽ���жϣ�1:ʹ���Զ���ƽ���ж�
	output											o_interrupt_en			,	//�����ж�=0��o_interrupt_en=0��һ֡ͳ����Чʱ����i_fval�½��أ�o_interrupt_en=1
	input											i_interrupt_pin			,	//�ж�ģ��������ж��źţ�1-�ж���Ч�����ж�������ʱ��������ɫ����ͳ��ֵ�ʹ��ڼĴ������˿�
	input	[REG_WD-1:0]							iv_pixel_format			,	//0x01080001:Mono8��0x01100003:Mono10��0x01080008:BayerGR8��0x0110000C:BayerGR10���ڰ�ʱ��������ƽ��ͳ�ƣ������˷���
	input	[2:0]									iv_test_image_sel		,	//����ͼѡ��Ĵ���,000:��ʵͼ,001:����ͼ��1�Ҷ�ֵ֡����,110:����ͼ��2��ֹ��б����,010:����ͼ��3������б����
	input	[WB_OFFSET_WIDTH-1:0]					iv_wb_offset_x_start	,	//��ƽ��ͳ�������x������ʼ�㣬�̼����õĸüĴ���ֵӦ���������ROI��ƫ��
	input	[WB_OFFSET_WIDTH-1:0]					iv_wb_offset_width		,	//��ƽ��ͳ������Ŀ��
	input	[WB_OFFSET_WIDTH-1:0]					iv_wb_offset_y_start	,	//��ƽ��ͳ�������y������ʼ�㣬�̼����õĸüĴ���ֵӦ���������ROI��ƫ��
	input	[WB_OFFSET_WIDTH-1:0]					iv_wb_offset_height		,	//��ƽ��ͳ������ĸ߶�
	input	[WB_GAIN_WIDTH-1:0]						iv_wb_gain_r			,	//��ƽ��R������R����С������256��Ľ����ȡֵ��Χ[0:2047]
	input	[WB_GAIN_WIDTH-1:0]						iv_wb_gain_g			,	//��ƽ��G������G����С������256��Ľ����ȡֵ��Χ[0:2047]
	input	[WB_GAIN_WIDTH-1:0]						iv_wb_gain_b			,	//��ƽ��B������B����С������256��Ľ����ȡֵ��Χ[0:2047]
	output	[WB_STATIS_WIDTH-1:0]					ov_wb_statis_r			,	//������ظ�ʽΪ8bit����ֵΪͼ��R����8bitͳ��ֵ��������ظ�ʽΪ����8bit����ֵΪͼ��R������8bitͳ��ֵ��
	output	[WB_STATIS_WIDTH-1:0]					ov_wb_statis_g			,	//������ظ�ʽΪ8bit����ֵΪͼ��G����8bitͳ��ֵ����2�Ľ����������ظ�ʽΪ����8bit����ֵΪͼ��G������8bitͳ��ֵ����2�Ľ����
	output	[WB_STATIS_WIDTH-1:0]					ov_wb_statis_b			,	//������ظ�ʽΪ8bit����ֵΪͼ��B����8bitͳ��ֵ��������ظ�ʽΪ����8bit����ֵΪͼ��B������8bitͳ��ֵ��
	output	[WB_OFFSET_WIDTH-1:0]					ov_wb_offset_width		,	//������ͳ�ƴ��ڣ���ƽ��ͳ������Ŀ��
	output	[WB_OFFSET_WIDTH-1:0]					ov_wb_offset_height		,	//������ͳ�ƴ��ڣ���ƽ��ͳ������ĸ߶�
	//���
	output											o_fval					,	//����Ч��o_fval��o_lval����λҪ��֤���������λһ��
	output											o_lval					,	//����Ч
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data					//ͼ������
	);

	//	ref signals
	wire											w_mono_sel		;
	wire	[CHANNEL_NUM-1:0]						wv_r_flag_bayer	;
	wire	[CHANNEL_NUM-1:0]						wv_g_flag_bayer	;
	wire	[CHANNEL_NUM-1:0]						wv_b_flag_bayer	;
	wire											w_fval_bayer	;
	wire											w_lval_bayer	;
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		wv_pix_data_bayer	;
	wire											w_fval_aoi	;
	wire											w_lval_aoi	;
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		wv_pix_data_aoi	;
	wire	[CHANNEL_NUM-1:0]						wv_r_flag_aoi	;
	wire	[CHANNEL_NUM-1:0]						wv_g_flag_aoi	;
	wire	[CHANNEL_NUM-1:0]						wv_b_flag_aoi	;

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ����bayer��ʽ����ȡ�� rgb��flag
	//  ===============================================================================================
	wb_bayer_sel # (
	.BAYER_PATTERN		(BAYER_PATTERN		),
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	),
	.CHANNEL_NUM		(CHANNEL_NUM		),
	.REG_WD				(REG_WD				)
	)
	wb_bayer_sel_inst (
	.clk				(clk				),
	.i_fval				(i_fval				),
	.i_lval				(i_lval				),
	.iv_pix_data		(iv_pix_data		),
	.iv_pixel_format	(iv_pixel_format	),
	.o_mono_sel			(w_mono_sel			),
	.ov_r_flag			(wv_r_flag_bayer	),
	.ov_g_flag			(wv_g_flag_bayer	),
	.ov_b_flag			(wv_b_flag_bayer	),
	.o_fval				(w_fval_bayer		),
	.o_lval				(w_lval_bayer		),
	.ov_pix_data		(wv_pix_data_bayer	)
	);

	//  ===============================================================================================
	//	ref ��ƽ��ͳ������
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	��ȡ��AOI����Ϣ
	//  -------------------------------------------------------------------------------------
	wb_aoi_sel # (
	.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH	),
	.CHANNEL_NUM			(CHANNEL_NUM		),
	.WB_OFFSET_WIDTH		(WB_OFFSET_WIDTH	),
	.REG_WD					(REG_WD				)
	)
	wb_aoi_sel_inst (
	.clk					(clk					),
	.i_fval					(w_fval_bayer			),
	.i_lval					(w_lval_bayer			),
	.iv_pix_data			(wv_pix_data_bayer		),
	.iv_r_flag				(wv_r_flag_bayer		),
	.iv_g_flag				(wv_g_flag_bayer		),
	.iv_b_flag				(wv_b_flag_bayer		),
	.i_interrupt_en			(i_interrupt_en			),
	.o_interrupt_en			(o_interrupt_en			),
	.i_interrupt_pin		(i_interrupt_pin		),
	.i_mono_sel				(w_mono_sel				),
	.iv_test_image_sel		(iv_test_image_sel		),
	.iv_wb_offset_x_start	(iv_wb_offset_x_start	),
	.iv_wb_offset_width		(iv_wb_offset_width		),
	.iv_wb_offset_y_start	(iv_wb_offset_y_start	),
	.iv_wb_offset_height	(iv_wb_offset_height	),
	.ov_wb_offset_width		(ov_wb_offset_width		),
	.ov_wb_offset_height	(ov_wb_offset_height	),
	.o_fval					(w_fval_aoi				),
	.o_lval					(w_lval_aoi				),
	.ov_pix_data			(wv_pix_data_aoi		),
	.ov_r_flag				(wv_r_flag_aoi			),
	.ov_g_flag				(wv_g_flag_aoi			),
	.ov_b_flag				(wv_b_flag_aoi			)
	);

	//  -------------------------------------------------------------------------------------
	//	ͳ��AOI�����ڵķ���ֵ
	//  -------------------------------------------------------------------------------------
	wb_statis # (
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	),
	.CHANNEL_NUM		(CHANNEL_NUM		),
	.WB_STATIS_WIDTH	(WB_STATIS_WIDTH	),
	.REG_WD				(REG_WD				)
	)
	wb_statis_inst (
	.clk				(clk				),
	.i_fval				(w_fval_aoi			),
	.i_lval				(w_lval_aoi			),
	.iv_pix_data		(wv_pix_data_aoi	),
	.iv_r_flag			(wv_r_flag_aoi		),
	.iv_g_flag			(wv_g_flag_aoi		),
	.iv_b_flag			(wv_b_flag_aoi		),
	.i_interrupt_pin	(i_interrupt_pin	),
	.ov_wb_statis_r		(ov_wb_statis_r		),
	.ov_wb_statis_g		(ov_wb_statis_g		),
	.ov_wb_statis_b		(ov_wb_statis_b		)
	);

	//  ===============================================================================================
	//	ref ��ƽ����������
	//  ===============================================================================================
	wb_gain # (
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	),
	.CHANNEL_NUM		(CHANNEL_NUM		),
	.WB_GAIN_WIDTH		(WB_GAIN_WIDTH		),
	.WB_RATIO			(WB_RATIO			),
	.REG_WD				(REG_WD				)
	)
	wb_gain_inst (
	.clk				(clk				),
	.i_fval				(w_fval_bayer		),
	.i_lval				(w_lval_bayer		),
	.iv_pix_data		(wv_pix_data_bayer	),
	.iv_r_flag			(wv_r_flag_bayer	),
	.iv_g_flag			(wv_g_flag_bayer	),
	.iv_b_flag			(wv_b_flag_bayer	),
	.i_mono_sel			(w_mono_sel			),
	.iv_test_image_sel	(iv_test_image_sel	),
	.iv_wb_gain_r		(iv_wb_gain_r		),
	.iv_wb_gain_g		(iv_wb_gain_g		),
	.iv_wb_gain_b		(iv_wb_gain_b		),
	.o_fval				(o_fval				),
	.o_lval				(o_lval				),
	.ov_pix_data		(ov_pix_data		)
	);


endmodule