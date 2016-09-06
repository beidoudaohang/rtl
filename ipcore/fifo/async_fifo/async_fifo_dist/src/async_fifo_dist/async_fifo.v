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
//  -- Michael      | 2014/4/8 15:26:47	|
//-------------------------------------------------------------------------------------------------
//`include			"_def.v"
//time unit/precision
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module async_fifo # (
	parameter			FIFO_WIDTH		= 8		,	//fifo 数据宽度
	parameter			FIFO_DEPTH		= 16		//fifo 数据深度，16 32 64
	)
	(
	input						reset_async		,	//异步复位信号，读写两端都会对复位做同步处理
	//写时钟域
	input						clk_wr			,	//写时钟
	input						i_wr_en			,	//写使能
	input	[FIFO_WIDTH-1:0]	iv_fifo_din		,	//写数据
	output						o_fifo_full		,	//满信号
	//读时钟域
	input						clk_rd			,	//读时钟
	input						i_rd_en			,	//读使能
	output	[FIFO_WIDTH-1:0]	ov_fifo_dout	,	//读数据
	output						o_fifo_empty		//空信号
	);

	//	ref signals

	//	-------------------------------------------------------------------------------------
	//	产生最大的addr地址宽度
	//	1.读写地址的位宽要扩充1bit，作为判断空满的标志
	//	2.实际读写DPRAM的地址比cnt要少1bit
	//	3.由于xilinx 的 dpram 最小是32深度，因此地址位宽最小是6bit，其中msb是扩充位
	//	-------------------------------------------------------------------------------------
	parameter	MAX_ADDR_WIDTH	= (FIFO_DEPTH/33)+6;

	parameter	ADDR_WIDTH	= (FIFO_DEPTH==16) ? 5 : (FIFO_DEPTH==32) ? 6 : (FIFO_DEPTH==64) ? 7 : 7;

	wire	[ADDR_WIDTH-1:0]	wv_rd_addr_gray			;
	wire	[ADDR_WIDTH-1:0]	wv_wr_addr_gray			;
	wire	[ADDR_WIDTH-2:0]	wv_wr_addr_dpram		;
	wire	[ADDR_WIDTH-2:0]	wv_rd_addr_dpram		;

	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	FIFO写操作相关逻辑
	//  -------------------------------------------------------------------------------------
	async_fifo_wrap_wr # (
	.ADDR_WIDTH			(ADDR_WIDTH			)
	)
	async_fifo_wrap_wr_inst (
	.reset_async		(reset_async		),
	.clk				(clk_wr				),
	.i_wr_en			(i_wr_en			),
	.o_fifo_full		(o_fifo_full		),
	.ov_wr_addr_gray	(wv_wr_addr_gray	),
	.ov_wr_addr_dpram	(wv_wr_addr_dpram	),
	.o_wr_en			(w_wr_en			),
	.iv_rd_addr_gray	(wv_rd_addr_gray	)
	);

	//  -------------------------------------------------------------------------------------
	//	FIFO读操作相关逻辑
	//  -------------------------------------------------------------------------------------
	async_fifo_wrap_rd # (
	.ADDR_WIDTH			(ADDR_WIDTH			)
	)
	async_fifo_wrap_rd_inst (
	.reset_async		(reset_async		),
	.clk				(clk_rd				),
	.i_rd_en			(i_rd_en			),
	.o_fifo_empty		(o_fifo_empty		),
	.ov_rd_addr_gray	(wv_rd_addr_gray	),
	.ov_rd_addr_dpram	(wv_rd_addr_dpram	),
	.o_rd_en			(					),
	.iv_wr_addr_gray	(wv_wr_addr_gray	)
	);

	//  -------------------------------------------------------------------------------------
	//	存储器
	//  -------------------------------------------------------------------------------------
	dpram_dist # (
	.FIFO_WIDTH			(FIFO_WIDTH			),
	.ADDR_WIDTH			(ADDR_WIDTH			),
	.MAX_ADDR_WIDTH		(MAX_ADDR_WIDTH		)
	)
	dpram_dist_inst (
	.clk_wr				(clk_wr				),
	.i_wr				(w_wr_en			),
	.iv_wr_addr			(wv_wr_addr_dpram	),
	.iv_din				(iv_fifo_din		),
	.clk_rd				(clk_rd				),
	.iv_rd_addr			(wv_rd_addr_dpram	),
	.ov_dout			(ov_fifo_dout		)
	);

endmodule