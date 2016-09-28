onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {sensor
} /driver_mt9p031/mt9p031_model_inst/clk
add wave -noupdate -expand -group {sensor
} /driver_mt9p031/mt9p031_model_inst/reset
add wave -noupdate -expand -group {sensor
} /driver_mt9p031/mt9p031_model_inst/i_pause_en
add wave -noupdate -expand -group {sensor
} /driver_mt9p031/mt9p031_model_inst/i_continue_lval
add wave -noupdate -expand -group {sensor
} /driver_mt9p031/mt9p031_model_inst/iv_width
add wave -noupdate -expand -group {sensor
} /driver_mt9p031/mt9p031_model_inst/iv_line_hide
add wave -noupdate -expand -group {sensor
} /driver_mt9p031/mt9p031_model_inst/iv_height
add wave -noupdate -expand -group {sensor
} /driver_mt9p031/mt9p031_model_inst/iv_frame_hide
add wave -noupdate -expand -group {sensor
} /driver_mt9p031/mt9p031_model_inst/iv_front_porch
add wave -noupdate -expand -group {sensor
} /driver_mt9p031/mt9p031_model_inst/iv_back_porch
add wave -noupdate -expand -group {sensor
} /driver_mt9p031/mt9p031_model_inst/o_clk_pix
add wave -noupdate -expand -group {sensor
} /driver_mt9p031/mt9p031_model_inst/o_fval
add wave -noupdate -expand -group {sensor
} /driver_mt9p031/mt9p031_model_inst/o_lval
add wave -noupdate -expand -group {sensor
} /driver_mt9p031/mt9p031_model_inst/ov_dout
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {sync_buffer
} /harness/sync_buffer_inst/clk_sensor_pix
add wave -noupdate -expand -group {sync_buffer
} /harness/sync_buffer_inst/i_clk_en
add wave -noupdate -expand -group {sync_buffer
} /harness/sync_buffer_inst/i_fval
add wave -noupdate -expand -group {sync_buffer
} /harness/sync_buffer_inst/i_lval
add wave -noupdate -expand -group {sync_buffer
} /harness/sync_buffer_inst/iv_pix_data
add wave -noupdate -expand -group {sync_buffer
} /harness/sync_buffer_inst/clk_pix
add wave -noupdate -expand -group {sync_buffer
} /harness/sync_buffer_inst/o_fval
add wave -noupdate -expand -group {sync_buffer
} /harness/sync_buffer_inst/o_lval
add wave -noupdate -expand -group {sync_buffer
} /harness/sync_buffer_inst/ov_pix_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {231664 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 180
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
WaveRestoreZoom {170209 ns} {724184 ns}
