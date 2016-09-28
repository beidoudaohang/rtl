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
//												3.���ʹ���źţ��ֱ�������֡ͣ���ɺ�����ͣ����
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
	parameter		DATA_WIDTH			= 32		,	//���ݿ��
	parameter		PTR_WIDTH			= 2			,	//��дָ���λ��1-���2֡ 2-���4֡ 3-���8֡ 4-���16֡ 5-���32֡
	parameter		RD_WR_WITH_PRE		= "FALSE"	,	//read write command end with precharge command
	parameter		DDR3_MEM_DENSITY	= "1Gb"		,	//DDR3 ���� "1Gb" "512Mb"
	parameter		TERRIBLE_TRAFFIC	= "TRUE"		//��д���������TRUE-ͬʱ��д��ͬ֡��ͬһ��ַ��FALSE-ͬʱ��дͬһ֡��ͬһ��ַ
	)
	(
	//  -------------------------------------------------------------------------------------
	//  ��Ƶ����ʱ����
	//  -------------------------------------------------------------------------------------
	input						clk					,	//ǰ��ʱ��
	input						reset				,	//ǰ��ʱ�Ӹ�λ�ź�
	input						i_fval				,	//����Ч�ź�
	input						i_sval				,	//������Ч�źţ�section_valid
	input						i_dval				,	//������Ч�ź�
	input	[DATA_WIDTH-1:0]	iv_image_din		,	//ͼ������
	input	[PTR_WIDTH-1:0]		iv_frame_depth		,	//֡�������
	input						i_start_full_frame	,	//ʹ�ܿ��أ���֤һ֡��������
	input						i_start_quick		,	//ʹ�ܿ��أ�����ͣ
	//  -------------------------------------------------------------------------------------
	//  �̶���
	//  -------------------------------------------------------------------------------------
	input	[18:0]				iv_start_addr_sec0	,	//�̶�����0�ε���ʼ��ַ
	input	[18:0]				iv_start_addr_sec1	,	//�̶�����1�ε���ʼ��ַ
	input	[18:0]				iv_start_addr_sec2	,	//�̶�����2�ε���ʼ��ַ
	input	[18:0]				iv_start_addr_sec3	,	//�̶�����3�ε���ʼ��ַ
	input	[18:0]				iv_start_addr_sec4	,	//�̶�����4�ε���ʼ��ַ
	input	[18:0]				iv_start_addr_sec5	,	//�̶�����5�ε���ʼ��ַ
	input	[18:0]				iv_start_addr_sec6	,	//�̶�����6�ε���ʼ��ַ
	input	[18:0]				iv_start_addr_sec7	,	//�̶�����7�ε���ʼ��ַ

	//  -------------------------------------------------------------------------------------
	//  ֡���湤��ʱ����
	//  -------------------------------------------------------------------------------------
	output	[PTR_WIDTH-1:0]		ov_wr_frame_ptr		,	//дָ��
	output	[18:0]				ov_wr_addr			,	//д��ַ
	output						o_wr_req			,	//д���󣬸���Ч
	input						i_wr_ack			,	//д��������Ч
	output						o_writing			,	//����д������Ч
	input	[PTR_WIDTH-1:0]		iv_rd_frame_ptr		,	//��ָ��
	input						i_reading			,	//���ڶ�������Ч
	//  -------------------------------------------------------------------------------------
	//  MCB�˿�
	//  -------------------------------------------------------------------------------------
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
	input						i_p2_wr_empty		, 	//MCB WR FIFO ���źţ�����Ч

	output						o_p4_cmd_en			,	//MCB CMD FIFO д�źţ�����Ч
	output	[2:0]				ov_p4_cmd_instr		,	//MCB CMD FIFO ָ��
	output	[5:0]				ov_p4_cmd_bl		,	//MCB CMD FIFO ͻ������
	output	[29:0]				ov_p4_cmd_byte_addr	,	//MCB CMD FIFO ��ʼ��ַ
	input						i_p4_cmd_empty		,	//MCB CMD FIFO ���źţ�����Ч
	input						i_p4_cmd_full		,	//MCB CMD FIFO ���źţ�����Ч
	output						o_p4_wr_en			,	//MCB WR FIFO д�źţ�����Ч
	output	[3:0]				ov_p4_wr_mask		,	//MCB WR �����ź�
	output	[DATA_WIDTH-1:0]	ov_p4_wr_data		,	//MCB WR FIFO д����
	input						i_p4_wr_full		,	//MCB WR FIFO ���źţ�����Ч
	input						i_p4_wr_empty		 	//MCB WR FIFO ���źţ�����Ч

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
	reg		[63:0]		state_ascii;
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
	reg							fval_dly				= 1'b0;
	wire						fval_rise				;
	wire						fval_fall				;
	reg		[PTR_WIDTH-1:0]		rd_frame_ptr_latch		= 'b0;
	reg							sval_dly				= 1'b0;
	wire						sval_fall				;
	reg		[2:0]				rd_req_shift			= 3'b000;
	wire						rd_req_fall				;

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
	//	1.i_fval��ͬ��ʱ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_dly	<= i_fval;
	end
	assign	fval_rise	= ({fval_dly,i_fval} == 2'b01) ? 1'b1 : 1'b0;
	assign	fval_fall	= ({fval_dly,i_fval} == 2'b10) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	ȡsval����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		sval_dly	<= i_sval;
	end
	assign	sval_fall	= ({sval_dly,i_sval}==2'b10) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	i_rd_req ȡ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		rd_req_shift	<= {rd_req_shift[1:0],i_rd_req};
	end
	assign	rd_req_fall	= (rd_req_shift[2:1]==2'b10) ? 1'b1 : 1'b0;

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
	//	-------------------------------------------------------------------------------------
	//	����������ʱ1�ģ����ʱ�����ܣ�д��ʹ��Ҳ����1��
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		wr_data_reg	<= iv_image_din;
	end
	assign	ov_p2_wr_data	= wr_data_reg	;
	assign	ov_p4_wr_data	= wr_data_reg	;

	//	-------------------------------------------------------------------------------------
	//	����д��ʹ��
	//	--��DDR3У׼�����ʹ�ܴ򿪡��������ݶ���Чʱ������
	//	--����д��p2 p4 ����fifo
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_WR && i_fval==1'b1 && i_sval==1'b1 && i_dval==1'b1) begin
			p2_wr_en	<= wr_fifo_cnt;
		end
		else begin
			p2_wr_en	<= 1'b0;
		end
	end
	assign	o_p2_wr_en	= p2_wr_en;

	always @ (posedge clk) begin
		if(current_state==S_WR && i_fval==1'b1 && i_sval==1'b1 && i_dval==1'b1) begin
			p4_wr_en	<= !wr_fifo_cnt;
		end
		else begin
			p4_wr_en	<= 1'b0;
		end
	end
	assign	o_p4_wr_en	= p4_wr_en;

	//	-------------------------------------------------------------------------------------
	//	д����mask�ź�
	//	1.����mask
	//	-------------------------------------------------------------------------------------
	assign	ov_p2_wr_mask	= 4'b0000;
	assign	ov_p4_wr_mask	= 4'b0000;

	//	-------------------------------------------------------------------------------------
	//	дָ��
	//	1.���ݲ������壬������2�����ʽ
	//	-------------------------------------------------------------------------------------
	assign	ov_p2_cmd_instr	= WR_CMD_INSTR;
	assign	ov_p4_cmd_instr	= WR_CMD_INSTR;

	//	-------------------------------------------------------------------------------------
	//	д����
	//	1.burst_length=word_cnt����ͼ���ва���ʱ�򣬲��Ὣ���������д��DDR
	//	-------------------------------------------------------------------------------------
	assign	ov_p2_cmd_bl	= word_cnt;
	assign	ov_p4_cmd_bl	= word_cnt;

	//	-------------------------------------------------------------------------------------
	//	MCB CMD FIFO д�ź�
	//	1.������ CMD ״̬ʱ�����cmd fifo�������Ϳ���д��һ���µ�����
	//	2.Ҳ�����ǣ�cmd fifo�յ�ʱ�򣬲�д�롣�����Ļ���д�������Ǵ��е�����������֤��д��ͬһ֡ʱ�������ᳬ��д��
	//		���ǣ���mcb λ��ܿ�ʱ��֡���������д�ٶ��п��ܳ���ddr3�������ͻ��С֡���������Ч��
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((current_state==S_CMD)) begin
			if(i_p2_cmd_full==1'b0) begin
				p2_wr_cmd	<= wr_fifo_cnt;
			end
			else begin
				p2_wr_cmd	<= 1'b0;
			end
		end
		else begin
			p2_wr_cmd	<= 1'b0;
		end
	end
	assign	o_p2_cmd_en	= p2_wr_cmd;

	always @ (posedge clk) begin
		if((current_state==S_CMD)) begin
			if(i_p4_cmd_full==1'b0) begin
				p4_wr_cmd	<= !wr_fifo_cnt;
			end
			else begin
				p4_wr_cmd	<= 1'b0;
			end
		end
		else begin
			p4_wr_cmd	<= 1'b0;
		end
	end
	assign	o_p4_cmd_en	= p4_wr_cmd;

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
	reg					wr_req_cnt_clear	= 1'b0;
	reg		[2:0]		wr_req_cnt		= 3'b111;
	//	-------------------------------------------------------------------------------------
	//	д��������������ź�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_REQ) begin
			wr_req_cnt_clear	<= 1'b1;
		end
		else begin
			wr_req_cnt_clear	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  д���������
	//	1.�����ڷ�req״̬��wr_req_cnt����
	//	2.������req״̬��һֱ�ۼӼ���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(wr_req_cnt_clear==1'b1) begin
			wr_req_cnt	<= 3'b0;
		end
		else begin
			if(wr_req_cnt==3'd7) begin
				wr_req_cnt	<= wr_req_cnt;
			end
			else begin
				wr_req_cnt	<= wr_req_cnt + 1'b1;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	д����
	//	--���������Ѿ�����������Է���
	//	-------------------------------------------------------------------------------------
	assign	o_wr_req	= (wr_req_cnt!=3'd7) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//  ����д
	//	1.������idle״̬ʱ������д�ź�����
	//	2.��д����ʱ��д�ź�����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			writing_reg	<= 1'b0;
		end
		//		else if(current_state==S_REQ && able_to_write==1'b1) begin
		else if(current_state==S_REQ) begin
			writing_reg	<= 1'b1;
		end
	end
	assign	o_writing	= writing_reg;

	//	-------------------------------------------------------------------------------------
	//	���� rd frame ptr
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(rd_req_fall) begin
			rd_frame_ptr_latch	<= iv_rd_frame_ptr;
		end
	end



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
		if(p2_wr_cmd==1'b1 || p4_wr_cmd==1'b1) begin
			word_cnt	<= 6'b111111;
		end
		else if(p2_wr_en==1'b1 || p4_wr_en==1'b1) begin
			word_cnt	<= word_cnt + 1'b1;
		end
	end



	//	-------------------------------------------------------------------------------------
	//	sval�½��ؼ�����
	//	-------------------------------------------------------------------------------------
	reg		[xxxxx:0]		sval_cnt	= 'b0;	//log2 �㷨
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			sval_cnt	<= 'b0;
		end
		else if(sval_fall) begin
			sval_cnt	<= sval_cnt + 1'b1;
		end
	end


	reg			sval_fall_reg	= 1'b0;
	//	-------------------------------------------------------------------------------------
	//	sval�½��� ���ּĴ���
	//	--��sval�½���ʱ��Ч��������д����ʱ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(sval_fall==1'b1) begin
			sval_fall_reg	<= 1'b1;
		end
		else if(p2_wr_cmd==1'b1 || p4_wr_cmd==1'b1) begin
			sval_fall_reg	<= 1'b0;
		end
	end
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
		else if(p2_wr_cmd==1'b1 || p4_wr_cmd==1'b1) begin
			if(sval_fall_reg==1'b1) begin
				case(scal_cnt)
					'd0		: wr_addr	<= iv_start_addr_sec0;
					'd1		: wr_addr	<= iv_start_addr_sec1;
					'd2		: wr_addr	<= iv_start_addr_sec2;
					'd3		: wr_addr	<= iv_start_addr_sec3;
					'd4		: wr_addr	<= iv_start_addr_sec4;
					'd5		: wr_addr	<= iv_start_addr_sec5;
					'd6		: wr_addr	<= iv_start_addr_sec6;
					'd7		: wr_addr	<= iv_start_addr_sec7;
					default	: wr_addr	<= iv_start_addr_sec0;
				endcase
			end
			else begin
				wr_addr	<= wr_addr + 1'b1;
			end
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
			if(wr_req_cnt==3'd7) begin
				if(i_reading==1'b1) begin
					if(wr_frame_ptr==frame_depth_reg) begin
						if(rd_frame_ptr_latch==0) begin
							wr_frame_ptr	<= rd_frame_ptr_latch + 1'b1;
						end
						else begin
							wr_frame_ptr	<= 0;
						end
					end
					else if(rd_frame_ptr_latch==frame_depth_reg) begin
						if((wr_frame_ptr+1'b1)==rd_frame_ptr_latch) begin
							wr_frame_ptr	<= 0;
						end
						else begin
							wr_frame_ptr	<= wr_frame_ptr + 1'b1;
						end
					end
					else begin
						if((wr_frame_ptr+1'b1)==rd_frame_ptr_latch) begin
							wr_frame_ptr	<= rd_frame_ptr_latch + 1'b1;
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
			if(fval_rise_reg==1'b1 && enable==1'b1 && calib_done_shift[1]==1'b1) begin
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
				next_state	= S_WR;
			end
			//	-------------------------------------------------------------------------------------
			//	д״̬
			//	1.������ͣ�ɵ�ʱ�򣬲���д�˶������ݣ���������cmd״̬���˴���enable
			//	2.��û������ͣ�ɵ�ʱ��
			//	--��д��63�����ݵ�ʱ��
			//	----�����дһ�����ݣ���MCB WR FIFO��������CMD״̬
			//	----���û��д�źţ�����WR״̬�ȴ�
			//	--������û�м���
			//	----���һ֡�����ˣ�˵��û�ва������ؿ���״̬������Ҫ����cmd
			//	----���һ֡û�н���������WR״̬�ȴ�
			//	--�������Ѿ���������û�м������δ�ֵ
			//	----���һ֡�����ˣ�����cmd״̬�����а�д��MCB��
			//	----���һ�ν����ˣ�����cmd״̬����һ��д��MCB��
			//	----��������ͣ����WR״̬
			//	-------------------------------------------------------------------------------------
			S_WR :
			if(!enable) begin
				next_state	= S_CMD;
			end
			else begin
				if(word_cnt==6'b111110) begin
					if(p2_wr_en==1'b1 || p4_wr_en==1'b1) begin
						next_state	= S_CMD;
					end
					else begin
						next_state	= S_WR;
					end
				end
				else if(word_cnt==6'b111111) begin
					if(fval_shift[1]==1'b0) begin
						next_state	= S_IDLE;
					end
					else begin
						next_state	= S_WR;
					end
				end
				else begin
					if(fval_shift[1]==1'b0) begin
						next_state	= S_CMD;
					end
					else if(sval_fall==1'b1) begin
						next_state	= S_CMD;
					end
					else begin
						next_state	= S_WR;
					end
				end
			end
			//	-------------------------------------------------------------------------------------
			//	����״̬
			//	1.������ͣ�ɵ�ʱ�򣬲���д�˶������ݣ���������cmd״̬���˴���enable
			//	2.��û������ͣ�ɵ�ʱ��
			//	--��cmd fifo������ʱ�򣬿���д���
			//	----���һ֡û�н������ص�wr������д
			//	--��cmd fifo����ʱ�򣬵ȴ�
			//	-------------------------------------------------------------------------------------
			S_CMD :
			if(!enable) begin
				next_state	= S_IDLE;
			end
			else begin
				if(wr_fifo_cnt) begin
					if(i_p2_cmd_full==1'b0) begin
						next_state	= S_WR;
					end
					else begin
						next_state	= S_CMD;
					end
				end
				else begin
					if(i_p4_cmd_full==1'b0) begin
						next_state	= S_WR;
					end
					else begin
						next_state	= S_CMD;
					end
				end
			end
			default :
			next_state	= S_IDLE;
		endcase
	end



endmodule
