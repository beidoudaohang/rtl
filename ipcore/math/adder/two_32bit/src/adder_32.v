//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : adder_32
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/10/22 16:36:21	:|  初始版本
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

module adder_32 (
	input			clk				,
	input			i_fval_rise		,
	input			i_stream_enable	,
	output	[63:0]	ov_blockid
	);

	//	ref signals
	reg		[31:0]						blockid_low32	= 32'hffff_ffff;
	reg		[31:0]						blockid_high32	= 32'hffff_ffff;
	reg									adder_en		= 1'b0;


	//	ref ARCHITECTURE

	always @ (posedge clk) begin
		if(!i_stream_enable) begin		// 顶层模块保证 i_stream_enable 属于clk时钟域
			blockid_low32	<= 32'hffff_ffff;
		end
		else if(i_fval_rise==1'b1) begin
			blockid_low32	<= blockid_low32 + 1'h1;
		end
	end

	always @ (posedge clk) begin
		if(i_fval_rise==1'b1 && blockid_low32==32'hffff_ffff) begin
			adder_en	<= 1'b1;
		end
		else begin
			adder_en	<= 1'b0;
		end
	end

	always @ (posedge clk) begin
		if(!i_stream_enable) begin		// 顶层模块保证 i_stream_enable 属于clk时钟域
			blockid_high32	<= 32'hffff_ffff;
		end
		else if(adder_en) begin
			blockid_high32	<= blockid_high32 + 1'h1;
		end
	end
	assign	ov_blockid	= {blockid_high32,blockid_low32};



endmodule
