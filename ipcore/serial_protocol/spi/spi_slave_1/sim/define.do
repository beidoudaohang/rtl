
##	-------------------------------------------------------------------------------------
##	建立仿真库
##	-------------------------------------------------------------------------------------
vlib	work

##	-------------------------------------------------------------------------------------
##	仿真类型
##	如果定义了后仿真，需要布局布线之后的网表文件
##	-------------------------------------------------------------------------------------
set	SIM_MODE	"behav"
#set	SIM_MODE	"back"

##	-------------------------------------------------------------------------------------
##	定义被测试对象
##	1.每一个DUT都有一个独立的顶层
##	2.根据被测试对象，选择性编译文件，选择性仿真文件
##	-------------------------------------------------------------------------------------
set TB_MODULE	"ctrl_channel"



##	-------------------------------------------------------------------------------------
##	定义testcase
##	1.测试用例
##	-------------------------------------------------------------------------------------
#set TESTCASE	testcase_1
#set TESTCASE	testcase_2
#set TESTCASE	testcase_3
#set TESTCASE	testcase_4
set TESTCASE	testcase_5



##	-------------------------------------------------------------------------------------
##	定义快捷键
##	-------------------------------------------------------------------------------------
alias d		"do define.do"
alias c		"do compile.do"
alias s		"do simulate.do"
alias f		"do flow.do"	
alias r		"do restart.do"
alias v		"do view.do";	##不编译源文件，直接观察之前的波形文件

alias aw	"add wave sim:/tb_$TB_MODULE/*";	##将testbench顶层的信号名添加到wave窗口中
alias ra	"run -all";		##modelsim开始仿真，且没有定义结束时间
alias mc	".main clear";	##清除transcript脚本
alias qs	"quit -sim";	##退出仿真
alias qf	"quit -force";	##强制退出modelsim

##	-------------------------------------------------------------------------------------
##	保存wave波形文件
##	1.前仿真与后仿真的wave波形名字是不一样的
##	-------------------------------------------------------------------------------------
if { $SIM_MODE == "behav" } {
	alias ww	"write format wave -window .main_pane.wave.interior.cs.body.pw.wf wave_$TB_MODULE.do"
	alias wwf	"write format wave -window .main_pane.wave.interior.cs.body.pw.wf wave_$TB_MODULE.do;do flow.do;"

} else {
	alias ww	"write format wave -window .main_pane.wave.interior.cs.body.pw.wf wave_back_$TB_MODULE.do"
	alias wwf	"write format wave -window .main_pane.wave.interior.cs.body.pw.wf wave_back_$TB_MODULE.do;do flow.do;"
}
