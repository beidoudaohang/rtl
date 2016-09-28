onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {hispi_if
} /harness/hispi_if_inst/clk
add wave -noupdate -expand -group {hispi_if
} /harness/hispi_if_inst/reset
add wave -noupdate -expand -group {hispi_if
} /harness/hispi_if_inst/iv_data
add wave -noupdate -expand -group {hispi_if
} /harness/hispi_if_inst/o_first_frame_detect
add wave -noupdate -expand -group {hispi_if
} /harness/hispi_if_inst/o_clk_en
add wave -noupdate -expand -group {hispi_if
} /harness/hispi_if_inst/o_fval
add wave -noupdate -expand -group {hispi_if
} /harness/hispi_if_inst/o_lval
add wave -noupdate -expand -group {hispi_if
} /harness/hispi_if_inst/ov_pix_data
add wave -noupdate -expand -group {word_align_top
} /harness/hispi_if_inst/word_aligner_top_inst/clk
add wave -noupdate -expand -group {word_align_top
} /harness/hispi_if_inst/word_aligner_top_inst/reset
add wave -noupdate -expand -group {word_align_top
} /harness/hispi_if_inst/word_aligner_top_inst/iv_data
add wave -noupdate -expand -group {word_align_top
} /harness/hispi_if_inst/word_aligner_top_inst/o_clk_en
add wave -noupdate -expand -group {word_align_top
} /harness/hispi_if_inst/word_aligner_top_inst/o_sync
add wave -noupdate -expand -group {word_align_top
} /harness/hispi_if_inst/word_aligner_top_inst/ov_data
add wave -noupdate -expand -group {timing
} /harness/hispi_if_inst/timing_decoder_inst/clk
add wave -noupdate -expand -group {timing
} /harness/hispi_if_inst/timing_decoder_inst/reset
add wave -noupdate -expand -group {timing
} /harness/hispi_if_inst/timing_decoder_inst/i_clk_en
add wave -noupdate -expand -group {timing
} /harness/hispi_if_inst/timing_decoder_inst/i_sync
add wave -noupdate -expand -group {timing
} /harness/hispi_if_inst/timing_decoder_inst/iv_data
add wave -noupdate -expand -group {timing
} /harness/hispi_if_inst/timing_decoder_inst/o_first_frame_detect
add wave -noupdate -expand -group {timing
} /harness/hispi_if_inst/timing_decoder_inst/o_clk_en
add wave -noupdate -expand -group {timing
} /harness/hispi_if_inst/timing_decoder_inst/o_fval
add wave -noupdate -expand -group {timing
} /harness/hispi_if_inst/timing_decoder_inst/o_lval
add wave -noupdate -expand -group {timing
} /harness/hispi_if_inst/timing_decoder_inst/ov_pix_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {299626342 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 170
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
WaveRestoreZoom {46639692 ps} {47189370 ps}
