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
	parameter	SENSOR_DAT_WIDTH	= 10	,	//sensor 数据宽度
	parameter	WB_OFFSET_WIDTH		= 12	,	//白平衡模块偏移位置寄存器宽度
	parameter	WB_GAIN_WIDTH		= 11	,	//白平衡模块增益寄存器宽度
	parameter	WB_STATIS_WIDTH		= 29	,	//白平衡模块统计值宽度
	parameter	GREY_OFFSET_WIDTH	= 12	,	//灰度统计模块偏移位置寄存器宽度
	parameter	GREY_STATIS_WIDTH	= 48	,	//灰度统计模块统计值宽度
	parameter	SHORT_REG_WD		= 16	,	//短寄存器位宽
	parameter	REG_WD				= 32	,	//寄存器位宽
	parameter	DATA_WD				= 32		//输入输出数据位宽，这里使用同一宽度

	)
	(
	//Sensor时钟域
	input							clk_sensor_pix			,	//72MHz，随路像素时钟,与本地72Mhz同频但不同相，可认为完全异步的两个信号，如果sensor复位，sensor输出时钟可能停止输出，而FPGA内部时钟不停止
	input							i_fval					,	//clk_sensor_pix时钟域，场有效信号，与clk_sensor_pix上升沿对齐。i_fval上升沿与i_lval上升沿对齐，i_fval下降沿与i_lval下降沿对齐
	input							i_lval					,	//clk_sensor_pix时钟域，行有效信号，与clk_sensor_pix上升沿对齐。i_fval上升沿与i_lval上升沿对齐，i_fval下降沿与i_lval下降沿对齐。，i_fval无效期间也有可能输出
	input	[SENSOR_DAT_WIDTH-1:0]	iv_pix_data				,	//clk_sensor_pix时钟域，图像数据，与clk_sensor_pix上升沿对齐，电路连接sensor高10位数据线，低2位数据没有接入到FPGA中
	//本地时钟域
	input							clk_pix					,	//本地像素时钟，72Mhz。与clk_sensor_pix同源，有相差
	input							reset_pix				,	//本地像素时钟的复位信号
	output							o_fval					,	//clk_pix时钟域，场有效，数据通道输出的加宽后的场信号。
	output							o_pix_data_en			,	//clk_pix时钟域，数据有效
	output	[DATA_WD-1:0]			ov_pix_data				,	//clk_pix时钟域，图像数据
	//寄存器数据
	input							i_acquisition_start		,	//clk_pix时钟域，开采信号，0-停采，1-开采
	input							i_stream_enable			,	//clk_pix时钟域，流使能信号，0-停采，1-开采
	output							o_full_frame_state		,	//clk_pix时钟域，完整帧状态,该寄存器用来保证停采时输出完整帧,0:停采时，已经传输完一帧数据,1:停采时，还在传输一帧数据
	input							i_encrypt_state			,	//clk_dna时钟域，加密状态，上电后保持不变，可以作为常数
	input							i_pulse_filter_en		,	//clk_pix时钟域，坏点校正开关,0:不使能坏点校正,1:使能坏点校正
	input	[SHORT_REG_WD-1:0]		iv_roi_pic_width		,	//行宽度
	input	[2:0]					iv_test_image_sel		,	//clk_pix时钟域，测试图选择寄存器,000:真实图,001:测试图像1灰度值帧递增,110:测试图像2静止的斜条纹,010:测试图像3滚动的斜条纹
	input	[REG_WD-1:0]			iv_pixel_format			,	//clk_pix时钟域，像素格式寄存器
	output	[REG_WD-1:0]			ov_pixel_format			,	//clk_pix时钟域，给后面的二级模块使用，保证前后级模块的数据格式是一样的

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
	//	数据通道固定参数
	//	-------------------------------------------------------------------------------------
	localparam						BAYER_PATTERN		= "GR"			;	//"GR" "RG" "GB" "BG"
	localparam						WB_RATIO			= 8				;	//白平衡调节因子，乘法增益需要右移多少位
	localparam						TIME_INTERVAL		= 3600000		;	//中断间隔-50ms

	//	-------------------------------------------------------------------------------------
	//	互联信号
	//	-------------------------------------------------------------------------------------
	wire							w_fval_sync			;	//sync_buffer输出，场信号
	wire							w_lval_sync			;	//sync_buffer输出，行信号
	wire	[SENSOR_DAT_WIDTH-1:0]	wv_pix_data_sync	;	//sync_buffer输出，图像数据
	wire							w_fval_filter		;	//pulse_filter输出，场信号
	wire							w_lval_filter		;	//pulse_filter输出，行信号
	wire	[SENSOR_DAT_WIDTH-1:0]	wv_pix_data_filter	;	//pulse_filter输出，图像数据
	wire							w_fval_pattern		;	//test_image输出，场信号
	wire							w_lval_pattern		;	//test_image输出，行信号
	wire	[SENSOR_DAT_WIDTH-1:0]	wv_pix_data_pattern	;	//test_image输出，图像数据
	wire							w_fval_wb			;	//raw_wb输出，场信号
	wire							w_lval_wb			;	//raw_wb输出，行信号
	wire	[SENSOR_DAT_WIDTH-1:0]	wv_pix_data_wb		;	//raw_wb输出，图像数据
	wire							w_interrupt_en_wb	;	//raw_wb输出，中断使能
	wire							w_fval_sel			;	//pixelformat_sel输出，场信号
	wire							w_lval_sel			;	//pixelformat_sel输出，行信号
	wire	[SENSOR_DAT_WIDTH-1:0]	wv_pix_data_sel		;	//pixelformat_sel输出，图像数据
	wire							w_fval_grey			;	//grey_statistics输出，场信号
	wire							w_interrupt_en_grey	;	//grey_statistics输出，中断使能

	wire	[REG_WD-1:0]			wv_pixel_format		;	//sync_buffer 输出的像素格式，数据通道的模块都要使用这一个寄存器，以保证所有数据通道模块的生效时机相同
	wire	[2:0]					wv_test_image_sel	;	//sync_buffer 输出的测试图选择寄存器，数据通道的模块都要使用这一个寄存器，以保证所有数据通道模块的生效时机相同

	//	ref ARCHITECTURE

	assign	ov_pixel_format	= wv_pixel_format;

	//  ===============================================================================================
	//	ref 1 数据流
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	同步缓冲，隔离Sensor时钟域和FPGA时钟域
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
	//	坏点校正模块
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
	//	测试图模块
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
	//	白平衡模块
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
	//	数据选择模块--该模块暂时没有用到，仅作为扩展备用
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
	//	数据选择模块--该模块暂时没有用到，仅作为扩展备用
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
	//	ref 2 其他模块
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	2a模块，统计灰度值
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
	//	中断模块
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