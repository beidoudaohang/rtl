//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : clock_reset
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/6/5 14:07:54	:|  ��ʼ�汾
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

module clock_reset # (
	parameter		DDR3_MEMCLK_FREQ	= 320	//Memory data transfer clock frequency DDR3-640:3125 DDR3-660:3030 DDR3-720:2778 DDR3-800:2500
	)
	(
	//  -------------------------------------------------------------------------------------
	//	�ⲿ��������
	//  -------------------------------------------------------------------------------------
	input			clk_osc				,	//�������ţ�40MHz�����ⲿ����
	//  -------------------------------------------------------------------------------------
	//	ʱ�Ӹ�λ���
	//  -------------------------------------------------------------------------------------
	//mcb
	output			async_rst			,	//�첽��λ��ֻ�ṩ��MCB
	output			sysclk_2x			,	//����ʱ�ӣ�ֻ�ṩ��MCB
	output			sysclk_2x_180		,	//����ʱ�ӣ�ֻ�ṩ��MCB
	output 			pll_ce_0			,	//����Ƭѡ��ֻ�ṩ��MCB
	output 			pll_ce_90			,	//����Ƭѡ��ֻ�ṩ��MCB
	output			mcb_drp_clk			,	//calib�߼�ʱ�ӣ�ֻ�ṩ��MCB
	output			bufpll_mcb_lock		,	//bufpll_mcb �����źţ�ֻ�ṩ��MCB
	//frame buf
	output			clk_frame_buf		,	//֡��ʱ�ӣ���gpifʱ����ͬһ��Դͷ��Ϊ�˱�֤ģ������ԣ�֡�滹��ʹ�õ�����ʱ������
	output			reset_frame_buf			//֡��ʱ�ӵĸ�λ�źţ���gpifʱ����ĸ�λ�ź���ͬһ��Դͷ
	);

	//	ref signals

	//PLL�Ĳ���
	parameter	DDR3_PLL_CLKIN_PERIOD	= 25000;
	parameter	DDR3_PLL_CLKOUT0_DIVIDE	= 1;
	parameter	DDR3_PLL_CLKOUT1_DIVIDE	= 1;
	parameter	DDR3_PLL_CLKOUT2_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 16	: ((DDR3_MEMCLK_FREQ==360) ? 16	: ((DDR3_MEMCLK_FREQ==330) ? 16	: ((DDR3_MEMCLK_FREQ==320) ? 16	: 16)));
	parameter	DDR3_PLL_CLKOUT3_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 5	: ((DDR3_MEMCLK_FREQ==360) ? 4	: ((DDR3_MEMCLK_FREQ==330) ? 5	: ((DDR3_MEMCLK_FREQ==320) ? 5	: 5)));
	parameter	DDR3_PLL_CLKOUT4_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 5	: ((DDR3_MEMCLK_FREQ==360) ? 5	: ((DDR3_MEMCLK_FREQ==330) ? 8	: ((DDR3_MEMCLK_FREQ==320) ? 5	: 5)));
	parameter	DDR3_PLL_CLKOUT5_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 5	: ((DDR3_MEMCLK_FREQ==360) ? 5	: ((DDR3_MEMCLK_FREQ==330) ? 8	: ((DDR3_MEMCLK_FREQ==320) ? 5	: 5)));
	parameter	DDR3_PLL_CLKFBOUT_MULT	= (DDR3_MEMCLK_FREQ==400) ? 20	: ((DDR3_MEMCLK_FREQ==360) ? 18	: ((DDR3_MEMCLK_FREQ==330) ? 33	: ((DDR3_MEMCLK_FREQ==320) ? 16	: 16)));
	parameter	DDR3_PLL_DIVCLK_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 1	: ((DDR3_MEMCLK_FREQ==360) ? 1	: ((DDR3_MEMCLK_FREQ==330) ? 2	: ((DDR3_MEMCLK_FREQ==320) ? 1	: 1)));

	wire				clk_osc_ibufg		;
	wire				clk_osc_bufio2		;
	reg		[3:0]		pwr_cnt				= 4'b0;
	wire				pwr_reset			;
	wire				pll_lock			;

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***����ʱ�Ӻ��ϵ縴λ***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	�Ⱦ���ibufg������
	//  -------------------------------------------------------------------------------------
	IBUFG ibufg_osc_inst (
	.I	(clk_osc		),
	.O	(clk_osc_ibufg	)
	);

	//  -------------------------------------------------------------------------------------
	//	�پ���bufio2��������20MHz
	//  -------------------------------------------------------------------------------------
	BUFIO2 #(
	.DIVIDE			(1				),	// DIVCLK divider (1,3-8)
	.DIVIDE_BYPASS	("TRUE"			),	// Bypass the divider circuitry (TRUE/FALSE)
	.I_INVERT		("FALSE"		),	// Invert clock (TRUE/FALSE)
	.USE_DOUBLER	("FALSE"		)	// Use doubler circuitry (TRUE/FALSE)
	)
	BUFIO2_inst (
	.I				(clk_osc_ibufg	),	// 1-bit input: Clock input (connect to IBUFG)
	.DIVCLK			(clk_osc_bufio2	),	// 1-bit output: Divided clock output
	.IOCLK			(				),	// 1-bit output: I/O output clock
	.SERDESSTROBE	(				)	// 1-bit output: Output SERDES strobe (connect to ISERDES2/OSERDES2)
	);

	//  -------------------------------------------------------------------------------------
	//	�ϵ縴λ�߼�
	//	1.fpga ���سɹ�֮�󣬻�� dcm pll������λ�źţ���λ�źſ����8��ʱ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_osc_ibufg) begin
		if(pwr_cnt[3] == 1'b0) begin
			pwr_cnt	<= pwr_cnt + 1'b1;
		end
	end
	assign	pwr_reset	= !pwr_cnt[3];

	//  ===============================================================================================
	//	ref ***PLL & DCM***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref ddr3 pll
	//	1.��PLL��Ҫ��������MCB����Ҫ��ʱ�ӣ� sysclk_2x sysclk_2x_180 �Ǹ���ʱ�ӣ���ͨ�߼�������
	//	2.mcb_drp_clk ������ʱ�ӣ�MCB�е�Calibration�߼�ʹ�õ�ʱ�ӣ����Ƶ�ʿ��Դﵽ100MHz���ң������߼�Ҳ����ʹ��
	//	3.clk_out3 4 5 ��PLL����������˿ڣ�Ŀǰû���õ�
	//  -------------------------------------------------------------------------------------
	infrastructure # (
	.C_INCLK_PERIOD  		(DDR3_PLL_CLKIN_PERIOD		),
	.C_CLKOUT0_DIVIDE		(DDR3_PLL_CLKOUT0_DIVIDE	),
	.C_CLKOUT1_DIVIDE		(DDR3_PLL_CLKOUT1_DIVIDE	),
	.C_CLKOUT2_DIVIDE		(DDR3_PLL_CLKOUT2_DIVIDE	),
	.C_CLKOUT3_DIVIDE		(DDR3_PLL_CLKOUT3_DIVIDE	),
	.C_CLKOUT4_DIVIDE		(DDR3_PLL_CLKOUT4_DIVIDE	),
	.C_CLKOUT5_DIVIDE		(DDR3_PLL_CLKOUT5_DIVIDE	),
	.C_CLKFBOUT_MULT 		(DDR3_PLL_CLKFBOUT_MULT		),
	.C_DIVCLK_DIVIDE 		(DDR3_PLL_DIVCLK_DIVIDE		)
	)
	ddr3_pll_inst (
	.sys_clk				(clk_osc_bufio2				),
	.sys_rst				(pwr_reset					),
	.async_rst				(async_rst					),
	.sysclk_2x				(sysclk_2x					),
	.sysclk_2x_180			(sysclk_2x_180				),
	.pll_ce_0				(pll_ce_0					),
	.pll_ce_90				(pll_ce_90					),
	.mcb_drp_clk			(mcb_drp_clk				),
	.bufpll_mcb_lock		(bufpll_mcb_lock			),
	.pll_lock				(pll_lock					),
	.clk_out3				(							),
	.clk_out4				(							),
	.clk_out5				(							)
	);



	//  ===============================================================================================
	//	ref ***��λ����***
	//	1.�����첽��λ��ͬ���ͷŵĴ�����
	//  ===============================================================================================


	//  ===============================================================================================
	//	ref ***ʱ�����***
	//  ===============================================================================================
	//  ===============================================================================================
	//	ref ***��λ���***
	//  ===============================================================================================




endmodule