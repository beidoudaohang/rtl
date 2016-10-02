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
	//	parameter						WORD_FACTOR			= 3					,	//DATA_WD��Ӧ��һ��������Ӧ���ֽ���
	parameter	DATA_WD								= 64			,	//�������λ������ʹ��ͬһ���
	parameter	BACK_DATA_WD						= 32			,	//����������λ��
	parameter	ADDR_WD   							= 19			,	//֡�ڵ�ַλ�� 19=30-2-9,9bit��64λ��864��Ⱦ�����128M��Ӧ27λ��wr_frame_ptr��һ����λbit����-2
	parameter	PTR_WIDTH							= 2				,	//��дָ���λ��1-���2֡ 2-���4֡ 3-���8֡ 4-���16֡ 5-���32֡
	parameter	BURST_SIZE							= 32			,	//BURST_SIZE��С
	parameter	DDR3_MASK_SIZE						= 8				,	//mask size
	parameter	ADDR_DUMMY_BIT						= 9				,	//MCB BYTE ADDR ��λΪ0�ĸ���
	parameter	DDR3_MEM_DENSITY					= "1Gb"			,	//DDR3 ���� "2Gb" "1Gb" "512Mb"
	parameter	REG_WD  							= 32				//�Ĵ���λ��
	)
	(
	//	===============================================================================================
	//	ͼ�����ʱ����
	//	===============================================================================================
	input							clk_vout						,	//��ʱ�ӣ�ͬU3_ITERFACE ģ��ʱ����
	input							i_buf_rd						,	//��ģ���ʹ�ܣ�����Ч��clk_voutʱ����
	output							o_buf_empty						,	//��FIFO���źţ�����Ч��clk_voutʱ����
	output	[BACK_DATA_WD-1:0]		ov_dout							,	//��FIFO������������32bit
	//	===============================================================================================
	//	֡���湤��ʱ����
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  �� wrap_wr_logic ����
	//  -------------------------------------------------------------------------------------
	input							clk								,	//MCB ����ʱ��
	input							reset							,	//clkʱ����λ�ź�
	input	[PTR_WIDTH-1:0]			iv_wr_ptr						,	//дָ��
	input	[ADDR_WD-1:0]			iv_wr_addr						,	//д��ַ,Ӧ����������Ч֮���д��ַ
	output	[PTR_WIDTH-1:0]			ov_rd_ptr						,	//��ָ��
	//  -------------------------------------------------------------------------------------
	//  ��������
	//  -------------------------------------------------------------------------------------
	input							i_se_2_fvalrise					,	//ͣ�ɵ���һ֡���ź������źţ�ͣ���ڼ�Ϊ�ͣ�����Ϊ�ߣ�Ϊ�˱���һ֮֡�ڵ���ͬ�������ź�չ��󴫸���ģ�飬clkʱ���򣬵͵�ƽ��־ͣ��
	input	[PTR_WIDTH-1:0]			iv_frame_depth					,	//֡������ȣ���ͬ��,wrap_wr_logicģ��������Чʱ������
	input	[BYTE_ADDR_WD-1:0]		iv_payload_size					,	//֡�����С����ByteΪ��λ
	input							i_wr_ptr_changing				,	//дָ�����ڱ仯�źţ���ʱ��ָ�벻�ܱ仯
	input							i_chunk_mode_active				,	//chunk�ܿ��أ�chunk����Ӱ��leader��trailer�Ĵ�С��ͨ���ж�chunk���ؿ���֪��leader��trailer����
	//  -------------------------------------------------------------------------------------
	//  MCB�˿�
	//  -------------------------------------------------------------------------------------
	input							i_calib_done					,	//MCBУ׼��ɣ�����Ч
	input							i_rd_cmd_empty					,	//MCB CMD �գ�����Ч
	output							o_rd_cmd_en						,	//MCB CMD дʹ�ܣ�����Ч
	output	[2:0]					ov_rd_cmd_instr					,	//MCB CMD ָ��
	output	[5:0]					ov_rd_cmd_bl					,	//MCB CMD ͻ������
	output	[29:0]					ov_rd_cmd_byte_addr				,	//MCB CMD ��ʼ��ַ
	input	[DATA_WD-1:0]			iv_rd_data						,	//MCB RD FIFO �������
	input							i_rd_empty						,	//MCB RD FIFO �գ�����Ч
	output							o_rd_en								//MCB RD FIFO ��ʹ�ܣ�����Ч
	);






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
			frame_size_leader_payload <= iv_payload_size + 'h34;	//payload + leader
		end
	end

	always @ (posedge clk)
	begin
		if( ~se_2_fvalrise_shift[1] )
		begin
			if ( i_chunkmodeactive )								//chunkʹ��
			begin
				trailer_length <= 'h24;
			end
			else													//chunk��ʹ��
			begin
				trailer_length <= 'h20;
			end
		end
	end

	always @ (posedge clk)
	begin
		if( ~se_2_fvalrise_shift[1] )
		begin
			if ( frame_size_leader_payload[BSIZE_WD-1:0] == 0  )	//�ܱ�512������Ҳ����һ��burst���ֽ���
			frame_size <= frame_size_leader_payload + trailer_length;
			else
			frame_size <= {frame_size_leader_payload[FSIZE_WD-1:BSIZE_WD],{BSIZE_WD{1'b0}}} + {{2'b10},{BSIZE_WD{1'b0}}};	//������ʱ��������trailer�ֱ��ռһ��burst������+2����burst����
		end
	end

	//��Ҫ���������ݵ�ֵ�����frame_size_leader_payloadֵ����8�ı�������Ҫ��ȡ��
	always @ ( posedge clk  )
	begin
		if ( frame_size_leader_payload[WORD_FACTOR-1] )		//ͼ���С��4�ı������������8�ı���������ֵ��Ҫ+1�������һ��8bytes
		begin
			read_data_word	<=	frame_size_leader_payload[FSIZE_WD-1:WORD_FACTOR]+1;
		end
		else
		begin
			read_data_word	<=	frame_size_leader_payload[FSIZE_WD-1:WORD_FACTOR];
		end
	end


	//��Ҫ���������ݵ�ֵ�����frame_size_leader_payloadֵ����8�ı�������Ҫ��ȡ��
	always @ ( posedge clk  )
	begin
		if ( frame_size[WORD_FACTOR-1] )					//ͼ���С��4�ı������������8�ı���������ֵ��Ҫ+1�������һ��8bytes
		begin
			fram_size_word	<=	frame_size[FSIZE_WD-1:WORD_FACTOR]+1;
		end
		else
		begin
			fram_size_word	<=	frame_size[FSIZE_WD-1:WORD_FACTOR];
		end
	end
	//
	always @ ( posedge clk  )
	begin
		if ( trailer_length[WORD_FACTOR-1] )				//ͼ���С��4�ı������������8�ı���������ֵ��Ҫ+1�������һ��8bytes
		begin
			trailer_length_word	<=	trailer_length[6:WORD_FACTOR]+1;
		end
		else
		begin
			trailer_length_word	<=	trailer_length[6:WORD_FACTOR];
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
				else if ( i_p_out_cmd_empty && ~fifo_prog_full && able_to_read)		//����FIFO���Һ��fifoδ�������ݿɶ�����ת����״̬
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
				if (word_cnt == BURST_SIZE)							//1�������������ۼƴ�burst
				begin
					next_state = S_CHK;
				end
				else if (~se_2_fvalrise_shift[1] && (word_cnt == BURST_SIZE) )
				begin
					next_state = S_IDLE;
				end
				else												//2�������ݶ�����������burst������
				begin
					next_state = S_RD;
				end
			end
			S_CHK	:
			begin
				if ( frame_size_cnt >= fram_size_word )
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
			o_p_out_cmd_en			<=	1'b0					;
			rd_addr					<=	{ADDR_WD{1'b0}}			;
			frame_size_cnt			<=	{(FSIZE_WD-4){1'b0}	}	;
			word_cnt				<=	7'h0					;
			ov_rd_frame_ptr			<= {BUF_DEPTH_WD{1'b0}}		;
			reading_trailer			<= 1'b0						;
		end
		else
		begin
			begin
				o_p_out_cmd_en		<=	1'b0					;
			end
			case( next_state )
				S_IDLE	:
				begin
					o_p_out_cmd_en	<=	1'b0					;
					frame_size_cnt	<=	{(FSIZE_WD-4){1'b0}	}	;
					word_cnt		<=	7'h0					;
					reading_trailer	<=  1'b0					;
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
					o_p_out_cmd_en			<=  1'b0			;
				end
				S_CMD	:
				begin
					word_cnt			<=	7'h0			;
					o_p_out_cmd_en			<=	1'b1			;
					if ( rd_addr ==	 {{(ADDR_WD-1){1'b1}},1'b0})
					begin
						reading_trailer <= 1'b1;
					end
				end
				S_RD	:
				begin
					o_p_out_cmd_en			<=	1'b0			;
					if ( o_p_out_rd_en )
					begin
						word_cnt		<=	word_cnt + 1;
						frame_size_cnt	<=	frame_size_cnt + 1;
					end
					if ( o_p_out_cmd_en )
					begin
						if ( rd_addr == frame_size_leader_payload[FSIZE_WD-1:BSIZE_WD] )	//���������ۼӵ�leader��payload����ʱ������ַ��Ϊ�����ֵ��׼��дβ��
						rd_addr		<=	{{(ADDR_WD-1){1'b1}},1'b0};
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

	assign	o_p_out_rd_en 			= (~i_p_out_rd_empty) && (~fifo_full) &&(word_cnt < BURST_SIZE);	//�ǿռ���,�ۼƲ�����BURST_SIZE
	assign	w_wr_leader_payload_en  = (frame_size_cnt < read_data_word) && o_p_out_rd_en ;
	assign	w_wr_trailer_en			= (reading_trailer && word_cnt < trailer_length_word) && o_p_out_rd_en ;
	assign	w_wr_en					= (w_wr_leader_payload_en || w_wr_trailer_en ) && (!reset_fifo);
	assign	ov_p_out_cmd_instr		= 3'b001;															//����Ԥ���Ķ�����Ϊ������������Ԥ���
	assign	ov_p_out_cmd_bl			= 6'h3f;															//burstlenth 64*4
	assign	ov_p_out_cmd_byte_addr  = {{2'b00},ov_rd_frame_ptr,rd_addr,{BSIZE_WD{1'b0}}};				//��ַָ��ƴ�ӣ�ָ֡��+����ַ+BSIZE_WD'h00
	assign	w_buf_rd				= i_buf_rd &&(!reset_fifo);
	//  ===============================================================================================
	//  ���Ĳ��֣�FIFO����
	//  ===============================================================================================
	//	ϵͳ��λ����ͣ��
	assign  reset_fifo = reset || !se_2_fvalrise_shift[1];
	//	FIFO 64bitתΪ32bit����32λ����������Խ����ߵ�32bit����
	fifo_w64d256_pf180_pe6 fifo_w64d256_pf180_pe6_inst (
	.rst			(reset_fifo			),
	.wr_clk			(clk	            ),
	.rd_clk			(clk_vout           ),
	.din			({iv_p_out_rd_data[GPIF_DAT_WIDTH-1:0],iv_p_out_rd_data[DATA_WD-1:GPIF_DAT_WIDTH]}),
	.wr_en			(w_wr_en			),
	.rd_en			(w_buf_rd			),
	.dout			(ov_frame_dout		),
	.full			(fifo_full		    ),
	.empty			(o_back_buf_empty   ),
	.valid			(o_frame_valid		),
	.prog_full		(fifo_prog_full	    ),
	.prog_empty		(fifo_prog_empty	)
	);
endmodule
