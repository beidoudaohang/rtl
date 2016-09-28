//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : format_python
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/10/14 11:40:28	:|  ��ʼ�汾
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

module format_python # (
	parameter			DATA_WIDTH			= 8		,	//����λ��
	parameter			CHANNEL_NUM			= 4			//ͨ����
	)
	(
	input										clk							,	//ʱ��
	input										i_fval						,	//����Ч
	input										i_lval						,	//����Ч
	input	[DATA_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data					,	//��������
	output										o_fval						,	//����Ч
	output										o_lval						,	//����Ч
	output	[DATA_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data						//��������
	);


	//	ref signals

	localparam		TR	= (DATA_WIDTH==10) ? 10'h3a6 : 8'he9;

	reg		[DATA_WIDTH*CHANNEL_NUM-1:0]		data_reg	= 'b0;
	reg											fval_dly	= 1'b0;
	reg											lval_dly	= 1'b0;


	//	ref ARCHITECTURE

	always @ (posedge clk) begin
		if(i_fval==1'b0 || i_lval==1'b0) begin
			data_reg	<= {CHANNEL_NUM{TR}};
		end
		else begin
			data_reg	<= iv_pix_data;
		end
	end
	assign	ov_pix_data	= data_reg;

	always @ (posedge clk) begin
		fval_dly	<= i_fval;
	end
	assign	o_fval	= fval_dly;

	always @ (posedge clk) begin
		lval_dly	<= i_lval;
	end
	assign	o_lval	= lval_dly;


endmodule
