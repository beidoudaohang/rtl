onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -group {core_int
} /driver_spi_master/spi_master_inst/spi_master_core_inst/spi_clk_en
add wave -noupdate -group {core_int
} /driver_spi_master/spi_master_inst/spi_master_core_inst/miso_iddr2
add wave -noupdate -group {core_int
} /driver_spi_master/spi_master_inst/spi_master_core_inst/miso_shift_reg
add wave -noupdate -group {core_int
} -radix ascii /driver_spi_master/spi_master_inst/spi_master_core_inst/state_ascii
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/rst
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/wr_clk
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/wr_en
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/full
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/din
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/rd_clk
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/rd_en
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/empty
add wave -noupdate -group {spi_cmd_fifo
} /driver_spi_master/spi_master_inst/cmd_fifo_inst/dout
add wave -noupdate -group {rdback_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/rst
add wave -noupdate -group {rdback_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/wr_clk
add wave -noupdate -group {rdback_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/wr_en
add wave -noupdate -group {rdback_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/full
add wave -noupdate -group {rdback_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/din
add wave -noupdate -group {rdback_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/rd_clk
add wave -noupdate -group {rdback_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/rd_en
add wave -noupdate -group {rdback_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/empty
add wave -noupdate -group {rdback_fifo
} /driver_spi_master/spi_master_inst/rdback_fifo_inst/dout
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {spi_4wire
} /harness/i_spi_cs
add wave -noupdate -expand -group {spi_4wire
} /harness/i_spi_clk
add wave -noupdate -expand -group {spi_4wire
} /harness/i_spi_mosi
add wave -noupdate -expand -group {spi_4wire
} /harness/o_spi_miso
add wave -noupdate -expand -group {spi_slave_int
} -radix unsigned /harness/ctrl_channel_inst/spi_slave_inst/SPI_CMD_BYTE_LENGTH
add wave -noupdate -expand -group {spi_slave_int
} -radix unsigned /harness/ctrl_channel_inst/spi_slave_inst/SPI_ADDR_BYTE_LENGTH
add wave -noupdate -expand -group {spi_slave_int
} -radix unsigned /harness/ctrl_channel_inst/spi_slave_inst/SPI_DATA_BYTE_LENGTH
add wave -noupdate -expand -group {spi_slave_int
} -radix unsigned /harness/ctrl_channel_inst/spi_slave_inst/sck_rising_cnt
add wave -noupdate -expand -group {spi_slave_int
} -radix unsigned /harness/ctrl_channel_inst/spi_slave_inst/once_byte_cnt
add wave -noupdate -expand -group {spi_slave_int
} /harness/ctrl_channel_inst/spi_slave_inst/once_cnt_over_flow
add wave -noupdate -expand -group {spi_slave_int
} -radix unsigned -childformat {{{/harness/ctrl_channel_inst/spi_slave_inst/continue_byte_cnt[1]} -radix unsigned} {{/harness/ctrl_channel_inst/spi_slave_inst/continue_byte_cnt[0]} -radix unsigned}} -subitemconfig {{/harness/ctrl_channel_inst/spi_slave_inst/continue_byte_cnt[1]} {-height 15 -radix unsigned} {/harness/ctrl_channel_inst/spi_slave_inst/continue_byte_cnt[0]} {-height 15 -radix unsigned}} /harness/ctrl_channel_inst/spi_slave_inst/continue_byte_cnt
add wave -noupdate -expand -group {spi_slave_int
} /harness/ctrl_channel_inst/spi_slave_inst/spi_data_shifter
add wave -noupdate -expand -group {spi_slave_int
} /harness/ctrl_channel_inst/spi_slave_inst/cmd_rd
add wave -noupdate -expand -group {spi_slave_int
} /harness/ctrl_channel_inst/spi_slave_inst/rd_en
add wave -noupdate -expand -group {spi_slave_int
} /harness/ctrl_channel_inst/spi_slave_inst/cmd_wr
add wave -noupdate -expand -group {spi_slave_int
} -radix unsigned /harness/ctrl_channel_inst/spi_slave_inst/addr_reg
add wave -noupdate -expand -group {spi_slave_int
} -color {Blue Violet} /harness/ctrl_channel_inst/spi_slave_inst/wr_en
add wave -noupdate -expand -group {spi_slave_int
} -radix unsigned /harness/ctrl_channel_inst/spi_slave_inst/sck_rising_cnt
add wave -noupdate -expand -group {spi_slave_int
} /harness/ctrl_channel_inst/spi_slave_inst/rd_data_reg
add wave -noupdate -expand -group {spi_slave_int
} /harness/ctrl_channel_inst/spi_slave_inst/spi_clk_inv
add wave -noupdate -expand -group {spi_slave_int
} /harness/ctrl_channel_inst/spi_slave_inst/rd_data_shift_ena
add wave -noupdate -expand -group {spi_slave_int
} /harness/ctrl_channel_inst/spi_slave_inst/rd_data_reg
add wave -noupdate -expand -group {spi_slave_int
} /harness/ctrl_channel_inst/spi_slave_inst/i_fix_sel
add wave -noupdate -expand -group {spi_slave_int
} /harness/ctrl_channel_inst/spi_slave_inst/iv_fix_rd_data
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/i_spi_clk
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/i_spi_cs_n
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/i_spi_mosi
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/o_spi_miso_data
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/o_spi_miso_data_en
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/o_wr_en
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/o_rd_en
add wave -noupdate -group {spi_slave
} -radix hexadecimal -childformat {{{/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[15]} -radix unsigned} {{/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[14]} -radix unsigned} {{/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[13]} -radix unsigned} {{/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[12]} -radix unsigned} {{/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[11]} -radix unsigned} {{/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[10]} -radix unsigned} {{/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[9]} -radix unsigned} {{/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[8]} -radix unsigned} {{/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[7]} -radix unsigned} {{/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[6]} -radix unsigned} {{/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[5]} -radix unsigned} {{/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[4]} -radix unsigned} {{/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[3]} -radix unsigned} {{/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[2]} -radix unsigned} {{/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[1]} -radix unsigned} {{/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[0]} -radix unsigned}} -subitemconfig {{/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[15]} {-height 15 -radix unsigned} {/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[14]} {-height 15 -radix unsigned} {/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[13]} {-height 15 -radix unsigned} {/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[12]} {-height 15 -radix unsigned} {/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[11]} {-height 15 -radix unsigned} {/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[10]} {-height 15 -radix unsigned} {/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[9]} {-height 15 -radix unsigned} {/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[8]} {-height 15 -radix unsigned} {/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[7]} {-height 15 -radix unsigned} {/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[6]} {-height 15 -radix unsigned} {/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[5]} {-height 15 -radix unsigned} {/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[4]} {-height 15 -radix unsigned} {/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[3]} {-height 15 -radix unsigned} {/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[2]} {-height 15 -radix unsigned} {/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[1]} {-height 15 -radix unsigned} {/harness/ctrl_channel_inst/spi_slave_inst/ov_addr[0]} {-height 15 -radix unsigned}} /harness/ctrl_channel_inst/spi_slave_inst/ov_addr
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/ov_wr_data
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/i_pix_sel
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/iv_pix_rd_data
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/i_frame_buf_sel
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/iv_frame_buf_rd_data
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/i_gpif_sel
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/iv_gpif_rd_data
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/i_osc_bufg_sel
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/iv_osc_bufg_rd_data
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/i_fix_sel
add wave -noupdate -group {spi_slave
} /harness/ctrl_channel_inst/spi_slave_inst/iv_fix_rd_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {fix_reg_list
} /harness/ctrl_channel_inst/mer_reg_inst/fix_reg_list_inst/i_rd_en
add wave -noupdate -expand -group {fix_reg_list
} /harness/ctrl_channel_inst/mer_reg_inst/fix_reg_list_inst/iv_addr
add wave -noupdate -expand -group {fix_reg_list
} /harness/ctrl_channel_inst/mer_reg_inst/fix_reg_list_inst/o_fix_sel
add wave -noupdate -expand -group {fix_reg_list
} /harness/ctrl_channel_inst/mer_reg_inst/fix_reg_list_inst/ov_fix_rd_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -group {time_stamp
} /harness/ctrl_channel_inst/timestamp_inst/clk
add wave -noupdate -group {time_stamp
} /harness/ctrl_channel_inst/timestamp_inst/reset
add wave -noupdate -group {time_stamp
} /harness/ctrl_channel_inst/timestamp_inst/i_fval
add wave -noupdate -group {time_stamp
} /harness/ctrl_channel_inst/timestamp_inst/ov_timestamp_u3
add wave -noupdate -group {time_stamp
} /harness/ctrl_channel_inst/timestamp_inst/i_timestamp_load
add wave -noupdate -group {time_stamp
} /harness/ctrl_channel_inst/timestamp_inst/ov_timestamp_reg
add wave -noupdate -group {dna
} /harness/ctrl_channel_inst/dna_inst/clk
add wave -noupdate -group {dna
} /harness/ctrl_channel_inst/dna_inst/reset
add wave -noupdate -group {dna
} /harness/ctrl_channel_inst/dna_inst/ov_dna_reg
add wave -noupdate -group {dna
} /harness/ctrl_channel_inst/dna_inst/iv_encrypt_reg
add wave -noupdate -group {dna
} /harness/ctrl_channel_inst/dna_inst/o_encrypt_state
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 4} {855000 ns} 1} {{Cursor 2} {888000 ns} 1} {{Cursor 3} {904000 ns} 1} {{Cursor 4} {679000 ns} 1} {{Cursor 5} {695000 ns} 1}
quietly wave cursor active 5
configure wave -namecolwidth 194
configure wave -valuecolwidth 45
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
WaveRestoreZoom {634514 ns} {977017 ns}
