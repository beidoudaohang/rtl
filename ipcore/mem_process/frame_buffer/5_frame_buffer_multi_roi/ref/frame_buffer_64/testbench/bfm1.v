//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : bfm1
//  -- 设计者       : 张强
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 张强         :| 2015/4/8 16:46:01	:|
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
module bfm1;
	localparam							DATA_WD			=32		;		//输入输出数据位宽，这里使用同一宽度
	localparam							SHORT_REG_WD 	=16		;		//短寄存器位宽
	localparam							REG_WD 			=32		;		//寄存器位宽
	localparam							LONG_REG_WD 	=64		;		//长寄存器位宽
	localparam							BUF_DEPTH_WD	=4		;		//帧存深度位宽,我们最大支持8帧深度，多一位进位位
// task1
task config_imagesize ;

	input								i_chunkmodeactive		;
	input		[BUF_DEPTH_WD-1		:0]	iv_frame_depth			;
	input		[SHORT_REG_WD-1		:0]	iv_size_x				; 		//窗口宽度
	input		[SHORT_REG_WD-1		:0]	iv_size_y				; 		//窗口高度
	input		[SHORT_REG_WD-1		:0]	iv_offset_x				; 		//水平偏移
	input		[SHORT_REG_WD-1		:0]	iv_offset_y				; 		//垂直便宜
	input		[SHORT_REG_WD-1		:0]	iv_h_period 			;
	input		[SHORT_REG_WD-1		:0]	iv_v_petiod 			;

	output								o_chunkmodeactive		;
	output		[BUF_DEPTH_WD-1		:0]	ov_frame_depth			;
	output		[SHORT_REG_WD-1		:0]	ov_h_period 			;
	output		[SHORT_REG_WD-1		:0]	ov_v_petiod 			;
	output		[SHORT_REG_WD-1		:0]	ov_size_x				; 		//窗口宽度
	output		[SHORT_REG_WD-1		:0]	ov_size_y				; 		//窗口高度
	output		[SHORT_REG_WD-1		:0]	ov_offset_x				; 		//水平偏移
	output		[SHORT_REG_WD-1		:0]	ov_offset_y				; 		//垂直便宜
	output		[LONG_REG_WD-1		:0]	ov_payload_size_frame_buf; 		//有效负载大小字段
	output		[LONG_REG_WD-1		:0]	ov_payload_size_pix      ;
	output		[SHORT_REG_WD-1		:0]	ov_u3v_size				;

	begin
		assign	o_chunkmodeactive			= i_chunkmodeactive		;
		assign	ov_frame_depth				= iv_frame_depth		;
		assign	ov_h_period 				= iv_h_period 			;
		assign	ov_v_petiod 	        	= iv_v_petiod 			;
		assign	ov_size_x					= iv_size_x				;
		assign	ov_size_y					= iv_size_y				;
		assign	ov_offset_x					= iv_offset_x			;
		assign	ov_offset_y					= iv_offset_y			;
		assign	ov_payload_size_frame_buf	= ov_size_x*ov_size_y 	;
		assign	ov_payload_size_pix			= ov_size_x*ov_size_y 	;
		assign	ov_u3v_size					= 16'hB					;
	end
endtask

endmodule
