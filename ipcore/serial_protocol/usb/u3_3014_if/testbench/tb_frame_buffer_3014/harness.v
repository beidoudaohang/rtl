//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : harness
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/4/1 15:42:08	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
`define		TESTCASE	testcase1
module harness ();

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	固定参数，从bfm中传递过来
	//	-------------------------------------------------------------------------------------
	parameter	NUM_DQ_PINS				= `TESTCASE.NUM_DQ_PINS			;
	parameter	MEM_BANKADDR_WIDTH      = `TESTCASE.MEM_BANKADDR_WIDTH	;
	parameter	MEM_ADDR_WIDTH          = `TESTCASE.MEM_ADDR_WIDTH		;
	parameter	DDR3_MEMCLK_FREQ        = `TESTCASE.DDR3_MEMCLK_FREQ	;
	parameter	MEM_ADDR_ORDER          = `TESTCASE.MEM_ADDR_ORDER		;
	parameter	SKIP_IN_TERM_CAL        = `TESTCASE.SKIP_IN_TERM_CAL	;
	parameter	DDR3_MEM_DENSITY        = `TESTCASE.DDR3_MEM_DENSITY	;
	parameter	DDR3_TCK_SPEED          = `TESTCASE.DDR3_TCK_SPEED		;
	parameter	DDR3_SIMULATION         = `TESTCASE.DDR3_SIMULATION		;
	parameter	DDR3_CALIB_SOFT_IP      = `TESTCASE.DDR3_CALIB_SOFT_IP	;
	parameter	DATA_WIDTH              = `TESTCASE.DATA_WIDTH			;
	parameter	PTR_WIDTH               = `TESTCASE.PTR_WIDTH			;
	parameter	FRAME_SIZE_WIDTH        = `TESTCASE.FRAME_SIZE_WIDTH	;
	parameter	TERRIBLE_TRAFFIC        = `TESTCASE.TERRIBLE_TRAFFIC	;
	parameter	DDR3_16_DQ_MCB_8_DQ		= `TESTCASE.DDR3_16_DQ_MCB_8_DQ	;

	parameter	TESTCASE_NUM			= `TESTCASE.TESTCASE_NUM	;

	localparam	DRAM_DQ_WIRE_WIDTH		= (DDR3_16_DQ_MCB_8_DQ==1) ? 16 : NUM_DQ_PINS;

	//	-------------------------------------------------------------------------------------
	//	输入信号
	//	-------------------------------------------------------------------------------------
	wire								i_fval			;
	wire								i_lval			;
	wire	[DATA_WIDTH-1:0]			iv_image_din	;
	wire								clk_front		;
	wire								clk_back		;
	wire								clk_frame_buf	;
	wire								reset_frame_buf	;
	wire								async_rst		;
	wire								sysclk_2x		;
	wire								sysclk_2x_180	;
	wire								pll_ce_0		;
	wire								pll_ce_90		;
	wire								mcb_drp_clk		;
	wire								bufpll_mcb_lock	;
	wire								o_usb_flagb_n	;

	//	-------------------------------------------------------------------------------------
	//	输出的信号
	//	-------------------------------------------------------------------------------------
	wire								i_back_buf_rd	;
	wire	[1:0]						ov_usb_addr		;
	wire								o_usb_slwr_n	;
	wire	[DATA_WIDTH-1:0]			ov_usb_data		;
	wire								o_usb_pktend_n	;

	//	-------------------------------------------------------------------------------------
	//	交互信号
	//	-------------------------------------------------------------------------------------
	wire	[DRAM_DQ_WIRE_WIDTH-1:0]	mcb3_dram_dq		;
	wire								o_front_fifo_full	;
	wire								o_buf_empty			;
	wire								o_buf_pe			;
	wire	[DATA_WIDTH:0]				ov_image_dout		;
	wire								o_calib_done		;
	wire								o_wr_error			;
	wire								o_rd_error			;
	wire	[MEM_ADDR_WIDTH-1:0]		mcb3_dram_a			;
	wire	[MEM_BANKADDR_WIDTH-1:0]	mcb3_dram_ba		;
	wire								mcb3_dram_ras_n		;
	wire								mcb3_dram_cas_n		;
	wire								mcb3_dram_we_n		;
	wire								mcb3_dram_odt		;
	wire								mcb3_dram_reset_n	;
	wire								mcb3_dram_cke		;
	wire								mcb3_dram_udm		;
	wire								mcb3_dram_dm		;
	wire								mcb3_dram_ck		;
	wire								mcb3_dram_ck_n		;
	wire								mcb3_dram_udqs		;
	wire								mcb3_dram_udqs_n	;
	wire								mcb3_dram_dqs		;
	wire								mcb3_dram_dqs_n		;
	wire								mcb3_rzq			;
	wire								mcb3_zio			;



	//	ref ARCHITECTURE
	//	===============================================================================================
	//	ref ***引用***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	引用 sensor 模型的输出
	//	-------------------------------------------------------------------------------------
	assign	i_fval				= driver_mt9p031.o_fval;
	assign	i_lval				= driver_mt9p031.o_lval;
	assign	iv_image_din		= driver_mt9p031.ov_pix_data;

	//	-------------------------------------------------------------------------------------
	//	引用 clock reset 的输出
	//	-------------------------------------------------------------------------------------
	assign	clk_front			= driver_clock_reset.clk_pix			;
	assign	clk_back			= driver_clock_reset.clk_gpif			;
	assign	clk_frame_buf		= driver_clock_reset.clk_frame_buf  	;
	assign	reset_frame_buf 	= driver_clock_reset.reset_frame_buf	;
	assign	async_rst       	= driver_clock_reset.async_rst			;
	assign	sysclk_2x       	= driver_clock_reset.sysclk_2x			;
	assign	sysclk_2x_180   	= driver_clock_reset.sysclk_2x_180		;
	assign	pll_ce_0        	= driver_clock_reset.pll_ce_0			;
	assign	pll_ce_90       	= driver_clock_reset.pll_ce_90			;
	assign	mcb_drp_clk     	= driver_clock_reset.mcb_drp_clk		;
	assign	bufpll_mcb_lock 	= driver_clock_reset.bufpll_mcb_lock	;
	assign	o_usb_flagb_n		= `TESTCASE.o_usb_flagb_n				;

	//	===============================================================================================
	//	ref ***例化***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	bfm 例化
	//	-------------------------------------------------------------------------------------
	bfm # (
	.DATA_WIDTH			(DATA_WIDTH			),
	.PTR_WIDTH			(PTR_WIDTH			),
	.FRAME_SIZE_WIDTH	(FRAME_SIZE_WIDTH	)
	)
	bfm ();

	//	-------------------------------------------------------------------------------------
	//	帧存模块
	//	-------------------------------------------------------------------------------------
	frame_buffer # (
	.NUM_DQ_PINS			(NUM_DQ_PINS		),
	.MEM_BANKADDR_WIDTH		(MEM_BANKADDR_WIDTH	),
	.MEM_ADDR_WIDTH			(MEM_ADDR_WIDTH		),
	.DDR3_MEMCLK_FREQ		(DDR3_MEMCLK_FREQ	),
	.MEM_ADDR_ORDER			(MEM_ADDR_ORDER		),
	.SKIP_IN_TERM_CAL		(SKIP_IN_TERM_CAL	),
	.DDR3_MEM_DENSITY		(DDR3_MEM_DENSITY	),
	.DDR3_TCK_SPEED			(DDR3_TCK_SPEED		),
	.DDR3_SIMULATION		(DDR3_SIMULATION	),
	.DDR3_CALIB_SOFT_IP		(DDR3_CALIB_SOFT_IP	),
	.DATA_WIDTH				(DATA_WIDTH			),
	.PTR_WIDTH				(PTR_WIDTH			),
	.FRAME_SIZE_WIDTH		(FRAME_SIZE_WIDTH	),
	.TERRIBLE_TRAFFIC		(TERRIBLE_TRAFFIC	)
	)
	frame_buffer_inst (
	.clk_front				(clk_front				),
	.i_fval					(i_fval					),
	.i_dval					(i_lval					),
	.iv_image_din			(iv_image_din			),
	.o_front_fifo_full		(o_front_fifo_full		),

	.clk_back				(clk_back				),
	.i_buf_rd				(i_back_buf_rd			),
	.o_buf_empty			(o_buf_empty			),
	.o_buf_pe				(o_buf_pe				),
	.ov_image_dout			(ov_image_dout			),

	.iv_frame_depth			(bfm.iv_frame_depth		),
	.i_start_full_frame		(bfm.i_start_full_frame	),
	.i_start_quick			(bfm.i_start_quick		),
	.iv_frame_size			(bfm.iv_frame_size		),
	.clk_frame_buf			(clk_frame_buf			),
	.reset_frame_buf		(reset_frame_buf		),
	.async_rst				(async_rst				),
	.sysclk_2x				(sysclk_2x				),
	.sysclk_2x_180			(sysclk_2x_180			),
	.pll_ce_0				(pll_ce_0				),
	.pll_ce_90				(pll_ce_90				),
	.mcb_drp_clk			(mcb_drp_clk			),
	.bufpll_mcb_lock		(bufpll_mcb_lock		),
	.o_calib_done			(o_calib_done			),
	.o_wr_error				(o_wr_error				),
	.o_rd_error				(o_rd_error				),
	.mcb3_dram_dq			(mcb3_dram_dq			),
	.mcb3_dram_a			(mcb3_dram_a			),
	.mcb3_dram_ba			(mcb3_dram_ba			),
	.mcb3_dram_ras_n		(mcb3_dram_ras_n		),
	.mcb3_dram_cas_n		(mcb3_dram_cas_n		),
	.mcb3_dram_we_n			(mcb3_dram_we_n			),
	.mcb3_dram_odt			(mcb3_dram_odt			),
	.mcb3_dram_reset_n		(mcb3_dram_reset_n		),
	.mcb3_dram_cke			(mcb3_dram_cke			),
	.mcb3_dram_udm			(mcb3_dram_udm			),
	.mcb3_dram_dm			(mcb3_dram_dm			),
	.mcb3_dram_udqs			(mcb3_dram_udqs			),
	.mcb3_dram_udqs_n		(mcb3_dram_udqs_n		),
	.mcb3_dram_dqs			(mcb3_dram_dqs			),
	.mcb3_dram_dqs_n		(mcb3_dram_dqs_n		),
	.mcb3_rzq				(mcb3_rzq				),
	.mcb3_zio				(mcb3_zio				),
	//	.mcb1_zio				(				),
	.mcb3_dram_ck			(mcb3_dram_ck			),
	.mcb3_dram_ck_n			(mcb3_dram_ck_n			),
	.ov_frame_buf_version	()
	);

	//	-------------------------------------------------------------------------------------
	//	u3 3014 if
	//	-------------------------------------------------------------------------------------
	u3_3014_if # (
	.DATA_WIDTH				(DATA_WIDTH			),
	.REG_WIDTH				(32					),
	.FRAME_SIZE_WIDTH		(FRAME_SIZE_WIDTH	),
	.DMA_SIZE				(14'h1000			)
	)
	u3_3014_if_inst (
	.clk					(driver_clock_reset.clk_gpif	),
	.reset					(driver_clock_reset.reset_gpif	),
	.iv_data				(ov_image_dout					),
	.i_buf_empty			(o_buf_empty					),
	.o_buf_rd				(i_back_buf_rd					),
	.i_stream_enable		(bfm.i_start_full_frame				),
	.iv_payload_size		({bfm.iv_frame_size,2'b00}-16'd52-16'd32	),
	.i_chunk_mode_active	(1'b0							),
	.iv_transfer_count		(bfm.iv_transfer_count			),
	.iv_transfer_size		(bfm.iv_transfer_size			),
	.iv_transfer1_size		(bfm.iv_transfer1_size			),
	.iv_transfer2_size		(bfm.iv_transfer2_size			),
	.i_usb_flagb_n			(o_usb_flagb_n					),
	.ov_usb_addr			(ov_usb_addr			),
	.o_usb_slwr_n			(o_usb_slwr_n			),
	.ov_usb_data			(ov_usb_data			),
	.o_usb_pktend_n			(o_usb_pktend_n			)
	);

	//	-------------------------------------------------------------------------------------
	//	DDR3 仿真模型
	//	-------------------------------------------------------------------------------------
	PULLDOWN zio_pulldown3 (.O(mcb3_zio));   PULLDOWN rzq_pulldown3 (.O(mcb3_rzq));
	generate
		//	-------------------------------------------------------------------------------------
		//	如果DDR3是16bit，但MCB却是8bit
		//	-------------------------------------------------------------------------------------
		if(DDR3_16_DQ_MCB_8_DQ==1) begin
			PULLDOWN mcb3_dram_dq_8 (.O(mcb3_dram_dq[8]));
			PULLDOWN mcb3_dram_dq_9 (.O(mcb3_dram_dq[9]));
			PULLDOWN mcb3_dram_dq_10 (.O(mcb3_dram_dq[10]));
			PULLDOWN mcb3_dram_dq_11 (.O(mcb3_dram_dq[11]));
			PULLDOWN mcb3_dram_dq_12 (.O(mcb3_dram_dq[12]));
			PULLDOWN mcb3_dram_dq_13 (.O(mcb3_dram_dq[13]));
			PULLDOWN mcb3_dram_dq_14 (.O(mcb3_dram_dq[14]));
			PULLDOWN mcb3_dram_dq_15 (.O(mcb3_dram_dq[15]));

			ddr3_model_c3 ddr3_model_c3_inst (
			.ck         	(mcb3_dram_ck					),
			.ck_n       	(mcb3_dram_ck_n					),
			.cke        	(mcb3_dram_cke					),
			.cs_n       	(1'b0							),
			.ras_n      	(mcb3_dram_ras_n				),
			.cas_n      	(mcb3_dram_cas_n				),
			.we_n       	(mcb3_dram_we_n					),
			.dm_tdqs    	({mcb3_dram_udm,mcb3_dram_dm}	),
			.ba         	(mcb3_dram_ba					),
			.addr       	(mcb3_dram_a					),
			.dq         	(mcb3_dram_dq					),
			.dqs      		({mcb3_dram_udqs,mcb3_dram_dqs}	),
			.dqs_n      	({mcb3_dram_udqs_n,mcb3_dram_dqs_n}),
			.tdqs_n     	(								),
			.odt        	(mcb3_dram_odt					),
			.rst_n      	(mcb3_dram_reset_n				)
			);
		end
		//	-------------------------------------------------------------------------------------
		//	DDR3和MCB都是8bit
		//	-------------------------------------------------------------------------------------
		else if(NUM_DQ_PINS==8) begin
			ddr3_model_c3 ddr3_model_c3_inst (
			.ck         	(mcb3_dram_ck					),
			.ck_n       	(mcb3_dram_ck_n					),
			.cke        	(mcb3_dram_cke					),
			.cs_n       	(1'b0							),
			.ras_n      	(mcb3_dram_ras_n				),
			.cas_n      	(mcb3_dram_cas_n				),
			.we_n       	(mcb3_dram_we_n					),
			.dm_tdqs    	(mcb3_dram_dm					),
			.ba         	(mcb3_dram_ba					),
			.addr       	(mcb3_dram_a					),
			.dq         	(mcb3_dram_dq					),
			.dqs        	(mcb3_dram_dqs					),
			.dqs_n      	(mcb3_dram_dqs_n				),
			.tdqs_n     	(								),
			.odt        	(mcb3_dram_odt					),
			.rst_n      	(mcb3_dram_reset_n				)
			);
		end
		//	-------------------------------------------------------------------------------------
		//	DDR3和MCB都是16bit
		//	-------------------------------------------------------------------------------------
		else if(NUM_DQ_PINS==16) begin
			ddr3_model_c3 ddr3_model_c3_inst (
			.ck         	(mcb3_dram_ck					),
			.ck_n       	(mcb3_dram_ck_n					),
			.cke        	(mcb3_dram_cke					),
			.cs_n       	(1'b0							),
			.ras_n      	(mcb3_dram_ras_n				),
			.cas_n      	(mcb3_dram_cas_n				),
			.we_n       	(mcb3_dram_we_n					),
			.dm_tdqs    	({mcb3_dram_udm,mcb3_dram_dm}	),
			.ba         	(mcb3_dram_ba					),
			.addr       	(mcb3_dram_a					),
			.dq         	(mcb3_dram_dq					),
			.dqs        	({mcb3_dram_udqs,mcb3_dram_dqs}	),
			.dqs_n      	({mcb3_dram_udqs_n,mcb3_dram_dqs_n}),
			.tdqs_n     	(								),
			.odt        	(mcb3_dram_odt					),
			.rst_n      	(mcb3_dram_reset_n				)
			);
		end
	endgenerate




	//generate vcd file
	//initial begin
	//$dumpfile("test.vcd");
	//$dumpvars(1,top_frame_buffer_inst);
	//end

	//for lattice simulation
	//GSR   GSR_INST (.GSR (1'b1)); //< global reset sig>
	//PUR   PUR_INST (.PUR (1'b1)); //<powerup reset sig>



endmodule

