////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.20131013
//  \   \         Application: netgen
//  /   /         Filename: urb_mult.v
// /___/   /\     Timestamp: Thu Apr 16 13:26:53 2015
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -w -sim -ofmt verilog E:/Camera/hw_mer/branches/zhangqiang/u3v/mer-500-14u3x/fpga_module/u3_interface/src/u3_transfer/urb_mult/tmp/_cg/urb_mult.ngc E:/Camera/hw_mer/branches/zhangqiang/u3v/mer-500-14u3x/fpga_module/u3_interface/src/u3_transfer/urb_mult/tmp/_cg/urb_mult.v 
// Device	: 6slx9ftg256-2
// Input file	: E:/Camera/hw_mer/branches/zhangqiang/u3v/mer-500-14u3x/fpga_module/u3_interface/src/u3_transfer/urb_mult/tmp/_cg/urb_mult.ngc
// Output file	: E:/Camera/hw_mer/branches/zhangqiang/u3v/mer-500-14u3x/fpga_module/u3_interface/src/u3_transfer/urb_mult/tmp/_cg/urb_mult.v
// # of Modules	: 1
// Design Name	: urb_mult
// Xilinx        : d:\Xilinx\14.7\ISE_DS\ISE\
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

module urb_mult (
  clk, ce, a, b, p
)/* synthesis syn_black_box syn_noprune=1 */;
  input clk;
  input ce;
  input [31 : 0] a;
  input [15 : 0] b;
  output [47 : 0] p;
  
  // synthesis translate_off
  
  wire \blk00000001/sig00000126 ;
  wire \blk00000001/sig00000125 ;
  wire \blk00000001/sig00000124 ;
  wire \blk00000001/sig00000123 ;
  wire \blk00000001/sig00000122 ;
  wire \blk00000001/sig00000121 ;
  wire \blk00000001/sig00000120 ;
  wire \blk00000001/sig0000011f ;
  wire \blk00000001/sig0000011e ;
  wire \blk00000001/sig0000011d ;
  wire \blk00000001/sig0000011c ;
  wire \blk00000001/sig0000011b ;
  wire \blk00000001/sig0000011a ;
  wire \blk00000001/sig00000119 ;
  wire \blk00000001/sig00000118 ;
  wire \blk00000001/sig00000117 ;
  wire \blk00000001/sig00000116 ;
  wire \blk00000001/sig00000115 ;
  wire \blk00000001/sig00000114 ;
  wire \blk00000001/sig00000113 ;
  wire \blk00000001/sig00000112 ;
  wire \blk00000001/sig00000111 ;
  wire \blk00000001/sig00000110 ;
  wire \blk00000001/sig0000010f ;
  wire \blk00000001/sig0000010e ;
  wire \blk00000001/sig0000010d ;
  wire \blk00000001/sig0000010c ;
  wire \blk00000001/sig0000010b ;
  wire \blk00000001/sig0000010a ;
  wire \blk00000001/sig00000109 ;
  wire \blk00000001/sig00000108 ;
  wire \blk00000001/sig00000107 ;
  wire \blk00000001/sig00000106 ;
  wire \blk00000001/sig00000105 ;
  wire \blk00000001/sig00000104 ;
  wire \blk00000001/sig00000103 ;
  wire \blk00000001/sig00000102 ;
  wire \blk00000001/sig00000101 ;
  wire \blk00000001/sig00000100 ;
  wire \blk00000001/sig000000ff ;
  wire \blk00000001/sig000000fe ;
  wire \blk00000001/sig000000fd ;
  wire \blk00000001/sig000000fc ;
  wire \blk00000001/sig000000fb ;
  wire \blk00000001/sig000000fa ;
  wire \blk00000001/sig000000f9 ;
  wire \blk00000001/sig000000f8 ;
  wire \blk00000001/sig000000f7 ;
  wire \blk00000001/sig000000f6 ;
  wire \blk00000001/sig000000f5 ;
  wire \blk00000001/sig000000f4 ;
  wire \blk00000001/sig000000f3 ;
  wire \blk00000001/sig000000f2 ;
  wire \blk00000001/sig000000f1 ;
  wire \blk00000001/sig000000f0 ;
  wire \blk00000001/sig000000ef ;
  wire \blk00000001/sig000000ee ;
  wire \blk00000001/sig000000ed ;
  wire \blk00000001/sig000000ec ;
  wire \blk00000001/sig000000eb ;
  wire \blk00000001/sig000000ea ;
  wire \blk00000001/sig000000e9 ;
  wire \blk00000001/sig000000e8 ;
  wire \blk00000001/sig000000e7 ;
  wire \blk00000001/sig000000e6 ;
  wire \blk00000001/sig000000e5 ;
  wire \blk00000001/sig000000e4 ;
  wire \blk00000001/sig000000e3 ;
  wire \blk00000001/sig000000e2 ;
  wire \blk00000001/sig000000e1 ;
  wire \blk00000001/sig000000e0 ;
  wire \blk00000001/sig000000df ;
  wire \blk00000001/sig000000de ;
  wire \blk00000001/sig000000dd ;
  wire \blk00000001/sig000000dc ;
  wire \blk00000001/sig000000db ;
  wire \blk00000001/sig000000da ;
  wire \blk00000001/sig000000d9 ;
  wire \blk00000001/sig000000d8 ;
  wire \blk00000001/sig000000d7 ;
  wire \blk00000001/sig000000d6 ;
  wire \blk00000001/sig000000d5 ;
  wire \blk00000001/sig000000d4 ;
  wire \blk00000001/sig000000d3 ;
  wire \blk00000001/sig000000d2 ;
  wire \blk00000001/sig000000d1 ;
  wire \blk00000001/sig000000d0 ;
  wire \blk00000001/sig000000cf ;
  wire \blk00000001/sig000000ce ;
  wire \blk00000001/sig000000cd ;
  wire \blk00000001/sig000000cc ;
  wire \blk00000001/sig000000cb ;
  wire \blk00000001/sig000000ca ;
  wire \blk00000001/sig000000c9 ;
  wire \blk00000001/sig000000c8 ;
  wire \blk00000001/sig000000c7 ;
  wire \blk00000001/sig000000c6 ;
  wire \blk00000001/sig000000c5 ;
  wire \blk00000001/sig000000c4 ;
  wire \blk00000001/sig000000c3 ;
  wire \blk00000001/sig000000c2 ;
  wire \blk00000001/sig000000c1 ;
  wire \blk00000001/sig000000c0 ;
  wire \blk00000001/sig000000bf ;
  wire \blk00000001/sig000000be ;
  wire \blk00000001/sig000000bd ;
  wire \blk00000001/sig000000bc ;
  wire \blk00000001/sig000000bb ;
  wire \blk00000001/sig000000ba ;
  wire \blk00000001/sig000000b9 ;
  wire \blk00000001/sig000000b8 ;
  wire \blk00000001/sig000000b7 ;
  wire \blk00000001/sig000000b6 ;
  wire \blk00000001/sig000000b5 ;
  wire \blk00000001/sig000000b4 ;
  wire \blk00000001/sig000000b3 ;
  wire \blk00000001/sig000000b2 ;
  wire \blk00000001/sig000000b1 ;
  wire \blk00000001/sig000000b0 ;
  wire \blk00000001/sig000000af ;
  wire \blk00000001/sig000000ae ;
  wire \blk00000001/sig000000ad ;
  wire \blk00000001/sig000000ac ;
  wire \blk00000001/sig000000ab ;
  wire \blk00000001/sig000000aa ;
  wire \blk00000001/sig000000a9 ;
  wire \blk00000001/sig000000a8 ;
  wire \blk00000001/sig000000a7 ;
  wire \blk00000001/sig000000a6 ;
  wire \blk00000001/sig000000a5 ;
  wire \blk00000001/sig000000a4 ;
  wire \blk00000001/sig000000a3 ;
  wire \blk00000001/sig000000a2 ;
  wire \blk00000001/sig000000a1 ;
  wire \blk00000001/sig000000a0 ;
  wire \blk00000001/sig0000009f ;
  wire \blk00000001/sig0000009e ;
  wire \blk00000001/sig0000009d ;
  wire \blk00000001/sig0000009c ;
  wire \blk00000001/sig0000009b ;
  wire \blk00000001/sig0000009a ;
  wire \blk00000001/sig00000099 ;
  wire \blk00000001/sig00000098 ;
  wire \blk00000001/sig00000097 ;
  wire \blk00000001/sig00000096 ;
  wire \blk00000001/sig00000095 ;
  wire \blk00000001/sig00000094 ;
  wire \blk00000001/sig00000093 ;
  wire \blk00000001/sig00000092 ;
  wire \blk00000001/sig00000091 ;
  wire \blk00000001/sig00000090 ;
  wire \blk00000001/sig0000008f ;
  wire \blk00000001/sig0000008e ;
  wire \blk00000001/sig0000008d ;
  wire \blk00000001/sig0000008c ;
  wire \blk00000001/sig0000008b ;
  wire \blk00000001/sig0000008a ;
  wire \blk00000001/sig00000089 ;
  wire \blk00000001/sig00000088 ;
  wire \blk00000001/sig00000087 ;
  wire \blk00000001/sig00000086 ;
  wire \blk00000001/sig00000085 ;
  wire \blk00000001/sig00000084 ;
  wire \blk00000001/sig00000083 ;
  wire \blk00000001/sig00000082 ;
  wire \blk00000001/sig00000081 ;
  wire \blk00000001/sig00000080 ;
  wire \blk00000001/sig0000007f ;
  wire \blk00000001/sig0000007e ;
  wire \blk00000001/sig0000007d ;
  wire \blk00000001/sig0000007c ;
  wire \blk00000001/sig0000007b ;
  wire \blk00000001/sig0000007a ;
  wire \blk00000001/sig00000079 ;
  wire \blk00000001/sig00000078 ;
  wire \blk00000001/sig00000077 ;
  wire \blk00000001/sig00000076 ;
  wire \blk00000001/sig00000075 ;
  wire \blk00000001/sig00000074 ;
  wire \blk00000001/sig00000073 ;
  wire \blk00000001/sig00000072 ;
  wire \blk00000001/sig00000071 ;
  wire \blk00000001/sig00000070 ;
  wire \blk00000001/sig0000006f ;
  wire \blk00000001/sig0000006e ;
  wire \blk00000001/sig0000006d ;
  wire \blk00000001/sig0000006c ;
  wire \blk00000001/sig0000006b ;
  wire \blk00000001/sig0000006a ;
  wire \blk00000001/sig00000069 ;
  wire \blk00000001/sig00000068 ;
  wire \blk00000001/sig00000067 ;
  wire \blk00000001/sig00000066 ;
  wire \blk00000001/sig00000065 ;
  wire \blk00000001/sig00000064 ;
  wire \blk00000001/sig00000063 ;
  wire \NLW_blk00000001/blk00000005_CARRYOUTF_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_CARRYOUT_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<47>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<46>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<45>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<44>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<43>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<42>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<41>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<40>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<39>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<38>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<37>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<36>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<35>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<34>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<33>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<32>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<31>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<30>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<29>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<28>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<27>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<26>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<25>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<24>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<23>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<22>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<21>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<20>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<19>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<18>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<17>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<16>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<15>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<14>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<13>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<12>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<11>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<10>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<9>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<8>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<7>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<6>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<5>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<4>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<3>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<2>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<1>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_C<0>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<35>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<34>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<33>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<32>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<31>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<30>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<29>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<28>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<27>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<26>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<25>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<24>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<23>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<22>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<21>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<20>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<19>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<18>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<17>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<16>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<15>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<14>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<13>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<12>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<11>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<10>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<9>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<8>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<7>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<6>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<5>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<4>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<3>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<2>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<1>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000005_M<0>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_CARRYOUTF_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_CARRYOUT_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<17>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<16>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<15>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<14>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<13>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<12>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<11>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<10>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<9>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<8>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<7>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<6>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<5>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<4>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<3>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<2>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<1>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_BCOUT<0>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_P<47>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_P<46>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_P<45>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_P<44>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_P<43>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_P<42>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_P<41>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_P<40>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_P<39>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_P<38>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_P<37>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_P<36>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_P<35>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_P<34>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_P<33>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_P<32>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_P<31>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<35>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<34>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<33>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<32>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<31>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<30>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<29>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<28>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<27>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<26>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<25>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<24>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<23>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<22>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<21>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<20>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<19>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<18>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<17>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<16>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<15>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<14>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<13>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<12>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<11>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<10>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<9>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<8>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<7>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<6>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<5>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<4>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<3>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<2>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<1>_UNCONNECTED ;
  wire \NLW_blk00000001/blk00000004_M<0>_UNCONNECTED ;
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000036  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000126 ),
    .R(\blk00000001/sig00000106 ),
    .Q(p[0])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000035  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000125 ),
    .R(\blk00000001/sig00000106 ),
    .Q(p[1])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000034  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000124 ),
    .R(\blk00000001/sig00000106 ),
    .Q(p[2])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000033  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000123 ),
    .R(\blk00000001/sig00000106 ),
    .Q(p[3])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000032  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000122 ),
    .R(\blk00000001/sig00000106 ),
    .Q(p[4])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000031  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000121 ),
    .R(\blk00000001/sig00000106 ),
    .Q(p[5])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000030  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000120 ),
    .R(\blk00000001/sig00000106 ),
    .Q(p[6])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000002f  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig0000011f ),
    .R(\blk00000001/sig00000106 ),
    .Q(p[7])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000002e  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig0000011e ),
    .R(\blk00000001/sig00000106 ),
    .Q(p[8])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000002d  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig0000011d ),
    .R(\blk00000001/sig00000106 ),
    .Q(p[9])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000002c  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig0000011c ),
    .R(\blk00000001/sig00000106 ),
    .Q(p[10])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000002b  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig0000011b ),
    .R(\blk00000001/sig00000106 ),
    .Q(p[11])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000002a  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig0000011a ),
    .R(\blk00000001/sig00000106 ),
    .Q(p[12])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000029  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000119 ),
    .R(\blk00000001/sig00000106 ),
    .Q(p[13])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000028  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000118 ),
    .R(\blk00000001/sig00000106 ),
    .Q(p[14])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000027  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000117 ),
    .R(\blk00000001/sig00000106 ),
    .Q(p[15])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000026  (
    .C(clk),
    .CE(ce),
    .D(\blk00000001/sig00000116 ),
    .R(\blk00000001/sig00000106 ),
    .Q(p[16])
  );
  SRL16E #(
    .INIT ( 16'h0000 ))
  \blk00000001/blk00000025  (
    .A0(\blk00000001/sig00000106 ),
    .A1(\blk00000001/sig00000106 ),
    .A2(\blk00000001/sig00000106 ),
    .A3(\blk00000001/sig00000106 ),
    .CE(ce),
    .CLK(clk),
    .D(\blk00000001/sig000000e3 ),
    .Q(\blk00000001/sig00000126 )
  );
  SRL16E #(
    .INIT ( 16'h0000 ))
  \blk00000001/blk00000024  (
    .A0(\blk00000001/sig00000106 ),
    .A1(\blk00000001/sig00000106 ),
    .A2(\blk00000001/sig00000106 ),
    .A3(\blk00000001/sig00000106 ),
    .CE(ce),
    .CLK(clk),
    .D(\blk00000001/sig000000e4 ),
    .Q(\blk00000001/sig00000125 )
  );
  SRL16E #(
    .INIT ( 16'h0000 ))
  \blk00000001/blk00000023  (
    .A0(\blk00000001/sig00000106 ),
    .A1(\blk00000001/sig00000106 ),
    .A2(\blk00000001/sig00000106 ),
    .A3(\blk00000001/sig00000106 ),
    .CE(ce),
    .CLK(clk),
    .D(\blk00000001/sig000000e5 ),
    .Q(\blk00000001/sig00000124 )
  );
  SRL16E #(
    .INIT ( 16'h0000 ))
  \blk00000001/blk00000022  (
    .A0(\blk00000001/sig00000106 ),
    .A1(\blk00000001/sig00000106 ),
    .A2(\blk00000001/sig00000106 ),
    .A3(\blk00000001/sig00000106 ),
    .CE(ce),
    .CLK(clk),
    .D(\blk00000001/sig000000e6 ),
    .Q(\blk00000001/sig00000123 )
  );
  SRL16E #(
    .INIT ( 16'h0000 ))
  \blk00000001/blk00000021  (
    .A0(\blk00000001/sig00000106 ),
    .A1(\blk00000001/sig00000106 ),
    .A2(\blk00000001/sig00000106 ),
    .A3(\blk00000001/sig00000106 ),
    .CE(ce),
    .CLK(clk),
    .D(\blk00000001/sig000000e7 ),
    .Q(\blk00000001/sig00000122 )
  );
  SRL16E #(
    .INIT ( 16'h0000 ))
  \blk00000001/blk00000020  (
    .A0(\blk00000001/sig00000106 ),
    .A1(\blk00000001/sig00000106 ),
    .A2(\blk00000001/sig00000106 ),
    .A3(\blk00000001/sig00000106 ),
    .CE(ce),
    .CLK(clk),
    .D(\blk00000001/sig000000e8 ),
    .Q(\blk00000001/sig00000121 )
  );
  SRL16E #(
    .INIT ( 16'h0000 ))
  \blk00000001/blk0000001f  (
    .A0(\blk00000001/sig00000106 ),
    .A1(\blk00000001/sig00000106 ),
    .A2(\blk00000001/sig00000106 ),
    .A3(\blk00000001/sig00000106 ),
    .CE(ce),
    .CLK(clk),
    .D(\blk00000001/sig000000e9 ),
    .Q(\blk00000001/sig00000120 )
  );
  SRL16E #(
    .INIT ( 16'h0000 ))
  \blk00000001/blk0000001e  (
    .A0(\blk00000001/sig00000106 ),
    .A1(\blk00000001/sig00000106 ),
    .A2(\blk00000001/sig00000106 ),
    .A3(\blk00000001/sig00000106 ),
    .CE(ce),
    .CLK(clk),
    .D(\blk00000001/sig000000ea ),
    .Q(\blk00000001/sig0000011f )
  );
  SRL16E #(
    .INIT ( 16'h0000 ))
  \blk00000001/blk0000001d  (
    .A0(\blk00000001/sig00000106 ),
    .A1(\blk00000001/sig00000106 ),
    .A2(\blk00000001/sig00000106 ),
    .A3(\blk00000001/sig00000106 ),
    .CE(ce),
    .CLK(clk),
    .D(\blk00000001/sig000000eb ),
    .Q(\blk00000001/sig0000011e )
  );
  SRL16E #(
    .INIT ( 16'h0000 ))
  \blk00000001/blk0000001c  (
    .A0(\blk00000001/sig00000106 ),
    .A1(\blk00000001/sig00000106 ),
    .A2(\blk00000001/sig00000106 ),
    .A3(\blk00000001/sig00000106 ),
    .CE(ce),
    .CLK(clk),
    .D(\blk00000001/sig000000ec ),
    .Q(\blk00000001/sig0000011d )
  );
  SRL16E #(
    .INIT ( 16'h0000 ))
  \blk00000001/blk0000001b  (
    .A0(\blk00000001/sig00000106 ),
    .A1(\blk00000001/sig00000106 ),
    .A2(\blk00000001/sig00000106 ),
    .A3(\blk00000001/sig00000106 ),
    .CE(ce),
    .CLK(clk),
    .D(\blk00000001/sig000000ed ),
    .Q(\blk00000001/sig0000011c )
  );
  SRL16E #(
    .INIT ( 16'h0000 ))
  \blk00000001/blk0000001a  (
    .A0(\blk00000001/sig00000106 ),
    .A1(\blk00000001/sig00000106 ),
    .A2(\blk00000001/sig00000106 ),
    .A3(\blk00000001/sig00000106 ),
    .CE(ce),
    .CLK(clk),
    .D(\blk00000001/sig000000ee ),
    .Q(\blk00000001/sig0000011b )
  );
  SRL16E #(
    .INIT ( 16'h0000 ))
  \blk00000001/blk00000019  (
    .A0(\blk00000001/sig00000106 ),
    .A1(\blk00000001/sig00000106 ),
    .A2(\blk00000001/sig00000106 ),
    .A3(\blk00000001/sig00000106 ),
    .CE(ce),
    .CLK(clk),
    .D(\blk00000001/sig000000ef ),
    .Q(\blk00000001/sig0000011a )
  );
  SRL16E #(
    .INIT ( 16'h0000 ))
  \blk00000001/blk00000018  (
    .A0(\blk00000001/sig00000106 ),
    .A1(\blk00000001/sig00000106 ),
    .A2(\blk00000001/sig00000106 ),
    .A3(\blk00000001/sig00000106 ),
    .CE(ce),
    .CLK(clk),
    .D(\blk00000001/sig000000f0 ),
    .Q(\blk00000001/sig00000119 )
  );
  SRL16E #(
    .INIT ( 16'h0000 ))
  \blk00000001/blk00000017  (
    .A0(\blk00000001/sig00000106 ),
    .A1(\blk00000001/sig00000106 ),
    .A2(\blk00000001/sig00000106 ),
    .A3(\blk00000001/sig00000106 ),
    .CE(ce),
    .CLK(clk),
    .D(\blk00000001/sig000000f1 ),
    .Q(\blk00000001/sig00000118 )
  );
  SRL16E #(
    .INIT ( 16'h0000 ))
  \blk00000001/blk00000016  (
    .A0(\blk00000001/sig00000106 ),
    .A1(\blk00000001/sig00000106 ),
    .A2(\blk00000001/sig00000106 ),
    .A3(\blk00000001/sig00000106 ),
    .CE(ce),
    .CLK(clk),
    .D(\blk00000001/sig000000f2 ),
    .Q(\blk00000001/sig00000117 )
  );
  SRL16E #(
    .INIT ( 16'h0000 ))
  \blk00000001/blk00000015  (
    .A0(\blk00000001/sig00000106 ),
    .A1(\blk00000001/sig00000106 ),
    .A2(\blk00000001/sig00000106 ),
    .A3(\blk00000001/sig00000106 ),
    .CE(ce),
    .CLK(clk),
    .D(\blk00000001/sig000000f3 ),
    .Q(\blk00000001/sig00000116 )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000014  (
    .C(clk),
    .CE(ce),
    .D(a[17]),
    .Q(\blk00000001/sig00000107 )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000013  (
    .C(clk),
    .CE(ce),
    .D(a[18]),
    .Q(\blk00000001/sig00000108 )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000012  (
    .C(clk),
    .CE(ce),
    .D(a[19]),
    .Q(\blk00000001/sig00000109 )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000011  (
    .C(clk),
    .CE(ce),
    .D(a[20]),
    .Q(\blk00000001/sig0000010a )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000010  (
    .C(clk),
    .CE(ce),
    .D(a[21]),
    .Q(\blk00000001/sig0000010b )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000000f  (
    .C(clk),
    .CE(ce),
    .D(a[22]),
    .Q(\blk00000001/sig0000010c )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000000e  (
    .C(clk),
    .CE(ce),
    .D(a[23]),
    .Q(\blk00000001/sig0000010d )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000000d  (
    .C(clk),
    .CE(ce),
    .D(a[24]),
    .Q(\blk00000001/sig0000010e )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000000c  (
    .C(clk),
    .CE(ce),
    .D(a[25]),
    .Q(\blk00000001/sig0000010f )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000000b  (
    .C(clk),
    .CE(ce),
    .D(a[26]),
    .Q(\blk00000001/sig00000110 )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk0000000a  (
    .C(clk),
    .CE(ce),
    .D(a[27]),
    .Q(\blk00000001/sig00000111 )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000009  (
    .C(clk),
    .CE(ce),
    .D(a[28]),
    .Q(\blk00000001/sig00000112 )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000008  (
    .C(clk),
    .CE(ce),
    .D(a[29]),
    .Q(\blk00000001/sig00000113 )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000007  (
    .C(clk),
    .CE(ce),
    .D(a[30]),
    .Q(\blk00000001/sig00000114 )
  );
  FDE #(
    .INIT ( 1'b0 ))
  \blk00000001/blk00000006  (
    .C(clk),
    .CE(ce),
    .D(a[31]),
    .Q(\blk00000001/sig00000115 )
  );
  DSP48A1 #(
    .A0REG ( 0 ),
    .A1REG ( 1 ),
    .B0REG ( 0 ),
    .B1REG ( 1 ),
    .CARRYINREG ( 0 ),
    .CARRYINSEL ( "OPMODE5" ),
    .CREG ( 0 ),
    .DREG ( 0 ),
    .MREG ( 1 ),
    .OPMODEREG ( 0 ),
    .PREG ( 1 ),
    .RSTTYPE ( "SYNC" ),
    .CARRYOUTREG ( 0 ))
  \blk00000001/blk00000005  (
    .CECARRYIN(\blk00000001/sig00000106 ),
    .RSTC(\blk00000001/sig00000106 ),
    .RSTCARRYIN(\blk00000001/sig00000106 ),
    .CED(\blk00000001/sig00000106 ),
    .RSTD(\blk00000001/sig00000106 ),
    .CEOPMODE(\blk00000001/sig00000106 ),
    .CEC(\blk00000001/sig00000106 ),
    .CARRYOUTF(\NLW_blk00000001/blk00000005_CARRYOUTF_UNCONNECTED ),
    .RSTOPMODE(\blk00000001/sig00000106 ),
    .RSTM(\blk00000001/sig00000106 ),
    .CLK(clk),
    .RSTB(\blk00000001/sig00000106 ),
    .CEM(ce),
    .CEB(ce),
    .CARRYIN(\blk00000001/sig00000106 ),
    .CEP(ce),
    .CEA(ce),
    .CARRYOUT(\NLW_blk00000001/blk00000005_CARRYOUT_UNCONNECTED ),
    .RSTA(\blk00000001/sig00000106 ),
    .RSTP(\blk00000001/sig00000106 ),
    .B({\blk00000001/sig00000106 , \blk00000001/sig00000106 , b[15], b[14], b[13], b[12], b[11], b[10], b[9], b[8], b[7], b[6], b[5], b[4], b[3], b[2]
, b[1], b[0]}),
    .BCOUT({\blk00000001/sig00000105 , \blk00000001/sig00000104 , \blk00000001/sig00000103 , \blk00000001/sig00000102 , \blk00000001/sig00000101 , 
\blk00000001/sig00000100 , \blk00000001/sig000000ff , \blk00000001/sig000000fe , \blk00000001/sig000000fd , \blk00000001/sig000000fc , 
\blk00000001/sig000000fb , \blk00000001/sig000000fa , \blk00000001/sig000000f9 , \blk00000001/sig000000f8 , \blk00000001/sig000000f7 , 
\blk00000001/sig000000f6 , \blk00000001/sig000000f5 , \blk00000001/sig000000f4 }),
    .PCIN({\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , 
\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , 
\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , 
\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , 
\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , 
\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , 
\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , 
\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , 
\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , 
\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 }),
    .C({\NLW_blk00000001/blk00000005_C<47>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<46>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_C<45>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<44>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<43>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_C<42>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<41>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<40>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_C<39>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<38>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<37>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_C<36>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<35>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<34>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_C<33>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<32>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<31>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_C<30>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<29>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<28>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_C<27>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<26>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<25>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_C<24>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<23>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<22>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_C<21>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<20>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<19>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_C<18>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<17>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<16>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_C<15>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<14>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<13>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_C<12>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<11>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<10>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_C<9>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<8>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<7>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_C<6>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<5>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<4>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_C<3>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<2>_UNCONNECTED , \NLW_blk00000001/blk00000005_C<1>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_C<0>_UNCONNECTED }),
    .P({\blk00000001/sig000000e2 , \blk00000001/sig000000e1 , \blk00000001/sig000000e0 , \blk00000001/sig000000df , \blk00000001/sig000000de , 
\blk00000001/sig000000dd , \blk00000001/sig000000dc , \blk00000001/sig000000db , \blk00000001/sig000000da , \blk00000001/sig000000d9 , 
\blk00000001/sig000000d8 , \blk00000001/sig000000d7 , \blk00000001/sig000000d6 , \blk00000001/sig000000d5 , \blk00000001/sig000000d4 , 
\blk00000001/sig000000d3 , \blk00000001/sig000000d2 , \blk00000001/sig000000d1 , \blk00000001/sig000000d0 , \blk00000001/sig000000cf , 
\blk00000001/sig000000ce , \blk00000001/sig000000cd , \blk00000001/sig000000cc , \blk00000001/sig000000cb , \blk00000001/sig000000ca , 
\blk00000001/sig000000c9 , \blk00000001/sig000000c8 , \blk00000001/sig000000c7 , \blk00000001/sig000000c6 , \blk00000001/sig000000c5 , 
\blk00000001/sig000000c4 , \blk00000001/sig000000f3 , \blk00000001/sig000000f2 , \blk00000001/sig000000f1 , \blk00000001/sig000000f0 , 
\blk00000001/sig000000ef , \blk00000001/sig000000ee , \blk00000001/sig000000ed , \blk00000001/sig000000ec , \blk00000001/sig000000eb , 
\blk00000001/sig000000ea , \blk00000001/sig000000e9 , \blk00000001/sig000000e8 , \blk00000001/sig000000e7 , \blk00000001/sig000000e6 , 
\blk00000001/sig000000e5 , \blk00000001/sig000000e4 , \blk00000001/sig000000e3 }),
    .OPMODE({\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , 
\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000093 }),
    .D({\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , 
\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , 
\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , 
\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 }),
    .PCOUT({\blk00000001/sig000000c3 , \blk00000001/sig000000c2 , \blk00000001/sig000000c1 , \blk00000001/sig000000c0 , \blk00000001/sig000000bf , 
\blk00000001/sig000000be , \blk00000001/sig000000bd , \blk00000001/sig000000bc , \blk00000001/sig000000bb , \blk00000001/sig000000ba , 
\blk00000001/sig000000b9 , \blk00000001/sig000000b8 , \blk00000001/sig000000b7 , \blk00000001/sig000000b6 , \blk00000001/sig000000b5 , 
\blk00000001/sig000000b4 , \blk00000001/sig000000b3 , \blk00000001/sig000000b2 , \blk00000001/sig000000b1 , \blk00000001/sig000000b0 , 
\blk00000001/sig000000af , \blk00000001/sig000000ae , \blk00000001/sig000000ad , \blk00000001/sig000000ac , \blk00000001/sig000000ab , 
\blk00000001/sig000000aa , \blk00000001/sig000000a9 , \blk00000001/sig000000a8 , \blk00000001/sig000000a7 , \blk00000001/sig000000a6 , 
\blk00000001/sig000000a5 , \blk00000001/sig000000a4 , \blk00000001/sig000000a3 , \blk00000001/sig000000a2 , \blk00000001/sig000000a1 , 
\blk00000001/sig000000a0 , \blk00000001/sig0000009f , \blk00000001/sig0000009e , \blk00000001/sig0000009d , \blk00000001/sig0000009c , 
\blk00000001/sig0000009b , \blk00000001/sig0000009a , \blk00000001/sig00000099 , \blk00000001/sig00000098 , \blk00000001/sig00000097 , 
\blk00000001/sig00000096 , \blk00000001/sig00000095 , \blk00000001/sig00000094 }),
    .A({\blk00000001/sig00000106 , a[16], a[15], a[14], a[13], a[12], a[11], a[10], a[9], a[8], a[7], a[6], a[5], a[4], a[3], a[2], a[1], a[0]}),
    .M({\NLW_blk00000001/blk00000005_M<35>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<34>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_M<33>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<32>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<31>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_M<30>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<29>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<28>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_M<27>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<26>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<25>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_M<24>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<23>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<22>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_M<21>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<20>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<19>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_M<18>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<17>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<16>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_M<15>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<14>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<13>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_M<12>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<11>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<10>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_M<9>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<8>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<7>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_M<6>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<5>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<4>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_M<3>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<2>_UNCONNECTED , \NLW_blk00000001/blk00000005_M<1>_UNCONNECTED , 
\NLW_blk00000001/blk00000005_M<0>_UNCONNECTED })
  );
  DSP48A1 #(
    .A0REG ( 1 ),
    .A1REG ( 1 ),
    .B0REG ( 1 ),
    .B1REG ( 1 ),
    .CARRYINREG ( 0 ),
    .CARRYINSEL ( "OPMODE5" ),
    .CREG ( 1 ),
    .DREG ( 0 ),
    .MREG ( 1 ),
    .OPMODEREG ( 0 ),
    .PREG ( 1 ),
    .RSTTYPE ( "SYNC" ),
    .CARRYOUTREG ( 0 ))
  \blk00000001/blk00000004  (
    .CECARRYIN(\blk00000001/sig00000106 ),
    .RSTC(\blk00000001/sig00000106 ),
    .RSTCARRYIN(\blk00000001/sig00000106 ),
    .CED(\blk00000001/sig00000106 ),
    .RSTD(\blk00000001/sig00000106 ),
    .CEOPMODE(\blk00000001/sig00000106 ),
    .CEC(ce),
    .CARRYOUTF(\NLW_blk00000001/blk00000004_CARRYOUTF_UNCONNECTED ),
    .RSTOPMODE(\blk00000001/sig00000106 ),
    .RSTM(\blk00000001/sig00000106 ),
    .CLK(clk),
    .RSTB(\blk00000001/sig00000106 ),
    .CEM(ce),
    .CEB(ce),
    .CARRYIN(\blk00000001/sig00000106 ),
    .CEP(ce),
    .CEA(ce),
    .CARRYOUT(\NLW_blk00000001/blk00000004_CARRYOUT_UNCONNECTED ),
    .RSTA(\blk00000001/sig00000106 ),
    .RSTP(\blk00000001/sig00000106 ),
    .B({\blk00000001/sig00000105 , \blk00000001/sig00000104 , \blk00000001/sig00000103 , \blk00000001/sig00000102 , \blk00000001/sig00000101 , 
\blk00000001/sig00000100 , \blk00000001/sig000000ff , \blk00000001/sig000000fe , \blk00000001/sig000000fd , \blk00000001/sig000000fc , 
\blk00000001/sig000000fb , \blk00000001/sig000000fa , \blk00000001/sig000000f9 , \blk00000001/sig000000f8 , \blk00000001/sig000000f7 , 
\blk00000001/sig000000f6 , \blk00000001/sig000000f5 , \blk00000001/sig000000f4 }),
    .BCOUT({\NLW_blk00000001/blk00000004_BCOUT<17>_UNCONNECTED , \NLW_blk00000001/blk00000004_BCOUT<16>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_BCOUT<15>_UNCONNECTED , \NLW_blk00000001/blk00000004_BCOUT<14>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_BCOUT<13>_UNCONNECTED , \NLW_blk00000001/blk00000004_BCOUT<12>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_BCOUT<11>_UNCONNECTED , \NLW_blk00000001/blk00000004_BCOUT<10>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_BCOUT<9>_UNCONNECTED , \NLW_blk00000001/blk00000004_BCOUT<8>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_BCOUT<7>_UNCONNECTED , \NLW_blk00000001/blk00000004_BCOUT<6>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_BCOUT<5>_UNCONNECTED , \NLW_blk00000001/blk00000004_BCOUT<4>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_BCOUT<3>_UNCONNECTED , \NLW_blk00000001/blk00000004_BCOUT<2>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_BCOUT<1>_UNCONNECTED , \NLW_blk00000001/blk00000004_BCOUT<0>_UNCONNECTED }),
    .PCIN({\blk00000001/sig000000c3 , \blk00000001/sig000000c2 , \blk00000001/sig000000c1 , \blk00000001/sig000000c0 , \blk00000001/sig000000bf , 
\blk00000001/sig000000be , \blk00000001/sig000000bd , \blk00000001/sig000000bc , \blk00000001/sig000000bb , \blk00000001/sig000000ba , 
\blk00000001/sig000000b9 , \blk00000001/sig000000b8 , \blk00000001/sig000000b7 , \blk00000001/sig000000b6 , \blk00000001/sig000000b5 , 
\blk00000001/sig000000b4 , \blk00000001/sig000000b3 , \blk00000001/sig000000b2 , \blk00000001/sig000000b1 , \blk00000001/sig000000b0 , 
\blk00000001/sig000000af , \blk00000001/sig000000ae , \blk00000001/sig000000ad , \blk00000001/sig000000ac , \blk00000001/sig000000ab , 
\blk00000001/sig000000aa , \blk00000001/sig000000a9 , \blk00000001/sig000000a8 , \blk00000001/sig000000a7 , \blk00000001/sig000000a6 , 
\blk00000001/sig000000a5 , \blk00000001/sig000000a4 , \blk00000001/sig000000a3 , \blk00000001/sig000000a2 , \blk00000001/sig000000a1 , 
\blk00000001/sig000000a0 , \blk00000001/sig0000009f , \blk00000001/sig0000009e , \blk00000001/sig0000009d , \blk00000001/sig0000009c , 
\blk00000001/sig0000009b , \blk00000001/sig0000009a , \blk00000001/sig00000099 , \blk00000001/sig00000098 , \blk00000001/sig00000097 , 
\blk00000001/sig00000096 , \blk00000001/sig00000095 , \blk00000001/sig00000094 }),
    .C({\blk00000001/sig000000e2 , \blk00000001/sig000000e2 , \blk00000001/sig000000e2 , \blk00000001/sig000000e2 , \blk00000001/sig000000e2 , 
\blk00000001/sig000000e2 , \blk00000001/sig000000e2 , \blk00000001/sig000000e2 , \blk00000001/sig000000e2 , \blk00000001/sig000000e2 , 
\blk00000001/sig000000e2 , \blk00000001/sig000000e2 , \blk00000001/sig000000e2 , \blk00000001/sig000000e2 , \blk00000001/sig000000e2 , 
\blk00000001/sig000000e2 , \blk00000001/sig000000e2 , \blk00000001/sig000000e2 , \blk00000001/sig000000e1 , \blk00000001/sig000000e0 , 
\blk00000001/sig000000df , \blk00000001/sig000000de , \blk00000001/sig000000dd , \blk00000001/sig000000dc , \blk00000001/sig000000db , 
\blk00000001/sig000000da , \blk00000001/sig000000d9 , \blk00000001/sig000000d8 , \blk00000001/sig000000d7 , \blk00000001/sig000000d6 , 
\blk00000001/sig000000d5 , \blk00000001/sig000000d4 , \blk00000001/sig000000d3 , \blk00000001/sig000000d2 , \blk00000001/sig000000d1 , 
\blk00000001/sig000000d0 , \blk00000001/sig000000cf , \blk00000001/sig000000ce , \blk00000001/sig000000cd , \blk00000001/sig000000cc , 
\blk00000001/sig000000cb , \blk00000001/sig000000ca , \blk00000001/sig000000c9 , \blk00000001/sig000000c8 , \blk00000001/sig000000c7 , 
\blk00000001/sig000000c6 , \blk00000001/sig000000c5 , \blk00000001/sig000000c4 }),
    .P({\NLW_blk00000001/blk00000004_P<47>_UNCONNECTED , \NLW_blk00000001/blk00000004_P<46>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_P<45>_UNCONNECTED , \NLW_blk00000001/blk00000004_P<44>_UNCONNECTED , \NLW_blk00000001/blk00000004_P<43>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_P<42>_UNCONNECTED , \NLW_blk00000001/blk00000004_P<41>_UNCONNECTED , \NLW_blk00000001/blk00000004_P<40>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_P<39>_UNCONNECTED , \NLW_blk00000001/blk00000004_P<38>_UNCONNECTED , \NLW_blk00000001/blk00000004_P<37>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_P<36>_UNCONNECTED , \NLW_blk00000001/blk00000004_P<35>_UNCONNECTED , \NLW_blk00000001/blk00000004_P<34>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_P<33>_UNCONNECTED , \NLW_blk00000001/blk00000004_P<32>_UNCONNECTED , \NLW_blk00000001/blk00000004_P<31>_UNCONNECTED , 
p[47], p[46], p[45], p[44], p[43], p[42], p[41], p[40], p[39], p[38], p[37], p[36], p[35], p[34], p[33], p[32], p[31], p[30], p[29], p[28], p[27], 
p[26], p[25], p[24], p[23], p[22], p[21], p[20], p[19], p[18], p[17]}),
    .OPMODE({\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000093 , 
\blk00000001/sig00000093 , \blk00000001/sig00000106 , \blk00000001/sig00000093 }),
    .D({\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , 
\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , 
\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , 
\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 }),
    .PCOUT({\blk00000001/sig00000063 , \blk00000001/sig00000064 , \blk00000001/sig00000065 , \blk00000001/sig00000066 , \blk00000001/sig00000067 , 
\blk00000001/sig00000068 , \blk00000001/sig00000069 , \blk00000001/sig0000006a , \blk00000001/sig0000006b , \blk00000001/sig0000006c , 
\blk00000001/sig0000006d , \blk00000001/sig0000006e , \blk00000001/sig0000006f , \blk00000001/sig00000070 , \blk00000001/sig00000071 , 
\blk00000001/sig00000072 , \blk00000001/sig00000073 , \blk00000001/sig00000074 , \blk00000001/sig00000075 , \blk00000001/sig00000076 , 
\blk00000001/sig00000077 , \blk00000001/sig00000078 , \blk00000001/sig00000079 , \blk00000001/sig0000007a , \blk00000001/sig0000007b , 
\blk00000001/sig0000007c , \blk00000001/sig0000007d , \blk00000001/sig0000007e , \blk00000001/sig0000007f , \blk00000001/sig00000080 , 
\blk00000001/sig00000081 , \blk00000001/sig00000082 , \blk00000001/sig00000083 , \blk00000001/sig00000084 , \blk00000001/sig00000085 , 
\blk00000001/sig00000086 , \blk00000001/sig00000087 , \blk00000001/sig00000088 , \blk00000001/sig00000089 , \blk00000001/sig0000008a , 
\blk00000001/sig0000008b , \blk00000001/sig0000008c , \blk00000001/sig0000008d , \blk00000001/sig0000008e , \blk00000001/sig0000008f , 
\blk00000001/sig00000090 , \blk00000001/sig00000091 , \blk00000001/sig00000092 }),
    .A({\blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000106 , \blk00000001/sig00000115 , \blk00000001/sig00000114 , 
\blk00000001/sig00000113 , \blk00000001/sig00000112 , \blk00000001/sig00000111 , \blk00000001/sig00000110 , \blk00000001/sig0000010f , 
\blk00000001/sig0000010e , \blk00000001/sig0000010d , \blk00000001/sig0000010c , \blk00000001/sig0000010b , \blk00000001/sig0000010a , 
\blk00000001/sig00000109 , \blk00000001/sig00000108 , \blk00000001/sig00000107 }),
    .M({\NLW_blk00000001/blk00000004_M<35>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<34>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_M<33>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<32>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<31>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_M<30>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<29>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<28>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_M<27>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<26>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<25>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_M<24>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<23>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<22>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_M<21>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<20>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<19>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_M<18>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<17>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<16>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_M<15>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<14>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<13>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_M<12>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<11>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<10>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_M<9>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<8>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<7>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_M<6>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<5>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<4>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_M<3>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<2>_UNCONNECTED , \NLW_blk00000001/blk00000004_M<1>_UNCONNECTED , 
\NLW_blk00000001/blk00000004_M<0>_UNCONNECTED })
  );
  GND   \blk00000001/blk00000003  (
    .G(\blk00000001/sig00000106 )
  );
  VCC   \blk00000001/blk00000002  (
    .P(\blk00000001/sig00000093 )
  );

// synthesis translate_on

endmodule

// synthesis translate_off

`ifndef GLBL
`define GLBL

`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;

    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule

`endif

// synthesis translate_on
