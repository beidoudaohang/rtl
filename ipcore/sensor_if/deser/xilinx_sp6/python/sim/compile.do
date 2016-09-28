##-------------------------------------------------------------------------------------------------
##
##  -- 模块描述     : compile.do完成源代码编译的任务，主要分为3个阶段
##              1)  : 准备阶段，先把define.do跑一边，检查是否是后仿真，此处不能修改
##
##              2)  : 根据被测试模块，定义需要仿真的源代码
##
##              3)  : 编译文件，文件共有4中类型，包括(1)源代码、(2)仿真模型、(3)testbench测试代码、(4)共用的测试代码
##						用户需要修改这部分
##
##-------------------------------------------------------------------------------------------------

##	===============================================================================================
##	ref ***准备工作，不能修改***
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


##	===============================================================================================
##	ref ***定义需要仿真的模块***
##	===============================================================================================
##	-------------------------------------------------------------------------------------
##	编译
##	1.如果定义了后仿真，则必须要用仿真par工具生成的.v文件
##	2.如果不是后仿真，则需要根据参数，选择需要的源文件
##	-------------------------------------------------------------------------------------
set	global_para		0

set	sync_buffer		0
set	pulse_filter	0


set	python			0
set	mt9p031			0
set	spi_master		0
set	ddr3			0
set	hispi			0
set	gpif_3014		0



if {$SIM_MODE == "back" } {
	if {$TB_MODULE == "sync_buffer" } {
		set	mt9p031			1
	} elseif {$TB_MODULE == "pulse_filter" } {
		set	spi_master		0
	} else {
		set	ddr3			0
	}
} else {
	if {$TB_MODULE == "deser_python" } {
		set	deser			1
		set	python_if		1

		set	python			1
	} elseif {$TB_MODULE == "pulse_filter" } {
		set	pulse_filter	1
		set	mt9p031			1
	} else {
		set	mt9p031			1
	}

}

##	===============================================================================================
##	ref ***开始编译***
##	===============================================================================================
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
##	deser 模块
##	-------------------------------------------------------------------------------------
if { $deser == 1 } {
	vlog	../src/deser/*.v
}
##	-------------------------------------------------------------------------------------
##	python_if 模块
##	-------------------------------------------------------------------------------------
if { $python_if == 1 } {
	vlog	../src/python_if/*.v
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
##	-------------------------------------------------------------------------------------
##	Sensor python 仿真模型
##	-------------------------------------------------------------------------------------
if { $python == 1 } {
	vlog	+define+TESTCASE=$TESTCASE	../testbench/python/*.v
	vlog	+define+TESTCASE=$TESTCASE	../testbench/python/mt9p031_ch/*.v
	vlog	+define+TESTCASE=$TESTCASE	../testbench/python/python_core/*.v
}

##	-------------------------------------------------------------------------------------
##	ref 3.编译测试代码
##	-------------------------------------------------------------------------------------
vlog	+define+TESTCASE=$TESTCASE	../testbench/tb_$TB_MODULE/*.v

##	-------------------------------------------------------------------------------------
##	ref 4.编译全局测试文件
##	-------------------------------------------------------------------------------------
if { $global_para == 1 } {
	vlog	+define+TESTCASE=$TESTCASE	../testbench/global/*.v
}

