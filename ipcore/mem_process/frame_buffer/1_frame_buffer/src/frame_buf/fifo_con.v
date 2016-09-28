//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : fifo_con
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2013/6/13 10:17:01	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :	前端FIFO的复位模块，产生1CLK的复位信号
//              1)  : 异步FIFO的读写端口需要对复位信号同步化，因此在各自时钟域的3个周期内，FIFO都是出于复位状态
//
//              2)  : fval和dval之间要有足够的空隙
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//`include			"frame_buffer_def.v"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module fifo_con (
	input			clk			,
	input			i_fval		,
	output			o_rst_buf
	);

	//ref signals
	reg				fval_d 		= 1'b0;
	reg				buf_rst_reg = 1'b0;
	wire			fval_rise	;

	//ref ARCHITECTURE

	//当fval上升沿到来时，复位前端FIFO
	always @ (posedge clk) begin
		fval_d		<= i_fval;
		buf_rst_reg	<= fval_rise;
	end

	assign	fval_rise	= (~fval_d)&i_fval;
	assign	o_rst_buf	= buf_rst_reg;


endmodule
