onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {sync_fifo_srl
} /harness/sync_fifo_srl_inst/reset
add wave -noupdate -expand -group {sync_fifo_srl
} /harness/sync_fifo_srl_inst/clk
add wave -noupdate -expand -group {sync_fifo_srl
} -radix unsigned /harness/sync_fifo_srl_inst/iv_din
add wave -noupdate -expand -group {sync_fifo_srl
} /harness/sync_fifo_srl_inst/i_wr
add wave -noupdate -expand -group {sync_fifo_srl
} /harness/sync_fifo_srl_inst/o_full
add wave -noupdate -expand -group {sync_fifo_srl
} /harness/sync_fifo_srl_inst/o_half_full
add wave -noupdate -expand -group {sync_fifo_srl
} /harness/sync_fifo_srl_inst/i_rd
add wave -noupdate -expand -group {sync_fifo_srl
} -radix unsigned /harness/sync_fifo_srl_inst/ov_dout
add wave -noupdate -expand -group {sync_fifo_srl
} /harness/sync_fifo_srl_inst/o_empty
add wave -noupdate -expand -group {sync_fifo_srl
} /harness/sync_fifo_srl_inst/FIFO_PTR_WIDTH
add wave -noupdate -radix unsigned /harness/sync_fifo_srl_inst/pointer
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5730526 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 162
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
