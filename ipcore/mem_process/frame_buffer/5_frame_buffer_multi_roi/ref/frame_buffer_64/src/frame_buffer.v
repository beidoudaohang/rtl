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
//  -- ��ǿ       	:| 2014/11/27 10:16:54	:|  ��ֲ��MER-U3V���̣�ȥ���ٲ�ģ��
//	-- ��ǿ			:| 2015/10/15 15:01:05	:|	Ϊ��Ӧ��ͨ������cmossensor��д��port��չ��64bits
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :	֡����ģ�鶥��
//              1)  : ��������ģ��
//					1.DDR3������
//					2.д�߼�����
//					3.���߼�����
//
//              2)  : �Ը�λ�ź�����ͬ�����Ĵ���
//
//              3)  : ��ʹ���źŲ��������Ҹ�λʱ��ʹ���ź���Ч
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps

module frame_buffer # (
	parameter	BUF_DEPTH_WD				= 3						,	//֡�����λ��,�������֧��4֡��ȣ���һλ��λλ
	parameter	NUM_DQ_PINS					= 16					,	//DDR3���ݿ��
	parameter	MEM_BANKADDR_WIDTH			= 3						,	//DDR3bank���
	parameter	MEM_ADDR_WIDTH				= 13					,	//DDR3��ַ���
	parameter	DDR3_MEMCLK_FREQ			= 320					,	//DDR3ʱ��Ƶ��
	parameter	MEM_ADDR_ORDER				= "ROW_BANK_COLUMN"		,	//DDR3��ַ�Ų�˳��
	parameter 	DDR3_RST_ACT_LOW          	= 0						,   // # = 1 for active low reset,# = 0 for active high reset.
	parameter 	DDR3_INPUT_CLK_TYPE       	= "SINGLE_ENDED"		,   // input clock type DIFFERENTIAL or SINGLE_ENDED
	parameter	SKIP_IN_TERM_CAL			= 1						,	//��У׼������裬��ʡ����
	parameter	DDR3_MEM_DENSITY			= "1Gb"					,	//DDR3����
	parameter	DDR3_TCK_SPEED				= "15E"					,	//DDR3���ٶȵȼ�
//	parameter	DDR3_SIMULATION				= "FALSE"				,	//�򿪷�����Լ��ٷ����ٶȣ�����ʵ�ʲ��ֲ���ʱ�����ܴ򿪷��档
	parameter	DDR3_SIMULATION				= "TRUE"				,	//�򿪷�����Լ��ٷ����ٶȣ�����ʵ�ʲ��ֲ���ʱ�����ܴ򿪷��档
	parameter	DDR3_CALIB_SOFT_IP			= "TRUE"				,	//����ʱ�����Բ�ʹ��У׼�߼�
	parameter	DDR3_P0_MASK_SIZE			= 8						,	//p0��mask size
	parameter	DDR3_P1_MASK_SIZE			= 8						,	//p1��mask size
	parameter	DATA_WD						= 64					,	//��������λ��
	parameter	GPIF_DAT_WIDTH				= 32					,	//�������λ��
	parameter	FSIZE_WD					= 25					,	//֡��С��ȶ���
	parameter	BSIZE_WD					= 9						,	//һ��BURST ������ռ��λ��
	parameter	REG_WD   					= 32
	)
	(
//  ===============================================================================================
//  ��Ƶ����ʱ����
//  ===============================================================================================
	input									clk_vin					,	//��������ʱ�ӣ���ͨ��sensorΪ����ͨ·ʱ��
	input									i_fval					,	//clk_pixʱ���򣬳���Ч�ź�
	input									i_dval					,	//clk_pixʱ����������Ч�ź�
	input									i_trailer_flag			,	//clk_pixʱ����β����־
	input		[DATA_WD-1				:0]	iv_image_din			,	//clk_pixʱ����ͼ������
	input									i_stream_en_clk_in		,	//��ֹͣ�źţ�clk_inʱ�����ź���Чʱ������������֡д��֡�棬��Чʱ����ֹͣд�룬����λ��д��ַָ�룬��֡��
//  ===============================================================================================
//  ��Ƶ���ʱ����
//  ===============================================================================================
	input									clk_vout				,	//gpif ʱ�ӣ�100MHz
	input									i_buf_rd				,   //clk_gpifʱ���򣬺�ģ���ʹ��
	output									o_back_buf_empty		,	//clk_gpifʱ����֡����FIFO�ձ�־������ָʾ֡�����Ƿ������ݿɶ�
	output		[GPIF_DAT_WIDTH-1		:0]	ov_frame_dout			,   //clk_gpifʱ���򣬺�FIFO������������32bit
	output									o_frame_valid			,	//clk_gpifʱ����֡�����������Ч
//  ===============================================================================================
//  ֡���湤��ʱ��
//  ===============================================================================================
	input									clk_frame_buf			,	//֡��ʱ�ӣ�
	input									reset_frame_buf			,	//֡��ʱ�ӵĸ�λ�ź�
//  ===============================================================================================
//  ��������
//  ===============================================================================================
	input									i_stream_en				,	//clk_frame_bufʱ������ʹ���źţ�SE=1�ȴ�����֡��SE=0����ֹͣ������ǰ������д��
	input		[BUF_DEPTH_WD-1			:0]	iv_frame_depth			,   //clk_frame_bufʱ����֡�������
	input		[FSIZE_WD -1			:0]	iv_payload_size_frame_buf,   //clk_frame_bufʱ����payload��С������֡���С��֧��32M����ͼ���С
	input		[FSIZE_WD -1			:0]	iv_payload_size_pix		,
	input									i_chunkmodeactive		,	//clk_frame_bufʱ����chunk�ܿ��أ�chunk����Ӱ��leader��trailer�Ĵ�С��ͨ���ж�chunk���ؿ���֪��leader��trailer����
//  ===============================================================================================
//  PLL PORT
//  ===============================================================================================
	input									i_async_rst				,	//MCB ��λ�źţ�����Ч
	input									i_sysclk_2x				,	//MCB ����ʱ��
	input									i_sysclk_2x_180			,	//MCB ����ʱ��
	input									i_pll_ce_0				,	//MCB ��λʹ���ź�
	input									i_pll_ce_90				,	//MCB ��λʹ���ź�
	input									i_mcb_drp_clk			,	//MCB DRP ʱ�ӣ�
	input									i_bufpll_mcb_lock		,	//BUFPLL_MCB �����ź�
//  ===============================================================================================
//  MCB Status
//  ===============================================================================================
	output									o_calib_done			,	//clk_frame_bufʱ����DDR3У׼����źţ�����Ч
	output									o_wr_error				,	//MCBд�˿ڳ��ִ��󣬸���Ч
	output									o_rd_error				,	//MCB���˿ڳ��ִ��󣬸���Ч
//  ===============================================================================================
//  External Memory
//  ===============================================================================================
	inout  		[NUM_DQ_PINS-1			:0]	mcb1_dram_dq			,	//�����ź�
	output 		[MEM_ADDR_WIDTH-1		:0]	mcb1_dram_a         	,	//��ַ�ź�
	output 		[MEM_BANKADDR_WIDTH-1	:0]	mcb1_dram_ba        	,	//Bank��ַ�ź�
	output									mcb1_dram_ras_n     	,	//�е�ַѡͨ
	output									mcb1_dram_cas_n     	,	//�е�ַѡͨ
	output									mcb1_dram_we_n      	,	//д�ź�
	output									mcb1_dram_odt       	,	//�迹ƥ���ź�
	output									mcb1_dram_reset_n   	,	//��λ�ź�
	output									mcb1_dram_cke       	,	//ʱ��ʹ���ź�
	output									mcb1_dram_dm        	,	//���ֽ����������ź�
	inout 									mcb1_dram_udqs      	,	//���ֽڵ�ַѡͨ�ź���
	inout 									mcb1_dram_udqs_n    	,	//���ֽڵ�ַѡͨ�źŸ�
	inout 									mcb1_rzq            	,	//����У׼
	output									mcb1_dram_udm       	,	//���ֽ����������ź�
	inout 									mcb1_dram_dqs       	,	//���ֽ�	����ѡͨ�ź���
	inout 									mcb1_dram_dqs_n     	,	//���ֽ�����ѡͨ�źŸ�
	output									mcb1_dram_ck        	,	//ʱ����
	output									mcb1_dram_ck_n      		//ʱ�Ӹ�

	);
//  -------------------------------------------------------------------------------------
//	��������
//  -------------------------------------------------------------------------------------
	localparam	DDR3_MEMCLK_PERIOD	= 1000000/DDR3_MEMCLK_FREQ	;
	localparam	BURST_SIZE			= 7'h40						;
	localparam	ADDR_WD   			= 19-BUF_DEPTH_WD			;//֡�ڵ�ַλ�� 19=30-2-9,9bit��64λ��864��Ⱦ�����128M��Ӧ27λ��wr_frame_ptr��һ����λbit����-2
//  ===============================================================================================
//  ��������
//  ===============================================================================================
	wire									w_p_in_cmd_en         	;	//wrap_wr_logic�����clk_frame_bufʱ����mcb p2 ��д�ź�
	wire		[2						:0]	wv_p_in_cmd_instr     	;	//wrap_wr_logic�����clk_frame_bufʱ����mcb p2 ��д����
	wire		[5						:0]	wv_p_in_cmd_bl        	;	//wrap_wr_logic�����clk_frame_bufʱ����mcb p2 ��д���ݵĳ���
	wire		[29						:0]	wv_p_in_cmd_byte_addr 	;	//wrap_wr_logic�����clk_frame_bufʱ����mcb p2 ��д���ݵĵ�ַ
	wire									w_p_in_cmd_empty      	;	//mig_core�����clk_frame_bufʱ����mcb p2 ������fifo��
	wire									w_p_in_cmd_full       	;	//mig_core�����clk_frame_bufʱ����mcb p2 ������fifo��
	wire									w_p_in_wr_en          	;	//wrap_wr_logic�����clk_frame_bufʱ����mcb p2 ��д���ݵĵ�ַ
	wire		[DDR3_P1_MASK_SIZE-1	:0]	wv_p_in_wr_mask       	;	//wrap_wr_logic�����clk_frame_bufʱ����mcb p2 ��д���������ź�
	wire		[DATA_WD-1				:0]	wv_p_in_wr_data       	;	//wrap_wr_logic�����clk_frame_bufʱ����mcb p2 ��д����
	wire									w_p_in_wr_full        	;	//mig_core�����clk_frame_bufʱ����mcb p2 ������fifo��
	wire									w_p_in_wr_empty       	;	//mig_core�����clk_frame_bufʱ����mcb p2 ������fifo��
	wire		[6						:0]	wv_p_in_wr_count		;	//mig_core�����clk_frame_bufʱ����mcb p2 ������fifo���ݸ���

	wire									w_p_out_cmd_en         	;	//wrap_rd_logic�����clk_frame_bufʱ����mcb p3 �ڶ��ź�
	wire		[2						:0]	wv_p_out_cmd_instr     	;	//wrap_rd_logic�����clk_frame_bufʱ����mcb p3 �ڶ�����
	wire		[5						:0]	wv_p_out_cmd_bl        	;	//wrap_rd_logic�����clk_frame_bufʱ����mcb p3 �ڶ����ݵĳ���
	wire		[29						:0]	wv_p_out_cmd_byte_addr 	;	//wrap_rd_logic�����clk_frame_bufʱ����mcb p3 �ڶ����ݵĵ�ַ
	wire									w_p_out_cmd_empty      	;	//mig_core�����clk_frame_bufʱ����mcb p3 ������fifo��
	wire									w_p_out_cmd_full       	;	//mig_core�����clk_frame_bufʱ����mcb p3 ������fifo��
	wire									w_p_out_rd_en          	;	//wrap_rd_logic�����clk_frame_bufʱ����mcb p3 �ڶ����ݵĵ�ַ
	wire		[DATA_WD-1				:0]	wv_p_out_rd_data       	;	//wrap_rd_logic�����clk_frame_bufʱ����mcb p3 �ڶ����������ź�
	wire									w_p_out_rd_full        	;	//wrap_rd_logic�����clk_frame_bufʱ����mcb p3 �ڶ�����
	wire									w_p_out_rd_empty       	;	//mig_core�����clk_frame_bufʱ����mcb p3 ������fifo��
	wire									w_p_out_rd_overflow    	;	//mig_core�����clk_frame_bufʱ����mcb p3 ������fifo���
	wire		[6						:0]	wv_p_out_rd_count		;	//mig_core�����clk_frame_bufʱ����mcb p3 ������fifo���ݸ���

	wire		[BUF_DEPTH_WD-1			:0]	wv_wr_frame_ptr     	;	//wrap_wr_logic�����clk_frame_bufʱ����дָ��
	wire		[ADDR_WD-1				:0]	wv_wr_addr          	;	//wrap_wr_logic�����clk_frame_bufʱ����д��ַ
	wire		[BUF_DEPTH_WD-1			:0]	wv_rd_frame_ptr 		;	//wrap_wr_logic�����clk_frame_bufʱ���򣬶�ָ��
	wire		[BUF_DEPTH_WD-1			:0]	wv_frame_depth			;	//֡������ȣ�clkʱ���򣬿�����Ϊ 2-8����ֵ��������ȿ���ֹͣ�ɼ����ܸ���֡�����,����ͣ����Чʱ�����ơ�
	wire									w_wr_frame_ptr_changing	;//clk_frame_bufʱ����дָ�����ڱ仯�źţ��������ģ�飬��ʱ��ָ�벻�ܱ仯
	wire									w_se_2_fvalrise			;	//ͣ�ɵ���һ֡���ź������أ�Ϊ�˱���һ֮֡�ڵ���ͬ�������ź�չ��󴫸���ģ�飬clk_vinʱ���򣬵͵�ƽ��־ͣ��

//  ===============================================================================================
//  MCB����
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//  MCB (Memory Controller Block) DDR3������ģ��
//  -------------------------------------------------------------------------------------

	mig_core # (
	.C1_P0_MASK_SIZE						(8						),
	.C1_P0_DATA_PORT_SIZE					(64						),
	.C1_P1_MASK_SIZE						(8						),
	.C1_P1_DATA_PORT_SIZE					(64						),
	.DEBUG_EN								(0						),
	.C1_MEMCLK_PERIOD						(DDR3_MEMCLK_PERIOD		),
	.C1_CALIB_SOFT_IP						(DDR3_CALIB_SOFT_IP		),
	.C1_SIMULATION							(DDR3_SIMULATION		),
	.C1_RST_ACT_LOW							(DDR3_RST_ACT_LOW		),
	.C1_INPUT_CLK_TYPE						(DDR3_INPUT_CLK_TYPE	),
	.C1_MEM_ADDR_ORDER						(MEM_ADDR_ORDER			),
	.C1_NUM_DQ_PINS							(NUM_DQ_PINS			),
	.C1_MEM_ADDR_WIDTH						(MEM_ADDR_WIDTH			),
	.C1_MEM_BANKADDR_WIDTH					(MEM_BANKADDR_WIDTH		)
	)
	mig_core_inst (
	.mcb1_dram_dq							(mcb1_dram_dq			),
	.mcb1_dram_a							(mcb1_dram_a			),
	.mcb1_dram_ba							(mcb1_dram_ba			),
	.mcb1_dram_ras_n						(mcb1_dram_ras_n		),
	.mcb1_dram_cas_n						(mcb1_dram_cas_n		),
	.mcb1_dram_we_n							(mcb1_dram_we_n			),
	.mcb1_dram_odt							(mcb1_dram_odt			),
	.mcb1_dram_reset_n						(mcb1_dram_reset_n		),
	.mcb1_dram_cke							(mcb1_dram_cke			),
	.mcb1_dram_dm							(mcb1_dram_dm			),
	.mcb1_dram_udqs							(mcb1_dram_udqs			),
	.mcb1_dram_udqs_n						(mcb1_dram_udqs_n		),
	.mcb1_rzq								(mcb1_rzq				),
//	.mcb1_zio								(mcb1_zio				),
	.mcb1_dram_udm							(mcb1_dram_udm			),
	.mcb1_dram_dqs							(mcb1_dram_dqs			),
	.mcb1_dram_dqs_n						(mcb1_dram_dqs_n		),
	.mcb1_dram_ck							(mcb1_dram_ck			),
	.mcb1_dram_ck_n							(mcb1_dram_ck_n			),
	.c1_calib_done							(o_calib_done			),
    .c1_p0_cmd_clk							(clk_frame_buf			),
    .c1_p0_cmd_en							(w_p_in_cmd_en			),
	.c1_p0_cmd_instr						(wv_p_in_cmd_instr		),
	.c1_p0_cmd_bl							(wv_p_in_cmd_bl			),
	.c1_p0_cmd_byte_addr					(wv_p_in_cmd_byte_addr	),
	.c1_p0_cmd_empty						(w_p_in_cmd_empty		),
	.c1_p0_cmd_full							(w_p_in_cmd_full		),
    .c1_p0_wr_clk							(clk_frame_buf			),
    .c1_p0_wr_en							(w_p_in_wr_en			),
	.c1_p0_wr_mask							(wv_p_in_wr_mask		),
	.c1_p0_wr_data							(wv_p_in_wr_data		),
	.c1_p0_wr_full							(w_p_in_wr_full			),
	.c1_p0_wr_empty							(w_p_in_wr_empty		),
	.c1_p0_wr_count							(wv_p_in_wr_count		),
	.c1_p0_wr_underrun						(w_p_in_wr_underrun_nc	),
	.c1_p0_wr_error							(o_wr_error				),
    .c1_p0_rd_clk							(clk_frame_buf			),
    .c1_p0_rd_en							(1'b0					),
	.c1_p0_rd_data							(						),
	.c1_p0_rd_full							(						),
	.c1_p0_rd_empty							(						),
	.c1_p0_rd_count							(						),
	.c1_p0_rd_overflow						(						),
	.c1_p0_rd_error							(						),
	.c1_p1_cmd_clk							(clk_frame_buf			),
	.c1_p1_cmd_en							(w_p_out_cmd_en			),
	.c1_p1_cmd_instr						(wv_p_out_cmd_instr		),
	.c1_p1_cmd_bl							(wv_p_out_cmd_bl		),
	.c1_p1_cmd_byte_addr					(wv_p_out_cmd_byte_addr	),
	.c1_p1_cmd_empty						(w_p_out_cmd_empty		),
	.c1_p1_cmd_full							(w_p_out_cmd_full		),
	.c1_p1_wr_clk							(clk_frame_buf			),
	.c1_p1_wr_en							(1'b0					),
	.c1_p1_wr_mask							(8'h00					),
	.c1_p1_wr_data							(64'h0					),
	.c1_p1_wr_full							(						),
	.c1_p1_wr_empty							(						),
	.c1_p1_wr_count							(						),
	.c1_p1_wr_underrun						(						),
	.c1_p1_wr_error							(						),
	.c1_p1_rd_clk							(clk_frame_buf			),
	.c1_p1_rd_en							(w_p_out_rd_en			),
	.c1_p1_rd_data							(wv_p_out_rd_data		),
	.c1_p1_rd_full							(w_p_out_rd_full		),
	.c1_p1_rd_empty							(w_p_out_rd_empty		),
	.c1_p1_rd_count							(wv_p_out_rd_count		),
	.c1_p1_rd_overflow						(w_p_out_rd_overflow	),
	.c1_p1_rd_error     					(o_rd_error     		),
	.c1_async_rst							(i_async_rst			),
	.c1_sysclk_2x							(i_sysclk_2x			),
	.c1_sysclk_2x_180						(i_sysclk_2x_180		),
	.c1_pll_ce_0							(i_pll_ce_0				),
	.c1_pll_ce_90							(i_pll_ce_90			),
	.c1_pll_lock							(i_bufpll_mcb_lock		),
	.c1_mcb_drp_clk							(i_mcb_drp_clk			)
	);

//  ===============================================================================================
//  wrap_wr_logic����
//  ===============================================================================================
	wrap_wr_logic # (
	.DATA_WD								(DATA_WD				),
	.BUF_DEPTH_WD							(BUF_DEPTH_WD			),
	.ADDR_WD								(ADDR_WD   				),
	.BURST_SIZE								(BURST_SIZE				),
	.DDR3_P0_MASK_SIZE						(DDR3_P0_MASK_SIZE		),
	.BSIZE_WD								(BSIZE_WD				)
	)
	wrap_wr_logic_inst(
	.clk_vin								(clk_vin				),
	.i_fval									(i_fval					),
	.i_dval									(i_dval					),
	.i_trailer_flag							(i_trailer_flag			),
	.iv_image_din							(iv_image_din			),
	.i_stream_en_clk_in						(i_stream_en_clk_in		),
	.i_stream_en							(i_stream_en			),
	.iv_frame_depth							(iv_frame_depth			),
	.ov_frame_depth							(wv_frame_depth			),
	.clk									(clk_frame_buf			),
	.reset									(reset_frame_buf		),
	.ov_wr_frame_ptr						(wv_wr_frame_ptr		),
	.ov_wr_addr								(wv_wr_addr				),
	.iv_rd_frame_ptr						(wv_rd_frame_ptr		),
	.o_wr_frame_ptr_changing				(w_wr_frame_ptr_changing),
	.o_se_2_fvalrise						(w_se_2_fvalrise		),
	.i_calib_done							(o_calib_done			),
	.o_p_in_cmd_en							(w_p_in_cmd_en			),
	.ov_p_in_cmd_instr						(wv_p_in_cmd_instr		),
	.ov_p_in_cmd_bl							(wv_p_in_cmd_bl			),
	.ov_p_in_cmd_byte_addr					(wv_p_in_cmd_byte_addr	),
	.i_p_in_cmd_empty						(w_p_in_cmd_empty		),
	.o_p_in_wr_en							(w_p_in_wr_en			),
	.ov_p_in_wr_mask						(wv_p_in_wr_mask		),
	.ov_p_in_wr_data						(wv_p_in_wr_data		),
	.i_p_in_wr_full							(w_p_in_wr_full			)
	);
//  ===============================================================================================
//  wrap_rd_logic����
//  ===============================================================================================
	wrap_rd_logic # (
	.DATA_WD								(DATA_WD				),
	.GPIF_DAT_WIDTH							(GPIF_DAT_WIDTH			),
	.BUF_DEPTH_WD							(BUF_DEPTH_WD			),
	.REG_WD									(REG_WD					),
	.BURST_SIZE								(BURST_SIZE				),
	.FSIZE_WD								(FSIZE_WD				),//֡��С��ȶ���
	.BSIZE_WD								(BSIZE_WD				) //һ��BURST ������ռ��λ��
	)
	wrap_rd_logic_inst (
	.clk_vout								(clk_vout				),
	.i_buf_rd								(i_buf_rd				),
	.o_back_buf_empty						(o_back_buf_empty		),
	.o_frame_valid							(o_frame_valid			),
	.ov_frame_dout							(ov_frame_dout			),
	.i_se_2_fvalrise						(w_se_2_fvalrise		),
	.iv_frame_depth							(wv_frame_depth			),
	.iv_payload_size						(iv_payload_size_frame_buf),
	.i_chunkmodeactive						(i_chunkmodeactive		),
	.i_wr_frame_ptr_changing				(w_wr_frame_ptr_changing),
	.clk									(clk_frame_buf		    ),
	.reset									(reset_frame_buf		),
	.iv_wr_frame_ptr						(wv_wr_frame_ptr		),
	.iv_wr_addr								(wv_wr_addr				),
	.ov_rd_frame_ptr						(wv_rd_frame_ptr		),
	.i_calib_done							(o_calib_done			),
	.i_p_out_cmd_empty						(w_p_out_cmd_empty		),
	.o_p_out_cmd_en							(w_p_out_cmd_en			),
	.ov_p_out_cmd_instr						(wv_p_out_cmd_instr		),
	.ov_p_out_cmd_bl						(wv_p_out_cmd_bl		),
	.ov_p_out_cmd_byte_addr					(wv_p_out_cmd_byte_addr	),
	.iv_p_out_rd_data						(wv_p_out_rd_data		),
	.i_p_out_rd_empty						(w_p_out_rd_empty		),
	.o_p_out_rd_en							(w_p_out_rd_en			)
	);
endmodule