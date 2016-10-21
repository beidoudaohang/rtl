//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : driver_clock_reset
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 	:|  ��ʼ�汾
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
`define		TESTCASE	testcase_1

module driver_clock_reset ();


	//	ref signals


	parameter	DDR3_MEMCLK_FREQ		= `TESTCASE.DDR3_MEMCLK_FREQ		;


	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------
	wire	clk_osc				;

	//	-------------------------------------------------------------------------------------
	//	���
	//	-------------------------------------------------------------------------------------
	wire	async_rst				;
	wire	sysclk_2x				;
	wire	sysclk_2x_180			;
	wire	pll_ce_0				;
	wire	pll_ce_90				;
	wire	mcb_drp_clk			;
	wire	bufpll_mcb_lock		;

	//	ref ARCHITECTURE


	//	-------------------------------------------------------------------------------------
	//	���������ź�
	//	-------------------------------------------------------------------------------------
	assign	clk_osc	= `TESTCASE.clk_osc;
	//	-------------------------------------------------------------------------------------
	//  clock_reset����
	//	-------------------------------------------------------------------------------------
	clock_reset # (
	.DDR3_MEMCLK_FREQ		(DDR3_MEMCLK_FREQ		)
	)
	clock_reset_inst (
	.clk_osc				(clk_osc				),
	.async_rst				(async_rst				),
	.sysclk_2x				(sysclk_2x				),
	.sysclk_2x_180			(sysclk_2x_180			),
	.pll_ce_0				(pll_ce_0				),
	.pll_ce_90				(pll_ce_90				),
	.mcb_drp_clk			(mcb_drp_clk			),
	.bufpll_mcb_lock		(bufpll_mcb_lock		)
	);

endmodule