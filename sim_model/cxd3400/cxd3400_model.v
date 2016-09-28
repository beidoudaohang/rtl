//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : cxd3400_model
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/2/24 11:15:45	:|  初始版本
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
//`include			"cxd3400_model_def.v"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module cxd3400_model (
	input	[3:0]		iv_xv	,
	input				i_ofd	,
	input				i_xsg	,
	output	[3:0]		ov_xv	,
	output				o_ofd	,
	output				o_xsg


	);

	//	ref signals

	reg	[3:0]		xv_reg	= 4'b0011;
	reg	[3:0]		falling_xv_reg	= 4'b0000;
	reg				ofd_reg = 1'b0;
	reg				xsg_reg	= 1'b0;

	//	ref ARCHITECTURE

//69 23


	always @ (iv_xv[0]) begin
		if(iv_xv[0] == 1'b0) begin
			#66.666		xv_reg[0]	<= 1'b1;		
		end
		else begin
			#22.222		xv_reg[0]	<= 1'b0;		
		end
	end
	
	always @ (iv_xv[1]) begin
		if(iv_xv[1] == 1'b0) begin
			#66.666		xv_reg[1]	<= 1'b1;		
		end
		else begin
			#22.222		xv_reg[1]	<= 1'b0;		
		end
	end
	
	always @ (iv_xv[2]) begin
		if(iv_xv[2] == 1'b0) begin
			#66.666 xv_reg[2]	<= 1'b1;		
		end
		else begin
			#22.222 xv_reg[2]	<= 1'b0;		
		end
	end
	
	always @ (iv_xv[3]) begin
		if(iv_xv[3] == 1'b0) begin
			#66.666 xv_reg[3]	<= 1'b1;		
		end
		else begin
			#22.222 xv_reg[3]	<= 1'b0;		
		end
	end

	always @ (i_ofd) begin
		if(i_ofd == 1'b0) begin
			#66.666 ofd_reg	<= 1'b1;	//延时6个时钟周期
		end
		else begin
			#22.222 ofd_reg	<= 1'b0;	//没有测量
		end
	end
	
	always @ (i_xsg) begin
		if(i_xsg == 1'b0) begin
			#66.666 xsg_reg	<= 1'b1;
		end
		else begin
			#22.222 xsg_reg	<= 1'b0;
		end
	end
	

	//ref output
	assign	ov_xv	= xv_reg;
	assign	o_ofd	= ofd_reg;
	assign	o_xsg	= xsg_reg;




endmodule
