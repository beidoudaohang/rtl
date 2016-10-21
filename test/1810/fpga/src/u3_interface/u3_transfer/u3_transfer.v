//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : u3_transfer
//  -- �����       : ��ǿ
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- ��ǿ         :| 2014/11/28 17:40:36	:|  ���ݼ���Ԥ������
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module u3_transfer # (
	parameter						DATA_WD      		=32		,	//GPIF���ݿ��
	parameter						REG_WD 				=32		,	//�Ĵ���λ��
	parameter						PACKET_SIZE_WD		=23		,	//ͼ���Сλ��,��λ4�ֽ�,֧�ֵ����32MBͼ��
	parameter						DMA_SIZE			=14'H2000	//DMA SIZE��С'h2000-1
	)
	(
	//  ===============================================================================================
	//  ��һ���֣�ʱ�Ӹ�λ�ź�
	//  ===============================================================================================

	input							clk							,	//u3�ӿں�framebuffer���ʱ��
	input							reset						,	//��λ�źţ�clk_usb_pclkʱ���򣬸���Ч
	//  ===============================================================================================
	//  �ڶ����֣������������ź�
	//  ===============================================================================================
	output							o_fifo_rd					,	//��ȡ֡����FIFO�źţ�clk_gpifʱ����,��i_data_valid�źŹ�ָͬʾ������Ч��framebuffer��ģ���ʹ�ܣ�����Ч
	input							i_data_valid				,	//֡���������������Ч�źţ�clk_usb_pclkʱ���򣬸���Ч
	input		[DATA_WD-1		:0]	iv_data						,	//֡�������32λ���ݣ�clk_usb_pclkʱ����
	input							i_framebuffer_empty			,	//framebuffer���FIFO�ձ�־���ߵ�ƽ��Ч��clk_gpifʱ����,֡��ͼ���ۼƺ�֡��տ��ܲ������
	input							i_leader_flag				,	//leader����־,clk_usb_pclkʱ����
	input							i_trailer_flag				,	//trailer����־,clk_usb_pclkʱ����
	input							i_payload_flag				,	//payload����־,clk_usb_pclkʱ����
	input							i_chunkmodeactive			,	//clkʱ�����źţ�chunk�ܿ��أ�������Чʱ�����ƣ�chunk����Ӱ��leader��trailer�Ĵ�С��ͨ���ж�chunk���ؿ���֪��leader��trailer����
	output	reg						o_change_flag				,	//leader��payload��trailer���л���־��ÿ����������ɺ��л�,�����ڿ��
	//  ===============================================================================================
	//  �������֣����ƼĴ���
	//  ===============================================================================================

	input		[REG_WD-1		 :0]iv_packet_size				,	//��ǰ����Ӧ����������С�����ڶ���framebuffer�е����ݰ���leader+payload+trailer���̼���Ϊ64λ��FPGA�ڲ�ֻʹ�õ�32λ
	input		[REG_WD-1		 :0]iv_transfer_count			,	//�������ݿ����
	input		[REG_WD-1		 :0]iv_transfer_size			,	//�������ݿ��С
	input		[REG_WD-1		 :0]iv_transfer1_size			,   //transfer1��С
	input		[REG_WD-1		 :0]iv_transfer2_size			,   //transfer2��С
	//  ===============================================================================================
	//  ���Ĳ��֣�GPIF�ӿ��ź�
	//  ===============================================================================================
	input							i_usb_flagb					,	//USB���źţ�������32k�ֽ����ݺ�3��ʱ�ӻ����ͣ��л�DMA��ַ���־ָʾ��ǰFIFO״̬�������ǰFIFO��û������FLAGB�����ߣ����PC��������ǰFIFO��û�ж������ñ�־���ܳ�ʱ������
	output		[1				 :0]ov_usb_fifoaddr				,	//GPIF �̵߳�ַ 2bit����ַ�л�˳��Ҫ�͹̼�����һ�£�ĿǰԼ��Ϊ2'b00,2'b11�л�
	output	reg						o_usb_slwr_n				,	//GPIF д�ź�
	output	reg	[DATA_WD-1		 :0]ov_usb_data					,	//GPIF �����ź�
	output							o_usb_pktend_n				,	//GPIF �������ź�
	output							o_usb_pktend_n_for_test		,	//GPIF �������źţ��������������
	output							o_usb_wr_for_led				//GPIF д�ź� - ��led_ctrlģ��
	);

	//  ===============================================================================================
	//  ��һ���֣��Ĵ�����������
	//  ===============================================================================================
	wire		[47				 :0]wv_pc_buffer_size			;	//PC��buffersize��С
	reg         [13 			 :0]dma_cnt						;	//DMA������
	reg			[PACKET_SIZE_WD-1:0]sending_size_cnt			;	//��ǰ�����ʹ�С������
	reg			[REG_WD-1		 :0]require_size_cnt			;	//��ǰ�����ʹ�С������
	reg			[2				 :0]usb_flagb_shift				;	//
	reg								urb_enough_flag				;	//PC�˿�urb�����豸Ҫ�����������ı�־
	wire							mult_en						;	//�˷���ʹ���ź�
	reg			[REG_WD-1		 :0]wv_transfer_count_m			;	//��Чʱ��֮�󣬵������ݿ����
	reg			[REG_WD-1		 :0]wv_transfer_size_m			;	//��Чʱ��֮�󣬵������ݿ��С
	reg			[REG_WD-1		 :0]wv_transfer1_size_m			;   //��Чʱ��֮��transfer1��С
	reg			[REG_WD-1		 :0]wv_transfer2_size_m			;   //��Чʱ��֮��transfer2��С
	reg			[REG_WD-1		 :0]wv_transfer12_size_m		;   //��Чʱ��֮��transfer1��transfer2�ĺ�
	reg			[7 				 :0]current_state				;
	reg			[7 				 :0]next_state					;
	reg								o_usb_slwr_n_m1				;	//GPIF д�ź�
	reg								o_usb_slwr_n_m2				;	//GPIF д�ź�
	reg			[DATA_WD-1		 :0]ov_usb_data_m1				;	//GPIF �����ź�
	reg			[DATA_WD-1		 :0]ov_usb_data_m2				;	//GPIF �����ź�
	reg			[1				 :0]usb_fifoaddr_reg	= 2'b0	;

	reg			[1				 :0]leader_flag_shift	= 2'b0	;
	reg			[1				 :0]payload_flag_shift	= 2'b0	;
	reg			[1				 :0]trailer_flag_shift	= 2'b0	;
	reg								match_flag			= 1'b0	;	//֡������Ϊ64bits��leader��trailer��д����ֽ���Ҫ����,�����߼��趨һ�����������ı�־

	//	-------------------------------------------------------------------------------------
	//	keepԼ���������Ǳ��������������Ĵ�����
	//	�����������Լ������ôusb_fifoaddr_iob�ͻ��Ϊһ������Ϊ�������Ĵ�������Ϊ��һ���ģ��ۺ������Ż���
	//	���ǣ����Ҫ�ѼĴ����ŵ�IOB�ϣ��Ͳ����Ż�Ϊ1��
	//	-------------------------------------------------------------------------------------
	(* KEEP="TRUE" *)reg	[1:0]	usb_fifoaddr_iob			= 2'b0;

	//	-------------------------------------------------------------------------------------
	//	usb_pktend_n_reg �� usb_pktend_n_for_test ����Ϊ��һ���ģ��������Լ�������Ż���
	//	usb_pktend_n_reg-�����GPIF������
	//	usb_pktend_n_for_test-��������Խ���
	//	-------------------------------------------------------------------------------------
	(* KEEP="TRUE" *)reg			usb_pktend_n_reg			= 1'b1;
	(* KEEP="TRUE" *)reg			usb_pktend_n_for_test		= 1'b1;

	//  ===============================================================================================
	//  �ڶ����֣���������
	//  ===============================================================================================
	localparam 						IDLE 		= 8'b00000000	;	//����״̬
	localparam 						PACKET_START= 8'b00000001	;	//����ʼ״̬
	localparam 						DMA_SENDING	= 8'b00000010	;	//DMA����״̬
	localparam 						CHECK_FLAG	= 8'b00000100	;	//����־״̬
	localparam 						PKT_END     = 8'b00001000	;	//������״̬
	localparam 						DELAY		= 8'b00010000	;	//��ʱ״̬���̰���flag��־Ϊ����3��ʱ�ӵ���ʱ
	localparam 						WAIT_FLAG	= 8'b00100000	;	//�ȴ���־״̬
	localparam						ADD_PKT_END = 8'b01000000	;	//��Ӱ�����״̬
	localparam						PACKET_STOP = 8'b10000000	;	//��Ӱ�����״̬
	//  ===============================================================================================
	//  �������ָ����߼�1:ȡi_usb_flagb�źŵı���
	//  ===============================================================================================

	always @ ( posedge	clk )
	begin
		usb_flagb_shift	<=	{usb_flagb_shift[1:0],i_usb_flagb}	;
	end

	always @ ( posedge	clk )
	begin
		leader_flag_shift	<=	{leader_flag_shift[0],i_leader_flag}	;
		payload_flag_shift	<=	{payload_flag_shift[0],i_payload_flag}	;
		trailer_flag_shift	<=	{trailer_flag_shift[0],i_trailer_flag}	;
	end

	//  ===============================================================================================
	//  �������ָ����߼�2:������Чʱ�����ƣ��������ò���ֻ����ͣ���ڼ�����޸ģ��ɼ��ڼ䱣�ֲ���
	//  ===============================================================================================

	always @ ( posedge	clk )
	begin
		if ( reset )
		begin
			wv_transfer_count_m	    <=	iv_transfer_count	    ;
			wv_transfer_size_m	    <=	iv_transfer_size	    ;
			wv_transfer1_size_m	    <=	iv_transfer1_size	    ;
			wv_transfer2_size_m		<=	iv_transfer2_size		;
		end
	end

	//  ===============================================================================================
	//  �������ָ����߼�3:����PC URB��С��iv_transfer_size*iv_transfer_count++iv_transfer1_size+iv_transfer2_size
	//  �Ĵ���λ����������������֧�ֵ�ͼ���С������16MB,����require_size_cnt 24bits�㹻
	//  �˷���ֻ������ͣ���ڼ���㣬��ʼ�ɼ����豣�ֲ��䣬����ʹ��resetȡ����ʱ��ʹ�ܣ���ˮ����ʱ5clk
	//  ����PC URB��С��Ҫ�������ж��Ƿ���Ӷ̰�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  �����˷���
	//  -------------------------------------------------------------------------------------
	urb_mult urb_mult_inst(
	.clk  (clk							),
	.ce   (mult_en						),
	.a    (wv_transfer_size_m			),
	.b    (wv_transfer_count_m[15:0]	),
	.p    (wv_pc_buffer_size			)
	);

	assign	mult_en  = ~reset;		//��λ�ڼ������������Ĳ�����


	always @ ( posedge	clk ) 		//�ϳ�����߼���һ�ţ��������Ż�ʱ��
	begin
		wv_transfer12_size_m <= wv_transfer1_size_m + wv_transfer2_size_m;
	end

	always @ ( posedge	clk ) 		//�ϳ�����߼���һ�ţ��������Ż�ʱ��
	begin
		require_size_cnt 	<= wv_pc_buffer_size[31:0] + wv_transfer12_size_m;
	end

	always @ ( posedge	clk ) 		//ֻ��i_payload_flag��־�ڼ���жϣ�leader��trailer����ֻ���Ƕ̰������ж�
	begin
		if ( reset )
		urb_enough_flag	<=	1'b0;
		else if ( i_payload_flag && ( require_size_cnt > iv_packet_size ) )
		urb_enough_flag	<=	1'b1;
		else
		urb_enough_flag	<=	1'b0;
	end

	//  ===============================================================================================
	//  ���Ĳ�������ʽ״̬�����ɲο���ϸ�����ת����ͼ
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  ״̬����һ��
	//  -------------------------------------------------------------------------------------
	always @ ( posedge	clk )
	begin
		if ( reset )
		current_state	<=	IDLE;
		else
		current_state	<=	next_state;
	end
	//  -------------------------------------------------------------------------------------
	//  ״̬���ڶ���
	//	��ϸ�ο���ϸ���״̬����תͼ
	//  ���߼���������
	//  -------------------------------------------------------------------------------------
	always @ * begin
		next_state  =	IDLE		;
		case (current_state)
			IDLE 		:
			begin
				if ( leader_flag_shift==2'b01 || i_payload_flag==2'b01 || i_trailer_flag==2'b01 )//ֻҪ��һ����־��������ת�������俪ʼ
					next_state	= PACKET_START;
				else
					next_state	= IDLE;
			end
			PACKET_START:
			begin
				if ( usb_flagb_shift[1] )								//���3014�Ƿ�������û������������ת����һ״̬
				next_state	= DMA_SENDING;
				else
				next_state	= PACKET_START;
			end
			DMA_SENDING	:
			begin
				if ( sending_size_cnt == iv_packet_size[PACKET_SIZE_WD+1:2] )//��sending_size_cnt[12:0] == DMA_SIZE�뱾����ͬʱ����ʱ��sending_size_cnt[12:0] == DMA_SIZE���ȼ���
				next_state	= PKT_END;
				else if ( dma_cnt== DMA_SIZE )							//dma_cnt��������������DMA_SIZEʱ����ת����һ״̬
				next_state	= CHECK_FLAG;
				else
				next_state	= DMA_SENDING;
			end
			CHECK_FLAG	:
			begin
				if ( usb_flagb_shift[2:1] == 2'b01 )					//���ü����ķ�ʽ���ȴ�flagb�ָ���֮���ټ�������һ��DMA_SIZE��С������
				next_state	= DMA_SENDING;
				else
				next_state	= CHECK_FLAG;
			end
			PKT_END		:
			begin
				if ( iv_packet_size[9:2] == 8'h00  )					//iv_packet_size��1k�ı���
				begin
					if ( urb_enough_flag )								//iv_packet_size��1k�ı����� PC URB�ܺʹ����豸��������������Ҫ��Ӷ̰�
					next_state	= WAIT_FLAG;
					else
					next_state	= DELAY;								//��������Ӷ̰�
				end
				else													//iv_packet_size����1k�ı����������̰�����IDEL
				next_state	= DELAY;
			end
			WAIT_FLAG	:
			begin
				if ( usb_flagb_shift[2:1] == 2'b01 )					//�ȴ�flagb�����أ����ֱ���ж�flagb�����ܻ���flagbû��ʱ��������
				next_state	= ADD_PKT_END;
				else
				next_state	= WAIT_FLAG;
			end
			ADD_PKT_END	:												//�����̰�
			begin
				next_state	= DELAY;
			end
			DELAY	:													//�ȴ�flagb�����أ����ֱ���ж�flagb�����ܻ���flagb������ʱ�ӵ���ʱ��û��ʱ����״̬��PACKET_START����
			begin
				if ( usb_flagb_shift[2:1] == 2'b01 )
				next_state	= PACKET_STOP;
				else
				next_state	= DELAY;
			end
			PACKET_STOP	:												//һ��packet���ͽ�������������change_flag
			begin
				next_state	= IDLE;
			end
		endcase
	end

	//  -------------------------------------------------------------------------------------
	//  ״̬��������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk )
	begin
		if( reset )
		begin
			o_change_flag			<=	1'b0    ;
			usb_fifoaddr_reg		<=	2'b00	;
			usb_pktend_n_reg		<=	1'b1    ;
			usb_pktend_n_for_test	<=	1'b1    ;
			dma_cnt					<=	14'h0   ;
			sending_size_cnt		<=	{PACKET_SIZE_WD{1'b0}};
		end
		else
		begin
			o_change_flag			<=	1'b0    ;															//�ź�Ĭ��״̬
			usb_pktend_n_reg		<=	1'b1    ;
			usb_pktend_n_for_test	<=	1'b1    ;
			dma_cnt					<=	14'h0   ;
			case (next_state)
				IDLE:
				begin
					sending_size_cnt		<=	{PACKET_SIZE_WD{1'b0}};
				end
				DMA_SENDING	:
				begin
					if ( o_fifo_rd && i_data_valid )	//3014δ����֡���˷ǿգ���û�мǵ�DMASIZE������ź����������ӳ٣���������ݶ����valid�ź�
					begin
						dma_cnt				<=  dma_cnt + 1;
						sending_size_cnt	<=	sending_size_cnt + 1;
					end
					else
					begin
						dma_cnt				<=  dma_cnt;
						sending_size_cnt	<=	sending_size_cnt ;
					end
				end
				CHECK_FLAG	:
				begin
					if ( usb_flagb_shift[2:1] == 2'b10 )		//flagb��ʱ���½��أ��л�FIFO��ַ
					begin
						usb_fifoaddr_reg	<=	~usb_fifoaddr_reg;
					end
				end
				PKT_END		:
				begin
					usb_pktend_n_reg		<= 1'b0;
					usb_pktend_n_for_test	<= 1'b0;
				end
				DELAY	:
				begin
					if ( usb_flagb_shift[2:1] == 2'b10 )		//flagb��ʱ���½��أ��л�FIFO��ַ
					usb_fifoaddr_reg		<=	~usb_fifoaddr_reg;
					else
					usb_fifoaddr_reg		<=	usb_fifoaddr_reg;
				end
				WAIT_FLAG	:
				begin
					if ( usb_flagb_shift[2:1] == 2'b10 )		//flagb��ʱ���½��أ��л�FIFO��ַ
					usb_fifoaddr_reg		<=	~usb_fifoaddr_reg;
				end
				ADD_PKT_END	:
				begin
					usb_pktend_n_reg		<= 1'b0;
					usb_pktend_n_for_test	<= 1'b0;
				end
				PACKET_STOP	:
				begin
					o_change_flag			<= 1'b1;
				end
				default		:;
			endcase
		end
	end

	//	-------------------------------------------------------------------------------------
	//	���� usb_fifoaddr_reg ���ڷ�����·���޷���ӵ�IOB�ϣ���ˣ���һ��
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		usb_fifoaddr_iob			<= usb_fifoaddr_reg;
	end
	assign	ov_usb_fifoaddr			= usb_fifoaddr_iob;

	//	-------------------------------------------------------------------------------------
	//	�������ź�
	//	���ڰ������ź�Ҫ����IOB�ϣ������ٷ��ص�FPGA��ͨ���߼������Ҫ��������Ϊһ���ļĴ���
	//	-------------------------------------------------------------------------------------
	assign	o_usb_pktend_n			= usb_pktend_n_reg;
	assign	o_usb_pktend_n_for_test	= usb_pktend_n_for_test;

	//  ===============================================================================================
	//  ����3014GPIF�˿��ź�
	//	3014д�źŵ�ͬ��frame_buffer���źţ�FIFOʹ��First-Word Fall-Through���źź�
	//  ���ݶ��룬д�źź�����ҲҪ���룬�������ݴ�һ��
	//	������������֡����FIFO��ƣ����FIFO����д�������ƣ������o_fifo_rd�������������
	//	���һ���̰����ݶ���֮����ʱһ��д�룬��ʱ����̰��źţ����һ��д�Ͷ̰����ö���
	//  ===============================================================================================
	//	�˴�ֻ����next_state== DMA_SENDING��������źŻ��1��ʱ��
	assign	o_fifo_rd = (next_state== DMA_SENDING) && usb_flagb_shift[1]  && (!i_framebuffer_empty) && (dma_cnt < DMA_SIZE);


	//����leader�ʹ�chunk��trailerʱ�����д��4B,��Ҫ����д����������Σ��˴�����һ��match��־
	always @ (posedge clk )
	begin
		if( i_leader_flag || (i_trailer_flag & i_chunkmodeactive ) )begin
			match_flag	<=	1'b1;
		end
		else begin
			match_flag	<=	1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	ͷ������52Bʵ��д����fifo 56B��������Ҫ����4B��
	//	β��chunk��ʱд��36B��ʵ��д��40B�������Ҫ����4B����chunk�ر�ʱд��32B��ʵ��д��Ҳ��32B����������
	//	Ϊ������������Ķ������ý�д�źš���������ʱ���̰��ź����λ�ñ��ֲ���ķ�����֤�̰���ȷд�룬��д���������ȷ����
	//  ����leader�ʹ�chunk��trailerʱ��Ҫ����д�źţ������߼����ö̰��ź���ʱһ��
	//	-------------------------------------------------------------------------------------
	//	ԭ���ź����λ��
	//	o_usb_slwr_n	��������������������������������������|______________________________|������������������������������������
	//	ov_usb_data 	-------------------X==============================X------------------
	//	o_usb_pktend_n	________________________________________________|-|__________________
	//	������������ʱ���źŵ���
	//	o_usb_slwr_n	������������������������������������������|______________________________|��������������������������������
	//	ov_usb_data 	---------------------X==============================X----------------
	//	o_usb_pktend_n	________________________________________________|-|__________________
	//	mask			__________________________________________________|-|________________

	//д�ź�����ʱ����
	always @ (posedge clk )
	begin
		if( reset )	begin
			o_usb_slwr_n_m1	<=	1'b1;
		end
		else begin
			o_usb_slwr_n_m1	<=	~( o_fifo_rd & i_data_valid );
		end
	end
	//����leader�ʹ�chunk��trailerʱ��Ҫ��д����ʱһ�ģ�������Ҫ����ԭ���߼�ֱ�Ӹ���
	always @ (posedge clk )
	begin
		if( reset )	begin
			o_usb_slwr_n_m2	<=	1'b1;
		end
		else if ( match_flag ) begin
			o_usb_slwr_n_m2	<=	o_usb_slwr_n_m1;
		end
		else begin
			o_usb_slwr_n_m2	<=	~( o_fifo_rd & i_data_valid );
		end
	end
	//��������ʱ����Ҫ����д���4B���ε���������ö̰��ź�ȡ����Ϊ�����źţ�����������ʱ����ԭ���߼�ֱ�Ӹ���
	always @ (posedge clk )
	begin
		if( reset ) begin
			o_usb_slwr_n	<=	1'b1;
		end
		else if ( match_flag )begin
			o_usb_slwr_n	<=	(o_usb_slwr_n_m2 | ~usb_pktend_n_reg) && (!(next_state == ADD_PKT_END ));
		end
		else begin
			o_usb_slwr_n	<=	o_usb_slwr_n_m2 && (!(next_state == ADD_PKT_END ));
		end
	end
	//���ݺ�д�ź�����ͬ�Ĵ���
	always @ (posedge clk )
	begin
		if( reset )
			ov_usb_data_m1	<=	32'h0;
		else
			ov_usb_data_m1	<=	iv_data;
	end
	//����leader�ʹ�chunk��trailerʱ��Ҫ�����ݶ���ʱһ��
	always @ (posedge clk )
	begin
		if( reset )
			ov_usb_data_m2	<=	32'h0;
		else if ( match_flag )
			ov_usb_data_m2	<=	ov_usb_data_m1;
		else
			ov_usb_data_m2	<=	iv_data;
	end

	always @ (posedge clk )
	begin
		if( reset )
			ov_usb_data		<=	32'h0;
		else if (~o_usb_slwr_n_m2)				//�����̰���Ӧ������Ϊ0
			ov_usb_data		<=	ov_usb_data_m2;
		else
			ov_usb_data		<=	32'h0;
	end

	//	-------------------------------------------------------------------------------------
	//	д�ź���Ϊled�̵Ƶı�־
	//	1.led �̵� 1-���� 0-Ϩ��
	//	-------------------------------------------------------------------------------------
	assign	o_usb_wr_for_led	= o_usb_slwr_n_m2;

endmodule