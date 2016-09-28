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
module driver_clock_reset ();
	//  -------------------------------------------------------------------------------------
	//	���� bfm ģ��
	//  -------------------------------------------------------------------------------------
	bfm_clock_reset	bfm_clock_reset();

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	���
	//	-------------------------------------------------------------------------------------
	wire				clk_osc_bufg		;
	wire				reset_osc_bufg		;
	wire				async_rst			;
	wire				sysclk_2x			;
	wire				sysclk_2x_180		;
	wire				pll_ce_0			;
	wire				pll_ce_90			;
	wire				mcb_drp_clk			;
	wire				bufpll_mcb_lock		;
	wire				clk_frame_buf		;
	wire				reset_frame_buf		;
	wire				clk_pix				;
	wire				reset_pix			;
	wire				o_clk_sensor		;
	wire				o_reset_senser_n	;
	wire				o_sensor_reset_done	;
	wire				o_clk_usb_pclk		;
	wire				clk_gpif			;
	wire				reset_gpif			;
	wire				reset_u3_interface	;


	//	ref ARCHITECTURE


	//  ===============================================================================================
	//  clock_reset����
	//  ===============================================================================================
	clock_reset # (
	.DDR3_MEMCLK_FREQ		(bfm_clock_reset.DDR3_MEMCLK_FREQ		)
	)
	clock_reset_inst (
	.clk_osc				(bfm_clock_reset.clk_osc			),
	.i_reset_sensor			(bfm_clock_reset.i_reset_sensor		),
	.i_stream_enable		(bfm_clock_reset.i_stream_enable	),
	.clk_osc_bufg			(clk_osc_bufg			),
	.reset_osc_bufg			(reset_osc_bufg			),
	.async_rst				(async_rst				),
	.sysclk_2x				(sysclk_2x				),
	.sysclk_2x_180			(sysclk_2x_180			),
	.pll_ce_0				(pll_ce_0				),
	.pll_ce_90				(pll_ce_90				),
	.mcb_drp_clk			(mcb_drp_clk			),
	.bufpll_mcb_lock		(bufpll_mcb_lock		),
	.clk_frame_buf			(clk_frame_buf			),
	.reset_frame_buf		(reset_frame_buf		),
	.clk_pix				(clk_pix				),
	.reset_pix				(reset_pix				),
	.o_clk_sensor			(o_clk_sensor			),
	.o_reset_senser_n		(o_reset_senser_n		),
	.o_sensor_reset_done	(o_sensor_reset_done	),
	.o_clk_usb_pclk			(o_clk_usb_pclk			),
	.clk_gpif				(clk_gpif				),
	.reset_gpif				(reset_gpif				),
	.reset_u3_interface		(reset_u3_interface		)
	);

endmodule
