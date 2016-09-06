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
  
  // synthesis translate_off
  
  wire N1;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i_11 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_regout_en ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_16 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/empty_fwft_i_17 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d2_29 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/RST_FULL_GEN_30 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_3_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_60 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/comp1_GND_34_o_MUX_21_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_GND_12_o_MUX_2_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_comb ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_GND_12_o_MUX_1_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_comb ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_d2_66 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_d1_67 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_68 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_d2_69 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_d1_70 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_71 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d3_72 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d1_73 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/ram_rd_en_i ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[3]_GND_23_o_add_0_OUT<1> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1-In ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/going_empty_fwft_leaving_empty_fwft_OR_5_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/empty_fwft_fb_97 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[3]_GND_32_o_add_0_OUT<1> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[3]_GND_32_o_add_0_OUT<2> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[3]_GND_32_o_add_0_OUT<3> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[3]_reduce_xor_7_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[3]_reduce_xor_6_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[3]_reduce_xor_12_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[3]_reduce_xor_11_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[0]_RD_PNTR[1]_XOR_12_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[1]_RD_PNTR[2]_XOR_11_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[2]_RD_PNTR[3]_XOR_10_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[0]_WR_PNTR[1]_XOR_3_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[1]_WR_PNTR[2]_XOR_2_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[2]_WR_PNTR[3]_XOR_1_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[3]_reduce_xor_8_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[3]_reduce_xor_13_o ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<0> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<1> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<2> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<3> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<0> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<1> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<2> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<3> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<0> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<1> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<2> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<3> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<0> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<1> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<2> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<3> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<0> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<1> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<2> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<3> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<0> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<1> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<2> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<3> ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus1<0>_inv ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rd_pntr_plus1<0>_inv ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_3_o1_139 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_3_o2_140 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_3_o3_141 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/Mmux_comp1_GND_34_o_MUX_21_o1 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/Mmux_comp1_GND_34_o_MUX_21_o11_143 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/Mmux_comp1_GND_34_o_MUX_21_o12_144 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot1 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_2_dpot_146 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_3_dpot_147 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_0_rstpot_148 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_rstpot_149 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_2_dpot_151 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_3_dpot_152 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_0_dpot1_153 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_1_dpot1_154 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_2_dpot1_155 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_3_dpot1_156 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_4_dpot1_157 ;
  wire \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_5_dpot1_158 ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/Mram_RAM22_SPO_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/Mram_RAM21_SPO_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/Mram_RAM1_DOD<1>_UNCONNECTED ;
  wire \NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/Mram_RAM1_DOD<0>_UNCONNECTED ;
  wire [3 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin ;
  wire [3 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin ;
  wire [3 : 1] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 ;
  wire [3 : 1] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 ;
  wire [7 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i ;
  wire [2 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg ;
  wire [1 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg ;
  wire [3 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count ;
  wire [3 : 1] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count ;
  wire [3 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 ;
  wire [7 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i ;
  wire [7 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/_n0014 ;
  wire [0 : 0] \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/next_fwft_state ;
  assign
    dout[7] = \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [7],
    dout[6] = \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [6],
    dout[5] = \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [5],
    dout[4] = \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [4],
    dout[3] = \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [3],
    dout[2] = \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [2],
    dout[1] = \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [1],
    dout[0] = \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [0],
    full = \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i_11 ,
    empty = \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/empty_fwft_i_17 ;
  GND   XST_GND (
    .G(N1)
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i  (
    .C(rd_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_3_o ),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_16 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/comp1_GND_34_o_MUX_21_o ),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d2_29 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_i_11 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/comp1_GND_34_o_MUX_21_o ),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d2_29 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_60 )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/RST_FULL_GEN  (
    .C(wr_clk),
    .CLR(rst),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d3_72 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/RST_FULL_GEN_30 )
  );
  FDP   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg  (
    .C(rd_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_GND_12_o_MUX_2_o ),
    .PRE(rst),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_68 )
  );
  FDP   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_GND_12_o_MUX_1_o ),
    .PRE(rst),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_71 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d3  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d2_29 ),
    .PRE(rst),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d3_72 )
  );
  FD #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_d2  (
    .C(rd_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_d1_67 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_d2_66 )
  );
  FD #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_d2  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_d1_70 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_d2_69 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d2  (
    .C(wr_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d1_73 ),
    .PRE(rst),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d2_29 )
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
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_68 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_d1_67 )
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
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_71 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_d1_70 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d1  (
    .C(wr_clk),
    .D(N1),
    .PRE(rst),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/grstd1.grst_full.rst_d1_73 )
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_7  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_regout_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [7]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [7])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_6  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_regout_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [6]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [6])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_5  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_regout_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [5]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [5])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_4  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_regout_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [4]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [4])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_3  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_regout_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [3]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [3])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_2  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_regout_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [2]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [2])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_1  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_regout_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [1]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [1])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i_0  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_regout_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [0]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/dout_i [0])
  );
  RAM16X1D #(
    .INIT ( 16'h0000 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/Mram_RAM22  (
    .A0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus1<0>_inv ),
    .A1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [1]),
    .A2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [2]),
    .A3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [3]),
    .D(din[7]),
    .DPRA0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rd_pntr_plus1<0>_inv ),
    .DPRA1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [1]),
    .DPRA2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [2]),
    .DPRA3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [3]),
    .WCLK(wr_clk),
    .WE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .SPO(\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/Mram_RAM22_SPO_UNCONNECTED ),
    .DPO(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/_n0014 [7])
  );
  RAM16X1D #(
    .INIT ( 16'h0000 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/Mram_RAM21  (
    .A0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus1<0>_inv ),
    .A1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [1]),
    .A2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [2]),
    .A3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [3]),
    .D(din[6]),
    .DPRA0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rd_pntr_plus1<0>_inv ),
    .DPRA1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [1]),
    .DPRA2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [2]),
    .DPRA3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [3]),
    .WCLK(wr_clk),
    .WE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .SPO(\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/Mram_RAM21_SPO_UNCONNECTED ),
    .DPO(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/_n0014 [6])
  );
  RAM32M #(
    .INIT_A ( 64'h0000000000000000 ),
    .INIT_B ( 64'h0000000000000000 ),
    .INIT_C ( 64'h0000000000000000 ),
    .INIT_D ( 64'h0000000000000000 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/Mram_RAM1  (
    .WCLK(wr_clk),
    .WE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .DIA({din[1], din[0]}),
    .DIB({din[3], din[2]}),
    .DIC({din[5], din[4]}),
    .DID({N1, N1}),
    .ADDRA({N1, \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [3], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [2], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [1], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rd_pntr_plus1<0>_inv }),
    .ADDRB({N1, \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [3], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [2], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [1], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rd_pntr_plus1<0>_inv }),
    .ADDRC({N1, \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [3], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [2], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [1], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rd_pntr_plus1<0>_inv }),
    .ADDRD({N1, \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [3], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [2], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [1], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus1<0>_inv }),
    .DOA({\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/_n0014 [1], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/_n0014 [0]}),
    .DOB({\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/_n0014 [3], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/_n0014 [2]}),
    .DOC({\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/_n0014 [5], 
\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/_n0014 [4]}),
    .DOD({\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/Mram_RAM1_DOD<1>_UNCONNECTED , 
\NLW_U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/Mram_RAM1_DOD<0>_UNCONNECTED })
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_7  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/ram_rd_en_i ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/_n0014 [7]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [7])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_6  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/ram_rd_en_i ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/_n0014 [6]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [6])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_5  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_5_dpot1_158 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [5])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_4  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_4_dpot1_157 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [4])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_3  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_3_dpot1_156 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [3])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_2  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_2_dpot1_155 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [2])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_1  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_1_dpot1_154 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [1])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_0  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_0_dpot1_153 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [0])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_3  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot1 ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_3_dpot_147 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [3])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_2  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot1 ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_2_dpot_146 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [2])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_1  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/ram_rd_en_i ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [1]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [1])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_3  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_3_dpot_152 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [3])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_2  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_2_dpot_151 ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [2])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_1  (
    .C(rd_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/ram_rd_en_i ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[3]_GND_23_o_add_0_OUT<1> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [1])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/next_fwft_state [0]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1-In ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/empty_fwft_i  (
    .C(rd_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/going_empty_fwft_leaving_empty_fwft_OR_5_o ),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/empty_fwft_i_17 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/empty_fwft_fb  (
    .C(rd_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/going_empty_fwft_leaving_empty_fwft_OR_5_o ),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/empty_fwft_fb_97 )
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
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2_1  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [1]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [1])
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
  FDPE #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1_0  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus1<0>_inv ),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_3  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[3]_GND_32_o_add_0_OUT<3> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [3])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_2  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[3]_GND_32_o_add_0_OUT<2> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [2])
  );
  FDPE #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_1  (
    .C(wr_clk),
    .CE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en ),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[3]_GND_32_o_add_0_OUT<1> ),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [1]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [1])
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
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/Q_reg_1  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<1> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<1> )
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
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/Q_reg_3  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<3> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<3> )
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
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg_1  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<1> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<1> )
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
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg_3  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/D<3> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<3> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/Q_reg_0  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<0> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<0> )
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
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/Q_reg_2  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<2> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<2> )
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
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg_0  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<0> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<0> )
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
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg_2  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/D<2> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<2> )
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
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin_3  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<3> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [3])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin_2  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[3]_reduce_xor_6_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [2])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin_1  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[3]_reduce_xor_7_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [1])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin_0  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[3]_reduce_xor_8_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [0])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin_3  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<3> ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [3])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin_2  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[3]_reduce_xor_11_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [2])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin_1  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[3]_reduce_xor_12_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [1])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin_0  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[3]_reduce_xor_13_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [0])
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_3  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [3]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<3> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_2  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[2]_RD_PNTR[3]_XOR_10_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<2> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_1  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[1]_RD_PNTR[2]_XOR_11_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<1> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_0  (
    .C(rd_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [1]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[0]_RD_PNTR[1]_XOR_12_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].wr_stg_inst/D<0> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_3  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [3]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<3> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_2  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[2]_WR_PNTR[3]_XOR_1_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<2> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_1  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[1]_WR_PNTR[2]_XOR_2_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<1> )
  );
  FDC #(
    .INIT ( 1'b0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_0  (
    .C(wr_clk),
    .CLR(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.wr_rst_reg [0]),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[0]_WR_PNTR[1]_XOR_3_o ),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[1].rd_stg_inst/D<0> )
  );
  LUT2 #(
    .INIT ( 4'h2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/ram_wr_en_i1  (
    .I0(wr_en),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_60 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_wr_en )
  );
  LUT2 #(
    .INIT ( 4'h2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/Mmux_rd_rst_asreg_GND_12_o_MUX_2_o11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_68 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_d1_67 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_GND_12_o_MUX_2_o )
  );
  LUT2 #(
    .INIT ( 4'h2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/Mmux_wr_rst_asreg_GND_12_o_MUX_1_o11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_71 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_d1_70 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_GND_12_o_MUX_1_o )
  );
  LUT2 #(
    .INIT ( 4'h4 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_comb1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_d2_66 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_asreg_68 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/rd_rst_comb )
  );
  LUT2 #(
    .INIT ( 4'h2 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_comb1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_71 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_asreg_d2_69 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/wr_rst_comb )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[3]_GND_23_o_add_0_OUT_xor<1>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [1]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count[3]_GND_23_o_add_0_OUT<1> )
  );
  LUT3 #(
    .INIT ( 8'hB0 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/RAM_REGOUT_EN1  (
    .I0(rd_en),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/ram_regout_en )
  );
  LUT4 #(
    .INIT ( 16'h8E8A ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/going_empty_fwft_leaving_empty_fwft_OR_5_o1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/empty_fwft_fb_97 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 ),
    .I3(rd_en),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/going_empty_fwft_leaving_empty_fwft_OR_5_o )
  );
  LUT4 #(
    .INIT ( 16'h2333 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11  (
    .I0(rd_en),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_16 ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/ram_rd_en_i )
  );
  LUT4 #(
    .INIT ( 16'h55D5 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1-In1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_16 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 ),
    .I3(rd_en),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1-In )
  );
  LUT3 #(
    .INIT ( 8'hAE ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2-In1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 ),
    .I2(rd_en),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/next_fwft_state [0])
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[3]_reduce_xor_11_o1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<2> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<3> ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[3]_reduce_xor_11_o )
  );
  LUT3 #(
    .INIT ( 8'h96 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[3]_reduce_xor_12_o1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<2> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<3> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<1> ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[3]_reduce_xor_12_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[3]_reduce_xor_6_o1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<2> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<3> ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[3]_reduce_xor_6_o )
  );
  LUT3 #(
    .INIT ( 8'h96 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[3]_reduce_xor_7_o1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<1> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<2> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<3> ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[3]_reduce_xor_7_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_WR_PNTR[2]_WR_PNTR[3]_XOR_1_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [2]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [3]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[2]_WR_PNTR[3]_XOR_1_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_RD_PNTR[2]_RD_PNTR[3]_XOR_10_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [2]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [3]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[2]_RD_PNTR[3]_XOR_10_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_WR_PNTR[1]_WR_PNTR[2]_XOR_2_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [1]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[1]_WR_PNTR[2]_XOR_2_o )
  );
  LUT2 #(
    .INIT ( 4'h6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_RD_PNTR[1]_RD_PNTR[2]_XOR_11_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [1]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[1]_RD_PNTR[2]_XOR_11_o )
  );
  LUT4 #(
    .INIT ( 16'h6996 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[3]_reduce_xor_131_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<0> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<1> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<2> ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].wr_stg_inst/Q_reg<3> ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_gc_asreg_last[3]_reduce_xor_13_o )
  );
  LUT4 #(
    .INIT ( 16'h6996 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[3]_reduce_xor_81_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<0> ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<1> ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<2> ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/gsync_stage[2].rd_stg_inst/Q_reg<3> ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_gc_asreg_last[3]_reduce_xor_8_o )
  );
  LUT6 #(
    .INIT ( 64'h8008400420021001 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_3_o1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [2]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [3]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [1]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [1]),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [2]),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [3]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_3_o1_139 )
  );
  LUT4 #(
    .INIT ( 16'h8241 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_3_o2  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [0]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [1]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [1]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_3_o2_140 )
  );
  LUT4 #(
    .INIT ( 16'h8241 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_3_o3  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [2]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [3]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [3]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_3_o3_141 )
  );
  LUT6 #(
    .INIT ( 64'h9009000000009009 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/Mmux_comp1_GND_34_o_MUX_21_o11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [2]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [2]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [3]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [3]),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [0]),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/Mmux_comp1_GND_34_o_MUX_21_o1 )
  );
  LUT6 #(
    .INIT ( 64'h2000002002000002 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/Mmux_comp1_GND_34_o_MUX_21_o13  (
    .I0(wr_en),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/ram_full_fb_i_60 ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [2]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [3]),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [3]),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/Mmux_comp1_GND_34_o_MUX_21_o12_144 )
  );
  LUT6 #(
    .INIT ( 64'h5541414155000000 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/Mmux_comp1_GND_34_o_MUX_21_o14  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/RST_FULL_GEN_30 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [1]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [1]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/Mmux_comp1_GND_34_o_MUX_21_o11_143 ),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/Mmux_comp1_GND_34_o_MUX_21_o12_144 ),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/Mmux_comp1_GND_34_o_MUX_21_o1 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/comp1_GND_34_o_MUX_21_o )
  );
  LUT4 #(
    .INIT ( 16'h2184 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/Mmux_comp1_GND_34_o_MUX_21_o12  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [1]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/rd_pntr_bin [0]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [1]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/gwas.wsts/Mmux_comp1_GND_34_o_MUX_21_o11_143 )
  );
  LUT3 #(
    .INIT ( 8'hA6 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/Madd_gic0.gc0.count[3]_GND_32_o_add_0_OUT_xor<2>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [2]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [1]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[3]_GND_32_o_add_0_OUT<2> )
  );
  LUT4 #(
    .INIT ( 16'hAA6A ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/Madd_gic0.gc0.count[3]_GND_32_o_add_0_OUT_xor<3>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [3]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [2]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [1]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[3]_GND_32_o_add_0_OUT<3> )
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/Madd_gic0.gc0.count[3]_GND_32_o_add_0_OUT_xor<1>11  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count [1]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count[3]_GND_32_o_add_0_OUT<1> )
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_WR_PNTR[0]_WR_PNTR[1]_XOR_3_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d2 [1]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/WR_PNTR[0]_WR_PNTR[1]_XOR_3_o )
  );
  LUT2 #(
    .INIT ( 4'h9 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/Mxor_RD_PNTR[0]_RD_PNTR[1]_XOR_12_o_xo<0>1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [0]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [1]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/RD_PNTR[0]_RD_PNTR[1]_XOR_12_o )
  );
  LUT6 #(
    .INIT ( 64'hF666F00066660000 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_3_o4  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gcx.clkx/wr_pntr_bin [0]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [0]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_3_o3_141 ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_3_o2_140 ),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_3_o1_139 ),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/ram_rd_en_i ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/comp0_comp1_OR_3_o )
  );
  LUT5 #(
    .INIT ( 32'hBAAA8AAA ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_2_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [2]),
    .I1(rd_en),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 ),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_2_dpot_146 )
  );
  LUT5 #(
    .INIT ( 32'hBAAA8AAA ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_3_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [3]),
    .I1(rd_en),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 ),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1 [3]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_d1_3_dpot_147 )
  );
  FDP #(
    .INIT ( 1'b1 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_0  (
    .C(rd_clk),
    .D(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_0_rstpot_148 ),
    .PRE(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/rstblk/ngwrdrst.grst.rd_rst_reg [2]),
    .Q(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [0])
  );
  LUT5 #(
    .INIT ( 32'h9999C999 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_0_rstpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_16 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [0]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 ),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 ),
    .I4(rd_en),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_0_rstpot_148 )
  );
  LUT3 #(
    .INIT ( 8'hBF ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_rstpot  (
    .I0(rd_en),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 ),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_rstpot_149 )
  );
  LUT6 #(
    .INIT ( 64'h66A66666AAAAAAAA ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_2_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [2]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [0]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 ),
    .I3(rd_en),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 ),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [1]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_2_dpot_151 )
  );
  LUT6 #(
    .INIT ( 64'hEEFEEEEE44044444 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_0_dpot1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_16 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/_n0014 [0]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 ),
    .I3(rd_en),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 ),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_0_dpot1_153 )
  );
  LUT6 #(
    .INIT ( 64'hEEFEEEEE44044444 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_1_dpot1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_16 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/_n0014 [1]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 ),
    .I3(rd_en),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 ),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [1]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_1_dpot1_154 )
  );
  LUT6 #(
    .INIT ( 64'hEEFEEEEE44044444 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_2_dpot1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_16 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/_n0014 [2]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 ),
    .I3(rd_en),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 ),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [2]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_2_dpot1_155 )
  );
  LUT6 #(
    .INIT ( 64'hEEFEEEEE44044444 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_3_dpot1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_16 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/_n0014 [3]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 ),
    .I3(rd_en),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 ),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [3]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_3_dpot1_156 )
  );
  LUT6 #(
    .INIT ( 64'hEEFEEEEE44044444 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_4_dpot1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_16 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/_n0014 [4]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 ),
    .I3(rd_en),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 ),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [4]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_4_dpot1_157 )
  );
  LUT6 #(
    .INIT ( 64'hEEFEEEEE44044444 ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_5_dpot1  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_16 ),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/_n0014 [5]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd2_95 ),
    .I3(rd_en),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/curr_fwft_state_FSM_FFd1_96 ),
    .I5(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i [5]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.mem/gdm.dm/dout_i_5_dpot1_158 )
  );
  LUT5 #(
    .INIT ( 32'h6AAAAAAA ))
  \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_3_dpot  (
    .I0(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [3]),
    .I1(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [2]),
    .I2(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [1]),
    .I3(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [0]),
    .I4(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_rstpot_149 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count_3_dpot_152 )
  );
  INV   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/Madd_gc0.count[3]_GND_23_o_add_0_OUT_xor<0>11_INV_0  (
    .I(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rpntr/gc0.count [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/rd_pntr_plus1<0>_inv )
  );
  INV   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus1<0>_inv1_INV_0  (
    .I(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wpntr/gic0.gc0.count_d1 [0]),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.wr/wr_pntr_plus1<0>_inv )
  );
  INV   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot1_INV_0  (
    .I(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_16 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot1 )
  );
  INV   \U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot_INV_0  (
    .I(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gras.rsts/ram_empty_fb_i_16 ),
    .O(\U0/xst_fifo_generator/gconvfifo.rf/grf.rf/gntv_or_sync_fifo.gl0.rd/gr1.rfwft/Mmux_RAM_RD_EN_FWFT11_cepot )
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
