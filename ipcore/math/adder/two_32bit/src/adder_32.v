//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : adder_32
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/10/22 16:36:21	:|  ��ʼ�汾
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
//���浥λ/����
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
		if(!i_stream_enable) begin		// ����ģ�鱣֤ i_stream_enable ����clkʱ����
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
		if(!i_stream_enable) begin		// ����ģ�鱣֤ i_stream_enable ����clkʱ����
			blockid_high32	<= 32'hffff_ffff;
		end
		else if(adder_en) begin
			blockid_high32	<= blockid_high32 + 1'h1;
		end
	end
	assign	ov_blockid	= {blockid_high32,blockid_low32};



endmodule
