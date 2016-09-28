

do define.do

#echo	"compile "
#vlog	$env(XILINX)/verilog/src/glbl.v
#vlog	+incdir+../src	+incdir+../testbench	+define+SIMULATION	../src/*.v
#vlog	../testbench/tb_bram.v

vlog	$env(XILINX)/verilog/src/glbl.v

#
if {$SIM_MODE == "back" } {
	file delete netgen
	file copy ../prj/netgen	../sim
}

#
if { $TB_MODULE == "sine" } {
	vlog	../src/bram/*.v
	vlog	../src/*.v
	vlog	../testbench/tb_$TB_MODULE.v
} elseif {$TB_MODULE == "" } {
		if {$SIM_MODE == "back" } {
			vlog	+incdir+../testbench +define+x1Gb +define+sg187E +define+x16 ../testbench/ddr3_model_c3.v
			vlog	+incdir+../src	+incdir+../testbench	../testbench/tb_$TB_MODULE.v
			vlog	"netgen/par/top_frame_buffer_timesim.v"
		} else {
		}
} else {
	echo	"compile no ***********"
}
