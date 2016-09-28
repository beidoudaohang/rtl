//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : frame_buffer
//  -- �����       : �Ϻ��Ρ���ǿ
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2013/6/14 14:00:40	:|  ��ʼ�汾
//  -- ��ǿ         :| 2014/11/27 10:16:54	:|  ��ֲ��MER-U3V���̣����ݲ�ƷҪ���ʵ��޸�
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
	parameter						DATA_WD				= 32			,	//�������λ������ʹ��ͬһ���
	parameter						BUF_DEPTH_WD		= 4				,	//֡�����λ��,������λλ,����ʹ��1G bit sDDR���֧��8֡��ȣ��궨�岻�ܳ���4
	parameter						ADDR_WD   			= 20-BUF_DEPTH_WD,	//֡�ڵ�ַλ��
	parameter						BURST_SIZE			= 7'h40			,	//BURST_SIZE��С
	parameter						REG_WD   			= 32				//�Ĵ���λ��
	)
	(
//  -------------------------------------------------------------------------------------
//  ��Ƶ����ʱ����
//  -------------------------------------------------------------------------------------
	input							clk_vin								,	//ǰ��FIFOд������ʱ��
	input							i_fval								,	//����Ч�źţ�����Ч��clk_vinʱ����,i_fval��������Ҫ��i_dval����������ǰ��i_fval���½���Ҫ��i_dval���½����ͺ�i_fval��i_dval������֮��Ҫ���㹻�Ŀ�϶����Сֵ��MAX(6*clk_vin,6*clk_frame_buf)��i_fval��i_dval�½���֮��Ҫ���㹻�Ŀ�϶����Сֵ��1*clk_vin + 7*clk_frame_buf
	input							i_dval								,	//������Ч�źţ�����Ч��clk_vinʱ����������Ч�������ź�һ�������������Ƕ������ź�
	input							i_trailer_flag						,	//β����־
	input		[DATA_WD-1		:0]	iv_image_din						,	//ͼ�����ݣ�32λ��clk_vinʱ����
	input							i_stream_en_clk_in					,	//��ֹͣ�źţ�clk_inʱ�����ź���Чʱ������������֡д��֡�棬��Чʱ����ֹͣд�룬����λ��д��ַָ�룬��֡��
//  -------------------------------------------------------------------------------------
//  ��������
//  -------------------------------------------------------------------------------------
	input							i_stream_en							,	//��ֹͣ�źţ�clkʱ�����ź���Чʱ������������֡д��֡�棬��Чʱ����ֹͣд�룬����λ��д��ַָ�룬��֡��
	input		[BUF_DEPTH_WD-1	:0]	iv_frame_depth						,	//֡������ȣ�clkʱ���򣬿�����Ϊ 2-8����ֵ��������ȿ���ֹͣ�ɼ����ܸ���֡����ȡ�
	input		[6				:0]	iv_p2_wr_count						,	//mig_core�����clk_frame_bufʱ����mcb p2 ������fifo���ݸ���
	output	reg	[BUF_DEPTH_WD-1	:0]	ov_frame_depth						,	//֡������ȣ�clkʱ���򣬿�����Ϊ 2-8����ֵ��������ȿ���ֹͣ�ɼ����ܸ���֡�����,����ͣ����Чʱ�����ơ�
//  -------------------------------------------------------------------------------------
//  ֡���湤��ʱ����
//  -------------------------------------------------------------------------------------
	input							clk									,	//MCB P2����ʱ��
	input							reset								,	//
	output	reg	[BUF_DEPTH_WD-1	:0]	ov_wr_frame_ptr						,	//дָ��,��֡Ϊ��λ
	output	reg	[ADDR_WD-1		:0]	ov_wr_addr							,	//clk_frame_bufʱ����P2������ʹ���źţ���־д��ַ�Ѿ���Ч�����ٲñ�֤�£������ܹ�д��DDR�����źŶԵ�ַ�жϷǳ���Ҫ
	output	reg						o_wr_frame_ptr_changing				,	//clk_frame_bufʱ����дָ�����ڱ仯�źţ��������ģ�飬��ʱ��ָ�벻�ܱ仯
	input		[BUF_DEPTH_WD-1 :0]	iv_rd_frame_ptr						,	//��ָ��,��֡Ϊ��λ
	output	reg						o_se_2_fvalrise						,	//ͣ�ɵ���һ֡���ź������أ�Ϊ�˱���һ֮֡�ڵ���ͬ�������ź�չ��󴫸���ģ�飬clkʱ���򣬵͵�ƽ��־ͣ��
//  -------------------------------------------------------------------------------------
//  MCB�˿�
//  -------------------------------------------------------------------------------------
	input							i_calib_done						,	//MCBУ׼����źţ�����Ч
	output	reg						o_p2_cmd_en							,	//MCB CMD FIFO д�źţ�����Ч
	output		[2				:0]	ov_p2_cmd_instr						,	//MCB CMD FIFO ָ��
	output	reg	[5				:0]	ov_p2_cmd_bl						,	//MCB CMD FIFO ͻ������
	output		[29				:0]	ov_p2_cmd_byte_addr					,	//MCB CMD FIFO ��ʼ��ַ
	input							i_p2_cmd_empty						,	//MCB CMD FIFO ���źţ�����Ч
	output							o_p2_wr_en							,	//MCB WR FIFO д�źţ�����Ч
	output		[3				:0]	ov_p2_wr_mask						,	//MCB WR �����ź�
	output		[DATA_WD-1		:0]	ov_p2_wr_data						,	//MCB WR FIFO д����
	input							i_p2_wr_full							//MCB WR FIFO ���źţ�����Ч
	);
//  ===============================================================================================
//  ��һ���֣������������ͼĴ�������
//  ===============================================================================================

	parameter						S_IDLE					= 5'b00000	;
	parameter						S_REQ					= 5'b00001	;
	parameter						S_WR					= 5'b00010	;
	parameter						S_CMD_CHK				= 5'b00100	;
	parameter						S_CMD					= 5'b01000	;
	parameter						S_CHK					= 5'b10000	;

	reg			[4				:0]	current_state						;	//current_state
	reg			[4				:0]	next_state							;	//next_state
	wire							data_valid							;	//������Ч
	wire							reset_fifo							;	//front FIFO reset,once per frame
	reg								fval_rise_edge_clk_vin	=1'b0		;	//the rising edge of fval in clk_vin timing
	reg			[1				:0]	calib_done_shift		=2'b00    	;	//the shift registers of i_calib_done
	reg			[2				:0]	favl_shift_clk_vin		=3'b000     ;	//the shift registers of i_fval in clk_vin timing
	reg			[2				:0]	favl_shift_clk			=3'b000     ;	//the shift registers of i_fval
	reg								cmd_en_reg				=1'b0		;	//command enable register
	reg			[6				:0]	word_cnt				=BURST_SIZE	;	//the number of datas that are writed into MCB data fifo
	reg								fifo_rd_leader_payload_en			;	//front fifo leader payload read enable
	wire		[DATA_WD-1		:0]	wv_p2_wr_data						;	//front fifo readout data
	wire							fifo_full_nc						;	//front fifo full flag
	wire		                    fifo_empty					        ;	//front fifo empty flag
	wire		                    fifo_valid					        ;	//front fifo data valid flag
	wire		                    fifo_prog_full_nc			        ;	//front fifo prog_full
	wire		                    fifo_prog_empty				        ;	//front fifo prog_empty
	reg			[7				:0]	pipeline_shift			=8'h1		;	//pipeline counter
	reg			[ADDR_WD-1		:0]	wr_addr_reg							;	//writing address
	reg								ptr_judge1							;	//frame point judge 1
	reg								ptr_judge2							;	//frame point judge 2
	reg			[BUF_DEPTH_WD-1 :0]	inc_value							;	//frame point increase value
	reg								first_frame_flag		=1'b0		;	//the flag of the first frame
	reg			[1				:0]	p2_cmd_empty_shfit					;
	reg			[1				:0]	cmden_2_cmdfempty_shift				;
	reg								cmden_2_cmdfempty					;
	wire							addr_valid							;
	reg			[BUF_DEPTH_WD-1	:0]	wr_frame_ptr						;
	reg								se_2_fvalrise_clk_in				;
	wire		[DATA_WD 		:0]	fifo_din							;	//fifo��������33bits
	wire		[DATA_WD 		:0]	fifo_dout							;	//fifo�������33bits
	wire							trailer_flag_fifoout				;
	reg      	[3				:0]	trailer_flag_fifoout_shift			;
	reg								wr_flag	=1'b0						;
	reg			[1				:0]	wr_flag_shift	=2'b0				;
	reg								trailer_wr_en_flag	=1'b0			;	//mask the writing to fifo
//  -------------------------------------------------------------------------------------
//	FSM for sim
//  -------------------------------------------------------------------------------------
// synthesis translate_off
	integer			state_ascii;
	always @ ( * ) begin
		case(current_state)
			5'b00000 :	state_ascii	<= "S_IDLE";
			5'b00001 :	state_ascii	<= "S_REQ";
			5'b00010 :	state_ascii	<= "S_WR";
			5'b00100 :	state_ascii	<= "S_CMD_CHK";
			5'b01000 :	state_ascii	<= "S_CMD";
			5'b10000 :	state_ascii	<= "S_CHK";
		endcase
	end
// synthesis translate_on

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
		if( ~i_stream_en_clk_in )				//��ͣ���ڼ�һֱ��λ
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

	assign	fifo_din 		= {i_trailer_flag,iv_image_din};
	assign	wv_p2_wr_data	= fifo_dout[DATA_WD-1:0];
	assign	trailer_flag_fifoout	= fifo_dout[DATA_WD];


	fifo_w33d256_pf180_pe6 fifo_w33d256_pf180_pe6_inst (
	.rst			(reset_fifo			), 	// input rst
	.wr_clk			(clk_vin            ), 	// input wr_clk
	.rd_clk			(clk                ), 	// input rd_clk
	.din			(fifo_din       	), 	// input [31 : 0] din
	.wr_en			(data_valid         ), 	// input wr_en
	.rd_en			(fifo_rd_en         ), 	// input rd_en
	.dout			(fifo_dout      	), 	// output [31 : 0] dout
	.full			(fifo_full_nc	    ), 	// output full
	.empty			(fifo_empty		    ), 	// output empty
	.valid			(fifo_valid		    ), 	// output valid
	.prog_full		(fifo_prog_full_nc  ), 	// output prog_full
	.prog_empty		(fifo_prog_empty	) 	// output prog_empty
	);


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
		p2_cmd_empty_shfit	<= {p2_cmd_empty_shfit[0],i_p2_cmd_empty};
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
		if( o_p2_cmd_en )
		begin
			cmden_2_cmdfempty <= 1'b1;
		end
		else if ( p2_cmd_empty_shfit== 2'b01 )
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
				if ( i_p2_cmd_empty )						//����FIFO�գ����Է������ת������״̬
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
			o_p2_cmd_en					<= 1'b0			;
			word_cnt					<= 7'h0			;
			wr_addr_reg					<= {ADDR_WD{1'b0}}	;
			pipeline_shift				<= 8'h01		;
			fifo_rd_leader_payload_en 	<= 1'b0			;
			ov_p2_cmd_bl				<= 6'h3f		;
			trailer_wr_en_flag			<= 1'b0			;
		end
		else
		begin
			o_p2_cmd_en					<= 1'b0			;
			case( next_state )
				S_IDLE	:
				begin
					word_cnt			<= 7'h0			;
					pipeline_shift		<= 8'h01		;
					ov_p2_cmd_bl		<= 6'h3f		;
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
							if(o_p2_wr_en)
								wr_flag <=1'b0;
							else
								wr_flag <=1'b1;
						end
					else
						begin
							wr_flag <=1'b1;
						end
					if ( o_p2_wr_en)									//����Ч�����ݽ���ͳ��ֻͳ��д�벿�֡�
						begin
							word_cnt<=  word_cnt + 1	;
						end
					if ( trailer_flag_fifoout && wr_flag &&( ~i_p2_wr_full ) && ( ~fifo_empty ) )
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
					o_p2_cmd_en		<=	1'b1			;
					if( !o_se_2_fvalrise )
						begin
							ov_p2_cmd_bl	<=  6'h3f;		//ֹͣ�ɼ�ʱ��P2��fifo��ʣ�����������Ϊburst lenth����������ʹ��
						end
					else
						begin
							ov_p2_cmd_bl	<=  word_cnt-1		;		//burst lenth����
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
							wr_addr_reg	<=	wr_addr_reg + 1	;		//ÿһ��д�����ۼ�1
						end
				end
			endcase
		end
	end


//  ===============================================================================================
//  ���岿�֣�MCB P2�˿ڿ����ź�
//  ===============================================================================================
//	o_p2_wr_en���ʹ������߼�������P2�ڵ����źŻ�����ʱ�����²���������֪P2��FIFO���źţ�
//	�������ʹ��ʱ���߼������P2 FIFO��֮����д�룬����д�����ݼ������ǵ�FIFO���
	assign	ov_p2_wr_mask		= 4'b0000		;
//	assign	ov_p2_cmd_bl		= 6'h3f			;	//�˴�һֱ�� 6'h3f����ͼ��֡β��ʱ�򣬱�֤P2���ܱ���Ч���
	assign	ov_p2_cmd_instr		= 3'b000		;	//MCBʹ�����Զ�Ԥ��磬���������
	assign	ov_p2_cmd_byte_addr	= {{2'b00},wr_frame_ptr,wr_addr_reg,8'h00};	//��ַָ��ƴ�ӣ�ָ֡��+д��ַ+8'h00
	assign	ov_p2_wr_data 		= wv_p2_wr_data;	//����߼���FIFO���������ֱ��д��P2 FIFO
//	P2��д����������д״̬��P2	FIFO��������������BURST_SIZE��ǰ��FIFO�ǿա�ǰ��������Ч��Ϊ��֤����������ݲ���д�룩
//	assign	fifo_rd_en			= (next_state == S_WR) &&(~i_p2_wr_full) && (word_cnt < BURST_SIZE) && (~fifo_empty);//
	assign	fifo_rd_en			= wr_flag &&( ~i_p2_wr_full ) && ( ~fifo_empty ) && o_se_2_fvalrise ;	//2015/8/7 17:30:58ֻ���ڿ���״̬�²��������д
	assign	o_p2_wr_en			= fifo_rd_en && ( (~trailer_flag_fifoout) || trailer_wr_en_flag);	//��д��һ����������ݣ��к�˶����Ʋ�����


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
		else if ( addr_valid || pipeline_shift[4] )	//���ִ�к���Ч,֡��ַ���µ�ʱ��д��ַҲ��Ҫ����
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
		else if ( pipeline_shift[4] )
		begin
			ov_wr_frame_ptr	<= wr_frame_ptr;
		end
	end

//	дָ��仯�ڼ����Чʱ��ָ������ܱ仯
	always @ (posedge clk )
	begin
		if( pipeline_shift[4:1]!=0 )
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
		else if(pipeline_shift[5])
		begin
			first_frame_flag <= 1'b1;
		end
	end
//  -------------------------------------------------------------------------------------
//	ָ֡���߼�������ˮ��ƣ�
//	��һ�ģ����ж�дָ����һ��Ŀ��λ�Ƿ���Ƕ�ָ�룬���������ҪԽ����ָ�룬�����ۼӼ���
//	�ڶ��ģ�ȷ���ۼ�ֵ���Ǽ�1���Ǽ�2
//	�����ţ����ǽ�λ�����ȷ������ָ��
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
		else if(pipeline_shift[1])
		begin
			if ( iv_rd_frame_ptr + ov_frame_depth - wr_frame_ptr == 1   )
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
		else if(pipeline_shift[2])						//��д�����cycle���ƶ�дָ��
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
		else if(pipeline_shift[3])
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