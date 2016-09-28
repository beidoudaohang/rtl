//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : pulse_filter_buffer
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/2/11 14:49:15	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : ram ����ģ��
//              1)  : ����4��ram��ÿ��ram�Ŀ����10bit�������3072��ÿ��ramռ���� 3 �� ram16k
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module pulse_filter_buffer (
	input			clk					,	//ʱ��
	input	[3:0]	iv_buffer_wr_en		,	//дʹ��
	input	[11:0]	iv_buffer_wr_addr	,	//д��ַ
	input	[9:0]	iv_buffer_wr_din	,	//д����
	input			i_reset_buffer		,	//��λ
	input	[3:0]	iv_buffer_rd_en		,	//��ʹ��
	input	[11:0]	iv_buffer_rd_addr	,	//����ַ
	output	[9:0]	ov_buffer_rd_dout0	,	//������0
	output	[9:0]	ov_buffer_rd_dout1	,	//������1
	output	[9:0]	ov_buffer_rd_dout2	,	//������2
	output	[9:0]	ov_buffer_rd_dout3		//������3
	);

	//	ref signals



	//	ref ARCHITECTURE

	pulse_filter_ram_w10d3072 pulse_filter_ram_w10d3072_inst0 (
	.clka		(clk				),
	.ena		(iv_buffer_wr_en[0]	),
	.wea		(iv_buffer_wr_en[0]	),
	.addra		(iv_buffer_wr_addr	),
	.dina		(iv_buffer_wr_din	),
	.clkb		(clk				),
	.rstb		(i_reset_buffer		),
	.enb		(iv_buffer_rd_en[0]	),
	.addrb		(iv_buffer_rd_addr	),
	.doutb		(ov_buffer_rd_dout0	)
	);

	pulse_filter_ram_w10d3072 pulse_filter_ram_w10d3072_inst1 (
	.clka		(clk				),
	.ena		(iv_buffer_wr_en[1]	),
	.wea		(iv_buffer_wr_en[1]	),
	.addra		(iv_buffer_wr_addr	),
	.dina		(iv_buffer_wr_din	),
	.clkb		(clk				),
	.rstb		(i_reset_buffer		),
	.enb		(iv_buffer_rd_en[1]	),
	.addrb		(iv_buffer_rd_addr	),
	.doutb		(ov_buffer_rd_dout1	)
	);

	pulse_filter_ram_w10d3072 pulse_filter_ram_w10d3072_inst2 (
	.clka		(clk				),
	.ena		(iv_buffer_wr_en[2]	),
	.wea		(iv_buffer_wr_en[2]	),
	.addra		(iv_buffer_wr_addr	),
	.dina		(iv_buffer_wr_din	),
	.clkb		(clk				),
	.rstb		(i_reset_buffer		),
	.enb		(iv_buffer_rd_en[2]	),
	.addrb		(iv_buffer_rd_addr	),
	.doutb		(ov_buffer_rd_dout2	)
	);

	pulse_filter_ram_w10d3072 pulse_filter_ram_w10d3072_inst3 (
	.clka		(clk				),
	.ena		(iv_buffer_wr_en[3]	),
	.wea		(iv_buffer_wr_en[3]	),
	.addra		(iv_buffer_wr_addr	),
	.dina		(iv_buffer_wr_din	),
	.clkb		(clk				),
	.rstb		(i_reset_buffer		),
	.enb		(iv_buffer_rd_en[3]	),
	.addrb		(iv_buffer_rd_addr	),
	.doutb		(ov_buffer_rd_dout3	)
	);



endmodule
