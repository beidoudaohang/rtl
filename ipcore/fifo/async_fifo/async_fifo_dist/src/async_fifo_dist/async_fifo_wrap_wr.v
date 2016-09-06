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
//  -- Michael      | 2016/09/06 10:52:45	|
//-------------------------------------------------------------------------------------------------
//`include			"_def.v"
//time unit/precision
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------


module async_fifo_wrap_wr # (
	parameter			ADDR_WIDTH 			= 6			//���λ��ַ�����жϿ�����־��������fifo��ַ����� 5-���16 6-���32 7-���64
	)
	(
	input							reset_async		,	//�첽��λ
	//дʱ����
	////fifo���
	input							clk				,	//ʱ��
	input							i_wr_en			,	//fifoдʹ��
	output							o_fifo_full		,	//fifo����־
	////dpram���
	output	[ADDR_WIDTH-1:0]		ov_wr_addr_gray	,	//д��ַ�ĸ����룬дʱ����
	output	[ADDR_WIDTH-2:0]		ov_wr_addr_dpram,	//д��ַ��2�����룬дʱ���򣬴��ݵ�dpram�У��ȸ�������һλ
	output							o_wr_en			,	//dpram��дʹ���ź�
	//��ʱ����
	input	[ADDR_WIDTH-1:0]		iv_rd_addr_gray		//����ַ�ĸ����룬��ʱ����
	);

	//	ref signals
	wire							reset_sync		;
	wire	[ADDR_WIDTH-1:0]		wv_rd_addr_bin	;
	wire	[ADDR_WIDTH-1:0]		wv_wr_addr_bin	;

	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	��λ
	//  -------------------------------------------------------------------------------------
	rst_sync # (
	.RESET_LENGTH	(2			)
	)
	rst_sync_inst (
	.clk			(clk		),
	.reset_in		(reset_async),
	.reset_out		(reset_sync	)
	);

	//  -------------------------------------------------------------------------------------
	//	����ַ�Ӹ������Ϊ2���ƣ��Ӷ�ʱ����任��дʱ����
	//  -------------------------------------------------------------------------------------
	gray2bin # (
	.DATA_WIDTH		(ADDR_WIDTH		),
	.TIME_DOMAIN	("ASYNC"		),
	.RESET_VALUE	(0				)
	)
	gray2bin_inst (
	.clk			(clk			),
	.reset			(reset_sync		),
	.iv_gray		(iv_rd_addr_gray),
	.ov_bin			(wv_rd_addr_bin	)
	);

	//  -------------------------------------------------------------------------------------
	//	д�߼�
	//  -------------------------------------------------------------------------------------
	async_fifo_wr_logic # (
	.ADDR_WIDTH			(ADDR_WIDTH			)
	)
	async_fifo_wr_logic_inst (
	.clk				(clk				),
	.reset				(reset_sync			),
	.i_wr_en			(i_wr_en			),
	.iv_rd_addr_bin		(wv_rd_addr_bin		),
	.ov_wr_addr_bin		(wv_wr_addr_bin		),
	.ov_wr_addr_dpram	(ov_wr_addr_dpram	),
	.o_wr_en			(o_wr_en			),
	.o_fifo_full		(o_fifo_full		)
	);

	//  -------------------------------------------------------------------------------------
	//	д��ַ 2���Ʊ�Ϊ�����룬ʱ���򲻱�
	//  -------------------------------------------------------------------------------------
	bin2gray # (
	.DATA_WIDTH		(ADDR_WIDTH		),
	.TIME_DOMAIN	("SYNC"			),
	.RESET_VALUE	(1				)
	)
	bin2gray_inst (
	.clk			(clk			),
	.reset			(reset_sync		),
	.iv_bin			(wv_wr_addr_bin	),
	.ov_gray		(ov_wr_addr_gray)
	);


endmodule
