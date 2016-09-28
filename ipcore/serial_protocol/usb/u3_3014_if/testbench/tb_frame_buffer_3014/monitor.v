//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : monitor
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/16 17:48:47	:|  初始版本
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
`define		TESTCASE	testcase_1
module monitor ();

	//	ref signals
	parameter	DATA_WIDTH              	= `TESTCASE.DATA_WIDTH	;
	parameter	OUTPUT_FILE_EN				= `TESTCASE.MONITOR_OUTPUT_FILE_EN	;
	parameter	OUTPUT_FILE_PATH			= `TESTCASE.MONITOR_OUTPUT_FILE_PATH	;

	parameter	TESTCASE_NUM				= `TESTCASE.TESTCASE_NUM;

	parameter	CHK_INOUT_DATA_STOP_ON_ERROR	= `TESTCASE.CHK_INOUT_DATA_STOP_ON_ERROR;
	parameter	CHK_PULSE_WIDTH_STOP_ON_ERROR	= `TESTCASE.CHK_PULSE_WIDTH_STOP_ON_ERROR;


	//	ref ARCHITECTURE
	wire						clk_in			;
	wire						fval_in			;
	wire						lval_in			;
	wire	[DATA_WIDTH-1:0]	pix_data_in		;
	wire						clk_out			;
	wire						fval_out		;
	wire						lval_out		;
	wire	[DATA_WIDTH-1:0]	pix_data_out	;



//	//	-------------------------------------------------------------------------------------
//	//	引用
//	//	-------------------------------------------------------------------------------------
//	assign	clk_in			= driver_clock_reset.clk_pix;
//	assign	fval_in			= driver_mt9p031.o_fval;
//	assign	lval_in			= driver_mt9p031.o_lval;
//	assign	pix_data_in		= driver_mt9p031.ov_pix_data;
//	assign	clk_out			= driver_clock_reset.clk_gpif;
//	assign	fval_out		= harness.o_fval;
//	assign	lval_out		= harness.o_lval;
//	assign	pix_data_out	= harness.ov_image_dout;
//
//	//  ===============================================================================================
//	//	ref ***文件操作***
//	//  ===============================================================================================
//	//	-------------------------------------------------------------------------------------
//	//	保存后端fifo输出的文件
//	//  -------------------------------------------------------------------------------------
//	generate
//		if(OUTPUT_FILE_EN==1'b1) begin
//			filte_write # (
//			.DATA_WIDTH		(DATA_WIDTH			),
//			.FILE_PATH		(OUTPUT_FILE_PATH	)
//			)
//			filte_write_rd_back_buf_inst (
//			.clk			(clk_out			),
//			.reset			(1'b0				),
//			.i_fval			(fval_out			),
//			.i_lval			(lval_out			),
//			.iv_din			(pix_data_out		)
//			);
//		end
//	endgenerate
//
//
//	//  ===============================================================================================
//	//	ref ***监视***
//	//  ===============================================================================================
//	//	-------------------------------------------------------------------------------------
//	//	延时
//	//  -------------------------------------------------------------------------------------
//	reg			fval_in_dly0	= 1'b0;
//	reg			fval_in_dly1	= 1'b0;
//	reg			fval_in_dly2	= 1'b0;
//	reg			lval_in_dly0	= 1'b0;
//	reg			lval_in_dly1	= 1'b0;
//	reg			lval_in_dly2	= 1'b0;
//	reg		[DATA_WIDTH-1:0]	pix_data_in_dly0	= {DATA_WIDTH{1'b0}};
//	reg		[DATA_WIDTH-1:0]	pix_data_in_dly1	= {DATA_WIDTH{1'b0}};
//	reg		[DATA_WIDTH-1:0]	pix_data_in_dly2	= {DATA_WIDTH{1'b0}};
//
//	always @ (posedge clk_in) begin
//		fval_in_dly0	<= fval_in;
//		fval_in_dly1	<= fval_in_dly0;
//		fval_in_dly2	<= fval_in_dly1;
//	end
//
//	always @ (posedge clk_in) begin
//		lval_in_dly0	<= lval_in;
//		lval_in_dly1	<= lval_in_dly0;
//		lval_in_dly2	<= lval_in_dly1;
//	end
//
//	always @ (posedge clk_in) begin
//		pix_data_in_dly0	<= pix_data_in;
//		pix_data_in_dly1	<= pix_data_in_dly0;
//		pix_data_in_dly2	<= pix_data_in_dly1;
//	end
//
//	//	-------------------------------------------------------------------------------------
//	//	检测输入输出数据
//	//  -------------------------------------------------------------------------------------
//	wire		i_chk_en;
//	assign		i_chk_en	= harness.o_calib_done;
//	chk_inout_data # (
//	.DATA_WIDTH			(DATA_WIDTH		),
//	.DATA_DEPTH			(1024			),
//	.STOP_ON_ERROR		(CHK_INOUT_DATA_STOP_ON_ERROR	)
//	)
//	chk_inout_data_inst (
//	.i_chk_en			(i_chk_en			),
//	.clk_in				(clk_in				),
//	.i_fval_in			(fval_in_dly1		),
//	.i_lval_in			(lval_in_dly1		),
//	.iv_pix_data_in		(pix_data_in_dly1	),
//	.clk_out			(clk_out			),
//	.i_fval_out			(fval_out			),
//	.i_lval_out			(lval_out			),
//	.iv_pix_data_out	(pix_data_out		)
//	);
//	
//	




endmodule
