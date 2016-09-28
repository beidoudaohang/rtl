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
//  -- Michael      | 2014/11/27 10:38:16	|
//-------------------------------------------------------------------------------------------------
//`include			"_def.v"
//time unit/precision
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module uart_tx_byte (
	input			clk					,	//主时钟
	input			reset				,	//复位
	input			i_16x_baud_en		,	//波特率的16倍速率使能信号，高电平有效，1个clk的宽度
	input			i_tx_fifo_wr		,	//tx fifo 的写信号
	input	[7:0]	iv_tx_fifo_din		,	//tx fifo 的数据信号
	output			o_tx_fifo_full		,	//tx fifo 的满信号
	output			o_tx_fifo_half_full	,	//tx fifo 的半满信号
	output			o_uart_tx_ser			//uart发送端口
	);

	//	ref signals
	wire	[7:0]			wv_fifo_dout	;
	wire					w_fifo_empty	;
	wire					w_fifo_rd		;

	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	同步fifo
	//  -------------------------------------------------------------------------------------
	sync_fifo_srl_w8d16 sync_fifo_srl_w8d16_inst (
	.reset			(reset					),
	.clk			(clk					),
	.iv_din			(iv_tx_fifo_din			),
	.i_wr			(i_tx_fifo_wr			),
	.o_full			(o_tx_fifo_full			),
	.o_half_full	(o_tx_fifo_half_full	),
	.i_rd			(w_fifo_rd				),
	.ov_dout		(wv_fifo_dout			),
	.o_empty		(w_fifo_empty			)
	);

	//  -------------------------------------------------------------------------------------
	//	uart tx 发送模块
	//  -------------------------------------------------------------------------------------
	uart_tx_bit uart_tx_bit_inst (
	.clk			(clk			),
	.i_16x_baud_en	(i_16x_baud_en	),
	.iv_fifo_dout	(wv_fifo_dout	),
	.i_fifo_empty	(w_fifo_empty	),
	.o_fifo_rd		(w_fifo_rd		),
	.o_uart_tx_ser	(o_uart_tx_ser	)
	);



endmodule
