//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : grey_statistics
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/12/5 14:52:08	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : �Ҷ�ֵͳ��ģ�飬
//              1)  : ģ���parameter֧�ֵ�����λ��Ϊ 8-16.
//
//              2)  : ��pixel format������λ��Ϊ8ʱ��ͳ�Ƶ�8bit����������£�ͳ��ȫ��λ����
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module grey_statistics # (
	parameter						SENSOR_DAT_WIDTH	= 10	,	//sensor ���ݿ��
	parameter						GREY_OFFSET_WIDTH	= 12	,	//�Ҷ�ͳ��ģ��ƫ��λ�üĴ������
	parameter						GREY_STATIS_WIDTH	= 48	,	//�Ҷ�ͳ��ģ��ͳ��ֵ���
	parameter						REG_WD				= 32		//�Ĵ���λ��
	)
	(
	//Sensor�����ź�
	input								clk						,	//����ʱ��
	input								i_fval					,	//���ź�
	input								i_lval					,	//���ź�
	input	[SENSOR_DAT_WIDTH-1:0]		iv_pix_data				,	//ͼ������
	//�Ҷ�ͳ����ؼĴ���
	input								i_interrupt_en			,	//2A�ж�ʹ�ܣ�2Aָ�����Զ��ع���Զ����棬������������FPGA����һ��ģ��ʵ�֣�������Ҫ��������һ��ܣ��ͱ���򿪸��ж������ʹ�ܸ��жϣ����ر�2Aģ�飬�Խ�ʡ����
	input	[2:0]						iv_test_image_sel		,	//����ͼѡ��Ĵ���,000:��ʵͼ,001:����ͼ��1�Ҷ�ֵ֡����,110:����ͼ��2��ֹ��б����,010:����ͼ��3������б����
	input	[REG_WD-1:0]				iv_pixel_format			,	//���ظ�ʽ�Ĵ���0x01080001:Mono8��0x01100003:Mono10��0x01080008:BayerGR8��0x0110000C:BayerGR10
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_x_start	,	//�Ҷ�ֵͳ�������x������ʼ�㣬�̼����õĸüĴ���ֵӦ���������ROI��ƫ��
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_width	,	//�Ҷ�ֵͳ������Ŀ��
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_y_start	,	//�Ҷ�ֵͳ�������y������ʼ�㣬�̼����õĸüĴ���ֵӦ���������ROI��ƫ��
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_height	,	//�Ҷ�ֵͳ������ĸ߶�
	output	[GREY_STATIS_WIDTH-1:0]		ov_grey_statis_sum		,	//�üĴ���ֵΪͼ��Ҷ�ͳ��ֵ�ܺ͡�������ظ�ʽΪ8bit����ֵΪ����8bitͳ��ֵ��������ظ�ʽΪ10bit����ֵΪ����10bitͳ��ֵ��
	output	[GREY_OFFSET_WIDTH-1:0]		ov_grey_offset_width	,	//������ͳ�ƴ��ڣ��Ҷ�ֵͳ������Ŀ��
	output	[GREY_OFFSET_WIDTH-1:0]		ov_grey_offset_height	,	//������ͳ�ƴ��ڣ��Ҷ�ֵͳ������ĸ߶�
	//����ģ�齻��
	output								o_interrupt_en			,	//�����ж�=0��o_interrupt_en=0��һ֡ͳ����Чʱ����i_fval�½��أ�o_interrupt_en=1
	input								i_interrupt_pin			,	//�ж�ģ��������ж��źţ�1-�ж���Ч�����ж�������ʱ������Ҷ�ͳ��ֵ�ʹ��ڼĴ������˿�
	output								o_fval						//������źţ���֤�ڳ��½���֮ǰ��ͳ��ֵ�Ѿ�ȷ��
	);

	//	ref signals
	wire							w_lval		;
	wire	[SENSOR_DAT_WIDTH-1:0]	wv_pix_data	;

	//	ref ARCHITECTURE

	grey_aoi_sel # (
	.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH		),
	.GREY_OFFSET_WIDTH		(GREY_OFFSET_WIDTH		)
	)
	grey_aoi_sel_inst (
	.clk					(clk					),
	.i_fval					(i_fval					),
	.i_lval					(i_lval					),
	.iv_pix_data			(iv_pix_data			),
	.i_interrupt_en			(i_interrupt_en			),
	.iv_test_image_sel		(iv_test_image_sel		),
	.iv_grey_offset_x_start	(iv_grey_offset_x_start	),
	.iv_grey_offset_width	(iv_grey_offset_width	),
	.iv_grey_offset_y_start	(iv_grey_offset_y_start	),
	.iv_grey_offset_height	(iv_grey_offset_height	),
	.ov_grey_offset_width	(ov_grey_offset_width	),
	.ov_grey_offset_height	(ov_grey_offset_height	),
	.o_interrupt_en			(o_interrupt_en			),
	.i_interrupt_pin		(i_interrupt_pin		),
	.o_fval					(o_fval					),
	.o_lval					(w_lval					),
	.ov_pix_data			(wv_pix_data			)
	);

	grey_statis # (
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	),
	.GREY_STATIS_WIDTH	(GREY_STATIS_WIDTH	),
	.REG_WD				(REG_WD				)
	)
	grey_statis_inst (
	.clk				(clk				),
	.i_fval				(o_fval				),
	.i_lval				(w_lval				),
	.iv_pix_data		(wv_pix_data		),
	.i_interrupt_pin	(i_interrupt_pin	),
	.iv_pixel_format	(iv_pixel_format	),
	.ov_grey_statis_sum	(ov_grey_statis_sum	)
	);
	

endmodule