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
//`include			"frame_buffer_def.v"
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wrap_wr_logic # (
	parameter		RD_WR_WITH_PRE		= "FALSE"	,//read write command end with precharge command
	parameter		DDR3_MEM_DENSITY	= "1Gb"		//DDR3 ���� "1Gb" "512Mb"
	)
	(
	//  -------------------------------------------------------------------------------------
	//  ��Ƶ����ʱ����
	//  -------------------------------------------------------------------------------------
	input						clk_vin,
	input						i_fval,					//����Ч�źţ�����Ч
	input						i_dval,					//������Ч�źţ�����Ч
	input	[31:0]				iv_image_din,			//ͼ������
	output						o_front_fifo_full,
	//  -------------------------------------------------------------------------------------
	//  ��������
	//  -------------------------------------------------------------------------------------
	input						i_frame_en,				//ʹ�ܿ���
	input	[2:0]				iv_frame_depth,			//֡������� ������Ϊ 1 2 4
	//  -------------------------------------------------------------------------------------
	//  ֡���湤��ʱ����
	//  -------------------------------------------------------------------------------------
	input						clk,
	input						reset,
	output	[1:0]				ov_wr_frame_ptr,		//дָ��
	output	[16:0]				ov_wr_addr,				//д��ַ
	output						o_wr_req,				//д���󣬸���Ч
	input						i_wr_ack,				//д��������Ч
	output						o_writing,				//����д������Ч
	input	[1:0]				iv_rd_frame_ptr,		//��ָ��
	input						i_reading,				//���ڶ�������Ч

	//  -------------------------------------------------------------------------------------
	//  MCB�˿�
	//  -------------------------------------------------------------------------------------
	input						i_calib_done,			//MCBУ׼����źţ�����Ч
	output						o_p2_cmd_en,			//MCB CMD FIFO д�źţ�����Ч
	output	[2:0]				ov_p2_cmd_instr,        //MCB CMD FIFO ָ��
	output	[5:0]				ov_p2_cmd_bl,           //MCB CMD FIFO ͻ������
	output	[29:0]				ov_p2_cmd_byte_addr,    //MCB CMD FIFO ��ʼ��ַ
	input						i_p2_cmd_empty,         //MCB CMD FIFO ���źţ�����Ч
	input						i_p2_cmd_full,          //MCB CMD FIFO ���źţ�����Ч
	output						o_p2_wr_en,				//MCB WR FIFO д�źţ�����Ч
	output	[3:0]				ov_p2_wr_mask,          //MCB WR �����ź�
	output	[31:0]				ov_p2_wr_data,          //MCB WR FIFO д����
	input						i_p2_wr_full,           //MCB WR FIFO ���źţ�����Ч
	input						i_p2_wr_empty           //MCB WR FIFO ���źţ�����Ч
	);

	//ref signals

	wire						w_front_buf_rst;
	wire						w_front_buf_full;
	wire						w_front_buf_pf_nc;
	wire						w_front_buf_rd;
	wire						w_front_buf_empty;
	wire						w_front_buf_pe;
	wire	[35:0]				wv_front_buf_dout;
	wire	[35:0]				wv_front_buf_din;



	//ref ARCHITECTURE


	fifo_con fifo_con_inst (
	.clk					(clk_vin			),
	.i_fval					(i_fval				),
	.o_rst_buf				(w_front_buf_rst	)
	);

	fifo_w36d256_pf180_pe6 front_buf_inst (
	.rst					(w_front_buf_rst	),
	.wr_clk					(clk_vin			),
	.wr_en					(i_dval				),
	.full					(w_front_buf_full	),
	.prog_full				(w_front_buf_pf_nc	),
	.din					(wv_front_buf_din	),
	.rd_clk					(clk				),
	.rd_en					(w_front_buf_rd		),
	.empty					(w_front_buf_empty	),
	.prog_empty				(w_front_buf_pe		),
	.dout					(wv_front_buf_dout	)
	);

	wr_logic # (
	.RD_WR_WITH_PRE			(RD_WR_WITH_PRE		),
	.DDR3_MEM_DENSITY		(DDR3_MEM_DENSITY	)
	)
	wr_logic_inst (
	.clk					(clk					),
	.reset					(reset					),
	.iv_frame_depth			(iv_frame_depth			),
	.i_frame_en				(i_frame_en				),
	.i_fval					(i_fval					),
	.iv_buf_dout			(wv_front_buf_dout[31:0]),
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


	assign	wv_front_buf_din	= {4'b0,iv_image_din};
	assign	o_front_fifo_full	= w_front_buf_full;



endmodule
