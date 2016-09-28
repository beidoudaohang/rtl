//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : rd_logic
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2013/6/13 14:33:26	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :	���߼�ģ��
//              1)  : ��MCB RD FIFO �е����ݰ��Ƶ���FIFO֮��
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

module rd_logic # (
	parameter		RD_WR_WITH_PRE		= "FALSE"	,//read write command end with precharge command
	parameter		DDR3_MEM_DENSITY	= "1Gb"		//DDR3 ���� "1Gb" "512Mb"
	)
	(
	//����ʱ�Ӻ͸�λ
	input						clk					,
	input						reset				,
	//�ⲿ�����ź�
	input	[2:0]				iv_frame_depth		,//֡������ȣ���ͬ��
	input	[22:0]				iv_frame_size		,//֡�����С����ͬ��
	input						i_frame_en			,//ʹ�ܿ��أ���ͬ��������Ч
	//��FIFO
	output						o_buf_rst			,//��FIFO��λ������Ч
	output	[32:0]				ov_buf_din			,//��FIFO�������룬33bit
	output						o_buf_wr_en			,//��FIFOдʹ�ܣ�����Ч
	input						i_buf_pf			,//��FIFO�����������Ч
	input						i_buf_empty			,//��FIFO�գ�����Ч
	input						i_buf_dout32		,//��FIFO����MSB
	//rd logic
	output	[1:0]				ov_rd_frame_ptr		,//��ָ��
	output						o_rd_req			,//�����󣬸���Ч
	input						i_rd_ack			,//����������Ч
	output						o_reading			,//���ڶ�������Ч
	//wr logic
	input	[1:0]				iv_wr_frame_ptr		,//дָ��
	input	[16:0]				iv_wr_addr			,//д��ַ
	input						i_writing			,//����д�ź�
	//MCB FIFO
	input						i_calib_done		,//MCBУ׼��ɣ�����Ч
	output						o_p3_cmd_en			,//MCB CMD дʹ�ܣ�����Ч
	output	[2:0]				ov_p3_cmd_instr		,//MCB CMD ָ��
	output	[5:0]				ov_p3_cmd_bl		,//MCB CMD ͻ������
	output	[29:0]				ov_p3_cmd_byte_addr	,//MCB CMD ��ʼ��ַ
	input						i_p3_cmd_empty		,//MCB CMD �գ�����Ч
	input						i_p3_cmd_full		,//MCB CMD ��������Ч
	output						o_p3_rd_en			,//MCB RD FIFO дʹ�ܣ�����Ч
	input	[31:0]				iv_p3_rd_data		,//MCB RD FIFO �������
	input						i_p3_rd_full		,//MCB RD FIFO ��������Ч
	input						i_p3_rd_empty		,//MCB RD FIFO �գ�����Ч
	input						i_p3_rd_overflow	,//MCB RD FIFO ���������Ч
	input						i_p3_rd_error		,//MCB RD FIFO ��������Ч
	input						i_p2_cmd_empty		//MCB CMD �գ�����Ч
	);

	//	ref signals

	//FSM Parameter Define
	parameter	S_IDLE		= 3'd0;
	parameter	S_REQ		= 3'd1;
	parameter	S_CMD		= 3'd2;
	parameter	S_RD		= 3'd3;
	parameter	S_CHK		= 3'd4;

	reg		[2:0]	current_state;
	reg		[2:0]	next_state;

	//FSM for sim
	// synthesis translate_off
	integer			state_ascii;
	always @ ( * ) begin
		case(current_state)
			3'd0 :	state_ascii	<= "S_IDLE";
			3'd1 :	state_ascii	<= "S_REQ";
			3'd2 :	state_ascii	<= "S_CMD";
			3'd3 :	state_ascii	<= "S_RD";
			3'd4 :	state_ascii	<= "S_CHK";
		endcase
	end
	// synthesis translate_on

	reg		[1:0]					calib_done_shift 	= 2'b0;
	reg		[2:0]					frame_depth_reg 	= 3'b0;
	reg		[22:0]					frame_size_reg 		= 23'b0;
	reg								frame_done_reg 		= 1'b0;
	reg								p2_cmd_empty 		= 1'b0;
	reg								p2_cmd_empty_sync 	= 1'b0;
	wire							fifo_rd_int			;
	reg								writing_d 			= 1'b0;
	wire							writing_rise		;
	reg								reading_d 			= 1'b0;
	reg								reading 			= 1'b0;
	wire							reading_rise		;
	reg								fresh_frame 		= 1'b0;
	reg								able_to_read 		= 1'b0;
	reg		[1:0]					rd_frame_ptr 		= 2'b0;

	reg								able_to_burst		;
	reg								fifo_rd_reg 		= 1'b0;
	reg		[5:0]					word_cnt 			= 6'b111111;
	reg		[16:0]					rd_addr 			= 17'b0;
	wire							ctrl_bit			;
	reg								rd_req_reg 			= 1'b0;
	reg								reading_reg 		= 1'b0;
	reg								addr_less 			= 1'b0;
	wire							frame_en_int		;
	reg								rd_cmd_reg 			= 1'b0;
	reg								buf_empty 			= 1'b0;
	reg								buf_empty_sync 		= 1'b0;
	reg								buf_dout32 			= 1'b0;
	reg								buf_dout32_sync 	= 1'b0;

	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//  �첽�źŲ���
	//  -------------------------------------------------------------------------------------

	//ֻ��һ֡��ʼ��ʱ�����������Ϣ
	//��λ��֡�������Ϊ1��֡������������ⲿ���Ƶģ���Ҫ�ⲿ�ṩһ����ʼֵ��
	//���ⲿ���õ���ֵ���� 1 2 4ʱ��������һ����ȷ���õ���ֵ��
	always @ (posedge clk) begin
		if(reset) begin
			frame_depth_reg		<= 3'b001;
		end
		else begin
			if(current_state == S_IDLE) begin
				case(iv_frame_depth)
					3'b001 :
					frame_depth_reg		<= 3'b001;
					3'b010 :
					frame_depth_reg		<= 3'b010;
					3'b100 :
					frame_depth_reg		<= 3'b100;
					default :
					frame_depth_reg		<= frame_depth_reg;
				endcase
			end
		end
	end

	//	//֡�����С
	//	always @ (posedge clk) begin
	//		frame_size_d		<= iv_frame_size;
	//	end
	//ֻ��һ֡��ʼ��ʱ�����������Ϣ
	always @ (posedge clk) begin
		if(current_state == S_IDLE) begin
			frame_size_reg	<= iv_frame_size;
		end
		else if(fifo_rd_int == 1'b1) begin			//����ва�Ҳ���Լ�����������ʱ�ü������Ѿ�������
			frame_size_reg	<= frame_size_reg - 1'b1;
		end
	end

	//MCB P2 CMD ���ź�
	always @ (posedge clk) begin
		p2_cmd_empty		<= i_p2_cmd_empty;
		p2_cmd_empty_sync	<= p2_cmd_empty;
	end

	//��FIFO���ź�
	always @ (posedge clk) begin
		buf_empty		<= i_buf_empty;
		buf_empty_sync	<= buf_empty;
	end

	//һ֡�������ű�־λ
	always @ (posedge clk) begin
		buf_dout32		<= i_buf_dout32;
		buf_dout32_sync	<= buf_dout32;
	end

	//  -------------------------------------------------------------------------------------
	//  calib_done ���� mcb drp clk ʱ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		calib_done_shift	<= {calib_done_shift[0],i_calib_done};
	end

	//  -------------------------------------------------------------------------------------
	//  �ڲ���������ʹ�ܿ���
	//  -------------------------------------------------------------------------------------
	assign	frame_en_int	= (current_state == S_IDLE) ? i_frame_en : 1'b1;

	//  -------------------------------------------------------------------------------------
	//  ��FIFO��λ
	//	����1	�ڽ��յ�ʹ���ź���Ч֮��Ҫ��ģ������ݶ������ˣ�����ģ����ͣ
	//	����2	֡����ģ����յ�ʹ���ź�֮�󣬲��ܺ�fifo�����������Ḵλ��fifo
	//	����3	ֻ������λ
	//  -------------------------------------------------------------------------------------
	//	//	**************����1**************
	//	//	��FIFO��λ����������
	//	//	1.����λ��Ч
	//	//	2.1 ����ģ�鴦��IDLE״̬�Ҵ�ʱʹ���ź�Ϊ��Ч
	//	//	2.2 ��FIFO�Ѿ�������
	//	//	2.3	��ģ���Ѿ���֡��β��������
	//	//	2.2 2.3�Ǳ�֤�ڸ�λ��FIFO֮ǰ����ģ���һ֡�����ݶ�������
	//	assign	o_buf_rst	= (~frame_en_int & buf_empty_sync & buf_dout32_sync) | reset;

	//	//	**************����2**************
	//	//	������FIFO��״̬���ڿ���״̬�жϵ�ʹ��ȡ�����ͻὫ��FIFO���
	//	assign	o_buf_rst	= ~frame_en_int;

	//	**************����3**************
	assign	o_buf_rst	= reset;
	//  -------------------------------------------------------------------------------------
	//  ��֡�����߼��У���ǰ֡�Ƿ���Ч�źš�
	//  -------------------------------------------------------------------------------------
	//��дģ�鴦��ͬһʱ�����ж�writing��������
	always @ (posedge clk) begin
		writing_d	<= i_writing;
	end
	assign	writing_rise	= (~writing_d) & i_writing;
	//�ж�reading��������
	always @ (posedge clk) begin
		reading_d	<= reading_reg;
	end
	assign	reading_rise	= (~reading_d) & reading_reg;

	//֡�ɶ��ź�
	always @ (posedge clk) begin
		if(frame_en_int == 1'b0) begin			//���ڿ���״̬��ʹ�ܹرգ�������ź�
			fresh_frame	<= 1'b0;
		end
		else begin
			if(writing_rise == 1'b1) begin										//����д�ˣ��Ǿ���һ֡�ɶ�
				fresh_frame	<= 1'b1;
			end
			else if(reading_rise == 1'b1) begin								//�������ˣ��Ǿ���֡�ɶ�����д������ͬʱ��Ч��
				fresh_frame	<= 1'b0;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//  ��rd_ack��CYCLE�ڣ����ݶ�д��״̬���ж��Ƿ��ܹ���
	//  -------------------------------------------------------------------------------------
	//��һ��Ҫ������߼�����Ϊ����Ҫ��1CLK������֡�����߼����ж�
	always @ ( * ) begin
		case(frame_depth_reg)
			3'b001 :			//1 frame
			begin
				able_to_read		<= fresh_frame;						//1֡�����������ǰ֡���¹����Ϳ��Զ�
			end
			3'b010,3'b100 :			//2 4 frames
			begin
				//ʵ�ʹ��̣���ָ���ܹ�����дָ��
				`ifndef	TERRIBLE_TRAFFIC
					if(rd_frame_ptr != iv_wr_frame_ptr) begin				//4֡��������дָ�벻һ�������Զ�
						able_to_read	<= 1'b1;
					end
					else begin
						able_to_read	<= 1'b0;
					end
					//������������ָ�벻�ܽ���дָ�룬�Ҷ�дͬʱ��ʼ��
				`elsif TERRIBLE_TRAFFIC
					if(rd_frame_ptr != iv_wr_frame_ptr) begin				//4֡��������ָ�벻�ܽ���дָ��
						if((rd_frame_ptr != (iv_wr_frame_ptr-1'b1))&&(addr_less == 1'b1)) begin
							able_to_read	<= 1'b1;
						end
						else begin
							able_to_read	<= 1'b0;
						end
					end
					else begin
						able_to_read	<= 1'b0;
					end
				`endif
			end
			default :
			begin
				able_to_read		<= 1'b0;
			end
		endcase
	end

	//	assign	ov_p3_cmd_byte_addr		= {{3'b0},rd_frame_ptr,rd_addr,{8'b0}};
	//  -------------------------------------------------------------------------------------
	//	UG388 pg63 �Ե�ַ�ֲ�����ϸ������
	//	��ַ�ֲ�ֻ��ddr3�Ĵ�С�й�
	//	ÿ�ζ�д�ĳ�����256yte����ˣ���8bit�̶�Ϊ0
	//	512Mb�Ĵ�С����ַҪ��һλ
	//  -------------------------------------------------------------------------------------
	generate
		if(DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p3_cmd_byte_addr	= {{4'b0},rd_frame_ptr,rd_addr[15:0],{8'b0}};
		end
		else begin
			assign	ov_p3_cmd_byte_addr	= {{3'b0},rd_frame_ptr,rd_addr[16:0],{8'b0}};
		end
	endgenerate

	//  -------------------------------------------------------------------------------------
	//  ��rd_ack��CYCLE�ڣ�����ܹ�������ô��ָ���ۼ�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(frame_depth_reg)
			3'b001 :
			rd_frame_ptr	<= 'b0;										//1֡��������ָ��̶�Ϊȫ0
			3'b010 :													//2֡����
			if(frame_en_int == 1'b0) begin
				rd_frame_ptr	<= 'b0;									//���عرգ���ָ��ص���ʼ״̬
			end
			else begin
				if((i_rd_ack == 1'b1)&&(able_to_read == 1'b1)) begin	//��ack��CYCLE�ڣ��ҵ�ַ���Կ��Զ�
					rd_frame_ptr[1]	<= 1'b0;							//MSB�̶�Ϊ0
					rd_frame_ptr[0]	<= ~rd_frame_ptr[0];				//LSBȡ����ʵ��������
				end
			end
			3'b100 :													//4֡����
			if(frame_en_int == 1'b0) begin
				rd_frame_ptr	<= 'b0;									//���عرգ���ָ��ص���ʼ״̬
			end
			else begin
				if((i_rd_ack == 1'b1)&&(able_to_read == 1'b1)) begin	//��ack��CYCLE�ڣ��ҵ�ַ���Կ��Զ�
					rd_frame_ptr	<= rd_frame_ptr + 1'b1;				//��ָ������
				end
			end
			default :
			rd_frame_ptr	<= 'b0;
		endcase
	end
	assign	ov_rd_frame_ptr = rd_frame_ptr;

	//  -------------------------------------------------------------------------------------
	//  CMD FIFO
	//  -------------------------------------------------------------------------------------
	//�ж϶���ַС��д��ַ���߼�.����ַС��д��ַ�������д��ַ�Ѿ���MCB�����ˡ�ff�����ʱ�����ܣ������ǹؼ�·����
	always @ (posedge clk) begin
		if((rd_addr[16:0] < iv_wr_addr[16:0])&&(p2_cmd_empty_sync == 1'b1)) begin
			addr_less	<= 1'b1;
		end
		else begin
			addr_less	<= 1'b0;
		end
	end

	//�жϵ�ǰ״̬�Ƿ��ܷ�����burst���߼�
	always @ ( * ) begin
		case(frame_depth_reg)
			3'b001 :							//��֡�����������ʱҲ��д������ַС��д��ַʱ���ܶ�
			if(i_writing == 1'b1) begin
				able_to_burst	<= addr_less;
			end
			else begin
				able_to_burst	<= 1'b1;
			end
			3'b010,3'b100 :							//2 4֡������ͬһ֡ʱ������ַ��С��д��ַ����ͬ֡ʱ��������������
			if(rd_frame_ptr == iv_wr_frame_ptr) begin
				if(i_writing == 1'b1) begin
					able_to_burst	<= addr_less;
				end
				else begin
					able_to_burst	<= 1'b1;
				end
			end
			else begin
				able_to_burst	<= 1'b1;
			end
			default :							//��������ʶ��������Ϣ���������
			able_to_burst	<= 1'b0;
		endcase
	end

	//���ﲻ�ǹؼ�·����������߼�����ʡ��Դ
	//	assign	cmd_en_int	= (current_state == S_CMD) ? (able_to_burst & ~i_p3_cmd_full & ~i_buf_pf) : 1'b0;
	//	assign	o_p3_cmd_en	= cmd_en_int;

	always @ (posedge clk) begin
		if(current_state == S_CMD) begin
			rd_cmd_reg	<= able_to_burst & ~i_p3_cmd_full & ~i_buf_pf;
		end
		else begin
			rd_cmd_reg	<= 1'b0;
		end
	end

	assign	o_p3_cmd_en		= rd_cmd_reg;
	assign	ov_p3_cmd_bl 	= 6'b111111;
	
	generate
		if(RD_WR_WITH_PRE=="TRUE") begin
			assign	ov_p3_cmd_instr	= 3'b011;	//read with auto precharge
		end
		else begin
			assign	ov_p3_cmd_instr	= 3'b001;	//read without auto precharge
		end
	endgenerate
	
	//  -------------------------------------------------------------------------------------
	//  transfer MCB RD FIFO
	//  -------------------------------------------------------------------------------------
	//��FIFO���ˣ������ٶ����˴�����������߼�
	assign	fifo_rd_int		= (current_state == S_RD) ? (~i_p3_rd_empty) : 1'b0;
	assign	o_p3_rd_en		= fifo_rd_int;

	//����ва������������ǲ���д���FIFO�ģ����Ҫ��frame_done_reg�ź�������
	//���Ҫд���������
	assign	o_buf_wr_en		= (fifo_rd_int & ~frame_done_reg) | ctrl_bit;

	//һ֡д���ˣ���CHK״̬�����FIFOд����Ʒ�
	assign	ctrl_bit		= (current_state == S_CHK) ? frame_done_reg : 1'b0;

	//��FIFO����Чλ��33λ�����λ�ǿ������ݱ�ʶ��
	assign	ov_buf_din		= {ctrl_bit,iv_p3_rd_data};

	//  -------------------------------------------------------------------------------------
	//  �� MCB RD FIFO ������
	//  -------------------------------------------------------------------------------------
	//��¼��MCB RD FIFO��ת���˶��ٸ�����
	always @ (posedge clk) begin
		if(current_state == S_IDLE) begin
			word_cnt	<= 6'b111111;
		end
		else if(fifo_rd_int == 1'b1) begin
			word_cnt	<= word_cnt + 1'b1;
		end
	end

	//�����������һ�����ݵ�ʱ���ź���Ч
	always @ (posedge clk) begin
		if(current_state == S_IDLE) begin
			frame_done_reg	<= 1'b0;
		end
		else if((|frame_size_reg == 1'b0)&&(fifo_rd_int == 1'b1)) begin
			frame_done_reg	<= 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  RD ADDR
	//	ÿ����һ����burst�����ַ+1
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//		if((i_rd_ack == 1'b1)&&(able_to_read == 1'b1)) begin	//��һ֡��ʼ��ʱ����ռ���������reading�����ص�ʱ������Ĵ���
		if(current_state == S_IDLE) begin	//��һ֡��ʼ��ʱ����ռ���������reading�����ص�ʱ������Ĵ���
			rd_addr	<= 'b0;
		end
		else if(rd_cmd_reg == 1'b1) begin
			rd_addr	<= rd_addr + 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  �������߼�����JUDGE����
	//	ʱ����Ҫ��˵���ĵ��б���һ��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((current_state == S_REQ)&&(i_rd_ack == 1'b0)) begin
			rd_req_reg	<= 1'b1;
		end
		else begin
			rd_req_reg	<= 1'b0;
		end
	end
	assign	o_rd_req	= rd_req_reg;

	always @ (posedge clk) begin
		if(current_state == S_IDLE) begin
			reading_reg	<= 1'b0;
		end
		else if((i_rd_ack == 1'b1)&&(able_to_read == 1'b1)) begin
			reading_reg	<= 1'b1;
		end
	end
	assign	o_reading	= reading_reg;

	//  -------------------------------------------------------------------------------------
	//	ref FSM ״̬���߼�
	//  -------------------------------------------------------------------------------------
	//FSM Sequential Logic
	always @ (posedge clk) begin
		if(reset == 1'b1) begin
			current_state	<= S_IDLE;
		end
		else begin
			current_state	<= next_state;
		end
	end

	//FSM Conbinatial Logic
	always @ ( * ) begin
		case(current_state)
			S_IDLE :
			//������һ֡�ĳ�����Ҫ������������
			//1 ʹ�ܴ� 2 ��fifo���㹻�Ŀռ� 3 DDR3У�������
			//4 able_to_read �������������һ����ԭ���Ǳ����� IDLE״̬��REQ״̬Ƶ����ת
			//һ�������˶�����ֻ�ж�����һ֡���ݻ��߸�λ �Ż᷵�ص�IDLE״̬
			if((i_frame_en == 1'b1)&&(i_buf_pf == 1'b0)&&(calib_done_shift[1] == 1'b1)&&(able_to_read == 1'b1)) begin
				next_state	<= S_REQ;
			end
			else begin
				next_state	<= S_IDLE;
			end

			//��JUDGEģ������״̬����һ֡�����������ˣ������ܿ�ʼ����Ҫ��JUDGEģ�����룬Ŀ����Ϊ�˱����дͬʱ���빤��״̬
			//��JUDGEģ���������ʱ�򣬸��ݶ�д״̬��֡�������ԣ��ж��Ƿ��пɶ�֡
			//able_to_read�źž��ǵ�ǰ״̬�Ƿ��пɶ�֡���ź�
			S_REQ :
			if((i_rd_ack == 1'b1)&&(able_to_read == 1'b1)) begin
				next_state	<= S_CMD;
			end
			else if((i_rd_ack == 1'b1)&&(able_to_read == 1'b0)) begin
				next_state	<= S_IDLE;
			end
			else begin
				next_state	<= S_REQ;
			end

			//����пɶ�֡����ô��Ҫ��ʼ�������ˡ�
			//����������������3������
			//1 ��FIFO ���㹻�Ŀռ� 2 MCB CMD FIFO û���� 3 ��ǰ�ĵ�ַ�������������
			//���ڶ�ָ����Խ���дָ�룬���Ա��뱣֤����ַҪС��д��ַ
			S_CMD :
			if((able_to_burst == 1'b1)&&(i_p3_cmd_full == 1'b0)&&(i_buf_pf == 1'b0)) begin
				next_state	<= S_RD;
			end
			else begin
				next_state	<= S_CMD;
			end

			//��MCB RD FIFO�е����ݰ��Ƶ� �� FIFO �У�ÿ�ΰ���64��
			S_RD :
			if((word_cnt == 6'b111110)&&(fifo_rd_int == 1'b1)) begin		//��MCB RD FIFO��64������ȫ������
				next_state	<= S_CHK;
			end
			else begin
				next_state	<= S_RD;
			end

			//һ�ζ�burst�����ˣ����һ֡�����Ѿ������ˣ���ô��Ҫ����IDLE�����򣬼�������
			S_CHK :
			if(frame_done_reg == 1'b1) begin								//�ж��Ƿ��Ѿ�������һ֡������
				next_state	<= S_IDLE;
			end
			else begin
				next_state	<= S_CMD;
			end
			default :
			next_state	<= S_IDLE;
		endcase
	end


endmodule
