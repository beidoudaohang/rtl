//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : bfm_ccd
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/8/13 13:58:52	:|  初始版本
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
`include "SHARP_RJ33J3_DEF.v"


module bfm_ccd ();

	//	ref signals
	reg		[`FRAME_WD-1:0]		iv_exp_line;
	reg		[`EXP_WD-1:0]		iv_exp_reg;

	reg		[`FRAME_WD-1:0]		iv_frame_period;
	reg		[`FRAME_WD-1:0]		iv_headblank_end;
	reg		[`FRAME_WD-1:0]		iv_vref_start;
	reg		[`FRAME_WD-1:0]		iv_tailblank_start;
	reg		[`FRAME_WD-1:0]		iv_tailblank_end;

	reg		[`LINE_WD-1:0]		iv_href_start;	//行有效开始寄存器
	reg		[`LINE_WD-1:0]		iv_href_end;	//行有效结束寄存器
	reg		[16-1:0]			iv_roi_offset_x;	//行有效结束寄存器
	reg		[16-1:0]			iv_roi_pic_width;	//行有效结束寄存器


	//	ref ARCHITECTURE


	task readout_reg_cfg;

		input [31:0] offsetx;
		input [31:0] offsety;
		input [31:0] width;
		input [31:0] height;

		reg [31:0] headblank_num;
		reg [31:0] tailblank_num;

		begin
			if(((offsety + 16)/8 -1)>1000) begin
				headblank_num	= 0;
			end
			else begin
				headblank_num	= (offsety + 16)/8 -1;
			end
			iv_headblank_end  	= headblank_num + 2 ;
			iv_vref_start 		= iv_headblank_end + (offsety + 16) - headblank_num*8 ;
			iv_tailblank_start 	= iv_vref_start + height;
			if(((996 - (height + offsety + 16))/8-1)>1000) begin
				tailblank_num	= 0;
			end
			else begin
				tailblank_num	= (996 - (height + offsety + 16))/8-1 ;	//4+4+8
			end

			iv_tailblank_end	= tailblank_num + iv_tailblank_start;
			iv_frame_period  	= iv_tailblank_end + 2;

			iv_href_start		= `HREF_START_AD_DEFVALUE;
			iv_href_end			= `HREF_END_AD_DEFVALUE;

			iv_roi_offset_x		= offsetx;
			iv_roi_pic_width	= width;

			$display(" iv_frame_period is %d\n iv_headblank_end is %d\n iv_vref_start is %d\n iv_tailblank_start is %d\n iv_tailblank_start is  %d\n",iv_frame_period,iv_headblank_end,iv_vref_start,iv_tailblank_start,iv_tailblank_start);
			$display(" iv_href_start is %d\n iv_href_end is %d\n",iv_href_start,iv_href_end);
			$display(" iv_roi_offset_x is %d\n iv_roi_pic_width is %d\n",iv_roi_offset_x,iv_roi_pic_width);
		end
	endtask

	task exp_time_us;
		input	[15:0]	exp_time_input;
		begin
			iv_exp_reg	= (exp_time_input*45)+31+100;
			iv_exp_line	= (((iv_exp_reg/`LINE_PIX)-1)>30000) ? 0 : ((iv_exp_reg/`LINE_PIX)-1);
		end
	endtask





endmodule
