//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : tb_frame_buffer
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2013/6/14 14:04:48	:|  ��ʼ�汾
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
`include			"pattern_model_def.v"
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module tb_frame_buffer ();
//	parameter	MEM_ADDR_WIDTH	= (DDR3_MEM_DENSITY=="512Mb") ? (13-NUM_DQ_PINS/9) : ((DDR3_MEM_DENSITY=="1Gb") ? (14-NUM_DQ_PINS/9) : (14-NUM_DQ_PINS/9));

	localparam	NUM_DQ_PINS					= 16	;
	localparam	MEM_BANKADDR_WIDTH			= 3		;
	localparam	MEM_ADDR_WIDTH				= 13	;
	localparam	DDR3_MEMCLK_FREQ			= 320	;
	localparam	MEM_ADDR_ORDER				= "ROW_BANK_COLUMN"	;
	localparam	SKIP_IN_TERM_CAL			= 1		;
	localparam	DDR3_MEM_DENSITY			= "1Gb"	;
	localparam	DDR3_TCK_SPEED				= "15E";
	localparam	DDR3_SIMULATION				= "TRUE";
	localparam	DDR3_CALIB_SOFT_IP			= "FALSE";
	
	localparam	DDR3_16_DQ_MCB_8_DQ	= 0;
	//  -------------------------------------------------------------------------------------
	//	---- ref 2.2.1 PLL �궨��
	//  -------------------------------------------------------------------------------------
	`define	DDR3_640

	`ifdef DDR3_800
		`define	DDR3_MEMCLK_PERIOD			2500			//DDR3-800 �Ĺ���ʱ��Ƶ����400MHz��������2500ps.����ʵ��Ƶ����д
		//PLL����
		`define	DDR3_PLL_CLKIN_PERIOD		25000			//PLL����Ƶ�ʣ���λ��ps
		`define	DDR3_PLL_CLKOUT0_DIVIDE		1				//ddr3 2��Ƶ 800MHz
		`define	DDR3_PLL_CLKOUT1_DIVIDE		1				//ddr3 2��Ƶ 800MHz ��λ�෴
		`define	DDR3_PLL_CLKOUT2_DIVIDE		8				//mcb drp ʱ�� 100MHz
		`define	DDR3_PLL_CLKOUT3_DIVIDE		5				//֡���湤��ʱ�� 160
		`define	DDR3_PLL_CLKOUT4_DIVIDE		5
		`define	DDR3_PLL_CLKOUT5_DIVIDE		5
		`define	DDR3_PLL_CLKFBOUT_MULT		20
		`define	DDR3_PLL_DIVCLK_DIVIDE		1

	`elsif DDR3_720
		`define	DDR3_MEMCLK_PERIOD			2778			//DDR3-720 �Ĺ���ʱ��Ƶ����360MHz��������2778ps.����ʵ��Ƶ����д
		//PLL����
		`define	DDR3_PLL_CLKIN_PERIOD		25000			//PLL����Ƶ�ʣ���λ��ps
		`define	DDR3_PLL_CLKOUT0_DIVIDE		1
		`define	DDR3_PLL_CLKOUT1_DIVIDE		1
		`define	DDR3_PLL_CLKOUT2_DIVIDE		8
		`define	DDR3_PLL_CLKOUT3_DIVIDE		4
		`define	DDR3_PLL_CLKOUT4_DIVIDE		5
		`define	DDR3_PLL_CLKOUT5_DIVIDE		5
		`define	DDR3_PLL_CLKFBOUT_MULT		18
		`define	DDR3_PLL_DIVCLK_DIVIDE		1

	`elsif DDR3_660
		`define	DDR3_MEMCLK_PERIOD			3030			//DDR3-660 �Ĺ���ʱ��Ƶ����330MHz��������3125ps.����ʵ��Ƶ����д
		//PLL����
		`define	DDR3_PLL_CLKIN_PERIOD		25000			//PLL����Ƶ�ʣ���λ��ps
		`define	DDR3_PLL_CLKOUT0_DIVIDE		1				//ddr3 2��Ƶ 660MHz
		`define	DDR3_PLL_CLKOUT1_DIVIDE		1				//ddr3 2��Ƶ 660MHz ��λ�෴
		`define	DDR3_PLL_CLKOUT2_DIVIDE		8				//mcb drp ʱ�� 82.5MHz
		`define	DDR3_PLL_CLKOUT3_DIVIDE		7				//֡���湤��ʱ�� 94.286MHz
		`define	DDR3_PLL_CLKOUT4_DIVIDE		8
		`define	DDR3_PLL_CLKOUT5_DIVIDE		8
		`define	DDR3_PLL_CLKFBOUT_MULT		33
		`define	DDR3_PLL_DIVCLK_DIVIDE		2

	`elsif DDR3_640
		`define	DDR3_MEMCLK_PERIOD			3125			//DDR3-640 �Ĺ���ʱ��Ƶ����320MHz��������3125ps.����ʵ��Ƶ����д
		//PLL����
		`define	DDR3_PLL_CLKIN_PERIOD		25000			//PLL����Ƶ�ʣ���λ��ps
		`define	DDR3_PLL_CLKOUT0_DIVIDE		1				//ddr3 2��Ƶ 640MHz
		`define	DDR3_PLL_CLKOUT1_DIVIDE		1				//ddr3 2��Ƶ 640MHz ��λ�෴
		`define	DDR3_PLL_CLKOUT2_DIVIDE		8				//mcb drp ʱ�� 80MHz
		`define	DDR3_PLL_CLKOUT3_DIVIDE		7				//֡���湤��ʱ�� 91.428MHz
		`define	DDR3_PLL_CLKOUT4_DIVIDE		5
		`define	DDR3_PLL_CLKOUT5_DIVIDE		5
		`define	DDR3_PLL_CLKFBOUT_MULT		16
		`define	DDR3_PLL_DIVCLK_DIVIDE		1
	`endif

//	localparam		LINE_ACTIVE_PIX_NUM			= 320	;
//	localparam		LINE_HIDE_PIX_NUM			= 4		;
//	localparam		LINE_ACTIVE_NUMBER			= 1024	;
//	localparam		FRAME_HIDE_PIX_NUM			= 11060	;
//	localparam		FRAME_TO_LINE_PIX_NUM		= 25	;
////	localparam		FRAME_DEPTH					= 3'b100;	//4 frame
//	localparam		FRAME_DEPTH					= 3'b010;	//4 frame
//	localparam		FRAME_SIZE					= (LINE_ACTIVE_PIX_NUM * LINE_ACTIVE_NUMBER) - 1	;
	
	//	ref signals

	reg									clk_vin = 1'b0;
	wire								i_fval;
	wire								i_dval;
	reg									clk_frame_buf = 1'b0;
	reg									reset_frame_buf = 1'b0;
	wire	[31:0]						iv_image_din;
	wire								o_front_fifo_full;
	reg									clk_vout = 1'b0;
	wire								i_buf_rd;
	wire								o_buf_empty;
	wire								o_buf_pe;
	wire	[32:0]						ov_image_dout;
	reg									i_frame_en = 1'b0;
	wire	[2:0]						iv_frame_depth;
	wire	[22:0]						iv_frame_size;

	wire								async_rst;
	wire								sysclk_2x;
	wire								sysclk_2x_180;
	wire								pll_ce_0;
	wire								pll_ce_90;
	wire								pll_lock;
	wire								mcb_drp_clk;
	wire								bufpll_mcb_lock;
	wire								clk_out3;
	wire								clk_out4;
	wire								clk_out5;

	reg			[15:0]					wv_line_active_pix_num		= `LINE_ACTIVE_PIX_NUM;
	reg			[15:0]					wv_line_hide_pix_num		= `LINE_HIDE_PIX_NUM;
	reg			[15:0]					wv_line_active_num			= `LINE_ACTIVE_NUMBER;
	reg			[15:0]					wv_frame_hide_pix_num		= `FRAME_HIDE_PIX_NUM;
	reg			[7:0]					wv_frame_to_line_pix_num	= `FRAME_TO_LINE_PIX_NUM;



	localparam	DRAM_DQ_WIRE_WIDTH	= (DDR3_16_DQ_MCB_8_DQ==1) ? 16 : NUM_DQ_PINS;
	wire	[DRAM_DQ_WIRE_WIDTH-1:0]	mcb3_dram_dq;

	wire	[MEM_ADDR_WIDTH-1:0]		mcb3_dram_a;
	wire	[MEM_BANKADDR_WIDTH-1:0]	mcb3_dram_ba;
	wire								mcb3_dram_ras_n;
	wire								mcb3_dram_cas_n;
	wire								mcb3_dram_we_n;
	wire								mcb3_dram_odt;
	wire								mcb3_dram_reset_n;
	wire								mcb3_dram_cke;
	wire								mcb3_dram_dm;
	wire								mcb3_dram_udqs;
	wire								mcb3_dram_udqs_n;
	wire								mcb3_rzq;
	wire								mcb3_zio;
	wire								mcb3_dram_udm;
	wire								mcb3_dram_dqs;
	wire								mcb3_dram_dqs_n;
	wire								mcb3_dram_ck;
	wire								mcb3_dram_ck_n;

	reg									sys_rst = 1'b0;
	reg									sys_clk = 1'b0;



	integer								file_src,file_src0,file_src1,file_src2,file_src3,file_src4,file_src5,file_src6,file_src7,
	file_src8,file_src9,file_src10,file_src11,file_src12,file_src13,file_src14,file_src15,file_src16,file_src17;
	integer								file_dst,file_dst0,file_dst1,file_dst2,file_dst3,file_dst4,file_dst5,file_dst6,file_dst7,
	file_dst8,file_dst9,file_dst10,file_dst11,file_dst12,file_dst13,file_dst14,file_dst15,file_dst16,file_dst17;
	integer								dst_cnt = 0;
	integer								src_cnt = 0;
	integer								file_frame_log = 0;
	integer								file_wr_data_log = 0;
	integer								file_rd_data_log = 0;

	//	reg									rst_pattern = 1'b0;
	wire								rst_pattern;
	integer								fval_fall_cnt = 0;
	reg		[31:0]						src_value = 32'b0;

	reg									buf_rd_en = 1'b0;
	wire								o_calib_done;
	wire								o_rd_error;
	wire								o_wr_error;

	reg		[1:0]						frame_en_cnt = 2'b0;
	wire								i_fval0;
	wire								i_fval1;
	wire								i_dval0;
	wire								i_dval1;
	wire	[31:0]						ov_frame_buf_version;

	reg									frame_en_d = 1'b0;
	reg									frame_en_chk = 1'b0;

	reg		[23:0]						DDR3_CMD;
	reg		[7:0]						rd_wr_cmd;
	wire	[2:0]						ddr_cmd_int;

	reg									bank [7:0];
	reg		[12:0]						row [7:0];
	genvar								i;
	reg		[12:0]						current_wr_row_addr;
	reg		[2:0]						current_wr_bank_addr;
	reg		[12:0]						current_rd_row_addr;
	reg		[2:0]						current_rd_bank_addr;

	//	ref ARCHITECTURE

	// Infrastructure-3 instantiation
	infrastructure # (
	.C_INCLK_PERIOD                 (`DDR3_PLL_CLKIN_PERIOD		),
	.C_CLKOUT0_DIVIDE               (`DDR3_PLL_CLKOUT0_DIVIDE	),
	.C_CLKOUT1_DIVIDE               (`DDR3_PLL_CLKOUT1_DIVIDE	),
	.C_CLKOUT2_DIVIDE               (`DDR3_PLL_CLKOUT2_DIVIDE	),
	.C_CLKOUT3_DIVIDE               (`DDR3_PLL_CLKOUT3_DIVIDE	),
	.C_CLKOUT4_DIVIDE               (`DDR3_PLL_CLKOUT4_DIVIDE	),
	.C_CLKOUT5_DIVIDE               (`DDR3_PLL_CLKOUT5_DIVIDE	),
	.C_CLKFBOUT_MULT                (`DDR3_PLL_CLKFBOUT_MULT	),
	.C_DIVCLK_DIVIDE                (`DDR3_PLL_DIVCLK_DIVIDE	)
	)
	ddr3_pll_inst (
	.sys_clk						(sys_clk			),
	.sys_rst						(sys_rst			),
	.async_rst						(async_rst			),
	.sysclk_2x						(sysclk_2x			),
	.sysclk_2x_180					(sysclk_2x_180		),
	.pll_ce_0						(pll_ce_0			),
	.pll_ce_90						(pll_ce_90			),
	.mcb_drp_clk					(mcb_drp_clk		),
	.bufpll_mcb_lock				(bufpll_mcb_lock	),
	.pll_lock						(pll_lock			),
	.clk_out3						(clk_out3			),
	.clk_out4						(clk_out4			),
	.clk_out5						(clk_out5			)
	);

	frame_buffer # (
	.NUM_DQ_PINS			(NUM_DQ_PINS		),
	.MEM_BANKADDR_WIDTH		(MEM_BANKADDR_WIDTH	),
	.MEM_ADDR_WIDTH			(MEM_ADDR_WIDTH		),
	.DDR3_MEMCLK_FREQ		(DDR3_MEMCLK_FREQ	),
	.MEM_ADDR_ORDER			(MEM_ADDR_ORDER		),
	.SKIP_IN_TERM_CAL		(SKIP_IN_TERM_CAL	),
	.DDR3_MEM_DENSITY		(DDR3_MEM_DENSITY	),
	.DDR3_TCK_SPEED			(DDR3_TCK_SPEED	),
	.DDR3_SIMULATION		(DDR3_SIMULATION	),
	.DDR3_CALIB_SOFT_IP		(DDR3_CALIB_SOFT_IP	)
	)
	frame_buffer_inst (
	.clk_vin				(clk_vin			),
	.i_fval					(i_fval				),
	.i_dval					(i_dval				),
	.iv_image_din			(iv_image_din		),
	.o_front_fifo_full		(o_front_fifo_full	),
	.clk_vout				(clk_vout			),
	.i_buf_rd				(i_buf_rd			),
	.o_buf_empty			(o_buf_empty		),
	.o_buf_pe				(o_buf_pe			),
	.ov_image_dout			(ov_image_dout		),
	.i_frame_en				(i_frame_en			),
	.iv_frame_depth			(iv_frame_depth		),
	.iv_frame_size			(iv_frame_size		),
	.clk_frame_buf			(clk_frame_buf		),
	.reset_frame_buf		(reset_frame_buf	),
	.async_rst				(async_rst			),
	.sysclk_2x				(sysclk_2x			),
	.sysclk_2x_180			(sysclk_2x_180		),
	.pll_ce_0				(pll_ce_0			),
	.pll_ce_90				(pll_ce_90			),
	.mcb_drp_clk			(mcb_drp_clk		),
	.bufpll_mcb_lock		(bufpll_mcb_lock	),
	.o_calib_done			(o_calib_done		),
	.o_wr_error             (o_wr_error			),
	.o_rd_error             (o_rd_error			),
	.mcb3_dram_dq			(mcb3_dram_dq		),
	.mcb3_dram_a			(mcb3_dram_a		),
	.mcb3_dram_ba			(mcb3_dram_ba		),
	.mcb3_dram_ras_n		(mcb3_dram_ras_n	),
	.mcb3_dram_cas_n		(mcb3_dram_cas_n	),
	.mcb3_dram_we_n			(mcb3_dram_we_n		),
	.mcb3_dram_odt			(mcb3_dram_odt		),
	.mcb3_dram_reset_n		(mcb3_dram_reset_n	),
	.mcb3_dram_cke			(mcb3_dram_cke		),
	.mcb3_dram_dm			(mcb3_dram_dm		),
	.mcb3_dram_udqs			(mcb3_dram_udqs		),
	.mcb3_dram_udqs_n		(mcb3_dram_udqs_n	),
	.mcb3_rzq				(mcb3_rzq			),
	.mcb3_zio				(mcb3_zio			),
	.mcb3_dram_udm			(mcb3_dram_udm		),
	.mcb3_dram_dqs			(mcb3_dram_dqs		),
	.mcb3_dram_dqs_n		(mcb3_dram_dqs_n	),
	.mcb3_dram_ck			(mcb3_dram_ck		),
	.mcb3_dram_ck_n			(mcb3_dram_ck_n		),
	.ov_frame_buf_version	(ov_frame_buf_version)
	);


	`ifdef	SIM_CHANGE_FRAME_SIZE

		pattern_model pattern_model_inst0 (
		.clk						(clk_vin			),
		.reset						(rst_pattern		),
		.iv_line_active_pix_num		(wv_line_active_pix_num		),
		.iv_line_hide_pix_num		(wv_line_hide_pix_num		),
		.iv_line_active_num			(wv_line_active_num			),
		.iv_frame_hide_pix_num		(wv_frame_hide_pix_num		),
		.iv_frame_to_line_pix_num	(wv_frame_to_line_pix_num	),
		.o_fval						(i_fval0				),
		.o_dval						(i_dval0				)
		);

		pattern_model pattern_model_inst1 (
		.clk						(clk_vin			),
		.reset						(rst_pattern		),
		.iv_line_active_pix_num		(wv_line_active_pix_num		),
		.iv_line_hide_pix_num		(wv_line_hide_pix_num		),
		.iv_line_active_num			(wv_line_active_num			),
		.iv_frame_hide_pix_num		(wv_frame_hide_pix_num		),
		.iv_frame_to_line_pix_num	(wv_frame_to_line_pix_num	),
		.o_fval						(i_fval1				),
		.o_dval						(i_dval1				)
		);


		assign	i_fval	= (frame_en_cnt == 0) ? i_fval0 : i_fval1;
		assign	i_dval	= (frame_en_cnt == 0) ? i_dval0 : i_dval1;

	`else

		pattern_model patten_model_inst (
		.clk						(clk_vin			),
		.reset						(rst_pattern		),
		.iv_line_active_pix_num		(wv_line_active_pix_num		),
		.iv_line_hide_pix_num		(wv_line_hide_pix_num		),
		.iv_line_active_num			(wv_line_active_num			),
		.iv_frame_hide_pix_num		(wv_frame_hide_pix_num		),
		.iv_frame_to_line_pix_num	(wv_frame_to_line_pix_num	),
		.o_fval						(i_fval				),
		.o_dval						(i_dval				)
		);


	`endif

	//  -------------------------------------------------------------------------------------
	//  DDR3 MODEL
	//  -------------------------------------------------------------------------------------
	PULLDOWN zio_pulldown3 (.O(mcb3_zio));   PULLDOWN rzq_pulldown3 (.O(mcb3_rzq));


//	`ifdef	DDR3_16_DQ_MCB_8_DQ
//		PULLDOWN mcb3_dram_dq_8 (.O(mcb3_dram_dq[8]));
//		PULLDOWN mcb3_dram_dq_9 (.O(mcb3_dram_dq[9]));
//		PULLDOWN mcb3_dram_dq_10 (.O(mcb3_dram_dq[10]));
//		PULLDOWN mcb3_dram_dq_11 (.O(mcb3_dram_dq[11]));
//		PULLDOWN mcb3_dram_dq_12 (.O(mcb3_dram_dq[12]));
//		PULLDOWN mcb3_dram_dq_13 (.O(mcb3_dram_dq[13]));
//		PULLDOWN mcb3_dram_dq_14 (.O(mcb3_dram_dq[14]));
//		PULLDOWN mcb3_dram_dq_15 (.O(mcb3_dram_dq[15]));
//
//		ddr3_model_c3 ddr3_model_c3_inst (
//		.ck         		(mcb3_dram_ck					),
//		.ck_n       		(mcb3_dram_ck_n					),
//		.cke        		(mcb3_dram_cke					),
//		.cs_n       		(1'b0							),
//		.ras_n      		(mcb3_dram_ras_n				),
//		.cas_n      		(mcb3_dram_cas_n				),
//		.we_n       		(mcb3_dram_we_n					),
//		.dm_tdqs    		({mcb3_dram_udm,mcb3_dram_dm}	),
//		.ba         		(mcb3_dram_ba					),
//		.addr       		(mcb3_dram_a					),
//		.dq         		(mcb3_dram_dq					),
//		.dqs      	  		({mcb3_dram_udqs,mcb3_dram_dqs}	),
//		.dqs_n      		({mcb3_dram_udqs_n,mcb3_dram_dqs_n}),
//		.tdqs_n     		(								),
//		.odt        		(mcb3_dram_odt					),
//		.rst_n      		(mcb3_dram_reset_n				)
//		);
//
//	`else
//		ddr3_model_c3 ddr3_model_c3_inst (
//		.ck         		(mcb3_dram_ck					),
//		.ck_n       		(mcb3_dram_ck_n					),
//		.cke        		(mcb3_dram_cke					),
//		.cs_n       		(1'b0							),
//		.ras_n      		(mcb3_dram_ras_n				),
//		.cas_n      		(mcb3_dram_cas_n				),
//		.we_n       		(mcb3_dram_we_n					),
//		//		`ifdef	DDR3_16_DQ
//		.dm_tdqs    		({mcb3_dram_udm,mcb3_dram_dm}	),
//		//		`elsif	DDR3_8_DQ
//		//			.dm_tdqs    		(mcb3_dram_dm					),
//		//		`endif
//		.ba         		(mcb3_dram_ba					),
//		//����ģ��ֻ��1Gb��2Gb����������û��512Mb���������ڷ���512Mbʱ��ֻ����1Gb��ģ�͡���˸�λ��ַ��Ҫ��0
//		`ifdef	DDR3_MEM_DENSITY_512Mb
//			.addr       	({1'b0,mcb3_dram_a}				),
//		`else
//			.addr       	(mcb3_dram_a					),
//		`endif
//		.dq         		(mcb3_dram_dq					),
//		`ifdef	DDR3_16_DQ
//			.dqs        	({mcb3_dram_udqs,mcb3_dram_dqs}	),
//		`elsif	DDR3_8_DQ
//			.dqs        	(mcb3_dram_dqs					),
//		`endif
//		`ifdef	DDR3_16_DQ
//			.dqs_n      	({mcb3_dram_udqs_n,mcb3_dram_dqs_n}),
//		`elsif	DDR3_8_DQ
//			.dqs_n      	(mcb3_dram_dqs_n				),
//		`endif
//		.tdqs_n     		(								),
//		.odt        		(mcb3_dram_odt					),
//		.rst_n      		(mcb3_dram_reset_n				)
//		);
//	`endif

	generate
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

	assign	ddr_cmd_int	= {mcb3_dram_ras_n,mcb3_dram_cas_n,mcb3_dram_we_n};
	always @ ( * ) begin
		case(ddr_cmd_int)
			3'b000 : begin
				DDR3_CMD	= "MRS";
			end
			3'b001 : begin
				DDR3_CMD	= "REF";
			end
			3'b010 : begin
				DDR3_CMD	= "PRE";
			end
			3'b011 : begin
				DDR3_CMD	= "ACT";
			end
			3'b100 : begin
				DDR3_CMD	= "WR";
			end
			3'b101 : begin
				DDR3_CMD	= "RD";
			end
			3'b110 : begin
				DDR3_CMD	= "ZQ";
			end
			3'b111 : begin
				DDR3_CMD	= "NOP";
			end
			default : begin

			end
		endcase
	end

	generate
		for(i = 0; i <= 7; i = i + 1) begin
			always @ (negedge mcb3_dram_reset_n or posedge mcb3_dram_ck) begin
				if(!mcb3_dram_reset_n) begin
					bank[i]	<= 1'b0;
					row[i]	<= 13'b0;
				end else begin
					if((DDR3_CMD == "ACT")&&(mcb3_dram_ba == i)) begin
						bank[i]	<= 1'b1;
						row[i]	<= mcb3_dram_a;
					end else if((DDR3_CMD == "PRE")&&(mcb3_dram_a[10] == 1'b0)&&(mcb3_dram_ba == i)) begin
						bank[i]	<= 1'b0;
					end else if((DDR3_CMD == "PRE")&&(mcb3_dram_a[10] == 1'b1)) begin
						bank[i]	<= 1'b0;
					end
				end
			end
		end
	endgenerate

	always @ (negedge mcb3_dram_reset_n or posedge mcb3_dram_ck) begin
		if(!mcb3_dram_reset_n) begin
			rd_wr_cmd	<= "N";
		end else begin
			if(DDR3_CMD == "RD") begin
				rd_wr_cmd	<= "R";
			end else if(DDR3_CMD == "WR") begin
				rd_wr_cmd	<= "W";
			end else if(DDR3_CMD == "PRE") begin
				rd_wr_cmd	<= "P";
			end else if(DDR3_CMD == "ACT") begin
				rd_wr_cmd	<= "A";
			end else if(DDR3_CMD == "REF") begin
				rd_wr_cmd	<= "R";
			end
		end
	end

	always @ (negedge mcb3_dram_reset_n or posedge mcb3_dram_ck) begin
		if(!mcb3_dram_reset_n) begin
			current_wr_bank_addr	<= 3'b0;
		end else begin
			if(DDR3_CMD == "WR") begin
				current_wr_bank_addr	<= mcb3_dram_ba;
			end
		end
	end

	always @ (negedge mcb3_dram_reset_n or posedge mcb3_dram_ck) begin
		if(!mcb3_dram_reset_n) begin
			current_wr_row_addr	<= 13'b0;
		end else begin
			if(DDR3_CMD == "WR") begin
				current_wr_row_addr	<= row[mcb3_dram_ba];
			end
		end
	end

	always @ (negedge mcb3_dram_reset_n or posedge mcb3_dram_ck) begin
		if(!mcb3_dram_reset_n) begin
			current_rd_bank_addr	<= 3'b0;
		end else begin
			if(DDR3_CMD == "RD") begin
				current_rd_bank_addr	<= mcb3_dram_ba;
			end
		end
	end

	always @ (negedge mcb3_dram_reset_n or posedge mcb3_dram_ck) begin
		if(!mcb3_dram_reset_n) begin
			current_rd_row_addr	<= 13'b0;
		end else begin
			if(DDR3_CMD == "RD") begin
				current_rd_row_addr	<= row[mcb3_dram_ba];
			end
		end
	end



	//  ===============================================================================================
	//	ref ��λ�ź�
	//  ===============================================================================================
	//������λ��ʱ���ź�
	`ifdef	SIM_CHANGE_RST
		initial begin
			sys_rst = 1'b1;
			#200
			sys_rst = 1'b0;
			#504100
			sys_rst = 1'b1;
			#1000000
			sys_rst = 1'b0;

		end


	`else
		initial begin
			sys_rst = 1'b1;
			#200
			sys_rst = 1'b0;
		end
	`endif


	assign	rst_pattern	= !o_calib_done;



	//  ===============================================================================================
	//	ref ʱ���ź�
	//  ===============================================================================================
	always # 12.5 						sys_clk 		= ~sys_clk;
	always # (`CLK_IN_PERIOD/2)			clk_vin 		= ~clk_vin;
	always # (`CLK_OUT_PERIOD/2)		clk_vout 		= ~clk_vout;
	always # (`CLK_FRAME_BUF_PERIOD/2)	clk_frame_buf 	= ~clk_frame_buf;

	//  ===============================================================================================
	//	ref ������������ź�
	//  ===============================================================================================
	`ifdef	SIM_CHANGE_FRAME_DEPTH
		assign	iv_frame_depth	= (frame_en_cnt == 0) ? `FRAME_DEPTH0 : `FRAME_DEPTH1;
	`else
		assign	iv_frame_depth	= `FRAME_DEPTH;
	`endif

	`ifdef	SIM_CHANGE_FRAME_SIZE
		assign	iv_frame_size	= (frame_en_cnt == 0) ? `FRAME_SIZE0 : `FRAME_SIZE1;
	`else
		assign	iv_frame_size	= `FRAME_SIZE;
	`endif

	//  ===============================================================================================
	//	ref ͣ�����ź�
	//  ===============================================================================================
	`ifdef	SIM_CHANGE_FRAME_EN
		initial begin
			i_frame_en		= 1'b1;
			//�ɼ�3֮֡��ֹͣ����
			wait(dst_cnt == 2);
			wait(frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.reading_rise == 1'b1);
			i_frame_en		= 1'b0;
			//100us֮�����´�ʹ�ܿ���
			#100000
			i_frame_en		= 1'b1;
		end
	`else
		initial begin
			i_frame_en		= 1'b1;
		end
	`endif

	always @ (posedge rst_pattern or posedge i_frame_en) begin
		if(rst_pattern) begin
			frame_en_cnt	<= 'b0;
		end else begin
			frame_en_cnt	<= frame_en_cnt + 1'b1;
		end
	end

	//  ===============================================================================================
	//	ref �����߶�ʹ��
	//  ===============================================================================================
	`ifdef	SIM_BACKEND_BLOCK
		initial begin
			buf_rd_en	= 1'b1;
			//���ڶ�֡��ʱ�����ӵ��
			wait(frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.reading_rise == 1'b1);
			#2000
			buf_rd_en	= 1'b0;
			#50000
			buf_rd_en	= 1'b1;
		end
		assign	i_buf_rd		= ~o_buf_empty & buf_rd_en;

	`elsif	SIM_READ_DELAY
		initial begin
			buf_rd_en	= 1'b0;
			#10
			@(negedge frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.writing); // �ȴ�ʱ���½���
			buf_rd_en	= 1'b0;
			#`SIM_DELAY_TIME_NUM
			buf_rd_en	= 1'b1;

		end

		assign	i_buf_rd		= ~o_buf_empty & buf_rd_en;


	`else
		assign	i_buf_rd		= ~o_buf_empty;
	`endif

	//  ===============================================================================================
	//	ref ����ʱ�����
	//  ===============================================================================================
	//�������֡���Ѿ����˵�ʱ���˳����棬����ʾ����ɹ�
	initial begin
		wait (dst_cnt == `SIM_FRAME_NUM);
		#10
		$display("*****************Simulation done,Successfully,Congratulations!*****************");
		$stop;
	end




	//  -------------------------------------------------------------------------------------
	//	�����������ͼ����������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_vin) begin
		if(i_dval) begin
			src_value	<= $random;
		end
	end
	assign	iv_image_din	= src_value;

	//  ===============================================================================================
	//	ref inputfile outputfile
	//  ===============================================================================================
	initial begin
		file_src0	= $fopen("../sim/input_file/0.txt","wb");
		file_src1	= $fopen("../sim/input_file/1.txt","wb");
		file_src2	= $fopen("../sim/input_file/2.txt","wb");
		file_src3	= $fopen("../sim/input_file/3.txt","wb");
		file_src4	= $fopen("../sim/input_file/4.txt","wb");
		file_src5	= $fopen("../sim/input_file/5.txt","wb");
		file_src6	= $fopen("../sim/input_file/6.txt","wb");
		file_src7	= $fopen("../sim/input_file/7.txt","wb");
		file_src8	= $fopen("../sim/input_file/8.txt","wb");
		file_src9	= $fopen("../sim/input_file/9.txt","wb");
		file_src10	= $fopen("../sim/input_file/10.txt","wb");
		file_src11	= $fopen("../sim/input_file/11.txt","wb");
		file_src12	= $fopen("../sim/input_file/12.txt","wb");
		file_src13	= $fopen("../sim/input_file/13.txt","wb");
		file_src14	= $fopen("../sim/input_file/14.txt","wb");
		file_src15	= $fopen("../sim/input_file/15.txt","wb");
		file_src16	= $fopen("../sim/input_file/16.txt","wb");
		file_src17	= $fopen("../sim/input_file/17.txt","wb");
	end

	always @ (posedge rst_pattern,negedge i_fval) begin
		if(rst_pattern) begin
			src_cnt	<= 'b0;
		end else begin
			if((frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.frame_en_int == 1'b1)&&(o_calib_done == 1'b1)) begin
				src_cnt	<= src_cnt + 1'b1;
			end
		end
	end

	always @ ( * ) begin
		if(src_cnt == 0) begin
			file_src	<= file_src0;
		end else if(src_cnt == 1) begin
			file_src	<= file_src1;
		end else if(src_cnt == 2) begin
			file_src	<= file_src2;
		end else if(src_cnt == 3) begin
			file_src	<= file_src3;
		end else if(src_cnt == 4) begin
			file_src	<= file_src4;
		end else if(src_cnt == 5) begin
			file_src	<= file_src5;
		end else if(src_cnt == 6) begin
			file_src	<= file_src6;
		end else if(src_cnt == 7) begin
			file_src	<= file_src7;
		end else if(src_cnt == 8) begin
			file_src	<= file_src8;
		end else if(src_cnt == 9) begin
			file_src	<= file_src9;
		end else if(src_cnt == 10) begin
			file_src	<= file_src10;
		end else if(src_cnt == 11) begin
			file_src	<= file_src11;
		end else if(src_cnt == 12) begin
			file_src	<= file_src12;
		end else if(src_cnt == 13) begin
			file_src	<= file_src13;
		end else if(src_cnt == 14) begin
			file_src	<= file_src14;
		end else if(src_cnt == 15) begin
			file_src	<= file_src15;
		end else if(src_cnt == 16) begin
			file_src	<= file_src16;
		end else if(src_cnt == 17) begin
			file_src	<= file_src17;
		end
	end

	//��������Ч������һ֡�Ѿ������յ�ʱ�򣬲Ż����������д���ļ�����
	always @ (posedge clk_vin) begin
		if(i_dval) begin
			if(frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.frame_en_int == 1'b1) begin
				$fwrite (file_src,"%c",src_value[31:24]);
				$fwrite (file_src,"%c",src_value[23:16]);
				$fwrite (file_src,"%c",src_value[15:8]);
				$fwrite (file_src,"%c",src_value[7:0]);
			end
		end
	end

	initial begin
		file_dst0	= $fopen("../sim/output_file/0.txt","wb");
		file_dst1	= $fopen("../sim/output_file/1.txt","wb");
		file_dst2	= $fopen("../sim/output_file/2.txt","wb");
		file_dst3	= $fopen("../sim/output_file/3.txt","wb");
		file_dst4	= $fopen("../sim/output_file/4.txt","wb");
		file_dst5	= $fopen("../sim/output_file/5.txt","wb");
		file_dst6	= $fopen("../sim/output_file/6.txt","wb");
		file_dst7	= $fopen("../sim/output_file/7.txt","wb");
		file_dst8	= $fopen("../sim/output_file/8.txt","wb");
		file_dst9	= $fopen("../sim/output_file/9.txt","wb");
		file_dst10	= $fopen("../sim/output_file/10.txt","wb");
		file_dst11	= $fopen("../sim/output_file/11.txt","wb");
		file_dst12	= $fopen("../sim/output_file/12.txt","wb");
		file_dst13	= $fopen("../sim/output_file/13.txt","wb");
		file_dst14	= $fopen("../sim/output_file/14.txt","wb");
		file_dst15	= $fopen("../sim/output_file/15.txt","wb");
		file_dst16	= $fopen("../sim/output_file/16.txt","wb");
		file_dst17	= $fopen("../sim/output_file/17.txt","wb");
	end

	always @ (posedge rst_pattern,posedge ov_image_dout[32]) begin
		if(rst_pattern) begin
			dst_cnt	<= 'b0;
		end else begin
			dst_cnt	<= dst_cnt + 1;
		end
	end

	always @ ( * ) begin
		if(dst_cnt == 0) begin
			file_dst	<= file_dst0;
		end else if(dst_cnt == 1) begin
			file_dst	<= file_dst1;
		end else if(dst_cnt == 2) begin
			file_dst	<= file_dst2;
		end else if(dst_cnt == 3) begin
			file_dst	<= file_dst3;
		end else if(dst_cnt == 4) begin
			file_dst	<= file_dst4;
		end else if(dst_cnt == 5) begin
			file_dst	<= file_dst5;
		end else if(dst_cnt == 6) begin
			file_dst	<= file_dst6;
		end else if(dst_cnt == 7) begin
			file_dst	<= file_dst7;
		end else if(dst_cnt == 8) begin
			file_dst	<= file_dst8;
		end else if(dst_cnt == 9) begin
			file_dst	<= file_dst9;
		end else if(dst_cnt == 10) begin
			file_dst	<= file_dst10;
		end else if(dst_cnt == 11) begin
			file_dst	<= file_dst11;
		end else if(dst_cnt == 12) begin
			file_dst	<= file_dst12;
		end else if(dst_cnt == 13) begin
			file_dst	<= file_dst13;
		end else if(dst_cnt == 14) begin
			file_dst	<= file_dst14;
		end else if(dst_cnt == 15) begin
			file_dst	<= file_dst15;
		end else if(dst_cnt == 16) begin
			file_dst	<= file_dst16;
		end else if(dst_cnt == 17) begin
			file_dst	<= file_dst17;
		end
	end

	always @ (posedge clk_vout) begin
		if((i_buf_rd == 1'b1)&&(ov_image_dout[32] == 1'b0)) begin
			$fwrite (file_dst,"%c",ov_image_dout[31:24]);
			$fwrite (file_dst,"%c",ov_image_dout[23:16]);
			$fwrite (file_dst,"%c",ov_image_dout[15:8]);
			$fwrite (file_dst,"%c",ov_image_dout[7:0]);
		end
	end

	//  ===============================================================================================
	//	ref log file
	//  ===============================================================================================

	//  -------------------------------------------------------------------------------------
	//	data_log��¼д����߶���MCB������
	//  ��¼д����������ݣ��������
	//  -------------------------------------------------------------------------------------
	initial begin
		file_wr_data_log	= $fopen("../sim/log_file/wr_data_log.txt","wb");
		file_rd_data_log	= $fopen("../sim/log_file/rd_data_log.txt","wb");
	end

	//��¼д�������
	always @ (posedge clk_frame_buf) begin
		if(frame_buffer_inst.w_p2_wr_en == 1'b1) begin
			$fdisplay (file_wr_data_log,"at time %0d ns wr en is valid.wr data is %h",$stime,frame_buffer_inst.wv_p2_wr_data);
		end
	end

	//��¼����������
	always @ (posedge clk_frame_buf) begin
		if(frame_buffer_inst.w_p3_rd_en == 1'b1) begin
			$fdisplay (file_rd_data_log,"at time %0d ns rd en is valid.rd data is %h",$stime,frame_buffer_inst.wv_p3_rd_data);
		end
	end

	//  -------------------------------------------------------------------------------------
	//	frame_log��¼��дָ��ı仯״̬
	//  -------------------------------------------------------------------------------------
	initial begin
		file_frame_log	= $fopen("../sim/log_file/frame_log.txt","wb");
	end


	//  ===============================================================================================
	//	ref ���ˢ�� refresh ��ʱ��
	//  ===============================================================================================
	reg		[11:0]	refresh_time_cnt 	= 12'b0;
	reg		[11:0]	refresh_num_cnt 	= 12'b0;
	integer			file_refresh_log;
	wire	[31:0]	refresh_time;

	initial begin
		file_refresh_log	= $fopen("../sim/log_file/refresh_log.txt","wb");
	end

	always @ ( posedge mcb3_dram_ck) begin
		if(!mcb3_dram_reset_n) begin
			refresh_num_cnt	<= 12'b0;
		end else begin
			if(DDR3_CMD == "REF") begin
				refresh_num_cnt	<= refresh_num_cnt + 1'b1;
			end
		end
	end

	always @ (posedge mcb3_dram_ck) begin
		if(!mcb3_dram_reset_n) begin
			refresh_time_cnt	<= 12'b0;
		end else begin
			if(DDR3_CMD == "REF") begin
				refresh_time_cnt	<= 12'b0;
			end
			else begin
				refresh_time_cnt	<= refresh_time_cnt + 1'b1;
			end
		end
	end

	`ifdef	DDR3_660
		assign	refresh_time	= refresh_time_cnt * 3.03;
	`elsif	DDR3_800
		assign	refresh_time	= refresh_time_cnt * 2.5;
	`endif

	always @ (posedge mcb3_dram_ck) begin
		if(DDR3_CMD == "REF") begin
			$fdisplay (file_refresh_log,"at time %0d ns\t%d refresh command interval is %d.",$stime,
			refresh_num_cnt,refresh_time);

		end
	end



	//  ===============================================================================================
	//	ref start monitor
	//  ===============================================================================================

	//  -------------------------------------------------------------------------------------
	//  ���Ӷ�дָ��
	//  -------------------------------------------------------------------------------------
	//fval������ʱ�̣��Լ���ʱ��֡������� ֡�����С
	always @ (posedge clk_vin) begin
		if(frame_buffer_inst.wrap_wr_logic_inst.fifo_con_inst.fval_rise == 1'b1) begin
			$display("at time %0d ns\tfval_rise is coming",$stime);
			$display("at time %0d ns\tframe depth is %b",$stime,iv_frame_depth);
			$display("at time %0d ns\tframe size is %h",$stime,iv_frame_size);
			$fdisplay (file_frame_log,"at time %0d ns\tNew Image is coming.config frame frame_depth is %b,frame_size is %h.",$stime,iv_frame_depth,iv_frame_size);
		end
	end

	//��ʼдһ֡��ʱ�̣��Լ���ʱ�Ĳ�����֡������Ⱥ�дָ��
	always @ (posedge clk_frame_buf) begin
		if(frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.writing_rise == 1'b1) begin
			$display("at time %0d ns\twriting is rise",$stime);
			$display("at time %0d ns\twr_logic sample frame depth is %b",$stime,frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.frame_depth_reg);
			$display("at time %0d ns\twr frame ptr is %h",$stime,frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.wr_frame_ptr);
			$fdisplay (file_frame_log,"at time %0d ns\tStart Write a frame. frame_depth is %b,wr frame ptr is %h.",$stime,
			frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.frame_depth_reg,frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.wr_frame_ptr);

		end
	end

	//һ֡д���ʱ�̣��Լ���ʱ�Ĳ�����֡������Ⱥ�дָ��
	always @ (posedge sys_rst,negedge frame_buffer_inst.w_writing) begin
		if(sys_rst) begin

		end else begin
			$display("at time %0d ns\twriting is down",$stime);
			$display("at time %0d ns\twr_logic sample frame depth is %b",$stime,frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.frame_depth_reg);
			$display("at time %0d ns\twr frame ptr is %h",$stime,frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.wr_frame_ptr);
			$fdisplay (file_frame_log,"at time %0d ns\tEnd Write a frame. frame_depth is %b,wr frame ptr is %h.",$stime,
			frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.frame_depth_reg,frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.wr_frame_ptr);
		end
	end

	//	//����һ��дburst��ʱ�̣��Լ���ʱ��д��ַ
	//	always @ (posedge clk_frame_buf) begin
	//		if(frame_buffer_inst.w_p2_cmd_en) begin
	//			$display("at time %0d ns wr cmd is valid",$stime);
	//			$display("at time %0d ns wr frame ptr is %h",$stime,frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.wr_frame_ptr);
	//			$display("at time %0d ns wr addr is %h",$stime,frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.wr_addr);
	//			$display("at time %0d ns wr byte addr is %h",$stime,frame_buffer_inst.wv_p2_cmd_byte_addr);
	//		end
	//	end

	//��ʼ��һ֡��ʱ�̣��Լ���ʱ��֡������ȡ�֡�����С����ָ��
	always @ (posedge clk_frame_buf) begin
		if(frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.reading_rise == 1'b1) begin
			$display("at time %0d ns\treading is rise",$stime);
			$display("at time %0d ns\trd_logic sample frame depth is %b",$stime,frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.frame_depth_reg);
			$display("at time %0d ns\trd_logic sample frame size is %h",$stime,frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.frame_size_reg);
			$display("at time %0d ns\trd frame ptr is %h",$stime,frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.rd_frame_ptr);
			$fdisplay (file_frame_log,"at time %0d ns\tStart Read a frame. frame_depth is %b,frame size is %h,rd frame ptr is %h.",$stime,
			frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.frame_depth_reg,frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.frame_size_reg,
			frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.rd_frame_ptr);
		end
	end

	//һ֡�����ʱ�̣��Լ���ʱ�Ĳ�����֡������Ⱥ�дָ��
	always @ (posedge sys_rst,negedge frame_buffer_inst.w_reading) begin
		if(sys_rst) begin

		end else begin
			$display("at time %0d ns\treading is down",$stime);
			$display("at time %0d ns\trd_logic sample frame depth is %b",$stime,frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.frame_depth_reg);
			$display("at time %0d ns\trd frame ptr is %h",$stime,frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.rd_frame_ptr);
			$fdisplay (file_frame_log,"at time %0d ns\tEnd Read over a frame. frame_depth is %b,rd frame ptr is %h.\n",$stime,
			frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.frame_depth_reg,frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.rd_frame_ptr);
		end
	end

	//	//����һ�ζ�burst��ʱ�̣��Լ���ʱ�Ķ���ַ
	//	always @ (posedge clk_frame_buf) begin
	//		if(frame_buffer_inst.w_p3_cmd_en) begin
	//			$display("at time %0d ns rd cmd is valid",$stime);
	//			$display("at time %0d ns rd frame ptr is %h",$stime,frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.rd_frame_ptr);
	//			$display("at time %0d ns rd addr is %h",$stime,frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.rd_addr);
	//			$display("at time %0d ns rd byte addr is %h",$stime,frame_buffer_inst.wv_p3_cmd_byte_addr);
	//		end
	//	end

	//  -------------------------------------------------------------------------------------
	//  FIFO�ؼ��ź�
	//  -------------------------------------------------------------------------------------
	//ǰ��FIFO�����źź�д�ź��Ƿ�ͬʱ��Ч.�����IDLE״̬���ˣ�˵����ʱдģ�鲢û�й�����
	always @ (posedge clk_vin) begin
		if((frame_buffer_inst.wrap_wr_logic_inst.front_buf_inst.wr_en & frame_buffer_inst.wrap_wr_logic_inst.front_buf_inst.full)
		&&(frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.current_state != "S_IDLE")) begin
			$display("**********Error! at time %0d ns\tfront buf write when full***********",$stime);
			#1000
			$stop;
		end
	end

	//ǰ��FIFO�Ŀ��źźͶ��ź��Ƿ�ͬʱ��Ч
	always @ (posedge clk_frame_buf) begin
		if(frame_buffer_inst.wrap_wr_logic_inst.front_buf_inst.rd_en & frame_buffer_inst.wrap_wr_logic_inst.front_buf_inst.empty) begin
			$display("**********Error! at time %0d ns\tfront buf read when empty**********",$stime);
			#1000
			$stop;
		end
	end


	//��һ֡�Ƿ�����
	always @ (posedge reset_frame_buf,posedge i_fval) begin
		if(reset_frame_buf) begin
			frame_en_d		<= 1'b0;
			frame_en_chk	<= 1'b0;
		end else begin
			frame_en_d		<= i_frame_en;
			frame_en_chk	<= frame_en_d;
		end
	end

	//��fval����������ʱ��ǰ��FIFO�Ƿ��ǿյ�.������һ֡�ǹ�����
	always @ (posedge clk_vin) begin
		if(frame_buffer_inst.wrap_wr_logic_inst.fifo_con_inst.fval_rise & ~frame_buffer_inst.wrap_wr_logic_inst.front_buf_inst.empty
		& frame_en_chk & o_calib_done) begin
			$display("**********Error! at time %0d ns\tfront buf is not empty when new frame is coming**********",$stime);
			#1000
			$stop;
		end
	end



	//MCB p2�˿ڵ�underrun�źŻ�error�ź��Ƿ���Ч
	//MCB p3�˿ڵ�overflow�źŻ�error�ź��Ƿ���Ч
	always @ (posedge clk_frame_buf) begin
		if(frame_buffer_inst.w_p2_wr_underrun_nc | frame_buffer_inst.w_p2_wr_error | frame_buffer_inst.w_p3_rd_overflow | frame_buffer_inst.w_p3_rd_error) begin
			$display("**********Error! at time %0d ns\tmcb buf is wrong**********",$stime);
			#1000
			$stop;
		end
	end

	//MCB p2�˿ڵ����źź�д�ź��Ƿ�ͬʱ��Ч
	always @ (posedge clk_frame_buf) begin
		if(frame_buffer_inst.w_p2_wr_en & frame_buffer_inst.w_p2_wr_full) begin
			$display("**********Error! at time %0d ns\tmcb wr buf full when writing**********",$stime);
			#1000
			$stop;
		end
	end

	//MCB p3�˿ڵĿ��źźͶ��ź��Ƿ�ͬʱ��Ч
	always @ (posedge clk_frame_buf) begin
		if(frame_buffer_inst.w_p3_rd_en & frame_buffer_inst.w_p3_rd_empty) begin
			$display("**********Error! at time %0d ns\tmcb rd buf empty when reading**********",$stime);
			#1000
			$stop;
		end
	end

	//��FIFO�����źź�д�ź��Ƿ�ͬʱ��Ч
	always @ (posedge clk_frame_buf) begin
		if(frame_buffer_inst.wrap_rd_logic_inst.back_buf_inst.full & frame_buffer_inst.wrap_rd_logic_inst.back_buf_inst.wr_en) begin
			$display("**********Error! at time %0d ns\tback buf is full when writing**********",$stime);
			#1000
			$stop;
		end
	end

	//��FIFO�Ŀ��źźͶ��ź��Ƿ�ͬʱ��Ч
	always @ (posedge clk_vout) begin
		if(frame_buffer_inst.wrap_rd_logic_inst.back_buf_inst.empty & frame_buffer_inst.wrap_rd_logic_inst.back_buf_inst.rd_en) begin
			$display("**********Error! at time %0d ns\tback buf is empty when reading**********",$stime);
			#1000
			$stop;
		end
	end
	//  -------------------------------------------------------------------------------------
	//  ��д������Ϣ
	//  -------------------------------------------------------------------------------------
	//��д��ͬһ֡ʱ������ַ�Ƿ�С��д��ַ
	always @ (posedge clk_frame_buf) begin
		if(frame_buffer_inst.w_reading & frame_buffer_inst.w_writing) begin
			if(frame_buffer_inst.wv_rd_frame_ptr == frame_buffer_inst.wv_wr_frame_ptr) begin
				if(frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.rd_addr > frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.wr_addr) begin
					$display("**********Error! at time %0d ns\trd addr great than wr addr when wr rd in the same frame**********",$stime);
					#1000
					$stop;
				end
			end
		end
	end

	//Writing��reading�Ƿ���ͬһʱ�̱�Ϊ��Ч
	always @ (posedge clk_frame_buf) begin
		if(frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.writing_rise & frame_buffer_inst.wrap_rd_logic_inst.rd_logic_inst.reading_rise) begin
			$display("**********Error! at time %0d ns\twriting & reading become valid at the same time**********",$stime);
			#1000
			$stop;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  ͼ����
	//  -------------------------------------------------------------------------------------
	//��˶�����ͼ���С�Ƿ�����õ�ͼ���Сһ��
	//�������Ƚ�����ļ���С�Ƿ��������ļ���Сһ�£�ue�Ƚ�

	//����֡����ģ�鵹��֮��ͼ���Ƿ�������
	//��������uc���ö����ƱȽ������ļ�������ļ�


	//  -------------------------------------------------------------------------------------
	//  ��֡��������
	//  -------------------------------------------------------------------------------------
	//дģ�����дһ֡��ʱ��
	always @ (posedge clk_frame_buf) begin
		if(frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.frame_depth_reg == 3'b001) begin
			if(frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.i_wr_ack & ~frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.able_to_write) begin
				$display("**********Warning! at time %0d ns\t1 frame.ignore one frame**********",$stime);
				$fdisplay (file_frame_log,"**********Warning! at time %0d ns\t1 frame.ignore one frame**********",$stime);
			end
		end
	end
	//  -------------------------------------------------------------------------------------
	//  2֡��������
	//  -------------------------------------------------------------------------------------
	//дָ������ָ���ʱ��
	always @ (posedge clk_frame_buf) begin
		if(frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.frame_depth_reg == 3'b010) begin
			if(frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.i_wr_ack & frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.i_reading) begin
				if(frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.wr_frame_ptr[0] == ~frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.iv_rd_frame_ptr[0]) begin
					$display("**********Warning! at time %0d ns 2 frame.wr frame ptr cross rd frame ptr**********",$stime);
					$display("at time %0d ns\t2 frame.wr frame ptr is %h rd frame ptr is %h",$stime,frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.wr_frame_ptr,
					frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.iv_rd_frame_ptr);

					$fdisplay(file_frame_log,"**********Warning! at time %0d ns 2 frame.wr frame ptr cross rd frame ptr**********",$stime);
					$fdisplay(file_frame_log,"at time %0d ns\t2 frame.wr frame ptr is %h rd frame ptr is %h",$stime,frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.wr_frame_ptr,
					frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.iv_rd_frame_ptr);
				end
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//  4֡��������
	//  -------------------------------------------------------------------------------------
	//дָ������ָ���ʱ��
	always @ (posedge clk_frame_buf) begin
		if(frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.frame_depth_reg == 3'b100) begin
			if(frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.i_wr_ack & frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.i_reading) begin
				if((frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.wr_frame_ptr + 1) == frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.iv_rd_frame_ptr) begin
					$display("**********Warning! at time %0d ns\t2 frame.wr frame ptr cross rd frame ptr**********",$stime);
					$display("at time %0d ns\t2 frame.wr frame ptr is %h rd frame ptr is %h",$stime,frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.wr_frame_ptr,
					frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.iv_rd_frame_ptr);

					$fdisplay(file_frame_log,"**********Warning! at time %0d ns 2 frame.wr frame ptr cross rd frame ptr**********",$stime);
					$fdisplay(file_frame_log,"at time %0d ns 2\tframe.wr frame ptr is %h rd frame ptr is %h",$stime,frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.wr_frame_ptr,
					frame_buffer_inst.wrap_wr_logic_inst.wr_logic_inst.iv_rd_frame_ptr);
				end
			end
		end
	end
	//  -------------------------------------------------------------------------------------
	//  ʹ�ܿ���
	//  -------------------------------------------------------------------------------------
	//ʹ�ܿ��عرգ��Ƿ���д������֡




	//  ===============================================================================================
	//  ref end monitor
	//  ===============================================================================================

endmodule
