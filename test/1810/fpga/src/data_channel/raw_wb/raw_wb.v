//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : raw_wb
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/5 11:10:54	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 自动白平衡模块，完成统计颜色分量和校正颜色的功能
//              1)  : 只锁存宽 高寄存器，不锁存起点坐标，因为固件计算平均值的时候只关心aoi图像大小
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
module raw_wb # (
	parameter						BAYER_PATTERN		= "GR"	,	//"GR" "RG" "GB" "BG"
	parameter						SENSOR_DAT_WIDTH	= 10	,	//sensor 数据宽度
	parameter						CHANNEL_NUM			= 4		,	//通道数
	parameter						WB_OFFSET_WIDTH		= 12	,	//白平衡模块偏移位置寄存器宽度
	parameter						WB_GAIN_WIDTH		= 11	,	//白平衡模块增益寄存器宽度
	parameter						WB_STATIS_WIDTH		= 29	,	//白平衡模块统计值宽度
	parameter						WB_RATIO			= 8		,	//白平衡调节因子，乘法增益需要右移多少位
	parameter						REG_WD				= 32		//寄存器位宽
	)
	(
	//Sensor输入信号
	input											clk						,	//像素时钟
	input											i_fval					,	//场信号
	input											i_lval					,	//行信号
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data				,	//图像数据
	//白平衡相关寄存器
	input											i_interrupt_en			,	//自动白平衡中断使能，如果不使能该中断，将关闭白平衡模块，以节省功耗。0:屏蔽自动白平衡中断，1:使能自动白平衡中断
	output											o_interrupt_en			,	//输入中断=0，o_interrupt_en=0。一帧统计有效时，在i_fval下降沿，o_interrupt_en=1
	input											i_interrupt_pin			,	//中断模块输出的中断信号，1-中断有效。在中断上升沿时，锁存颜色分量统计值和窗口寄存器到端口
	input	[REG_WD-1:0]							iv_pixel_format			,	//0x01080001:Mono8、0x01100003:Mono10、0x01080008:BayerGR8、0x0110000C:BayerGR10。黑白时，不做白平衡统计，不做乘法。
	input	[2:0]									iv_test_image_sel		,	//测试图选择寄存器,000:真实图,001:测试图像1灰度值帧递增,110:测试图像2静止的斜条纹,010:测试图像3滚动的斜条纹
	input	[WB_OFFSET_WIDTH-1:0]					iv_wb_offset_x_start	,	//白平衡统计区域的x坐标起始点，固件设置的该寄存器值应该是相对于ROI的偏移
	input	[WB_OFFSET_WIDTH-1:0]					iv_wb_offset_width		,	//白平衡统计区域的宽度
	input	[WB_OFFSET_WIDTH-1:0]					iv_wb_offset_y_start	,	//白平衡统计区域的y坐标起始点，固件设置的该寄存器值应该是相对于ROI的偏移
	input	[WB_OFFSET_WIDTH-1:0]					iv_wb_offset_height		,	//白平衡统计区域的高度
	input	[WB_GAIN_WIDTH-1:0]						iv_wb_gain_r			,	//白平衡R分量，R分量小数乘以256后的结果，取值范围[0:2047]
	input	[WB_GAIN_WIDTH-1:0]						iv_wb_gain_g			,	//白平衡G分量，G分量小数乘以256后的结果，取值范围[0:2047]
	input	[WB_GAIN_WIDTH-1:0]						iv_wb_gain_b			,	//白平衡B分量，B分量小数乘以256后的结果，取值范围[0:2047]
	output	[WB_STATIS_WIDTH-1:0]					ov_wb_statis_r			,	//如果像素格式为8bit，该值为图像R分量8bit统计值。如果像素格式为大于8bit，该值为图像R分量高8bit统计值。
	output	[WB_STATIS_WIDTH-1:0]					ov_wb_statis_g			,	//如果像素格式为8bit，该值为图像G分量8bit统计值除以2的结果。如果像素格式为大于8bit，该值为图像G分量高8bit统计值除以2的结果。
	output	[WB_STATIS_WIDTH-1:0]					ov_wb_statis_b			,	//如果像素格式为8bit，该值为图像B分量8bit统计值。如果像素格式为大于8bit，该值为图像B分量高8bit统计值。
	output	[WB_OFFSET_WIDTH-1:0]					ov_wb_offset_width		,	//锁存后的统计窗口，白平衡统计区域的宽度
	output	[WB_OFFSET_WIDTH-1:0]					ov_wb_offset_height		,	//锁存后的统计窗口，白平衡统计区域的高度
	//输出
	output											o_fval					,	//场有效，o_fval与o_lval的相位要保证与输入的相位一致
	output											o_lval					,	//行有效
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data					//图像数据
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
	//	ref 根据bayer格式，提取出 rgb的flag
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
	//	ref 白平衡统计流程
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	提取出AOI的信息
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
	//	统计AOI区域内的分量值
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
	//	ref 白平衡增益流程
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