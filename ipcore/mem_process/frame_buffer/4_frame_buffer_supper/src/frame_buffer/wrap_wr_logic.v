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
	//  -------------------------------------------------------------------------------------
	//  ��Ƶ����ʱ����
	//  -------------------------------------------------------------------------------------
	input						clk					,	//ǰ��ʱ��
	input						reset				,	//ǰ��ʱ�Ӹ�λ�ź�
	input						i_fval				,	//����Ч�ź�
	input						i_dval				,	//������Ч�ź�
	input	[DATA_WIDTH-1:0]	iv_image_din		,	//ͼ������
	input	[PTR_WIDTH-1:0]		iv_frame_depth		,	//֡�������
	input						i_start_full_frame	,	//ʹ�ܿ��أ���֤һ֡��������
	input						i_start_quick		,	//ʹ�ܿ��أ�����ͣ
	input	[SECTION_NUM-1:0]	iv_section_en		,	//һ֡��ÿ���ε�ʹ��λ
	//  -------------------------------------------------------------------------------------
	//  ֡���湤��ʱ����
	//  -------------------------------------------------------------------------------------
	output	[PTR_WIDTH-1:0]		ov_wr_frame_ptr		,	//дָ��
	output	[18:0]				ov_wr_addr			,	//д��ַ
	output						o_wr_req			,	//д���󣬸���Ч
	input						i_wr_ack			,	//д��������Ч
	output						o_writing			,	//����д������Ч
	input	[PTR_WIDTH-1:0]		iv_rd_frame_ptr		,	//��ָ��
	input						i_reading			,	//���ڶ�������Ч
	//  -------------------------------------------------------------------------------------
	//  MCB�˿�
	//  -------------------------------------------------------------------------------------
	input						i_calib_done		,	//MCBУ׼����źţ�����Ч

	output						o_p2_cmd_en			,	//MCB CMD FIFO д�źţ�����Ч
	output	[2:0]				ov_p2_cmd_instr		,	//MCB CMD FIFO ָ��
	output	[5:0]				ov_p2_cmd_bl		,	//MCB CMD FIFO ͻ������
	output	[29:0]				ov_p2_cmd_byte_addr	,	//MCB CMD FIFO ��ʼ��ַ
	input						i_p2_cmd_empty		,	//MCB CMD FIFO ���źţ�����Ч
	input						i_p2_cmd_full		,	//MCB CMD FIFO ���źţ�����Ч
	output						o_p2_wr_en			,	//MCB WR FIFO д�źţ�����Ч
	output	[3:0]				ov_p2_wr_mask		,	//MCB WR �����ź�
	output	[DATA_WIDTH-1:0]	ov_p2_wr_data		,	//MCB WR FIFO д����
	input						i_p2_wr_full		,	//MCB WR FIFO ���źţ�����Ч
	input						i_p2_wr_empty		, 	//MCB WR FIFO ���źţ�����Ч

	output						o_p4_cmd_en			,	//MCB CMD FIFO д�źţ�����Ч
	output	[2:0]				ov_p4_cmd_instr		,	//MCB CMD FIFO ָ��
	output	[5:0]				ov_p4_cmd_bl		,	//MCB CMD FIFO ͻ������
	output	[29:0]				ov_p4_cmd_byte_addr	,	//MCB CMD FIFO ��ʼ��ַ
	input						i_p4_cmd_empty		,	//MCB CMD FIFO ���źţ�����Ч
	input						i_p4_cmd_full		,	//MCB CMD FIFO ���źţ�����Ч
	output						o_p4_wr_en			,	//MCB WR FIFO д�źţ�����Ч
	output	[3:0]				ov_p4_wr_mask		,	//MCB WR �����ź�
	output	[DATA_WIDTH-1:0]	ov_p4_wr_data		,	//MCB WR FIFO д����
	input						i_p4_wr_full		,	//MCB WR FIFO ���źţ�����Ч
	input						i_p4_wr_empty		 	//MCB WR FIFO ���źţ�����Ч

	);

	//ref signals


	//ref ARCHITECTURE


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
	.clk					(clk					),
	.reset					(reset					),
	.iv_frame_depth			(iv_frame_depth			),
	.i_start_full_frame		(i_start_full_frame		),
	.i_start_quick			(i_start_quick			),
	.i_fval					(i_fval					),
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