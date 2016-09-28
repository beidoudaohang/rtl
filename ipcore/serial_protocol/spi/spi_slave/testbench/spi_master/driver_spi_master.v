//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : driver_spi_master
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/4/13 15:45:28	:|  ��ʼ�汾
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
`define		TESTCASE	testcase1
module driver_spi_master ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	��������
	//	-------------------------------------------------------------------------------------
	parameter	SPI_FIRST_DATA		= `TESTCASE.SPI_FIRST_DATA		;
	parameter	SPI_CS_POL			= `TESTCASE.SPI_CS_POL			;
	parameter	SPI_LEAD_TIME		= `TESTCASE.SPI_LEAD_TIME		;
	parameter	SPI_LAG_TIME		= `TESTCASE.SPI_LAG_TIME		;

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------
	wire					clk_fifo	;
	wire					reset_fifo	;
	wire					spi_clk		;

	//	-------------------------------------------------------------------------------------
	//	���
	//	-------------------------------------------------------------------------------------
	wire					o_cmd_fifo_full	;
	wire	[8:0]			ov_rdback_fifo_dout	;
	wire					o_rdback_fifo_empty	;
	wire					o_spi_clk	;
	wire					o_spi_cs	;
	wire					o_spi_mosi	;

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------
	assign	i_spi_miso		= `TESTCASE.spi_master_i_spi_miso	;
	assign	clk_fifo		= `TESTCASE.spi_master_clk_fifo		;
	assign	reset_fifo		= `TESTCASE.spi_master_reset_fifo	;
	assign	spi_clk			= `TESTCASE.spi_master_spi_clk		;

	//	-------------------------------------------------------------------------------------
	//	���� bfm
	//	-------------------------------------------------------------------------------------
	bfm_spi_master # (
	.SPI_FIRST_DATA		(SPI_FIRST_DATA	),
	.SPI_CS_POL			(SPI_CS_POL		),
	.SPI_LEAD_TIME		(SPI_LEAD_TIME	),
	.SPI_LAG_TIME		(SPI_LAG_TIME	)
	)
	bfm_spi_master (
	.cmd_fifo_full		(o_cmd_fifo_full		),
	.rdback_fifo_empty	(o_rdback_fifo_empty	),
	.rdback_fifo_dout	(ov_rdback_fifo_dout	),
	.clk_fifo			(clk_fifo				)
	);

	//	-------------------------------------------------------------------------------------
	//	����spi master
	//	-------------------------------------------------------------------------------------
	spi_master # (
	.SPI_FIRST_DATA			(SPI_FIRST_DATA	    ),
	.SPI_CS_POL				(SPI_CS_POL		    ),
	.SPI_LEAD_TIME			(SPI_LEAD_TIME		),
	.SPI_LAG_TIME			(SPI_LAG_TIME		)
	)
	spi_master_inst (
	.clk_fifo				(clk_fifo			),
	.reset_fifo				(reset_fifo			),
	.i_cmd_fifo_wr			(bfm_spi_master.i_cmd_fifo_wr		),
	.iv_cmd_fifo_din		(bfm_spi_master.iv_cmd_fifo_din		),
	.o_cmd_fifo_full		(o_cmd_fifo_full	),
	.i_rdback_fifo_rd		(bfm_spi_master.i_rdback_fifo_rd	),
	.ov_rdback_fifo_dout	(ov_rdback_fifo_dout),
	.o_rdback_fifo_empty	(o_rdback_fifo_empty),
	.spi_clk				(spi_clk			),
	.o_spi_clk				(o_spi_clk			),
	.o_spi_cs				(o_spi_cs			),
	.o_spi_mosi				(o_spi_mosi			),
	.i_spi_miso				(i_spi_miso			)
	);

endmodule
