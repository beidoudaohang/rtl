onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider sensor
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/DATA_WD_64
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/DATA_WD_32
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/SHORT_REG_WD
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/REG_WD
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/LONG_REG_WD
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/I2C_MASTER_CLOCK_FREQ_KHZ
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/I2C_CLOCK_FREQ_KHZ
add wave -noupdate -group {localparam
} -radix ascii /harness/mer_1810_21u3x_inst/REG_INIT_VALUE
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/MAX_TRIG_FILTER_TIME_MS
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/TRIG_FILTER_WIDTH
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/MAX_TRIG_DELAY_TIME_MS
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/TRIG_DELAY_WIDTH
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/LED_CTRL_WIDTH
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/PLL_CHECK_CLK_PERIOD_NS
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/INT_TIME_INTERVAL_MS
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/SENSOR_MAX_EDGE
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/WB_OFFSET_WIDTH
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/WB_GAIN_WIDTH
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/WB_STATIS_WIDTH
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/WB_RATIO
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/GREY_OFFSET_WIDTH
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/GREY_STATIS_WIDTH
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/BUF_DEPTH_WD
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/FSIZE_WD
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/BSIZE_WD
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/PACKET_SIZE_WD
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/DMA_SIZE
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/SENSOR_ALL_PIX_DIV4
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/WB_STATIS_MAX_DIV4
add wave -noupdate -group {localparam
} -radix unsigned /harness/mer_1810_21u3x_inst/GREY_STATIS_MAX_DIV4
add wave -noupdate -group pll_hispi /driver_hispi/pll_hispi_inst/sys_clk
add wave -noupdate -group pll_hispi /driver_hispi/pll_hispi_inst/pll_lock
add wave -noupdate -group pll_hispi /driver_hispi/pll_hispi_inst/clk_out0
add wave -noupdate -group {sensor
} /driver_hispi/hispi_stim_inst/rstn
add wave -noupdate -group {sensor
} /driver_hispi/hispi_stim_inst/sclk
add wave -noupdate -group {sensor
} /driver_hispi/hispi_stim_inst/vd_active_height
add wave -noupdate -group {sensor
} /driver_hispi/hispi_stim_inst/vd_active_width
add wave -noupdate -group {sensor
} /driver_hispi/hispi_stim_inst/vd_blank_height
add wave -noupdate -group {sensor
} /driver_hispi/hispi_stim_inst/vd_blank_width
add wave -noupdate -group {sensor
} /driver_hispi/hispi_stim_inst/sclk_o
add wave -noupdate -group {sensor
} /driver_hispi/hispi_stim_inst/sdata_o
add wave -noupdate -group {sensor_out
} /driver_hispi/hispi_stim_inst/sclk_o
add wave -noupdate -group {sensor_out
} /driver_hispi/hispi_stim_inst/sdata_o
add wave -noupdate -divider clock_reset
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/clk_osc
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/i_reset_sensor
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/i_stream_enable
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/clk_osc_bufg
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/reset_osc_bufg
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/async_rst
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/sysclk_2x
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/sysclk_2x_180
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/pll_ce_0
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/pll_ce_90
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/mcb_drp_clk
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/bufpll_mcb_lock
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/clk_frame_buf
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/reset_frame_buf
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/clk_pix
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/reset_pix
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/clk_pix_2x
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/reset_pix_2x
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/o_clk_sensor
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/o_sensor_reset_n
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/o_sensor_reset_done
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/o_clk_usb_pclk
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/clk_gpif
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/reset_gpif
add wave -noupdate -group clock_reset /harness/mer_1810_21u3x_inst/clock_reset_inst/reset_u3_interface
add wave -noupdate -divider data_channel
add wave -noupdate -group {pll_reset
} /harness/mer_1810_21u3x_inst/data_channel_inst/pll_reset_inst/clk
add wave -noupdate -group {pll_reset
} /harness/mer_1810_21u3x_inst/data_channel_inst/pll_reset_inst/i_pll_lock
add wave -noupdate -group {pll_reset
} /harness/mer_1810_21u3x_inst/data_channel_inst/pll_reset_inst/o_pll_reset
add wave -noupdate -group {pll_reset
} /harness/mer_1810_21u3x_inst/data_channel_inst/pll_reset_inst/reset_cnt
add wave -noupdate -group {sync_buffer
} /harness/mer_1810_21u3x_inst/data_channel_inst/sync_buffer_inst/iv_pix_data
add wave -noupdate -group {sync_buffer
} /harness/mer_1810_21u3x_inst/data_channel_inst/sync_buffer_inst/clk_pix
add wave -noupdate -group {sync_buffer
} /harness/mer_1810_21u3x_inst/data_channel_inst/sync_buffer_inst/o_fval
add wave -noupdate -group {sync_buffer
} /harness/mer_1810_21u3x_inst/data_channel_inst/sync_buffer_inst/o_lval
add wave -noupdate -group {sync_buffer
} /harness/mer_1810_21u3x_inst/data_channel_inst/sync_buffer_inst/ov_pix_data
add wave -noupdate -group {stream_ctrl
} /harness/mer_1810_21u3x_inst/data_channel_inst/stream_ctrl_inst/clk
add wave -noupdate -group {stream_ctrl
} /harness/mer_1810_21u3x_inst/data_channel_inst/stream_ctrl_inst/i_fval
add wave -noupdate -group {stream_ctrl
} /harness/mer_1810_21u3x_inst/data_channel_inst/stream_ctrl_inst/i_lval
add wave -noupdate -group {stream_ctrl
} /harness/mer_1810_21u3x_inst/data_channel_inst/stream_ctrl_inst/iv_pix_data
add wave -noupdate -group {stream_ctrl
} /harness/mer_1810_21u3x_inst/data_channel_inst/stream_ctrl_inst/o_fval
add wave -noupdate -group {stream_ctrl
} /harness/mer_1810_21u3x_inst/data_channel_inst/stream_ctrl_inst/o_lval
add wave -noupdate -group {stream_ctrl
} /harness/mer_1810_21u3x_inst/data_channel_inst/stream_ctrl_inst/ov_pix_data
add wave -noupdate -group {stream_ctrl
} /harness/mer_1810_21u3x_inst/data_channel_inst/stream_ctrl_inst/i_acquisition_start
add wave -noupdate -group {stream_ctrl
} /harness/mer_1810_21u3x_inst/data_channel_inst/stream_ctrl_inst/i_stream_enable
add wave -noupdate -group {stream_ctrl
} /harness/mer_1810_21u3x_inst/data_channel_inst/stream_ctrl_inst/i_encrypt_state
add wave -noupdate -group {stream_ctrl
} /harness/mer_1810_21u3x_inst/data_channel_inst/stream_ctrl_inst/iv_pixel_format
add wave -noupdate -group {stream_ctrl
} /harness/mer_1810_21u3x_inst/data_channel_inst/stream_ctrl_inst/iv_test_image_sel
add wave -noupdate -group {stream_ctrl
} /harness/mer_1810_21u3x_inst/data_channel_inst/stream_ctrl_inst/o_full_frame_state
add wave -noupdate -group {stream_ctrl
} /harness/mer_1810_21u3x_inst/data_channel_inst/stream_ctrl_inst/ov_pixel_format
add wave -noupdate -group {stream_ctrl
} /harness/mer_1810_21u3x_inst/data_channel_inst/stream_ctrl_inst/ov_test_image_sel
add wave -noupdate -group {data_mask
} /harness/mer_1810_21u3x_inst/data_channel_inst/data_mask_inst/clk
add wave -noupdate -group {data_mask
} /harness/mer_1810_21u3x_inst/data_channel_inst/data_mask_inst/i_pll_lock
add wave -noupdate -group {data_mask
} /harness/mer_1810_21u3x_inst/data_channel_inst/data_mask_inst/i_trigger_mode
add wave -noupdate -group {data_mask
} /harness/mer_1810_21u3x_inst/data_channel_inst/data_mask_inst/i_fval
add wave -noupdate -group {data_mask
} /harness/mer_1810_21u3x_inst/data_channel_inst/data_mask_inst/i_lval
add wave -noupdate -group {data_mask
} /harness/mer_1810_21u3x_inst/data_channel_inst/data_mask_inst/iv_pix_data
add wave -noupdate -group {data_mask
} /harness/mer_1810_21u3x_inst/data_channel_inst/data_mask_inst/o_fval
add wave -noupdate -group {data_mask
} /harness/mer_1810_21u3x_inst/data_channel_inst/data_mask_inst/o_lval
add wave -noupdate -group {data_mask
} /harness/mer_1810_21u3x_inst/data_channel_inst/data_mask_inst/ov_pix_data
add wave -noupdate -group width_cut /harness/mer_1810_21u3x_inst/data_channel_inst/width_cut_inst/clk
add wave -noupdate -group width_cut /harness/mer_1810_21u3x_inst/data_channel_inst/width_cut_inst/i_fval
add wave -noupdate -group width_cut /harness/mer_1810_21u3x_inst/data_channel_inst/width_cut_inst/i_lval
add wave -noupdate -group width_cut /harness/mer_1810_21u3x_inst/data_channel_inst/width_cut_inst/iv_data
add wave -noupdate -group width_cut /harness/mer_1810_21u3x_inst/data_channel_inst/width_cut_inst/iv_offset_x
add wave -noupdate -group width_cut /harness/mer_1810_21u3x_inst/data_channel_inst/width_cut_inst/iv_offset_width
add wave -noupdate -group width_cut /harness/mer_1810_21u3x_inst/data_channel_inst/width_cut_inst/o_fval
add wave -noupdate -group width_cut /harness/mer_1810_21u3x_inst/data_channel_inst/width_cut_inst/o_lval
add wave -noupdate /harness/mer_1810_21u3x_inst/data_channel_inst/width_cut_inst/ov_pix_data
add wave -noupdate -group {pix_sel
} /harness/mer_1810_21u3x_inst/data_channel_inst/pixelformat_sel_inst/clk
add wave -noupdate -group {pix_sel
} /harness/mer_1810_21u3x_inst/data_channel_inst/pixelformat_sel_inst/i_fval
add wave -noupdate -group {pix_sel
} /harness/mer_1810_21u3x_inst/data_channel_inst/pixelformat_sel_inst/i_lval
add wave -noupdate -group {pix_sel
} /harness/mer_1810_21u3x_inst/data_channel_inst/pixelformat_sel_inst/iv_pix_data
add wave -noupdate -group {pix_sel
} /harness/mer_1810_21u3x_inst/data_channel_inst/pixelformat_sel_inst/iv_pixel_format
add wave -noupdate -group {pix_sel
} /harness/mer_1810_21u3x_inst/data_channel_inst/pixelformat_sel_inst/o_fval
add wave -noupdate -group {pix_sel
} /harness/mer_1810_21u3x_inst/data_channel_inst/pixelformat_sel_inst/o_lval
add wave -noupdate -group {pix_sel
} /harness/mer_1810_21u3x_inst/data_channel_inst/pixelformat_sel_inst/ov_pix_data
add wave -noupdate -group {data_align
} /harness/mer_1810_21u3x_inst/data_channel_inst/data_align_inst/clk
add wave -noupdate -group {data_align
} /harness/mer_1810_21u3x_inst/data_channel_inst/data_align_inst/i_fval
add wave -noupdate -group {data_align
} /harness/mer_1810_21u3x_inst/data_channel_inst/data_align_inst/i_lval
add wave -noupdate -group {data_align
} /harness/mer_1810_21u3x_inst/data_channel_inst/data_align_inst/iv_pix_data
add wave -noupdate -group {data_align
} /harness/mer_1810_21u3x_inst/data_channel_inst/data_align_inst/iv_pixel_format
add wave -noupdate -group {data_align
} /harness/mer_1810_21u3x_inst/data_channel_inst/data_align_inst/o_fval
add wave -noupdate -group {data_align
} /harness/mer_1810_21u3x_inst/data_channel_inst/data_align_inst/o_pix_data_en
add wave -noupdate -group {data_align
} /harness/mer_1810_21u3x_inst/data_channel_inst/data_align_inst/ov_pix_data
add wave -noupdate -divider data_fix
add wave -noupdate -group data_fix /harness/mer_1810_21u3x_inst/data_fix_inst/clk_pix
add wave -noupdate -group data_fix /harness/mer_1810_21u3x_inst/data_fix_inst/reset_pix
add wave -noupdate -group data_fix /harness/mer_1810_21u3x_inst/data_fix_inst/i_fval
add wave -noupdate -group data_fix /harness/mer_1810_21u3x_inst/data_fix_inst/i_data_valid
add wave -noupdate -group data_fix /harness/mer_1810_21u3x_inst/data_fix_inst/iv_data
add wave -noupdate -group data_fix /harness/mer_1810_21u3x_inst/data_fix_inst/clk_pix_2x
add wave -noupdate -group data_fix /harness/mer_1810_21u3x_inst/data_fix_inst/reset_pix_2x
add wave -noupdate -group data_fix /harness/mer_1810_21u3x_inst/data_fix_inst/o_fval
add wave -noupdate -group data_fix /harness/mer_1810_21u3x_inst/data_fix_inst/o_data_valid
add wave -noupdate -group data_fix /harness/mer_1810_21u3x_inst/data_fix_inst/ov_data
add wave -noupdate -divider u3v_format
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/reset
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/clk
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/i_fval
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/i_data_valid
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/iv_data
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/i_stream_enable
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/i_acquisition_start
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/iv_pixel_format
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/i_chunk_mode_active
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/i_chunkid_en_ts
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/i_chunkid_en_fid
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/iv_chunk_size_img
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/iv_timestamp
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/iv_offset_x
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/iv_offset_y
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/iv_size_x
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/iv_size_y
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/iv_trailer_size_y
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/o_trailer_flag
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/o_fval
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/o_data_valid
add wave -noupdate -group {u3v_format
} /harness/mer_1810_21u3x_inst/u3v_format_inst/ov_data
add wave -noupdate -divider frame_buffer
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/clk_vin
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/i_fval
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/i_dval
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/i_trailer_flag
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/iv_image_din
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/i_stream_en_clk_in
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/clk_vout
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/i_buf_rd
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/o_back_buf_empty
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/ov_frame_dout
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/o_frame_valid
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/clk_frame_buf
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/reset_frame_buf
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/i_stream_en
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/iv_frame_depth
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/iv_payload_size_frame_buf
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/iv_payload_size_pix
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/i_chunkmodeactive
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/i_async_rst
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/i_sysclk_2x
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/i_sysclk_2x_180
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/i_pll_ce_0
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/i_pll_ce_90
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/i_mcb_drp_clk
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/i_bufpll_mcb_lock
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/o_calib_done
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/o_wr_error
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/o_rd_error
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_dram_dq
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_dram_a
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_dram_ba
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_dram_ras_n
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_dram_cas_n
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_dram_we_n
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_dram_odt
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_dram_reset_n
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_dram_cke
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_dram_dm
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_dram_udqs
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_dram_udqs_n
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_rzq
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_dram_udm
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_dram_dqs
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_dram_dqs_n
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_dram_ck
add wave -noupdate -group {frame_buffer
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mcb1_dram_ck_n
add wave -noupdate -group {frame_buffer
} -divider {New Divider}
add wave -noupdate -group {wr_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/clk_vin
add wave -noupdate -group {wr_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/i_fval
add wave -noupdate -group {wr_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/i_dval
add wave -noupdate -group {wr_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/i_trailer_flag
add wave -noupdate -group {wr_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/iv_image_din
add wave -noupdate -group {wr_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/i_stream_en_clk_in
add wave -noupdate -group {wr_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/i_stream_en
add wave -noupdate -group {wr_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/iv_frame_depth
add wave -noupdate -group {wr_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/ov_frame_depth
add wave -noupdate -group {wr_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/clk
add wave -noupdate -group {wr_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/reset
add wave -noupdate -group {wr_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/ov_wr_frame_ptr
add wave -noupdate -group {wr_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/ov_wr_addr
add wave -noupdate -group {wr_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/iv_rd_frame_ptr
add wave -noupdate -group {wr_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/o_wr_frame_ptr_changing
add wave -noupdate -group {wr_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/o_se_2_fvalrise
add wave -noupdate -group {wr_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/i_calib_done
add wave -noupdate -group {wr_logic_int
} -radix ascii /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/state_ascii
add wave -noupdate -group {wr_logic_int
} {/harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/calib_done_shift[1]}
add wave -noupdate -group {wr_logic_int
} {/harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/favl_shift_clk[1]}
add wave -noupdate -group {wr_logic_int
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/fifo_prog_empty
add wave -noupdate -group {wr_logic_int
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/o_se_2_fvalrise
add wave -noupdate -group {wr_logic_int
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/wr_flag_shift
add wave -noupdate -group {wr_logic_int
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_wr_logic_inst/wr_flag
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_calib_done
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_cmd_clk
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_cmd_en
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_cmd_instr
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_cmd_bl
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_cmd_byte_addr
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_cmd_empty
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_cmd_full
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_clk
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_en
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_mask
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_data
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_full
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_empty
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_count
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_underrun
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_error
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_cmd_clk
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_cmd_en
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_cmd_instr
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_cmd_bl
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_cmd_byte_addr
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_cmd_empty
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_cmd_full
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_clk
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_en
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_data
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_full
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_empty
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_count
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_overflow
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_error
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_async_rst
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_sysclk_2x
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_sysclk_2x_180
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_pll_ce_0
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_pll_ce_90
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_pll_lock
add wave -noupdate -group {mig_core
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_mcb_drp_clk
add wave -noupdate -group {spi_rd_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/rst
add wave -noupdate -group {spi_rd_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/wr_clk
add wave -noupdate -group {spi_rd_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/wr_en
add wave -noupdate -group {spi_rd_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/full
add wave -noupdate -group {spi_rd_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/din
add wave -noupdate -group {spi_rd_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/rd_clk
add wave -noupdate -group {spi_rd_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/rd_en
add wave -noupdate -group {spi_rd_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/empty
add wave -noupdate -group {spi_rd_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/dout
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/rst
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/wr_clk
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/wr_en
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/full
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/din
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/rd_clk
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/rd_en
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/empty
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/dout
add wave -noupdate -group {spi_4wire
} /harness/i_spi_cs_n_fpga
add wave -noupdate -group {spi_4wire
} /harness/i_usb_spi_sck
add wave -noupdate -group {spi_4wire
} /harness/i_usb_spi_mosi
add wave -noupdate -group {spi_4wire
} /harness/o_usb_spi_miso
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/clk_spi_sample
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/i_spi_clk
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/i_spi_cs_n
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/i_spi_mosi
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/o_spi_miso_data
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/o_spi_miso_data_en
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/o_wr_en
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/o_rd_en
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/o_cmd_is_rd
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/ov_addr
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/ov_wr_data
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/i_pix_sel
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/iv_pix_rd_data
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/i_frame_buf_sel
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/iv_frame_buf_rd_data
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/i_gpif_sel
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/iv_gpif_rd_data
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/i_osc_bufg_sel
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/iv_osc_bufg_rd_data
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/i_fix_sel
add wave -noupdate -group {spi_slave
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/spi_slave_inst/iv_fix_rd_data
add wave -noupdate /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_empty
add wave -noupdate /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/i_se_2_fvalrise
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_dram_dq
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_dram_a
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_dram_ba
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_dram_ras_n
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_dram_cas_n
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_dram_we_n
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_dram_odt
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_dram_reset_n
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_dram_cke
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_dram_dm
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_dram_udqs
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_dram_udqs_n
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_rzq
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_dram_udm
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_dram_dqs
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_dram_dqs_n
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_dram_ck
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/mcb1_dram_ck_n
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_calib_done
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_cmd_clk
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_cmd_en
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_cmd_instr
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_cmd_bl
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_cmd_byte_addr
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_cmd_empty
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_cmd_full
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_clk
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_en
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_mask
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_data
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_full
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_empty
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_count
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_underrun
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_error
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_cmd_clk
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_cmd_en
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_cmd_instr
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_cmd_bl
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_cmd_byte_addr
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_cmd_empty
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_cmd_full
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_clk
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_en
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_data
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_full
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_empty
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_count
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_overflow
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_error
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_async_rst
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_sysclk_2x
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_sysclk_2x_180
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_pll_ce_0
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_pll_ce_90
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_pll_lock
add wave -noupdate -group {mcb
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_mcb_drp_clk
add wave -noupdate -divider u3_if
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/clk
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/reset
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/i_data_valid
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/iv_data
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/i_framebuffer_empty
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/o_fifo_rd
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/iv_payload_size
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/i_chunkmodeactive
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/iv_transfer_count
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/iv_transfer_size
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/iv_transfer1_size
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/iv_transfer2_size
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/i_usb_flagb
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/ov_usb_fifoaddr
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/o_usb_slwr_n
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/ov_usb_data
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/o_usb_pktend_n
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/o_usb_pktend_n_for_test
add wave -noupdate -group {u3_if
} /harness/mer_1810_21u3x_inst/u3_interface_inst/o_usb_wr_for_led
add wave -noupdate -divider ctrl_channel
add wave -noupdate -group {ctrl_channel
} /harness/mer_1810_21u3x_inst/ctrl_channel_inst/o_trigger_soft
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/clk_osc
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/i_reset_sensor
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/i_stream_enable
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/clk_osc_bufg
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/reset_osc_bufg
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/async_rst
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/sysclk_2x
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/sysclk_2x_180
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/pll_ce_0
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/pll_ce_90
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/mcb_drp_clk
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/bufpll_mcb_lock
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/clk_frame_buf
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/reset_frame_buf
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/clk_pix
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/reset_pix
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/o_clk_sensor
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/o_sensor_reset_done
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/o_clk_usb_pclk
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/clk_gpif
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/reset_gpif
add wave -noupdate -group {clk_reset
} /harness/mer_1810_21u3x_inst/clock_reset_inst/reset_u3_interface
add wave -noupdate -divider io_channel
add wave -noupdate -group {circuit
} /harness/mer_1810_21u3x_inst/io_channel_inst/circuit_dependent_inst/i_optocoupler
add wave -noupdate -group {circuit
} /harness/mer_1810_21u3x_inst/io_channel_inst/circuit_dependent_inst/iv_gpio
add wave -noupdate -group {circuit
} /harness/mer_1810_21u3x_inst/io_channel_inst/circuit_dependent_inst/o_optocoupler_in
add wave -noupdate -group {circuit
} /harness/mer_1810_21u3x_inst/io_channel_inst/circuit_dependent_inst/ov_gpio_in
add wave -noupdate -group {mode_inv
} /harness/mer_1810_21u3x_inst/io_channel_inst/line_mode_and_inverter_inst/clk
add wave -noupdate -group {mode_inv
} /harness/mer_1810_21u3x_inst/io_channel_inst/line_mode_and_inverter_inst/i_optocoupler
add wave -noupdate -group {mode_inv
} /harness/mer_1810_21u3x_inst/io_channel_inst/line_mode_and_inverter_inst/iv_gpio
add wave -noupdate -group {mode_inv
} /harness/mer_1810_21u3x_inst/io_channel_inst/line_mode_and_inverter_inst/o_optocoupler
add wave -noupdate -group {mode_inv
} /harness/mer_1810_21u3x_inst/io_channel_inst/line_mode_and_inverter_inst/ov_gpio
add wave -noupdate -group {mode_inv
} /harness/mer_1810_21u3x_inst/io_channel_inst/line_mode_and_inverter_inst/i_line2_mode
add wave -noupdate -group {mode_inv
} /harness/mer_1810_21u3x_inst/io_channel_inst/line_mode_and_inverter_inst/i_line3_mode
add wave -noupdate -group {mode_inv
} /harness/mer_1810_21u3x_inst/io_channel_inst/line_mode_and_inverter_inst/i_line0_invert
add wave -noupdate -group {mode_inv
} /harness/mer_1810_21u3x_inst/io_channel_inst/line_mode_and_inverter_inst/i_line1_invert
add wave -noupdate -group {mode_inv
} /harness/mer_1810_21u3x_inst/io_channel_inst/line_mode_and_inverter_inst/i_line2_invert
add wave -noupdate -group {mode_inv
} /harness/mer_1810_21u3x_inst/io_channel_inst/line_mode_and_inverter_inst/i_line3_invert
add wave -noupdate -group {mode_inv
} /harness/mer_1810_21u3x_inst/io_channel_inst/line_mode_and_inverter_inst/ov_line_status
add wave -noupdate -group {mode_inv
} /harness/mer_1810_21u3x_inst/io_channel_inst/line_mode_and_inverter_inst/ov_linein
add wave -noupdate -group {mode_inv
} /harness/mer_1810_21u3x_inst/io_channel_inst/line_mode_and_inverter_inst/iv_lineout
add wave -noupdate -group {trig_src
} /harness/mer_1810_21u3x_inst/io_channel_inst/triggersource_sel_inst/clk
add wave -noupdate -group {trig_src
} /harness/mer_1810_21u3x_inst/io_channel_inst/triggersource_sel_inst/iv_trigger_source
add wave -noupdate -group {trig_src
} /harness/mer_1810_21u3x_inst/io_channel_inst/triggersource_sel_inst/iv_linein
add wave -noupdate -group {trig_src
} /harness/mer_1810_21u3x_inst/io_channel_inst/triggersource_sel_inst/o_linein
add wave -noupdate -group {trig_active
} /harness/mer_1810_21u3x_inst/io_channel_inst/trigger_active_inst/clk
add wave -noupdate -group {trig_active
} /harness/mer_1810_21u3x_inst/io_channel_inst/trigger_active_inst/i_trigger_soft
add wave -noupdate -group {trig_active
} /harness/mer_1810_21u3x_inst/io_channel_inst/trigger_active_inst/iv_trigger_source
add wave -noupdate -group {trig_active
} /harness/mer_1810_21u3x_inst/io_channel_inst/trigger_active_inst/i_trigger_active
add wave -noupdate -group {trig_active
} /harness/mer_1810_21u3x_inst/io_channel_inst/trigger_active_inst/i_din
add wave -noupdate -group {trig_active
} /harness/mer_1810_21u3x_inst/io_channel_inst/trigger_active_inst/o_dout
add wave -noupdate -group {trig_delay
} /harness/mer_1810_21u3x_inst/io_channel_inst/trigger_delay_inst/clk
add wave -noupdate -group {trig_delay
} /harness/mer_1810_21u3x_inst/io_channel_inst/trigger_delay_inst/iv_trigger_delay
add wave -noupdate -group {trig_delay
} /harness/mer_1810_21u3x_inst/io_channel_inst/trigger_delay_inst/i_din
add wave -noupdate -group {trig_delay
} /harness/mer_1810_21u3x_inst/io_channel_inst/trigger_delay_inst/o_dout
add wave -noupdate -divider {New Divider}
add wave -noupdate -group {p2_cmd
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_cmd_en
add wave -noupdate -group {p2_cmd
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_cmd_empty
add wave -noupdate -group {p2_cmd
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_clk
add wave -noupdate -group {p2_cmd
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_en
add wave -noupdate -group {p2_cmd
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p0_wr_full
add wave -noupdate -group {p3_cmd
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_cmd_en
add wave -noupdate -group {p3_cmd
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_cmd_empty
add wave -noupdate -group {p3_cmd
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_cmd_full
add wave -noupdate -group {p3_cmd
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_clk
add wave -noupdate -group {p3_cmd
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_en
add wave -noupdate -group {p3_cmd
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_full
add wave -noupdate -group {p3_cmd
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/mig_core_inst/c1_p1_rd_empty
add wave -noupdate -divider {New Divider}
add wave -noupdate -group {rd_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/clk_vout
add wave -noupdate -group {rd_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/i_buf_rd
add wave -noupdate -group {rd_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/o_back_buf_empty
add wave -noupdate -group {rd_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/o_frame_valid
add wave -noupdate -group {rd_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/ov_frame_dout
add wave -noupdate -group {rd_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/i_se_2_fvalrise
add wave -noupdate -group {rd_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/iv_frame_depth
add wave -noupdate -group {rd_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/iv_payload_size
add wave -noupdate -group {rd_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/i_wr_frame_ptr_changing
add wave -noupdate -group {rd_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/i_chunkmodeactive
add wave -noupdate -group {rd_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/clk
add wave -noupdate -group {rd_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/reset
add wave -noupdate -group {rd_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/iv_wr_frame_ptr
add wave -noupdate -group {rd_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/iv_wr_addr
add wave -noupdate -group {rd_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/ov_rd_frame_ptr
add wave -noupdate -group {rd_logic
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/i_calib_done
add wave -noupdate -group {rd_logic_int
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/able_to_read
add wave -noupdate -group {rd_logic_int
} -radix ascii /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/state_ascii
add wave -noupdate -group {rd_logic_int
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/current_state
add wave -noupdate -group {rd_logic_int
} {/harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/se_2_fvalrise_shift[1]}
add wave -noupdate -group {rd_logic_int
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/fifo_prog_full
add wave -noupdate -group {rd_logic_int
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/able_to_read
add wave -noupdate -group {rd_logic_int
} /harness/mer_1810_21u3x_inst/frame_buffer_inst/wrap_rd_logic_inst/word_cnt
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
} /harness/genblk1/ddr3_model_c3_inst/tdqs_n
add wave -noupdate -group {ddr3
} -radix ascii /monitor_ddr3/rd_wr_cmd
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
add wave -noupdate -group monitor_ddr3 -radix ascii /monitor_ddr3/DDR3_CMD
add wave -noupdate -group monitor_ddr3 -radix ascii /monitor_ddr3/rd_wr_cmd
add wave -noupdate -group monitor_ddr3 -radix unsigned /monitor_ddr3/current_wr_bank_addr
add wave -noupdate -group monitor_ddr3 -radix unsigned /monitor_ddr3/current_wr_row_addr
add wave -noupdate -group monitor_ddr3 -radix unsigned /monitor_ddr3/current_rd_bank_addr
add wave -noupdate -group monitor_ddr3 -radix unsigned /monitor_ddr3/current_rd_row_addr
add wave -noupdate -group {gpif_3014
} /harness/slave_fifo_inst/reset_n
add wave -noupdate -group {gpif_3014
} /harness/slave_fifo_inst/i_usb_rd
add wave -noupdate -group {gpif_3014
} /harness/slave_fifo_inst/iv_usb_addr
add wave -noupdate -group {gpif_3014
} /harness/slave_fifo_inst/i_usb_wr
add wave -noupdate -group {gpif_3014
} /harness/slave_fifo_inst/iv_usb_data
add wave -noupdate -group {gpif_3014
} /harness/slave_fifo_inst/i_usb_pclk
add wave -noupdate -group {gpif_3014
} /harness/slave_fifo_inst/i_usb_pkt
add wave -noupdate -group {gpif_3014
} /harness/slave_fifo_inst/i_usb_cs
add wave -noupdate -group {gpif_3014
} /harness/slave_fifo_inst/i_usb_oe
add wave -noupdate -group {gpif_3014
} /harness/slave_fifo_inst/i_pc_busy
add wave -noupdate -group {gpif_3014
} /harness/slave_fifo_inst/o_flaga
add wave -noupdate -group {gpif_3014
} /harness/slave_fifo_inst/o_flagb
add wave -noupdate -group {pkt_switch
} /harness/mer_1810_21u3x_inst/u3_interface_inst/packet_switch_inst/clk
add wave -noupdate -group {pkt_switch
} /harness/mer_1810_21u3x_inst/u3_interface_inst/packet_switch_inst/reset
add wave -noupdate -group {pkt_switch
} /harness/mer_1810_21u3x_inst/u3_interface_inst/packet_switch_inst/i_chunkmodeactive
add wave -noupdate -group {pkt_switch
} /harness/mer_1810_21u3x_inst/u3_interface_inst/packet_switch_inst/i_framebuffer_empty
add wave -noupdate -group {pkt_switch
} /harness/mer_1810_21u3x_inst/u3_interface_inst/packet_switch_inst/iv_payload_size
add wave -noupdate -group {pkt_switch
} /harness/mer_1810_21u3x_inst/u3_interface_inst/packet_switch_inst/i_change_flag
add wave -noupdate -group {pkt_switch
} /harness/mer_1810_21u3x_inst/u3_interface_inst/packet_switch_inst/o_leader_flag
add wave -noupdate -group {pkt_switch
} /harness/mer_1810_21u3x_inst/u3_interface_inst/packet_switch_inst/o_trailer_flag
add wave -noupdate -group {pkt_switch
} /harness/mer_1810_21u3x_inst/u3_interface_inst/packet_switch_inst/o_payload_flag
add wave -noupdate -group {pkt_switch
} /harness/mer_1810_21u3x_inst/u3_interface_inst/packet_switch_inst/ov_packet_size
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 5} {3117237 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 166
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
WaveRestoreZoom {56013092 ps} {76036423 ps}
