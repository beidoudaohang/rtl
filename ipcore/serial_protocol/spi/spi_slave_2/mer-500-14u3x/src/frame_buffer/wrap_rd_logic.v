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
	parameter						DATA_WD		= 32				,	//�������λ������ʹ��ͬһ���
	parameter						BUF_DEPTH_WD= 4					,	//֡�����λ��,��֤֧�ֵ�֡������ڲ�������������֧��8���,������λλ
	parameter						ADDR_WD   	= 20-BUF_DEPTH_WD	,	//֡�ڵ�ַλ��
	parameter						REG_WD		= 32				,	//�Ĵ������
	parameter						BURST_SIZE	= 7'h40					//BURST_SIZE��С
	)
	(
//  -------------------------------------------------------------------------------------
//  ��Ƶ���ʱ����
//  -------------------------------------------------------------------------------------
	input							clk_vout						,	//��ʱ�ӣ�ͬU3_ITERFACE ģ��ʱ����
	input							i_buf_rd						,	//��ģ���ʹ�ܣ�����Ч��clk_voutʱ����
	output							o_back_buf_empty				,	//��FIFO���źţ�����Ч��clk_voutʱ����
	output							o_frame_valid					,	//��FIFO������Ч�źţ�����Ч��clk_voutʱ����
	output		[DATA_WD-1		:0]	ov_frame_dout					,	//��FIFO������������32bit
//  -------------------------------------------------------------------------------------
//  ��������
//  -------------------------------------------------------------------------------------
	input							i_se_2_fvalrise					,	//ͣ�ɵ���һ֡���ź������źţ�ͣ���ڼ�Ϊ�ͣ�����Ϊ�ߣ�Ϊ�˱���һ֮֡�ڵ���ͬ�������ź�չ��󴫸���ģ�飬clkʱ���򣬵͵�ƽ��־ͣ��
	input		[BUF_DEPTH_WD-1	:0]	iv_frame_depth					,	//֡������ȣ���ͬ��,wrap_wr_logicģ��������Чʱ������
	input		[23				:0]	iv_payload_size					,	//֡�����С����ͬ��,֧��16M����ͼ���С
	input							i_wr_frame_ptr_changing			,	//clk_frame_bufʱ����дָ�����ڱ仯�źţ���ʱ��ָ�벻�ܱ仯
	input							i_chunkmodeactive				,	//clk_frame_bufʱ����chunk�ܿ��أ�chunk����Ӱ��leader��trailer�Ĵ�С��ͨ���ж�chunk���ؿ���֪��leader��trailer����
//  -------------------------------------------------------------------------------------
//  ֡���湤��ʱ����
//  -------------------------------------------------------------------------------------
	input							clk								,	//MCB P3����ʱ��
	input							reset							,	//clkʱ����λ�ź�
	input		[BUF_DEPTH_WD-1	:0]	iv_wr_frame_ptr					,	//дָ��
	input		[ADDR_WD-1		:0]	iv_wr_addr						,	//д��ַ,Ӧ����������Ч֮���д��ַ
	output	reg [BUF_DEPTH_WD-1	:0]	ov_rd_frame_ptr					,	//��ָ��

//  -------------------------------------------------------------------------------------
//  MCB�˿�
//  -------------------------------------------------------------------------------------
	input							i_calib_done					,	//MCBУ׼��ɣ�����Ч
	input							i_p3_cmd_empty					,	//MCB CMD �գ�����Ч
	output	reg						o_p3_cmd_en						,	//MCB CMD дʹ�ܣ�����Ч
	output		[2				:0]	ov_p3_cmd_instr					,	//MCB CMD ָ��
	output		[5				:0]	ov_p3_cmd_bl					,	//MCB CMD ͻ������
	output		[29				:0]	ov_p3_cmd_byte_addr				,	//MCB CMD ��ʼ��ַ
	input		[DATA_WD-1		:0]	iv_p3_rd_data					,	//MCB RD FIFO �������
	input							i_p3_rd_empty					,	//MCB RD FIFO �գ�����Ч
	output							o_p3_rd_en							//MCB RD FIFO ��ʹ�ܣ�����Ч
	);

//  ===============================================================================================
//  ��һ���֣������������ͼĴ�������
//  ===============================================================================================

	parameter						S_IDLE				= 6'b000000	;
	parameter						S_REQ_WAIT			= 6'b000001	;
	parameter						S_REQ				= 6'b000010	;
	parameter						S_CMD_WAIT			= 6'b000100	;
	parameter						S_CMD				= 6'b001000	;
	parameter						S_RD				= 6'b010000	;
	parameter						S_CHK				= 6'b100000	;

	reg			[5				:0]	current_state					;	//current_state
	reg			[5				:0]	next_state						;	//next_state
	reg								cmd_en_reg			= 1'b0		;	//command enable register
	reg			[6				:0]	word_cnt			= BURST_SIZE;	//the number of datas that are writed into MCB data fifo
	reg			[23				:0]	frame_size				 		;	//the num of all the data in current frame
	reg			[23				:0]	frame_size_leader_payload 		;	//the num of the data in leader and payload
	reg			[21				:0]	frame_size_cnt		= 22'h0		;	//the count of frame_size
	reg								able_to_read		= 1'b0		;	//there is enough datas in ddr it can be read
	reg								addr_less			= 1'b0		;	//the addr of reading less than the addr of writing
	reg			[ADDR_WD-1		:0]	rd_addr				= 16'h0		;
	reg			[1				:0]	calib_done_shift	= 2'b00    	;	//the shift registers of i_calib_done
	wire							fifo_full						;	//front fifo full flag
	wire		                    fifo_prog_full			        ;	//front fifo prog_full
	wire		                    fifo_prog_empty			        ;	//front fifo prog_empty
	reg 							after_firstrd_perframe	=1'b0	;	//the first rd flag of very frame
	wire							reset_fifo						;	//the reset of backbuffer
	wire							w_wr_leader_payload_en			;	//enable leader and payload wr
	wire							w_wr_trailer_en					;	//enable trailer wr
	wire							w_wr_en							;
	reg			[1				:0]	se_2_fvalrise_shift				;
	wire							w_buf_rd						;
	reg								reading_trailer					;
	reg			[6				:0]	trailer_length					;
//  -------------------------------------------------------------------------------------
//	FSM for sim
//  -------------------------------------------------------------------------------------

// synthesis translate_off
	integer			state_ascii;
	always @ ( * ) begin
		case(current_state)
			 6'b000000 :	state_ascii	<= "S_IDLE";
			 6'b000001 :	state_ascii	<= "S_REQ_WAIT";
			 6'b000010 :	state_ascii	<= "S_REQ";
			 6'b000100 :	state_ascii	<= "S_CMD_WAIT";
			 6'b001000 :	state_ascii	<= "S_CMD";
			 6'b010000 :	state_ascii	<= "S_RD";
			 6'b100000 :	state_ascii	<= "S_CHK";
		endcase
	end
// synthesis translate_on


//  ===============================================================================================
//  �ڶ����֣������߼�
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	֡���������ݣ����������־:
//	�����Ҫ��֤��������ǰ��������
//	1��дָ�롢д��ַ�������ڶ�ָ�롢����ַ�仯
//	2��дָ�롢д��ַҪͬʱ�仯��һ��ʱ���ڱ仯
//	1����֡��ַָ�벻ͬʱ���Ҷ�ָ���ַ��Ϊ��ʱ���Զ���
//	2����֡��ַָ����ͬʱ������ַС��д��ַʱ���Զ���
//  -------------------------------------------------------------------------------------
	always @ (posedge clk)
	begin
		se_2_fvalrise_shift <= {se_2_fvalrise_shift[0],i_se_2_fvalrise};
	end

	always @ (posedge clk)
	begin
		if( iv_wr_frame_ptr != ov_rd_frame_ptr )
		begin
			if( iv_wr_addr == 0)
			begin
				able_to_read <= 1'b0;
			end
			else
			begin
				able_to_read <= 1'b1;
			end
		end
		else if ( rd_addr < iv_wr_addr  )
		begin
			able_to_read <= 1'b1;
		end
		else
		begin
			able_to_read <= 1'b0;
		end
	end

//  -------------------------------------------------------------------------------------
//	�ź���λ
//  -------------------------------------------------------------------------------------
	always @ (posedge clk )
	begin
		calib_done_shift	<= {calib_done_shift[0],i_calib_done};
	end

//  -------------------------------------------------------------------------------------
//	����֡��д��������frame_size=leader size + payload size + trailer size
//	��ֻ����ͣ���ڼ����
//	chunk�Ƿ��ͷ���Ȳ�ͬ
//  -------------------------------------------------------------------------------------

	always @ (posedge clk)
	begin
		if( ~se_2_fvalrise_shift[1] )
		begin
			frame_size_leader_payload <= iv_payload_size + 24'h34;	//payload + leader
		end
	end

	always @ (posedge clk)
	begin
		if( ~se_2_fvalrise_shift[1] )
		begin
			if ( i_chunkmodeactive )		//chunkʹ��   leader length + trailer length
			begin
				trailer_length <= 7'h24;
			end
			else							//chunk��ʹ�� leader length + trailer length
			begin
				trailer_length <= 7'h20;
			end
		end
	end

	always @ (posedge clk)
	begin
		if( ~se_2_fvalrise_shift[1] )
		begin
			if ( frame_size_leader_payload[7:0] == 0  )
				frame_size <= frame_size_leader_payload + trailer_length;
			else
				frame_size <= {frame_size_leader_payload[23:8],8'h00}+24'h200;
		end
	end

//  ===============================================================================================
//  �ڶ����֣�״̬�����
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	��һ��
//  -------------------------------------------------------------------------------------
	always @ (posedge clk )
	begin
		if(reset)
		begin
			current_state	<=	S_IDLE;
		end
		else
		begin
			current_state	<=	next_state;
		end
	end
//  -------------------------------------------------------------------------------------
//	�ڶ���
//  -------------------------------------------------------------------------------------
	always @  *
	begin
		next_state = S_IDLE;
		case( current_state )
			S_IDLE	:
			begin											//DDRУ����ɣ����Զ�ȡ�����fifo�ɱ�̱�־����������
				if ( calib_done_shift[1] && able_to_read && ~fifo_prog_full && se_2_fvalrise_shift[1] )
				begin
					next_state = S_REQ_WAIT;
				end
				else
				begin
					next_state = S_IDLE;
				end
			end
			S_REQ_WAIT:										//��ͣ��
			begin
				 if (~se_2_fvalrise_shift[1] )
				begin
					next_state = S_IDLE;
				end
				else if(i_wr_frame_ptr_changing)
				begin
					next_state = S_REQ_WAIT;
				end
				else
				begin
					next_state = S_REQ;
				end
			end
			S_REQ	:
			begin											//��д��ָ��仯ʱ��ָ���ۼ�
				next_state = S_CMD_WAIT;
			end
			S_CMD_WAIT	:
			begin
				if (~se_2_fvalrise_shift[1] )				//��ͣ��
				begin
					next_state = S_IDLE;
				end
				else if ( i_p3_cmd_empty && ~fifo_prog_full && able_to_read)		//����FIFO���Һ��fifoδ�������ݿɶ�����ת����״̬
				begin
					next_state = S_CMD;
				end
				else										//����FIFO���գ������ȴ���������Ϊ�˱�֤�����DDRʵ�ʶ���ַ��Ӧ��ȷ
				begin
					next_state = S_CMD_WAIT;
				end
			end
			S_CMD	:
			begin
				next_state = S_RD;
			end
			S_RD	:
			begin
				if (word_cnt == BURST_SIZE)					//1�������������ۼƴ�burst
				begin
					next_state = S_CHK;
				end
				else if (~se_2_fvalrise_shift[1] && (word_cnt == BURST_SIZE) )
				begin
					next_state = S_IDLE;
				end
				else										//2�������ݶ�����������burst������
				begin
					next_state = S_RD;
				end
			end
			S_CHK	:
			begin
				if ( frame_size_cnt >= frame_size[23:2] )
				begin
					next_state = S_IDLE;
				end
				else
				begin
					next_state = S_CMD_WAIT;
				end
			end
		endcase
	end
//  -------------------------------------------------------------------------------------
//	������
//  -------------------------------------------------------------------------------------
	always @ ( posedge clk  )
	begin
		if ( reset )
		begin
			o_p3_cmd_en				<=	1'b0			;
			rd_addr					<=	{ADDR_WD{1'b0}}	;
			frame_size_cnt			<=	22'h0			;
			word_cnt				<=	7'h0			;
			ov_rd_frame_ptr			<= {BUF_DEPTH_WD{1'b0}};
			reading_trailer			<= 1'b0				;
		end
		else
		begin
			begin
				o_p3_cmd_en			<=	1'b0			;
			end
			case( next_state )
				S_IDLE	:
				begin
					o_p3_cmd_en		<=	1'b0			;
					frame_size_cnt	<=	22'h0			;
					word_cnt		<=	7'h0			;
					reading_trailer	<=  1'b0			;
					if(~se_2_fvalrise_shift[1])
					begin												//ֹͣ�ɼ�ָ�븴λ
						ov_rd_frame_ptr	<= {BUF_DEPTH_WD{1'b0}};
						rd_addr			<=	{ADDR_WD{1'b0}}	;
					end
				end
				S_REQ	:
				begin
					rd_addr					<=	{ADDR_WD{1'b0}}	;
					if ( ov_rd_frame_ptr != iv_wr_frame_ptr )
					begin
						if ( ov_rd_frame_ptr == iv_frame_depth-1 )
						begin
							ov_rd_frame_ptr	<=	{BUF_DEPTH_WD{1'b0}};
						end
						else
						begin
							ov_rd_frame_ptr <= ov_rd_frame_ptr + 1;
						end
					end
				end
				S_CMD_WAIT	:
				begin
					o_p3_cmd_en			<=  1'b0			;
				end
				S_CMD	:
				begin
					word_cnt			<=	7'h0			;
					o_p3_cmd_en			<=	1'b1			;
					if ( rd_addr ==	 {{(ADDR_WD-1){1'b1}},1'b0})
						begin
							reading_trailer <= 1'b1;
						end
				end
				S_RD	:
				begin
					o_p3_cmd_en			<=	1'b0			;
					if ( o_p3_rd_en )
						begin
							word_cnt		<=	word_cnt + 1;
							frame_size_cnt	<=	frame_size_cnt + 1;
						end
					if ( o_p3_cmd_en )
						begin
							if ( rd_addr == frame_size_leader_payload[23:8] )
								rd_addr		<=	 {{(ADDR_WD-1){1'b1}},1'b0};
							else
								rd_addr		<=	rd_addr + 1;
						end
				end
				S_CHK	:
				begin
					word_cnt			<=	7'h0;
					reading_trailer 	<= 	1'b0;
				end
			endcase
		end
	end
//  ===============================================================================================
//  �������֣�P3�ںͺ��FIFO��Ŀ����߼�
//  ===============================================================================================
	assign	o_p3_rd_en 				= (~i_p3_rd_empty) && (~fifo_full) &&(word_cnt < BURST_SIZE);	//�ǿռ���,�ۼƲ�����BURST_SIZE
	assign	w_wr_leader_payload_en  = (frame_size_cnt < frame_size_leader_payload[23:2]) && o_p3_rd_en ;
	assign	w_wr_trailer_en			= (reading_trailer && word_cnt < trailer_length[6:2]) && o_p3_rd_en ;
	assign	w_wr_en					= (w_wr_leader_payload_en || w_wr_trailer_en ) && (!reset_fifo);
	assign	ov_p3_cmd_instr			= 3'b001;										//����Ԥ���Ķ�����Ϊ������������Ԥ���
	assign	ov_p3_cmd_bl			= 6'h3f;										//burstlenth 64*4
	assign	ov_p3_cmd_byte_addr    	= {{2'b00},ov_rd_frame_ptr,rd_addr,{8'h00}};	//��ַָ��ƴ�ӣ�ָ֡��+����ַ+8'h00
	assign	w_buf_rd				= i_buf_rd &&(!reset_fifo);
//  ===============================================================================================
//  ���Ĳ��֣�FIFO����
//  ===============================================================================================
//	ϵͳ��λ����ͣ��
	assign  reset_fifo = reset || !se_2_fvalrise_shift[1];

	fifo_w32d256_pf180_pe6 fifo_w32d256_pf180_pe6_inst (
	.rst			(reset_fifo			), 	// input rst
	.wr_clk			(clk	            ), 	// input wr_clk
	.rd_clk			(clk_vout           ), 	// input rd_clk
	.din			(iv_p3_rd_data      ), 	// input [31 : 0] din
	.wr_en			(w_wr_en			), 	// input wr_en
	.rd_en			(w_buf_rd			), 	// input rd_en
	.dout			(ov_frame_dout		), 	// output [31 : 0] dout
	.full			(fifo_full		    ), 	// output full
	.empty			(o_back_buf_empty   ), 	// output empty
	.valid			(o_frame_valid		), 	// output valid
	.prog_full		(fifo_prog_full	    ), 	// output prog_full
	.prog_empty		(fifo_prog_empty	) 	// output prog_empty
	);
endmodule
