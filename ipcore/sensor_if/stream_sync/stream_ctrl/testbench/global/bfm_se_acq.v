//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : bfm_se_acq
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/4/10 15:46:57	:|  ��ʼ�汾
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
`define		TESTCASE	testcase1
module bfm_se_acq ();

	//	ref signals
	reg			i_acquisition_start	= 1'b0;
	reg			i_stream_enable		= 1'b0;

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	--ref se acq ��������
	//	-------------------------------------------------------------------------------------
	//	-------------------------------------------------------------------------------------
	//	acq ��ͣ��
	//	-------------------------------------------------------------------------------------
	task acq_low;
		begin
			#1
			i_acquisition_start	= 1'b0;
		end
	endtask

	task acq_high;
		begin
			#1
			i_acquisition_start	= 1'b1;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se ��ͣ��
	//	-------------------------------------------------------------------------------------
	task se_low;
		begin
			#1
			i_stream_enable	= 1'b0;
		end
	endtask

	task se_high;
		begin
			#1
			i_stream_enable	= 1'b1;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se���ɾ���fval������̫�������������
	//	-------------------------------------------------------------------------------------
	task se_at_fval_rise_error;
		integer		i	;
		begin
			for(i=1;i<20;i=i+1) begin
				//	-------------------------------------------------------------------------------------
				//	��fval�����ؿ���
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b1;
				//	-------------------------------------------------------------------------------------
				//	��fval������ͣ��
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b0;
			end
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se������fval������֮ǰ
	//	-------------------------------------------------------------------------------------
	task se_at_fval_rise_1;
		integer		i	;
		begin
			for(i=1;i<20;i=i+1) begin
				//	-------------------------------------------------------------------------------------
				//	��fval�����ؿ���
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(1) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b1;
				//	-------------------------------------------------------------------------------------
				//	��fval������ͣ��
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b0;
			end
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se������fval������֮��
	//	-------------------------------------------------------------------------------------
	task se_at_fval_rise_2;
		integer		i	;
		begin
			for(i=1;i<20;i=i+1) begin
				//	-------------------------------------------------------------------------------------
				//	��fval�����ؿ���
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(20) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b1;
				//	-------------------------------------------------------------------------------------
				//	��fval������ͣ��
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b0;
			end
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se������fval�½��ظ�����ͣ��
	//	-------------------------------------------------------------------------------------
	task se_at_fval_fall;
		integer		i		;
		begin
			for(i=1;i<30;i=i+2) begin
				//	-------------------------------------------------------------------------------------
				//	��fval�½��ؿ���
				//	-------------------------------------------------------------------------------------
				@ (negedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b1;
				//	-------------------------------------------------------------------------------------
				//	��fval�½���ͣ��
				//	-------------------------------------------------------------------------------------
				@ (negedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b0;
			end
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se������fval=1���м�λ�ÿ�ͣ��
	//	-------------------------------------------------------------------------------------
	task se_at_fval_mid;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		i;
		begin
			for(i=start_point;i<end_point;i=i+1) begin
				//	-------------------------------------------------------------------------------------
				//	��fval=1�м俪��
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b1;
				//	-------------------------------------------------------------------------------------
				//	��fval=1�м�ͣ��
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b0;
			end
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se������fval=0���м�λ�ÿ�ͣ��
	//	-------------------------------------------------------------------------------------
	task se_at_fhide_mid;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		i;
		begin
			for(i=start_point;i<end_point;i=i+1) begin
				//	-------------------------------------------------------------------------------------
				//	��fval=0�м俪��
				//	-------------------------------------------------------------------------------------
				@ (negedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b1;
				//	-------------------------------------------------------------------------------------
				//	��fval=1�м�ͣ��
				//	-------------------------------------------------------------------------------------
				@ (negedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b0;
			end
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	acq se �����ͣ��
	//	-------------------------------------------------------------------------------------
	task se_random;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		time_slot;
		begin
			//	-------------------------------------------------------------------------------------
			//	�� start point �� stop point ֮�䣬����һ�������
			//	-------------------------------------------------------------------------------------
			time_slot	= {$random()}%(end_point-start_point)+start_point;
			i_stream_enable	= 1'b1;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			i_stream_enable	= 1'b0;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
		end
	endtask

	task acq_random;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		time_slot	;
		begin
			//	-------------------------------------------------------------------------------------
			//	�� start point �� stop point ֮�䣬����һ�������
			//	-------------------------------------------------------------------------------------
			time_slot	= {$random()}%(end_point-start_point)+start_point;
			i_acquisition_start	= 1'b1;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			i_acquisition_start	= 1'b0;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref ��ͣ�ɽ��
	//	-------------------------------------------------------------------------------------
	//	-------------------------------------------------------------------------------------
	//	se����
	//	-------------------------------------------------------------------------------------
	task se_sensor_start_fix;
		input	[15:0]		iv_fix_time	;
		begin
			//	-------------------------------------------------------------------------------------
			//	��λsensor
			//	-------------------------------------------------------------------------------------
			driver_mt9p031.bfm_mt9p031.reset	= 1'b1;
			repeat(iv_fix_time) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	����
			//	-------------------------------------------------------------------------------------
			i_stream_enable		= 1'b1;
			repeat(iv_fix_time) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	ȡ����λ
			//	-------------------------------------------------------------------------------------
			driver_mt9p031.bfm_mt9p031.reset	= 1'b0;
			repeat(iv_fix_time) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se acq ����
	//	-------------------------------------------------------------------------------------
	task se_acq_sensor_start_fix;
		input	[15:0]		iv_fix_time	;
		begin
			//	-------------------------------------------------------------------------------------
			//	��λsensor
			//	-------------------------------------------------------------------------------------
			driver_mt9p031.bfm_mt9p031.reset	= 1'b1;
			repeat(iv_fix_time) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	����
			//	-------------------------------------------------------------------------------------
			i_stream_enable		= 1'b1;
			repeat(iv_fix_time) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			i_acquisition_start	= 1'b1;
			repeat(iv_fix_time) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	ȡ����λ
			//	-------------------------------------------------------------------------------------
			driver_mt9p031.bfm_mt9p031.reset	= 1'b0;
			repeat(iv_fix_time) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se��fval=1ʱ��ͣ�ɺ󿪲�
	//	-------------------------------------------------------------------------------------
	task se_at_fval_stop_start;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		i;
		begin
			for(i=start_point;i<end_point;i=i+1) begin
				//	-------------------------------------------------------------------------------------
				//	��һ������֡
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				//	-------------------------------------------------------------------------------------
				//	��fval=1�м�ͣ��
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b0;
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				//	-------------------------------------------------------------------------------------
				//	����
				//	-------------------------------------------------------------------------------------
				se_sensor_start_fix(i);
			end
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se��fval=1ʱ��ͣ�ɺ󿪲ɣ�������
	//	-------------------------------------------------------------------------------------
	task se_at_fval_stop_start_random;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		time_slot	;
		begin
			//	-------------------------------------------------------------------------------------
			//	�� start point �� stop point ֮�䣬����һ�������
			//	-------------------------------------------------------------------------------------
			time_slot	= {$random()}%(end_point-start_point)+start_point;
			//	-------------------------------------------------------------------------------------
			//	��һ������֡
			//	-------------------------------------------------------------------------------------
			@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
			//	-------------------------------------------------------------------------------------
			//	��fval=1�м�ͣ��
			//	-------------------------------------------------------------------------------------
			@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			i_stream_enable	= 1'b0;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	����
			//	-------------------------------------------------------------------------------------
			se_sensor_start_fix(time_slot);
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	�ظ���ο�ͣ��
	//	-------------------------------------------------------------------------------------
	task se_stop_start_random;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		time_slot;
		begin
			//	-------------------------------------------------------------------------------------
			//	�� start point �� stop point ֮�䣬����һ�������
			//	-------------------------------------------------------------------------------------
			time_slot	= {$random()}%(end_point-start_point)+start_point;
			//	-------------------------------------------------------------------------------------
			//	ͣ��
			//	-------------------------------------------------------------------------------------
			i_stream_enable	= 1'b0;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	����
			//	-------------------------------------------------------------------------------------
			se_sensor_start_fix(time_slot);
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se acq �ظ���ο�ͣ��
	//	-------------------------------------------------------------------------------------
	task se_acq_stop_start_random;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		time_slot;
		begin
			//	-------------------------------------------------------------------------------------
			//	�� start point �� stop point ֮�䣬����һ�������
			//	-------------------------------------------------------------------------------------
			time_slot	= {$random()}%(end_point-start_point)+start_point;
			//	-------------------------------------------------------------------------------------
			//	se ͣ��
			//	-------------------------------------------------------------------------------------
			i_stream_enable	= 1'b0;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	acq ͣ��
			//	-------------------------------------------------------------------------------------
			i_acquisition_start	= 1'b0;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	����
			//	-------------------------------------------------------------------------------------
			se_acq_sensor_start_fix(time_slot);
			//	-------------------------------------------------------------------------------------
			//	acq ͣ��
			//	-------------------------------------------------------------------------------------
			i_acquisition_start	= 1'b0;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	se ͣ��
			//	-------------------------------------------------------------------------------------
			i_stream_enable	= 1'b0;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	����
			//	-------------------------------------------------------------------------------------
			se_acq_sensor_start_fix(time_slot);
		end
	endtask

endmodule