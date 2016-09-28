//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : mer_reg
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/12 14:11:45	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 该模块包括了工程中所有寄存器，把寄存器按照时钟域划分为了5个模块，分别是
//						pix时钟域、gpif时钟域、frame_bufg时钟域、osc_bufg时钟域和固定时钟域
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

module mer_reg # (
	parameter		SPI_ADDR_LENGTH			= 16	,	//spi 地址的长度
	parameter		WB_OFFSET_WIDTH			= 12	,	//白平衡模块偏移位置寄存器宽度
	parameter		WB_GAIN_WIDTH			= 11	,	//白平衡模块增益寄存器宽度
	parameter		WB_STATIS_WIDTH			= 31	,	//白平衡模块统计值宽度
	parameter		GREY_OFFSET_WIDTH		= 12	,	//灰度统计模块偏移位置寄存器
	parameter		GREY_STATIS_WIDTH		= 48	,	//灰度统计模块统计值宽度
	parameter		TRIG_FILTER_WIDTH		= 19	,	//触发信号滤波模块寄存器宽度
	parameter		TRIG_DELAY_WIDTH		= 28	,	//触发信号延时模块寄存器宽度
	parameter		LED_CTRL_WIDTH			= 5     ,	//LED CTRL 寄存器宽度
	parameter		SHORT_REG_WD			= 16	,	//短寄存器位宽
	parameter		REG_WD					= 32	,	//寄存器位宽
	parameter		LONG_REG_WD				= 64	,	//长寄存器位宽
	parameter		BUF_DEPTH_WD			= 4		,	//帧存深度位宽,我们最大支持8帧深度，多一位进位位
	parameter		REG_INIT_VALUE			= "TRUE"	//寄存器是否有初始值
	)
	(
	//  ===============================================================================================
	//	控制信号
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spi时钟域
	//  -------------------------------------------------------------------------------------
	//解析后的数据，主时钟域
	input								i_wr_en					,	//写使能，clk_sample时钟域
	input								i_rd_en					,	//读使能，clk_sample时钟域
	input								i_cmd_is_rd				,	//读命令来了，clk_sample时钟域
	input	[SPI_ADDR_LENGTH-1:0]		iv_addr					,	//读写地址，clk_sample时钟域
	input	[SHORT_REG_WD-1:0]			iv_wr_data				,	//写数据，clk_sample时钟域

	//  -------------------------------------------------------------------------------------
	//	pix 时钟域
	//  -------------------------------------------------------------------------------------
	input								clk_pix					,	//本地像素时钟，72Mhz
	input								reset_pix				,	//本地像素时钟的复位信号
	output								o_pix_sel				,	//本地像素时钟域被选择
	output	[SHORT_REG_WD-1:0]			ov_pix_rd_data			,	//读数据
	//  -------------------------------------------------------------------------------------
	//	frame buf 时钟域
	//  -------------------------------------------------------------------------------------
	input								clk_frame_buf			,	//帧存时钟100MHz
	input								reset_frame_buf			,	//帧存时钟的复位信号
	output								o_frame_buf_sel			,	//帧存时钟域被选择
	output	[SHORT_REG_WD-1:0]			ov_frame_buf_rd_data	,	//读数据
	//  -------------------------------------------------------------------------------------
	//	gpif 时钟域
	//  -------------------------------------------------------------------------------------
	input								clk_gpif				,	//gpif 时钟，100MHz
	input								reset_gpif				,	//gpif 时钟的复位信号
	output								o_gpif_sel				,	//gpif 时钟域被选择
	output	[SHORT_REG_WD-1:0]			ov_gpif_rd_data			,	//读数据
	//  -------------------------------------------------------------------------------------
	//	40MHz 时钟域
	//  -------------------------------------------------------------------------------------
	input								clk_osc_bufg			,	//osc bufg 时钟，40MHz
	input								reset_osc_bufg			,	//osc bufg 时钟的复位信号
	output								o_osc_bufg_sel			,	//osc 时钟域被选择
	output	[SHORT_REG_WD-1:0]			ov_osc_bufg_rd_data		,	//读数据
	//  -------------------------------------------------------------------------------------
	//	固定电平
	//  -------------------------------------------------------------------------------------
	output								o_fix_sel				,	//固定时钟域被选择
	output	[SHORT_REG_WD-1:0]			ov_fix_rd_data			,	//读数据
	//  ===============================================================================================
	//	以下内容是寄存器
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	通用
	//  -------------------------------------------------------------------------------------
	output								o_stream_enable_pix			,	//clk_pix时钟域，流使能信号
	output								o_acquisition_start_pix		,	//clk_pix时钟域，停开采信号
	output								o_stream_enable_frame_buf	,	//clk_frame_buf时钟域，流使能信号
	output								o_stream_enable_gpif		,	//clk_gpif时钟域，流使能信号
	//  -------------------------------------------------------------------------------------
	//	clk reset top
	//  -------------------------------------------------------------------------------------
	output								o_reset_sensor			,	//clk_osc_bufg时钟域，复位Sensor寄存器
	input								i_sensor_reset_done		,	//clk_osc_bufg时钟域，Sensor复位完成寄存器
	//  -------------------------------------------------------------------------------------
	//	io channel
	//  -------------------------------------------------------------------------------------
	output								o_trigger_mode			,	//clk_pix时钟域，触发模式寄存器
	output	[3:0]						ov_trigger_source		,	//clk_pix时钟域，触发源寄存器
	output								o_trigger_soft			,	//clk_pix时钟域，软触发寄存器
	output								o_trigger_active		,	//clk_pix时钟域，触发有效沿寄存器
	output	[TRIG_FILTER_WIDTH-1:0]		ov_trigger_filter_rise	,	//clk_pix时钟域，上升沿触发滤波寄存器
	output	[TRIG_FILTER_WIDTH-1:0]		ov_trigger_filter_fall	,	//clk_pix时钟域，下降沿触发滤波寄存器
	output	[TRIG_DELAY_WIDTH-1:0]		ov_trigger_delay		,	//clk_pix时钟域，触发延迟寄存器
	output	[2:0]						ov_useroutput_level		,	//clk_pix时钟域，用户自定义输出寄存器
	output								o_line2_mode			,	//clk_pix时钟域，line2输入输出模式寄存器
	output								o_line3_mode			,	//clk_pix时钟域，line3输入输出模式寄存器
	output								o_line0_invert			,	//clk_pix时钟域，line0极性寄存器
	output								o_line1_invert			,	//clk_pix时钟域，line1极性寄存器
	output								o_line2_invert			,	//clk_pix时钟域，line2极性寄存器
	output								o_line3_invert			,	//clk_pix时钟域，line3极性寄存器
	output	[2:0]						ov_line_source1			,	//clk_pix时钟域，line1的输出源选择寄存器
	output	[2:0]						ov_line_source2			,	//clk_pix时钟域，line2的输出源选择寄存器
	output	[2:0]						ov_line_source3			,	//clk_pix时钟域，line3的输出源选择寄存器
	input	[3:0]						iv_line_status			,	//clk_pix时钟域，line状态寄存器
	output	[LED_CTRL_WIDTH-1:0]		ov_led_ctrl				,	//clk_pix时钟域，双色灯控制寄存器
	
	//调试用
	input	[15:0]						iv_linein_sel_rise_cnt		,	//i_linein_sel的上升沿计数器
	input	[15:0]						iv_linein_sel_fall_cnt		,	//i_linein_sel的下降沿计数器
	input	[15:0]						iv_linein_filter_rise_cnt	,	//i_linein_filter的上升沿计数器
	input	[15:0]						iv_linein_filter_fall_cnt	,	//i_linein_filter的下降沿计数器
	input	[15:0]						iv_linein_active_cnt		,	//i_linein_active的上升沿计数器
	input	[15:0]						iv_trigger_n_rise_cnt		,	//i_trigger_n的上升沿计数器
	input	[15:0]						iv_trigger_soft_cnt			,	//i_trigger_soft的计数器
	input	[12:0]						iv_strobe_length_reg		,	//测量的strobe宽度
	
	//  -------------------------------------------------------------------------------------
	//	data channel
	//  -------------------------------------------------------------------------------------
	output	[REG_WD-1:0]				ov_pixel_format			,	//clk_pix时钟域，像素格式寄存器
	input								i_full_frame_state		,	//clk_pix时钟域，完整帧状态信号
	output								o_pulse_filter_en		,	//clk_pix时钟域，坏点校正寄存器
	output	[2:0]						ov_test_image_sel		,	//clk_pix时钟域，测试图选择寄存器
	output	[1:0]						ov_interrupt_en			,	//clk_pix时钟域，中断使能寄存器
	input	[1:0]						iv_interrupt_state		,	//clk_pix时钟域，中断状态寄存器
	output	[1:0]						ov_interrupt_clear		,	//clk_pix时钟域，中断清除寄存器，自清零
	output	[WB_OFFSET_WIDTH-1:0]		ov_wb_offset_x_start	,	//clk_pix时钟域，白平衡横坐标寄存器
	output	[WB_OFFSET_WIDTH-1:0]		ov_wb_offset_width		,	//clk_pix时钟域，白平衡宽度寄存器
	output	[WB_OFFSET_WIDTH-1:0]		ov_wb_offset_y_start	,	//clk_pix时钟域，白平衡纵坐标寄存器
	output	[WB_OFFSET_WIDTH-1:0]		ov_wb_offset_height		,	//clk_pix时钟域，白平衡高度寄存器
	output	[WB_GAIN_WIDTH-1:0]			ov_wb_gain_r			,	//clk_pix时钟域，白平衡红分量增益寄存器
	output	[WB_GAIN_WIDTH-1:0]			ov_wb_gain_g			,	//clk_pix时钟域，白平衡绿分量增益寄存器
	output	[WB_GAIN_WIDTH-1:0]			ov_wb_gain_b			,	//clk_pix时钟域，白平衡蓝分量增益寄存器
	input	[WB_STATIS_WIDTH-1:0]		iv_wb_statis_r			,	//clk_pix时钟域，白平衡红分量灰度值统计寄存器
	input	[WB_STATIS_WIDTH-1:0]		iv_wb_statis_g			,	//clk_pix时钟域，白平衡绿分量灰度值统计寄存器
	input	[WB_STATIS_WIDTH-1:0]		iv_wb_statis_b			,	//clk_pix时钟域，白平衡蓝分量灰度值统计寄存器
	input	[WB_OFFSET_WIDTH-1:0]		iv_wb_offset_width		,	//clk_pix时钟域，白平衡宽度寄存器
	input	[WB_OFFSET_WIDTH-1:0]		iv_wb_offset_height		,	//clk_pix时钟域，白平衡高度寄存器
	output	[GREY_OFFSET_WIDTH-1:0]		ov_grey_offset_x_start	,	//clk_pix时钟域，灰度值统计区域横坐标寄存器
	output	[GREY_OFFSET_WIDTH-1:0]		ov_grey_offset_width	,	//clk_pix时钟域，灰度值统计区域宽度寄存器
	output	[GREY_OFFSET_WIDTH-1:0]		ov_grey_offset_y_start	,	//clk_pix时钟域，灰度值统计区域纵坐标寄存器
	output	[GREY_OFFSET_WIDTH-1:0]		ov_grey_offset_height	,	//clk_pix时钟域，灰度值统计区域高度寄存器
	input	[GREY_STATIS_WIDTH-1:0]		iv_grey_statis_sum		,	//clk_pix时钟域，的灰度值统计寄存器，与灰度统计值区域同属一帧
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_width	,	//clk_pix时钟域，灰度值统计区域宽度寄存器，与灰度统计值同属一帧
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_height	,	//clk_pix时钟域，灰度值统计区域高度寄存器，与灰度统计值同属一帧
	
	//调试用
	input	[3:0]						iv_fval_state			,	//fval 状态
	
	//  -------------------------------------------------------------------------------------
	//	u3v format
	//  -------------------------------------------------------------------------------------
	output								o_chunk_mode_active		,	//clk_pix时钟域，chunk开关寄存器
	output								o_chunkid_en_ts			,	//clk_pix时钟域，时间戳开关寄存器
	output								o_chunkid_en_fid		,	//clk_pix时钟域，frame id开关寄存器
	output	[REG_WD-1:0]				ov_chunk_size_img		,	//clk_pix时钟域，chunk image大小
	output	[REG_WD-1:0]				ov_payload_size_pix		,	//clk_pix时钟域，数据的大小但不包含头包尾包，协议要求64bit，我们只是用32bit即可，高32bit补0
	output	[SHORT_REG_WD-1:0]			ov_roi_offset_x			,	//clk_pix时钟域，头包中的水平偏移
	output	[SHORT_REG_WD-1:0]			ov_roi_offset_y			,	//clk_pix时钟域，头包中的垂直偏移
	output	[SHORT_REG_WD-1:0]			ov_roi_pic_width		,	//clk_pix时钟域，头包中的窗口宽度
	output	[SHORT_REG_WD-1:0]			ov_roi_pic_height		,	//clk_pix时钟域，头包中的窗口高度
	//  -------------------------------------------------------------------------------------
	//	frame buffer
	//  -------------------------------------------------------------------------------------
	output	[REG_WD-1:0]				ov_payload_size_frame_buf		,	//clk_frame_buf时钟域，数据的大小但不包含头包尾包，协议要求64bit，我们只是用32bit即可，高32bit补0
	output	[BUF_DEPTH_WD-1:0]			ov_frame_buffer_depth			,	//clk_frame_buf时钟域，帧存深度，2-8
	output								o_chunk_mode_active_frame_buf	,	//clk_frame_buf时钟域，chunk开关寄存器
	input								i_ddr_init_done					,	//frame_buffer模块输出，mcb_drp_clk时钟域，MCB输出的初始化完整信号。
	input								i_ddr_error						,	//frame_buffer模块输出，时钟域未知，与MCB硬核相关，DDR错误信号
	//  -------------------------------------------------------------------------------------
	//	u3 interface
	//  -------------------------------------------------------------------------------------
	output	[REG_WD-1:0]				ov_si_payload_transfer_size			,	//clk_gpif时钟域，等量数据块大小
	output	[REG_WD-1:0]				ov_si_payload_transfer_count		,	//clk_gpif时钟域，等量数据块个数
	output	[REG_WD-1:0]				ov_si_payload_final_transfer1_size	,	//clk_gpif时钟域，transfer1大小
	output	[REG_WD-1:0]				ov_si_payload_final_transfer2_size	,	//clk_gpif时钟域，transfer2大小
	output	[REG_WD-1:0]				ov_payload_size_gpif				,	//clk_gpif时钟域，数据的大小但不包含头包尾包，协议要求64bit，我们只是用32bit即可，高32bit补0
	output								o_chunk_mode_active_gpif			,	//clk_gpif时钟域，chunk开关寄存器
	
	//调试用
	input	[4:0]						iv_gpif_state						,	//GPIF 状态
	
	//  -------------------------------------------------------------------------------------
	//	时间戳 40MHz 时钟域
	//  -------------------------------------------------------------------------------------
	output								o_timestamp_load	,	//clk_osc_bufg时钟域，时间戳加载信号，自清零
	input	[LONG_REG_WD-1:0]			iv_timestamp		,	//clk_osc_bufg时钟域，时间戳
	//  -------------------------------------------------------------------------------------
	//	DNA 1MHz 时钟域
	//  -------------------------------------------------------------------------------------
	input	[LONG_REG_WD-1:0]			iv_dna_reg			,	//clk_osc_bufg时钟域，dna数据
	output	[LONG_REG_WD-1:0]			ov_encrypt_reg		,	//clk_osc_bufg时钟域，固件设置的加密值
	input								i_encrypt_state			//clk_dna时钟域，加密状态
	);

	//	ref signals



	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	像素时钟域的寄存器
	//  -------------------------------------------------------------------------------------
	pix_reg_list # (
	.SPI_ADDR_LENGTH	(SPI_ADDR_LENGTH	),
	.WB_OFFSET_WIDTH	(WB_OFFSET_WIDTH	),
	.WB_GAIN_WIDTH		(WB_GAIN_WIDTH		),
	.WB_STATIS_WIDTH	(WB_STATIS_WIDTH	),
	.GREY_OFFSET_WIDTH	(GREY_OFFSET_WIDTH	),
	.GREY_STATIS_WIDTH	(GREY_STATIS_WIDTH	),
	.TRIG_FILTER_WIDTH	(TRIG_FILTER_WIDTH	),
	.TRIG_DELAY_WIDTH	(TRIG_DELAY_WIDTH	),
	.LED_CTRL_WIDTH		(LED_CTRL_WIDTH		),
	.SHORT_REG_WD		(SHORT_REG_WD		),
	.REG_WD				(REG_WD				),
	.LONG_REG_WD		(LONG_REG_WD		),
	.REG_INIT_VALUE		(REG_INIT_VALUE		)
	)
	pix_reg_list_inst (
	//  ===============================================================================================
	//	控制信号
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spi时钟域
	//  -------------------------------------------------------------------------------------
	.i_wr_en					(i_wr_en				),
	.i_rd_en					(i_rd_en				),
	.i_cmd_is_rd				(i_cmd_is_rd			),
	.iv_addr					(iv_addr				),
	.iv_wr_data					(iv_wr_data				),
	//  -------------------------------------------------------------------------------------
	//	pix 时钟域
	//  -------------------------------------------------------------------------------------
	.clk_pix					(clk_pix				),
	.o_pix_sel					(o_pix_sel				),
	.ov_pix_rd_data				(ov_pix_rd_data			),
	//  ===============================================================================================
	//	其他时钟域信号，需要和本时钟域的信号放在一个寄存器当中
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	clk reset top
	//  -------------------------------------------------------------------------------------
	.i_sensor_reset_done		(i_sensor_reset_done	),
	//  -------------------------------------------------------------------------------------
	//	frame buffer
	//  -------------------------------------------------------------------------------------
	.i_ddr_init_done			(i_ddr_init_done		),
	.i_ddr_error				(i_ddr_error			),
	//  ===============================================================================================
	//	以下内容是寄存器
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	通用
	//  -------------------------------------------------------------------------------------
	.o_stream_enable_pix		(o_stream_enable_pix	),
	.o_acquisition_start_pix	(o_acquisition_start_pix	),
	//  -------------------------------------------------------------------------------------
	//	io channel
	//  -------------------------------------------------------------------------------------
	.o_trigger_mode				(o_trigger_mode			),
	.ov_trigger_source			(ov_trigger_source		),
	.o_trigger_soft				(o_trigger_soft			),
	.o_trigger_active			(o_trigger_active		),
	.ov_trigger_filter_rise		(ov_trigger_filter_rise	),
	.ov_trigger_filter_fall		(ov_trigger_filter_fall	),
	.ov_trigger_delay			(ov_trigger_delay		),
	.ov_useroutput_level		(ov_useroutput_level	),
	.o_line2_mode				(o_line2_mode			),
	.o_line3_mode				(o_line3_mode			),
	.o_line0_invert				(o_line0_invert			),
	.o_line1_invert				(o_line1_invert			),
	.o_line2_invert				(o_line2_invert			),
	.o_line3_invert				(o_line3_invert			),
	.ov_line_source1			(ov_line_source1		),
	.ov_line_source2			(ov_line_source2		),
	.ov_line_source3			(ov_line_source3		),
	.iv_line_status				(iv_line_status			),
	.ov_led_ctrl				(ov_led_ctrl			),
	
	//调试用
	.iv_linein_sel_rise_cnt		(iv_linein_sel_rise_cnt		),
	.iv_linein_sel_fall_cnt		(iv_linein_sel_fall_cnt		),
	.iv_linein_filter_rise_cnt	(iv_linein_filter_rise_cnt	),
	.iv_linein_filter_fall_cnt	(iv_linein_filter_fall_cnt	),
	.iv_linein_active_cnt		(iv_linein_active_cnt		),
	.iv_trigger_n_rise_cnt		(iv_trigger_n_rise_cnt		),
	.iv_trigger_soft_cnt		(iv_trigger_soft_cnt		),
	.iv_strobe_length_reg		(iv_strobe_length_reg		),

	//  -------------------------------------------------------------------------------------
	//	data channel
	//  -------------------------------------------------------------------------------------
	.ov_pixel_format			(ov_pixel_format		),
	.i_full_frame_state			(i_full_frame_state		),
	.o_pulse_filter_en			(o_pulse_filter_en		),
	.ov_test_image_sel			(ov_test_image_sel		),
	.ov_interrupt_en			(ov_interrupt_en		),
	.iv_interrupt_state			(iv_interrupt_state		),
	.ov_interrupt_clear			(ov_interrupt_clear		),
	.ov_wb_offset_x_start		(ov_wb_offset_x_start	),
	.ov_wb_offset_width			(ov_wb_offset_width		),
	.ov_wb_offset_y_start		(ov_wb_offset_y_start	),
	.ov_wb_offset_height		(ov_wb_offset_height	),
	
	//调试用
	.iv_fval_state				(iv_fval_state			),
	
	//  -------------------------------------------------------------------------------------
	//	u3v format
	//  -------------------------------------------------------------------------------------
	.ov_wb_gain_r				(ov_wb_gain_r			),
	.ov_wb_gain_g				(ov_wb_gain_g			),
	.ov_wb_gain_b				(ov_wb_gain_b			),
	.iv_wb_statis_r				(iv_wb_statis_r			),
	.iv_wb_statis_g				(iv_wb_statis_g			),
	.iv_wb_statis_b				(iv_wb_statis_b			),
	.iv_wb_offset_width			(iv_wb_offset_width		),
	.iv_wb_offset_height		(iv_wb_offset_height	),
	.ov_grey_offset_x_start		(ov_grey_offset_x_start	),
	.ov_grey_offset_width		(ov_grey_offset_width	),
	.ov_grey_offset_y_start		(ov_grey_offset_y_start	),
	.ov_grey_offset_height		(ov_grey_offset_height	),
	.iv_grey_statis_sum			(iv_grey_statis_sum		),
	.iv_grey_offset_width		(iv_grey_offset_width	),
	.iv_grey_offset_height		(iv_grey_offset_height	),
	//  -------------------------------------------------------------------------------------
	//	u3v format
	//  -------------------------------------------------------------------------------------
	.o_chunk_mode_active		(o_chunk_mode_active	),
	.o_chunkid_en_ts			(o_chunkid_en_ts		),
	.o_chunkid_en_fid			(o_chunkid_en_fid		),
	.ov_chunk_size_img			(ov_chunk_size_img		),
	.ov_payload_size_pix		(ov_payload_size_pix	),
	.ov_roi_offset_x			(ov_roi_offset_x		),
	.ov_roi_offset_y			(ov_roi_offset_y		),
	.ov_roi_pic_width			(ov_roi_pic_width		),
	.ov_roi_pic_height			(ov_roi_pic_height		)
	);

	//  -------------------------------------------------------------------------------------
	//	gpif时钟域的寄存器
	//  -------------------------------------------------------------------------------------
	gpif_reg_list # (
	.SPI_ADDR_LENGTH	(SPI_ADDR_LENGTH	),
	.SHORT_REG_WD		(SHORT_REG_WD		),
	.REG_WD				(REG_WD				),
	.LONG_REG_WD		(LONG_REG_WD		),
	.REG_INIT_VALUE		(REG_INIT_VALUE		)
	)
	gpif_reg_list_inst (
	//  ===============================================================================================
	//	控制信号
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spi时钟域
	//  -------------------------------------------------------------------------------------
	.i_wr_en							(i_wr_en							),
	.i_rd_en							(i_rd_en							),
	.i_cmd_is_rd						(i_cmd_is_rd						),
	.iv_addr							(iv_addr							),
	.iv_wr_data							(iv_wr_data							),
	//  -------------------------------------------------------------------------------------
	//	gpif 时钟域
	//  -------------------------------------------------------------------------------------
	.clk_gpif							(clk_gpif							),
	.o_gpif_sel							(o_gpif_sel							),
	.ov_gpif_rd_data					(ov_gpif_rd_data					),
	//  ===============================================================================================
	//	以下内容是寄存器
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	通用
	//  -------------------------------------------------------------------------------------
	.o_stream_enable_gpif				(o_stream_enable_gpif				),
	//  -------------------------------------------------------------------------------------
	//	u3 interface
	//  -------------------------------------------------------------------------------------
	.ov_si_payload_transfer_size		(ov_si_payload_transfer_size		),
	.ov_si_payload_transfer_count		(ov_si_payload_transfer_count		),
	.ov_si_payload_final_transfer1_size	(ov_si_payload_final_transfer1_size	),
	.ov_si_payload_final_transfer2_size	(ov_si_payload_final_transfer2_size	),
	.ov_payload_size_gpif				(ov_payload_size_gpif				),
	.o_chunk_mode_active_gpif			(o_chunk_mode_active_gpif			),
	
	//调试用
	.iv_gpif_state						(iv_gpif_state						)
	);

	//  -------------------------------------------------------------------------------------
	//	frame buf时钟域的寄存器
	//  -------------------------------------------------------------------------------------
	frame_buf_reg_list # (
	.SPI_ADDR_LENGTH				(SPI_ADDR_LENGTH				),
	.SHORT_REG_WD					(SHORT_REG_WD					),
	.REG_WD							(REG_WD							),
	.LONG_REG_WD					(LONG_REG_WD					),
	.BUF_DEPTH_WD					(BUF_DEPTH_WD					),
	.REG_INIT_VALUE					(REG_INIT_VALUE					)
	)
	frame_buf_reg_list_inst (
	//  ===============================================================================================
	//	控制信号
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spi时钟域
	//  -------------------------------------------------------------------------------------
	.i_wr_en						(i_wr_en						),
	.i_rd_en						(i_rd_en						),
	.i_cmd_is_rd					(i_cmd_is_rd					),
	.iv_addr						(iv_addr						),
	.iv_wr_data						(iv_wr_data						),
	//  -------------------------------------------------------------------------------------
	//	frame buf 时钟域
	//  -------------------------------------------------------------------------------------
	.clk_frame_buf					(clk_frame_buf					),
	.o_frame_buf_sel				(o_frame_buf_sel				),
	.ov_frame_buf_rd_data			(ov_frame_buf_rd_data			),
	//  ===============================================================================================
	//	以下内容是寄存器
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	通用
	//  -------------------------------------------------------------------------------------
	.o_stream_enable_frame_buf		(o_stream_enable_frame_buf		),
	//  -------------------------------------------------------------------------------------
	//	frame buffer
	//  -------------------------------------------------------------------------------------
	.ov_payload_size_frame_buf		(ov_payload_size_frame_buf		),
	.ov_frame_buffer_depth			(ov_frame_buffer_depth			),
	.o_chunk_mode_active_frame_buf	(o_chunk_mode_active_frame_buf	)
	);

	//  -------------------------------------------------------------------------------------
	//	clk osc bufg时钟域的寄存器
	//  -------------------------------------------------------------------------------------
	osc_bufg_reg_list # (
	.SPI_ADDR_LENGTH	(SPI_ADDR_LENGTH	),
	.SHORT_REG_WD		(SHORT_REG_WD		),
	.REG_WD				(REG_WD				),
	.LONG_REG_WD		(LONG_REG_WD		)
	)
	osc_bufg_reg_list_inst (
	//  ===============================================================================================
	//	控制信号
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spi时钟域
	//  -------------------------------------------------------------------------------------
	.i_wr_en				(i_wr_en			),
	.i_rd_en				(i_rd_en			),
	.i_cmd_is_rd			(i_cmd_is_rd		),
	.iv_addr				(iv_addr			),
	.iv_wr_data				(iv_wr_data			),
	//  -------------------------------------------------------------------------------------
	//	40MHz 时钟域
	//  -------------------------------------------------------------------------------------
	.clk_osc_bufg			(clk_osc_bufg		),
	.o_osc_bufg_sel			(o_osc_bufg_sel		),
	.ov_osc_bufg_rd_data	(ov_osc_bufg_rd_data),
	//  ===============================================================================================
	//	以下内容是寄存器
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	clk reset top
	//  -------------------------------------------------------------------------------------
	.o_reset_sensor			(o_reset_sensor		),
	//  -------------------------------------------------------------------------------------
	//	时间戳 40MHz 时钟域
	//  -------------------------------------------------------------------------------------
	.o_timestamp_load		(o_timestamp_load	),
	.iv_timestamp			(iv_timestamp		),
	//  -------------------------------------------------------------------------------------
	//	clk_osc_bufg时钟域
	//  -------------------------------------------------------------------------------------
	.iv_dna_reg				(iv_dna_reg			),
	.ov_encrypt_reg			(ov_encrypt_reg		),
	.i_encrypt_state		(i_encrypt_state	)
	);

	//  -------------------------------------------------------------------------------------
	//	固定电平时钟域的寄存器
	//  -------------------------------------------------------------------------------------
	fix_reg_list # (
	.SPI_ADDR_LENGTH	(SPI_ADDR_LENGTH	),
	.SHORT_REG_WD		(SHORT_REG_WD		),
	.REG_WD				(REG_WD				),
	.LONG_REG_WD		(LONG_REG_WD		)
	)
	fix_reg_list_inst (
	//  ===============================================================================================
	//	控制信号
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spi时钟域
	//  -------------------------------------------------------------------------------------
	.i_rd_en			(i_rd_en			),
	.iv_addr			(iv_addr			),
	//  -------------------------------------------------------------------------------------
	//	固定电平
	//  -------------------------------------------------------------------------------------
	.o_fix_sel			(o_fix_sel			),
	.ov_fix_rd_data		(ov_fix_rd_data		)
	);

endmodule