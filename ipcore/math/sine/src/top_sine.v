//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : top_sine
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/5/21 13:54:44	:|  初始版本
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
//`include			"top_sine_def.v"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module top_sine (
	input				clk			,
	input	[9:0]		address		,
	output	[12:0]		ov_data_out	

	);

	//	ref signals

	reg		[7:0]		addra	;
	wire	[12:0]		douta	;
	reg		[12:0]		data_out	;

	//	ref ARCHITECTURE


	blk_mem_gen_v7_3 blk_mem_gen_v7_3_inst (
	.clka	(clk	),
	.addra	(addra	),
	.douta	(douta	)
	);

	always @ (posedge clk) begin
		if(address <= 10'd157) begin
			addra	<= address;
		end
		else if(address <= 10'd315 ) begin
			addra	<= 10'd315 - address;
		end
		else if(address <= 10'd473 ) begin
			addra	<= address - 10'd316;
		end
		else if(address <= 10'd631) begin
			addra	<= 10'd631 - address;
		end
		else begin
			addra	<= 0;
		end
	end

	// 判断输出值是正数还是负数。
	always @ (posedge clk) begin
		if(address <= 10'd315) begin
			data_out	<= douta;
		end
		else if(address <= 10'd631) begin
			data_out	<= ~douta + 1'b1;
		end
		else begin
			data_out	<= 0;
		end
	end
	assign	ov_data_out	= data_out;
	
	
	
endmodule
