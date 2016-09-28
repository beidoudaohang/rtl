//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : top_frame_buffer
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/9/23 16:11:03	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : ����ddrоƬ��ʹ��mig�Դ���example����
//              1)  : copy ֡����ģ�� top_frame_buffer
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
`include		"frame_buffer_def.v"

//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module top_ddr_verify (
	//  -------------------------------------------------------------------------------------
	//  ����ʱ��
	//  -------------------------------------------------------------------------------------
	input											clk_osc			,
	//  -------------------------------------------------------------------------------------
	//  External Memory
	//  -------------------------------------------------------------------------------------
	inout  		[`NUM_DQ_PINS-1:0]       			mcb3_dram_dq		,
	output 		[`MEM_ADDR_WIDTH-1:0]    			mcb3_dram_a			,
	output 		[`MEM_BANKADDR_WIDTH-1:0]			mcb3_dram_ba		,
	output											mcb3_dram_ras_n		,
	output											mcb3_dram_cas_n		,
	output											mcb3_dram_we_n		,
	output											mcb3_dram_odt		,
	output											mcb3_dram_reset_n	,
	output											mcb3_dram_cke		,
	output											mcb3_dram_dm		,
	`ifdef	DDR3_16_DQ
		inout 										mcb3_dram_udqs		,
		inout 										mcb3_dram_udqs_n	,
	`endif
	inout 											mcb3_rzq			,
	//	inout 											mcb3_zio			,
	`ifdef	DDR3_16_DQ
		output										mcb3_dram_udm		,
	`endif
	inout 											mcb3_dram_dqs		,
	inout 											mcb3_dram_dqs_n		,
	output											mcb3_dram_ck		,
	output											mcb3_dram_ck_n		,
	//test
	output		[4:0]								ov_fpga_sw			,
	output		[4:0]								ov_fpga_led

	);

	//	ref signals

	wire								async_rst			;
	wire								async_rst_int		;
	wire								sysclk_2x			;
	wire								sysclk_2x_180		;
	wire								pll_ce_0			;
	wire								pll_ce_90			;
	wire								pll_lock			;
	wire								mcb_drp_clk			;
	wire								bufpll_mcb_lock		;
	wire								bufpll_mcb_lock_int	;
	wire								w_clk_out3			;
	wire								w_reset_clk3			;
	reg									calib_done_dly0 	= 1'b0;
	reg									calib_done_dly1 	= 1'b0;
	reg									w_rst0				= 1'b0;
	wire								test_switch_dly1 	;

	wire								w_calib_done	;
	wire								w_error			;
	//	wire	[119:0]						TRIG0		;
	wire	[31:0]						ASYNC_IN	;
	wire	[31:0]						ASYNC_OUT	;

	wire								w_run_led	;
	reg								run_led_dly0	;
	reg								run_led_dly1	;
	//	ref ARCHITECTURE

	assign 		ov_fpga_led[0]  	= 1'b0;
	assign 		ov_fpga_led[1] 		= 1'b0;
	assign 		ov_fpga_led[2] 		= w_calib_done;
	assign 		ov_fpga_led[3]   	= !w_error;
	assign 		ov_fpga_led[4] 		= run_led_dly1;

	assign 		ov_fpga_sw[0]  		= 1'b0;
	assign 		ov_fpga_sw[1] 		= 1'b0;
	assign 		ov_fpga_sw[2] 		= 1'b0;
	assign 		ov_fpga_sw[3]   	= 1'b1;
	assign 		ov_fpga_sw[4] 		= 1'b0;



	always @ (posedge w_clk_out3) begin
		run_led_dly0	<= w_run_led;
		run_led_dly1	<= run_led_dly0;
	end

	//  ===============================================================================================
	//	ʱ�Ӹ�λģ��
	//  ===============================================================================================
	clk_rst_top clk_rst_top_inst (
	.clk_osc				(clk_osc			),
	.async_rst				(async_rst			),
	.sysclk_2x				(sysclk_2x			),
	.sysclk_2x_180			(sysclk_2x_180		),
	.pll_ce_0				(pll_ce_0			),
	.pll_ce_90				(pll_ce_90			),
	.mcb_drp_clk			(mcb_drp_clk		),
	.bufpll_mcb_lock		(bufpll_mcb_lock	),
	.pll_lock				(pll_lock			),
	.o_clk_out3				(w_clk_out3			),
	.o_reset_clk3			(w_reset_clk3		),
	.o_clk_out4				(					),
	.o_clk_out5				(					),
	.o_clk_pix				(			),
	.o_reset_pix			(			)
	);

	//  ===============================================================================================
	//	����ǰ�˼���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	��λ���
	//  -------------------------------------------------------------------------------------
	always @ (posedge w_clk_out3) begin
		calib_done_dly0	<= w_calib_done;
		calib_done_dly1	<= calib_done_dly0;
	end
	assign	test_switch_dly1	= 1'b1;
	
	always @ (posedge w_clk_out3 or posedge w_reset_clk3) begin
		if(w_reset_clk3) begin
			w_rst0	<= 1'b1;
		end
		else begin
			if((test_switch_dly1 == 1'b0)||(calib_done_dly1 == 1'b0)) begin
				w_rst0	<= 1'b1;
			end
			else begin
				w_rst0	<= 1'b0;
			end
		end
	end

	assign	async_rst_int	= async_rst | !test_switch_dly1;
	assign	bufpll_mcb_lock_int	= bufpll_mcb_lock & test_switch_dly1;

	//  -------------------------------------------------------------------------------------
	//	ddr3�����߼�
	//  -------------------------------------------------------------------------------------
	example_top # (
	.C3_P0_MASK_SIZE				(16						),
	.C3_P0_DATA_PORT_SIZE			(128					),
	.DEBUG_EN						(0						),
	.C3_MEMCLK_PERIOD				(`DDR3_MEMCLK_PERIOD	),
	.C3_CALIB_SOFT_IP				(`DDR3_CALIB_SOFT_IP	),
	.C3_SIMULATION					(`DDR3_SIMULATION		),
	.C3_HW_TESTING					(`DDR3_HW_TESTING		),
	.C3_MEM_ADDR_ORDER				(`MEM_ADDR_ORDER		),
	.C3_NUM_DQ_PINS					(`NUM_DQ_PINS			),
	.C3_MEM_ADDR_WIDTH				(`MEM_ADDR_WIDTH		),
	.C3_MEM_BANKADDR_WIDTH			(`MEM_BANKADDR_WIDTH	)
	)
	example_top_inst (
	.mcb3_dram_dq					(mcb3_dram_dq		),
	.mcb3_dram_a					(mcb3_dram_a		),
	.mcb3_dram_ba					(mcb3_dram_ba		),
	.mcb3_dram_ras_n				(mcb3_dram_ras_n	),
	.mcb3_dram_cas_n				(mcb3_dram_cas_n	),
	.mcb3_dram_we_n					(mcb3_dram_we_n		),
	.mcb3_dram_odt					(mcb3_dram_odt		),
	.mcb3_dram_reset_n				(mcb3_dram_reset_n	),
	.mcb3_dram_cke					(mcb3_dram_cke		),
	.mcb3_dram_dm					(mcb3_dram_dm		),
	`ifdef DDR3_16_DQ
		.mcb3_dram_udqs				(mcb3_dram_udqs		),
		.mcb3_dram_udqs_n			(mcb3_dram_udqs_n	),
	`endif
	.mcb3_rzq						(mcb3_rzq			),
	`ifdef DDR3_16_DQ
		.mcb3_dram_udm				(mcb3_dram_udm		),
	`endif
	.mcb3_dram_dqs					(mcb3_dram_dqs		),
	.mcb3_dram_dqs_n				(mcb3_dram_dqs_n	),
	.mcb3_dram_ck					(mcb3_dram_ck		),
	.mcb3_dram_ck_n					(mcb3_dram_ck_n		),
	.c3_calib_done					(w_calib_done		),
	.c3_error						(w_error			),
	.c3_clk0						(w_clk_out3			),
	.c3_rst0						(w_rst0				),
	.c3_async_rst					(async_rst_int		),
	.c3_sysclk_2x					(sysclk_2x			),
	.c3_sysclk_2x_180				(sysclk_2x_180		),
	.c3_pll_ce_0					(pll_ce_0			),
	.c3_pll_ce_90					(pll_ce_90			),
	//	.c3_pll_lock					(bufpll_mcb_lock_int),
	.c3_pll_lock					(bufpll_mcb_lock	),
	.c3_mcb_drp_clk					(mcb_drp_clk		),
	.o_run_led						(w_run_led			)
	);


endmodule