//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : testcase_1
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/30 15:23:39	:|  初始版本
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
//`timescale 1ns/1ps
`timescale 1ns/1ns
//-------------------------------------------------------------------------------------------------

module testcase_1 ();

	//	ref signals

	//	-------------------------------------------------------------------------------------
	//	TESTCASE
	//	-------------------------------------------------------------------------------------
	parameter	TESTCASE_NUM			= "testcase_1"			;	//其他模块需要使用字符串

	//	-------------------------------------------------------------------------------------
	//	sensor model parameter
	//	-------------------------------------------------------------------------------------
	parameter	IMAGE_SRC				= "RANDOM"				;	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC"
	parameter	DATA_WIDTH				= 32					;	//8 10 12 max is 16
	parameter	SENSOR_CLK_DELAY_VALUE	= 3						;	//Sensor 芯片内部延时 单位ns
	parameter	CLK_DATA_ALIGN			= "RISING"				;	//"RISING" - 输出时钟的上升沿与数据对齐。"FALLING" - 输出时钟的下降沿与数据对齐
	parameter	DSP_IMPLEMENT			= "FLALSE"				;	//"TRUE" - 布线模式，使用乘法器。"FALSE" - 仿真模式，不使能乘法器。
	parameter	FVAL_LVAL_ALIGN			= "FALSE"				;	//"TRUE" - fval 与 lval 之间的距离固定为3个时钟。"FALSE" - fval 与 lval 之间的距离自由设定
	parameter	SOURCE_FILE_PATH		= "file/source_file/"	;	//数据源文件路径
	parameter	GEN_FILE_EN				= 1						;	//0-生成的图像不写入文件，1-生成的图像写入文件
	parameter	GEN_FILE_PATH			= "file/gen_file/"		;	//产生的数据要写入的路径
	parameter	NOISE_EN				= 0						;	//0-不加入噪声，1-加入噪声

	//	-------------------------------------------------------------------------------------
	//	clock reset parameter
	//	-------------------------------------------------------------------------------------
	parameter		DDR3_MEMCLK_FREQ	= 320					;	//Memory data transfer clock frequency DDR3-640:3125 DDR3-660:3030 DDR3-720:2778 DDR3-800:2500

	//	-------------------------------------------------------------------------------------
	//	dut paramter
	//	-------------------------------------------------------------------------------------
	parameter		NUM_DQ_PINS			= 16					;	//External memory data width
	parameter		MEM_BANKADDR_WIDTH	= 3						;	//External memory bank address width
	parameter		MEM_ADDR_WIDTH		= 13					;	//External memory address width.
	//	parameter		DDR3_MEMCLK_FREQ	= 320					;	//Memory data transfer clock frequency DDR3-640:3125 DDR3-660:3030 DDR3-720:2778 DDR3-800:2500
	parameter		MEM_ADDR_ORDER		= "ROW_BANK_COLUMN"		;	//"ROW_BANK_COLUMN" or "BANK_ROW_COLUMN"
	parameter		SKIP_IN_TERM_CAL	= 1						;	//1-calib input term 0-not calib input term.1 will decrease power consumption
	parameter		DDR3_MEM_DENSITY	= "1Gb"					;	//DDR3 容量 "1Gb" "512Mb"
	parameter		DDR3_TCK_SPEED		= "15E"					;	//DDR3 speed "187E" "15E" "125"
	parameter		DDR3_SIMULATION		= "TRUE"				;	//仿真模式，加速MCB仿真速度
	parameter		DDR3_CALIB_SOFT_IP	= "FALSE"				;	//使能calibration模块
	//	parameter		DATA_WIDTH			= 32					;	//数据宽度
	parameter		PTR_WIDTH			= 2						;	//读写指针的位宽，1-最大2帧 2-最大4帧 3-最大8帧 4-最大16帧 5-最大32帧
	parameter		FRAME_SIZE_WIDTH	= 25					;	//一帧大小位宽，当DDR3是1Gbit时，最大容量是128Mbyte，当mcb p3 口位宽是32时，25位宽的size计数器就足够了
	parameter		TERRIBLE_TRAFFIC	= "FALSE"				;	//读写最差的情况，TRUE-同时读写不同帧的同一地址，FALSE-同时读写同一帧的同一地址
	parameter		DDR3_16_DQ_MCB_8_DQ	= 0						;	//DDR3是16bit，但是MCB却是8bit

	//	-------------------------------------------------------------------------------------
	//	monitor paramter
	//	-------------------------------------------------------------------------------------
	parameter		MONITOR_OUTPUT_FILE_EN			= 0					;	//是否产生输出文件
	parameter		MONITOR_OUTPUT_FILE_PATH		= "file/frame_buffer_file/"		;	//产生的数据要写入的路径
	parameter		CHK_INOUT_DATA_STOP_ON_ERROR	= 0						;
	parameter		CHK_PULSE_WIDTH_STOP_ON_ERROR	= 0						;

	//	-------------------------------------------------------------------------------------
	//	testcase parameter
	//	-------------------------------------------------------------------------------------
	parameter		CLK_PERIOD		= 25	;	//时钟频率，40MHz

	//	-------------------------------------------------------------------------------------
	//	reg wire
	//	-------------------------------------------------------------------------------------
	reg									clk_osc					= 1'b0	;
	wire								clk_mt9p031				;
	wire								o_fval_mt9p031				;
	wire								i_fval					;
	wire								i_lval					;
	wire	[DATA_WIDTH-1:0]			iv_image_din			;
	wire								clk_front				;
	wire								clk_back				;
	wire								clk_frame_buf			;
	wire								reset_frame_buf			;
	wire								async_rst				;
	wire								sysclk_2x				;
	wire								sysclk_2x_180			;
	wire								pll_ce_0				;
	wire								pll_ce_90				;
	wire								mcb_drp_clk				;
	wire								bufpll_mcb_lock			;
	
	//	ref ARCHITECTURE
	//	===============================================================================================
	//	ref ***tb 子模块激励***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	--ref 时钟复位
	//	-------------------------------------------------------------------------------------
	always	#(CLK_PERIOD/2.0)	clk_osc	= !clk_osc;

	//	-------------------------------------------------------------------------------------
	//	--ref Sensor
	//	-------------------------------------------------------------------------------------
	assign	clk_mt9p031		= driver_clock_reset.clk_pix;
	assign	o_fval_mt9p031	= driver_mt9p031.o_fval;
	
	//	-------------------------------------------------------------------------------------
	//	--ref dut
	//	-------------------------------------------------------------------------------------
	assign	i_fval			= driver_mt9p031.o_fval;
	assign	i_lval			= driver_mt9p031.o_lval;
	assign	iv_image_din	= driver_mt9p031.ov_pix_data	;
	assign	clk_front		= driver_clock_reset.clk_pix	;
	assign	clk_back		= driver_clock_reset.clk_gpif	;
	assign	clk_frame_buf	= driver_clock_reset.clk_frame_buf		;
	assign	reset_frame_buf = driver_clock_reset.reset_frame_buf   ;
	assign	async_rst       = driver_clock_reset.async_rst         ;
	assign	sysclk_2x       = driver_clock_reset.sysclk_2x         ;
	assign	sysclk_2x_180   = driver_clock_reset.sysclk_2x_180     ;
	assign	pll_ce_0        = driver_clock_reset.pll_ce_0          ;
	assign	pll_ce_90       = driver_clock_reset.pll_ce_90         ;
	assign	mcb_drp_clk     = driver_clock_reset.mcb_drp_clk       ;
	assign	bufpll_mcb_lock = driver_clock_reset.bufpll_mcb_lock   ;


	//	-------------------------------------------------------------------------------------
	//	--ref 仿真时间
	//	-------------------------------------------------------------------------------------
	initial begin
		#200
		repeat(6) @ (posedge harness.ov_image_dout[32]);
		#200
		$stop;
	end


	//	===============================================================================================
	//	ref ***调用bfm task***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	--ref sensor bfm
	//	-------------------------------------------------------------------------------------
	initial begin
		#200;
		driver_mt9p031.bfm_mt9p031.reset_high();
		#200;
		wait(harness.o_calib_done==1'b1);
		#200;
		driver_mt9p031.bfm_mt9p031.reset_low();
	end

	//	-------------------------------------------------------------------------------------
	//	sensor pattern
	//	-------------------------------------------------------------------------------------
	initial begin
		driver_mt9p031.bfm_mt9p031.pattern_2para(16,16);
	end

	//	-------------------------------------------------------------------------------------
	//	--ref dut bfm
	//	-------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	帧存深度
	//  -------------------------------------------------------------------------------------
	initial begin
		harness.bfm.frame_depth(2);
	end

	initial begin
		//		bfm.sti_se_start_fval();
		harness.bfm.se_low_high();
	end




endmodule
