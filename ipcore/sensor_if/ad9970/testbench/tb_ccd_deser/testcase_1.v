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
`include "SHARP_RJ33J3_DEF.v"
`include "deserializer_def.v"

`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module testcase_1 ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	TESTCASE
	//	-------------------------------------------------------------------------------------
	parameter	TESTCASE_NUM			= "testcase_1"			;	//其他模块需要使用字符串
	//	-------------------------------------------------------------------------------------
	//	sensor model parameter
	//	-------------------------------------------------------------------------------------
//	parameter	CCD_SHARP_DATA_WIDTH			= 14						;	//像素数据位宽
	parameter	CCD_SHARP_DATA_WIDTH			= 16						;	//像素数据位宽
	parameter	CCD_SHARP_IMAGE_WIDTH			= 1320						;	//图像宽度
	parameter	CCD_SHARP_IMAGE_HEIGHT			= 976						;	//图像高度
	parameter	CCD_SHARP_BLACK_VFRONT			= 8							;	//场头黑行个数
	parameter	CCD_SHARP_BLACK_VREAR			= 2							;	//场尾黑行个数
	parameter	CCD_SHARP_BLACK_HFRONT			= 12						;	//行头黑像素个数
	parameter	CCD_SHARP_BLACK_HREAR			= 40						;	//行尾黑像素个数
	parameter	CCD_SHARP_DUMMY_VFRONT			= 2							;	//场头哑行个数
	parameter	CCD_SHARP_DUMMY_VREAR			= 0							;	//场尾哑行个数
	parameter	CCD_SHARP_DUMMY_HFRONT			= 4							;	//行头哑像素个数
	parameter	CCD_SHARP_DUMMY_HREAR			= 0							;	//行尾哑像素个数
	parameter	CCD_SHARP_DUMMY_INIT_VALUE		= 16						;	//DUMMY初始值
	parameter	CCD_SHARP_BLACK_INIT_VALUE		= 32						;	//BLACK初始值
	parameter	CCD_SHARP_IMAGE_SOURCE			= "PIX_INC"					;	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC" or "PIX_INC"
	parameter	CCD_SHARP_SOURCE_FILE_PATH		= "source_file/ccd_sharp/"	;	//数据源文件路径

	//	-------------------------------------------------------------------------------------
	//	ad9970 paramter
	//	-------------------------------------------------------------------------------------
	parameter	CLK_UNIT_VENDOR		= "xilinx"		;	//串行时钟器件，"xilinx" "lattice"
	parameter	CLK_FREQ_MHZ		= 45			;	//并行时钟频率


	//	-------------------------------------------------------------------------------------
	//	dut paramter
	//	-------------------------------------------------------------------------------------


	//	-------------------------------------------------------------------------------------
	//	monitor paramter
	//	-------------------------------------------------------------------------------------

	//	-------------------------------------------------------------------------------------
	//	testcase parameter
	//	-------------------------------------------------------------------------------------
	parameter	CLK_PERIOD				= 22.222	;	//时钟频率，45MHz
//	parameter	CLK_PERIOD				= 20.833	;	//时钟频率，48MHz

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	sensor signal
	//	-------------------------------------------------------------------------------------
	wire				ccd_sharp_xv1			;
	wire				ccd_sharp_xv2			;
	wire				ccd_sharp_xv3			;
	wire				ccd_sharp_xv4			;
	wire				ccd_sharp_hl			;
	wire				ccd_sharp_h1			;
	wire				ccd_sharp_h2			;
	wire				ccd_sharp_rs			;

	//	-------------------------------------------------------------------------------------
	//	ad9970 signal
	//	-------------------------------------------------------------------------------------
	wire	[13:0]		iv_pix_data_ad9970	;
	wire				i_hd_ad9970			;
	wire				i_vd_ad9970			;
	wire				cli_ad9970			;


	//	-------------------------------------------------------------------------------------
	//	dut signal
	//	-------------------------------------------------------------------------------------
	reg								clk					= 1'b0	;
	reg								reset				= 1'b0	;
	reg								i_start_acquisit	= 1'b1	;
	reg								i_trigger			= 1'b0	;
	reg								i_triggermode		= 1'b0	;
	reg		[`LINE_WD - 1:0]		iv_href_start		= 'b0	;
	reg		[`LINE_WD - 1:0]		iv_href_end			= 'b0	;
	reg		[`LINE_WD - 1:0]		iv_hd_rising		= 'b0	;
	reg		[`LINE_WD - 1:0]		iv_hd_falling		= 'b0	;
	reg		[`LINE_WD - 1:0]		iv_sub_rising		= 'b0	;
	reg		[`LINE_WD - 1:0]		iv_sub_falling		= 'b0	;
	reg		[`FRAME_WD - 1:0]		iv_vd_rising		= 'b0	;
	reg		[`FRAME_WD - 1:0]		iv_vd_falling		= 'b0	;
	reg		[`EXP_WD - 1:0]			iv_xsg_width		= 'b0	;

	reg								i_ad_parm_valid		= 1'b0	;

	wire							clk_p				;
	wire							clk_n				;
	wire	[`sys_w - 1:0]			iv_data_p			;
	wire	[`sys_w - 1:0]			iv_data_n			;

	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***tb 子模块激励***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	--ref ccd sharp
	//	-------------------------------------------------------------------------------------
	assign	ccd_sharp_xv1	= harness.ov_xv_inv[0]	;
	assign	ccd_sharp_xv2	= harness.ov_xv_inv[1]	;
	assign	ccd_sharp_xv3	= harness.ov_xv_inv[2]	;
	assign	ccd_sharp_xv4	= harness.ov_xv_inv[3]	;
	assign	ccd_sharp_xsg	= harness.o_xsg_inv		;
	assign	ccd_sharp_hl	= driver_ad9970.o_hl	;
	assign	ccd_sharp_h1	= driver_ad9970.o_h1	;
	assign	ccd_sharp_h2	= driver_ad9970.o_h2	;
	assign	ccd_sharp_rs	= driver_ad9970.o_rg	;

	//	-------------------------------------------------------------------------------------
	//	--ref ad9970
	//	-------------------------------------------------------------------------------------
	assign	cli_ad9970			= clk;

	assign	iv_pix_data_ad9970	= driver_ccd_sharp.ov_pix_data[13:0];
//	assign	iv_pix_data_ad9970	= 'b0;
	assign	i_vd_ad9970			= harness.o_vd;
	assign	i_hd_ad9970			= harness.o_hd;


	//	-------------------------------------------------------------------------------------
	//	--ref Sensor
	//	-------------------------------------------------------------------------------------
	always	#(CLK_PERIOD/2.0)	clk	= !clk;

	//	-------------------------------------------------------------------------------------
	//	--ref DUT
	//	-------------------------------------------------------------------------------------
	assign #1.5	clk_p				= driver_ad9970.o_tckp;
	assign #1.5	clk_n				= driver_ad9970.o_tckn;

//	assign 	clk_p				= driver_ad9970.o_tckp;
//	assign 	clk_n				= driver_ad9970.o_tckn;

	assign	iv_data_p[0]		= driver_ad9970.o_dout0p;
	assign	iv_data_n[0]		= driver_ad9970.o_dout0n;
	assign	iv_data_p[1]		= driver_ad9970.o_dout1p;
	assign	iv_data_n[1]		= driver_ad9970.o_dout1n;

	//	-------------------------------------------------------------------------------------
	//	--ref 仿真时间
	//	-------------------------------------------------------------------------------------
	initial begin
		#200
		//		repeat(20) @ (negedge harness.o_fval);
		//		repeat(30) @ (negedge driver_mt9p031.o_fval);
		#20000
		#600000
		$stop;
	end

	//	===============================================================================================
	//	ref ***调用bfm task***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	复位
	//	-------------------------------------------------------------------------------------
	initial begin
		reset 			= 1;
		#4000
		#200 reset 		= 0;
	end

	//	-------------------------------------------------------------------------------------
	//	配置ccd参数
	//	-------------------------------------------------------------------------------------
	//	-------------------------------------------------------------------------------------
	//	固定位置
	//	-------------------------------------------------------------------------------------
	initial begin
		iv_hd_rising			= `HD_RISING	;
		iv_hd_falling			= `HD_FALLING	;
		iv_vd_rising			= `VD_RISING	;
		iv_vd_falling			= `VD_FALLING	;
		iv_sub_rising			= `SUB_RISING	;
		iv_sub_falling			= `SUB_FALLING	;
	end

	initial begin
		iv_href_start			= `HREF_START_DEFVALUE		;
		iv_href_end				= `HREF_END_DEFVALUE		;
	end

	//	-------------------------------------------------------------------------------------
	//	配置ccd曝光时间
	//	-------------------------------------------------------------------------------------
	initial begin
		iv_xsg_width			= `XSG_WIDTH	;
	end


	initial begin
//		harness.bfm_ccd.readout_reg_cfg(0,0,1320,976);
//		harness.bfm_ccd.readout_reg_cfg(-12,-6,1372,984);
		harness.bfm_ccd.readout_reg_cfg(0,0,1292,964);
//		harness.bfm_ccd.readout_reg_cfg(-12,0,1372,4);
//		harness.bfm_ccd.exp_time_us(40);
//		harness.bfm_ccd.exp_time_us(50);
//		harness.bfm_ccd.exp_time_us(100);
		harness.bfm_ccd.exp_time_us(90);
	end


	initial begin
		i_start_acquisit		= 1'b0	;
		#10000
		i_start_acquisit		= 1'b1	;
	end

	//	-------------------------------------------------------------------------------------
	//	ad9970 bfm
	//	-------------------------------------------------------------------------------------
	initial begin
//		driver_ad9970.bfm_ad9970.sync_start_loc(13'h98);
		driver_ad9970.bfm_ad9970.sync_start_loc(13'd124);
		driver_ad9970.bfm_ad9970.sync_word(16'h8421,16'h8421,16'h8421,16'h8421,16'h8421,16'h8421,16'h8421);
		driver_ad9970.bfm_ad9970.sync_align_right;
		driver_ad9970.bfm_ad9970.hblk_tog1(0);
		driver_ad9970.bfm_ad9970.hblk_tog2(137);
	end


endmodule
