//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : freq_change
//  -- �����       : ������
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- ������       :| 2016/3/8 17:11:09	:|  ��ʼ�汾
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

module data_fix # (
	parameter	DATA_WD_128		= 128,
	parameter	DATA_WD_64		= 64
	)
	(
	input							clk_pix				,
	input							reset_pix			,	//δʹ��
	input							i_fval				,
	input							i_data_valid		,
	input	[DATA_WD_128-1:0]		iv_data				,
	input							clk_pix_2x			,
	input							reset_pix_2x		,	//δʹ��

//	input							i_acquisition_start	,	//�����źţ�0-ͣ�ɣ�1-����
//	input							i_stream_enable		,	//��ʹ���ź�
//	input							i_encrypt_state		,	//����ͨ·�����dna ʱ���򣬼���״̬�����ܲ�ͨ���������ͼ��

	output							o_fval				,
	output							o_data_valid		,
	output	[DATA_WD_64-1:0]		ov_data
	);


	//	ref signals

	reg		[7:0]					fval_shift_out	= 8'b0	;
	reg		[1:0]					fval_shift_in	= 2'b0	;
	reg								reset_fifo		= 1'b0	;


	change_fifo
	change_fifo_inst (
	  .rst			(reset_fifo					), 		// input rst
	  .wr_clk		(clk_pix					), 		// input wr_clk
	  .rd_clk		(clk_pix_2x					), 		// input rd_clk
	  .din			({i_data_valid,iv_data[DATA_WD_64-1:0],i_data_valid,iv_data[DATA_WD_128-1:DATA_WD_64]}),// input [130 : 0] din
	  .wr_en		(1'b1						), 		// input wr_en
	  .rd_en		(1'b1						), 		// input rd_en
	  .dout			({o_data_valid,ov_data}		),		// output [64 : 0] dout
	  .full			(							), 		// output full
	  .empty		(							) 		// output empty
	);


	always @ (posedge clk_pix_2x) begin
		fval_shift_out <= {fval_shift_out[6:0],i_fval};
	end

	assign	o_fval = fval_shift_out[7];

	//  -------------------------------------------------------------------------------------
	//	����Ч�ź������ظ�λfifo
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		fval_shift_in <= {fval_shift_in[0],i_fval};
	end

	always @ (posedge clk_pix) begin
		if (fval_shift_in==2'b1) begin
			reset_fifo <= 1'b1;
		end
		else begin
			reset_fifo <= 1'b0;
		end
	end



endmodule