//-------------------------------------------------------------------------------------------------
//  -- Corporation  : MicroRTL.com
//  -- Email        : haitaox2013@gmail.com
//  -- Module       : sync_fifo_srl
//-------------------------------------------------------------------------------------------------
//  -- Description  : �����Դ��picoblaze uart bb_fifo.ͬ��fifo����ȺͿ�ȶ��ɱ�
//		��fifo��ʱ�������дͬʱ��Ч���൱��д����һ�����ݣ����Ƕ��������ã�fifo��Ϊ�ǿ�-��bb_fifo��ͬ
//		��fifo��ʱ�������дͬʱ��Ч���൱�ڶ�����һ�����ݣ�����д�������ã�fifo��Ϊ����-��bb_fifo��ͬ��bb_fifo�����źŻ�����Ч����дҲ�������ˡ�
//
//-------------------------------------------------------------------------------------------------
//  -- Changelog    :
//  -- Author       | Date                  | Content
//  -- Michael      | 2014/12/6 16:21:34	|
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module sync_fifo_srl # (
	parameter		FIFO_WIDTH		= 8		,	//fifo ���ݿ��
	parameter		FIFO_DEPTH		= 16		//fifo �������
	)
	(
	input						reset		,	//��λ�źţ�����Ч
	input						clk			,	//ʱ���ź�
	input	[FIFO_WIDTH-1:0]	iv_din		,	//8bit�����ź�
	input						i_wr		,	//д�źţ�����Ч
	output						o_full		,	//���źţ�����Ч
	output						o_half_full	,	//�����źţ�����Ч
	input						i_rd		,	//���źţ�����Ч
	output	[FIFO_WIDTH-1:0]	ov_dout		,	//8bit�������
	output						o_empty			//���źţ�����Ч
	);

	//	ref signals
	parameter	FIFO_PTR_WIDTH	= (FIFO_DEPTH/17)+4;


	wire								valid_wr		;
	reg		[FIFO_PTR_WIDTH-1:0]		pointer			= {FIFO_PTR_WIDTH{1'b0}};
	wire								full_int		;
	wire								pointer_zero	;
	wire								half_full_int	;
	wire	[FIFO_WIDTH-1:0]			store_data		;
	reg									empty_reg		= 1'b0;

	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	�洢��
	//	SRL16��һ��������λ����λ�Ĵ�����A3-A0ѡ�������bit
	//  -------------------------------------------------------------------------------------
	genvar i;
	generate
		if(FIFO_DEPTH<=16) begin
			for (i = 0 ; i <= FIFO_WIDTH-1 ; i = i+1) begin : data_width_loop_in_depth16
				SRL16E # (
				.INIT   (16'h0000	)
				)
				storage_srl (
				.D  	(iv_din[i]		),
				.CE 	(valid_wr		),
				.CLK	(clk			),
				.A0 	(pointer[0]		),
				.A1 	(pointer[1]		),
				.A2 	(pointer[2]		),
				.A3 	(pointer[3]		),
				.Q  	(store_data[i]	)
				);
			end //generate data_width_loop;
		end

		else if((FIFO_DEPTH>16)&&(FIFO_DEPTH<=32)) begin
			for (i = 0 ; i <= FIFO_WIDTH-1 ; i = i+1) begin : data_width_loop_in_depth32
				SRLC32E # (
				.INIT   (32'h00000000	)
				)
				storage_srl (
				.D  	(iv_din[i]		),
				.CE 	(valid_wr		),
				.CLK	(clk			),
				.A	 	(pointer		),
				.Q  	(store_data[i]	),
				.Q31  	(	)	// SRL cascade output pin
				);
			end //generate data_width_loop;
		end

	endgenerate

	//  -------------------------------------------------------------------------------------
	//	valid_wr
	//  -------------------------------------------------------------------------------------
	//���洢����ʱ��д��״̬�����״̬�й�
	//�����дͬʱ��Ч������д��������
	//�������Ч��������д��������
	//���洢������ʱ��д�ź���Ч
	assign	valid_wr	= (full_int) ? (((i_wr==1'b1)&&(i_rd==1'b1)) ? 1'b1 : 1'b0) : i_wr	;

	//  -------------------------------------------------------------------------------------
	//	pointer
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			pointer	<= 'b0;
		end
		else begin
			//�����ղ���ʱ��ֻд������������++
			//�����ղ���ʱ��ֻ����д��������--
			if((empty_reg==1'b0)&&(full_int==1'b0)) begin
				if((i_wr==1'b1)&&(i_rd==1'b0)) begin
					pointer	<= pointer + 1'b1;
				end
				else if((i_wr==1'b0)&&(i_rd==1'b1)) begin
					if(pointer_zero==1'b1) begin
						pointer	<= pointer;
					end
					else begin
						pointer	<= pointer - 1'b1;
					end
				end
			end

			//������������ʱ��ֻ�������������д
			else if(full_int==1'b1) begin
				if(i_rd==1'b1) begin
					pointer	<= pointer - 1'b1;
				end
			end

			//			//���������յ�ʱ��ֻ����д���������.����ָ�벻��.��һ�β���д����
			//			else if(empty_reg==1'b1) begin
			//				if(i_wr==1'b1) begin
			//					pointer	<= pointer;
			//				end
			//			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	empty_reg
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			empty_reg	<= 1'b1;
		end
		else begin
			if((pointer_zero==1'b1)&&(i_wr==1'b1)) begin
				empty_reg	<= 1'b0;
			end
			else if((pointer_zero==1'b1)&&(i_rd==1'b1)) begin
				empty_reg	<= 1'b1;
			end
		end
	end
	assign	pointer_zero	= (|pointer==1'b0) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	���ź�
	//  -------------------------------------------------------------------------------------
	generate
		if((FIFO_DEPTH==16)||(FIFO_DEPTH==32)) begin : full_flag_gen_simple
			assign	full_int		= &pointer;
			assign	half_full_int	= pointer[FIFO_PTR_WIDTH-1];
		end
		else begin : full_flag_gen_complex
			assign	full_int		= (pointer==(FIFO_DEPTH-1)) ? 1'b1 : 1'b0	;
			assign	half_full_int	= (pointer>=(FIFO_DEPTH/2)) ? 1'b1 : 1'b0	;
		end
	endgenerate

	//  -------------------------------------------------------------------------------------
	//	���
	//  -------------------------------------------------------------------------------------
	assign	o_full			= full_int;
	assign	o_empty			= empty_reg;
	assign	o_half_full		= half_full_int;
	assign	ov_dout			= store_data;


endmodule
