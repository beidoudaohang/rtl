//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : ad9970_module
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/7/15 10:48:46	:|  初始版本
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

module ad9970_module # (
	parameter	CLK_UNIT_VENDOR		= "xilinx"	,	//时钟器件，"xilinx" "lattice"
	parameter	CLK_FREQ_MHZ		= 45			//并行时钟频率
	)
	(
	//AD9970输入信号
	input				cli					,	//输入时钟
	input				i_vd				,	//ad9970的VD信号
	input				i_hd				,	//ad9970的HD信号

	//ad9970配置寄存器
	input				i_lvds_pattern_en	,	//lvds测试数使能
	input	[15:0]		iv_lvds_pattern		,	//lvds测试数
	input				i_sync_align_loc	,	//同步字位置，0：右边，1：左边
	input	[12:0]		iv_sync_start_loc	,	//同步字起始位置
	input	[15:0]		iv_sync_word0		,	//Synchronization Word 0 data bits.
	input	[15:0]		iv_sync_word1		,	//Synchronization Word 1 data bits.
	input	[15:0]		iv_sync_word2		,	//Synchronization Word 2 data bits.
	input	[15:0]		iv_sync_word3		,	//Synchronization Word 3 data bits.
	input	[15:0]		iv_sync_word4		,	//Synchronization Word 4 data bits.
	input	[15:0]		iv_sync_word5		,	//Synchronization Word 5 data bits.
	input	[15:0]		iv_sync_word6		,	//Synchronization Word 6 data bits.

	input	[12:0]		iv_hblk_tog1		,	//hblk起点
	input	[12:0]		iv_hblk_tog2		,	//hblk终点
	input				i_hl_mask_pol		,	//hblk有效时，hl的电平
	input				i_h1_mask_pol		,	//hblk有效时，h1的电平
	input				i_h2_mask_pol		,	//hblk有效时，h2的电平

	input	[3:0]		iv_tclk_delay		,	//TCLK rising edge delay,0 = default with no delay,1 LSB = 1/16 cycle of internal TCLK when operating in double port mode,1 LSB = 1/8 cycle of internal TCLK when operating in single port mode
	
	//水平驱动
	output				o_hl				,	//hl水平驱动
	output				o_h1				,	//h1水平驱动
	output				o_h2				,	//h2水平驱动
	output				o_rg				,	//rg水平驱动
	input	[13:0]		iv_pix_data			,	//像素数据
	//lvds端口
	output				o_tckp				,	//差分时钟 p端
	output				o_tckn				,	//差分时钟 n端
	output				o_dout0p			,	//差分数据0 p端
	output				o_dout0n			,	//差分数据0 n端
	output				o_dout1p			,	//差分数据1 p端
	output				o_dout1n				//差分数据1 n端
	);

	//	ref signals
	wire				clk				;
	wire				clk_ser			;
	wire				lock			;
	wire				reset_ser		;
	wire				w_sync_word_sel	;
	wire	[15:0]		wv_sync_word	;

	wire	[13:0]		wv_pix_data_adc	;
	wire	[15:0]		wv_pix_data_latch	;


	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***ad9970 控制模块***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	时钟处理模块
	//	-------------------------------------------------------------------------------------
	ad_clock_unit # (
	.CLK_UNIT_VENDOR	(CLK_UNIT_VENDOR	)
	)
	ad_clock_unit_inst (
	.cli				(cli				),
	.clk				(clk				),
	.clk_ser			(clk_ser			),
	.reset_ser			(reset_ser			)
	);

	//	-------------------------------------------------------------------------------------
	//	时序产生模块
	//	-------------------------------------------------------------------------------------
	ad_timing_generation ad_timing_generation_inst (
	.clk				(clk				),
	.i_vd				(i_vd				),
	.i_hd				(i_hd				),
	.i_sync_align_loc	(i_sync_align_loc	),
	.iv_sync_start_loc	(iv_sync_start_loc	),
	.iv_sync_word0		(iv_sync_word0		),
	.iv_sync_word1		(iv_sync_word1		),
	.iv_sync_word2		(iv_sync_word2		),
	.iv_sync_word3		(iv_sync_word3		),
	.iv_sync_word4		(iv_sync_word4		),
	.iv_sync_word5		(iv_sync_word5		),
	.iv_sync_word6		(iv_sync_word6		),
	.o_sync_word_sel	(w_sync_word_sel	),
	.ov_sync_word		(wv_sync_word		),
	.iv_hblk_tog1		(iv_hblk_tog1		),
	.iv_hblk_tog2		(iv_hblk_tog2		),
	.o_hblk_n			(w_hblk_n      		)
	);

	//	-------------------------------------------------------------------------------------
	//	水平驱动
	//	-------------------------------------------------------------------------------------
	ad_horizontal_driver ad_horizontal_driver_inst (
	.clk				(clk_ser			),
	.reset				(reset_ser			),
	.i_hl_mask_pol		(i_hl_mask_pol		),
	.i_h1_mask_pol		(i_h1_mask_pol		),
	.i_h2_mask_pol		(i_h2_mask_pol		),
	.i_hblk_n			(w_hblk_n			),
	.o_hl				(o_hl				),
	.o_h1				(o_h1				),
	.o_h2				(o_h2				),
	.o_rg				(o_rg				)
	);

	//	===============================================================================================
	//	ref ***ad9970 数据通道***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	14bit adc
	//	-------------------------------------------------------------------------------------
	ad_14bit_adc ad_14bit_adc_inst (
	.clk				(clk				),
	.iv_pix_data		(iv_pix_data		),
	.ov_pix_data		(wv_pix_data_adc	)
	);

	//	-------------------------------------------------------------------------------------
	//	output latch
	//	-------------------------------------------------------------------------------------
	ad_output_latch ad_output_latch_inst (
	.clk				(clk				),
	.iv_pix_data		(wv_pix_data_adc	),
	.i_lvds_pattern_en	(i_lvds_pattern_en	),
	.iv_lvds_pattern	(iv_lvds_pattern	),
	.i_sync_word_sel	(w_sync_word_sel	),
	.iv_sync_word		(wv_sync_word		),
	.ov_pix_data		(wv_pix_data_latch	)
	);

	//	-------------------------------------------------------------------------------------
	//	lvds serializer
	//	-------------------------------------------------------------------------------------
	ad_lvds_serializer ad_lvds_serializer_inst (
	.clk				(clk_ser			),
	.reset				(reset_ser			),
	.iv_pix_data		(wv_pix_data_latch	),
	.o_tckp				(o_tckp				),
	.o_tckn				(o_tckn				),
	.o_dout0p			(o_dout0p			),
	.o_dout0n			(o_dout0n			),
	.o_dout1p			(o_dout1p			),
	.o_dout1n			(o_dout1n			)
	);

endmodule
