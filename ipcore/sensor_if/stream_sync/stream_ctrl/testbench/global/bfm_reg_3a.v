//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : bfm_reg_3a
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
module bfm_reg_3a # (
	parameter	BAYER_PATTERN		= "GR"	,	//"GR" "RG" "GB" "BG"
	parameter	SENSOR_DAT_WIDTH	= 10	,	//sensor 数据宽度
	parameter	WB_OFFSET_WIDTH		= 12	,	//白平衡模块偏移位置寄存器宽度
	parameter	WB_GAIN_WIDTH		= 11	,	//白平衡模块增益寄存器宽度
	parameter	WB_STATIS_WIDTH		= 29	,	//白平衡模块统计值宽度
	parameter	WB_RATIO			= 8		,	//白平衡调节因子，乘法增益需要右移多少位
	parameter	REG_WD				= 32	,	//寄存器位宽.
	parameter	GREY_OFFSET_WIDTH	= 12	,	//灰度统计模块偏移位置寄存器宽度
	parameter	GREY_STATIS_WIDTH	= 48		//灰度统计模块统计值宽度
	)
	();

	//	ref signals

	reg										i_interrupt_pin			= 1'b0;
	reg										i_interrupt_en_wb		= 1'b0;
	reg										i_interrupt_en_grey		= 1'b0;
	reg		[WB_OFFSET_WIDTH-1:0]			iv_wb_offset_x_start	= 'b0;
	reg		[WB_OFFSET_WIDTH-1:0]			iv_wb_offset_width		= 'b0;
	reg		[WB_OFFSET_WIDTH-1:0]			iv_wb_offset_y_start	= 'b0;
	reg		[WB_OFFSET_WIDTH-1:0]			iv_wb_offset_height		= 'b0;
	reg		[WB_GAIN_WIDTH-1:0]				iv_wb_gain_r			= 'h100;
	reg		[WB_GAIN_WIDTH-1:0]				iv_wb_gain_g			= 'h100;
	reg		[WB_GAIN_WIDTH-1:0]				iv_wb_gain_b			= 'h100;
	reg		[GREY_OFFSET_WIDTH-1:0]			iv_grey_offset_x_start	= 'b0;
	reg		[GREY_OFFSET_WIDTH-1:0]			iv_grey_offset_width	= 'b0;
	reg		[GREY_OFFSET_WIDTH-1:0]			iv_grey_offset_y_start	= 'b0;
	reg		[GREY_OFFSET_WIDTH-1:0]			iv_grey_offset_height	= 'b0;

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	--ref 中断引脚
	//	-------------------------------------------------------------------------------------
	task interrupt_pin_rise;
		begin
			#1
			i_interrupt_pin	= 1'b0;
			@ (negedge harness.o_fval);
			repeat(5) @ (posedge driver_mt9p031.clk_sensor_pix);
			i_interrupt_pin	= 1'b1;
			repeat(5) @ (posedge driver_mt9p031.clk_sensor_pix);
			i_interrupt_pin	= 1'b0;
		end
	endtask

	task interrupt_pin_low;
		begin
			#1
			i_interrupt_pin	= 1'b0;
		end
	endtask

	task interrupt_pin_high;
		begin
			#1
			i_interrupt_pin	= 1'b1;
		end
	endtask


	//	-------------------------------------------------------------------------------------
	//	--ref 中断使能 wb
	//	-------------------------------------------------------------------------------------
	task interrupt_en_wb_low;
		begin
			#1
			i_interrupt_en_wb	= 1'b0;
		end
	endtask

	task interrupt_en_wb_high;
		begin
			#1
			i_interrupt_en_wb	= 1'b1;
		end
	endtask

	task interrupt_en_wb_random;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		time_slot;
		begin
			//	-------------------------------------------------------------------------------------
			//	在 start point 和 stop point 之间，产生一个随机数
			//	-------------------------------------------------------------------------------------
			time_slot	= $random()%(end_point-start_point)+start_point;
			repeat(time_slot) @ (posedge driver_mt9p031.clk_sensor_pix);
			i_interrupt_en_wb	= 1'b1;
			time_slot	= $random()%(end_point-start_point)+start_point;
			repeat(time_slot) @ (posedge driver_mt9p031.clk_sensor_pix);
			i_interrupt_en_wb	= 1'b0;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref 中断使能 grey
	//	-------------------------------------------------------------------------------------
	task interrupt_en_grey_low;
		begin
			#1
			i_interrupt_en_grey	= 1'b0;
		end
	endtask

	task interrupt_en_grey_high;
		begin
			#1
			i_interrupt_en_grey	= 1'b1;
		end
	endtask

	task interrupt_en_grey_random;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		time_slot;
		begin
			//	-------------------------------------------------------------------------------------
			//	在 start point 和 stop point 之间，产生一个随机数
			//	-------------------------------------------------------------------------------------
			time_slot	= $random()%(end_point-start_point)+start_point;
			repeat(time_slot) @ (posedge driver_mt9p031.clk_sensor_pix);
			i_interrupt_en_grey	= 1'b1;
			time_slot	= $random()%(end_point-start_point)+start_point;
			repeat(time_slot) @ (posedge driver_mt9p031.clk_sensor_pix);
			i_interrupt_en_grey	= 1'b0;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref aoi wb
	//	-------------------------------------------------------------------------------------
	task aoi_wb_random;
		begin
			#100
			@ (posedge harness.o_fval);
			repeat(10) @ (posedge driver_mt9p031.clk_sensor_pix);
			wait(driver_mt9p031.bfm_mt9p031.reset==1'b0);
			iv_wb_offset_x_start	= $random()%(driver_mt9p031.bfm_mt9p031.width_temp-1);
			iv_wb_offset_width		= $random()%(driver_mt9p031.bfm_mt9p031.width_temp-iv_wb_offset_x_start);
			iv_wb_offset_y_start	= $random()%(driver_mt9p031.bfm_mt9p031.iv_height-1);
			iv_wb_offset_height		= $random()%(driver_mt9p031.bfm_mt9p031.iv_height-iv_wb_offset_y_start);
		end
	endtask

	task aoi_wb_full_frame;
		begin
			#100
			@ (posedge harness.o_fval);
			repeat(10) @ (posedge driver_mt9p031.clk_sensor_pix);
			wait(driver_mt9p031.bfm_mt9p031.reset==1'b0);
			iv_wb_offset_x_start	= 0;
			iv_wb_offset_width		= driver_mt9p031.bfm_mt9p031.width_temp;
			iv_wb_offset_y_start	= 0;
			iv_wb_offset_height		= driver_mt9p031.bfm_mt9p031.iv_height;
		end
	endtask

	task aoi_wb_zero;
		begin
			#100
			@ (posedge harness.o_fval);
			repeat(10) @ (posedge driver_mt9p031.clk_sensor_pix);
			wait(driver_mt9p031.bfm_mt9p031.reset==1'b0);
			iv_wb_offset_x_start	= $random()%(driver_mt9p031.bfm_mt9p031.width_temp-1);
			iv_wb_offset_width		= 0;
			iv_wb_offset_y_start	= $random()%(driver_mt9p031.bfm_mt9p031.iv_height-1);
			iv_wb_offset_height		= 0;
		end
	endtask

	task aoi_wb_random_large;
		begin
			#100
			@ (posedge harness.o_fval);
			repeat(10) @ (posedge driver_mt9p031.clk_sensor_pix);
			wait(driver_mt9p031.bfm_mt9p031.reset==1'b0);
			iv_wb_offset_x_start	= $random()%(driver_mt9p031.bfm_mt9p031.width_temp-1);
			iv_wb_offset_width		= (driver_mt9p031.bfm_mt9p031.width_temp-iv_wb_offset_x_start)+10;
			iv_wb_offset_y_start	= $random()%(driver_mt9p031.bfm_mt9p031.iv_height-1);
			iv_wb_offset_height		= (driver_mt9p031.bfm_mt9p031.iv_height-iv_wb_offset_y_start)+10;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref aoi grey
	//	-------------------------------------------------------------------------------------
	task aoi_grey_random;
		begin
			#100
			@ (posedge harness.o_fval);
			repeat(10) @ (posedge driver_mt9p031.clk_sensor_pix);
			wait(driver_mt9p031.bfm_mt9p031.reset==1'b0);
			iv_grey_offset_x_start		= $random()%(driver_mt9p031.bfm_mt9p031.width_temp-1);
			iv_grey_offset_width		= $random()%(driver_mt9p031.bfm_mt9p031.width_temp-iv_grey_offset_x_start);
			iv_grey_offset_y_start		= $random()%(driver_mt9p031.bfm_mt9p031.iv_height-1);
			iv_grey_offset_height		= $random()%(driver_mt9p031.bfm_mt9p031.iv_height-iv_grey_offset_y_start);
		end
	endtask

	task aoi_grey_full_frame;
		begin
			#100
			@ (posedge harness.o_fval);
			repeat(10) @ (posedge driver_mt9p031.clk_sensor_pix);
			wait(driver_mt9p031.bfm_mt9p031.reset==1'b0);
			iv_grey_offset_x_start		= 0;
			iv_grey_offset_width		= driver_mt9p031.bfm_mt9p031.width_temp;
			iv_grey_offset_y_start		= 0;
			iv_grey_offset_height		= driver_mt9p031.bfm_mt9p031.iv_height;
		end
	endtask

	task aoi_grey_zero;
		begin
			#100
			@ (posedge harness.o_fval);
			repeat(10) @ (posedge driver_mt9p031.clk_sensor_pix);
			wait(driver_mt9p031.bfm_mt9p031.reset==1'b0);
			iv_grey_offset_x_start		= $random()%(driver_mt9p031.bfm_mt9p031.width_temp-1);
			iv_grey_offset_width		= 0;
			iv_grey_offset_y_start		= $random()%(driver_mt9p031.bfm_mt9p031.iv_height-1);
			iv_grey_offset_height		= 0;
		end
	endtask

	task aoi_grey_random_large;
		begin
			#100
			@ (posedge harness.o_fval);
			repeat(10) @ (posedge driver_mt9p031.clk_sensor_pix);
			wait(driver_mt9p031.bfm_mt9p031.reset==1'b0);
			iv_grey_offset_x_start		= $random()%(driver_mt9p031.bfm_mt9p031.width_temp-1);
			iv_grey_offset_width		= (driver_mt9p031.bfm_mt9p031.width_temp-iv_grey_offset_x_start)+10;
			iv_grey_offset_y_start		= $random()%(driver_mt9p031.bfm_mt9p031.iv_height-1);
			iv_grey_offset_height		= (driver_mt9p031.bfm_mt9p031.iv_height-iv_grey_offset_y_start)+10;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref wb gain 系数
	//	-------------------------------------------------------------------------------------
	task gain_rgb;
		input	[WB_GAIN_WIDTH-1:0]		iv_din_r;
		input	[WB_GAIN_WIDTH-1:0]		iv_din_g;
		input	[WB_GAIN_WIDTH-1:0]		iv_din_b;
		begin
			iv_wb_gain_r	= iv_din_r;
			iv_wb_gain_g	= iv_din_g;
			iv_wb_gain_b	= iv_din_b;
		end
	endtask

	task gain_r_random;
		input	[WB_GAIN_WIDTH-1:0]		start_point	;
		input	[WB_GAIN_WIDTH-1:0]		end_point	;
		reg		[WB_GAIN_WIDTH-1:0]		reg_value	;
		begin
			#100
			@ (posedge harness.o_fval);
			reg_value		= $random()%(end_point-start_point)+start_point;
			iv_wb_gain_r	= reg_value;
		end
	endtask

	task gain_g_random;
		input	[WB_GAIN_WIDTH-1:0]		start_point	;
		input	[WB_GAIN_WIDTH-1:0]		end_point	;
		reg		[WB_GAIN_WIDTH-1:0]		reg_value	;
		begin
			#100
			@ (posedge harness.o_fval);
			reg_value		= $random()%(end_point-start_point)+start_point;
			iv_wb_gain_g	= reg_value;
		end
	endtask

	task gain_b_random;
		input	[WB_GAIN_WIDTH-1:0]		start_point	;
		input	[WB_GAIN_WIDTH-1:0]		end_point	;
		reg		[WB_GAIN_WIDTH-1:0]		reg_value	;
		begin
			#100
			@ (posedge harness.o_fval);
			reg_value		= $random()%(end_point-start_point)+start_point;
			iv_wb_gain_b	= reg_value;
		end
	endtask

	task gain_rgb_random;
		input	[WB_GAIN_WIDTH-1:0]		start_point	;
		input	[WB_GAIN_WIDTH-1:0]		end_point	;
		reg		[WB_GAIN_WIDTH-1:0]		reg_value	;
		begin
			#100
			@ (posedge harness.o_fval);
			reg_value		= $random()%(end_point-start_point)+start_point;
			iv_wb_gain_r	= reg_value;
			reg_value		= $random()%(end_point-start_point)+start_point;
			iv_wb_gain_g	= reg_value;
			reg_value		= $random()%(end_point-start_point)+start_point;
			iv_wb_gain_b	= reg_value;
		end
	endtask




endmodule
