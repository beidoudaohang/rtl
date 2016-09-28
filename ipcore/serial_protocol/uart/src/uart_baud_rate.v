//-------------------------------------------------------------------------------------------------
//  -- Corporation  : MicroRTL.com
//  -- Email        : haitaox2013@gmail.com
//  -- Module       : uart_baud_rate
//-------------------------------------------------------------------------------------------------
//  -- Description  :
//
//-------------------------------------------------------------------------------------------------
//  -- Changelog    :
//  -- Author       | Date                  | Content
//  -- Michael      | 2016/08/15 16:37:22	|
//-------------------------------------------------------------------------------------------------
//`include			"uart_baud_rate_def.v"
//time unit/precision
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module uart_baud_rate # (
	parameter	UART_CLK_FREQ_KHZ		= 40000		,	//时钟频率
	parameter	UART_BAUD_RATE			= 115200		//波特率
	)
	(
	//输入信号
	input					clk					,	//输入时钟
	output					o_16x_baud_en			//16倍波特率的采样信号
	);

	//	ref signals
	localparam		UART_BAUD_RATE_16X	= UART_BAUD_RATE*16;
	localparam		BAUD_CNT_LIMIT		= (UART_CLK_FREQ_KHZ*1000/UART_BAUD_RATE_16X)-1;
	localparam		CNT_WIDTH			= log2(BAUD_CNT_LIMIT+1);

	reg		[CNT_WIDTH-1:0]			baud_count		= 'b0;
	reg								en_16_x_baud	= 1'b0;

	//	-------------------------------------------------------------------------------------
	//	取对数，上取整
	//	-------------------------------------------------------------------------------------
	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	To set serial communication baud rate to 115,200 then en_16_x_baud must pulse
	//	High at 1,843,200Hz which is every 27.13 cycles at 50MHz. In this implementation
	//	a pulse is generated every 27 cycles resulting is a baud rate of 115,741 baud which
	//	is only 0.5% high and well within limits.
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if (baud_count==BAUD_CNT_LIMIT) begin
			baud_count		<= 'b0;
			en_16_x_baud	<= 1'b1;	// single cycle enable pulse
		end
		else begin
			baud_count		<= baud_count + 1'b1;
			en_16_x_baud	<= 1'b0;
		end
	end
	assign	o_16x_baud_en	= en_16_x_baud;

endmodule
