onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {cmd fifo
} /tb_wrap_spi_master/wrap_spi_master_inst/cmd_fifo_inst/rst
add wave -noupdate -expand -group {cmd fifo
} /tb_wrap_spi_master/wrap_spi_master_inst/cmd_fifo_inst/wr_clk
add wave -noupdate -expand -group {cmd fifo
} /tb_wrap_spi_master/wrap_spi_master_inst/cmd_fifo_inst/wr_en
add wave -noupdate -expand -group {cmd fifo
} /tb_wrap_spi_master/wrap_spi_master_inst/cmd_fifo_inst/full
add wave -noupdate -expand -group {cmd fifo
} /tb_wrap_spi_master/wrap_spi_master_inst/cmd_fifo_inst/din
add wave -noupdate -expand -group {cmd fifo
} /tb_wrap_spi_master/wrap_spi_master_inst/cmd_fifo_inst/rd_clk
add wave -noupdate -expand -group {cmd fifo
} /tb_wrap_spi_master/wrap_spi_master_inst/cmd_fifo_inst/rd_en
add wave -noupdate -expand -group {cmd fifo
} /tb_wrap_spi_master/wrap_spi_master_inst/cmd_fifo_inst/empty
add wave -noupdate -expand -group {cmd fifo
} /tb_wrap_spi_master/wrap_spi_master_inst/cmd_fifo_inst/dout
add wave -noupdate -expand -group {wrap_spi_master
} /tb_wrap_spi_master/wrap_spi_master_inst/clk
add wave -noupdate -expand -group {wrap_spi_master
} /tb_wrap_spi_master/wrap_spi_master_inst/reset
add wave -noupdate -expand -group {wrap_spi_master
} /tb_wrap_spi_master/wrap_spi_master_inst/i_cmd_fifo_wr
add wave -noupdate -expand -group {wrap_spi_master
} /tb_wrap_spi_master/wrap_spi_master_inst/iv_cmd_fifo_din
add wave -noupdate -expand -group {wrap_spi_master
} /tb_wrap_spi_master/wrap_spi_master_inst/o_cmd_fifo_full
add wave -noupdate -expand -group {wrap_spi_master
} /tb_wrap_spi_master/wrap_spi_master_inst/o_spi_cs
add wave -noupdate -expand -group {wrap_spi_master
} /tb_wrap_spi_master/wrap_spi_master_inst/o_spi_clk
add wave -noupdate -expand -group {wrap_spi_master
} /tb_wrap_spi_master/wrap_spi_master_inst/o_spi_mosi
add wave -noupdate -expand -group {wrap_spi_master
} /tb_wrap_spi_master/wrap_spi_master_inst/i_spi_miso
add wave -noupdate -expand -group {spi_master_int
} -radix ascii /tb_wrap_spi_master/wrap_spi_master_inst/spi_master_inst/state_ascii
add wave -noupdate -expand -group {spi_master_int
} /tb_wrap_spi_master/wrap_spi_master_inst/spi_master_inst/bit_cnt
add wave -noupdate /tb_wrap_spi_master/wrap_spi_master_inst/spi_master_inst/cs_delay_cnt
add wave -noupdate /tb_wrap_spi_master/wrap_spi_master_inst/spi_master_inst/mosi_shift_reg
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8387999 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 171
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
WaveRestoreZoom {0 ps} {46150189 ps}
