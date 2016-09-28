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
//`include			"frame_buffer_def.v"
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wr_logic # (
	parameter		RD_WR_WITH_PRE		= "FALSE"	,//read write command end with precharge command
	parameter		DDR3_MEM_DENSITY	= "1Gb"		//DDR3 ���� "1Gb" "512Mb"
	)
	(
	//����ʱ�Ӻ͸�λ
	input						clk					,
	input						reset				,
	//�ⲿ�����ź�
	input	[2:0]				iv_frame_depth		,//֡������� ������Ϊ 1 2 4
	input						i_frame_en			,//ʹ�ܿ���
	//����Ч�źţ�ͼ��ʱ����
	input						i_fval				,//����Ч�źţ�����Ч���첽�ź�
	//ǰ��FIFO
	input	[31:0]				iv_buf_dout			,//ǰ��FIFO�������
	output						o_buf_rd_en			,//ǰ��FIFO��ʹ�ܣ�����Ч
	input						i_buf_pe			,//ǰ��FIFO��̿ձ�־λ������Ч
	input						i_buf_empty			,//ǰ��FIFO�ձ�־λ������Ч
	//wr logic
	output	[1:0]				ov_wr_frame_ptr		,//дָ��
	output	[16:0]				ov_wr_addr			,//д��ַ
	output						o_writing			,//����д������Ч
	//judge
	output						o_wr_req			,//д���󣬸���Ч
	input						i_wr_ack			,//д��������Ч
	//rd logic
	input	[1:0]				iv_rd_frame_ptr		,//��ָ��
	input						i_reading			,//���ڶ�������Ч
	//MCB FIFO
	input						i_calib_done		,//MCBУ׼����źţ�����Ч
	output						o_p2_cmd_en			,//MCB CMD FIFO д�źţ�����Ч
	output	[2:0]				ov_p2_cmd_instr		,//MCB CMD FIFO ָ��
	output	[5:0]				ov_p2_cmd_bl		,//MCB CMD FIFO ͻ������
	output	[29:0]				ov_p2_cmd_byte_addr	,//MCB CMD FIFO ��ʼ��ַ
	input						i_p2_cmd_empty		,//MCB CMD FIFO ���źţ�����Ч
	input						i_p2_cmd_full		,//MCB CMD FIFO ���źţ�����Ч

	output						o_p2_wr_en			,//MCB WR FIFO д�źţ�����Ч
	output	[3:0]				ov_p2_wr_mask		,//MCB WR �����ź�
	output	[31:0]				ov_p2_wr_data		,//MCB WR FIFO д����
	input						i_p2_wr_full		,//MCB WR FIFO ���źţ�����Ч
	input						i_p2_wr_empty		//MCB WR FIFO ���źţ�����Ч
	);

	//ref signals

	//FSM Parameter Define
	parameter	S_IDLE		= 2'd0;
	parameter	S_REQ		= 2'd1;
	parameter	S_WR		= 2'd2;
	parameter	S_CMD		= 2'd3;

	reg		[1:0]	current_state;
	reg		[1:0]	next_state;

	//FSM for sim
	// synthesis translate_off
	integer			state_ascii;
	always @ ( * ) begin
		case(current_state)
			2'd0 :	state_ascii	<= "S_IDLE";
			2'd1 :	state_ascii	<= "S_REQ";
			2'd2 :	state_ascii	<= "S_WR";
			2'd3 :	state_ascii	<= "S_CMD";
		endcase
	end
	// synthesis translate_on

	reg		[1:0]				calib_done_shift 	= 2'b0;
	reg		[2:0]				fval_shift 			= 3'b100;
	wire						fval_rise			;
	wire						fval_fall			;

	reg							buf_rd_reg 			= 1'b0;
	wire						buf_rd_int			;
	reg		[5:0]				word_cnt 			= 6'b111111;
	reg							cmd_en_reg 			= 1'b0;


	`ifdef	TERRIBLE_TRAFFIC			//��������˷��濪�����������дָ�븴λ��10λ��
		reg		[1:0]				wr_frame_ptr 		= 2'b01;
	`else
		reg		[1:0]				wr_frame_ptr 		= 2'b00;
	`endif

	reg		[16:0]				wr_addr 			= 17'b0;
	reg							able_to_write 		= 1'b0;
	reg							wr_req_reg 			= 1'b0;
	reg		[2:0]				frame_depth_d 		= 3'b0;
	reg		[2:0]				frame_depth_reg 	= 3'b0;
	reg							fval_rise_reg 		= 1'b0;
	wire						frame_en_int		;
	reg							writing 			= 1'b0;
	reg							wr_cmd_reg 			= 1'b0;


	//ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//  calib_done ���� mcb drp clk ʱ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		calib_done_shift	<= {calib_done_shift[0],i_calib_done};
	end

	//  -------------------------------------------------------------------------------------
	//  ����Ч������
	//  -------------------------------------------------------------------------------------

	//�첽�źŲ���
	always @ (posedge clk) begin
		fval_shift	<= {fval_shift[1:0],i_fval};
	end

	assign	fval_rise	= (fval_shift[2:1] == 2'b01) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_shift[2:1] == 2'b10) ? 1'b1 : 1'b0;

	always @ (posedge clk) begin
		if(reset) begin
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

	//�ڳ���Ч������ʱ���� frame_depth
	//��λ��֡�������Ϊ0��֡������������ⲿ���Ƶģ���Ҫ�ⲿ�ṩһ����ʼֵ��
	//���ⲿ���õ���ֵ���� 1 2 4ʱ��������һ����ȷ���õ���ֵ��
	always @ (posedge clk) begin
		if(reset) begin
			frame_depth_reg		<= iv_frame_depth;
		end else begin
			if(fval_rise == 1'b1) begin
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

	//  -------------------------------------------------------------------------------------
	//  �ڲ���������ʹ�ܿ���
	//  -------------------------------------------------------------------------------------
	assign	frame_en_int	= (current_state == S_IDLE) ? i_frame_en : 1'b1;

	//  -------------------------------------------------------------------------------------
	//  ��ǰ��FIFO
	//  -------------------------------------------------------------------------------------
	//���뿼��MCB WR FIFO ����״̬��
	assign	buf_rd_int		= (current_state == S_WR) ? (~i_buf_empty & ~i_p2_wr_full) : 1'b0;
	assign	o_buf_rd_en		= buf_rd_int;

	//��ǰ��FIFO��MCB WR FIFO֮��û�м���ˮ�ߣ�Ŀ���Ǽ�����Դ��33 FFs��ʵ�������ﲢ�����ǹؼ�·����
	assign	o_p2_wr_en		= buf_rd_int;
	assign	ov_p2_wr_data	= iv_buf_dout;
	assign	ov_p2_wr_mask	= 4'b0000;

	//һ��burst�ļ�����������64��
	always @ (posedge clk) begin
		if(current_state == S_IDLE) begin		//��һ֡��ʼ��ʱ����ռ���������wr_adddrһͬ���㡣
			word_cnt	<= 6'b111111;
		end
		else if(buf_rd_int == 1'b1) begin
			word_cnt	<= word_cnt + 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  CMD FIFO
	//  -------------------------------------------------------------------------------------
	//	assign	cmd_en_int	= (current_state == S_CMD) ? (~i_p2_cmd_full) : 1'b0;
	//	assign	o_p2_cmd_en	= cmd_en_int;	//������߼���������һ��ff

	always @ (posedge clk) begin
		if((current_state == S_CMD)) begin
			wr_cmd_reg	<= ~i_p2_cmd_full;
		end
		else begin
			wr_cmd_reg	<= 1'b0;
		end
	end

	assign	o_p2_cmd_en	= wr_cmd_reg;

	generate
		if(RD_WR_WITH_PRE=="TRUE") begin
			assign	ov_p2_cmd_instr	= 3'b010;	//write with auto precharge
		end
		else begin
			assign	ov_p2_cmd_instr	= 3'b000;		//write without auto precharge
		end
	endgenerate

	assign	ov_p2_cmd_bl	= word_cnt;		//�˴�������word_cnt����ͼ���ва���ʱ�򣬲��Ὣ���������д��DDR

	//  -------------------------------------------------------------------------------------
	//  д��ַ�߼�
	//  -------------------------------------------------------------------------------------
	//ÿ��дburst֮�󣬵�ַ�ۼ�
	always @ (posedge clk) begin
		if((i_wr_ack == 1'b1)&&(able_to_write == 1'b1)) begin		//��һ֡��ʼ��ʱ����ռ���������writing�����ص�ʱ������Ĵ���
			wr_addr	<= 'b0;
			//		end else if(cmd_en_int == 1'b1) begin
		end
		else if(wr_cmd_reg == 1'b1) begin
			wr_addr	<= wr_addr + 1;
		end
	end
	assign	ov_wr_addr	= wr_addr;

	//  -------------------------------------------------------------------------------------
	//  �������߼�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((current_state == S_REQ)&&(i_wr_ack == 1'b0)) begin
			wr_req_reg	<= 1'b1;
		end
		else begin
			wr_req_reg	<= 1'b0;
		end
	end
	assign	o_wr_req	= wr_req_reg;

	always @ (posedge clk) begin
		if(current_state == S_IDLE) begin
			writing	<= 1'b0;
		end
		else if((i_wr_ack == 1'b1)&&(able_to_write == 1'b1)) begin
			writing	<= 1'b1;
		end
	end

	assign	o_writing	= writing;
	//  -------------------------------------------------------------------------------------
	//  дָ���߼�
	//  -------------------------------------------------------------------------------------

	//�˴α���������߼�
	always @ ( * ) begin
		case(frame_depth_reg)
			3'b001 :		//1 frame	��������ʱ�򣬾Ϳ���д
			begin
				able_to_write		<= !i_reading;
			end
			3'b010 :		//2 frames	д����֡
			begin
				able_to_write		<= 1'b1;
			end
			3'b100 :		//4 frames	д����֡
			begin
				able_to_write		<= 1'b1;
			end
			default :
			begin
				able_to_write		<= 1'b0;					//���ô���״̬������������ת
			end
		endcase
	end

	assign	ov_wr_frame_ptr				= wr_frame_ptr;
	//	assign	ov_p2_cmd_byte_addr			= {{3'b0},wr_frame_ptr,wr_addr,{8'b0}};
	//  -------------------------------------------------------------------------------------
	//	UG388 pg63 �Ե�ַ�ֲ�����ϸ������
	//	��ַ�ֲ�ֻ��ddr3�Ĵ�С�й�
	//	ÿ�ζ�д�ĳ�����256yte����ˣ���8bit�̶�Ϊ0
	//	512Mb�Ĵ�С����ַҪ��һλ
	//  -------------------------------------------------------------------------------------
	generate
		if(DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p2_cmd_byte_addr	= {{4'b0},wr_frame_ptr,wr_addr[15:0],{8'b0}};
		end
		else begin
			assign	ov_p2_cmd_byte_addr	= {{3'b0},wr_frame_ptr,wr_addr[16:0],{8'b0}};
		end
	endgenerate

	always @ (posedge clk) begin
		case(frame_depth_reg)
			3'b001 :						//1 frame
			wr_frame_ptr	<= 'b0;
			3'b010 :						//2 frames
			if(frame_en_int == 1'b0) begin			//������IDLE״̬��ʹ�ܹرյ�ʱ��ָ�븴λ
				wr_frame_ptr	<= 'b0;
			end
			else begin
				if(i_wr_ack == 1'b1) begin											//��д�����cycle���ƶ�дָ��
					if(i_reading == 1'b1) begin
						if(wr_frame_ptr[0] == ~iv_rd_frame_ptr[0]) begin			//��ģ�����ڶ���Ҫд����һ֡���ָ����ͬ
							wr_frame_ptr[1]	<= 1'b0;								//2֡������MSB�̶�Ϊ0
							wr_frame_ptr[0]	<= wr_frame_ptr[0];						//LSB���䣬��ʵ����֡����
						end
						else begin												//��ģ�����ڶ���Ҫд����һ֡���ָ�벻��ͬ
							wr_frame_ptr[1]	<= 1'b0;								//2֡������MSB�̶�Ϊ0
							wr_frame_ptr[0]	<= ~wr_frame_ptr[0];					//LSBȡ����ʵ����+1����
						end
					end
					else begin													//��ģ�鲻�ڶ���дָ����Խ�������һ֡
						wr_frame_ptr[1]	<= 1'b0;									//2֡������MSB�̶�Ϊ0
						wr_frame_ptr[0]	<= ~wr_frame_ptr[0];						//LSBȡ����ʵ����+1����
					end
				end
			end
			3'b100 :						//4 frames
			if(frame_en_int == 1'b0) begin			//������IDLE״̬��ʹ�ܹرյ�ʱ��ָ�븴λ
				`ifdef	TERRIBLE_TRAFFIC			//��������˷��濪�����������дָ�븴λ��10λ��
					wr_frame_ptr	<= 2'b01;
				`else
					wr_frame_ptr	<= 2'b00;
				`endif
			end
			else begin
				if(i_wr_ack == 1'b1) begin											//��д�����cycle���ƶ�дָ��
					if(i_reading == 1'b1) begin
						if((wr_frame_ptr + 1) == iv_rd_frame_ptr) begin				//��ģ�����ڶ���Ҫд����һ֡���ָ����ͬ
							wr_frame_ptr	<= iv_rd_frame_ptr + 1;					//д��ַ=����ַ+1��ʵ����֡����
						end
						else begin												//��ģ�����ڶ���Ҫд����һ֡���ָ�벻��ͬ
							wr_frame_ptr	<= wr_frame_ptr + 1;					//д��ַ����
						end
					end
					else begin													//��ģ�鲻�ڶ���дָ����Խ�������һ֡
						wr_frame_ptr	<= wr_frame_ptr + 1;						//д��ַ����
					end
				end
			end
			default :
			//			wr_frame_ptr	<= 'b0;		//֡������ȸı��ʱ��дָ�벻��λ��ֻ��ʹ��ȡ����ʱ�򣬲ŻḴλ��
			;
		endcase
	end

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

			//��ʼһ֡д�����ĳ�����Ҫ����һ����������
			//1 fval��������Ч
			//2 ǰ��FIFO�е����ݲ��Ǻܶ�
			//3 �����Ѿ���
			//4 DDR3У�����
			//����д״̬֮��ֻ��һ֡д���˻��߸�λ�����ܻص�IDLE״̬
			S_IDLE :
			if((fval_rise_reg == 1'b1)&&(i_buf_pe == 1'b1)&&(i_frame_en == 1'b1)&&(calib_done_shift[1] == 1'b1)) begin
				next_state	= S_REQ;
			end
			else begin
				next_state	= S_IDLE;
			end

			//Ϊ�˱����дͬʱ���빤��״̬����ҪJUDGEģ��������
			//��ACK��1clk���������жϣ����ݵ�ǰ�Ķ�д״̬��֡�������ʣ����Ƿ��пɶ�֡
			S_REQ :
			if((i_wr_ack == 1'b1)&&(able_to_write == 1'b1)) begin
				next_state	= S_WR;
			end
			else if((i_wr_ack == 1'b1)&&(able_to_write == 1'b0)) begin
				next_state	= S_IDLE;
			end
			else begin
				next_state	= S_REQ;
			end

			//ǰ��FIFO�����գ��Ͱ�����ת�Ƶ� MCB WR FIFO ��
			//ÿ��д64�����ݣ�����һ��burst
			//fval���½�����Ϊ��һ֡�Ľ����ź�
			S_WR :
			if((word_cnt == 6'b111110)&&(buf_rd_int == 1'b1)) begin			//���������ˣ�����һ��дburst
				next_state	= S_CMD;
				//			end else if((word_cnt == 6'b111111)&&(fval_fall_reg == 1'b1)&&(i_buf_empty == 1'b1)) begin	//������û�м���������һ֡�����ˣ�˵��û�ва������ؿ���״̬
			end
			else if((word_cnt == 6'b111111)&&(fval_shift[1] == 1'b0)&&(i_buf_empty == 1'b1)) begin	//������û�м���������һ֡�����ˣ�˵��û�ва������ؿ���״̬

				next_state	= S_IDLE;
				//			end else if((fval_fall_reg == 1'b1)&&(i_buf_empty == 1'b1)) begin	//������û������һ֡�Ѿ�������ǰ��FIFO����
			end
			else if((fval_shift[1] == 1'b0)&&(i_buf_empty == 1'b1)) begin	//������û������һ֡�Ѿ�������ǰ��FIFO����
				next_state	= S_CMD;
			end
			else begin
				next_state	= S_WR;
			end

			//��cmd fifo������ʱ�򣬿���д����
			S_CMD :
			if(i_p2_cmd_full == 1'b0) begin				//���CMD FIFO������־λ
				//				if((i_buf_empty == 1'b1)&&(fval_fall_reg == 1'b1)) begin			//ǰ��FIFO���˲����½���Ҳ���ˣ�˵��һ֡���е����ݶ������ˣ����س�ʼ״̬
				if((i_buf_empty == 1'b1)&&(fval_shift[1] == 1'b0)) begin			//ǰ��FIFO���˲��ҳ���Ч��Ч��˵��һ֡���е����ݶ������ˣ����س�ʼ״̬
					next_state	= S_IDLE;
				end
				else begin							//ǰ��FIFOû�пգ�˵���������ݲ�����FIFO��
					next_state	= S_WR;
				end
			end
			else begin
				next_state	= S_CMD;
			end
			default :
			next_state	= S_IDLE;
		endcase
	end



endmodule
