onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {mt9p031
} /driver_mt9p031/mt9p031_model_inst/clk
add wave -noupdate -expand -group {mt9p031
} /driver_mt9p031/mt9p031_model_inst/reset
add wave -noupdate -expand -group {mt9p031
} /driver_mt9p031/mt9p031_model_inst/iv_line_active_pix_num
add wave -noupdate -expand -group {mt9p031
} /driver_mt9p031/mt9p031_model_inst/iv_line_hide_pix_num
add wave -noupdate -expand -group {mt9p031
} /driver_mt9p031/mt9p031_model_inst/iv_line_active_num
add wave -noupdate -expand -group {mt9p031
} /driver_mt9p031/mt9p031_model_inst/iv_frame_hide_pix_num
add wave -noupdate -expand -group {mt9p031
} /driver_mt9p031/mt9p031_model_inst/iv_frame_to_line_pix_num
add wave -noupdate -expand -group {mt9p031
} /driver_mt9p031/mt9p031_model_inst/o_clk_pix
add wave -noupdate -expand -group {mt9p031
} /driver_mt9p031/mt9p031_model_inst/o_fval
add wave -noupdate -expand -group {mt9p031
} /driver_mt9p031/mt9p031_model_inst/o_lval
add wave -noupdate -expand -group {mt9p031
} /driver_mt9p031/mt9p031_model_inst/ov_dout
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {driver_3014
} /driver_3014_slave/u3_3014_slave_inst/clk
add wave -noupdate -expand -group {driver_3014
} /driver_3014_slave/u3_3014_slave_inst/reset
add wave -noupdate -expand -group {driver_3014
} /driver_3014_slave/u3_3014_slave_inst/o_usb_flagb_n
add wave -noupdate -expand -group {driver_3014
} /driver_3014_slave/u3_3014_slave_inst/iv_usb_addr
add wave -noupdate -expand -group {driver_3014
} /driver_3014_slave/u3_3014_slave_inst/i_usb_slwr_n
add wave -noupdate -expand -group {driver_3014
} /driver_3014_slave/u3_3014_slave_inst/iv_usb_data
add wave -noupdate -expand -group {driver_3014
} /driver_3014_slave/u3_3014_slave_inst/i_usb_pktend_n
add wave -noupdate -group {monitor_ddr3
} -radix ascii /monitor_ddr3/DDR3_CMD
add wave -noupdate -group {monitor_ddr3
} /monitor_ddr3/rd_wr_cmd
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
WaveRestoreCursors {{Cursor 1} {28847112 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 186
configure wave -valuecolwidth 56
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
WaveRestoreZoom {0 ps} {67021395 ps}
