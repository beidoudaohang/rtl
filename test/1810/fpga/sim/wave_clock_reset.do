onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {New Divider}
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/clk_osc
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/i_reset_sensor
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/i_stream_enable
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/clk_osc_bufg
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/reset_osc_bufg
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/async_rst
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/sysclk_2x
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/sysclk_2x_180
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/pll_ce_0
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/pll_ce_90
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/mcb_drp_clk
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/bufpll_mcb_lock
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/clk_frame_buf
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/reset_frame_buf
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/clk_pix
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/reset_pix
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/clk_pix_2x
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/reset_pix_2x
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/o_clk_sensor
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/o_sensor_reset_n
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/o_sensor_reset_done
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/o_clk_usb_pclk
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/clk_gpif
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/reset_gpif
add wave -noupdate -expand -group clock_reset /harness/clock_reset_inst/reset_u3_interface
add wave -noupdate -divider {New Divider}
add wave -noupdate /harness/clock_reset_inst/clk_sensor_ouput_reset
add wave -noupdate /harness/clock_reset_inst/sensor_reset_inst/clk_delay_cnt
add wave -noupdate /harness/clock_reset_inst/sensor_reset_inst/o_sensor_reset_n
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3950437600 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 201
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
WaveRestoreZoom {0 ps} {4725 us}
