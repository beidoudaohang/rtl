//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : bfm
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/4/8 11:28:42	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
`define		TESTCASE	testcase_1
module bfm (
	input			i_fval	,
	input			i_lval
	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	�̶�����
	//	-------------------------------------------------------------------------------------
	parameter	NUM_DQ_PINS				= `TESTCASE.NUM_DQ_PINS			;
	parameter	MEM_BANKADDR_WIDTH      = `TESTCASE.MEM_BANKADDR_WIDTH	;
	parameter	MEM_ADDR_WIDTH          = `TESTCASE.MEM_ADDR_WIDTH		;
	parameter	DDR3_MEMCLK_FREQ        = `TESTCASE.DDR3_MEMCLK_FREQ	;
	parameter	MEM_ADDR_ORDER          = `TESTCASE.MEM_ADDR_ORDER		;
	parameter	SKIP_IN_TERM_CAL        = `TESTCASE.SKIP_IN_TERM_CAL	;
	parameter	DDR3_MEM_DENSITY        = `TESTCASE.DDR3_MEM_DENSITY	;
	parameter	DDR3_TCK_SPEED          = `TESTCASE.DDR3_TCK_SPEED		;
	parameter	DDR3_SIMULATION         = `TESTCASE.DDR3_SIMULATION		;
	parameter	DDR3_CALIB_SOFT_IP      = `TESTCASE.DDR3_CALIB_SOFT_IP	;
	parameter	DATA_WIDTH              = `TESTCASE.DATA_WIDTH			;
	parameter	PTR_WIDTH               = `TESTCASE.PTR_WIDTH			;
	parameter	FRAME_SIZE_WIDTH        = `TESTCASE.FRAME_SIZE_WIDTH	;
	parameter	TERRIBLE_TRAFFIC        = `TESTCASE.TERRIBLE_TRAFFIC	;
	parameter	DDR3_16_DQ_MCB_8_DQ		= `TESTCASE.DDR3_16_DQ_MCB_8_DQ	;

	parameter	TESTCASE_NUM			= `TESTCASE.TESTCASE_NUM	;

	//	-------------------------------------------------------------------------------------
	//	�����ź�
	//	-------------------------------------------------------------------------------------	
	reg		[PTR_WIDTH-1:0]				iv_frame_depth			;
	reg									i_start_full_frame		= 1'b1;
	reg									i_start_quick			= 1'b1;
	wire	[FRAME_SIZE_WIDTH-1:0]		frame_size_byte			;
	wire	[FRAME_SIZE_WIDTH-1:0]		iv_frame_size			;
	reg									i_chunk_mode_active		= 1'b0;
	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***֡�� task***
	//  ===============================================================================================
	task frame_depth;
		input	[PTR_WIDTH-1:0]		iv_frame_depth_input;
		begin
			#10
			iv_frame_depth	= iv_frame_depth_input;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	֡���С
	//	�ǰ����ֽ�����ģ�Ҫ��ȥleader ��trailer�ĳ���
	//	-------------------------------------------------------------------------------------
	assign	frame_size_byte		= (driver_mt9p031.bfm_mt9p031.iv_width * driver_mt9p031.bfm_mt9p031.iv_height * 4 );
	assign	iv_frame_size		= (i_chunk_mode_active==1'b1) ? (frame_size_byte-52-36) : (frame_size_byte-52-32);

	//	===============================================================================================
	//	ref ��ͣ��
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	֡��Ч�ڼ俪��
	//	1.�ȴ�Sensor���fval�ź�
	//	2.���2��֮�󿪲�-��λSensor
	//	3.���2��֮�󿪲�-SE=1
	//	4.���2��֮�󿪲�-ȡ����λSensor
	//  -------------------------------------------------------------------------------------
	task se_start_fval;
		begin
			#200;
			i_start_quick	= 1'b0;
			#200;
			@ (posedge i_fval);
			//2��֮�� Sensor��λ
			@ (posedge i_lval);
			@ (posedge i_lval);
			i_start_quick	= 1'b1;
		end
	endtask

	task se_low_high;
		begin
			i_start_full_frame	= 1'b0;
			#1000;
			i_start_full_frame	= 1'b1;
		end
	endtask

	task chunk_mode_active_high;
		begin
			#1
			i_chunk_mode_active	= 1'b1;
		end
	endtask

	task chunk_mode_active_low;
		begin
			#1
			i_chunk_mode_active	= 1'b0;
		end
	endtask
	


endmodule
