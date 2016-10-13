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
//	-- �Ϻ���		:| 2016/9/14 16:25:37	:|	��ROI�汾
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
	parameter	NUM_DQ_PINS					= 16					,	//DDR3���ݿ��
	parameter	MEM_BANKADDR_WIDTH			= 3						,	//DDR3bank���
	parameter	MEM_ADDR_WIDTH				= 13					,	//DDR3��ַ���
	parameter	DDR3_MEMCLK_FREQ			= 320					,	//DDR3ʱ��Ƶ��
	parameter	MEM_ADDR_ORDER				= "ROW_BANK_COLUMN"		,	//DDR3��ַ�Ų�˳��
	parameter	SKIP_IN_TERM_CAL			= 1						,	//��У׼������裬��ʡ����
	parameter	DDR3_MEM_DENSITY			= "1Gb"					,	//DDR3����
	parameter	DDR3_TCK_SPEED				= "15E"					,	//DDR3���ٶȵȼ�
	parameter	DDR3_SIMULATION				= "TRUE"				,	//�򿪷�����Լ��ٷ����ٶȣ�����ʵ�ʲ��ֲ���ʱ�����ܴ򿪷��档
	parameter	DDR3_CALIB_SOFT_IP			= "TRUE"				,	//����ʱ�����Բ�ʹ��У׼�߼�
	parameter	DATA_WD						= 64					,	//��������λ��MCB ��д FIFO λ��
	parameter	BACK_DATA_WD				= 32					,	//����������λ��
	parameter	SHORT_REG_WD   				= 16					,	//�̼Ĵ���λ��
	parameter	REG_WD   					= 32					,	//�Ĵ���λ��
	parameter	MROI_MAX_NUM 				= 8						,	//Multi-ROI��������
	parameter	SENSOR_MAX_WIDTH			= 4912					,	//Sensor��������Ч��ȣ�������ʱ��Ϊ��λ
	parameter	SENSOR_ALL_PIX_DIV4			= 1920					,	//Sensor��󴰿��£��������صĸ���/4
	parameter	PTR_WIDTH					= 2							//��дָ���λ��1-���2֡ 2-���4֡ 3-���8֡ 4-���16֡ 5-���32֡
	)
	(
	//  ===============================================================================================
	//  ͼ������ʱ����
	//  ===============================================================================================
	input									clk_in					,	//ͼ������ʱ��
	input									i_fval					,	//clk_inʱ���򣬳���Ч�ź�
	input									i_dval					,	//clk_inʱ����������Ч�ź�
	input									i_leader_flag			,	//clk_inʱ����ͷ����־
	input									i_image_flag			,	//clk_inʱ����ͼ���־
	input									i_chunk_flag			,	//clk_inʱ����chunk��־
	input									i_trailer_flag			,	//clk_inʱ����β����־
	input	[DATA_WD-1:0]					iv_din					,	//clk_inʱ������������
	output									o_buf_overflow			,	//clk_inʱ����֡��ǰ��FIFO��� 0:֡��ǰ��FIFOû����� 1:֡��ǰ��FIFO���ֹ����������
	//  ===============================================================================================
	//  ͼ�����ʱ����
	//  ===============================================================================================
	input									clk_out					,	//ͼ�����ʱ��
	input									i_buf_rd				,   //clk_outʱ���򣬺�ģ���ʹ��
	output									o_back_buf_empty		,	//clk_outʱ����֡����FIFO�ձ�־������ָʾ֡�����Ƿ������ݿɶ�
	output	[BACK_DATA_WD-1:0]				ov_dout					,   //clk_outʱ���򣬺�FIFO�������
	//  ===============================================================================================
	//  ֡���湤��ʱ��
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	ʱ�Ӹ�λ
	//	-------------------------------------------------------------------------------------
	input									clk_frame_buf			,	//֡��ʱ��
	input									reset_frame_buf			,	//֡��ʱ�ӵĸ�λ�ź�
	//	-------------------------------------------------------------------------------------
	//	��������
	//	-------------------------------------------------------------------------------------
	input									i_stream_enable			,	//��ʹ���źţ�SE=1�ȴ�����֡��SE=0����ֹͣ������ǰ������д��
	input	[SHORT_REG_WD-1:0]				iv_frame_depth			,   //֡�������
	input									i_chunk_mode_active		,	//chunk�ܿ��أ�chunk����Ӱ��leader��trailer�Ĵ�С��ͨ���ж�chunk���ؿ���֪��leader��trailer����
	//	-------------------------------------------------------------------------------------
	//	��ROI�Ĵ���
	//	-------------------------------------------------------------------------------------
	input									iv_multi_roi_global_en	,	//Multi-ROI ȫ��ʹ��
	input	[MROI_MAX_NUM*REG_WD-1:0]		iv_payload_size_mroi	,	//Multi-ROI payload size ����
	input	[MROI_MAX_NUM*REG_WD-1:0]		iv_image_size_mroi		,	//Multi-ROI image size ����
	input	[MROI_MAX_NUM*SHORT_REG_WD-1:0]	iv_roi_pic_width		,	//sensor���ͼ����ܿ��
	input	[MROI_MAX_NUM*SHORT_REG_WD-1:0]	iv_roi_pic_width_mroi	,	//Multi-ROI pic_width ����
	input	[MROI_MAX_NUM*REG_WD-1:0]		iv_start_mroi			,	//Multi-ROI ֡����ʵ��ַ ����
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
	output									o_calib_done			,	//DDR3У׼����źţ�����Ч��ʱ����δ֪
	output									o_wr_error				,	//MCBд�˿ڳ��ִ��󣬸���Ч��ʱ����δ֪
	output									o_rd_error				,	//MCB���˿ڳ��ִ��󣬸���Ч��ʱ����δ֪
	//  ===============================================================================================
	//  External Memory
	//  ===============================================================================================
	inout  	[NUM_DQ_PINS-1:0]				mcb1_dram_dq			,	//�����ź�
	output 	[MEM_ADDR_WIDTH-1:0]			mcb1_dram_a         	,	//��ַ�ź�
	output 	[MEM_BANKADDR_WIDTH-1:0]		mcb1_dram_ba        	,	//Bank��ַ�ź�
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


	//	ref signals

	//	===============================================================================================
	//	busrt��ز���
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	����burst�ĳ���
	//	��ѡ 64 32 16 8 4 2 1��������2��n�η��������64��
	//	-------------------------------------------------------------------------------------
	localparam	BURST_SIZE					= 32;
	//	-------------------------------------------------------------------------------------
	//	MCB fifo λ���byte����
	//	-------------------------------------------------------------------------------------
	localparam	MCB_BYTE_NUM				= DATA_WD/8;
	//	-------------------------------------------------------------------------------------
	//	MCB fifo λ���byte������Ӧ��λ��
	//	-------------------------------------------------------------------------------------
	localparam	MCB_BYTE_NUM_WIDTH			= log2(MCB_BYTE_NUM);
	//	-------------------------------------------------------------------------------------
	//	ÿ��burst������������byteΪ��λ
	//	-------------------------------------------------------------------------------------
	localparam	MCB_BURST_BYTE_NUM			= BURST_SIZE*MCB_BYTE_NUM;


	//	===============================================================================================
	//	��ַ��ز���
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	refer to ug388 v2.3 p63
	//	mcb ��ַ�ռ��Ų�����ͬ������DDR3����ͬ���λ��
	//	1. 512Mb - 26
	//	2. 1Gb   - 27
	//	3. 2Gb   - 28
	//	��������������1Gb�ķ�ʽ����λ����Ϊ����Ĭ����1Gb
	//	-------------------------------------------------------------------------------------
	localparam	BYTE_ADDR_WIDTH		= (DDR3_MEM_DENSITY=="512Mb") ? 26 : ((DDR3_MEM_DENSITY=="2Gb") ? 28 : 27);
	//	-------------------------------------------------------------------------------------
	//	MCB BYTE ADDR ��λΪ0�ĸ���
	//	-------------------------------------------------------------------------------------
	localparam	MCB_BURST_BYTE_NUM_WIDTH		= log2(MCB_BURST_BYTE_NUM);

	//	-------------------------------------------------------------------------------------
	//	��д������ wr_addr rd_addr �����λ��
	//	���ǵ���֡�������byte addrֻ�� wr_addr �������� wr_ptr �޹أ���� wr_addr �����λ��=ʵ����Ч��λ��
	//	-------------------------------------------------------------------------------------
	localparam	WR_ADDR_WIDTH				= BYTE_ADDR_WIDTH-MCB_BURST_BYTE_NUM_WIDTH;
	localparam	RD_ADDR_WIDTH				= BYTE_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH;

	//	===============================================================================================
	//	����flag�ĵ�ַ���䣬ÿ��flagռ�õ��������ĵ�λ�� һ�� max burst ��������
	//	1.֡���е����ݷֲ���ʽΪ����MAX_BURST_LENGTH=32��MROI_MAX_NUM=8Ϊ��˵��
	//	-------------------------------------------------------------------------------------
	//					addr			max_data		addr_size
	//	-------------------------------------------------------------------------------------
	//	leader			0				56*8=448		(448/256)+1=2
	//
	//	trailer			2				36*8=288		(288/256)+1=2
	//
	//	chunk			4				40*8=320		(320/256)+1=2
	//
	//	image			6				na				na
	//
	//	trailer_final	{n(1'b1),1'b0}	36				(36/256)+1=1
	//	-------------------------------------------------------------------------------------
	//
	//	2.֡���е����ݷֲ���ʽΪ����MAX_BURST_LENGTH=64��MROI_MAX_NUM=8Ϊ��˵��
	//	-------------------------------------------------------------------------------------
	//					addr			max_data		addr_size
	//	-------------------------------------------------------------------------------------
	//	leader			0				56*16=896		(896/256)+1=4
	//
	//	trailer			4				36*16=576		(576/256)+1=3
	//
	//	chunk			7				40*16=640		(640/256)+1=3
	//
	//	image			10				na				na
	//
	//	trailer_final	{n(1'b1),1'b0}	36				(36/256)+1=1
	//	-------------------------------------------------------------------------------------
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	leader�ĵ�ַ
	//	-------------------------------------------------------------------------------------
	localparam	LEADER_START_ADDR				= 0;
	localparam	EACH_LEADER_SIZE				= 52;

	localparam	EACH_LEADER_SIZE_CEIL			= cdiv(EACH_LEADER_SIZE,MCB_BYTE_NUM)*MCB_BYTE_NUM;
	localparam	LEADER_REMAINDER				= remain(EACH_LEADER_SIZE,MCB_BYTE_NUM);

	localparam	MAX_LEADER_DATA					= EACH_LEADER_SIZE_CEIL*MROI_MAX_NUM;
	localparam	MAX_LEADER_ADDR_SIZE			= cdiv(MAX_LEADER_DATA,MCB_BYTE_NUM);

	localparam	MAX_LEADER_DATA_WIDTH			= log2(MAX_LEADER_DATA+1)-MCB_BYTE_NUM_WIDTH;

	//	-------------------------------------------------------------------------------------
	//	trailer�ĵ�ַ
	//	-------------------------------------------------------------------------------------
	localparam	TRAILER_START_ADDR				= LEADER_START_ADDR + MAX_LEADER_ADDR_SIZE;
	localparam	EACH_TRAILER_SIZE				= 32;
	localparam	EACH_TRAILER_SIZE_CHUNK			= 36;

	localparam	EACH_TRAILER_SIZE_CEIL			= cdiv(EACH_TRAILER_SIZE,MCB_BYTE_NUM)*MCB_BYTE_NUM;
	localparam	EACH_TRAILER_SIZE_CHUNK_CEIL	= cdiv(EACH_TRAILER_SIZE_CHUNK,MCB_BYTE_NUM)*MCB_BYTE_NUM;

	localparam	TRAILER_REMAINDER				= remain(EACH_TRAILER_SIZE,MCB_BYTE_NUM);
	localparam	TRAILER_CHUNK_REMAINDER			= remain(EACH_TRAILER_SIZE_CHUNK,MCB_BYTE_NUM);

	localparam	MAX_TRAILER_DATA				= EACH_TRAILER_SIZE_CHUNK_CEIL*MROI_MAX_NUM;
	localparam	MAX_TRAILER_ADDR_SIZE			= cdiv(MAX_TRAILER_DATA,MCB_BYTE_NUM);

	localparam	MAX_TRAILER_DATA_WIDTH			= log2(MAX_TRAILER_DATA+1)-MCB_BYTE_NUM_WIDTH;

	//	-------------------------------------------------------------------------------------
	//	chunk�ĵ�ַ
	//	-------------------------------------------------------------------------------------
	localparam	CHUNK_START_ADDR				= TRAILER_START_ADDR + MAX_TRAILER_ADDR_SIZE;
	localparam	EACH_CHUNK_SIZE					= 40;
	localparam	CHUNK_REMAINDER					= 1'b0;
	localparam	MAX_CHUNK_DATA					= EACH_CHUNK_SIZE*MROI_MAX_NUM;
	localparam	MAX_CHUNK_ADDR_SIZE				= cdiv(MAX_CHUNK_DATA,MCB_BYTE_NUM);

	localparam	MAX_CHUNK_DATA_WIDTH			= log2(MAX_CHUNK_DATA+1)-MCB_BYTE_NUM_WIDTH;

	//	-------------------------------------------------------------------------------------
	//	image�ĵ�ַ
	//	-------------------------------------------------------------------------------------
	localparam	IMAGE_START_ADDR				= CHUNK_START_ADDR + MAX_CHUNK_ADDR_SIZE;

	//	-------------------------------------------------------------------------------------
	//	trailer_final�ĵ�ַ
	//	-------------------------------------------------------------------------------------
	localparam	MAX_TRAILER_FINAL_DATA			= EACH_TRAILER_SIZE_CHUNK_CEIL*1;
	localparam	MAX_TRAILER_FINAL_ADDR_SIZE		= cdiv(MAX_TRAILER_FINAL_DATA,MCB_BYTE_NUM);
	localparam	TRAILER_FINAL_START_ADDR		= {{(WR_ADDR_WIDTH-MAX_TRAILER_FINAL_ADDR_SIZE){1'b1}},{(MAX_TRAILER_FINAL_ADDR_SIZE){1'b0}}};

	//	===============================================================================================
	//	��������λ�����
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	����leader������֮�� / 8����λ��byte
	//  -------------------------------------------------------------------------------------
	localparam	MAX_LEADER_DATA_DIV8		= cdiv(MAX_LEADER_DATA,8);
	//  -------------------------------------------------------------------------------------
	//	image������ / 8����λ��byte
	//  -------------------------------------------------------------------------------------
	localparam	MAX_IMAGE_DATA_DIV8			= SENSOR_ALL_PIX_DIV4;
	//	-------------------------------------------------------------------------------------
	//	һ��flag�����������ȡ���� leader��image˭��
	//	-------------------------------------------------------------------------------------
	localparam	MAX_FLAG_DATA_DIV8			= (MAX_LEADER_DATA_DIV8>=MAX_IMAGE_DATA_DIV8) ? MAX_LEADER_DATA_DIV8 : MAX_IMAGE_DATA_DIV8;
	//	-------------------------------------------------------------------------------------
	//	flag �����ݼ�������λ��
	//	1.log2(MAX_FLAG_DATA_DIV8+1)+3 ��ʾ��10/12���ظ�ʽ�£�sensor����������������Ҫ��λ��
	//	2.-MCB_BYTE_NUM_WIDTH ����MCB������1��byteλ��λ����˻�Ҫ��ȥMCB��λ��
	//	-------------------------------------------------------------------------------------
	localparam	WORD_CNT_FLAG_WIDTH			= log2(cdiv(MAX_FLAG_DATA_DIV8,MCB_BURST_BYTE_NUM)*MCB_BURST_BYTE_NUM+1)+3-MCB_BYTE_NUM_WIDTH;
	//	-------------------------------------------------------------------------------------
	//	line �����ݼ�������λ��
	//	1.log2(SENSOR_MAX_WIDTH*2+1) ��ʾ��10/12���ظ�ʽ�£�sensorһ�е����������������Ҫ��λ��
	//	2.-MCB_BYTE_NUM_WIDTH ����MCB������1��byteλ��λ����˻�Ҫ��ȥMCB��λ��
	//	-------------------------------------------------------------------------------------
	localparam	WORD_CNT_LINE_WIDTH			= log2(cdiv(SENSOR_MAX_WIDTH*2,MCB_BURST_BYTE_NUM)*MCB_BURST_BYTE_NUM+1)-MCB_BYTE_NUM_WIDTH;
	//	-------------------------------------------------------------------------------------
	//	burst �����ݼ�������λ��
	//	1.�� n byte Ϊ��λ
	//	-------------------------------------------------------------------------------------
	localparam	WORD_CNT_WIDTH				= log2(BURST_SIZE);
	//	-------------------------------------------------------------------------------------
	//	chunk��С��λ��
	//	-------------------------------------------------------------------------------------
	localparam	CHUNK_SIZE_WIDTH			= log2(EACH_CHUNK_SIZE+1);

	//	===============================================================================================
	//	��������
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	mask size
	//	-------------------------------------------------------------------------------------
	localparam	DDR3_MASK_SIZE	= MCB_BYTE_NUM;
	//	-------------------------------------------------------------------------------------
	//	DDR3ʱ������
	//	-------------------------------------------------------------------------------------
	localparam	DDR3_MEMCLK_PERIOD	= 1000000/DDR3_MEMCLK_FREQ	;
	//	-------------------------------------------------------------------------------------
	//	��ģ���е�flag�ĸ�������4��
	//	�ֱ��� leader image chunk trailer
	//	-------------------------------------------------------------------------------------
	localparam	FLAG_NUM			= 4;




	//	ref functions
	//	-------------------------------------------------------------------------------------
	//	ȡ��������ȡ��
	//	-------------------------------------------------------------------------------------
	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction

	//	-------------------------------------------------------------------------------------
	//	������ȡ��
	//	-------------------------------------------------------------------------------------
	function integer cdiv;
		input integer	dividend;	//������
		input integer	divisior;	//����
		integer			division;	//��

		begin
			//�˴��ĳ�������ȡ��
			division	= dividend/divisior;
			//��� ��*����=������ ���������������򣬴���ʡ�Ե�С�����֣���Ҫ��1
			cdiv		= (division*divisior==dividend) ? division : division+1;
		end
	endfunction

	//	-------------------------------------------------------------------------------------
	//	�жϳ����Ƿ���������0��û������ 1��������
	//	-------------------------------------------------------------------------------------
	function [0:0] remain;
		input integer	dividend;	//������
		input integer	divisior;	//����
		integer			division;	//��
		begin
			//�˴��ĳ�������ȡ��
			division	= dividend/divisior;
			//��� ��*����=������ ���������������򣬴���ʡ�Ե�С�����֣����������
			remain		= (division*divisior==dividend) ? 1'b0 : 1'b1;
		end
	endfunction






	//	ref ARCHITECTURE

	wrap_wr_logic # (
	.DATA_WD						(DATA_WD						),
	.DDR3_MEM_DENSITY				(DDR3_MEM_DENSITY				),
	.DDR3_MASK_SIZE					(DDR3_MASK_SIZE					),
	.BURST_SIZE						(BURST_SIZE						),
	.PTR_WIDTH						(PTR_WIDTH						),
	.WR_ADDR_WIDTH					(WR_ADDR_WIDTH					),
	.WORD_CNT_WIDTH					(WORD_CNT_WIDTH					),
	.MCB_BURST_BYTE_NUM_WIDTH		(MCB_BURST_BYTE_NUM_WIDTH		),
	.SENSOR_MAX_WIDTH				(SENSOR_MAX_WIDTH				),
	.LEADER_START_ADDR				(LEADER_START_ADDR				),
	.TRAILER_START_ADDR				(TRAILER_START_ADDR				),
	.CHUNK_START_ADDR				(CHUNK_START_ADDR				),
	.IMAGE_START_ADDR				(IMAGE_START_ADDR				),
	.TRAILER_FINAL_START_ADDR		(TRAILER_FINAL_START_ADDR		),
	.REG_WD							(REG_WD							)
	)
	wrap_wr_logic_inst (
	.clk_in							(clk_in							),
	.i_fval							(i_fval							),
	.i_dval							(i_dval							),
	.i_leader_flag					(i_leader_flag					),
	.i_image_flag					(i_image_flag					),
	.i_chunk_flag					(i_chunk_flag					),
	.i_trailer_flag					(i_trailer_flag					),
	.iv_image_din					(iv_image_din					),
	.o_front_fifo_overflow			(o_front_fifo_overflow			),
	.clk							(clk_frame_buf					),
	.reset							(reset_frame_buf				),
	.ov_wr_ptr						(wv_wr_ptr						),
	.ov_wr_addr						(wv_wr_addr						),
	.o_wr_ptr_change				(w_wr_ptr_change				),
	.iv_rd_ptr						(wv_rd_ptr						),
	.i_reading						(w_reading						),
	.o_writing						(w_writing						),
	.i_stream_enable				(i_stream_enable				),
	.iv_frame_depth					(iv_frame_depth					),
	.ov_frame_depth					(wv_frame_depth					),
	.i_calib_done					(i_calib_done					),
	.o_wr_cmd_en					(w_wr_cmd_en					),
	.ov_wr_cmd_instr				(wv_wr_cmd_instr				),
	.ov_wr_cmd_bl					(wv_wr_cmd_bl					),
	.ov_wr_cmd_byte_addr			(wv_wr_cmd_byte_addr			),
	.i_wr_cmd_empty					(w_wr_cmd_empty					),
	.i_wr_cmd_full					(w_wr_cmd_full					),
	.o_wr_en						(w_wr_en						),
	.ov_wr_mask						(wv_wr_mask						),
	.ov_wr_data						(wv_wr_data						),
	.i_wr_full						(w_wr_full						)
	);










endmodule
