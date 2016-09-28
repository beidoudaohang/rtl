


#
vlib	work

set	SIM_MODE	"behav"
#set	SIM_MODE	"back"

#define which testbench should be compile and load
set TB_MODULE	"wrap_spi_master"
set TB_MODULE	"iddr2"

#define hotkey
alias d		"do define.do"
alias r		"do restart.do"
alias s		"do simulate.do"
alias c		"do compile.do"
alias g		"do go.do"
alias f		"do flow.do"
alias v		"do view.do"
alias aw	"do addwave.do"
alias qs	"quit -sim"
alias qf	"quit -force"
alias all	"run -all"
#Çå³ýtranscript½Å±¾
alias mc	".main clear"

if { $SIM_MODE == "behav" } {
	alias ww	"write format wave -window .main_pane.wave.interior.cs.body.pw.wf wave_$TB_MODULE.do"

} else {
	alias ww	"write format wave -window .main_pane.wave.interior.cs.body.pw.wf wave_back_$TB_MODULE.do"
}
