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

module bfm_uart (
	input				clk					,	//ʱ��
	input				i_tx_fifo_full		,	//tx fifo ���ź�
	input				i_rx_fifo_empty		,	//rx fifo ���ź�
	input	[7:0]		iv_rx_fifo_dout			//rx fifo �������
	);

	//	ref signals
	reg					i_tx_fifo_wr		= 1'b0	;	//tx fifo дʹ��
	reg		[7:0]		iv_tx_fifo_din		= 8'b0	;	//tx fifo ��������
	reg					i_rx_fifo_rd		= 1'b0	;	//rx fifo ��ʹ��

	//	ref ARCHITECTURE
	//	===============================================================================================
	//	ref ***bfm***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	uart wr 1 byte
	//	-------------------------------------------------------------------------------------
	task uart_wr_1byte;
		input	[7:0]	iv_wr_byte;
		begin
			#1
			wait (i_tx_fifo_full==1'b0);
			$display("at time %0d ns\t ******uart wr 1 byte\t: wr data is 0x%02x",$stime,iv_wr_byte[7:0]);
			//	-------------------------------------------------------------------------------------
			//	д��1��byte
			//	-------------------------------------------------------------------------------------
			@ (posedge clk);
			i_tx_fifo_wr	= 1'b1;
			iv_tx_fifo_din	= iv_wr_byte;
			@ (posedge clk);
			i_tx_fifo_wr	= 1'b0;
			iv_tx_fifo_din	= 8'b0;
			@ (posedge clk);
		end
	endtask

	task uart_wr_1byte_random;
		reg		[7:0]			wr_data_int;
		begin
			#1
			wr_data_int	= {$random()}%(255);
			wait (i_tx_fifo_full==1'b0);
			$display("at time %0d ns\t ******uart wr 1 byte\t: wr data is 0x%02x",$stime,wr_data_int[7:0]);
			//	-------------------------------------------------------------------------------------
			//	д��1��byte
			//	-------------------------------------------------------------------------------------
			@ (posedge clk);
			i_tx_fifo_wr	= 1'b1;
			iv_tx_fifo_din	= wr_data_int;
			@ (posedge clk);
			i_tx_fifo_wr	= 1'b0;
			iv_tx_fifo_din	= 8'b0;
			@ (posedge clk);
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	uart rd 1 byte
	//	-------------------------------------------------------------------------------------
	task uart_rd_1byte;
		begin
			#1
			wait (i_rx_fifo_empty==1'b0);
			$display("at time %0d ns\t ******uart rd 1 byte\t: rd data is 0x%02x",$stime,iv_rx_fifo_dout[7:0]);
			//	-------------------------------------------------------------------------------------
			//	����1��byte
			//	-------------------------------------------------------------------------------------
			@ (posedge clk);
			i_rx_fifo_rd	= 1'b1;
			@ (posedge clk);
			i_rx_fifo_rd	= 1'b0;
			@ (posedge clk);
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	uart rd һֱ��
	//	-------------------------------------------------------------------------------------
	task uart_rd_always;
		begin
			#1
			forever begin
				wait (i_rx_fifo_empty==1'b0);
				$display("at time %0d ns\t ******uart rd byte\t: rd data is 0x%02x",$stime,iv_rx_fifo_dout[7:0]);
				@ (posedge clk);
				i_rx_fifo_rd	= 1'b1;
				@ (posedge clk);
				i_rx_fifo_rd	= 1'b0;
				@ (posedge clk);
			end
		end
	endtask

endmodule
