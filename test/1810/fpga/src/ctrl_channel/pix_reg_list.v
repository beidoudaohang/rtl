//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : pix_reg_list
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/5 15:39:34	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : pix时钟域的寄存器列表
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

module pix_reg_list # (
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
	parameter		LONG_REG_WD				= 64		//长寄存器位宽
	)
	(
	//  ===============================================================================================
	//	控制信号
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spi时钟域
	//  -------------------------------------------------------------------------------------
	input								i_wr_en				,	//写使能，clk_sample时钟域
	input								i_rd_en				,	//读使能，clk_sample时钟域
	input								i_cmd_is_rd			,	//读命令来了，clk_sample时钟域
	input	[SPI_ADDR_LENGTH-1:0]		iv_addr				,	//读写地址，clk_sample时钟域
	input	[SHORT_REG_WD-1:0]			iv_wr_data			,	//写数据，clk_sample时钟域
	//  -------------------------------------------------------------------------------------
	//	pix 时钟域
	//  -------------------------------------------------------------------------------------
	input								clk_pix				,	//像素时钟
	output								o_pix_sel			,	//像素时钟域被选择
	output	[SHORT_REG_WD-1:0]			ov_pix_rd_data		,	//读数据

	//  ===============================================================================================
	//	其他时钟域信号，需要和本时钟域的信号放在一个寄存器当中
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	clk reset top
	//  -------------------------------------------------------------------------------------
	input								i_sensor_reset_done			,	//clk_osc_bufg时钟域，Sensor复位完成寄存器
	//  -------------------------------------------------------------------------------------
	//	i2c_top
	//  -------------------------------------------------------------------------------------
	output	[4:0]						ov_i2c_ram_addr		,
	output	[15:0]						ov_i2c_cmd_addr		,
	output	[15:0]						ov_i2c_cmd_data		,
	output								o_i2c_ram_wren		,
	output								o_i2c_ena			,
	input								i_state_idle		,
	//  -------------------------------------------------------------------------------------
	//	frame buffer
	//  -------------------------------------------------------------------------------------
	input								i_ddr_init_done				,	//frame_buffer模块输出，mcb_drp_clk时钟域，MCB输出的初始化完整信号。
	input								i_ddr_error					,	//frame_buffer模块输出，时钟域未知，与MCB硬核相关，DDR错误信号
	input								i_frame_buffer_front_fifo_overflow,//帧存前端FIFO溢出 0:帧存前端FIFO没有溢出 1:帧存前端FIFO出现过溢出的现象
	//  -------------------------------------------------------------------------------------
	//	解串模块
	//  -------------------------------------------------------------------------------------
	input								i_deser_pll_lock			,	//解串模块pll_lock
	input								i_bitslip_done				,	//解串模块并行时钟时钟域，1表示边界已经对齐,固件检测到该信号为1之后才能开始图像采集
	//  ===============================================================================================
	//	以下内容是寄存器
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	通用
	//  -------------------------------------------------------------------------------------
	output								o_stream_enable_pix			,	//clk_pix时钟域，流使能信号
	output								o_acquisition_start_pix		,	//clk_pix时钟域，停开采信号
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
	output	[REG_WD-1:0]				ov_trigger_interval		,	//clk_pix时钟域，触发间隔，单位us
	input								i_sync_buffer_error			,	//sync_buffer模块引出出错检测脚，当不同的phy解析出的lval不同时，引脚置1
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
	output	[SHORT_REG_WD-1:0]			ov_roi_pic_height			//clk_pix时钟域，头包中的窗口高度
	);

	//	ref signals
	//  ===============================================================================================
	//	控制寄存器
	//  ===============================================================================================
	reg		[2:0]									wr_en_shift			= 3'b0;
	wire											wr_en_rise			;
	reg		[SHORT_REG_WD:0]						data_out_reg		= {(SHORT_REG_WD+1){1'b0}};

	//  ===============================================================================================
	//	以下内容是寄存器
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	测试
	//	-------------------------------------------------------------------------------------
	reg		[SHORT_REG_WD-1:0]						test_reg	= 16'h55aa;
	//  -------------------------------------------------------------------------------------
	//	通用
	//  -------------------------------------------------------------------------------------
	reg												param_cfg_done			= 1'b0;
	reg												stream_enable_pix		= 1'b0;
	reg												acquisition_start_pix	= 1'b0;
	//  -------------------------------------------------------------------------------------
	//	i2c_top
	//  -------------------------------------------------------------------------------------
	reg												i2c_ena					= 1'b0	;	//1-FPGA访问sensor，0-3014访问sensor
	reg		[SHORT_REG_WD-1:0]						coarse_exp_time			= 16'b0	;	//粗曝光时间
	reg		[SHORT_REG_WD-1:0]						fine_exp_time			= 16'b0	;	//细曝光时间
	reg		[SHORT_REG_WD-1:0]						line_length_pck			= 16'b0	;	//行周期
	reg		[SHORT_REG_WD-1:0]						frame_length_lines		= 16'b0	;	//帧周期
	reg		[SHORT_REG_WD-1:0]						y_output_size			= 16'b0	;	//输出窗口的高度
	reg		[SHORT_REG_WD-1:0]						y_addr_start			= 16'b0	;	//输出窗口的Y起点
	reg		[SHORT_REG_WD-1:0]						y_addr_end				= 16'b0	;	//输出窗口的Y终点
	reg		[SHORT_REG_WD-1:0]						x_output_size			= 16'b0	;	//输出窗口的宽度
	reg		[SHORT_REG_WD-1:0]						x_addr_start			= 16'b0	;	//输出窗口的X起点
	reg		[SHORT_REG_WD-1:0]						x_addr_end				= 16'b0	;	//输出窗口的X终点
	reg		[SHORT_REG_WD-1:0]						global_gain				= 16'b0	;	//增益
	reg		[SHORT_REG_WD-1:0]						data_pedestal			= 16'b0	;	//黑电平
	reg		[SHORT_REG_WD-1:0]						reset_register			= 16'b0	;	//复位 restart 寄存器
	reg		[SHORT_REG_WD-1:0]						gain1					= 16'b0	;	//新增增益1
	reg		[SHORT_REG_WD-1:0]						gain2					= 16'b0	;	//新增增益2
	reg		[SHORT_REG_WD-1:0]						gain3					= 16'b0	;	//新增增益3

	reg												i2c_ena_lock			= 1'b0	;	//i2c_ena锁存值
	reg												wr_en_rise_dly			= 1'b0	;	//写使能延时一拍，用于i2c的操作
	reg												i2c_ram_addr_hit		= 1'b0	;	//i2c ram 地址命中，用于i2c的操作
	reg												i2c_ram_wren			= 1'b0	;	//i2c ram 写使能，输出到i2c ram端口
	reg		[4:0]									i2c_ram_addr			= 5'b0	;	//i2c ram 写地址，输出到i2c ram端口
	reg		[15:0]									i2c_cmd_addr			= 16'b0	;	//i2c ram 写数据的一部分，输出到i2c ram端口
	reg		[15:0]									i2c_cmd_data			= 16'b0	;	//i2c ram 写数据的一部分，输出到i2c ram端口
	//  -------------------------------------------------------------------------------------
	//	io channel
	//  -------------------------------------------------------------------------------------
	reg												trigger_mode			= 1'b0		;	//默认触发模式关闭
	reg		[3:0]									trigger_source			= 4'b0001	;	//默认选择软触发
	reg												trigger_soft			= 1'b0		;
	reg												trigger_active			= 1'b1		;	//0-下降沿有效，1上升沿有效，默认上升沿有效
	reg		[TRIG_FILTER_WIDTH-SHORT_REG_WD-1:0]	trigger_filter_rise_h		= {(TRIG_FILTER_WIDTH-SHORT_REG_WD){1'b0}};
	reg		[TRIG_FILTER_WIDTH-SHORT_REG_WD-1:0]	trigger_filter_rise_h_group	= {(TRIG_FILTER_WIDTH-SHORT_REG_WD){1'b0}};
	reg		[SHORT_REG_WD-1:0]						trigger_filter_rise_l		= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]						trigger_filter_rise_l_group	= {SHORT_REG_WD{1'b0}};
	reg		[TRIG_FILTER_WIDTH-SHORT_REG_WD-1:0]	trigger_filter_fall_h		= {(TRIG_FILTER_WIDTH-SHORT_REG_WD){1'b0}};
	reg		[TRIG_FILTER_WIDTH-SHORT_REG_WD-1:0]	trigger_filter_fall_h_group	= {(TRIG_FILTER_WIDTH-SHORT_REG_WD){1'b0}};
	reg		[SHORT_REG_WD-1:0]						trigger_filter_fall_l		= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]						trigger_filter_fall_l_group	= {SHORT_REG_WD{1'b0}};
	reg		[TRIG_DELAY_WIDTH-SHORT_REG_WD-1:0]		trigger_delay_h			= {(TRIG_DELAY_WIDTH-SHORT_REG_WD){1'b0}};
	reg		[TRIG_DELAY_WIDTH-SHORT_REG_WD-1:0]		trigger_delay_h_group	= {(TRIG_DELAY_WIDTH-SHORT_REG_WD){1'b0}};
	reg		[SHORT_REG_WD-1:0]						trigger_delay_l			= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]						trigger_delay_l_group	= {SHORT_REG_WD{1'b0}};
	reg		[2:0]									useroutput_level		= 3'b0;
	//  -------------------------------------------------------------------------------------
	//	physic line bit define
	//	bit 0	: line mode		: 0-input	1-output
	//	bit 1	: line invert	: 0-keep	1-invert
	//	bit 4-2	: line source	: 000-no	001-strobe	010-user_output0(default)	011-user_output1	100-user_output2
	//  -------------------------------------------------------------------------------------
	reg		[4:0]						physic_line0			= 5'b00000	;	//line0 - bit0 只读，默认为0，意思是输入.bit4-2只读，默认为0.
	reg		[4:0]						physic_line1			= 5'b01001	;	//line1 - bit0 只读，默认为1，意思是输出
	reg		[4:0]						physic_line2			= 5'b01000	;
	reg		[4:0]						physic_line3			= 5'b01000	;
	reg		[LED_CTRL_WIDTH-1:0]		led_ctrl				= {LED_CTRL_WIDTH{1'b0}};
	//  -------------------------------------------------------------------------------------
	//	data channel
	//  -------------------------------------------------------------------------------------
	reg		[SHORT_REG_WD-1:0]			pixel_format_h			= 16'h0108;
	reg		[SHORT_REG_WD-1:0]			pixel_format_h_group	= 16'h0108;
	reg		[SHORT_REG_WD-1:0]			pixel_format_l			= 16'h0001;
	reg		[SHORT_REG_WD-1:0]			pixel_format_l_group	= 16'h0001;
	reg									pulse_filter_en			= 1'b1;
	reg		[2:0]						test_image_sel			= 3'b0;
	reg		[1:0]						interrupt_en			= 2'b0;
	reg		[1:0]						interrupt_clear			= 2'b0;
	reg		[WB_OFFSET_WIDTH-1:0]		wb_offset_x_start		= {WB_OFFSET_WIDTH{1'b0}};
	reg		[WB_OFFSET_WIDTH-1:0]		wb_offset_width_reg		= {WB_OFFSET_WIDTH{1'b0}};	//与parameter 参数名一样，因此加上后缀 _reg
	reg		[WB_OFFSET_WIDTH-1:0]		wb_offset_y_start		= {WB_OFFSET_WIDTH{1'b0}};
	reg		[WB_OFFSET_WIDTH-1:0]		wb_offset_height		= {WB_OFFSET_WIDTH{1'b0}};
	reg		[WB_GAIN_WIDTH-1:0]			wb_gain_r				= 'h100;
	reg		[WB_GAIN_WIDTH-1:0]			wb_gain_g				= 'h100;
	reg		[WB_GAIN_WIDTH-1:0]			wb_gain_b				= 'h100;
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_x_start		= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_width_reg	= {GREY_OFFSET_WIDTH{1'b0}};	//与parameter 参数名一样，因此加上后缀 _reg
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_y_start		= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_height		= {GREY_OFFSET_WIDTH{1'b0}};

	reg		[REG_WD-1:0]				trigger_interval		= 32'd200_000;
	//  -------------------------------------------------------------------------------------
	//	u3v format
	//  -------------------------------------------------------------------------------------
	reg									chunk_mode_active		= 1'b0	;
	reg									chunkid_en_img			= 1'b1	;	//该寄存器只读，恒为1
	reg									chunkid_en_fid			= 1'b0	;
	reg									chunkid_en_ts			= 1'b0	;
	reg		[SHORT_REG_WD-1:0]			chunk_size_img1			= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			chunk_size_img1_group	= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			chunk_size_img2			= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			chunk_size_img2_group	= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			payload_size_3			= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			payload_size_3_group	= {SHORT_REG_WD{1'b0}};


	reg		[SHORT_REG_WD-1:0]			payload_size_4			= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			payload_size_4_group	= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			trigger_interval1_group	= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			trigger_interval2_group	= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			roi_offset_x			= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			roi_offset_y			= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			roi_pic_width			= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			roi_pic_height			= {SHORT_REG_WD{1'b0}};

	//  ===============================================================================================
	//	非本时钟域信号，但是在同一个寄存器当中，需要跨时钟域处理
	//  ===============================================================================================
	reg									sensor_reset_done_dly0	= 1'b0;
	reg									sensor_reset_done_dly1	= 1'b0;
	reg									ddr_error_dly0			= 1'b0;
	reg									ddr_error_dly1			= 1'b0;
	reg									ddr_init_done_dly0		= 1'b0;
	reg									ddr_init_done_dly1		= 1'b0;
	reg		[3:0]						fval_state_dly0			= 4'b0;
	reg		[3:0]						fval_state_dly1			= 4'b0;
	reg									deser_pll_lock_dly0		= 1'b0;
	reg									deser_pll_lock_dly1		= 1'b0;
	reg									bitslip_done_dly0		= 1'b0;
	reg									bitslip_done_dly1		= 1'b0;

	//  ===============================================================================================
	//	只读寄存器锁存
	//  ===============================================================================================
	reg		[2:0]						cmd_is_rd_shift	= 3'b000;
	wire								cmd_is_rd_rise	;

	reg		[3:0]						line_status_latch			= 4'b0;
	reg		[WB_OFFSET_WIDTH-1:0]		wb_offset_width_latch		= {WB_OFFSET_WIDTH{1'b0}};
	reg		[WB_OFFSET_WIDTH-1:0]		wb_offset_height_latch		= {WB_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_width_latch		= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_height_latch	= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[SHORT_REG_WD-1:0]			state_latch					= {SHORT_REG_WD{1'b0}};
	reg		[1:0]						interrupt_state_latch		= 2'b0;
	reg		[WB_STATIS_WIDTH-1:0]		wb_statis_r_latch			= {WB_STATIS_WIDTH{1'b0}};
	reg		[WB_STATIS_WIDTH-1:0]		wb_statis_g_latch			= {WB_STATIS_WIDTH{1'b0}};
	reg		[WB_STATIS_WIDTH-1:0]		wb_statis_b_latch			= {WB_STATIS_WIDTH{1'b0}};
	reg		[GREY_STATIS_WIDTH-1:0]		grey_statis_sum_latch		= {GREY_STATIS_WIDTH{1'b0}};
	//	-------------------------------------------------------------------------------------
	//	测试
	//	-------------------------------------------------------------------------------------
	reg		[3:0]		fval_state_latch		= 4'b0;


	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***write process***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref write reg
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	在pix 时钟域取写信号的上升沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		wr_en_shift	<= {wr_en_shift[1:0],i_wr_en};
	end
	assign	wr_en_rise	= (wr_en_shift[2:1]==2'b01) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	-- ref write reg opration
	//	当 wr_en_rise 的时候，iv_addr已经稳定
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(wr_en_rise) begin
			case(iv_addr[8:0])
				//  -------------------------------------------------------------------------------------
				//	测试
				//  -------------------------------------------------------------------------------------
				9'h10	: test_reg					<= iv_wr_data[SHORT_REG_WD-1:0];
				//  -------------------------------------------------------------------------------------
				//	通用
				//  -------------------------------------------------------------------------------------
				9'h20	: param_cfg_done			<= iv_wr_data[0];
				9'h30	: stream_enable_pix			<= iv_wr_data[0];
				9'h32	: acquisition_start_pix		<= iv_wr_data[0];
				//  -------------------------------------------------------------------------------------
				//	io channel
				//  -------------------------------------------------------------------------------------
				9'h50	: trigger_mode				<= iv_wr_data[0];
				9'h51	: trigger_source			<= iv_wr_data[3:0];
				9'h52	: trigger_soft				<= iv_wr_data[0];
				9'h53	: trigger_active			<= iv_wr_data[0];
				9'h54	: trigger_filter_rise_h		<= iv_wr_data[TRIG_FILTER_WIDTH-SHORT_REG_WD-1:0];
				9'h55	: trigger_filter_rise_l		<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h56	: trigger_filter_fall_h		<= iv_wr_data[TRIG_FILTER_WIDTH-SHORT_REG_WD-1:0];
				9'h57	: trigger_filter_fall_l		<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h60	: trigger_delay_h			<= iv_wr_data[TRIG_DELAY_WIDTH-SHORT_REG_WD-1:0];
				9'h61	: trigger_delay_l			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h62	: useroutput_level			<= iv_wr_data[2:0];
				9'h63	: physic_line0[1]			<= iv_wr_data[1];
				9'h64	: physic_line1[4:1]			<= iv_wr_data[4:1];
				9'h65	: physic_line2				<= iv_wr_data[4:0];
				9'h66	: physic_line3				<= iv_wr_data[4:0];
				9'h90	: led_ctrl					<= iv_wr_data[LED_CTRL_WIDTH-1:0];
				//  -------------------------------------------------------------------------------------
				//	data channel
				//  -------------------------------------------------------------------------------------
				9'h33	: pixel_format_h			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h34	: pixel_format_l			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h130	: pulse_filter_en			<= iv_wr_data[0];
				9'h39	: test_image_sel			<= iv_wr_data[2:0];
				9'h80	: interrupt_en				<= iv_wr_data[1:0];
				9'h83	: interrupt_clear			<= iv_wr_data[1:0];
				9'hf0	: wb_offset_x_start			<= iv_wr_data[WB_OFFSET_WIDTH-1:0];
				9'hf1	: wb_offset_width_reg		<= iv_wr_data[WB_OFFSET_WIDTH-1:0];
				9'hf2	: wb_offset_y_start			<= iv_wr_data[WB_OFFSET_WIDTH-1:0];
				9'hf3	: wb_offset_height			<= iv_wr_data[WB_OFFSET_WIDTH-1:0];
				9'hf4	: wb_gain_r					<= iv_wr_data[WB_GAIN_WIDTH-1:0];
				9'hf5	: wb_gain_g					<= iv_wr_data[WB_GAIN_WIDTH-1:0];
				9'hf6	: wb_gain_b					<= iv_wr_data[WB_GAIN_WIDTH-1:0];
				9'h120	: grey_offset_x_start		<= iv_wr_data[GREY_OFFSET_WIDTH-1:0];
				9'h121	: grey_offset_width_reg		<= iv_wr_data[GREY_OFFSET_WIDTH-1:0];
				9'h122	: grey_offset_y_start		<= iv_wr_data[GREY_OFFSET_WIDTH-1:0];
				9'h123	: grey_offset_height		<= iv_wr_data[GREY_OFFSET_WIDTH-1:0];
				9'h68	: trigger_interval[31:16]	<= iv_wr_data;
				9'h69	: trigger_interval[15:0]	<= iv_wr_data;
				//  -------------------------------------------------------------------------------------
				//	u3v format
				//  -------------------------------------------------------------------------------------
				9'ha0	: chunk_mode_active			<= iv_wr_data[0];
				9'ha2	: chunkid_en_fid			<= iv_wr_data[0];
				9'ha3	: chunkid_en_ts				<= iv_wr_data[0];
				9'ha4	: chunk_size_img1			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'ha5	: chunk_size_img2			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h37	: payload_size_3			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h38	: payload_size_4			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h40	: roi_offset_x				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h41	: roi_offset_y				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h42	: roi_pic_width				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h43	: roi_pic_height			<= iv_wr_data[SHORT_REG_WD-1:0];
				//  -------------------------------------------------------------------------------------
				//	i2c_top
				//  -------------------------------------------------------------------------------------
				9'h18f	: i2c_ena					<= iv_wr_data[0];
				9'h190	: coarse_exp_time			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h191	: fine_exp_time				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h192	: line_length_pck			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h193	: frame_length_lines		<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h194	: y_output_size				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h195	: y_addr_start				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h196	: y_addr_end				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h197	: x_output_size				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h198	: x_addr_start				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h199	: x_addr_end				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h19a	: global_gain				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h19b	: data_pedestal				<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h19c	: reset_register			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h19d	: gain1						<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h19e	: gain2						<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h19f	: gain3						<= iv_wr_data[SHORT_REG_WD-1:0];
				default : ;
			endcase
		end
		else begin
			//自清零寄存器
			param_cfg_done		<= 1'b0;
			trigger_soft		<= 1'b0;
			interrupt_clear		<= 2'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	-- ref write i2c RAM
	//	wr_en_rise		:_______|--|___________________
	//	i2c_ena			:___|--------------------------
	//	wr_en_rise_dly	:__________|--|________________
	//	i2c_ram_addr_hit:__________|--|________________
	//	ov_i2c_ram_addr	:----------<---------->--------
	//	ov_i2c_cmd_addr	:----------<---------->--------
	//	ov_i2c_cmd_data	:----------<---------->--------
	//	o_i2c_ram_wren	:______________|--|____________
	//  -------------------------------------------------------------------------------------

	//	-------------------------------------------------------------------------------------
	//	i2c 写使能信号打一拍，目的是与后面的信号对齐
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		wr_en_rise_dly	<= wr_en_rise;
	end

	//	-------------------------------------------------------------------------------------
	//	i2c 地址命中信号。如果i2c的地址在ram取值范围之内，则命中
	//	只有地址是0x190-0x19f时才能产生RAM的写使能
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(wr_en_rise) begin
			if(iv_addr[8:0]>9'h18f && iv_addr[8:0]<9'h1a0) begin
				i2c_ram_addr_hit	<= 1'b1;
			end
			else begin
				i2c_ram_addr_hit	<= 1'b0;
			end
		end
		else begin
			i2c_ram_addr_hit	<= 1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	i2c ram 写使能信号
	//	写使能输出为1的条件是
	//	1.spi 写有效
	//	2.spi 写地址在i2c ram的区间之内
	//	3.i2c_ena寄存器打开
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		i2c_ram_wren	<= wr_en_rise_dly & i2c_ram_addr_hit & i2c_ena;
	end
	assign	o_i2c_ram_wren	= i2c_ram_wren;

	//	-------------------------------------------------------------------------------------
	//	i2c 写数据，在 wr_en_rise 的时候，保存数据
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(wr_en_rise) begin
			i2c_cmd_data	<= iv_wr_data[15:0];
		end
	end
	assign	ov_i2c_cmd_data	= i2c_cmd_data;

	//	-------------------------------------------------------------------------------------
	//	i2c 写地址
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(wr_en_rise) begin
			//	-------------------------------------------------------------------------------------
			//	如果写 0x19c 寄存器， ram 地址要加5 变为17
			//	-------------------------------------------------------------------------------------
			if(iv_addr[3:0]==4'hc) begin
				i2c_ram_addr[4:0]	<= iv_addr[3:0] + 5;
			end
			//	-------------------------------------------------------------------------------------
			//	如果写 0x19d - 0x19f 寄存器，ram 地址要加1 变为 14 15 16
			//	-------------------------------------------------------------------------------------
			else if(iv_addr[3:0]==4'hd || iv_addr[3:0]==4'he || iv_addr[3:0]==4'hf) begin
				i2c_ram_addr[4:0]	<= iv_addr[3:0] + 1;
			end
			//	-------------------------------------------------------------------------------------
			//	其他写操作 0x190 - 0x19b 寄存器，ram 地址要加2 变为 2 - 13
			//	-------------------------------------------------------------------------------------
			else begin
				i2c_ram_addr[4:0]	<= iv_addr[3:0] + 2;
			end
		end
	end
	assign	ov_i2c_ram_addr	= i2c_ram_addr;

	//  -------------------------------------------------------------------------------------
	//	RAM 内容分布
	//	地址		初始化内容		说明
	//  -------------------------------------------------------------------------------------
	//	0			00000000		RAM0地址没有用到
	//	1			301A801C		Sensor 流使能，使能HOLD命令
	//	2			30120C58		曝光时间粗调寄存器，对应的Sensor地址为0x3012
	//	3			30140000		曝光时间细调寄存器，对应的Sensor地址为0x3014
	//	4			300C15C0		行周期，对应的Sensor地址为0x300c
	//	5			300A0EB1		帧周期，对应的Sensor地址为0x300a
	//	6			034E0E64		输出图像高度，对应的Sensor地址为0x34e
	//	7			30020008		高度起始地址，对应的Sensor地址为0x3002
	//	8			30060E6D		高度结束地址，对应的Sensor地址为0x3006
	//	9			034C1330		输出图像宽度，对应的Sensor地址为0x34c
	//	10			30040008		宽度起始地址，对应的Sensor地址为0x3004
	//	11			30081337		宽度结束地址，对应的Sensor地址为0x3008
	//	12			305E2001		增益，对应的Sensor地址为0x305e
	//	13			301E00A8		黑电平，对应的Sensor地址为0x301e
	//	14			3ECC7368		增益1，只在AR1820中使用，对应的Sensor地址为0x3ecc
	//	15			3F1A0F04		增益2，只在AR1820中使用，对应的Sensor地址为0x3f1a
	//	16			3F440C0C		增益3，只在AR1820中使用，对应的Sensor地址为0x3f44
	//	17			301A801E		重新触发一帧图像，对应的Sensor地址为0x301a，该寄存器在连续模式下也能改写。但是在触发模式下的数据必须是0x801E
	//	18			301A001C		解除HOLD命令，对应的Sensor地址为0x301a
	//	19-31		00000000		没有用到
	//  -------------------------------------------------------------------------------------

	//  -------------------------------------------------------------------------------------
	//	根据FPGA内部寄存器地址给出i2c寄存器地，这些地址在RAM里是顺序存放的
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(wr_en_rise) begin
			case(iv_addr[8:0])
				9'h190	: i2c_cmd_addr	<= 16'h3012	;	//曝光粗调寄存器地址，		存入RAM地址1
				9'h191	: i2c_cmd_addr	<= 16'h3014	;	//曝光细调寄存器地址，		存入RAM地址2
				9'h192	: i2c_cmd_addr	<= 16'h300C	;	//行周期寄存器地址，		存入RAM地址3
				9'h193	: i2c_cmd_addr	<= 16'h300A	;	//帧周期寄存器地址，		存入RAM地址4
				9'h194	: i2c_cmd_addr	<= 16'h34E	;	//输出图像高度寄存器地址，	存入RAM地址5
				9'h195	: i2c_cmd_addr	<= 16'h3002	;	//行起始地址寄存器地址，	存入RAM地址6
				9'h196	: i2c_cmd_addr	<= 16'h3006	;	//行结束地址寄存器地址，	存入RAM地址7
				9'h197	: i2c_cmd_addr	<= 16'h34C	;	//输出图像宽度寄存器地址，	存入RAM地址8
				9'h198	: i2c_cmd_addr	<= 16'h3004	;	//列起始地址寄存器地址，	存入RAM地址9
				9'h199	: i2c_cmd_addr	<= 16'h3008	;	//列结束地址寄存器地址，	存入RAM地址10
				9'h19a	: i2c_cmd_addr	<= 16'h305E	;	//增益寄存器地址，			存入RAM地址11
				9'h19b	: i2c_cmd_addr	<= 16'h301E	;	//黑电平寄存器地址，		存入RAM地址12
				9'h19c	: i2c_cmd_addr	<= 16'h301A	;	//复位寄存器地址，			存入RAM地址16  ***注意这个是最后一个地址***
				9'h19d	: i2c_cmd_addr	<= 16'h3ECC	;	//gain1寄存器地址，			存入RAM地址13
				9'h19e	: i2c_cmd_addr	<= 16'h3F1A	;	//gain2寄存器地址，			存入RAM地址14
				9'h19f	: i2c_cmd_addr	<= 16'h3F44	;	//gain3寄存器地址，			存入RAM地址15
				default	: i2c_cmd_addr	<= 16'hFFFF	;
			endcase
		end
	end
	assign	ov_i2c_cmd_addr	= i2c_cmd_addr;

	//  -------------------------------------------------------------------------------------
	//	-- ref group enable
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	像素格式成组生效
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(param_cfg_done) begin
			pixel_format_h_group	<= pixel_format_h;
			pixel_format_l_group	<= pixel_format_l;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	IO参数成组生效
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(param_cfg_done) begin
			trigger_filter_rise_h_group	<= trigger_filter_rise_h;
			trigger_filter_rise_l_group	<= trigger_filter_rise_l;
			trigger_filter_fall_h_group	<= trigger_filter_fall_h;
			trigger_filter_fall_l_group	<= trigger_filter_fall_l;
			trigger_delay_h_group		<= trigger_delay_h;
			trigger_delay_l_group		<= trigger_delay_l;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	传输大小成组生效
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(param_cfg_done) begin
			payload_size_3_group	<= payload_size_3;
			payload_size_4_group	<= payload_size_4;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	chunk size 成组生效
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(param_cfg_done) begin
			chunk_size_img1_group	<= chunk_size_img1;
			chunk_size_img2_group	<= chunk_size_img2;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	trigger_interval 成组生效
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(param_cfg_done) begin
			trigger_interval1_group	<= trigger_interval[31:16];
			trigger_interval2_group	<= trigger_interval[15:0];
		end
	end
	//  -------------------------------------------------------------------------------------
	//	-- ref output
	//  -------------------------------------------------------------------------------------
	assign	o_stream_enable_pix		= stream_enable_pix;
	assign	o_acquisition_start_pix	= acquisition_start_pix;
	//  -------------------------------------------------------------------------------------
	//	i2c_top
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix)begin
		if(i_state_idle)					//i2c_top模块空闲时锁存i2c_ena
		i2c_ena_lock	<=	i2c_ena;
		else
		i2c_ena_lock	<=	i2c_ena_lock;
	end
	assign	o_i2c_ena			= i2c_ena_lock;
	//  -------------------------------------------------------------------------------------
	//	io channel
	//  -------------------------------------------------------------------------------------
	assign	o_trigger_mode			= trigger_mode;
	assign	ov_trigger_source		= trigger_source;
	assign	o_trigger_soft			= trigger_soft;
	assign	o_trigger_active		= trigger_active;
	assign	ov_trigger_filter_rise	= {trigger_filter_rise_h_group,trigger_filter_rise_l_group};
	assign	ov_trigger_filter_fall	= {trigger_filter_fall_h_group,trigger_filter_fall_l_group};
	assign	ov_trigger_delay		= {trigger_delay_h_group,trigger_delay_l_group};
	assign	ov_useroutput_level		= useroutput_level;
	assign	o_line2_mode			= physic_line2[0];
	assign	o_line3_mode			= physic_line3[0];
	assign	o_line0_invert			= physic_line0[1];
	assign	o_line1_invert			= physic_line1[1];
	assign	o_line2_invert			= physic_line2[1];
	assign	o_line3_invert			= physic_line3[1];
	assign	ov_line_source1			= physic_line1[4:2];
	assign	ov_line_source2			= physic_line2[4:2];
	assign	ov_line_source3			= physic_line3[4:2];
	assign	ov_led_ctrl				= led_ctrl[LED_CTRL_WIDTH-1:0];
	//  -------------------------------------------------------------------------------------
	//	data channel
	//  -------------------------------------------------------------------------------------
	assign	ov_pixel_format			= {pixel_format_h_group,pixel_format_l_group};
	assign	o_pulse_filter_en		= pulse_filter_en;
	assign	ov_test_image_sel		= test_image_sel;
	assign	ov_interrupt_en			= interrupt_en;
	assign	ov_interrupt_clear		= interrupt_clear;
	assign	ov_wb_offset_x_start	= wb_offset_x_start;
	assign	ov_wb_offset_width		= wb_offset_width_reg;
	assign	ov_wb_offset_y_start	= wb_offset_y_start;
	assign	ov_wb_offset_height		= wb_offset_height;
	assign	ov_wb_gain_r			= wb_gain_r;
	assign	ov_wb_gain_g			= wb_gain_g;
	assign	ov_wb_gain_b			= wb_gain_b;
	assign	ov_grey_offset_x_start	= grey_offset_x_start;
	assign	ov_grey_offset_width	= grey_offset_width_reg;
	assign	ov_grey_offset_y_start	= grey_offset_y_start;
	assign	ov_grey_offset_height	= grey_offset_height;
	assign	ov_trigger_interval		= {trigger_interval1_group,trigger_interval2_group};
	//  -------------------------------------------------------------------------------------
	//	u3v format
	//  -------------------------------------------------------------------------------------
	assign	o_chunk_mode_active		= chunk_mode_active;
	assign	o_chunkid_en_ts			= chunkid_en_ts;
	assign	o_chunkid_en_fid		= chunkid_en_fid;
	assign	ov_chunk_size_img		= {chunk_size_img1_group,chunk_size_img2_group};
	assign	ov_payload_size_pix		= {payload_size_3_group,payload_size_4_group};
	assign	ov_roi_offset_x			= roi_offset_x;
	assign	ov_roi_offset_y			= roi_offset_y;
	assign	ov_roi_pic_width		= roi_pic_width;
	assign	ov_roi_pic_height		= roi_pic_height;

	//  ===============================================================================================
	//	ref ***read process***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref read reg operation
	//	读, data_out_reg 最高bit说明是否选中了该时钟域，余下内容为寄存器数据
	//	读过程是纯异步逻辑，i_rd_en iv_addr 都是异步信号，输入信号稳定之后，输出也就会稳定
	//  -------------------------------------------------------------------------------------
	always @ ( * ) begin
		//当读地址选中的时候，sel拉高为有效
		if(i_rd_en) begin
			case(iv_addr[8:0])
				//  -------------------------------------------------------------------------------------
				//	测试
				//  -------------------------------------------------------------------------------------
				9'h10	: data_out_reg	<= {1'b1,test_reg[SHORT_REG_WD-1:0]};
				//  -------------------------------------------------------------------------------------
				//	通用
				//  -------------------------------------------------------------------------------------
				9'h20	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},param_cfg_done};
				9'h30	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},stream_enable_pix};
				9'h32	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},acquisition_start_pix};
				//  -------------------------------------------------------------------------------------
				//	io channel
				//  -------------------------------------------------------------------------------------
				9'h50	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},trigger_mode};
				9'h51	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-4){1'b0}},trigger_source[3:0]};
				9'h52	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},trigger_soft};
				9'h53	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},trigger_active};
				9'h54	: data_out_reg	<= {1'b1,{(REG_WD-TRIG_FILTER_WIDTH){1'b0}},trigger_filter_rise_h[TRIG_FILTER_WIDTH-SHORT_REG_WD-1:0]};
				9'h55	: data_out_reg	<= {1'b1,trigger_filter_rise_l[SHORT_REG_WD-1:0]};
				9'h56	: data_out_reg	<= {1'b1,{(REG_WD-TRIG_FILTER_WIDTH){1'b0}},trigger_filter_fall_h[TRIG_FILTER_WIDTH-SHORT_REG_WD-1:0]};
				9'h57	: data_out_reg	<= {1'b1,trigger_filter_fall_l[SHORT_REG_WD-1:0]};
				9'h60	: data_out_reg	<= {1'b1,{(REG_WD-TRIG_DELAY_WIDTH){1'b0}},trigger_delay_h[TRIG_DELAY_WIDTH-SHORT_REG_WD-1:0]};
				9'h61	: data_out_reg	<= {1'b1,trigger_delay_l[SHORT_REG_WD-1:0]};
				9'h62	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-3){1'b0}},useroutput_level[2:0]};
				9'h63	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-5){1'b0}},physic_line0[4:0]};
				9'h64	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-5){1'b0}},physic_line1[4:0]};
				9'h65	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-5){1'b0}},physic_line2[4:0]};
				9'h66	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-5){1'b0}},physic_line3[4:0]};
				9'h90	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-LED_CTRL_WIDTH){1'b0}},led_ctrl[LED_CTRL_WIDTH-1:0]};

				//read only
				9'h67	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-4){1'b0}},line_status_latch[3:0]};
				9'h78	: data_out_reg	<= {1'b1,{12'b0},fval_state_latch[3:0]};

				//  -------------------------------------------------------------------------------------
				//	data channel
				//  -------------------------------------------------------------------------------------
				//read write
				9'h33	: data_out_reg	<= {1'b1,pixel_format_h[SHORT_REG_WD-1:0]};
				9'h34	: data_out_reg	<= {1'b1,pixel_format_l[SHORT_REG_WD-1:0]};
				9'h130	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},pulse_filter_en};
				9'h39	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-3){1'b0}},test_image_sel[2:0]};
				9'h80	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-2){1'b0}},interrupt_en[1:0]};
				9'h83	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-2){1'b0}},interrupt_clear[1:0]};
				9'hf0	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-WB_OFFSET_WIDTH){1'b0}},wb_offset_x_start[WB_OFFSET_WIDTH-1:0]};
				9'hf1	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-WB_OFFSET_WIDTH){1'b0}},wb_offset_width_latch[WB_OFFSET_WIDTH-1:0]};
				9'hf2	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-WB_OFFSET_WIDTH){1'b0}},wb_offset_y_start[WB_OFFSET_WIDTH-1:0]};
				9'hf3	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-WB_OFFSET_WIDTH){1'b0}},wb_offset_height_latch[WB_OFFSET_WIDTH-1:0]};
				9'hf4	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-WB_GAIN_WIDTH){1'b0}},wb_gain_r[WB_GAIN_WIDTH-1:0]};
				9'hf5	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-WB_GAIN_WIDTH){1'b0}},wb_gain_g[WB_GAIN_WIDTH-1:0]};
				9'hf6	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-WB_GAIN_WIDTH){1'b0}},wb_gain_b[WB_GAIN_WIDTH-1:0]};
				9'h120	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-GREY_OFFSET_WIDTH){1'b0}},grey_offset_x_start[GREY_OFFSET_WIDTH-1:0]};
				9'h121	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-GREY_OFFSET_WIDTH){1'b0}},grey_offset_width_latch[GREY_OFFSET_WIDTH-1:0]};
				9'h122	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-GREY_OFFSET_WIDTH){1'b0}},grey_offset_y_start[GREY_OFFSET_WIDTH-1:0]};
				9'h123	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-GREY_OFFSET_WIDTH){1'b0}},grey_offset_height_latch[GREY_OFFSET_WIDTH-1:0]};
				9'h68	: data_out_reg	<= {1'b1,trigger_interval[31:16]};
				9'h69	: data_out_reg	<= {1'b1,trigger_interval[15:0]};
				//read only
				9'h31	: data_out_reg	<= {1'b1,state_latch};
				9'h82	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-2){1'b0}},interrupt_state_latch[1:0]};
				9'hf7	: data_out_reg	<= {1'b1,{(REG_WD-WB_STATIS_WIDTH){1'b0}},wb_statis_r_latch[WB_STATIS_WIDTH-1:SHORT_REG_WD]};
				9'hf8	: data_out_reg	<= {1'b1,wb_statis_r_latch[SHORT_REG_WD-1:0]};
				9'hf9	: data_out_reg	<= {1'b1,{(REG_WD-WB_STATIS_WIDTH){1'b0}},wb_statis_g_latch[WB_STATIS_WIDTH-1:SHORT_REG_WD]};
				9'hfa	: data_out_reg	<= {1'b1,wb_statis_g_latch[SHORT_REG_WD-1:0]};
				9'hfb	: data_out_reg	<= {1'b1,{(REG_WD-WB_STATIS_WIDTH){1'b0}},wb_statis_b_latch[WB_STATIS_WIDTH-1:SHORT_REG_WD]};
				9'hfc	: data_out_reg	<= {1'b1,wb_statis_b_latch[SHORT_REG_WD-1:0]};
				9'h124	: data_out_reg	<= {1'b1,{(3*SHORT_REG_WD-GREY_STATIS_WIDTH){1'b0}},grey_statis_sum_latch[GREY_STATIS_WIDTH-1:REG_WD]};	//灰度统计结果小于32bit
				9'h125	: data_out_reg	<= {1'b1,grey_statis_sum_latch[REG_WD-1:SHORT_REG_WD]};
				9'h126	: data_out_reg	<= {1'b1,grey_statis_sum_latch[SHORT_REG_WD-1:0]};
				//  -------------------------------------------------------------------------------------
				//	u3v format
				//  -------------------------------------------------------------------------------------
				//read write
				9'ha0	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},chunk_mode_active};
				9'ha1	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},chunkid_en_img};
				9'ha2	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},chunkid_en_fid};
				9'ha3	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},chunkid_en_ts};
				9'ha4	: data_out_reg	<= {1'b1,chunk_size_img1[SHORT_REG_WD-1:0]};
				9'ha5	: data_out_reg	<= {1'b1,chunk_size_img2[SHORT_REG_WD-1:0]};
				9'h35	: data_out_reg	<= {1'b1,{SHORT_REG_WD{1'b0}}};	//payload_size1
				9'h36	: data_out_reg	<= {1'b1,{SHORT_REG_WD{1'b0}}};	//payload_size2
				9'h37	: data_out_reg	<= {1'b1,payload_size_3[SHORT_REG_WD-1:0]};
				9'h38	: data_out_reg	<= {1'b1,payload_size_4[SHORT_REG_WD-1:0]};
				9'h40	: data_out_reg	<= {1'b1,roi_offset_x[SHORT_REG_WD-1:0]};
				9'h41	: data_out_reg	<= {1'b1,roi_offset_y[SHORT_REG_WD-1:0]};
				9'h42	: data_out_reg	<= {1'b1,roi_pic_width[SHORT_REG_WD-1:0]};
				9'h43	: data_out_reg	<= {1'b1,roi_pic_height[SHORT_REG_WD-1:0]};

				//  -------------------------------------------------------------------------------------
				//	i2c_top
				//  -------------------------------------------------------------------------------------
				//reaf only
				9'h18e	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},i2c_ena_lock};
				//read write
				9'h18f	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},i2c_ena};
				9'h190	: data_out_reg	<= {1'b1,coarse_exp_time[SHORT_REG_WD-1:0]};
				9'h191	: data_out_reg	<= {1'b1,fine_exp_time[SHORT_REG_WD-1:0]};
				9'h192	: data_out_reg	<= {1'b1,line_length_pck[SHORT_REG_WD-1:0]};
				9'h193	: data_out_reg	<= {1'b1,frame_length_lines[SHORT_REG_WD-1:0]};
				9'h194	: data_out_reg	<= {1'b1,y_output_size[SHORT_REG_WD-1:0]};
				9'h195	: data_out_reg	<= {1'b1,y_addr_start[SHORT_REG_WD-1:0]};
				9'h196	: data_out_reg	<= {1'b1,y_addr_end[SHORT_REG_WD-1:0]};
				9'h197	: data_out_reg	<= {1'b1,x_output_size[SHORT_REG_WD-1:0]};
				9'h198	: data_out_reg	<= {1'b1,x_addr_start[SHORT_REG_WD-1:0]};
				9'h199	: data_out_reg	<= {1'b1,x_addr_end[SHORT_REG_WD-1:0]};
				9'h19a	: data_out_reg	<= {1'b1,global_gain[SHORT_REG_WD-1:0]};
				9'h19b	: data_out_reg	<= {1'b1,data_pedestal[SHORT_REG_WD-1:0]};
				9'h19c	: data_out_reg	<= {1'b1,reset_register[SHORT_REG_WD-1:0]};
				9'h19d	: data_out_reg	<= {1'b1,gain1[SHORT_REG_WD-1:0]};
				9'h19e	: data_out_reg	<= {1'b1,gain2[SHORT_REG_WD-1:0]};
				9'h19f	: data_out_reg	<= {1'b1,gain3[SHORT_REG_WD-1:0]};
				default	: data_out_reg	<= {(SHORT_REG_WD+1){1'b0}};
			endcase
		end
		//当读使能取消的时候，sel才能复位为0
		else begin
			data_out_reg	<= {(SHORT_REG_WD+1){1'b0}};
		end
	end
	assign	o_pix_sel		= data_out_reg[SHORT_REG_WD];
	assign	ov_pix_rd_data	= data_out_reg[SHORT_REG_WD-1:0];

	//  ===============================================================================================
	//	-- ref cross domain read
	//	但是在同一个寄存器当中，需要跨时钟域处理
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	clk reset top
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		sensor_reset_done_dly0	<= 	i_sensor_reset_done;
		sensor_reset_done_dly1	<= 	sensor_reset_done_dly0;
	end

	//  -------------------------------------------------------------------------------------
	//	frame buffer
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		ddr_init_done_dly0	<= 	i_ddr_init_done;
		ddr_init_done_dly1	<= 	ddr_init_done_dly0;
	end

	always @ (posedge clk_pix) begin
		ddr_error_dly0	<= 	i_ddr_error;
		ddr_error_dly1	<= 	ddr_error_dly0;
	end

	//	-------------------------------------------------------------------------------------
	//	fval state 有的bit不是 clk_pix时钟域的，一起打拍延时
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		fval_state_dly0	<= iv_fval_state;
		fval_state_dly1	<= fval_state_dly0;
	end

	//	-------------------------------------------------------------------------------------
	//	解串模块pll
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		deser_pll_lock_dly0	<= i_deser_pll_lock;
		deser_pll_lock_dly1	<= deser_pll_lock_dly0;
	end

	//	-------------------------------------------------------------------------------------
	//	解串模块并行时钟域
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		bitslip_done_dly0	<= i_bitslip_done;
		bitslip_done_dly1	<= bitslip_done_dly0;
	end

	//  ===============================================================================================
	//	-- ref read only reg-latch
	//	在读之前，将所有的只读寄存器打一拍，不让其跳动
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	提取读命令的上升沿
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		cmd_is_rd_shift	<= {cmd_is_rd_shift[1:0],i_cmd_is_rd};
	end
	assign	cmd_is_rd_rise	= (cmd_is_rd_shift[2:1]==2'b01) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	在读命令的上升沿锁存只读数据
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(cmd_is_rd_rise) begin
			line_status_latch			<= iv_line_status[3:0];
			wb_offset_width_latch		<= iv_wb_offset_width;
			wb_offset_height_latch		<= iv_wb_offset_height;
			grey_offset_width_latch		<= iv_grey_offset_width;
			grey_offset_height_latch	<= iv_grey_offset_height;
			state_latch					<= {{(SHORT_REG_WD-8){1'b0}},i_frame_buffer_front_fifo_overflow,i_sync_buffer_error,bitslip_done_dly1,deser_pll_lock_dly1,sensor_reset_done_dly1,i_full_frame_state,ddr_error_dly1,ddr_init_done_dly1};
			interrupt_state_latch		<= iv_interrupt_state;
			wb_statis_r_latch			<= iv_wb_statis_r;
			wb_statis_g_latch			<= iv_wb_statis_g;
			wb_statis_b_latch			<= iv_wb_statis_b;
			grey_statis_sum_latch		<= iv_grey_statis_sum;

			fval_state_latch			<= fval_state_dly1;
		end
	end


endmodule