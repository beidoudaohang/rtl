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
`include			"frame_buffer_def.v"
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module clk_rst_top (
	input			clk_osc				,
	//mcb clk
	output			async_rst			,//��λ�����ֻ�ṩ��MCB
	output			sysclk_2x			,//����ʱ�ӣ�ֻ�ṩ��MCB
	output			sysclk_2x_180		,//����ʱ�ӣ�ֻ�ṩ��MCB
	output 			pll_ce_0			,//����Ƭѡ��ֻ�ṩ��MCB
	output 			pll_ce_90			,//����Ƭѡ��ֻ�ṩ��MCB
	output			mcb_drp_clk			,//calib�߼�ʱ��
	output			bufpll_mcb_lock		,//bufpll_mcb �����ź�
	output 			pll_lock			,//pll �����ź�
	output			o_clk_out3			,//pll clkout3
	output			o_reset_clk3		,//pll o_reset_clk3
	output			o_clk_out4			,//pll clkout4
	output			o_clk_out5			,//pll clkout5
	//pix clk
	output			o_clk_pix			,
	output			o_reset_pix

	);

	//	ref signals


	wire			clk_osc_ibufg	;
	reg		[3:0]	pwr_cnt 	= 4'b0;
	reg		[1:0]	reset_cnt_pix 	= 2'b11;
	reg		[1:0]	reset_cnt_clk3 	= 2'b11;
	wire			clk_pix	;
	wire			dcm_locked	;
	
	wire			clk_out3	;
	wire			clk_out4	;
	wire			clk_out5	;

	//	ref ARCHITECTURE

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
	.C_INCLK_PERIOD  		(`DDR3_PLL_CLKIN_PERIOD		),
	.C_CLKOUT0_DIVIDE		(`DDR3_PLL_CLKOUT0_DIVIDE	),
	.C_CLKOUT1_DIVIDE		(`DDR3_PLL_CLKOUT1_DIVIDE	),
	.C_CLKOUT2_DIVIDE		(`DDR3_PLL_CLKOUT2_DIVIDE	),
	.C_CLKOUT3_DIVIDE		(`DDR3_PLL_CLKOUT3_DIVIDE	),
	.C_CLKOUT4_DIVIDE		(`DDR3_PLL_CLKOUT4_DIVIDE	),
	.C_CLKOUT5_DIVIDE		(`DDR3_PLL_CLKOUT5_DIVIDE	),
	.C_CLKFBOUT_MULT 		(`DDR3_PLL_CLKFBOUT_MULT	),
	.C_DIVCLK_DIVIDE 		(`DDR3_PLL_DIVCLK_DIVIDE	)
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
	.clk_out3				(clk_out3					),
	.clk_out4				(clk_out4					),
	.clk_out5				(clk_out5					)
	);
	assign	o_clk_out3	= clk_out3;
	assign	o_clk_out4	= clk_out4;
	assign	o_clk_out5	= clk_out5;

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
	//	clk pix ��Ӧ�ĸ�λ�ź�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_out3 or negedge pll_lock) begin
		if(!pll_lock) begin
			reset_cnt_clk3	<= 2'b11;
		end
		else begin
			reset_cnt_clk3	<= {reset_cnt_clk3[0],1'b0};
		end
	end
	assign	o_reset_clk3	= reset_cnt_clk3[1];

endmodule