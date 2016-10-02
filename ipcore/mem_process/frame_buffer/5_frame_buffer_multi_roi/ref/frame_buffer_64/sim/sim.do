vlib    work
#echo	"compile "
vlog	$env(XILINX)/verilog/src/glbl.v
vlog	+incdir+ ../src/*.v
vlog	+incdir+ ../src/fifo_w64d256_pf180_pe6/*.v
vlog	+incdir+ ../src/fifo_w65d256_pf180_pe6/*.v
vlog	+incdir+ ../src/mig_core/ip/mig_core/user_design/rtl/*.v
vlog	+incdir+ ../src/mig_core/ip/mig_core/user_design/rtl/mcb_controller/*.v
vlog	+incdir+ +define+x1Gb +define+sg15E +define+x16 +define+MAX_MEM  ../testbench/ddr3_model_c1.v
vlog	+incdir+ ../testbench/*.v
#vlog	+incdir+ ../testbench/*.vh

#vsim -t ps -novopt +notimingchecks -L unisims_ver -L secureip -L xilinxcorelib_ver work.harness testcase_1 glbl
#vsim -t ps -novopt +notimingchecks -L unisims_ver -L secureip -L xilinxcorelib_ver work.harness testcase_2 glbl
vsim -t ps -novopt +notimingchecks -L unisims_ver -L secureip -L xilinxcorelib_ver work.harness testcase_3 glbl
#vsim -t ps -novopt +notimingchecks -L unisims_ver -L secureip -L xilinxcorelib_ver work.harness testcase_4 glbl
#vsim -t ps -novopt +notimingchecks -L unisims_ver -L secureip -L xilinxcorelib_ver work.harness testcase_5 glbl
#vsim -t ps -novopt +notimingchecks -L unisims_ver -L secureip -L xilinxcorelib_ver work.harness testcase_6 glbl
#vsim -t ps -novopt +notimingchecks -L unisims_ver -L secureip -L xilinxcorelib_ver work.harness testcase_7 glbl
#vsim -t ps -novopt +notimingchecks -L unisims_ver -L secureip -L xilinxcorelib_ver work.harness testcase_8 glbl
onerror {resume}
log -r /*

#Change radix to Hexadecimal#
radix hex
do wave.do
run -all