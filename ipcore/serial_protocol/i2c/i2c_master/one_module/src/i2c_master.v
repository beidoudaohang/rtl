//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : i2c_master
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/11/10 17:43:32	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1)  : ov_status[3:0]	bit0-i2c done bit1-slave addr nack bit2-reg addr nack bit3-wr data nack
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module i2c_master # (
	parameter	P_REG_ADDR_WIDTH	= 8		,	//8 or 16
	parameter	P_DATA_WIDTH 		= 16	,	//8 or 16
	parameter	P_I2C_FIRST_DATA	= "MSB"		//"MSB" or "LSB"
	)
	(
	//	-------------------------------------------------------------------------------------
	//	ϵͳ�ź�
	//	-------------------------------------------------------------------------------------
	input							clk				,	//ʱ��
	input							i_nwr_prd		,	//��д�źţ�0-д��1-��
	input							i_trig			,	//�����ź�
	input	[3:0]					iv_rd_num		,	//����������
	input	[7:0]					iv_slave_addr	,	//��������ַ
	input	[P_REG_ADDR_WIDTH-1:0]	iv_reg_addr		,	//�Ĵ�����ַ
	input	[P_DATA_WIDTH-1:0]		iv_wr_data		,	//Ҫд�������
	output	[P_DATA_WIDTH-1:0]		ov_rd_data		,	//����������
	output							o_rd_valid		,	//�������
	output	[3:0]					ov_status		,	//��ǰ״̬
	//  -------------------------------------------------------------------------------------
	//	I2C �ӿ��ź�
	//  -------------------------------------------------------------------------------------
	input							clk_i2c			,	//i2cʱ��
	output							slave_exp		,	//������æ
	inout							scl				,	//i2c ʱ��
	inout							sda					//i2c ����
	);

	//	ref signals
	//FSM Parameter Define
	parameter	S_IDLE			= 4'd0;
	parameter	S_START_READY	= 4'd1;
	parameter	S_ISSUE_START	= 4'd2;
	parameter	S_SLAVE_ADDR	= 4'd3;
	parameter	S_REG_ADDR		= 4'd4;
	parameter	S_WR_DATA		= 4'd5;
	parameter	S_STOP			= 4'd6;
	parameter	S_ERROR			= 4'd7;
	parameter	S_RD_DATA		= 4'd8;


	reg		[3:0]	current_state	= S_IDLE;
	reg		[3:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	reg		[127:0]			state_ascii;
	always @ ( * ) begin
		case(current_state)
			4'd0 :	state_ascii	<= "IDLE";
			4'd1 :	state_ascii	<= "START_READY";
			4'd2 :	state_ascii	<= "ISSUE_START";
			4'd3 :	state_ascii	<= "SLAVE_ADDR";
			4'd4 :	state_ascii	<= "REG_ADDR";
			4'd5 :	state_ascii	<= "WR_DATA";
			4'd6 :	state_ascii	<= "STOP";
			4'd7 :	state_ascii	<= "ERROR";
			4'd8 :	state_ascii	<= "RD_DATA";
		endcase
	end
	// synthesis translate_on

	parameter	P_REG_ADDR_BYTE_NUM	= P_REG_ADDR_WIDTH/8;
	parameter	P_DATA_BYTE_NUM		= P_DATA_WIDTH/8;




	reg		[2:0]						clk_i2c_shift		= 3'b0;
	wire								clk_i2c_rise		;
	wire								clk_i2c_fall		;
	reg		[3:0]						clk_i2c_cnt			= 4'b0;
	reg		[3:0]						clk_i2c_fall_cnt	= 4'b0;
	reg									nwr_prd_reg			= 1'b0;
	reg		[3:0]						rd_num_reg			= 4'b0;
	reg		[7:0]						slave_addr_reg		= 8'b0;
	reg		[P_REG_ADDR_WIDTH-1:0]		reg_addr_reg		= {P_REG_ADDR_WIDTH{1'b0}};
	reg		[P_DATA_WIDTH-1:0]			wr_data_reg			= {P_DATA_WIDTH{1'b0}};
	reg									rd_first_cycle		= 1'b0;
	reg									second_byte			= 1'b0;
	reg		[8:0]						data_shifter		= 9'b0;
	reg									rd_valid_reg		= 1'b0;
	reg		[P_DATA_WIDTH-1:0]			rd_data_reg			= {P_DATA_WIDTH{1'b0}};

	reg									slave_addr_nack_reg	= 1'b0;
	reg									reg_addr_nack_reg	= 1'b0;
	reg									wr_data_nack_reg	= 1'b0;
	reg									i2c_done_reg		= 1'b0;
	wire								scl_in				;
	wire								sda_in				;
	reg									scl_out				=1'b1;
	reg									sda_out				=1'b1;
	reg		[3:0]						rd_num_cnt			= 4'b0;


	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref �첽�źŴ���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	��ȡ clk_i2c �ı���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		clk_i2c_shift[2:0]	<= {clk_i2c_shift[1:0],clk_i2c};
	end
	assign	clk_i2c_rise	= (clk_i2c_shift[2:1]==2'b01) ? 1'b1 : 1'b0;
	assign	clk_i2c_fall	= (clk_i2c_shift[2:1]==2'b10) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	clk_i2c ������ �������ػ��½��ص�ʱ��λ������ʱ���ۼӡ��ۼӵ����ֵʱ��ֹͣ�ۼ�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(clk_i2c_rise|clk_i2c_fall) begin
			clk_i2c_cnt	<= 4'b0;
		end
		else begin
			if(clk_i2c_cnt==4'hf) begin
				clk_i2c_cnt	<= clk_i2c_cnt;
			end
			else begin
				clk_i2c_cnt	<= clk_i2c_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	clk i2c���½��ؼ�����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((current_state==S_SLAVE_ADDR)||(current_state==S_REG_ADDR)||(current_state==S_WR_DATA)||(current_state==S_RD_DATA)) begin
			if((clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'hf)) begin
				clk_i2c_fall_cnt	<= 'b0;
			end
			else if(clk_i2c_fall) begin
				clk_i2c_fall_cnt	<= clk_i2c_fall_cnt + 1'b1;
			end
		end
		else if(current_state==S_IDLE) begin
			clk_i2c_fall_cnt	<= 'b0;
		end
	end

	//  ===============================================================================================
	//	ref ��־�Ĵ���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	�������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((current_state==S_IDLE)&&(i_trig==1'b1)) begin
			nwr_prd_reg		<= i_nwr_prd;
			rd_num_reg		<= iv_rd_num;
			slave_addr_reg	<= iv_slave_addr;
			reg_addr_reg	<= iv_reg_addr;
			wr_data_reg		<= iv_wr_data;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	��������ĸ������У���������Ҫ����start
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			rd_first_cycle	<= 1'b0;
		end
		else if((current_state==S_START_READY)&&(clk_i2c_rise==1'b1)) begin
			rd_first_cycle	<= !rd_first_cycle;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	reg addr��wr data �� rd data ��������2��byte
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(current_state)
			S_IDLE : begin
				second_byte	<= 1'b0;
			end
			S_REG_ADDR : begin
				if((clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'hf)) begin
					if(second_byte==P_REG_ADDR_BYTE_NUM-1) begin
						second_byte	<= 1'b0;
					end
					else begin
						second_byte	<= !second_byte;
					end
				end
			end
			S_WR_DATA , S_RD_DATA : begin
				if((clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'hf)) begin
					if(second_byte==P_DATA_BYTE_NUM-1) begin
						second_byte	<= 1'b0;
					end
					else begin
						second_byte	<= !second_byte;
					end
				end
			end
		endcase
	end
	//  -------------------------------------------------------------------------------------
	//	�����˶��ٸ�����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			rd_num_cnt	<= 4'b0;
		end
		else if((current_state==S_RD_DATA)&&(clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'hf)&&(second_byte==P_DATA_BYTE_NUM-1)) begin
			rd_num_cnt	<= rd_num_cnt + 1'b1;
		end
	end

	//  ===============================================================================================
	//	ref ����λ���
	//  ===============================================================================================
	always @ (posedge clk) begin
		if(current_state==S_SLAVE_ADDR) begin
			if(clk_i2c_fall_cnt==4'b0) begin
				if(nwr_prd_reg==1'b1) begin
					if(rd_first_cycle==1'b1) begin
						data_shifter[8:0]	<= {slave_addr_reg[7:1],1'b0,1'b1};
					end
					else begin
						data_shifter[8:0]	<= {slave_addr_reg[7:1],1'b1,1'b1};
					end
				end
				else begin
					data_shifter[8:0]	<= {slave_addr_reg[7:1],nwr_prd_reg,1'b1};
				end
			end
			else begin
				if((scl_in==1'b0)&&(clk_i2c_cnt==4'he)) begin
					data_shifter[8:0]	<= {data_shifter[7:0],1'b1};
				end
			end
		end

		else if(current_state==S_REG_ADDR) begin
			if(clk_i2c_fall_cnt==4'b0) begin
				if(second_byte==1'b0) begin
					data_shifter[8:0]	<= {reg_addr_reg[P_REG_ADDR_WIDTH-1:P_REG_ADDR_WIDTH-8],1'b1};
				end
				else begin
					//					data_shifter[8:0]	<= {reg_addr_reg[P_REG_ADDR_WIDTH-9:P_REG_ADDR_WIDTH-16],1'b1};		//ISE �����ۺ���һ��
					data_shifter[8:0]	<= {reg_addr_reg[P_REG_ADDR_WIDTH-1:P_REG_ADDR_WIDTH-8],1'b1};
				end
			end
			else begin
				if((scl_in==1'b0)&&(clk_i2c_cnt==4'he)) begin
					data_shifter[8:0]	<= {data_shifter[7:0],1'b1};
				end
			end
		end

		else if(current_state==S_WR_DATA) begin
			if(clk_i2c_fall_cnt==4'b0) begin
				if((second_byte==1'b0)) begin
					data_shifter[8:0]	<= {wr_data_reg[P_DATA_WIDTH-1:P_DATA_WIDTH-8],1'b1};
				end
				else begin
					data_shifter[8:0]	<= {wr_data_reg[P_DATA_WIDTH-9:P_DATA_WIDTH-16],1'b1};
				end
			end
			else begin
				if((scl_in==1'b0)&&(clk_i2c_cnt==4'he)) begin
					data_shifter[8:0]	<= {data_shifter[7:0],1'b1};
				end
			end
		end

		else if(current_state==S_RD_DATA) begin
			if((scl_in==1'b1)&&(clk_i2c_cnt==4'he)) begin
				data_shifter[8:0]	<= {data_shifter[7:0],sda_in};
			end
		end


	end

	//  -------------------------------------------------------------------------------------
	//	����������Ч�ź�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_RD_DATA) begin
			if((clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'he)) begin
				rd_valid_reg	<= 1'b1;
			end
			else begin
				rd_valid_reg	<= 1'b0;
			end
		end
		else begin
			rd_valid_reg	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	ƴ���������
	//  -------------------------------------------------------------------------------------
	generate
		if(P_DATA_BYTE_NUM==1) begin
			always @ (posedge clk) begin
				if(rd_valid_reg==1'b1) begin
					rd_data_reg	<= data_shifter[8:1];
				end
			end

		end
		else if(P_DATA_BYTE_NUM==2) begin
			always @ (posedge clk) begin
				if(rd_valid_reg==1'b1) begin
					if(second_byte==1'b1) begin
						rd_data_reg[7:0]	<= data_shifter[8:1];
					end
					else begin
						rd_data_reg[15:8]	<= data_shifter[8:1];
					end
				end
			end
		end

	endgenerate

	//  -------------------------------------------------------------------------------------
	//	��������
	//  -------------------------------------------------------------------------------------
	assign	ov_rd_data	= rd_data_reg;
	assign	o_rd_valid	= rd_valid_reg;


	//  ===============================================================================================
	//	ref ��������ʹ�����
	//  ===============================================================================================

	//  -------------------------------------------------------------------------------------
	//	slave addr û��ack
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_SLAVE_ADDR) begin
			if((clk_i2c_fall_cnt==4'h8)&&(clk_i2c_shift[2]==1'b1)&&(clk_i2c_cnt==4'hf)) begin
				if(sda_in==1'b1) begin
					slave_addr_nack_reg	<= 1'b1;
				end
			end
		end
		else if(current_state==S_START_READY) begin
			slave_addr_nack_reg	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	reg addr û��ack
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_REG_ADDR) begin
			if((clk_i2c_fall_cnt==4'h8)&&(clk_i2c_shift[2]==1'b1)&&(clk_i2c_cnt==4'hf)) begin
				if(sda_in==1'b1) begin
					reg_addr_nack_reg	<= 1'b1;
				end
			end
		end
		else if(current_state==S_START_READY) begin
			reg_addr_nack_reg	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	reg addr û��ack
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_WR_DATA) begin
			if((clk_i2c_fall_cnt==4'h8)&&(clk_i2c_shift[2]==1'b1)&&(clk_i2c_cnt==4'hf)) begin
				if(sda_in==1'b1) begin
					wr_data_nack_reg	<= 1'b1;
				end
			end
		end
		else if(current_state==S_START_READY) begin
			wr_data_nack_reg	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	I2C �������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((current_state==S_STOP)||(current_state==S_ERROR)) begin
			i2c_done_reg	<= 1'b1;
		end
		else if(current_state==S_START_READY) begin
			i2c_done_reg	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	״̬λ���
	//  -------------------------------------------------------------------------------------
	assign		ov_status	= {wr_data_nack_reg,reg_addr_nack_reg,slave_addr_nack_reg,i2c_done_reg};

	//  ===============================================================================================
	//	ref ���
	//  ===============================================================================================
	assign	scl		= (scl_out==1'b0) ? 1'b0 : 1'bz;
	assign	sda		= (sda_out==1'b0) ? 1'b0 : 1'bz;

	assign	scl_in	= scl;
	assign	sda_in	= sda;

	always @ (posedge clk) begin
		case(current_state)
			S_IDLE , S_START_READY , S_ERROR : begin
				sda_out	<= 1'b1;
			end
			S_ISSUE_START , S_STOP : begin
				sda_out	<= 1'b0;
			end
			S_SLAVE_ADDR , S_REG_ADDR , S_WR_DATA : begin
				sda_out	<= data_shifter[8];
			end
			S_RD_DATA : begin
				if(clk_i2c_fall_cnt==4'h8) begin
					if(clk_i2c_cnt==4'hf) begin
						sda_out	<= 1'b0;
					end
				end
				else if(clk_i2c_fall_cnt==4'h0) begin
					sda_out	<= 1'b1;
				end
			end
		endcase
	end

	always @ (posedge clk) begin
		case(current_state)
			S_IDLE : begin
				scl_out	<= 1'b1;
			end
			S_START_READY : begin
				scl_out	<= 1'b1;
			end
			default : begin
				scl_out	<= clk_i2c;
			end
		endcase
	end


	//  -------------------------------------------------------------------------------------
	//	δ�õ�
	//  -------------------------------------------------------------------------------------
	assign	slave_exp	= 1'b0;



	//  ===============================================================================================
	//	ref ״̬��
	//  ===============================================================================================
	//FSM Sequential Logic
	always @ (posedge clk) begin
		current_state	<= next_state;
	end

	//FSM Conbinatial Logic
	always @ ( * ) begin
		case(current_state)
			//  -------------------------------------------------------------------------------------
			//	�������ź�����ʱ�򣬸��ݶ�д�źţ��ж��Ƕ�����д
			//  -------------------------------------------------------------------------------------
			S_IDLE :
			if(i_trig==1'b1) begin
				next_state	= S_START_READY;
			end
			else begin
				next_state	= S_IDLE;
			end

			//  -------------------------------------------------------------------------------------
			//	clk_i2c �����������ˣ����� start �źŷ�����״̬
			//  -------------------------------------------------------------------------------------
			S_START_READY :
			if(clk_i2c_rise==1'b1) begin
				next_state	= S_ISSUE_START;
			end
			else begin
				next_state	= S_START_READY;
			end

			//  -------------------------------------------------------------------------------------
			//	���� start �ź�
			//  -------------------------------------------------------------------------------------
			S_ISSUE_START :
			if((clk_i2c_shift[2]==1'b0)&&(clk_i2c_cnt==4'hf)) begin
				next_state	= S_SLAVE_ADDR;
			end
			else begin
				next_state	= S_ISSUE_START;
			end

			//  -------------------------------------------------------------------------------------
			//	���� slave addr
			//	1. ack ����Ӧ���˳���error״̬
			//	2. ����Ƕ�������ڵ�2�ζ��Ĺ����У�д��slave addr ֮��Ҫ��������ݵ�״̬
			//	3. ��������£�����д reg addr ��״̬
			//  -------------------------------------------------------------------------------------
			S_SLAVE_ADDR :
			if((clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'hf)) begin
				if(slave_addr_nack_reg==1'b1) begin
					next_state	= S_ERROR;
				end
				else begin
					if((nwr_prd_reg==1'b1)&&(rd_first_cycle==1'b0)) begin
						next_state	= S_RD_DATA;
					end
					else begin
						next_state	= S_REG_ADDR;
					end
				end
			end
			else begin
				next_state	= S_SLAVE_ADDR;
			end

			//  -------------------------------------------------------------------------------------
			//	���� reg addr
			//	1. ack ����Ӧ���˳���error״̬
			//	2. ����Ƕ������ô�϶����ڵ�һ�εĹ����У�д�� reg addr ֮��Ҫ�ط� start
			//	3. ��������£�����д ���� ��״̬
			//  -------------------------------------------------------------------------------------
			S_REG_ADDR :
			if((clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'hf)) begin
				if(reg_addr_nack_reg==1'b1) begin
					next_state	= S_ERROR;
				end
				else begin
					if(second_byte==P_REG_ADDR_BYTE_NUM-1) begin
						if(nwr_prd_reg==1'b1) begin
							next_state	= S_START_READY;
						end
						else begin
							next_state	= S_WR_DATA;
						end
					end
					else begin
						next_state	= S_REG_ADDR;
					end
				end
			end
			else begin
				next_state	= S_REG_ADDR;
			end

			//  -------------------------------------------------------------------------------------
			//	д����
			//	1. ÿ��д����������1byte��������ݿ�ȴ���8��Ҫд���
			//	2. ACK֮��Ҫ����Ƿ������������������������˳���Ŀǰ��֧������д�ķ�ʽ
			//  -------------------------------------------------------------------------------------
			S_WR_DATA :
			if((clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'hf)) begin
				if(wr_data_nack_reg==1'b1) begin
					next_state	= S_ERROR;
				end
				else begin
					if(second_byte==P_DATA_BYTE_NUM-1) begin
						next_state	= S_STOP;
					end
					else begin
						next_state	= S_WR_DATA;
					end
				end
			end
			else begin
				next_state	= S_WR_DATA;
			end

			//  -------------------------------------------------------------------------------------
			//	����
			//  -------------------------------------------------------------------------------------
			S_STOP :
			if((clk_i2c_shift[2]==1'b1)&&(clk_i2c_cnt==4'hf)) begin
				next_state	= S_IDLE;
			end
			else begin
				next_state	= S_STOP;
			end

			//  -------------------------------------------------------------------------------------
			//	����
			//  -------------------------------------------------------------------------------------
			S_ERROR :
			next_state	= S_IDLE;

			//  -------------------------------------------------------------------------------------
			//	������
			//	1. ÿ�ζ�����������1byte��������ݿ�ȴ���8��Ҫд���
			//	2. ACK֮��Ҫ����Ƿ���������:�������������˳���δ��������������������
			//  -------------------------------------------------------------------------------------
			S_RD_DATA :
			if((clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'hf)) begin
				if(second_byte==P_DATA_BYTE_NUM-1) begin
					if(rd_num_cnt==rd_num_reg) begin
						next_state	= S_STOP;
					end
					else begin
						next_state	= S_RD_DATA;
					end
				end
				else begin
					next_state	= S_RD_DATA;
				end
			end
			else begin
				next_state	= S_RD_DATA;
			end
			default :
			next_state	= S_IDLE;
		endcase
	end



endmodule
