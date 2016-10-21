onerror {resume}
quietly virtual signal -install /harness/frame_buffer_inst/wrap_rd_logic_inst/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440_inst { /harness/frame_buffer_inst/wrap_rd_logic_inst/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440_inst/dout[31:0]} dout_low
quietly virtual function -install /harness/frame_buffer_inst/wrap_rd_logic_inst -env /harness/rd_back_buf_inst { &{/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[23], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[22], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[21], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[20], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[19], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[18], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[17], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[16], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[15], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[14], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[13], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[12], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[11], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[10], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[9], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[8], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[7], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[6], /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[5] }} rd_addr_high
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider sensor
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
add wave -noupdate -expand -group {mt9p031
} -radix unsigned /driver_mt9p031/mt9p031_model_inst/ov_dout
add wave -noupdate -divider clock
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/clk_osc
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/async_rst
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/sysclk_2x
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/sysclk_2x_180
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/pll_ce_0
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/pll_ce_90
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/mcb_drp_clk
add wave -noupdate -group clock_reset /driver_clock_reset/clock_reset_inst/bufpll_mcb_lock
add wave -noupdate -divider u3v_format
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/clk
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/reset
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/i_fval
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/i_data_valid
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/iv_data
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/i_stream_enable
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/i_acquisition_start
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/iv_pixel_format
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/i_chunk_mode_active
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/i_chunkid_en_ts
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/i_chunkid_en_fid
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/iv_timestamp
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/iv_chunk_size_img
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/i_multi_roi_global_en
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/iv_multi_roi_single_en
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/iv_chunk_size_img_mroi
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/iv_offset_x_mroi
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/iv_offset_y_mroi
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/iv_size_x_mroi
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/iv_size_y_mroi
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/iv_trailer_size_y_mroi
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/o_fval
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/o_data_valid
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/o_leader_flag
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/o_trailer_flag
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/o_chunk_flag
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/o_image_flag
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/o_trailer_final_flag
add wave -noupdate -group u3v_format /driver_u3v_format/u3v_format_inst/ov_data
add wave -noupdate -divider fb
add wave -noupdate /harness/frame_buffer_inst/o_calib_done
add wave -noupdate -group fb_io /harness/frame_buffer_inst/clk_in
add wave -noupdate -group fb_io /harness/frame_buffer_inst/i_fval
add wave -noupdate -group fb_io /harness/frame_buffer_inst/i_dval
add wave -noupdate -group fb_io /harness/frame_buffer_inst/i_leader_flag
add wave -noupdate -group fb_io /harness/frame_buffer_inst/i_trailer_flag
add wave -noupdate -group fb_io /harness/frame_buffer_inst/i_chunk_flag
add wave -noupdate -group fb_io /harness/frame_buffer_inst/i_image_flag
add wave -noupdate -group fb_io /harness/frame_buffer_inst/i_trailer_final_flag
add wave -noupdate -group fb_io /harness/frame_buffer_inst/iv_din
add wave -noupdate -group fb_io /harness/frame_buffer_inst/o_front_fifo_overflow
add wave -noupdate -group fb_io /harness/frame_buffer_inst/clk_out
add wave -noupdate -group fb_io /harness/frame_buffer_inst/i_buf_rd
add wave -noupdate -group fb_io /harness/frame_buffer_inst/o_back_buf_empty
add wave -noupdate -group fb_io /harness/frame_buffer_inst/ov_dout
add wave -noupdate -group fb_io /harness/frame_buffer_inst/clk_frame_buf
add wave -noupdate -group fb_io /harness/frame_buffer_inst/reset_frame_buf
add wave -noupdate -group fb_io /harness/frame_buffer_inst/i_stream_enable
add wave -noupdate -group fb_io /harness/frame_buffer_inst/iv_pixel_format
add wave -noupdate -group fb_io /harness/frame_buffer_inst/iv_frame_depth
add wave -noupdate -group fb_io /harness/frame_buffer_inst/i_chunk_mode_active
add wave -noupdate -group fb_io /harness/frame_buffer_inst/i_multi_roi_global_en
add wave -noupdate -group fb_io /harness/frame_buffer_inst/iv_payload_size_mroi
add wave -noupdate -group fb_io /harness/frame_buffer_inst/iv_image_size_mroi
add wave -noupdate -group fb_io /harness/frame_buffer_inst/iv_roi_pic_width
add wave -noupdate -group fb_io /harness/frame_buffer_inst/iv_roi_pic_width_mroi
add wave -noupdate -group fb_io /harness/frame_buffer_inst/iv_start_mroi
add wave -noupdate -group front_fifo /harness/frame_buffer_inst/wrap_wr_logic_inst/genblk1/frame_buf_front_fifo_w69d2048_pe1024_inst/rst
add wave -noupdate -group front_fifo /harness/frame_buffer_inst/wrap_wr_logic_inst/genblk1/frame_buf_front_fifo_w69d2048_pe1024_inst/wr_clk
add wave -noupdate -group front_fifo /harness/frame_buffer_inst/wrap_wr_logic_inst/genblk1/frame_buf_front_fifo_w69d2048_pe1024_inst/wr_en
add wave -noupdate -group front_fifo /harness/frame_buffer_inst/wrap_wr_logic_inst/genblk1/frame_buf_front_fifo_w69d2048_pe1024_inst/full
add wave -noupdate -group front_fifo /harness/frame_buffer_inst/wrap_wr_logic_inst/genblk1/frame_buf_front_fifo_w69d2048_pe1024_inst/din
add wave -noupdate -group front_fifo /harness/frame_buffer_inst/wrap_wr_logic_inst/genblk1/frame_buf_front_fifo_w69d2048_pe1024_inst/rd_clk
add wave -noupdate -group front_fifo /harness/frame_buffer_inst/wrap_wr_logic_inst/genblk1/frame_buf_front_fifo_w69d2048_pe1024_inst/rd_en
add wave -noupdate -group front_fifo /harness/frame_buffer_inst/wrap_wr_logic_inst/genblk1/frame_buf_front_fifo_w69d2048_pe1024_inst/empty
add wave -noupdate -group front_fifo /harness/frame_buffer_inst/wrap_wr_logic_inst/genblk1/frame_buf_front_fifo_w69d2048_pe1024_inst/prog_empty
add wave -noupdate -group front_fifo {/harness/frame_buffer_inst/wrap_wr_logic_inst/genblk1/frame_buf_front_fifo_w69d2048_pe1024_inst/dout[68]}
add wave -noupdate -group front_fifo {/harness/frame_buffer_inst/wrap_wr_logic_inst/genblk1/frame_buf_front_fifo_w69d2048_pe1024_inst/dout[67]}
add wave -noupdate -group front_fifo {/harness/frame_buffer_inst/wrap_wr_logic_inst/genblk1/frame_buf_front_fifo_w69d2048_pe1024_inst/dout[66]}
add wave -noupdate -group front_fifo {/harness/frame_buffer_inst/wrap_wr_logic_inst/genblk1/frame_buf_front_fifo_w69d2048_pe1024_inst/dout[65]}
add wave -noupdate -group front_fifo {/harness/frame_buffer_inst/wrap_wr_logic_inst/genblk1/frame_buf_front_fifo_w69d2048_pe1024_inst/dout[64]}
add wave -noupdate -group front_fifo /harness/frame_buffer_inst/wrap_wr_logic_inst/genblk1/frame_buf_front_fifo_w69d2048_pe1024_inst/dout
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/clk_in
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/i_fval
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/i_dval
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/i_leader_flag
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/i_trailer_flag
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/i_chunk_flag
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/i_image_flag
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/i_trailer_final_flag
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/iv_din
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/o_front_fifo_overflow
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/clk
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/reset
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/ov_wr_ptr
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/ov_wr_addr
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/o_wr_ptr_changing
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/iv_rd_ptr
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/i_reading
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/o_writing
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/i_stream_enable
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/iv_frame_depth
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/ov_frame_depth
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/i_calib_done
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/o_wr_cmd_en
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/ov_wr_cmd_instr
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/ov_wr_cmd_bl
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/ov_wr_cmd_byte_addr
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/i_wr_cmd_empty
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/i_wr_cmd_full
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/o_wr_en
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/ov_wr_mask
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/ov_wr_data
add wave -noupdate -group wr_io /harness/frame_buffer_inst/wrap_wr_logic_inst/i_wr_full
add wave -noupdate -group wr_int -radix ascii /harness/frame_buffer_inst/wrap_wr_logic_inst/state_ascii
add wave -noupdate -group wr_int /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_ptr
add wave -noupdate -group wr_int /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr
add wave -noupdate -group wr_int -radix unsigned /harness/frame_buffer_inst/wrap_wr_logic_inst/word_cnt
add wave -noupdate -group wr_int /harness/frame_buffer_inst/wrap_wr_logic_inst/fifo_rd_en
add wave -noupdate -group wr_int /harness/frame_buffer_inst/wrap_wr_logic_inst/active_flag
add wave -noupdate -group wr_int /harness/frame_buffer_inst/wrap_wr_logic_inst/active_flag_fall
add wave -noupdate -group wr_int /harness/frame_buffer_inst/wrap_wr_logic_inst/start_addr
add wave -noupdate -group wr_int /harness/frame_buffer_inst/wrap_wr_logic_inst/flag_num_cnt
add wave -noupdate -group wr_int /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_ptr_changing
add wave -noupdate -group wr_int /harness/frame_buffer_inst/wrap_wr_logic_inst/fifo_empty
add wave -noupdate -group wr_int {/harness/frame_buffer_inst/wrap_wr_logic_inst/fval_shift[1]}
add wave -noupdate /harness/frame_buffer_inst/wrap_wr_logic_inst/o_wr_cmd_en
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/o_rd_cmd_en
add wave -noupdate -radix unsigned -childformat {{{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[18]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[17]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[16]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[15]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[14]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[13]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[12]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[11]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[10]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[9]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[8]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[7]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[6]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[5]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[4]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[3]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[2]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[1]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[0]} -radix unsigned}} -subitemconfig {{/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[18]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[17]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[16]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[15]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[14]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[13]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[12]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[11]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[10]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[9]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[8]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[7]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[6]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[5]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[4]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[3]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[2]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[1]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr[0]} {-height 15 -radix unsigned}} /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr
add wave -noupdate -radix unsigned -childformat {{(18) -radix unsigned} {(17) -radix unsigned} {(16) -radix unsigned} {(15) -radix unsigned} {(14) -radix unsigned} {(13) -radix unsigned} {(12) -radix unsigned} {(11) -radix unsigned} {(10) -radix unsigned} {(9) -radix unsigned} {(8) -radix unsigned} {(7) -radix unsigned} {(6) -radix unsigned} {(5) -radix unsigned} {(4) -radix unsigned} {(3) -radix unsigned} {(2) -radix unsigned} {(1) -radix unsigned} {(0) -radix unsigned}} -subitemconfig {{/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[23]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[22]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[21]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[20]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[19]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[18]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[17]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[16]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[15]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[14]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[13]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[12]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[11]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[10]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[9]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[8]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[7]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[6]} {-radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr[5]} {-radix unsigned}} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr_high
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/ov_rd_ptr
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/o_reading
add wave -noupdate /harness/frame_buffer_inst/wrap_wr_logic_inst/ov_wr_addr
add wave -noupdate /harness/frame_buffer_inst/wrap_wr_logic_inst/ov_wr_ptr
add wave -noupdate /harness/frame_buffer_inst/wrap_wr_logic_inst/o_writing
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/clk_out
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/i_buf_rd
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/o_back_buf_empty
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/ov_dout
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/iv_payload_size_mroi
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/iv_image_size_mroi
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/iv_roi_pic_width
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/iv_roi_pic_width_mroi
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/iv_start_mroi
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/clk
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/reset
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/iv_wr_ptr
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/iv_wr_addr
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/ov_rd_ptr
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/i_writing
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/o_reading
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/i_stream_enable
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/iv_pixel_format
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/iv_frame_depth
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/i_wr_ptr_changing
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/i_chunk_mode_active
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/i_calib_done
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/i_wr_cmd_empty
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/i_rd_cmd_empty
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/i_rd_cmd_full
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/o_rd_cmd_en
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/ov_rd_cmd_instr
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/ov_rd_cmd_bl
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/ov_rd_cmd_byte_addr
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/iv_rd_data
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/i_rd_empty
add wave -noupdate -group rd_io /harness/frame_buffer_inst/wrap_rd_logic_inst/o_rd_en
add wave -noupdate -expand -group rd_int -radix ascii /harness/frame_buffer_inst/wrap_rd_logic_inst/state_ascii
add wave -noupdate -expand -group rd_int -radix unsigned -childformat {{{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[7]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[6]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[5]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[4]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[3]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[2]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[1]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0]} -radix unsigned -childformat {{{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][15]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][14]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][13]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][12]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][11]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][10]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][9]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][8]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][7]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][6]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][5]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][4]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][3]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][2]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][1]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][0]} -radix unsigned}}}} -subitemconfig {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[7]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[6]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[5]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[4]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[3]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[2]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[1]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0]} {-height 15 -radix unsigned -childformat {{{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][15]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][14]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][13]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][12]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][11]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][10]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][9]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][8]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][7]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][6]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][5]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][4]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][3]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][2]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][1]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][0]} -radix unsigned}}} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][15]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][14]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][13]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][12]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][11]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][10]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][9]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][8]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][7]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][6]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][5]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][4]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][3]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][2]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][1]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0][0]} {-height 15 -radix unsigned}} /harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch
add wave -noupdate -expand -group rd_int -radix unsigned -childformat {{{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7]} -radix unsigned -childformat {{{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][31]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][30]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][29]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][28]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][27]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][26]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][25]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][24]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][23]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][22]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][21]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][20]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][19]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][18]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][17]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][16]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][15]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][14]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][13]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][12]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][11]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][10]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][9]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][8]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][7]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][6]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][5]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][4]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][3]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][2]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][1]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][0]} -radix unsigned}}} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[6]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[5]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[4]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[3]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[2]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[1]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[0]} -radix unsigned}} -subitemconfig {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7]} {-height 15 -radix unsigned -childformat {{{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][31]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][30]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][29]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][28]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][27]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][26]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][25]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][24]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][23]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][22]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][21]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][20]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][19]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][18]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][17]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][16]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][15]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][14]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][13]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][12]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][11]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][10]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][9]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][8]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][7]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][6]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][5]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][4]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][3]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][2]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][1]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][0]} -radix unsigned}}} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][31]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][30]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][29]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][28]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][27]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][26]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][25]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][24]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][23]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][22]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][21]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][20]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][19]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][18]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][17]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][16]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][15]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][14]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][13]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][12]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][11]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][10]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][9]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][8]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][7]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][6]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][5]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][4]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][3]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][2]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][1]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[7][0]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[6]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[5]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[4]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[3]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[2]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[1]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch[0]} {-height 15 -radix unsigned}} /harness/frame_buffer_inst/wrap_rd_logic_inst/payload_size_ch
add wave -noupdate -expand -group rd_int -radix unsigned -childformat {{{/harness/frame_buffer_inst/wrap_rd_logic_inst/image_size_ch[7]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/image_size_ch[6]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/image_size_ch[5]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/image_size_ch[4]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/image_size_ch[3]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/image_size_ch[2]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/image_size_ch[1]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/image_size_ch[0]} -radix unsigned}} -subitemconfig {{/harness/frame_buffer_inst/wrap_rd_logic_inst/image_size_ch[7]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/image_size_ch[6]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/image_size_ch[5]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/image_size_ch[4]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/image_size_ch[3]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/image_size_ch[2]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/image_size_ch[1]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/image_size_ch[0]} {-height 15 -radix unsigned}} /harness/frame_buffer_inst/wrap_rd_logic_inst/image_size_ch
add wave -noupdate -expand -group rd_int -radix unsigned -childformat {{{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7]} -radix unsigned -childformat {{{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][31]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][30]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][29]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][28]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][27]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][26]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][25]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][24]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][23]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][22]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][21]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][20]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][19]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][18]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][17]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][16]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][15]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][14]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][13]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][12]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][11]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][10]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][9]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][8]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][7]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][6]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][5]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][4]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][3]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][2]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][1]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][0]} -radix unsigned}}} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[6]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[5]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[4]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[3]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[2]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[1]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[0]} -radix unsigned}} -subitemconfig {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7]} {-height 15 -radix unsigned -childformat {{{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][31]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][30]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][29]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][28]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][27]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][26]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][25]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][24]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][23]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][22]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][21]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][20]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][19]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][18]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][17]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][16]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][15]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][14]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][13]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][12]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][11]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][10]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][9]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][8]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][7]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][6]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][5]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][4]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][3]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][2]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][1]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][0]} -radix unsigned}}} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][31]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][30]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][29]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][28]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][27]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][26]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][25]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][24]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][23]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][22]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][21]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][20]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][19]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][18]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][17]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][16]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][15]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][14]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][13]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][12]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][11]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][10]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][9]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][8]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][7]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][6]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][5]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][4]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][3]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][2]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][1]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[7][0]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[6]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[5]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[4]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[3]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[2]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[1]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch[0]} {-height 15 -radix unsigned}} /harness/frame_buffer_inst/wrap_rd_logic_inst/start_mroi_ch
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_ptr
add wave -noupdate -expand -group rd_int -radix unsigned /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/leader_addr
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/chunk_addr
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/trailer_addr
add wave -noupdate -expand -group rd_int -radix hexadecimal /harness/frame_buffer_inst/wrap_rd_logic_inst/image_addr
add wave -noupdate -expand -group rd_int -radix unsigned /harness/frame_buffer_inst/wrap_rd_logic_inst/word_cnt_flag
add wave -noupdate -expand -group rd_int -radix unsigned /harness/frame_buffer_inst/wrap_rd_logic_inst/chunk_size
add wave -noupdate -expand -group rd_int -radix unsigned -childformat {{{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[25]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[24]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[23]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[22]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[21]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[20]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[19]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[18]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[17]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[16]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[15]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[14]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[13]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[12]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[11]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[10]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[9]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[8]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[7]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[6]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[5]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[4]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[3]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[2]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[1]} -radix unsigned} {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[0]} -radix unsigned}} -subitemconfig {{/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[25]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[24]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[23]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[22]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[21]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[20]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[19]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[18]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[17]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[16]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[15]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[14]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[13]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[12]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[11]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[10]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[9]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[8]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[7]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[6]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[5]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[4]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[3]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[2]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[1]} {-height 15 -radix unsigned} {/harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size[0]} {-height 15 -radix unsigned}} /harness/frame_buffer_inst/wrap_rd_logic_inst/flag_word_size
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/remainder_head
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/remainder_tail
add wave -noupdate -expand -group rd_int -radix hexadecimal /harness/frame_buffer_inst/wrap_rd_logic_inst/roi_num
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/last_roi
add wave -noupdate -expand -group rd_int -radix unsigned /harness/frame_buffer_inst/wrap_rd_logic_inst/word_cnt
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/burst_done
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/line_done
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/line_done_int
add wave -noupdate -expand -group rd_int -radix unsigned /harness/frame_buffer_inst/wrap_rd_logic_inst/word_cnt_line
add wave -noupdate -expand -group rd_int -radix unsigned /harness/frame_buffer_inst/wrap_rd_logic_inst/line_word_size
add wave -noupdate -expand -group rd_int -radix ascii /harness/frame_buffer_inst/wrap_rd_logic_inst/state_ascii
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/flag_done
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/flag_done_int
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/iv_rd_data
add wave -noupdate -expand -group rd_int -color {Slate Blue} /harness/frame_buffer_inst/wrap_rd_logic_inst/flag_num_cnt
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/line_equal
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/last_flag
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/dummy_head
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/dummy_tail
add wave -noupdate -expand -group rd_int /harness/frame_buffer_inst/wrap_rd_logic_inst/able_to_read
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/iv_roi_pic_width
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_global
add wave -noupdate {/harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_ch[0]}
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_global_format
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/roi_pic_width_active_format
add wave -noupdate -expand -group sensor /driver_mt9p031/mt9p031_model_inst/o_fval
add wave -noupdate -expand -group sensor /driver_mt9p031/mt9p031_model_inst/o_lval
add wave -noupdate -group back_fifo /harness/frame_buffer_inst/wrap_rd_logic_inst/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440_inst/rst
add wave -noupdate -group back_fifo /harness/frame_buffer_inst/wrap_rd_logic_inst/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440_inst/wr_clk
add wave -noupdate -group back_fifo /harness/frame_buffer_inst/wrap_rd_logic_inst/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440_inst/wr_en
add wave -noupdate -group back_fifo /harness/frame_buffer_inst/wrap_rd_logic_inst/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440_inst/full
add wave -noupdate -group back_fifo /harness/frame_buffer_inst/wrap_rd_logic_inst/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440_inst/prog_full
add wave -noupdate -group back_fifo {/harness/frame_buffer_inst/wrap_rd_logic_inst/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440_inst/din[65]}
add wave -noupdate -group back_fifo {/harness/frame_buffer_inst/wrap_rd_logic_inst/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440_inst/din[32]}
add wave -noupdate -group back_fifo /harness/frame_buffer_inst/wrap_rd_logic_inst/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440_inst/din
add wave -noupdate -group back_fifo /harness/frame_buffer_inst/wrap_rd_logic_inst/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440_inst/rd_clk
add wave -noupdate -group back_fifo /harness/frame_buffer_inst/wrap_rd_logic_inst/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440_inst/rd_en
add wave -noupdate -group back_fifo /harness/frame_buffer_inst/wrap_rd_logic_inst/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440_inst/empty
add wave -noupdate -group back_fifo {/harness/frame_buffer_inst/wrap_rd_logic_inst/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440_inst/dout[32]}
add wave -noupdate -group back_fifo /harness/frame_buffer_inst/wrap_rd_logic_inst/frame_buf_back_fifo_ww66wd512rw33wd1024_pf440_inst/dout_low
add wave -noupdate -divider mig
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p0_cmd_clk
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p0_cmd_en
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p0_cmd_instr
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p0_cmd_bl
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p0_cmd_byte_addr
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p0_cmd_empty
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p0_cmd_full
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p0_wr_clk
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p0_wr_en
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p0_wr_mask
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p0_wr_data
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p0_wr_full
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p0_wr_empty
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p0_wr_count
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p0_wr_underrun
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p0_wr_error
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p1_cmd_clk
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p1_cmd_en
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p1_cmd_instr
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p1_cmd_bl
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p1_cmd_byte_addr
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p1_cmd_empty
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p1_cmd_full
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p1_rd_clk
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p1_rd_en
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p1_rd_data
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p1_rd_full
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p1_rd_empty
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p1_rd_count
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p1_rd_overflow
add wave -noupdate -group mig_core /harness/frame_buffer_inst/mig_core_inst/c1_p1_rd_error
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group rd_back_buf /harness/rd_back_buf_inst/clk
add wave -noupdate -expand -group rd_back_buf /harness/rd_back_buf_inst/i_stream_enable
add wave -noupdate -expand -group rd_back_buf /harness/rd_back_buf_inst/iv_image_size_mroi
add wave -noupdate -expand -group rd_back_buf /harness/rd_back_buf_inst/i_empty
add wave -noupdate -expand -group rd_back_buf /harness/rd_back_buf_inst/iv_pix_data
add wave -noupdate -expand -group rd_back_buf -color {Slate Blue} /harness/rd_back_buf_inst/o_rd
add wave -noupdate -expand -group rd_back_buf /harness/rd_back_buf_inst/o_fval
add wave -noupdate -expand -group rd_back_buf /harness/rd_back_buf_inst/o_lval
add wave -noupdate -expand -group rd_back_buf /harness/rd_back_buf_inst/ov_pix_data
add wave -noupdate -expand -group rd_back_buf -radix unsigned /harness/rd_back_buf_inst/ov_pix_data
add wave -noupdate -expand -group rd_back_buf_int -radix ascii /harness/rd_back_buf_inst/state_ascii
add wave -noupdate -expand -group rd_back_buf_int /harness/rd_back_buf_inst/leader_done
add wave -noupdate -expand -group rd_back_buf_int -radix unsigned /harness/rd_back_buf_inst/leader_num_cnt
add wave -noupdate -expand -group rd_back_buf_int -radix unsigned /harness/rd_back_buf_inst/leader_size
add wave -noupdate -expand -group rd_back_buf_int -radix unsigned /harness/rd_back_buf_inst/image_num_cnt
add wave -noupdate -expand -group rd_back_buf_int -radix unsigned /harness/rd_back_buf_inst/image_size
add wave -noupdate -expand -group rd_back_buf_int /harness/rd_back_buf_inst/image_done
add wave -noupdate -expand -group rd_back_buf_int /harness/rd_back_buf_inst/trailer_num_cnt
add wave -noupdate -expand -group rd_back_buf_int /harness/rd_back_buf_inst/trailer_done
add wave -noupdate -expand -group rd_back_buf_int /harness/rd_back_buf_inst/chunk_num_cnt
add wave -noupdate -expand -group rd_back_buf_int /harness/rd_back_buf_inst/chunk_done
add wave -noupdate -expand -group rd_back_buf_int -radix unsigned -childformat {{{/harness/rd_back_buf_inst/image_size[31]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[30]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[29]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[28]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[27]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[26]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[25]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[24]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[23]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[22]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[21]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[20]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[19]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[18]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[17]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[16]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[15]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[14]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[13]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[12]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[11]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[10]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[9]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[8]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[7]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[6]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[5]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[4]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[3]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[2]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[1]} -radix unsigned} {{/harness/rd_back_buf_inst/image_size[0]} -radix unsigned}} -subitemconfig {{/harness/rd_back_buf_inst/image_size[31]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[30]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[29]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[28]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[27]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[26]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[25]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[24]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[23]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[22]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[21]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[20]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[19]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[18]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[17]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[16]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[15]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[14]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[13]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[12]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[11]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[10]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[9]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[8]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[7]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[6]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[5]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[4]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[3]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[2]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[1]} {-height 15 -radix unsigned} {/harness/rd_back_buf_inst/image_size[0]} {-height 15 -radix unsigned}} /harness/rd_back_buf_inst/image_size
add wave -noupdate -expand -group rd_back_buf_int /harness/rd_back_buf_inst/roi_num
add wave -noupdate -expand -group rd_back_buf_int /harness/rd_back_buf_inst/image_size
add wave -noupdate -expand -group rd_back_buf_int /harness/rd_back_buf_inst/chunk_size
add wave -noupdate -expand -group rd_back_buf_int /harness/rd_back_buf_inst/trailer_size
add wave -noupdate -expand -group rd_back_buf_int /harness/rd_back_buf_inst/roi_num
add wave -noupdate -expand -group rd_back_buf_int /harness/rd_back_buf_inst/image_num_cnt
add wave -noupdate -divider ddr
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
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 6} {328779066 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 184
configure wave -valuecolwidth 40
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
WaveRestoreZoom {0 ps} {745444324 ps}
