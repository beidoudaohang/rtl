onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {deser_top
} /harness/deser_wrap_inst/i_clk_p
add wave -noupdate -expand -group {deser_top
} /harness/deser_wrap_inst/i_clk_n
add wave -noupdate -expand -group {deser_top
} /harness/deser_wrap_inst/iv_data_p
add wave -noupdate -expand -group {deser_top
} /harness/deser_wrap_inst/iv_data_n
add wave -noupdate -expand -group {deser_top
} /harness/deser_wrap_inst/reset
add wave -noupdate -expand -group {deser_top
} /harness/deser_wrap_inst/iv_bitslip
add wave -noupdate -expand -group {deser_top
} /harness/deser_wrap_inst/o_bufpll_lock
add wave -noupdate -expand -group {deser_top
} /harness/deser_wrap_inst/clk_recover
add wave -noupdate -expand -group {deser_top
} /harness/deser_wrap_inst/reset_recover
add wave -noupdate -expand -group {deser_top
} /harness/deser_wrap_inst/ov_data_recover
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {world_align
} /harness/word_aligner_inst/clk
add wave -noupdate -expand -group {world_align
} /harness/word_aligner_inst/reset
add wave -noupdate -expand -group {world_align
} /harness/word_aligner_inst/iv_data
add wave -noupdate -expand -group {world_align
} /harness/word_aligner_inst/o_clk_en
add wave -noupdate -expand -group {world_align
} /harness/word_aligner_inst/o_sync
add wave -noupdate -expand -group {world_align
} /harness/word_aligner_inst/ov_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {word_align_int
} /harness/word_aligner_inst/window_0
add wave -noupdate -expand -group {word_align_int
} /harness/word_aligner_inst/window_1
add wave -noupdate -expand -group {word_align_int
} /harness/word_aligner_inst/window_2
add wave -noupdate -expand -group {word_align_int
} -color {Slate Blue} /harness/word_aligner_inst/window_3
add wave -noupdate -expand -group {word_align_int
} /harness/word_aligner_inst/window_4
add wave -noupdate -expand -group {word_align_int
} /harness/word_aligner_inst/window_5
add wave -noupdate -expand -group {word_align_int
} /harness/word_aligner_inst/din_shift
add wave -noupdate -expand -group {word_align_int
} /harness/word_aligner_inst/window_num
add wave -noupdate -expand -group {word_align_int
} /harness/word_aligner_inst/div_cnt
add wave -noupdate -expand -group {word_align_int
} /harness/word_aligner_inst/div_cnt_lock
add wave -noupdate -expand -group {word_align_int
} /harness/word_aligner_inst/word_align_tmp
add wave -noupdate -expand -group {word_align_int
} /harness/word_aligner_inst/sync_tmp
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {41777484 ps} 1} {{Cursor 2} {249013847 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 140
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
WaveRestoreZoom {0 ps} {315 us}
