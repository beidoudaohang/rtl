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

`define		TESTCASE	testcase_1
module harness ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	参数定义
	//	-------------------------------------------------------------------------------------
	parameter	UART_TYPE				= `TESTCASE.UART_TYPE				;
	parameter	UART_CLK_FREQ_KHZ		= `TESTCASE.UART_CLK_FREQ_KHZ		;
	parameter	UART_BAUD_RATE			= `TESTCASE.UART_BAUD_RATE			;

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	输入
	//	-------------------------------------------------------------------------------------
	wire							clk						;
	wire							reset					;
	wire							i_uart_rx_ser			;

	//	-------------------------------------------------------------------------------------
	//	输出
	//	-------------------------------------------------------------------------------------
	wire							o_tx_fifo_full			;
	wire							o_tx_fifo_half_full		;
	wire							o_uart_tx_ser			;
	wire							o_rx_fifo_empty			;
	wire							o_rx_fifo_full			;
	wire							o_rx_fifo_half_full		;
	wire	[7:0]					ov_rx_fifo_dout			;

	//	-------------------------------------------------------------------------------------
	//	交互
	//	-------------------------------------------------------------------------------------
	wire							i_tx_fifo_wr			;
	wire	[7:0]					iv_tx_fifo_din			;
	wire							i_rx_fifo_rd			;

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	引用
	//	-------------------------------------------------------------------------------------
	assign	clk				= `TESTCASE.uart_clk			;
	assign	reset			= `TESTCASE.uart_reset			;
	assign	i_uart_rx_ser	= `TESTCASE.uart_rx_ser			;

	assign	i_tx_fifo_wr	= bfm_uart.i_tx_fifo_wr			;
	assign	iv_tx_fifo_din	= bfm_uart.iv_tx_fifo_din		;
	assign	i_rx_fifo_rd	= bfm_uart.i_rx_fifo_rd			;

	//	-------------------------------------------------------------------------------------
	//	例化 bfm
	//	-------------------------------------------------------------------------------------
	bfm_uart bfm_uart (
	.clk				(clk				),
	.i_tx_fifo_full		(o_tx_fifo_full		),
	.i_rx_fifo_empty	(o_rx_fifo_empty	),
	.iv_rx_fifo_dout	(ov_rx_fifo_dout	)
	);

	//	-------------------------------------------------------------------------------------
	//	例化uart 收发模块
	//	-------------------------------------------------------------------------------------
	uart_tx_rx # (
	.UART_TYPE				(UART_TYPE				),
	.UART_CLK_FREQ_KHZ		(UART_CLK_FREQ_KHZ		),
	.UART_BAUD_RATE			(UART_BAUD_RATE			)
	)
	uart_tx_rx_inst (
	.clk					(clk					),
	.reset					(reset					),
	.i_tx_fifo_wr			(i_tx_fifo_wr			),
	.iv_tx_fifo_din			(iv_tx_fifo_din			),
	.o_tx_fifo_full			(o_tx_fifo_full			),
	.o_tx_fifo_half_full	(o_tx_fifo_half_full	),
	.o_uart_tx_ser			(o_uart_tx_ser			),
	.i_uart_rx_ser			(i_uart_rx_ser			),
	.i_rx_fifo_rd			(i_rx_fifo_rd			),
	.o_rx_fifo_empty		(o_rx_fifo_empty		),
	.o_rx_fifo_full			(o_rx_fifo_full			),
	.o_rx_fifo_half_full	(o_rx_fifo_half_full	),
	.ov_rx_fifo_dout		(ov_rx_fifo_dout		)
	);


endmodule
