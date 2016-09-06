##-------------------------------------------------------------------------------------------------
##
##  -- 模块描述     : simulate.do完成启动仿真的任务
##              1)  : 准备阶段，先把define.do跑一边
##
##              2)  : 启动仿真，根据不同的被测模块，仿真命令可能要微调
##
##              3)  : 仿真固定命令，不要修改
##
##-------------------------------------------------------------------------------------------------

##	===============================================================================================
##	ref ***准备工作***
##	===============================================================================================
##	-------------------------------------------------------------------------------------
##	首先先把define.do 跑一遍
##	-------------------------------------------------------------------------------------
do define.do
echo	"simulation start ******"

##	-------------------------------------------------------------------------------------
##	常用的器件库
##	-------------------------------------------------------------------------------------
##--------xilinx lib--------
#cpld
#cpld_ver
#edk
#secureip
#simprim
#simprims_ver
#uni9000_ver
#unimacro
#unimacro_ver
#unisim
#unisims_ver
#xilinxcorelib
#xilinxcorelib_ver

##--------lattice lib--------
#machxo2
#sc
#lptm
#pmi
#scm

##	-------------------------------------------------------------------------------------
##	常用的仿真命令
##	-------------------------------------------------------------------------------------
##--------Xilinx command--------
#vsim -t ps -novopt +notimingchecks work.tb_$TB_MODULE
#vsim -t ps -novopt +notimingchecks -L unisims_ver -L secureip work.tb_$TB_MODULE glbl
#vsim -t ps -voptargs=+acc -debugDB +notimingchecks -L unisims_ver -L secureip -L xilinxcorelib_ver work.tb_$TB_MODULE glbl
##--------Lattice command--------
#vsim -t ps -novopt +notimingchecks -L machxo2 work.tb_$TB_MODULE

##	===============================================================================================
##	ref ***启动仿真，根据不同的被测模块，仿真命令可能要微调***
##	===============================================================================================
##	-------------------------------------------------------------------------------------
##	前仿真与后仿真的命令是不同的
##	1.后仿真的时候，vcd文件可以在testbench中产生，也可以在do文件中产生
##	-------------------------------------------------------------------------------------
if { $SIM_MODE == "back" } {
	#	vsim -t ps -voptargs="+acc" +maxdelays -L unisims_ver -L simprims_ver -L secureip -lib work work.tb_$TB_MODULE glbl
	#	vsim -t ps -novopt +notimingchecks +maxdelays -L unisims_ver -L simprims_ver -L secureip -L xilinxcorelib_ver -lib work work.tb_$TB_MODULE glbl
	#	vcd file test.vcd
	#	vcd add /tb_$TB_MODULE/top_frame_buffer_inst/*

	if { $TB_MODULE == "sync_buffer"} {
		vsim -t ps -novopt +notimingchecks +maxdelays -L unisims_ver -L simprims_ver -L secureip -L xilinxcorelib_ver -lib work work.glbl harness $TESTCASE\
		driver_mt9p031
	} elseif {$TB_MODULE == "pulse_filter"} {
		vsim -t ps -novopt +notimingchecks +maxdelays -L unisims_ver -L simprims_ver -L secureip -L xilinxcorelib_ver -lib work work.glbl harness $TESTCASE\
		driver_mt9p031
	} else {

	}

} else {
	if {$TB_MODULE == "two_fifo" || $TB_MODULE == "sync_fifo_srl"} {
		vsim -t ps -novopt +notimingchecks -L unisims_ver -lib work work.glbl harness $TESTCASE
	} elseif {$TB_MODULE == "pulse_filter" } {
		vsim -t ns -novopt +notimingchecks -L unisims_ver -L secureip -L xilinxcorelib_ver work.glbl harness $TESTCASE monitor\
		driver_mt9p031
	} else {
	}

}

##	===============================================================================================
##	ref ***仿真固定命令，不要修改***
##	===============================================================================================
##	-------------------------------------------------------------------------------------
##	新建波形文件
##	1.前仿真和后仿真的波形文件名字不一样
##	2.如果文件名不存在，说明是第一次仿真，则使用模板的波形文件新建一个
##	3.如果文件名存在，说明不是第一次仿真，没有动作
##	-------------------------------------------------------------------------------------
if { [file exists $WAVE_NAME] == 1} {
	echo "wave do file exists"
} else {
	file copy wave.do $WAVE_NAME
	echo "wave do file does not exist"
}

##	-------------------------------------------------------------------------------------
##	modelsim的初始设置
##	1.如果遇到错误，不停止，继续
##	2.记录全部的变量
##	-------------------------------------------------------------------------------------
onerror {resume}
log -r /*

##	-------------------------------------------------------------------------------------
##	wave的初始设置
##	1.数据默认显示是16进制
##	-------------------------------------------------------------------------------------
radix hex

##	-------------------------------------------------------------------------------------
##	打开初始的窗口
##	-------------------------------------------------------------------------------------
view library
view object
view structure
