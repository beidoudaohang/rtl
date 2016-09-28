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
//  -- Michael      | 2014/11/27 11:19:47	|
//-------------------------------------------------------------------------------------------------
//`include			"_def.v"
//time unit/precision
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------


module uart_rx_byte (
	input			clk					,	//主时钟
	input			reset				,	//复位
	input			i_uart_rx_ser		,	//uart接收端口
	input			i_16x_baud_en		,	//波特率的16倍速率使能信号，高电平有效，1个clk的宽度
	input			i_rx_fifo_rd		,	//fifo读信号
	output			o_rx_fifo_empty		,	//fifo空状态
	output			o_rx_fifo_full		,	//fifo满状态
	output			o_rx_fifo_half_full	,	//fifo半满状态
	output	[7:0]	ov_rx_fifo_dout			//fifo数据输出
	);

	//	ref signals
	wire				w_fifo_wr		;
	wire	[7:0]		wv_fifo_din		;


	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	uart rx 接收模块
	//  -------------------------------------------------------------------------------------
	uart_rx_bit uart_rx_bit_inst (
	.clk			(clk			),
	.i_uart_rx_ser	(i_uart_rx_ser	),
	.i_16x_baud_en	(i_16x_baud_en	),
	.o_fifo_wr		(w_fifo_wr		),
	.ov_fifo_din	(wv_fifo_din	)
	);

	//  -------------------------------------------------------------------------------------
	//	同步fifo
	//  -------------------------------------------------------------------------------------
	sync_fifo_srl_w8d16 sync_fifo_srl_w8d16_inst (
	.reset			(reset				),
	.clk			(clk				),
	.iv_din			(wv_fifo_din		),
	.i_wr			(w_fifo_wr			),
	.o_full			(o_rx_fifo_full		),
	.o_half_full	(o_rx_fifo_half_full),
	.i_rd			(i_rx_fifo_rd		),
	.ov_dout		(ov_rx_fifo_dout	),
	.o_empty		(o_rx_fifo_empty 	)
	);


endmodule
