onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {fifo_core
} /harness/fifo_w8d16_inst/rst
add wave -noupdate -expand -group {fifo_core
} /harness/fifo_w8d16_inst/wr_clk
add wave -noupdate -expand -group {fifo_core
} /harness/fifo_w8d16_inst/wr_en
add wave -noupdate -expand -group {fifo_core
} /harness/fifo_w8d16_inst/full
add wave -noupdate -expand -group {fifo_core
} /harness/fifo_w8d16_inst/din
add wave -noupdate -expand -group {fifo_core
} /harness/fifo_w8d16_inst/rd_clk
add wave -noupdate -expand -group {fifo_core
} /harness/fifo_w8d16_inst/rd_en
add wave -noupdate -expand -group {fifo_core
} /harness/fifo_w8d16_inst/empty
add wave -noupdate -expand -group {fifo_core
} /harness/fifo_w8d16_inst/dout
add wave -noupdate -expand -group {async_fifo
} /harness/async_fifo_inst/reset_async
add wave -noupdate -expand -group {async_fifo
} /harness/async_fifo_inst/clk_wr
add wave -noupdate -expand -group {async_fifo
} /harness/async_fifo_inst/i_wr_en
add wave -noupdate -expand -group {async_fifo
} /harness/async_fifo_inst/iv_fifo_din
add wave -noupdate -expand -group {async_fifo
} /harness/async_fifo_inst/o_fifo_full
add wave -noupdate -expand -group {async_fifo
} /harness/async_fifo_inst/clk_rd
add wave -noupdate -expand -group {async_fifo
} /harness/async_fifo_inst/i_rd_en
add wave -noupdate -expand -group {async_fifo
} /harness/async_fifo_inst/ov_fifo_dout
add wave -noupdate -expand -group {async_fifo
} /harness/async_fifo_inst/o_fifo_empty
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5160 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 100
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
WaveRestoreZoom {0 ns} {10920 ns}
