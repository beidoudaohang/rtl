onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {sensor_out
} /driver_mt9p031/mt9p031_model_inst/o_fval
add wave -noupdate -expand -group {sensor_out
} /driver_mt9p031/mt9p031_model_inst/o_lval
add wave -noupdate -expand -group {sensor_out
} /driver_mt9p031/mt9p031_model_inst/ov_dout
add wave -noupdate -expand -group {stream_ctrl
} /harness/stream_ctrl_inst/clk_pix
add wave -noupdate -expand -group {stream_ctrl
} /harness/stream_ctrl_inst/i_fval
add wave -noupdate -expand -group {stream_ctrl
} /harness/stream_ctrl_inst/i_fval_sync
add wave -noupdate -expand -group {stream_ctrl
} /harness/stream_ctrl_inst/i_acquisition_start
add wave -noupdate -expand -group {stream_ctrl
} /harness/stream_ctrl_inst/i_stream_enable
add wave -noupdate -expand -group {stream_ctrl
} /harness/stream_ctrl_inst/i_encrypt_state
add wave -noupdate -expand -group {stream_ctrl
} /harness/stream_ctrl_inst/iv_pixel_format
add wave -noupdate -expand -group {stream_ctrl
} /harness/stream_ctrl_inst/iv_test_image_sel
add wave -noupdate -expand -group {stream_ctrl
} /harness/stream_ctrl_inst/o_enable
add wave -noupdate -expand -group {stream_ctrl
} /harness/stream_ctrl_inst/o_full_frame_state
add wave -noupdate -expand -group {stream_ctrl
} /harness/stream_ctrl_inst/ov_pixel_format
add wave -noupdate -expand -group {stream_ctrl
} /harness/stream_ctrl_inst/ov_test_image_sel
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {554779 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 175
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
WaveRestoreZoom {0 ns} {1608860 ns}
