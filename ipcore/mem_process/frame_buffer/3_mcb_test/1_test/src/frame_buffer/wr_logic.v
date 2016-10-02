//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : wr_logic
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2013/6/3 16:03:55	:|  ��ʼ�汾
//  -- �Ϻ���       :| 2013/8/6 15:35:23	:|  ȥ���� fval_fall_reg ����Ϊfval_shift[1]
//  -- �Ϻ���       :| 2015/3/30 18:29:05	:|  1.�޸�ע��
//												2.֡����ȿɱ䣬1֡-32֡����ÿһ֡�������������ȶ���
//												3.����ʹ���źţ��ֱ�������֡ͣ���ɺ�����ͣ����
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :	д�߼�ģ��
//              1)  : ��ǰ��FIFO�е�����ת�Ƶ�MCB WR FIFO��
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wr_logic # (
	parameter		DATA_WIDTH			= 32		,	//���ݿ���
	parameter		PTR_WIDTH			= 2			,	//��дָ���λ����1-���2֡ 2-���4֡ 3-���8֡ 4-���16֡ 5-���32֡
	parameter		RD_WR_WITH_PRE		= "FALSE"	,	//read write command end with precharge command
	parameter		DDR3_MEM_DENSITY	= "1Gb"		,	//DDR3 ���� "1Gb" "512Mb"
	parameter		TERRIBLE_TRAFFIC	= "TRUE"		//��д���������TRUE-ͬʱ��д��ͬ֡��ͬһ��ַ��FALSE-ͬʱ��дͬһ֡��ͬһ��ַ
	)
	(
	//����ʱ�Ӻ͸�λ
	input						clk					,	//ʱ������
	input						reset				,	//��λ
	//�ⲿ�����ź�
	input	[PTR_WIDTH-1:0]		iv_frame_depth		,	//֡������� ������Ϊ 1 - 31����Ϊ0ʱ�����壬������
	input						i_start_full_frame	,	//ʹ�ܿ��أ���֤һ֡��������
	input						i_start_quick		,	//ʹ�ܿ��أ�����ͣ
	//����Ч�źţ�ͼ��ʱ����
	input						i_fval				,	//����Ч�źţ�����Ч���첽�ź�
	//ǰ��FIFO
	input	[DATA_WIDTH-1:0]	iv_buf_dout			,	//ǰ��FIFO�������
	output						o_buf_rd_en			,	//ǰ��FIFO��ʹ�ܣ�����Ч
	input						i_buf_pe			,	//ǰ��FIFO��̿ձ�־λ������Ч
	input						i_buf_empty			,	//ǰ��FIFO�ձ�־λ������Ч
	//wr logic
	output	[PTR_WIDTH-1:0]		ov_wr_frame_ptr		,	//дָ��
	output	[18:0]				ov_wr_addr			,	//д��ַ
	output						o_writing			,	//����д������Ч
	//judge
	output						o_wr_req			,	//д���󣬸���Ч
	input						i_wr_ack			,	//д����������Ч
	//rd logic
	input	[PTR_WIDTH-1:0]		iv_rd_frame_ptr		,	//��ָ��
	input						i_reading			,	//���ڶ�������Ч
	//MCB FIFO
	input						i_calib_done		,	//MCBУ׼����źţ�����Ч
	output						o_p2_cmd_en			,	//MCB CMD FIFO д�źţ�����Ч
	output	[2:0]				ov_p2_cmd_instr		,	//MCB CMD FIFO ָ��
	output	[5:0]				ov_p2_cmd_bl		,	//MCB CMD FIFO ͻ������
	output	[29:0]				ov_p2_cmd_byte_addr	,	//MCB CMD FIFO ��ʼ��ַ
	input						i_p2_cmd_empty		,	//MCB CMD FIFO ���źţ�����Ч
	input						i_p2_cmd_full		,	//MCB CMD FIFO ���źţ�����Ч

	output						o_p2_wr_en			,	//MCB WR FIFO д�źţ�����Ч
	output	[3:0]				ov_p2_wr_mask		,	//MCB WR �����ź�
	output	[DATA_WIDTH-1:0]	ov_p2_wr_data		,	//MCB WR FIFO д����
	input						i_p2_wr_full		,	//MCB WR FIFO ���źţ�����Ч
	input						i_p2_wr_empty			//MCB WR FIFO ���źţ�����Ч
	);

	//ref signals

	//FSM Parameter Define
	parameter	S_IDLE		= 2'd0;
	parameter	S_REQ		= 2'd1;
	parameter	S_WR		= 2'd2;
	parameter	S_CMD		= 2'd3;

	reg		[1:0]	current_state	= S_IDLE;
	reg		[1:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	reg		[199:0]		state_ascii;
	always @ ( * ) begin
		case(current_state)
			2'd0 :	state_ascii	<= "S_IDLE";
			2'd1 :	state_ascii	<= "S_REQ";
			2'd2 :	state_ascii	<= "S_WR";
			2'd3 :	state_ascii	<= "S_CMD";
		endcase
	end
	// synthesis translate_on

	//	-------------------------------------------------------------------------------------
	//	�̶�����
	//	1.дָ�븴λֵ��
	//	--��ģ������ʱ��дָ��ĸ�λֵ��1������дָ��ĸ�λֵ��0��
	//	2.MCBд����
	//	--Ĭ�ϲ���precharge�����ʡһЩ��������
	//	-------------------------------------------------------------------------------------
	localparam	WR_FRAME_PTR_RESET_VALUE	= (TERRIBLE_TRAFFIC=="TRUE") ? 1 : 0;
	localparam	WR_CMD_INSTR				= (RD_WR_WITH_PRE=="TRUE") ? 3'b010 : 3'b000;

	reg		[1:0]				calib_done_shift 		= 2'b0;
	reg		[2:0]				fval_shift 				= 3'b100;
	wire						fval_rise				;
	wire						fval_fall				;
	reg							buf_rd_reg 				= 1'b0;
	wire						buf_rd_int				;
	reg		[5:0]				word_cnt 				= 6'b111111;
	reg							cmd_en_reg 				= 1'b0;
	reg		[PTR_WIDTH-1:0]		wr_frame_ptr 			= WR_FRAME_PTR_RESET_VALUE;
	reg		[18:0]				wr_addr 				= 19'b0;
	reg							able_to_write 			= 1'b0;
	reg							wr_req_reg 				= 1'b0;
	reg		[PTR_WIDTH-1:0]		frame_depth_reg 		= 1;
	reg							start_full_frame_int	= 1'b0;
	wire						enable					;
	reg							fval_rise_reg 			= 1'b0;
	reg							writing_reg 			= 1'b0;
	reg							wr_cmd_reg 				= 1'b0;


	//ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***��ʱ ��ȡ����***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  calib_done ���� mcb drp clk ʱ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		calib_done_shift	<= {calib_done_shift[0],i_calib_done};
	end

	//  -------------------------------------------------------------------------------------
	//  ��ȡ����Ч������
	//	1.i_fval���첽ʱ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_shift	<= {fval_shift[1:0],i_fval};
	end
	assign	fval_rise	= (fval_shift[2:1] == 2'b01) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_shift[2:1] == 2'b10) ? 1'b1 : 1'b0;

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

	//	===============================================================================================
	//	ref ***���ƼĴ���***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	����Ч���ּĴ���
	//	1.��ʹ����Чʱ�� fval_rise_reg=0 �����������Ա�֤ʹ���ź�=1ʱ�����i_fval����1�����������
	//	2.��ʹ����Чʱ
	//	--2.1��i_fval�����ص�ʱ��fval_rise_reg=1
	//	--2.2��i_fval�½��ص�ʱ��fval_rise_reg=0
	//	3.Ŀ����Ϊ�˱���ס��ʼ��״̬������idle�����ж�һ֡�Ѿ���ʼ��
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!enable) begin
			fval_rise_reg	<= 1'b0;
		end
		else begin
			if(fval_rise == 1'b1) begin
				fval_rise_reg	<= 1'b1;
			end
			else if(fval_fall == 1'b1) begin
				fval_rise_reg	<= 1'b0;
			end
		end
	end

	//	===============================================================================================
	//	ref ***FIFO MCB ����***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  ǰ��FIFO���ź�
	//	1.������д״̬ʱ�����ǰ��fifo���գ���fifo���������ź���Ч
	//	2.������߼�����������ᵼ�¶��������
	//  -------------------------------------------------------------------------------------
	assign	buf_rd_int		= (current_state==S_WR) ? (~i_buf_empty & ~i_p2_wr_full) : 1'b0;
	assign	o_buf_rd_en		= buf_rd_int;

	//  -------------------------------------------------------------------------------------
	//  MCB fifo д�ź�
	//	1.��ǰ��FIFO���ź�ͬԴ
	//	2.ǰ��FIFO���� first word fall through���ص㣬�����յ�ʱ�򣬵�һ�������Ѿ��ŵ��˿�����
	//  -------------------------------------------------------------------------------------
	assign	o_p2_wr_en		= buf_rd_int;

	//  -------------------------------------------------------------------------------------
	//  MCB fifo д����
	//	1.ǰ��FIFO���ֱ���͵�MCB��fifo��
	//	2.ǰ��FIFO���� first word fall through���ص㣬�����յ�ʱ�򣬵�һ�������Ѿ��ŵ��˿�����
	//	3.��ǰ��FIFO��MCB WR FIFO֮��û�м���ˮ�ߣ�Ŀ���Ǽ�����Դ��33 FFs��ʵ�������ﲢ�����ǹؼ�·����
	//  -------------------------------------------------------------------------------------
	assign	ov_p2_wr_data	= iv_buf_dout;

	//	-------------------------------------------------------------------------------------
	//	д����mask�ź�
	//	1.����mask
	//	-------------------------------------------------------------------------------------
	assign	ov_p2_wr_mask	= 4'b0000;

	//	-------------------------------------------------------------------------------------
	//	MCB CMD FIFO д�ź�
	//	1.������ CMD ״̬ʱ�����cmd fifo�������Ϳ���д��һ���µ�����
	//	2.Ҳ�����ǣ�cmd fifo�յ�ʱ�򣬲�д�롣�����Ļ���д�������Ǵ��е�����������֤��д��ͬһ֡ʱ�������ᳬ��д��
	//		���ǣ���mcb λ���ܿ�ʱ��֡���������д�ٶ��п��ܳ���ddr3�������ͻ��С֡���������Ч��
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((current_state==S_CMD)) begin
			wr_cmd_reg	<= ~i_p2_cmd_full;
		end
		else begin
			wr_cmd_reg	<= 1'b0;
		end
	end
	assign	o_p2_cmd_en	= wr_cmd_reg;

	//	-------------------------------------------------------------------------------------
	//	дָ��
	//	1.���ݲ������壬������2�����ʽ
	//	-------------------------------------------------------------------------------------
	assign	ov_p2_cmd_instr	= WR_CMD_INSTR;

	//  -------------------------------------------------------------------------------------
	//	д��ַ
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
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==1'd0) ? {{4'b0},wr_addr[17:0],{8'b0}} : 	//��֡
			{{4'b0},wr_frame_ptr[0],wr_addr[16:0],{8'b0}}	;			//2֡
		end
		else if(PTR_WIDTH==1 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==1'd0) ? {{3'b0},wr_addr[18:0],{8'b0}} : 	//��֡
			{{3'b0},wr_frame_ptr[0],wr_addr[17:0],{8'b0}}	;			//2֡
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	���֡�������4֡
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==2 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==2'd0) ? {{4'b0},wr_addr[17:0],{8'b0}} : 					//��֡
			(frame_depth_reg==2'd1) ? {{4'b0},wr_frame_ptr[0],wr_addr[16:0],{8'b0}} : 	//2֡
			{{4'b0},wr_frame_ptr[1:0],wr_addr[15:0],{8'b0}}	;							//3 4 ֡
		end
		else if(PTR_WIDTH==2 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==2'd0) ? {{3'b0},wr_addr[18:0],{8'b0}} : 					//��֡
			(frame_depth_reg==2'd1) ? {{3'b0},wr_frame_ptr[0],wr_addr[17:0],{8'b0}} : 	//2֡
			{{3'b0},wr_frame_ptr[1:0],wr_addr[16:0],{8'b0}}	;							//3 4 ֡
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	���֡�������8֡
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==3 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==3'd0) ? {{4'b0},wr_addr[17:0],{8'b0}} : 												//��֡
			(frame_depth_reg==3'd1) ? {{4'b0},wr_frame_ptr[0],wr_addr[16:0],{8'b0}} : 								//2֡
			(frame_depth_reg==3'd2 || frame_depth_reg==3'd3) ? {{4'b0},wr_frame_ptr[1:0],wr_addr[15:0],{8'b0}} :	//3 4 ֡
			{{4'b0},wr_frame_ptr[2:0],wr_addr[14:0],{8'b0}};														//5 - 8 ֡
		end
		else if(PTR_WIDTH==3 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==3'd0) ? {{3'b0},wr_addr[18:0],{8'b0}} : 												//��֡
			(frame_depth_reg==3'd1) ? {{3'b0},wr_frame_ptr[0],wr_addr[17:0],{8'b0}} : 								//2֡
			(frame_depth_reg==3'd2 || frame_depth_reg==3'd3) ? {{3'b0},wr_frame_ptr[1:0],wr_addr[16:0],{8'b0}} :	//3 4 ֡
			{{3'b0},wr_frame_ptr[2:0],wr_addr[15:0],{8'b0}};														//5 - 8 ֡
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	���֡�������16֡
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==4 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==4'd0) ? {{4'b0},wr_addr[17:0],{8'b0}} : 												//��֡
			(frame_depth_reg==4'd1) ? {{4'b0},wr_frame_ptr[0],wr_addr[16:0],{8'b0}} : 								//2֡
			(frame_depth_reg==4'd2 || frame_depth_reg==4'd3) ? {{4'b0},wr_frame_ptr[1:0],wr_addr[15:0],{8'b0}} :	//3 4 ֡
			(frame_depth_reg>=4'd4 && frame_depth_reg<=4'd7) ? {{4'b0},wr_frame_ptr[2:0],wr_addr[14:0],{8'b0}} :	//5 - 8 ֡
			{{4'b0},wr_frame_ptr[3:0],wr_addr[13:0],{8'b0}};														//9 - 16 ֡
		end
		else if(PTR_WIDTH==4 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==4'd0) ? {{3'b0},wr_addr[18:0],{8'b0}} : 												//��֡
			(frame_depth_reg==4'd1) ? {{3'b0},wr_frame_ptr[0],wr_addr[17:0],{8'b0}} : 								//2֡
			(frame_depth_reg==4'd2 || frame_depth_reg==4'd3) ? {{3'b0},wr_frame_ptr[1:0],wr_addr[16:0],{8'b0}} :	//3 4 ֡
			(frame_depth_reg>=4'd4 && frame_depth_reg<=4'd7) ? {{3'b0},wr_frame_ptr[2:0],wr_addr[15:0],{8'b0}} :	//5 - 8 ֡
			{{3'b0},wr_frame_ptr[3:0],wr_addr[14:0],{8'b0}};														//9 - 16 ֡
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	���֡�������32֡
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==5 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==5'd0) ? {{4'b0},wr_addr[17:0],{8'b0}} : 												//��֡
			(frame_depth_reg==5'd1) ? {{4'b0},wr_frame_ptr[0],wr_addr[16:0],{8'b0}} : 								//2֡
			(frame_depth_reg==5'd2 || frame_depth_reg==5'd3) ? {{4'b0},wr_frame_ptr[1:0],wr_addr[15:0],{8'b0}} :	//3 4 ֡
			(frame_depth_reg>=5'd4 && frame_depth_reg<=5'd7) ? {{4'b0},wr_frame_ptr[2:0],wr_addr[14:0],{8'b0}} :	//5 - 8 ֡
			(frame_depth_reg>=5'd8 && frame_depth_reg<=5'd15) ? {{4'b0},wr_frame_ptr[3:0],wr_addr[13:0],{8'b0}} :	//9 - 16 ֡
			{{4'b0},wr_frame_ptr[4:0],wr_addr[12:0],{8'b0}};														//17 - 32 ֡
		end
		else if(PTR_WIDTH==5 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==5'd0) ? {{3'b0},wr_addr[18:0],{8'b0}} : 												//��֡
			(frame_depth_reg==5'd1) ? {{3'b0},wr_frame_ptr[0],wr_addr[17:0],{8'b0}} : 								//2֡
			(frame_depth_reg==5'd2 || frame_depth_reg==5'd3) ? {{3'b0},wr_frame_ptr[1:0],wr_addr[16:0],{8'b0}} :	//3 4 ֡
			(frame_depth_reg>=5'd4 && frame_depth_reg<=5'd7) ? {{3'b0},wr_frame_ptr[2:0],wr_addr[15:0],{8'b0}} :	//5 - 8 ֡
			(frame_depth_reg>=5'd8 && frame_depth_reg<=5'd15) ? {{3'b0},wr_frame_ptr[3:0],wr_addr[14:0],{8'b0}} :	//9 - 16 ֡
			{{3'b0},wr_frame_ptr[4:0],wr_addr[13:0],{8'b0}};														//17 - 32 ֡
		end
	endgenerate

	//	===============================================================================================
	//	ref ***�����ź�***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  д����
	//	1.������req״̬����д����=0ʱ������д����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_REQ && i_wr_ack==1'b0) begin
			wr_req_reg	<= 1'b1;
		end
		else begin
			wr_req_reg	<= 1'b0;
		end
	end
	assign	o_wr_req	= wr_req_reg;

	//  -------------------------------------------------------------------------------------
	//  ����д
	//	1.������idle״̬ʱ������д�ź�����
	//	2.��д����ʱ��д�ź�����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			writing_reg	<= 1'b0;
		end
		else if(i_wr_ack==1'b1 && able_to_write==1'b1) begin
			writing_reg	<= 1'b1;
		end
	end
	assign	o_writing	= writing_reg;

	//	===============================================================================================
	//	ref ***֡׷�ϲ���***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  ����д�ź�--ֻ���ڵ�֡
	//	1.�˴�����������߼���������REQ״̬�����
	//	2.ֻ�ڵ�֡ʱ�����źŲ�����Ч�ġ���һ֡���ڶ�ʱ���Ͳ�����д������һ֡������
	//	3.�ڶ�֡ʱ������Ч�ģ���Ϊд���Կ�Խ�������ᶪ��д����
	//  -------------------------------------------------------------------------------------
	always @ ( * ) begin
		if(frame_depth_reg==0) begin
			able_to_write	<= !i_reading;
		end
		else begin
			able_to_write	<= 1'b1;
		end
	end

	//	===============================================================================================
	//	ref ***���ݡ���ַ������***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	word_cnt һ��burst������
	//	1.һ��burst�ļ�����������64��
	//	2.����Ҫ���ж�reset����Ϊreset=1���ͻ����idle״̬
	//	3.��һ֡��ʼ��ʱ����ռ���������wr_adddrһͬ���㡣
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			word_cnt	<= 6'b111111;
		end
		else if(buf_rd_int==1'b1) begin
			word_cnt	<= word_cnt + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	д����
	//	1.burst_length=word_cnt����ͼ���ва���ʱ�򣬲��Ὣ���������д��DDR
	//	-------------------------------------------------------------------------------------
	assign	ov_p2_cmd_bl	= word_cnt;

	//  -------------------------------------------------------------------------------------
	//  д��ַ�߼�
	//	1.��idle״̬�£���ַ����
	//	2.�����ж�reset����Ϊreset=1���ͻ����idle
	//	3.ÿ��д����֮�󣬵�ַ��1
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			wr_addr	<= 19'b0;
		end
		else if(wr_cmd_reg == 1'b1) begin
			wr_addr	<= wr_addr + 1'b1;
		end
	end
	assign	ov_wr_addr	= wr_addr;

	//	-------------------------------------------------------------------------------------
	//	дָ���߼�
	//	1.��֡�������1֡���߸�λ�ź���Ч����ʹ����Чʱ��дָ�븴λ
	//	2.��������£�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(frame_depth_reg==0 || reset==1'b1 || enable==1'b0) begin
			wr_frame_ptr	<= WR_FRAME_PTR_RESET_VALUE;
		end
		else begin
			//	-------------------------------------------------------------------------------------
			//	1.��д����=1ʱ�����������ƶ�дָ�롣��д����=0ʱ���������ƶ�дָ�롣
			//	2.��д����=1�����ڶ�=0ʱ��˵����ģ��û��ռ���κ��ڴ棬дָ������������
			//	3.��д����=1�����ڶ�=1ʱ��˵����ģ���Ѿ�ռ����һ���ڴ棬дָ��Ҫ���ݶ�ָ���״̬�����ж�
			//	--3.1��дָ���Ѿ��ﵽ���ֵʱ
			//	----�����ģ�����ڶ�0���ڴ棬��ôдָ��Ҫ������ָ�룬ʵ��д��Խ
			//	----�����ģ��û���ڶ�0���ڴ棬��ôдָ��д0�ŵ�ַ
			//	--3.2��дָ��û�дﵽ���ֵ�����Ƕ�ָ�뵽�����ֵʱ
			//	----���дָ��+1=��ָ�룬��ôдָ��д0�ŵ�ַ
			//	----���дָ��+1!=��ָ�룬��ôдָ������
			//	--3.3�����������дָ�붼�������ֵ
			//	----���дָ��+1=��ָ�룬��ôдָ��Ҫ������ָ�룬ʵ��д��Խ
			//	----���дָ��+1!=��ָ�룬��ôдָ������
			//	-------------------------------------------------------------------------------------
			if(i_wr_ack==1'b1) begin
				if(i_reading==1'b1) begin
					if(wr_frame_ptr==frame_depth_reg) begin
						if(iv_rd_frame_ptr==0) begin
							wr_frame_ptr	<= iv_rd_frame_ptr + 1'b1;
						end
						else begin
							wr_frame_ptr	<= 0;
						end
					end
					else if(iv_rd_frame_ptr==frame_depth_reg) begin
						if((wr_frame_ptr+1'b1)==iv_rd_frame_ptr) begin
							wr_frame_ptr	<= 0;
						end
						else begin
							wr_frame_ptr	<= wr_frame_ptr + 1'b1;
						end
					end
					else begin
						if((wr_frame_ptr+1'b1)==iv_rd_frame_ptr) begin
							wr_frame_ptr	<= iv_rd_frame_ptr + 1'b1;
						end
						else begin
							wr_frame_ptr	<= wr_frame_ptr + 1'b1;
						end
					end
				end
				else begin
					if(wr_frame_ptr==frame_depth_reg) begin
						wr_frame_ptr	<= 0;
					end
					else begin
						wr_frame_ptr	<= wr_frame_ptr + 1'b1;
					end
				end
			end
		end
	end
	assign	ov_wr_frame_ptr		= wr_frame_ptr;

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
			//	--fval��������Ч
			//	--ǰ��FIFO�е����ݲ��Ǻܶ࣬�����������ݺܶ࣬��ô����֡����п���д�������ˡ�
			//	--�����Ѿ���
			//	--DDR3У�����
			//	--able_to_write ����д��������һ����ԭ���Ǳ����� IDLE״̬��REQ״̬Ƶ����ת
			//	2.����д״̬֮��ֻ��һ֡д���˻��߸�λ�����ܻص�IDLE״̬
			//	-------------------------------------------------------------------------------------
			S_IDLE :
			if(fval_rise_reg==1'b1 && i_buf_pe==1'b1 && enable==1'b1 && calib_done_shift[1]==1'b1 && able_to_write==1'b1) begin
				next_state	= S_REQ;
			end
			else begin
				next_state	= S_IDLE;
			end
			//	-------------------------------------------------------------------------------------
			//	����״̬
			//	1.Ϊ�˱����дͬʱ���빤��״̬����ҪJUDGEģ��������
			//	2.��ACK��1clk���������жϣ����ݵ�ǰ�Ķ�д״̬��֡�������ʣ����Ƿ��пɶ�֡
			//	3.����ʹ��ʱ������idle
			//	4.��ʹ������ʱ
			//	--�������д�������CMD״̬
			//	--�������д���򷵻�idle
			//	5.���judgeû�з�����������ȴ�2
			//	-------------------------------------------------------------------------------------
			S_REQ :
			if(!enable) begin
				next_state	= S_IDLE;
			end
			else begin
				if(i_wr_ack==1'b1 && able_to_write==1'b1) begin
					next_state	= S_WR;
				end
				else if(i_wr_ack==1'b1 && able_to_write==1'b0) begin
					next_state	= S_IDLE;
				end
				else begin
					next_state	= S_REQ;
				end
			end
			//	-------------------------------------------------------------------------------------
			//	д״̬
			//	1.������ͣ�ɵ�ʱ�򣬲���д�˶������ݣ���������cmd״̬���˴���enable
			//	2.��û������ͣ�ɵ�ʱ��
			//	--��д��64�����ݵ�ʱ����Ϊ1��burst����������cmd״̬
			//	--������û�м���������һ֡�����ˣ�˵��û�ва������ؿ���״̬������Ҫ����cmd
			//	--�������Ѿ�����������һ֡�����ˣ�����cmd״̬
			//	-------------------------------------------------------------------------------------
			S_WR :
			if(!enable) begin
				next_state	= S_CMD;
			end
			else begin
				if(word_cnt==6'b111110 && buf_rd_int==1'b1) begin
					next_state	= S_CMD;
				end
				else if(word_cnt==6'b111111 && fval_shift[1]==1'b0 && i_buf_empty==1'b1) begin
					next_state	= S_IDLE;
				end
				else if(fval_shift[1]==1'b0 && i_buf_empty==1'b1) begin
					next_state	= S_CMD;
				end
				else begin
					next_state	= S_WR;
				end
			end
			//	-------------------------------------------------------------------------------------
			//	����״̬
			//	1.������ͣ�ɵ�ʱ�򣬲���д�˶������ݣ���������cmd״̬���˴���enable
			//	2.��û������ͣ�ɵ�ʱ��
			//	--��cmd fifo������ʱ�򣬿���д���
			//	----���ǰ��fifo���ˣ���fval=0��˵��һ֡�Ѿ��������ص�idle
			//	----���һ֡û�н������ص�wr������д
			//	--��cmd fifo����ʱ�򣬵ȴ�
			//	-------------------------------------------------------------------------------------
			S_CMD :
			if(!enable) begin
				next_state	= S_IDLE;
			end
			else begin
				if(i_p2_cmd_full==1'b0) begin
					if(fval_shift[1]==1'b0 && i_buf_empty==1'b1) begin
						next_state	= S_IDLE;
					end
					else begin
						next_state	= S_WR;
					end
				end
				else begin
					next_state	= S_CMD;
				end
			end
			default :
			next_state	= S_IDLE;
		endcase
	end



endmodule