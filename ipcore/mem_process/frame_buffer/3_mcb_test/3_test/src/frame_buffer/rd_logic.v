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
//  -- �Ϻ���       :| 2015/3/31 9:31:24	:|  1.�޸�ע��
//												2.֡����ȿɱ䣬1֡-32֡����ÿһ֡�������������ȶ���
//												3.���ʹ���źţ��ֱ�������֡ͣ���ɺ�����ͣ����
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
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module rd_logic # (
	parameter		DATA_WIDTH			= 32		,	//���ݿ��
	parameter		PTR_WIDTH			= 2			,	//��дָ���λ��1-���2֡ 2-���4֡ 3-���8֡ 4-���16֡ 5-���32֡
	parameter		RD_WR_WITH_PRE		= "FALSE"	,	//read write command end with precharge command
	parameter		DDR3_MEM_DENSITY	= "1Gb"		,	//DDR3 ���� "1Gb" "512Mb"
	parameter		FRAME_SIZE_WIDTH	= 25		,	//һ֡��Сλ����DDR3��1Gbitʱ�����������128Mbyte����mcb p3 ��λ����32ʱ��25λ���size���������㹻��
	parameter		TERRIBLE_TRAFFIC	= "TRUE"		//��д���������TRUE-ͬʱ��д��ͬ֡��ͬһ��ַ��FALSE-ͬʱ��дͬһ֡��ͬһ��ַ
	)
	(
	//����ʱ�Ӻ͸�λ
	input							clk					,	//ʱ��
	input							reset				,	//��λ
	//�ⲿ�����ź�
	input	[PTR_WIDTH-1:0]			iv_frame_depth		,	//֡������ȣ���ͬ��
	input	[FRAME_SIZE_WIDTH-1:0]	iv_frame_size		,	//֡�����С����ͬ��
	input							i_chunk_mode_active	,	//chunk����
	input							i_start_full_frame	,	//ʹ�ܿ��أ���֤һ֡��������
	input							i_start_quick		,	//ʹ�ܿ��أ�����ͣ
	//��FIFO
	output							o_reset_back_buf	,	//��FIFO��λ������Ч
	output	[DATA_WIDTH:0]			ov_buf_din			,	//��FIFO�������룬33bit
	output							o_buf_wr_en			,	//��FIFOдʹ�ܣ�����Ч
	input							i_buf_pf			,	//��FIFO�����������Ч
	input							i_buf_full			,	//��FIFO��������Ч
	input							i_buf_empty			,	//��FIFO�գ�����Ч
	input							i_buf_dout32		,	//��FIFO����MSB
	//rd logic
	output	[PTR_WIDTH-1:0]			ov_rd_frame_ptr		,	//��ָ��
	output							o_rd_req			,	//�����󣬸���Ч
	input							i_rd_ack			,	//����������Ч
	output							o_reading			,	//���ڶ�������Ч
	//wr logic
	input	[PTR_WIDTH-1:0]			iv_wr_frame_ptr		,	//дָ��
	input	[18:0]					iv_wr_addr			,	//д��ַ
	input							i_writing			,	//����д�ź�
	//MCB FIFO
	input							i_calib_done		,	//MCBУ׼��ɣ�����Ч
	output							o_p3_cmd_en			,	//MCB CMD дʹ�ܣ�����Ч
	output	[2:0]					ov_p3_cmd_instr		,	//MCB CMD ָ��
	output	[5:0]					ov_p3_cmd_bl		,	//MCB CMD ͻ������
	output	[29:0]					ov_p3_cmd_byte_addr	,	//MCB CMD ��ʼ��ַ
	input							i_p3_cmd_empty		,	//MCB CMD �գ�����Ч
	input							i_p3_cmd_full		,	//MCB CMD ��������Ч
	output							o_p3_rd_en			,	//MCB RD FIFO дʹ�ܣ�����Ч
	input	[DATA_WIDTH-1:0]		iv_p3_rd_data		,	//MCB RD FIFO �������
	input							i_p3_rd_full		,	//MCB RD FIFO ��������Ч
	input							i_p3_rd_empty		,	//MCB RD FIFO �գ�����Ч
	input							i_p3_rd_overflow	,	//MCB RD FIFO ���������Ч
	input							i_p3_rd_error		,	//MCB RD FIFO ��������Ч
	input							i_p2_cmd_empty			//MCB CMD �գ�����Ч
	);

	//	ref signals

	//FSM Parameter Define
	parameter	S_IDLE		= 2'd0;
	parameter	S_REQ		= 2'd1;
	parameter	S_CMD		= 2'd2;
	parameter	S_RD		= 2'd3;

	reg		[1:0]	current_state	= S_IDLE;
	reg		[1:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	reg		[199:0]		state_ascii;
	always @ ( * ) begin
		case(current_state)
			2'd0 :	state_ascii	<= "S_IDLE";
			2'd1 :	state_ascii	<= "S_REQ";
			2'd2 :	state_ascii	<= "S_CMD";
			2'd3 :	state_ascii	<= "S_RD";
		endcase
	end
	// synthesis translate_on

	//	-------------------------------------------------------------------------------------
	//	�̶�����
	//	1.��ָ�븴λֵ��
	//	--��ģ������ʱ��дָ��ĸ�λֵ��1�������ָ��ĸ�λֵ��0��
	//	2.MCBд����
	//	--Ĭ�ϲ���precharge�����ʡһЩ��������
	//	-------------------------------------------------------------------------------------
	localparam	RD_FRAME_PTR_RESET_VALUE	= (TERRIBLE_TRAFFIC=="TRUE") ? 1 : 0;
	localparam	RD_CMD_INSTR				= (RD_WR_WITH_PRE=="TRUE") ? 3'b011 : 3'b001;

	reg		[1:0]					calib_done_shift 	= 2'b0;
	reg		[PTR_WIDTH-1:0]			frame_depth_reg 	= 1;
	reg								start_full_frame_int= 1'b0;
	wire							enable				;
	reg								enable_dly			= 1'b0;
	wire							enable_rise			;
	reg		[FRAME_SIZE_WIDTH-1:0]	frame_size_reg 		= {FRAME_SIZE_WIDTH{1'b0}};
	reg								frame_done_reg 		= 1'b0;
	wire							fifo_rd_int			;
	reg								writing_dly 		= 1'b0;
	wire							writing_rise		;
	reg								reading_dly 		= 1'b0;
	reg								reading 			= 1'b0;
	wire							reading_rise		;
	reg								fresh_frame 		= 1'b0;
	reg								able_to_read 		= 1'b0;
	reg		[PTR_WIDTH-1:0]			rd_frame_ptr 		= RD_FRAME_PTR_RESET_VALUE;
	reg								addr_less_int		= 1'b0;
	reg								fifo_rd_reg 		= 1'b0;
	reg		[5:0]					word_cnt 			= 6'b111111;
	reg		[18:0]					rd_addr 			= 19'b0;
	wire	[1:0]					ctrl_bit			;
	reg								rd_req_reg 			= 1'b0;
	reg								reading_reg 		= 1'b0;
	reg		[18:0]					wr_addr_sub 		= 19'b0;
	reg								addr_less 			= 1'b0;
	reg								rd_cmd_reg 			= 1'b0;
	reg								buf_dout32 			= 1'b0;
	reg								buf_dout32_sync 	= 1'b0;

	reg								back_buf_wr_en		= 1'b0;
	reg		[DATA_WIDTH:0]			back_buf_din		= {(DATA_WIDTH+1){1'b0}};


	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***��ʱ ��ȡ����***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  calib_done ���� mcb drp clk ʱ����
	//  -------------------------------------------------------------------------------------
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
	//	ref ***�Ĵ�����Чʱ��***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	frame_depth_reg ֡����ȼĴ���
	//	1.�ڿ���״̬���� frame_depth
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			frame_depth_reg		<= iv_frame_depth;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	֡�����С
	//	1.��idle״̬����������Ϣ
	//	--����chunkʱ��leader=52byte trailer=32byte
	//	--���ر�chunkʱ��leader=52byte trailer=36byte
	//	2.ÿ����һ�ζ����������-1
	//	3.�����һ��burst���������ݴ���ʵ��������ʱ��frame size reg������������Ѿ������֡������־�����Ҳ������ν��
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			if(!i_chunk_mode_active) begin
				frame_size_reg	<= iv_frame_size + 8'd21 - 1'b1;
			end
			else begin
				frame_size_reg	<= iv_frame_size + 8'd22 - 1'b1;
			end
		end
		else if(fifo_rd_int==1'b1) begin
			frame_size_reg	<= frame_size_reg - 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  ����֡ʹ���ڲ��ź�
	//	1.ֻ��idle״̬�²�������֡ʹ���ź�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			start_full_frame_int	<= i_start_full_frame;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	ʹ���ź�
	//	1.����ʹ���źŵ���������Ϊ���յ�ʹ���ź�
	//  -------------------------------------------------------------------------------------
	assign	enable	= start_full_frame_int & i_start_quick;
	
	//  -------------------------------------------------------------------------------------
	//	ʹ���ź� ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		enable_dly	<= enable;
	end	
	assign	enable_rise	= (enable_dly==1'b0 && enable==1'b1) ? 1'b1 : 1'b0;
	
	//	===============================================================================================
	//	ref ***FIFO MCB ����***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	������
	//	1.�����ڶ�����״̬��ʱ�򣬲ſ��Է���������
	//	2.�����������������
	//	--ʹ�ܹرջ���һ֡����ʱ����������
	//	--��������£��� ��ַ������� �� p3 cmd fifo ���� ʱ�����Է�����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_CMD) begin
			if(enable==1'b0 || frame_done_reg==1'b1) begin
				rd_cmd_reg	<= 1'b0;
			end
			else if(addr_less_int==1'b1 && i_p3_cmd_full==1'b0) begin
				rd_cmd_reg	<= 1'b1;
			end
			else begin
				rd_cmd_reg	<= 1'b0;
			end
		end
		else begin
			rd_cmd_reg	<= 1'b0;
		end
	end
	assign	o_p3_cmd_en		= rd_cmd_reg;

	//	-------------------------------------------------------------------------------------
	//	������
	//	1.ÿ�ζ��ĳ��ȹ̶�Ϊ64
	//	2.֡β���һ��burst�������������ݣ���Ҫ���ⲿ������������
	//	-------------------------------------------------------------------------------------
	assign	ov_p3_cmd_bl 	= 6'b111111;

	//	-------------------------------------------------------------------------------------
	//	��ָ��
	//	1.���ݲ������壬������2�����ʽ
	//	-------------------------------------------------------------------------------------
	assign	ov_p3_cmd_instr	= RD_CMD_INSTR;

	//  -------------------------------------------------------------------------------------
	//	����ַ
	//	1.UG388 pg63 �Ե�ַ�ֲ�����ϸ������
	//	2.��ַ�ֲ�ֻ��ddr3�Ĵ�С�й�
	//	3.ÿ�ζ�д�ĳ�����256yte����ˣ���8bit�̶�Ϊ0
	//	4.512Mb�Ĵ�С����ַҪ��һλ
	//	5.��֡����Ȳ�һ��ʱ��ÿһ֡���Ի������������ǲ�ͬ��
	//  -------------------------------------------------------------------------------------
	//	-------------------------------------------------------------------------------------
	//	���֡�������2֡
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==1 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==1'd0) ? {{4'b0},rd_addr[17:0],{8'b0}} : 	//��֡
			{{4'b0},rd_frame_ptr[0],rd_addr[16:0],{8'b0}}	;			//2֡
		end
		else if(PTR_WIDTH==1 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==1'd0) ? {{3'b0},rd_addr[18:0],{8'b0}} : 	//��֡
			{{3'b0},rd_frame_ptr[0],rd_addr[17:0],{8'b0}}	;			//2֡
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	���֡�������4֡
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==2 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==2'd0) ? {{4'b0},rd_addr[17:0],{8'b0}} : 					//��֡
			(frame_depth_reg==2'd1) ? {{4'b0},rd_frame_ptr[0],rd_addr[16:0],{8'b0}} : 	//2֡
			{{4'b0},rd_frame_ptr[1:0],rd_addr[15:0],{8'b0}}	;							//3 4 ֡
		end
		else if(PTR_WIDTH==2 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==2'd0) ? {{3'b0},rd_addr[18:0],{8'b0}} : 					//��֡
			(frame_depth_reg==2'd1) ? {{3'b0},rd_frame_ptr[0],rd_addr[17:0],{8'b0}} : 	//2֡
			{{3'b0},rd_frame_ptr[1:0],rd_addr[16:0],{8'b0}}	;							//3 4 ֡
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	���֡�������8֡
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==3 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==3'd0) ? {{4'b0},rd_addr[17:0],{8'b0}} : 												//��֡
			(frame_depth_reg==3'd1) ? {{4'b0},rd_frame_ptr[0],rd_addr[16:0],{8'b0}} : 								//2֡
			(frame_depth_reg==3'd2 || frame_depth_reg==3'd3) ? {{4'b0},rd_frame_ptr[1:0],rd_addr[15:0],{8'b0}} :	//3 4 ֡
			{{4'b0},rd_frame_ptr[2:0],rd_addr[14:0],{8'b0}};														//5 - 8 ֡
		end
		else if(PTR_WIDTH==3 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==3'd0) ? {{3'b0},rd_addr[18:0],{8'b0}} : 												//��֡
			(frame_depth_reg==3'd1) ? {{3'b0},rd_frame_ptr[0],rd_addr[17:0],{8'b0}} : 								//2֡
			(frame_depth_reg==3'd2 || frame_depth_reg==3'd3) ? {{3'b0},rd_frame_ptr[1:0],rd_addr[16:0],{8'b0}} :	//3 4 ֡
			{{3'b0},rd_frame_ptr[2:0],rd_addr[15:0],{8'b0}};														//5 - 8 ֡
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	���֡�������16֡
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==4 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==4'd0) ? {{4'b0},rd_addr[17:0],{8'b0}} : 												//��֡
			(frame_depth_reg==4'd1) ? {{4'b0},rd_frame_ptr[0],rd_addr[16:0],{8'b0}} : 								//2֡
			(frame_depth_reg==4'd2 || frame_depth_reg==4'd3) ? {{4'b0},rd_frame_ptr[1:0],rd_addr[15:0],{8'b0}} :	//3 4 ֡
			(frame_depth_reg>=4'd4 && frame_depth_reg<=4'd7) ? {{4'b0},rd_frame_ptr[2:0],rd_addr[14:0],{8'b0}} :	//5 - 8 ֡
			{{4'b0},rd_frame_ptr[3:0],rd_addr[13:0],{8'b0}};														//9 - 16 ֡
		end
		else if(PTR_WIDTH==4 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==4'd0) ? {{3'b0},rd_addr[18:0],{8'b0}} : 												//��֡
			(frame_depth_reg==4'd1) ? {{3'b0},rd_frame_ptr[0],rd_addr[17:0],{8'b0}} : 								//2֡
			(frame_depth_reg==4'd2 || frame_depth_reg==4'd3) ? {{3'b0},rd_frame_ptr[1:0],rd_addr[16:0],{8'b0}} :	//3 4 ֡
			(frame_depth_reg>=4'd4 && frame_depth_reg<=4'd7) ? {{3'b0},rd_frame_ptr[2:0],rd_addr[15:0],{8'b0}} :	//5 - 8 ֡
			{{3'b0},rd_frame_ptr[3:0],rd_addr[14:0],{8'b0}};														//9 - 16 ֡
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	���֡�������32֡
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==5 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==5'd0) ? {{4'b0},rd_addr[17:0],{8'b0}} : 												//��֡
			(frame_depth_reg==5'd1) ? {{4'b0},rd_frame_ptr[0],rd_addr[16:0],{8'b0}} : 								//2֡
			(frame_depth_reg==5'd2 || frame_depth_reg==5'd3) ? {{4'b0},rd_frame_ptr[1:0],rd_addr[15:0],{8'b0}} :	//3 4 ֡
			(frame_depth_reg>=5'd4 && frame_depth_reg<=5'd7) ? {{4'b0},rd_frame_ptr[2:0],rd_addr[14:0],{8'b0}} :	//5 - 8 ֡
			(frame_depth_reg>=5'd8 && frame_depth_reg<=5'd15) ? {{4'b0},rd_frame_ptr[3:0],rd_addr[13:0],{8'b0}} :	//9 - 16 ֡
			{{4'b0},rd_frame_ptr[4:0],rd_addr[12:0],{8'b0}};														//17 - 32 ֡
		end
		else if(PTR_WIDTH==5 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==5'd0) ? {{3'b0},rd_addr[18:0],{8'b0}} : 												//��֡
			(frame_depth_reg==5'd1) ? {{3'b0},rd_frame_ptr[0],rd_addr[17:0],{8'b0}} : 								//2֡
			(frame_depth_reg==5'd2 || frame_depth_reg==5'd3) ? {{3'b0},rd_frame_ptr[1:0],rd_addr[16:0],{8'b0}} :	//3 4 ֡
			(frame_depth_reg>=5'd4 && frame_depth_reg<=5'd7) ? {{3'b0},rd_frame_ptr[2:0],rd_addr[15:0],{8'b0}} :	//5 - 8 ֡
			(frame_depth_reg>=5'd8 && frame_depth_reg<=5'd15) ? {{3'b0},rd_frame_ptr[3:0],rd_addr[14:0],{8'b0}} :	//9 - 16 ֡
			{{3'b0},rd_frame_ptr[4:0],rd_addr[13:0],{8'b0}};														//17 - 32 ֡
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	mcb rd fifo ������
	//	1.����rd״̬
	//	2.mcb rd fifo ���գ����fifo����
	//	-------------------------------------------------------------------------------------
//	assign	fifo_rd_int		= (current_state==S_RD && i_p3_rd_empty==1'b0 && i_buf_full==1'b0) ? 1'b1 : 1'b0;
	assign	fifo_rd_int		= (current_state==S_RD && i_buf_full==1'b0) ? 1'b1 : 1'b0;
	assign	o_p3_rd_en		= fifo_rd_int;

	//  -------------------------------------------------------------------------------------
	//  MCB fifo д�ź�
	//	1.�� mcb rd FIFO ���ź�ͬԴ
	//	2.mcb rd FIFO���� first word fall through���ص㣬�����յ�ʱ�򣬵�һ�������Ѿ��ŵ��˿�����
	//	3.�������һ��burst�п��ܻ��ж�������ݶ����������Ҫ��������������Σ�����д����fifo��
	//	4.���⣬��Ҫд�����λ���Ա�ʶ֡ͷ֡β
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((fifo_rd_int==1'b1 && frame_done_reg==1'b0) || ctrl_bit[1]==1'b1) begin
			back_buf_wr_en	<= 1'b1;
		end
		else begin
			back_buf_wr_en	<= 1'b0;
		end
	end
	assign	o_buf_wr_en	= back_buf_wr_en;

	//	-------------------------------------------------------------------------------------
	//	֡ͷ֡β�Ŀ����ַ�
	//	1.��һ֡��ʼ��ʱ��ctrl_bit=2'b11����ʾ֡ͷ
	//	2.��һ֡��β��ʱ��ctrl_bit=2'b10����ʾ֡β
	//	-------------------------------------------------------------------------------------
	assign	ctrl_bit		= (current_state==S_REQ && i_rd_ack==1'b1 && able_to_read==1'b1) ? 2'b11 :
	(current_state==S_CMD && (enable==1'b0 || frame_done_reg==1'b1)) ? 2'b10 : 2'b00;

	//	-------------------------------------------------------------------------------------
	//	��FIFO����
	//	1.λ��32+1�����λ�� image_valid. 1-ͼ������ 0-��������
	//	2.���ctrl_bit[1]==1��˵����֡ͷ֡β�ı�־��
	//	--д������ݵ�bit0��ʾ֡ͷ֡β��bit0=1 - ֡ͷ��bit0=0 - ֡β
	//	3.���ctrl_bit[1]==0��˵�����������ݡ�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(ctrl_bit[1]) begin
			back_buf_din	<= {1'b0,{(DATA_WIDTH-1){1'b0}},ctrl_bit[0]};
		end
		else begin
			back_buf_din	<= {1'b1,iv_p3_rd_data};
		end
	end
	assign	ov_buf_din	= back_buf_din;

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
	//	assign	o_reset_back_buf	= (~frame_en_int & back_buf_empty_dly1 & buf_dout32_sync) | reset;

	//	//	**************����2**************
	//	//	������FIFO��״̬���ڿ���״̬�жϵ�ʹ��ȡ�����ͻὫ��FIFO���
	//	assign	o_reset_back_buf	= ~frame_en_int;

	//	**************����3**************
	assign	o_reset_back_buf	= reset | enable_rise;

	//	===============================================================================================
	//	ref ***�����ź�***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  ������
	//	1.������req״̬���Ҷ�����=0ʱ������������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_REQ && i_rd_ack==1'b0) begin
			rd_req_reg	<= 1'b1;
		end
		else begin
			rd_req_reg	<= 1'b0;
		end
	end
	assign	o_rd_req	= rd_req_reg;

	//  -------------------------------------------------------------------------------------
	//  ���ڶ�
	//	1.������idle״̬ʱ�����ڶ��ź�����
	//	2.��������ʱ�����ź�����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			reading_reg	<= 1'b0;
		end
		else if(i_rd_ack==1'b1 && able_to_read==1'b1) begin
			reading_reg	<= 1'b1;
		end
	end
	assign	o_reading	= reading_reg;

	//	===============================================================================================
	//	ref ***֡׷�ϲ���***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	��ȥ4֮���д��ַ
	//	1.д cmd fifo����ܻ���4�������˼���д�˿ڷ���������������ǰ��д��ַ-4������ַ�Ͳ��ᳬ��д��ַ
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(iv_wr_addr[18:0]<4) begin
			wr_addr_sub	<= 19'b0;
		end
		else begin
			wr_addr_sub	<= iv_wr_addr - 4;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	��ַ�ж�
	//	1.����д��ͬһ֡��ʱ�򣬶���ַҪС��д��ַ
	//	2.p2�ڿգ�˵���Ѿ��ѵ�ǰ�Ķ���ַ���ͳ�ȥ��
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(rd_addr[18:0] < wr_addr_sub[18:0]) begin
			addr_less	<= 1'b1;
		end
		else begin
			addr_less	<= 1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	�����ĵ�ַ�ж�
	//	1.����дָ����ͬʱ���������д����addr_less_int����
	//	2.����дָ����ͬʱ�����û��д������������
	//	3.����дָ�벻ͬʱ������������
	//	-------------------------------------------------------------------------------------
	always @ ( * ) begin
		if(rd_frame_ptr==iv_wr_frame_ptr) begin
			if(i_writing) begin
				addr_less_int	<= addr_less;
			end
			else begin
				addr_less_int	<= 1'b1;
			end
		end
		else begin
			addr_less_int	<= 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  ��֡�����߼��У���ǰ֡�Ƿ���Ч�źš�
	//	1.��ʹ�ܹرջ���֡����Ȳ���1֡ʱ��fresh_frame����
	//	2.��������£���writing������ʱ��fresh_frame=1����ʾ�����ݿɶ�
	//	3.��������£���reading������ʱ��fresh_frame=0����ʾ�Ѿ���ȡ��ǰ֡
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!enable || frame_depth_reg!=0) begin
			fresh_frame	<= 1'b0;
		end
		else begin
			if(writing_rise == 1'b1) begin
				fresh_frame	<= 1'b1;
			end
			else if(reading_rise == 1'b1) begin
				fresh_frame	<= 1'b0;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	������������ӵ��ʱ������ͬʱ��дͬһ֡
	//	-------------------------------------------------------------------------------------
	generate
		if(TERRIBLE_TRAFFIC=="TRUE") begin
			//	-------------------------------------------------------------------------------------
			//	�������ź�
			//	1.��֡������ǵ�֡ʱ��fresh_frame�����Ƿ���Զ��µ�һ֡
			//	2.��֡������Ƕ�֡��ʱ�������ָ��!=дָ���Ҷ�ָ��!=дָ��-1��˵�����µ����ݿ��Զ������Ҳ�����뵽дָ����
			//	-------------------------------------------------------------------------------------
			always @ ( * ) begin
				if(frame_depth_reg==0) begin
					able_to_read		<= fresh_frame;
				end
				else begin
					if(rd_frame_ptr!=iv_wr_frame_ptr && rd_frame_ptr!=(iv_wr_frame_ptr-1'b1)) begin
						able_to_read	<= 1'b1;
					end
					else begin
						able_to_read	<= 1'b0;
					end
				end
			end
		end
		else begin
			//	-------------------------------------------------------------------------------------
			//	�������ź�
			//	1.��֡������ǵ�֡ʱ��fresh_frame�����Ƿ���Զ��µ�һ֡
			//	2.��֡������Ƕ�֡��ʱ�������ָ��!=дָ�룬˵�����µ����ݿ��Զ����Ϳ��Զ��µ�һ֡
			//	-------------------------------------------------------------------------------------
			always @ ( * ) begin
				if(frame_depth_reg==0) begin
					able_to_read		<= fresh_frame;
				end
				else begin
					if(rd_frame_ptr!=iv_wr_frame_ptr) begin
						able_to_read	<= 1'b1;
					end
					else begin
						able_to_read	<= 1'b0;
					end
				end
			end
		end
	endgenerate

	//	===============================================================================================
	//	ref ***���ݡ���ַ������***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	word_cnt һ��burst������
	//	1.һ��burst�ļ�����������64��
	//	2.����Ҫ���ж�reset����Ϊreset=1���ͻ����idle״̬
	//	3.��һ֡��ʼ��ʱ����ռ���������rd_adddrһͬ���㡣
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			word_cnt	<= 6'b111111;
		end
		else if(fifo_rd_int == 1'b1) begin
			word_cnt	<= word_cnt + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	һ֡����ź�
	//	1.������idleʱ��frame_done_reg=0
	//	2.���������ݶ�����ʱ��frame_done_reg=1
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			frame_done_reg	<= 1'b0;
		end
		else if(|frame_size_reg==1'b0 && fifo_rd_int==1'b1) begin
			frame_done_reg	<= 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  RD ADDR
	//	1.������idleʱ������ַ��λ
	//	2.ÿ������1�����������ַ�ۼ�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			rd_addr	<= 19'b0;
		end
		else if(rd_cmd_reg==1'b1) begin
			rd_addr	<= rd_addr + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	��ָ���߼�
	//	1.��֡�������1֡���߸�λ�ź���Ч����ʹ����Чʱ����ָ�븴λ
	//	2.��������£���д����=1�ҿ��Զ�(��дָ�벻һ��)����ָ������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(frame_depth_reg==0 || reset==1'b1 || enable==1'b0) begin
			rd_frame_ptr	<= RD_FRAME_PTR_RESET_VALUE;
		end
		else begin
			if(i_rd_ack==1'b1 && able_to_read==1'b1) begin
				if(rd_frame_ptr==frame_depth_reg) begin
					rd_frame_ptr	<= 0;
				end
				else begin
					rd_frame_ptr	<= rd_frame_ptr + 1'b1;
				end
			end
		end
	end
	assign	ov_rd_frame_ptr		= rd_frame_ptr;

	//  -------------------------------------------------------------------------------------
	//	ref FSM ״̬���߼�
	//  -------------------------------------------------------------------------------------
	//FSM Sequential Logic
	always @ (posedge clk) begin
		if(reset==1'b1) begin
			current_state	<= S_IDLE;
		end
		else begin
			current_state	<= next_state;
		end
	end

	//FSM Conbinatial Logic
	always @ ( * ) begin
		case(current_state)
			//	-------------------------------------------------------------------------------------
			//	IDLE״̬
			//	1.��ʼһ֡д�����ĳ�����Ҫ����һ����������
			//	--ʹ�ܴ�
			//	--��fifo����
			//	--DDR3У�������
			//	--able_to_read �������������һ����ԭ���Ǳ����� IDLE״̬��REQ״̬Ƶ����ת
			//	2.�����״̬֮��ֻ��һ֡�����˻��߸�λ�����ܻص�IDLE״̬
			//	-------------------------------------------------------------------------------------
			S_IDLE :
			if(enable==1'b1 && i_buf_full==1'b0 && calib_done_shift[1]==1'b1 && able_to_read==1'b1) begin
				next_state	<= S_REQ;
			end
			else begin
				next_state	<= S_IDLE;
			end
			//	-------------------------------------------------------------------------------------
			//	����״̬
			//	1.Ϊ�˱����дͬʱ���빤��״̬����ҪJUDGEģ��������
			//	2.��ACK��1clk���������жϣ����ݵ�ǰ�Ķ�д״̬��֡�������ԣ����Ƿ��пɶ�֡
			//	3.����ʹ��ʱ������idle
			//	4.��ʹ������ʱ
			//	--������Զ��������CMD״̬
			//	--������ܶ����򷵻�idle
			//	5.���judgeû�з�����������ȴ�
			//	-------------------------------------------------------------------------------------
			S_REQ :
			if(!enable) begin
				next_state	<= S_IDLE;
			end
			else begin
				if(i_rd_ack==1'b1 && able_to_read==1'b1) begin
					next_state	<= S_CMD;
				end
				else if(i_rd_ack==1'b1 && able_to_read==1'b0) begin
					next_state	<= S_IDLE;
				end
				else begin
					next_state	<= S_REQ;
				end
			end
			//	-------------------------------------------------------------------------------------
			//	����״̬
			//	1.��ʹ�ܹرջ���һ֡������ʱ�򣬲�Ҫ������������ص�idle״̬
			//	2.��ʹ�ܴ�ʱ���������������
			//	--�����д��ͬһ֡������ַҪС��д��ַ(addr_less_int)
			//	--p3 cmd fifo ����
			//	-------------------------------------------------------------------------------------
			S_CMD :
			if(enable==1'b0 || frame_done_reg==1'b1) begin
				next_state	<= S_IDLE;
			end
			else begin
				if(addr_less_int==1'b1 && i_p3_cmd_full==1'b0) begin
					next_state	<= S_RD;
				end
				else begin
					next_state	<= S_CMD;
				end
			end
			//	-------------------------------------------------------------------------------------
			//	��״̬
			//	1.����MCB�е����ݶ�������֮�󣬷���cmd״̬
			//	2.���û�ж��꣬�������
			//	3.����rd״̬�ж�һ֡�Ƿ���ֻ꣬��cmd״̬�ж�
			//	-------------------------------------------------------------------------------------
			S_RD :
			if(word_cnt==6'b111110 && fifo_rd_int==1'b1) begin
				next_state	<= S_CMD;
			end
			else begin
				next_state	<= S_RD;
			end
			default :
			next_state	<= S_IDLE;
		endcase
	end


endmodule