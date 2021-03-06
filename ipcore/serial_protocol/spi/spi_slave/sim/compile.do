
##	===============================================================================================
##	ref ***准备工作***
##	===============================================================================================
##	-------------------------------------------------------------------------------------
##	首先先把define.do 跑一遍，防止修改了define之后，造成错误
##	-------------------------------------------------------------------------------------
do define.do
echo	"compile start ******"

##	-------------------------------------------------------------------------------------
##	如果定义了后仿真，首先把netgen目录下清空，然后再把工程目录下的netgen目录复制过来
##	-------------------------------------------------------------------------------------
if {$SIM_MODE == "back" } {
	file delete -force netgen
	file copy ../prj/netgen	../sim
}

##	-------------------------------------------------------------------------------------
##	常用的compile的语法
##	1.+incdir+ 包含头文件的路径
##	2.+define+MACRO[=NAME]	宏定义
##	-------------------------------------------------------------------------------------
#vlog	$env(XILINX)/verilog/src/glbl.v
#vlog	../testbench/tb_bram.v
#vlog	+incdir+../src	+incdir+../testbench	+define+SIMULATION	../src/*.v
#vlog	+incdir+../testbench +define+x1Gb +define+sg187E +define+x16 ../testbench/ddr3_model_c3.v

##	-------------------------------------------------------------------------------------
##	编译
##	1.如果定义了后仿真，则必须要用仿真par工具生成的.v文件
##	2.如果不是后仿真，则需要根据参数，选择需要的源文件
##	-------------------------------------------------------------------------------------
set	global_para		0
set	ctrl_channel	0
set	spi_master		0

if {$SIM_MODE == "back" } {
	set	spi_master		1
} else {
	if {$TB_MODULE == "ctrl_channel" } {
		set	ctrl_channel	1
		set	spi_master		1
	} else {
		set	ctrl_channel	1
	}
}



##	===============================================================================================
##	ref ***开始编译***
##	===============================================================================================
##	-------------------------------------------------------------------------------------
##	xilinx的很多ip需要glbl文件才能仿真
##	-------------------------------------------------------------------------------------
vlog	$env(XILINX)/verilog/src/glbl.v

##	-------------------------------------------------------------------------------------
##	根据不同的DUT，compile不同的文件
##	-------------------------------------------------------------------------------------
##	-------------------------------------------------------------------------------------
##	ref 1.编译源代码
##	-------------------------------------------------------------------------------------
##	-------------------------------------------------------------------------------------
##	ctrl_channel 模块
##	-------------------------------------------------------------------------------------
if { $ctrl_channel == 1 } {
	vlog	../src/*.v
}

##	-------------------------------------------------------------------------------------
##	编译后仿真生成的时序文件
##	-------------------------------------------------------------------------------------
if {$SIM_MODE == "back" } {
	vlog	"netgen/par/top_frame_buffer_timesim.v"
}

##	-------------------------------------------------------------------------------------
##	ref 2.编译仿真模型
##	-------------------------------------------------------------------------------------
if {$spi_master == 1 } {
	vlog	+define+TESTCASE=$TESTCASE	../testbench/spi_master/*.v
	vlog	+define+TESTCASE=$TESTCASE	../testbench/spi_master/distri_fifo_w9d32/distri_fifo_w9d32.v
}
##	-------------------------------------------------------------------------------------
##	ref 3.编译测试代码
##	-------------------------------------------------------------------------------------
vlog	+define+TESTCASE=$TESTCASE	../testbench/tb_$TB_MODULE/*.v

##	-------------------------------------------------------------------------------------
##	ref 3.编译全局测试文件
##	-------------------------------------------------------------------------------------
if { $global_para == 1 } {
	vlog	+define+TESTCASE=$TESTCASE	../testbench/global/*.v
}

