//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : top_sine
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/5/21 13:54:44	:|  ��ʼ�汾
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
//`include			"top_sine_def.v"
//���浥λ/����
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

	// �ж����ֵ���������Ǹ�����
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
