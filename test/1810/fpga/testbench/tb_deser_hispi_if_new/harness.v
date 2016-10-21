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
//  -- 邢海涛       :| 2015/3/9 17:18:50	:|  初始版本
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
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	parameter	PLL_CHECK_CLK_PERIOD_NS       	= `TESTCASE.PLL_CHECK_CLK_PERIOD_NS   ;
	parameter	SER_FIRST_BIT       	= `TESTCASE.SER_FIRST_BIT   ;
	parameter	END_STYLE           	= `TESTCASE.END_STYLE       ;
	parameter	SER_DATA_RATE       	= `TESTCASE.SER_DATA_RATE   ;
	parameter	DESER_CLOCK_ARC     	= `TESTCASE.DESER_CLOCK_ARC ;
	parameter	DESER_WIDTH         	= `TESTCASE.DESER_WIDTH     ;
	parameter	CLKIN_PERIOD_PS     	= `TESTCASE.CLKIN_PERIOD_PS ;
	parameter	DATA_DELAY_TYPE     	= `TESTCASE.DATA_DELAY_TYPE ;
	parameter	DATA_DELAY_VALUE    	= `TESTCASE.DATA_DELAY_VALUE;
	parameter	BITSLIP_ENABLE      	= `TESTCASE.BITSLIP_ENABLE  ;
	parameter	SENSOR_DAT_WIDTH		= `TESTCASE.SENSOR_DAT_WIDTH	;
	parameter	CHANNEL_NUM				= `TESTCASE.CHANNEL_NUM	;


	//	-------------------------------------------------------------------------------------
	//	输出的信号
	//	-------------------------------------------------------------------------------------


	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	输入
	//	-------------------------------------------------------------------------------------
	wire								pix_clk_p	;
	wire								pix_clk_n	;
	wire	[CHANNEL_NUM-1:0]			iv_pix_data_p	;
	wire	[CHANNEL_NUM-1:0]			iv_pix_data_n	;
	wire								reset	;
	wire								clk_pll_check	;

	//	-------------------------------------------------------------------------------------
	//	输出
	//	-------------------------------------------------------------------------------------
	wire										o_first_frame_detect	;
	wire										o_clk_en				;
	wire										o_fval					;
	wire										o_lval					;
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	ov_pix_data				;

	//	-------------------------------------------------------------------------------------
	//	交互
	//	-------------------------------------------------------------------------------------
	wire										clk_recover	;
	wire										reset_recover	;
	wire	[DESER_WIDTH*CHANNEL_NUM-1:0]		wv_data_recover	;
	wire										w_pll_reset	;


	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	引入输入信号
	//	-------------------------------------------------------------------------------------
	assign	pix_clk_p			= `TESTCASE.pix_clk_p	;
	assign	pix_clk_n			= `TESTCASE.pix_clk_n	;
	assign	iv_pix_data_p		= `TESTCASE.iv_pix_data_p	;
	assign	iv_pix_data_n		= `TESTCASE.iv_pix_data_n	;
	assign	reset				= `TESTCASE.reset	;
	assign	clk_pll_check		= `TESTCASE.clk_pll_check	;

	//	-------------------------------------------------------------------------------------
	//	例化 bfm 模块
	//	-------------------------------------------------------------------------------------

	//	-------------------------------------------------------------------------------------
	//	例化 dut 模型
	//	-------------------------------------------------------------------------------------
	deserializer # (
	.SER_FIRST_BIT				(SER_FIRST_BIT				),
	.END_STYLE					(END_STYLE					),
	.SER_DATA_RATE				(SER_DATA_RATE				),
	.DESER_CLOCK_ARC			(DESER_CLOCK_ARC			),
	.CHANNEL_NUM				(CHANNEL_NUM				),
	.DESER_WIDTH				(DESER_WIDTH				),
	.CLKIN_PERIOD_PS			(CLKIN_PERIOD_PS			),
	.DATA_DELAY_TYPE			(DATA_DELAY_TYPE			),
	.DATA_DELAY_VALUE			(DATA_DELAY_VALUE			),
	.BITSLIP_ENABLE				(BITSLIP_ENABLE				)
	)
	deserializer (
	.i_clk_p					(pix_clk_p					),
	.i_clk_n					(pix_clk_n					),
	.iv_data_p					(iv_pix_data_p				),
	.iv_data_n					(iv_pix_data_n				),
	.reset						(reset	| w_pll_reset		),
	.iv_bitslip					({CHANNEL_NUM{1'b0}}		),
	.o_bufpll_lock				(o_deser_pll_lock			),
	.clk_recover				(clk_recover				),
	.reset_recover				(reset_recover				),
	.ov_data_recover			(wv_data_recover			)
	);

	//	-------------------------------------------------------------------------------------
	//	PLL 复位模块
	//	-------------------------------------------------------------------------------------
	pll_reset # (
	.PLL_CHECK_CLK_PERIOD_NS	(PLL_CHECK_CLK_PERIOD_NS	)
	)
	pll_reset_inst (
	.clk			(clk_pll_check			),
	.i_pll_lock		(o_deser_pll_lock		),
	.o_pll_reset	(w_pll_reset			)
	);

	hispi_if # (
	.SER_FIRST_BIT			(SER_FIRST_BIT			),
	.DESER_WIDTH			(DESER_WIDTH			),
	.CHANNEL_NUM			(CHANNEL_NUM			),
	.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH		)
	)
	hispi_if_inst (
	.clk					(clk_recover			),
	.reset					(reset_recover			),
	.iv_data				(wv_data_recover		),
	.o_first_frame_detect	(o_first_frame_detect	),
	.o_clk_en				(o_clk_en				),
	.o_fval					(o_fval					),
	.o_lval					(o_lval					),
	.ov_pix_data			(ov_pix_data			)
	);

	//generate vcd file
	//initial begin
	//$dumpfile("test.vcd");
	//$dumpvars(1,top_frame_buffer_inst);
	//end

	//for lattice simulation
	//GSR   GSR_INST (.GSR (1'b1)); //< global reset sig>
	//PUR   PUR_INST (.PUR (1'b1)); //<powerup reset sig>



endmodule
