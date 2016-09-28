//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : mer_500_14u3x
//  -- 设计者       : 张强
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期     :|  修改说明
//---------------------------------------------------------------------------------------
//  -- 张强         :| 2014/11/25   :|  描述顶层信号属性
//	-- 邢海涛		:| 2015/3/30 	:|	将写完的二级模块整合进来
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1) 	: 该模块是mer_500_14u3x相机的顶层模块，主要包含：xxxx二级模块
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
module mer_500_14u3x  # (
	parameter	SENSOR_DAT_WIDTH			= 10				,	//Sensor 数据宽度
	parameter	GPIF_DAT_WIDTH				= 32				,	//GPIF数据宽度
	parameter	NUM_GPIO					= 2					,	//GPIO个数
	parameter	NUM_DQ_PINS					= 16 				,	//DDR3数据宽度
	parameter	MEM_ADDR_WIDTH				= 13 				,	//DDR3地址宽度
	parameter	MEM_BANKADDR_WIDTH			= 3  				,	//DDR3bank宽度
	parameter	DDR3_MEMCLK_FREQ			= 320				,	//DDR3时钟频率
	parameter	DDR3_MEM_DENSITY			= "1Gb"				,	//DDR3容量
	parameter	DDR3_TCK_SPEED				= "15E"				,	//DDR3的速度等级
	parameter	DDR3_SIMULATION				= "FALSE"			,	//打开仿真可以加速仿真速度，但是实际布局布线时，不能打开仿真。
	parameter	DDR3_CALIB_SOFT_IP			= "TRUE"				//仿真时，可以不使能校准逻辑
	)
	(
	//  ===============================================================================================
	//  第一部分：输入时钟信号
	//  ===============================================================================================
	input									clk_osc				,	//输入引脚，40MHz，接外部晶振
	//  ===============================================================================================
	//  第二部分：sensor接口信号
	//  ===============================================================================================
	input									clk_sensor_pix		,	//输入引脚，Sensor驱动，72MHz，随路像素时钟,与本地72Mhz同频但不同相，可认为完全异步的两个信号，如果sensor复位，sensor输出时钟可能停止输出，而FPGA内部时钟不停止
	input		[SENSOR_DAT_WIDTH-1:0]		iv_pix_data			,	//输入引脚，Sensor驱动，图像数据，与clk_sensor_pix上升沿对齐，电路连接sensor高10位数据线，低2位数据没有接入到FPGA中
	input									i_fval				,	//输入引脚，Sensor驱动，场有效信号，与clk_sensor_pix上升沿对齐。i_fval上升沿与i_lval上升沿对齐，i_fval下降沿与i_lval下降沿对齐
	input									i_lval				,	//输入引脚，Sensor驱动，行有效信号，与clk_sensor_pix上升沿对齐。i_fval上升沿与i_lval上升沿对齐，i_fval下降沿与i_lval下降沿对齐。，i_fval无效期间也有可能输出
	input									i_sensor_strobe		,	//输入引脚，Sensor驱动，高有效，闪光灯信号，与clk_sensor_pix上升沿对齐，sensor本身有bug，当SW<=VB+H的时候，也会有strobe输出（但最大宽度不超过一行周期）
	output									o_clk_sensor		,	//输出引脚，连接到Sensor，Sensor的时钟，20Mhz，由40M晶振分配而来。按照MT9P031手册，在复位的时候，Sensor需要输入时钟
	output									o_trigger_n			,	//输出引脚，连接到Sensor，Sensor的触发信号，低有效，有效宽度8192clk_pix，clk_pix时钟域。经过测试，Sensor要求触发信号的宽度至少一行的时间
	output									o_senser_reset_n	,	//输出引脚，连接到Sensor，Sensor的复位信号，低有效，1ms宽度，FPGA配置完成后立即输出。相机运行中不复位Sensor
	input	[9:4]							iv_pix_data_mux		,	//复用的输入引脚
	input									clk_sensor_pix_mux	,	//复用的输入引脚
	input									i_fval_mux			,	//复用的输入引脚
	input									i_lval_mux			,	//复用的输入引脚
	input									i_sensor_strobe_mux	,	//复用的输入引脚
	//  ===============================================================================================
	//  第二部分：GPIF接口信号
	//  ===============================================================================================
	output									o_clk_usb_pclk		,	//输出引脚，连接到3014，GPIF接口的时钟100MHz，使用ODDR输出，在FPGA 引脚上，时钟下降沿与gpif数据对齐
	output		[GPIF_DAT_WIDTH-1:0]		ov_usb_data			,	//输出引脚，连接到3014，GPIF接口的数据，clk_gpif 时钟域，在FPGA引脚上，o_clk_usb_pclk与ov_usb_data对齐
	output		[1:0]						ov_usb_fifoaddr		,	//输出引脚，连接到3014，GPIF fifo地址，clk_gpif 时钟域，00和11交替，在FPGA引脚上，o_clk_usb_pclk与ov_usb_data对齐
	output									o_usb_slwr_n		,	//输出引脚，连接到3014，GPIF 写信号，clk_gpif 时钟域
	output									o_usb_pktend_n		,	//输出引脚，连接到3014，GPIF 包结束信号，clk_gpif 时钟域
	input									i_usb_flagb_n		,	//输入引脚，连接到3014，3014驱动，o_clk_usb_pclk 时钟域，GPIF当前DMAbuffer满信号，与 clk_gpif 有相位差，认为是异步信号，需要在 u3_interface 模块中做跨时钟域处理
	//  ===============================================================================================
	//  第三部分：SPI接口信号
	//  ===============================================================================================
	input									i_usb_spi_sck		,	//输入引脚，3014驱动，SPI时钟，出厂程序10Mhz，用户程序463Khz频率，FPGA需都满足。当固件是用户程序时，信号占空比可能会有较大变化，但信号最小宽度保证>384ns
	input									i_usb_spi_mosi		,	//输入引脚，3014驱动，SPI数据输入，信号宽度可能会有较大变化，但信号最小宽度保证>384ns
	input									i_spi_cs_n_fpga		,	//输入引脚，3014驱动，SPI FPGA片选，固件不一定能保证只有访问FPGA时片选才拉低，FPGA需要屏蔽异常的片选
	output									o_usb_spi_miso		,	//输出引脚，连接到3014，外部与flash的输出相连，SPI数据输出，只有读命令通过之后才输出有效数据，否则高阻。片选无效时，立即高阻
	//  ===============================================================================================
	//  第四部分：IO接口信号
	//  ===============================================================================================
	input									i_optocoupler		,	//输入引脚，光耦驱动，宽度从0到无穷大都有可能，上下沿有毛刺，宽度大于帧周期时需要屏蔽下降沿的误触发，异步信号
	input		[NUM_GPIO-1:0]				iv_gpio				,	//输入引脚，三极管驱动，双向IO的输入端，宽度从0到无穷大都有可能，较容易受干扰，异步信号。双向IO配置为输入时需屏蔽为0
	output									o_optocoupler		,	//输出引脚，连接到光耦，光耦输出电路有延时，上沿延时7~44us，下沿延时9~35us
	output		[NUM_GPIO-1:0]				ov_gpio				,	//输出引脚，连接到三极管，双向IO的输出端，延时<1us,双向IO配置为输入时需配置为0
	output									o_f_led_gre			,	//输出引脚，连接到LED，绿色指示灯，高电平点亮
	output									o_f_led_red			,	//输出引脚，连接到LED，红色指示灯，高电平点亮
	//  ===============================================================================================
	//  第五部分：DDR3接口信号
	//  下述的使用信号属于ddr3芯片外部接口信号，具体信号定义参考标准的ddr3接口
	//  ===============================================================================================
	inout  		[NUM_DQ_PINS-1:0]			mcb1_dram_dq		,	//DDR3相关引脚，数据信号
	output 		[MEM_ADDR_WIDTH-1:0]		mcb1_dram_a			,	//DDR3相关引脚，地址信号
	output 		[MEM_BANKADDR_WIDTH-1:0]	mcb1_dram_ba		,	//DDR3相关引脚，Bank地址信号
	output									mcb1_dram_ras_n		,	//DDR3相关引脚，行地址选通
	output									mcb1_dram_cas_n		,	//DDR3相关引脚，列地址选通
	output									mcb1_dram_we_n		,	//DDR3相关引脚，写信号
	output									mcb1_dram_odt		,	//DDR3相关引脚，阻抗匹配信号
	output									mcb1_dram_reset_n	,	//DDR3相关引脚，复位信号
	output									mcb1_dram_cke		,	//DDR3相关引脚，时钟使能信号
	output									mcb1_dram_dm		,	//DDR3相关引脚，低字节数据屏蔽信号
	inout 									mcb1_dram_udqs		,	//DDR3相关引脚，高字节地址选通信号正
	inout 									mcb1_dram_udqs_n	,	//DDR3相关引脚，高字节地址选通信号负
	inout 									mcb1_rzq			,	//DDR3相关引脚，驱动校准
	output									mcb1_dram_udm		,	//DDR3相关引脚，高字节数据屏蔽信号
	inout 									mcb1_dram_dqs		,	//DDR3相关引脚，低字节数据选通信号正
	inout 									mcb1_dram_dqs_n		,	//DDR3相关引脚，低字节数据选通信号负
	output									mcb1_dram_ck		,	//DDR3相关引脚，时钟正
	output									mcb1_dram_ck_n		,	//DDR3相关引脚，时钟负
	//  ===============================================================================================
	//  第六部分：其他接口信号
	//  ===============================================================================================
	input									i_flash_hold		,	//输入的hold信号
	output									o_flash_hold		,	//输出的hold信号
	output									o_usb_int			,	//输出引脚，连接到3014，给3014的中断信号，高电平有效，>100ns，clk_pix时钟域
	output		[3:0]						ov_test				,	//输出引脚，PCB上有焊点，测试管脚
	output									o_unused_pin			//原理图上没有分频引脚，sensor上的复用引脚需要输出到这里
	);

	//	ref signals

	//  ===============================================================================================
	//	-- ref 本地参数定义
	//  ===============================================================================================
	localparam		WB_OFFSET_WIDTH			= 12	;	//白平衡模块偏移位置寄存器宽度
	localparam		WB_GAIN_WIDTH			= 11	;	//白平衡模块增益寄存器宽度
	localparam		WB_STATIS_WIDTH			= 31	;	//白平衡模块统计值宽度
	localparam		GREY_OFFSET_WIDTH		= 12	;	//灰度统计模块偏移位置寄存器
	localparam		GREY_STATIS_WIDTH		= 48	;	//灰度统计模块统计值宽度
	localparam		TRIG_FILTER_WIDTH		= 19	;	//触发信号滤波模块寄存器宽度
	localparam		TRIG_DELAY_WIDTH		= 28	;	//触发信号延时模块寄存器宽度
	localparam		LED_CTRL_WIDTH			= 5     ;	//LED CTRL 寄存器宽度
	localparam		DATA_WD					= 32	;	//输入输出数据位宽，这里使用同一宽度
	localparam		SHORT_REG_WD 			= 16	;	//短寄存器位宽
	localparam		REG_WD 					= 32	;	//寄存器位宽
	localparam		LONG_REG_WD 			= 64	;	//长寄存器位宽
	localparam		BACK_FIFO_DEEP_WD 		= 8		;	//后端FIFO深度位宽
	localparam		DMA_SIZE		 		= 16'h2000	;	//DMA SIZE大小
	localparam		REG_INIT_VALUE			= "FALSE"	;	//寄存器有默认的初始值
	localparam		BUF_DEPTH_WD			= 4		;	//帧存深度位宽,我们最大支持8帧深度，多一位进位位

	//  ===============================================================================================
	//	-- ref 时钟复位模块输出
	//  ===============================================================================================
	wire							w_async_rst					;	//时钟复位模块输出，异步复位，只提供给MCB
	wire							w_sysclk_2x					;	//时钟复位模块输出，高速时钟，只提供给MCB
	wire							w_sysclk_2x_180				;	//时钟复位模块输出，高速时钟，只提供给MCB
	wire							w_pll_ce_0					;	//时钟复位模块输出，高速片选，只提供给MCB
	wire							w_pll_ce_90					;	//时钟复位模块输出，高速片选，只提供给MCB
	wire							w_mcb_drp_clk				;	//时钟复位模块输出，calib逻辑时钟，只提供给MCB
	wire							w_bufpll_mcb_lock			;	//时钟复位模块输出，bufpll_mcb 锁定信号，只提供给MCB
	wire							clk_osc_bufg				;	//时钟复位模块输出，40MHz时钟，全局缓冲驱动
	wire							reset_osc_bufg				;	//时钟复位模块输出，40MHz时钟的复位信号
	wire							clk_pix						;	//时钟复位模块输出，本地像素时钟，72Mhz
	wire							reset_pix					;	//时钟复位模块输出，本地像素时钟的复位信号
	wire							clk_frame_buf				;	//时钟复位模块输出，帧存时钟，与gpif时钟是同一个源头，为了保证模块独立性，帧存还是使用单独的时钟名称
	wire							reset_frame_buf				;	//时钟复位模块输出，帧存时钟的复位信号，与gpif时钟域的复位信号是同一个源头
	wire							clk_gpif					;	//时钟复位模块输出，gpif 时钟，100MHz
	wire							reset_gpif					;	//时钟复位模块输出，gpif 时钟的复位信号
	wire							reset_u3_interface			;	//时钟复位模块输出，u3 interface 模块复位
	wire							w_sensor_reset_done			;	//时钟复位模块输出，clk_osc_bufg时钟域，sensor复位完成信号，供固件查询，固件查询到该标志才能复位
	//  ===============================================================================================
	//	-- ref 控制通道模块输出
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	SPI 三态
	//	-------------------------------------------------------------------------------------
	wire							w_spi_miso_data				;	//控制通道输出，spi_sample时钟域，spi输出信号
	wire							w_spi_miso_data_en			;	//控制通道输出，spi_sample时钟域，spi输出信号使能信号，当使能信号为0时，miso引脚高阻

	//  -------------------------------------------------------------------------------------
	//	通用
	//  -------------------------------------------------------------------------------------
	wire							w_stream_enable_pix			;	//控制通道输出，clk_pix时钟域，流开采信号，没有生效时机
	wire							w_acquisition_start_pix		;	//控制通道输出，clk_pix时钟域，开采信号，没有生效时机
	wire							w_stream_enable_frame_buf	;	//控制通道输出，clk_frame_buf时钟域，流开采信号，没有生效时机
	wire							w_stream_enable_gpif		;	//控制通道输出，clk_gpif时钟域，流开采信号，没有生效时机
	//  -------------------------------------------------------------------------------------
	//	输出给 clk reset top
	//  -------------------------------------------------------------------------------------
	wire							w_reset_sensor				;	//控制通道输出，clk_osc_bufg时钟域，复位sensor使能信号，1个时钟周期宽度
	//  -------------------------------------------------------------------------------------
	//	输出给 io channel
	//  -------------------------------------------------------------------------------------
	wire							w_trigger_mode				;	//控制通路输出，clk_pix时钟域，触发模式寄存器，没做生效时机控制
	wire	[3:0]					wv_trigger_source			;	//控制通路输出，clk_pix时钟域，触发源寄存器，没做生效时机控制
	wire							w_trigger_soft				;	//控制通路输出，clk_pix时钟域，软触发寄存器，控制通道自清零，宽度是1个时钟周期
	wire							w_trigger_active			;	//控制通路输出，clk_pix时钟域，触发有效沿寄存器，没做生效时机控制
	wire	[TRIG_FILTER_WIDTH-1:0]	wv_trigger_filter_rise		;	//控制通路输出，clk_pix时钟域，上升沿触发滤波寄存器，没做生效时机控制，但保证成组生效
	wire	[TRIG_FILTER_WIDTH-1:0]	wv_trigger_filter_fall		;	//控制通路输出，clk_pix时钟域，下降沿触发滤波寄存器，没做生效时机控制，但保证成组生效
	wire	[TRIG_DELAY_WIDTH-1:0]	wv_trigger_delay			;	//控制通路输出，clk_pix时钟域，触发延迟寄存器，没做生效时机控制，但保证成组生效
	wire	[2:0]					wv_useroutput_level			;	//控制通路输出，clk_pix时钟域，用户自定义输出寄存器，没做生效时机控制
	wire							w_line2_mode				;	//控制通道输出，clk_pix时钟域，line2输入输出模式寄存器
	wire							w_line3_mode				;	//控制通道输出，clk_pix时钟域，line3输入输出模式寄存器
	wire							w_line0_invert				;	//控制通道输出，clk_pix时钟域，line0极性寄存器
	wire							w_line1_invert				;	//控制通道输出，clk_pix时钟域，line1极性寄存器
	wire							w_line2_invert				;	//控制通道输出，clk_pix时钟域，line2极性寄存器
	wire							w_line3_invert				;	//控制通道输出，clk_pix时钟域，line3极性寄存器
	wire	[2:0]					wv_line_source1				;	//控制通道输出，clk_pix时钟域，line1的输出源选择寄存器
	wire	[2:0]					wv_line_source2				;	//控制通道输出，clk_pix时钟域，line2的输出源选择寄存器
	wire	[2:0]					wv_line_source3				;	//控制通道输出，clk_pix时钟域，line3的输出源选择寄存器
	wire	[4:0]					wv_led_ctrl					;	//控制通道输出，clk_pix时钟域，双色灯控制寄存器
	//  -------------------------------------------------------------------------------------
	//	输出给 data channel
	//  -------------------------------------------------------------------------------------
	wire	[REG_WD-1:0]			wv_pixel_format				;	//控制通道输出，clk_pix时钟域，控制通路输出的像素格式寄存器，没做生效时机控制，0x01080001:Mono8、0x01100003:Mono10、0x01080008:BayerGR8、0x0110000C:BayerGR10
	wire							w_encrypt_state				;	//控制通道输出，clk_dna时钟域，加密状态，上电后保持不变，可以作为常数
	wire							w_pulse_filter_en			;	//控制通路输出，clk_pix时钟域，坏点校正寄存器，没做生效时机控制
	wire	[2:0]					wv_test_image_sel			;	//控制通路输出，clk_pix时钟域，测试图选择寄存器，没做生效时机控制，000:真实图,001:测试图像1灰度值帧递增,110:测试图像2静止的斜条纹,010:测试图像3滚动的斜条纹
	wire	[1:0]					wv_interrupt_en				;	//控制通路输出，clk_pix时钟域，中断使能寄存器，没做生效时机控制
	wire	[1:0]					wv_interrupt_clear			;	//控制通路输出，clk_pix时钟域，中断清除寄存器，立即生效
	wire	[WB_OFFSET_WIDTH-1:0]	wv_wb_offset_x_start		;	//控制通路输出，clk_pix时钟域，白平衡横坐标寄存器，没做生效时机控制
	wire	[WB_OFFSET_WIDTH-1:0]	wv_wb_offset_width			;	//控制通路输出，clk_pix时钟域，白平衡宽度寄存器，没做生效时机控制
	wire	[WB_OFFSET_WIDTH-1:0]	wv_wb_offset_y_start		;	//控制通路输出，clk_pix时钟域，白平衡纵坐标寄存器，没做生效时机控制
	wire	[WB_OFFSET_WIDTH-1:0]	wv_wb_offset_height			;	//控制通路输出，clk_pix时钟域，白平衡高度寄存器，没做生效时机控制
	wire	[WB_GAIN_WIDTH-1:0]		wv_wb_gain_r				;	//控制通路输出，clk_pix时钟域，白平衡红分量增益寄存器，没做生效时机控制
	wire	[WB_GAIN_WIDTH-1:0]		wv_wb_gain_g				;	//控制通路输出，clk_pix时钟域，白平衡绿分量增益寄存器，没做生效时机控制
	wire	[WB_GAIN_WIDTH-1:0]		wv_wb_gain_b				;	//控制通路输出，clk_pix时钟域，白平衡蓝分量增益寄存器，没做生效时机控制
	wire	[GREY_OFFSET_WIDTH-1:0]	wv_grey_offset_x_start		;	//控制通路输出，clk_pix时钟域，灰度值统计区域横坐标寄存器，没做生效时机控制
	wire	[GREY_OFFSET_WIDTH-1:0]	wv_grey_offset_width		;	//控制通路输出，clk_pix时钟域，灰度值统计区域宽度寄存器，没做生效时机控制
	wire	[GREY_OFFSET_WIDTH-1:0]	wv_grey_offset_y_start		;	//控制通路输出，clk_pix时钟域，灰度值统计区域纵坐标寄存器，没做生效时机控制
	wire	[GREY_OFFSET_WIDTH-1:0]	wv_grey_offset_height		;	//控制通路输出，clk_pix时钟域，灰度值统计区域高度寄存器，没做生效时机控制
	//  -------------------------------------------------------------------------------------
	//	输出给 u3v format
	//  -------------------------------------------------------------------------------------
	wire							w_chunk_mode_active_pix		;	//控制通路输出，clk_pix时钟域，chunk开关寄存器，没做生效时机控制
	wire							w_chunkid_en_ts				;	//控制通路输出，clk_pix时钟域，时间戳开关寄存器，没做生效时机控制
	wire							w_chunkid_en_fid			;	//控制通路输出，clk_pix时钟域，frame id开关寄存器，没做生效时机控制
	wire	[REG_WD-1:0]			wv_chunk_size_img			;	//控制通路输出，clk_pix时钟域，chunk image大小，没做生效时机控制
	wire	[REG_WD-1:0]			wv_payload_size_pix			;	//控制通道输出，clk_pix时钟域，数据的大小但不包含头包尾包，协议要求64bit，我们只是用32bit即可，高32bit补0
	wire	[SHORT_REG_WD-1:0]		wv_roi_offset_x				;	//控制通道输出，clk_pix时钟域，头包中的水平偏移
	wire	[SHORT_REG_WD-1:0]		wv_roi_offset_y				;	//控制通道输出，clk_pix时钟域，头包中的垂直偏移
	wire	[SHORT_REG_WD-1:0]		wv_roi_pic_width			;	//控制通道输出，clk_pix时钟域，头包中的窗口宽度
	wire	[SHORT_REG_WD-1:0]		wv_roi_pic_height			;	//控制通道输出，clk_pix时钟域，头包中的窗口高度
	wire	[LONG_REG_WD-1:0]		wv_timestamp_u3				;	//控制通道输出，clk_osc_bufg时钟域，在场信号上下沿锁存时间戳计数器。最长4个clk_osc_bufg时钟输出稳定，在pix时钟域看来，最长8个时钟之后才能稳定
	//  -------------------------------------------------------------------------------------
	//	输出给 frame buffer
	//  -------------------------------------------------------------------------------------
	wire	[BUF_DEPTH_WD-1:0]		wv_frame_buffer_depth			;	//控制通道输出，帧存深度，2-8
	wire	[REG_WD-1:0]			wv_payload_size_frame_buf		;	//控制通道输出，clk_frame_buf时钟域，数据的大小但不包含头包尾包，协议要求64bit，我们只是用32bit即可，高32bit补0
	wire							w_chunk_mode_active_frame_buf	;	//控制通道输出，clk_frame_buf时钟域，chunk开关寄存器
	//  -------------------------------------------------------------------------------------
	//	输出给 u3 interface
	//  -------------------------------------------------------------------------------------
	wire	[REG_WD-1:0]			wv_si_payload_transfer_size	;	//控制通路输出，clk_gpif时钟域，等量数据块大小,控制通道输出，未作生效时机控制
	wire	[REG_WD-1:0]			wv_si_payload_transfer_count;	//控制通路输出，clk_gpif时钟域，等量数据块个数,控制通道输出，未作生效时机控制
	wire	[REG_WD-1:0]			wv_si_payload_final_transfer1_size	;	//控制通路输出，clk_gpif时钟域，transfer1大小,控制通道输出，未作生效时机控制
	wire	[REG_WD-1:0]			wv_si_payload_final_transfer2_size	;	//控制通路输出，clk_gpif时钟域，transfer2大小,控制通道输出，未作生效时机控制
	wire	[REG_WD-1:0]			wv_payload_size_gpif		;	//控制通道输出，clk_gpif时钟域，数据的大小但不包含头包尾包，协议要求64bit，我们只是用32bit即可，高32bit补0
	wire							w_chunk_mode_active_gpif	;	//控制通道输出，clk_gpif时钟域，chunk开关寄存器
	//  ===============================================================================================
	//  -- ref io_channel 输出
	//  ===============================================================================================
	wire	[3:0]					wv_line_status				;	//控制通道输出，clk_pix时钟域，line状态寄存器，IO通道输出，指示IO进行选择后状态
	//  ===============================================================================================
	//  -- ref data_channel 输出
	//  ===============================================================================================
	wire							w_fval_data_channel			;	//数据通路输出，clk_pix时钟域，场有效信号，fval的信号是经过数据通道加宽过的场信号，场头可以添加leader、并包含有效的图像数据，停采期间保持低电平
	wire							w_data_channel_dvalid		;	//数据通路输出，clk_pix时钟域，数据有效信号，标志32位数据为有效数据
	wire	[DATA_WD-1:0]			wv_data_channel_data		;	//数据通路输出，clk_pix时钟域，32bit数据，与数据有效对齐，与像素时钟对齐
	wire							w_full_frame_state			;	//数据通路输出，clk_pix时钟域，完整帧状态信号，供固件查询
	wire	[REG_WD-1:0]			wv_pixel_format_data_channel;	//数据通路输出，clk_pix时钟域，目的是让后级模块与数据通道的像素格式保持一致
	wire	[WB_STATIS_WIDTH-1:0]	wv_wb_statis_r				;	//数据通路输出，clk_pix时钟域，白平衡红分量灰度值统计寄存器，已做生效时机控制
	wire	[WB_STATIS_WIDTH-1:0]	wv_wb_statis_g				;	//数据通路输出，clk_pix时钟域，白平衡绿分量灰度值统计寄存器，已做生效时机控制
	wire	[WB_STATIS_WIDTH-1:0]	wv_wb_statis_b				;	//数据通路输出，clk_pix时钟域，白平衡蓝分量灰度值统计寄存器，已做生效时机控制
	wire	[WB_OFFSET_WIDTH-1:0]	wv_wb_offset_width_valid	;	//数据通路输出，clk_pix时钟域，白平衡宽度寄存器，与白平衡统计值同属一帧图像
	wire	[WB_OFFSET_WIDTH-1:0]	wv_wb_offset_height_valid	;	//数据通路输出，clk_pix时钟域，白平衡高度寄存器，与白平衡统计值同属一帧图像
	wire	[GREY_OFFSET_WIDTH-1:0]	wv_grey_offset_width_valid	;	//数据通路输出，clk_pix时钟域，灰度值统计区域宽度寄存器，与灰度统计值同属一帧
	wire	[GREY_OFFSET_WIDTH-1:0]	wv_grey_offset_height_valid	;	//数据通路输出，clk_pix时钟域，灰度值统计区域高度寄存器，与灰度统计值同属一帧
	wire	[GREY_STATIS_WIDTH-1:0]	wv_grey_statis_sum			;	//数据通路输出，clk_pix时钟域，的灰度值统计寄存器，与灰度统计值区域同属一帧，如果像素格式为8bit，该值为像素8bit统计值。如果像素格式为10bit，该值为像素10bit统计值。
	wire	[1:0]					wv_interrupt_state			;	//数据通路输出，clk_pix时钟域，中断状态寄存器
	//  ===============================================================================================
	//  -- ref u3v_format 输出
	//  ===============================================================================================
	wire							w_u3v_format_fval			;	//u3v_format模块输出，clk_pix时钟域，场有效信号
	wire							w_u3v_format_dvalid			;	//u3v_format模块输出，clk_pix时钟域，数据有效信号
	wire	[DATA_WD-1:0]			wv_u3v_format_data			;	//u3v_format模块输出，clk_pix时钟域，数据
	//  ===============================================================================================
	//  -- ref frame_buffer 输出
	//  ===============================================================================================
	wire	[DATA_WD-1:0]			wv_frame_buffer_data		;	//frame_buffer模块输出，clk_frame_buf时钟域，帧存后级FIFO数据输出，宽度32bit
	wire							w_frame_buffer_dvalid		;	//frame_buffer模块输出，clk_frame_buf时钟域，帧存输出数据有效
	wire							w_ddr_init_done				;	//frame_buffer模块输出，mcb_drp_clk时钟域，MCB输出的初始化完整信号
	wire							w_wr_error					;	//frame_buffer模块输出，时钟域未知，与MCB硬核输出，DDR错误信号
	wire							w_rd_error					;	//frame_buffer模块输出，时钟域未知，与MCB硬核输出，DDR错误信号
	wire							w_back_buf_empty			;	//frame_buffer模块输出，clk_gpif时钟域，帧存后端FIFO空标志，用来指示帧存中是否有数据可读
	//  ===============================================================================================
	//  -- ref u3_interface 输出
	//  ===============================================================================================
	wire							w_buf_rd					;	//u3_interface模块输出，clk_gpif时钟域，读取帧存后端FIFO信号，和i_data_valid信号共同指示数据有效
	wire							w_usb_wr_for_led			;	//GPIF 写信号 - 给led_ctrl模块
	wire							w_usb_pktend_n_for_test		;	//GPIF 包结束信号，输出到测试引脚
	wire	[1:0]					wv_usb_fifoaddr_reg			;	//GPIF 地址信号，输出到测试寄存器
	//  ===============================================================================================
	//  -- ref 其他
	//  ===============================================================================================
	wire							w_ddr_error					;	//frame_buffer模块输出，时钟域未知，与MCB硬核相关，DDR错误信号
	wire	[4:0]					wv_gpif_state				;	//GPIF 状态
	wire	[3:0]					wv_fval_state				;	//fval 状态


	//  ===============================================================================================
	//  -- ref 测试信号
	//  ===============================================================================================
	wire	[15:0]					wv_linein_sel_rise_cnt		;
	wire	[15:0]					wv_linein_sel_fall_cnt		;
	wire	[15:0]					wv_linein_filter_rise_cnt	;
	wire	[15:0]					wv_linein_filter_fall_cnt	;
	wire	[15:0]					wv_linein_active_cnt		;
	wire	[15:0]					wv_trigger_n_rise_cnt		;
	wire	[15:0]					wv_trigger_soft_cnt			;
	wire	[12:0]					wv_strobe_length_reg		;
	wire							w_trailer_flag				;
	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref 接口逻辑
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	hold直接输入1
	//	-------------------------------------------------------------------------------------
	//	assign	o_flash_hold	= i_flash_hold;
	assign	o_flash_hold		= 1'b1;

	//	-------------------------------------------------------------------------------------
	//	spi 的双向操作在顶层实现
	//	-------------------------------------------------------------------------------------
	assign	o_usb_spi_miso		= w_spi_miso_data_en ? w_spi_miso_data : 1'bz;

	//	-------------------------------------------------------------------------------------
	//	1.sensor的一些输入管脚是 1驱2 ，在fpga中只需用到1个。为了电路上信号完整性考虑，另一个也需要当做输入引脚，因此就必须做一段逻辑
	//	2.flash的hold输入管脚，保留
	//	-------------------------------------------------------------------------------------
	assign	o_unused_pin		= ^iv_pix_data_mux[9:4] ^ clk_sensor_pix_mux ^ i_fval_mux ^ i_lval_mux ^ i_sensor_strobe_mux ^ i_flash_hold;

	//	-------------------------------------------------------------------------------------
	//	测试管脚
	//	-------------------------------------------------------------------------------------
	assign	ov_test[0]		= w_usb_pktend_n_for_test;
	assign	ov_test[1]		= w_usb_wr_for_led;
	assign	ov_test[2]		= i_usb_flagb_n;
	assign	ov_test[3]		= o_trigger_n;

	//  ===============================================================================================
	//	ref 内部逻辑
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	ddr的错误指示信号
	//	-------------------------------------------------------------------------------------
	assign	w_ddr_error			= w_wr_error | w_rd_error;

	//	-------------------------------------------------------------------------------------
	//	gpif接口的状态，调试使用
	//	-------------------------------------------------------------------------------------
	assign	wv_gpif_state[4:0]	= {wv_usb_fifoaddr_reg[1:0],w_usb_pktend_n_for_test,w_usb_wr_for_led,i_usb_flagb_n};

	//	-------------------------------------------------------------------------------------
	//	fval state，调试使用
	//	-------------------------------------------------------------------------------------

	assign	wv_fval_state[3:0]	= {w_back_buf_empty,w_u3v_format_fval,w_fval_data_channel,i_fval};

	//  ===============================================================================================
	//  clock_reset例化
	//  ===============================================================================================
	clock_reset # (
	.DDR3_MEMCLK_FREQ		(DDR3_MEMCLK_FREQ		)
	)
	clock_reset_inst (
	.clk_osc				(clk_osc				),
	.i_reset_sensor			(w_reset_sensor			),
	.i_stream_enable		(w_stream_enable_gpif	),
	.clk_osc_bufg			(clk_osc_bufg			),
	.reset_osc_bufg			(reset_osc_bufg			),
	.async_rst				(w_async_rst			),
	.sysclk_2x				(w_sysclk_2x			),
	.sysclk_2x_180			(w_sysclk_2x_180		),
	.pll_ce_0				(w_pll_ce_0				),
	.pll_ce_90				(w_pll_ce_90			),
	.mcb_drp_clk			(w_mcb_drp_clk			),
	.bufpll_mcb_lock		(w_bufpll_mcb_lock		),
	.clk_frame_buf			(clk_frame_buf			),
	.reset_frame_buf		(reset_frame_buf		),
	.clk_pix				(clk_pix				),
	.reset_pix				(reset_pix				),
	.o_clk_sensor			(o_clk_sensor			),
	.o_reset_senser_n		(o_senser_reset_n		),
	.o_sensor_reset_done	(w_sensor_reset_done	),
	.o_clk_usb_pclk			(o_clk_usb_pclk			),
	.clk_gpif				(clk_gpif				),
	.reset_gpif				(reset_gpif				),
	.reset_u3_interface		(reset_u3_interface		)
	);

	//  ===============================================================================================
	//  ctrl_channel例化
	//  ===============================================================================================
	ctrl_channel # (
	.WB_OFFSET_WIDTH		(WB_OFFSET_WIDTH	),
	.WB_GAIN_WIDTH			(WB_GAIN_WIDTH		),
	.WB_STATIS_WIDTH		(WB_STATIS_WIDTH	),
	.GREY_OFFSET_WIDTH		(GREY_OFFSET_WIDTH	),
	.GREY_STATIS_WIDTH		(GREY_STATIS_WIDTH	),
	.TRIG_FILTER_WIDTH		(TRIG_FILTER_WIDTH	),
	.TRIG_DELAY_WIDTH		(TRIG_DELAY_WIDTH	),
	.LED_CTRL_WIDTH			(LED_CTRL_WIDTH		),
	.SHORT_REG_WD			(SHORT_REG_WD		),
	.REG_WD					(REG_WD				),
	.LONG_REG_WD			(LONG_REG_WD		),
	.BUF_DEPTH_WD			(BUF_DEPTH_WD		),
	.REG_INIT_VALUE			(REG_INIT_VALUE		)
	)
	ctrl_channel_inst(
	//  ===============================================================================================
	//	控制信号
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spi时钟域
	//  -------------------------------------------------------------------------------------
	.i_spi_clk					(i_usb_spi_sck			),
	.i_spi_cs_n					(i_spi_cs_n_fpga		),
	.i_spi_mosi					(i_usb_spi_mosi			),
	.o_spi_miso_data			(w_spi_miso_data		),
	.o_spi_miso_data_en			(w_spi_miso_data_en		),
	//  -------------------------------------------------------------------------------------
	//	40MHz时钟
	//  -------------------------------------------------------------------------------------
	.clk_osc_bufg				(clk_osc_bufg			),
	.reset_osc_bufg				(reset_osc_bufg			),
	//  -------------------------------------------------------------------------------------
	//	pix 时钟域
	//  -------------------------------------------------------------------------------------
	.clk_pix				    (clk_pix				),
	.reset_pix					(reset_pix				),
	.i_fval						(w_fval_data_channel	),
	//  -------------------------------------------------------------------------------------
	//	frame buf 时钟域
	//  -------------------------------------------------------------------------------------
	.clk_frame_buf			    (clk_frame_buf			),
	.reset_frame_buf			(reset_frame_buf		),
	//  -------------------------------------------------------------------------------------
	//	gpif 时钟域
	//  -------------------------------------------------------------------------------------
	.clk_gpif			        (clk_gpif				),
	.reset_gpif					(reset_gpif				),
	//  ===============================================================================================
	//	以下内容是寄存器
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	通用
	//  -------------------------------------------------------------------------------------
	.o_stream_enable_pix		(w_stream_enable_pix		),
	.o_acquisition_start_pix	(w_acquisition_start_pix	),
	.o_stream_enable_frame_buf	(w_stream_enable_frame_buf	),
	.o_stream_enable_gpif		(w_stream_enable_gpif		),
	//  -------------------------------------------------------------------------------------
	//	clk reset top
	//  -------------------------------------------------------------------------------------
	.o_reset_sensor				(w_reset_sensor			),
	.i_sensor_reset_done		(w_sensor_reset_done	),
	//  -------------------------------------------------------------------------------------
	//	io channel
	//  -------------------------------------------------------------------------------------
	.o_trigger_mode				(w_trigger_mode			),
	.ov_trigger_source			(wv_trigger_source		),
	.o_trigger_soft				(w_trigger_soft			),
	.o_trigger_active			(w_trigger_active		),
	.ov_trigger_filter_rise		(wv_trigger_filter_rise	),
	.ov_trigger_filter_fall		(wv_trigger_filter_fall	),
	.ov_trigger_delay			(wv_trigger_delay		),
	.ov_useroutput_level		(wv_useroutput_level	),
	.o_line2_mode				(w_line2_mode			),
	.o_line3_mode				(w_line3_mode			),
	.o_line0_invert				(w_line0_invert			),
	.o_line1_invert				(w_line1_invert			),
	.o_line2_invert				(w_line2_invert			),
	.o_line3_invert				(w_line3_invert			),
	.ov_line_source1			(wv_line_source1		),
	.ov_line_source2			(wv_line_source2		),
	.ov_line_source3			(wv_line_source3		),
	.iv_line_status				(wv_line_status			),
	.ov_led_ctrl				(wv_led_ctrl			),
	//调试用
	.iv_linein_sel_rise_cnt		(wv_linein_sel_rise_cnt		),
	.iv_linein_sel_fall_cnt		(wv_linein_sel_fall_cnt		),
	.iv_linein_filter_rise_cnt	(wv_linein_filter_rise_cnt	),
	.iv_linein_filter_fall_cnt	(wv_linein_filter_fall_cnt	),
	.iv_linein_active_cnt		(wv_linein_active_cnt		),
	.iv_trigger_n_rise_cnt		(wv_trigger_n_rise_cnt		),
	.iv_trigger_soft_cnt		(wv_trigger_soft_cnt		),
	.iv_strobe_length_reg		(wv_strobe_length_reg		),

	//  -------------------------------------------------------------------------------------
	//	data channel
	//  -------------------------------------------------------------------------------------
	.ov_pixel_format			(wv_pixel_format				),
	.i_full_frame_state			(w_full_frame_state		    	),
	.o_encrypt_state			(w_encrypt_state				),
	.o_pulse_filter_en			(w_pulse_filter_en				),
	.ov_test_image_sel			(wv_test_image_sel		    	),
	.ov_interrupt_en			(wv_interrupt_en		    	),
	.iv_interrupt_state			(wv_interrupt_state		    	),
	.ov_interrupt_clear			(wv_interrupt_clear		    	),
	.ov_wb_offset_x_start		(wv_wb_offset_x_start	    	),
	.ov_wb_offset_width			(wv_wb_offset_width		    	),
	.ov_wb_offset_y_start		(wv_wb_offset_y_start	    	),
	.ov_wb_offset_height		(wv_wb_offset_height	    	),
	.ov_wb_gain_r				(wv_wb_gain_r			    	),
	.ov_wb_gain_g				(wv_wb_gain_g			    	),
	.ov_wb_gain_b				(wv_wb_gain_b			    	),
	.iv_wb_statis_r				(wv_wb_statis_r			    	),
	.iv_wb_statis_g				(wv_wb_statis_g			    	),
	.iv_wb_statis_b				(wv_wb_statis_b			    	),
	.iv_wb_offset_width			(wv_wb_offset_width_valid   	),
	.iv_wb_offset_height		(wv_wb_offset_height_valid  	),
	.ov_grey_offset_x_start		(wv_grey_offset_x_start	    	),
	.ov_grey_offset_width		(wv_grey_offset_width	    	),
	.ov_grey_offset_y_start		(wv_grey_offset_y_start	    	),
	.ov_grey_offset_height		(wv_grey_offset_height	    	),
	.iv_grey_statis_sum			(wv_grey_statis_sum		    	),
	.iv_grey_offset_width		(wv_grey_offset_width_valid 	),
	.iv_grey_offset_height		(wv_grey_offset_height_valid	),

	//调试用
	.iv_fval_state				(wv_fval_state					),

	//  -------------------------------------------------------------------------------------
	//	u3v format
	//  -------------------------------------------------------------------------------------
	.o_chunk_mode_active		(w_chunk_mode_active_pix		),
	.o_chunkid_en_ts			(w_chunkid_en_ts				),
	.o_chunkid_en_fid			(w_chunkid_en_fid				),
	.ov_chunk_size_img			(wv_chunk_size_img				),
	.ov_payload_size_pix		(wv_payload_size_pix			),
	.ov_roi_offset_x			(wv_roi_offset_x				),
	.ov_roi_offset_y			(wv_roi_offset_y				),
	.ov_roi_pic_width			(wv_roi_pic_width				),
	.ov_roi_pic_height			(wv_roi_pic_height				),
	.ov_timestamp_u3			(wv_timestamp_u3				),
	//  -------------------------------------------------------------------------------------
	//	frame buffer
	//  -------------------------------------------------------------------------------------
	.ov_payload_size_frame_buf		(wv_payload_size_frame_buf		),
	.ov_frame_buffer_depth			(wv_frame_buffer_depth			),
	.o_chunk_mode_active_frame_buf	(w_chunk_mode_active_frame_buf	),
	.i_ddr_init_done				(w_ddr_init_done				),
	.i_ddr_error					(w_ddr_error					),
	//  -------------------------------------------------------------------------------------
	//	u3 interface
	//  -------------------------------------------------------------------------------------
	.ov_si_payload_transfer_size			(wv_si_payload_transfer_size	    	),
	.ov_si_payload_transfer_count			(wv_si_payload_transfer_count	    	),
	.ov_si_payload_final_transfer1_size		(wv_si_payload_final_transfer1_size		),
	.ov_si_payload_final_transfer2_size		(wv_si_payload_final_transfer2_size		),
	.ov_payload_size_gpif					(wv_payload_size_gpif					),
	.o_chunk_mode_active_gpif				(w_chunk_mode_active_gpif				),

	//调试用
	.iv_gpif_state							(wv_gpif_state							)
	);

	//  ===============================================================================================
	//  io_channel例化
	//  ===============================================================================================
	io_channel # (
	.TRIG_FILTER_WIDTH		(TRIG_FILTER_WIDTH		),
	.TRIG_DELAY_WIDTH		(TRIG_DELAY_WIDTH		),
	.LED_CTRL_WIDTH			(LED_CTRL_WIDTH			)
	)
	io_channel_inst(
	.clk					(clk_pix					),
	.i_trigger_mode			(w_trigger_mode				),
	.i_acquisition_start	(w_acquisition_start_pix	),
	.i_stream_enable		(w_stream_enable_pix		),
	.ov_line_status			(wv_line_status				),
	.i_line2_mode			(w_line2_mode				),
	.i_line3_mode			(w_line3_mode				),
	.i_line0_invert			(w_line0_invert				),
	.i_line1_invert			(w_line1_invert				),
	.i_line2_invert			(w_line2_invert				),
	.i_line3_invert			(w_line3_invert				),
	.iv_filter_rise			(wv_trigger_filter_rise		),
	.iv_filter_fall			(wv_trigger_filter_fall		),
	.i_trigger_soft			(w_trigger_soft				),
	.iv_trigger_source		(wv_trigger_source			),
	.i_trigger_active		(w_trigger_active			),
	.iv_trigger_delay		(wv_trigger_delay			),
	.iv_line_source1		(wv_line_source1			),
	.iv_line_source2		(wv_line_source2			),
	.iv_line_source3		(wv_line_source3			),
	.iv_useroutput_level	(wv_useroutput_level		),
	.iv_led_ctrl			(wv_led_ctrl				),
	.i_optocoupler			(i_optocoupler				),
	.iv_gpio				(iv_gpio					),
	.o_optocoupler			(o_optocoupler				),
	.ov_gpio				(ov_gpio					),
	.o_f_led_gre			(o_f_led_gre				),
	.o_f_led_red			(o_f_led_red				),
	.i_usb_slwr_n			(w_usb_wr_for_led			),
	.i_fval					(i_fval						),
	.i_lval					(i_lval						),
	.i_sensor_strobe		(i_sensor_strobe			),
	.o_trigger_n			(o_trigger_n				),

	.ov_linein_sel_rise_cnt		(wv_linein_sel_rise_cnt		),
	.ov_linein_sel_fall_cnt		(wv_linein_sel_fall_cnt		),
	.ov_linein_filter_rise_cnt	(wv_linein_filter_rise_cnt	),
	.ov_linein_filter_fall_cnt	(wv_linein_filter_fall_cnt	),
	.ov_linein_active_cnt		(wv_linein_active_cnt		),
	.ov_trigger_n_rise_cnt		(wv_trigger_n_rise_cnt		),
	.ov_trigger_soft_cnt		(wv_trigger_soft_cnt		),
	.ov_strobe_length_reg		(wv_strobe_length_reg		)

	);
	//  ===============================================================================================
	//  data_channel例化
	//  ===============================================================================================
	data_channel # (
	.SENSOR_DAT_WIDTH			(SENSOR_DAT_WIDTH		),
	.WB_OFFSET_WIDTH			(WB_OFFSET_WIDTH		),
	.WB_GAIN_WIDTH				(WB_GAIN_WIDTH			),
	.WB_STATIS_WIDTH			(WB_STATIS_WIDTH		),
	.GREY_OFFSET_WIDTH			(GREY_OFFSET_WIDTH		),
	.GREY_STATIS_WIDTH			(GREY_STATIS_WIDTH		),
	.SHORT_REG_WD				(SHORT_REG_WD			),
	.REG_WD						(REG_WD					),
	.DATA_WD					(DATA_WD				)
	)
	data_channel_inst(
	.clk_sensor_pix				(clk_sensor_pix					),
	.i_fval						(i_fval							),
	.i_lval						(i_lval							),
	.iv_pix_data				(iv_pix_data					),
	.clk_pix					(clk_pix						),
	.reset_pix					(reset_pix						),
	.o_fval						(w_fval_data_channel			),
	.o_pix_data_en				(w_data_channel_dvalid			),
	.ov_pix_data				(wv_data_channel_data			),
	.i_acquisition_start		(w_acquisition_start_pix		),
	.i_stream_enable			(w_stream_enable_pix			),
	.o_full_frame_state			(w_full_frame_state				),
	.i_encrypt_state			(w_encrypt_state				),
	.i_pulse_filter_en			(w_pulse_filter_en				),
	.iv_roi_pic_width			(wv_roi_pic_width				),
	.iv_test_image_sel			(wv_test_image_sel				),
	.iv_pixel_format			(wv_pixel_format				),
	.ov_pixel_format			(wv_pixel_format_data_channel	),
	.iv_wb_offset_x_start		(wv_wb_offset_x_start			),
	.iv_wb_offset_width			(wv_wb_offset_width				),
	.iv_wb_offset_y_start		(wv_wb_offset_y_start			),
	.iv_wb_offset_height		(wv_wb_offset_height			),
	.iv_wb_gain_r				(wv_wb_gain_r					),
	.iv_wb_gain_g				(wv_wb_gain_g					),
	.iv_wb_gain_b				(wv_wb_gain_b					),
	.ov_wb_statis_r				(wv_wb_statis_r					),
	.ov_wb_statis_g				(wv_wb_statis_g					),
	.ov_wb_statis_b				(wv_wb_statis_b					),
	.ov_wb_offset_width			(wv_wb_offset_width_valid		),
	.ov_wb_offset_height		(wv_wb_offset_height_valid		),

	.iv_grey_offset_x_start		(wv_grey_offset_x_start			),
	.iv_grey_offset_width		(wv_grey_offset_width			),
	.iv_grey_offset_y_start		(wv_grey_offset_y_start			),
	.iv_grey_offset_height		(wv_grey_offset_height			),
	.ov_grey_statis_sum			(wv_grey_statis_sum				),
	.ov_grey_offset_width		(wv_grey_offset_width_valid		),
	.ov_grey_offset_height		(wv_grey_offset_height_valid	),

	.iv_interrupt_en			(wv_interrupt_en				),
	.iv_interrupt_clear			(wv_interrupt_clear				),
	.ov_interrupt_state			(wv_interrupt_state				),
	.o_interrupt				(o_usb_int						)
	);

	//  ===============================================================================================
	//  u3v_format例化
	//  ===============================================================================================
	u3v_format # (
	.DATA_WD						(DATA_WD						),
	.SHORT_REG_WD 					(SHORT_REG_WD 					),
	.REG_WD 						(REG_WD 						),
	.LONG_REG_WD 					(LONG_REG_WD 					)
	)
	u3v_format_inst(
	.reset							(reset_pix						),
	.clk							(clk_pix						),
	.i_fval							(w_fval_data_channel			),
	.i_data_valid					(w_data_channel_dvalid			),
	.iv_data						(wv_data_channel_data			),
	.i_stream_enable				(w_stream_enable_pix			),
	.i_acquisition_start     		(w_acquisition_start_pix   		),
	.iv_pixel_format         		(wv_pixel_format_data_channel	),
	.i_chunk_mode_active     		(w_chunk_mode_active_pix   		),
	.i_chunkid_en_ts         		(w_chunkid_en_ts        		),
	.i_chunkid_en_fid        		(w_chunkid_en_fid       		),
	.iv_chunk_size_img       		(wv_chunk_size_img      		),
	.iv_timestamp					(wv_timestamp_u3				),
	.iv_offset_x					(wv_roi_offset_x				),
	.iv_offset_y					(wv_roi_offset_y				),
	.iv_size_x						(wv_roi_pic_width				),
	.iv_size_y						(wv_roi_pic_height				),
	.iv_trailer_size_y				({16'h0,wv_roi_pic_height}		),
	.o_trailer_flag					(w_trailer_flag					),
	.o_fval							(w_u3v_format_fval   			),
	.o_data_valid					(w_u3v_format_dvalid 			),
	.ov_data                 		(wv_u3v_format_data      		)
	);

	//  ===============================================================================================
	//  frame_buffer 例化
	//  ===============================================================================================
	frame_buffer # (
	.BUF_DEPTH_WD					(BUF_DEPTH_WD				),
	.NUM_DQ_PINS					(NUM_DQ_PINS         		),
	.MEM_BANKADDR_WIDTH				(MEM_BANKADDR_WIDTH  		),
	.MEM_ADDR_WIDTH					(MEM_ADDR_WIDTH      		),
	.DDR3_MEMCLK_FREQ				(DDR3_MEMCLK_FREQ			),
	.MEM_ADDR_ORDER					("ROW_BANK_COLUMN"			),
	.SKIP_IN_TERM_CAL				(1							),
	.DDR3_MEM_DENSITY				(DDR3_MEM_DENSITY			),
	.DDR3_TCK_SPEED					(DDR3_TCK_SPEED				),
	.DDR3_SIMULATION				(DDR3_SIMULATION			),
	.DDR3_CALIB_SOFT_IP				(DDR3_CALIB_SOFT_IP			),
	.DATA_WD						(DATA_WD					),
	.REG_WD 						(REG_WD 					)
	)
	frame_buffer_inst(
	.clk_vin						(clk_pix							),
	.i_fval							(w_u3v_format_fval   				),
	.i_dval							(w_u3v_format_dvalid 				),
	.i_trailer_flag					(w_trailer_flag						),
	.iv_image_din					(wv_u3v_format_data  				),
	.i_stream_en_clk_in				(w_stream_enable_pix				),
	.clk_vout						(clk_gpif							),
	.i_buf_rd						(w_buf_rd							),
	.o_back_buf_empty				(w_back_buf_empty					),
	.ov_frame_dout					(wv_frame_buffer_data				),
	.o_frame_valid					(w_frame_buffer_dvalid				),
	.clk_frame_buf					(clk_frame_buf						),
	.reset_frame_buf				(reset_frame_buf					),
	.i_stream_en					(w_stream_enable_frame_buf			),
	.iv_frame_depth					(wv_frame_buffer_depth				),
	.iv_payload_size_frame_buf		(wv_payload_size_frame_buf[23:0]	),
	.iv_payload_size_pix			(wv_payload_size_pix[23:0]			),
	.i_chunkmodeactive				(w_chunk_mode_active_frame_buf		),
	.i_async_rst					(w_async_rst						),
	.i_sysclk_2x					(w_sysclk_2x						),
	.i_sysclk_2x_180				(w_sysclk_2x_180					),
	.i_pll_ce_0						(w_pll_ce_0							),
	.i_pll_ce_90					(w_pll_ce_90						),
	.i_mcb_drp_clk					(w_mcb_drp_clk						),
	.i_bufpll_mcb_lock				(w_bufpll_mcb_lock					),
	.o_calib_done					(w_ddr_init_done					),
	.o_wr_error						(w_wr_error							),
	.o_rd_error						(w_rd_error							),
	.mcb1_dram_dq					(mcb1_dram_dq						),
	.mcb1_dram_a         			(mcb1_dram_a         				),
	.mcb1_dram_ba        			(mcb1_dram_ba        				),
	.mcb1_dram_ras_n     			(mcb1_dram_ras_n     				),
	.mcb1_dram_cas_n     			(mcb1_dram_cas_n     				),
	.mcb1_dram_we_n      			(mcb1_dram_we_n      				),
	.mcb1_dram_odt       			(mcb1_dram_odt       				),
	.mcb1_dram_reset_n   			(mcb1_dram_reset_n   				),
	.mcb1_dram_cke       			(mcb1_dram_cke       				),
	.mcb1_dram_dm        			(mcb1_dram_dm        				),
	.mcb1_dram_udqs      			(mcb1_dram_udqs      				),
	.mcb1_dram_udqs_n    			(mcb1_dram_udqs_n    				),
	.mcb1_rzq            			(mcb1_rzq            				),
	.mcb1_dram_udm       			(mcb1_dram_udm       				),
	.mcb1_dram_dqs       			(mcb1_dram_dqs       				),
	.mcb1_dram_dqs_n     			(mcb1_dram_dqs_n     				),
	.mcb1_dram_ck        			(mcb1_dram_ck        				),
	.mcb1_dram_ck_n      			(mcb1_dram_ck_n      				)
	);

	//  ===============================================================================================
	//  u3_interface例化
	//  ===============================================================================================
	u3_interface # (
	.DATA_WD      					(DATA_WD      						),
	.REG_WD 						(REG_WD 							),
	.DMA_SIZE						(DMA_SIZE							)
	)
	u3_interface_inst(
	.clk							(clk_gpif							),
	.reset							(reset_u3_interface					),
	.i_data_valid					(w_frame_buffer_dvalid				),
	.iv_data						(wv_frame_buffer_data				),
	.i_framebuffer_empty			(w_back_buf_empty					),
	.o_fifo_rd						(w_buf_rd							),
	.iv_payload_size				(wv_payload_size_gpif				),
	.i_chunkmodeactive				(w_chunk_mode_active_gpif			),
	.iv_transfer_count				(wv_si_payload_transfer_count      	),
	.iv_transfer_size				(wv_si_payload_transfer_size      	),
	.iv_transfer1_size				(wv_si_payload_final_transfer1_size	),
	.iv_transfer2_size				(wv_si_payload_final_transfer2_size	),
	.i_usb_flagb					(i_usb_flagb_n						),
	.ov_usb_fifoaddr				(ov_usb_fifoaddr					),
	.ov_usb_fifoaddr_reg			(wv_usb_fifoaddr_reg				),
	.o_usb_slwr_n					(o_usb_slwr_n						),
	.ov_usb_data					(ov_usb_data						),
	.o_usb_pktend_n					(o_usb_pktend_n						),
	.o_usb_pktend_n_for_test		(w_usb_pktend_n_for_test			),
	.o_usb_wr_for_led				(w_usb_wr_for_led					)
	);

endmodule
