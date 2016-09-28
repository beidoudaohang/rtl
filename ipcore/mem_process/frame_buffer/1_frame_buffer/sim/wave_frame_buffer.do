onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -group {debug
} -radix binary -childformat {{{/tb_frame_buffer/bank[7]} -radix binary} {{/tb_frame_buffer/bank[6]} -radix binary} {{/tb_frame_buffer/bank[5]} -radix binary} {{/tb_frame_buffer/bank[4]} -radix binary} {{/tb_frame_buffer/bank[3]} -radix binary} {{/tb_frame_buffer/bank[2]} -radix binary} {{/tb_frame_buffer/bank[1]} -radix binary} {{/tb_frame_buffer/bank[0]} -radix binary}} -subitemconfig {{/tb_frame_buffer/bank[7]} {-height 15 -radix binary} {/tb_frame_buffer/bank[6]} {-height 15 -radix binary} {/tb_frame_buffer/bank[5]} {-height 15 -radix binary} {/tb_frame_buffer/bank[4]} {-height 15 -radix binary} {/tb_frame_buffer/bank[3]} {-height 15 -radix binary} {/tb_frame_buffer/bank[2]} {-height 15 -radix binary} {/tb_frame_buffer/bank[1]} {-height 15 -radix binary} {/tb_frame_buffer/bank[0]} {-height 15 -radix binary}} /tb_frame_buffer/bank
add wave -noupdate -group {debug
} /tb_frame_buffer/row
add wave -noupdate -group {debug
} /tb_frame_buffer/current_wr_bank_addr
add wave -noupdate -group {debug
} /tb_frame_buffer/current_wr_row_addr
add wave -noupdate -group {debug
} /tb_frame_buffer/current_rd_bank_addr
add wave -noupdate -group {debug
} /tb_frame_buffer/current_rd_row_addr
add wave -noupdate -group {debug
} -radix ascii -childformat {{{/tb_frame_buffer/rd_wr_cmd[7]} -radix ascii} {{/tb_frame_buffer/rd_wr_cmd[6]} -radix ascii} {{/tb_frame_buffer/rd_wr_cmd[5]} -radix ascii} {{/tb_frame_buffer/rd_wr_cmd[4]} -radix ascii} {{/tb_frame_buffer/rd_wr_cmd[3]} -radix ascii} {{/tb_frame_buffer/rd_wr_cmd[2]} -radix ascii} {{/tb_frame_buffer/rd_wr_cmd[1]} -radix ascii} {{/tb_frame_buffer/rd_wr_cmd[0]} -radix ascii}} -subitemconfig {{/tb_frame_buffer/rd_wr_cmd[7]} {-height 15 -radix ascii} {/tb_frame_buffer/rd_wr_cmd[6]} {-height 15 -radix ascii} {/tb_frame_buffer/rd_wr_cmd[5]} {-height 15 -radix ascii} {/tb_frame_buffer/rd_wr_cmd[4]} {-height 15 -radix ascii} {/tb_frame_buffer/rd_wr_cmd[3]} {-height 15 -radix ascii} {/tb_frame_buffer/rd_wr_cmd[2]} {-height 15 -radix ascii} {/tb_frame_buffer/rd_wr_cmd[1]} {-height 15 -radix ascii} {/tb_frame_buffer/rd_wr_cmd[0]} {-height 15 -radix ascii}} /tb_frame_buffer/rd_wr_cmd
add wave -noupdate -group {debug
} -color Magenta -radix ascii /tb_frame_buffer/DDR3_CMD
add wave -noupdate -group {debug
} /tb_frame_buffer/buf_rd_en
add wave -noupdate -radix ascii -childformat {{{/tb_frame_buffer/rd_wr_cmd[7]} -radix ascii} {{/tb_frame_buffer/rd_wr_cmd[6]} -radix ascii} {{/tb_frame_buffer/rd_wr_cmd[5]} -radix ascii} {{/tb_frame_buffer/rd_wr_cmd[4]} -radix ascii} {{/tb_frame_buffer/rd_wr_cmd[3]} -radix ascii} {{/tb_frame_buffer/rd_wr_cmd[2]} -radix ascii} {{/tb_frame_buffer/rd_wr_cmd[1]} -radix ascii} {{/tb_frame_buffer/rd_wr_cmd[0]} -radix ascii}} -subitemconfig {{/tb_frame_buffer/rd_wr_cmd[7]} {-height 15 -radix ascii} {/tb_frame_buffer/rd_wr_cmd[6]} {-height 15 -radix ascii} {/tb_frame_buffer/rd_wr_cmd[5]} {-height 15 -radix ascii} {/tb_frame_buffer/rd_wr_cmd[4]} {-height 15 -radix ascii} {/tb_frame_buffer/rd_wr_cmd[3]} {-height 15 -radix ascii} {/tb_frame_buffer/rd_wr_cmd[2]} {-height 15 -radix ascii} {/tb_frame_buffer/rd_wr_cmd[1]} {-height 15 -radix ascii} {/tb_frame_buffer/rd_wr_cmd[0]} {-height 15 -radix ascii}} /tb_frame_buffer/rd_wr_cmd
add wave -noupdate /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_cmd_en
add wave -noupdate /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_cmd_en
add wave -noupdate /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_cmd_empty
add wave -noupdate -expand -group ddr3_model -radix ascii -childformat {{{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9]} -radix ascii -childformat {{{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][71]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][70]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][69]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][68]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][67]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][66]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][65]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][64]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][63]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][62]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][61]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][60]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][59]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][58]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][57]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][56]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][55]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][54]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][53]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][52]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][51]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][50]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][49]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][48]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][47]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][46]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][45]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][44]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][43]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][42]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][41]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][40]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][39]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][38]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][37]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][36]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][35]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][34]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][33]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][32]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][31]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][30]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][29]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][28]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][27]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][26]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][25]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][24]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][23]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][22]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][21]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][20]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][19]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][18]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][17]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][16]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][15]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][14]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][13]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][12]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][11]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][10]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][9]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][8]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][7]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][6]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][5]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][4]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][3]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][2]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][1]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][0]} -radix ascii}}} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[8]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[7]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[6]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[5]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[4]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[3]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[2]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[1]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[0]} -radix ascii}} -subitemconfig {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9]} {-height 15 -radix ascii -childformat {{{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][71]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][70]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][69]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][68]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][67]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][66]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][65]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][64]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][63]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][62]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][61]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][60]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][59]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][58]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][57]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][56]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][55]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][54]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][53]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][52]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][51]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][50]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][49]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][48]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][47]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][46]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][45]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][44]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][43]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][42]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][41]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][40]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][39]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][38]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][37]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][36]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][35]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][34]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][33]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][32]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][31]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][30]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][29]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][28]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][27]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][26]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][25]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][24]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][23]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][22]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][21]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][20]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][19]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][18]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][17]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][16]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][15]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][14]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][13]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][12]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][11]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][10]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][9]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][8]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][7]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][6]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][5]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][4]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][3]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][2]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][1]} -radix ascii} {{/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][0]} -radix ascii}}} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][71]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][70]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][69]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][68]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][67]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][66]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][65]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][64]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][63]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][62]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][61]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][60]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][59]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][58]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][57]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][56]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][55]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][54]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][53]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][52]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][51]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][50]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][49]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][48]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][47]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][46]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][45]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][44]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][43]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][42]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][41]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][40]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][39]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][38]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][37]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][36]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][35]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][34]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][33]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][32]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][31]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][30]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][29]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][28]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][27]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][26]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][25]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][24]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][23]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][22]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][21]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][20]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][19]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][18]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][17]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][16]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][15]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][14]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][13]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][12]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][11]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][10]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][9]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][8]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][7]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][6]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][5]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][4]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][3]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][2]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][1]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[9][0]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[8]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[7]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[6]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[5]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[4]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[3]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[2]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[1]} {-height 15 -radix ascii} {/tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string[0]} {-height 15 -radix ascii}} /tb_frame_buffer/genblk1/ddr3_model_c3_inst/cmd_string
add wave -noupdate -expand -group ddr3_model /tb_frame_buffer/genblk1/ddr3_model_c3_inst/ck
add wave -noupdate -expand -group ddr3_model /tb_frame_buffer/genblk1/ddr3_model_c3_inst/ck_n
add wave -noupdate -expand -group ddr3_model /tb_frame_buffer/genblk1/ddr3_model_c3_inst/cke
add wave -noupdate -expand -group ddr3_model /tb_frame_buffer/genblk1/ddr3_model_c3_inst/cs_n
add wave -noupdate -expand -group ddr3_model /tb_frame_buffer/genblk1/ddr3_model_c3_inst/ras_n
add wave -noupdate -expand -group ddr3_model /tb_frame_buffer/genblk1/ddr3_model_c3_inst/cas_n
add wave -noupdate -expand -group ddr3_model /tb_frame_buffer/genblk1/ddr3_model_c3_inst/we_n
add wave -noupdate -expand -group ddr3_model /tb_frame_buffer/genblk1/ddr3_model_c3_inst/dm_tdqs
add wave -noupdate -expand -group ddr3_model /tb_frame_buffer/genblk1/ddr3_model_c3_inst/ba
add wave -noupdate -expand -group ddr3_model /tb_frame_buffer/genblk1/ddr3_model_c3_inst/addr
add wave -noupdate -expand -group ddr3_model /tb_frame_buffer/genblk1/ddr3_model_c3_inst/dq
add wave -noupdate -expand -group ddr3_model /tb_frame_buffer/genblk1/ddr3_model_c3_inst/dqs
add wave -noupdate -expand -group ddr3_model /tb_frame_buffer/genblk1/ddr3_model_c3_inst/dqs_n
add wave -noupdate -expand -group ddr3_model /tb_frame_buffer/genblk1/ddr3_model_c3_inst/tdqs_n
add wave -noupdate -expand -group ddr3_model /tb_frame_buffer/genblk1/ddr3_model_c3_inst/odt
add wave -noupdate -expand -group ddr3_model /tb_frame_buffer/genblk1/ddr3_model_c3_inst/rst_n
add wave -noupdate -divider mcb
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_calib_done
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_cmd_clk
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_cmd_en
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_cmd_instr
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_cmd_bl
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_cmd_byte_addr
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_cmd_empty
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_cmd_full
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_wr_clk
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_wr_en
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_wr_mask
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_wr_data
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_wr_full
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_wr_empty
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_wr_count
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_wr_underrun
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_wr_error
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_cmd_clk
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_cmd_en
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_cmd_instr
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_cmd_bl
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_cmd_byte_addr
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_cmd_empty
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_cmd_full
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_rd_clk
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_rd_en
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_rd_data
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_rd_full
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_rd_empty
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_rd_count
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_rd_overflow
add wave -noupdate -expand -group mcb /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_rd_error
add wave -noupdate -group {mcb_raw_wrapper
} /tb_frame_buffer/frame_buffer_inst/mig_core_inst/memc3_wrapper_inst/mcb_ui_top_inst/mcb_raw_wrapper_inst/DONE_SOFTANDHARD_CAL
add wave -noupdate -group {mcb_raw_wrapper
} /tb_frame_buffer/frame_buffer_inst/mig_core_inst/memc3_wrapper_inst/mcb_ui_top_inst/mcb_raw_wrapper_inst/hard_done_cal
add wave -noupdate -group {mcb_raw_wrapper
} /tb_frame_buffer/frame_buffer_inst/mig_core_inst/memc3_wrapper_inst/mcb_ui_top_inst/mcb_raw_wrapper_inst/uo_done_cal
add wave -noupdate -group {mcb_raw_wrapper
} -radix ascii /tb_frame_buffer/frame_buffer_inst/mig_core_inst/memc3_wrapper_inst/mcb_ui_top_inst/mcb_raw_wrapper_inst/C_CALIB_SOFT_IP
add wave -noupdate -group {mcb_raw_wrapper
} -radix ascii /tb_frame_buffer/frame_buffer_inst/mig_core_inst/C3_SIMULATION
add wave -noupdate -group {wrap_frame_buffer
} /tb_frame_buffer/ddr3_pll_inst/sys_rst
add wave -noupdate -group {wrap_frame_buffer
} /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_calib_done
add wave -noupdate -group {wrap_frame_buffer
} /tb_frame_buffer/frame_buffer_inst/wv_wr_frame_ptr
add wave -noupdate -group {wrap_frame_buffer
} /tb_frame_buffer/frame_buffer_inst/wv_rd_frame_ptr
add wave -noupdate -group {wrap_frame_buffer
} /tb_frame_buffer/frame_buffer_inst/w_reading
add wave -noupdate -group {wrap_frame_buffer
} /tb_frame_buffer/frame_buffer_inst/w_writing
add wave -noupdate -divider testbench
add wave -noupdate -expand -group pattern /tb_frame_buffer/i_fval
add wave -noupdate -expand -group pattern /tb_frame_buffer/i_dval
add wave -noupdate -group file /tb_frame_buffer/file_src
add wave -noupdate -group file /tb_frame_buffer/file_dst
add wave -noupdate -group config /tb_frame_buffer/i_frame_en
add wave -noupdate -group config /tb_frame_buffer/iv_frame_depth
add wave -noupdate -group config /tb_frame_buffer/iv_frame_size
add wave -noupdate -group pll /tb_frame_buffer/ddr3_pll_inst/sys_clk
add wave -noupdate -group pll /tb_frame_buffer/ddr3_pll_inst/sys_rst
add wave -noupdate -group pll /tb_frame_buffer/ddr3_pll_inst/async_rst
add wave -noupdate -group pll /tb_frame_buffer/ddr3_pll_inst/sysclk_2x
add wave -noupdate -group pll /tb_frame_buffer/ddr3_pll_inst/sysclk_2x_180
add wave -noupdate -group pll /tb_frame_buffer/ddr3_pll_inst/pll_ce_0
add wave -noupdate -group pll /tb_frame_buffer/ddr3_pll_inst/pll_ce_90
add wave -noupdate -group pll /tb_frame_buffer/ddr3_pll_inst/mcb_drp_clk
add wave -noupdate -group pll /tb_frame_buffer/ddr3_pll_inst/bufpll_mcb_lock
add wave -noupdate -group pll /tb_frame_buffer/ddr3_pll_inst/pll_lock
add wave -noupdate -group pll /tb_frame_buffer/ddr3_pll_inst/clk_out3
add wave -noupdate -group pll /tb_frame_buffer/ddr3_pll_inst/clk_out4
add wave -noupdate -group pll /tb_frame_buffer/ddr3_pll_inst/clk_out5
add wave -noupdate -group mcb_key_signal /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_cmd_en
add wave -noupdate -group mcb_key_signal /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_cmd_empty
add wave -noupdate -group mcb_key_signal /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_cmd_byte_addr
add wave -noupdate -group mcb_key_signal /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_cmd_en
add wave -noupdate -group mcb_key_signal /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_cmd_empty
add wave -noupdate -group mcb_key_signal /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_cmd_byte_addr
add wave -noupdate -group mcb_key_signal /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_calib_done
add wave -noupdate -divider wrap_wr_logic
add wave -noupdate /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_cmd_en
add wave -noupdate /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_cmd_en
add wave -noupdate -group fifo_con /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/fifo_con_inst/clk
add wave -noupdate -group fifo_con /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/fifo_con_inst/i_fval
add wave -noupdate -group fifo_con /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/fifo_con_inst/o_rst_buf
add wave -noupdate -group front_buf /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/rst
add wave -noupdate -group front_buf /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/wr_clk
add wave -noupdate -group front_buf /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/wr_en
add wave -noupdate -group front_buf /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/full
add wave -noupdate -group front_buf /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/prog_full
add wave -noupdate -group front_buf /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/din
add wave -noupdate -group front_buf /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/rd_clk
add wave -noupdate -group front_buf /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/rd_en
add wave -noupdate -group front_buf -color {Slate Blue} /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/empty
add wave -noupdate -group front_buf /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/prog_empty
add wave -noupdate -group front_buf /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/front_buf_inst/dout
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/clk
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/reset
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/iv_frame_depth
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_fval
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/iv_buf_dout
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/o_buf_rd_en
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_buf_pe
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_buf_empty
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/ov_wr_frame_ptr
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/ov_wr_addr
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/o_wr_req
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_wr_ack
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/o_writing
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/iv_rd_frame_ptr
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_reading
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_calib_done
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/o_p2_cmd_en
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/ov_p2_cmd_instr
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/ov_p2_cmd_bl
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/ov_p2_cmd_byte_addr
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_p2_cmd_empty
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_p2_cmd_full
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/o_p2_wr_en
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/ov_p2_wr_mask
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/ov_p2_wr_data
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_p2_wr_full
add wave -noupdate -group wr_logic /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/i_p2_wr_empty
add wave -noupdate -group wr_logic_int /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/frame_en_int
add wave -noupdate -group wr_logic_int /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/current_state
add wave -noupdate -group wr_logic_int -radix ascii /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/state_ascii
add wave -noupdate /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_wr_full
add wave -noupdate /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/frame_depth_reg
add wave -noupdate -divider wrap_rd_logic
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/clk
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/reset
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/iv_frame_depth
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/iv_frame_size
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/o_buf_rst
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/ov_buf_din
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/o_buf_wr_en
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_buf_pf
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_buf_empty
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_buf_dout32
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/ov_rd_frame_ptr
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/o_rd_req
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_rd_ack
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/o_reading
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/iv_wr_frame_ptr
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/iv_wr_addr
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_writing
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_calib_done
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/o_p3_cmd_en
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/ov_p3_cmd_instr
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/ov_p3_cmd_bl
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/ov_p3_cmd_byte_addr
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_p3_cmd_empty
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_p3_cmd_full
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/o_p3_rd_en
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/iv_p3_rd_data
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_p3_rd_full
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_p3_rd_empty
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_p3_rd_overflow
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_p3_rd_error
add wave -noupdate -group rd_logic /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/i_p2_cmd_empty
add wave -noupdate -expand -group {rd_logic_int
} /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/frame_done_reg
add wave -noupdate -expand -group {rd_logic_int
} -radix ascii /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/state_ascii
add wave -noupdate -expand -group {rd_logic_int
} /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/rd_logic_inst/frame_size_reg
add wave -noupdate -group back_buf /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/rst
add wave -noupdate -group back_buf /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/wr_clk
add wave -noupdate -group back_buf /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/wr_en
add wave -noupdate -group back_buf /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/full
add wave -noupdate -group back_buf /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/prog_full
add wave -noupdate -group back_buf /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/din
add wave -noupdate -group back_buf /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/rd_clk
add wave -noupdate -group back_buf /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/rd_en
add wave -noupdate -group back_buf /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/empty
add wave -noupdate -group back_buf /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/prog_empty
add wave -noupdate -group back_buf /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/dout
add wave -noupdate -divider judge
add wave -noupdate -group judge /tb_frame_buffer/frame_buffer_inst/judge_inst/clk
add wave -noupdate -group judge /tb_frame_buffer/frame_buffer_inst/judge_inst/i_wr_req
add wave -noupdate -group judge /tb_frame_buffer/frame_buffer_inst/judge_inst/i_rd_req
add wave -noupdate -group judge /tb_frame_buffer/frame_buffer_inst/judge_inst/o_wr_ack
add wave -noupdate -group judge /tb_frame_buffer/frame_buffer_inst/judge_inst/o_rd_ack
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {test wr period}
add wave -noupdate -group {test_wr_period
} /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_cmd_en
add wave -noupdate -group {test_wr_period
} /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_cmd_empty
add wave -noupdate -group {test_wr_period
} /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p2_wr_full
add wave -noupdate -group {test_wr_period
} -radix ascii /tb_frame_buffer/frame_buffer_inst/wrap_wr_logic_inst/wr_logic_inst/state_ascii
add wave -noupdate -divider {test rd period}
add wave -noupdate -group {test_rd_period
} /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_cmd_en
add wave -noupdate -group {test_rd_period
} /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_cmd_empty
add wave -noupdate -group {test_rd_period
} /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_rd_en
add wave -noupdate -group {test_rd_period
} /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_rd_full
add wave -noupdate -group {test_rd_period
} /tb_frame_buffer/frame_buffer_inst/mig_core_inst/c3_p3_rd_empty
add wave -noupdate -group {test_rd_period
} -group {back_buf
1} /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/rst
add wave -noupdate -group {test_rd_period
} -group {back_buf
1} /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/wr_clk
add wave -noupdate -group {test_rd_period
} -group {back_buf
1} /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/wr_en
add wave -noupdate -group {test_rd_period
} -group {back_buf
1} /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/full
add wave -noupdate -group {test_rd_period
} -group {back_buf
1} /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/prog_full
add wave -noupdate -group {test_rd_period
} -group {back_buf
1} /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/din
add wave -noupdate -group {test_rd_period
} -group {back_buf
1} /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/rd_clk
add wave -noupdate -group {test_rd_period
} -group {back_buf
1} /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/rd_en
add wave -noupdate -group {test_rd_period
} -group {back_buf
1} /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/empty
add wave -noupdate -group {test_rd_period
} -group {back_buf
1} /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/prog_empty
add wave -noupdate -group {test_rd_period
} -group {back_buf
1} /tb_frame_buffer/frame_buffer_inst/wrap_rd_logic_inst/back_buf_inst/dout
add wave -noupdate -divider {New Divider}
add wave -noupdate /tb_frame_buffer/refresh_time_cnt
add wave -noupdate -radix unsigned /tb_frame_buffer/refresh_num_cnt
add wave -noupdate /tb_frame_buffer/refresh_time
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {6993700 ps} 0} {{Cursor 3} {23336744 ps} 1}
quietly wave cursor active 1
configure wave -namecolwidth 181
configure wave -valuecolwidth 69
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
WaveRestoreZoom {11028330 ps} {12103372 ps}
