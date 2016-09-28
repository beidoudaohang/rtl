//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : frame_buffer
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2013/6/14 14:00:40	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :	֡����ģ�鶥��
//              1)  : ��������ģ��
//					1.DDR3������
//					2.д�߼�����
//					3.���߼�����
//					4.�ٲ�ģ��
//
//              2)  : �Ը�λ�ź�����ͬ�����Ĵ���
//
//              3)  : ��ʹ���źŲ��������Ҹ�λʱ��ʹ���ź���Ч
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module frame_buffer # (
	parameter	NUM_DQ_PINS			= 16		,	//External memory data width
	parameter	MEM_BANKADDR_WIDTH	= 3			,	//External memory bank address width
	parameter	MEM_ADDR_WIDTH		= 13		,	//External memory address width.
	parameter	DDR3_MEMCLK_FREQ	= 320		,	//Memory data transfer clock frequency DDR3-640:3125 DDR3-660:3030 DDR3-720:2778 DDR3-800:2500
	parameter	MEM_ADDR_ORDER		= "ROW_BANK_COLUMN"	,	//"ROW_BANK_COLUMN" or "BANK_ROW_COLUMN"
	parameter	SKIP_IN_TERM_CAL	= 1			,	//1-calib input term 0-not calib input term.1 will decrease power consumption
	parameter	DDR3_MEM_DENSITY	= "1Gb"		,	//DDR3 ���� "1Gb" "512Mb"
	parameter	DDR3_TCK_SPEED		= "187E"	,	//DDR3 speed "187E" "15E" "125"
	parameter	DDR3_SIMULATION		= "FALSE"	,	//����ģʽ������MCB�����ٶ�
	parameter	DDR3_CALIB_SOFT_IP	= "TRUE"		//ʹ��calibrationģ��
	)
	(
	//  -------------------------------------------------------------------------------------
	//  ��Ƶ����ʱ����
	//  -------------------------------------------------------------------------------------
	input											clk_vin				,//ͼ������ʱ�ӣ���������Ч
	input											i_fval				,//����Ч�źţ�����Ч
	input											i_dval				,//������Ч�źţ�����Ч
	input		[31:0]								iv_image_din		,//ͼ������
	output											o_front_fifo_full	,
	//  -------------------------------------------------------------------------------------
	//  ��Ƶ���ʱ����
	//  -------------------------------------------------------------------------------------
	input											clk_vout			,//��ʱ��
	input											i_buf_rd			,//��ģ���ʹ�ܣ�����Ч
	output											o_buf_empty			,//��FIFO�գ�����Ч
	output											o_buf_pe			,//��FIFO��̿գ�����Ч
	output		[32:0]								ov_image_dout		,//��FIFO������������33bit
	//  -------------------------------------------------------------------------------------
	//  ��������
	//  -------------------------------------------------------------------------------------
	input											i_frame_en			,//ʹ�ܿ��أ���ͬ��������Ч
	input		[2:0]								iv_frame_depth		,//֡������ȣ��첽ʱ����
	input		[22:0]								iv_frame_size		,//֡�����С���첽ʱ����
	//  -------------------------------------------------------------------------------------
	//  ֡���湤��ʱ��
	//  -------------------------------------------------------------------------------------
	input											clk_frame_buf		,//֡����ģ�鹤��ʱ��
	input											reset_frame_buf		,//֡����ģ�鸴λ�źţ��� clk_frame_buf ʱ������
	//  -------------------------------------------------------------------------------------
	//  PLL PORT
	//  -------------------------------------------------------------------------------------
	input											async_rst			,//MCB ��λ�źţ�����Ч
	input											sysclk_2x			,//MCB ����ʱ��
	input											sysclk_2x_180		,//MCB ����ʱ��
	input											pll_ce_0			,//MCB ��λʹ���ź�
	input											pll_ce_90			,//MCB ��λʹ���ź�
	input											mcb_drp_clk			,//MCB DRP ʱ�ӣ�
	input											bufpll_mcb_lock		,//BUFPLL_MCB �����ź�
	//  -------------------------------------------------------------------------------------
	//  MCB Status
	//  -------------------------------------------------------------------------------------
	output											o_calib_done		,//DDR3У׼����źţ�����Ч
	output											o_wr_error			,//MCBд�˿ڳ��ִ��󣬸���Ч
	output											o_rd_error			,//MCB���˿ڳ��ִ��󣬸���Ч
	//  -------------------------------------------------------------------------------------
	//  External Memory
	//  -------------------------------------------------------------------------------------
	inout  		[NUM_DQ_PINS-1:0]       			mcb3_dram_dq		,
	output 		[MEM_ADDR_WIDTH-1:0]    			mcb3_dram_a			,
	output 		[MEM_BANKADDR_WIDTH-1:0]			mcb3_dram_ba		,
	output											mcb3_dram_ras_n		,
	output											mcb3_dram_cas_n		,
	output											mcb3_dram_we_n		,
	output											mcb3_dram_odt		,
	output											mcb3_dram_reset_n	,
	output											mcb3_dram_cke		,
	output											mcb3_dram_dm		,
	inout											mcb3_dram_udqs		,
	inout											mcb3_dram_udqs_n	,
	inout 											mcb3_rzq			,
	inout 											mcb3_zio			,
	output											mcb3_dram_udm		,
	inout 											mcb3_dram_dqs		,
	inout 											mcb3_dram_dqs_n		,
	output											mcb3_dram_ck		,
	output											mcb3_dram_ck_n		,
	//  -------------------------------------------------------------------------------------
	//  frame buf module version
	//  -------------------------------------------------------------------------------------
	output		[31:0]								ov_frame_buf_version	//֡����ģ��汾��
	);

	//	ref signals
	//  -------------------------------------------------------------------------------------
	//	��������
	//  -------------------------------------------------------------------------------------
	//ddr3��ʱ�����
	localparam	DDR3_MEM_TRAS	= (DDR3_TCK_SPEED=="187E") ? 37500 : ((DDR3_TCK_SPEED=="15E") ? 36000 : ((DDR3_TCK_SPEED=="125") ? 35000 : 35000));
	localparam	DDR3_MEM_TRCD	= (DDR3_TCK_SPEED=="187E") ? 13130 : ((DDR3_TCK_SPEED=="15E") ? 13500 : ((DDR3_TCK_SPEED=="125") ? 13750 : 13750));
	localparam	DDR3_MEM_TREFI	= (DDR3_TCK_SPEED=="187E") ? 7800000 : ((DDR3_TCK_SPEED=="15E") ? 7800000 : ((DDR3_TCK_SPEED=="125") ? 7800000 : 7800000));
	localparam	DDR3_MEM_TRFC	= (DDR3_TCK_SPEED=="187E") ? 160000 : ((DDR3_TCK_SPEED=="15E") ? 160000 : ((DDR3_TCK_SPEED=="125") ? 160000 : 160000));
	localparam	DDR3_MEM_TRP	= (DDR3_TCK_SPEED=="187E") ? 13130 : ((DDR3_TCK_SPEED=="15E") ? 13500 : ((DDR3_TCK_SPEED=="125") ? 13750 : 13750));
	localparam	DDR3_MEM_TWR	= (DDR3_TCK_SPEED=="187E") ? 15000 : ((DDR3_TCK_SPEED=="15E") ? 15000 : ((DDR3_TCK_SPEED=="125") ? 15000 : 15000));
	localparam	DDR3_MEM_TRTP	= (DDR3_TCK_SPEED=="187E") ? 7500 : ((DDR3_TCK_SPEED=="15E") ? 7500 : ((DDR3_TCK_SPEED=="125") ? 7500 : 7500));
	localparam	DDR3_MEM_TWTR	= (DDR3_TCK_SPEED=="187E") ? 7500 : ((DDR3_TCK_SPEED=="15E") ? 7500 : ((DDR3_TCK_SPEED=="125") ? 7500 : 7500));

	//ddr3��ַ�߿��
	localparam	RD_WR_WITH_PRE	= "FALSE"	;	//��д������治����Ԥ������� "TRUE" or "FALSE"
	
	
	//Memory data transfer clock period DDR3-640:3125 DDR3-660:3030 DDR3-720:2778 DDR3-800:2500
	localparam	DDR3_MEMCLK_PERIOD	= 1000000/DDR3_MEMCLK_FREQ;
	
	//  -------------------------------------------------------------------------------------
	//	��������
	//  -------------------------------------------------------------------------------------
	reg							rst_dly0 			= 1'b1;
	reg							rst_dly1 			= 1'b1;
	reg							frame_en_d 			= 1'b0;
	reg							frame_en_sync 		= 1'b0;
	reg		[2:0]				frame_depth_d 		= 3'b0;
	reg		[2:0]				frame_depth_sync 	= 3'b0;
	reg		[22:0]				frame_size_d 		= 23'b0;
	wire	[1:0]				wv_wr_frame_ptr		;
	wire	[1:0]				wv_rd_frame_ptr		;
	wire	[16:0]				wv_wr_addr			;
	wire						w_wr_req			;
	wire						w_wr_ack			;
	wire						w_writing			;
	wire						w_rd_req			;
	wire						w_rd_ack			;
	wire						w_reading			;

	wire						w_calib_done		;
	wire						w_p2_cmd_en			;
	wire	[2:0]				wv_p2_cmd_instr		;
	wire	[5:0]				wv_p2_cmd_bl		;
	wire	[29:0]				wv_p2_cmd_byte_addr	;
	wire						w_p2_cmd_empty		;
	wire						w_p2_cmd_full		;
	wire						w_p2_wr_en			;
	wire	[3:0]				wv_p2_wr_mask		;
	wire	[31:0]				wv_p2_wr_data		;
	wire						w_p2_wr_full		;
	wire						w_p2_wr_empty		;
	wire	[6:0]				wv_p2_wr_count		;
	wire						w_p2_wr_underrun_nc	;
	wire						w_p2_wr_error		;
	wire						w_p3_cmd_en			;
	wire	[2:0]				wv_p3_cmd_instr		;
	wire	[5:0]				wv_p3_cmd_bl		;
	wire	[29:0]				wv_p3_cmd_byte_addr	;
	wire						w_p3_cmd_empty		;
	wire						w_p3_cmd_full		;
	wire						w_p3_rd_en			;
	wire	[31:0]				wv_p3_rd_data		;
	wire						w_p3_rd_full		;
	wire						w_p3_rd_empty		;
	wire	[6:0]				wv_p3_rd_count		;
	wire						w_p3_rd_overflow	;
	wire						w_p3_rd_error		;

	//	ref ARCHITECTURE


	//  -------------------------------------------------------------------------------------
	//  ref version
	//  -------------------------------------------------------------------------------------
	assign	ov_frame_buf_version = 32'h00_00_00_10;

	//  -------------------------------------------------------------------------------------
	//  �첽����
	//  -------------------------------------------------------------------------------------
	//������λ��Чʱ�������ź�Ҫ�ر�
	always @ (posedge clk_frame_buf) begin
		if(reset_frame_buf) begin
			frame_en_d		<= 1'b0;
			frame_en_sync	<= 1'b0;
		end else begin
			frame_en_d		<= i_frame_en;
			frame_en_sync	<= frame_en_d;
		end
	end

	//����֡�������
	always @ (posedge clk_frame_buf) begin
		if(reset_frame_buf) begin
			frame_depth_d		<= 3'b000;
			frame_depth_sync	<= 3'b000;
		end else begin
			frame_depth_d		<= iv_frame_depth;
			frame_depth_sync	<= frame_depth_d;
		end
	end

	//����֡�����С��ֻ����һ�ģ�����ģ�����ٴ�һ��
	always @ (posedge clk_frame_buf) begin
		if(reset_frame_buf) begin
			frame_size_d	<= 'b0;
		end else begin
			frame_size_d	<= iv_frame_size;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  ����ź�
	//  -------------------------------------------------------------------------------------
	assign	o_calib_done	= w_calib_done;
	assign	o_wr_error		= w_p2_wr_error;
	assign	o_rd_error		= w_p3_rd_error;

	//  -------------------------------------------------------------------------------------
	//  д�߼�����ģ��
	//  -------------------------------------------------------------------------------------
	wrap_wr_logic # (
	.RD_WR_WITH_PRE			(RD_WR_WITH_PRE		),
	.DDR3_MEM_DENSITY		(DDR3_MEM_DENSITY	)
	)
	wrap_wr_logic_inst (
	.clk_vin				(clk_vin				),
	.i_fval					(i_fval					),
	.i_dval					(i_dval					),
	.iv_image_din			(iv_image_din			),
	.o_front_fifo_full		(o_front_fifo_full		),
	.i_frame_en				(frame_en_sync			),
	.iv_frame_depth			(frame_depth_sync		),
	.clk					(clk_frame_buf			),
	.reset					(reset_frame_buf		),
	.ov_wr_frame_ptr		(wv_wr_frame_ptr		),
	.ov_wr_addr				(wv_wr_addr				),
	.o_wr_req				(w_wr_req				),
	.i_wr_ack				(w_wr_ack				),
	.o_writing				(w_writing				),
	.iv_rd_frame_ptr		(wv_rd_frame_ptr		),
	.i_reading				(w_reading				),
	.i_calib_done			(w_calib_done			),
	.o_p2_cmd_en			(w_p2_cmd_en			),
	.ov_p2_cmd_instr		(wv_p2_cmd_instr		),
	.ov_p2_cmd_bl			(wv_p2_cmd_bl			),
	.ov_p2_cmd_byte_addr	(wv_p2_cmd_byte_addr	),
	.i_p2_cmd_empty			(w_p2_cmd_empty			),
	.i_p2_cmd_full			(w_p2_cmd_full			),
	.o_p2_wr_en				(w_p2_wr_en				),
	.ov_p2_wr_mask			(wv_p2_wr_mask			),
	.ov_p2_wr_data			(wv_p2_wr_data			),
	.i_p2_wr_full			(w_p2_wr_full			),
	.i_p2_wr_empty			(w_p2_wr_empty			)
	);

	//  -------------------------------------------------------------------------------------
	//  ���߼�����ģ��
	//  -------------------------------------------------------------------------------------
	wrap_rd_logic # (
	.RD_WR_WITH_PRE			(RD_WR_WITH_PRE		),
	.DDR3_MEM_DENSITY		(DDR3_MEM_DENSITY	)
	)
	wrap_rd_logic_inst (
	.clk_vout				(clk_vout				),
	.i_buf_rd				(i_buf_rd				),
	.o_buf_empty			(o_buf_empty			),
	.o_buf_pe				(o_buf_pe				),
	.ov_image_dout			(ov_image_dout			),
	.i_frame_en				(frame_en_sync			),
	.iv_frame_depth			(frame_depth_sync		),
	.iv_frame_size			(frame_size_d			),
	.clk					(clk_frame_buf			),
	.reset					(reset_frame_buf		),
	.ov_rd_frame_ptr		(wv_rd_frame_ptr		),
	.o_rd_req				(w_rd_req				),
	.i_rd_ack				(w_rd_ack				),
	.o_reading				(w_reading				),
	.iv_wr_frame_ptr		(wv_wr_frame_ptr		),
	.iv_wr_addr				(wv_wr_addr				),
	.i_writing				(w_writing				),
	.i_calib_done			(w_calib_done			),
	.o_p3_cmd_en			(w_p3_cmd_en			),
	.ov_p3_cmd_instr		(wv_p3_cmd_instr		),
	.ov_p3_cmd_bl			(wv_p3_cmd_bl			),
	.ov_p3_cmd_byte_addr	(wv_p3_cmd_byte_addr	),
	.i_p3_cmd_empty			(w_p3_cmd_empty			),
	.i_p3_cmd_full			(w_p3_cmd_full			),
	.o_p3_rd_en				(w_p3_rd_en				),
	.iv_p3_rd_data			(wv_p3_rd_data			),
	.i_p3_rd_full			(w_p3_rd_full			),
	.i_p3_rd_empty			(w_p3_rd_empty			),
	.i_p3_rd_overflow		(w_p3_rd_overflow		),
	.i_p3_rd_error			(w_p3_rd_error			),
	.i_p2_cmd_empty			(w_p2_cmd_empty			)
	);

	//  -------------------------------------------------------------------------------------
	//  ��д�ٲ�ģ��
	//  -------------------------------------------------------------------------------------
	judge judge_inst (
	.clk					(clk_frame_buf	),
	.i_wr_req				(w_wr_req		),
	.i_rd_req				(w_rd_req		),
	.o_wr_ack				(w_wr_ack		),
	.o_rd_ack				(w_rd_ack		)
	);

	//  -------------------------------------------------------------------------------------
	//  MCB (Memory Controller Block) DDR3������ģ��
	//  -------------------------------------------------------------------------------------
	mig_core # (
	.C3_P0_MASK_SIZE		(4						),
	.C3_P0_DATA_PORT_SIZE	(32						),
	.C3_P1_MASK_SIZE		(4						),
	.C3_P1_DATA_PORT_SIZE	(32						),
	.DEBUG_EN				(0						),
	.C3_MEMCLK_PERIOD		(DDR3_MEMCLK_PERIOD		),
	.C3_CALIB_SOFT_IP		(DDR3_CALIB_SOFT_IP		),
	.C3_SIMULATION			(DDR3_SIMULATION		),
	.C3_MEM_ADDR_ORDER		(MEM_ADDR_ORDER			),
	.C3_NUM_DQ_PINS			(NUM_DQ_PINS			),
	.C3_MEM_ADDR_WIDTH		(MEM_ADDR_WIDTH			),
	.C3_MEM_BANKADDR_WIDTH	(MEM_BANKADDR_WIDTH		),
	.SKIP_IN_TERM_CAL		(SKIP_IN_TERM_CAL		),
	.DDR3_MEM_DENSITY		(DDR3_MEM_DENSITY		),
	.DDR3_MEM_TRAS			(DDR3_MEM_TRAS			),
	.DDR3_MEM_TRCD			(DDR3_MEM_TRCD			),
	.DDR3_MEM_TREFI			(DDR3_MEM_TREFI			),
	.DDR3_MEM_TRFC			(DDR3_MEM_TRFC			),
	.DDR3_MEM_TRP			(DDR3_MEM_TRP			),
	.DDR3_MEM_TWR			(DDR3_MEM_TWR			),
	.DDR3_MEM_TRTP			(DDR3_MEM_TRTP			),
	.DDR3_MEM_TWTR			(DDR3_MEM_TWTR			)
	)
	mig_core_inst (
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
	.c3_calib_done			(w_calib_done		),
	.c3_p2_cmd_clk			(clk_frame_buf		),
	.c3_p2_cmd_en			(w_p2_cmd_en		),
	.c3_p2_cmd_instr		(wv_p2_cmd_instr	),
	.c3_p2_cmd_bl			(wv_p2_cmd_bl		),
	.c3_p2_cmd_byte_addr	(wv_p2_cmd_byte_addr),
	.c3_p2_cmd_empty		(w_p2_cmd_empty		),
	.c3_p2_cmd_full			(w_p2_cmd_full		),
	.c3_p2_wr_clk			(clk_frame_buf		),
	.c3_p2_wr_en			(w_p2_wr_en			),
	.c3_p2_wr_mask			(wv_p2_wr_mask		),
	.c3_p2_wr_data			(wv_p2_wr_data		),
	.c3_p2_wr_full			(w_p2_wr_full		),
	.c3_p2_wr_empty			(w_p2_wr_empty		),
	.c3_p2_wr_count			(wv_p2_wr_count		),
	.c3_p2_wr_underrun		(w_p2_wr_underrun_nc),
	.c3_p2_wr_error			(w_p2_wr_error		),
	.c3_p3_cmd_clk			(clk_frame_buf		),
	.c3_p3_cmd_en			(w_p3_cmd_en		),
	.c3_p3_cmd_instr		(wv_p3_cmd_instr	),
	.c3_p3_cmd_bl			(wv_p3_cmd_bl		),
	.c3_p3_cmd_byte_addr	(wv_p3_cmd_byte_addr),
	.c3_p3_cmd_empty		(w_p3_cmd_empty		),
	.c3_p3_cmd_full			(w_p3_cmd_full		),
	.c3_p3_rd_clk			(clk_frame_buf		),
	.c3_p3_rd_en			(w_p3_rd_en			),
	.c3_p3_rd_data			(wv_p3_rd_data		),
	.c3_p3_rd_full			(w_p3_rd_full		),
	.c3_p3_rd_empty			(w_p3_rd_empty		),
	.c3_p3_rd_count			(wv_p3_rd_count		),
	.c3_p3_rd_overflow		(w_p3_rd_overflow	),
	.c3_p3_rd_error			(w_p3_rd_error		),
	.c3_async_rst			(async_rst			),
	.c3_sysclk_2x			(sysclk_2x			),
	.c3_sysclk_2x_180		(sysclk_2x_180		),
	.c3_pll_ce_0			(pll_ce_0			),
	.c3_pll_ce_90			(pll_ce_90			),
	.c3_pll_lock			(bufpll_mcb_lock	),
	.c3_mcb_drp_clk			(mcb_drp_clk		)
	);



endmodule
