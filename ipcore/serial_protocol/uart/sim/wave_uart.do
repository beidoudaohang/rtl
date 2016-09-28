onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group uart_tx /harness/uart_tx_rx_inst/genblk1/uart_tx_byte_inst/clk
add wave -noupdate -expand -group uart_tx /harness/uart_tx_rx_inst/genblk1/uart_tx_byte_inst/reset
add wave -noupdate -expand -group uart_tx /harness/uart_tx_rx_inst/genblk1/uart_tx_byte_inst/i_16x_baud_en
add wave -noupdate -expand -group uart_tx /harness/uart_tx_rx_inst/genblk1/uart_tx_byte_inst/i_tx_fifo_wr
add wave -noupdate -expand -group uart_tx /harness/uart_tx_rx_inst/genblk1/uart_tx_byte_inst/iv_tx_fifo_din
add wave -noupdate -expand -group uart_tx /harness/uart_tx_rx_inst/genblk1/uart_tx_byte_inst/o_tx_fifo_full
add wave -noupdate -expand -group uart_tx /harness/uart_tx_rx_inst/genblk1/uart_tx_byte_inst/o_tx_fifo_half_full
add wave -noupdate -expand -group uart_tx /harness/uart_tx_rx_inst/genblk1/uart_tx_byte_inst/o_uart_tx_ser
add wave -noupdate -expand -group uart_rx /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/clk
add wave -noupdate -expand -group uart_rx /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/reset
add wave -noupdate -expand -group uart_rx /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/i_uart_rx_ser
add wave -noupdate -expand -group uart_rx /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/i_16x_baud_en
add wave -noupdate -expand -group uart_rx /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/i_rx_fifo_rd
add wave -noupdate -expand -group uart_rx /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/o_rx_fifo_empty
add wave -noupdate -expand -group uart_rx /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/o_rx_fifo_full
add wave -noupdate -expand -group uart_rx /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/o_rx_fifo_half_full
add wave -noupdate -expand -group uart_rx /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/ov_rx_fifo_dout
add wave -noupdate -expand -group rx_fifo /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/sync_fifo_srl_w8d16_inst/reset
add wave -noupdate -expand -group rx_fifo /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/sync_fifo_srl_w8d16_inst/clk
add wave -noupdate -expand -group rx_fifo /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/sync_fifo_srl_w8d16_inst/iv_din
add wave -noupdate -expand -group rx_fifo /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/sync_fifo_srl_w8d16_inst/i_wr
add wave -noupdate -expand -group rx_fifo /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/sync_fifo_srl_w8d16_inst/o_full
add wave -noupdate -expand -group rx_fifo /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/sync_fifo_srl_w8d16_inst/o_half_full
add wave -noupdate -expand -group rx_fifo /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/sync_fifo_srl_w8d16_inst/i_rd
add wave -noupdate -expand -group rx_fifo /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/sync_fifo_srl_w8d16_inst/ov_dout
add wave -noupdate -expand -group rx_fifo /harness/uart_tx_rx_inst/genblk2/uart_rx_byte_inst/sync_fifo_srl_w8d16_inst/o_empty
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {289323 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 167
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
WaveRestoreZoom {2008708 ns} {2010279 ns}
