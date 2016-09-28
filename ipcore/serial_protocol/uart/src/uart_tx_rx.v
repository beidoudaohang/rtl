//-------------------------------------------------------------------------------------------------
//  -- Corporation  : MicroRTL.com
//  -- Email        : haitaox2013@gmail.com
//  -- Module       : uart_tx_rx
//-------------------------------------------------------------------------------------------------
//  -- Description  :
//
//-------------------------------------------------------------------------------------------------
//  -- Changelog    :
//  -- Author       | Date                  | Content
//  -- Michael      | 2016/08/15 16:29:59	|
//-------------------------------------------------------------------------------------------------
//`include			"uart_tx_rx_def.v"
//time unit/precision
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module uart_tx_rx # (
	parameter	UART_TYPE				= "TXRX"	,	//"TX":ONLY TX."RX":ONLY RX."TXRX" or "RXTX":BOTH RX & TX
	parameter	UART_CLK_FREQ_KHZ		= 40000		,	//ʱ��Ƶ��
	parameter	UART_BAUD_RATE			= 115200		//������
	)
	(
	input			clk					,	//��ʱ��
	input			reset				,	//��λ
	//uart tx
	input			i_tx_fifo_wr		,	//tx fifo ��д�ź�
	input	[7:0]	iv_tx_fifo_din		,	//tx fifo �������ź�
	output			o_tx_fifo_full		,	//tx fifo �����ź�
	output			o_tx_fifo_half_full	,	//tx fifo �İ����ź�
	output			o_uart_tx_ser		,	//uart���Ͷ˿�
	//uart rx
	input			i_uart_rx_ser		,	//uart���ն˿�
	input			i_rx_fifo_rd		,	//fifo���ź�
	output			o_rx_fifo_empty		,	//fifo��״̬
	output			o_rx_fifo_full		,	//fifo��״̬
	output			o_rx_fifo_half_full	,	//fifo����״̬
	output	[7:0]	ov_rx_fifo_dout			//fifo�������
	);

	//	ref signals

	wire			w_16x_baud_en		;	//�����ʵ�16������ʹ���źţ��ߵ�ƽ��Ч��1��clk�Ŀ��


	//	ref ARCHITECTURE


	//	-------------------------------------------------------------------------------------
	//	uart baud rate ģ��
	//	-------------------------------------------------------------------------------------
	uart_baud_rate # (
	.UART_CLK_FREQ_KHZ		(UART_CLK_FREQ_KHZ		),
	.UART_BAUD_RATE			(UART_BAUD_RATE			)
	)
	uart_baud_rate_inst (
	.clk					(clk					),
	.o_16x_baud_en			(w_16x_baud_en			)
	);

	//	-------------------------------------------------------------------------------------
	//	uart tx ģ��
	//	-------------------------------------------------------------------------------------
	generate
		if(UART_TYPE=="TX" || UART_TYPE=="TXRX" || UART_TYPE=="RXTX") begin
			uart_tx_byte uart_tx_byte_inst (
			.clk					(clk					),
			.reset					(reset					),
			.i_16x_baud_en			(w_16x_baud_en			),
			.i_tx_fifo_wr			(i_tx_fifo_wr			),
			.iv_tx_fifo_din			(iv_tx_fifo_din			),
			.o_tx_fifo_full			(o_tx_fifo_full			),
			.o_tx_fifo_half_full	(o_tx_fifo_half_full	),
			.o_uart_tx_ser			(o_uart_tx_ser			)
			);
		end
		else begin
			assign	o_tx_fifo_full		= 1'b0;
			assign	o_tx_fifo_half_full	= 1'b0;
			assign	o_uart_tx_ser		= 1'b1;
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	uart rx ģ��
	//	-------------------------------------------------------------------------------------
	generate
		if(UART_TYPE=="RX" || UART_TYPE=="TXRX" || UART_TYPE=="RXTX") begin
			uart_rx_byte uart_rx_byte_inst (
			.clk					(clk					),
			.reset					(reset					),
			.i_uart_rx_ser			(i_uart_rx_ser			),
			.i_16x_baud_en			(w_16x_baud_en			),
			.i_rx_fifo_rd			(i_rx_fifo_rd			),
			.o_rx_fifo_empty		(o_rx_fifo_empty		),
			.o_rx_fifo_full			(o_rx_fifo_full			),
			.o_rx_fifo_half_full	(o_rx_fifo_half_full	),
			.ov_rx_fifo_dout		(ov_rx_fifo_dout		)
			);
		end
		else begin
			assign	o_rx_fifo_empty		= 1'b1;
			assign	o_rx_fifo_full		= 1'b0;
			assign	o_rx_fifo_half_full	= 1'b0;
			assign	ov_rx_fifo_dout		= 8'b0;
		end
	endgenerate

endmodule
