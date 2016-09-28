//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : harness
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/4/13 15:38:58	:|  初始版本
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
`define		TESTCASE	testcase1
module harness ();

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	参数定义
	//	-------------------------------------------------------------------------------------
	parameter				WB_OFFSET_WIDTH			= `TESTCASE.WB_OFFSET_WIDTH			;
	parameter				WB_GAIN_WIDTH			= `TESTCASE.WB_GAIN_WIDTH			;
	parameter				WB_STATIS_WIDTH			= `TESTCASE.WB_STATIS_WIDTH			;
	parameter				GREY_OFFSET_WIDTH		= `TESTCASE.GREY_OFFSET_WIDTH		;
	parameter				GREY_STATIS_WIDTH		= `TESTCASE.GREY_STATIS_WIDTH		;
	parameter				TRIG_FILTER_WIDTH		= `TESTCASE.TRIG_FILTER_WIDTH		;
	parameter				TRIG_DELAY_WIDTH		= `TESTCASE.TRIG_DELAY_WIDTH		;
	parameter				LED_CTRL_WIDTH			= `TESTCASE.LED_CTRL_WIDTH			;
	parameter				SHORT_REG_WD			= `TESTCASE.SHORT_REG_WD			;
	parameter				REG_WD					= `TESTCASE.REG_WD					;
	parameter				LONG_REG_WD				= `TESTCASE.LONG_REG_WD				;
	parameter				BUF_DEPTH_WD			= `TESTCASE.BUF_DEPTH_WD			;
	parameter				REG_INIT_VALUE			= `TESTCASE.REG_INIT_VALUE			;

	//	-------------------------------------------------------------------------------------
	//	输出线网
	//	-------------------------------------------------------------------------------------
	wire							o_stream_enable_pix;
	wire							o_acquisition_start_pix;
	wire							o_stream_enable_frame_buf;
	wire							o_stream_enable_gpif;
	wire							o_reset_sensor;

	wire							o_trigger_mode;
	wire	[3:0]					ov_trigger_source;
	wire							o_trigger_soft;
	wire							o_trigger_active;
	wire	[TRIG_FILTER_WIDTH-1:0]	ov_trigger_filter_rise;
	wire	[TRIG_FILTER_WIDTH-1:0]	ov_trigger_filter_fall;
	wire	[TRIG_DELAY_WIDTH-1:0]	ov_trigger_delay;
	wire	[2:0]					ov_useroutput_level;
	wire							o_line2_mode;
	wire							o_line3_mode;
	wire							o_line0_invert;
	wire							o_line1_invert;
	wire							o_line2_invert;
	wire							o_line3_invert;
	wire	[2:0]					ov_line_source1;
	wire	[2:0]					ov_line_source2;
	wire	[2:0]					ov_line_source3;

	wire	[4:0]					ov_led_ctrl;
	wire	[REG_WD-1:0]			ov_pixel_format;

	wire							o_encrypt_state;
	wire							o_pulse_filter_en;
	wire	[1:0]					ov_test_image_sel;
	wire	[1:0]					ov_interrupt_en;

	wire	[1:0]					ov_interrupt_clear;
	wire	[WB_OFFSET_WIDTH-1:0]	ov_wb_offset_x_start;
	wire	[WB_OFFSET_WIDTH-1:0]	ov_wb_offset_width;
	wire	[WB_OFFSET_WIDTH-1:0]	ov_wb_offset_y_start;
	wire	[WB_OFFSET_WIDTH-1:0]	ov_wb_offset_height;
	wire	[WB_GAIN_WIDTH-1:0]		ov_wb_gain_r;
	wire	[WB_GAIN_WIDTH-1:0]		ov_wb_gain_g;
	wire	[WB_GAIN_WIDTH-1:0]		ov_wb_gain_b;

	wire	[GREY_OFFSET_WIDTH-1:0]	ov_grey_offset_x_start;
	wire	[GREY_OFFSET_WIDTH-1:0]	ov_grey_offset_width;
	wire	[GREY_OFFSET_WIDTH-1:0]	ov_grey_offset_y_start;
	wire	[GREY_OFFSET_WIDTH-1:0]	ov_grey_offset_height;

	wire							o_chunk_mode_active;
	wire							o_chunkid_en_ts;
	wire							o_chunkid_en_fid;
	wire	[REG_WD-1:0]			ov_chunk_size_img;
	wire	[REG_WD-1:0]			ov_payload_size_pix;
	wire	[SHORT_REG_WD-1:0]		ov_roi_offset_x;
	wire	[SHORT_REG_WD-1:0]		ov_roi_offset_y;
	wire	[SHORT_REG_WD-1:0]		ov_roi_pic_width;
	wire	[SHORT_REG_WD-1:0]		ov_roi_pic_height;
	wire	[LONG_REG_WD-1:0]		ov_timestamp_u3;
	wire	[REG_WD-1:0]			ov_payload_size_frame_buf;
	wire	[BUF_DEPTH_WD-1:0]		ov_frame_buffer_depth	;
	wire							o_chunk_mode_active_frame_buf	;
	wire	[REG_WD-1:0]			ov_si_payload_transfer_size;
	wire	[REG_WD-1:0]			ov_si_payload_transfer_count;
	wire	[REG_WD-1:0]			ov_si_payload_final_transfer1_size;
	wire	[REG_WD-1:0]			ov_si_payload_final_transfer2_size;
	wire	[REG_WD-1:0]			ov_payload_size_gpif;
	wire							o_chunk_mode_active_gpif	;

	//	-------------------------------------------------------------------------------------
	//	输入引用
	//	-------------------------------------------------------------------------------------
	wire				i_spi_clk	;
	wire				i_spi_cs	;
	wire				i_spi_mosi	;

	wire				clk_osc_bufg	;
	wire				reset_osc_bufg	;
	wire				clk_pix			;
	wire				reset_pix		;
	wire				clk_frame_buf	;
	wire				reset_frame_buf	;
	wire				clk_gpif		;
	wire				reset_gpif		;

	//	-------------------------------------------------------------------------------------
	//	重新做逻辑
	//	-------------------------------------------------------------------------------------
	wire				o_spi_miso	;
	wire				o_spi_miso_data_en	;
	wire				o_spi_miso_data	;

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	引用
	//	-------------------------------------------------------------------------------------
	assign	i_spi_clk	= driver_spi_master.o_spi_clk	;
	assign	i_spi_cs	= driver_spi_master.o_spi_cs	;
	assign	i_spi_mosi	= driver_spi_master.o_spi_mosi	;

	assign	clk_osc_bufg	= `TESTCASE.clk_osc_bufg   ;
	assign	reset_osc_bufg  = `TESTCASE.reset_osc_bufg ;
	assign	clk_pix         = `TESTCASE.clk_pix        ;
	assign	reset_pix       = `TESTCASE.reset_pix      ;
	assign	clk_frame_buf   = `TESTCASE.clk_frame_buf  ;
	assign	reset_frame_buf = `TESTCASE.reset_frame_buf;
	assign	clk_gpif        = `TESTCASE.clk_gpif       ;
	assign	reset_gpif      = `TESTCASE.reset_gpif     ;

	//	-------------------------------------------------------------------------------------
	//	上拉模块
	//	-------------------------------------------------------------------------------------
	PULLUP PULLUP_inst (
	.O	(o_spi_miso)     // Pullup output (connect directly to top-level port)
	);
	assign	o_spi_miso	= o_spi_miso_data_en ? o_spi_miso_data : 1'bz;


	//	-------------------------------------------------------------------------------------
	//	控制通道模块
	//	-------------------------------------------------------------------------------------
	ctrl_channel # (
	.WB_OFFSET_WIDTH			(WB_OFFSET_WIDTH	),
	.WB_GAIN_WIDTH				(WB_GAIN_WIDTH		),
	.WB_STATIS_WIDTH			(WB_STATIS_WIDTH	),
	.GREY_OFFSET_WIDTH			(GREY_OFFSET_WIDTH	),
	.GREY_STATIS_WIDTH			(GREY_STATIS_WIDTH	),
	.TRIG_FILTER_WIDTH			(TRIG_FILTER_WIDTH	),
	.TRIG_DELAY_WIDTH			(TRIG_DELAY_WIDTH	),
	.LED_CTRL_WIDTH				(LED_CTRL_WIDTH		),
	.SHORT_REG_WD				(SHORT_REG_WD		),
	.REG_WD						(REG_WD				),
	.LONG_REG_WD				(LONG_REG_WD		),
	.BUF_DEPTH_WD				(BUF_DEPTH_WD		),
	.REG_INIT_VALUE				(REG_INIT_VALUE		)
	)
	ctrl_channel_inst (
	.i_spi_clk					(i_spi_clk				),
	.i_spi_cs_n					(i_spi_cs				),
	.i_spi_mosi					(i_spi_mosi				),
	.o_spi_miso_data			(o_spi_miso_data			),
	.o_spi_miso_data_en			(o_spi_miso_data_en			),
	.clk_osc_bufg				(clk_osc_bufg				),
	.reset_osc_bufg				(reset_osc_bufg				),
	.clk_pix					(clk_pix					),
	.reset_pix					(reset_pix					),
	.i_fval						(`TESTCASE.i_fval					),
	.clk_frame_buf				(clk_frame_buf				),
	.reset_frame_buf			(reset_frame_buf			),
	.clk_gpif					(clk_gpif					),
	.reset_gpif					(reset_gpif					),
	.o_stream_enable_pix		(o_stream_enable_pix		),
	.o_acquisition_start_pix	(o_acquisition_start_pix	),
	.o_stream_enable_frame_buf	(o_stream_enable_frame_buf	),
	.o_stream_enable_gpif		(o_stream_enable_gpif		),
	.o_reset_sensor				(o_reset_sensor				),
	.i_sensor_reset_done		(`TESTCASE.i_sensor_reset_done	),
	.o_trigger_mode				(o_trigger_mode				),
	.ov_trigger_source			(ov_trigger_source			),
	.o_trigger_soft				(o_trigger_soft				),
	.o_trigger_active			(o_trigger_active			),
	.ov_trigger_filter_rise		(ov_trigger_filter_rise		),
	.ov_trigger_filter_fall		(ov_trigger_filter_fall		),
	.ov_trigger_delay			(ov_trigger_delay			),
	.ov_useroutput_level		(ov_useroutput_level		),
	.o_line2_mode				(o_line2_mode				),
	.o_line3_mode				(o_line3_mode				),
	.o_line0_invert				(o_line0_invert				),
	.o_line1_invert				(o_line1_invert				),
	.o_line2_invert				(o_line2_invert				),
	.o_line3_invert				(o_line3_invert				),
	.ov_line_source1			(ov_line_source1			),
	.ov_line_source2			(ov_line_source2			),
	.ov_line_source3			(ov_line_source3			),
	.iv_line_status				(`TESTCASE.iv_line_status			),
	.ov_led_ctrl				(ov_led_ctrl				),
	.ov_pixel_format			(ov_pixel_format			),
	.i_full_frame_state			(`TESTCASE.i_full_frame_state		),
	.o_encrypt_state			(o_encrypt_state			),
	.o_pulse_filter_en			(o_pulse_filter_en			),
	.ov_test_image_sel			(ov_test_image_sel			),
	.ov_interrupt_en			(ov_interrupt_en			),
	.iv_interrupt_state			(`TESTCASE.iv_interrupt_state		),
	.ov_interrupt_clear			(ov_interrupt_clear			),
	.ov_wb_offset_x_start		(ov_wb_offset_x_start		),
	.ov_wb_offset_width			(ov_wb_offset_width			),
	.ov_wb_offset_y_start		(ov_wb_offset_y_start		),
	.ov_wb_offset_height		(ov_wb_offset_height		),
	.ov_wb_gain_r				(ov_wb_gain_r				),
	.ov_wb_gain_g				(ov_wb_gain_g				),
	.ov_wb_gain_b				(ov_wb_gain_b				),
	.iv_wb_statis_r				(`TESTCASE.iv_wb_statis_r			),
	.iv_wb_statis_g				(`TESTCASE.iv_wb_statis_g			),
	.iv_wb_statis_b				(`TESTCASE.iv_wb_statis_b			),
	.iv_wb_offset_width			(`TESTCASE.iv_wb_offset_width		),
	.iv_wb_offset_height		(`TESTCASE.iv_wb_offset_height	),
	.ov_grey_offset_x_start		(ov_grey_offset_x_start		),
	.ov_grey_offset_width		(ov_grey_offset_width		),
	.ov_grey_offset_y_start		(ov_grey_offset_y_start		),
	.ov_grey_offset_height		(ov_grey_offset_height		),
	.iv_grey_statis_sum			(`TESTCASE.iv_grey_statis_sum		),
	.iv_grey_offset_width		(`TESTCASE.iv_grey_offset_width	),
	.iv_grey_offset_height		(`TESTCASE.iv_grey_offset_height	),
	.o_chunk_mode_active		(o_chunk_mode_active		),
	.o_chunkid_en_ts			(o_chunkid_en_ts			),
	.o_chunkid_en_fid			(o_chunkid_en_fid			),
	.ov_chunk_size_img			(ov_chunk_size_img			),
	.ov_payload_size_pix		(ov_payload_size_pix		),
	.ov_roi_offset_x			(ov_roi_offset_x			),
	.ov_roi_offset_y			(ov_roi_offset_y			),
	.ov_roi_pic_width			(ov_roi_pic_width			),
	.ov_roi_pic_height			(ov_roi_pic_height			),
	.ov_timestamp_u3			(ov_timestamp_u3			),
	.ov_payload_size_frame_buf	(ov_payload_size_frame_buf	),
	.ov_frame_buffer_depth		(ov_frame_buffer_depth		),
	.o_chunk_mode_active_frame_buf		(o_chunk_mode_active_frame_buf	),
	.i_ddr_init_done					(`TESTCASE.i_ddr_init_done			),
	.i_ddr_error						(`TESTCASE.i_ddr_error				),
	.ov_si_payload_transfer_size		(ov_si_payload_transfer_size	),
	.ov_si_payload_transfer_count		(ov_si_payload_transfer_count	),
	.ov_si_payload_final_transfer1_size	(ov_si_payload_final_transfer1_size	),
	.ov_si_payload_final_transfer2_size	(ov_si_payload_final_transfer2_size	),
	.ov_payload_size_gpif				(ov_payload_size_gpif			),
	.o_chunk_mode_active_gpif			(o_chunk_mode_active_gpif		)
	);



endmodule
