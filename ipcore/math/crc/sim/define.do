


#
vlib	work

set	SIM_MODE	"behav"
#set	SIM_MODE	"back"

#define which testbench should be compile and load
set TB_MODULE	"example"

#define hotkey
alias d		"do define.do"
alias r		"do restart.do"
alias s		"do simulate.do"
alias c		"do compile.do"
alias g		"do go.do"
alias f		"do first.do"
alias v		"do view.do"
alias aw	"do addwave.do"
alias qs	"quit -sim"
alias qf	"quit -force"
alias all	"run -all"
alias ww	"write format wave -window .main_pane.wave.interior.cs.body.pw.wf wave_$TB_MODULE.do"

if { [file exists wave_$TB_MODULE.do] == 1} {
	echo "wave do file exists"
} else {
	#open wave_$TB_MODULE.do w+
	file copy wave.do wave_$TB_MODULE.do
	
	echo "wave do file does not exist"
	
}

