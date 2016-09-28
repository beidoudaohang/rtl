//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : spi_master_core
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/10/29 15:19:11	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1)  : ֻ֧��mode0ģʽ��cpol=0 cpha=0
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module spi_master_core # (
	parameter	SPI_FIRST_DATA	= "MSB"	,	//"MSB" or "LSB"
	parameter	SPI_CS_POL		= "LOW"	,	//"HIGH" or "LOW" ��cs��Чʱ�ĵ�ƽ
	parameter	SPI_LEAD_TIME	= 1		,	//��ʼʱ��CS �� CLK �ľ��룬��λ��ʱ�����ڣ���ѡ 1 2 3
	parameter	SPI_LAG_TIME	= 1			//����ʱ��CS �� CLK �ľ��룬��λ��ʱ�����ڣ���ѡ 1 2 3
	)
	(
	//ʱ�Ӻ͸�λ
	input			clk					,	//ģ�鹤��ʱ��
	//spi�ӿ��ź� 4 wire
	output			o_spi_clk			,	//spi ʱ��
	output			o_spi_cs			,	//spi Ƭѡ������Ч
	output			o_spi_mosi			,	//�������������
	input			i_spi_miso			,	//�����룬�����
	//����fifo �ӿ�
	output			o_cmd_fifo_rd		,	//cmd fifo ��ʹ��
	input	[8:0]	iv_cmd_fifo_dout	,	//cmd fifo ���������bit8 ��ʾ�ǵ�һ���ֽ�
	input			i_cmd_fifo_empty	,	//cmd fifo ���ź�
	//������fifo �ӿ�
	output			o_rdback_fifo_wr	,	//rdback fifo дʹ��
	output	[7:0]	ov_rdback_fifo_din		//rdback fifo д����
	);

	//	ref signals
	//FSM Parameter Define
	parameter	S_IDLE		= 3'd0;
	parameter	S_CHK_BIT	= 3'd1;
	parameter	S_LEAD_DLY	= 3'd2;
	parameter	S_SHIFT		= 3'd3;
	parameter	S_LAG_DLY	= 3'd4;


	reg		[2:0]	current_state	= S_IDLE;
	reg		[2:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	reg		[79:0]			state_ascii;
	always @ ( * ) begin
		case(current_state)
			3'd0 :	state_ascii	= "S_IDLE";
			3'd1 :	state_ascii	= "S_CHK_BIT";
			3'd2 :	state_ascii	= "S_LEAD_DLY";
			3'd3 :	state_ascii	= "S_SHIFT";
			3'd4 :	state_ascii	= "S_LAG_DLY";
		endcase
	end
	// synthesis translate_on


	//	ref ARCHITECTURE
	reg					cmd_fifo_rd	= 1'b0;
	reg		[1:0]		cs_delay_cnt	= 2'b0;
	reg		[2:0]		bit_cnt	= 3'b0;
	reg		[7:0]		mosi_shift_reg	= 8'b0;
	reg					spi_cs_reg	= 1'b1;
	wire				spi_clk_en;
	reg		[8:0]		miso_shift_reg	= 9'b0;
	reg					spi_clk_en_dly	= 1'b0;
	reg					rdback_fifo_wr	= 1'b0;


	//  ===============================================================================================
	//	ref 1 cmd fifo ������
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	cmd fifo �Ķ�����
	//	1.��״̬���� S_CHK_BIT ����cmd fifo
	//	2.��״̬���� S_SHIFT ����bit cnt=7 �� cmd fifo�ǿ� �� cmd fifo ���������bit8��0 ����cmd fifo
	//	3.��� iv_cmd_fifo_dout[8]==1'b1��˵������һ�������Ҫ���¿�ʼ
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_CHK_BIT) begin
			cmd_fifo_rd	<= 1'b1;
		end
		else if(current_state==S_SHIFT) begin
			if(bit_cnt==3'h7 && i_cmd_fifo_empty==1'b0 && iv_cmd_fifo_dout[8]==1'b0) begin
				cmd_fifo_rd	<= 1'b1;
			end
			else begin
				cmd_fifo_rd	<= 1'b0;
			end
		end
		else begin
			cmd_fifo_rd	<= 1'b0;
		end
	end
	assign	o_cmd_fifo_rd	= cmd_fifo_rd;

	//  ===============================================================================================
	//	ref 2 spi wr ����
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	cs ��ʱ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_LEAD_DLY) begin
			if(cs_delay_cnt==SPI_LEAD_TIME) begin
				cs_delay_cnt	<= 2'b0;
			end
			else begin
				cs_delay_cnt	<= cs_delay_cnt + 1'b1;
			end
		end
		else if(current_state==S_LAG_DLY) begin
			if(cs_delay_cnt==SPI_LAG_TIME) begin
				cs_delay_cnt	<= 2'b0;
			end
			else begin
				cs_delay_cnt	<= cs_delay_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	bit ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_SHIFT) begin
			bit_cnt	<= bit_cnt + 1'b1;
		end
		else begin
			bit_cnt	<= 'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	mosi��λ�Ĵ���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_SHIFT) begin
			if(bit_cnt==3'h7) begin
				mosi_shift_reg	<= iv_cmd_fifo_dout[7:0];
			end
			else begin
				mosi_shift_reg	<= {mosi_shift_reg[6:0],mosi_shift_reg[7]};
			end
		end
		else if(current_state==S_CHK_BIT) begin
			mosi_shift_reg	<= iv_cmd_fifo_dout[7:0];
		end
	end

	assign	o_spi_mosi	= (current_state==S_SHIFT) ? mosi_shift_reg[7] : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	cs �߼�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(current_state)
			S_LEAD_DLY,S_SHIFT,S_LAG_DLY : begin
				spi_cs_reg	<= 1'b0;
			end
			default : begin
				spi_cs_reg	<= 1'b1;
			end
		endcase
	end
	assign	o_spi_cs	= spi_cs_reg;

	//  -------------------------------------------------------------------------------------
	//	ʱ��
	//  -------------------------------------------------------------------------------------
	assign	spi_clk_en	= (current_state==S_SHIFT) ? 1'b1 : 1'b0;
	ODDR2 # (
	.DDR_ALIGNMENT	("C0"			),	// Sets output alignment to "NONE", "C0" or "C1"
	.INIT			(1'b0			),  // Sets initial state of the Q output to 1'b0 or 1'b1
	.SRTYPE			("ASYNC"		)	// Specifies "SYNC" or "ASYNC" set/reset
	)
	ODDR2_spi_clk_inst (
	.Q				(o_spi_clk		),
	.C0				(!clk			),
	.C1				(clk			),
	.CE				(spi_clk_en		),
	.D0				(1'b1			),
	.D1				(1'b0			),
	.R				(1'b0			),
	.S				(1'b0			)
	);

	//  ===============================================================================================
	//	ref 3 spi ״̬��
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	״̬��
	//  -------------------------------------------------------------------------------------
	//FSM Sequential Logic
	always @ (posedge clk) begin
		current_state	<= next_state;
	end

	//FSM Conbinatial Logic
	always @ ( * ) begin
		case(current_state)
			//  -------------------------------------------------------------------------------------
			//	������fifo���յ�ʱ�򣬽����fifo״̬
			//  -------------------------------------------------------------------------------------
			S_IDLE :
			if(!i_cmd_fifo_empty) begin
				next_state	= S_CHK_BIT;
			end
			else begin
				next_state	= S_IDLE;
			end
			//  -------------------------------------------------------------------------------------
			//	1.������bit��1��˵���ǵ�һ�����ݣ���������״̬
			//	2.������bit��0��˵�����ǵ�һ�����ݣ��ص�idle
			//  -------------------------------------------------------------------------------------
			S_CHK_BIT :
			if(iv_cmd_fifo_dout[8]==1'b1) begin
				next_state	= S_LEAD_DLY;
			end
			else begin
				next_state	= S_IDLE;
			end
			//  -------------------------------------------------------------------------------------
			//	����ʱʱ�䵽�˵�ʱ�򣬽�����һ��״̬
			//  -------------------------------------------------------------------------------------
			S_LEAD_DLY :
			if(cs_delay_cnt==SPI_LEAD_TIME) begin
				next_state	= S_SHIFT;
			end
			else begin
				next_state	= S_LEAD_DLY;
			end
			//  -------------------------------------------------------------------------------------
			//	1.��λ�����һ��bit�������ʱfifo���ˣ���Ϊһ�β������������� S_LAG_DLY ״̬
			//	2.��λ�����һ��bit�������ʱfifo���գ���������bit8=1������ S_LAG_DLY ״̬
			//	3.���������ͣ��shift״̬
			//  -------------------------------------------------------------------------------------
			S_SHIFT :
			if(bit_cnt==3'h7) begin
				if(i_cmd_fifo_empty==1'b1) begin
					next_state	= S_LAG_DLY;
				end
				else if(iv_cmd_fifo_dout[8]==1'b1) begin
					next_state	= S_LAG_DLY;
				end
				else begin
					next_state	= S_SHIFT;
				end
			end
			else begin
				next_state	= S_SHIFT;
			end
			//  -------------------------------------------------------------------------------------
			//	β����ʱ����֮�󣬽���idle״̬
			//  -------------------------------------------------------------------------------------
			S_LAG_DLY :
			if(cs_delay_cnt==SPI_LAG_TIME) begin
				next_state	= S_IDLE;
			end
			else begin
				next_state	= S_LAG_DLY;
			end
			default :
			next_state	= S_IDLE;
		endcase
	end

	//  ===============================================================================================
	//	ref 4 spi rd ����
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ʹ��iddr2�������ݣ���clk�½��ؽ������ݣ���clk�����ؽ����ݴ����
	//  -------------------------------------------------------------------------------------
	IDDR2 # (
	.DDR_ALIGNMENT	("C1"	),	// Sets output alignment to "NONE", "C0" or "C1"
	.INIT_Q0		(1'b0	),	// Sets initial state of the Q0 output to 1'b0 or 1'b1
	.INIT_Q1		(1'b0	),	// Sets initial state of the Q1 output to 1'b0 or 1'b1
	.SRTYPE			("SYNC"	)	// Specifies "SYNC" or "ASYNC" set/reset
	)
	IDDR2_miso_inst (
	.Q0				(miso_iddr2	),	// 1-bit output captured with C0 clock
	.Q1				(			),	// 1-bit output captured with C1 clock
	.C0				(!clk		),	// 1-bit clock input
	.C1				(clk		),	// 1-bit clock input
	.CE				(1'b1		),	// 1-bit clock enable input
	.D				(i_spi_miso	),	// 1-bit DDR data input
	.R				(1'b0		),	// 1-bit reset input
	.S				(1'b0		)	// 1-bit set input
	);

	//  -------------------------------------------------------------------------------------
	//	miso ��λ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		spi_clk_en_dly	<= spi_clk_en;
	end

	always @ (posedge clk) begin
		if(spi_clk_en_dly) begin
			miso_shift_reg[7:0]	<= {miso_shift_reg[6:0],miso_iddr2};
		end
		else begin
			miso_shift_reg[7:0]	<= 8'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	miso_shift_reg bit8 ��ʾspi ��λ�ĵ�һ��byte
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!spi_clk_en_dly) begin
			miso_shift_reg[8]	<= 1'b1;
		end
		else begin
			if(rdback_fifo_wr) begin
				miso_shift_reg[8]	<= 1'b0;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	rdback fifo д����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(spi_clk_en_dly==1'b1 && bit_cnt==3'h0) begin
			rdback_fifo_wr	<= 1'b1;
		end
		else begin
			rdback_fifo_wr	<= 1'b0;
		end
	end
	assign	o_rdback_fifo_wr	= rdback_fifo_wr;
	assign	ov_rdback_fifo_din	= miso_shift_reg;



endmodule
