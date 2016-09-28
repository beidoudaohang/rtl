//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : ctrl_ch_det
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2013/9/10 14:32:56	:|  初始版本
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
//`include			"ctrl_ch_det_def.vh"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module ctrl_ch_det (
	input					clk,
	input					reset,
	input					i_bitslip_done,
	input	[9:0]			iv_splice_contr_data,
	output					o_crc_en,
	output					o_cmp_en
	);

	//	ref signals

	parameter		FS		= 10'h2aa;
	parameter		FE		= 10'h32a;
	parameter		LS		= 10'h0aa;
	parameter		LE		= 10'h12a;

	parameter		BL		= 10'h015;
	parameter		IMG		= 10'h035;
	parameter		CRC		= 10'h059;
	parameter		TR		= 10'h3a6;


	reg		crc_en_reg		= 1'b0;
	reg		cmp_en_reg		= 1'b0;

	//	ref ARCHITECTURE
	always @ (posedge reset or posedge clk) begin
		if(reset) begin
			crc_en_reg	<= 1'b0;
		end else begin
			if(i_bitslip_done) begin
				case(iv_splice_contr_data)
					FS,LS : begin
						crc_en_reg	<= 1'b1;
					end
					CRC : begin
						crc_en_reg	<= 1'b0;
					end
					default : begin
						crc_en_reg	<= crc_en_reg;
					end
				endcase
			end else begin
				crc_en_reg	<= 1'b0;
			end
		end
	end

	always @ (posedge reset or posedge clk) begin
		if(reset) begin
			cmp_en_reg	<= 1'b0;
		end else begin
			if(i_bitslip_done) begin
				if(iv_splice_contr_data == CRC) begin
					cmp_en_reg	<= 1'b1;
				end else begin
					cmp_en_reg	<= 1'b0;
				end
			end else begin
				cmp_en_reg	<= 1'b0;
			end
		end
	end


	assign	o_crc_en		= crc_en_reg;
	assign	o_cmp_en		= cmp_en_reg;

endmodule
