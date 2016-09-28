//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : wrap_rd_logic
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2013/6/14 13:40:52	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :	���߼�����
//              1)  : ���߼�ģ��ͺ�FIFO
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wrap_rd_logic # (
	parameter		DATA_WIDTH			= 32		,	//���ݿ��
	parameter		PTR_WIDTH			= 2			,	//��дָ���λ��1-���2֡ 2-���4֡ 3-���8֡ 4-���16֡ 5-���32֡
	parameter		RD_WR_WITH_PRE		= "FALSE"	,	//read write command end with precharge command
	parameter		DDR3_MEM_DENSITY	= "1Gb"		,	//DDR3 ���� "1Gb" "512Mb"
	parameter		FRAME_SIZE_WIDTH	= 25		,	//һ֡��Сλ����DDR3��1Gbitʱ�����������128Mbyte����mcb p3 ��λ����32ʱ��25λ���size���������㹻��
	parameter		TERRIBLE_TRAFFIC	= "TRUE"		//��д���������TRUE-ͬʱ��д��ͬ֡��ͬһ��ַ��FALSE-ͬʱ��дͬһ֡��ͬһ��ַ
	)
	(
	//  -------------------------------------------------------------------------------------
	//  ���ʱ����
	//  -------------------------------------------------------------------------------------
	input							clk_back				,	//��ʱ��
	input							i_buf_rd				,	//��ģ���ʹ�ܣ�����Ч
	output							o_buf_empty				,	//��FIFO�գ�����Ч
	output							o_buf_pe				,	//��FIFO��̿գ�����Ч
	output	[DATA_WIDTH:0]			ov_image_dout			,	//��FIFO������������33bit
	//  -------------------------------------------------------------------------------------
	//  ��������
	//  -------------------------------------------------------------------------------------
	input	[PTR_WIDTH-1:0]			iv_frame_depth			,	//֡������ȣ���ͬ��
	input	[FRAME_SIZE_WIDTH-1:0]	iv_frame_size			,	//֡�����С����ͬ��
	input							i_chunk_mode_active		,	//chunk����
	input							i_start_full_frame		,	//ʹ�ܿ��أ���֤һ֡��������
	input							i_start_quick			,	//ʹ�ܿ��أ�����ͣ
	//  -------------------------------------------------------------------------------------
	//  ֡���湤��ʱ����
	//  -------------------------------------------------------------------------------------
	input							clk						,	//֡��ʱ��
	input							reset					,	//֡�渴λ
	output	[PTR_WIDTH-1:0]			ov_rd_frame_ptr			,	//��ָ��
	output							o_rd_req				,	//�����󣬸���Ч
	input							i_rd_ack				,	//����������Ч
	output							o_reading				,	//���ڶ�������Ч
	input	[PTR_WIDTH-1:0]			iv_wr_frame_ptr			,	//дָ��
	input	[18:0]					iv_wr_addr				,	//д��ַ
	input							i_writing				,	//����д�ź�
	//  -------------------------------------------------------------------------------------
	//  MCB�˿�
	//  -------------------------------------------------------------------------------------
	input							i_calib_done			,	//MCBУ׼��ɣ�����Ч
	output							o_p3_cmd_en				,	//MCB CMD дʹ�ܣ�����Ч
	output	[2:0]					ov_p3_cmd_instr			,	//MCB CMD ָ��
	output	[5:0]					ov_p3_cmd_bl			,	//MCB CMD ͻ������
	output	[29:0]					ov_p3_cmd_byte_addr		,	//MCB CMD ��ʼ��ַ
	input							i_p3_cmd_empty			,	//MCB CMD �գ�����Ч
	input							i_p3_cmd_full			,	//MCB CMD ��������Ч
	output							o_p3_rd_en				,	//MCB RD FIFO дʹ�ܣ�����Ч
	input	[DATA_WIDTH-1:0]		iv_p3_rd_data			,	//MCB RD FIFO �������
	input							i_p3_rd_full			,	//MCB RD FIFO ��������Ч
	input							i_p3_rd_empty			,	//MCB RD FIFO �գ�����Ч
	input							i_p3_rd_overflow		,	//MCB RD FIFO ���������Ч
	input							i_p3_rd_error			,	//MCB RD FIFO ��������Ч
	input							i_p2_cmd_empty				//MCB CMD �գ�����Ч
	);

	//	ref signals
	wire							w_reset_back_buf	;
	wire	[DATA_WIDTH:0]			wv_back_buf_din		;
	wire							w_back_buf_pf		;
	wire							w_back_buf_full		;
	wire	[35:0]					wv_buf_dout			;
	wire							w_buf_empty			;
	wire							w_buf_dout32		;
	wire	[35:0]					wv_back_buf_din_comb;


	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	֡���ģ��
	//	-------------------------------------------------------------------------------------
	rd_logic # (
	.DATA_WIDTH				(DATA_WIDTH			),
	.PTR_WIDTH				(PTR_WIDTH			),
	.RD_WR_WITH_PRE			(RD_WR_WITH_PRE		),
	.DDR3_MEM_DENSITY		(DDR3_MEM_DENSITY	),
	.FRAME_SIZE_WIDTH		(FRAME_SIZE_WIDTH	),
	.TERRIBLE_TRAFFIC		(TERRIBLE_TRAFFIC	)
	)
	rd_logic_inst (
	.clk					(clk				),
	.reset					(reset				),
	.iv_frame_depth			(iv_frame_depth		),
	.iv_frame_size			(iv_frame_size		),
	.i_chunk_mode_active	(i_chunk_mode_active),
	.i_start_full_frame		(i_start_full_frame	),
	.i_start_quick			(i_start_quick		),
	.o_reset_back_buf		(w_reset_back_buf	),
	.ov_buf_din				(wv_back_buf_din	),
	.o_buf_wr_en			(back_buf_wr		),
	.i_buf_pf				(w_back_buf_pf		),
	.i_buf_full				(w_back_buf_full	),
	.i_buf_empty			(w_buf_empty		),
	.i_buf_dout32			(w_buf_dout32		),
	.ov_rd_frame_ptr		(ov_rd_frame_ptr	),
	.o_rd_req				(o_rd_req			),
	.i_rd_ack				(i_rd_ack			),
	.o_reading				(o_reading			),
	.iv_wr_frame_ptr		(iv_wr_frame_ptr	),
	.iv_wr_addr				(iv_wr_addr			),
	.i_writing				(i_writing			),
	.i_calib_done			(i_calib_done		),
	.o_p3_cmd_en			(o_p3_cmd_en		),
	.ov_p3_cmd_instr		(ov_p3_cmd_instr	),
	.ov_p3_cmd_bl			(ov_p3_cmd_bl		),
	.ov_p3_cmd_byte_addr	(ov_p3_cmd_byte_addr),
	.i_p3_cmd_empty			(i_p3_cmd_empty		),
	.i_p3_cmd_full			(i_p3_cmd_full		),
	.o_p3_rd_en				(o_p3_rd_en			),
	.iv_p3_rd_data			(iv_p3_rd_data		),
	.i_p3_rd_full			(i_p3_rd_full		),
	.i_p3_rd_empty			(i_p3_rd_empty		),
	.i_p3_rd_overflow		(i_p3_rd_overflow	),
	.i_p3_rd_error			(i_p3_rd_error		),
	.i_p2_cmd_empty			(i_p2_cmd_empty		)
	);

	//	-------------------------------------------------------------------------------------
	//	���FIFO
	//	-------------------------------------------------------------------------------------
	fifo_w36d256_pf180_pe6 back_buf_inst (
	.rst					(w_reset_back_buf		),
	.wr_clk					(clk					),
	.wr_en					(back_buf_wr			),
	.full					(w_back_buf_full		),
	.prog_full				(w_back_buf_pf			),
	.din					(wv_back_buf_din_comb	),
	.rd_clk					(clk_back				),
	.rd_en					(i_buf_rd				),
	.empty					(w_buf_empty			),
	.prog_empty				(o_buf_pe				),
	.dout					(wv_buf_dout			)
	);

	assign	ov_image_dout			= wv_buf_dout[DATA_WIDTH:0];
	assign	o_buf_empty				= w_buf_empty;
	assign	w_buf_dout32			= wv_buf_dout[DATA_WIDTH];
	assign	wv_back_buf_din_comb	= {3'b0,wv_back_buf_din};

endmodule