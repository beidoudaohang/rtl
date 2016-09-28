//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : io_channel
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/9/19 13:12:32	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : io_channel����ģ��
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

module io_channel # (
	parameter		TRIG_FILTER_WIDTH		= 19	,	//�����ź��˲�ģ��Ĵ������
	parameter		TRIG_DELAY_WIDTH		= 28	,	//�����ź���ʱģ��Ĵ������
	parameter		LED_CTRL_WIDTH			= 5			//LED CTRL �Ĵ������
	)
	(
	//  ===============================================================================================
	//	�����ź�
	//  ===============================================================================================
	input								clk					,	//��������ʱ�ӣ�72Mhz
	//  ===============================================================================================
	//	�Ĵ�������
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	�����ź�
	//  -------------------------------------------------------------------------------------
	input								i_trigger_mode		,	//����ģʽ��0-����ģʽ��1-����ģʽ
	input								i_acquisition_start	,	//�����źţ�0-ͣ�ɣ�1-����
	input								i_stream_enable		,	//��ʹ���źţ�0-ͣ�ɣ�1-����
	output	[3:0]						ov_line_status		,	//line״̬�Ĵ�����bit0-line0 bit1-line1 bit2-line2 bit3-line3����ӳ��·�ϵ�ʵ��״̬
	//  -------------------------------------------------------------------------------------
	//	line mode and invert
	//  -------------------------------------------------------------------------------------
	input								i_line2_mode		,	//line2���������ģʽ��0���룬1���
	input								i_line3_mode		,	//line3���������ģʽ��0���룬1���
	input								i_line0_invert		,	//0������1����
	input								i_line1_invert		,	//0������1����
	input								i_line2_invert		,	//0������1����
	input								i_line3_invert		,	//0������1����
	//  -------------------------------------------------------------------------------------
	//	filter
	//  -------------------------------------------------------------------------------------
	input	[TRIG_FILTER_WIDTH-1:0]		iv_filter_rise		,	//�������˲�����
	input	[TRIG_FILTER_WIDTH-1:0]		iv_filter_fall		,	//�½����˲�����
	//  -------------------------------------------------------------------------------------
	//	triggersource_sel
	//  -------------------------------------------------------------------------------------
	input								i_trigger_soft		,	//�������룬����ͨ�������㣬�����1��ʱ������
	input	[3:0]						iv_trigger_source	,	//ѡ������Դ��0001-������0010-line0��0100-line2��1000-line3
	//  -------------------------------------------------------------------------------------
	//	trigger_active
	//  -------------------------------------------------------------------------------------
	input								i_trigger_active	,	//0-�½�����Ч��1��������Ч
	//  -------------------------------------------------------------------------------------
	//	trigger_dleay
	//  -------------------------------------------------------------------------------------
	input	[TRIG_DELAY_WIDTH-1:0]		iv_trigger_delay	,	//�ӳٲ���
	//  -------------------------------------------------------------------------------------
	//	linesource_sel
	//  -------------------------------------------------------------------------------------
	input	[2:0]						iv_line_source1		,	//line1���Դ��0-�ر�(��ʹ��)��1-�ع⣬2-useroutput(Ĭ��ֵ)��3-useroutput1��4-useroutput2
	input	[2:0]						iv_line_source2		,	//line2���Դ��0-�ر�(��ʹ��)��1-�ع⣬2-useroutput(Ĭ��ֵ)��3-useroutput1��4-useroutput2
	input	[2:0]						iv_line_source3		,	//line3���Դ��0-�ر�(��ʹ��)��1-�ع⣬2-useroutput(Ĭ��ֵ)��3-useroutput1��4-useroutput2
	//  -------------------------------------------------------------------------------------
	//	useroutput
	//  -------------------------------------------------------------------------------------
	input	[2:0]						iv_useroutput_level	,	//����3��useroutputֵ��bit0-useroutput0��bit1-useroutput1��bit2-useroutput2
	//  -------------------------------------------------------------------------------------
	//	led_ctrl
	//	0x00:��Ƴ�������ʱFPGA����δ��ɼ��ػ����������С�
	//	0x01:�����ݴ���ʱ���̵Ƴ�������ͼ�����ݴ���ʱ���̵���˸����ͼ������ʱϨ����ͼ������ʱ������
	//	0x10:�Ƶ���˸(1Hz)����ʱ������һ����󣬱����û���������ʧ�ܡ�
	//  -------------------------------------------------------------------------------------
	input	[LED_CTRL_WIDTH-1:0]		iv_led_ctrl			,	//led���ƼĴ�����FPGA�ⲿ���Ӻ�������LED�ƣ�����LEDͬʱ��ʱΪ��ɫ��
	//  ===============================================================================================
	//	�ⲿ�����ź�
	//  ===============================================================================================
	//���ӵ�IO�������
	input								i_optocoupler		,	//line0�������ź�
	input	[1:0]						iv_gpio				,	//line2 line3 �������ź�
	output								o_optocoupler		,	//line1������ź�
	output	[1:0]						ov_gpio				,	//line2 line3 ������ź�
	output								o_f_led_gre			,	//��ɫָʾ�ƣ��ߵ�ƽ����
	output								o_f_led_red			,	//��ɫָʾ�ƣ��ߵ�ƽ����
	//���ӵ�3014������
	input								i_usb_slwr_n		,	//GPIF д�źţ�clk_gpifʱ����
	//���ӵ�Sensor������
	input								i_fval				,	//Sensor������첽�ź�
	input								i_lval				,	//Sensor������첽�ź�
	input								i_sensor_strobe		,	//Sensor������첽�źţ��˵�С��1�п�ȵ�strobe�������ź�
	output								o_trigger_n			,	//�����Sensor�������źţ��͵�ƽ��Ч�����������1��������

	output	[15:0]						ov_linein_sel_rise_cnt		,	//i_linein_sel�������ؼ�����
	output	[15:0]						ov_linein_sel_fall_cnt		,	//i_linein_sel���½��ؼ�����
	output	[15:0]						ov_linein_filter_rise_cnt	,	//i_linein_filter�������ؼ�����
	output	[15:0]						ov_linein_filter_fall_cnt	,	//i_linein_filter���½��ؼ�����
	output	[15:0]						ov_linein_active_cnt		,	//i_linein_active�������ؼ�����
	output	[15:0]						ov_trigger_n_rise_cnt		,	//i_trigger_n�������ؼ�����
	output	[15:0]						ov_trigger_soft_cnt			,	//i_trigger_soft�ļ�����
	output	[12:0]						ov_strobe_length_reg			//������strobe���

	);

	//	ref signals
	wire								w_optocoupler_in	;	//circuit_dependent������� i_optocoupler ȡ��
	wire	[1:0]						wv_gpio_in			;	//circuit_dependent��������� iv_gpio
	wire	[2:0]						wv_linein_mode		;	//line_mode_and_inverter���������ģʽѡ��ͼ��Կ��ƣ�����3·�ⴥ��Դ
	wire								w_linein_sel		;	//triggersource_sel�������������Դѡ����źţ�3·�����źű�Ϊ1��
	wire								w_linein_filter		;	//filter����������˲�֮����ź�
	wire								w_linein_active		;	//trigger_active������Դ���Դȡ����֮����źţ������1��ʱ������
	wire								w_linein_delay		;	//trigger_delay�������ʱ֮����źţ�����Ծ���1��ʱ������

	wire								w_strobe_filter		;	//strobe_filter����������˲�֮��������ź�
	wire	[2:0]						wv_lineout			;	//linesource_and_useroutput���������linesourceѡ��֮���3·����ź�

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref 1 line in --> trigger ��������
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	circuit_dependent
	//  -------------------------------------------------------------------------------------
	circuit_dependent circuit_dependent_inst (
	//���ӵ�IO�������
	.i_optocoupler			(i_optocoupler			),
	.iv_gpio				(iv_gpio				),
	//���ӵ�io channel�ĺ�ģ��
	.o_optocoupler_in		(w_optocoupler_in		),
	.ov_gpio_in				(wv_gpio_in				)
	);

	//  -------------------------------------------------------------------------------------
	//	line_mode_and_inverter
	//  -------------------------------------------------------------------------------------
	line_mode_and_inverter line_mode_and_inverter_inst (
	.clk				(clk					),
	.i_optocoupler		(w_optocoupler_in		),
	.iv_gpio			(wv_gpio_in				),
	.o_optocoupler		(o_optocoupler			),
	.ov_gpio			(ov_gpio				),
	.i_line2_mode		(i_line2_mode			),
	.i_line3_mode		(i_line3_mode			),
	.i_line0_invert		(i_line0_invert			),
	.i_line1_invert		(i_line1_invert			),
	.i_line2_invert		(i_line2_invert			),
	.i_line3_invert		(i_line3_invert			),
	.ov_line_status		(ov_line_status			),
	.ov_linein			(wv_linein_mode			),
	.iv_lineout			(wv_lineout				)
	);

	//  -------------------------------------------------------------------------------------
	//	triggersource_sel
	//  -------------------------------------------------------------------------------------
	triggersource_sel triggersource_sel_inst (
	.clk				(clk				),
	.iv_trigger_source	(iv_trigger_source	),
	.iv_linein			(wv_linein_mode		),
	.o_linein			(w_linein_sel		)
	);

	//  -------------------------------------------------------------------------------------
	//	filter
	//  -------------------------------------------------------------------------------------
	filter # (
	.TRIG_FILTER_WIDTH	(TRIG_FILTER_WIDTH	)
	)
	filter_inst (
	.clk				(clk				),
	.iv_filter_rise		(iv_filter_rise		),
	.iv_filter_fall		(iv_filter_fall		),
	.i_din				(w_linein_sel		),
	.o_dout				(w_linein_filter	)
	);

	//  -------------------------------------------------------------------------------------
	//	trigger_active �ڱ���ģ������ͣ�ɵĴ���
	//  -------------------------------------------------------------------------------------
	trigger_active trigger_active_inst (
	.clk				(clk				),
	.i_trigger_soft		(i_trigger_soft		),
	.iv_trigger_source	(iv_trigger_source	),
	.i_trigger_active	(i_trigger_active	),
	.i_din				(w_linein_filter	),
	.o_dout				(w_linein_active	)
	);

	//  -------------------------------------------------------------------------------------
	//	trigger_delay
	//  -------------------------------------------------------------------------------------
	trigger_delay # (
	.TRIG_DELAY_WIDTH		(TRIG_DELAY_WIDTH		)
	)
	trigger_delay_inst (
	.clk					(clk					),
	.iv_trigger_delay		(iv_trigger_delay		),
	.i_din					(w_linein_active		),
	.o_dout					(w_linein_delay			)
	);

	//  -------------------------------------------------------------------------------------
	//	trigger_extend
	//  -------------------------------------------------------------------------------------
	trigger_extend trigger_extend_inst (
	.clk					(clk					),
	.i_trigger_mode			(i_trigger_mode			),
	.i_acquisition_start	(i_acquisition_start	),
	.i_stream_enable		(i_stream_enable		),
	.i_din					(w_linein_delay			),
	.o_dout_n				(o_trigger_n			)
	);


	//  ===============================================================================================
	//	ref 2. strobe --> line out ��������
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	strobe_filter
	//  -------------------------------------------------------------------------------------
	strobe_filter strobe_filter_inst (
	.clk					(clk					),
	.i_acquisition_start	(i_acquisition_start	),
	.i_stream_enable		(i_stream_enable		),
	.i_fval					(i_fval					),
	.i_lval					(i_lval					),
	.i_sensor_strobe		(i_sensor_strobe		),
	.ov_strobe_length_reg	(ov_strobe_length_reg	),
	.o_strobe_filter		(w_strobe_filter		)
	);

	//  -------------------------------------------------------------------------------------
	//	linesource_and_useroutput
	//  -------------------------------------------------------------------------------------
	linesource_and_useroutput linesource_and_useroutput_inst (
	.clk					(clk					),
	.i_strobe				(w_strobe_filter		),
	.iv_useroutput_level	(iv_useroutput_level	),
	.iv_line_source1		(iv_line_source1		),
	.iv_line_source2		(iv_line_source2		),
	.iv_line_source3		(iv_line_source3		),
	.ov_lineout				(wv_lineout				)
	);

	//  ===============================================================================================
	//	ref 3. led ctrl LED����
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	led_ctrl
	//  -------------------------------------------------------------------------------------
	led_ctrl # (
	.LED_CTRL_WIDTH		(LED_CTRL_WIDTH	)
	)
	led_ctrl_inst (
	.clk				(clk			),
	.i_usb_slwr_n		(i_usb_slwr_n	),
	.iv_led_ctrl		(iv_led_ctrl	),
	.o_f_led_gre		(o_f_led_gre	),
	.o_f_led_red		(o_f_led_red	)
	);

	//	===============================================================================================
	//	ref 4 ����ģ��
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	����������
	//	-------------------------------------------------------------------------------------
	trigger_cnt trigger_cnt_inst (
	.clk						(clk						),
	.i_trigger_mode				(i_trigger_mode				),
	.i_stream_enable			(i_stream_enable			),
	.i_acquisition_start		(i_acquisition_start		),
	.i_linein_sel				(w_linein_sel				),
	.i_linein_filter			(w_linein_filter			),
	.i_linein_active			(w_linein_active			),
	.i_trigger_n				(o_trigger_n				),
	.i_trigger_soft				(i_trigger_soft				),
	.ov_linein_sel_rise_cnt		(ov_linein_sel_rise_cnt		),
	.ov_linein_sel_fall_cnt		(ov_linein_sel_fall_cnt		),
	.ov_linein_filter_rise_cnt	(ov_linein_filter_rise_cnt	),
	.ov_linein_filter_fall_cnt	(ov_linein_filter_fall_cnt	),
	.ov_linein_active_cnt		(ov_linein_active_cnt		),
	.ov_trigger_n_rise_cnt		(ov_trigger_n_rise_cnt		),
	.ov_trigger_soft_cnt		(ov_trigger_soft_cnt		)
	);

endmodule