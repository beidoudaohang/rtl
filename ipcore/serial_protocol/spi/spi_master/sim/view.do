
do define.do

if { [file exists vsim.wlf] == 1} {
	echo "wlf file exists"
} else {
	if { [file exists $TB_MODULE.vcd] == 1} {
		vcd2wlf $TB_MODULE.vcd vsim.wlf
		echo "generate wlf file"
	} else {
		echo "no vcd or wlf file"
	}
}




noview wave
vsim -view vsim.wlf -do wave_$TB_MODULE.do
radix hex
view wave

