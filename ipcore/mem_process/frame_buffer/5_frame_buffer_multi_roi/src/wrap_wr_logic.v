//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : wrap_wr_logic
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2013/6/14 14:00:40	:|  ��ʼ�汾
//  -- ��ǿ         :| 2014/11/27 10:16:54	:|  ��ֲ��MER-U3V���̣����ݲ�ƷҪ���ʵ��޸�
//  -- ��ǿ         :| 2015/10/15 17:22:35	:|  ��port����չΪ64bit���
//  -- �Ϻ���       :| 2016/9/14 16:25:07	:|  ��ROI�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :	֡����ģ�鶥��
//						1�����֡ͼ��ǰ��FIFO����д��Ͷ�����MCBP2������д��Ĺ���
//						2�����дָ�루ͼ���������ַ�任��д��ַ���ֽڼ������任�Լ�����������������
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
module wrap_wr_logic # (
	parameter	DATA_WD										= 64		,	//�������λ������ʹ��ͬһ���
	parameter	ADDR_WD   									= 19		,	//֡�ڵ�ַλ�� 19=30-2-9,9bit��64λ��864��Ⱦ�����128M��Ӧ27λ��wr_frame_ptr��һ����λbit����-2
	parameter	PTR_WIDTH									= 2			,	//��дָ���λ��1-���2֡ 2-���4֡ 3-���8֡ 4-���16֡ 5-���32֡
	parameter	BURST_SIZE									= 32		,	//BURST_SIZE��С
	parameter	DDR3_MASK_SIZE								= 8			,	//mask size
	parameter	ADDR_DUMMY_BIT								= 9			,	//MCB BYTE ADDR ��λΪ0�ĸ���
	parameter	DDR3_MEM_DENSITY							= "1Gb"		,	//DDR3 ���� "2Gb" "1Gb" "512Mb"
	parameter	SENSOR_MAX_WIDTH							= 1280		,	//Sensor��������Ч���
	parameter	REG_WD  						 			= 32			//�Ĵ���λ��
	)
	(
	//	===============================================================================================
	//	ͼ������ʱ����
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  ͼ����������
	//  -------------------------------------------------------------------------------------
	input							clk_vin								,	//ǰ��FIFOд������ʱ��
	input							i_fval								,	//����Ч�źţ�����Ч��clk_vinʱ����,i_fval��������Ҫ��i_dval����������ǰ��i_fval���½���Ҫ��i_dval���½����ͺ�i_fval��i_dval������֮��Ҫ���㹻�Ŀ�϶����Сֵ��MAX(6*clk_vin,6*clk_frame_buf)��i_fval��i_dval�½���֮��Ҫ���㹻�Ŀ�϶����Сֵ��1*clk_vin + 7*clk_frame_buf
	input							i_dval								,	//������Ч�źţ�����Ч��clk_vinʱ����������Ч�������ź�һ�������������Ƕ������ź�
	input							i_leader_flag						,	//ͷ����־
	input							i_image_flag						,	//ͼ���־
	input							i_chunk_flag						,	//chunk��־
	input							i_trailer_flag						,	//β����־
	input	[DATA_WD-1:0]			iv_image_din						,	//ͼ�����ݣ�32λ��clk_vinʱ����
	input							i_stream_en_clk_in					,	//��ֹͣ�źţ�clk_inʱ�����ź���Чʱ������������֡д��֡�棬��Чʱ����ֹͣд�룬����λ��д��ַָ�룬��֡��
	output							o_buf_full							,	//ǰ��FIFO ��
	output							o_buf_overflow						,	//֡��ǰ��FIFO��� 0:֡��ǰ��FIFOû����� 1:֡��ǰ��FIFO���ֹ����������
	//	===============================================================================================
	//	֡���湤��ʱ����
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  �� wrap_rd_logic ����
	//  -------------------------------------------------------------------------------------
	input							clk									,	//MCB P2����ʱ��
	input							reset								,	//
	output	[PTR_WIDTH-1:0]			ov_wr_ptr							,	//дָ��,��֡Ϊ��λ
	output	[ADDR_WD-1:0]			ov_wr_addr							,	//P2������ʹ���źţ���־д��ַ�Ѿ���Ч�����ٲñ�֤�£������ܹ�д��DDR�����źŶԵ�ַ�жϷǳ���Ҫ
	output							o_wr_ptr_changing					,	//дָ�����ڱ仯�źţ��������ģ�飬��ʱ��ָ�벻�ܱ仯
	input	[PTR_WIDTH-1 :0]		iv_rd_ptr							,	//��ָ��,��֡Ϊ��λ
	output							o_se_2_fvalrise						,	//ͣ�ɵ���һ֡���ź������أ�Ϊ�˱���һ֮֡�ڵ���ͬ�������ź�չ��󴫸���ģ�飬clkʱ���򣬵͵�ƽ��־ͣ��
	//  -------------------------------------------------------------------------------------
	//  ��������
	//  -------------------------------------------------------------------------------------
	input							i_stream_en							,	//��ֹͣ�źţ�clkʱ�����ź���Чʱ������������֡д��֡�棬��Чʱ����ֹͣд�룬����λ��д��ַָ�룬��֡��
	input	[PTR_WIDTH-1:0]			iv_frame_depth						,	//֡������� ������Ϊ 0 - 31.
	//  -------------------------------------------------------------------------------------
	//  MCB�˿�
	//  -------------------------------------------------------------------------------------
	input							i_calib_done						,	//MCBУ׼����źţ�����Ч
	output							o_wr_cmd_en							,	//MCB CMD FIFO д�źţ�����Ч
	output	[2:0]					ov_wr_cmd_instr						,	//MCB CMD FIFO ָ��
	output	[5:0]					ov_wr_cmd_bl						,	//MCB CMD FIFO ͻ������
	output	[29:0]					ov_wr_cmd_byte_addr					,	//MCB CMD FIFO ��ʼ��ַ
	input							i_wr_cmd_empty						,	//MCB CMD FIFO ���źţ�����Ч
	output							o_wr_en								,	//MCB WR FIFO д�źţ�����Ч
	output	[DDR3_MASK_SIZE-1:0]	ov_wr_mask							,	//MCB WR �����ź�
	output	[DATA_WD-1:0]			ov_wr_data							,	//MCB WR FIFO д����
	input							i_wr_full								//MCB WR FIFO ���źţ�����Ч
	);

	localparam		MAX_LINE_DATA				= SENSOR_MAX_WIDTH*2;			//BIT10 12 ģʽ�� һ�е�������
	localparam		MIN_FRONT_FIFO_DEPTH		= MAX_LINE_DATA/(DATA_WD/8);	//ǰ��fifo��ȵ���Сֵ
	localparam		FRONT_FIFO_DEPTH			= (MIN_FRONT_FIFO_DEPTH<=256) ? 256 : ((MIN_FRONT_FIFO_DEPTH<=512) ? 512 : ((MIN_FRONT_FIFO_DEPTH<=1024) ? 1024 : 2048));




	//	-------------------------------------------------------------------------------------
	//	ȡ��������ȡ��
	//	-------------------------------------------------------------------------------------
	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction



	//	-------------------------------------------------------------------------------------
	//	front fifo ����
	//	-------------------------------------------------------------------------------------
	generate
		if(FRONT_FIFO_DEPTH==256) begin
			frame_buf_front_fifo_w69d256_pe128 frame_buf_front_fifo_w69d256_pe128_inst (
			.rst			(reset_fifo		),
			.wr_clk			(clk_vin		),
			.wr_en			(wr_en			),
			.full			(full			),
			.din			(din			),
			.rd_clk			(clk			),
			.rd_en			(rd_en			),
			.empty			(empty			),
			.prog_empty		(prog_empty		),
			.dout			(dout			)
			);
		end
		else if(FRONT_FIFO_DEPTH==512) begin
			frame_buf_front_fifo_w69d512_pe256 frame_buf_front_fifo_w69d512_pe256_inst (
			.rst			(reset_fifo		),
			.wr_clk			(clk_vin		),
			.wr_en			(wr_en			),
			.full			(full			),
			.din			(din			),
			.rd_clk			(clk			),
			.rd_en			(rd_en			),
			.empty			(empty			),
			.prog_empty		(prog_empty		),
			.dout			(dout			)
			);
		end
		else if(FRONT_FIFO_DEPTH==1024) begin
			frame_buf_front_fifo_w69d1024_pe512 frame_buf_front_fifo_w69d1024_pe512_inst (
			.rst			(reset_fifo		),
			.wr_clk			(clk_vin		),
			.wr_en			(wr_en			),
			.full			(full			),
			.din			(din			),
			.rd_clk			(clk			),
			.rd_en			(rd_en			),
			.empty			(empty			),
			.prog_empty		(prog_empty		),
			.dout			(dout			)
			);
		end
		else if(FRONT_FIFO_DEPTH==2048) begin
			frame_buf_front_fifo_w69d2048_pe1024 frame_buf_front_fifo_w69d2048_pe1024_inst (
			.rst			(reset_fifo		),
			.wr_clk			(clk_vin		),
			.wr_en			(wr_en			),
			.full			(full			),
			.din			(din			),
			.rd_clk			(clk			),
			.rd_en			(rd_en			),
			.empty			(empty			),
			.prog_empty		(prog_empty		),
			.dout			(dout			)
			);
		end
	endgenerate






	//  ===============================================================================================
	//  �ڶ����֣�clk_vinʱ�������߼���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	���źŽ�����λ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_vin)
	begin
		favl_shift_clk_vin	<= {favl_shift_clk_vin[1:0],i_fval};
	end

	always @ (posedge clk )
	begin
		trailer_flag_fifoout_shift	<= {trailer_flag_fifoout_shift[3:0],trailer_flag_fifoout};
	end

	always @ (posedge clk )
	begin
		wr_flag_shift	<= {wr_flag_shift[0],wr_flag};
	end

	//  -------------------------------------------------------------------------------------
	//	ȡ���źŵ�������/�½��أ�������/�½��ر�־��ʵ��������/�½�����ʱ3��ʱ��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_vin)
	begin
		if ( favl_shift_clk_vin[2:1] == 2'b01 ) begin
			fval_rise_edge_clk_vin	=	1'b1;
		end
		else begin
			fval_rise_edge_clk_vin	=	1'b0;
		end
	end
	//  -------------------------------------------------------------------------------------
	//	��i_stream_en����ʱ����ͬ����ͬ����clk_vin
	//  -------------------------------------------------------------------------------------

	always @ (posedge clk)
	begin
		if( ~i_stream_en )								//��ͣ���ڼ�һֱ��λ
		begin
			o_se_2_fvalrise	<= 1'b0;
		end
		else if ( favl_shift_clk[2:1] == 2'b01 )		//ֱ�����ź������ص���
		begin
			o_se_2_fvalrise	<= 1'b1;
		end
	end


	always @ (posedge clk_vin)
	begin
		if( ~i_stream_en_clk_in )						//��ͣ���ڼ�һֱ��λ
		begin
			se_2_fvalrise_clk_in	<= 1'b0;
		end
		else if ( favl_shift_clk_vin[2:1] == 2'b01 )	//ֱ�����ź������ص���
		begin
			se_2_fvalrise_clk_in	<= 1'b1;
		end
	end
	//  -------------------------------------------------------------------------------------
	//	ʹ�ó��źŵ������غ�ͣ����Ϊfifo��λ�źţ�ͣ�ɸ�λ�����ڸ�λ���
	//	�г�ͬʱ��Чʱ������Ч
	//	��λ�ڼ䲻��д�룬������źŻ��쳣
	//  -------------------------------------------------------------------------------------
	assign	reset_fifo = fval_rise_edge_clk_vin	|| (~se_2_fvalrise_clk_in);
	assign	data_valid = i_fval & i_dval & (!reset_fifo);

	//  ===============================================================================================
	//  ��������FIFO������FIFO��32��256,�ɱ����180���ɱ�̿�6,fisrt word fall through
	//  ===============================================================================================

	assign	fifo_din 				= {i_trailer_flag,iv_image_din};
	assign	wv_p_in_wr_data			= fifo_dout[DATA_WD-1:0];
	assign	trailer_flag_fifoout	= fifo_dout[DATA_WD];

	//	fifo_w65d256_pf180_pe6 fifo_w65d256_pf180_pe6_inst(
	//	fifo_w65d512_pf430_pe6 fifo_w65d512_pf430_pe6_inst(
	fifo_w65d1k_pf950_pe6 fifo_w65d1k_pf950_pe6_inst(
	.rst			(reset_fifo			),
	.wr_clk			(clk_vin            ),
	.rd_clk			(clk                ),
	.din			(fifo_din       	),
	.wr_en			(data_valid         ),
	.rd_en			(fifo_rd_en         ),
	.dout			(fifo_dout      	),
	.full			(fifo_full_nc	    ),
	.empty			(fifo_empty		    ),
	.prog_full		(fifo_prog_full_nc  ),
	.prog_empty     (fifo_prog_empty	)
	);
	assign	o_fifo_full		= fifo_full_nc;
	//	-------------------------------------------------------------------------------------
	//	֡��ǰ��������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_vin) begin
		if(data_valid && fifo_full_nc) begin
			frame_buffer_front_fifo_overflow <= 1'b1;
		end
		else begin
			frame_buffer_front_fifo_overflow <= frame_buffer_front_fifo_overflow;
		end
	end

	assign o_frame_buffer_front_fifo_overflow = frame_buffer_front_fifo_overflow;
	//  ===============================================================================================
	//  ���Ĳ��֣�clkʱ�������߼���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ֹͣ�ɼ�ʱ�����л�֡�����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk )
	begin
		if(reset)
		begin
			ov_frame_depth	<=	{{(BUF_DEPTH_WD-2){1'b0}},2'b10};
		end
		else if ( ~i_stream_en )
		begin
			ov_frame_depth	<=	iv_frame_depth;
		end
	end
	//  -------------------------------------------------------------------------------------
	//	���źŽ�����λ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk )
	begin
		calib_done_shift	<= {calib_done_shift[0],i_calib_done};
	end
	always @ (posedge clk )
	begin
		p_in_cmd_empty_shfit	<= {p_in_cmd_empty_shfit[0],i_p_in_cmd_empty};
	end
	always @ (posedge clk)
	begin
		favl_shift_clk	<= {favl_shift_clk[1:0],i_fval};
	end
	//  -------------------------------------------------------------------------------------
	//	���ɵ�ַ��Ч��־��������ִ�е�FIFOΪ��
	//  -------------------------------------------------------------------------------------

	always @ (posedge clk)
	begin
		if( o_p_in_cmd_en )
		begin
			cmden_2_cmdfempty <= 1'b1;
		end
		else if ( p_in_cmd_empty_shfit== 2'b01 )
		begin
			cmden_2_cmdfempty <= 1'b0;
		end
	end
	//	�ź���λ
	always @ (posedge clk)
	begin
		cmden_2_cmdfempty_shift	<= {cmden_2_cmdfempty_shift[0],cmden_2_cmdfempty};
	end
	//	�����ɷ���������fifo���źŵ��½��ر�־��������Ч
	assign  addr_valid = ( cmden_2_cmdfempty_shift == 2'b10 )? 1'b1: 1'b0;
	//  ===============================================================================================
	//  ���Ĳ��֣�����ʽ״̬��
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
	//	ǰ��FIFOΪ������ƣ�д��������ݾ���Ҫ��ʱȡ�߶������ݣ�ǰ��FIFOԭ���ϲ�����������
	//	�����������
	//  -------------------------------------------------------------------------------------
	always @  *
	begin
		next_state = S_IDLE;
		case( current_state )
			S_IDLE	:
			begin											//DDRУ����ɣ�����ЧΪ�ߣ�FIFO������������
				if ( calib_done_shift[1] && favl_shift_clk[1] && ~fifo_prog_empty && o_se_2_fvalrise )
				begin
					next_state = S_REQ;
				end
				else
				begin
					next_state = S_IDLE;
				end
			end
			S_REQ	:
			begin
				if ( pipeline_shift==8'h80 )				//�ӳ�7��
				begin
					next_state = S_WR;
				end
				else
				begin
					next_state = S_REQ;
				end
			end
			S_WR	:											//word_cnt�м������
			begin
				if(wr_flag_shift[1:0] == 2'b10)				//����ת�����ϲ�Ϊһ������wr_flag���½��ؿ���������ת
				begin
					next_state = S_CMD_CHK;
				end
				else										//4��������д�룬������burst������
				begin
					next_state = S_WR;
				end
			end
			S_CMD_CHK:
			begin
				if ( i_p_in_cmd_empty )						//����FIFO�գ����Է������ת������״̬
				begin
					next_state = S_CMD;
				end
				else										//����FIFO�ǿգ������ȴ�
				begin
					next_state = S_CMD_CHK;
				end
			end
			S_CMD	:											//����״̬�����ڿ�ȣ�֮����ת����ѯ
			begin
				next_state = S_CHK;
			end
			S_CHK	:
			begin
				if ( ~favl_shift_clk[1] && fifo_empty)		//1�����һ֡ͼ���Ƿ������ǰ��FIFO�����ݣ�����������򷵻ؿ���״̬
				begin
					next_state = S_IDLE;
				end
				else										//2) ���������ݼ���д��
				begin
					next_state = S_WR;
				end
			end
			default	:											//���Ĭ��״̬
			begin
				next_state = S_IDLE;
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
			o_p_in_cmd_en				<= 1'b0			;
			word_cnt					<= 7'h0			;
			wr_addr_reg					<= {ADDR_WD{1'b0}}	;
			pipeline_shift				<= 8'h01		;
			fifo_rd_leader_payload_en 	<= 1'b0			;
			ov_p_in_cmd_bl				<= 6'h3f		;
			trailer_wr_en_flag			<= 1'b0			;
		end
		else
		begin
			o_p_in_cmd_en					<= 1'b0			;
			case( next_state )
				S_IDLE	:
				begin
					word_cnt			<= 7'h0			;
					pipeline_shift		<= 8'h01		;
					ov_p_in_cmd_bl		<= 6'h3f		;
					wr_flag				<= 1'b0			;
					trailer_wr_en_flag	<= 1'b0			;
					if( !o_se_2_fvalrise )
					begin
						wr_addr_reg	<=	{ADDR_WD{1'b0}}		;		//��ͬ����֤��ַ����
					end
				end
				S_REQ	:
				begin
					pipeline_shift		<= pipeline_shift << 1	;
					wr_addr_reg			<= {ADDR_WD{1'b0}}		;
					fifo_rd_leader_payload_en <= 1'b1			;
					trailer_wr_en_flag	<= 1'b0					;
				end
				//����β����־ʱ����wr_flag����⵽��������ǰ��FIFO���źű�־ʱ����wr_flag���̶�����д״̬
				S_WR	:
				begin
					if( {trailer_flag_fifoout_shift[3],trailer_flag_fifoout} == 2'b01 )
					begin
						wr_flag <=1'b0;
					end
					else if ( ~favl_shift_clk[1] && fifo_empty)
					begin
						wr_flag <=1'b0;
					end
					else if(word_cnt>=BURST_SIZE-1)
					begin
						if(o_p_in_wr_en)
						wr_flag <=1'b0;
						else
						wr_flag <=1'b1;
					end
					else
					begin
						wr_flag <=1'b1;
					end
					if ( o_p_in_wr_en)									//����Ч�����ݽ���ͳ��ֻͳ��д�벿�֡�
					begin
						word_cnt<=  word_cnt + 1	;
					end
					if ( trailer_flag_fifoout && wr_flag &&( ~i_p_in_wr_full ) && ( ~fifo_empty ) )
					begin
						trailer_wr_en_flag	<= 1'b1	;
					end
				end
				S_CMD_CHK:
				begin
					wr_flag 		<=	1'b0;
				end
				S_CMD	:
				begin
					if( word_cnt !=0 )									//����ս���S_WR״̬��β��������������word_cntΪ�㣬�򲻷���������������������
					begin
						o_p_in_cmd_en	<=	1'b1			;
					end
					if( !o_se_2_fvalrise )
					begin
						ov_p_in_cmd_bl	<=  6'h3f;					//ֹͣ�ɼ�ʱ��P2��fifo��ʣ�����������Ϊburst lenth����
					end
					else
					begin
						ov_p_in_cmd_bl	<=  word_cnt-1		;		//burst lenth����
					end
				end
				S_CHK	:
				begin
					word_cnt		<=	7'h00			;				//������λ
					wr_flag 		<=	1'b0			;
					if( trailer_flag_fifoout )							//�Ƶ�֡β����ֱַ�Ӹ�ֵ
					begin
						wr_addr_reg <= {{(ADDR_WD-1){1'b1}},1'b0};	//trailer��ַ��֡��ַ��ĩ��
					end
					else
					begin
						wr_addr_reg	<=	wr_addr_reg + 1	;			//ÿһ��д�����ۼ�1
					end
				end
			endcase
		end
	end

	//  ===============================================================================================
	//  ���岿�֣�MCB P2�˿ڿ����ź�
	//  ===============================================================================================
	//	o_p_in_wr_en���ʹ������߼�������P2�ڵ����źŻ�����ʱ�����²���������֪P2��FIFO���źţ�
	//	�������ʹ��ʱ���߼������P2 FIFO��֮����д�룬����д�����ݼ������ǵ�FIFO���
	assign	ov_p_in_wr_mask			= {DDR3_P0_MASK_SIZE{1'b0}};
	//	assign	ov_p_in_cmd_bl			= 6'h3f			;										//�˴�һֱ�� 6'h3f����ͼ��֡β��ʱ�򣬱�֤P2���ܱ���Ч���
	assign	ov_p_in_cmd_instr		= 3'b000		;										//MCBʹ�����Զ�Ԥ��磬���������
	assign	ov_p_in_cmd_byte_addr	= {{2'b00},wr_frame_ptr,wr_addr_reg,{BSIZE_WD{1'b0}}};	//��ַָ��ƴ�ӣ�ָ֡��+д��ַ+9'h000
	assign	ov_p_in_wr_data 		= wv_p_in_wr_data;										//����߼���FIFO���������ֱ��д��P2 FIFO
	//	P2��д����������д״̬��P2	FIFO��������������BURST_SIZE��ǰ��FIFO�ǿա�ǰ��������Ч��Ϊ��֤����������ݲ���д�룩
	//	assign	fifo_rd_en				= (next_state == S_WR) &&(~i_p_in_wr_full) && (word_cnt < BURST_SIZE) && (~fifo_empty);//
	assign	fifo_rd_en				= wr_flag &&( ~i_p_in_wr_full ) && ( ~fifo_empty ) && o_se_2_fvalrise ;		//2015/8/7 17:30:58ֻ���ڿ���״̬�²��������д
	assign	o_p_in_wr_en			= fifo_rd_en && ( (~trailer_flag_fifoout) || trailer_wr_en_flag);			//��д��һ����������ݣ��к�˶����Ʋ�����


	//  ===============================================================================================
	//  �������֣�дָ���д��ַ�ļ�������Ч����
	//  ===============================================================================================
	//	д��ַ�迼�����¼��㣺
	//  1���豸��ͬ������ͬ����ַ��Ҫ����
	//	2��д��ַ��дָ���豣֤ͬʱ����
	//	3��д��ַ��Ҫ���ڶ���ַ�仯
	//	4��дָ��Ҫ���仯��ʱ���ݸ�֡������࣬������ܵ��¶��������У�������������ڱ仯ʱ��֤�������ָ�벻�ܱ仯
	always @ (posedge clk)
	begin
		if (reset)
		begin
			ov_wr_addr 		<= {ADDR_WD{1'b0}};
		end
		else if (~o_se_2_fvalrise)					//�����ͣ�ɸ�λ����o_se_2_fvalriseΪ��ʱд��ַ�����ڶ���ַ�仯�����ܱ�֤׷����ȷ
		begin
			ov_wr_addr 		<= {ADDR_WD{1'b0}};
		end
		else if ( addr_valid || pipeline_shift[5] )	//���ִ�к���Ч,֡��ַ���µ�ʱ��д��ַҲ��Ҫ����
		begin
			ov_wr_addr 		<= wr_addr_reg;
		end
	end

	//	��ָ��仯��ɺ�һ�ſ���ָ����Ч
	always @ (posedge clk)
	begin
		if (reset)
		begin
			ov_wr_frame_ptr	<= {(BUF_DEPTH_WD){1'b0}};
		end
		else if (~o_se_2_fvalrise)					//�����ͣ�ɸ�λ����o_se_2_fvalriseΪ��ʱд��ַ�����ڶ���ַ�仯�����ܱ�֤׷����ȷ
		begin
			ov_wr_frame_ptr	<= {(BUF_DEPTH_WD){1'b0}};
		end
		else if ( pipeline_shift[5] )
		begin
			ov_wr_frame_ptr	<= wr_frame_ptr;
		end
	end

	//	дָ��仯�ڼ����Чʱ��ָ������ܱ仯
	always @ (posedge clk )
	begin
		if( pipeline_shift[5:1]!=0 )
		o_wr_frame_ptr_changing <= 1'b1;
		else
		o_wr_frame_ptr_changing <= 1'b0;
	end
	//  -------------------------------------------------------------------------------------
	//	ָ֡���߼���Ĭ��дָ�����ȶ�ָ��仯�����Ե�дָ����ڶ�ָ��ʱ�����дָ����һ��
	//	��ַ���Ƕ�ָ�룬дָ��+1���������+2��
	//	ͬ����ָ�����дָ��ʱ����ζ��дָ���Ѿ���λ��ͬ�����дָ����һ����ַ����
	//	��ָ�룬дָ��+1���������+2��
	//	iv_rd_frame_ptr + ov_frame_depth - wr_frame_ptr = 1 �����ж�дָ���Ƿ�Ҫ׷�϶�ָ��
	//  -------------------------------------------------------------------------------------
	//  ���߼����ƿ��ɺ��һ֡��ַ���ۼӣ�ֱ����һ֡��ʼд֮���־����Ч��������һ��д��ָ���Ǵ�0��ʼ������1��ʼ
	always @ (posedge clk)
	begin
		if(~o_se_2_fvalrise)
		begin
			first_frame_flag <= 1'b0;
		end
		else if(pipeline_shift[6])
		begin
			first_frame_flag <= 1'b1;
		end
	end
	//  -------------------------------------------------------------------------------------
	//	ָ֡���߼�������ˮ��ƣ�
	//	��һ�ģ����ж�дָ����һ��Ŀ��λ�Ƿ���Ƕ�ָ�룬���������ҪԽ����ָ�룬�����ۼӼ���
	//	�ڶ��ģ�ȷ���ۼ�ֵ���Ǽ�1���Ǽ�2
	//	�����ţ����ǽ�λ�����ȷ������ָ��
	//	bug�޸�2015/11/11 16:29:49 ��ǿ
	//	��ˮ�ڼ��ֹ��ָ��仯�����������ָ��仯����ˮ��־��Чͬʱ������Ҳ�ᵼ��дָ�����
	//	���������o_wr_frame_ptr_changing��iv_rd_frame_ptr�仯�����¼����1clk������дָ������߼����pipeline_shift[2��3]��ʼ��
	//  -------------------------------------------------------------------------------------
	//  ���߼����ƿ��ɺ��һ֡��ַ���ۼӣ�ֱ����һ֡��ʼд֮���־����Ч��������һ��д��ָ���Ǵ�0��ʼ������1��ʼ
	always @ (posedge clk)
	begin
		if(!(o_se_2_fvalrise &&first_frame_flag))
		begin										//ֹͣ�ɼ�ָ�븴λ
			wr_frame_ptr	<= {(BUF_DEPTH_WD){1'b0}};
			ptr_judge1		<= 1'b0;
			ptr_judge2		<= 1'b0;
			inc_value		<= {{(BUF_DEPTH_WD-1){1'b0}},{1'b1}};
		end
		else if(pipeline_shift[2])					//2015/11/11 16:28:05����ʱ������Ϊ�˴���ָ���дָ��ͬʱ�仯����дָ���������
		begin
			if ( iv_rd_frame_ptr + ov_frame_depth - wr_frame_ptr == 1 )
			begin
				ptr_judge1	<=1'b1;
			end
			else
			begin
				ptr_judge1	<=1'b0;
			end
			if ( iv_rd_frame_ptr - wr_frame_ptr == 1   )
			begin
				ptr_judge2	<=1'b1;
			end
			else
			begin
				ptr_judge2	<=1'b0;
			end
		end
		else if(pipeline_shift[3])					//��д�����cycle���ƶ�дָ��
		begin
			if ( wr_frame_ptr >= iv_rd_frame_ptr  )
			begin
				if ( ptr_judge1 )
				begin
					inc_value	<= {{(BUF_DEPTH_WD-2){1'b0}},{2'b10}}	;		//2
				end
				else
				begin
					inc_value	<= {{(BUF_DEPTH_WD-1){1'b0}},{1'b1}}	;		//1
				end
			end
			else
			begin
				if ( ptr_judge2)
				begin
					inc_value	<= {{(BUF_DEPTH_WD-2){1'b0}},{2'b10}}	;		//2
				end
				else
				begin
					inc_value	<= {{(BUF_DEPTH_WD-1){1'b0}},{1'b1}}	;		//1
				end
			end
		end
		//���дָ�볬����֡����ȣ���Ҫ��ȥ��Ȳ���
		else if(pipeline_shift[4])
		begin
			if ( wr_frame_ptr + inc_value > ov_frame_depth -1 )
			begin
				wr_frame_ptr <=	wr_frame_ptr + inc_value - ov_frame_depth;
			end
			else
			begin
				wr_frame_ptr <= wr_frame_ptr + inc_value;
			end
		end
	end

endmodule