//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : crc_16
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/6/5 14:03:51	:|  初始版本
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
//`include			"crc_16_def.v"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module crc_16 (
	input			reset		,
	input			clk			,
	input	[31:0]	data_in		,
	input			crc_en		,
	output	[15:0]	crc_out
	);

	//	ref signals

	reg		[15:0]		lfsr_q	;
	reg		[15:0]		lfsr_c	;


	//	ref ARCHITECTURE

	assign crc_out = lfsr_q;

	always @ (*) begin
		lfsr_c[0] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[10] ^ data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[15] ^ data_in[16] ^ data_in[17] ^ data_in[18] ^ data_in[19] ^ data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[30] ^ data_in[31];
		lfsr_c[1] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[11] ^ lfsr_q[12] ^ lfsr_q[15] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[10] ^ data_in[11] ^ data_in[12] ^ data_in[13] ^ data_in[14] ^ data_in[16] ^ data_in[17] ^ data_in[18] ^ data_in[19] ^ data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[27] ^ data_in[28] ^ data_in[31];
		lfsr_c[2] = lfsr_q[0] ^ lfsr_q[12] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in[0] ^ data_in[1] ^ data_in[14] ^ data_in[16] ^ data_in[28] ^ data_in[29] ^ data_in[30] ^ data_in[31];
		lfsr_c[3] = lfsr_q[1] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in[1] ^ data_in[2] ^ data_in[15] ^ data_in[17] ^ data_in[29] ^ data_in[30] ^ data_in[31];
		lfsr_c[4] = lfsr_q[0] ^ lfsr_q[2] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in[2] ^ data_in[3] ^ data_in[16] ^ data_in[18] ^ data_in[30] ^ data_in[31];
		lfsr_c[5] = lfsr_q[1] ^ lfsr_q[3] ^ lfsr_q[15] ^ data_in[3] ^ data_in[4] ^ data_in[17] ^ data_in[19] ^ data_in[31];
		lfsr_c[6] = lfsr_q[2] ^ lfsr_q[4] ^ data_in[4] ^ data_in[5] ^ data_in[18] ^ data_in[20];
		lfsr_c[7] = lfsr_q[3] ^ lfsr_q[5] ^ data_in[5] ^ data_in[6] ^ data_in[19] ^ data_in[21];
		lfsr_c[8] = lfsr_q[4] ^ lfsr_q[6] ^ data_in[6] ^ data_in[7] ^ data_in[20] ^ data_in[22];
		lfsr_c[9] = lfsr_q[5] ^ lfsr_q[7] ^ data_in[7] ^ data_in[8] ^ data_in[21] ^ data_in[23];
		lfsr_c[10] = lfsr_q[6] ^ lfsr_q[8] ^ data_in[8] ^ data_in[9] ^ data_in[22] ^ data_in[24];
		lfsr_c[11] = lfsr_q[7] ^ lfsr_q[9] ^ data_in[9] ^ data_in[10] ^ data_in[23] ^ data_in[25];
		lfsr_c[12] = lfsr_q[8] ^ lfsr_q[10] ^ data_in[10] ^ data_in[11] ^ data_in[24] ^ data_in[26];
		lfsr_c[13] = lfsr_q[9] ^ lfsr_q[11] ^ data_in[11] ^ data_in[12] ^ data_in[25] ^ data_in[27];
		lfsr_c[14] = lfsr_q[10] ^ lfsr_q[12] ^ data_in[12] ^ data_in[13] ^ data_in[26] ^ data_in[28];
		lfsr_c[15] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[6] ^ lfsr_q[7] ^ lfsr_q[8] ^ lfsr_q[9] ^ lfsr_q[10] ^ lfsr_q[13] ^ lfsr_q[14] ^ lfsr_q[15] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7] ^ data_in[8] ^ data_in[9] ^ data_in[10] ^ data_in[11] ^ data_in[12] ^ data_in[14] ^ data_in[15] ^ data_in[16] ^ data_in[17] ^ data_in[18] ^ data_in[19] ^ data_in[20] ^ data_in[21] ^ data_in[22] ^ data_in[23] ^ data_in[24] ^ data_in[25] ^ data_in[26] ^ data_in[29] ^ data_in[30] ^ data_in[31];
	end

	always @ (posedge clk) begin
		if(reset) begin
			lfsr_q	<= {16{1'b1}};
		end
		else begin
			lfsr_q	<= crc_en ? lfsr_c : lfsr_q;
		end
	end
	
endmodule
