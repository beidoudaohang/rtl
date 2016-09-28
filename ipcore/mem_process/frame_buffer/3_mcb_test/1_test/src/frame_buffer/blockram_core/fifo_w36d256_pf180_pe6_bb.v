////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.20131013
//  \   \         Application: netgen
//  /   /         Filename: fifo_w36d256_pf180_pe6.v
// /___/   /\     Timestamp: Tue May 20 16:56:38 2014
// \   \  /  \
//  \___\/\___\
//
// Command	: -w -sim -ofmt verilog F:/DAHENG/svn/hw_mer/branches/xinghaotao/fpga_module/frame_buffer/src/blockram_core/tmp/_cg/fifo_w36d256_pf180_pe6.ngc F:/DAHENG/svn/hw_mer/branches/xinghaotao/fpga_module/frame_buffer/src/blockram_core/tmp/_cg/fifo_w36d256_pf180_pe6.v
// Device	: 6slx150fgg676-3
// Input file	: F:/DAHENG/svn/hw_mer/branches/xinghaotao/fpga_module/frame_buffer/src/blockram_core/tmp/_cg/fifo_w36d256_pf180_pe6.ngc
// Output file	: F:/DAHENG/svn/hw_mer/branches/xinghaotao/fpga_module/frame_buffer/src/blockram_core/tmp/_cg/fifo_w36d256_pf180_pe6.v
// # of Modules	: 1
// Design Name	: fifo_w36d256_pf180_pe6
// Xilinx        : D:\tools\Xilinx\14.7\ISE_DS\ISE\
//
// Purpose:
//     This verilog netlist is a verification model and uses simulation
//     primitives which may not represent the true implementation of the
//     device, however the netlist is functionally correct and should not
//     be modified. This file cannot be synthesized and should only be used
//     with supported simulation tools.
//
// Reference:
//     Command Line Tools User Guide, Chapter 23 and Synthesis and Simulation Design Guide, Chapter 6
//
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/1 ps

module fifo_w36d256_pf180_pe6 (
	rst, wr_clk, rd_clk, wr_en, rd_en, full, empty, prog_full, prog_empty, din, dout
	);
	input rst;
	input wr_clk;
	input rd_clk;
	input wr_en;
	input rd_en;
	output full;
	output empty;
	output prog_full;
	output prog_empty;
	input [35 : 0] din;
	output [35 : 0] dout;

endmodule
