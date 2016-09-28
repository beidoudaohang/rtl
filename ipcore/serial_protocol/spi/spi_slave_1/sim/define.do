
##	-------------------------------------------------------------------------------------
##	���������
##	-------------------------------------------------------------------------------------
vlib	work

##	-------------------------------------------------------------------------------------
##	��������
##	��������˺���棬��Ҫ���ֲ���֮��������ļ�
##	-------------------------------------------------------------------------------------
set	SIM_MODE	"behav"
#set	SIM_MODE	"back"

##	-------------------------------------------------------------------------------------
##	���屻���Զ���
##	1.ÿһ��DUT����һ�������Ķ���
##	2.���ݱ����Զ���ѡ���Ա����ļ���ѡ���Է����ļ�
##	-------------------------------------------------------------------------------------
set TB_MODULE	"ctrl_channel"



##	-------------------------------------------------------------------------------------
##	����testcase
##	1.��������
##	-------------------------------------------------------------------------------------
#set TESTCASE	testcase_1
#set TESTCASE	testcase_2
#set TESTCASE	testcase_3
#set TESTCASE	testcase_4
set TESTCASE	testcase_5



##	-------------------------------------------------------------------------------------
##	�����ݼ�
##	-------------------------------------------------------------------------------------
alias d		"do define.do"
alias c		"do compile.do"
alias s		"do simulate.do"
alias f		"do flow.do"	
alias r		"do restart.do"
alias v		"do view.do";	##������Դ�ļ���ֱ�ӹ۲�֮ǰ�Ĳ����ļ�

alias aw	"add wave sim:/tb_$TB_MODULE/*";	##��testbench������ź�����ӵ�wave������
alias ra	"run -all";		##modelsim��ʼ���棬��û�ж������ʱ��
alias mc	".main clear";	##���transcript�ű�
alias qs	"quit -sim";	##�˳�����
alias qf	"quit -force";	##ǿ���˳�modelsim

##	-------------------------------------------------------------------------------------
##	����wave�����ļ�
##	1.ǰ�����������wave���������ǲ�һ����
##	-------------------------------------------------------------------------------------
if { $SIM_MODE == "behav" } {
	alias ww	"write format wave -window .main_pane.wave.interior.cs.body.pw.wf wave_$TB_MODULE.do"
	alias wwf	"write format wave -window .main_pane.wave.interior.cs.body.pw.wf wave_$TB_MODULE.do;do flow.do;"

} else {
	alias ww	"write format wave -window .main_pane.wave.interior.cs.body.pw.wf wave_back_$TB_MODULE.do"
	alias wwf	"write format wave -window .main_pane.wave.interior.cs.body.pw.wf wave_back_$TB_MODULE.do;do flow.do;"
}
