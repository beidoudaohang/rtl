//-------------------------------------------------------------------------------------------------
//  -- Corporation  : MicroRTL.com
//  -- Email        : haitaox2013@gmail.com
//  -- Module       :
//-------------------------------------------------------------------------------------------------
//  -- Description  :
//
//-------------------------------------------------------------------------------------------------
//  -- Changelog    :
//  -- Author       | Date                  | Content
//  -- Michael      | 2014/4/8 15:26:47	|
//-------------------------------------------------------------------------------------------------
//`include			"_def.v"
//time unit/precision
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module async_fifo # (
	parameter			FIFO_WIDTH		= 8		,	//fifo ���ݿ��
	parameter			FIFO_DEPTH		= 16		//fifo ������ȣ�16 32 64
	)
	(
	input						reset_async		,	//�첽��λ�źţ���д���˶���Ը�λ��ͬ������
	//дʱ����
	input						clk_wr			,	//дʱ��
	input						i_wr_en			,	//дʹ��
	input	[FIFO_WIDTH-1:0]	iv_fifo_din		,	//д����
	output						o_fifo_full		,	//���ź�
	//��ʱ����
	input						clk_rd			,	//��ʱ��
	input						i_rd_en			,	//��ʹ��
	output	[FIFO_WIDTH-1:0]	ov_fifo_dout	,	//������
	output						o_fifo_empty		//���ź�
	);

	//	ref signals

	//	-------------------------------------------------------------------------------------
	//	��������addr��ַ���
	//	1.��д��ַ��λ��Ҫ����1bit����Ϊ�жϿ����ı�־
	//	2.ʵ�ʶ�дDPRAM�ĵ�ַ��cntҪ��1bit
	//	3.����xilinx �� dpram ��С��32��ȣ���˵�ַλ����С��6bit������msb������λ
	//	-------------------------------------------------------------------------------------
	parameter	MAX_ADDR_WIDTH	= (FIFO_DEPTH/33)+6;

	parameter	ADDR_WIDTH	= (FIFO_DEPTH==16) ? 5 : (FIFO_DEPTH==32) ? 6 : (FIFO_DEPTH==64) ? 7 : 7;

	wire	[ADDR_WIDTH-1:0]	wv_rd_addr_gray			;
	wire	[ADDR_WIDTH-1:0]	wv_wr_addr_gray			;
	wire	[ADDR_WIDTH-2:0]	wv_wr_addr_dpram		;
	wire	[ADDR_WIDTH-2:0]	wv_rd_addr_dpram		;

	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	FIFOд��������߼�
	//  -------------------------------------------------------------------------------------
	async_fifo_wrap_wr # (
	.ADDR_WIDTH			(ADDR_WIDTH			)
	)
	async_fifo_wrap_wr_inst (
	.reset_async		(reset_async		),
	.clk				(clk_wr				),
	.i_wr_en			(i_wr_en			),
	.o_fifo_full		(o_fifo_full		),
	.ov_wr_addr_gray	(wv_wr_addr_gray	),
	.ov_wr_addr_dpram	(wv_wr_addr_dpram	),
	.o_wr_en			(w_wr_en			),
	.iv_rd_addr_gray	(wv_rd_addr_gray	)
	);

	//  -------------------------------------------------------------------------------------
	//	FIFO����������߼�
	//  -------------------------------------------------------------------------------------
	async_fifo_wrap_rd # (
	.ADDR_WIDTH			(ADDR_WIDTH			)
	)
	async_fifo_wrap_rd_inst (
	.reset_async		(reset_async		),
	.clk				(clk_rd				),
	.i_rd_en			(i_rd_en			),
	.o_fifo_empty		(o_fifo_empty		),
	.ov_rd_addr_gray	(wv_rd_addr_gray	),
	.ov_rd_addr_dpram	(wv_rd_addr_dpram	),
	.o_rd_en			(					),
	.iv_wr_addr_gray	(wv_wr_addr_gray	)
	);

	//  -------------------------------------------------------------------------------------
	//	�洢��
	//  -------------------------------------------------------------------------------------
	dpram_dist # (
	.FIFO_WIDTH			(FIFO_WIDTH			),
	.ADDR_WIDTH			(ADDR_WIDTH			),
	.MAX_ADDR_WIDTH		(MAX_ADDR_WIDTH		)
	)
	dpram_dist_inst (
	.clk_wr				(clk_wr				),
	.i_wr				(w_wr_en			),
	.iv_wr_addr			(wv_wr_addr_dpram	),
	.iv_din				(iv_fifo_din		),
	.clk_rd				(clk_rd				),
	.iv_rd_addr			(wv_rd_addr_dpram	),
	.ov_dout			(ov_fifo_dout		)
	);

endmodule