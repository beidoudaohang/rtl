
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



do define.do

#echo	"sim "

##--------Xilinx command--------
#vsim -t ps -novopt +notimingchecks work.tb_$TB_MODULE
#vsim -t ps -novopt +notimingchecks -L unisims_ver -L secureip work.tb_$TB_MODULE glbl
#vsim -t ps -voptargs=+acc -debugDB +notimingchecks -L unisims_ver -L secureip -L xilinxcorelib_ver work.tb_$TB_MODULE glbl
if { $SIM_MODE == "back" } {
	vsim -t ps -voptargs="+acc" +maxdelays -L unisims_ver -L simprims_ver -L secureip -lib work work.tb_$TB_MODULE glbl	
	#vcd file test.vcd
	#vcd add /tb_$TB_MODULE/top_frame_buffer_inst/*
} else {
	vsim -t ps -novopt +notimingchecks -L unisims_ver work.tb_$TB_MODULE glbl
}

##--------Lattice command--------
#vsim -t ps -novopt +notimingchecks -L machxo2 work.tb_$TB_MODULE




add wave /tb_$TB_MODULE/*


do wave_$TB_MODULE.do


onerror {resume} 
log -r /*

#Change radix to Hexadecimal#
radix hex

view library
view object
view structure


#Supress Numeric Std package and Arith package warnings.#
#For VHDL designs we get some warnings due to unknown values on some signals at startup#
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0#
#We may also get some Arithmetic packeage warnings because of unknown values on#
#some of the signals that are used in an Arithmetic operation.#
#In order to suppress these warnings, we use following two commands#
set NumericStdNoWarnings 1
set StdArithNoWarnings 1
set IgnoreWarning 1

