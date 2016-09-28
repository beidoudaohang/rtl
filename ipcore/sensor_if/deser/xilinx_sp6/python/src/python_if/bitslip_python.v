
//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : bitslip_python.v
//  -- �����       : ��
//-------------------------------------------------------------------------------------------------
//
//  --�޸ļ�¼  :
//
//  -- ����         :| �޸�����     :|  �޸�˵��
//---------------------------------------------------------------------------------------
//  -- ��       	:| 02/25/2013   :|  ��ʼ�汾
//
//---------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1)  : ����bitslip�����ź�
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale      1ns/100ps
//-------------------------------------------------------------------------------------------------

module  bitslip_python # (
	parameter	SER_FIRST_BIT			= "MSB"				,	//"LSB" or "MSB" , first bit to the receiver
	parameter	CHANNEL_NUM				= 4					,	//���ͨ������
	parameter	DESER_WIDTH				= 5						//ÿ��ͨ���⴮��� 2-8
	)
	(
	input												clk				,	//�ָ�ʱ��
	input												reset			,	//����Ч��λ
	input		[DESER_WIDTH*(CHANNEL_NUM+1)-1:0]		iv_data			,	//�⴮��������
	output												o_clk_en		,	//ʱ��ʹ���ź�
	input												i_bitslip_en	,	//bitslip�ź�ʹ��
	output												o_bitslip_done	,	//�����ź�
	output												o_bitslip		,	//bitslip�ź�
	output		[2*DESER_WIDTH*CHANNEL_NUM-1:0]			ov_data			,	//�������
	output		[2*DESER_WIDTH-1:0]						ov_ctrl				//�������
	);

	//ref signals

	//  -------------------------------------------------------------------------------------
	//  ����
	//	--��sensor���������ڼ��ʱ������ͨ��������ͨ�����Ƿ��͵�ͬ����
	//	--ÿ5���ж�һ���Ƿ����
	//  -------------------------------------------------------------------------------------
	localparam		SYNC_WORD			= (DESER_WIDTH==5) ? 10'h3a6 : 8'he9;
	localparam		BITSLIP_CNT_LENGTH	= 5	;

	//FSM Parameter Define
	parameter	S_IDLE		= 2'd0;
	parameter	S_CHK		= 2'd1;
	parameter	S_SLIP		= 2'd2;
	parameter	S_DONE		= 2'd3;

	reg		[1:0]	current_state	= S_IDLE;
	reg		[1:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	integer			state_ascii;
	always @ ( * ) begin
		case(current_state)
			2'd0 :	state_ascii	<= "S_IDLE";
			2'd1 :	state_ascii	<= "S_CHK";
			2'd2 :	state_ascii	<= "S_SLIP";
			2'd3 :	state_ascii	<= "S_DONE";
		endcase
	end
	// synthesis translate_on

	reg		[1:0]									bitslip_en_shift		;	//��λʹ�ܴ�����
	wire											bitslip_en_int	;
	wire	[DESER_WIDTH-1:0]						wv_data_lane[CHANNEL_NUM:0]	;	//������ϵ�ͨ��1������
	reg		[2*DESER_WIDTH-1:0]						data_lane_align[CHANNEL_NUM:0]	;	//������ϵ�ͨ��1������
	reg												div_cnt					= 1'b0	;	//��Ƶ������
	reg		[DESER_WIDTH*2-1:0]						data_lane0_shift		= 'b0	;	//lan0ͨ����λ�Ĵ���
	reg		[2:0]									dly_cnt	= 3'b0;
	reg												bitslip_done	= 1'b0;
	reg												bitslip_reg	= 1'b0;

	//ref ARCHITECTURE
	//	===============================================================================================
	//	ref ***�첽ʱ������***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	i_bitslip_enΪclk_pixʱ����ת����i_clk_parallelʱ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		bitslip_en_shift	<=	{bitslip_en_shift[0],i_bitslip_en};
	end

	//	-------------------------------------------------------------------------------------
	//	���Ѿ�����֮�󣬽�ֹ�ٴζ�λ
	//	-------------------------------------------------------------------------------------
	assign	bitslip_en_int	= bitslip_done ? 1'b0 : bitslip_en_shift[1];

	//	===============================================================================================
	//	ref ***���ͬ����***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	����ͨ��
	//	--ÿ��ͨ����λ���� DESER_WIDTH ��bit
	//	--��ˣ���ߵ�ͨ���ڵ�byte��С�ˣ���͵�ͨ���ڵ�byte��
	//	-------------------------------------------------------------------------------------
	genvar	i;
	generate
		for(i=0;i<CHANNEL_NUM+1;i=i+1) begin
			assign	wv_data_lane[i]	= iv_data[DESER_WIDTH*(i+1)-1:DESER_WIDTH*i];
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	��lan0��λ��ÿ���ƶ� DESER_WIDTH ��bit
	//	--Ŀǰ�ļ�ⷽ����ֻ��lane0���ͬ���֡�����ͨ�������
	//	--lan0�� DESER_WIDTH bit����ÿ����λ��ע�⣬�˴�������LSB MSB �����ǽ����ݴ���Ͷ��Ƶ���߶�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(SER_FIRST_BIT=="LSB") begin
			data_lane0_shift	<= {wv_data_lane[0],data_lane0_shift[DESER_WIDTH*2-1:DESER_WIDTH]};
		end
		else if(SER_FIRST_BIT=="MSB") begin
			data_lane0_shift	<= {data_lane0_shift[DESER_WIDTH*2-1:0],wv_data_lane[0]};
		end
	end

	//	-------------------------------------------------------------------------------------
	//	��LSBΪ����˵��data lock��ƴ���߼�
	//	-------------------------------------------------------------------------------------
	//	-------------------------------------------------------------------------------------
	//			  	  ____   ____   ____   ____   ____   ____   ____   ____   ____   ____   ____   ____   ____   ____
	//	clk_2x		__|  |___|  |___|  |___|  |___|  |___|  |___|  |___|  |___|  |___|  |___|  |___|  |___|  |___|  |___
	//
	//	byte in		--<H0    ><L0   ><H1   ><L1   ><H2   ><L2   ><H3   ><L3   ><H4   ><L4   ><H5   ><L5   ><H6   ><L6   >
	//
	//									                 ______________________________________________________________________
	//	data lock	_____________________________________|
	//
	//	byte shift	-----------------<H0L0 ><L0H1 ><H1L2 ><H2L1 >
	//
	//	data align	--------------------------------------<L1H2 ><H2L2 ><L2H3 ><H3L3 ><L3H4 ><H4L4 ><L4H5 ><H5L5 ><L5H6 >
	//						    								________      ________      ________      ________
	//	clk en		____________________________________________|      |______|      |______|      |______|      |______
	//
	//
	//	-------------------------------------------------------------------------------------

	//	===============================================================================================
	//	ref ***ƴ������***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	ÿ��ͨ������ʱ1��
	//	--2�� DESER_WIDTH bit��ƴ��һ��word
	//	--LSBģʽ���Ƚ��յ��� DESER_WIDTH bit�ǵ�λ��MSBģʽ���Ƚ��յ��� DESER_WIDTH bit�Ǹ�λ
	//	-------------------------------------------------------------------------------------
	genvar	j;
	generate
		for(j=0;j<CHANNEL_NUM+1;j=j+1) begin
			if(SER_FIRST_BIT=="LSB") begin
				always @ (posedge clk) begin
					data_lane_align[j]	= {wv_data_lane[j],data_lane_align[j][2*DESER_WIDTH-1:DESER_WIDTH]};
				end
			end
			else if(SER_FIRST_BIT=="MSB") begin
				always @ (posedge clk) begin
					data_lane_align[j]	= {data_lane_align[j][DESER_WIDTH-1:0],wv_data_lane[j]};
				end
			end
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	div_cnt ��Ƶ������
	//	--ֻ�� data_lock == 1��ʱ��ſ�ʼ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!bitslip_done) begin
			div_cnt	<= 'b0;
		end
		else begin
			div_cnt	<= !div_cnt;
		end
	end
	assign	o_clk_en	= div_cnt;

	//	===============================================================================================
	//	ref ***bitslip ����߼�***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	dly_cnt��ʱ�ź�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			dly_cnt	<= 'b0;
		end
		else begin
			if(current_state==S_SLIP || current_state==S_DONE) begin
				dly_cnt	<= dly_cnt + 1'b1;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	��һ��֮��û�м�⵽ͬ���֣�����λ
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_SLIP && dly_cnt==3'd0) begin
			bitslip_reg	<= 1'b1;
		end
		else begin
			bitslip_reg	<= 1'b0;
		end
	end
	assign	o_bitslip	= bitslip_reg	;

	//	-------------------------------------------------------------------------------------
	//	��������ź�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			bitslip_done	<= 1'b0;
		end
		else begin
			if(current_state==S_SLIP) begin
				bitslip_done	<= 1'b0;
			end
			else if(current_state==S_DONE && dly_cnt==3'd7) begin
				bitslip_done	<= 1'b1;
			end
		end
	end
	assign	o_bitslip_done	= bitslip_done;

	//	-------------------------------------------------------------------------------------
	//	������������ݣ����ִ�С��
	//	-------------------------------------------------------------------------------------
	genvar	l;
	generate
		for(l=0;l<CHANNEL_NUM;l=l+1) begin
			assign	ov_data[(l+1)*(2*DESER_WIDTH)-1:l*(2*DESER_WIDTH)]	= data_lane_align[l+1];
		end
	endgenerate
	assign	ov_ctrl[(2*DESER_WIDTH)-1:0]	= data_lane_align[0];

	//	===============================================================================================
	//	ref FSM
	//	===============================================================================================
	//FSM Sequential Logic
	always @ (posedge clk) begin
		if(reset) begin
			current_state	<= S_IDLE;
		end
		else begin
			current_state	<= next_state;
		end
	end

	//FSM Conbinatial Logic
	always @ ( * ) begin
		case(current_state)
			S_IDLE	:
			if(bitslip_en_int) begin
				next_state	= S_CHK;
			end
			else begin
				next_state	= S_IDLE;
			end
			S_CHK	:
			if(data_lane0_shift==SYNC_WORD) begin
				next_state	= S_DONE;
			end
			else begin
				next_state	= S_SLIP;
			end
			S_SLIP	:
			if(dly_cnt==6) begin
				next_state	= S_IDLE;
			end
			else begin
				next_state	= S_SLIP;
			end
			S_DONE	:
			if(dly_cnt==7) begin
				next_state	= S_IDLE;
			end
			else begin
				next_state	= S_DONE;
			end
			default	:
			next_state	= S_IDLE;
		endcase
	end


endmodule