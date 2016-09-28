onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {mt9p031
} /driver_mt9p031/mt9p031_model_inst/clk
add wave -noupdate -expand -group {mt9p031
} /driver_mt9p031/mt9p031_model_inst/reset
add wave -noupdate -expand -group {mt9p031
} /driver_mt9p031/mt9p031_model_inst/o_clk_pix
add wave -noupdate -expand -group {mt9p031
} /driver_mt9p031/mt9p031_model_inst/o_fval
add wave -noupdate -expand -group {mt9p031
} /driver_mt9p031/mt9p031_model_inst/o_lval
add wave -noupdate -expand -group {mt9p031
} /driver_mt9p031/mt9p031_model_inst/ov_dout
add wave -noupdate -divider {New Divider}
add wave -noupdate /harness/frame_buffer_inst/o_calib_done
add wave -noupdate /harness/frame_buffer_inst/async_rst
add wave -noupdate /harness/frame_buffer_inst/mig_core_inst/c3_p2_wr_full
add wave -noupdate /harness/frame_buffer_inst/mig_core_inst/c3_p2_wr_empty
add wave -noupdate /harness/frame_buffer_inst/mig_core_inst/c3_p2_wr_en
add wave -noupdate /harness/frame_buffer_inst/mig_core_inst/c3_p2_cmd_en
add wave -noupdate /harness/frame_buffer_inst/mig_core_inst/c3_p2_cmd_empty
add wave -noupdate /harness/frame_buffer_inst/mig_core_inst/c3_p2_cmd_full
add wave -noupdate /harness/frame_buffer_inst/mig_core_inst/c3_p3_cmd_en
add wave -noupdate /harness/frame_buffer_inst/mig_core_inst/c3_p3_rd_en
add wave -noupdate /harness/frame_buffer_inst/mig_core_inst/c3_p3_rd_full
add wave -noupdate /harness/frame_buffer_inst/mig_core_inst/c3_p3_rd_empty
add wave -noupdate -divider {New Divider}
add wave -noupdate -group {ddr3
} /harness/genblk1/ddr3_model_c3_inst/ck
add wave -noupdate -group {ddr3
} /harness/genblk1/ddr3_model_c3_inst/ck_n
add wave -noupdate -group {ddr3
} /harness/genblk1/ddr3_model_c3_inst/cke
add wave -noupdate -group {ddr3
} /harness/genblk1/ddr3_model_c3_inst/cs_n
add wave -noupdate -group {ddr3
} /harness/genblk1/ddr3_model_c3_inst/ras_n
add wave -noupdate -group {ddr3
} /harness/genblk1/ddr3_model_c3_inst/cas_n
add wave -noupdate -group {ddr3
} /harness/genblk1/ddr3_model_c3_inst/we_n
add wave -noupdate -group {ddr3
} /harness/genblk1/ddr3_model_c3_inst/dm_tdqs
add wave -noupdate -group {ddr3
} /harness/genblk1/ddr3_model_c3_inst/ba
add wave -noupdate -group {ddr3
} /harness/genblk1/ddr3_model_c3_inst/addr
add wave -noupdate -group {ddr3
} /harness/genblk1/ddr3_model_c3_inst/dq
add wave -noupdate -group {ddr3
} /harness/genblk1/ddr3_model_c3_inst/dqs
add wave -noupdate -group {ddr3
} /harness/genblk1/ddr3_model_c3_inst/dqs_n
add wave -noupdate -group {ddr3
} /harness/genblk1/ddr3_model_c3_inst/tdqs_n
add wave -noupdate -group {ddr3
} /harness/genblk1/ddr3_model_c3_inst/odt
add wave -noupdate -group {ddr3
} /harness/genblk1/ddr3_model_c3_inst/rst_n
add wave -noupdate -group {monitor_ddr3
} -radix ascii /monitor_ddr3/DDR3_CMD
add wave -noupdate -group {monitor_ddr3
} -radix ascii /monitor_ddr3/rd_wr_cmd
add wave -noupdate -group {monitor_ddr3
} /monitor_ddr3/ddr_cmd_int
add wave -noupdate -group {monitor_ddr3
} /monitor_ddr3/current_wr_row_addr
add wave -noupdate -group {monitor_ddr3
} /monitor_ddr3/current_wr_bank_addr
add wave -noupdate -group {monitor_ddr3
} /monitor_ddr3/current_rd_row_addr
add wave -noupdate -group {monitor_ddr3
} /monitor_ddr3/current_rd_bank_addr
add wave -noupdate -divider {New Divider}
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/i_fval
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/i_dval
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/iv_image_din
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/i_buf_rd
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/o_buf_empty
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/o_buf_pe
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/ov_image_dout
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/iv_frame_depth
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/i_start_full_frame
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/i_start_quick
add wave -noupdate -group {frame_buffer
} -radix unsigned /harness/frame_buffer_inst/iv_frame_size
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/reset_frame_buf
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/async_rst
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/bufpll_mcb_lock
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/o_calib_done
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/o_wr_error
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/o_rd_error
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_dram_dq
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_dram_a
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_dram_ba
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_dram_ras_n
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_dram_cas_n
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_dram_we_n
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_dram_odt
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_dram_reset_n
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_dram_cke
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_dram_udm
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_dram_dm
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_dram_udqs
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_dram_udqs_n
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_dram_dqs
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_dram_dqs_n
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_rzq
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_zio
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_dram_ck
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/mcb3_dram_ck_n
add wave -noupdate -group {frame_buffer
} /harness/frame_buffer_inst/ov_frame_buf_version
add wave -noupdate -group {front_buf
} /harness/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/rst
add wave -noupdate -group {front_buf
} /harness/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/wr_clk
add wave -noupdate -group {front_buf
} /harness/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/wr_en
add wave -noupdate -group {front_buf
} /harness/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/full
add wave -noupdate -group {front_buf
} /harness/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/prog_full
add wave -noupdate -group {front_buf
} /harness/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/din
add wave -noupdate -group {front_buf
} /harness/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/rd_clk
add wave -noupdate -group {front_buf
} /harness/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/rd_en
add wave -noupdate -group {front_buf
} /harness/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/empty
add wave -noupdate -group {front_buf
} /harness/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/prog_empty
add wave -noupdate -group {front_buf
} /harness/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/dout
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/clk
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/reset
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/iv_frame_depth
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_start_full_frame
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_start_quick
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_fval
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/iv_buf_dout
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/o_buf_rd_en
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_buf_pe
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_buf_empty
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/ov_wr_frame_ptr
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/ov_wr_addr
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/o_writing
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/o_wr_req
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_wr_ack
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/iv_rd_frame_ptr
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_reading
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_calib_done
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/o_p2_cmd_en
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/ov_p2_cmd_instr
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/ov_p2_cmd_bl
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/ov_p2_cmd_byte_addr
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_p2_cmd_empty
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_p2_cmd_full
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/o_p2_wr_en
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/ov_p2_wr_mask
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/ov_p2_wr_data
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_p2_wr_full
add wave -noupdate -group {wr_logic
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_p2_wr_empty
add wave -noupdate -group {wr_logic_int
} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_p2_wr_full
add wave -noupdate -group {wr_logic_int
} -radix ascii /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/state_ascii
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/clk
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/reset
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/iv_frame_depth
add wave -noupdate -group {rd_logic
} -radix unsigned /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/iv_frame_size
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_start_full_frame
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_start_quick
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/o_reset_back_buf
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/ov_buf_din
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/o_buf_wr_en
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_buf_pf
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_buf_full
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_buf_empty
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_buf_dout32
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/ov_rd_frame_ptr
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/o_rd_req
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_rd_ack
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/o_reading
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/iv_wr_frame_ptr
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/iv_wr_addr
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_writing
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_calib_done
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/o_p3_cmd_en
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/ov_p3_cmd_instr
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/ov_p3_cmd_bl
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/ov_p3_cmd_byte_addr
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_p3_cmd_empty
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_p3_cmd_full
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/o_p3_rd_en
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/iv_p3_rd_data
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_p3_rd_full
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_p3_rd_empty
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_p3_rd_overflow
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_p3_rd_error
add wave -noupdate -group {rd_logic
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_p2_cmd_empty
add wave -noupdate -group {rd_logic_int
} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/frame_depth_reg
add wave -noupdate -group {rd_logic_int
} -radix unsigned /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/frame_size_reg
add wave -noupdate -group {rd_logic_int
} -radix ascii /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/state_ascii
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/fifo_rd_int
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_p3_rd_empty
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_buf_full
add wave -noupdate -group {rd_back_buf
} /harness/rd_back_buf_inst/clk
add wave -noupdate -group {rd_back_buf
} /harness/rd_back_buf_inst/i_empty
add wave -noupdate -group {rd_back_buf
} {/harness/rd_back_buf_inst/iv_pix_data[32]}
add wave -noupdate -group {rd_back_buf
} /harness/rd_back_buf_inst/iv_pix_data
add wave -noupdate -group {rd_back_buf
} /harness/rd_back_buf_inst/o_rd
add wave -noupdate -group {rd_back_buf
} /harness/rd_back_buf_inst/o_fval
add wave -noupdate -group {rd_back_buf
} /harness/rd_back_buf_inst/o_lval
add wave -noupdate -group {rd_back_buf
} /harness/rd_back_buf_inst/ov_pix_data
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_dram_dq
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_dram_a
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_dram_ba
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_dram_ras_n
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_dram_cas_n
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_dram_we_n
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_dram_odt
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_dram_reset_n
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_dram_cke
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_dram_dm
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_dram_udqs
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_dram_udqs_n
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_rzq
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_zio
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_dram_udm
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_dram_dqs
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_dram_dqs_n
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_dram_ck
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/mcb3_dram_ck_n
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_calib_done
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p2_cmd_clk
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p2_cmd_en
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p2_cmd_instr
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p2_cmd_bl
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p2_cmd_byte_addr
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p2_cmd_empty
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p2_cmd_full
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p2_wr_clk
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p2_wr_en
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p2_wr_mask
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p2_wr_data
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p2_wr_full
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p2_wr_empty
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p2_wr_count
add wave -noupdate -expand -group {mcb
} -color {Slate Blue} /harness/frame_buffer_inst/mig_core_inst/c3_p2_wr_underrun
add wave -noupdate -expand -group {mcb
} -color {Slate Blue} /harness/frame_buffer_inst/mig_core_inst/c3_p2_wr_error
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p3_cmd_clk
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p3_cmd_en
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p3_cmd_instr
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p3_cmd_bl
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p3_cmd_byte_addr
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p3_cmd_empty
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p3_cmd_full
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p3_rd_clk
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p3_rd_en
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p3_rd_data
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p3_rd_full
add wave -noupdate -expand -group {mcb
} -color Red /harness/frame_buffer_inst/mig_core_inst/c3_p3_rd_empty
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_p3_rd_count
add wave -noupdate -expand -group {mcb
} -color {Slate Blue} /harness/frame_buffer_inst/mig_core_inst/c3_p3_rd_overflow
add wave -noupdate -expand -group {mcb
} -color {Slate Blue} /harness/frame_buffer_inst/mig_core_inst/c3_p3_rd_error
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_async_rst
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_sysclk_2x
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_sysclk_2x_180
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_pll_ce_0
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_pll_ce_90
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_pll_lock
add wave -noupdate -expand -group {mcb
} /harness/frame_buffer_inst/mig_core_inst/c3_mcb_drp_clk
add wave -noupdate -color {Slate Blue} /harness/frame_buffer_inst/mig_core_inst/c3_p2_wr_underrun
add wave -noupdate -color {Slate Blue} /harness/frame_buffer_inst/mig_core_inst/c3_p2_wr_error
add wave -noupdate -color {Slate Blue} /harness/frame_buffer_inst/mig_core_inst/c3_p3_rd_overflow
add wave -noupdate -color {Slate Blue} /harness/frame_buffer_inst/mig_core_inst/c3_p3_rd_error
add wave -noupdate -divider {New Divider}
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/clk_osc
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/i_reset_sensor
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/i_stream_enable
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/clk_osc_bufg
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/reset_osc_bufg
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/async_rst
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/sysclk_2x
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/sysclk_2x_180
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/pll_ce_0
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/pll_ce_90
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/mcb_drp_clk
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/bufpll_mcb_lock
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/clk_frame_buf
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/reset_frame_buf
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/clk_pix
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/reset_pix
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/o_clk_sensor
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/o_reset_senser_n
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/o_sensor_reset_done
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/o_clk_usb_pclk
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/clk_gpif
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/reset_gpif
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/reset_u3_interface
add wave -noupdate -group {bfm
} -radix unsigned /harness/bfm/frame_size_byte
add wave -noupdate -group {bfm
} /harness/bfm/i_chunk_mode_active
add wave -noupdate -group {bfm
} -radix unsigned /harness/bfm/iv_frame_size
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {136419400 ps} 1} {{Cursor 2} {145691100 ps} 1} {{Cursor 3} {27766611 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 179
configure wave -valuecolwidth 53
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {27696356 ps} {27851203 ps}
