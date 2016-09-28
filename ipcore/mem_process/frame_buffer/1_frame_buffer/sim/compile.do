

do define.do

#echo	"compile "
#vlog	$env(XILINX)/verilog/src/glbl.v
#vlog	+incdir+../src	+incdir+../src/pattern_port	+define+SIMULATION	../src/*.v
#vlog	../testbench/tb_bram.v

#vlog	$env(XILINX)/verilog/src/glbl.v




#
if {$SIM_MODE == "back" } {
	file delete -force netgen
	file copy ../prj/netgen	../sim
}

#
if { $TB_MODULE == "" } {
	vlog	../src/example/pattern_model.v
	vlog	+incdir+../src/pattern_port +define+x1Gb +define+sg187E +define+x16 ../testbench/ddr3_model_c3.v

	vlog	../src/blockram_core/fifo_w36d256_pf180_pe6.v
	vlog	../src/ddr3_core_150/ddr3_core_150/user_design/rtl/*.v
	vlog	../src/ddr3_core_150/ddr3_core_150/user_design/rtl/mcb_controller/*.v
	
	vlog	+incdir+../src	+incdir+../src/pattern_port	../src/*.v
	vlog	+incdir+../src	+incdir+../src/pattern_port	../src/wrap_frame_buffer.v
	vlog	+incdir+../src	+incdir+../src/pattern_port	../testbench/tb_$TB_MODULE.v
	
	
} elseif {$TB_MODULE == "frame_buffer" } {	
	#ddr3 core
	vlog	../src/frame_buf/blockram_core/fifo_w36d256_pf180_pe6.v
	vlog	../src/frame_buf/mig_core/mig_core/user_design/rtl/*.v
	vlog	../src/frame_buf/mig_core/mig_core/user_design/rtl/mcb_controller/*.v
	#frame buf
#	vlog	../src/frame_buf/*.v
	vlog	+define+TERRIBLE_TRAFFIC	../src/frame_buf/*.v

	#module
	vlog	../src/pattern_port/*.v
	vlog	../src/pattern_port/mult/*.v
	
	#testbench
#	vlog	+incdir+../testbench +define+x1Gb +define+sg15E +define+x8 ../testbench/ddr3_model_c3.v
	vlog	+incdir+../testbench +define+x1Gb +define+sg15E +define+x16 ../testbench/ddr3_model_c3.v
	vlog	+incdir+../testbench	../testbench/tb_$TB_MODULE.v
	
} elseif {$TB_MODULE == "example" } {
	if {$SIM_MODE == "back" } {
		vlog	+incdir+../src/pattern_port +define+x1Gb +define+sg187E +define+x16 ../testbench/ddr3_model_c3.v
		vlog	+incdir+../src	+incdir+../src/pattern_port	../testbench/tb_$TB_MODULE.v
		vlog	"netgen/par/top_frame_buffer_timesim.v"
	} else {

		vlog	../src/example/pattern_model.v
		vlog	+incdir+../src/pattern_port +define+x1Gb +define+sg187E +define+x16 ../testbench/ddr3_model_c3.v

		vlog	../src/blockram_core/fifo_w36d256_pf180_pe6.v
		vlog	../src/ddr3_core_150/ddr3_core_150/user_design/rtl/*.v
		vlog	../src/ddr3_core_150/ddr3_core_150/user_design/rtl/mcb_controller/*.v

		vlog	+incdir+../src	+incdir+../src/pattern_port	../src/*.v
		vlog	+incdir+../src	+incdir+../src/pattern_port	../src/example/top_frame_buffer.v
		vlog	+incdir+../src	+incdir+../src/pattern_port	../testbench/tb_$TB_MODULE.v

	}
} elseif {$TB_MODULE == "top" } {
	if {$SIM_MODE == "back" } {
		vlog	+incdir+../src/pattern_port +define+x1Gb +define+sg187E +define+x16 ../testbench/ddr3_model_c3.v
		vlog	+incdir+../src	+incdir+../src/pattern_port	../testbench/tb_$TB_MODULE.v
		vlog	"netgen/par/top_frame_buffer_timesim.v"
	} else {
		#ddr3 core
		vlog	../src/frame_buf/blockram_core/fifo_w36d256_pf180_pe6.v
		vlog	+incdir+../src/frame_buf	../src/frame_buf/mig_core/mig_core/user_design/rtl/*.v
		vlog	+incdir+../src/frame_buf	../src/frame_buf/mig_core/mig_core/user_design/rtl/mcb_controller/*.v
		#frame buf
		vlog	+define+SIMULATION	+incdir+../src/frame_buf	../src/frame_buf/*.v
		#module
		vlog	../src/chipscope/*.v
		vlog	+incdir+../src/frame_buf	../src/clk_rst/*.v
		vlog	../src/pattern_port/*.v
		vlog	../src/pattern_port/mult/*.v
		vlog	../src/frame_buf_traffic/rd_data/*.v
		vlog	../src/frame_buf_traffic/wr_data/*.v
		vlog	../src/frame_buf_traffic/*.v
		
		#top
		vlog	+define+SIMULATION	+incdir+../src/frame_buf	+incdir+../testbench	../src/top_frame_buffer.v
		
		#testbench
#		vlog	+incdir+../testbench +define+x1Gb +define+sg187E +define+x16 ../testbench/ddr3_model_c3.v
		vlog	+incdir+../testbench +define+x1Gb +define+sg187E +define+x8 ../testbench/ddr3_model_c3.v
		vlog	+define+SIMULATION	+incdir+../src/frame_buf	+incdir+../testbench	../testbench/tb_$TB_MODULE.v

	}
} else {
	echo	"compile no ***********"
}
