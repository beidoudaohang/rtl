onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {bb_fifo
} /harness/bbfifo_16x8_inst/reset
add wave -noupdate -expand -group {bb_fifo
} /harness/bbfifo_16x8_inst/clk
add wave -noupdate -expand -group {bb_fifo
} -radix unsigned /harness/bbfifo_16x8_inst/data_in
add wave -noupdate -expand -group {bb_fifo
} /harness/bbfifo_16x8_inst/write
add wave -noupdate -expand -group {bb_fifo
} /harness/bbfifo_16x8_inst/full
add wave -noupdate -expand -group {bb_fifo
} /harness/bbfifo_16x8_inst/half_full
add wave -noupdate -expand -group {bb_fifo
} /harness/bbfifo_16x8_inst/read
add wave -noupdate -expand -group {bb_fifo
} -radix unsigned /harness/bbfifo_16x8_inst/data_out
add wave -noupdate -expand -group {bb_fifo
} /harness/bbfifo_16x8_inst/data_present
add wave -noupdate /harness/bbfifo_16x8_inst/pointer
add wave -noupdate /harness/bbfifo_16x8_inst/data_present_int
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {sync_fifo
} /harness/sync_fifo_srl_w8d16_inst/reset
add wave -noupdate -expand -group {sync_fifo
} /harness/sync_fifo_srl_w8d16_inst/clk
add wave -noupdate -expand -group {sync_fifo
} -radix unsigned /harness/sync_fifo_srl_w8d16_inst/iv_din
add wave -noupdate -expand -group {sync_fifo
} /harness/sync_fifo_srl_w8d16_inst/i_wr
add wave -noupdate -expand -group {sync_fifo
} /harness/sync_fifo_srl_w8d16_inst/o_full
add wave -noupdate -expand -group {sync_fifo
} /harness/sync_fifo_srl_w8d16_inst/o_half_full
add wave -noupdate -expand -group {sync_fifo
} /harness/sync_fifo_srl_w8d16_inst/i_rd
add wave -noupdate -expand -group {sync_fifo
} -radix unsigned /harness/sync_fifo_srl_w8d16_inst/ov_dout
add wave -noupdate -expand -group {sync_fifo
} /harness/sync_fifo_srl_w8d16_inst/o_empty
add wave -noupdate /harness/sync_fifo_srl_w8d16_inst/pointer
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {810000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 177
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
WaveRestoreZoom {0 ps} {10710 ns}
