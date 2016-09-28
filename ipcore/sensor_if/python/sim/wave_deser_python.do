onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -group {mt9p031
} /driver_python/mt9p031_model_inst/clk
add wave -noupdate -group {mt9p031
} /driver_python/mt9p031_model_inst/reset
add wave -noupdate -group {mt9p031
} /driver_python/mt9p031_model_inst/i_pause_en
add wave -noupdate -group {mt9p031
} /driver_python/mt9p031_model_inst/i_continue_lval
add wave -noupdate -group {mt9p031
} /driver_python/mt9p031_model_inst/iv_width
add wave -noupdate -group {mt9p031
} /driver_python/mt9p031_model_inst/iv_line_hide
add wave -noupdate -group {mt9p031
} /driver_python/mt9p031_model_inst/iv_height
add wave -noupdate -group {mt9p031
} /driver_python/mt9p031_model_inst/iv_frame_hide
add wave -noupdate -group {mt9p031
} /driver_python/mt9p031_model_inst/iv_front_porch
add wave -noupdate -group {mt9p031
} /driver_python/mt9p031_model_inst/iv_back_porch
add wave -noupdate -group {mt9p031
} /driver_python/mt9p031_model_inst/o_clk_pix
add wave -noupdate -group {mt9p031
} /driver_python/mt9p031_model_inst/o_fval
add wave -noupdate -group {mt9p031
} /driver_python/mt9p031_model_inst/o_lval
add wave -noupdate -group {mt9p031
} /driver_python/mt9p031_model_inst/ov_dout
add wave -noupdate -divider {New Divider}
add wave -noupdate -group {python
} /driver_python/python_module_inst/clk_para
add wave -noupdate -group {python
} /driver_python/python_module_inst/clk_ser
add wave -noupdate -group {python
} /driver_python/python_module_inst/i_clk_en
add wave -noupdate -group {python
} /driver_python/python_module_inst/i_fval
add wave -noupdate -group {python
} /driver_python/python_module_inst/i_lval
add wave -noupdate -group {python
} /driver_python/python_module_inst/iv_pix_data
add wave -noupdate -group {python
} /driver_python/python_module_inst/o_clk_p
add wave -noupdate -group {python
} /driver_python/python_module_inst/o_clk_n
add wave -noupdate -group {python
} /driver_python/python_module_inst/ov_data_p
add wave -noupdate -group {python
} /driver_python/python_module_inst/ov_data_n
add wave -noupdate -group {python
} /driver_python/python_module_inst/o_ctrl_p
add wave -noupdate -group {python
} /driver_python/python_module_inst/o_ctrl_n
add wave -noupdate -group {map
} /driver_python/python_module_inst/map_python_inst/clk
add wave -noupdate -group {map
} /driver_python/python_module_inst/map_python_inst/i_fval
add wave -noupdate -group {map
} /driver_python/python_module_inst/map_python_inst/i_lval
add wave -noupdate -group {map
} /driver_python/python_module_inst/map_python_inst/iv_pix_data
add wave -noupdate -group {map
} /driver_python/python_module_inst/map_python_inst/o_fval
add wave -noupdate -group {map
} /driver_python/python_module_inst/map_python_inst/o_lval
add wave -noupdate -group {map
} /driver_python/python_module_inst/map_python_inst/ov_pix_data
add wave -noupdate -group {map_int
} /driver_python/python_module_inst/map_python_inst/wv_data_lane
add wave -noupdate -group {map_int
} /driver_python/python_module_inst/map_python_inst/map_temp0
add wave -noupdate -group {map_int
} /driver_python/python_module_inst/map_python_inst/map_temp1
add wave -noupdate -group {map_int
} /driver_python/python_module_inst/map_python_inst/pix_cnt
add wave -noupdate -group {map_int
} /driver_python/python_module_inst/map_python_inst/map_latch0
add wave -noupdate -group {map_int
} /driver_python/python_module_inst/map_python_inst/map_latch1
add wave -noupdate -group {map_int
} {/driver_python/python_module_inst/map_python_inst/pix_cnt_dly2[0]}
add wave -noupdate -group {format
} /driver_python/python_module_inst/format_python_inst/clk
add wave -noupdate -group {format
} /driver_python/python_module_inst/format_python_inst/i_fval
add wave -noupdate -group {format
} /driver_python/python_module_inst/format_python_inst/i_lval
add wave -noupdate -group {format
} /driver_python/python_module_inst/format_python_inst/iv_pix_data
add wave -noupdate -group {format
} /driver_python/python_module_inst/format_python_inst/o_fval
add wave -noupdate -group {format
} /driver_python/python_module_inst/format_python_inst/o_lval
add wave -noupdate -group {format
} /driver_python/python_module_inst/format_python_inst/ov_pix_data
add wave -noupdate -group {ctrl_in
} /driver_python/python_module_inst/ctrl_insert_python_inst/clk
add wave -noupdate -group {ctrl_in
} /driver_python/python_module_inst/ctrl_insert_python_inst/i_fval
add wave -noupdate -group {ctrl_in
} /driver_python/python_module_inst/ctrl_insert_python_inst/i_lval
add wave -noupdate -group {ctrl_in
} /driver_python/python_module_inst/ctrl_insert_python_inst/iv_pix_data
add wave -noupdate -group {ctrl_in
} /driver_python/python_module_inst/ctrl_insert_python_inst/o_fval
add wave -noupdate -group {ctrl_in
} /driver_python/python_module_inst/ctrl_insert_python_inst/o_lval
add wave -noupdate -group {ctrl_in
} /driver_python/python_module_inst/ctrl_insert_python_inst/ov_pix_data
add wave -noupdate -group {ctrl_in
} /driver_python/python_module_inst/ctrl_insert_python_inst/ov_ctrl_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -group {deser
} /harness/deser_wrap_inst/i_clk_p
add wave -noupdate -group {deser
} /harness/deser_wrap_inst/i_clk_n
add wave -noupdate -group {deser
} -expand /harness/deser_wrap_inst/iv_data_p
add wave -noupdate -group {deser
} /harness/deser_wrap_inst/iv_data_n
add wave -noupdate -group {deser
} /harness/deser_wrap_inst/reset
add wave -noupdate -group {deser
} /harness/deser_wrap_inst/iv_bitslip
add wave -noupdate -group {deser
} /harness/deser_wrap_inst/o_bufpll_lock
add wave -noupdate -group {deser
} /harness/deser_wrap_inst/clk_recover
add wave -noupdate -group {deser
} /harness/deser_wrap_inst/reset_recover
add wave -noupdate -group {deser
} /harness/deser_wrap_inst/ov_data_recover
add wave -noupdate -group {bufpll
} /harness/deser_wrap_inst/genblk1/deser_clk_gen_bufpll_inst/clkin_p
add wave -noupdate -group {bufpll
} /harness/deser_wrap_inst/genblk1/deser_clk_gen_bufpll_inst/clkin_n
add wave -noupdate -group {bufpll
} /harness/deser_wrap_inst/genblk1/deser_clk_gen_bufpll_inst/reset
add wave -noupdate -group {bufpll
} /harness/deser_wrap_inst/genblk1/deser_clk_gen_bufpll_inst/clk_recover
add wave -noupdate -group {bufpll
} /harness/deser_wrap_inst/genblk1/deser_clk_gen_bufpll_inst/clk_io
add wave -noupdate -group {bufpll
} /harness/deser_wrap_inst/genblk1/deser_clk_gen_bufpll_inst/serdesstrobe
add wave -noupdate -group {bufpll
} /harness/deser_wrap_inst/genblk1/deser_clk_gen_bufpll_inst/bufpll_lock
add wave -noupdate -group {deser_data
} /harness/deser_wrap_inst/deser_data_inst/iv_data_p
add wave -noupdate -group {deser_data
} /harness/deser_wrap_inst/deser_data_inst/iv_data_n
add wave -noupdate -group {deser_data
} /harness/deser_wrap_inst/deser_data_inst/clk_io
add wave -noupdate -group {deser_data
} /harness/deser_wrap_inst/deser_data_inst/clk_io_inv
add wave -noupdate -group {deser_data
} /harness/deser_wrap_inst/deser_data_inst/serdesstrobe
add wave -noupdate -group {deser_data
} /harness/deser_wrap_inst/deser_data_inst/iv_bitslip
add wave -noupdate -group {deser_data
} /harness/deser_wrap_inst/deser_data_inst/clk_recover
add wave -noupdate -group {deser_data
} /harness/deser_wrap_inst/deser_data_inst/reset_recover
add wave -noupdate -group {deser_data
} /harness/deser_wrap_inst/deser_data_inst/ov_data_recover
add wave -noupdate -expand -group {bitslip
} /harness/bitslip_python_inst/clk
add wave -noupdate -expand -group {bitslip
} /harness/bitslip_python_inst/reset
add wave -noupdate -expand -group {bitslip
} /harness/bitslip_python_inst/iv_data
add wave -noupdate -expand -group {bitslip
} /harness/bitslip_python_inst/o_clk_en
add wave -noupdate -expand -group {bitslip
} /harness/bitslip_python_inst/i_bitslip_en
add wave -noupdate -expand -group {bitslip
} /harness/bitslip_python_inst/o_bitslip_done
add wave -noupdate -expand -group {bitslip
} /harness/bitslip_python_inst/o_bitslip
add wave -noupdate -expand -group {bitslip
} /harness/bitslip_python_inst/ov_data
add wave -noupdate -expand -group {bitslip
} /harness/bitslip_python_inst/ov_ctrl
add wave -noupdate -group {phase_detect
} /harness/deser_wrap_inst/deser_data_inst/genblk2/phase_detector_inst/busy
add wave -noupdate -group {phase_detect
} /harness/deser_wrap_inst/deser_data_inst/genblk2/phase_detector_inst/valid
add wave -noupdate -group {phase_detect
} /harness/deser_wrap_inst/deser_data_inst/genblk2/phase_detector_inst/inc_dec
add wave -noupdate -group {phase_detect
} /harness/deser_wrap_inst/deser_data_inst/genblk2/phase_detector_inst/reset
add wave -noupdate -group {phase_detect
} /harness/deser_wrap_inst/deser_data_inst/genblk2/phase_detector_inst/gclk
add wave -noupdate -group {phase_detect
} /harness/deser_wrap_inst/deser_data_inst/genblk2/phase_detector_inst/debug_in
add wave -noupdate -group {phase_detect
} /harness/deser_wrap_inst/deser_data_inst/genblk2/phase_detector_inst/debug
add wave -noupdate -group {phase_detect
} /harness/deser_wrap_inst/deser_data_inst/genblk2/phase_detector_inst/cal_master
add wave -noupdate -group {phase_detect
} /harness/deser_wrap_inst/deser_data_inst/genblk2/phase_detector_inst/cal_slave
add wave -noupdate -group {phase_detect
} /harness/deser_wrap_inst/deser_data_inst/genblk2/phase_detector_inst/rst_out
add wave -noupdate -group {phase_detect
} /harness/deser_wrap_inst/deser_data_inst/genblk2/phase_detector_inst/ce
add wave -noupdate -group {phase_detect
} /harness/deser_wrap_inst/deser_data_inst/genblk2/phase_detector_inst/inc
add wave -noupdate -expand -group {timing_d
ec
} /harness/timing_decoder_python_inst/clk
add wave -noupdate -expand -group {timing_d
ec
} /harness/timing_decoder_python_inst/reset
add wave -noupdate -expand -group {timing_d
ec
} /harness/timing_decoder_python_inst/clk_en
add wave -noupdate -expand -group {timing_d
ec
} /harness/timing_decoder_python_inst/iv_ctrl
add wave -noupdate -expand -group {timing_d
ec
} /harness/timing_decoder_python_inst/iv_data
add wave -noupdate -expand -group {timing_d
ec
} /harness/timing_decoder_python_inst/o_dval
add wave -noupdate -expand -group {timing_d
ec
} /harness/timing_decoder_python_inst/o_fval
add wave -noupdate -expand -group {timing_d
ec
} /harness/timing_decoder_python_inst/ov_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3472658 ps} 0} {{Cursor 2} {1028211 ps} 1}
quietly wave cursor active 1
configure wave -namecolwidth 141
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
WaveRestoreZoom {0 ps} {21210 ns}
