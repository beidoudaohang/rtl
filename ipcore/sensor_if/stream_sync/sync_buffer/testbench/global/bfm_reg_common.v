//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : bfm_reg_common
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
module bfm_reg_common # (
	parameter	REG_WD			= 32	,
	parameter	SHORT_REG_WD	= 16
	)
	();

	//	ref signals
	reg								i_encrypt_state		= 1'b0;
	reg		[2:0]					iv_test_image_sel	= 3'b0;
	reg		[REG_WD-1:0]			iv_pixel_format		= {REG_WD{1'b0}};
	reg								i_pulse_filter_en	= 1'b0;
	reg		[SHORT_REG_WD-1:0]		iv_roi_pic_width	= {SHORT_REG_WD{1'b0}};


	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	--ref 加密
	//	-------------------------------------------------------------------------------------
	//	-------------------------------------------------------------------------------------
	//	加密状态
	//	-------------------------------------------------------------------------------------
	task encrypt_low;
		begin
			#1
			i_encrypt_state	= 1'b0;
		end
	endtask

	task encrypt_high;
		begin
			#1
			i_encrypt_state	= 1'b1;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref 测试图寄存器
	//	-------------------------------------------------------------------------------------
	task test_image_sel;
		input	[2:0]		din;
		begin
			#1
			iv_test_image_sel	= din;
		end
	endtask

	task test_image_random;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		time_slot;
		reg		[1:0]		test_image;
		begin
			//	-------------------------------------------------------------------------------------
			//	测试图定义
			//	000:真实图
			//	001:测试图像1灰度值帧递增
			//	110:测试图像2静止的斜条纹
			//	010:测试图像3滚动的斜条纹
			//	-------------------------------------------------------------------------------------
			//	在 start point 和 stop point 之间，产生一个随机数
			//	-------------------------------------------------------------------------------------
			time_slot	= {$random()}%(end_point-start_point)+start_point;
			repeat(time_slot) @ (posedge driver_mt9p031.clk_sensor_pix);
			test_image			= {$random()}%4;
			case(test_image)
				0		: iv_test_image_sel	= 3'b000;
				1		: iv_test_image_sel	= 3'b001;
				2		: iv_test_image_sel	= 3'b110;
				3		: iv_test_image_sel	= 3'b010;
				default	: iv_test_image_sel	= 3'b000;
			endcase
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	以下两个task会保证完整帧
	//	-------------------------------------------------------------------------------------
	task test_image_frame_random;
		begin
			@ (negedge harness.o_fval)
			test_image_random(0,1);
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref 像素格式寄存器
	//	-------------------------------------------------------------------------------------
	task pixel_format_mono8;
		begin
			#1
			iv_pixel_format	= 32'h01080001;
		end
	endtask

	task pixel_format_mono10;
		begin
			#1
			iv_pixel_format	= 32'h01100003;
		end
	endtask

	task pixel_format_gr8;
		begin
			#1
			iv_pixel_format	= 32'h01080008;
		end
	endtask

	task pixel_format_gr10;
		begin
			#1
			iv_pixel_format	= 32'h0110000c;
		end
	endtask

	task pixel_format_random;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		time_slot;
		reg		[31:0]		reg_value;
		begin
			//	-------------------------------------------------------------------------------------
			//	在 start point 和 stop point 之间，产生一个随机数
			//	-------------------------------------------------------------------------------------
			time_slot	= {$random()}%(end_point-start_point)+start_point;
			repeat(time_slot) @ (posedge driver_mt9p031.clk_sensor_pix);
			reg_value	= {$random()}%4;
			case(reg_value)
				0		: pixel_format_mono8();
				1		: pixel_format_mono10();
				2		: pixel_format_gr8();
				3		: pixel_format_gr10();
				default	: pixel_format_mono8();
			endcase
		end
	endtask

	task pixel_format_frame_random;
		reg		[31:0]		reg_value;
		begin
			reg_value	= {$random()}%4;
			@ (negedge harness.o_fval)
			case(reg_value)
				0		: pixel_format_mono8();
				1		: pixel_format_mono10();
				2		: pixel_format_gr8();
				3		: pixel_format_gr10();
				default	: pixel_format_mono8();
			endcase
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref pulse filter 行宽
	//	-------------------------------------------------------------------------------------
	task roi_pic_width;
		begin
			iv_roi_pic_width	= driver_mt9p031.bfm_mt9p031.iv_width;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref pulse filter 开关
	//	-------------------------------------------------------------------------------------
	task pulse_filter_en_low;
		begin
			i_pulse_filter_en	= 1'b0;
		end
	endtask

	task pulse_filter_en_high;
		begin
			i_pulse_filter_en	= 1'b1;
		end
	endtask

	task pulse_filter_en_random;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		time_slot;
		begin
			//	-------------------------------------------------------------------------------------
			//	在 start point 和 stop point 之间，产生一个随机数
			//	-------------------------------------------------------------------------------------
			time_slot	= {$random()}%(end_point-start_point)+start_point;
			i_pulse_filter_en	= 1'b1;
			repeat(time_slot) @ (posedge driver_mt9p031.clk_sensor_pix);
			i_pulse_filter_en	= 1'b0;
			repeat(time_slot) @ (posedge driver_mt9p031.clk_sensor_pix);
		end
	endtask



endmodule
