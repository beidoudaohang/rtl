//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : u3_transfer
//  -- �����       : ��ǿ���ܽ�
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- ��ǿ         :| 2014/11/28 17:40:36	:|  ���ݼ���Ԥ������
//  -- �ܽ�       :| 2016/9/22 14:29:57	:|  �޸�Ϊ֧��multi-roi�İ汾
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
	parameter						SHORT_REG_WD 		=16		,	//�̼Ĵ���λ��
	parameter						PACKET_SIZE_WD		=24		,	//ͼ���Сλ��,��λ4�ֽ�,֧�ֵ����64MBͼ��
	parameter						DMA_SIZE			=14'H2000	//DMA SIZE��С8192x32bit
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
	input		[DATA_WD		:0]	iv_data						,	//֡�������32λ���ݣ�clk_usb_pclkʱ����
	input							i_framebuffer_empty			,	//framebuffer���FIFO�ձ�־���ߵ�ƽ��Ч��clk_gpifʱ����,֡��ͼ���ۼƺ�֡��տ��ܲ������
	input							i_leader_flag				,	//leader����־,clk_usb_pclkʱ����
	input							i_trailer_flag				,	//trailer����־,clk_usb_pclkʱ����
	input							i_payload_flag				,	//payload����־,clk_usb_pclkʱ����
	output	reg						o_change_flag				,	//leader��payload��trailer���л���־��ÿ����������ɺ��л�,�����ڿ��
	output	reg	[7				 :0]ov_roi_num					,	//multi-roiģʽ�����roi��num��
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
	output	reg						o_usb_slwr_n				,	//GPIF д�źţ��͵�ƽ��Ч
	output	reg	[DATA_WD-1		 :0]ov_usb_data					,	//GPIF �����ź�
	output							o_usb_pktend_n					//GPIF �������źţ��͵�ƽ��Ч����Чʱ�����1��ʱ������
	);

	//  ===============================================================================================
	//  ��һ���֣��Ĵ�����������
	//  ===============================================================================================
	wire		[47				 :0]wv_pc_buffer_size			;	//PC��buffersize��С��λ���ǳ˷�����������λ��ĺ�
	reg         [13 			 :0]dma_cnt						;	//DMA������
	reg			[PACKET_SIZE_WD-1:0]sending_size_cnt			;	//��ǰ�����ʹ�С������
	reg			[REG_WD-1		 :0]require_size_cnt			;	//��ǰ�����ʹ�С������
	reg			[2				 :0]usb_flagb_shift				;	//i_flagb����λ�Ĵ���
	reg								urb_enough_flag				;	//PC�˿�urb�����豸Ҫ�����������ı�־
	wire							w_mult_en					;	//�˷���ʹ���ź�
	reg			[REG_WD-1		 :0]transfer_count_m			;	//��Чʱ��֮�󣬵������ݿ����
	reg			[REG_WD-1		 :0]transfer_size_m				;	//��Чʱ��֮�󣬵������ݿ��С
	reg			[REG_WD-1		 :0]transfer1_size_m			;   //��Чʱ��֮��transfer1��С
	reg			[REG_WD-1		 :0]transfer2_size_m			;   //��Чʱ��֮��transfer2��С
	reg			[REG_WD-1		 :0]transfer12_size_m			;   //��Чʱ��֮��transfer1��transfer2�ĺ�
	reg			[REG_WD-1		 :0]buffer_plus_transfer1		;	//��Чʱ��֮��transfer_count*transfer_size��transfer1�ĺ�
	reg			[7 				 :0]current_state				;	//��ǰ״̬����next_state��ʱ1��ʱ�����ڣ�����״̬��ת
	reg			[7 				 :0]next_state					;	//�����߼�����
	reg								usb_slwr_n_m1				;	//GPIF д�ź�
	reg			[DATA_WD-1		 :0]usb_data_m1					;	//GPIF �����ź�
	reg			[1				 :0]usb_fifoaddr_reg	= 2'b0	;

	reg			[1				 :0]leader_flag_shift	= 2'b0	;	//i_leader_flag��λ�Ĵ���
	reg			[1				 :0]payload_flag_shift	= 2'b0	;	//i_payload_flag��λ�Ĵ���
	reg			[1				 :0]trailer_flag_shift	= 2'b0	;	//i_trailer_flag��λ�Ĵ���
	
	reg			[SHORT_REG_WD-1	 :0]urb_num_total		=	0	;	//urb���ܸ���
	reg			[SHORT_REG_WD-1	 :0]urb_num_total_reg	=	0	;	//urb���ܸ�����urb_num_total_reg=urb_num_total����urb_num_total_reg=urb_num_total+1
	reg			[SHORT_REG_WD-1	 :0]urb_used_cnt		=	0	;	//��ǰͼ������ʹ�õ�urb����
	reg			[REG_WD-3		 :0]urb_size_cnt		=	0	;	//����urb������
	wire 							urb_num0					;	//transfer1_size=0��Ϊ0������Ϊ1
	wire 							urb_num1					;	//transfer2_size=0��Ϊ0������Ϊ1

	//	-------------------------------------------------------------------------------------
	//	usb_pktend_n_reg �� usb_pktend_n_for_test ����Ϊ��һ���ģ��������Լ�������Ż���
	//	usb_pktend_n_reg-�����GPIF������
	//	-------------------------------------------------------------------------------------
	reg			usb_pktend_n_reg			= 1'b1;

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
	//	-------------------------------------------------------------------------------------
	//	�����ã����ڷ���ʱ����״̬�������ĸ�״̬
	//	-------------------------------------------------------------------------------------
	//FSM for sim
	// synthesis translate_off
	reg		[111:0]			current_state_ascii;
	reg		[111:0]			next_state_ascii;
	always @ ( * ) begin
		case(current_state)
			8'b00000000 :	current_state_ascii	<= "IDLE";
			8'b00000001 :	current_state_ascii	<= "PACKET_START";
			8'b00000010 :	current_state_ascii	<= "DMA_SENDING";
			8'b00000100 :	current_state_ascii	<= "CHECK_FLAG";
			8'b00001000 :	current_state_ascii	<= "PKT_END";
			8'b00010000 :	current_state_ascii	<= "DELAY";
			8'b00100000 :	current_state_ascii	<= "WAIT_FLAG"; 
			8'b01000000	:	current_state_ascii	<= "ADD_PKT_END";
			8'b10000000	:	current_state_ascii	<= "PACKET_STOP";
		endcase
	end
	
	always @ ( * ) begin
		case(next_state)
			8'b00000000 :	next_state_ascii	<= "IDLE";
			8'b00000001 :	next_state_ascii	<= "PACKET_START";
			8'b00000010 :	next_state_ascii	<= "DMA_SENDING";
			8'b00000100 :	next_state_ascii	<= "CHECK_FLAG";
			8'b00001000 :	next_state_ascii	<= "PKT_END";
			8'b00010000 :	next_state_ascii	<= "DELAY";
			8'b00100000 :	next_state_ascii	<= "WAIT_FLAG"; 
			8'b01000000	:	next_state_ascii	<= "ADD_PKT_END";
			8'b10000000	:	next_state_ascii	<= "PACKET_STOP";
		endcase
	end
	// synthesis translate_on
	//  ===============================================================================================
	//  �������ָ����߼�1:ȡi_usb_flagb�źŵı���
	//  ===============================================================================================

	always @ (posedge clk)begin
		usb_flagb_shift	<=	{usb_flagb_shift[1:0],i_usb_flagb}	;
	end

	always @ (posedge clk)begin
		leader_flag_shift	<=	{leader_flag_shift[0],i_leader_flag}	;
		payload_flag_shift	<=	{payload_flag_shift[0],i_payload_flag}	;
		trailer_flag_shift	<=	{trailer_flag_shift[0],i_trailer_flag}	;
	end

	//  ===============================================================================================
	//  �������ָ����߼�2:������Чʱ�����ƣ��������ò���ֻ����ͣ���ڼ�����޸ģ��ɼ��ڼ䱣�ֲ���
	//  ===============================================================================================
	assign urb_num0	=	transfer1_size_m ? 1 :0;
	assign urb_num1	=	transfer2_size_m ? 1 :0;
	
	always @ (posedge clk)begin
		if(reset)begin
			transfer_count_m	    <=	iv_transfer_count   ;
			transfer_size_m	    	<=	iv_transfer_size    ;
			transfer1_size_m	    <=	iv_transfer1_size   ;
			transfer2_size_m		<=	iv_transfer2_size	;
			urb_num_total			<=	iv_transfer_count	+	urb_num0	+	urb_num1;
		end
	end

	//  ===============================================================================================
	//  �������ָ����߼�3:����PC URB��С��iv_transfer_size*iv_transfer_count++iv_transfer1_size+iv_transfer2_size
	//  ֧�ֵ�ͼ���С����ͨ��PACKET_SIZE_WD�����ã�require_size_cnt��λ��Ӧ��������PACKET_SIZE_WD+2
	//  �˷���ֻ������ͣ���ڼ���㣬��ʼ�ɼ����豣�ֲ��䣬����ʹ��resetȡ����ʱ��ʹ�ܣ���ˮ����ʱ5clk
	//  ����PC URB��С��Ҫ�������ж��Ƿ���Ӷ̰�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  �����˷���
	//  -------------------------------------------------------------------------------------
	urb_mult urb_mult_inst(
	.clk  (clk									),
	.ce   (w_mult_en							),
	.a    (transfer_size_m						),
	.b    (transfer_count_m[SHORT_REG_WD-1	:0]	),
	.p    (wv_pc_buffer_size					)
	);
	//	-------------------------------------------------------------------------------------
	//	��λ�ڼ������������Ĳ�����	
	//	-------------------------------------------------------------------------------------
	assign	w_mult_en  = ~reset;		

	//	-------------------------------------------------------------------------------------
	//	�ϳ�����߼���һ�ţ��������Ż�ʱ��
	//	-------------------------------------------------------------------------------------
	always @ (posedge	clk)begin 		
		transfer12_size_m		<= transfer1_size_m 	+ 	transfer2_size_m;
	end
	
	always @ (posedge clk) begin
		buffer_plus_transfer1	<=	wv_pc_buffer_size	+	transfer1_size_m;
	end
	
	always @ (posedge clk)begin 		
		require_size_cnt		<= wv_pc_buffer_size[REG_WD-1:0] + transfer12_size_m;
	end
	//	-------------------------------------------------------------------------------------
	//	ֻ��i_payload_flag��־�ڼ���жϣ�leader��trailer����ֻ���Ƕ̰������ж�	
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk)begin		
		if (reset)
			urb_enough_flag	<=	1'b0;
		else if(i_payload_flag && ( require_size_cnt > iv_packet_size))
			urb_enough_flag	<=	1'b1;
		else
			urb_enough_flag	<=	1'b0;
	end
	//  ===============================================================================================
	//  �������ָ����߼�4ͳ��ʹ��urb�ĸ���urb_used_cnt	
	//	ͳ��ʹ��urb�����߼�˵��
	//	1��sending_size_cnt<=(wv_pc_buffer_size>>2)-1ʱ��ÿ����1������urb��urb_used_cnt+1
	//	2��sending_size_cnt==(buffer_plus_transfer1>>2)-1ʱ������transfer1��urb_used_cnt+1
	//	3��sending_size_cnt==(iv_packet_size>>2)-1ʱ�������Ƿ�����ĳ��urb��urb_used_cnt+1
	//	===============================================================================================
	always @ (posedge clk) begin
		if(next_state==0)begin															//�ص�IDEL״̬ʱ
			urb_used_cnt	<=	0;														//urb_used_cnt����
			urb_size_cnt	<=	0;														//urb_size_cnt����
		end
		else if(i_payload_flag)begin													//״̬�����ڷ���payload���ݽ׶�
			if(next_state[1] & o_fifo_rd & (~iv_data[DATA_WD]))begin															//next_state=DMA_SENDING
				if(sending_size_cnt==iv_packet_size[PACKET_SIZE_WD+1:2]-1)begin				//�������ﵽ���ֵ
					urb_used_cnt	<=	urb_used_cnt	+	1'd1;							//urb_size_cnt��1
				end
				else if(sending_size_cnt==buffer_plus_transfer1[PACKET_SIZE_WD+1:2]-1)begin	//sending_size_cnt�ﵽ����urb+transfer1�Ĵ�С
					urb_used_cnt	<=	urb_used_cnt	+	1'd1;							//urb_used_cnt��1
				end
				else if(sending_size_cnt<=wv_pc_buffer_size[PACKET_SIZE_WD+1:2]-1)begin		//����ֵС�ڵ��ڵ���urb���ܺ�
					if(urb_size_cnt==transfer_size_m[PACKET_SIZE_WD+1:2]-1)begin			//urb_size_cnt����ֵ�ﵽ1��urb�Ĵ�С
						urb_used_cnt	<=	urb_used_cnt	+	1'd1;						//urb_used_cnt��1
						urb_size_cnt	<=	0;												//urb_size����
					end
					else begin																//����
						urb_used_cnt	<=	urb_used_cnt;									//urb_used_cnt���ֲ���
						urb_size_cnt	<=	urb_size_cnt	+	1'd1;						//urb_size_cnt��1
					end
				end
			end
			else if(next_state[6])begin														//״̬�����ڷ��Ͷ̰��׶�
				urb_used_cnt	<=	urb_used_cnt	+	1'd1;								//urb_used_cnt��1
			end
		end	
	end
	//  ===============================================================================================
	//	�������ָ����߼�5������Ҫ���͵Ķ̰���������Ҫ���͵Ķ̰�����Ϊurb_num_total_reg-urb_used_cnt 
	//	������Ҫ���͵Ķ̰��������߼�˵��
	//	�����ݷ������
	//	1��iv_packet_sizeΪ1024��������ʱ��
	//		��urb_enough_flag=1ʱ
	//		a�����urb_size_cnt==(wv_transfer_size_m>>2)-1�����ʾ����urb��������urb_num_total_reg=urb_num_total
	//		b�����sending_size_cnt==(wv_pc_buffer_size+wv_transfer1_size_m)>>2-1��urb_num_total_reg=urb_num_total
	//		c���������,urb_num_total_reg=urb_num_total+1
	//		��urb_enough_flag=0ʱ
	//		urb_num_total_reg=urb_num_total
	//	2��iv_packet_size����1024��������ʱ��
	//		urb_num_total_reg=urb_num_total
	//  ===============================================================================================
	always @ (posedge clk) begin
		if(next_state==0)begin
			urb_num_total_reg	<=	0;
		end
		else if(i_payload_flag==1 && next_state[1]==1 && sending_size_cnt==iv_packet_size[PACKET_SIZE_WD+1:2]-1)begin//i_payload_flag=1��next_state=DMA_SENDING
			if(iv_packet_size[9:2] == 8'h00)begin							//iv_packet_sizeΪ1024��������
				if(urb_enough_flag)begin									//urb_size>payload_size
					if(urb_size_cnt==transfer_size_m[PACKET_SIZE_WD+1:2]-1)	//��������urb�������Ͷ̰�
						urb_num_total_reg	<=	urb_num_total;
					else if(sending_size_cnt==buffer_plus_transfer1[PACKET_SIZE_WD+1:2]-1)//����transfer1�������Ͷ̰�
						urb_num_total_reg	<=	urb_num_total;
					else
						urb_num_total_reg	<=	urb_num_total	+	1'd1;
				end									
				else
					urb_num_total_reg	<=	urb_num_total;
			end
			else
				urb_num_total_reg	<=	urb_num_total;
		end
	end
	//  ===============================================================================================
	//  ��leader��ȡroi_num
	//	leader�����ݽṹ
	//	leader		:	-|32'h4c563355	|...........................................|byte4 byte3 byte2 byte1|  
	//	dma_cnt		:	-|		0		|		1		|............|		12		|			13			|
	//	o_fifo_rd	:	_|��������������������������������������������������������������������������������������������������������������������������������������������������������������������|_
	//	byte4:8'h0
	//	byte3:8'h0
	//	byte2:1-last roi,0-others
	//	byte1:roi_num,range from 0 to 7
	//  ===============================================================================================
	always @ (posedge clk) begin
		if(i_leader_flag & (dma_cnt==13)) begin
			ov_roi_num	<=	iv_data[7:0];
		end
	end
	//  ===============================================================================================
	//  ���Ĳ�������ʽ״̬�����ɲο���ϸ�����ת����ͼ
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  ״̬����һ��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset)
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
			IDLE 		:begin		
				if(leader_flag_shift==2'b01 || payload_flag_shift==2'b01 || trailer_flag_shift==2'b01)//ֻҪ��һ����־��������ת�������俪ʼ
					next_state	= PACKET_START;
				else
					next_state	= IDLE;
			end
			PACKET_START:begin			
				if(usb_flagb_shift[1])							//���3014�Ƿ�������û������������ת����һ״̬
					next_state	= DMA_SENDING;
				else
					next_state	= PACKET_START;
			end
			DMA_SENDING	:begin		
				if(sending_size_cnt == iv_packet_size[PACKET_SIZE_WD+1:2])//��sending_size_cnt[12:0] == DMA_SIZE�뱾����ͬʱ����ʱ��sending_size_cnt[12:0] == DMA_SIZE���ȼ���
					next_state	= PKT_END;		
				else if(dma_cnt== DMA_SIZE)					//dma_cnt��������������DMA_SIZEʱ����ת����һ״̬
					next_state	= CHECK_FLAG;
				else
					next_state	= DMA_SENDING;
			end
			CHECK_FLAG	:begin			
				if(usb_flagb_shift[2:1] == 2'b01)				//���ü����ķ�ʽ���ȴ�flagb�ָ���֮���ټ�������һ��DMA_SIZE��С������
					next_state	= DMA_SENDING;
				else
					next_state	= CHECK_FLAG;
			end
			PKT_END		:begin			
				if(iv_packet_size[9:2] == 8'h00)begin			//iv_packet_size��1k�ı���				
					if(urb_enough_flag)							//iv_packet_size��1k�ı����� PC URB�ܺʹ����豸��������������Ҫ��Ӷ̰�
						next_state	= WAIT_FLAG;
					else
						next_state	= DELAY;					//��������Ӷ̰�
				end
				else begin										//iv_packet_size����1k�ı����������̰�����IDEL
					if(urb_used_cnt>=urb_num_total_reg)
						next_state	= DELAY;
					else
						next_state	= WAIT_FLAG;	
				end
			end
			WAIT_FLAG	:begin		
				if (usb_flagb_shift[2:1] == 2'b01)				//�ȴ�flagb�����أ����ֱ���ж�flagb�����ܻ���flagbû��ʱ��������
					next_state	= ADD_PKT_END;
				else
					next_state	= WAIT_FLAG;
			end
			ADD_PKT_END	:begin									//�����̰�			
				if(i_payload_flag)begin
					if(urb_used_cnt==urb_num_total_reg)
						next_state	= DELAY;
					else
						next_state	= WAIT_FLAG;
				end
				else begin
					next_state	= DELAY;
				end
			end
			DELAY		:begin									//�ȴ�flagb�����أ����ֱ���ж�flagb�����ܻ���flagb������ʱ�ӵ���ʱ��û��ʱ����״̬��PACKET_START����		
				if(usb_flagb_shift[2:1] == 2'b01)
					next_state	= PACKET_STOP;
				else
					next_state	= DELAY;
			end
			PACKET_STOP	:begin									//һ��packet���ͽ�������������change_flag			
				next_state	= IDLE;
			end
		endcase
	end

	//  -------------------------------------------------------------------------------------
	//  ״̬��������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset)begin
			o_change_flag			<=	1'b0    ;
			usb_fifoaddr_reg		<=	2'b00	;
			usb_pktend_n_reg		<=	1'b1    ;
			dma_cnt					<=	14'h0   ;
			sending_size_cnt		<=	{PACKET_SIZE_WD{1'b0}};
		end
		else begin
			o_change_flag			<=	1'b0    ;				//�ź�Ĭ��״̬
			usb_pktend_n_reg		<=	1'b1    ;
			dma_cnt					<=	14'h0   ;
			case (next_state)
				IDLE		:begin
					sending_size_cnt		<=	{PACKET_SIZE_WD{1'b0}};
				end
				DMA_SENDING	:begin
					if(o_fifo_rd & (~iv_data[DATA_WD]))begin							//3014δ����֡���˷ǿգ���û�мǵ�DMASIZE������ź����������ӳ٣���������ݶ����valid�ź�					
						dma_cnt				<=  dma_cnt + 1;
						sending_size_cnt	<=	sending_size_cnt + 1;
					end
					else begin					
						dma_cnt				<=  dma_cnt;
						sending_size_cnt	<=	sending_size_cnt ;
					end								
				end
				CHECK_FLAG	:begin
					if(usb_flagb_shift[2:1] == 2'b10)begin		//flagb��ʱ���½��أ��л�FIFO��ַ				
						usb_fifoaddr_reg	<=	~usb_fifoaddr_reg;
					end
				end
				PKT_END		:begin
					usb_pktend_n_reg		<= 1'b0;
				end
				DELAY		:begin
					if(usb_flagb_shift[2:1] == 2'b10)			//flagb��ʱ���½��أ��л�FIFO��ַ
						usb_fifoaddr_reg		<=	~usb_fifoaddr_reg;
					else
						usb_fifoaddr_reg		<=	usb_fifoaddr_reg;
				end
				WAIT_FLAG	:begin
					if(usb_flagb_shift[2:1] == 2'b10)			//flagb��ʱ���½��أ��л�FIFO��ַ
						usb_fifoaddr_reg		<=	~usb_fifoaddr_reg;
				end
				ADD_PKT_END	:begin
					usb_pktend_n_reg		<= 1'b0;					
				end
				PACKET_STOP	:begin
					o_change_flag			<= 1'b1;	
				end
				default		:;
			endcase
		end
	end

	//	-------------------------------------------------------------------------------------
	//	3014 FIFO��ַ
	//	-------------------------------------------------------------------------------------
	assign	ov_usb_fifoaddr			= usb_fifoaddr_reg;

	//	-------------------------------------------------------------------------------------
	//	�������ź�
	//	-------------------------------------------------------------------------------------
	assign	o_usb_pktend_n			= usb_pktend_n_reg;

	//  ===============================================================================================
	//  ����3014GPIF�˿��ź�
	//	3014д�źŵ�ͬ��frame_buffer���źţ�FIFOʹ��First-Word Fall-Through���źź�
	//  ���ݶ��룬д�źź�����ҲҪ���룬�������ݴ�һ��
	//	������������֡����FIFO��ƣ����FIFO����д�������ƣ������o_fifo_rd�������������
	//	���һ���̰����ݶ���֮����ʱһ��д�룬��ʱ����̰��źţ����һ��д�Ͷ̰����ö���
	//  ===============================================================================================
	//	�˴�ֻ����next_state== DMA_SENDING��������źŻ��1��ʱ��
	assign	o_fifo_rd = (next_state== DMA_SENDING) && usb_flagb_shift[1]  && (!i_framebuffer_empty) && (dma_cnt < DMA_SIZE);

	//	-------------------------------------------------------------------------------------
	//��������ʱ���п��ܻ��д��4Byte����Ч���ݣ���Ҫ����д�����������
	//����3�������Ҫ�������4Byte��д��
	//1������leader����
	//2�����ʹ�chunk��trailer����
	//3��������������4�ı���������8�ı�����payload����
	//	-------------------------------------------------------------------------------------

	//  ===============================================================================================
	//	ͷ������52Bʵ��д����fifo 56B��������Ҫ����4B��
	//	β��chunk��ʱд��36B��ʵ��д��40B�������Ҫ����4B����chunk�ر�ʱд��32B��ʵ��д��Ҳ��32B����������
	//	Ϊ������������Ķ������ý�д�źš���������ʱ���̰��ź����λ�ñ��ֲ���ķ�����֤�̰���ȷд�룬��д���������ȷ����
	//  ����leader�ʹ�chunk��trailerʱ��Ҫ����д�źţ������߼����ö̰��ź���ʱһ��
	//  ===============================================================================================
	//	ԭ���ź����λ��
	//	o_usb_slwr_n	��������������������������������������|______________________________|������������������������������������
	//	ov_usb_data 	-------------------X==============================X------------------
	//	o_usb_pktend_n	������������������������������������������������������������������������������������������������|_|��������������������������������������
	//	o_usb_slwr_n	������������������������������������������|____________________________|��������������������������������
	//	ov_usb_data 	---------------------X==============================X----------------
	//	o_usb_pktend_n	������������������������������������������������������������������������������������������������|_|������������������������������������
	//	-------------------------------------------------------------------------------------
	//	д�ź�����ʱ����,�Ա���o_usb_pktend_n��ʱ���϶���
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset)begin
			usb_slwr_n_m1	<=	1'b1;
		end
		else begin
			usb_slwr_n_m1	<=	~o_fifo_rd | iv_data[DATA_WD];
		end
	end
	
	always @ (posedge clk)begin
		if(reset) begin
			o_usb_slwr_n	<=	1'b1;
		end
		else begin
			o_usb_slwr_n	<=	usb_slwr_n_m1 && (!(next_state == ADD_PKT_END));
		end
	end
	//	-------------------------------------------------------------------------------------
	//��������ʱ����,�Ա���o_usb_slwr_n��o_usb_pktend_n��ʱ���϶���
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset)
			usb_data_m1	<=	32'h0;
		else
			usb_data_m1	<=	iv_data[DATA_WD-1:0];
	end
	
	always @ (posedge clk)begin
		if(reset)
			ov_usb_data		<=	32'h0;
		else if(~usb_slwr_n_m1)				
			ov_usb_data		<=	usb_data_m1;
		else//�����̰���Ӧ������Ϊ0					
			ov_usb_data		<=	32'h0;
	end

endmodule