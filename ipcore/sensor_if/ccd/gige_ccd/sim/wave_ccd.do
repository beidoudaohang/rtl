onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/clk
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/reset
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/i_start_acquisit
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/i_trigger
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/i_triggermode
add wave -noupdate -expand -group {ccd
} -radix unsigned /harness/mv_ccd_inst/iv_href_start
add wave -noupdate -expand -group {ccd
} -radix unsigned /harness/mv_ccd_inst/iv_href_end
add wave -noupdate -expand -group {ccd
} -radix unsigned /harness/mv_ccd_inst/iv_hd_rising
add wave -noupdate -expand -group {ccd
} -radix unsigned /harness/mv_ccd_inst/iv_hd_falling
add wave -noupdate -expand -group {ccd
} -radix unsigned /harness/mv_ccd_inst/iv_sub_rising
add wave -noupdate -expand -group {ccd
} -radix unsigned /harness/mv_ccd_inst/iv_sub_falling
add wave -noupdate -expand -group {ccd
} -radix unsigned /harness/mv_ccd_inst/iv_vd_rising
add wave -noupdate -expand -group {ccd
} -radix unsigned /harness/mv_ccd_inst/iv_vd_falling
add wave -noupdate -expand -group {ccd
} -radix unsigned /harness/mv_ccd_inst/iv_xsg_width
add wave -noupdate -expand -group {ccd
} -radix unsigned /harness/mv_ccd_inst/iv_frame_period
add wave -noupdate -expand -group {ccd
} -radix unsigned /harness/mv_ccd_inst/iv_headblank_end
add wave -noupdate -expand -group {ccd
} -radix unsigned /harness/mv_ccd_inst/iv_vref_start
add wave -noupdate -expand -group {ccd
} -radix unsigned /harness/mv_ccd_inst/iv_tailblank_start
add wave -noupdate -expand -group {ccd
} -radix unsigned /harness/mv_ccd_inst/iv_tailblank_end
add wave -noupdate -expand -group {ccd
} -radix unsigned /harness/mv_ccd_inst/iv_exp_line
add wave -noupdate -expand -group {ccd
} -radix unsigned /harness/mv_ccd_inst/iv_exp_reg
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/i_ad_parm_valid
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/o_strobe
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/o_integration
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/o_href
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/o_vref
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/o_ccd_stop_flag
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/o_exposure_end
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/o_trigger_mask
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/o_trigger_mask_flag
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/o_hd
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/o_vd
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/o_sub
add wave -noupdate -expand -group {ccd
} {/harness/mv_ccd_inst/ov_xsg[0]}
add wave -noupdate -expand -group {ccd
} /harness/mv_ccd_inst/ov_xv
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/clk
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/reset
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/i_reg_active
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/iv_frame_period
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/iv_headblank_end
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/iv_vref_start
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/iv_tailblank_start
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/iv_tailblank_end
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/iv_exp_line
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/iv_exp_reg
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/ov_frame_period
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/ov_headblank_end
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/ov_vref_start
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/ov_tailblank_start
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/ov_tailblank_end
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/ov_tailblank_num
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/ov_headblank_num
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/ov_exp_start_reg
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/ov_exp_line_reg
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/ov_exp_reg
add wave -noupdate -group {ccd_reg
} /harness/mv_ccd_inst/ccd_reg_inst/ov_exp_xsg_reg
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {39587770785 ps} 0} {{Cursor 4} {12950119020 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 178
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
WaveRestoreZoom {0 ps} {42021210 ns}
