//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : pulse_filter
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/12/8 9:42:03	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1)  : ram�Ŀ����18bit�������3072�����֧�ֵ�����λ�������18bit���г�����3072.���λ��ֻ��8bit��������������ram����Ϊ8bit�Ĵ洢����
//
//              2)  : ��֡ͷ��2�к�֡β��2�в����˲���������ͷ��2�����غ���β��2�����ز����˲�����
//
//              3)  : ��4���л��棬�����ӳ�ʱ����2������
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module pulse_filter # (
	parameter	SENSOR_DAT_WIDTH	= 10	,	//sensor ���ݿ��
	parameter	SHORT_REG_WD		= 16		//�̼Ĵ���λ��
	)
	(
	//Sensor�����ź�
	input								clk					,	//����ʱ��
	input								i_fval				,	//���źţ�i_fval���±�����i_lval���10��ʱ������
	input								i_lval				,	//���ź�
	input	[SENSOR_DAT_WIDTH-1:0]		iv_pix_data			,	//ͼ������
	//�Ĵ�������
	input								i_pulse_filter_en	,	//����У������,0:��ʹ�ܻ���У��,1:ʹ�ܻ���У��
	input	[SHORT_REG_WD-1:0]			iv_roi_pic_width	,	//�п��
	//���
	output								o_fval				,	//����Ч��o_fval��o_lval����������2�е�ʱ�䣬�½�����10��ʱ�ӵļ��
	output								o_lval				,	//����Ч
	output	[SENSOR_DAT_WIDTH-1:0]		ov_pix_data				//ͼ������
	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	�̶�����
	//	-------------------------------------------------------------------------------------
	localparam	COMPARE_LVAL_DELAY	= 5		;	//�� compare ģ���lval����ʱ
	localparam	LINE_HIDE_PIX_NUM	= 30	;	//�������ɵ�2�У���������ֵ
	localparam	LINE2FRAME_PIX_NUM	= 10	;	//�������ɵ�2�У����һ�е��½�����o_fval���½��صľ���

	wire	[3:0]						wv_buffer_wr_en		;
	wire	[11:0]						wv_buffer_wr_addr	;
	wire	[9:0]						wv_buffer_wr_din	;
	wire	[SENSOR_DAT_WIDTH-1:0]		wv_lower_line		;
	wire								w_reset_buffer		;
	wire	[3:0]						wv_buffer_rd_en		;
	wire	[11:0]						wv_buffer_rd_addr	;
	wire	[9:0]						wv_buffer_rd_dout0	;
	wire	[9:0]						wv_buffer_rd_dout1	;
	wire	[9:0]						wv_buffer_rd_dout2	;
	wire	[9:0]						wv_buffer_rd_dout3	;
	wire	[SENSOR_DAT_WIDTH-1:0]		wv_upper_line	;
	wire	[SENSOR_DAT_WIDTH-1:0]		wv_mid_line		;
	wire								w_lval_delay	;
	wire								w_fval_delay	;


	//	ref ARCHITECTURE


	//  -------------------------------------------------------------------------------------
	//	bufferдģ��
	//  -------------------------------------------------------------------------------------
	pulser_filter_wr # (
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	)
	)
	pulser_filter_wr_inst (
	.clk				(clk				),
	.i_fval				(i_fval				),
	.i_lval				(i_lval				),
	.iv_pix_data		(iv_pix_data		),
	.ov_buffer_wr_en	(wv_buffer_wr_en	),
	.ov_buffer_wr_addr	(wv_buffer_wr_addr	),
	.ov_buffer_wr_din	(wv_buffer_wr_din	),
	.ov_lower_line		(wv_lower_line		)
	);

	//  -------------------------------------------------------------------------------------
	//	buffer��ģ��
	//  -------------------------------------------------------------------------------------
	pulse_filter_rd # (
	.COMPARE_LVAL_DELAY	(COMPARE_LVAL_DELAY	),
	.LINE_HIDE_PIX_NUM	(LINE_HIDE_PIX_NUM	),
	.LINE2FRAME_PIX_NUM	(LINE2FRAME_PIX_NUM	),
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	),
	.SHORT_REG_WD		(SHORT_REG_WD		)
	)
	pulse_filter_rd_inst (
	.clk				(clk				),
	.iv_roi_pic_width	(iv_roi_pic_width	),
	.i_fval				(i_fval				),
	.i_lval				(i_lval				),
	.o_reset_buffer		(w_reset_buffer	),
	.ov_buffer_rd_en	(wv_buffer_rd_en	),
	.ov_buffer_rd_addr	(wv_buffer_rd_addr	),
	.iv_buffer_rd_dout0	(wv_buffer_rd_dout0	),
	.iv_buffer_rd_dout1	(wv_buffer_rd_dout1	),
	.iv_buffer_rd_dout2	(wv_buffer_rd_dout2	),
	.iv_buffer_rd_dout3	(wv_buffer_rd_dout3	),
	.o_fval				(w_fval_delay		),
	.o_lval				(w_lval_delay		),
	.ov_upper_line		(wv_upper_line		),
	.ov_mid_line		(wv_mid_line		)
	);

	//  -------------------------------------------------------------------------------------
	//	bufferģ�飬����4���л��棬ÿ���л���Ŀ����18bit�������3072
	//	û�б�Ҫ��λ��ȥ���˸�λ�ź�
	//  -------------------------------------------------------------------------------------
	pulse_filter_buffer pulse_filter_buffer_inst (
	.clk				(clk				),
	.iv_buffer_wr_en	(wv_buffer_wr_en	),
	.iv_buffer_wr_addr	(wv_buffer_wr_addr	),
	.iv_buffer_wr_din	(wv_buffer_wr_din	),
//	.i_reset_buffer		(w_reset_buffer		),
	.i_reset_buffer		(1'b0				),
	.iv_buffer_rd_en	(wv_buffer_rd_en	),
	.iv_buffer_rd_addr	(wv_buffer_rd_addr	),
	.ov_buffer_rd_dout0	(wv_buffer_rd_dout0	),
	.ov_buffer_rd_dout1	(wv_buffer_rd_dout1	),
	.ov_buffer_rd_dout2	(wv_buffer_rd_dout2	),
	.ov_buffer_rd_dout3	(wv_buffer_rd_dout3	)
	);

	//  -------------------------------------------------------------------------------------
	//	�Ƚ�ģ�飬����˲�����
	//  -------------------------------------------------------------------------------------
	pulse_filter_compare # (
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	)
	)
	pulse_filter_compare_inst (
	.clk				(clk				),
	.i_pulse_filter_en	(i_pulse_filter_en	),
	.i_fval				(i_fval				),
	.i_fval_delay		(w_fval_delay		),
	.i_lval_delay		(w_lval_delay		),
	.iv_upper_line		(wv_upper_line		),
	.iv_mid_line		(wv_mid_line		),
	.iv_lower_line		(wv_lower_line		),
	.o_fval				(o_fval				),
	.o_lval				(o_lval				),
	.ov_pix_data		(ov_pix_data		)
	);



endmodule