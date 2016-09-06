//-------------------------------------------------------------------------------------------------
//  -- Corporation  : MicroRTL.com
//  -- Email        : haitaox2013@gmail.com
//  -- Module       :
//-------------------------------------------------------------------------------------------------
//  -- Description  :
//
//-------------------------------------------------------------------------------------------------
//  -- Changelog    :
//  -- Author       | Date                  | Content
//  -- Michael      | 2014/4/11 9:08:52	|
//-------------------------------------------------------------------------------------------------
//`include			"_def.v"
//time unit/precision
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module top_memory (
	input	clk_wr	,
	input	clk_rd	,
	input	reset	,
	output	test0	,
	output	test1
	);





	reg		[7:0]	wr_cnt = 8'b0;
	reg		[7:0]	lfsr = 8'b0;

	wire			w_wr_en;
	wire			w_rd_en;
	wire			w_fifo_full;
	wire			w_fifo_empty;
	wire	[7:0]	wv_fifo_din;
	wire	[7:0]	wv_fifo_dout;

	wire			w_wr_en_ip;
	wire			w_rd_en_ip;
	wire			w_fifo_full_ip;
	wire			w_fifo_empty_ip;
	wire	[7:0]	wv_fifo_din_ip;
	wire	[7:0]	wv_fifo_dout_ip;

	reg				test0_reg = 1'b0;
	reg				test1_reg = 1'b0;

	//	ref signals



	//	ref ARCHITECTURE


	//  ===============================================================================================
	//	产生随机数
	//  ===============================================================================================
	always @ (posedge clk_wr) begin
		lfsr	<= {lfsr[6:0],(lfsr[7]^lfsr[2])};
	end

	//  ===============================================================================================
	//	输出
	//  ===============================================================================================
	always @ (posedge clk_rd) begin
		test0_reg	<= ^wv_fifo_dout;
	end
	assign	test0	= test0_reg;

	always @ (posedge clk_rd) begin
		test1_reg	<= ^wv_fifo_dout_ip;
	end
	assign	test1	= test1_reg;

	//  ===============================================================================================
	//	例化
	//  ===============================================================================================

	//  -------------------------------------------------------------------------------------
	//	手工fifo 深度16 位宽8
	//  -------------------------------------------------------------------------------------
	async_fifo # (
	.FIFO_WIDTH			(8	),
	.FIFO_DEPTH			(16	)
	)
	async_fifo_inst (
	.reset_async		(reset			),
	.clk_wr				(clk_wr			),
	.i_wr_en			(w_wr_en		),
	.iv_fifo_din		(wv_fifo_din	),
	.o_fifo_full		(w_fifo_full	),
	.clk_rd				(clk_rd			),
	.i_rd_en			(w_rd_en		),
	.ov_fifo_dout		(wv_fifo_dout	),
	.o_fifo_empty		(w_fifo_empty	)
	);

	assign	w_wr_en	= !w_fifo_full;
	assign	wv_fifo_din	= lfsr;
	assign	w_rd_en	= !w_fifo_empty;

	//  -------------------------------------------------------------------------------------
	//	ip fifo 深度16 位宽8
	//  -------------------------------------------------------------------------------------
	fifo_w8d16 fifo_w8d16_inst (
	.rst				(reset				),
	.wr_clk				(clk_wr				),
	.rd_clk				(clk_rd				),
	.din				(wv_fifo_din_ip		),
	.wr_en				(w_wr_en_ip			),
	.rd_en				(w_rd_en_ip			),
	.dout				(wv_fifo_dout_ip	),
	.full				(w_fifo_full_ip		),
	.empty				(w_fifo_empty_ip	)
	);

	assign	w_wr_en_ip		= !w_fifo_full_ip;
	assign	wv_fifo_din_ip	= lfsr;
	assign	w_rd_en_ip		= !w_fifo_empty_ip;



endmodule