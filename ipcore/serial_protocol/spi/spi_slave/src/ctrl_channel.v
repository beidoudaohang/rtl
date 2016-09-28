//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : ctrl_channel
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/12 10:37:21	:|  初始版本
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

module ctrl_channel # (
	parameter				WB_OFFSET_WIDTH			= 12	,	//白平衡模块偏移位置寄存器宽度
	parameter				WB_GAIN_WIDTH			= 11	,	//白平衡模块增益寄存器宽度
	parameter				WB_STATIS_WIDTH			= 31	,	//白平衡模块统计值宽度
	parameter				GREY_OFFSET_WIDTH		= 12	,	//灰度统计模块偏移位置寄存器
	parameter				GREY_STATIS_WIDTH		= 48	,	//灰度统计模块统计值宽度
	parameter				TRIG_FILTER_WIDTH		= 19	,	//触发信号滤波模块寄存器宽度
	parameter				TRIG_DELAY_WIDTH		= 28	,	//触发信号延时模块寄存器宽度
	parameter				LED_CTRL_WIDTH			= 5		,	//LED CTRL 寄存器宽度
	parameter				SHORT_REG_WD			= 16	,	//短寄存器位宽
	parameter				REG_WD					= 32	,	//寄存器位宽
	parameter				LONG_REG_WD				= 64	,	//长寄存器位宽
	parameter				BUF_DEPTH_WD			= 4		,	//帧存深度位宽,我们最大支持8帧深度，多一位进位位
	parameter				REG_INIT_VALUE			= "FALSE"	//寄存器是否有初始值
	)
	(
	//  ===============================================================================================
	//	控制信号
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spi时钟域
	//  -------------------------------------------------------------------------------------
	input								i_spi_clk			,	//spi时钟，上升沿采样， 时钟的高电平宽度至少是 主时钟周期 的3倍
	input								i_spi_cs_n			,	//spi片选，低有效
	input								i_spi_mosi			,	//spi输入数据
	output								o_spi_miso_data		,	//spi输出数据
	output								o_spi_miso_data_en	,	//spi miso有效信号，0-spi——mosi 三态 1-输出数据
	//  -------------------------------------------------------------------------------------
	//	40MHz时钟
	//  -------------------------------------------------------------------------------------
	input								clk_osc_bufg		,	//40MHz时钟，全局缓冲驱动，时间戳模块使用
	input								reset_osc_bufg		,	//40MHz时钟的复位信号
	//  -------------------------------------------------------------------------------------
	//	pix 时钟域
	//  -------------------------------------------------------------------------------------
	input								clk_pix				,	//本地像素时钟，72Mhz
	input								reset_pix			,	//本地像素时钟的复位信号
	input								i_fval				,	//clk_pix时钟域，场有效信号，在上下边沿锁存时间戳
	//  -------------------------------------------------------------------------------------
	//	frame buf 时钟域
	//  -------------------------------------------------------------------------------------
	input								clk_frame_buf		,	//帧存时钟100MHz
	input								reset_frame_buf		,	//帧存时钟的复位信号
	//  -------------------------------------------------------------------------------------
	//	gpif 时钟域
	//  -------------------------------------------------------------------------------------
	input								clk_gpif			,	//gpif 时钟，100MHz
	input								reset_gpif			,	//gpif 时钟的复位信号
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
	output								o_encrypt_state			,	//clk_dna时钟域，加密状态，上电后保持不变，可以作为常数
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
	output	[LONG_REG_WD-1:0]			ov_timestamp_u3			,	//clk_osc_bufg时钟域，在场信号上下沿锁存时间戳计数器。最长4个clk_osc_bufg时钟输出稳定，在pix时钟域看来，最长8个时钟之后才能稳定
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
	input	[4:0]						iv_gpif_state							//GPIF 状态
	);

	//	ref signals

	//	-------------------------------------------------------------------------------------
	//	固定参数
	//	-------------------------------------------------------------------------------------
	localparam			SPI_CMD_LENGTH		= 8			;	//spi 命令的长度
	localparam			SPI_CMD_WR			= 8'h80		;	//spi 写命令
	localparam			SPI_CMD_RD			= 8'h81		;	//spi 读命令
	localparam			SPI_ADDR_LENGTH		= 16		;	//spi 地址的长度

	wire							clk_spi_sample		;	//spi 采样时钟
	wire							w_wr_en				;	//spi_slave输出，clk_sample时钟域，写使能
	wire							w_rd_en				;	//spi_slave输出，clk_sample时钟域，读使能
	wire							w_cmd_is_rd			;	//spi_slave输出，clk_sample时钟域，读命令来了
	wire	[SPI_ADDR_LENGTH-1:0]	wv_addr				;	//spi_slave输出，clk_sample时钟域，读写地址
	wire	[SHORT_REG_WD-1:0]		wv_wr_data			;	//spi_slave输出，clk_sample时钟域，写数据

	wire							w_pix_sel			;	//pix 时钟域被选择信号
	wire	[SHORT_REG_WD-1:0]		wv_pix_rd_data		;	//pix 时钟域数据输出
	wire							w_frame_buf_sel		;	//frame buf 时钟域被选择信号
	wire	[SHORT_REG_WD-1:0]		wv_frame_buf_rd_data;	//frame buf 时钟域数据输出
	wire							w_gpif_sel			;	//gpif 时钟域被选择信号
	wire	[SHORT_REG_WD-1:0]		wv_gpif_rd_data		;	//gpif 时钟域数据输出
	wire							w_osc_bufg_sel		;	//osc bufg 时钟域被选择信号
	wire	[SHORT_REG_WD-1:0]		wv_osc_bufg_rd_data	;	//osc bufg 时钟域数据输出
	wire							w_fix_sel			;	//fix 时钟域被选择信号，采用spi 采样时钟
	wire	[SHORT_REG_WD-1:0]		wv_fix_rd_data		;	//fix 时钟域数据输出，采用spi 采样时钟

	wire							w_timestamp_load	;	//mer_reg输出，clk_osc_bufg时钟域，时间戳加载信号，自清零
	wire	[LONG_REG_WD-1:0]		wv_timestamp_reg	;	//timestamp输出，clk_osc_bufg时钟域，时间戳
	wire	[LONG_REG_WD-1:0]		wv_dna_reg			;	//dna输出，clk_osc_bufg时钟域，dna数据
	wire	[LONG_REG_WD-1:0]		wv_encrypt_reg		;	//mer_reg输出，clk_osc_bufg时钟域，固件设置的加密值

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	确定spi采样时钟
	//	-------------------------------------------------------------------------------------
	assign	clk_spi_sample	= clk_gpif	;
	//  ===============================================================================================
	//	spi 解析模块
	//  ===============================================================================================
	spi_slave # (
	.SPI_CMD_LENGTH			(SPI_CMD_LENGTH			),
	.SPI_CMD_WR				(SPI_CMD_WR				),
	.SPI_CMD_RD				(SPI_CMD_RD				),
	.SPI_ADDR_LENGTH		(SPI_ADDR_LENGTH		),
	.SPI_DATA_LENGTH		(SHORT_REG_WD			)
	)
	spi_slave_inst (
	.clk_spi_sample			(clk_spi_sample			),
	.i_spi_clk				(i_spi_clk				),
	.i_spi_cs_n				(i_spi_cs_n				),
	.i_spi_mosi				(i_spi_mosi				),
	.o_spi_miso_data		(o_spi_miso_data		),
	.o_spi_miso_data_en		(o_spi_miso_data_en		),
	.o_wr_en				(w_wr_en				),
	.o_rd_en				(w_rd_en				),
	.o_cmd_is_rd			(w_cmd_is_rd			),
	.ov_addr				(wv_addr				),
	.ov_wr_data				(wv_wr_data				),
	.i_pix_sel				(w_pix_sel				),
	.iv_pix_rd_data			(wv_pix_rd_data			),
	.i_frame_buf_sel		(w_frame_buf_sel		),
	.iv_frame_buf_rd_data	(wv_frame_buf_rd_data	),
	.i_gpif_sel				(w_gpif_sel				),
	.iv_gpif_rd_data		(wv_gpif_rd_data		),
	.i_osc_bufg_sel			(w_osc_bufg_sel			),
	.iv_osc_bufg_rd_data	(wv_osc_bufg_rd_data	),
	.i_fix_sel				(w_fix_sel				),
	.iv_fix_rd_data			(wv_fix_rd_data			)
	);

	//  ===============================================================================================
	//	reg 列表
	//  ===============================================================================================
	mer_reg # (
	.SPI_ADDR_LENGTH		(SPI_ADDR_LENGTH		),
	.WB_OFFSET_WIDTH		(WB_OFFSET_WIDTH		),
	.WB_GAIN_WIDTH			(WB_GAIN_WIDTH			),
	.WB_STATIS_WIDTH		(WB_STATIS_WIDTH		),
	.GREY_STATIS_WIDTH		(GREY_STATIS_WIDTH		),
	.TRIG_FILTER_WIDTH		(TRIG_FILTER_WIDTH		),
	.TRIG_DELAY_WIDTH		(TRIG_DELAY_WIDTH		),
	.LED_CTRL_WIDTH			(LED_CTRL_WIDTH			),
	.SHORT_REG_WD			(SHORT_REG_WD			),
	.REG_WD					(REG_WD					),
	.LONG_REG_WD			(LONG_REG_WD			),
	.BUF_DEPTH_WD			(BUF_DEPTH_WD			),
	.REG_INIT_VALUE			(REG_INIT_VALUE			)
	)
	mer_reg_inst (
	//  ===============================================================================================
	//	控制信号
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spi时钟域
	//  -------------------------------------------------------------------------------------
	.i_wr_en						(w_wr_en				),
	.i_rd_en						(w_rd_en				),
	.i_cmd_is_rd					(w_cmd_is_rd			),
	.iv_addr						(wv_addr				),
	.iv_wr_data						(wv_wr_data				),
	//  -------------------------------------------------------------------------------------
	//	pix 时钟域
	//  -------------------------------------------------------------------------------------
	.clk_pix						(clk_pix				),
	.reset_pix						(reset_pix				),
	.o_pix_sel						(w_pix_sel				),
	.ov_pix_rd_data					(wv_pix_rd_data			),
	//  -------------------------------------------------------------------------------------
	//	frame buf 时钟域
	//  -------------------------------------------------------------------------------------
	.clk_frame_buf					(clk_frame_buf			),
	.reset_frame_buf				(reset_frame_buf		),
	.o_frame_buf_sel				(w_frame_buf_sel		),
	.ov_frame_buf_rd_data			(wv_frame_buf_rd_data	),
	//  -------------------------------------------------------------------------------------
	//	gpif 时钟域
	//  -------------------------------------------------------------------------------------
	.clk_gpif						(clk_gpif				),
	.reset_gpif						(reset_gpif				),
	.o_gpif_sel						(w_gpif_sel				),
	.ov_gpif_rd_data				(wv_gpif_rd_data		),
	//  -------------------------------------------------------------------------------------
	//	40MHz 时钟域
	//  -------------------------------------------------------------------------------------
	.clk_osc_bufg					(clk_osc_bufg			),
	.reset_osc_bufg					(reset_osc_bufg			),
	.o_osc_bufg_sel					(w_osc_bufg_sel			),
	.ov_osc_bufg_rd_data			(wv_osc_bufg_rd_data	),
	//  -------------------------------------------------------------------------------------
	//	固定电平
	//  -------------------------------------------------------------------------------------
	.o_fix_sel						(w_fix_sel				),
	.ov_fix_rd_data					(wv_fix_rd_data			),
	//  ===============================================================================================
	//	以下内容是寄存器
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	通用
	//  -------------------------------------------------------------------------------------
	.o_stream_enable_pix			(o_stream_enable_pix		),
	.o_acquisition_start_pix		(o_acquisition_start_pix	),
	.o_stream_enable_frame_buf		(o_stream_enable_frame_buf	),
	.o_stream_enable_gpif			(o_stream_enable_gpif		),
	//  -------------------------------------------------------------------------------------
	//	clk reset top
	//  -------------------------------------------------------------------------------------
	.i_sensor_reset_done			(i_sensor_reset_done	),
	.o_reset_sensor					(o_reset_sensor			),
	//  -------------------------------------------------------------------------------------
	//	io channel
	//  -------------------------------------------------------------------------------------
	.o_trigger_mode					(o_trigger_mode			),
	.ov_trigger_source				(ov_trigger_source		),
	.o_trigger_soft					(o_trigger_soft			),
	.o_trigger_active				(o_trigger_active		),
	.ov_trigger_filter_rise			(ov_trigger_filter_rise	),
	.ov_trigger_filter_fall			(ov_trigger_filter_fall	),
	.ov_trigger_delay				(ov_trigger_delay		),
	.ov_useroutput_level			(ov_useroutput_level	),
	.o_line2_mode					(o_line2_mode			),
	.o_line3_mode					(o_line3_mode			),
	.o_line0_invert					(o_line0_invert			),
	.o_line1_invert					(o_line1_invert			),
	.o_line2_invert					(o_line2_invert			),
	.o_line3_invert					(o_line3_invert			),
	.ov_line_source1				(ov_line_source1		),
	.ov_line_source2				(ov_line_source2		),
	.ov_line_source3				(ov_line_source3		),
	.iv_line_status					(iv_line_status			),
	.ov_led_ctrl					(ov_led_ctrl			),
	
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
	.ov_pixel_format				(ov_pixel_format		),
	.i_full_frame_state				(i_full_frame_state		),
	.o_pulse_filter_en				(o_pulse_filter_en		),
	.ov_test_image_sel				(ov_test_image_sel		),
	.ov_interrupt_en				(ov_interrupt_en		),
	.iv_interrupt_state				(iv_interrupt_state		),
	.ov_interrupt_clear				(ov_interrupt_clear		),
	.ov_wb_offset_x_start			(ov_wb_offset_x_start	),
	.ov_wb_offset_width				(ov_wb_offset_width		),
	.ov_wb_offset_y_start			(ov_wb_offset_y_start	),
	.ov_wb_offset_height			(ov_wb_offset_height	),
	.ov_wb_gain_r					(ov_wb_gain_r			),
	.ov_wb_gain_g					(ov_wb_gain_g			),
	.ov_wb_gain_b					(ov_wb_gain_b			),
	.iv_wb_statis_r					(iv_wb_statis_r			),
	.iv_wb_statis_g					(iv_wb_statis_g			),
	.iv_wb_statis_b					(iv_wb_statis_b			),
	.iv_wb_offset_width				(iv_wb_offset_width		),
	.iv_wb_offset_height			(iv_wb_offset_height	),
	.ov_grey_offset_x_start			(ov_grey_offset_x_start	),
	.ov_grey_offset_width			(ov_grey_offset_width	),
	.ov_grey_offset_y_start			(ov_grey_offset_y_start	),
	.ov_grey_offset_height			(ov_grey_offset_height	),
	.iv_grey_statis_sum				(iv_grey_statis_sum		),
	.iv_grey_offset_width			(iv_grey_offset_width	),
	.iv_grey_offset_height			(iv_grey_offset_height	),
	
	//调试用
	.iv_fval_state					(iv_fval_state			),
	
	//  -------------------------------------------------------------------------------------
	//	u3v format
	//  -------------------------------------------------------------------------------------
	.o_chunk_mode_active			(o_chunk_mode_active	),
	.o_chunkid_en_ts				(o_chunkid_en_ts		),
	.o_chunkid_en_fid				(o_chunkid_en_fid		),
	.ov_chunk_size_img				(ov_chunk_size_img		),
	.ov_payload_size_pix			(ov_payload_size_pix	),
	.ov_roi_offset_x				(ov_roi_offset_x		),
	.ov_roi_offset_y				(ov_roi_offset_y		),
	.ov_roi_pic_width				(ov_roi_pic_width		),
	.ov_roi_pic_height				(ov_roi_pic_height		),
	//  -------------------------------------------------------------------------------------
	//	frame buffer
	//  -------------------------------------------------------------------------------------
	.ov_payload_size_frame_buf			(ov_payload_size_frame_buf		),
	.ov_frame_buffer_depth				(ov_frame_buffer_depth			),
	.o_chunk_mode_active_frame_buf		(o_chunk_mode_active_frame_buf	),
	.i_ddr_init_done					(i_ddr_init_done				),
	.i_ddr_error						(i_ddr_error					),
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
	.iv_gpif_state						(iv_gpif_state						),

	//  -------------------------------------------------------------------------------------
	//	时间戳 40MHz 时钟域
	//  -------------------------------------------------------------------------------------
	.o_timestamp_load					(w_timestamp_load		),
	.iv_timestamp						(wv_timestamp_reg		),
	//  -------------------------------------------------------------------------------------
	//	DNA 1MHz 时钟域
	//  -------------------------------------------------------------------------------------
	.iv_dna_reg							(wv_dna_reg				),
	.ov_encrypt_reg						(wv_encrypt_reg			),
	.i_encrypt_state					(o_encrypt_state		)
	);

	//  ===============================================================================================
	//	时间戳
	//  ===============================================================================================
	timestamp # (
	.LONG_REG_WD		(LONG_REG_WD		)
	)
	timestamp_inst (
	.clk				(clk_osc_bufg		),
	.reset				(reset_osc_bufg		),
	.i_fval				(i_fval				),
	.ov_timestamp_u3	(ov_timestamp_u3	),
	.i_timestamp_load	(w_timestamp_load	),
	.ov_timestamp_reg	(wv_timestamp_reg	)
	);

	//  ===============================================================================================
	//	DNA
	//  ===============================================================================================
	dna # (
	.LONG_REG_WD		(LONG_REG_WD		),
	.REG_INIT_VALUE		(REG_INIT_VALUE		)
	)
	dna_inst (
	.clk				(clk_osc_bufg		),
	.reset				(reset_osc_bufg		),
	.ov_dna_reg			(wv_dna_reg			),
	.iv_encrypt_reg		(wv_encrypt_reg		),
	.o_encrypt_state	(o_encrypt_state	)
	);


endmodule