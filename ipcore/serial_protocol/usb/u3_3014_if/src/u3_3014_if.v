//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : u3_3014_if
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/4/9 11:00:36	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : U3оƬ cy3014 �ӿ�ģ�顣��u3vЭ�����ϡ�
//              1)  : �� leader payload trailer ����鴫�䡣ÿһ���Ϊһ�� sector
//
//              2)  : ��һ��sector����ʱ�����һ������Ҫ���� pktend
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module u3_3014_if # (
	parameter				DATA_WIDTH			= 32		,	//GPIF���ݿ�ȣ�Ŀǰ�̶�Ϊ32
	parameter				REG_WIDTH			= 32		,	//�Ĵ���λ��
	parameter				FRAME_SIZE_WIDTH	= 22		,	//һ֡��Сλ����λ��DATA_WIDTH����DATA_WIDTH=32ʱ��FRAME_SIZE_WIDTH=22 -> 16Mbyte.23 -> 32Mbyte.24 -> 64Mbyte.
	parameter				DMA_SIZE			= 14'h1000		//DMA SIZE��С.DATA_WIDTH*DMA_SIZE=3014 DMA SIZE
	)
	(
	//	-------------------------------------------------------------------------------------
	//  ʱ�Ӹ�λ�ź�
	//	-------------------------------------------------------------------------------------
	input								clk					,	//ʱ��
	input								reset				,	//��λ
	//	-------------------------------------------------------------------------------------
	//  ��ǰ�����ݽӿ�
	//	-------------------------------------------------------------------------------------
	input	[DATA_WIDTH:0]				iv_data				,	//֡����������ݣ����bitΪ����λ
	input								i_buf_empty			,	//FIFO�ձ�־���ߵ�ƽ��Ч
	output								o_buf_rd			,	//FIFO���źţ��ߵ�ƽ��Ч
	//	-------------------------------------------------------------------------------------
	//	���Ʋ���
	//	-------------------------------------------------------------------------------------
	input								i_stream_enable		,	//��ʹ���źţ�����Ч
	input	[REG_WIDTH-1:0]				iv_payload_size		,	//paylod��С,�ֽ�Ϊ��λ
	input								i_chunk_mode_active	,	//chunk�ܿ��أ�chunk����Ӱ��leader��trailer�Ĵ�С��ͨ���ж�chunk���ؿ���֪��leader��trailer����
	input	[REG_WIDTH-1:0]				iv_transfer_count	,	//�������ݿ����
	input	[REG_WIDTH-1:0]				iv_transfer_size	,	//�������ݿ��С
	input	[REG_WIDTH-1:0]				iv_transfer1_size	,	//transfer1��С
	input	[REG_WIDTH-1:0]				iv_transfer2_size	,	//transfer2��С
	//	-------------------------------------------------------------------------------------
	//	GPIF�ӿ��ź�
	//	-------------------------------------------------------------------------------------
	input								i_usb_flagb_n		,	//�첽ʱ����USB���źţ�����Ч����ʱ3��ʱ����Ч���л�DMA��ַ���־ָʾ��ǰDMA״̬�������ǰDMA��û������FLAGB�����ߣ����PC��������ǰFIFO��û�ж������ñ�־���ܳ�ʱ������
	output	[1:0]						ov_usb_addr			,	//GPIF �̵߳�ַ 2bit����ַ�л�˳��Ҫ�͹̼�����һ�£�ĿǰԼ��Ϊ2'b00,2'b11�л�
	output								o_usb_slwr_n		,	//GPIF д�źţ�����Ч
	output	[DATA_WIDTH-1:0]			ov_usb_data			,	//GPIF �����ź�
	output								o_usb_pktend_n			//GPIF �������źţ�����Ч��pktend��slwrͬʱ��Ч����ʾ��������
	);

	//	ref signals
	//FSM Parameter Define
	parameter	S_IDLE			= 3'd0;
	parameter	S_CHK_HEADER	= 3'd1;
	parameter	S_DMA_SENDING	= 3'd2;
	parameter	S_CHK_FLAG		= 3'd3;
	parameter	S_SECTOR_OVER	= 3'd4;
	parameter	S_ADD_PKTEND	= 3'd5;

	reg		[2:0]	current_state	= S_IDLE;
	reg		[2:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	reg		[127:0]			state_ascii;
	always @ ( * ) begin
		case(current_state)
			3'd0 :	state_ascii	<= "S_IDLE";
			3'd1 :	state_ascii	<= "S_CHK_HEADER";
			3'd2 :	state_ascii	<= "S_DMA_SENDING";
			3'd3 :	state_ascii	<= "S_CHK_FLAG";
			3'd4 :	state_ascii	<= "S_SECTOR_OVER";
			3'd5 :	state_ascii	<= "S_ADD_PKTEND";
		endcase
	end
	// synthesis translate_on

	reg		[2:0]						flagb_shift		= 3'b000;
	wire								flagb_rise		;
	wire								flagb_fall		;
	reg		[2:0]						se_shift		= 3'b0;
	
	wire								mult_en				;
	wire	[47:0]						wv_pc_buffer_size	;
	reg									urb_is_larger		= 1'b0;
	wire	[FRAME_SIZE_WIDTH-1:0]		require_size	;

	wire								buf_rd_header	;
	wire								buf_rd_dma		;
	wire								buf_rd_pktend	;

	reg		[13:0]						dma_cnt			= 14'b0;
	reg		[REG_WIDTH-3:0]				sector_size_cnt	= {(REG_WIDTH-2){1'b0}};
	reg		[REG_WIDTH-1:0]				sector_size_reg	= {REG_WIDTH{1'b0}};
	reg		[1:0]						sector_cnt		= 2'b0;

	wire								gpif_wr_n			;
	wire								gpif_pktend_n		;
	wire	[DATA_WIDTH-1:0]			gpif_data			;
	reg		[1:0]						gpif_addr			= 2'b0;
	reg									gpif_wr_n_reg		= 1'b1;
	reg									gpif_pktend_n_reg	= 1'b1;
	reg		[DATA_WIDTH-1:0]			gpif_data_reg		= {DATA_WIDTH{1'b0}};
	reg		[1:0]						gpif_addr_reg		= 2'b0;

	//	ref ARCHITECTURE



	//	===============================================================================================
	//	ref ***��ʱ ȡ����***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	flagb ��ʱ
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		flagb_shift	<= {flagb_shift[1:0],i_usb_flagb_n};
	end
	assign	flagb_rise	= (flagb_shift[2:1]==2'b01) ? 1'b1 : 1'b0;
	assign	flagb_fall	= (flagb_shift[2:1]==2'b10) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	i_stream_enable ��ʱ
	//	1.����֮��frame buffer��˻Ḵλ���ȴ����fifo���ڸ�λ֮�У�������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		se_shift	<= {se_shift[1:0],i_stream_enable};
	end

	//	===============================================================================================
	//	ref ***�ж�urb��payload_size***
	//  ����PC URB��С��iv_transfer_size*iv_transfer_count
	//  �Ĵ���λ����������������֧�ֵ�ͼ���С������16MB,����require_size_cnt 24bits�㹻
	//  �˷���ֻ������ͣ���ڼ���㣬��ʼ�ɼ����豣�ֲ��䣬����ʹ��resetȡ����ʱ��ʹ�ܣ���ˮ����ʱ5clk
	//  ����PC URB��С��Ҫ�������ж��Ƿ���Ӷ̰�
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  �����˷���
	//  -------------------------------------------------------------------------------------
	urb_mult_a32b16 urb_mult_a32b16_inst(
	.clk	(clk						),
	.ce		(mult_en					),
	.a		(iv_transfer_size			),
	.b		(iv_transfer_count[15:0]	),
	.p		(wv_pc_buffer_size			)
	);
	assign	mult_en  = ~i_stream_enable;

	//	-------------------------------------------------------------------------------------
	//	����urb��Ƚ�
	//	-------------------------------------------------------------------------------------
	assign	require_size = wv_pc_buffer_size[FRAME_SIZE_WIDTH-1:0];
	always @ (posedge clk) begin
		if(reset==1'b1 || i_stream_enable==1'b0) begin
			urb_is_larger	<= 1'b0;
		end
		else begin
			if(require_size>iv_payload_size[FRAME_SIZE_WIDTH-1:0 ]) begin
				urb_is_larger	<= 1'b1;
			end
			else begin
				urb_is_larger	<= 1'b0;
			end
		end
	end

	//	===============================================================================================
	//	ref ***ǰ��FIFO������***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	fifo ��
	//	1.��chk header״̬����ǰ��fifo���ա��������bit=0ʱ�����ܶ���
	//	2.��dma sending״̬����ǰ��fifo���ղ��ܶ���
	//	3.��sector over״̬����ǰ��fifo���ղ��ܶ���
	//	-------------------------------------------------------------------------------------
	assign	buf_rd_header	= (current_state==S_CHK_HEADER && i_buf_empty==1'b0 && iv_data[DATA_WIDTH]==1'b0) ? 1'b1 : 1'b0;
	assign	buf_rd_dma		= (current_state==S_DMA_SENDING && i_buf_empty==1'b0) ? 1'b1 : 1'b0;
	assign	buf_rd_pktend	= (current_state==S_SECTOR_OVER && i_buf_empty==1'b0) ? 1'b1 : 1'b0;

	assign	o_buf_rd		= buf_rd_header | buf_rd_dma | buf_rd_pktend;

	//	===============================================================================================
	//	ref ***GPIF ����***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	��add pktend״̬��Ҫ�����������źţ�ͬʱҲҪ����д�ź�
	//	-------------------------------------------------------------------------------------
	assign	gpif_wr_add	= (current_state==S_ADD_PKTEND) ? 1'b1 : 1'b0;
	//	-------------------------------------------------------------------------------------
	//	GPIF wr
	//	1.����dma���ݺ�д��������ʱ��д�ź���Ч
	//	-------------------------------------------------------------------------------------
	assign	gpif_wr_n	= (buf_rd_dma==1'b1 || buf_rd_pktend==1'b1 || gpif_wr_add==1'b1) ? 1'b0 : 1'b1;
	//	-------------------------------------------------------------------------------------
	//	GPIF pktend
	//	1.ֻ�ڷ��Ͱ�������ʱ��pktend��Ч
	//	-------------------------------------------------------------------------------------
	assign	gpif_pktend_n	= (buf_rd_pktend==1'b1 || gpif_wr_add==1'b1) ? 1'b0 : 1'b1;
	//	-------------------------------------------------------------------------------------
	//	GPIF data
	//	1.�������λ��Ҫ
	//	-------------------------------------------------------------------------------------
	assign	gpif_data	= iv_data[DATA_WIDTH-1:0];

	//	-------------------------------------------------------------------------------------
	//	GPIF addr
	//	1.ֻ����ֹͣ��ʱ�򣬲ŻḴλ��ַ��idle��ʱ�򲻸�λ
	//	2.һ��dma�����ˣ����߰����������ˣ���Ҫ�л���ַ����flagb�½���ʱ���л���ַ
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_stream_enable) begin
			gpif_addr	<= 2'b0;
		end
		else if(current_state==S_CHK_FLAG && flagb_fall==1'b1) begin
			gpif_addr	<= ~gpif_addr;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	���ݡ�ʹ�ܡ���ַ����
	//	1.����ź�Ҫ�ŵ�iob���ٴ�һ�ģ��ڱ�ģ�������������
	//	2.�˴��Ĵ�����Ϊ���������ݺ�iob֮��ľ���
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		gpif_wr_n_reg		<= gpif_wr_n;
		gpif_pktend_n_reg	<= gpif_pktend_n;
		gpif_data_reg		<= gpif_data;
		gpif_addr_reg		<= gpif_addr;
	end
	assign	o_usb_slwr_n	= gpif_wr_n_reg;
	assign	o_usb_pktend_n	= gpif_pktend_n_reg;
	assign	ov_usb_data		= gpif_data_reg;
	assign	ov_usb_addr		= gpif_addr_reg;

	//	===============================================================================================
	//	ref ***��Ҫ������***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	dma��С������
	//	1.�ڿ���״̬�ͽ���dma sending֮ǰ����������
	//	2.��dma sending״̬��ÿ��һ�Σ�������+1
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE || current_state==S_CHK_FLAG) begin
			dma_cnt	<= 14'b0;
		end
		else if(buf_rd_dma==1'b1 || buf_rd_pktend==1'b1) begin
			dma_cnt	<= dma_cnt + 1'b1;
		end
	end

	//	===============================================================================================
	//	ref ***�л�sector***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	sector������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			sector_cnt	<= 2'b00;
		end
		else if(current_state==S_SECTOR_OVER && i_buf_empty==1'b0) begin
			sector_cnt	<= sector_cnt + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	sector_size_reg,���ֽ�Ϊ��λ
	//	1.sector_cnt==2'b00 - leader ״̬��52���ֽ�
	//	2.sector_cnt==2'b01 - payload ״̬���Ĵ�������
	//	3.sector_cnt==2'b10 - trailer ״̬��chunk��-36�ֽڣ�chunk�ر�-32�ֽ�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(sector_cnt==2'b00) begin
			sector_size_reg	<= 52;
		end
		else if(sector_cnt==2'b01) begin
			sector_size_reg	<= iv_payload_size;
		end
		else begin
			if(i_chunk_mode_active) begin
				sector_size_reg	<= 36;
			end
			else begin
				sector_size_reg	<= 32;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	sector��С����������DATA_WIDTHΪ��λ
	//	1.������״̬��sector����״̬������������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE || current_state==S_SECTOR_OVER) begin
			sector_size_cnt	<= {(REG_WIDTH-2){1'b0}};
		end
		else if(buf_rd_dma) begin
			sector_size_cnt	<= sector_size_cnt + 1'b1;
		end
	end

	//	===============================================================================================
	//	ref ***FSM***
	//	===============================================================================================
	//FSM Sequential Logic
	//	-------------------------------------------------------------------------------------
	//	1.����λ�ź�=1������ʹ��ֹͣ��״̬����������idle��
	//	2.����ֹͣʱ��3014Ҳ�Ḵλ����ˣ�״̬��������������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset==1'b1 || se_shift[2]==1'b0) begin
			current_state	<= S_IDLE;
		end else begin
			current_state	<= next_state;
		end
	end

	//FSM Conbinatial Logic
	always @ ( * ) begin
		case(current_state)
			//	-------------------------------------------------------------------------------------
			//	����״̬
			//	1.�����ʹ�ܴ򿪣�ǰ�˷ǿյĻ����Ϳ��Խ�����һ״̬
			//	2.��������㣬������ȴ�
			//	-------------------------------------------------------------------------------------
			S_IDLE	:
			if(se_shift[2]==1'b1 && i_buf_empty==1'b0) begin
				next_state	= S_CHK_HEADER;
			end
			else begin
				next_state	= S_IDLE;
			end
			//	-------------------------------------------------------------------------------------
			//	���ͼ��ͷ
			//	1.��һ֡ͼ��ʼ��ʱ�򣬻���ͼ��ͷ��ͼ��β��Ҫ��ͷβ����
			//	2.�����bit��0��buf����ʱ��˵�������Ѿ�����ͷβ�ˣ����Խ�����һ��״̬
			//	3.���򣬼����ȴ�
			//	-------------------------------------------------------------------------------------
			S_CHK_HEADER	:
			if(iv_data[DATA_WIDTH]==1'b1 && i_buf_empty==1'b0) begin
				next_state	= S_DMA_SENDING;
			end
			else begin
				next_state	= S_CHK_HEADER;
			end
			//	-------------------------------------------------------------------------------------
			//	DMA����
			//	1.�����͵���������3014��DMA SIZEһ��ʱ����� flagb ��������
			//	2.�����͵�����������3014��DMA SIZE��������sector sizeʱ��˵��sector����
			//	3.������ͣ��DMA_SENDING״̬
			//	-------------------------------------------------------------------------------------
			S_DMA_SENDING	:
			if(dma_cnt==DMA_SIZE-1 && buf_rd_dma==1'b1) begin
				next_state	= S_CHK_FLAG;
			end
			else if(sector_size_cnt==(sector_size_reg[REG_WIDTH-1:2]-2) && buf_rd_dma==1'b1) begin
				next_state	= S_SECTOR_OVER;
			end
			else begin
				next_state	= S_DMA_SENDING;
			end
			//	-------------------------------------------------------------------------------------
			//	���flagb״̬
			//	1.��flagb�����أ�˵��socket ��ַ�л��ɹ�
			//	--���sector_cnt==2'b11˵�������1��sector���ͳɹ�������idle
			//	--������ǣ�����DMA ����״̬
			//	2.���򣬼����ȴ�
			//	-------------------------------------------------------------------------------------
			S_CHK_FLAG	:
			if(flagb_rise) begin
				if(sector_cnt==2'b11) begin
					next_state	= S_IDLE;
				end
				else begin
					next_state	= S_DMA_SENDING;
				end
			end
			else begin
				next_state	= S_CHK_FLAG;
			end
			//	-------------------------------------------------------------------------------------
			//	sector ������
			//	1.�ڱ�״̬�ᷢ��һ��pktend�����Ҫ���ǰ�˵�fifo״̬�����յ�ʱ�򣬲ſ��Է���.
			//	2.��� sector_cnt==2'b01 ˵����payload
			//	--2.1���sector��С����Kbyte����
			//	----���pc��urb size ����payload size��˵��pc buffer ���ıȽϴ���Kbyte�޷�������Ҫ�ٷ�һ���̰�
			//	----���pc��urb������payload size�������sector���ͳɹ������淵��DMA ����״̬
			//	--2.2���sector��С������Kbyte�����������sector���ͳɹ������淵��DMA ����״̬
			//	3.���������sector��������������ź�֮��Ҫ�ж�flagb��״̬
			//	-------------------------------------------------------------------------------------
			S_SECTOR_OVER	:
			if(!i_buf_empty) begin
				if(sector_cnt==2'b01) begin
					if(sector_size_reg[9:2]==8'h00) begin
						if(urb_is_larger==1'b1) begin
							next_state	= S_ADD_PKTEND;
						end
						else begin
							next_state	= S_CHK_FLAG;
						end
					end
					else begin
						next_state	= S_CHK_FLAG;
					end
				end
				else begin
					next_state	= S_CHK_FLAG;
				end
			end
			else begin
				next_state	= S_SECTOR_OVER;
			end
			//	-------------------------------------------------------------------------------------
			//	��ӵİ�����
			//	1.��pc buffer������urb����payload size����payloadsize����k����ʱ���޷�����pc��buffer����Ҫ�ٷ�һ��4�ֽڵĶ̰���pc
			//	2.����̰�֮�󣬷���DMA ����״̬����������
			//	-------------------------------------------------------------------------------------
			S_ADD_PKTEND	:
			next_state	= S_CHK_FLAG;
			default	:
			next_state	= S_IDLE;
		endcase
	end


endmodule
