

##	===============================================================================================
##	ref ***׼������***
##	===============================================================================================
##	-------------------------------------------------------------------------------------
##	�����Ȱ�define.do ��һ��
##	-------------------------------------------------------------------------------------
do define.do
echo	"simulation start ******"

##	-------------------------------------------------------------------------------------
##	���õ�������
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
##	���õķ�������
##	-------------------------------------------------------------------------------------
##--------Xilinx command--------
#vsim -t ps -novopt +notimingchecks work.tb_$TB_MODULE
#vsim -t ps -novopt +notimingchecks -L unisims_ver -L secureip work.tb_$TB_MODULE glbl
#vsim -t ps -voptargs=+acc -debugDB +notimingchecks -L unisims_ver -L secureip -L xilinxcorelib_ver work.tb_$TB_MODULE glbl
##--------Lattice command--------
#vsim -t ps -novopt +notimingchecks -L machxo2 work.tb_$TB_MODULE


##	===============================================================================================
##	ref ***��������***
##	===============================================================================================
##	-------------------------------------------------------------------------------------
##	ǰ����������������ǲ�ͬ��
##	1.������ʱ��vcd�ļ�������testbench�в�����Ҳ������do�ļ��в���
##	-------------------------------------------------------------------------------------
if { $SIM_MODE == "back" } {
	#	vsim -t ps -voptargs="+acc" +maxdelays -L unisims_ver -L simprims_ver -L secureip -lib work work.tb_$TB_MODULE glbl
	#	vsim -t ps -novopt +notimingchecks +maxdelays -L unisims_ver -L simprims_ver -L secureip -L xilinxcorelib_ver -lib work work.tb_$TB_MODULE glbl
	#	vcd file test.vcd
	#	vcd add /tb_$TB_MODULE/top_frame_buffer_inst/*

} else {
	vsim -t ns -novopt +notimingchecks -L unisims_ver -L secureip -L xilinxcorelib_ver work.glbl $TESTCASE\
	driver_mt9p031
}

##	-------------------------------------------------------------------------------------
##	�½������ļ�
##	1.ǰ����ͺ����Ĳ����ļ����ֲ�һ��
##	2.����ļ��������ڣ�˵���ǵ�һ�η��棬��ʹ��ģ��Ĳ����ļ��½�һ��
##	3.����ļ������ڣ�˵�����ǵ�һ�η��棬û�ж���
##	-------------------------------------------------------------------------------------
if { $SIM_MODE == "behav" } {
	if { [file exists wave_$TB_MODULE.do] == 1} {
		echo "wave do file exists"
	} else {
		file copy wave.do wave_$TB_MODULE.do
		echo "wave do file does not exist"
	}

} else {
	if { [file exists wave_back_$TB_MODULE.do] == 1} {
		echo "wave do file exists"
	} else {
		file copy wave.do wave_back_$TB_MODULE.do
		echo "wave do file does not exist"
	}
}

##	-------------------------------------------------------------------------------------
##	modelsim�ĳ�ʼ����
##	1.����������󣬲�ֹͣ������
##	2.��¼ȫ���ı���
##	-------------------------------------------------------------------------------------
onerror {resume}
log -r /*

##	-------------------------------------------------------------------------------------
##	wave�ĳ�ʼ����
##	1.����Ĭ����ʾ��16����
##	-------------------------------------------------------------------------------------
radix hex

##	-------------------------------------------------------------------------------------
##	�򿪳�ʼ�Ĵ���
##	-------------------------------------------------------------------------------------
view library
view object
view structure
