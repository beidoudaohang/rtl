onerror {resume}
quietly virtual function -install /harness/frame_buffer_inst/wrap_rd_logic_inst -env /harness/frame_buffer_inst/wrap_rd_logic_inst { 32'h624b63c4} virtual_000001
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider pll
add wave -noupdate /harness/frame_buffer_inst/i_sysclk_2x_180
add wave -noupdate /harness/frame_buffer_inst/i_sysclk_2x
add wave -noupdate /harness/frame_buffer_inst/i_stream_en_clk_in
add wave -noupdate /harness/frame_buffer_inst/i_stream_en
add wave -noupdate /harness/frame_buffer_inst/i_pll_ce_90
add wave -noupdate /harness/frame_buffer_inst/i_pll_ce_0
add wave -noupdate /harness/frame_buffer_inst/i_mcb_drp_clk
add wave -noupdate /harness/reset
add wave -noupdate -divider timing
add wave -noupdate /harness/timing_inst/o_trailer_flag
add wave -noupdate /harness/timing_inst/o_fval
add wave -noupdate /harness/timing_inst/o_dval
add wave -noupdate /harness/timing_inst/hcount
add wave -noupdate -divider data
add wave -noupdate /harness/hv_data_inst/i_dval
add wave -noupdate /harness/hv_data_inst/i_fval
add wave -noupdate /harness/hv_data_inst/i_trailer_flag
add wave -noupdate /harness/hv_data_inst/o_dval
add wave -noupdate /harness/hv_data_inst/o_fval
add wave -noupdate /harness/hv_data_inst/o_trailer_flag
add wave -noupdate /harness/hv_data_inst/ov_data
add wave -noupdate -divider wr
add wave -noupdate -color Red /harness/frame_buffer_inst/wrap_wr_logic_inst/iv_rd_frame_ptr
add wave -noupdate -color Red /harness/frame_buffer_inst/wrap_wr_logic_inst/ov_wr_frame_ptr
add wave -noupdate -color Red /harness/frame_buffer_inst/wrap_wr_logic_inst/ov_wr_addr
add wave -noupdate -color Red /harness/frame_buffer_inst/wrap_wr_logic_inst/wr_addr_reg
add wave -noupdate /harness/frame_buffer_inst/wrap_wr_logic_inst/state_ascii
add wave -noupdate /harness/frame_buffer_inst/wrap_wr_logic_inst/ov_frame_depth
add wave -noupdate /harness/frame_buffer_inst/wrap_wr_logic_inst/o_se_2_fvalrise
add wave -noupdate /harness/frame_buffer_inst/wrap_wr_logic_inst/ov_wr_frame_ptr
add wave -noupdate /harness/frame_buffer_inst/wrap_wr_logic_inst/ov_wr_addr
add wave -noupdate -divider rd
add wave -noupdate -color Red -itemcolor {Orange Red} /harness/frame_buffer_inst/wrap_rd_logic_inst/iv_wr_addr
add wave -noupdate -color Red -itemcolor {Orange Red} /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/iv_payload_size
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/frame_size_leader_payload
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/rd_addr
add wave -noupdate -radix ascii /harness/frame_buffer_inst/wrap_rd_logic_inst/state_ascii
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/next_state
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/frame_size
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/frame_size_cnt
add wave -noupdate -divider core
add wave -noupdate /harness/frame_buffer_inst/mig_core_inst/c1_p0_wr_data
add wave -noupdate /harness/frame_buffer_inst/mig_core_inst/c1_p0_wr_en
add wave -noupdate /harness/frame_buffer_inst/mig_core_inst/c1_p1_rd_data
add wave -noupdate /harness/frame_buffer_inst/mig_core_inst/c1_p1_rd_en
add wave -noupdate /harness/frame_buffer_inst/mig_core_inst/c1_p1_rd_clk
add wave -noupdate -divider front_fifo
add wave -noupdate /harness/frame_buffer_inst/wrap_wr_logic_inst/fifo_w65d256_pf180_pe6_inst/din
add wave -noupdate /harness/frame_buffer_inst/wrap_wr_logic_inst/fifo_w65d256_pf180_pe6_inst/wr_en
add wave -noupdate /harness/frame_buffer_inst/wrap_wr_logic_inst/fifo_w65d256_pf180_pe6_inst/rd_en
add wave -noupdate /harness/frame_buffer_inst/wrap_wr_logic_inst/fifo_w65d256_pf180_pe6_inst/dout
add wave -noupdate -divider back_fio
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/fifo_w64d256_pf180_pe6_inst/full
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/fifo_w64d256_pf180_pe6_inst/empty
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/fifo_w64d256_pf180_pe6_inst/rd_en
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/fifo_w64d256_pf180_pe6_inst/din
add wave -noupdate /harness/frame_buffer_inst/wrap_rd_logic_inst/fifo_w64d256_pf180_pe6_inst/dout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {71321739 ps} 0} {{Cursor 2} {466886403 ps} 0} {{Cursor 3} {771657128 ps} 0}
configure wave -namecolwidth 406
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1049315400 ps}
