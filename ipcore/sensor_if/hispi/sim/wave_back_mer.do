onerror {resume}
quietly WaveActivateNextPane {} 0
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
add wave -noupdate -expand -group {iserdes_slave
} {/harness/mer_1520_13u3x_inst/iv_pix_data_p[0]}
add wave -noupdate -expand -group {iserdes_slave
} /harness/mer_1520_13u3x_inst/pix_clk_p
add wave -noupdate -expand -group {iserdes_slave
} {/harness/mer_1520_13u3x_inst/\NlwBufferSignal_data_channel_inst/deser_wrap_inst/deser_data_inst/channel[0].iserdes2_slave/CLK0 }
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {iserdes_master
} {/harness/mer_1520_13u3x_inst/iv_pix_data_p[0]}
add wave -noupdate -expand -group {iserdes_master
} /harness/mer_1520_13u3x_inst/pix_clk_p
add wave -noupdate -expand -group {iserdes_master
} {/harness/mer_1520_13u3x_inst/\NlwBufferSignal_data_channel_inst/deser_wrap_inst/deser_data_inst/channel[3].iserdes2_master/CLK0 }
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {data0
_p
} {/harness/mer_1520_13u3x_inst/iv_pix_data_p[0]}
add wave -noupdate -expand -group {data0
_p
} {/harness/mer_1520_13u3x_inst/\data_channel_inst/deser_wrap_inst/deser_data_inst/data_ibufds<0>_0 }
add wave -noupdate -expand -group {data0
_p
} {/harness/mer_1520_13u3x_inst/\NlwBufferSignal_data_channel_inst/deser_wrap_inst/deser_data_inst/channel[0].iodelay_m/IDATAIN }
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {data0_n
} {/harness/mer_1520_13u3x_inst/iv_pix_data_n[0]}
add wave -noupdate -expand -group {data0_n
} {/harness/mer_1520_13u3x_inst/\data_channel_inst/deser_wrap_inst/deser_data_inst/data_ibufds<0>_0 }
add wave -noupdate -expand -group {data0_n
} {/harness/mer_1520_13u3x_inst/\NlwBufferSignal_data_channel_inst/deser_wrap_inst/deser_data_inst/channel[0].iodelay_s/IDATAIN }
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {clkin_to_pllin
} /harness/mer_1520_13u3x_inst/pix_clk_p
add wave -noupdate -divider {New Divider}
add wave -noupdate -group {pllin_pllfb
} {/harness/mer_1520_13u3x_inst/\data_channel_inst/deser_wrap_inst/clk_io }
add wave -noupdate -divider {New Divider}
add wave -noupdate -group {pllin_iserdes
} {/harness/mer_1520_13u3x_inst/\data_channel_inst/deser_wrap_inst/clk_io }
add wave -noupdate -group {pllin_iserdes
} {/harness/mer_1520_13u3x_inst/\NlwBufferSignal_data_channel_inst/deser_wrap_inst/deser_data_inst/channel[3].iserdes2_master/CLK0 }
add wave -noupdate -group {pllin_iserdes
} {/harness/mer_1520_13u3x_inst/\NlwBufferSignal_data_channel_inst/deser_wrap_inst/deser_data_inst/channel[0].iserdes2_slave/CLK0 }
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {bufio2_clkp} /harness/mer_1520_13u3x_inst/pix_clk_p
add wave -noupdate -expand -group {bufio2_clkp} {/harness/mer_1520_13u3x_inst/\data_channel_inst/deser_wrap_inst/deser_clk_gen_bufio2_inst/clk_p_ibufgds }
add wave -noupdate -expand -group {bufio2_clkp} {/harness/mer_1520_13u3x_inst/\data_channel_inst/deser_wrap_inst/deser_clk_gen_bufio2_inst/clk_p_ibufgds_0 }
add wave -noupdate -expand -group {bufio2_clkp} {/harness/mer_1520_13u3x_inst/\NlwBufferSignal_data_channel_inst/deser_wrap_inst/deser_clk_gen_bufio2_inst/iodelay_deser_clkp_inst/IDATAIN }
add wave -noupdate -expand -group {bufio2_clkp} {/harness/mer_1520_13u3x_inst/\data_channel_inst/deser_wrap_inst/deser_clk_gen_bufio2_inst/clk_p_delay }
add wave -noupdate -expand -group {bufio2_clkp} {/harness/mer_1520_13u3x_inst/\NlwBufferSignal_data_channel_inst/deser_wrap_inst/deser_clk_gen_bufio2_inst/bufio2_2clk_deser_clk_inst/I }
add wave -noupdate -expand -group {bufio2_clkp} {/harness/mer_1520_13u3x_inst/\data_channel_inst/deser_wrap_inst/clk_io }
add wave -noupdate -expand -group {bufio2_clkp} {/harness/mer_1520_13u3x_inst/\NlwBufferSignal_data_channel_inst/deser_wrap_inst/deser_data_inst/channel[3].iserdes2_master/CLK0 }
add wave -noupdate -expand -group {bufio2_clkp} {/harness/mer_1520_13u3x_inst/\data_channel_inst/deser_wrap_inst/deser_data_inst/channel[3].iodelay_m/IOCLK0_INT }
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {bufio2_data0} {/harness/mer_1520_13u3x_inst/iv_pix_data_p[0]}
add wave -noupdate -expand -group {bufio2_data0} {/harness/mer_1520_13u3x_inst/\data_channel_inst/deser_wrap_inst/deser_data_inst/data_ibufds [0]}
add wave -noupdate -expand -group {bufio2_data0} {/harness/mer_1520_13u3x_inst/\data_channel_inst/deser_wrap_inst/deser_data_inst/data_ibufds<0>_0 }
add wave -noupdate -expand -group {bufio2_data0} {/harness/mer_1520_13u3x_inst/\NlwBufferSignal_data_channel_inst/deser_wrap_inst/deser_data_inst/channel[0].iodelay_m/IDATAIN }
add wave -noupdate -expand -group {bufio2_data0} {/harness/mer_1520_13u3x_inst/\data_channel_inst/deser_wrap_inst/deser_data_inst/data_delay_m [0]}
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group {bufio2_iserdes} {/harness/mer_1520_13u3x_inst/iv_pix_data_p[0]}
add wave -noupdate -expand -group {bufio2_iserdes} /harness/mer_1520_13u3x_inst/pix_clk_p
add wave -noupdate -expand -group {bufio2_iserdes} {/harness/mer_1520_13u3x_inst/\data_channel_inst/deser_wrap_inst/deser_data_inst/data_delay_m [0]}
add wave -noupdate -expand -group {bufio2_iserdes} {/harness/mer_1520_13u3x_inst/\NlwBufferSignal_data_channel_inst/deser_wrap_inst/deser_data_inst/channel[3].iserdes2_master/CLK0 }
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 29} {53108973 ps} 1} {{Cursor 30} {53109730 ps} 1} {{Cursor 31} {53113252 ps} 1} {{Cursor 32} {53114084 ps} 1} {{Cursor 33} {53114908 ps} 0}
quietly wave cursor active 5
configure wave -namecolwidth 575
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
WaveRestoreZoom {53098215 ps} {53150981 ps}
