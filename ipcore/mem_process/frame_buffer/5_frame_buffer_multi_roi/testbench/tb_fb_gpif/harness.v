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
//  -- 邢海涛       :| 2015/3/9 17:18:50	:|  初始版本
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
`define		TESTCASE	testcase_1
module harness ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	parameter	NUM_DQ_PINS					= `TESTCASE.NUM_DQ_PINS				;
	parameter	MEM_BANKADDR_WIDTH			= `TESTCASE.MEM_BANKADDR_WIDTH			;
	parameter	MEM_ADDR_WIDTH				= `TESTCASE.MEM_ADDR_WIDTH				;
	parameter	DDR3_MEMCLK_FREQ			= `TESTCASE.DDR3_MEMCLK_FREQ			;
	parameter	MEM_ADDR_ORDER				= `TESTCASE.MEM_ADDR_ORDER				;
	parameter	SKIP_IN_TERM_CAL			= `TESTCASE.SKIP_IN_TERM_CAL			;
	parameter	DDR3_MEM_DENSITY			= `TESTCASE.DDR3_MEM_DENSITY			;
	parameter	DDR3_TCK_SPEED				= `TESTCASE.DDR3_TCK_SPEED				;
	parameter	DDR3_SIMULATION				= `TESTCASE.DDR3_SIMULATION			;
	parameter	DDR3_CALIB_SOFT_IP			= `TESTCASE.DDR3_CALIB_SOFT_IP			;
	parameter	DATA_WD						= `TESTCASE.DATA_WD					;
	parameter	GPIF_DATA_WD				= `TESTCASE.GPIF_DATA_WD				;
	parameter	SHORT_REG_WD				= `TESTCASE.SHORT_REG_WD				;
	parameter	REG_WD						= `TESTCASE.REG_WD						;
	parameter	MROI_MAX_NUM				= `TESTCASE.MROI_MAX_NUM				;
	parameter	SENSOR_MAX_WIDTH			= `TESTCASE.SENSOR_MAX_WIDTH			;
	parameter	SENSOR_ALL_PIX_DIV4			= `TESTCASE.SENSOR_ALL_PIX_DIV4		;
	parameter	PTR_WIDTH					= `TESTCASE.PTR_WIDTH					;
	//	-------------------------------------------------------------------------------------
	//	ddr
	//	-------------------------------------------------------------------------------------
	parameter	DDR3_16_DQ_MCB_8_DQ		= 0   ;
	localparam	DRAM_DQ_WIRE_WIDTH		= (DDR3_16_DQ_MCB_8_DQ==1) ? 16 : NUM_DQ_PINS;

	parameter	FB_FILE_PATH				= `TESTCASE.FB_FILE_PATH		;
	parameter	FB_LEADER_FILE_PATH			= `TESTCASE.FB_LEADER_FILE_PATH		;
	parameter	FB_TRAILER_FILE_PATH		= `TESTCASE.FB_TRAILER_FILE_PATH		;

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	输入
	//	-------------------------------------------------------------------------------------
	wire										clk_in						;
	wire										i_fval						;
	wire										i_dval						;
	wire										i_leader_flag				;
	wire										i_trailer_flag				;
	wire										i_chunk_flag				;
	wire										i_image_flag				;
	wire										i_trailer_final_flag		;
	wire	[DATA_WD-1:0]						iv_din						;
	wire										clk_out						;
	wire										i_buf_rd					;
	wire										clk_frame_buf				;
	wire										reset_frame_buf				;
	wire										i_stream_enable				;
	wire	[REG_WD-1:0]						iv_pixel_format				;
	wire	[SHORT_REG_WD-1:0]					iv_frame_depth				;
	wire										i_chunk_mode_active			;
	wire										i_multi_roi_global_en		;

	wire	[MROI_MAX_NUM*REG_WD-1:0]			iv_payload_size_mroi		;
	wire	[MROI_MAX_NUM*REG_WD-1:0]			iv_image_size_mroi			;
	wire	[SHORT_REG_WD-1:0]					iv_roi_pic_width			;
	wire	[MROI_MAX_NUM*SHORT_REG_WD-1:0]		iv_roi_pic_width_mroi		;
	wire	[MROI_MAX_NUM*REG_WD-1:0]			iv_start_mroi				;

	wire										i_async_rst					;
	wire										i_sysclk_2x					;
	wire										i_sysclk_2x_180				;
	wire										i_pll_ce_0					;
	wire										i_pll_ce_90					;
	wire										i_mcb_drp_clk				;
	wire										i_bufpll_mcb_lock			;


	//	-------------------------------------------------------------------------------------
	//	输出
	//	-------------------------------------------------------------------------------------
	wire										o_front_fifo_overflow		;
	wire										o_back_buf_empty			;
	wire	[GPIF_DATA_WD:0]					ov_dout					;
	wire										o_calib_done				;
	wire										o_wr_error					;
	wire										o_rd_error					;
	wire	[NUM_DQ_PINS-1:0]					mcb1_dram_dq				;
	wire	[MEM_ADDR_WIDTH-1:0]				mcb1_dram_a				;
	wire	[MEM_BANKADDR_WIDTH-1:0]			mcb1_dram_ba				;
	wire										mcb1_dram_ras_n			;
	wire										mcb1_dram_cas_n			;
	wire										mcb1_dram_we_n				;
	wire										mcb1_dram_odt				;
	wire										mcb1_dram_reset_n			;
	wire										mcb1_dram_cke				;
	wire										mcb1_dram_dm				;
	wire										mcb1_dram_udqs				;
	wire										mcb1_dram_udqs_n			;
	wire										mcb1_rzq					;
	wire										mcb1_dram_udm				;
	wire										mcb1_dram_dqs				;
	wire										mcb1_dram_dqs_n				;
	wire										mcb1_dram_ck				;
	wire										mcb1_dram_ck_n				;

	//	-------------------------------------------------------------------------------------
	//	tb
	//	-------------------------------------------------------------------------------------
	wire										o_rd;
	wire										o_fval;
	wire										o_lval;
	wire										o_lval_leader;
	wire										o_lval_trailer;
	wire	[GPIF_DATA_WD-1:0]					ov_pix_data;

	//	-------------------------------------------------------------------------------------
	//	u3 if
	//	-------------------------------------------------------------------------------------
	wire	[31:0]						si_payload_transfer_size	;
	wire	[31:0]						si_payload_transfer_count	;
	wire	[31:0]						si_payload_final_transfer1_size	;
	wire	[31:0]						si_payload_final_transfer2_size	;

	wire								reset_u3_if	;
	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	引入输入信号
	//	-------------------------------------------------------------------------------------
	assign	clk_in						= `TESTCASE.clk_in               ;
	assign	i_fval						= `TESTCASE.i_fval               ;
	assign	i_dval              		= `TESTCASE.i_dval               ;
	assign	i_leader_flag       		= `TESTCASE.i_leader_flag        ;
	assign	i_trailer_flag      		= `TESTCASE.i_trailer_flag       ;
	assign	i_chunk_flag        		= `TESTCASE.i_chunk_flag         ;
	assign	i_image_flag        		= `TESTCASE.i_image_flag         ;
	assign	i_trailer_final_flag      	= `TESTCASE.i_trailer_final_flag ;
	assign	iv_din						= `TESTCASE.iv_din               ;
	assign	clk_out						= `TESTCASE.clk_out              ;
	assign	clk_frame_buf               = `TESTCASE.clk_frame_buf        ;
	assign	reset_frame_buf             = `TESTCASE.reset_frame_buf      ;

	assign	i_stream_enable             = `TESTCASE.i_stream_enable      ;
	assign	iv_pixel_format             = `TESTCASE.iv_pixel_format      ;
	assign	iv_frame_depth              = `TESTCASE.iv_frame_depth       ;
	assign	i_chunk_mode_active         = `TESTCASE.i_chunk_mode_active  ;
	assign	i_multi_roi_global_en       = `TESTCASE.i_multi_roi_global_en;
	assign	iv_payload_size_mroi        = `TESTCASE.iv_payload_size_mroi ;
	assign	iv_image_size_mroi          = `TESTCASE.iv_chunk_size_img_mroi   ;
	assign	iv_roi_pic_width            = `TESTCASE.iv_roi_pic_width     ;
	assign	iv_roi_pic_width_mroi       = `TESTCASE.iv_size_x_mroi;
	assign	iv_start_mroi               = `TESTCASE.iv_start_mroi        ;

	assign	i_async_rst                 = `TESTCASE.i_async_rst          ;
	assign	i_sysclk_2x                 = `TESTCASE.i_sysclk_2x          ;
	assign	i_sysclk_2x_180             = `TESTCASE.i_sysclk_2x_180      ;
	assign	i_pll_ce_0                  = `TESTCASE.i_pll_ce_0           ;
	assign	i_pll_ce_90                 = `TESTCASE.i_pll_ce_90          ;
	assign	i_mcb_drp_clk               = `TESTCASE.i_mcb_drp_clk        ;
	assign	i_bufpll_mcb_lock           = `TESTCASE.i_bufpll_mcb_lock    ;


	assign	si_payload_transfer_size		= `TESTCASE.si_payload_transfer_size;
	assign	si_payload_transfer_count		= `TESTCASE.si_payload_transfer_count;
	assign	si_payload_final_transfer1_size	= `TESTCASE.si_payload_final_transfer1_size;
	assign	si_payload_final_transfer2_size	= `TESTCASE.si_payload_final_transfer2_size;
	assign	reset_u3_if						= `TESTCASE.reset_u3_if;

	//	-------------------------------------------------------------------------------------
	//	例化 bfm 模块
	//	-------------------------------------------------------------------------------------
	//	bfm_reg_common # (
	//	.REG_WD				(REG_WD				),
	//	.SHORT_REG_WD		(SHORT_REG_WD		)
	//	)
	//	bfm_reg_common ();
	//
	//	bfm_se_acq bfm_se_acq ();


	//	-------------------------------------------------------------------------------------
	//	例化 sync_buffer 模块
	//	-------------------------------------------------------------------------------------
	frame_buffer # (
	.NUM_DQ_PINS				(NUM_DQ_PINS				),
	.MEM_BANKADDR_WIDTH			(MEM_BANKADDR_WIDTH			),
	.MEM_ADDR_WIDTH				(MEM_ADDR_WIDTH				),
	.DDR3_MEMCLK_FREQ			(DDR3_MEMCLK_FREQ			),
	.MEM_ADDR_ORDER				(MEM_ADDR_ORDER				),
	.SKIP_IN_TERM_CAL			(SKIP_IN_TERM_CAL			),
	.DDR3_MEM_DENSITY			(DDR3_MEM_DENSITY			),
	.DDR3_TCK_SPEED				(DDR3_TCK_SPEED				),
	.DDR3_SIMULATION			(DDR3_SIMULATION			),
	.DDR3_CALIB_SOFT_IP			(DDR3_CALIB_SOFT_IP			),
	.DATA_WD					(DATA_WD					),
	.GPIF_DATA_WD				(GPIF_DATA_WD				),
	.SHORT_REG_WD				(SHORT_REG_WD				),
	.REG_WD						(REG_WD						),
	.MROI_MAX_NUM				(MROI_MAX_NUM				),
	.SENSOR_MAX_WIDTH			(SENSOR_MAX_WIDTH			),
	.SENSOR_ALL_PIX_DIV4		(SENSOR_ALL_PIX_DIV4		),
	.PTR_WIDTH					(PTR_WIDTH					)
	)
	frame_buffer_inst (
	.clk_in						(clk_in						),
	.i_fval						(i_fval						),
	.i_dval						(i_dval						),
	.i_leader_flag				(i_leader_flag				),
	.i_trailer_flag				(i_trailer_flag				),
	.i_chunk_flag				(i_chunk_flag				),
	.i_image_flag				(i_image_flag				),
	.i_trailer_final_flag		(i_trailer_final_flag		),
	.iv_din						(iv_din						),
	.o_front_fifo_overflow		(o_front_fifo_overflow		),
	.clk_out					(clk_out					),
	.i_buf_rd					(o_rd						),
	.o_back_buf_empty			(o_back_buf_empty			),
	.ov_dout					(ov_dout					),
	.clk_frame_buf				(clk_frame_buf				),
	.reset_frame_buf			(reset_frame_buf			),
	.i_stream_enable			(i_stream_enable			),
	.iv_pixel_format			(iv_pixel_format			),
	.iv_frame_depth				(iv_frame_depth				),
	.i_chunk_mode_active		(i_chunk_mode_active		),
	.i_multi_roi_global_en		(i_multi_roi_global_en		),
	.iv_payload_size_mroi		(iv_payload_size_mroi		),
	.iv_image_size_mroi			(iv_image_size_mroi			),
	.iv_roi_pic_width			(iv_roi_pic_width			),
	.iv_roi_pic_width_mroi		(iv_roi_pic_width_mroi		),
	.iv_start_mroi				(iv_start_mroi				),
	.i_async_rst				(i_async_rst				),
	.i_sysclk_2x				(i_sysclk_2x				),
	.i_sysclk_2x_180			(i_sysclk_2x_180			),
	.i_pll_ce_0					(i_pll_ce_0					),
	.i_pll_ce_90				(i_pll_ce_90				),
	.i_mcb_drp_clk				(i_mcb_drp_clk				),
	.i_bufpll_mcb_lock			(i_bufpll_mcb_lock			),
	.o_calib_done				(o_calib_done				),
	.o_wr_error					(o_wr_error					),
	.o_rd_error					(o_rd_error					),
	.mcb1_dram_dq				(mcb1_dram_dq				),
	.mcb1_dram_a				(mcb1_dram_a				),
	.mcb1_dram_ba				(mcb1_dram_ba				),
	.mcb1_dram_ras_n			(mcb1_dram_ras_n			),
	.mcb1_dram_cas_n			(mcb1_dram_cas_n			),
	.mcb1_dram_we_n				(mcb1_dram_we_n				),
	.mcb1_dram_odt				(mcb1_dram_odt				),
	.mcb1_dram_reset_n			(mcb1_dram_reset_n			),
	.mcb1_dram_cke				(mcb1_dram_cke				),
	.mcb1_dram_dm				(mcb1_dram_dm				),
	.mcb1_dram_udqs				(mcb1_dram_udqs				),
	.mcb1_dram_udqs_n			(mcb1_dram_udqs_n			),
	.mcb1_rzq					(mcb1_rzq					),
	.mcb1_dram_udm				(mcb1_dram_udm				),
	.mcb1_dram_dqs				(mcb1_dram_dqs				),
	.mcb1_dram_dqs_n			(mcb1_dram_dqs_n			),
	.mcb1_dram_ck				(mcb1_dram_ck				),
	.mcb1_dram_ck_n				(mcb1_dram_ck_n				)
	);


	wire	[1:0]			ov_usb_fifoaddr	;
	wire				o_usb_slwr_n	;
	wire				o_usb_pktend_n	;
	wire	[31:0]			ov_usb_data	;

	wire				i_usb_flagb_n	;


	u3_interface # (
	.DATA_WD					(32							),
	.REG_WD						(REG_WD						),
	.SHORT_REG_WD				(SHORT_REG_WD				),
	.DMA_SIZE					(16'h2000					),
	.PACKET_SIZE_WD				(23							),
	.MROI_MAX_NUM				(MROI_MAX_NUM				)
	)
	u3_interface_inst (
	.clk						(clk_out					),
	.reset						(reset_u3_if				),
	.iv_data					(ov_dout					),
	.i_framebuffer_empty		(o_back_buf_empty		),
	.o_fifo_rd					(o_rd						),
	.i_chunkmodeactive			(i_chunk_mode_active		),
	.iv_transfer_count			(si_payload_transfer_count			),
	.iv_transfer_size			(si_payload_transfer_size			),
	.iv_transfer1_size			(si_payload_final_transfer1_size			),
	.iv_transfer2_size			(si_payload_final_transfer2_size			),
	.i_multi_roi_total_en		(i_multi_roi_global_en		),
	.iv_payload_size_mroi		(iv_payload_size_mroi		),
	.i_usb_flagb				(i_usb_flagb_n				),
	.ov_usb_fifoaddr			(ov_usb_fifoaddr			),
	.o_usb_slwr_n				(o_usb_slwr_n				),
	.ov_usb_data				(ov_usb_data				),
	.o_usb_pktend_n				(o_usb_pktend_n				)
	);

	//	-------------------------------------------------------------------------------------
	//	3014 gpif 仿真模型
	//	-------------------------------------------------------------------------------------
	slave_fifo # (
	.SLAVE_DPTH				(16'h2000				)
	)
	slave_fifo_inst(
	.reset_n				(1'b1					),
	.i_usb_rd				(1'b1		    		),
	.iv_usb_addr			(ov_usb_fifoaddr    	),
	.i_usb_wr				(o_usb_slwr_n	    	),
	.iv_usb_data			(ov_usb_data	    	),
	.i_usb_pclk				(!clk_out		    	),
	.i_usb_pkt				(o_usb_pktend_n	    	),
	.i_usb_cs				(1'b0		    		),
	.i_usb_oe				(1'b1		    		),
	.i_pc_busy				(1'b0					),
	.o_flaga				(						),
	.o_flagb				(i_usb_flagb_n			)
	);

//	//	-------------------------------------------------------------------------------------
//	//	读后端fifo的逻辑
//	//	-------------------------------------------------------------------------------------
//	rd_back_buf # (
//	.MROI_MAX_NUM			(MROI_MAX_NUM			),
//	.REG_WD					(REG_WD					),
//	.DATA_WIDTH				(GPIF_DATA_WD			)
//	)
//	rd_back_buf_inst (
//	.clk					(clk_out				),
//	.i_stream_enable		(i_stream_enable		),
//	.iv_image_size_mroi		(iv_image_size_mroi		),
//	.i_empty				(o_back_buf_empty		),
//	.iv_pix_data			(ov_dout				),
//	.o_rd					(o_rd					),
//	.o_fval					(o_fval					),
//	.o_lval					(o_lval					),
//	.o_lval_leader			(o_lval_leader			),
//	.o_lval_trailer			(o_lval_trailer			),
//	.ov_pix_data			(ov_pix_data			)
//	);
//
//	file_write # (
//	.DATA_WIDTH	(GPIF_DATA_WD			),
//	.FILE_PATH	(FB_FILE_PATH			)
//	)
//	file_write_inst (
//	.clk			(clk_out		),
//	.reset			(1'b0			),
//	.i_fval			(o_fval			),
//	.i_lval			(o_lval			),
//	.iv_din			(ov_pix_data	)
//	);
//
//	file_write # (
//	.DATA_WIDTH	(GPIF_DATA_WD			),
//	.FILE_PATH	(FB_LEADER_FILE_PATH	)
//	)
//	file_write_leader_inst (
//	.clk			(clk_out		),
//	.reset			(1'b0			),
//	.i_fval			(o_fval			),
//	.i_lval			(o_lval_leader	),
//	.iv_din			(ov_pix_data	)
//	);
//
//	file_write # (
//	.DATA_WIDTH	(GPIF_DATA_WD			),
//	.FILE_PATH	(FB_TRAILER_FILE_PATH	)
//	)
//	file_write_trailer_inst (
//	.clk			(clk_out		),
//	.reset			(1'b0			),
//	.i_fval			(o_fval			),
//	.i_lval			(o_lval_trailer	),
//	.iv_din			(ov_pix_data	)
//	);

	//	-------------------------------------------------------------------------------------
	//	DDR3 仿真模型
	//	-------------------------------------------------------------------------------------
	PULLDOWN zio_pulldown3 (.O(mcb1_zio));   PULLDOWN rzq_pulldown3 (.O(mcb1_rzq));
	generate
		//	-------------------------------------------------------------------------------------
		//	如果DDR3是16bit，但MCB却是8bit
		//	-------------------------------------------------------------------------------------
		if(DDR3_16_DQ_MCB_8_DQ==1) begin
			PULLDOWN mcb1_dram_dq_8 (.O(mcb1_dram_dq[8]));
			PULLDOWN mcb1_dram_dq_9 (.O(mcb1_dram_dq[9]));
			PULLDOWN mcb1_dram_dq_10 (.O(mcb1_dram_dq[10]));
			PULLDOWN mcb1_dram_dq_11 (.O(mcb1_dram_dq[11]));
			PULLDOWN mcb1_dram_dq_12 (.O(mcb1_dram_dq[12]));
			PULLDOWN mcb1_dram_dq_13 (.O(mcb1_dram_dq[13]));
			PULLDOWN mcb1_dram_dq_14 (.O(mcb1_dram_dq[14]));
			PULLDOWN mcb1_dram_dq_15 (.O(mcb1_dram_dq[15]));

			ddr3_model_c3 ddr3_model_c3_inst (
			.ck         	(mcb1_dram_ck					),
			.ck_n       	(mcb1_dram_ck_n					),
			.cke        	(mcb1_dram_cke					),
			.cs_n       	(1'b0							),
			.ras_n      	(mcb1_dram_ras_n				),
			.cas_n      	(mcb1_dram_cas_n				),
			.we_n       	(mcb1_dram_we_n					),
			.dm_tdqs    	({mcb1_dram_udm,mcb1_dram_dm}	),
			.ba         	(mcb1_dram_ba					),
			.addr       	(mcb1_dram_a					),
			.dq         	(mcb1_dram_dq					),
			.dqs      		({mcb1_dram_udqs,mcb1_dram_dqs}	),
			.dqs_n      	({mcb1_dram_udqs_n,mcb1_dram_dqs_n}),
			.tdqs_n     	(								),
			.odt        	(mcb1_dram_odt					),
			.rst_n      	(mcb1_dram_reset_n				)
			);
		end
		//	-------------------------------------------------------------------------------------
		//	DDR3和MCB都是8bit
		//	-------------------------------------------------------------------------------------
		else if(NUM_DQ_PINS==8) begin
			ddr3_model_c3 ddr3_model_c3_inst (
			.ck         	(mcb1_dram_ck					),
			.ck_n       	(mcb1_dram_ck_n					),
			.cke        	(mcb1_dram_cke					),
			.cs_n       	(1'b0							),
			.ras_n      	(mcb1_dram_ras_n				),
			.cas_n      	(mcb1_dram_cas_n				),
			.we_n       	(mcb1_dram_we_n					),
			.dm_tdqs    	(mcb1_dram_dm					),
			.ba         	(mcb1_dram_ba					),
			.addr       	(mcb1_dram_a					),
			.dq         	(mcb1_dram_dq					),
			.dqs        	(mcb1_dram_dqs					),
			.dqs_n      	(mcb1_dram_dqs_n				),
			.tdqs_n     	(								),
			.odt        	(mcb1_dram_odt					),
			.rst_n      	(mcb1_dram_reset_n				)
			);
		end
		//	-------------------------------------------------------------------------------------
		//	DDR3和MCB都是16bit
		//	-------------------------------------------------------------------------------------
		else if(NUM_DQ_PINS==16) begin
			ddr3_model_c3 ddr3_model_c3_inst (
			.ck         	(mcb1_dram_ck					),
			.ck_n       	(mcb1_dram_ck_n					),
			.cke        	(mcb1_dram_cke					),
			.cs_n       	(1'b0							),
			.ras_n      	(mcb1_dram_ras_n				),
			.cas_n      	(mcb1_dram_cas_n				),
			.we_n       	(mcb1_dram_we_n					),
			.dm_tdqs    	({mcb1_dram_udm,mcb1_dram_dm}	),
			.ba         	(mcb1_dram_ba					),
			.addr       	(mcb1_dram_a					),
			.dq         	(mcb1_dram_dq					),
			.dqs        	({mcb1_dram_udqs,mcb1_dram_dqs}	),
			.dqs_n      	({mcb1_dram_udqs_n,mcb1_dram_dqs_n}),
			.tdqs_n     	(								),
			.odt        	(mcb1_dram_odt					),
			.rst_n      	(mcb1_dram_reset_n				)
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
