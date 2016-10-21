//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : io_channel
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/9/19 13:12:32	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : io_channel顶层模块
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module io_channel # (
	parameter		TRIG_FILTER_WIDTH		= 19	,	//触发信号滤波模块寄存器宽度
	parameter		TRIG_DELAY_WIDTH		= 28	,	//触发信号延时模块寄存器宽度
	parameter		LED_CTRL_WIDTH			= 5		,	//LED CTRL 寄存器宽度
	parameter   		PIX_CLK_FREQ_KHZ    	= 55000 , 	//本地像素时钟，单位KHz
	parameter		SHORT_LINE_LENGTH_PCK	= 5568	,	//sensor短行周期设置值，这个值是写入sensor寄存器的十进制表示
	parameter		PHY_NUM					= 2		,	//phy数量
	parameter		PHY_CH_NUM				= 4		,	//每个phy的通道数量
	parameter		STROBE_MASK_SIMULATION	= "FALSE"	//"TRUE"为仿真模式，"FALSE"为正常模式
	)
	(
	//  ===============================================================================================
	//	控制信号
	//  ===============================================================================================
	input								clk					,	//本地像素时钟，55Mhz
	//  ===============================================================================================
	//	寄存器数据
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	控制信号
	//  -------------------------------------------------------------------------------------
	input								i_trigger_mode		,	//触发模式，0-连续模式，1-触发模式
	input								i_acquisition_start	,	//开采信号，0-停采，1-开采
	input								i_stream_enable		,	//流使能信号，0-停采，1-开采
	output	[3:0]						ov_line_status		,	//line状态寄存器，bit0-line0 bit1-line1 bit2-line2 bit3-line3，反映电路上的实际状态
	input								i_trigger_mode_data_mask,//解串时钟域，data_mask输出的trigger_mode信号
	//  -------------------------------------------------------------------------------------
	//	line mode and invert
	//  -------------------------------------------------------------------------------------
	input								i_line2_mode		,	//line2的输入输出模式，0输入，1输出
	input								i_line3_mode		,	//line3的输入输出模式，0输入，1输出
	input								i_line0_invert		,	//0不反向，1反向
	input								i_line1_invert		,	//0不反向，1反向
	input								i_line2_invert		,	//0不反向，1反向
	input								i_line3_invert		,	//0不反向，1反向
	//  -------------------------------------------------------------------------------------
	//	filter
	//  -------------------------------------------------------------------------------------
	input	[TRIG_FILTER_WIDTH-1:0]		iv_filter_rise		,	//上升沿滤波参数
	input	[TRIG_FILTER_WIDTH-1:0]		iv_filter_fall		,	//下降沿滤波参数
	//  -------------------------------------------------------------------------------------
	//	triggersource_sel
	//  -------------------------------------------------------------------------------------
	input								i_trigger_soft		,	//软触发输入，控制通道自清零，宽度是1个时钟周期
	input	[3:0]						iv_trigger_source	,	//选择输入源，0001-软触发，0010-line0，0100-line2，1000-line3
	//  -------------------------------------------------------------------------------------
	//	trigger_active
	//  -------------------------------------------------------------------------------------
	input								i_trigger_active	,	//0-下降沿有效，1上升沿有效
	//  -------------------------------------------------------------------------------------
	//	trigger_dleay
	//  -------------------------------------------------------------------------------------
	input	[TRIG_DELAY_WIDTH-1:0]		iv_trigger_delay	,	//延迟参数
	//  -------------------------------------------------------------------------------------
	//	strobe_mask trigger_mask
	//  -------------------------------------------------------------------------------------
	input								i_fval				,	//data_cahnnel模块hispi_if输出，解串时钟域，110MHz，异步信号
	input								i_lval				,	//data_cahnnel模块hispi_if输出，解串时钟域，110MHz，异步信号_
	input								i_trigger_status	,	//data_cahnnel模块data_mask输出，1-有触发信号且触发帧未输出完毕，0-无触发信号或触发帧输出完毕
	//  -------------------------------------------------------------------------------------
	//	strobe_mask
	//  -------------------------------------------------------------------------------------
	input								i_pll_lock			,	//解串PLL锁定信号
	//  -------------------------------------------------------------------------------------
	//	trigger_mask
	//  -------------------------------------------------------------------------------------
	input	[31:0]						iv_trigger_interval	,	//clk_pix时钟域，触发间隔，单位us
	//  -------------------------------------------------------------------------------------
	//	linesource_sel
	//  -------------------------------------------------------------------------------------
	input	[2:0]						iv_line_source1		,	//line1输出源，0-关闭(不使用)，1-曝光，2-useroutput(默认值)，3-useroutput1，4-useroutput2
	input	[2:0]						iv_line_source2		,	//line2输出源，0-关闭(不使用)，1-曝光，2-useroutput(默认值)，3-useroutput1，4-useroutput2
	input	[2:0]						iv_line_source3		,	//line3输出源，0-关闭(不使用)，1-曝光，2-useroutput(默认值)，3-useroutput1，4-useroutput2
	//  -------------------------------------------------------------------------------------
	//	useroutput
	//  -------------------------------------------------------------------------------------
	input	[2:0]						iv_useroutput_level	,	//配置3个useroutput值，bit0-useroutput0，bit1-useroutput1，bit2-useroutput2
	//  -------------------------------------------------------------------------------------
	//	led_ctrl
	//	0x00:红灯常亮。此时FPGA程序未完成加载或在线升级中。
	//	0x01:无数据传输时，绿灯常亮；当图像数据传输时，绿灯闪烁，有图像数据时熄灭，无图像数据时点亮。
	//	0x10:黄灯闪烁(1Hz)。此时产生了一般错误，比如用户参数加载失败。
	//  -------------------------------------------------------------------------------------
	input	[LED_CTRL_WIDTH-1:0]		iv_led_ctrl			,	//led控制寄存器，FPGA外部连接红绿两个LED灯，两个LED同时亮时为黄色。
	//  ===============================================================================================
	//	外部引脚信号
	//  ===============================================================================================
	//连接到IO板的引脚
	input								i_optocoupler		,	//line0的输入信号
	input	[1:0]						iv_gpio				,	//line2 line3 的输入信号
	output								o_optocoupler		,	//line1的输出信号
	output	[1:0]						ov_gpio				,	//line2 line3 的输出信号
	output								o_f_led_gre			,	//绿色指示灯，高电平点亮
	output								o_f_led_red			,	//红色指示灯，高电平点亮
	//连接到3014的引脚
	input								i_usb_slwr_n		,	//GPIF 写信号，clk_gpif时钟域
	//连接到Sensor的引脚
	input								i_sensor_strobe		,	//Sensor输出，异步信号，
	output								o_trigger				//输出给Sensor，触发信号，高电平有效，宽度至少是1个行周期
	);

	//	ref signals

	wire								w_optocoupler_in	;	//circuit_dependent输出，对 i_optocoupler 取反
	wire	[1:0]						wv_gpio_in			;	//circuit_dependent输出，保持 iv_gpio
	wire	[2:0]						wv_linein_mode		;	//line_mode_and_inverter输出，经过模式选择和极性控制，共有3路外触发源
	wire								w_linein_sel		;	//triggersource_sel输出，经过触发源选择的信号，3路触发信号变为1个
	wire								w_linein_filter		;	//filter输出，经过滤波之后的信号
	wire								w_linein_active		;	//trigger_active输出，对触发源取边沿之后的信号，宽度是1个时钟周期
	wire								w_linein_delay		;	//trigger_delay输出，延时之后的信号，宽度仍旧是1个时钟周期

	wire								w_strobe_mask		;	//strobe_mask模块输出的闪光灯信号

	wire	[2:0]						wv_lineout			;	//linesource_and_useroutput输出，经过linesource选择之后的3路输出信号

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref 1 line in --> trigger (trigger flow)
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	circuit_dependent
	//  -------------------------------------------------------------------------------------
	circuit_dependent circuit_dependent_inst (
	//连接到IO板的引脚
	.i_optocoupler			(i_optocoupler			),
	.iv_gpio				(iv_gpio				),
	//连接到io channel的后级模块
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
	//	trigger_active 在本级模块做开停采的处理
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
	//	trigger_mask
	//  -------------------------------------------------------------------------------------
	trigger_mask  #(
	.PIX_CLK_FREQ_KHZ		(PIX_CLK_FREQ_KHZ	)
	)
	trigger_mask_inst (
	.clk					(clk				),
	.i_trigger				(w_linein_delay		),
	.i_acquisition_start	(i_acquisition_start),
	.i_stream_enable		(i_stream_enable	),
	.i_trigger_mode			(i_trigger_mode		),
	.iv_trigger_interval	(iv_trigger_interval),//200ms
	.i_trigger_status		(i_trigger_status	),//解串时钟域，110MHz
	.i_fval					(i_fval				),//输入场信号，解串时钟域，110MHz
	.o_trigger				(o_trigger			)
	);

	//  ===============================================================================================
	//	ref 2. strobe --> line out (strobe flow)
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	strobe_mask
	//  -------------------------------------------------------------------------------------

	strobe_mask # (
	.PIX_CLK_FREQ_KHZ			(PIX_CLK_FREQ_KHZ			),
	.SHORT_LINE_LENGTH_PCK		(SHORT_LINE_LENGTH_PCK		),
	.PHY_NUM					(PHY_NUM					),
	.PHY_CH_NUM					(PHY_CH_NUM					),
	.SIMULATION					(STROBE_MASK_SIMULATION		)
	)
	strobe_mask_inst (
	.clk						(clk						),
	.i_strobe					(i_sensor_strobe			),
	.i_acquisition_start		(i_acquisition_start		),
	.i_stream_enable			(i_stream_enable			),
	.i_trigger					(o_trigger					),
	.i_pll_lock					(i_pll_lock					),
	.i_fval						(i_fval						),
	.i_lval						(i_lval						),
	.i_trigger_mode				(i_trigger_mode_data_mask	),
	.o_strobe					(w_strobe_mask				)
	);

	//  -------------------------------------------------------------------------------------
	//	linesource_and_useroutput
	//  -------------------------------------------------------------------------------------
	linesource_and_useroutput linesource_and_useroutput_inst (
	.clk					(clk					),
	.i_strobe				(w_strobe_mask			),
	.iv_useroutput_level	(iv_useroutput_level	),
	.iv_line_source1		(iv_line_source1		),
	.iv_line_source2		(iv_line_source2		),
	.iv_line_source3		(iv_line_source3		),
	.ov_lineout				(wv_lineout				)
	);

	//  ===============================================================================================
	//	ref 3. led ctrl
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	led_ctrl
	//  -------------------------------------------------------------------------------------
	led_ctrl # (
	.LED_CTRL_WIDTH		(LED_CTRL_WIDTH		),
	.LED_CLK_FREQ_KHZ	(PIX_CLK_FREQ_KHZ	)
	)
	led_ctrl_inst (
	.clk				(clk			),
	.i_usb_slwr_n		(i_usb_slwr_n	),
	.iv_led_ctrl		(iv_led_ctrl	),
	.o_f_led_gre		(o_f_led_gre	),
	.o_f_led_red		(o_f_led_red	)
	);

endmodule