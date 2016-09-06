////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.20131013
//  \   \         Application: netgen
//  /   /         Filename: fifo_w8d16.v
// /___/   /\     Timestamp: Fri May 15 14:30:39 2015
// \   \  /  \
//  \___\/\___\
//
// Command	: -w -sim -ofmt verilog F:/DAHENG/svn/hw_mer/branches/xinghaotao/zme/FPGA/1_my_ip_core/fifo/async_fifo/async_fifo_dist/src/fifo_core/fifo_distri_w8d16/tmp/_cg/fifo_w8d16.ngc F:/DAHENG/svn/hw_mer/branches/xinghaotao/zme/FPGA/1_my_ip_core/fifo/async_fifo/async_fifo_dist/src/fifo_core/fifo_distri_w8d16/tmp/_cg/fifo_w8d16.v
// Device	: 6slx9ftg256-2
// Input file	: F:/DAHENG/svn/hw_mer/branches/xinghaotao/zme/FPGA/1_my_ip_core/fifo/async_fifo/async_fifo_dist/src/fifo_core/fifo_distri_w8d16/tmp/_cg/fifo_w8d16.ngc
// Output file	: F:/DAHENG/svn/hw_mer/branches/xinghaotao/zme/FPGA/1_my_ip_core/fifo/async_fifo/async_fifo_dist/src/fifo_core/fifo_distri_w8d16/tmp/_cg/fifo_w8d16.v
// # of Modules	: 1
// Design Name	: fifo_w8d16
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

module fifo_w8d16 (
	rst, wr_clk, rd_clk, wr_en, rd_en, full, empty, din, dout
	)/* synthesis syn_black_box syn_noprune=1 */;
	input rst;
	input wr_clk;
	input rd_clk;
	input wr_en;
	input rd_en;
	output full;
	output empty;
	input [7 : 0] din;
	output [7 : 0] dout;


endmodule


