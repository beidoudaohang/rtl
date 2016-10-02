////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2013 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: P.20131013
//  \   \         Application: netgen
//  /   /         Filename: frame_buf_back_fifo_ww66wd512rw33wd1024_pf440.v
// /___/   /\     Timestamp: Thu Sep 29 16:31:05 2016
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -w -sim -ofmt verilog F:/DAHENG/hw_mer/branches/xinghaotao/u3v/mer-131-210u3x-multi-roi/fpga_module/frame_buffer/src/frame_buf_back_fifo/tmp/_cg/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440.ngc F:/DAHENG/hw_mer/branches/xinghaotao/u3v/mer-131-210u3x-multi-roi/fpga_module/frame_buffer/src/frame_buf_back_fifo/tmp/_cg/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440.v 
// Device	: 6slx16ftg256-2
// Input file	: F:/DAHENG/hw_mer/branches/xinghaotao/u3v/mer-131-210u3x-multi-roi/fpga_module/frame_buffer/src/frame_buf_back_fifo/tmp/_cg/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440.ngc
// Output file	: F:/DAHENG/hw_mer/branches/xinghaotao/u3v/mer-131-210u3x-multi-roi/fpga_module/frame_buffer/src/frame_buf_back_fifo/tmp/_cg/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440.v
// # of Modules	: 1
// Design Name	: frame_buf_back_fifo_ww66wd512rw33wd1024_pf440
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

module frame_buf_back_fifo_ww66wd512rw33wd1024_pf440 (
  rst, wr_clk, rd_clk, wr_en, rd_en, full, empty, prog_full, din, dout
)/* synthesis syn_black_box syn_noprune=1 */;
  input rst;
  input wr_clk;
  input rd_clk;
  input wr_en;
  input rd_en;
  output full;
  output empty;
  output prog_full;
  input [65 : 0] din;
  output [32 : 0] dout;
  
  // synthesis translate_off
  
  wire N0;
  wire N1;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ;
  wire \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/prog_full_i ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i_149 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_158 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/empty_fwft_i_159 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d2_203 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/RST_FULL_GEN_204 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_6_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp1 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_310 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/comp1_GND_266_o_MUX_61_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/comp2 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/comp1 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_GND_12_o_MUX_2_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_comb ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_GND_12_o_MUX_1_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_comb ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_d2_318 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_d1_319 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_320 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_d2_321 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_d1_322 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_323 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d3_324 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d1_325 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/tmp_ram_rd_en ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[9]_GND_251_o_add_0_OUT_xor<6>11_378 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<1> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<2> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<3> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<4> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<5> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<6> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<7> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<8> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<9> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1-In ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/going_empty_fwft_leaving_empty_fwft_OR_8_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/empty_fwft_fb_393 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<9>_412 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<8>_413 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<8>_414 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<7>_415 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<7>_416 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<6>_417 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<6>_418 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<5>_419 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<5>_420 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<4>_421 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<4>_422 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<3>_423 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<3>_424 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<2>_425 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<2>_426 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<1>_427 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<1>_428 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<0>_429 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<2> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<3> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<4> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<5> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<6> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<7> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<8> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<9> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/Madd_gic0.gc0.count[8]_GND_264_o_add_0_OUT_xor<6>11_446 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<1> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<2> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<3> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<4> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<5> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<6> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<7> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<8> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_12_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_11_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_10_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_9_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_8_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_7_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_6_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_23_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_22_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_21_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_20_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_19_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_18_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_17_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_16_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[0]_RD_PNTR[1]_XOR_53_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[1]_RD_PNTR[2]_XOR_52_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[2]_RD_PNTR[3]_XOR_51_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[3]_RD_PNTR[4]_XOR_50_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[4]_RD_PNTR[5]_XOR_49_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[5]_RD_PNTR[6]_XOR_48_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[6]_RD_PNTR[7]_XOR_47_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[7]_RD_PNTR[8]_XOR_46_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[8]_RD_PNTR[9]_XOR_45_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[0]_WR_PNTR[1]_XOR_8_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[1]_WR_PNTR[2]_XOR_7_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[2]_WR_PNTR[3]_XOR_6_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[3]_WR_PNTR[4]_XOR_5_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[4]_WR_PNTR[5]_XOR_4_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[5]_WR_PNTR[6]_XOR_3_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[6]_WR_PNTR[7]_XOR_2_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[7]_WR_PNTR[8]_XOR_1_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_13_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<0> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<1> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<2> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<3> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<4> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<5> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<6> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<7> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<8> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<9> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<0> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<1> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<2> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<3> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<4> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<5> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<6> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<7> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<8> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<0> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<1> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<2> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<3> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<4> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<5> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<6> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<7> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<8> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<0> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<1> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<2> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<3> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<4> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<5> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<6> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<7> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<8> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<0> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<1> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<2> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<3> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<4> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<5> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<6> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<7> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<8> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<9> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<0> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<1> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<2> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<3> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<4> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<5> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<6> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<7> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<8> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<9> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus1<0>_inv ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus2<1>_inv ;
  wire N4;
  wire N10;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/prog_full_i_rstpot_549 ;
  wire N12;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_0_dpot_551 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_1_dpot_552 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_2_dpot_553 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_3_dpot_554 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_4_dpot_555 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_5_dpot_556 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_6_dpot_557 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_7_dpot_558 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_8_dpot_559 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_9_dpot_560 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_10_dpot_561 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_11_dpot_562 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_12_dpot_563 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_13_dpot_564 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_14_dpot_565 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_15_dpot_566 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_16_dpot_567 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_17_dpot_568 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_18_dpot_569 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_19_dpot_570 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_20_dpot_571 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_21_dpot_572 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_22_dpot_573 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_23_dpot_574 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_24_dpot_575 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_25_dpot_576 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_26_dpot_577 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_27_dpot_578 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_28_dpot_579 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_29_dpot_580 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_30_dpot_581 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_31_dpot_582 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_32_dpot_583 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/ram_wr_en_i1_cepot ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_0_dpot_585 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_rstpot_586 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_0_dpot_588 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_0_rstpot_589 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<31>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<30>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<29>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<28>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<27>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<26>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<25>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<24>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<23>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<22>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<21>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<20>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<19>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<18>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<17>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<16>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<15>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<14>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<13>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<12>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<11>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<10>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<9>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<8>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<7>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<6>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<5>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<4>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<3>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<2>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<1>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<0>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPA<3>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPA<2>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPA<1>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPA<0>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPB<3>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPB<2>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPB<1>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPB<0>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<31>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<30>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<29>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<28>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<27>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<26>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<25>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<24>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<23>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<22>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<21>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<20>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<19>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<18>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<17>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<16>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<15>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<31>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<30>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<29>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<28>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<27>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<26>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<25>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<24>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<23>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<22>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<21>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<20>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<19>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<18>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<17>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<16>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<15>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<14>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<13>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<12>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<11>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<10>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<9>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<8>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<7>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<6>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<5>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<4>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<3>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<2>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<1>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<0>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPA<3>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPA<2>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPA<1>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPA<0>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPB<3>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPB<2>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<31>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<30>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<29>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<28>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<27>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<26>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<25>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<24>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<23>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<22>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<21>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<20>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<19>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<18>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<17>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<16>_UNCONNECTED ;
  wire [9 : 1] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin ;
  wire [8 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin ;
  wire [8 : 2] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 ;
  wire [9 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 ;
  wire [32 : 0] \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i ;
  wire [2 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg ;
  wire [1 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg ;
  wire [0 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rd_pntr_plus1 ;
  wire [9 : 1] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count ;
  wire [8 : 1] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count ;
  wire [8 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 ;
  wire [32 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i ;
  wire [3 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/gmux.carrynet ;
  wire [4 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/v1 ;
  wire [3 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/gmux.carrynet ;
  wire [4 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/v1 ;
  wire [0 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/next_fwft_state ;
  wire [3 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/gmux.carrynet ;
  wire [4 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/v1 ;
  wire [3 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/gmux.carrynet ;
  wire [4 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/v1 ;
  wire [9 : 2] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad ;
  assign
    dout[32] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [32],
    dout[31] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [31],
    dout[30] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [30],
    dout[29] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [29],
    dout[28] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [28],
    dout[27] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [27],
    dout[26] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [26],
    dout[25] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [25],
    dout[24] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [24],
    dout[23] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [23],
    dout[22] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [22],
    dout[21] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [21],
    dout[20] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [20],
    dout[19] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [19],
    dout[18] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [18],
    dout[17] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [17],
    dout[16] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [16],
    dout[15] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [15],
    dout[14] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [14],
    dout[13] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [13],
    dout[12] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [12],
    dout[11] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [11],
    dout[10] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [10],
    dout[9] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [9],
    dout[8] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [8],
    dout[7] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [7],
    dout[6] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [6],
    dout[5] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [5],
    dout[4] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [4],
    dout[3] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [3],
    dout[2] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [2],
    dout[1] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [1],
    dout[0] = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [0],
    full = \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i_149 ,
    empty = \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/empty_fwft_i_159 ,
    prog_full = \NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/prog_full_i ;
  VCC   XST_VCC (
    .P(N0)
  );
  GND   XST_GND (
    .G(N1)
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i  (
    .C(rd_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_6_o ),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_158 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/comp1_GND_266_o_MUX_61_o ),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d2_203 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i_149 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/comp1_GND_266_o_MUX_61_o ),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d2_203 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_310 )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/RST_FULL_GEN  (
    .C(wr_clk),
    .CLR(rst),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d3_324 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/RST_FULL_GEN_204 )
  );
  FDP   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg  (
    .C(rd_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_GND_12_o_MUX_2_o ),
    .PRE(rst),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_320 )
  );
  FDP   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_GND_12_o_MUX_1_o ),
    .PRE(rst),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_323 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d3  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d2_203 ),
    .PRE(rst),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d3_324 )
  );
  FD #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_d2  (
    .C(rd_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_d1_319 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_d2_318 )
  );
  FD #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_d2  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_d1_322 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_d2_321 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d2  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d1_325 ),
    .PRE(rst),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d2_203 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg_2  (
    .C(rd_clk),
    .D(N1),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_comb ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2])
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg_1  (
    .C(rd_clk),
    .D(N1),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_comb ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1])
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg_0  (
    .C(rd_clk),
    .D(N1),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_comb ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0])
  );
  FD #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_d1  (
    .C(rd_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_320 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_d1_319 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg_1  (
    .C(wr_clk),
    .D(N1),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_comb ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1])
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg_0  (
    .C(wr_clk),
    .D(N1),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_comb ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0])
  );
  FD #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_d1  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_323 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_d1_322 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d1  (
    .C(wr_clk),
    .D(N1),
    .PRE(rst),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d1_325 )
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_32  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_32_dpot_583 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [32])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_31  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_31_dpot_582 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [31])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_30  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_30_dpot_581 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [30])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_29  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_29_dpot_580 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [29])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_28  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_28_dpot_579 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [28])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_27  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_27_dpot_578 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [27])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_26  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_26_dpot_577 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [26])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_25  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_25_dpot_576 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [25])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_24  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_24_dpot_575 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [24])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_23  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_23_dpot_574 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [23])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_22  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_22_dpot_573 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [22])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_21  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_21_dpot_572 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [21])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_20  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_20_dpot_571 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [20])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_19  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_19_dpot_570 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [19])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_18  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_18_dpot_569 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [18])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_17  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_17_dpot_568 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [17])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_16  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_16_dpot_567 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [16])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_15  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_15_dpot_566 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [15])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_14  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_14_dpot_565 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [14])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_13  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_13_dpot_564 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [13])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_12  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_12_dpot_563 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [12])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_11  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_11_dpot_562 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [11])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_10  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_10_dpot_561 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [10])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_9  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_9_dpot_560 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [9])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_8  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_8_dpot_559 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [8])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_7  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_7_dpot_558 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [7])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_6  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_6_dpot_557 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [6])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_5  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_5_dpot_556 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [5])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_4  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_4_dpot_555 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [4])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_3  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_3_dpot_554 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [3])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_2  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_2_dpot_553 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [2])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_1  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_1_dpot_552 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [1])
  );
  FDRE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_0  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_0_dpot_551 ),
    .R(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [0])
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/gmux.gm[4].gms.ms  (
    .CI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/gmux.carrynet [3]),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/v1 [4]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0 )
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/gmux.gm[3].gms.ms  (
    .CI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/gmux.carrynet [2]),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/v1 [3]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/gmux.carrynet [3])
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/gmux.gm[2].gms.ms  (
    .CI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/gmux.carrynet [1]),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/v1 [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/gmux.carrynet [2])
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/gmux.gm[1].gms.ms  (
    .CI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/gmux.carrynet [0]),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/v1 [1]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/gmux.carrynet [1])
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/gmux.gm[0].gm1.m1  (
    .CI(N0),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/v1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/gmux.carrynet [0])
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/gmux.gm[4].gms.ms  (
    .CI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/gmux.carrynet [3]),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/v1 [4]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp1 )
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/gmux.gm[3].gms.ms  (
    .CI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/gmux.carrynet [2]),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/v1 [3]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/gmux.carrynet [3])
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/gmux.gm[2].gms.ms  (
    .CI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/gmux.carrynet [1]),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/v1 [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/gmux.carrynet [2])
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/gmux.gm[1].gms.ms  (
    .CI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/gmux.carrynet [0]),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/v1 [1]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/gmux.carrynet [1])
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/gmux.gm[0].gm1.m1  (
    .CI(N0),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/v1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/gmux.carrynet [0])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_9  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [9]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [9])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_8  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [8]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [8])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_7  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [7]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [7])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_6  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [6]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [6])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_5  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [5]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [5])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_4  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [4]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [4])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_3  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [3]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [3])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_2  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [2]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [2])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_1  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [1]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [1])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_0  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_0_dpot_588 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [0])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_9  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<9> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [9])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_8  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<8> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [8])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_7  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<7> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [7])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_6  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<6> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [6])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_5  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<5> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [5])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_4  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<4> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [4])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_3  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<3> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [3])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_2  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<2> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [2])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_1  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<1> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [1])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/next_fwft_state [0]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1-In ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/empty_fwft_i  (
    .C(rd_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/going_empty_fwft_leaving_empty_fwft_OR_8_o ),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/empty_fwft_i_159 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/empty_fwft_fb  (
    .C(rd_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/going_empty_fwft_leaving_empty_fwft_OR_8_o ),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/empty_fwft_fb_393 )
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/gmux.gm[3].gms.ms  (
    .CI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/gmux.carrynet [2]),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/v1 [3]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/gmux.carrynet [3])
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/gmux.gm[2].gms.ms  (
    .CI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/gmux.carrynet [1]),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/v1 [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/gmux.carrynet [2])
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/gmux.gm[1].gms.ms  (
    .CI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/gmux.carrynet [0]),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/v1 [1]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/gmux.carrynet [1])
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/gmux.gm[0].gm1.m1  (
    .CI(N0),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/v1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/gmux.carrynet [0])
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/gmux.gm[4].gms.ms  (
    .CI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/gmux.carrynet [3]),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/v1 [4]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/comp1 )
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/gmux.gm[3].gms.ms  (
    .CI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/gmux.carrynet [2]),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/v1 [3]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/gmux.carrynet [3])
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/gmux.gm[2].gms.ms  (
    .CI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/gmux.carrynet [1]),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/v1 [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/gmux.carrynet [2])
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/gmux.gm[1].gms.ms  (
    .CI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/gmux.carrynet [0]),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/v1 [1]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/gmux.carrynet [1])
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/gmux.gm[0].gm1.m1  (
    .CI(N0),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/v1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/gmux.carrynet [0])
  );
  MUXCY   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/gmux.gm[4].gms.ms  (
    .CI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/gmux.carrynet [3]),
    .DI(N1),
    .S(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/v1 [4]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/comp2 )
  );
  XORCY 
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_xor<9>  (
    .CI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<8>_413 )
,
    .LI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<9>_412 )
,
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<9> )
  );
  XORCY 
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_xor<8>  (
    .CI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<7>_415 )
,
    .LI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<8>_414 )
,
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<8> )
  );
  MUXCY 
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<8>  (
    .CI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<7>_415 )
,
    .DI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [7]),
    .S
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<8>_414 )
,
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<8>_413 )

  );
  XORCY 
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_xor<7>  (
    .CI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<6>_417 )
,
    .LI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<7>_416 )
,
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<7> )
  );
  MUXCY 
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<7>  (
    .CI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<6>_417 )
,
    .DI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [6]),
    .S
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<7>_416 )
,
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<7>_415 )

  );
  XORCY 
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_xor<6>  (
    .CI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<5>_419 )
,
    .LI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<6>_418 )
,
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<6> )
  );
  MUXCY 
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<6>  (
    .CI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<5>_419 )
,
    .DI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [5]),
    .S
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<6>_418 )
,
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<6>_417 )

  );
  XORCY 
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_xor<5>  (
    .CI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<4>_421 )
,
    .LI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<5>_420 )
,
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<5> )
  );
  MUXCY 
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<5>  (
    .CI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<4>_421 )
,
    .DI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [4]),
    .S
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<5>_420 )
,
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<5>_419 )

  );
  XORCY 
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_xor<4>  (
    .CI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<3>_423 )
,
    .LI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<4>_422 )
,
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<4> )
  );
  MUXCY 
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<4>  (
    .CI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<3>_423 )
,
    .DI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [3]),
    .S
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<4>_422 )
,
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<4>_421 )

  );
  XORCY 
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_xor<3>  (
    .CI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<2>_425 )
,
    .LI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<3>_424 )
,
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<3> )
  );
  MUXCY 
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<3>  (
    .CI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<2>_425 )
,
    .DI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [2]),
    .S
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<3>_424 )
,
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<3>_423 )

  );
  XORCY 
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_xor<2>  (
    .CI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<1>_427 )
,
    .LI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<2>_426 )
,
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<2> )
  );
  MUXCY 
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<2>  (
    .CI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<1>_427 )
,
    .DI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [1]),
    .S
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<2>_426 )
,
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<2>_425 )

  );
  MUXCY 
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<1>  (
    .CI
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<0>_429 )
,
    .DI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .S
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<1>_428 )
,
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<1>_427 )

  );
  MUXCY 
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<0>  (
    .CI(N1),
    .DI(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .S(N1),
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_cy<0>_429 )

  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad_9  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<9> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad [9])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad_8  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<8> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad [8])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad_7  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<7> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad [7])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad_6  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<6> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad [6])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad_5  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<5> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad [5])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad_4  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<4> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad [4])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad_3  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<3> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad [3])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad_2  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT<2> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad [2])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2_8  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [8]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [8])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2_7  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [7]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [7])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2_6  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [6]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [6])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2_5  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [5]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [5])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2_4  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [4]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [4])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2_3  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [3]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [3])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2_2  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [2]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [2])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_8  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [8]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [8])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_7  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [7]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [7])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_6  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [6]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [6])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_5  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [5]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [5])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_4  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [4]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [4])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_3  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [3]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [3])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_2  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [2]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [2])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_1  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [1]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [1])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_8  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<8> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [8])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_7  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<7> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [7])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_6  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<6> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [6])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_5  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<5> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [5])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_4  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<4> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [4])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_3  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<3> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [3])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_2  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<2> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [2])
  );
  FDPE #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_1  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<1> ),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [1])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin_8  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<8> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [8])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin_7  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_6_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [7])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin_6  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_7_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [6])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin_5  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_8_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [5])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin_4  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_9_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [4])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin_3  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_10_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [3])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin_2  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_11_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [2])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin_1  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_12_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [1])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin_0  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_13_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [0])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin_9  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<9> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [9])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin_8  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_16_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [8])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin_7  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_17_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [7])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin_6  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_18_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [6])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin_5  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_19_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [5])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin_4  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_20_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [4])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin_3  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_21_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [3])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin_2  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_22_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [2])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin_1  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_23_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [1])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_9  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [9]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<9> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_8  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[8]_RD_PNTR[9]_XOR_45_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<8> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_7  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[7]_RD_PNTR[8]_XOR_46_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<7> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_6  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[6]_RD_PNTR[7]_XOR_47_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<6> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_5  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[5]_RD_PNTR[6]_XOR_48_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<5> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_4  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[4]_RD_PNTR[5]_XOR_49_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<4> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_3  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[3]_RD_PNTR[4]_XOR_50_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<3> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_2  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[2]_RD_PNTR[3]_XOR_51_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<2> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_1  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[1]_RD_PNTR[2]_XOR_52_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<1> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_0  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[0]_RD_PNTR[1]_XOR_53_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<0> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_8  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [8]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<8> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_7  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[7]_WR_PNTR[8]_XOR_1_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<7> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_6  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[6]_WR_PNTR[7]_XOR_2_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<6> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_5  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[5]_WR_PNTR[6]_XOR_3_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<5> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_4  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[4]_WR_PNTR[5]_XOR_4_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<4> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_3  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[3]_WR_PNTR[4]_XOR_5_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<3> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_2  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[2]_WR_PNTR[3]_XOR_6_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<2> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_1  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[1]_WR_PNTR[2]_XOR_7_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<1> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_0  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[0]_WR_PNTR[1]_XOR_8_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<0> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg_9  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<9> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<9> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg_8  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<8> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<8> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg_7  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<7> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<7> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg_6  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<6> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<6> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg_5  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<5> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<5> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg_4  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<4> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<4> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg_3  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<3> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<3> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg_2  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<2> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<2> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg_1  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<1> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<1> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg_0  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<0> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<0> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/Q_reg_9  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<9> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<9> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/Q_reg_8  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<8> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<8> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/Q_reg_7  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<7> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<7> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/Q_reg_6  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<6> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<6> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/Q_reg_5  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<5> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<5> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/Q_reg_4  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<4> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<4> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/Q_reg_3  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<3> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<3> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/Q_reg_2  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<2> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<2> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/Q_reg_1  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<1> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<1> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/Q_reg_0  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<0> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<0> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg_8  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<8> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<8> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg_7  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<7> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<7> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg_6  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<6> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<6> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg_5  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<5> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<5> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg_4  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<4> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<4> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg_3  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<3> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<3> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg_2  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<2> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<2> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg_1  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<1> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<1> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg_0  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<0> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<0> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/Q_reg_8  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<8> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<8> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/Q_reg_7  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<7> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<7> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/Q_reg_6  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<6> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<6> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/Q_reg_5  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<5> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<5> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/Q_reg_4  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<4> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<4> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/Q_reg_3  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<3> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<3> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/Q_reg_2  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<2> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<2> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/Q_reg_1  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<1> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<1> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/Q_reg_0  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<0> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<0> )
  );
  LUT2 #(
    .INIT ( 4'h2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/ram_wr_en_i1  (
    .I0(wr_en),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_310 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en )
  );
  LUT5 #(
    .INIT ( 32'h33023300 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/Mmux_comp1_GND_266_o_MUX_61_o11  (
    .I0(wr_en),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/RST_FULL_GEN_204 ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_310 ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/comp1 ),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/comp2 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/comp1_GND_266_o_MUX_61_o )
  );
  LUT2 #(
    .INIT ( 4'h2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/Mmux_rd_rst_asreg_GND_12_o_MUX_2_o11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_320 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_d1_319 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_GND_12_o_MUX_2_o )
  );
  LUT2 #(
    .INIT ( 4'h2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/Mmux_wr_rst_asreg_GND_12_o_MUX_1_o11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_323 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_d1_322 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_GND_12_o_MUX_1_o )
  );
  LUT2 #(
    .INIT ( 4'h2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_comb1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_320 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_d2_318 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_comb )
  );
  LUT2 #(
    .INIT ( 4'h2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_comb1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_323 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_d2_321 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_comb )
  );
  LUT4 #(
    .INIT ( 16'h8421 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/v1<4>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [7]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [8]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [8]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [9]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/v1 [4])
  );
  LUT4 #(
    .INIT ( 16'h8421 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/v1<3>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [5]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [6]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [6]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [7]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/v1 [3])
  );
  LUT4 #(
    .INIT ( 16'h8421 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/v1<2>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [3]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [4]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [4]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [5]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/v1 [2])
  );
  LUT4 #(
    .INIT ( 16'h8421 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/v1<1>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [1]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [2]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [2]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [3]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/v1 [1])
  );
  LUT3 #(
    .INIT ( 8'h09 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/v1<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [0]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [1]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c0/v1 [0])
  );
  LUT4 #(
    .INIT ( 16'h8241 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/v1<4>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [7]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [8]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [9]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [8]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/v1 [4])
  );
  LUT4 #(
    .INIT ( 16'h8241 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/v1<3>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [5]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [6]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [7]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [6]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/v1 [3])
  );
  LUT4 #(
    .INIT ( 16'h8241 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/v1<2>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [3]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [4]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [5]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [4]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/v1 [2])
  );
  LUT4 #(
    .INIT ( 16'h8241 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/v1<1>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [1]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [2]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [3]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/v1 [1])
  );
  LUT5 #(
    .INIT ( 32'hAAAA6AAA ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[9]_GND_251_o_add_0_OUT_xor<9>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [9]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [8]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [7]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [6]),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[9]_GND_251_o_add_0_OUT_xor<6>11_378 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<9> )
  );
  LUT4 #(
    .INIT ( 16'hAA6A ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[9]_GND_251_o_add_0_OUT_xor<8>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [8]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [7]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [6]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[9]_GND_251_o_add_0_OUT_xor<6>11_378 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<8> )
  );
  LUT3 #(
    .INIT ( 8'hA6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[9]_GND_251_o_add_0_OUT_xor<7>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [7]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [6]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[9]_GND_251_o_add_0_OUT_xor<6>11_378 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<7> )
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[9]_GND_251_o_add_0_OUT_xor<6>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [6]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[9]_GND_251_o_add_0_OUT_xor<6>11_378 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<6> )
  );
  LUT4 #(
    .INIT ( 16'h8E8A ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/going_empty_fwft_leaving_empty_fwft_OR_8_o1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/empty_fwft_fb_393 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .I3(rd_en),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/going_empty_fwft_leaving_empty_fwft_OR_8_o )
  );
  LUT4 #(
    .INIT ( 16'h2333 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11  (
    .I0(rd_en),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_158 ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_rd_en )
  );
  LUT4 #(
    .INIT ( 16'h55D5 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1-In1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_158 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I3(rd_en),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1-In )
  );
  LUT3 #(
    .INIT ( 8'hAE ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2-In1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/next_fwft_state [0])
  );
  LUT4 #(
    .INIT ( 16'h9009 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/v1<3>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [8]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [7]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [7]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [6]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/v1 [3])
  );
  LUT4 #(
    .INIT ( 16'h9009 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/v1<2>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [6]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [5]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [5]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [4]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/v1 [2])
  );
  LUT4 #(
    .INIT ( 16'h9009 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/v1<1>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [4]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [3]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [3]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/v1 [1])
  );
  LUT4 #(
    .INIT ( 16'h9009 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/v1<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [2]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [1]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [1]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/v1 [0])
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/v1<4>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [9]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [8]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c1/v1 [4])
  );
  LUT4 #(
    .INIT ( 16'h9009 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/v1<3>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [8]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [7]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [7]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [6]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/v1 [3])
  );
  LUT4 #(
    .INIT ( 16'h9009 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/v1<2>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [6]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [5]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [5]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [4]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/v1 [2])
  );
  LUT4 #(
    .INIT ( 16'h8241 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/v1<1>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [3]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [4]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [3]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/v1 [1])
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/v1<4>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [9]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [8]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/v1 [4])
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/Madd_gic0.gc0.count[8]_GND_264_o_add_0_OUT_xor<6>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [6]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/Madd_gic0.gc0.count[8]_GND_264_o_add_0_OUT_xor<6>11_446 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<6> )
  );
  LUT3 #(
    .INIT ( 8'hA6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/Madd_gic0.gc0.count[8]_GND_264_o_add_0_OUT_xor<7>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [7]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [6]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/Madd_gic0.gc0.count[8]_GND_264_o_add_0_OUT_xor<6>11_446 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<7> )
  );
  LUT4 #(
    .INIT ( 16'hAA6A ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/Madd_gic0.gc0.count[8]_GND_264_o_add_0_OUT_xor<8>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [8]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [7]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [6]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/Madd_gic0.gc0.count[8]_GND_264_o_add_0_OUT_xor<6>11_446 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<8> )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_16_o1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<8> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<9> ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_16_o )
  );
  LUT3 #(
    .INIT ( 8'h96 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_17_o1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<8> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<9> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<7> ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_17_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_6_o1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<7> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<8> ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_6_o )
  );
  LUT3 #(
    .INIT ( 8'h96 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_7_o1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<7> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<8> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<6> ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_7_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_WR_PNTR[6]_WR_PNTR[7]_XOR_2_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [6]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [7]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[6]_WR_PNTR[7]_XOR_2_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_WR_PNTR[7]_WR_PNTR[8]_XOR_1_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [7]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [8]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[7]_WR_PNTR[8]_XOR_1_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_WR_PNTR[5]_WR_PNTR[6]_XOR_3_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [5]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [6]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[5]_WR_PNTR[6]_XOR_3_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_WR_PNTR[4]_WR_PNTR[5]_XOR_4_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [4]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [5]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[4]_WR_PNTR[5]_XOR_4_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_WR_PNTR[3]_WR_PNTR[4]_XOR_5_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [3]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [4]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[3]_WR_PNTR[4]_XOR_5_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_WR_PNTR[2]_WR_PNTR[3]_XOR_6_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [2]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [3]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[2]_WR_PNTR[3]_XOR_6_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_RD_PNTR[8]_RD_PNTR[9]_XOR_45_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [8]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [9]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[8]_RD_PNTR[9]_XOR_45_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_RD_PNTR[7]_RD_PNTR[8]_XOR_46_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [7]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [8]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[7]_RD_PNTR[8]_XOR_46_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_RD_PNTR[6]_RD_PNTR[7]_XOR_47_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [6]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [7]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[6]_RD_PNTR[7]_XOR_47_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_RD_PNTR[5]_RD_PNTR[6]_XOR_48_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [5]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [6]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[5]_RD_PNTR[6]_XOR_48_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_RD_PNTR[4]_RD_PNTR[5]_XOR_49_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [4]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [5]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[4]_RD_PNTR[5]_XOR_49_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_RD_PNTR[1]_RD_PNTR[2]_XOR_52_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [1]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[1]_RD_PNTR[2]_XOR_52_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_RD_PNTR[3]_RD_PNTR[4]_XOR_50_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [3]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [4]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[3]_RD_PNTR[4]_XOR_50_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_RD_PNTR[2]_RD_PNTR[3]_XOR_51_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [2]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [3]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[2]_RD_PNTR[3]_XOR_51_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_RD_PNTR[0]_RD_PNTR[1]_XOR_53_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [0]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [1]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[0]_RD_PNTR[1]_XOR_53_o )
  );
  LUT5 #(
    .INIT ( 32'h96696996 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_191_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<5> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<6> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<7> ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<8> ),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<9> ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_19_o )
  );
  LUT4 #(
    .INIT ( 16'h6996 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_181_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<6> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<7> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<8> ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<9> ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_18_o )
  );
  LUT6 #(
    .INIT ( 64'h6996966996696996 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_201_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<4> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<5> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<6> ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<7> ),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<8> ),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<9> ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_20_o )
  );
  LUT4 #(
    .INIT ( 16'h6996 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_81_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<5> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<6> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<7> ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<8> ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_8_o )
  );
  LUT5 #(
    .INIT ( 32'h96696996 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_91_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<4> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<5> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<6> ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<7> ),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<8> ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_9_o )
  );
  LUT6 #(
    .INIT ( 64'h6996966996696996 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_101_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<3> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<4> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<5> ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<6> ),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<7> ),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<8> ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_10_o )
  );
  LUT6 #(
    .INIT ( 64'h6996966996696996 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_131_xo<0>  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<2> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<1> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<4> ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<3> ),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<0> ),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_8_o ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_13_o )
  );
  LUT6 #(
    .INIT ( 64'h6996966996696996 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_211_xo<0>  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<3> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<5> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<4> ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<7> ),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<6> ),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_16_o ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_21_o )
  );
  LUT3 #(
    .INIT ( 8'h69 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_221_xo<0>_SW0  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<6> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<9> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<8> ),
    .O(N4)
  );
  LUT6 #(
    .INIT ( 64'h9669699669969669 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_221_xo<0>  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<3> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<2> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<5> ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<4> ),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<7> ),
    .I5(N4),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_22_o )
  );
  LUT6 #(
    .INIT ( 64'h6996966996696996 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_231_xo<0>  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<3> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<2> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<5> ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<4> ),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<1> ),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_18_o ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[9]_reduce_xor_23_o )
  );
  LUT6 #(
    .INIT ( 64'h6996966996696996 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_111_xo<0>  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<2> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<4> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<3> ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<6> ),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<5> ),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_6_o ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_11_o )
  );
  LUT3 #(
    .INIT ( 8'h69 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_121_xo<0>_SW0  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<5> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<8> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<7> ),
    .O(N10)
  );
  LUT6 #(
    .INIT ( 64'h9669699669969669 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_121_xo<0>  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<2> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<1> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<4> ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<3> ),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<6> ),
    .I5(N10),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[8]_reduce_xor_12_o )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/prog_full_i  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/prog_full_i_rstpot_549 ),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d2_203 ),
    .Q(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/prog_full_i )
  );
  LUT3 #(
    .INIT ( 8'h90 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/v1<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [0]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [1]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/c1/v1 [0])
  );
  LUT4 #(
    .INIT ( 16'h4182 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/v1<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [1]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [2]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [1]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/c2/v1 [0])
  );
  LUT6 #(
    .INIT ( 64'hFFFF2333FFFF0000 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_6_o1  (
    .I0(rd_en),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_158 ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0 ),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp1 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_6_o )
  );
  LUT6 #(
    .INIT ( 64'hFFFFFFFF7FFFFFFF ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[9]_GND_251_o_add_0_OUT_xor<6>111  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [5]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [4]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [3]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [2]),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [1]),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[9]_GND_251_o_add_0_OUT_xor<6>11_378 )
  );
  LUT6 #(
    .INIT ( 64'hFFFFFFFF7FFFFFFF ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/Madd_gic0.gc0.count[8]_GND_264_o_add_0_OUT_xor<6>111  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [5]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [4]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [3]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [2]),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [1]),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/Madd_gic0.gc0.count[8]_GND_264_o_add_0_OUT_xor<6>11_446 )
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<1>  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [1]),
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<1>_428 )

  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<2>  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [1]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [2]),
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<2>_426 )

  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<3>  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [2]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [3]),
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<3>_424 )

  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<4>  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [3]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [4]),
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<4>_422 )

  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<5>  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [4]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [5]),
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<5>_420 )

  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<6>  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [5]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [6]),
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<6>_418 )

  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<7>  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [6]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [7]),
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<7>_416 )

  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<8>  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [7]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [8]),
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<8>_414 )

  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<9>  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [8]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [9]),
    .O
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/Madd_wr_pntr_plus1_pad[9]_adjusted_rd_pntr_wr_inv_pad[9]_add_3_OUT_lut<9>_412 )

  );
  LUT6 #(
    .INIT ( 64'hFFFFFFFF88808080 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/prog_full_i_rstpot_SW0  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad [5]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad [6]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad [4]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad [2]),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad [3]),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad [7]),
    .O(N12)
  );
  LUT6 #(
    .INIT ( 64'h5140404040404040 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/prog_full_i_rstpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/RST_FULL_GEN_204 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_310 ),
    .I2(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/prog_full_i ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad [8]),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/diff_pntr_pad [9]),
    .I5(N12),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.gpf.wrpf/prog_full_i_rstpot_549 )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_WR_PNTR[0]_WR_PNTR[1]_XOR_8_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [1]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[0]_WR_PNTR[1]_XOR_8_o )
  );
  LUT5 #(
    .INIT ( 32'hFF23FF33 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/tmp_ram_rd_en1  (
    .I0(rd_en),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_158 ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/tmp_ram_rd_en )
  );
  LUT6 #(
    .INIT ( 64'hAAAAAAAA6AAAAAAA ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[9]_GND_251_o_add_0_OUT_xor<5>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [5]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [4]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [1]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [2]),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [3]),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<5> )
  );
  LUT5 #(
    .INIT ( 32'h9AAAAAAA ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[9]_GND_251_o_add_0_OUT_xor<4>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [4]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [0]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [1]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [2]),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [3]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<4> )
  );
  LUT4 #(
    .INIT ( 16'h9AAA ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[9]_GND_251_o_add_0_OUT_xor<3>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [3]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [0]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [1]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<3> )
  );
  LUT3 #(
    .INIT ( 8'h9A ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[9]_GND_251_o_add_0_OUT_xor<2>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [2]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [0]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [1]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<2> )
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[9]_GND_251_o_add_0_OUT_xor<1>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [1]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[9]_GND_251_o_add_0_OUT<1> )
  );
  LUT5 #(
    .INIT ( 32'h9AAAAAAA ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/Madd_gic0.gc0.count[8]_GND_264_o_add_0_OUT_xor<4>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [4]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [1]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [2]),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [3]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<4> )
  );
  LUT6 #(
    .INIT ( 64'hAAAAAAAA6AAAAAAA ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/Madd_gic0.gc0.count[8]_GND_264_o_add_0_OUT_xor<5>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [5]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [4]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [1]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [2]),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [3]),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<5> )
  );
  LUT4 #(
    .INIT ( 16'h9AAA ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/Madd_gic0.gc0.count[8]_GND_264_o_add_0_OUT_xor<3>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [3]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [1]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<3> )
  );
  LUT3 #(
    .INIT ( 8'h9A ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/Madd_gic0.gc0.count[8]_GND_264_o_add_0_OUT_xor<2>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [2]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [1]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<2> )
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/Madd_gic0.gc0.count[8]_GND_264_o_add_0_OUT_xor<1>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [1]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[8]_GND_264_o_add_0_OUT<1> )
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_WR_PNTR[1]_WR_PNTR[2]_XOR_7_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [1]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[1]_WR_PNTR[2]_XOR_7_o )
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_0_dpot  (
    .I0(wr_en),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus1<0>_inv ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_0_dpot_585 )
  );
  LUT3 #(
    .INIT ( 8'hDF ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_rstpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I1(rd_en),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_392 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_rstpot_586 )
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_0_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_rstpot_586 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [0]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rd_pntr_plus1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_0_dpot_588 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_0_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [0]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_0_dpot_551 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_1_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [1]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [1]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_1_dpot_552 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_2_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [2]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_2_dpot_553 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_3_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [3]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [3]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_3_dpot_554 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_4_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [4]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [4]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_4_dpot_555 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_5_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [5]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [5]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_5_dpot_556 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_6_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [6]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [6]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_6_dpot_557 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_7_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [7]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [7]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_7_dpot_558 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_8_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [8]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [8]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_8_dpot_559 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_9_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [9]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [9]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_9_dpot_560 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_10_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [10]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [10]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_10_dpot_561 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_11_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [11]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [11]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_11_dpot_562 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_12_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [12]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [12]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_12_dpot_563 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_13_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [13]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [13]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_13_dpot_564 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_14_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [14]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [14]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_14_dpot_565 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_15_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [15]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [15]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_15_dpot_566 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_16_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [16]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [16]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_16_dpot_567 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_17_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [17]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [17]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_17_dpot_568 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_18_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [18]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [18]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_18_dpot_569 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_19_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [19]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [19]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_19_dpot_570 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_20_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [20]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [20]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_20_dpot_571 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_21_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [21]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [21]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_21_dpot_572 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_22_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [22]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [22]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_22_dpot_573 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_23_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [23]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [23]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_23_dpot_574 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_24_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [24]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [24]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_24_dpot_575 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_25_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [25]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [25]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_25_dpot_576 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_26_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [26]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [26]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_26_dpot_577 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_27_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [27]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [27]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_27_dpot_578 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_28_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [28]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [28]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_28_dpot_579 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_29_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [29]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [29]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_29_dpot_580 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_30_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [30]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [30]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_30_dpot_581 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_31_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [31]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [31]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_31_dpot_582 )
  );
  LUT4 #(
    .INIT ( 16'hAEA2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_32_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [32]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_391 ),
    .I2(rd_en),
    .I3(\NlwRenamedSig_OI_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [32]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_32_dpot_583 )
  );
  LUT3 #(
    .INIT ( 8'hE4 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_0_rstpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/ram_wr_en_i1_cepot ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_0_dpot_585 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_0_rstpot_589 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_0  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_0_rstpot_589 ),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0])
  );
  INV   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus1<0>_inv1_INV_0  (
    .I(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus1<0>_inv )
  );
  INV   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rd_pntr<0>_inv1_INV_0  (
    .I(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rd_pntr_plus1 [0])
  );
  INV   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus2<1>_inv1_INV_0  (
    .I(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [1]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus2<1>_inv )
  );
  INV   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/ram_wr_en_i1_cepot_INV_0  (
    .I(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_310 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/ram_wr_en_i1_cepot )
  );
  INV   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot_INV_0  (
    .I(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_158 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot )
  );
  RAMB16BWER #(
    .DATA_WIDTH_A ( 36 ),
    .DATA_WIDTH_B ( 18 ),
    .DOA_REG ( 0 ),
    .DOB_REG ( 0 ),
    .EN_RSTRAM_A ( "FALSE" ),
    .EN_RSTRAM_B ( "TRUE" ),
    .INITP_00 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_01 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_02 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_03 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_04 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_05 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_06 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_07 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_00 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_01 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_02 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_03 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_04 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_05 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_06 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_07 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_08 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_09 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_0A ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_0B ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_0C ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_0D ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_0E ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_0F ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_10 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_11 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_12 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_13 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_14 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_15 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_16 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_17 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_18 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_19 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1A ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1B ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1C ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1D ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1E ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1F ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_20 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_21 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_22 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_23 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_24 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_25 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_26 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_27 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_28 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_29 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2A ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2B ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2C ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2D ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2E ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2F ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_30 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_31 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_32 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_33 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_34 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_35 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_36 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_37 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_38 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_39 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_3A ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_3B ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_3C ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_3D ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_3E ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_3F ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_A ( 36'h000000000 ),
    .INIT_B ( 36'h000000000 ),
    .INIT_FILE ( "NONE" ),
    .RSTTYPE ( "SYNC" ),
    .RST_PRIORITY_A ( "CE" ),
    .RST_PRIORITY_B ( "CE" ),
    .SIM_COLLISION_CHECK ( "ALL" ),
    .SIM_DEVICE ( "SPARTAN6" ),
    .SRVAL_A ( 36'h000000000 ),
    .SRVAL_B ( 36'h000000000 ),
    .WRITE_MODE_A ( "WRITE_FIRST" ),
    .WRITE_MODE_B ( "WRITE_FIRST" ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram  (
    .REGCEA
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR ),
    .CLKA(wr_clk),
    .ENB(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/tmp_ram_rd_en ),
    .RSTB(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .CLKB(rd_clk),
    .REGCEB
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR ),
    .RSTA(N1),
    .ENA(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .DIPA({\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR 
, \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR }),
    .WEA({\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en , \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en , \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en }),
    .DOA({
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<31>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<30>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<29>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<28>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<27>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<26>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<25>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<24>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<23>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<22>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<21>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<20>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<19>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<18>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<17>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<16>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<15>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<14>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<13>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<12>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<11>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<10>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<9>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<8>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<7>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<6>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<5>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<4>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<3>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<2>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<1>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<0>_UNCONNECTED 
}),
    .ADDRA({\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [8], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [7], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [6], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [5], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [4], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [3], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [2], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus2<1>_inv , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus1<0>_inv , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR }),
    .ADDRB({\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [9], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [8], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [7], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [6], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [5], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [4], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [3], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [2], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [1], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [0], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR }),
    .DIB({\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR 
, \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR }),
    .DOPA({
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPA<3>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPA<2>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPA<1>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPA<0>_UNCONNECTED 
}),
    .DIPB({\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR 
, \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR }),
    .DOPB({
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPB<3>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPB<2>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPB<1>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPB<0>_UNCONNECTED 
}),
    .DOB({
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<31>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<30>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<29>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<28>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<27>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<26>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<25>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<24>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<23>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<22>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<21>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<20>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<19>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<18>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<17>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<16>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[1].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<15>_UNCONNECTED 
, \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [32], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [31], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [30], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [29], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [28], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [27], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [26], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [25], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [24], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [23], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [22], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [21], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [20], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [19], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [18]}),
    .WEB({\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR 
, \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR }),
    .DIA({\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR 
, din[32], din[31], din[30], din[29], din[28], din[27], din[26], din[25], din[24], din[23], din[22], din[21], din[20], din[19], din[18], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , din[65], 
din[64], din[63], din[62], din[61], din[60], din[59], din[58], din[57], din[56], din[55], din[54], din[53], din[52], din[51]})
  );
  RAMB16BWER #(
    .DATA_WIDTH_A ( 36 ),
    .DATA_WIDTH_B ( 18 ),
    .DOA_REG ( 0 ),
    .DOB_REG ( 0 ),
    .EN_RSTRAM_A ( "FALSE" ),
    .EN_RSTRAM_B ( "TRUE" ),
    .INITP_00 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_01 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_02 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_03 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_04 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_05 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_06 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INITP_07 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_00 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_01 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_02 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_03 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_04 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_05 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_06 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_07 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_08 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_09 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_0A ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_0B ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_0C ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_0D ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_0E ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_0F ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_10 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_11 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_12 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_13 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_14 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_15 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_16 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_17 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_18 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_19 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1A ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1B ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1C ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1D ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1E ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_1F ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_20 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_21 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_22 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_23 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_24 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_25 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_26 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_27 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_28 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_29 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2A ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2B ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2C ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2D ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2E ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_2F ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_30 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_31 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_32 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_33 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_34 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_35 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_36 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_37 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_38 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_39 ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_3A ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_3B ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_3C ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_3D ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_3E ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_3F ( 256'h0000000000000000000000000000000000000000000000000000000000000000 ),
    .INIT_A ( 36'h000000000 ),
    .INIT_B ( 36'h000000000 ),
    .INIT_FILE ( "NONE" ),
    .RSTTYPE ( "SYNC" ),
    .RST_PRIORITY_A ( "CE" ),
    .RST_PRIORITY_B ( "CE" ),
    .SIM_COLLISION_CHECK ( "ALL" ),
    .SIM_DEVICE ( "SPARTAN6" ),
    .SRVAL_A ( 36'h000000000 ),
    .SRVAL_B ( 36'h000000000 ),
    .WRITE_MODE_A ( "WRITE_FIRST" ),
    .WRITE_MODE_B ( "WRITE_FIRST" ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram  (
    .REGCEA
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR ),
    .CLKA(wr_clk),
    .ENB(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/tmp_ram_rd_en ),
    .RSTB(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .CLKB(rd_clk),
    .REGCEB
(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR ),
    .RSTA(N1),
    .ENA(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .DIPA({din[17], din[8], din[50], din[41]}),
    .WEA({\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en , \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en , \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en }),
    .DOA({
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<31>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<30>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<29>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<28>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<27>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<26>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<25>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<24>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<23>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<22>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<21>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<20>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<19>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<18>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<17>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<16>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<15>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<14>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<13>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<12>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<11>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<10>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<9>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<8>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<7>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<6>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<5>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<4>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<3>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<2>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<1>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOA<0>_UNCONNECTED 
}),
    .ADDRA({\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [8], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [7], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [6], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [5], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [4], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [3], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [2], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus2<1>_inv , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus1<0>_inv , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR }),
    .ADDRB({\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [9], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [8], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [7], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [6], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [5], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [4], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [3], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [2], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [1], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [0], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR }),
    .DIB({\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR 
, \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR }),
    .DOPA({
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPA<3>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPA<2>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPA<1>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPA<0>_UNCONNECTED 
}),
    .DIPB({\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR 
, \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR }),
    .DOPB({
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPB<3>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOPB<2>_UNCONNECTED 
, \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [17], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [8]}),
    .DOB({
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<31>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<30>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<29>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<28>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<27>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<26>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<25>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<24>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<23>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<22>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<21>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<20>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<19>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<18>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<17>_UNCONNECTED 
, 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/ramloop[0].ram.r/s6_noinit.ram/SDP.SIMPLE_PRIM18.ram_DOB<16>_UNCONNECTED 
, \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [16], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [15], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [14], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [13], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [12], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [11], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [10], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [9], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [7], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [6], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [5], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [4], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [3], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [2], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [1], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/doutb_i [0]}),
    .WEB({\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR 
, \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR , 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR }),
    .DIA({din[16], din[15], din[14], din[13], din[12], din[11], din[10], din[9], din[7], din[6], din[5], din[4], din[3], din[2], din[1], din[0], 
din[49], din[48], din[47], din[46], din[45], din[44], din[43], din[42], din[40], din[39], din[38], din[37], din[36], din[35], din[34], din[33]})
  );
  GND   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/XST_GND  (
    .G(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gbm.gbmg.gbmga.ngecc.bmg/gnativebmg.native_blk_mem_gen/valid.cstr/DBITERR )
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
