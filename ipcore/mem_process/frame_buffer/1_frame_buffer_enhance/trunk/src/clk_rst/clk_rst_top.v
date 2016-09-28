//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : clk_rst_top
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
//`include			"frame_buffer_def.v"
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module clk_rst_top # (
	parameter	DDR3_MEMCLK_FREQ	= 320			//Memory data transfer clock frequency DDR3-640:3125 DDR3-660:3030 DDR3-720:2778 DDR3-800:2500
	)
	(
	input			clk_osc				,
	//mcb clk
	output			async_rst			,//��λ�����ֻ�ṩ��MCB
	output			sysclk_2x			,//����ʱ�ӣ�ֻ�ṩ��MCB
	output			sysclk_2x_180		,//����ʱ�ӣ�ֻ�ṩ��MCB
	output 			pll_ce_0			,//����Ƭѡ��ֻ�ṩ��MCB
	output 			pll_ce_90			,//����Ƭѡ��ֻ�ṩ��MCB
	output			mcb_drp_clk			,//calib�߼�ʱ��
	output			bufpll_mcb_lock		,//bufpll_mcb �����ź�
	//clk_frame_buf
	output			clk_frame_buf		,
	output			reset_frame_buf		,
	//pix clk
	output			o_clk_pix			,
	output			o_reset_pix

	);

	//	ref signals
	wire			clk_osc_ibufg	;
	reg		[3:0]	pwr_cnt 	= 4'b0;
	wire			clk_pix	;
	wire			dcm_locked	;
	wire			pll_lock	;

	reg		[1:0]	reset_cnt_pix 	= 2'b11;
	reg		[1:0]	reset_cnt_frame_buf 	= 2'b11;
	
	parameter	DDR3_PLL_CLKIN_PERIOD	= 25000;
	parameter	DDR3_PLL_CLKOUT0_DIVIDE	= 1;
	parameter	DDR3_PLL_CLKOUT1_DIVIDE	= 1;
	parameter	DDR3_PLL_CLKOUT2_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 8 : ((DDR3_MEMCLK_FREQ==360) ? 8 : ((DDR3_MEMCLK_FREQ==330) ? 8 : ((DDR3_MEMCLK_FREQ==320) ? 8 : 8)));
	parameter	DDR3_PLL_CLKOUT3_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 5 : ((DDR3_MEMCLK_FREQ==360) ? 4 : ((DDR3_MEMCLK_FREQ==330) ? 7 : ((DDR3_MEMCLK_FREQ==320) ? 7 : 7)));
	parameter	DDR3_PLL_CLKOUT4_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 5 : ((DDR3_MEMCLK_FREQ==360) ? 5 : ((DDR3_MEMCLK_FREQ==330) ? 8 : ((DDR3_MEMCLK_FREQ==320) ? 5 : 5)));
	parameter	DDR3_PLL_CLKOUT5_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 5 : ((DDR3_MEMCLK_FREQ==360) ? 5 : ((DDR3_MEMCLK_FREQ==330) ? 8 : ((DDR3_MEMCLK_FREQ==320) ? 5 : 5)));
	parameter	DDR3_PLL_CLKFBOUT_MULT	= (DDR3_MEMCLK_FREQ==400) ? 20 : ((DDR3_MEMCLK_FREQ==360) ? 18 : ((DDR3_MEMCLK_FREQ==330) ? 33 : ((DDR3_MEMCLK_FREQ==320) ? 16 : 16)));
	parameter	DDR3_PLL_DIVCLK_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 1 : ((DDR3_MEMCLK_FREQ==360) ? 1 : ((DDR3_MEMCLK_FREQ==330) ? 2 : ((DDR3_MEMCLK_FREQ==320) ? 1 : 1)));

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ʱ�ӹ���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ibufg ����
	//  -------------------------------------------------------------------------------------
	IBUFG ibufg_inst (
	.I	(clk_osc		),
	.O	(clk_osc_ibufg	)
	);

	//  -------------------------------------------------------------------------------------
	//	�ϵ縴λ�߼�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_osc_ibufg) begin
		if(pwr_cnt[3] == 1'b0) begin
			pwr_cnt	<= pwr_cnt + 1'b1;
		end
	end
	assign	pwr_reset	= !pwr_cnt[3];


	//  -------------------------------------------------------------------------------------
	//	ddr3 pll
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
	.sys_clk				(clk_osc_ibufg				),
	.sys_rst				(pwr_reset					),
	.async_rst				(async_rst					),
	.sysclk_2x				(sysclk_2x					),
	.sysclk_2x_180			(sysclk_2x_180				),
	.pll_ce_0				(pll_ce_0					),
	.pll_ce_90				(pll_ce_90					),
	.mcb_drp_clk			(mcb_drp_clk				),
	.bufpll_mcb_lock		(bufpll_mcb_lock			),
	.pll_lock				(pll_lock					),
	.clk_out3				(clk_frame_buf				),
	.clk_out4				(					),
	.clk_out5				(					)
	);


	//  -------------------------------------------------------------------------------------
	//	72MHz dcm
	//  -------------------------------------------------------------------------------------
	dcm dcm_inst (
	.clk_in		(clk_osc_ibufg	),
	.dcm_reset	(pwr_reset		),
	.clk_fx_out	(clk_pix		),
	.clk_2x_out	(		),
	.locked		(dcm_locked		)
	);
	assign	o_clk_pix	= clk_pix;

	//  ===============================================================================================
	//	��λ����
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	clk pix ��Ӧ�ĸ�λ�ź�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix or negedge dcm_locked) begin
		if(!dcm_locked) begin
			reset_cnt_pix	<= 2'b11;
		end
		else begin
			reset_cnt_pix	<= {reset_cnt_pix[0],1'b0};
		end
	end
	assign	o_reset_pix	= reset_cnt_pix[1];

	//  -------------------------------------------------------------------------------------
	//	clk frame buf ��Ӧ�ĸ�λ�ź�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_frame_buf or negedge pll_lock) begin
		if(!pll_lock) begin
			reset_cnt_frame_buf	<= 2'b11;
		end
		else begin
			reset_cnt_frame_buf	<= {reset_cnt_frame_buf[0],1'b0};
		end
	end
	assign	o_reset_frame_buf	= reset_cnt_frame_buf[1];


endmodule