onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -group {sensor
} /driver_hispi/hispi_stim_inst/vd_active_width
add wave -noupdate -group {sensor
} /driver_hispi/hispi_stim_inst/vd_blank_width
add wave -noupdate -group {sensor
} /driver_hispi/hispi_stim_inst/vd_active_height
add wave -noupdate -group {sensor
} /driver_hispi/hispi_stim_inst/vd_blank_height
add wave -noupdate -group {sensor
} /driver_hispi/hispi_stim_inst/rstn
add wave -noupdate -group {sensor
} /driver_hispi/hispi_stim_inst/sclk
add wave -noupdate -group {sensor
} /driver_hispi/hispi_stim_inst/sclk_o
add wave -noupdate -group {sensor
} /driver_hispi/hispi_stim_inst/sdata_o
add wave -noupdate -divider {New Divider}
add wave -noupdate -group {hispi_if
} /harness/hispi_if_inst/clk
add wave -noupdate -group {hispi_if
} /harness/hispi_if_inst/reset
add wave -noupdate -group {hispi_if
} /harness/hispi_if_inst/iv_data
add wave -noupdate -group {hispi_if
} /harness/hispi_if_inst/i_bitslip_en
add wave -noupdate -group {hispi_if
} /harness/hispi_if_inst/o_bitslip
add wave -noupdate -group {hispi_if
} /harness/hispi_if_inst/o_first_frame_detect
add wave -noupdate -group {hispi_if
} /harness/hispi_if_inst/iv_line_length
add wave -noupdate -group {hispi_if
} /harness/hispi_if_inst/o_clk_en
add wave -noupdate -group {hispi_if
} /harness/hispi_if_inst/o_fval
add wave -noupdate -group {hispi_if
} /harness/hispi_if_inst/o_lval
add wave -noupdate -group {hispi_if
} /harness/hispi_if_inst/ov_pix_data
add wave -noupdate -group {bitslip
} /harness/hispi_if_inst/bitslip_inst/clk
add wave -noupdate -group {bitslip
} /harness/hispi_if_inst/bitslip_inst/reset
add wave -noupdate -group {bitslip
} /harness/hispi_if_inst/bitslip_inst/iv_data
add wave -noupdate -group {bitslip
} /harness/hispi_if_inst/bitslip_inst/iv_line_length
add wave -noupdate -group {bitslip
} /harness/hispi_if_inst/bitslip_inst/i_bitslip_en
add wave -noupdate -group {bitslip
} /harness/hispi_if_inst/bitslip_inst/o_bitslip
add wave -noupdate -group {bitslip
} /harness/hispi_if_inst/bitslip_inst/o_data_valid
add wave -noupdate -group {bitslip
} /harness/hispi_if_inst/bitslip_inst/o_clk_en
add wave -noupdate -group {bitslip
} /harness/hispi_if_inst/bitslip_inst/ov_data
add wave -noupdate -group {bitslip_int
} /harness/hispi_if_inst/bitslip_inst/o_bitslip
add wave -noupdate -group {bitslip_int
} -expand /harness/hispi_if_inst/bitslip_inst/wv_data_lane
add wave -noupdate -group {bitslip_int
} -expand /harness/hispi_if_inst/bitslip_inst/data_lane_align
add wave -noupdate -group {bitslip_int
} {/harness/hispi_if_inst/bitslip_inst/data_lane_align[0]}
add wave -noupdate -group {bitslip_int
} /harness/hispi_if_inst/bitslip_inst/data_lane0_shift
add wave -noupdate -group {hispi_receiver
} /harness/hispi_if_inst/hispi_receiver_inst/clk
add wave -noupdate -group {hispi_receiver
} /harness/hispi_if_inst/hispi_receiver_inst/reset
add wave -noupdate -group {hispi_receiver
} /harness/hispi_if_inst/hispi_receiver_inst/i_clk_en
add wave -noupdate -group {hispi_receiver
} /harness/hispi_if_inst/hispi_receiver_inst/i_data_valid
add wave -noupdate -group {hispi_receiver
} /harness/hispi_if_inst/hispi_receiver_inst/iv_data
add wave -noupdate -group {hispi_receiver
} /harness/hispi_if_inst/hispi_receiver_inst/i_bitslip_en
add wave -noupdate -group {hispi_receiver
} /harness/hispi_if_inst/hispi_receiver_inst/o_first_frame_detect
add wave -noupdate -group {hispi_receiver
} /harness/hispi_if_inst/hispi_receiver_inst/o_clk_en
add wave -noupdate -group {hispi_receiver
} /harness/hispi_if_inst/hispi_receiver_inst/o_fval
add wave -noupdate -group {hispi_receiver
} /harness/hispi_if_inst/hispi_receiver_inst/o_lval
add wave -noupdate -group {hispi_receiver
} /harness/hispi_if_inst/hispi_receiver_inst/ov_pix_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5331918 ps} 1} {{Cursor 2} {668363 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 118
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
WaveRestoreZoom {116621507 ps} {309651500 ps}
