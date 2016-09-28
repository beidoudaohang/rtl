//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : wrap_wr_logic
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2013/5/30 9:31:41	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :	д�߼�����
//              1)  : ����ǰ��FIFO��FIFO��λ����ģ�飬д�߼�ģ��
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wrap_wr_logic # (
	parameter		DATA_WIDTH			= 32		,	//���ݿ��
	parameter		PTR_WIDTH			= 2			,	//��дָ���λ��1-���2֡ 2-���4֡ 3-���8֡ 4-���16֡ 5-���32֡
	parameter		RD_WR_WITH_PRE		= "FALSE"	,	//read write command end with precharge command
	parameter		DDR3_MEM_DENSITY	= "1Gb"		,	//DDR3 ���� "1Gb" "512Mb"
	parameter		TERRIBLE_TRAFFIC	= "TRUE"		//��д���������TRUE-ͬʱ��д��ͬ֡��ͬһ��ַ��FALSE-ͬʱ��дͬһ֡��ͬһ��ַ
	)
	(
	//	===============================================================================================
	//	��Ƶ����ʱ����
	//	===============================================================================================
	input											clk_front			,	//ǰ��ʱ��
	input											i_fval				,	//����Ч�ź�
	input											i_sval				,	//������Ч�źţ�section_valid
	input											i_dval				,	//������Ч�ź�
	input	[DATA_WIDTH-1:0]						iv_image_din		,	//ͼ������
	output											o_front_fifo_full	,	//ǰ��fifo��
	//	===============================================================================================
	//	֡������ʱ����
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	ʱ��
	//	-------------------------------------------------------------------------------------
	input											clk					,	//֡��ʱ��
	input											reset				,	//֡�渴λ
	//	-------------------------------------------------------------------------------------
	//	ÿһ�ε���ʼ��ַ
	//	-------------------------------------------------------------------------------------
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec0	,	//�̶�����0�ε���ʼ��ַ
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec1	,	//�̶�����1�ε���ʼ��ַ
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec2	,	//�̶�����2�ε���ʼ��ַ
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec3	,	//�̶�����3�ε���ʼ��ַ
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec4	,	//�̶�����4�ε���ʼ��ַ
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec5	,	//�̶�����5�ε���ʼ��ַ
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec6	,	//�̶�����6�ε���ʼ��ַ
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec7	,	//�̶�����7�ε���ʼ��ַ
	//	-------------------------------------------------------------------------------------
	//	ÿһ�εĴ�С
	//	-------------------------------------------------------------------------------------
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec0		,	//0�εĴ�С
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec1		,	//1�εĴ�С
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec2		,	//2�εĴ�С
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec3		,	//3�εĴ�С
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec4		,	//4�εĴ�С
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec5		,	//5�εĴ�С
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec6		,	//6�εĴ�С
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec7		,	//7�εĴ�С
	//  -------------------------------------------------------------------------------------
	//  ��������
	//  -------------------------------------------------------------------------------------
	input	[PTR_WIDTH-1:0]							iv_frame_depth		,	//֡������� ������Ϊ 0 - 31����Ϊ0��ʾ1֡����Ϊ1ʱ��ʾ2֡
	input											i_start_full_frame	,	//ʹ�ܿ��أ���֤һ֡��������
	input											i_start_quick		,	//ʹ�ܿ��أ�����ͣ
	//  -------------------------------------------------------------------------------------
	//	��������
	//  -------------------------------------------------------------------------------------
	output	[PTR_WIDTH-1:0]							ov_wr_frame_ptr		,	//дָ��
	output	[18:0]									ov_wr_addr			,	//д��ַ
	output											o_wr_req			,	//д���󣬸���Ч
	input											i_wr_ack			,	//д��������Ч
	output											o_writing			,	//����д������Ч
	input	[PTR_WIDTH-1:0]							iv_rd_frame_ptr		,	//��ָ��
	input											i_reading			,	//���ڶ�������Ч
	//	===============================================================================================
	//	MCB�˿�
	//	===============================================================================================
	input											i_calib_done		,	//MCBУ׼����źţ�����Ч
	output											o_p2_cmd_en			,	//MCB CMD FIFO д�źţ�����Ч
	output	[2:0]									ov_p2_cmd_instr		,	//MCB CMD FIFO ָ��
	output	[5:0]									ov_p2_cmd_bl		,	//MCB CMD FIFO ͻ������
	output	[29:0]									ov_p2_cmd_byte_addr	,	//MCB CMD FIFO ��ʼ��ַ
	input											i_p2_cmd_empty		,	//MCB CMD FIFO ���źţ�����Ч
	input											i_p2_cmd_full		,	//MCB CMD FIFO ���źţ�����Ч
	output											o_p2_wr_en			,	//MCB WR FIFO д�źţ�����Ч
	output	[3:0]									ov_p2_wr_mask		,	//MCB WR �����ź�
	output	[DATA_WIDTH-1:0]						ov_p2_wr_data		,	//MCB WR FIFO д����
	input											i_p2_wr_full		,	//MCB WR FIFO ���źţ�����Ч
	input											i_p2_wr_empty		 	//MCB WR FIFO ���źţ�����Ч
	);

	//ref signals
	wire						w_reset_front_buf;
	wire						w_front_buf_pf_nc;
	wire						w_front_buf_rd;
	wire						w_front_buf_empty;
	wire						w_front_buf_pe;
	wire	[35:0]				wv_front_buf_dout;
	wire	[35:0]				wv_front_buf_din;

	//ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	ǰ��fifo����ģ��
	//	-------------------------------------------------------------------------------------
	fifo_ctrl fifo_ctrl_inst (
	.clk					(clk_front			),
	.i_fval					(i_fval				),
	.i_sval					(i_sval				),
	.iv_image_din			(iv_image_din		),
	.ov_front_buf_din		(wv_front_buf_din	),
	.o_reset_front_buf		(w_reset_front_buf	)
	);

	//	-------------------------------------------------------------------------------------
	//	ǰ��fifo
	//	-------------------------------------------------------------------------------------
	fifo_w36d256_pf180_pe6 front_buf_inst (
	.rst					(w_reset_front_buf	),
	.wr_clk					(clk_front			),
	.wr_en					(i_dval				),
	.full					(o_front_fifo_full	),
	.prog_full				(w_front_buf_pf_nc	),
	.din					(wv_front_buf_din	),
	.rd_clk					(clk				),
	.rd_en					(w_front_buf_rd		),
	.empty					(w_front_buf_empty	),
	.prog_empty				(w_front_buf_pe		),
	.dout					(wv_front_buf_dout	)
	);

	//	-------------------------------------------------------------------------------------
	//	֡��д�߼�
	//	-------------------------------------------------------------------------------------
	wr_logic # (
	.DATA_WIDTH				(DATA_WIDTH			),
	.PTR_WIDTH				(PTR_WIDTH			),
	.RD_WR_WITH_PRE			(RD_WR_WITH_PRE		),
	.DDR3_MEM_DENSITY		(DDR3_MEM_DENSITY	),
	.TERRIBLE_TRAFFIC		(TERRIBLE_TRAFFIC	)
	)
	wr_logic_inst (
	.i_fval					(i_fval					),
	.clk					(clk					),
	.reset					(reset					),
	.iv_frame_depth			(iv_frame_depth			),
	.i_start_full_frame		(i_start_full_frame		),
	.i_start_quick			(i_start_quick			),
	.iv_buf_dout			(wv_front_buf_dout[DATA_WIDTH-1:0]	),
	.o_buf_rd_en			(w_front_buf_rd			),
	.i_buf_pe				(w_front_buf_pe			),
	.i_buf_empty			(w_front_buf_empty		),
	.ov_wr_frame_ptr		(ov_wr_frame_ptr		),
	.ov_wr_addr				(ov_wr_addr				),
	.o_wr_req				(o_wr_req				),
	.i_wr_ack				(i_wr_ack				),
	.o_writing				(o_writing				),
	.iv_rd_frame_ptr		(iv_rd_frame_ptr		),
	.i_reading				(i_reading				),
	.i_calib_done			(i_calib_done			),
	.o_p2_cmd_en			(o_p2_cmd_en			),
	.ov_p2_cmd_instr		(ov_p2_cmd_instr		),
	.ov_p2_cmd_bl			(ov_p2_cmd_bl			),
	.ov_p2_cmd_byte_addr	(ov_p2_cmd_byte_addr	),
	.i_p2_cmd_empty			(i_p2_cmd_empty			),
	.i_p2_cmd_full			(i_p2_cmd_full			),
	.o_p2_wr_en				(o_p2_wr_en				),
	.ov_p2_wr_mask			(ov_p2_wr_mask			),
	.ov_p2_wr_data			(ov_p2_wr_data			),
	.i_p2_wr_full			(i_p2_wr_full			),
	.i_p2_wr_empty			(i_p2_wr_empty			)
	);





endmodule