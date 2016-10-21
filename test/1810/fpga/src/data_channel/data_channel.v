//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : data_channel
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/4 13:39:53	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
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

module data_channel # (
	//	-------------------------------------------------------------------------------------
	//	解串相关的参数
	//	-------------------------------------------------------------------------------------
	parameter	PLL_CHECK_CLK_PERIOD_NS	= 25				,	//pll检测时钟的周期
	parameter	SER_FIRST_BIT		= "LSB"					,	//"LSB" or "MSB" , first bit to the receiver
	parameter	END_STYLE			= "LITTLE"				,	//"LITTLE" or "BIG" , "LITTLE" - {CHANNEL3 CHANNE2 CHANNEL1 CHANNEL0}. "BIG" - {CHANNEL0 CHANNEL1 CHANNEL2 CHANNEL3}.
	parameter	SER_DATA_RATE		= "DDR"					,	//"DDR" or "SDR" 输入的串行时钟采样方式
	parameter	DESER_CLOCK_ARC		= "BUFPLL"				,	//"BUFPLL" or "BUFIO2" , deserializer clock achitecture
	parameter	DESER_WIDTH			= 6						,	//每个通道解串宽度 2-8
	parameter	CLKIN_PERIOD_PS		= 3030					,	//输入时钟频率，PS为单位。只在BUFPLL方式下有用。
	parameter	DATA_DELAY_TYPE		= "DIFF_PHASE_DETECTOR"	,	//"DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
	parameter	DATA_DELAY_VALUE	= 0						,	//0-255，最大不能超过 1 UI
	parameter	BITSLIP_ENABLE		= "TRUE"				,	//"TRUE" "FALSE" iserdes 字边界对齐功能
	parameter	PLL_RESET_SIMULATION= "FALSE"				,	//解串PLL复位，使能仿真模式，复位时间变短，加速仿真
	parameter	PHY_NUM				= 2						,	//HiSPi PHY的数量
	parameter	PHY_CH_NUM			= 4						,	//每路HiSPi PHY数据通道的数量
	parameter	DIFF_TERM			= "TRUE"				,	//Differential Termination
	parameter	IOSTANDARD			= "LVDS_33"				,	//Specifies the I/O standard for this buffer
	//	-------------------------------------------------------------------------------------
	//	其他数据通道的参数
	//	-------------------------------------------------------------------------------------
	parameter	BAYER_PATTERN		= "GR"					,	//"GR" "RG" "GB" "BG"
	parameter	SENSOR_DAT_WIDTH	= 12					,	//sensor 数据宽度
	parameter	WB_OFFSET_WIDTH		= 12					,	//白平衡模块偏移位置寄存器宽度
	parameter	WB_GAIN_WIDTH		= 11					,	//白平衡模块增益寄存器宽度
	parameter	WB_STATIS_WIDTH		= 29					,	//白平衡模块统计值宽度
	parameter	WB_RATIO			= 8						,	//白平衡调节因子，乘法增益需要右移多少位
	parameter	GREY_OFFSET_WIDTH	= 12					,	//灰度统计模块偏移位置寄存器宽度
	parameter	GREY_STATIS_WIDTH	= 48					,	//灰度统计模块统计值宽度
	parameter	SHORT_REG_WD		= 16					,	//短寄存器位宽
	parameter	REG_WD				= 32					,	//寄存器位宽
	parameter	DATA_WD				= 128					,	//输出数据位宽
	parameter	PIX_CLK_FREQ_KHZ	= 55000					,	//像素时钟频率，单位KHZ，很多模块用该时钟作为定时器，因此必须写明像素时钟的频率
	parameter	INT_TIME_INTERVAL_MS= 50					,	//中断间隔
	parameter	TRIGGER_STATUS_INTERVAL=1100				,	//data_mask模块trigger_status=1超时时间
	parameter	SENSOR_MAX_WIDTH	=	4912
	)
	(
	//  -------------------------------------------------------------------------------------
	//	Sensor接口
	//  -------------------------------------------------------------------------------------
	input		[PHY_NUM-1:0]		pix_clk_p				,	//输入引脚，Sensor驱动，330MHz，HiSpi差分时钟
	input		[PHY_NUM-1:0]		pix_clk_n				,	//输入引脚，Sensor驱动，330MHz，HiSpi差分时钟
	input		[PHY_CH_NUM*PHY_NUM-1:0]	iv_pix_data_p			,	//输入引脚，Sensor驱动，HiSpi差分数据接口
	input		[PHY_CH_NUM*PHY_NUM-1:0]	iv_pix_data_n			,	//输入引脚，Sensor驱动，HiSpi差分数据接口
	//  -------------------------------------------------------------------------------------
	//	检测时钟域
	//  -------------------------------------------------------------------------------------
	input							clk_pll_check			,	//检测pll lock时钟
	//  -------------------------------------------------------------------------------------
	//	解串时钟域
	//  -------------------------------------------------------------------------------------
	output                          o_fval_deser            ,   //解串时钟域，hispi_if输出的场信号
	output                          o_lval_deser            ,   //解串时钟域，hispi_if输出的行信号
	output							o_trigger_mode_data_mask,	//解串时钟域，data_mask输出的trigger_mode信号
	output							o_trigger_status		,	//解串时钟域，1-有触发信号且触发帧未输出完毕，0-无触发信号或触发帧输出完毕
	//  -------------------------------------------------------------------------------------
	//	本地时钟域
	//  -------------------------------------------------------------------------------------
	input							clk_pix					,	//本地像素时钟，55Mhz。
	input							reset_pix				,	//本地像素时钟的复位信号
	output							o_fval					,	//clk_pix_2x时钟域，场有效，数据通道输出的加宽后的场信号。
	output							o_pix_data_en			,	//clk_pix_2x时钟域，数据有效
	output	[DATA_WD-1:0]			ov_pix_data				,	//clk_pix_2x时钟域，图像数据
	//寄存器数据
	input							i_trigger_start			,	//clk_pix时钟域，55MHz，i2c_top模块开始发送触发命令
	input							i_trigger_mode			,	//clk_pix时钟域，触发模式寄存器
	output							o_deser_pll_lock		,	//解串模块pll_lock
	output							o_bitslip_done			,	//解串模块并行时钟时钟域，1表示边界已经对齐,固件检测到该信号为1之后才能开始图像采集
	input							i_sensor_init_done		,	//clk_osc_bufg时钟域，sensor寄存器初始化完成
	input							i_acquisition_start		,	//clk_pix时钟域，开采信号，0-停采，1-开采
	input							i_stream_enable			,	//clk_pix时钟域，流使能信号，0-停采，1-开采
	output							o_full_frame_state		,	//clk_pix时钟域，完整帧状态,该寄存器用来保证停采时输出完整帧,0:停采时，已经传输完一帧数据,1:停采时，还在传输一帧数据
	input							i_encrypt_state			,	//clk_dna时钟域，加密状态，上电后保持不变，可以作为常数
	input							i_pulse_filter_en		,	//clk_pix时钟域，坏点校正开关,0:不使能坏点校正,1:使能坏点校正
	input	[SHORT_REG_WD-1:0]		iv_roi_pic_width		,	//行宽度
	input	[2:0]					iv_test_image_sel		,	//clk_pix时钟域，测试图选择寄存器,000:真实图,001:测试图像1灰度值帧递增,110:测试图像2静止的斜条纹,010:测试图像3滚动的斜条纹
	input	[REG_WD-1:0]			iv_pixel_format			,	//clk_pix时钟域，像素格式寄存器
	output	[REG_WD-1:0]			ov_pixel_format			,	//clk_pix时钟域，给后面的二级模块使用，保证前后级模块的数据格式是一样的
	output							o_sync_buffer_error		,	//sync_buffer模块引出出错检测脚，当不同的phy解析出的lval不同时，引脚置1

	input	[SHORT_REG_WD-1:0]		iv_offset_x				,	//ROI起始x
	input	[SHORT_REG_WD-1:0]		iv_offset_width			,	//ROI宽度

	input	[WB_OFFSET_WIDTH-1:0]	iv_wb_offset_x_start	,	//clk_pix时钟域，白平衡统计区域的x坐标起始点，固件设置的该寄存器值应该是相对于ROI的偏移
	input	[WB_OFFSET_WIDTH-1:0]	iv_wb_offset_width		,	//clk_pix时钟域，白平衡统计区域的宽度
	input	[WB_OFFSET_WIDTH-1:0]	iv_wb_offset_y_start	,	//clk_pix时钟域，白平衡统计区域的y坐标起始点，固件设置的该寄存器值应该是相对于ROI的偏移
	input	[WB_OFFSET_WIDTH-1:0]	iv_wb_offset_height		,	//clk_pix时钟域，白平衡统计区域的高度
	input	[WB_GAIN_WIDTH-1:0]		iv_wb_gain_r			,	//clk_pix时钟域，白平衡R分量，R分量小数乘以256后的结果，取值范围[0:2047]
	input	[WB_GAIN_WIDTH-1:0]		iv_wb_gain_g			,	//clk_pix时钟域，白平衡G分量，G分量小数乘以256后的结果，取值范围[0:2047]
	input	[WB_GAIN_WIDTH-1:0]		iv_wb_gain_b			,	//clk_pix时钟域，白平衡B分量，B分量小数乘以256后的结果，取值范围[0:2047]
	output	[WB_STATIS_WIDTH-1:0]	ov_wb_statis_r			,	//clk_pix时钟域，如果像素格式为8bit，该值为图像R分量8bit统计值。如果像素格式为大于8bit，该值为图像R分量高8bit统计值。
	output	[WB_STATIS_WIDTH-1:0]	ov_wb_statis_g			,	//clk_pix时钟域，如果像素格式为8bit，该值为图像G分量8bit统计值除以2的结果。如果像素格式为大于8bit，该值为图像G分量高8bit统计值除以2的结果。
	output	[WB_STATIS_WIDTH-1:0]	ov_wb_statis_b			,	//clk_pix时钟域，如果像素格式为8bit，该值为图像B分量8bit统计值。如果像素格式为大于8bit，该值为图像B分量高8bit统计值。
	output	[WB_OFFSET_WIDTH-1:0]	ov_wb_offset_width		,	//clk_pix时钟域，锁存后的统计窗口，白平衡统计区域的宽度
	output	[WB_OFFSET_WIDTH-1:0]	ov_wb_offset_height		,	//clk_pix时钟域，锁存后的统计窗口，白平衡统计区域的高度

	input	[GREY_OFFSET_WIDTH-1:0]	iv_grey_offset_x_start	,	//clk_pix时钟域，灰度值统计区域的x坐标起始点，固件设置的该寄存器值应该是相对于ROI的偏移
	input	[GREY_OFFSET_WIDTH-1:0]	iv_grey_offset_width	,	//clk_pix时钟域，灰度值统计区域的宽度
	input	[GREY_OFFSET_WIDTH-1:0]	iv_grey_offset_y_start	,	//clk_pix时钟域，灰度值统计区域的y坐标起始点，固件设置的该寄存器值应该是相对于ROI的偏移
	input	[GREY_OFFSET_WIDTH-1:0]	iv_grey_offset_height	,	//clk_pix时钟域，灰度值统计区域的高度
	output	[GREY_STATIS_WIDTH-1:0]	ov_grey_statis_sum		,	//clk_pix时钟域，该寄存器值为图像灰度统计值总和。如果像素格式为8bit，该值为像素8bit统计值。如果像素格式为10bit，该值为像素10bit统计值。
	output	[GREY_OFFSET_WIDTH-1:0]	ov_grey_offset_width	,	//clk_pix时钟域，锁存后的统计窗口，灰度值统计区域的宽度
	output	[GREY_OFFSET_WIDTH-1:0]	ov_grey_offset_height	,	//clk_pix时钟域，锁存后的统计窗口，灰度值统计区域的高度

	input	[1:0]					iv_interrupt_en			,	//clk_pix时钟域，bit0-2a中断使能，bit1-白平衡中断使能。高有效
	input	[1:0]					iv_interrupt_clear		,	//clk_pix时钟域，中断自清零信号，高有效，控制通道自清零，bit0-清2a中断，bit1-清白平衡中断
	output	[1:0]					ov_interrupt_state		,	//clk_pix时钟域，中断状态，与中断使能对应，高有效。bit0-2a中断状态，bit1-白平衡中断状态
	output							o_interrupt					//clk_pix时钟域，发到外部的中断信号，中断频率20Hz以下。高有效，宽度最少是100ns

	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	本地常数
	//	-------------------------------------------------------------------------------------
	localparam	CHANNEL_NUM	=	PHY_NUM*PHY_CH_NUM;//HiSPi数据通道的总数
	//	-------------------------------------------------------------------------------------
	//	互联信号
	//	-------------------------------------------------------------------------------------
	wire	[PHY_NUM-1:0]						clk_recover			;	//恢复时钟
	wire	[PHY_NUM-1:0]						reset_recover		;	//恢复时钟的复位信号
	wire	[DESER_WIDTH*PHY_CH_NUM-1:0]		wv_data_recover[PHY_NUM-1:0]		;	//恢复数据，并行
	wire										w_interrupt_en_pll	;	//pll_reset输出，中断使能
	wire										w_pll_reset			;	//解串pll复位信号
	wire										w_sync_buf_en		;	//sync buffer 使能信号
	wire										w_fifo_reset		;	//sync buffer 内部 fifo 复位信号
	wire	[PHY_NUM-1:0]						wv_clk_en_recover	;	//恢复时钟使能信号
	wire	[PHY_NUM-1:0]						wv_fval_deser		;	//hispi_if输出，场信号
	wire	[PHY_NUM-1:0]						wv_lval_deser		;	//hispi_if输出，行信号
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_deser	;	//hispi_if输出，图像数据
	wire	[PHY_NUM-1:0]						wv_bitslip_done		;	//解串模块并行时钟时钟域，1表示边界已经对齐,固件检测到该信号为1之后才能开始图像采集
	wire										w_fval_mask			;	//data_mask输出，场信号
	wire										w_lval_mask			;	//data_mask输出，行信号
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_mask	;	//data_mask输出，图像数据
	wire										w_fval_cut			;	//width_cut输出，场信号
	wire										w_lval_cut			;	//width_cut输出，行信号
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_cut		;	//width_cut输出，图像数据
	wire										w_fval_filter		;	//pulse_filter_1d输出，场信号
	wire										w_lval_filter		;	//pulse_filter_1d输出，行信号
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_filter	;	//pulse_filter_1d输出，图像数据
	wire										w_fval_sync			;	//sync_buffer输出，场信号
	wire										w_lval_sync			;	//sync_buffer输出，行信号
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_sync	;	//sync_buffer输出，图像数据
	wire										w_fval_ctrl			;	//stream_ctrl输出，场信号
	wire										w_lval_ctrl			;	//stream_ctrl输出，行信号
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_ctrl	;	//stream_ctrl输出，图像数据
	wire										w_fval_pattern		;	//test_image输出，场信号
	wire										w_lval_pattern		;	//test_image输出，行信号
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_pattern	;	//test_image输出，图像数据
	wire										w_fval_wb			;	//raw_wb输出，场信号
	wire										w_lval_wb			;	//raw_wb输出，行信号
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_wb		;	//raw_wb输出，图像数据
	wire										w_interrupt_en_wb	;	//raw_wb输出，中断使能
	wire										w_fval_sel			;	//pixelformat_sel输出，场信号
	wire										w_lval_sel			;	//pixelformat_sel输出，行信号
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_sel		;	//pixelformat_sel输出，图像数据

	wire										w_fval_grey			;	//grey_statistics输出，场信号
	wire										w_interrupt_en_grey	;	//grey_statistics输出，中断使能

	wire	[REG_WD-1:0]						wv_pixel_format		;	//sync_buffer 输出的像素格式，数据通道的模块都要使用这一个寄存器，以保证所有数据通道模块的生效时机相同
	wire	[2:0]								wv_test_image_sel	;	//sync_buffer 输出的测试图选择寄存器，数据通道的模块都要使用这一个寄存器，以保证所有数据通道模块的生效时机相同


	//	ref ARCHITECTURE

	assign	ov_pixel_format	= wv_pixel_format;
	assign  o_fval_deser    = wv_fval_deser[0];
	assign  o_lval_deser    = wv_lval_deser[0];
	//  ===============================================================================================
	//	ref 1 数据流
	//  ===============================================================================================

	wire[PHY_NUM-1:0]	w_deser_pll_lock;
	genvar	i;
	generate
		for(i=0;i<PHY_NUM;i=i+1)begin:DESERi
			if(i==0) begin
				//	-------------------------------------------------------------------------------------
				//	解串模块
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
				//	解串模块
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
			//	hispi 解析模块
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
	//	PLL 复位模块
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
	//	同步缓冲，隔离Sensor时钟域和FPGA时钟域
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
	//	流控制模块
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
	//	连续采集模式，不过滤图像
	//	触发采集模式，只通过触发帧，过滤其他图像数据
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
	//	截宽模块
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
	//	坏点矫正
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
	//	//	测试图模块
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
	//	白平衡模块
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
	//	数据选择模块--该模块暂时没有用到，仅作为扩展备用，数据不做任何处理直接输出
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
	//	模块输出的数据位宽为128bit
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
	//	ref 2 其他模块
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	2a模块，统计灰度值
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
	//	中断模块
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