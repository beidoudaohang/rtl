//--------------------------------s-----------------------------------------------------------------
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
//  -- ��ǿ         :| 2014/11/27 10:16:54	:|  ��ֲ��MER-U3V���̣����ݲ�ƷҪ���ʵ��޸�
//  -- ��ǿ         :| 2015/10/15 17:22:35	:|  ��port����չΪ64bit���
//  -- �Ϻ���       :| 2016/9/14 16:25:07	:|  ��ROI�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :	���߼�����
//              1)  : ���֡ͼ���MCBP3�ڶ�����д����FIFO���������FIFO�������߼���
//              2)  : ��ɶ�������ͳ�ƣ���֤�������ݺ�u3vЭ��Ҫ���������
//              3)  : ��ɶ�ָ�루ͼ���������ַ�任������ַ���ֽڼ������任�Լ�����������������
//
//-------------------------------------------------------------------------------------------------

//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wrap_rd_logic # (
	parameter	DATA_WD										= 64		,	//�������λ������ʹ��ͬһ���
	parameter	DDR3_MEM_DENSITY							= "1Gb"		,	//DDR3 ���� "2Gb" "1Gb" "512Mb"
	parameter	GPIF_DATA_WD								= 32		,	//����������λ��
	parameter	BURST_SIZE									= 32		,	//BURST_SIZE��С

	parameter	PTR_WIDTH									= 2			,	//��дָ���λ��1-���1֡ 2-���3֡ 3-���7֡ 4-���15֡ 5-���31֡ ... 16-���65535֡
	parameter	WR_ADDR_WIDTH   							= 21		,	//֡��д��ַλ��
	parameter	RD_ADDR_WIDTH								= 24		,	//֡�ڶ���ַλ��
	parameter	WORD_CNT_WIDTH								= 5			,	//word cnt λ��
	parameter	WORD_CNT_LINE_WIDTH							= 11		,	//ÿһ�м�������λ��
	parameter	WORD_CNT_FLAG_WIDTH							= 23		,	//ÿ��flag��������λ��

	parameter	BYTE_ADDR_WIDTH								= 27		,	//��Ч��ַλ��DDR3������ͬ��λ��ͬ
	parameter	CHUNK_SIZE_WIDTH							= 6			,	//chunk sizeλ��
	parameter	MCB_BYTE_NUM_WIDTH							= 3			,	//mcb ���ݿ�ȶ�Ӧ��λ��

	parameter	LEADER_ADDR_WIDTH							= 6			,	//leader addr �ļ�����λ��
	parameter	CHUNK_ADDR_WIDTH							= 6			,	//chunk addr �ļ�����λ��

	parameter	LEADER_START_ADDR							= 0			,	//leader���׵�ַ
	parameter	TRAILER_START_ADDR							= 2			,	//trailer���׵�ַ
	parameter	CHUNK_START_ADDR							= 4			,	//chunk���׵�ַ
	parameter	IMAGE_START_ADDR							= 6			,	//image���׵�ַ
	parameter	TRAILER_FINAL_START_ADDR					= {{19{1'b1}},8'b0}		,	//trailer_final���׵�ַ

	parameter	MROI_MAX_NUM 								= 8			,	//Multi-ROI��������
	parameter	RD_FLAG_NUM									= 4			,	//��flag�ĸ���

	parameter	EACH_LEADER_SIZE_CEIL						= 56		,
	parameter	EACH_CHUNK_SIZE								= 40		,
	parameter	EACH_TRAILER_SIZE_CEIL						= 32		,
	parameter	EACH_TRAILER_SIZE_CHUNK_CEIL				= 40		,

	parameter	LEADER_REMAINDER							= 1'b1		,
	parameter	TRAILER_REMAINDER							= 1'b0		,
	parameter	TRAILER_CHUNK_REMAINDER						= 1'b1		,

	parameter	SHORT_REG_WD  								= 16		,	//�̼Ĵ���λ��
	parameter	REG_WD  									= 32			//�Ĵ���λ��
	)
	(
	//	===============================================================================================
	//	ͼ�����ʱ����
	//	===============================================================================================
	input										clk_out					,	//��ʱ�ӣ�ͬU3_ITERFACE ģ��ʱ����
	input										i_buf_rd				,	//��ģ���ʹ�ܣ�����Ч��clk_outʱ����
	output										o_back_buf_empty		,	//��FIFO���źţ�����Ч��clk_outʱ����
	output	[GPIF_DATA_WD:0]					ov_dout					,	//��FIFO������������32bit
	//	===============================================================================================
	//	֡���湤��ʱ����
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	��ROI�Ĵ���
	//	-------------------------------------------------------------------------------------
	input	[MROI_MAX_NUM*REG_WD-1:0]			iv_payload_size_mroi	,	//Multi-ROI payload size ����
	input	[MROI_MAX_NUM*REG_WD-1:0]			iv_image_size_mroi		,	//Multi-ROI image size ����
	input	[SHORT_REG_WD-1:0]					iv_roi_pic_width		,	//sensor���ͼ����ܿ��
	input	[MROI_MAX_NUM*SHORT_REG_WD-1:0]		iv_roi_pic_width_mroi	,	//Multi-ROI pic_width ����
	input	[MROI_MAX_NUM*REG_WD-1:0]			iv_start_mroi			,	//Multi-ROI ֡����ʵ��ַ ����
	input										i_multi_roi_global_en	,	//Multi-ROI ȫ��ʹ��
	//  -------------------------------------------------------------------------------------
	//  �� wrap_wr_logic ����
	//  -------------------------------------------------------------------------------------
	input										clk						,	//MCB ����ʱ��
	input										reset					,	//clkʱ����λ�ź�
	input	[PTR_WIDTH-1:0]						iv_wr_ptr				,	//дָ��
	input	[WR_ADDR_WIDTH-1:0]					iv_wr_addr				,	//д��ַ,Ӧ����������Ч֮���д��ַ
	output	[PTR_WIDTH-1:0]						ov_rd_ptr				,	//��ָ��
	input										i_writing				,	//����д
	output										o_reading				,	//���ڶ�
	output										o_chunk_mode_active		,	//chunk mode active ������Чʱ������
	//  -------------------------------------------------------------------------------------
	//  ��������
	//  -------------------------------------------------------------------------------------
	input										i_stream_enable			,	//��ֹͣ�źţ�clkʱ�����ź���Чʱ������������֡д��֡�棬��Чʱ����ֹͣд�룬����λ��д��ַָ�룬��֡��
	input	[REG_WD-1:0]						iv_pixel_format			,	//���ظ�ʽ�Ĵ���
	input	[PTR_WIDTH-1:0]						iv_frame_depth			,	//֡������ȣ���ͬ��,wrap_wr_logicģ��������Чʱ������
	input										i_wr_ptr_changing		,	//дָ�����ڱ仯�źţ���ʱ��ָ�벻�ܱ仯
	input										i_chunk_mode_active		,	//chunk�ܿ��أ�chunk����Ӱ��leader��trailer�Ĵ�С��ͨ���ж�chunk���ؿ���֪��leader��trailer����
	//  -------------------------------------------------------------------------------------
	//  MCB�˿�
	//  -------------------------------------------------------------------------------------
	input										i_calib_done			,	//MCBУ׼��ɣ�����Ч
	input										i_wr_cmd_empty			,	//MCB CMD �գ�����Ч
	input										i_rd_cmd_empty			,	//MCB CMD �գ�����Ч
	input										i_rd_cmd_full			,	//MCB CMD ��������Ч
	output										o_rd_cmd_en				,	//MCB CMD дʹ�ܣ�����Ч
	output	[2:0]								ov_rd_cmd_instr			,	//MCB CMD ָ��
	output	[5:0]								ov_rd_cmd_bl			,	//MCB CMD ͻ������
	output	[29:0]								ov_rd_cmd_byte_addr		,	//MCB CMD ��ʼ��ַ
	input	[DATA_WD-1:0]						iv_rd_data				,	//MCB RD FIFO �������
	input										i_rd_empty				,	//MCB RD FIFO �գ�����Ч
	output										o_rd_en						//MCB RD FIFO ��ʹ�ܣ�����Ч
	);



	//	ref signals
	localparam	ROI_CNT_WIDTH				= log2(MROI_MAX_NUM);
	localparam	FLAG_CNT_WIDTH				= log2(RD_FLAG_NUM+1);

	//FSM Parameter Define
	parameter	S_IDLE		= 3'd0;
	parameter	S_PTR		= 3'd1;
	parameter	S_CMD		= 3'd2;
	parameter	S_RD		= 3'd3;
	parameter	S_LINE		= 3'd4;
	parameter	S_FLAG		= 3'd5;
	parameter	S_ROI		= 3'd6;

	reg		[2:0]	current_state	= S_IDLE;
	reg		[2:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	reg		[127:0]			state_ascii;
	always @ ( * ) begin
		case(current_state)
			3'd0 :	state_ascii	<= "S_IDLE";
			3'd1 :	state_ascii	<= "S_PTR";
			3'd2 :	state_ascii	<= "S_CMD";
			3'd3 :	state_ascii	<= "S_RD";
			3'd4 :	state_ascii	<= "S_LINE";
			3'd5 :	state_ascii	<= "S_FLAG";
			3'd6 :	state_ascii	<= "S_ROI";
		endcase
	end
	// synthesis translate_on

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
	//	��̬λ��ƴ��
	//	1.����verilog�е�λ��ƴ��������в�������ֱ����������function�ķ�ʽʵ�ֶ�̬λ��ƴ��
	//	function forѭ��չ��֮��
	//	-------------------------------------------------------------------------------------
	//	i		              ptr_and_addr
	//
	//	i=0		        |------------------------|
	//	i=1		        ||-----------------------|
	//	i=2		        | |----------------------|
	//	i=3		        |  |---------------------|
	//	i=4		        |   |--------------------|
	//	i=5		        |    |-------------------|
	//                    ^           ^
	//			        |ptr |       addr        |
	//	-------------------------------------------------------------------------------------
	//	��ַ�Ų� forѭ��չ��֮��
	//  -------------------------------------------------------------------------------------
	//	i		��Ӧframe_depth��ֵ		byte_addrʵ���Ų�
	//	i=0		1						{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_addr[RD_ADDR_WIDTH-1:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	i=1		2       				{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_ptr[0:0],rd_addr[RD_ADDR_WIDTH-2:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	i=2		3-4						{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_ptr[1:0],rd_addr[RD_ADDR_WIDTH-3:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	i=3 	5-8						{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_ptr[2:0],rd_addr[RD_ADDR_WIDTH-4:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	i=4		9-16					{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_ptr[3:0],rd_addr[RD_ADDR_WIDTH-5:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	i=5		17-32					{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_ptr[4:0],rd_addr[RD_ADDR_WIDTH-6:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	i=6		33-64					{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_ptr[5:0],rd_addr[RD_ADDR_WIDTH-7:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	i=7		65-128					{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_ptr[6:0],rd_addr[RD_ADDR_WIDTH-8:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	i=8		129-256					{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_ptr[7:0],rd_addr[RD_ADDR_WIDTH-9:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	......
	//	-------------------------------------------------------------------------------------
	function [RD_ADDR_WIDTH-1:0] ptr_and_addr;
		input	[PTR_WIDTH-1:0]			ptr_int;
		input	[RD_ADDR_WIDTH-1:0]		addr_int;
		input	[PTR_WIDTH-1:0]			depth_int;
		integer	i;
		integer	j;
		begin
			if(depth_int==1) begin
				ptr_and_addr	= addr_int;
			end
			for(i=1;i<=PTR_WIDTH;i=i+1) begin
				if(depth_int>=(2**(i-1)+1) && depth_int<=2**i) begin
					for(j=0;j<RD_ADDR_WIDTH;j=j+1) begin
						if(j<RD_ADDR_WIDTH-i) begin
							ptr_and_addr[j]	= addr_int[j];
						end
						else begin
							ptr_and_addr[j]	= ptr_int[j+i-RD_ADDR_WIDTH];
						end
					end
				end
			end
		end
	endfunction

	//	-------------------------------------------------------------------------------------
	//	edge
	//	-------------------------------------------------------------------------------------
	reg										stream_enable_dly	= 1'b0;
	wire									stream_enable_rise	;
	reg		[1:0]							calib_done_shift	= 2'b00;
	reg										writing_dly 		= 1'b0;
	wire									writing_rise		;
	reg										reading_dly 		= 1'b0;
	wire									reading_rise		;
	//	-------------------------------------------------------------------------------------
	//	reg active time
	//	-------------------------------------------------------------------------------------
	reg										format8_sel			= 1'b0;
	reg										chunk_mode_active	= 1'b0;

	//	-------------------------------------------------------------------------------------
	//	divide roi
	//	-------------------------------------------------------------------------------------
	wire	[SHORT_REG_WD-1:0]										roi_pic_width_ch[MROI_MAX_NUM-1:0]	;	//���»���ͨ��
	wire	[SHORT_REG_WD-1:0]										roi_pic_width_global				;	//���п�ֻ�� multi-roi ģʽ�� �Ż����øüĴ���
	wire	[SHORT_REG_WD-1:0]										roi_pic_width_global_format_temp	;	//����format���Ƶ����п�������ظ�ʽ����8����*2
	wire	[WORD_CNT_LINE_WIDTH+MCB_BYTE_NUM_WIDTH-1:0]			roi_pic_width_global_format			;	//����format���Ƶ����п�������ظ�ʽ����8����*2
	wire	[SHORT_REG_WD-1:0]										roi_pic_width_active_format_temp	;	//��ǰ�Ŀ�ȣ�������ظ�ʽ����8����*2
	wire	[WORD_CNT_LINE_WIDTH+MCB_BYTE_NUM_WIDTH-1:0]			roi_pic_width_active_format			;	//��ǰ�Ŀ�ȣ�������ظ�ʽ����8����*2
	wire	[REG_WD-1:0]											payload_size_ch[MROI_MAX_NUM-1:0]	;	//���»���ͨ��
	wire	[REG_WD-1:0]											image_size_ch[MROI_MAX_NUM-1:0]		;	//���»���ͨ��
	wire	[REG_WD-1:0]											start_mroi_ch[MROI_MAX_NUM-1:0]		;	//���»���ͨ��

	//	-------------------------------------------------------------------------------------
	//	back fifo
	//	-------------------------------------------------------------------------------------
	wire									reset_fifo			;
	wire									fifo_wr_en			;
	wire									fifo_full			;
	wire									fifo_prog_full		;
	wire	[65:0]							fifo_din			;

	//	-------------------------------------------------------------------------------------
	//	mcb fifo operation
	//	-------------------------------------------------------------------------------------
	wire									mcb_rd_en			;
	reg										rd_cmd_en			= 1'b0;
	wire	[RD_ADDR_WIDTH-1:0]				ptr_and_addr_int	;

	//	-------------------------------------------------------------------------------------
	//	ptr addr cnt
	//	-------------------------------------------------------------------------------------
	reg		[PTR_WIDTH-1:0]					rd_ptr				= 'b0;
	reg		[RD_ADDR_WIDTH-1:0]				rd_addr				= 'b0;
	reg		[LEADER_ADDR_WIDTH-1:0]			leader_addr			= 'b0;
	reg		[BYTE_ADDR_WIDTH-1:0]			trailer_addr		= 'b0;
	reg		[CHUNK_ADDR_WIDTH-1:0]			chunk_addr			= 'b0;
	reg		[BYTE_ADDR_WIDTH-1:0]			image_addr			= 'b0;

	//	-------------------------------------------------------------------------------------
	//	word cnt
	//	-------------------------------------------------------------------------------------
	reg		[WORD_CNT_WIDTH-1:0]			word_cnt			= 'b0;	//��λ�� n byte,n ��mcb fifo �Ŀ��
	reg		[WORD_CNT_LINE_WIDTH-1:0]		word_cnt_line		= 1;	//��λ�� n byte,n ��mcb fifo �Ŀ��
	reg		[WORD_CNT_FLAG_WIDTH-1:0]		word_cnt_flag		= 1;	//��λ�� n byte,n ��mcb fifo �Ŀ��

	//	-------------------------------------------------------------------------------------
	//	num cnt
	//	-------------------------------------------------------------------------------------
	reg		[FLAG_CNT_WIDTH-1:0]			flag_num_cnt		= 'b0;

	//	-------------------------------------------------------------------------------------
	//	size
	//	-------------------------------------------------------------------------------------
	reg		[CHUNK_SIZE_WIDTH-1:0]							chunk_size				= 'b0;	//��λ��byte
	reg		[WORD_CNT_LINE_WIDTH+MCB_BYTE_NUM_WIDTH-1:0]	line_word_size			= 'b0;	//��λ��byte
	reg		[WORD_CNT_FLAG_WIDTH+MCB_BYTE_NUM_WIDTH-1:0]	flag_word_size			= 'b0;	//��λ��byte
	reg														remainder_head			= 1'b0;
	reg														remainder_tail			= 1'b0;

	//	-------------------------------------------------------------------------------------
	//	parser leader info
	//	-------------------------------------------------------------------------------------
	reg		[ROI_CNT_WIDTH-1:0]				roi_num				= 'b0;
	reg										last_roi			= 1'b0;

	//	-------------------------------------------------------------------------------------
	//	fsm flag
	//	-------------------------------------------------------------------------------------
	wire									burst_done			;			//һ��burst�������㹻
	wire									line_done			;			//һ���������㹻
	reg										flag_done_reg		= 1'b0;		//һ���������㹻
	wire									flag_done_int		;			//һ���������㹻���
	wire									flag_done			;			//һflag�������㹻
	reg										line_done_reg		= 1'b0;		//һflag�������㹻
	wire									line_done_int		;			//һflag�������㹻���
	wire									line_equal			;			//��ǰroi�Ŀ���Ƿ����ܿ�����
	wire									last_flag			;			//���һ��flag��־λ

	wire									dummy_head			;
	wire									dummy_tail			;

	reg										able_to_read		= 1'b0;
	reg										pipe_cnt			= 1'b0;

	reg										reading_reg 		= 1'b0;
	reg										fresh_frame 		= 1'b0;
	wire									ptr_move			;	//ָ������ƶ��ź�






	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***edge***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	stream_enable ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		stream_enable_dly	<= i_stream_enable;
	end
	assign	stream_enable_rise	= (stream_enable_dly==1'b0 && i_stream_enable==1'b1) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	i_calib_done ʱ����δ֪����Ҫ��2�Ĵ���
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		calib_done_shift	<= {calib_done_shift[0],i_calib_done};
	end

	//	-------------------------------------------------------------------------------------
	//	�ж�writing��������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		writing_dly	<= i_writing;
	end
	assign	writing_rise	= (writing_dly==1'b0 && i_writing==1'b1) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	�ж�writing��������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		reading_dly	<= reading_reg;
	end
	assign	reading_rise	= (reading_dly==1'b0 && reading_reg==1'b1) ? 1'b1 : 1'b0;

	//	===============================================================================================
	//	ref ***reg activate time***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	USB3 Vision 	version 1.0.1	March, 2015
	//	table 5-14: Recommended Pixel Formats
	//
	//	Mono1p			0x01010037
	//	Mono2p			0x01020038
	//	Mono4p			0x01040039
	//	Mono8			0x01080001
	//	Mono10			0x01100003
	//	Mono10p			0x010a0046
	//	Mono12			0x01100005
	//	Mono12p			0x010c0047
	//	Mono14			0x01100025
	//	Mono16			0x01100007
	//
	//	BayerGR8		0x01080008
	//	BayerGR10		0x0110000C
	//	BayerGR10p		0x010A0056
	//	BayerGR12		0x01100010
	//	BayerGR12p		0x010C0057
	//	BayerGR16		0x0110002E
	//
	//	BayerRG8		0x01080009
	//	BayerRG10		0x0110000D
	//	BayerRG10p		0x010A0058
	//	BayerRG12		0x01100011
	//	BayerRG12p		0x010C0059
	//	BayerRG16		0x0110002F
	//
	//	BayerGB8		0x0108000A
	//	BayerGB10		0x0110000E
	//	BayerGB10p		0x010A0054
	//	BayerGB12		0x01100012
	//	BayerGB12p		0x010C0055
	//	BayerGB16		0x01100030
	//
	//	BayerBG8		0x0108000B
	//	BayerBG10		0x0110000F
	//	BayerBG10p		0x010A0052
	//	BayerBG12		0x01100013
	//	BayerBG12p		0x010C0053
	//	BayerBG16		0x01100031

	//	BGR8			0x02180015
	//	BGR10			0x02300019
	//	BGR10p			0x021E0048
	//	BGR12			0x0230001B
	//	BGR12p			0x02240049
	//	BGR14			0x0230004A
	//	BGR16			0x0230004B

	//	BGRa8			0x02200017
	//	BGRa10			0x0240004C
	//	BGRa10p			0x0228004D
	//	BGRa12			0x0240004E
	//	BGRa12p			0x0230004F
	//	BGRa14			0x02400050
	//	BGRa16			0x02400051
	//
	//	YCbCr8			0x0218005B
	//	YCbCr422_8		0x0210003B
	//	YCbCr411_8		0x020C005A
	//  -------------------------------------------------------------------------------------
	//	format8_sel
	//	1.�ж����ظ�ʽ�Ƿ�ѡ��8bit���ظ�ʽ
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(stream_enable_rise==1'b1) begin
			case (iv_pixel_format[6:0])
				7'h01		: format8_sel	<= 1'b1;
				7'h08		: format8_sel	<= 1'b1;
				7'h09		: format8_sel	<= 1'b1;
				7'h0A		: format8_sel	<= 1'b1;
				7'h0B		: format8_sel	<= 1'b1;
				7'h15		: format8_sel	<= 1'b1;
				7'h17		: format8_sel	<= 1'b1;
				7'h5B		: format8_sel	<= 1'b1;
				7'h3B		: format8_sel	<= 1'b1;
				7'h5A		: format8_sel	<= 1'b1;
				default		: format8_sel	<= 1'b0;
			endcase
		end
	end

	//	-------------------------------------------------------------------------------------
	//	��se�����ز��� chunk mode ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(stream_enable_rise==1'b1) begin
			chunk_mode_active	<= i_chunk_mode_active;
		end
	end
	assign	o_chunk_mode_active	= chunk_mode_active;

	//	===============================================================================================
	//	ref ***divide roi***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	�����п�
	//	-------------------------------------------------------------------------------------
	genvar	i;
	generate
		for(i=0;i<MROI_MAX_NUM;i=i+1) begin
			assign	roi_pic_width_ch[i]	= iv_roi_pic_width_mroi[SHORT_REG_WD*(i+1)-1:SHORT_REG_WD*i];
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	���п�
	//	1.���� multi-roi ȫ�ֿ��ص�ʱ�����п�=iv_roi_pic_width������Ĵ����ĵ�ַ�� 0x2b03
	//	2.���ر� multi-roi ȫ�ֿ��ص�ʱ�����п�=roi_pic_width_ch[0]������Ĵ����ĵ�ַ�� 0x42
	//	-------------------------------------------------------------------------------------
	assign	roi_pic_width_global			= (i_multi_roi_global_en==1'b1) ? iv_roi_pic_width : roi_pic_width_ch[0];

	//	-------------------------------------------------------------------------------------
	//	����format���Ƶ����п�
	//	1.8bitģʽ�£��п���
	//	2.10 12bitģʽ�£��п�*2
	//	-------------------------------------------------------------------------------------
	assign	roi_pic_width_global_format_temp	= (format8_sel==1'b1) ? roi_pic_width_global : roi_pic_width_global<<1;
	assign	roi_pic_width_global_format			= roi_pic_width_global_format_temp[WORD_CNT_LINE_WIDTH+MCB_BYTE_NUM_WIDTH-1:0];

	//	-------------------------------------------------------------------------------------
	//	����format���Ƶĵ�ǰroi���п�
	//	1.8bitģʽ�£��п���
	//	2.10 12bitģʽ�£��п�*2
	//	-------------------------------------------------------------------------------------
	assign	roi_pic_width_active_format_temp	= (format8_sel==1'b1) ? roi_pic_width_ch[roi_num] : roi_pic_width_ch[roi_num]<<1;
	assign	roi_pic_width_active_format			= roi_pic_width_active_format_temp[WORD_CNT_LINE_WIDTH+MCB_BYTE_NUM_WIDTH-1:0];

	//	-------------------------------------------------------------------------------------
	//	����payload_size
	//	-------------------------------------------------------------------------------------
	genvar	j;
	generate
		for(j=0;j<MROI_MAX_NUM;j=j+1) begin
			assign	payload_size_ch[j]	= iv_payload_size_mroi[REG_WD*(j+1)-1:REG_WD*j];
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	����image_size
	//	-------------------------------------------------------------------------------------
	genvar	k;
	generate
		for(k=0;k<MROI_MAX_NUM;k=k+1) begin
			assign	image_size_ch[k]	= iv_image_size_mroi[REG_WD*(k+1)-1:REG_WD*k];
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	����start_mroi
	//	-------------------------------------------------------------------------------------
	genvar	l;
	generate
		for(l=0;l<MROI_MAX_NUM;l=l+1) begin
			assign	start_mroi_ch[l]	= iv_start_mroi[REG_WD*(l+1)-1:REG_WD*l];
		end
	endgenerate

	//	===============================================================================================
	//	ref ***back fifo***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	back fifo ����
	//	-------------------------------------------------------------------------------------
	frame_buf_back_fifo_ww66wd512rw33wd1024_pf440 frame_buf_back_fifo_ww66wd512rw33wd1024_pf440_inst (
	.rst			(reset_fifo			),
	.wr_clk			(clk				),
	.wr_en			(fifo_wr_en			),
	.full			(fifo_full			),
	.prog_full		(fifo_prog_full		),
	.din			(fifo_din			),
	.rd_clk			(clk_out			),
	.rd_en			(i_buf_rd			),
	.empty			(o_back_buf_empty	),
	.dout			(ov_dout			)
	);

	//	-------------------------------------------------------------------------------------
	//	fifo ��λ
	//	1.reset��Ч(֡��ʱ����)
	//	2.ͣ��
	//	-------------------------------------------------------------------------------------
	assign	reset_fifo	= reset | !i_stream_enable;

	//	-------------------------------------------------------------------------------------
	//	fifo дʹ��
	//	1.mcb rd fifo ��ʹ����Ч
	//	2.һ��û�н���
	//	3.һ��flagû�н���
	//	-------------------------------------------------------------------------------------
	//	assign	fifo_wr_en	= (mcb_rd_en==1'b1 && line_done==1'b0 && flag_done==1'b0) ? 1'b1 : 1'b0;
	assign	fifo_wr_en	= (mcb_rd_en==1'b1 && line_done_reg==1'b0 && flag_done_reg==1'b0) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	fifo ��������
	//	1.FIFO 64bitתΪ32bit����32λ����������Խ����ߵ�32bit����
	//	2.����һ�������һ�л���һ��flag��β��λ�ã�����������8byte����Ҫ�Ѷ����4byte��ǳ�����ctrl_bit���Ǳ�־λ
	//	-------------------------------------------------------------------------------------
	assign	fifo_din	= {dummy_head,iv_rd_data[GPIF_DATA_WD-1:0],dummy_tail,iv_rd_data[DATA_WD-1:GPIF_DATA_WD]};

	//	===============================================================================================
	//	ref ***mcb fifo operation***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	mcb rd fifo ��ʹ���ź�
	//	1.��״̬ 2.mcb rd fifo ���� 3.���fifo����
	//	-------------------------------------------------------------------------------------
	assign	mcb_rd_en	= (current_state==S_RD && i_rd_empty==1'b0 && fifo_full==1'b0) ? 1'b1 : 1'b0;
	assign	o_rd_en		= mcb_rd_en;

	//	-------------------------------------------------------------------------------------
	//	mcb rd cmd fifo ʹ���ź�
	//	1.ֻ�� CMD ״̬���ܷ���ʹ���ź�
	//	2.����ʹ���źŵ������� CMD ��ת�� RD ��������һ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_CMD && able_to_read==1'b1) begin
			rd_cmd_en	<= 1'b1;
		end
		else begin
			rd_cmd_en	<= 1'b0;
		end
	end
	assign	o_rd_cmd_en	= rd_cmd_en;

	//	-------------------------------------------------------------------------------------
	//	��ָ��
	//	1.���ݲ������壬������2�����ʽ
	//	2.3'b011 -> with precharge; 3'b001 -> without precharge
	//	-------------------------------------------------------------------------------------
	assign	ov_rd_cmd_instr	= 3'b001;

	//	-------------------------------------------------------------------------------------
	//	������
	//	1.ÿ�ζ��ĳ��ȹ̶�Ϊ BURST_SIZE
	//	2.line��β flag��β ���һ��burst�������������ݣ���Ҫ���ⲿ������������
	//	-------------------------------------------------------------------------------------
	assign	ov_rd_cmd_bl 	= BURST_SIZE-1;

	//  -------------------------------------------------------------------------------------
	//	mcb ��ַƴ��
	//	1.UG388 pg63 �Ե�ַ�ֲ�����ϸ������
	//	2.burst_size ��С��ͬ�����λ�̶�Ϊ0�ĸ���Ҳ��ͬ
	//	3.���� iv_frame_depth ����˿�λ����16������֧�ֵ���󻺴����Ϊ2**16-1=65535֡
	//	4.���ݵ�ǰ�趨��֡������ȣ����ı�洢λ��
	//	-------------------------------------------------------------------------------------
	assign	ptr_and_addr_int	= ptr_and_addr(rd_ptr[PTR_WIDTH-1:0],rd_addr[RD_ADDR_WIDTH-1:0],iv_frame_depth[PTR_WIDTH-1:0]);
	assign	ov_rd_cmd_byte_addr	= {{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},ptr_and_addr_int[RD_ADDR_WIDTH-1:0],{MCB_BYTE_NUM_WIDTH{1'b0}}};

	//	===============================================================================================
	//	ref ***ptr addr cnt***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	��ָ���߼�
	//	1.��֡�������1֡���߸�λ�ź���Ч����ʹ����Чʱ����ָ�븴λ
	//	2.��������£���д����=1�ҿ��Զ�(��дָ�벻һ��)����ָ������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(iv_frame_depth==1 || reset==1'b1 || i_stream_enable==1'b0) begin
			rd_ptr	<= 'b0;
		end
		else begin
			//	-------------------------------------------------------------------------------------
			//	ֻ���� PTR ״̬�� wr_ptr_change=0��ʱ�򣬲��ܸı��ָ��
			//	-------------------------------------------------------------------------------------
			if(current_state==S_PTR && i_wr_ptr_changing==1'b0) begin
				//	-------------------------------------------------------------------------------------
				//	����֡��ʱ�������ָ��!=дָ�룬˵�����µ����ݣ���ô�����Խ���д
				//	-------------------------------------------------------------------------------------
				if(rd_ptr!=iv_wr_ptr) begin
					//	-------------------------------------------------------------------------------------
					//	�����ָ��ﵽ������ȵ����ֵ����ô��ָ��Ҫ���㡣
					//	--�����ʱдָ��ҲΪ0����ô������д����ʱ����ַҪС�ڵ���д��ַ
					//	-------------------------------------------------------------------------------------
					if(rd_ptr==(iv_frame_depth-1)) begin
						rd_ptr	<= 0;
					end
					//	-------------------------------------------------------------------------------------
					//	�����ָ��û�дﵽ������ȵ����ֵ����ô��ָ��������
					//	-------------------------------------------------------------------------------------
					else begin
						rd_ptr	<= rd_ptr + 1'b1;
					end
				end
				//	-------------------------------------------------------------------------------------
				//	����֡��ʱ�򣬶�ָ��=дָ�룬˵������û��ˢ�¹���FSM����idle״̬����ָ�벻�ܸı�
				//	-------------------------------------------------------------------------------------
			end
		end
	end
	assign	ov_rd_ptr		= rd_ptr;

	//  -------------------------------------------------------------------------------------
	//  д��ַ�߼�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	��idle״̬�£���ַ����
		//	-------------------------------------------------------------------------------------
		if(current_state==S_IDLE) begin
			rd_addr	<= leader_addr[LEADER_ADDR_WIDTH-1:MCB_BYTE_NUM_WIDTH];
		end
		//	-------------------------------------------------------------------------------------
		//	�� LINE ״̬�£����¶���ַ
		//	-------------------------------------------------------------------------------------
		else if(current_state==S_LINE) begin
			rd_addr	<= image_addr[BYTE_ADDR_WIDTH-1:MCB_BYTE_NUM_WIDTH];
		end
		//	-------------------------------------------------------------------------------------
		//	�� FLAG ״̬�£����¶���ַ
		//	-------------------------------------------------------------------------------------
		else if(current_state==S_FLAG) begin
			if(flag_num_cnt==1) begin
				rd_addr	<= image_addr[BYTE_ADDR_WIDTH-1:MCB_BYTE_NUM_WIDTH];
			end
			else if(flag_num_cnt==2) begin
				rd_addr	<= chunk_addr[CHUNK_ADDR_WIDTH-1:MCB_BYTE_NUM_WIDTH];
			end
			else if(flag_num_cnt==3) begin
				rd_addr	<= trailer_addr[BYTE_ADDR_WIDTH-1:MCB_BYTE_NUM_WIDTH];
			end
		end
		//	-------------------------------------------------------------------------------------
		//	�� ROI ״̬�£����¶���ַ
		//	-------------------------------------------------------------------------------------
		else if(current_state==S_ROI) begin
			rd_addr	<= leader_addr[LEADER_ADDR_WIDTH-1:MCB_BYTE_NUM_WIDTH];
		end
		//	-------------------------------------------------------------------------------------
		//	������״̬�£����������֮��д��ַ����
		//	-------------------------------------------------------------------------------------
		else if(rd_cmd_en==1'b1) begin
			rd_addr	<= rd_addr + BURST_SIZE;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	����leader��ַ
	//	1.��idle״̬��ʱ�򣬸�λΪleader�Ŀ�ʼ��ַ
	//	2.��һ֡������ʱ�򣬸�λΪleader�Ŀ�ʼ��ַ����Ϊ��idle״̬ (1) leader_addr	<= LEADER_START_ADDR; (2) rd_addr	<= leader_addr[LEADER_ADDR_WIDTH-1:MCB_BYTE_NUM_WIDTH];
	//		���idleֻ��1�ģ��� rd_addr �������Ϊ��ʼֵ
	//	2.�ڶ� leader ��ʱ��ÿ����һ�� cmd ����ַ�ۼ�
	//	3.�ۼӵ���ֵ�� leader��С/8 ��ȡ��
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			leader_addr	<= LEADER_START_ADDR;
		end
		else if(current_state==S_ROI && last_roi==1'b1) begin
			leader_addr	<= LEADER_START_ADDR;
		end
		else if(flag_num_cnt==0 && rd_cmd_en==1'b1) begin
			leader_addr	<= leader_addr + EACH_LEADER_SIZE_CEIL;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	����chunk��ַ
	//	1.��idle״̬��ʱ�򣬸�λΪchunk�Ŀ�ʼ��ַ
	//	2.�ڶ� chunk ��ʱ��ÿ����һ�� cmd ����ַ�ۼ�
	//	3.�ۼӵ���ֵ�ǴӼĴ�����̬��ȡ��chunk��С����8�ı���
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			chunk_addr	<= CHUNK_START_ADDR;
		end
		else if(flag_num_cnt==2 && rd_cmd_en==1'b1) begin
			chunk_addr	<= chunk_addr + chunk_size;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	����trailer��ַ
	//	1.��idle״̬��ʱ�򣬸�λΪtrailer�Ŀ�ʼ��ַ
	//	2.�ڶ� trailer ��ʱ��ÿ����һ�� cmd ����ַ�ۼ�
	//	3.�ۼӵ���ֵ�� trailer��С/8 ��ȡ��
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			trailer_addr	<= TRAILER_START_ADDR;
		end
		else if(flag_num_cnt==3 && last_roi==1'b1) begin
			trailer_addr	<= TRAILER_FINAL_START_ADDR;
		end
		else if(flag_num_cnt==3 && rd_cmd_en==1'b1) begin
			trailer_addr	<= trailer_addr + EACH_TRAILER_SIZE_CHUNK_CEIL;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	����image��ַ
	//	1.��leader�׶Σ���ַ�л�Ϊ��Ӧ��roi����ʼ��ַ
	//	2.��line״̬�����Ҫ�����п������� pipe_cnt=0��ʱ���ۼӣ���Ϊ��pipe_cnt=1��ʱ��rd_addr����� image_addr
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(flag_num_cnt==0) begin
			image_addr	<= start_mroi_ch[roi_num]+IMAGE_START_ADDR;
		end
		else if(current_state==S_LINE && pipe_cnt==1'b0) begin
			//			image_addr	<= image_addr + roi_pic_width_active_format;
			image_addr	<= image_addr + roi_pic_width_global_format;
		end
	end

	//	===============================================================================================
	//	ref ***word cnt***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	word_cnt һ��burst������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	1.һ��burst�ļ����������� burst_size
		//	2.����Ҫ���ж�reset����Ϊreset=1���ͻ����idle״̬
		//	3.��һ֡��ʼ��ʱ����ռ���������wr_addrһͬ���㡣
		//	-------------------------------------------------------------------------------------
		if(current_state==S_IDLE) begin
			word_cnt	<= 'b0;
		end
		//	-------------------------------------------------------------------------------------
		//	���뵽 LINE FLAG ROI ״̬��˵��һ�� һ��flag һ��roi �����ˣ���ʱword_cnt��Ҫ��λ
		//	-------------------------------------------------------------------------------------
		else if(current_state==S_LINE || current_state==S_FLAG || current_state==S_ROI) begin
			word_cnt	<= 'b0;
		end
		//	-------------------------------------------------------------------------------------
		//	���������£�ÿ��һ��mcb rd fifo��word_cnt����
		//	-------------------------------------------------------------------------------------
		else if(mcb_rd_en==1'b1) begin
			word_cnt	<= word_cnt + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	word_cnt_line ��ͼ��׶Σ�һ�����ݼ�����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	1.��idle״̬����λ
		//	2.��line״̬����pipe_cnt=1����ʱҪ��line״̬��������λ
		//	-------------------------------------------------------------------------------------
		if(current_state==S_IDLE || (current_state==S_LINE && pipe_cnt==1'b1)) begin
			word_cnt_line	<= 1;
		end
		//	-------------------------------------------------------------------------------------
		//	1.ֻ��image flag�ڼ����
		//	-------------------------------------------------------------------------------------
		else if(flag_num_cnt==1 && mcb_rd_en==1'b1 && line_done_reg==1'b0) begin
			word_cnt_line	<= word_cnt_line + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	word_cnt_flag һ��FLAG���ݼ�����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	1.��idle״̬����λ
		//	2.��flag״̬����pipe_cnt=1����ʱҪ��line״̬��������λ
		//	-------------------------------------------------------------------------------------
		if(current_state==S_IDLE || (current_state==S_FLAG && pipe_cnt==1'b1)) begin
			word_cnt_flag	<= 1;
		end
		//	-------------------------------------------------------------------------------------
		//	1.ֻ��image flag�ڼ����
		//	-------------------------------------------------------------------------------------
		else if(mcb_rd_en==1'b1 && line_done_reg==1'b0 && flag_done_reg==1'b0) begin
			word_cnt_flag	<= word_cnt_flag + 1'b1;
		end
	end

	//	===============================================================================================
	//	ref ***num cnt***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	flag_num_cnt
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	1.��idle״̬����λ
		//	2.��roi״̬����λ�� ��flag״̬����������Ҫ����roi״̬
		//	-------------------------------------------------------------------------------------
		if(current_state==S_IDLE || current_state==S_ROI) begin
			flag_num_cnt	<= 'b0;
		end
		//	-------------------------------------------------------------------------------------
		//	1.������flag״̬��pipe cnt=0��flag����������
		//	-------------------------------------------------------------------------------------
		else if(current_state==S_FLAG && pipe_cnt==1'b0) begin
			//	-------------------------------------------------------------------------------------
			//	���chunkû�д򿪣�����chunk
			//	-------------------------------------------------------------------------------------
			if(chunk_mode_active==1'b0 && flag_num_cnt==1'b1) begin
				flag_num_cnt	<= flag_num_cnt + 2;
			end
			else begin
				flag_num_cnt	<= flag_num_cnt + 1'b1;
			end
		end
	end

	//	//	-------------------------------------------------------------------------------------
	//	//	roi_num_cnt
	//	//	-------------------------------------------------------------------------------------
	//	always @ (posedge clk) begin
	//		//	-------------------------------------------------------------------------------------
	//		//	ֻ��idle״̬��λ
	//		//	-------------------------------------------------------------------------------------
	//		if(current_state==S_IDLE) begin
	//			roi_num_cnt	<= 'b0;
	//		end
	//		//	-------------------------------------------------------------------------------------
	//		//	1.������roi״̬��pipe cnt=0��roi����������
	//		//	-------------------------------------------------------------------------------------
	//		else if(current_state==S_ROI && pipe_cnt==1'b0) begin
	//			roi_num_cnt	<= roi_num_cnt + 1'b1;
	//		end
	//	end

	//	===============================================================================================
	//	ref ***size***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	��se�����ز��� chunk size����roi0�� payload size �� image_size �Ĳ��ʾ
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(stream_enable_rise==1'b1) begin
			chunk_size	<= payload_size_ch[0] - image_size_ch[0];
		end
	end

	//	-------------------------------------------------------------------------------------
	//	1.flag_word_size	ÿ��flag�Ĵ�С����byteΪ��λ
	//	2.line_word_size	ͼ��״̬�£�ÿһ�еĴ�С����byteΪ��λ
	//	3.remainder			flag����line�Ĵ�С ����"MCB FIFO �Ŀ��(Ĭ����8byte)"֮���Ƿ���������1�������� 0��û������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(flag_num_cnt)
			//	-------------------------------------------------------------------------------------
			//	leader
			//	1.flag_word_size
			//	--52byte ����8��������������ҪдΪ56byte
			//	2.remainder_head
			//	--�����8����������û������
			//	3.remainder_tail
			//	--���һ�����ݣ���4byte�Ƕ����
			//	-------------------------------------------------------------------------------------
			0	: begin
				flag_word_size	<= EACH_LEADER_SIZE_CEIL;
				remainder_head	<= 1'b0;
				remainder_tail	<= LEADER_REMAINDER;
			end
			//	-------------------------------------------------------------------------------------
			//	image
			//	1.flag_word_size
			//	--ͼ���С����flag�Ĵ�С
			//	2.line_word_size
			//	--�����ʼ���������������п�����������Ҫ����һ����������������������� 1 byte ������ n byte��
			//	--���û����������ô�͵����п�
			//	3.remainder_head
			//	--�����ʼ�㲻��8�ı�������ô�ͱ�ǳ���
			//	3.remainder_tail
			//	--���һ�е�����������8�ı�������ô�ͱ�ǳ���
			//	-------------------------------------------------------------------------------------
			1	: begin
				flag_word_size	<= image_size_ch[roi_num];
				if(remainder_head|remainder_tail) begin
					line_word_size	<= roi_pic_width_active_format + {1'b1,{MCB_BYTE_NUM_WIDTH{1'b0}}};
				end
				else begin
					line_word_size	<= roi_pic_width_active_format;
				end
				remainder_head	<= image_addr[MCB_BYTE_NUM_WIDTH-1];
				remainder_tail	<= roi_pic_width_active_format[MCB_BYTE_NUM_WIDTH-1];
			end
			//	-------------------------------------------------------------------------------------
			//	chunk
			//	1.flag_word_size
			//	--��������ͨ�� payload_size - image_size �õ���
			//	2.remainder_head
			//	--��ʼ����Զ��8�ı���
			//	3.remainder_tail
			//	--chunk��С��Զ��8�ı���
			//	-------------------------------------------------------------------------------------
			2	: begin
				flag_word_size	<= chunk_size;
				remainder_head	<= 1'b0;
				remainder_tail	<= 1'b0;
			end
			//	-------------------------------------------------------------------------------------
			//	trailer
			//	1.flag_word_size
			//	--��chunk���صĳ����й�
			//	2.remainder_head
			//	--�����Զ��8�ı���
			//	3.remainder_tail
			//	--�ر�chunk��ʱ��trailer�Ĵ�С��32byte
			//	--��chunk��ʱ��trailer�Ĵ�С��36byte��������
			//	-------------------------------------------------------------------------------------
			3	: begin
				if(chunk_mode_active==1'b0) begin
					flag_word_size	<= EACH_TRAILER_SIZE_CEIL;
					remainder_head	<= 1'b0;
					remainder_tail	<= TRAILER_REMAINDER;
				end
				else begin
					flag_word_size	<= EACH_TRAILER_SIZE_CHUNK_CEIL;
					remainder_head	<= 1'b0;
					remainder_tail	<= TRAILER_CHUNK_REMAINDER;
				end
			end
			default	: begin
				flag_word_size	<= flag_word_size;
				remainder_head	<= 1'b0;
				remainder_tail	<= 1'b0;
			end
		endcase
	end

	//	===============================================================================================
	//	ref ***parse leader info***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	��leader�н��� roi num �� last roi ����Ϣ
	//
	//	<BYTE3><BYTE2><BYTE1><BYTE0><  RESERVED  ><  PADDING_X >
	//
	//	BYTE0	: bit[7:0]	roi_num
	//	BYTE1	: bit[0] 	last_roi
	//			: bit[7:1]	reserved
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//		if(flag_num_cnt==0 && word_cnt_flag==flag_word_size[WORD_CNT_FLAG_WIDTH+MCB_BYTE_NUM_WIDTH-1:MCB_BYTE_NUM_WIDTH]-1 && mcb_rd_en==1'b1) begin
		//		if(flag_num_cnt==0 && word_cnt_flag[LEADER_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH-1:0]==flag_word_size[LEADER_ADDR_WIDTH-1:MCB_BYTE_NUM_WIDTH] && mcb_rd_en==1'b1) begin
		if(flag_num_cnt==0 && flag_done==1'b1) begin
			roi_num		<= iv_rd_data[GPIF_DATA_WD+ROI_CNT_WIDTH-1:GPIF_DATA_WD];
			last_roi	<= iv_rd_data[GPIF_DATA_WD+8];
		end
	end

	//	===============================================================================================
	//	ref ***fsm flag***
	//	FSM ��ת��Ҫ�ı�־λ
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	burst_done �������Ƿ�����һ��burst
	//	word cnt ��0��ʼ��������һ����д��һ��
	//	-------------------------------------------------------------------------------------
	assign	burst_done		= (word_cnt==(BURST_SIZE-1) && mcb_rd_en==1'b1) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	line_done �������Ƿ�����һ��
	//	1.�������һ�����ݵ�ʱ�򣬾�Ҫ����
	//	2.����һ��burst�ĳ����ǹ̶��ģ���˶��������������ܻᳬ��һ�еĳ���
	//	-------------------------------------------------------------------------------------
	assign	line_done	= (word_cnt_line==line_word_size[WORD_CNT_LINE_WIDTH+MCB_BYTE_NUM_WIDTH-1:MCB_BYTE_NUM_WIDTH] && mcb_rd_en==1'b1) ? 1'b1 : 1'b0;

	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	�� word_cnt_line �����ʱ��line_done_reg Ҳ����
		//	-------------------------------------------------------------------------------------
		if(current_state==S_IDLE || (current_state==S_LINE && pipe_cnt==1'b1)) begin
			line_done_reg	<= 1'b0;
		end
		//	-------------------------------------------------------------------------------------
		//	��line_done=1��ʱ������
		//	-------------------------------------------------------------------------------------
		else if(line_done==1'b1) begin
			line_done_reg	<= 1'b1;
		end
	end
	assign	line_done_int	= line_done | line_done_reg;

	//	-------------------------------------------------------------------------------------
	//	flag_done �������Ƿ�����һ��flag
	//	1.�������һ�����ݵ�ʱ�򣬾�Ҫ����
	//	2.����һ��burst�ĳ����ǹ̶��ģ���˶��������������ܻᳬ��һ��flag�ĳ���
	//	-------------------------------------------------------------------------------------
	assign	flag_done	= (word_cnt_flag==flag_word_size[WORD_CNT_FLAG_WIDTH+MCB_BYTE_NUM_WIDTH-1:MCB_BYTE_NUM_WIDTH] && mcb_rd_en==1'b1) ? 1'b1 : 1'b0;

	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	�� word_cnt_flag ��λ��ʱ��ͬʱ ���� flag_done_reg
		//	-------------------------------------------------------------------------------------
		if(current_state==S_IDLE || (current_state==S_FLAG && pipe_cnt==1'b1)) begin
			flag_done_reg	<= 1'b0;
		end
		else if(flag_done==1'b1) begin
			flag_done_reg	<= 1'b1;
		end
	end
	assign	flag_done_int	= flag_done | flag_done_reg;


	assign	line_equal		= (roi_pic_width_ch[roi_num]==roi_pic_width_global) ? 1'b1 : 1'b0;
	assign	last_flag		= (flag_num_cnt==RD_FLAG_NUM) ? 1'b1 : 1'b0;


	assign	dummy_head		= (remainder_head==1'b1 && word_cnt_line==1) ? 1'b1 : 1'b0;
	assign	dummy_tail		= (remainder_tail==1'b1 && (line_done==1'b1 || flag_done==1'b1)) ? 1'b1 : 1'b0;
	//	assign	dummy_tail		= (remainder_tail==1'b1 && (line_done_int==1'b1 || flag_done_int==1'b1)) ? 1'b1 : 1'b0;

	reg		[WR_ADDR_WIDTH-1:0]			wr_addr_sub ='b0;

	always @ (posedge clk) begin
		if(iv_wr_addr==0) begin
			wr_addr_sub	<= 0;
		end
		else begin
			wr_addr_sub	<= iv_wr_addr - 1'b1;
		end
	end


	//	-------------------------------------------------------------------------------------
	//	���Զ�������
	//	able_to_read�� a.��CMD��ת��RD��������Ҳ�� b.��CMD״̬�������������
	//	-------------------------------------------------------------------------------------
	always @ ( * ) begin
		//	-------------------------------------------------------------------------------------
		//	�� rd cmd fifo ������ʱ�򣬲����ж��Ƿ������һ��״̬������ͣ����CMD״̬
		//	-------------------------------------------------------------------------------------
		if(i_rd_cmd_full==1'b0) begin
			//	-------------------------------------------------------------------------------------
			//	�����дָ����ȣ��Ҵ�ʱ����д����ô����ַҪС��д��ַ��mcb wr cmd fifo�ǿյ�
			//	-------------------------------------------------------------------------------------
//			if(rd_ptr==iv_wr_ptr && i_writing==1'b1 && rd_addr<{{iv_wr_addr-1},{(RD_ADDR_WIDTH-WR_ADDR_WIDTH){1'b0}}} && i_wr_cmd_empty==1'b1) begin
//			if(rd_ptr==iv_wr_ptr && i_writing==1'b1 && rd_addr<{iv_wr_addr,{(RD_ADDR_WIDTH-WR_ADDR_WIDTH){1'b0}}} && i_wr_cmd_empty==1'b1) begin
			if(rd_ptr==iv_wr_ptr && i_writing==1'b1 && rd_addr<{wr_addr_sub,{(RD_ADDR_WIDTH-WR_ADDR_WIDTH){1'b0}}} && i_wr_cmd_empty==1'b1) begin
				able_to_read	<= 1'b1;
			end
			//	-------------------------------------------------------------------------------------
			//	�����дָ����ȣ��Ҵ�ʱ����д
			//	-------------------------------------------------------------------------------------
			else if(rd_ptr==iv_wr_ptr && i_writing==1'b0) begin
				able_to_read	<= 1'b1;
			end
			//	-------------------------------------------------------------------------------------
			//	�����дָ�벻���
			//	-------------------------------------------------------------------------------------
			else if(rd_ptr!=iv_wr_ptr) begin
				able_to_read	<= 1'b1;
			end
			//	-------------------------------------------------------------------------------------
			//	���򣬼���ͣ����CMD״̬
			//	-------------------------------------------------------------------------------------
			else begin
				able_to_read	<= 1'b0;
			end
		end
		else begin
			able_to_read	<= 1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	pipe_cnt
	//	1.LINE FLAG ROI ������״̬�У�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_LINE || current_state==S_FLAG || current_state==S_ROI) begin
			pipe_cnt	<= !pipe_cnt;
		end
		else begin
			pipe_cnt	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  ��֡�����߼��У���ǰ֡�Ƿ���Ч�źš�
	//	1.��ʹ�ܹر� fresh_frame����
	//	2.����ʱ����writing������ʱ��fresh_frame=1����ʾ�����ݿɶ�
	//	3.����ʱ����reading������ʱ��fresh_frame=0����ʾ�Ѿ���ȡ��ǰ֡
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_stream_enable==1'b0) begin
			fresh_frame	<= 1'b0;
		end
		else begin
			if(writing_rise==1'b1) begin
				fresh_frame	<= 1'b1;
			end
			else if(reading_rise==1'b1) begin
				fresh_frame	<= 1'b0;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//  ���ڶ�
	//	1.������idle״̬ʱ�����ڶ��ź�����
	//	2.������ PTR ״̬�� wr_ptr_change=0��ʱ�򣬲��ܱ�Ϊ1������Ҫ�� rd_ptr һ��ı��ԭ��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			reading_reg	<= 1'b0;
		end
		else if(current_state==S_PTR && i_wr_ptr_changing==1'b0) begin
			//	-------------------------------------------------------------------------------------
			//	����֡��ʱ�����дˢ�¹�������Զ������򣬷���idle״̬��
			//	-------------------------------------------------------------------------------------
			if(iv_frame_depth==1'b1) begin
				if(fresh_frame==1'b1) begin
					reading_reg	<= 1'b1;
				end
				else begin
					reading_reg	<= 1'b0;
				end
			end
			//	-------------------------------------------------------------------------------------
			//	����֡��ʱ�������ָ��!=дָ�룬˵�����µ����ݣ���ô�����Խ���д
			//	-------------------------------------------------------------------------------------
			else if(rd_ptr!=iv_wr_ptr) begin
				reading_reg	<= 1'b1;
			end
			//	-------------------------------------------------------------------------------------
			//	����֡��ʱ�򣬶�ָ��=дָ�룬˵������û��ˢ�¹�������idle״̬
			//	-------------------------------------------------------------------------------------
			else begin
				reading_reg	<= 1'b0;
			end
		end
	end
	assign	o_reading	= reading_reg;

	//	-------------------------------------------------------------------------------------
	//	ptr_move ��ָ������ƶ����ź�
	//	����֡��ʱ�����дˢ�¹�������Զ������򣬷���idle״̬��
	//	����֡��ʱ�������ָ��!=дָ�룬˵�����µ����ݣ���ô�����Խ���д
	//	-------------------------------------------------------------------------------------
	assign	ptr_move	= (iv_frame_depth==1 && fresh_frame==1'b1) ? 1'b1 : ((iv_frame_depth!=1 && rd_ptr!=iv_wr_ptr) ? 1'b1 : 1'b0);

	//	===============================================================================================
	//	ref ***FSM***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	FSM Sequential Logic
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			current_state	<= S_IDLE;
		end
		else begin
			current_state	<= next_state;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	FSM Conbinatial Logic
	//	-------------------------------------------------------------------------------------
	always @ ( * ) begin
		case(current_state)
			S_IDLE	:
			//	-------------------------------------------------------------------------------------
			//	IDLE -> PTR
			//	1.������Ч 2.У׼���
			//	3.ָ������ƶ��źţ��������ź�֮����֡�����ڼ䣬״̬����һֱͣ����idle״̬�������� idle ptr ����״̬֮�以����Ծ
			//	��idleʱ����Ҫ�жϺ��fifo��״̬���ڶ�mcb rd fifo��ʱ���жϺ��fifo��״̬
			//	-------------------------------------------------------------------------------------
			if(i_stream_enable==1'b1 && calib_done_shift[1]==1'b1 && ptr_move==1'b1) begin
				next_state	= S_PTR;
			end
			else begin
				next_state	= S_IDLE;
			end
			S_PTR	:
			//	-------------------------------------------------------------------------------------
			//	ֻ���� wr_ptr_change=1 ��ʱ�򣬲��ܹ��л���ָ�롣������PTR״̬�ȴ���
			//	wr_ptr_change�źŵĿ����2��ʱ�����ڣ�������ȴ�2��ʱ������
			//	��������Ŀ���Ƿ�ֹ��дָ��ͬʱ�仯
			//	-------------------------------------------------------------------------------------
			if(i_wr_ptr_changing==1'b0) begin
				if(ptr_move==1'b1) begin
					next_state	= S_CMD;
				end
				else begin
					next_state	= S_IDLE;
				end
			end
			else begin
				next_state	= S_PTR;
			end
			S_CMD	:
			//	-------------------------------------------------------------------------------------
			//	CMD -> RD
			//	1.�� rd cmd fifo ������ʱ�򣬲����ж��Ƿ������һ��״̬������ͣ����CMD״̬
			//	2.��дָ����ȣ��Ҵ�ʱ����д����ô����ַҪС��д��ַ��mcb wr cmd fifo�ǿյ�
			//	3.��дָ����ȣ��Ҵ�ʱ����д
			//	4.��дָ�벻���
			//	-------------------------------------------------------------------------------------
			if(able_to_read==1'b1) begin
				next_state	= S_RD;
			end
			else begin
				next_state	= S_CMD;
			end
			S_RD	:
			//	-------------------------------------------------------------------------------------
			//	RD -> IDLE
			//	1.����������һ��burst
			//	2.ͣ��
			//	-------------------------------------------------------------------------------------
			if(i_stream_enable==1'b0 && burst_done==1'b1) begin
				next_state	= S_IDLE;
			end
			//	-------------------------------------------------------------------------------------
			//	RD -> LINE
			//	1.����������һ��burst
			//	2.�� image flag �׶�
			//	3.����һ�е�������
			//	4.����
			//	-------------------------------------------------------------------------------------
			else if(i_stream_enable==1'b1 && flag_num_cnt==1 && burst_done==1'b1 && line_done_int==1'b1) begin
				next_state	= S_LINE;
			end
			//	-------------------------------------------------------------------------------------
			//	RD -> FLAG (���roi���п���sensor������п���ȣ���û�б�Ҫ���У���һ��flag����֮�󣬽���flag״̬)
			//	1.����������һ��burst
			//	2.�� image flag �׶�
			//	3.����һ��flag��������
			//	4.��ǰROI���п������п����
			//	5.����
			//	-------------------------------------------------------------------------------------
			else if(i_stream_enable==1'b1 && flag_num_cnt==1 && burst_done==1'b1 && flag_done_int==1'b1 && line_equal==1'b1) begin
				next_state	= S_FLAG;
			end
			//	-------------------------------------------------------------------------------------
			//	RD -> FLAG (��ͼ��׶Σ��ǲ�����뵽line״̬��)
			//	1.����������һ��burst
			//	2.���� image flag �׶�
			//	3.����һ��flag��������
			//	5.����
			//	-------------------------------------------------------------------------------------
			else if(i_stream_enable==1'b1 && flag_num_cnt!=1 && burst_done==1'b1 && flag_done_int==1'b1) begin
				next_state	= S_FLAG;
			end
			//	-------------------------------------------------------------------------------------
			//	RD -> CMD
			//	1.����������һ��burst
			//	2.������һ�е�������
			//	4.����
			//	-------------------------------------------------------------------------------------
			else if(i_stream_enable==1'b1 && burst_done==1'b1 && line_done_int==1'b0) begin
				next_state	= S_CMD;
			end
			//	-------------------------------------------------------------------------------------
			//	����������ͣ����RD״̬
			//	-------------------------------------------------------------------------------------
			else begin
				next_state	= S_RD;
			end
			S_LINE	:
			//	-------------------------------------------------------------------------------------
			//	LINE -> CMD
			//	1.������һ��flag��������
			//	-------------------------------------------------------------------------------------
			if(flag_done_int==1'b0 && pipe_cnt==1'b1) begin
				next_state	= S_CMD;
			end
			//	-------------------------------------------------------------------------------------
			//	LINE -> FLAG
			//	1.����һ��flag��������
			//	-------------------------------------------------------------------------------------
			else if(flag_done_int==1'b1 && pipe_cnt==1'b1) begin
				next_state	= S_FLAG;
			end
			else begin
				next_state	= S_LINE;
			end
			S_FLAG	:
			//	-------------------------------------------------------------------------------------
			//	FLAG -> CMD
			//	1.��ǰflag�������һ��flag
			//	-------------------------------------------------------------------------------------
			if(last_flag==1'b0 && pipe_cnt==1'b1) begin
				next_state	= S_CMD;
			end
			//	-------------------------------------------------------------------------------------
			//	FLAG -> IDLE
			//	1.��ǰflag�����һ��flag
			//	-------------------------------------------------------------------------------------
			else if(last_flag==1'b1 && pipe_cnt==1'b1) begin
				next_state	= S_ROI;
			end
			else begin
				next_state	= S_FLAG;
			end
			S_ROI	:
			//	-------------------------------------------------------------------------------------
			//	ROI -> CMD
			//	1.��ǰROI�������һ��ROI
			//	-------------------------------------------------------------------------------------
			if(last_roi==1'b0 && pipe_cnt==1'b1) begin
				next_state	= S_CMD;
			end
			//	-------------------------------------------------------------------------------------
			//	FLAG -> IDLE
			//	1.��ǰROI�����һ��ROI
			//	-------------------------------------------------------------------------------------
			else if(last_roi==1'b1 && pipe_cnt==1'b1) begin
				next_state	= S_IDLE;
			end
			else begin
				next_state	= S_ROI;
			end
			default	:
			next_state	= S_IDLE;
		endcase
	end


endmodule
