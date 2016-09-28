//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : bfm_se_acq
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/4/10 15:46:57	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
`define		TESTCASE	testcase1
module bfm_se_acq ();

	//	ref signals
	reg			i_acquisition_start	= 1'b0;
	reg			i_stream_enable		= 1'b0;

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	--ref se acq 单独控制
	//	-------------------------------------------------------------------------------------
	//	-------------------------------------------------------------------------------------
	//	acq 开停采
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
	//	se 开停采
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
	//	se开采距离fval上升沿太近，会出现问题
	//	-------------------------------------------------------------------------------------
	task se_at_fval_rise_error;
		integer		i	;
		begin
			for(i=1;i<20;i=i+1) begin
				//	-------------------------------------------------------------------------------------
				//	在fval上升沿开采
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b1;
				//	-------------------------------------------------------------------------------------
				//	在fval上升沿停采
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b0;
			end
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se开采在fval上升沿之前
	//	-------------------------------------------------------------------------------------
	task se_at_fval_rise_1;
		integer		i	;
		begin
			for(i=1;i<20;i=i+1) begin
				//	-------------------------------------------------------------------------------------
				//	在fval上升沿开采
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(1) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b1;
				//	-------------------------------------------------------------------------------------
				//	在fval上升沿停采
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b0;
			end
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se开采在fval上升沿之后
	//	-------------------------------------------------------------------------------------
	task se_at_fval_rise_2;
		integer		i	;
		begin
			for(i=1;i<20;i=i+1) begin
				//	-------------------------------------------------------------------------------------
				//	在fval上升沿开采
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(20) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b1;
				//	-------------------------------------------------------------------------------------
				//	在fval上升沿停采
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b0;
			end
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se开采在fval下降沿附近开停采
	//	-------------------------------------------------------------------------------------
	task se_at_fval_fall;
		integer		i		;
		begin
			for(i=1;i<30;i=i+2) begin
				//	-------------------------------------------------------------------------------------
				//	在fval下降沿开采
				//	-------------------------------------------------------------------------------------
				@ (negedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b1;
				//	-------------------------------------------------------------------------------------
				//	在fval下降沿停采
				//	-------------------------------------------------------------------------------------
				@ (negedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b0;
			end
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se开采在fval=1的中间位置开停采
	//	-------------------------------------------------------------------------------------
	task se_at_fval_mid;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		i;
		begin
			for(i=start_point;i<end_point;i=i+1) begin
				//	-------------------------------------------------------------------------------------
				//	在fval=1中间开采
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b1;
				//	-------------------------------------------------------------------------------------
				//	在fval=1中间停采
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b0;
			end
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se开采在fval=0的中间位置开停采
	//	-------------------------------------------------------------------------------------
	task se_at_fhide_mid;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		i;
		begin
			for(i=start_point;i<end_point;i=i+1) begin
				//	-------------------------------------------------------------------------------------
				//	在fval=0中间开采
				//	-------------------------------------------------------------------------------------
				@ (negedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b1;
				//	-------------------------------------------------------------------------------------
				//	在fval=1中间停采
				//	-------------------------------------------------------------------------------------
				@ (negedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b0;
			end
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	acq se 随机开停采
	//	-------------------------------------------------------------------------------------
	task se_random;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		time_slot;
		begin
			//	-------------------------------------------------------------------------------------
			//	在 start point 和 stop point 之间，产生一个随机数
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
			//	在 start point 和 stop point 之间，产生一个随机数
			//	-------------------------------------------------------------------------------------
			time_slot	= {$random()}%(end_point-start_point)+start_point;
			i_acquisition_start	= 1'b1;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			i_acquisition_start	= 1'b0;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref 开停采结合
	//	-------------------------------------------------------------------------------------
	//	-------------------------------------------------------------------------------------
	//	se开采
	//	-------------------------------------------------------------------------------------
	task se_sensor_start_fix;
		input	[15:0]		iv_fix_time	;
		begin
			//	-------------------------------------------------------------------------------------
			//	复位sensor
			//	-------------------------------------------------------------------------------------
			driver_mt9p031.bfm_mt9p031.reset	= 1'b1;
			repeat(iv_fix_time) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	开采
			//	-------------------------------------------------------------------------------------
			i_stream_enable		= 1'b1;
			repeat(iv_fix_time) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	取消复位
			//	-------------------------------------------------------------------------------------
			driver_mt9p031.bfm_mt9p031.reset	= 1'b0;
			repeat(iv_fix_time) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se acq 开采
	//	-------------------------------------------------------------------------------------
	task se_acq_sensor_start_fix;
		input	[15:0]		iv_fix_time	;
		begin
			//	-------------------------------------------------------------------------------------
			//	复位sensor
			//	-------------------------------------------------------------------------------------
			driver_mt9p031.bfm_mt9p031.reset	= 1'b1;
			repeat(iv_fix_time) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	开采
			//	-------------------------------------------------------------------------------------
			i_stream_enable		= 1'b1;
			repeat(iv_fix_time) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			i_acquisition_start	= 1'b1;
			repeat(iv_fix_time) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	取消复位
			//	-------------------------------------------------------------------------------------
			driver_mt9p031.bfm_mt9p031.reset	= 1'b0;
			repeat(iv_fix_time) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se在fval=1时先停采后开采
	//	-------------------------------------------------------------------------------------
	task se_at_fval_stop_start;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		i;
		begin
			for(i=start_point;i<end_point;i=i+1) begin
				//	-------------------------------------------------------------------------------------
				//	等一个完整帧
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				//	-------------------------------------------------------------------------------------
				//	在fval=1中间停采
				//	-------------------------------------------------------------------------------------
				@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				i_stream_enable	= 1'b0;
				repeat(i) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
				//	-------------------------------------------------------------------------------------
				//	开采
				//	-------------------------------------------------------------------------------------
				se_sensor_start_fix(i);
			end
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se在fval=1时先停采后开采，随机间隔
	//	-------------------------------------------------------------------------------------
	task se_at_fval_stop_start_random;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		time_slot	;
		begin
			//	-------------------------------------------------------------------------------------
			//	在 start point 和 stop point 之间，产生一个随机数
			//	-------------------------------------------------------------------------------------
			time_slot	= {$random()}%(end_point-start_point)+start_point;
			//	-------------------------------------------------------------------------------------
			//	等一个完整帧
			//	-------------------------------------------------------------------------------------
			@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
			//	-------------------------------------------------------------------------------------
			//	在fval=1中间停采
			//	-------------------------------------------------------------------------------------
			@ (posedge driver_mt9p031.mt9p031_model_inst.w_fval);
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			i_stream_enable	= 1'b0;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	开采
			//	-------------------------------------------------------------------------------------
			se_sensor_start_fix(time_slot);
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	重复多次开停采
	//	-------------------------------------------------------------------------------------
	task se_stop_start_random;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		time_slot;
		begin
			//	-------------------------------------------------------------------------------------
			//	在 start point 和 stop point 之间，产生一个随机数
			//	-------------------------------------------------------------------------------------
			time_slot	= {$random()}%(end_point-start_point)+start_point;
			//	-------------------------------------------------------------------------------------
			//	停采
			//	-------------------------------------------------------------------------------------
			i_stream_enable	= 1'b0;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	开采
			//	-------------------------------------------------------------------------------------
			se_sensor_start_fix(time_slot);
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	se acq 重复多次开停采
	//	-------------------------------------------------------------------------------------
	task se_acq_stop_start_random;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		time_slot;
		begin
			//	-------------------------------------------------------------------------------------
			//	在 start point 和 stop point 之间，产生一个随机数
			//	-------------------------------------------------------------------------------------
			time_slot	= {$random()}%(end_point-start_point)+start_point;
			//	-------------------------------------------------------------------------------------
			//	se 停采
			//	-------------------------------------------------------------------------------------
			i_stream_enable	= 1'b0;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	acq 停采
			//	-------------------------------------------------------------------------------------
			i_acquisition_start	= 1'b0;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	开采
			//	-------------------------------------------------------------------------------------
			se_acq_sensor_start_fix(time_slot);
			//	-------------------------------------------------------------------------------------
			//	acq 停采
			//	-------------------------------------------------------------------------------------
			i_acquisition_start	= 1'b0;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	se 停采
			//	-------------------------------------------------------------------------------------
			i_stream_enable	= 1'b0;
			repeat(time_slot) @ (posedge driver_mt9p031.bfm_mt9p031.clk);
			//	-------------------------------------------------------------------------------------
			//	开采
			//	-------------------------------------------------------------------------------------
			se_acq_sensor_start_fix(time_slot);
		end
	endtask

endmodule
