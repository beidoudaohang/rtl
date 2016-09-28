//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : ctrl_ch_det
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2013/9/10 14:32:56	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//`include			"ctrl_ch_det_def.vh"
//���浥λ/����
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
