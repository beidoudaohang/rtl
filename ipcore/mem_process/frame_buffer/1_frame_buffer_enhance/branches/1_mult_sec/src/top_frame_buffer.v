//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : top_frame_buffer
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2013/6/17 15:43:38	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 帧缓存模块 top_frame_buffer
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//`include		"frame_buffer_def.v"
//`include        "pattern_model_def.v"

//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module top_frame_buffer # (
	//	parameter	MEM_ADDR_WIDTH	= (DDR3_MEM_DENSITY=="512Mb") ? (13-NUM_DQ_PINS/9) : ((DDR3_MEM_DENSITY=="1Gb") ? (14-NUM_DQ_PINS/9) : (14-NUM_DQ_PINS/9));
	parameter	NUM_DQ_PINS					= 8		,
	parameter	MEM_BANKADDR_WIDTH			= 3		,
	parameter	MEM_ADDR_WIDTH				= 14	,
	parameter	DDR3_MEMCLK_FREQ			= 320	,
	parameter	MEM_ADDR_ORDER				= "ROW_BANK_COLUMN"	,
	parameter	SKIP_IN_TERM_CAL			= 1		,
	parameter	DDR3_MEM_DENSITY			= "1Gb"	,
	parameter	DDR3_TCK_PERIOD				= "187E",
	parameter	DDR3_SIMULATION				= "FALSE",
	parameter	DDR3_CALIB_SOFT_IP			= "TRUE"
	)
	(
	//  -------------------------------------------------------------------------------------
	//  输入时钟
	//  -------------------------------------------------------------------------------------
	input											clk_osc			,
	//  -------------------------------------------------------------------------------------
	//  External Memory
	//  -------------------------------------------------------------------------------------
	inout  		[NUM_DQ_PINS-1:0]       			mcb3_dram_dq		,
	output 		[MEM_ADDR_WIDTH-1:0]    			mcb3_dram_a			,
	output 		[MEM_BANKADDR_WIDTH-1:0]			mcb3_dram_ba		,
	output											mcb3_dram_ras_n		,
	output											mcb3_dram_cas_n		,
	output											mcb3_dram_we_n		,
	output											mcb3_dram_odt		,
	output											mcb3_dram_reset_n	,
	output											mcb3_dram_cke		,
	output											mcb3_dram_dm		,
//	inout 											mcb3_dram_udqs		,	//DQ 16 bit only
//	inout 											mcb3_dram_udqs_n	,	//DQ 16 bit only
	inout 											mcb3_rzq			,
	//	inout 											mcb3_zio			,	//skip calib input term only
//	output											mcb3_dram_udm		,	//DQ 16 bit only
	inout 											mcb3_dram_dqs		,
	inout 											mcb3_dram_dqs_n		,
	output											mcb3_dram_ck		,
	output											mcb3_dram_ck_n		,
	//test
	output		[4:0]								ov_fpga_sw			,
	output		[4:0]								ov_fpga_led

	);

	//	ref signals

	//pattern model
	localparam		LINE_ACTIVE_PIX_NUM			= 320	;
	localparam		LINE_HIDE_PIX_NUM			= 4		;
	localparam		LINE_ACTIVE_NUMBER			= 1024	;
	localparam		FRAME_HIDE_PIX_NUM			= 11060	;
	localparam		FRAME_TO_LINE_PIX_NUM		= 25	;
	localparam		FRAME_DEPTH					= 3'b100;	//4 frame
	localparam		FRAME_SIZE					= (LINE_ACTIVE_PIX_NUM * LINE_ACTIVE_NUMBER) - 1	;



	wire								async_rst			;
	wire								sysclk_2x			;
	wire								sysclk_2x_180		;
	wire								pll_ce_0			;
	wire								pll_ce_90			;
	wire								mcb_drp_clk			;
	wire								bufpll_mcb_lock		;
	wire								w_clk_frame_buf		;
	wire								w_reset_frame_buf	;
	wire								w_clk_pix			;
	wire								w_reset_pix			;
	reg									reset_pattern		;
	wire								w_fval				;
	wire								w_dval				;
	reg									calib_done_dly0 	= 1'b0;
	reg									calib_done_dly1 	= 1'b0;
	reg		[15:0]						wv_line_active_pix_num		= LINE_ACTIVE_PIX_NUM;
	reg		[15:0]						wv_line_hide_pix_num		= LINE_HIDE_PIX_NUM;
	reg		[15:0]						wv_line_active_num			= LINE_ACTIVE_NUMBER;
	reg		[15:0]						wv_frame_hide_pix_num		= FRAME_HIDE_PIX_NUM;
	reg		[7:0]						wv_frame_to_line_pix_num	= FRAME_TO_LINE_PIX_NUM;

	wire								w_crc_fifo_wr_en	;
	wire	[15:0]						wv_crc_fifo_din		;
	wire	[15:0]						wv_crc_fifo_dout	;
	wire								w_calib_done		;
	wire								w_wr_error			;
	wire								w_rd_error			;
	wire								w_frame_en			;
	wire	[2:0]						wv_frame_depth		;
	wire	[22:0]						wv_frame_size		;
	wire								w_front_fifo_full	;
	wire								w_buf_rd			;
	wire								w_buf_empty			;
	wire								w_buf_pe			;
	wire	[31:0]						wv_image_din		;
	wire	[32:0]						wv_image_dout		;

	reg		[1:0]						fval_shift 			= 2'b0;
	wire								w_crc_buf_rd		;
	wire								w_good_frame		;
	wire								w_bad_frame			;
	wire	[15:0]						wv_crc_logic		;
	reg									comp_ok				;
	reg		[31:0]						send_frame_cnt 		= 32'b0;
	reg		[31:0]						good_frame_cnt 		= 32'b0;
	reg		[7:0]						bad_frame_cnt 		= 8'b0;
	reg									front_fifo_over_flow 	= 1'b0;
	reg									test_clear_dly0 		= 1'b0;
	reg									test_clear_dly1 		= 1'b0;
	reg									test_switch_dly0 		= 1'b0;
	reg									test_switch_dly1 		= 1'b0;

	wire	[119:0]						TRIG0		;
	wire	[31:0]						ASYNC_IN	;
	wire	[31:0]						ASYNC_OUT	;

	//	ref ARCHITECTURE

	assign 		ov_fpga_led[0]  	= test_switch_dly1;
	assign 		ov_fpga_led[1] 		= test_clear_dly1;
	assign 		ov_fpga_led[2] 		= w_calib_done;
	assign 		ov_fpga_led[3]   	= comp_ok;
	assign 		ov_fpga_led[4] 		= 1'b0;

	assign 		ov_fpga_sw[0]  		= w_fval;
	assign 		ov_fpga_sw[1] 		= w_dval;
	assign 		ov_fpga_sw[2] 		= 1'b0;
	assign 		ov_fpga_sw[3]   	= 1'b1;
	assign 		ov_fpga_sw[4] 		= 1'b0;




	//  ===============================================================================================
	//	时钟复位模块
	//  ===============================================================================================
	clk_rst_top # (
	.DDR3_MEMCLK_FREQ		(DDR3_MEMCLK_FREQ	)
	)
	clk_rst_top_inst (
	.clk_osc				(clk_osc			),
	.async_rst				(async_rst			),
	.sysclk_2x				(sysclk_2x			),
	.sysclk_2x_180			(sysclk_2x_180		),
	.pll_ce_0				(pll_ce_0			),
	.pll_ce_90				(pll_ce_90			),
	.mcb_drp_clk			(mcb_drp_clk		),
	.bufpll_mcb_lock		(bufpll_mcb_lock	),
	.clk_frame_buf			(w_clk_frame_buf	),
	.reset_frame_buf		(w_reset_frame_buf	),
	.o_clk_pix				(w_clk_pix			),
	.o_reset_pix			(w_reset_pix		)
	);

	//  ===============================================================================================
	//	产生前端激励
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	pattern 模块 复位设计
	//  -------------------------------------------------------------------------------------
	always @ (posedge w_clk_pix) begin
		calib_done_dly0	<= w_calib_done;
		calib_done_dly1	<= calib_done_dly0;
	end

	always @ (posedge w_clk_pix) begin
		if(((w_fval == 1'b0)&&(test_switch_dly1 == 1'b0))||(calib_done_dly1 == 1'b0)) begin
			reset_pattern	<= 1'b1;
		end
		else begin
			reset_pattern	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	fval dval 产生逻辑
	//  -------------------------------------------------------------------------------------
	pattern_model pattern_model_inst (
	.clk						(w_clk_pix			),
	.reset						(reset_pattern		),
	.iv_line_active_pix_num		(wv_line_active_pix_num		),
	.iv_line_hide_pix_num		(wv_line_hide_pix_num		),
	.iv_line_active_num			(wv_line_active_num			),
	.iv_frame_hide_pix_num		(wv_frame_hide_pix_num		),
	.iv_frame_to_line_pix_num	(wv_frame_to_line_pix_num	),
	.o_fval						(w_fval				),
	.o_dval						(w_dval				)
	);

	//  -------------------------------------------------------------------------------------
	//	帧缓存模块的读写测试逻辑
	//  -------------------------------------------------------------------------------------
	wrap_frame_buf_traffic wrap_frame_buf_traffic_inst (
	.clk			(w_clk_pix		),
	.reset			(w_reset_pix	),
	.i_fval			(w_fval			),
	.i_dval			(w_dval			),
	.iv_frame_size	(wv_frame_size	),
	.ov_image_dout	(wv_image_din	),
	.i_buf_empty	(w_buf_empty	),
	.o_buf_rd		(w_buf_rd		),
	.iv_image_din	(wv_image_dout	),
	.o_good_frame	(w_good_frame	),
	.o_bad_frame	(w_bad_frame	)
	);

	//  ===============================================================================================
	//	帧缓存模块
	//  ===============================================================================================
	frame_buffer # (
	.NUM_DQ_PINS			(NUM_DQ_PINS		),
	.MEM_BANKADDR_WIDTH		(MEM_BANKADDR_WIDTH	),
	.MEM_ADDR_WIDTH			(MEM_ADDR_WIDTH		),
	.DDR3_MEMCLK_FREQ		(DDR3_MEMCLK_FREQ	),
	.MEM_ADDR_ORDER			(MEM_ADDR_ORDER		),
	.SKIP_IN_TERM_CAL		(SKIP_IN_TERM_CAL	),
	.DDR3_MEM_DENSITY		(DDR3_MEM_DENSITY	),
	.DDR3_TCK_PERIOD		(DDR3_TCK_PERIOD	),
	.DDR3_SIMULATION		(DDR3_SIMULATION	),
	.DDR3_CALIB_SOFT_IP		(DDR3_CALIB_SOFT_IP	)
	)
	frame_buffer_inst (
	.clk_vin				(w_clk_pix				),
	.i_fval					(w_fval					),
	.i_dval					(w_dval					),
	.iv_image_din			(wv_image_din			),
	.o_front_fifo_full		(w_front_fifo_full		),
	.clk_vout				(w_clk_pix				),
	.i_buf_rd				(w_buf_rd				),
	.o_buf_empty			(w_buf_empty			),
	.o_buf_pe				(w_buf_pe				),
	.ov_image_dout			(wv_image_dout			),
	.i_frame_en				(w_frame_en				),
	.iv_frame_depth			(wv_frame_depth			),
	.iv_frame_size			(wv_frame_size			),
	.clk_frame_buf			(w_clk_frame_buf		),
	.reset_frame_buf		(w_reset_frame_buf		),
	.async_rst				(async_rst				),
	.sysclk_2x				(sysclk_2x				),
	.sysclk_2x_180			(sysclk_2x_180			),
	.pll_ce_0				(pll_ce_0				),
	.pll_ce_90				(pll_ce_90				),
	.mcb_drp_clk			(mcb_drp_clk			),
	.bufpll_mcb_lock		(bufpll_mcb_lock		),
	.o_calib_done			(w_calib_done			),
	.o_wr_error             (w_wr_error				),
	.o_rd_error             (w_rd_error				),
	.mcb3_dram_dq			(mcb3_dram_dq			),
	.mcb3_dram_a			(mcb3_dram_a			),
	.mcb3_dram_ba			(mcb3_dram_ba			),
	.mcb3_dram_ras_n		(mcb3_dram_ras_n		),
	.mcb3_dram_cas_n		(mcb3_dram_cas_n		),
	.mcb3_dram_we_n			(mcb3_dram_we_n			),
	.mcb3_dram_odt			(mcb3_dram_odt			),
	.mcb3_dram_reset_n		(mcb3_dram_reset_n		),
	.mcb3_dram_cke			(mcb3_dram_cke			),
	.mcb3_dram_dm			(mcb3_dram_dm			),
//	.mcb3_dram_udqs			(mcb3_dram_udqs			),	//DQ 16 bit only
//	.mcb3_dram_udqs_n		(mcb3_dram_udqs_n		),	//DQ 16 bit only
	.mcb3_rzq				(mcb3_rzq				),
	//	.mcb3_zio				(mcb3_zio				),	//skip calib input term only
//	.mcb3_dram_udm			(mcb3_dram_udm			),	//DQ 16 bit only
	.mcb3_dram_dqs			(mcb3_dram_dqs			),
	.mcb3_dram_dqs_n		(mcb3_dram_dqs_n		),
	.mcb3_dram_ck			(mcb3_dram_ck			),
	.mcb3_dram_ck_n			(mcb3_dram_ck_n			),
	.ov_frame_buf_version	(						)
	);

	assign	wv_frame_depth	= 3'b100;
	assign	wv_frame_size	= FRAME_SIZE;
	assign	w_frame_en		= 1'b1;

	//  ===============================================================================================
	//	测试逻辑
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	测试前端fifo是否会满
	//  -------------------------------------------------------------------------------------
	always @ (posedge w_clk_pix) begin
		if(test_clear_dly1 == 1'b0) begin
			if(w_front_fifo_full&w_dval) begin
				front_fifo_over_flow	<= 1'b1;
			end
		end
		else begin
			front_fifo_over_flow	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	统计发出的帧数
	//  -------------------------------------------------------------------------------------
	always @ (posedge w_clk_pix) begin
		fval_shift	<= {fval_shift[0],w_fval};
	end

	always @ (posedge w_clk_pix) begin
		if(test_clear_dly1 == 1'b1) begin
			send_frame_cnt	<= 32'h0;
		end
		else begin
			if(fval_shift == 2'b01) begin
				send_frame_cnt	<= send_frame_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	统计接收的帧数
	//  -------------------------------------------------------------------------------------
	always @ (posedge w_clk_pix) begin
		if(test_clear_dly1 == 1'b1) begin
			good_frame_cnt	<= 32'h0;
		end
		else begin
			if(w_good_frame) begin
				good_frame_cnt	<= good_frame_cnt + 1'b1;
			end
		end
	end

	always @ (posedge w_clk_pix) begin
		if(test_clear_dly1 == 1'b1) begin
			bad_frame_cnt	<= 8'h0;
		end
		else begin
			if(w_bad_frame) begin
				bad_frame_cnt	<= bad_frame_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	比较接发送和接收的帧数
	//  -------------------------------------------------------------------------------------
	always @ (posedge w_clk_pix) begin
		if(test_switch_dly1 == 1'b1) begin
			comp_ok		<= 1'b0;
		end
		else begin
			if(send_frame_cnt == good_frame_cnt) begin
				comp_ok		<= 1'b1;
			end
			else begin
				comp_ok		<= 1'b0;
			end
		end
	end


	`ifdef SIMULATION
		always @ (posedge w_clk_pix) begin
			test_switch_dly1	<= 1'b1;
		end
	`else
		//  ===============================================================================================
		//	chipscope
		//  ===============================================================================================
		cs_top cs_top_inst (
		.CLK		(w_clk_pix	),
		.TRIG0		(TRIG0	),
		.ASYNC_IN	(ASYNC_IN	),
		.ASYNC_OUT	(ASYNC_OUT	)
		);


		//  -------------------------------------------------------------------------------------
		//	ILA
		//  -------------------------------------------------------------------------------------
		assign	TRIG0[31:0]		= send_frame_cnt	;
		assign	TRIG0[63:32]	= good_frame_cnt	;
		assign	TRIG0[71:64]	= bad_frame_cnt	;
		assign	TRIG0[72]		= w_good_frame	;
		assign	TRIG0[73]		= w_bad_frame	;
		assign	TRIG0[74]		= comp_ok	;
		assign	TRIG0[75]		= calib_done_dly1	;

		assign	TRIG0[79:76	]	= 'b0	;

		assign	TRIG0[80	]	= w_fval	;
		assign	TRIG0[81	]	= w_dval	;
		assign	TRIG0[82	]	= w_front_fifo_full	;
		assign	TRIG0[83	]	= front_fifo_over_flow	;

		assign	TRIG0[99:84]	= wv_crc_fifo_dout[15:0]	;
		assign	TRIG0[115:100]	= wv_crc_logic[15:0]	;
		assign	TRIG0[116]		= w_crc_buf_rd	;

		assign	TRIG0[119:117]	= 'b0	;





		//  -------------------------------------------------------------------------------------
		//	VIO
		//  -------------------------------------------------------------------------------------
		assign	test_switch	= ASYNC_OUT[0];
		assign	test_clear	= ASYNC_OUT[1];
		always @ (posedge w_clk_pix) begin
			wv_frame_hide_pix_num		<= ASYNC_OUT[17:2];
			wv_line_hide_pix_num[7:0]	<= ASYNC_OUT[25:18];
		end




		assign	ASYNC_IN[0]		= front_fifo_over_flow;
		assign	ASYNC_IN[16:1]	= wv_frame_hide_pix_num;
		assign	ASYNC_IN[24:17]	= wv_line_hide_pix_num[7:0];
		assign	ASYNC_IN[31:25]	= 'b0;


		always @ (posedge w_clk_pix) begin
			test_switch_dly0	<= test_switch;
			test_switch_dly1	<= test_switch_dly0;
		end


		always @ (posedge w_clk_pix) begin
			test_clear_dly0	<= test_clear;
			test_clear_dly1	<= test_clear_dly0;
		end
	`endif




endmodule