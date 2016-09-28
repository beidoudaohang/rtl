//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : crc_chk
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2013/9/10 14:03:34	:|  初始版本
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
//`include			"crc_chk_def.vh"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module crc_chk (
	input				clk,
	input				reset,
	input				i_bitslip_done,
	input				i_crc_reg_ena,
	input				i_crc_reg_clr,
	input				i_crc_en,
	input				i_cmp_en,
	input	[9:0]		iv_splice_data,
	output				o_crc_err,
	output				o_crc_ok,
	output	[15:0]		ov_crc_err_reg

	);

	//	ref signals

	reg		[15:0]				crc_err_reg = 16'b0;
	wire	[9:0]				crc_out;
	reg							crc_err = 1'b0;
	reg							crc_ok = 1'b0;
	reg		[9:0]				splice_data_reg = 10'b0;
	reg							cmp_en_reg = 1'b0;
	
	reg							crc_reg_clr_d = 1'b0;
	reg							crc_reg_clr_reg = 1'b0;
	reg							crc_reg_ena_d = 1'b0;
	reg							crc_reg_ena_reg = 1'b0;

	//	ref ARCHITECTURE


	//  -------------------------------------------------------------------------------------
	//	crc 算法模块
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		splice_data_reg	<= iv_splice_data;
	end
	
	always @ (posedge clk) begin
		cmp_en_reg	<= i_cmp_en;
	end


	crc inst_crc (
	.clk		(clk),
	.rst		(reset | cmp_en_reg),
	.crc_en		(i_crc_en),
	.data_in	(splice_data_reg),
	.crc_out	(crc_out)
	);

	//  -------------------------------------------------------------------------------------
	//	当i_cmp_en有效时，比较输入的crc和计算的crc，如果二者不相等，发出错误信号
	//  -------------------------------------------------------------------------------------
	always @ (posedge reset or posedge clk) begin
		if(reset) begin
			crc_err	<= 1'b0;
		end else begin
			if((i_cmp_en)&&(splice_data_reg != crc_out)) begin
				crc_err	<= 1'b1;
			end else begin
				crc_err	<= 1'b0;
			end
		end
	end
	assign	o_crc_err	= crc_err;
	
	
	always @ (posedge reset or posedge clk) begin
		if(reset) begin
			crc_ok	<= 1'b0;
		end else begin
			if((i_cmp_en)&&(splice_data_reg == crc_out)) begin
				crc_ok	<= 1'b1;
			end else begin
				crc_ok	<= 1'b0;
			end
		end
	end
	assign	o_crc_ok	= crc_ok;	
				
	//  -------------------------------------------------------------------------------------
	//	bitslip没有结束时，reg清零。
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		crc_reg_clr_d	<= i_crc_reg_clr;
		crc_reg_clr_reg	<= crc_reg_clr_d;
	end
	
	always @ (posedge clk) begin
		crc_reg_ena_d	<= i_crc_reg_ena;
		crc_reg_ena_reg	<= crc_reg_ena_d;
	end

	always @ (posedge reset or posedge clk) begin
		if(reset) begin
			crc_err_reg	<= 'b0;
		end else begin
			if(!i_bitslip_done) begin
				crc_err_reg	<= 'b0;
			end else if(crc_reg_clr_reg) begin
				crc_err_reg	<= 'b0;
			end else if(crc_reg_ena_reg & crc_err) begin
				crc_err_reg	<= crc_err_reg + 1'b1;
			end
		end
	end
	
	assign	ov_crc_err_reg		= crc_err_reg;

endmodule
