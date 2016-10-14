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
	parameter	GPIF_DATA_WD				= 32					,	//����������λ��
	parameter	SHORT_REG_WD   				= 16					,	//�̼Ĵ���λ��
	parameter	REG_WD   					= 32					,	//�Ĵ���λ��
	parameter	MROI_MAX_NUM 				= 8						,	//Multi-ROI��������
	parameter	SENSOR_MAX_WIDTH			= 4912					,	//Sensor��������Ч��ȣ�������ʱ��Ϊ��λ
	parameter	SENSOR_ALL_PIX_DIV4			= 4523952				,	//Sensor��󴰿��£��������صĸ���/4 Ĭ��ֵΪ4912*3684/4
	parameter	PTR_WIDTH					= 2							//��дָ���λ��1-���1֡ 2-���3֡ 3-���7֡ 4-���15֡ 5-���31֡ ... 16-���65535֡
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
	output									o_front_fifo_overflow	,	//clk_inʱ����֡��ǰ��FIFO��� 0:֡��ǰ��FIFOû����� 1:֡��ǰ��FIFO���ֹ����������
	//  ===============================================================================================
	//  ͼ�����ʱ����
	//  ===============================================================================================
	input									clk_out					,	//ͼ�����ʱ��
	input									i_buf_rd				,   //clk_outʱ���򣬺�ģ���ʹ��
	output									o_back_buf_empty		,	//clk_outʱ����֡����FIFO�ձ�־������ָʾ֡�����Ƿ������ݿɶ�
	output	[GPIF_DATA_WD-1:0]				ov_dout					,   //clk_outʱ���򣬺�FIFO�������
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
	input	[REG_WD-1:0]					iv_pixel_format			,	//���ظ�ʽ�Ĵ���
	input	[SHORT_REG_WD-1:0]				iv_frame_depth			,   //֡�������
	input									i_chunk_mode_active		,	//chunk�ܿ��أ�chunk����Ӱ��leader��trailer�Ĵ�С��ͨ���ж�chunk���ؿ���֪��leader��trailer����
	//	-------------------------------------------------------------------------------------
	//	��ROI�Ĵ���
	//	-------------------------------------------------------------------------------------
	input									i_multi_roi_global_en	,	//Multi-ROI ȫ��ʹ��
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


	//	ref parameters


	//	===============================================================================================
	//	�̶�����
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	DDR3ʱ������
	//	-------------------------------------------------------------------------------------
	localparam	DDR3_MEMCLK_PERIOD	= 1000000/DDR3_MEMCLK_FREQ	;
	//	-------------------------------------------------------------------------------------
	//	��ģ���е�flag�ĸ�������4��
	//	�ֱ��� leader image chunk trailer
	//	-------------------------------------------------------------------------------------
	localparam	RD_FLAG_NUM			= 4;
	//	-------------------------------------------------------------------------------------
	//	дģ���е�flag�ĸ�������5��
	//	�ֱ��� leader trailer chunk image trailer_final
	//	-------------------------------------------------------------------------------------
	localparam	WR_FLAG_NUM			= 5;


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
	//	-------------------------------------------------------------------------------------
	//	ÿ��burst��������Ӧ��λ��
	//	-------------------------------------------------------------------------------------
	localparam	MCB_BURST_BYTE_NUM_WIDTH	= log2(MCB_BURST_BYTE_NUM);
	//	-------------------------------------------------------------------------------------
	//	mask size
	//	-------------------------------------------------------------------------------------
	localparam	DDR3_MASK_SIZE				= MCB_BYTE_NUM;

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

	//	===============================================================================================
	//	leader ���
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	leader��ʼ��ַ��Ĭ����0
	//	-------------------------------------------------------------------------------------
	localparam	LEADER_START_ADDR				= 0;
	//	-------------------------------------------------------------------------------------
	//	ÿ��leader�Ĵ�С�̶�Ϊ52byte
	//	-------------------------------------------------------------------------------------
	localparam	EACH_LEADER_SIZE				= 52;
	//	-------------------------------------------------------------------------------------
	//	ÿ��leader�Ĵ�С�� MCB_BYTE_NUM(8byte) ȡ������Ϊ56byte
	//	-------------------------------------------------------------------------------------
	localparam	EACH_LEADER_SIZE_CEIL			= cdiv(EACH_LEADER_SIZE,MCB_BYTE_NUM)*MCB_BYTE_NUM;
	//	-------------------------------------------------------------------------------------
	//	ÿ��leader��С�Ƿ���������52��������8�����������
	//	-------------------------------------------------------------------------------------
	localparam	LEADER_REMAINDER				= remain(EACH_LEADER_SIZE,MCB_BYTE_NUM);
	//	-------------------------------------------------------------------------------------
	//	���е�leader������������byteΪ��λ
	//	-------------------------------------------------------------------------------------
	localparam	ALL_LEADER_DATA					= EACH_LEADER_SIZE_CEIL*MROI_MAX_NUM;
	//	-------------------------------------------------------------------------------------
	//	���е�leaderռ�õĵ�ַ�ռ䣬���� burst byte num(256 byte) ���룬��byteΪ��λ
	//	-------------------------------------------------------------------------------------
	localparam	ALL_LEADER_ADDR_SIZE			= cdiv(ALL_LEADER_DATA,MCB_BURST_BYTE_NUM)*MCB_BURST_BYTE_NUM;
	//	-------------------------------------------------------------------------------------
	//	leader addr ��������λ����byteΪ��λ
	//	-------------------------------------------------------------------------------------
	localparam	LEADER_ADDR_WIDTH				= log2(ALL_LEADER_DATA+1);

	//	===============================================================================================
	//	trailer ���
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	trailer��ʼ��ַ��leader��ʼ��ַ+leader�ĵ�ַ�ռ䣬��byteΪ��λ
	//	-------------------------------------------------------------------------------------
	localparam	TRAILER_START_ADDR				= LEADER_START_ADDR + ALL_LEADER_ADDR_SIZE;
	//	-------------------------------------------------------------------------------------
	//	1.chunk �ر�ʱ��trailer��С��36byte
	//	2.chunk ��ʱ��trailer��С��32byte
	//	-------------------------------------------------------------------------------------
	localparam	EACH_TRAILER_SIZE				= 32;
	localparam	EACH_TRAILER_SIZE_CHUNK			= 36;
	//	-------------------------------------------------------------------------------------
	//	ÿ��trailer�Ĵ�С�� MCB_BYTE_NUM(8byte) ȡ������Ϊ 32 40 byte
	//	-------------------------------------------------------------------------------------
	localparam	EACH_TRAILER_SIZE_CEIL			= cdiv(EACH_TRAILER_SIZE,MCB_BYTE_NUM)*MCB_BYTE_NUM;
	localparam	EACH_TRAILER_SIZE_CHUNK_CEIL	= cdiv(EACH_TRAILER_SIZE_CHUNK,MCB_BYTE_NUM)*MCB_BYTE_NUM;
	//	-------------------------------------------------------------------------------------
	//	ÿ��trailer��С�Ƿ���������chunk�ر�ʱ��û��������chunk��ʱ����������
	//	-------------------------------------------------------------------------------------
	localparam	TRAILER_REMAINDER				= remain(EACH_TRAILER_SIZE,MCB_BYTE_NUM);
	localparam	TRAILER_CHUNK_REMAINDER			= remain(EACH_TRAILER_SIZE_CHUNK,MCB_BYTE_NUM);
	//	-------------------------------------------------------------------------------------
	//	���е�trailer������������byteΪ��λ
	//	-------------------------------------------------------------------------------------
	localparam	ALL_TRAILER_DATA				= EACH_TRAILER_SIZE_CHUNK_CEIL*MROI_MAX_NUM;
	//	-------------------------------------------------------------------------------------
	//	���е�trailerռ�õĵ�ַ�ռ䣬���� burst byte num(256 byte) ���룬��byteΪ��λ
	//	-------------------------------------------------------------------------------------
	localparam	ALL_TRAILER_ADDR_SIZE			= cdiv(ALL_TRAILER_DATA,MCB_BURST_BYTE_NUM)*MCB_BURST_BYTE_NUM;
	//	-------------------------------------------------------------------------------------
	//	trailer addr ��������λ����byteΪ��λ
	//	-------------------------------------------------------------------------------------
	localparam	TRAILER_ADDR_WIDTH				= log2(ALL_TRAILER_DATA+1);

	//	===============================================================================================
	//	chunk ���
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	chunk��ʼ��ַ��trailer��ʼ��ַ+trailer��ַ�ռ䣬��byteΪ��λ
	//	-------------------------------------------------------------------------------------
	localparam	CHUNK_START_ADDR				= TRAILER_START_ADDR + ALL_TRAILER_ADDR_SIZE;
	//	-------------------------------------------------------------------------------------
	//	ÿ��chunk�Ĵ�С������ʱ����40byte
	//	-------------------------------------------------------------------------------------
	localparam	EACH_CHUNK_SIZE					= 40;
	//	-------------------------------------------------------------------------------------
	//	chunk��С����8�ı���
	//	-------------------------------------------------------------------------------------
	localparam	CHUNK_REMAINDER					= 1'b0;
	//	-------------------------------------------------------------------------------------
	//	���е�chunk������������byteΪ��λ
	//	-------------------------------------------------------------------------------------
	localparam	ALL_CHUNK_DATA					= EACH_CHUNK_SIZE*MROI_MAX_NUM;
	//	-------------------------------------------------------------------------------------
	//	���е�chunkռ�õĵ�ַ�ռ䣬���� burst byte num(256 byte) ���룬��byteΪ��λ
	//	-------------------------------------------------------------------------------------
	localparam	ALL_CHUNK_ADDR_SIZE				= cdiv(ALL_CHUNK_DATA,MCB_BURST_BYTE_NUM)*MCB_BURST_BYTE_NUM;
	//	-------------------------------------------------------------------------------------
	//	chunk addr ��������λ����byteΪ��λ
	//	-------------------------------------------------------------------------------------
	localparam	CHUNK_ADDR_WIDTH				= log2(ALL_CHUNK_DATA+1);
	//	-------------------------------------------------------------------------------------
	//	chunk��С��λ���ü��������ڱ��浱ǰchunk�Ĵ�С
	//	-------------------------------------------------------------------------------------
	localparam	CHUNK_SIZE_WIDTH				= log2(EACH_CHUNK_SIZE+1);

	//	===============================================================================================
	//	image ���
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	image��ʼ��ַ��chunk��ʼ��ַ+chunk��ַ�ռ䣬��byteΪ��λ
	//	-------------------------------------------------------------------------------------
	localparam	IMAGE_START_ADDR				= CHUNK_START_ADDR + ALL_CHUNK_ADDR_SIZE;

	//	===============================================================================================
	//	trailer final ���
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	���е� trailer final ������������byteΪ��λ
	//	-------------------------------------------------------------------------------------
	localparam	ALL_TRAILER_FINAL_DATA			= EACH_TRAILER_SIZE_CHUNK_CEIL*1;
	//	-------------------------------------------------------------------------------------
	//	���е� trailer final ռ�õĵ�ַ�ռ䣬���� burst byte num(256 byte) ���룬��byteΪ��λ
	//	-------------------------------------------------------------------------------------
	localparam	ALL_TRAILER_FINAL_ADDR_SIZE		= cdiv(ALL_TRAILER_FINAL_DATA,MCB_BURST_BYTE_NUM)*MCB_BURST_BYTE_NUM;
	//	-------------------------------------------------------------------------------------
	//	trailer_final��ʼ��ַ��trailer final ����һ֡����λ��
	//	-------------------------------------------------------------------------------------
	localparam	TRAILER_FINAL_START_ADDR		= {{(BYTE_ADDR_WIDTH-log2(ALL_TRAILER_FINAL_ADDR_SIZE)){1'b1}},{log2(ALL_TRAILER_FINAL_ADDR_SIZE){1'b0}}};

	//	===============================================================================================
	//	��������λ�����
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	����leader������֮�� / 8����λ��byte
	//  -------------------------------------------------------------------------------------
	localparam	ALL_LEADER_DATA_DIV8		= cdiv(ALL_LEADER_DATA,8);
	//  -------------------------------------------------------------------------------------
	//	image������ / 8����λ��byte
	//  -------------------------------------------------------------------------------------
	localparam	ALL_IMAGE_DATA_DIV8			= SENSOR_ALL_PIX_DIV4;
	//	-------------------------------------------------------------------------------------
	//	һ��flag�����������ȡ���� leader��image˭��
	//	-------------------------------------------------------------------------------------
	localparam	ALL_FLAG_DATA_DIV8			= (ALL_LEADER_DATA_DIV8>=ALL_IMAGE_DATA_DIV8) ? ALL_LEADER_DATA_DIV8 : ALL_IMAGE_DATA_DIV8;
	//	-------------------------------------------------------------------------------------
	//	flag �����ݼ�������λ��
	//	1.cdiv(ALL_FLAG_DATA_DIV8,MCB_BURST_BYTE_NUM)*MCB_BURST_BYTE_NUM ��ʾһ��flag����������������� burst byte num(256 byte) ���룬��byteΪ��λ
	//	2.log2(cdiv(ALL_FLAG_DATA_DIV8,MCB_BURST_BYTE_NUM)*MCB_BURST_BYTE_NUM+1)+3 ��ʾ��10/12���ظ�ʽ�£�sensor����������������Ҫ��λ����byteΪ��λ
	//	3.-MCB_BYTE_NUM_WIDTH ����MCB������1��byteλ��λ����˻�Ҫ��ȥMCB��λ��
	//	-------------------------------------------------------------------------------------
	localparam	WORD_CNT_FLAG_WIDTH			= log2(cdiv(ALL_FLAG_DATA_DIV8,MCB_BURST_BYTE_NUM)*MCB_BURST_BYTE_NUM+1)+3-MCB_BYTE_NUM_WIDTH;
	//	-------------------------------------------------------------------------------------
	//	line �����ݼ�������λ��
	//	1.cdiv(SENSOR_MAX_WIDTH*2,MCB_BURST_BYTE_NUM)*MCB_BURST_BYTE_NUM+1 ��ʾһ�е���������������� burst byte num(256 byte) ���룬��byteΪ��λ
	//	1.log2(cdiv(SENSOR_MAX_WIDTH*2,MCB_BURST_BYTE_NUM)*MCB_BURST_BYTE_NUM+1) ��ʾ��10/12���ظ�ʽ�£�sensorһ�е����������������Ҫ��λ����byteΪ��λ
	//	2.-MCB_BYTE_NUM_WIDTH ����MCB������1��byteλ��λ����˻�Ҫ��ȥMCB��λ��
	//	-------------------------------------------------------------------------------------
	localparam	WORD_CNT_LINE_WIDTH			= log2(cdiv(SENSOR_MAX_WIDTH*2,MCB_BURST_BYTE_NUM)*MCB_BURST_BYTE_NUM+1)-MCB_BYTE_NUM_WIDTH;
	//	-------------------------------------------------------------------------------------
	//	burst �����ݼ�������λ��
	//	1.�� n byte Ϊ��λ
	//	-------------------------------------------------------------------------------------
	localparam	WORD_CNT_WIDTH				= log2(BURST_SIZE);





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


	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	wr logic signal
	//	-------------------------------------------------------------------------------------
	wire	[PTR_WIDTH-1:0]						wv_wr_ptr					;	//wrap_wr_logic�����clk_frame_bufʱ����дָ��
	wire	[WR_ADDR_WIDTH-1:0]					wv_wr_addr					;	//wrap_wr_logic�����clk_frame_bufʱ����д��ַ
	wire										w_wr_ptr_changing			;	//wrap_wr_logic�����clk_frame_bufʱ����дָ��ı��ź�
	wire										w_writing					;	//wrap_wr_logic�����clk_frame_bufʱ��������д
	wire	[PTR_WIDTH-1:0]						wv_frame_depth				;	//wrap_wr_logic�����clk_frame_bufʱ���򣬾�����Чʱ�����ƵĻ������
	wire										w_wr_cmd_en					;	//wrap_wr_logic�����clk_frame_bufʱ����mcb wr cmd ʹ��
	wire	[2:0]								wv_wr_cmd_instr				;	//wrap_wr_logic�����clk_frame_bufʱ����mcb wr cmd ����
	wire	[5:0]								wv_wr_cmd_bl				;	//wrap_wr_logic�����clk_frame_bufʱ����mcb wr cmd ����
	wire	[29:0]								wv_wr_cmd_byte_addr			;	//wrap_wr_logic�����clk_frame_bufʱ����mcb wr cmd ��ַ
	wire										w_wr_cmd_empty				;	//wrap_wr_logic�����clk_frame_bufʱ����mcb wr cmd ��
	wire										w_wr_cmd_full				;	//wrap_wr_logic�����clk_frame_bufʱ����mcb wr cmd ��
	wire										w_wr_en						;	//wrap_wr_logic�����clk_frame_bufʱ����mcb wr fifo ʹ��
	wire	[DDR3_MASK_SIZE-1:0]				wv_wr_mask					;	//wrap_wr_logic�����clk_frame_bufʱ����mcb wr cmd ����
	wire	[DATA_WD-1:0]						wv_wr_data					;	//wrap_wr_logic�����clk_frame_bufʱ����mcb wr fifo ����
	wire										w_wr_full					;	//wrap_wr_logic�����clk_frame_bufʱ����mcb wr fifo ��
	wire										w_wr_empty_nc				;	//wrap_wr_logic�����clk_frame_bufʱ����mcb wr fifo ��
	wire	[6:0]								wv_wr_count_nc				;	//wrap_wr_logic�����clk_frame_bufʱ����mcb wr fifo ������
	wire										w_wr_underrun_nc			;	//wrap_wr_logic�����clk_frame_bufʱ����mcb wr fifo ����������

	//	-------------------------------------------------------------------------------------
	//	rd logic signal
	//	-------------------------------------------------------------------------------------
	wire	[PTR_WIDTH-1:0]						wv_rd_ptr					;	//wrap_rd_logic�����clk_frame_bufʱ���򣬶�ָ��
	wire										w_reading					;	//wrap_rd_logic�����clk_frame_bufʱ�������ڶ�
	wire										w_rd_cmd_en					;	//wrap_rd_logic�����clk_frame_bufʱ����mcb rd cmd ʹ��
	wire	[2:0]								wv_rd_cmd_instr				;	//wrap_rd_logic�����clk_frame_bufʱ����mcb rd cmd ����
	wire	[5:0]								wv_rd_cmd_bl				;	//wrap_rd_logic�����clk_frame_bufʱ����mcb rd cmd ����
	wire	[29:0]								wv_rd_cmd_byte_addr			;	//wrap_rd_logic�����clk_frame_bufʱ����mcb rd cmd ��ַ
	wire										w_rd_cmd_empty				;	//wrap_rd_logic�����clk_frame_bufʱ����mcb rd cmd ��
	wire										w_rd_cmd_full				;	//wrap_rd_logic�����clk_frame_bufʱ����mcb rd cmd ��
	wire										w_rd_en						;	//wrap_rd_logic�����clk_frame_bufʱ����mcb rd fifo ʹ��
	wire	[DATA_WD-1:0]						wv_rd_data					;	//wrap_rd_logic�����clk_frame_bufʱ����mcb rd fifo ����
	wire										w_rd_full_nc				;	//wrap_rd_logic�����clk_frame_bufʱ����mcb rd fifo ��
	wire										w_rd_empty					;	//wrap_rd_logic�����clk_frame_bufʱ����mcb rd fifo ��
	wire	[6:0]								wv_rd_count_nc				;	//wrap_rd_logic�����clk_frame_bufʱ����mcb rd fifo ������
	wire										w_rd_overflow_nc			;	//wrap_rd_logic�����clk_frame_bufʱ����mcb rd fifo ���



	//	ref ARCHITECTURE
	//	-------------------------------------------------------------------------------------
	//	д�߼�
	//	-------------------------------------------------------------------------------------
	wrap_wr_logic # (
	.DATA_WD							(DATA_WD						),
	.DDR3_MEM_DENSITY					(DDR3_MEM_DENSITY				),
	.DDR3_MASK_SIZE						(DDR3_MASK_SIZE					),
	.BURST_SIZE							(BURST_SIZE						),
	.WR_FLAG_NUM						(WR_FLAG_NUM					),
	.PTR_WIDTH							(PTR_WIDTH						),
	.BYTE_ADDR_WIDTH					(BYTE_ADDR_WIDTH				),
	.WR_ADDR_WIDTH						(WR_ADDR_WIDTH					),
	.WORD_CNT_WIDTH						(WORD_CNT_WIDTH					),
	.MCB_BURST_BYTE_NUM_WIDTH			(MCB_BURST_BYTE_NUM_WIDTH		),
	.SENSOR_MAX_WIDTH					(SENSOR_MAX_WIDTH				),
	.LEADER_START_ADDR					(LEADER_START_ADDR				),
	.TRAILER_START_ADDR					(TRAILER_START_ADDR				),
	.CHUNK_START_ADDR					(CHUNK_START_ADDR				),
	.IMAGE_START_ADDR					(IMAGE_START_ADDR				),
	.TRAILER_FINAL_START_ADDR			(TRAILER_FINAL_START_ADDR		),
	.REG_WD								(REG_WD							)
	)
	wrap_wr_logic_inst (
	.clk_in								(clk_in							),
	.i_fval								(i_fval							),
	.i_dval								(i_dval							),
	.i_leader_flag						(i_leader_flag					),
	.i_image_flag						(i_image_flag					),
	.i_chunk_flag						(i_chunk_flag					),
	.i_trailer_flag						(i_trailer_flag					),
	.iv_din								(iv_din							),
	.o_front_fifo_overflow				(o_front_fifo_overflow			),
	.clk								(clk_frame_buf					),
	.reset								(reset_frame_buf				),
	.ov_wr_ptr							(wv_wr_ptr						),
	.ov_wr_addr							(wv_wr_addr						),
	.o_wr_ptr_changing					(w_wr_ptr_changing				),
	.iv_rd_ptr							(wv_rd_ptr						),
	.i_reading							(w_reading						),
	.o_writing							(w_writing						),
	.i_stream_enable					(i_stream_enable				),
	.iv_frame_depth						(iv_frame_depth[PTR_WIDTH-1:0]	),
	.ov_frame_depth						(wv_frame_depth					),
	.i_calib_done						(o_calib_done					),
	.o_wr_cmd_en						(w_wr_cmd_en					),
	.ov_wr_cmd_instr					(wv_wr_cmd_instr				),
	.ov_wr_cmd_bl						(wv_wr_cmd_bl					),
	.ov_wr_cmd_byte_addr				(wv_wr_cmd_byte_addr			),
	.i_wr_cmd_empty						(w_wr_cmd_empty					),
	.i_wr_cmd_full						(w_wr_cmd_full					),
	.o_wr_en							(w_wr_en						),
	.ov_wr_mask							(wv_wr_mask						),
	.ov_wr_data							(wv_wr_data						),
	.i_wr_full							(w_wr_full						)
	);

	//	-------------------------------------------------------------------------------------
	//	���߼�
	//	-------------------------------------------------------------------------------------
	wrap_rd_logic # (
	.DATA_WD							(DATA_WD							),
	.DDR3_MEM_DENSITY					(DDR3_MEM_DENSITY					),
	.GPIF_DATA_WD						(GPIF_DATA_WD						),
	.BURST_SIZE							(BURST_SIZE							),
	.PTR_WIDTH							(PTR_WIDTH							),
	.WR_ADDR_WIDTH						(WR_ADDR_WIDTH						),
	.RD_ADDR_WIDTH						(RD_ADDR_WIDTH						),
	.WORD_CNT_WIDTH						(WORD_CNT_WIDTH						),
	.WORD_CNT_LINE_WIDTH				(WORD_CNT_LINE_WIDTH				),
	.WORD_CNT_FLAG_WIDTH				(WORD_CNT_FLAG_WIDTH				),
	.BYTE_ADDR_WIDTH					(BYTE_ADDR_WIDTH					),
	.CHUNK_SIZE_WIDTH					(CHUNK_SIZE_WIDTH					),
	.MCB_BYTE_NUM_WIDTH					(MCB_BYTE_NUM_WIDTH					),
	.LEADER_ADDR_WIDTH					(LEADER_ADDR_WIDTH					),
	.CHUNK_ADDR_WIDTH					(CHUNK_ADDR_WIDTH					),
	.LEADER_START_ADDR					(LEADER_START_ADDR					),
	.TRAILER_START_ADDR					(TRAILER_START_ADDR					),
	.CHUNK_START_ADDR					(CHUNK_START_ADDR					),
	.IMAGE_START_ADDR					(IMAGE_START_ADDR					),
	.TRAILER_FINAL_START_ADDR			(TRAILER_FINAL_START_ADDR			),
	.MROI_MAX_NUM						(MROI_MAX_NUM						),
	.RD_FLAG_NUM						(RD_FLAG_NUM						),
	.EACH_LEADER_SIZE_CEIL				(EACH_LEADER_SIZE_CEIL				),
	.EACH_CHUNK_SIZE					(EACH_CHUNK_SIZE					),
	.EACH_TRAILER_SIZE_CEIL				(EACH_TRAILER_SIZE_CEIL				),
	.EACH_TRAILER_SIZE_CHUNK_CEIL		(EACH_TRAILER_SIZE_CHUNK_CEIL		),
	.LEADER_REMAINDER					(LEADER_REMAINDER					),
	.TRAILER_REMAINDER					(TRAILER_REMAINDER					),
	.TRAILER_CHUNK_REMAINDER			(TRAILER_CHUNK_REMAINDER			),
	.SHORT_REG_WD						(SHORT_REG_WD						),
	.REG_WD								(REG_WD								)
	)
	wrap_rd_logic_inst (
	.clk_out							(clk_out							),
	.i_buf_rd							(i_buf_rd							),
	.o_back_buf_empty					(o_back_buf_empty					),
	.ov_dout							(ov_dout							),
	.iv_payload_size_mroi				(iv_payload_size_mroi				),
	.iv_image_size_mroi					(iv_image_size_mroi					),
	.iv_roi_pic_width					(iv_roi_pic_width					),
	.iv_roi_pic_width_mroi				(iv_roi_pic_width_mroi				),
	.iv_start_mroi						(iv_start_mroi						),
	.clk								(clk_frame_buf						),
	.reset								(reset_frame_buf					),
	.iv_wr_ptr							(wv_wr_ptr							),
	.iv_wr_addr							(wv_wr_addr							),
	.ov_rd_ptr							(wv_rd_ptr							),
	.i_writing							(w_writing							),
	.o_reading							(w_reading							),
	.i_stream_enable					(i_stream_enable					),
	.iv_pixel_format					(iv_pixel_format					),
	.iv_frame_depth						(wv_frame_depth						),
	.i_wr_ptr_changing					(w_wr_ptr_changing					),
	.i_chunk_mode_active				(i_chunk_mode_active				),
	.i_calib_done						(o_calib_done						),
	.i_wr_cmd_empty						(w_wr_cmd_empty						),
	.i_rd_cmd_empty						(w_rd_cmd_empty						),
	.i_rd_cmd_full						(w_rd_cmd_full						),
	.o_rd_cmd_en						(w_rd_cmd_en						),
	.ov_rd_cmd_instr					(wv_rd_cmd_instr					),
	.ov_rd_cmd_bl						(wv_rd_cmd_bl						),
	.ov_rd_cmd_byte_addr				(wv_rd_cmd_byte_addr				),
	.iv_rd_data							(wv_rd_data							),
	.i_rd_empty							(w_rd_empty							),
	.o_rd_en							(w_rd_en							)
	);

	//  -------------------------------------------------------------------------------------
	//  MCB (Memory Controller Block) DDR3������ģ��
	//  -------------------------------------------------------------------------------------
	mig_core # (
	.C1_P0_MASK_SIZE					(DDR3_MASK_SIZE			),
	.C1_P0_DATA_PORT_SIZE				(DATA_WD				),
	.C1_P1_MASK_SIZE					(DDR3_MASK_SIZE			),
	.C1_P1_DATA_PORT_SIZE				(DATA_WD				),
	.DEBUG_EN							(0						),
	.C1_MEMCLK_PERIOD					(DDR3_MEMCLK_PERIOD		),
	.C1_CALIB_SOFT_IP					(DDR3_CALIB_SOFT_IP		),
	.C1_SIMULATION						(DDR3_SIMULATION		),
	.C1_RST_ACT_LOW						(0						),
	.C1_INPUT_CLK_TYPE					("SINGLE_ENDED"			),
	.C1_MEM_ADDR_ORDER					(MEM_ADDR_ORDER			),
	.C1_NUM_DQ_PINS						(NUM_DQ_PINS			),
	.C1_MEM_ADDR_WIDTH					(MEM_ADDR_WIDTH			),
	.C1_MEM_BANKADDR_WIDTH				(MEM_BANKADDR_WIDTH		)
	)
	mig_core_inst (
	.mcb1_dram_dq						(mcb1_dram_dq			),
	.mcb1_dram_a						(mcb1_dram_a			),
	.mcb1_dram_ba						(mcb1_dram_ba			),
	.mcb1_dram_ras_n					(mcb1_dram_ras_n		),
	.mcb1_dram_cas_n					(mcb1_dram_cas_n		),
	.mcb1_dram_we_n						(mcb1_dram_we_n			),
	.mcb1_dram_odt						(mcb1_dram_odt			),
	.mcb1_dram_reset_n					(mcb1_dram_reset_n		),
	.mcb1_dram_cke						(mcb1_dram_cke			),
	.mcb1_dram_dm						(mcb1_dram_dm			),
	.mcb1_dram_udqs						(mcb1_dram_udqs			),
	.mcb1_dram_udqs_n					(mcb1_dram_udqs_n		),
	.mcb1_rzq							(mcb1_rzq				),
	//	.mcb1_zio							(mcb1_zio				),
	.mcb1_dram_udm						(mcb1_dram_udm			),
	.mcb1_dram_dqs						(mcb1_dram_dqs			),
	.mcb1_dram_dqs_n					(mcb1_dram_dqs_n		),
	.mcb1_dram_ck						(mcb1_dram_ck			),
	.mcb1_dram_ck_n						(mcb1_dram_ck_n			),
	.c1_calib_done						(o_calib_done			),
	.c1_p0_cmd_clk						(clk_frame_buf			),
	.c1_p0_cmd_en						(w_wr_cmd_en			),
	.c1_p0_cmd_instr					(wv_wr_cmd_instr		),
	.c1_p0_cmd_bl						(wv_wr_cmd_bl			),
	.c1_p0_cmd_byte_addr				(wv_wr_cmd_byte_addr	),
	.c1_p0_cmd_empty					(w_wr_cmd_empty			),
	.c1_p0_cmd_full						(w_wr_cmd_full			),
	.c1_p0_wr_clk						(clk_frame_buf			),
	.c1_p0_wr_en						(w_wr_en				),
	.c1_p0_wr_mask						(wv_wr_mask				),
	.c1_p0_wr_data						(wv_wr_data				),
	.c1_p0_wr_full						(w_wr_full				),
	.c1_p0_wr_empty						(w_wr_empty_nc			),
	.c1_p0_wr_count						(wv_wr_count_nc			),
	.c1_p0_wr_underrun					(w_wr_underrun_nc		),
	.c1_p0_wr_error						(o_wr_error				),
	.c1_p0_rd_clk						(clk_frame_buf			),
	.c1_p0_rd_en						(1'b0					),
	.c1_p0_rd_data						(						),
	.c1_p0_rd_full						(						),
	.c1_p0_rd_empty						(						),
	.c1_p0_rd_count						(						),
	.c1_p0_rd_overflow					(						),
	.c1_p0_rd_error						(						),
	.c1_p1_cmd_clk						(clk_frame_buf			),
	.c1_p1_cmd_en						(w_rd_cmd_en			),
	.c1_p1_cmd_instr					(wv_rd_cmd_instr		),
	.c1_p1_cmd_bl						(wv_rd_cmd_bl			),
	.c1_p1_cmd_byte_addr				(wv_rd_cmd_byte_addr	),
	.c1_p1_cmd_empty					(w_rd_cmd_empty			),
	.c1_p1_cmd_full						(w_rd_cmd_full			),
	.c1_p1_wr_clk						(clk_frame_buf			),
	.c1_p1_wr_en						(1'b0					),
	.c1_p1_wr_mask						(8'h00					),
	.c1_p1_wr_data						(64'h0					),
	.c1_p1_wr_full						(						),
	.c1_p1_wr_empty						(						),
	.c1_p1_wr_count						(						),
	.c1_p1_wr_underrun					(						),
	.c1_p1_wr_error						(						),
	.c1_p1_rd_clk						(clk_frame_buf			),
	.c1_p1_rd_en						(w_rd_en				),
	.c1_p1_rd_data						(wv_rd_data				),
	.c1_p1_rd_full						(w_rd_full_nc			),
	.c1_p1_rd_empty						(w_rd_empty				),
	.c1_p1_rd_count						(wv_rd_count_nc			),
	.c1_p1_rd_overflow					(w_rd_overflow_nc		),
	.c1_p1_rd_error     				(o_rd_error     		),
	.c1_async_rst						(i_async_rst			),
	.c1_sysclk_2x						(i_sysclk_2x			),
	.c1_sysclk_2x_180					(i_sysclk_2x_180		),
	.c1_pll_ce_0						(i_pll_ce_0				),
	.c1_pll_ce_90						(i_pll_ce_90			),
	.c1_pll_lock						(i_bufpll_mcb_lock		),
	.c1_mcb_drp_clk						(i_mcb_drp_clk			)
	);



endmodule
