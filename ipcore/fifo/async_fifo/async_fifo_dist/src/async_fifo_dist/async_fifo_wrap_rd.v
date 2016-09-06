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


module async_fifo_wrap_rd # (
	parameter					ADDR_WIDTH	= 6			//���λ��ַ�����жϿ�����־��������fifo��ַ����� 6-���32 7-���64
	)
	(
	input							reset_async		,	//�첽��λ
	//��ʱ����
	//--fifo���
	input							clk				,	//ʱ��
	input							i_rd_en			,	//fifo��ʹ��
	output							o_fifo_empty	,	//fifo�ձ�־
	//--dpram���
	output	[ADDR_WIDTH-1:0]		ov_rd_addr_gray	,	//����ַ�ĸ����룬��ʱ����
	output	[ADDR_WIDTH-2:0]		ov_rd_addr_dpram,	//����ַ��2�����룬��ʱ���򣬴��ݵ�dpram�У��ȸ�������һλ
	output							o_rd_en			,	//dpram�Ķ�ʹ���ź�
	//дʱ����
	input	[ADDR_WIDTH-1:0]		iv_wr_addr_gray		//д��ַ�ĸ����룬дʱ����

	);

	//	ref signals
	wire							reset_sync		;
	wire	[ADDR_WIDTH-1:0]		wv_wr_addr_bin	;
	wire	[ADDR_WIDTH-1:0]		wv_rd_addr_bin	;



	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	��λ����ʱҪ�㹻������Ϊ��дʱ���򴫵ݹ����ĵ�ַҪ��3�Ĳ��ܵ�дʱ����
	//  -------------------------------------------------------------------------------------
	rst_sync # (
	.RESET_LENGTH	(4			)
	)
	rst_sync_inst (
	.clk			(clk		),
	.reset_in		(reset_async),
	.reset_out		(reset_sync	)
	);

	//  -------------------------------------------------------------------------------------
	//	дָ��Ӹ������Ϊ2���ƣ���дʱ����任����ʱ����
	//  -------------------------------------------------------------------------------------
	gray2bin # (
	.DATA_WIDTH		(ADDR_WIDTH		),
	.TIME_DOMAIN	("ASYNC"		),
	.RESET_VALUE	(1				)
	)
	gray2bin_inst (
	.clk			(clk			),
	.reset			(reset_sync		),
	.iv_gray		(iv_wr_addr_gray),
	.ov_bin			(wv_wr_addr_bin	)
	);

	//  -------------------------------------------------------------------------------------
	//	���߼�
	//  -------------------------------------------------------------------------------------
	async_fifo_rd_logic # (
	.ADDR_WIDTH			(ADDR_WIDTH			)
	)
	async_fifo_rd_logic_inst (
	.clk				(clk				),
	.reset				(reset_sync			),
	.i_rd_en			(i_rd_en			),
	.iv_wr_addr_bin		(wv_wr_addr_bin		),
	.ov_rd_addr_bin		(wv_rd_addr_bin		),
	.ov_rd_addr_dpram	(ov_rd_addr_dpram	),
	.o_rd_en			(o_rd_en			),
	.o_fifo_empty		(o_fifo_empty		)
	);

	//  -------------------------------------------------------------------------------------
	//	��ָ�� 2���Ʊ�Ϊ�����룬ʱ���򲻱�
	//  -------------------------------------------------------------------------------------
	bin2gray # (
	.DATA_WIDTH		(ADDR_WIDTH	),
	.TIME_DOMAIN	("SYNC"		),
	.RESET_VALUE	(0			)
	)
	bin2gray_inst (
	.clk			(clk			),
	.reset			(reset_sync		),
	.iv_bin			(wv_rd_addr_bin	),
	.ov_gray		(ov_rd_addr_gray)
	);


endmodule
