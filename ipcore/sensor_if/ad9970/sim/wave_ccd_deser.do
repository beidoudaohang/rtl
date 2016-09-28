onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider ccd
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/clk
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/reset
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/i_start_acquisit
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/i_trigger
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/i_triggermode
add wave -noupdate -group {mv_ccd
} -radix unsigned /harness/mv_ccd_inst/iv_href_start
add wave -noupdate -group {mv_ccd
} -radix unsigned /harness/mv_ccd_inst/iv_href_end
add wave -noupdate -group {mv_ccd
} -radix unsigned /harness/mv_ccd_inst/iv_hd_rising
add wave -noupdate -group {mv_ccd
} -radix unsigned /harness/mv_ccd_inst/iv_hd_falling
add wave -noupdate -group {mv_ccd
} -radix unsigned /harness/mv_ccd_inst/iv_sub_rising
add wave -noupdate -group {mv_ccd
} -radix unsigned /harness/mv_ccd_inst/iv_sub_falling
add wave -noupdate -group {mv_ccd
} -radix unsigned /harness/mv_ccd_inst/iv_vd_rising
add wave -noupdate -group {mv_ccd
} -radix unsigned /harness/mv_ccd_inst/iv_vd_falling
add wave -noupdate -group {mv_ccd
} -radix unsigned /harness/mv_ccd_inst/iv_xsg_width
add wave -noupdate -group {mv_ccd
} -radix unsigned /harness/mv_ccd_inst/iv_frame_period
add wave -noupdate -group {mv_ccd
} -radix unsigned /harness/mv_ccd_inst/iv_headblank_end
add wave -noupdate -group {mv_ccd
} -radix unsigned /harness/mv_ccd_inst/iv_vref_start
add wave -noupdate -group {mv_ccd
} -radix unsigned /harness/mv_ccd_inst/iv_tailblank_start
add wave -noupdate -group {mv_ccd
} -radix unsigned /harness/mv_ccd_inst/iv_tailblank_end
add wave -noupdate -group {mv_ccd
} -radix unsigned /harness/mv_ccd_inst/iv_exp_line
add wave -noupdate -group {mv_ccd
} -radix unsigned /harness/mv_ccd_inst/iv_exp_reg
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/i_ad_parm_valid
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/o_strobe
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/o_integration
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/o_href
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/o_vref
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/o_ccd_stop_flag
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/o_exposure_end
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/o_trigger_mask
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/o_trigger_mask_flag
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/o_hd
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/o_vd
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/o_sub
add wave -noupdate -group {mv_ccd
} /harness/mv_ccd_inst/ov_xsg
add wave -noupdate -group {mv_ccd
} -expand /harness/mv_ccd_inst/ov_xv
add wave -noupdate -group {ccd_controller_int
} -radix unsigned /harness/mv_ccd_inst/ccd_controller_inst/wv_vcount
add wave -noupdate -group {ccd_controller_int
} -radix unsigned /harness/mv_ccd_inst/ccd_controller_inst/wv_hcount
add wave -noupdate -group {ad_timing_gen_int
} -radix unsigned /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/hcount
add wave -noupdate -divider deser
add wave -noupdate -group {deser_top
} /harness/deserializer_top_inst/clk
add wave -noupdate -group {deser_top
} /harness/deserializer_top_inst/reset
add wave -noupdate -group {deser_top
} /harness/deserializer_top_inst/i_bitslip_en
add wave -noupdate -group {deser_top
} /harness/deserializer_top_inst/o_bitslip
add wave -noupdate -group {deser_top
} /harness/deserializer_top_inst/clk_p
add wave -noupdate -group {deser_top
} /harness/deserializer_top_inst/clk_n
add wave -noupdate -group {deser_top
} /harness/deserializer_top_inst/iv_data_p
add wave -noupdate -group {deser_top
} /harness/deserializer_top_inst/iv_data_n
add wave -noupdate -group {deser_top
} -radix unsigned /harness/deserializer_top_inst/iv_href_start
add wave -noupdate -group {deser_top
} -radix unsigned /harness/deserializer_top_inst/iv_href_end
add wave -noupdate -group {deser_top
} /harness/deserializer_top_inst/i_vref
add wave -noupdate -group {deser_top
} /harness/deserializer_top_inst/o_vref
add wave -noupdate -group {deser_top
} /harness/deserializer_top_inst/o_href
add wave -noupdate -group {deser_top
} /harness/deserializer_top_inst/ov_data
add wave -noupdate -group {deser_wrap
} /harness/deserializer_top_inst/deserializer_wrap_inst/gclk
add wave -noupdate -group {deser_wrap
} /harness/deserializer_top_inst/deserializer_wrap_inst/reset_gclk
add wave -noupdate -group {deser_wrap
} /harness/deserializer_top_inst/deserializer_wrap_inst/reset
add wave -noupdate -group {deser_wrap
} /harness/deserializer_top_inst/deserializer_wrap_inst/i_bitslip_en
add wave -noupdate -group {deser_wrap
} /harness/deserializer_top_inst/deserializer_wrap_inst/clk_p
add wave -noupdate -group {deser_wrap
} /harness/deserializer_top_inst/deserializer_wrap_inst/clk_n
add wave -noupdate -group {deser_wrap
} /harness/deserializer_top_inst/deserializer_wrap_inst/iv_data_p
add wave -noupdate -group {deser_wrap
} /harness/deserializer_top_inst/deserializer_wrap_inst/iv_data_n
add wave -noupdate -group {deser_wrap
} /harness/deserializer_top_inst/deserializer_wrap_inst/o_bitslip
add wave -noupdate -group {deser_wrap
} /harness/deserializer_top_inst/deserializer_wrap_inst/o_bitslip_done
add wave -noupdate -group {deser_wrap
} /harness/deserializer_top_inst/deserializer_wrap_inst/ov_data
add wave -noupdate -group {deser
_data
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/CLK_DIV_IN
add wave -noupdate -group {deser
_data
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/IO_RESET
add wave -noupdate -group {deser
_data
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/DATA_IN_FROM_PINS_P
add wave -noupdate -group {deser
_data
} -expand /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/DATA_IN_FROM_PINS_N
add wave -noupdate -group {deser
_data
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/clk_in_int_buf
add wave -noupdate -group {deser
_data
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/clk_in_int_inv
add wave -noupdate -group {deser
_data
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/serdesstrobe
add wave -noupdate -group {deser
_data
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/LOCKED_IN
add wave -noupdate -group {deser
_data
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/BITSLIP
add wave -noupdate -group {deser
_data
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/DEBUG_IN
add wave -noupdate -group {deser
_data
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/DEBUG_OUT
add wave -noupdate -group {deser
_data
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/DATA_IN_TO_DEVICE
add wave -noupdate -expand -group {deser_data_int
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/clk_in_int_buf
add wave -noupdate -expand -group {deser_data_int
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/rst_out
add wave -noupdate -expand -group {deser_data_int
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/cal_slave
add wave -noupdate -expand -group {deser_data_int
} -expand -group {ch0
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/busy[0]}
add wave -noupdate -expand -group {deser_data_int
} -expand -group {ch0
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/data_in_from_pins_int[0]}
add wave -noupdate -expand -group {deser_data_int
} -expand -group {ch0
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/data_in_from_pins_delay_m[0]}
add wave -noupdate -expand -group {deser_data_int
} -expand -group {ch0
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/data_in_from_pins_delay_s[0]}
add wave -noupdate -expand -group {deser_data_int
} -expand -group {ch0_idelay_slave
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[0]/iodelay_s/delay1_out}
add wave -noupdate -expand -group {deser_data_int
} -expand -group {ch0_idelay_slave
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[0]/iodelay_s/delay1_out_dly}
add wave -noupdate -expand -group {deser_data_int
} -expand -group {ch0_idelay_slave
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[0]/iodelay_s/delay1_out_sig}
add wave -noupdate -expand -group {deser_data_int
} -expand -group {ch0_idelay_slave
} -radix unsigned {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[0]/iodelay_s/delay_val_pe_1}
add wave -noupdate -expand -group {deser_data_int
} -expand -group {ch0_idelay_slave
} -radix unsigned {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[0]/iodelay_s/half_max}
add wave -noupdate -expand -group {deser_data_int
} -expand -group {ch0_idelay_master
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[0]/iodelay_m/delay1_out}
add wave -noupdate -expand -group {deser_data_int
} -expand -group {ch0_idelay_master
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[0]/iodelay_m/delay1_out_dly}
add wave -noupdate -expand -group {deser_data_int
} -expand -group {ch0_idelay_master
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[0]/iodelay_m/delay1_out_sig}
add wave -noupdate -expand -group {deser_data_int
} -expand -group {ch0_idelay_master
} -radix unsigned {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[0]/iodelay_m/delay_val_pe_1}
add wave -noupdate -expand -group {deser_data_int
} -expand -group {ch0_idelay_master
} -radix unsigned {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[0]/iodelay_m/half_max}
add wave -noupdate -expand -group {deser_data_int
} -group {ch1
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/busy[1]}
add wave -noupdate -expand -group {deser_data_int
} -group {ch1
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/data_in_from_pins_int[1]}
add wave -noupdate -expand -group {deser_data_int
} -group {ch1
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/data_in_from_pins_delay_m[1]}
add wave -noupdate -expand -group {deser_data_int
} -group {ch1
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/data_in_from_pins_delay_s[1]}
add wave -noupdate -expand -group {deser_data_int
} -group {ch1_idelay_slave
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[1]/iodelay_s/delay1_out}
add wave -noupdate -expand -group {deser_data_int
} -group {ch1_idelay_slave
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[1]/iodelay_s/delay1_out_dly}
add wave -noupdate -expand -group {deser_data_int
} -group {ch1_idelay_slave
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[1]/iodelay_s/delay1_out_sig}
add wave -noupdate -expand -group {deser_data_int
} -group {ch1_idelay_slave
} -radix unsigned {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[1]/iodelay_s/delay_val_pe_1}
add wave -noupdate -expand -group {deser_data_int
} -group {ch1_idelay_slave
} -radix unsigned {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[1]/iodelay_s/half_max}
add wave -noupdate -expand -group {deser_data_int
} -group {ch1_idelay_master
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[1]/iodelay_m/delay1_out}
add wave -noupdate -expand -group {deser_data_int
} -group {ch1_idelay_master
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[1]/iodelay_m/delay1_out_dly}
add wave -noupdate -expand -group {deser_data_int
} -group {ch1_idelay_master
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[1]/iodelay_m/delay1_out_sig}
add wave -noupdate -expand -group {deser_data_int
} -group {ch1_idelay_master
} -radix unsigned {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[1]/iodelay_m/delay_val_pe_1}
add wave -noupdate -expand -group {deser_data_int
} -group {ch1_idelay_master
} -radix unsigned {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/pins[1]/iodelay_m/half_max}
add wave -noupdate -expand -group {deser_data_int
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/data_in_from_pins_int
add wave -noupdate -expand -group {deser_data_int
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/data_in_from_pins_delay_m
add wave -noupdate -expand -group {deser_data_int
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/data_in_from_pins_delay_s
add wave -noupdate -group {phase_detector
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/use_phase_detector
add wave -noupdate -group {phase_detector
} -expand /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/busy
add wave -noupdate -group {phase_detector
} -expand /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/valid
add wave -noupdate -group {phase_detector
} -expand /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/inc_dec
add wave -noupdate -group {phase_detector
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/reset
add wave -noupdate -group {phase_detector
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/gclk
add wave -noupdate -group {phase_detector
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/debug_in
add wave -noupdate -group {phase_detector
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/debug
add wave -noupdate -group {phase_detector
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/cal_master
add wave -noupdate -group {phase_detector
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/cal_slave
add wave -noupdate -group {phase_detector
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/rst_out
add wave -noupdate -group {phase_detector
} -expand /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/ce
add wave -noupdate -group {phase_detector
} -expand /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/inc
add wave -noupdate -group {pd_int
} {/harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/counter[5]}
add wave -noupdate -group {pd_int
} /harness/deserializer_top_inst/deserializer_wrap_inst/deserializer_data_inst/phase_detector_inst/state
add wave -noupdate -divider {sim model}
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/cli
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/i_vd
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/i_hd
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/i_lvds_pattern_en
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/iv_lvds_pattern
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/i_sync_align_loc
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/iv_sync_start_loc
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/iv_sync_word0
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/iv_sync_word1
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/iv_sync_word2
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/iv_sync_word3
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/iv_sync_word4
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/iv_sync_word5
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/iv_sync_word6
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/iv_hblk_tog1
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/iv_hblk_tog2
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/i_hl_mask_pol
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/i_h1_mask_pol
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/i_h2_mask_pol
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/iv_tclk_delay
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/o_hl
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/o_h1
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/o_h2
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/o_rg
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/iv_pix_data
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/o_tckp
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/o_tckn
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/o_dout0p
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/o_dout0n
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/o_dout1p
add wave -noupdate -group {ad9970
} /driver_ad9970/ad9970_module_inst/o_dout1n
add wave -noupdate -group {ad_timing_gen
} /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/clk
add wave -noupdate -group {ad_timing_gen
} /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/i_vd
add wave -noupdate -group {ad_timing_gen
} /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/i_hd
add wave -noupdate -group {ad_timing_gen
} /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/i_sync_align_loc
add wave -noupdate -group {ad_timing_gen
} /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/iv_sync_start_loc
add wave -noupdate -group {ad_timing_gen
} /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/iv_sync_word0
add wave -noupdate -group {ad_timing_gen
} /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/iv_sync_word1
add wave -noupdate -group {ad_timing_gen
} /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/iv_sync_word2
add wave -noupdate -group {ad_timing_gen
} /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/iv_sync_word3
add wave -noupdate -group {ad_timing_gen
} /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/iv_sync_word4
add wave -noupdate -group {ad_timing_gen
} /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/iv_sync_word5
add wave -noupdate -group {ad_timing_gen
} /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/iv_sync_word6
add wave -noupdate -group {ad_timing_gen
} /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/o_sync_word_sel
add wave -noupdate -group {ad_timing_gen
} /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/ov_sync_word
add wave -noupdate -group {ad_timing_gen
} /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/iv_hblk_tog1
add wave -noupdate -group {ad_timing_gen
} /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/iv_hblk_tog2
add wave -noupdate -group {ad_timing_gen
} /driver_ad9970/ad9970_module_inst/ad_timing_generation_inst/o_hblk_n
add wave -noupdate -divider {New Divider}
add wave -noupdate -group {sharp_ccd
} /driver_ccd_sharp/ccd_sharp_module_inst/xv1
add wave -noupdate -group {sharp_ccd
} /driver_ccd_sharp/ccd_sharp_module_inst/xv2
add wave -noupdate -group {sharp_ccd
} /driver_ccd_sharp/ccd_sharp_module_inst/xv3
add wave -noupdate -group {sharp_ccd
} /driver_ccd_sharp/ccd_sharp_module_inst/xv4
add wave -noupdate -group {sharp_ccd
} /driver_ccd_sharp/ccd_sharp_module_inst/hl
add wave -noupdate -group {sharp_ccd
} /driver_ccd_sharp/ccd_sharp_module_inst/h1
add wave -noupdate -group {sharp_ccd
} /driver_ccd_sharp/ccd_sharp_module_inst/h2
add wave -noupdate -group {sharp_ccd
} /driver_ccd_sharp/ccd_sharp_module_inst/rs
add wave -noupdate -group {sharp_ccd
} /driver_ccd_sharp/ccd_sharp_module_inst/ov_pix_data
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
add wave -noupdate -divider {New Divider}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {280361061 ps} 0} {{Cursor 2} {619643249 ps} 1}
quietly wave cursor active 1
configure wave -namecolwidth 232
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
WaveRestoreZoom {363973444 ps} {375312678 ps}
