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
	wire								i_bitslip_en	;

	//	-------------------------------------------------------------------------------------
	//	输出
	//	-------------------------------------------------------------------------------------
	wire										o_data_valid	;
	wire										o_deser_pll_lock	;
	wire										o_bitslip_done	;

	//	-------------------------------------------------------------------------------------
	//	交互
	//	-------------------------------------------------------------------------------------
	wire										clk_recover	;
	wire										reset_recover	;
	wire	[DESER_WIDTH*CHANNEL_NUM-1:0]		wv_data_recover	;
	wire										w_bitslip	;
	wire										w_clk_en_recover	;
	wire										w_fval_deser	;
	wire										w_lval_deser	;
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_deser	;


	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	引入输入信号
	//	-------------------------------------------------------------------------------------
	assign	pix_clk_p			= `TESTCASE.pix_clk_p	;
	assign	pix_clk_n			= `TESTCASE.pix_clk_n	;
	assign	iv_pix_data_p		= `TESTCASE.iv_pix_data_p	;
	assign	iv_pix_data_n		= `TESTCASE.iv_pix_data_n	;
	assign	i_bitslip_en		= `TESTCASE.i_bitslip_en	;

	//	-------------------------------------------------------------------------------------
	//	例化 bfm 模块
	//	-------------------------------------------------------------------------------------

	//	-------------------------------------------------------------------------------------
	//	例化 dut 模型
	//	-------------------------------------------------------------------------------------
	deserializer # (
	.SER_FIRST_BIT		(SER_FIRST_BIT				),
	.END_STYLE			(END_STYLE					),
	.SER_DATA_RATE		(SER_DATA_RATE				),
	.DESER_CLOCK_ARC	(DESER_CLOCK_ARC			),
	.CHANNEL_NUM		(CHANNEL_NUM				),
	.DESER_WIDTH		(DESER_WIDTH				),
	.CLKIN_PERIOD_PS	(CLKIN_PERIOD_PS			),
	.DATA_DELAY_TYPE	(DATA_DELAY_TYPE			),
	.DATA_DELAY_VALUE	(DATA_DELAY_VALUE			),
	.BITSLIP_ENABLE		(BITSLIP_ENABLE				)
	)
	deserializer_inst (
	.i_clk_p			(pix_clk_p					),
	.i_clk_n			(pix_clk_n					),
	.iv_data_p			(iv_pix_data_p				),
	.iv_data_n			(iv_pix_data_n				),
	.reset				(1'b0						),
	.iv_bitslip			({CHANNEL_NUM{w_bitslip}}	),
	.o_bufpll_lock		(o_deser_pll_lock			),
	.clk_recover		(clk_recover				),
	.reset_recover		(reset_recover				),
	.ov_data_recover	(wv_data_recover			)
	);

	hispi_if # (
	.SER_FIRST_BIT		(SER_FIRST_BIT		),
	.END_STYLE			(END_STYLE			),
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	),
	.RATIO				(DESER_WIDTH		),
	.CHANNEL_NUM		(CHANNEL_NUM		)
	)
	hispi_if_inst (
	.clk				(clk_recover			),
	.reset				(reset_recover			),
	.iv_data			(wv_data_recover		),
	.i_bitslip_en		(i_bitslip_en			),
	.o_bitslip			(w_bitslip				),
	.o_data_valid		(o_data_valid			),
	.o_first_frame_detect(o_bitslip_done		),
	.iv_line_length		(16'd1200				),	//sensor输出的最大宽度为4608，该值最好大于1152（4608/4=1152）
	.o_clk_en			(w_clk_en_recover		),
	.o_fval				(w_fval_deser			),
	.o_lval				(w_lval_deser			),
	.ov_pix_data		(wv_pix_data_deser		)
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
