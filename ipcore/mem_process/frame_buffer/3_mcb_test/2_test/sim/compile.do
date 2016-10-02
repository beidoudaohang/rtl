
##	===============================================================================================
##	ref ***׼������***
##	===============================================================================================
##	-------------------------------------------------------------------------------------
##	�����Ȱ�define.do ��һ�飬��ֹ�޸���define֮����ɴ���
##	-------------------------------------------------------------------------------------
do define.do
echo	"compile start ******"

##	-------------------------------------------------------------------------------------
##	��������˺���棬���Ȱ�netgenĿ¼����գ�Ȼ���ٰѹ���Ŀ¼�µ�netgenĿ¼���ƹ���
##	-------------------------------------------------------------------------------------
if {$SIM_MODE == "back" } {
	file delete -force netgen
	file copy ../prj/netgen	../sim
}

##	-------------------------------------------------------------------------------------
##	���õ�compile���﷨
##	1.+incdir+ ����ͷ�ļ���·��
##	2.+define+MACRO[=NAME]	�궨��
##	-------------------------------------------------------------------------------------
#vlog	$env(XILINX)/verilog/src/glbl.v
#vlog	../testbench/tb_bram.v
#vlog	+incdir+../src	+incdir+../testbench	+define+SIMULATION	../src/*.v
#vlog	+incdir+../testbench +define+x1Gb +define+sg187E +define+x16 ../testbench/ddr3_model_c3.v

##	-------------------------------------------------------------------------------------
##	���ݲ���������Ҫ������ЩԴ�ļ�
##	-------------------------------------------------------------------------------------
set	frame_buffer	0

set	ddr3			0
set	clock_reset		0
set	mt9p031			0

if {$TB_MODULE == "frame_buffer" } {
	set	frame_buffer	1
	set	ddr3			1
	set	clock_reset		1
	set	mt9p031			1
} elseif {$TB_MODULE == "" } {

}


##	===============================================================================================
##	ref ***��ʼ����***
##	===============================================================================================
##	-------------------------------------------------------------------------------------
##	xilinx�ĺܶ�ip��Ҫglbl�ļ����ܷ���
##	-------------------------------------------------------------------------------------
vlog	$env(XILINX)/verilog/src/glbl.v

##	-------------------------------------------------------------------------------------
##	���ݲ�ͬ��DUT��compile��ͬ���ļ�
##	-------------------------------------------------------------------------------------
##	-------------------------------------------------------------------------------------
##	ref 1.����Դ����
##	-------------------------------------------------------------------------------------
##	-------------------------------------------------------------------------------------
##	frame bufferģ��
##	-------------------------------------------------------------------------------------
if { $frame_buffer == 1 } {
	vlog	../src/frame_buffer/*.v
	vlog	../src/frame_buffer/blockram_core/fifo_w36d256_pf180_pe6.v
	vlog	../src/frame_buffer/mig_core/mig_core/user_design/rtl/*.v
	vlog	../src/frame_buffer/mig_core/mig_core/user_design/rtl/mcb_controller/*.v
}
#} elseif {$pulse_filter == 1 } {
#	vlog	../src/pulse_filter/*.v
#	vlog	../src/pulse_filter/pulse_filter_ram/pulse_filter_ram_w10d3072.v
#}

##	-------------------------------------------------------------------------------------
##	ref 2.�������ģ��
##	-------------------------------------------------------------------------------------
##	-------------------------------------------------------------------------------------
##	Sensor mt9p031 ����ģ��
##	-------------------------------------------------------------------------------------
if { $mt9p031 == 1 } {
	vlog	+define+TESTCASE=$TESTCASE	../testbench/mt9p031/*.v
}

##	-------------------------------------------------------------------------------------
##	clock reset
##	-------------------------------------------------------------------------------------
if { $clock_reset == 1 } {
	vlog	+define+TESTCASE=$TESTCASE	../testbench/clock_reset/*.v
	vlog	../src/clock_reset/*.v
}

##	-------------------------------------------------------------------------------------
##	ddr3
##	-------------------------------------------------------------------------------------
if { $ddr3 == 1 } {
	vlog	+incdir+../testbench/ddr3_model +define+x1Gb +define+sg15E +define+x16 ../testbench/ddr3_model/ddr3_model_c3.v
	vlog	../testbench/ddr3_model/monitor_ddr3.v
}

##	-------------------------------------------------------------------------------------
##	ref 3.������Դ���
##	-------------------------------------------------------------------------------------
vlog	+define+TESTCASE=$TESTCASE	../testbench/tb_$TB_MODULE/*.v


#	##	===============================================================================================
#	##	test code
#	##	===============================================================================================
#	##	-------------------------------------------------------------------------------------
#	##	test code
#	##	-------------------------------------------------------------------------------------
#	vlog	../testbench/sync_buffer/*.v
#}
#

#
#
#} elseif {$TB_MODULE == "mer" } {
#	##	===============================================================================================
#	##	DUT
#	##	===============================================================================================
#	##	-------------------------------------------------------------------------------------
#	##	top
#	##	-------------------------------------------------------------------------------------
#	vlog	../src/*.v
#
#	##	-------------------------------------------------------------------------------------
#	##	clock_reset
#	##	-------------------------------------------------------------------------------------
#	vlog	../src/clock_reset/*.v
#
#	##	-------------------------------------------------------------------------------------
#	##	io_channel
#	##	-------------------------------------------------------------------------------------
#	vlog	../src/io_channel/*.v
#
#	##	-------------------------------------------------------------------------------------
#	##	ctrl_channel
#	##	-------------------------------------------------------------------------------------
#	vlog	../src/ctrl_channel/*.v
#
#	##	-------------------------------------------------------------------------------------
#	##	data_channel
#	##	-------------------------------------------------------------------------------------
#	vlog	../src/data_channel/*.v
#	vlog	../src/data_channel/grey_statistics/*.v
#	vlog	../src/data_channel/pulse_filter/*.v
#	vlog	../src/data_channel/pulse_filter/pulse_filter_ram/pulse_filter_ram_w10d3072.v
#	vlog	../src/data_channel/raw_wb/*.v
#	vlog	../src/data_channel/raw_wb/wb_mult/wb_mult_a17b17p34.v
#	vlog	../src/data_channel/sync_buffer/*.v
#	vlog	../src/data_channel/sync_buffer/fifo_bram/sync_buffer_fifo_bram_w18d16.v
#	vlog	../src/data_channel/sync_buffer/fifo_dram/sync_buffer_fifo_dram_w18d16.v
#
#	##	-------------------------------------------------------------------------------------
#	##	u3v_format
#	##	-------------------------------------------------------------------------------------
#	vlog	../src/u3v_format/*.v
#
#	##	-------------------------------------------------------------------------------------
#	##	frame buffer
#	##	-------------------------------------------------------------------------------------
#	vlog	../src/frame_buffer/*.v
#	vlog	../src/frame_buffer/blockram_core/fifo_w36d256_pf180_pe6.v
#	vlog	../src/frame_buffer/mig_core/mig_core/user_design/rtl/*.v
#	vlog	../src/frame_buffer/mig_core/mig_core/user_design/rtl/mcb_controller/*.v
#
#	##	-------------------------------------------------------------------------------------
#	##	u3_interface
#	##	-------------------------------------------------------------------------------------
#	vlog	../src/u3_interface/*.v
#	vlog	../src/u3_interface/u3_transfer/*.v
#	vlog	../src/u3_interface/u3_transfer/urb_mult/urb_mult.v
#
#	##	===============================================================================================
#	##	test code
#	##	===============================================================================================
#	##	-------------------------------------------------------------------------------------
#	##	sim model
#	##	-------------------------------------------------------------------------------------
#	vlog	../testbench/mt9p031/*.v
#	vlog	../testbench/spi_master/*.v
#	vlog	../testbench/spi_master/distri_fifo_w9d32/distri_fifo_w9d32.v
#
#	vlog	+incdir+../testbench/ddr3_model	+define+x1Gb +define+sg15E +define+x16 ../testbench/ddr3_model/*v
#
#	##	-------------------------------------------------------------------------------------
#	##	test code
#	##	-------------------------------------------------------------------------------------
#	vlog	../testbench/*.v
#
#
#} elseif {$TB_MODULE == "" } {
#	#��������˺���棬�����Ҫ����par�������ɵ�.v�ļ�
#	if {$SIM_MODE == "back" } {
#		vlog	"netgen/par/top_frame_buffer_timesim.v"
#	} else {
#
#	}
#} else {
#	echo	"ERROR compile no ***********"
#}