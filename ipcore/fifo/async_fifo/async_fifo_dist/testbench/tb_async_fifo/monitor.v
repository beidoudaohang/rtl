//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : monitor
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/16 17:48:47	:|  初始版本
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
//`timescale 1ns/1ps
`timescale 1ns/1ns
//-------------------------------------------------------------------------------------------------
`define		TESTCASE	testcase_1
module monitor ();

	//	ref signals
	
	parameter	FIFO_WIDTH	= `TESTCASE.FIFO_WIDTH	;
		
	wire						clk_rd	;
	wire						reset_async	;
	wire						o_fifo_empty	;
	wire						i_rd_en	;
	wire						empty	;
	wire	[FIFO_WIDTH-1:0]	ov_fifo_dout	;
	wire	[FIFO_WIDTH-1:0]	dout	;
	
	reg		[FIFO_WIDTH-1:0]	async_rd_cnt	= 0;
	reg		[FIFO_WIDTH-1:0]	ip_rd_cnt		= 0;
	
	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	引用
	//	-------------------------------------------------------------------------------------
	assign	clk_rd			= `TESTCASE.clk_rd;
	assign	reset_async		= `TESTCASE.reset_async;
	assign	o_fifo_empty	= harness.o_fifo_empty;
	assign	i_rd_en			= harness.i_rd_en;
	assign	empty			= harness.empty;
	assign	ov_fifo_dout	= harness.ov_fifo_dout;
	assign	dout			= harness.dout;

	//	-------------------------------------------------------------------------------------
	//	检测
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_rd) begin
		if(reset_async) begin
			async_rd_cnt	<= 0;
		end
		else if(o_fifo_empty==1'b0 && i_rd_en==1'b1) begin
			async_rd_cnt	<= async_rd_cnt + 1'b1;
		end
	end

	always @ (posedge clk_rd) begin
		if(reset_async) begin
			ip_rd_cnt	<= 0;
		end
		else if(empty==1'b0 && i_rd_en==1'b1) begin
			ip_rd_cnt	<= ip_rd_cnt + 1'b1;
		end
	end

	always @ (posedge clk_rd) begin
		if(o_fifo_empty==1'b0 && i_rd_en==1'b1 && async_rd_cnt!=ov_fifo_dout) begin
			$display("%m: at time %t ERROR: async_rd_cnt is 0x%x!,ov_fifo_dout is 0x%x", $time,async_rd_cnt,ov_fifo_dout);
			//			$stop;
		end
	end

	always @ (posedge clk_rd) begin
		if(empty==1'b0 && i_rd_en==1'b1 && async_rd_cnt!=dout) begin
			$display("%m: at time %t ERROR: ip_rd_cnt is 0x%x!,dout is 0x%x", $time,ip_rd_cnt,dout);
			//			$stop;
		end
	end




endmodule
