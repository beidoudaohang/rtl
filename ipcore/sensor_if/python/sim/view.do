
##	-------------------------------------------------------------------------------------
##	�����Ȱ�define.do ��һ�飬��ֹ�޸���define֮����ɴ���
##	-------------------------------------------------------------------------------------
do define.do

##	-------------------------------------------------------------------------------------
##	���wlf�ļ�
##	1.modelsimֻ��֧��wlf��ʽ�ķ����ļ�
##	2.���wlf�ļ����ڣ�û�ж���
##	3.���wlf�ļ������ڣ�vcd�ļ����ڣ���vcd�ļ�ת��Ϊwlf�ļ�
##	4.���wlf�ļ���vcd�ļ���������
##	-------------------------------------------------------------------------------------
set	wlf_vcd_exist	0
if { [file exists vsim.wlf] == 1} {
	set	wlf_vcd_exist	1
	echo "wlf file exists"
} else {
	if { [file exists $TB_MODULE.vcd] == 1} {
		set	wlf_vcd_exist	1
		vcd2wlf $TB_MODULE.vcd vsim.wlf
		echo "generate wlf file"
	} else {
		set	wlf_vcd_exist	0
		echo "no vcd or wlf file"
	}
}

##	-------------------------------------------------------------------------------------
##	��ʾ�����ļ�
##	1.�ر�wave���ڣ���ֹ��ͬһ��wave�����з������Ӳ���
##	2.�������棬ֻ�鿴����
##	3.Ĭ��16����
##	4.��wave����
##	-------------------------------------------------------------------------------------
if {$wlf_vcd_exist == 1} {
	noview wave
	vsim -view vsim.wlf -do $WAVE_NAME
	radix hex
	view wave
}