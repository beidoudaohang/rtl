
##	-------------------------------------------------------------------------------------
##	首先先把define.do 跑一遍，防止修改了define之后，造成错误
##	-------------------------------------------------------------------------------------
do define.do

##	-------------------------------------------------------------------------------------
##	检查wlf文件
##	1.modelsim只能支持wlf格式的仿真文件
##	2.如果wlf文件存在，没有动作
##	3.如果wlf文件不存在，vcd文件存在，将vcd文件转换为wlf文件
##	4.如果wlf文件和vcd文件都不存在
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
##	显示波形文件
##	1.关闭wave窗口，防止在同一个wave窗口中反复添加波形
##	2.启动仿真，只查看波形
##	3.默认16进制
##	4.打开wave窗口
##	-------------------------------------------------------------------------------------
if {$wlf_vcd_exist == 1} {
	noview wave
	vsim -view vsim.wlf -do wave_$TB_MODULE.do
	radix hex
	view wave
}
