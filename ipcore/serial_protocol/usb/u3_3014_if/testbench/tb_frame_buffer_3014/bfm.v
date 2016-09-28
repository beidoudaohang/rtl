//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : bfm
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/4/8 11:28:42	:|  初始版本
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
module bfm # (
	parameter		DATA_WIDTH			= 32		,	//数据宽度
	parameter		PTR_WIDTH			= 2			,	//读写指针的位宽，1-最大2帧 2-最大4帧 3-最大8帧 4-最大16帧 5-最大32帧
	parameter		FRAME_SIZE_WIDTH	= 25			//一帧大小位宽，当DDR3是1Gbit时，最大容量是128Mbyte，当mcb p3 口位宽是32时，25位宽的size计数器就足够了
	)
	();

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	可用信号
	//	-------------------------------------------------------------------------------------
	reg		[PTR_WIDTH-1:0]				iv_frame_depth			;
	reg									i_start_full_frame		= 1'b1;
	reg									i_start_quick			= 1'b1;
	wire	[FRAME_SIZE_WIDTH-1:0]		iv_frame_size			;
	reg		[31:0]						iv_transfer_count		= 32'b0;
	reg		[31:0]						iv_transfer_size		= 32'b0;
	reg		[31:0]						iv_transfer1_size		= 32'b0;
	reg		[31:0]						iv_transfer2_size		= 32'b0;



	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***帧存 task***
	//  ===============================================================================================
	task frame_depth;
		input	[PTR_WIDTH-1:0]		iv_frame_depth_input;
		begin
			#1
			iv_frame_depth	= iv_frame_depth_input;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	帧存大小
	//	-------------------------------------------------------------------------------------
	assign	iv_frame_size		= (driver_mt9p031.bfm_mt9p031.iv_line_active_pix_num * driver_mt9p031.bfm_mt9p031.iv_line_active_num);

	//	-------------------------------------------------------------------------------------
	//	start_ff
	//	-------------------------------------------------------------------------------------
	task start_ff_high;
		begin
			#1
			i_start_full_frame	= 1'b1;
		end
	endtask
	
	task start_ff_low;
		begin
			#1
			i_start_full_frame	= 1'b1;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	start_qk
	//	-------------------------------------------------------------------------------------
	task start_qk_high;
		begin
			#1
			i_start_quick	= 1'b1;
		end
	endtask
	
	task start_qk_low;
		begin
			#1
			i_start_quick	= 1'b1;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	si info
	//	-------------------------------------------------------------------------------------
	task si_info;
		begin
			#1
			iv_transfer_size	= 32'h100000;
			#1
			iv_transfer_count	= iv_frame_size/iv_transfer_size;
			#1
			iv_transfer1_size	= (((iv_frame_size-iv_transfer_size*iv_transfer_count)/32'h400)*32'h400);
			#1
			if((iv_frame_size-iv_transfer_size*iv_transfer_count-iv_transfer1_size)!=0) begin
				iv_transfer2_size	= 32'h400;
			end
			else begin
				iv_transfer2_size	= 32'h0;
			end
		end
	endtask




endmodule
