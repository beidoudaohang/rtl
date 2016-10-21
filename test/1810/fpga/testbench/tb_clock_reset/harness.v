//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : harness
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/3/9 17:18:50	:|  ��ʼ�汾
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
module harness ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	parameter	DDR3_MEMCLK_FREQ		= `TESTCASE.DDR3_MEMCLK_FREQ		;


	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------
	wire							clk_osc				;
	wire							i_reset_sensor			;
	wire							i_stream_enable		;

	//	-------------------------------------------------------------------------------------
	//	���
	//	-------------------------------------------------------------------------------------
	wire							clk_osc_bufg			;
	wire							reset_osc_bufg			;
	wire							async_rst				;
	wire							sysclk_2x				;
	wire							sysclk_2x_180			;
	wire							pll_ce_0				;
	wire							pll_ce_90				;
	wire							mcb_drp_clk			;
	wire							bufpll_mcb_lock		;
	wire							clk_frame_buf			;
	wire							reset_frame_buf		;
	wire							clk_pix				;
	wire							reset_pix				;
	wire							clk_pix_2x				;
	wire							reset_pix_2x			;
	wire							o_clk_sensor			;
	wire							o_sensor_reset_n		;
	wire							o_sensor_reset_done	;
	wire							o_clk_usb_pclk			;
	wire							clk_gpif				;
	wire							reset_gpif				;
	wire							reset_u3_interface		;


	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	���������ź�
	//	-------------------------------------------------------------------------------------
	assign	clk_osc					= `TESTCASE.clk_osc	;
	assign	i_reset_sensor			= `TESTCASE.i_reset_sensor	;
	assign	i_stream_enable			= `TESTCASE.i_stream_enable	;


	//	-------------------------------------------------------------------------------------
	//	���� dut ģ��
	//	-------------------------------------------------------------------------------------
	clock_reset # (
	.DDR3_MEMCLK_FREQ		(DDR3_MEMCLK_FREQ		)
	)
	clock_reset_inst (
	.clk_osc				(clk_osc				),
	.i_reset_sensor			(i_reset_sensor			),
	.i_stream_enable		(i_stream_enable		),
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
	.clk_pix_2x				(clk_pix_2x				),
	.reset_pix_2x			(reset_pix_2x			),
	.o_clk_sensor			(o_clk_sensor			),
	.o_sensor_reset_n		(o_sensor_reset_n		),
	.o_sensor_reset_done	(o_sensor_reset_done	),
	.o_clk_usb_pclk			(o_clk_usb_pclk			),
	.clk_gpif				(clk_gpif				),
	.reset_gpif				(reset_gpif				),
	.reset_u3_interface		(reset_u3_interface		)
	);



	//generate vcd file
	//initial begin
	//$dumpfile("test.vcd");
	//$dumpvars(1,top_frame_buffer_inst);
	//end

	//for lattice simulation
	//GSR   GSR_INST (.GSR (1'b1)); //< global reset sig>
	//PUR   PUR_INST (.PUR (1'b1)); //<powerup reset sig>



endmodule
