##-------------------------------------------------------------------------------------------------
##
##  -- ģ������     : compile.do���Դ��������������Ҫ��Ϊ3���׶�
##              1)  : ׼���׶Σ��Ȱ�define.do��һ�ߣ�����Ƿ��Ǻ���棬�˴������޸�
##
##              2)  : ���ݱ�����ģ�飬������Ҫ�����Դ����
##
##              3)  : �����ļ����ļ�����4�����ͣ�����(1)Դ���롢(2)����ģ�͡�(3)testbench���Դ��롢(4)���õĲ��Դ���
##						�û���Ҫ�޸��ⲿ��
##
##-------------------------------------------------------------------------------------------------

##	===============================================================================================
##	ref ***׼�������������޸�***
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

##	===============================================================================================
##	ref ***������Ҫ�����ģ��***
##	===============================================================================================
##	-------------------------------------------------------------------------------------
##	����
##	1.��������˺���棬�����Ҫ�÷���par�������ɵ�.v�ļ�
##	2.������Ǻ���棬����Ҫ���ݲ�����ѡ����Ҫ��Դ�ļ�
##	-------------------------------------------------------------------------------------
set	global_para		1

set	clock_reset		0
set	ctrl_channel	0
set	io_channel		0

set	data_channel	0
set	hispi_if_new	0
set	u3v_format		0
set	frame_buffer	0
set	u3_interface	0

set	top				0

set	spi_master		0
set	ddr3			0
set	hispi			0
set	gpif_3014		0




if {$SIM_MODE == "back" } {
	set	spi_master		1
	set	ddr3			1
	set	hispi			1
	set	gpif_3014		1
} else {
	if {$TB_MODULE == "mer" } {
		set	clock_reset		1
		set	ctrl_channel	1
		set	io_channel		1

		set	data_channel	1
		set	u3v_format		1
		set	frame_buffer	1
		set	u3_interface	1

		set	top				1

		set	spi_master		1
		set	ddr3			1
		set	hispi			1
		set	gpif_3014		1
	} elseif {$TB_MODULE == "deser_hispi" } {

		set	data_channel	1
		set	hispi			1
		set	clock_reset		1

	} elseif {$TB_MODULE == "deser_word_align" } {
		set	hispi_if_new	1
		set	hispi			1
	} elseif {$TB_MODULE == "deser_hispi_if_new" } {
		set	hispi_if_new	1
		set	hispi			1
	} else {
		set	ctrl_channel	1
	}
}
file copy ../src/ctrl_channel/i2c_top/trigger_cmd_ram/trigger_cmd_ram.mif 	../sim
##	===============================================================================================
##	ref ***��ʼ����***
##	===============================================================================================
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
##	clock_reset ģ��
##	-------------------------------------------------------------------------------------
if { $clock_reset == 1 } {
	vlog	../src/clock_reset/*.v
}

##	-------------------------------------------------------------------------------------
##	ctrl_channel ģ��
##	-------------------------------------------------------------------------------------
if { $ctrl_channel == 1 } {
	##	-------------------------------------------------------------------------------------
	##	����ͨ��ͨ��ģ��
	##	-------------------------------------------------------------------------------------
	vlog	../src/ctrl_channel/*.v

	##	-------------------------------------------------------------------------------------
	##	����ͨ��ͨ��ģ��
	##	-------------------------------------------------------------------------------------
	vlog	../src/ctrl_channel/i2c_top/*.v
	vlog	../src/ctrl_channel/i2c_top/continuous_cmd_fifo/*.v
	vlog	../src/ctrl_channel/i2c_top/i2c_master_wb_top/*.v
	vlog	+incdir+../src/ctrl_channel/i2c_top/trigger_cmd_ram		../src/ctrl_channel/i2c_top/trigger_cmd_ram/*.v
}

##	-------------------------------------------------------------------------------------
##	io_channel ģ��
##	-------------------------------------------------------------------------------------
if { $io_channel == 1 } {
	vlog	../src/io_channel/*.v
	vlog	../src/io_channel/test/*.v
}

##	-------------------------------------------------------------------------------------
##	data_channel ģ��
##	-------------------------------------------------------------------------------------
if { $data_channel == 1 } {

	##	-------------------------------------------------------------------------------------
	##	hispi_if_new ģ��
	##	-------------------------------------------------------------------------------------
	vlog	../src/data_channel/hispi_if_quick/*.v

	##	-------------------------------------------------------------------------------------
	##	deser ģ��
	##	-------------------------------------------------------------------------------------
	vlog	../src/data_channel/deser/*.v

	##	-------------------------------------------------------------------------------------
	##	pll_reset ģ��
	##	-------------------------------------------------------------------------------------
	vlog	../src/data_channel/pll_reset.v

	##	-------------------------------------------------------------------------------------
	##	sync_bufferr ģ��
	##	-------------------------------------------------------------------------------------
	vlog	../src/data_channel/sync_buffer/*.v
	vlog	../src/data_channel/sync_buffer/fifo_bram/*.v
	vlog	../src/data_channel/sync_buffer/fifo_dram/*.v

	##	-------------------------------------------------------------------------------------
	##	raw_wb ģ��
	##	-------------------------------------------------------------------------------------
	vlog	../src/data_channel/raw_wb/*.v
	vlog	../src/data_channel/raw_wb/wb_mult/wb_mult_a17b17p34.v

	##	-------------------------------------------------------------------------------------
	##	grey_statistics ģ��
	##	-------------------------------------------------------------------------------------
	vlog	../src/data_channel/grey_statistics/*.v

	vlog	../src/data_channel/*.v

}


##	-------------------------------------------------------------------------------------
##	hispi_if_new ģ��
##	-------------------------------------------------------------------------------------
if { $hispi_if_new == 1 } {
	##	-------------------------------------------------------------------------------------
	##	hispi_if_new ģ��
	##	-------------------------------------------------------------------------------------
	vlog	../src/data_channel/hispi_if_quick/*.v

	##	-------------------------------------------------------------------------------------
	##	deser ģ��
	##	-------------------------------------------------------------------------------------
	vlog	../src/data_channel/deser/*.v

	##	-------------------------------------------------------------------------------------
	##	pll_reset ģ��
	##	-------------------------------------------------------------------------------------
	vlog	../src/data_channel/pll_reset.v

}


##	-------------------------------------------------------------------------------------
##	u3v_format ģ��
##	-------------------------------------------------------------------------------------
if { $u3v_format == 1 } {
	vlog	../src/u3v_format/*.v
	vlog	../src/u3v_format/adder/*.v
}

##	-------------------------------------------------------------------------------------
##	frame_buffer ģ��
##	-------------------------------------------------------------------------------------
if { $frame_buffer == 1 } {
	vlog	../src/frame_buffer/*.v
	vlog	../src/frame_buffer/fifo_w64d256_pf180_pe6/fifo_w64d256_pf180_pe6.v
	vlog	../src/frame_buffer/fifo_w65d256_pf180_pe6/fifo_w65d256_pf180_pe6.v
	vlog	../src/frame_buffer/mig_core/ip/mig_core/user_design/rtl/mig_core.v
	vlog	../src/frame_buffer/mig_core/ip/mig_core/user_design/rtl/memc_wrapper.v
	vlog	../src/frame_buffer/mig_core/ip/mig_core/user_design/rtl/mcb_controller/*.v
}

##	-------------------------------------------------------------------------------------
##	u3_interface ģ��
##	-------------------------------------------------------------------------------------
if { $u3_interface == 1 } {
	vlog	../src/u3_interface/*.v
	vlog	../src/u3_interface/u3_transfer/*.v
	vlog	../src/u3_interface/u3_transfer/urb_mult/urb_mult.v
}

##	-------------------------------------------------------------------------------------
##	top ģ��
##	-------------------------------------------------------------------------------------
if { $top == 1 } {
	vlog	../src/*.v
}


##	-------------------------------------------------------------------------------------
##	�����������ɵ�ʱ���ļ�
##	-------------------------------------------------------------------------------------
if {$SIM_MODE == "back" } {
	vlog	"netgen/par/mer_1520_13u3x_timesim.v"
}

##	-------------------------------------------------------------------------------------
##	ref 2.�������ģ��
##	-------------------------------------------------------------------------------------

##	-------------------------------------------------------------------------------------
##	spi
##	-------------------------------------------------------------------------------------
if {$spi_master == 1 } {
	vlog	+define+TESTCASE=$TESTCASE	../testbench/spi_master/*.v
	vlog	+define+TESTCASE=$TESTCASE	../testbench/spi_master/distri_fifo_w9d32/distri_fifo_w9d32.v
}

##	-------------------------------------------------------------------------------------
##	Sensor hispi ����ģ��
##	-------------------------------------------------------------------------------------
if { $hispi == 1 } {
	vlog	+define+TESTCASE=$TESTCASE	../testbench/hispi/*.v
}

##	-------------------------------------------------------------------------------------
##	ddr3
##	-------------------------------------------------------------------------------------
if { $ddr3 == 1 } {
	vlog	+incdir+../testbench/ddr3_model +define+x1Gb +define+sg15E +define+x16 ../testbench/ddr3_model/ddr3_model_c3.v
	vlog	../testbench/ddr3_model/monitor_ddr3.v
}

##	-------------------------------------------------------------------------------------
##	gpif_3014
##	-------------------------------------------------------------------------------------
if { $gpif_3014 == 1 } {
	vlog	../testbench/gpif_3014/*.v
}


##	-------------------------------------------------------------------------------------
##	ref 3.������Դ���
##	-------------------------------------------------------------------------------------
vlog	+define+TESTCASE=$TESTCASE	../testbench/tb_$TB_MODULE/*.v

##	-------------------------------------------------------------------------------------
##	ref 4.����ȫ�ֲ����ļ�
##	-------------------------------------------------------------------------------------
if { $global_para == 1 } {
	vlog	+define+TESTCASE=$TESTCASE	../testbench/global/*.v
}
