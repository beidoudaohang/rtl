//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : testcase_8
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
//  -- 模块描述     : fval从小到大 最小是3
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

module testcase_8 ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	TESTCASE
	//	-------------------------------------------------------------------------------------
	parameter	TESTCASE_NUM			= "testcase_8"			;	//其他模块需要使用字符串
	//	-------------------------------------------------------------------------------------
	//	sensor model parameter
	//	-------------------------------------------------------------------------------------
	parameter	IMAGE_SRC				= "RANDOM"				;	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC"
	parameter	DATA_WIDTH				= 10					;	//8 10 12 max is 16
	parameter	CHANNEL_NUM				= 1						;	//8 10 12 max is 16
	parameter	SENSOR_CLK_DELAY_VALUE	= 3						;	//Sensor 芯片内部延时 单位ns
	parameter	CLK_DATA_ALIGN			= "RISING"				;	//"RISING" - 输出时钟的上升沿与数据对齐。"FALLING" - 输出时钟的下降沿与数据对齐
	parameter	FVAL_LVAL_ALIGN			= "TRUE"				;	//"TRUE" - fval 与 lval 之间的距离固定为3个时钟。"FALSE" - fval 与 lval 之间的距离自由设定
	parameter	SOURCE_FILE_PATH		= "file/source_file/"	;	//数据源文件路径
	parameter	GEN_FILE_EN				= 0						;	//0-生成的图像不写入文件，1-生成的图像写入文件
	parameter	GEN_FILE_PATH			= "file/gen_file/"		;	//产生的数据要写入的路径
	parameter	NOISE_EN				= 0						;	//0-不加入噪声，1-加入噪声

	//	-------------------------------------------------------------------------------------
	//	dut paramter
	//	-------------------------------------------------------------------------------------
	parameter	REG_WD					= 32	;	//寄存器位宽

	//	-------------------------------------------------------------------------------------
	//	monitor paramter
	//	-------------------------------------------------------------------------------------
	parameter	MONITOR_OUTPUT_FILE_EN			= 0						;	//是否产生输出文件
	parameter	MONITOR_OUTPUT_FILE_PATH		= "file/sync_buffer_file/"	;	//产生的数据要写入的路径
	parameter	CHK_INOUT_DATA_STOP_ON_ERROR	= 0						;
	parameter	CHK_PULSE_WIDTH_STOP_ON_ERROR	= 0						;

	//	-------------------------------------------------------------------------------------
	//	testcase parameter
	//	-------------------------------------------------------------------------------------
	parameter	CLK_PERIOD				= 10	;	//时钟频率，100MHz

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	sensor signal
	//	-------------------------------------------------------------------------------------
	reg					clk_mt9p031		= 1'b0;
	wire				o_fval_mt9p031	;

	//	-------------------------------------------------------------------------------------
	//	dut signal
	//	-------------------------------------------------------------------------------------
	wire								o_fval_sensor	;
	wire								clk_pix_sensor	;

	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***tb 子模块激励***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	--ref Sensor
	//	-------------------------------------------------------------------------------------
	always	#(CLK_PERIOD/2.0)	clk_mt9p031	= !clk_mt9p031;

	initial begin
		driver_mt9p031.bfm_mt9p031.reset_high();
		#200;
		driver_mt9p031.bfm_mt9p031.reset_low();
	end

//	assign	o_fval_mt9p031	= harness.o_fval;
	assign	o_fval_mt9p031	= driver_mt9p031.o_fval;

	//	-------------------------------------------------------------------------------------
	//	--ref DUT
	//	-------------------------------------------------------------------------------------
	assign	o_fval_sensor			= driver_mt9p031.o_fval;
	assign	clk_pix_sensor			= driver_mt9p031.clk_sensor_pix;

	//	-------------------------------------------------------------------------------------
	//	--ref 仿真时间
	//	-------------------------------------------------------------------------------------
	initial begin
		#200
		//		repeat(20) @ (negedge harness.o_fval);
		repeat(30) @ (negedge driver_mt9p031.o_fval);
		#200
		$stop;
	end

	//	===============================================================================================
	//	ref ***调用bfm task***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	--ref sensor pattern
	//	-------------------------------------------------------------------------------------
	//	initial begin
	//		forever begin
	//			driver_mt9p031.bfm_mt9p031.pattern_random(16,400);
	//		end
	//	end

	initial begin
		driver_mt9p031.bfm_mt9p031.pattern_2para(64,64);
	end

	//	-------------------------------------------------------------------------------------
	//	--ref 开停采
	//	-------------------------------------------------------------------------------------
	initial begin
		harness.bfm_se_acq.acq_high();
		harness.bfm_se_acq.se_high();
		harness.bfm_reg_common.encrypt_high();
		forever begin
			harness.bfm_se_acq.se_at_fval_stop_start(50,150);
		end
	end


endmodule
