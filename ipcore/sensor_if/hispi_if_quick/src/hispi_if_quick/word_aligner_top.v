//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : word_aligner_top
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/10/27 13:29:41	:|  ��ʼ�汾
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

module word_aligner_top # (
	parameter		SER_FIRST_BIT			= "LSB"		,	//"LSB" or "MSB" , first bit to the receiver
	parameter		DESER_WIDTH				= 6			,	//�⴮����
	parameter		CHANNEL_NUM				= 4				//ͨ����
	)
	(
	input										clk				,	//ʱ��
	input										reset			,	//��λ
	input	[DESER_WIDTH*CHANNEL_NUM-1:0]		iv_data			,	//���벢������
	output										o_clk_en		,	//ʱ��ʹ���ź�
	output										o_sync			,	//�������ݱ�ʶ
	output	[2*DESER_WIDTH*CHANNEL_NUM-1:0]		ov_data				//�������
	);

	//	ref signals
	wire	[CHANNEL_NUM-1:0]			w_clk_en	;
	wire	[CHANNEL_NUM-1:0]			w_sync	;


	//	ref ARCHITECTURE
	genvar	i;
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			word_aligner # (
			.SER_FIRST_BIT	(SER_FIRST_BIT	),
			.DESER_WIDTH	(DESER_WIDTH	)
			)
			word_aligner_inst (
			.clk			(clk		),
			.reset			(reset		),
			.iv_data		(iv_data[(i+1)*DESER_WIDTH-1:i*DESER_WIDTH]	),
			.o_clk_en		(w_clk_en[i]	),
			.o_sync			(w_sync[i]		),
			.ov_data		(ov_data[(i+1)*(2*DESER_WIDTH)-1:i*(2*DESER_WIDTH)]	)
			);
		end
	endgenerate
	assign	o_clk_en	= w_clk_en[0];
	assign	o_sync		= w_sync[0];


endmodule
