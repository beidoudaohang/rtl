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
//  -- Michael      | 2016/09/06 10:52:45	|
//-------------------------------------------------------------------------------------------------
//`include			"_def.v"
//time unit/precision
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------


module async_fifo_wrap_wr # (
	parameter			ADDR_WIDTH 			= 6			//最高位地址用于判断空满标志，不用于fifo地址，因此 5-深度16 6-深度32 7-深度64
	)
	(
	input							reset_async		,	//异步复位
	//写时钟域
	////fifo相关
	input							clk				,	//时钟
	input							i_wr_en			,	//fifo写使能
	output							o_fifo_full		,	//fifo满标志
	////dpram相关
	output	[ADDR_WIDTH-1:0]		ov_wr_addr_gray	,	//写地址的格雷码，写时钟域
	output	[ADDR_WIDTH-2:0]		ov_wr_addr_dpram,	//写地址的2进制码，写时钟域，传递到dpram中，比格雷码少一位
	output							o_wr_en			,	//dpram的写使能信号
	//读时钟域
	input	[ADDR_WIDTH-1:0]		iv_rd_addr_gray		//读地址的格雷码，读时钟域
	);

	//	ref signals
	wire							reset_sync		;
	wire	[ADDR_WIDTH-1:0]		wv_rd_addr_bin	;
	wire	[ADDR_WIDTH-1:0]		wv_wr_addr_bin	;

	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	复位
	//  -------------------------------------------------------------------------------------
	rst_sync # (
	.RESET_LENGTH	(2			)
	)
	rst_sync_inst (
	.clk			(clk		),
	.reset_in		(reset_async),
	.reset_out		(reset_sync	)
	);

	//  -------------------------------------------------------------------------------------
	//	读地址从格雷码变为2进制，从读时钟域变换到写时钟域
	//  -------------------------------------------------------------------------------------
	gray2bin # (
	.DATA_WIDTH		(ADDR_WIDTH		),
	.TIME_DOMAIN	("ASYNC"		),
	.RESET_VALUE	(0				)
	)
	gray2bin_inst (
	.clk			(clk			),
	.reset			(reset_sync		),
	.iv_gray		(iv_rd_addr_gray),
	.ov_bin			(wv_rd_addr_bin	)
	);

	//  -------------------------------------------------------------------------------------
	//	写逻辑
	//  -------------------------------------------------------------------------------------
	async_fifo_wr_logic # (
	.ADDR_WIDTH			(ADDR_WIDTH			)
	)
	async_fifo_wr_logic_inst (
	.clk				(clk				),
	.reset				(reset_sync			),
	.i_wr_en			(i_wr_en			),
	.iv_rd_addr_bin		(wv_rd_addr_bin		),
	.ov_wr_addr_bin		(wv_wr_addr_bin		),
	.ov_wr_addr_dpram	(ov_wr_addr_dpram	),
	.o_wr_en			(o_wr_en			),
	.o_fifo_full		(o_fifo_full		)
	);

	//  -------------------------------------------------------------------------------------
	//	写地址 2进制变为格雷码，时钟域不变
	//  -------------------------------------------------------------------------------------
	bin2gray # (
	.DATA_WIDTH		(ADDR_WIDTH		),
	.TIME_DOMAIN	("SYNC"			),
	.RESET_VALUE	(1				)
	)
	bin2gray_inst (
	.clk			(clk			),
	.reset			(reset_sync		),
	.iv_bin			(wv_wr_addr_bin	),
	.ov_gray		(ov_wr_addr_gray)
	);


endmodule
