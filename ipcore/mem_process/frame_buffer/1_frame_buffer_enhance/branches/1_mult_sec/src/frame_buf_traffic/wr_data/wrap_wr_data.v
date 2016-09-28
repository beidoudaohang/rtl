//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : wrap_wr_data
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/6/9 16:24:48	:|  ��ʼ�汾
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
//`include			"wrap_wr_data_def.v"
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wrap_wr_data (
	input			clk		,
	input			reset	,
	input			i_fval	,
	input			i_dval	,
	input	[22:0]	iv_frame_size	,
	output	[31:0]	ov_image_dout
	);

	//	ref signals

	wire					crc_en	;
	wire	[31:0]			wv_image_data	;
	wire	[15:0]			wv_crc_out	;
	reg		[22:0]			frame_size_cnt	= 'b0;
	
	
	
	//	ref ARCHITECTURE


	gen_wr_data gen_wr_data_inst (
	.clk			(clk	),
	.ov_image_data	(wv_image_data	)
	);


	assign	crc_en	= i_fval&i_dval;
	crc_16 crc_16_inst (
	.reset			(reset | !i_fval),
	.clk			(clk			),
	.data_in		(wv_image_data	),
	.crc_en			(crc_en			),
	.crc_out		(wv_crc_out		)
	);
	
	always @ (posedge clk) begin
		if(i_fval == 1'b0) begin
			frame_size_cnt	<= 23'b0;
		end
		else begin
			if(i_dval == 1'b1) begin
				frame_size_cnt	<= frame_size_cnt + 1'b1;
			end
		end
	end

	assign	crc_switch	= (frame_size_cnt == iv_frame_size) ? 1'b1 : 1'b0	;
	assign	ov_image_dout	= crc_switch ? {wv_crc_out,wv_crc_out} : wv_image_data;
	

endmodule
