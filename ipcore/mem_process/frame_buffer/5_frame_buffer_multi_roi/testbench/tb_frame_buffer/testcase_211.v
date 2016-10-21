//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : testcase_211
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/4/10 16:50:28	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 窗口大小是16x16，开采信号有效，正常模式下的运行状况
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

module testcase_211 ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	TESTCASE
	//	-------------------------------------------------------------------------------------
	parameter	TESTCASE_NUM			= "testcase_211"			;	//其他模块需要使用字符串
	//	-------------------------------------------------------------------------------------
	//	sensor model parameter
	//	-------------------------------------------------------------------------------------
	parameter	IMAGE_SRC				= "LINE_INC"				;	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC" or "FRAME_INC_NO_RST" or "PIX_INC_NO_FVAL" or "PIX_INC"
	parameter	DATA_WIDTH				= 64					;	//8 10 12 max is 16
	parameter	SENSOR_CLK_DELAY_VALUE	= 0						;	//Sensor 芯片内部延时 单位ns
	parameter	CLK_DATA_ALIGN			= "RISING"				;	//"RISING" - 输出时钟的上升沿与数据对齐。"FALLING" - 输出时钟的下降沿与数据对齐
	parameter	DSP_IMPLEMENT			= "FALSE"				;	//"TRUE" - 布线模式，使用乘法器。"FALSE" - 仿真模式，不使能乘法器。
	parameter	FVAL_LVAL_ALIGN			= "FALSE"				;	//"TRUE" - fval 与 lval 之间的距离固定为3个时钟。"FALSE" - fval 与 lval 之间的距离自由设定
	parameter	SOURCE_FILE_PATH		= "file/source_file/"	;	//数据源文件路径
	parameter	GEN_FILE_EN				= 1						;	//0-生成的图像不写入文件，1-生成的图像写入文件
	parameter	GEN_FILE_PATH			= "file/gen_file/"		;	//产生的数据要写入的路径
	parameter	NOISE_EN				= 0						;	//0-不加入噪声，1-加入噪声

	//	-------------------------------------------------------------------------------------
	//	clock_reset
	//	-------------------------------------------------------------------------------------
	parameter	DDR3_MEMCLK_FREQ	= 320	;	//Memory data transfer clock frequency DDR3-640:3125 DDR3-660:3030 DDR3-720:2778 DDR3-800:2500

	//	-------------------------------------------------------------------------------------
	//	u3v_format
	//	-------------------------------------------------------------------------------------
	parameter	PIX_CLK_FREQ_KHZ			= 65000				;	//像素时钟的频率，以khz为单位
	parameter	FVAL_TS_STABLE_NS			= 95				;	//从fval发出到稳定接收时间戳的时间
	parameter	DATA_WD						= 64				;	//输入输出数据位宽，这里使用同一宽度
	parameter	SHORT_REG_WD 				= 16				;	//短寄存器位宽
	parameter	REG_WD 						= 32				;	//寄存器位宽
	parameter	LONG_REG_WD 				= 64				;	//长寄存器位宽
	parameter	MROI_MAX_NUM 				= 8					;	//Multi-ROI的最大个数,最大支持2^8

	//	-------------------------------------------------------------------------------------
	//	dut paramter
	//	-------------------------------------------------------------------------------------
	parameter	NUM_DQ_PINS					= 16	;
	parameter	MEM_BANKADDR_WIDTH			= 3	;
	parameter	MEM_ADDR_WIDTH				= 13	;
	//	parameter	DDR3_MEMCLK_FREQ			= 320	;
	parameter	MEM_ADDR_ORDER				= "ROW_BANK_COLUMN"	;
	parameter	SKIP_IN_TERM_CAL			= 1	;
	parameter	DDR3_MEM_DENSITY			= "1Gb"	;
	parameter	DDR3_TCK_SPEED				= "15E"	;
	parameter	DDR3_SIMULATION				= "TRUE"	;
	parameter	DDR3_CALIB_SOFT_IP			= "TRUE"	;
	//	parameter	DATA_WD						= 64	;
	parameter	GPIF_DATA_WD				= 32	;
	//	parameter	SHORT_REG_WD				= 16	;
	//	parameter	REG_WD						= 32	;
	//	parameter	MROI_MAX_NUM				= 8	;
	parameter	SENSOR_MAX_WIDTH			= 4912	;
	parameter	SENSOR_ALL_PIX_DIV4			= 4523952	;
	parameter	PTR_WIDTH					= 2	;


	parameter	FB_FILE_PATH			= "file/fb_file/"		;	//产生的数据要写入的路径
	parameter	FB_LEADER_FILE_PATH		= "file/fb_leader_file/"		;	//产生的数据要写入的路径
	parameter	FB_TRAILER_FILE_PATH	= "file/fb_trailer_file/"		;	//产生的数据要写入的路径

	//	-------------------------------------------------------------------------------------
	//	monitor paramter
	//	-------------------------------------------------------------------------------------
	//	parameter	MONITOR_OUTPUT_FILE_EN			= 0						;	//是否产生输出文件
	//	parameter	MONITOR_OUTPUT_FILE_PATH		= "file/sync_buffer_file/"	;	//产生的数据要写入的路径
	//	parameter	CHK_INOUT_DATA_STOP_ON_ERROR	= 0						;
	//	parameter	CHK_PULSE_WIDTH_STOP_ON_ERROR	= 0						;

	//	-------------------------------------------------------------------------------------
	//	testcase parameter
	//	-------------------------------------------------------------------------------------
	parameter	CLK_PERIOD				= 25	;	//时钟频率，40MHz
	parameter	CLK_PERIOD_FB			= 10	;	//时钟频率，100MHz
	parameter	CLK_PERIOD_GPIF			= 10	;	//时钟频率，100MHz
	parameter	CLK_PERIOD_SENSOR		= 8.3	;	//时钟频率，120MHz

	//	-------------------------------------------------------------------------------------
	//	function declare
	//	-------------------------------------------------------------------------------------
	function [31:0] max_num;
		input [31:0]	iv_roi0_payload_size;
		input [31:0]	iv_roi1_payload_size;
		input [31:0]	iv_roi2_payload_size;
		input [31:0]	iv_roi3_payload_size;
		input [31:0]	iv_roi4_payload_size;
		input [31:0]	iv_roi5_payload_size;
		input [31:0]	iv_roi6_payload_size;
		input [31:0]	iv_roi7_payload_size;
		begin
			if(
			iv_roi0_payload_size>=iv_roi1_payload_size &&
			iv_roi0_payload_size>=iv_roi2_payload_size &&
			iv_roi0_payload_size>=iv_roi3_payload_size &&
			iv_roi0_payload_size>=iv_roi4_payload_size &&
			iv_roi0_payload_size>=iv_roi5_payload_size &&
			iv_roi0_payload_size>=iv_roi6_payload_size &&
			iv_roi0_payload_size>=iv_roi7_payload_size
			) begin
				max_num	= iv_roi0_payload_size;
			end

			else if(
			iv_roi1_payload_size>=iv_roi0_payload_size &&
			iv_roi1_payload_size>=iv_roi2_payload_size &&
			iv_roi1_payload_size>=iv_roi3_payload_size &&
			iv_roi1_payload_size>=iv_roi4_payload_size &&
			iv_roi1_payload_size>=iv_roi5_payload_size &&
			iv_roi1_payload_size>=iv_roi6_payload_size &&
			iv_roi1_payload_size>=iv_roi7_payload_size
			) begin
				max_num	= iv_roi1_payload_size;
			end

			else if(
			iv_roi2_payload_size>=iv_roi0_payload_size &&
			iv_roi2_payload_size>=iv_roi1_payload_size &&
			iv_roi2_payload_size>=iv_roi3_payload_size &&
			iv_roi2_payload_size>=iv_roi4_payload_size &&
			iv_roi2_payload_size>=iv_roi5_payload_size &&
			iv_roi2_payload_size>=iv_roi6_payload_size &&
			iv_roi2_payload_size>=iv_roi7_payload_size
			) begin
				max_num	= iv_roi2_payload_size;
			end

			else if(
			iv_roi3_payload_size>=iv_roi0_payload_size &&
			iv_roi3_payload_size>=iv_roi1_payload_size &&
			iv_roi3_payload_size>=iv_roi2_payload_size &&
			iv_roi3_payload_size>=iv_roi4_payload_size &&
			iv_roi3_payload_size>=iv_roi5_payload_size &&
			iv_roi3_payload_size>=iv_roi6_payload_size &&
			iv_roi3_payload_size>=iv_roi7_payload_size
			) begin
				max_num	= iv_roi3_payload_size;
			end

			else if(
			iv_roi4_payload_size>=iv_roi0_payload_size &&
			iv_roi4_payload_size>=iv_roi1_payload_size &&
			iv_roi4_payload_size>=iv_roi2_payload_size &&
			iv_roi4_payload_size>=iv_roi3_payload_size &&
			iv_roi4_payload_size>=iv_roi5_payload_size &&
			iv_roi4_payload_size>=iv_roi6_payload_size &&
			iv_roi4_payload_size>=iv_roi7_payload_size
			) begin
				max_num	= iv_roi4_payload_size;
			end

			else if(
			iv_roi5_payload_size>=iv_roi0_payload_size &&
			iv_roi5_payload_size>=iv_roi1_payload_size &&
			iv_roi5_payload_size>=iv_roi2_payload_size &&
			iv_roi5_payload_size>=iv_roi3_payload_size &&
			iv_roi5_payload_size>=iv_roi4_payload_size &&
			iv_roi5_payload_size>=iv_roi6_payload_size &&
			iv_roi5_payload_size>=iv_roi7_payload_size
			) begin
				max_num	= iv_roi5_payload_size;
			end

			else if(
			iv_roi6_payload_size>=iv_roi0_payload_size &&
			iv_roi6_payload_size>=iv_roi1_payload_size &&
			iv_roi6_payload_size>=iv_roi2_payload_size &&
			iv_roi6_payload_size>=iv_roi3_payload_size &&
			iv_roi6_payload_size>=iv_roi4_payload_size &&
			iv_roi6_payload_size>=iv_roi5_payload_size &&
			iv_roi6_payload_size>=iv_roi7_payload_size
			) begin
				max_num	= iv_roi6_payload_size;
			end

			else if(
			iv_roi7_payload_size>=iv_roi0_payload_size &&
			iv_roi7_payload_size>=iv_roi1_payload_size &&
			iv_roi7_payload_size>=iv_roi2_payload_size &&
			iv_roi7_payload_size>=iv_roi3_payload_size &&
			iv_roi7_payload_size>=iv_roi4_payload_size &&
			iv_roi7_payload_size>=iv_roi5_payload_size &&
			iv_roi7_payload_size>=iv_roi6_payload_size
			) begin
				max_num	= iv_roi7_payload_size;
			end
		end
	endfunction

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	testbench
	//	-------------------------------------------------------------------------------------
	reg									clk_frame_buf	= 1'b0;
	reg									clk_gpif		= 1'b0;
	reg									clk_sensor		= 1'b0;

	//	-------------------------------------------------------------------------------------
	//	mt9p031
	//	-------------------------------------------------------------------------------------
	wire								clk_mt9p031	;
	wire								o_fval_mt9p031	;

	//	-------------------------------------------------------------------------------------
	//	clock_reset
	//	-------------------------------------------------------------------------------------
	reg									clk_osc			= 1'b0;

	//	-------------------------------------------------------------------------------------
	//	u3v_format
	//	-------------------------------------------------------------------------------------
	wire								clk_u3v							;
	wire								reset_u3v						;
	wire								i_fval_u3v						;
	wire								i_data_valid_u3v				;
	wire	[DATA_WD-1:0]				iv_data_u3v						;
	wire	[LONG_REG_WD-1:0]			iv_timestamp_u3v				;

	reg									i_stream_enable				= 1'b0;
	reg									i_acquisition_start			= 1'b0;
	reg		[REG_WD-1:0]				iv_pixel_format				= 'b0;


	//	-------------------------------------------------------------------------------------
	//	dut signal
	//	-------------------------------------------------------------------------------------
	wire								clk_in						;
	wire								i_fval						;
	wire								i_dval						;
	wire								i_leader_flag				;
	wire								i_trailer_flag				;
	wire								i_chunk_flag				;
	wire								i_image_flag				;
	wire								i_trailer_final_flag		;
	wire	[DATA_WD-1:0]				iv_din						;

	wire								clk_out						;
	wire								reset_frame_buf				;
	reg		[SHORT_REG_WD-1:0]			iv_frame_depth				= 'b0;

	wire								i_async_rst					;
	wire								i_sysclk_2x					;
	wire								i_sysclk_2x_180				;
	wire								i_pll_ce_0					;
	wire								i_pll_ce_90					;
	wire								i_mcb_drp_clk				;
	wire								i_bufpll_mcb_lock			;



	//	ref ARCHITECTURE
	//	===============================================================================================
	//	ref ***tb***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	--ref clock
	//	-------------------------------------------------------------------------------------
	always	#(CLK_PERIOD_FB/2.0)		clk_frame_buf	= !clk_frame_buf;
	always	#(CLK_PERIOD_GPIF/2.0)		clk_gpif		= !clk_gpif;
	always	#(CLK_PERIOD_SENSOR/2.0)	clk_sensor		= !clk_sensor;

	//	-------------------------------------------------------------------------------------
	//	--ref clock reset
	//	-------------------------------------------------------------------------------------
	always	#(CLK_PERIOD/2.0)			clk_osc			= !clk_osc;

	//	-------------------------------------------------------------------------------------
	//	--ref Sensor
	//	-------------------------------------------------------------------------------------
	assign	clk_mt9p031		= clk_sensor;
	assign	o_fval_mt9p031	= driver_mt9p031.o_fval;

	//	-------------------------------------------------------------------------------------
	//	--ref u3v_format
	//	-------------------------------------------------------------------------------------
	assign	clk_u3v				= clk_sensor;
	assign	reset_u3v			= 1'b0;
	assign	i_fval_u3v			= driver_mt9p031.o_fval;
	assign	i_data_valid_u3v	= driver_mt9p031.o_lval;
	assign	iv_data_u3v			= driver_mt9p031.ov_pix_data;
	assign	iv_timestamp_u3v	= 'b0;




	//	-------------------------------------------------------------------------------------
	//	--ref DUT
	//	-------------------------------------------------------------------------------------
	assign	clk_in					= clk_sensor;
	assign	i_fval					= driver_u3v_format.o_fval;
	assign	i_dval					= driver_u3v_format.o_data_valid;
	assign	i_leader_flag			= driver_u3v_format.o_leader_flag;
	assign	i_trailer_flag			= driver_u3v_format.o_trailer_flag;
	assign	i_chunk_flag			= driver_u3v_format.o_chunk_flag;
	assign	i_image_flag			= driver_u3v_format.o_image_flag;
	assign	i_trailer_final_flag	= driver_u3v_format.o_trailer_final_flag;
	assign	iv_din					= driver_u3v_format.ov_data;

	assign	clk_out					= clk_gpif;
	assign	reset_frame_buf			= 1'b0;

	assign	i_async_rst				= driver_clock_reset.async_rst;
	assign	i_sysclk_2x				= driver_clock_reset.sysclk_2x;
	assign	i_sysclk_2x_180         = driver_clock_reset.sysclk_2x_180;
	assign	i_pll_ce_0              = driver_clock_reset.pll_ce_0;
	assign	i_pll_ce_90             = driver_clock_reset.pll_ce_90;
	assign	i_mcb_drp_clk           = driver_clock_reset.mcb_drp_clk;
	assign	i_bufpll_mcb_lock       = driver_clock_reset.bufpll_mcb_lock;


	//	===============================================================================================
	//	ref ***config parameter***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	sensor 图像尺寸
	//	-------------------------------------------------------------------------------------
	wire	[15:0]			senor_active_width	;
	wire	[15:0]			senor_blank_width	;
	wire	[15:0]			senor_active_height	;
	wire	[15:0]			senor_blank_height	;



//	assign	senor_active_width		= 16'd1280	;
//	assign	senor_blank_width		= 16'd2000	;
//	assign	senor_active_height		= 16'd8		;
//	assign	senor_blank_height		= 16'd6		;

	assign	senor_active_width		= 16'd64	;
	assign	senor_blank_width		= 16'd2000	;
	assign	senor_active_height		= 16'd64	;
	assign	senor_blank_height		= 16'd6		;

	wire	[1:0]			pixel_byte	;
	wire	[7:0]			leader_size	;
	wire	[7:0]			trailer_size	;
	wire					i_chunk_mode_active	;
	wire					i_chunkid_en_ts	;
	wire					i_chunkid_en_fid	;

	wire	[7:0]			chunk_size_1	;
	wire	[7:0]			chunk_size_2	;
	wire	[7:0]			chunk_size_3	;
	wire	[7:0]			chunk_size_all	;
	wire	[31:0]			iv_chunk_size_img	;

	assign	pixel_byte				= 1;
	assign	i_chunk_mode_active		= 0;
	assign	i_chunkid_en_ts			= 0;
	assign	i_chunkid_en_fid		= 0;


	assign	leader_size				= 52;
	assign	trailer_size			= (i_chunk_mode_active==1) ? 36 : 32;

	assign	chunk_size_1			= (i_chunk_mode_active==1) ? 8 : 0;
	assign	chunk_size_2			= (i_chunk_mode_active==1 && i_chunkid_en_ts==1'b1) ? 16 : 0;
	assign	chunk_size_3			= (i_chunk_mode_active==1 && i_chunkid_en_fid==1'b1) ? 16 : 0;
	assign	chunk_size_all			= chunk_size_1+chunk_size_2+chunk_size_3;

	assign	iv_chunk_size_img		= senor_active_width*senor_active_height*pixel_byte;

	//	-------------------------------------------------------------------------------------
	//	多roi的设置
	//	-------------------------------------------------------------------------------------
	wire					i_multi_roi_global_en	;
	wire	[15:0]			iv_multi_roi_single_en	;
	assign	i_multi_roi_global_en	= 1;
	assign	iv_multi_roi_single_en	= 16'b11;

	wire	[SHORT_REG_WD-1:0]		iv_roi_pic_width		;
//	assign	iv_roi_pic_width		= 16'b0;
	assign	iv_roi_pic_width		= (i_multi_roi_global_en==1'b1) ? senor_active_height : 16'b0;

	//	-------------------------------------------------------------------------------------
	//	roi0
	//	-------------------------------------------------------------------------------------

	wire	[SHORT_REG_WD-1:0]			roi0_offset_x	;
	wire	[SHORT_REG_WD-1:0]			roi0_offset_y	;
	wire	[SHORT_REG_WD-1:0]			roi0_pic_width	;
	wire	[SHORT_REG_WD-1:0]			roi0_pic_height	;
	wire	[REG_WD-1:0]				roi0_chunk_size_img	;
	wire	[REG_WD-1:0]				roi0_payload_size	;
	wire	[REG_WD-1:0]				roi0_start	;

	wire	[SHORT_REG_WD-1:0]			roi1_offset_x	;
	wire	[SHORT_REG_WD-1:0]			roi1_offset_y	;
	wire	[SHORT_REG_WD-1:0]			roi1_pic_width	;
	wire	[SHORT_REG_WD-1:0]			roi1_pic_height	;
	wire	[REG_WD-1:0]				roi1_chunk_size_img	;
	wire	[REG_WD-1:0]				roi1_payload_size	;
	wire	[REG_WD-1:0]				roi1_start	;

	wire	[SHORT_REG_WD-1:0]			roi2_offset_x	;
	wire	[SHORT_REG_WD-1:0]			roi2_offset_y	;
	wire	[SHORT_REG_WD-1:0]			roi2_pic_width	;
	wire	[SHORT_REG_WD-1:0]			roi2_pic_height	;
	wire	[REG_WD-1:0]				roi2_chunk_size_img	;
	wire	[REG_WD-1:0]				roi2_payload_size	;
	wire	[REG_WD-1:0]				roi2_start	;

	wire	[SHORT_REG_WD-1:0]			roi3_offset_x	;
	wire	[SHORT_REG_WD-1:0]			roi3_offset_y	;
	wire	[SHORT_REG_WD-1:0]			roi3_pic_width	;
	wire	[SHORT_REG_WD-1:0]			roi3_pic_height	;
	wire	[REG_WD-1:0]				roi3_chunk_size_img	;
	wire	[REG_WD-1:0]				roi3_payload_size	;
	wire	[REG_WD-1:0]				roi3_start	;

	wire	[SHORT_REG_WD-1:0]			roi4_offset_x	;
	wire	[SHORT_REG_WD-1:0]			roi4_offset_y	;
	wire	[SHORT_REG_WD-1:0]			roi4_pic_width	;
	wire	[SHORT_REG_WD-1:0]			roi4_pic_height	;
	wire	[REG_WD-1:0]				roi4_chunk_size_img	;
	wire	[REG_WD-1:0]				roi4_payload_size	;
	wire	[REG_WD-1:0]				roi4_start	;

	wire	[SHORT_REG_WD-1:0]			roi5_offset_x	;
	wire	[SHORT_REG_WD-1:0]			roi5_offset_y	;
	wire	[SHORT_REG_WD-1:0]			roi5_pic_width	;
	wire	[SHORT_REG_WD-1:0]			roi5_pic_height	;
	wire	[REG_WD-1:0]				roi5_chunk_size_img	;
	wire	[REG_WD-1:0]				roi5_payload_size	;
	wire	[REG_WD-1:0]				roi5_start	;

	wire	[SHORT_REG_WD-1:0]			roi6_offset_x	;
	wire	[SHORT_REG_WD-1:0]			roi6_offset_y	;
	wire	[SHORT_REG_WD-1:0]			roi6_pic_width	;
	wire	[SHORT_REG_WD-1:0]			roi6_pic_height	;
	wire	[REG_WD-1:0]				roi6_chunk_size_img	;
	wire	[REG_WD-1:0]				roi6_payload_size	;
	wire	[REG_WD-1:0]				roi6_start	;

	wire	[SHORT_REG_WD-1:0]			roi7_offset_x	;
	wire	[SHORT_REG_WD-1:0]			roi7_offset_y	;
	wire	[SHORT_REG_WD-1:0]			roi7_pic_width	;
	wire	[SHORT_REG_WD-1:0]			roi7_pic_height	;
	wire	[REG_WD-1:0]				roi7_chunk_size_img	;
	wire	[REG_WD-1:0]				roi7_payload_size	;
	wire	[REG_WD-1:0]				roi7_start	;


//	assign	roi0_offset_x			= 0;
//	assign	roi0_offset_y			= 0;
//	assign	roi0_pic_width			= 1280;
//	assign	roi0_pic_height			= 8;

	assign	roi0_offset_x			= 0;
	assign	roi0_offset_y			= 0;
	assign	roi0_pic_width			= 64;
	assign	roi0_pic_height			= 64;

	assign	roi0_chunk_size_img		= roi0_pic_width*roi0_pic_height*pixel_byte;
	assign	roi0_payload_size		= roi0_chunk_size_img+chunk_size_all;
	assign	roi0_start				= roi0_offset_y*senor_active_width*pixel_byte+roi0_offset_x*pixel_byte;

	//	-------------------------------------------------------------------------------------
	//	roi1
	//	-------------------------------------------------------------------------------------
//	assign	roi1_offset_x			= 0;
//	assign	roi1_offset_y			= 0;
//	assign	roi1_pic_width			= 640;
//	assign	roi1_pic_height			= 4;

	assign	roi1_offset_x			= 0;
	assign	roi1_offset_y			= 0;
	assign	roi1_pic_width			= 32;
	assign	roi1_pic_height			= 32;

	assign	roi1_chunk_size_img		= roi1_pic_width*roi1_pic_height*pixel_byte;
	assign	roi1_payload_size		= roi1_chunk_size_img+chunk_size_all;
	assign	roi1_start				= roi1_offset_y*senor_active_width*pixel_byte+roi1_offset_x*pixel_byte;

	//	-------------------------------------------------------------------------------------
	//	roi2
	//	-------------------------------------------------------------------------------------
	assign	roi2_offset_x			= 640;
	assign	roi2_offset_y			= 0;
	assign	roi2_pic_width			= 640;
	assign	roi2_pic_height			= 8;

	assign	roi2_chunk_size_img		= roi2_pic_width*roi2_pic_height*pixel_byte;
	assign	roi2_payload_size		= roi2_chunk_size_img+chunk_size_all;
	assign	roi2_start				= roi2_offset_y*senor_active_width*pixel_byte+roi2_offset_x*pixel_byte;

	//	-------------------------------------------------------------------------------------
	//	roi3
	//	-------------------------------------------------------------------------------------
	assign	roi3_offset_x			= 640;
	assign	roi3_offset_y			= 0;
	assign	roi3_pic_width			= 640;
	assign	roi3_pic_height			= 8;

	assign	roi3_chunk_size_img		= roi3_pic_width*roi3_pic_height*pixel_byte;
	assign	roi3_payload_size		= roi3_chunk_size_img+chunk_size_all;
	assign	roi3_start				= roi3_offset_y*senor_active_width*pixel_byte+roi3_offset_x*pixel_byte;

	//	-------------------------------------------------------------------------------------
	//	roi4
	//	-------------------------------------------------------------------------------------
	assign	roi4_offset_x			= 640;
	assign	roi4_offset_y			= 0;
	assign	roi4_pic_width			= 640;
	assign	roi4_pic_height			= 8;

	assign	roi4_chunk_size_img		= roi4_pic_width*roi4_pic_height*pixel_byte;
	assign	roi4_payload_size		= roi4_chunk_size_img+chunk_size_all;
	assign	roi4_start				= roi4_offset_y*senor_active_width*pixel_byte+roi4_offset_x*pixel_byte;

	//	-------------------------------------------------------------------------------------
	//	roi5
	//	-------------------------------------------------------------------------------------
	assign	roi5_offset_x			= 640;
	assign	roi5_offset_y			= 0;
	assign	roi5_pic_width			= 640;
	assign	roi5_pic_height			= 8;

	assign	roi5_chunk_size_img		= roi5_pic_width*roi5_pic_height*pixel_byte;
	assign	roi5_payload_size		= roi5_chunk_size_img+chunk_size_all;
	assign	roi5_start				= roi5_offset_y*senor_active_width*pixel_byte+roi5_offset_x*pixel_byte;

	//	-------------------------------------------------------------------------------------
	//	roi6
	//	-------------------------------------------------------------------------------------
	assign	roi6_offset_x			= 640;
	assign	roi6_offset_y			= 0;
	assign	roi6_pic_width			= 640;
	assign	roi6_pic_height			= 8;

	assign	roi6_chunk_size_img		= roi6_pic_width*roi6_pic_height*pixel_byte;
	assign	roi6_payload_size		= roi6_chunk_size_img+chunk_size_all;
	assign	roi6_start				= roi6_offset_y*senor_active_width*pixel_byte+roi6_offset_x*pixel_byte;

	//	-------------------------------------------------------------------------------------
	//	roi7
	//	-------------------------------------------------------------------------------------
	assign	roi7_offset_x			= 640;
	assign	roi7_offset_y			= 0;
	assign	roi7_pic_width			= 640;
	assign	roi7_pic_height			= 8;

	assign	roi7_chunk_size_img		= roi7_pic_width*roi7_pic_height*pixel_byte;
	assign	roi7_payload_size		= roi7_chunk_size_img+chunk_size_all;
	assign	roi7_start				= roi7_offset_y*senor_active_width*pixel_byte+roi7_offset_x*pixel_byte;

	//	-------------------------------------------------------------------------------------
	//	si info
	//	-------------------------------------------------------------------------------------
	wire		[31:0]				max_payload_size;
	assign	max_payload_size		= max_num(roi0_payload_size,roi1_payload_size,roi2_payload_size,roi3_payload_size,roi4_payload_size,roi5_payload_size,roi6_payload_size,roi7_payload_size);

	wire	[31:0]			si_payload_transfer_size	;
	wire	[31:0]			si_payload_transfer_count	;
	wire	[31:0]			si_payload_final_transfer1_size	;
	wire	[31:0]			si_payload_final_transfer2_size	;

	assign	si_payload_transfer_size		= 32'd1048576;		//1Mbyte
	assign	si_payload_transfer_count		= max_payload_size/1048576;
	assign	si_payload_final_transfer1_size	= (max_payload_size-si_payload_transfer_count*1048576)/1024;
	assign	si_payload_final_transfer2_size	= 32'd1024;

	//	-------------------------------------------------------------------------------------
	//	寄存器组合
	//	-------------------------------------------------------------------------------------
	wire	[REG_WD*MROI_MAX_NUM-1:0]				iv_chunk_size_img_mroi	;	//图像长度，以字节为单位，当pixel format为8bit时，一个像素占一个字节，当pixel format 10 bit时，一个像素占用两个字节。
	wire	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_offset_x_mroi		;	//头包中的水平偏移
	wire	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_offset_y_mroi		;	//头包中的垂直便宜
	wire	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_size_x_mroi			;	//头包中的窗口宽度
	wire	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_size_y_mroi			;	//头包中的窗口高度

	wire	[REG_WD*MROI_MAX_NUM-1:0]				iv_start_mroi			;	//起始位置
	wire	[REG_WD*MROI_MAX_NUM-1:0]				iv_payload_size_mroi	;	//包大小




	assign	iv_chunk_size_img_mroi	= {32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,roi1_chunk_size_img,roi0_chunk_size_img};
	assign	iv_offset_x_mroi		= {16'b0,16'b0,16'b0,16'b0,16'b0,16'b0,roi1_offset_x,roi0_offset_x};
	assign	iv_offset_y_mroi		= {16'b0,16'b0,16'b0,16'b0,16'b0,16'b0,roi1_offset_y,roi0_offset_y};

	assign	iv_size_x_mroi		= {16'b0,16'b0,16'b0,16'b0,16'b0,16'b0,roi1_pic_width,roi0_pic_width};
	assign	iv_size_y_mroi		= {16'b0,16'b0,16'b0,16'b0,16'b0,16'b0,roi1_pic_height,roi0_pic_height};

	assign	iv_start_mroi		= {32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,roi1_start,roi0_start};
	assign	iv_payload_size_mroi= {32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,roi1_payload_size,roi0_payload_size};

	//	===============================================================================================
	//	ref ***call bfm task***
	//	===============================================================================================

	//	-------------------------------------------------------------------------------------
	//	--ref register config
	//	-------------------------------------------------------------------------------------
	initial begin
		#200;
		driver_mt9p031.bfm_mt9p031.reset_high();
		//		driver_mt9p031.bfm_mt9p031.pattern_2para(senor_active_width/4,senor_active_height);
		driver_mt9p031.bfm_mt9p031.pattern_5para(senor_active_width/8,senor_blank_width/8,senor_active_height,senor_blank_height,senor_blank_width/8-10);

		i_stream_enable		= 1'b0;
		i_acquisition_start	= 1'b0;
		iv_frame_depth		= 16'd2;

		if(pixel_byte==1) begin
			iv_pixel_format	= 32'h01080001;	//mono8
		end
		else begin
			iv_pixel_format	= 32'h01100003;	//mono10
		end

		#200;
		driver_mt9p031.bfm_mt9p031.reset_low();

		#200

		i_stream_enable		= 1'b1;
		i_acquisition_start	= 1'b1;

	end

	//	-------------------------------------------------------------------------------------
	//	--ref sim time
	//	-------------------------------------------------------------------------------------
	initial begin
		#200
		repeat(2) @ (negedge o_fval_mt9p031);
		//		repeat(30) @ (negedge driver_mt9p031.o_fval);
		#200
		$stop;
	end


endmodule
