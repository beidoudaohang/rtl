##-------------------------------------------------------------------------------------------------
##
##  -- 模块描述     : define.do完成两个任务
##              1)  : 定义仿真需要的参数，包括3个子内容，分别是前仿后仿，待测试模块名字，testcase序号
##
##              2)  : 建立仿真库和定义快捷键
##
##-------------------------------------------------------------------------------------------------

##	===============================================================================================
##	ref ***Please Modify Following Parameter***
##	===============================================================================================
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
#set TB_MODULE	"frame_buffer"
set TB_MODULE	"fb_gpif"

##	-------------------------------------------------------------------------------------
##	定义testcase
##	1.测试用例
##	-------------------------------------------------------------------------------------
#set TESTCASE	testcase_000
#set TESTCASE	testcase_001
#set TESTCASE	testcase_010

#set TESTCASE	testcase_210
set TESTCASE	testcase_211

##	===============================================================================================
##	ref ***Do Not Modify Following Parameter!***
##	===============================================================================================
##	-------------------------------------------------------------------------------------
##	建立仿真库
##	-------------------------------------------------------------------------------------
vlib	work

##	-------------------------------------------------------------------------------------
##	定义快捷键
##	-------------------------------------------------------------------------------------
alias d		"do define.do"
alias c		"do compile.do"
alias s		"do simulate.do"
alias f		"do flow.do"

alias r		"restart;view wave;run -all";	##不编译源文件，重新跑仿真
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
	set	WAVE_NAME	wave_$TB_MODULE.do
} else {
	set	WAVE_NAME	wave_back_$TB_MODULE.do
}

alias ww	"write format wave -window .main_pane.wave.interior.cs.body.pw.wf $WAVE_NAME"
alias wwf	"ww;f"
alias wwqf	"ww;qf"
