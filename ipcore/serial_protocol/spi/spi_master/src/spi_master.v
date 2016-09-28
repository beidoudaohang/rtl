//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : spi_master
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/3/4 16:05:54	:|  ��ʼ�汾
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

module spi_master # (
	parameter	SPI_FIRST_DATA		= "MSB"	,	//"MSB" or "LSB"
	parameter	SPI_CS_POL			= "LOW"	,	//"HIGH" or "LOW" ��cs��Чʱ�ĵ�ƽ
	parameter	SPI_LEAD_TIME		= 1		,	//��ʼʱ��CS �� CLK �ľ��룬��λ��ʱ�����ڣ���ѡ 1 2 3
	parameter	SPI_LAG_TIME		= 1			//����ʱ��CS �� CLK �ľ��룬��λ��ʱ�����ڣ���ѡ 1 2 3
	)
	(
	//ʱ�Ӻ͸�λ
	input				clk_fifo			,	//cmd fifo дʱ��
	input				reset_fifo			,	//cmd fifo ��λ
	//cmd fifo����
	input				i_cmd_fifo_wr		,	//cmd fifoд�ź�
	input	[8:0]		iv_cmd_fifo_din		,	//cmd fifoд����
	output				o_cmd_fifo_full		,	//cmd fifo���ź�
	//rdback fifo����
	input				i_rdback_fifo_rd	,	//rdback fifo���ź�
	output	[8:0]		ov_rdback_fifo_dout	,	//rdback fifo��������
	output				o_rdback_fifo_empty	,	//rdback fifo���ź�
	//spi�ӿ�ʱ��
	input				spi_clk				,	//ģ�鹤��ʱ��
	//spi�ӿ��ź� 4 wire
	output				o_spi_clk			,	//spi ʱ��
	output				o_spi_cs			,	//spi Ƭѡ
	output				o_spi_mosi			,	//�������������
	input				i_spi_miso				//�����룬�����
	);

	//	ref signals
	wire				w_cmd_fifo_rd		;
	wire				w_cmd_fifo_empty	;
	wire	[8:0]		wv_cmd_fifo_dout	;
	wire				w_rdback_fifo_wr	;
	wire	[7:0]		wv_rdback_fifo_din	;

	//	ref ARCHITECTURE


	distri_fifo_w9d32 cmd_fifo_inst (
	.rst		(reset_fifo			),
	.wr_clk		(clk_fifo			),
	.wr_en		(i_cmd_fifo_wr		),
	.full		(o_cmd_fifo_full	),
	.din		(iv_cmd_fifo_din	),
	.rd_clk		(spi_clk			),
	.rd_en		(w_cmd_fifo_rd		),
	.empty		(w_cmd_fifo_empty	),
	.dout		(wv_cmd_fifo_dout	)
	);

	distri_fifo_w9d32 rdback_fifo_inst (
	.rst		(reset_fifo			),
	.wr_clk		(spi_clk			),
	.wr_en		(w_rdback_fifo_wr	),
	.full		(w_rdback_fifo_full	),
	.din		({1'b0,wv_rdback_fifo_din}	),
	.rd_clk		(clk_fifo			),
	.rd_en		(i_rdback_fifo_rd	),
	.empty		(o_rdback_fifo_empty),
	.dout		(ov_rdback_fifo_dout)
	);

	spi_master_core # (
	.SPI_FIRST_DATA		(SPI_FIRST_DATA	),
	.SPI_CS_POL			(SPI_CS_POL		),
	.SPI_LEAD_TIME		(SPI_LEAD_TIME	),
	.SPI_LAG_TIME		(SPI_LAG_TIME	)
	)
	spi_master_core_inst (
	.clk				(spi_clk			),
	.o_spi_clk			(o_spi_clk			),
	.o_spi_cs			(o_spi_cs			),
	.o_spi_mosi			(o_spi_mosi			),
	.i_spi_miso			(i_spi_miso			),
	.o_cmd_fifo_rd		(w_cmd_fifo_rd		),
	.iv_cmd_fifo_dout	(wv_cmd_fifo_dout	),
	.i_cmd_fifo_empty	(w_cmd_fifo_empty	),
	.o_rdback_fifo_wr	(w_rdback_fifo_wr	),
	.ov_rdback_fifo_din	(wv_rdback_fifo_din	)
	);



endmodule
