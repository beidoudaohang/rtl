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
	parameter	NUM_DQ_PINS					= 16					,	//DDR3���ݿ���
	parameter	MEM_BANKADDR_WIDTH			= 3						,	//DDR3bank����
	parameter	MEM_ADDR_WIDTH				= 13					,	//DDR3��ַ����
	parameter	DDR3_MEMCLK_FREQ			= 320					,	//DDR3ʱ��Ƶ��
	parameter	MEM_ADDR_ORDER				= "ROW_BANK_COLUMN"		,	//DDR3��ַ�Ų�˳��
	parameter	SKIP_IN_TERM_CAL			= 1						,	//��У׼������裬��ʡ����
	parameter	DDR3_MEM_DENSITY			= "1Gb"					,	//DDR3����
	parameter	DDR3_TCK_SPEED				= "15E"					,	//DDR3���ٶȵȼ�
	parameter	DDR3_SIMULATION				= "TRUE"				,	//�򿪷�����Լ��ٷ����ٶȣ�����ʵ�ʲ��ֲ���ʱ�����ܴ򿪷��档
	parameter	DDR3_CALIB_SOFT_IP			= "TRUE"				,	//����ʱ�����Բ�ʹ��У׼�߼�
	parameter	DATA_WD						= 64					,	//��������λ����MCB ��д FIFO λ��
	parameter	BACK_DATA_WD				= 32					,	//����������λ��
	parameter	SHORT_REG_WD   				= 16					,	//�̼Ĵ���λ��
	parameter	REG_WD   					= 32					,	//�Ĵ���λ��
	parameter	MROI_MAX_NUM 				= 8						,	//Multi-ROI��������
	parameter	SENSOR_ALL_PIX_DIV4			= 1920					,	//Sensor��󴰿��£��������صĸ���/4
	parameter	PTR_WIDTH					= 2							//��дָ���λ����1-���2֡ 2-���4֡ 3-���8֡ 4-���16֡ 5-���32֡
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
	input									i_stream_en_clk_in		,	//clk_inʱ������ֹͣ�źţ��ź���Чʱ������������֡д��֡�棬��Чʱ����ֹͣд�룬����λ��д��ַָ�룬��֡��
	output									o_fifo_full				,	//clk_inʱ����ǰ��FIFO��
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
	input									i_stream_en				,	//��ʹ���źţ�SE=1�ȴ�����֡��SE=0����ֹͣ������ǰ������д��
	input	[SHORT_REG_WD-1:0]				iv_frame_depth			,   //֡�������
	input									i_chunk_mode_active		,	//chunk�ܿ��أ�chunk����Ӱ��leader��trailer�Ĵ�С��ͨ���ж�chunk���ؿ���֪��leader��trailer����
	//	-------------------------------------------------------------------------------------
	//	��ROI�Ĵ���
	//	-------------------------------------------------------------------------------------
	input									iv_multi_roi_global_en	,	//Multi-ROI ȫ��ʹ��
	input	[MROI_MAX_NUM*REG_WD-1:0]		iv_payload_size_mroi	,	//Multi-ROI payload size ����
	input	[MROI_MAX_NUM*REG_WD-1:0]		iv_image_size_mroi		,	//Multi-ROI image size ����
	input	[MROI_MAX_NUM*SHORT_REG_WD-1:0]	iv_roi_pic_width		,	//sensor���ͼ����ܿ���
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

	//  -------------------------------------------------------------------------------------
	//	��������
	//  -------------------------------------------------------------------------------------
//	localparam	MAX_IMAGE_DATA_DIV8			= SENSOR_ALL_PIX_DIV4;
//	localparam	ALL_DATA_DIV8				= MAX_IMAGE_DATA_DIV8+(MAX_LEADER_ADDR_SIZE+MAX_TRAILER_ADDR_SIZE+MAX_CHUNK_ADDR_SIZE+MAX_TRAILER_FINAL_ADDR_SIZE)*BURST_BYTE/8;
//	localparam	MEM_MAX_DATA_DIV8			= 2**(BYTE_ADDR_WD-3);
//	localparam	MAX_FRAME_NUM				= MEM_MAX_DATA_DIV8/ALL_DATA_DIV8;



	//	===============================================================================================
	//	busrt��ز���
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	����burst�ĳ���
	//	��ѡ 64 32 16 8 4 2 1��������2��n�η��������64��
	//	-------------------------------------------------------------------------------------
	localparam	MAX_BURST_LENGTH	= 32;
	//	-------------------------------------------------------------------------------------
	//	ÿ��burst��������
	//	-------------------------------------------------------------------------------------
	localparam	MAX_BURST_BYTE		= MAX_BURST_LENGTH*DATA_WD/8;

	//	===============================================================================================
	//	��ַ��ز���
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	refer to ug388 v2.3 p63
	//	mcb ��ַ�ռ��Ų�����ͬ������DDR3����ͬ���λ��
	//	1. 512Mb - 26
	//	2. 1Gb   - 27
	//	3. 2Gb   - 28
	//	��������������1Gb�ķ�ʽ����λ������Ϊ����Ĭ����1Gb
	//	-------------------------------------------------------------------------------------
	localparam	BYTE_ADDR_WD	= (DDR3_MEM_DENSITY=="512Mb") ? 26 : ((DDR3_MEM_DENSITY=="2Gb") ? 28 : 27);
	//	-------------------------------------------------------------------------------------
	//	MCB BYTE ADDR ��λΪ0�ĸ���
	//	-------------------------------------------------------------------------------------
	localparam	ADDR_DUMMY_BIT		= log2(MAX_BURST_BYTE);
	//	-------------------------------------------------------------------------------------
	//	��д������ wr_addr rd_addr �����λ��
	//	���ǵ���֡�������byte addrֻ�� wr_addr �������� wr_ptr �޹أ���� wr_addr �����λ��=ʵ����Ч��λ��
	//	-------------------------------------------------------------------------------------
	localparam	ADDR_WD			= BYTE_ADDR_WD-ADDR_DUMMY_BIT;

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
	//	2.֡���е����ݷֲ���ʽΪ����MAX_BURST_LENGTH=32��MROI_MAX_NUM=8Ϊ��˵��
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
	localparam	MAX_LEADER_SIZE					= 56;
	localparam	MAX_LEADER_DATA					= MAX_LEADER_SIZE*MROI_MAX_NUM;
	localparam	MAX_LEADER_ADDR_SIZE			= (MAX_LEADER_DATA/BURST_BYTE)+1;
	//	-------------------------------------------------------------------------------------
	//	trailer�ĵ�ַ
	//	-------------------------------------------------------------------------------------
	localparam	TRAILER_START_ADDR				= LEADER_START_ADDR + MAX_LEADER_ADDR_SIZE;
	localparam	MAX_TRAILER_SIZE				= 36;
	localparam	MAX_TRAILER_DATA				= MAX_TRAILER_SIZE*MROI_MAX_NUM;
	localparam	MAX_TRAILER_ADDR_SIZE			= (MAX_TRAILER_DATA/BURST_BYTE)+1;
	//	-------------------------------------------------------------------------------------
	//	image�ĵ�ַ
	//	-------------------------------------------------------------------------------------
	localparam	CHUNK_START_ADDR				= TRAILER_START_ADDR + MAX_TRAILER_ADDR_SIZE;
	localparam	MAX_CHUNK_SIZE					= 40;
	localparam	MAX_CHUNK_DATA					= MAX_CHUNK_SIZE*MROI_MAX_NUM;
	localparam	MAX_CHUNK_ADDR_SIZE				= (MAX_CHUNK_DATA/BURST_BYTE)+1;
	//	-------------------------------------------------------------------------------------
	//	chunk�ĵ�ַ
	//	-------------------------------------------------------------------------------------
	localparam	IMAGE_START_ADDR				= CHUNK_START_ADDR + MAX_CHUNK_ADDR_SIZE;
	//	-------------------------------------------------------------------------------------
	//	trailer_final�ĵ�ַ
	//	-------------------------------------------------------------------------------------
	localparam	MAX_TRAILER_FINAL_SIZE			= 36;
	localparam	MAX_TRAILER_FINAL_DATA			= MAX_TRAILER_FINAL_SIZE*1;
	localparam	MAX_TRAILER_FINAL_ADDR_SIZE		= (MAX_TRAILER_FINAL_DATA/BURST_BYTE)+1;
	localparam	TRAILER_FINAL_START_ADDR		= {(ADDR_WD-MAX_TRAILER_FINAL_ADDR_SIZE){1'b1},(MAX_TRAILER_FINAL_ADDR_SIZE){1'b0}};

	//	===============================================================================================
	//	��������
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	mask size
	//	-------------------------------------------------------------------------------------
	localparam	DDR3_MASK_SIZE	= DATA_WD/8;
	//	-------------------------------------------------------------------------------------
	//	DDR3ʱ������
	//	-------------------------------------------------------------------------------------
	localparam	DDR3_MEMCLK_PERIOD	= 1000000/DDR3_MEMCLK_FREQ	;
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


endmodule