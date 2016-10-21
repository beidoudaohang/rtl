//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : u3v_format
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/10/21 15:25:14	:|  ��ʼ�汾
//  -- �Ϻ���       :| 2016/4/25 17:40:31	:|  1.���� FVAL_TS_STABLE_NS ����
//												2.���ʱ�ӳ���60MHzʱ��chunk�е�ʱ����ɲ��ȵ�����
//  -- �Ϻ���       :| 2016/9/21 15:29:55	:|  ��fval=1��ʱ�� se=0 se=1��blockid��Ҫ����
//
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module u3v_format # (
	parameter	PIX_CLK_FREQ_KHZ	= 65000	,	//����ʱ�ӵ�Ƶ�ʣ���khzΪ��λ
	parameter	FVAL_TS_STABLE_NS	= 95	,	//��fval�������ȶ�����ʱ�����ʱ��
	parameter	DATA_WD				= 64	,	//�����������λ��������ʹ��ͬһ����
	parameter	SHORT_REG_WD 		= 16	,	//�̼Ĵ���λ��
	parameter	REG_WD 				= 32	,	//�Ĵ���λ��
	parameter	LONG_REG_WD 		= 64		//���Ĵ���λ��
	)
	(
	//  ===============================================================================================
	//  ��һ���֣�ʱ�Ӹ�λ
	//  ===============================================================================================
	input								clk						,	//ʱ���źţ�����ʱ��ʱ����ͬ�ڲ�����ʱ��
	input								reset					,	//��λ�źţ��ߵ�ƽ��Ч������ʱ��ʱ����
	//  ===============================================================================================
	//  �ڶ����֣��С��������ݡ�������Ч
	//  ===============================================================================================
	input								i_fval					,	//����ͨ·����ĳ��źţ�����ʱ��ʱ����,fval���ź��Ǿ�������ͨ���ӿ����ĳ��źţ���ͷ��������leader����������Ч��ͼ�����ݣ�ͣ���ڼ䱣�ֵ͵�ƽ
	input								i_data_valid			,	//����ͨ·�����������Ч�źţ���־32λ����Ϊ��Ч����
	input	[DATA_WD-1:0]				iv_data					,	//����ͨ·ƴ�Ӻõ�32bit���ݣ���������Ч���룬������ʱ�Ӷ���
	//  ===============================================================================================
	//  �������֣����ƼĴ�����chunk��Ϣ��ֻ���Ĵ���
	//  ===============================================================================================
	input								i_stream_enable			,	//��ʹ���źţ�����ʱ��ʱ����=0�����������ֹͣ��chunk�е�BLOCK IDΪ0
	input								i_acquisition_start     ,	//�����źţ�����ʱ��ʱ����=0����־����֡�����������β�������ֹͣ
	input	[REG_WD-1:0]				iv_pixel_format         ,	//���ظ�ʽ������������leader��,����ͨ·������Чʱ�����ƣ���ģ�鲻���ٽ�����Чʱ������
	input								i_chunk_mode_active     ,	//chunk�ܿ��أ����ش�Payload Typeʹ��Ϊimage extend chunk ���ͣ�chunk�ر�Ϊimage����
	input								i_chunkid_en_ts         ,	//ʱ���chunkʹ��
	input								i_chunkid_en_fid        ,	//frame id chunkʹ��
	input	[REG_WD-1:0]				iv_chunk_size_img       ,	//ͼ�񳤶ȣ����ֽ�Ϊ��λ����pixel formatΪ8bitʱ��һ������ռһ���ֽڣ���pixel format 10 bitʱ��һ������ռ�������ֽڡ�
	input	[LONG_REG_WD-1:0]			iv_timestamp			,	//ͷ���е�ʱ����ֶ�,�ɿ���ͨ�����͹���,iv_timestamp�ڳ��ź�������8��ʱ��֮������ȶ�
	input	[SHORT_REG_WD-1:0]			iv_size_x				,	//ͷ���еĴ��ڿ���
	input	[SHORT_REG_WD-1:0]			iv_size_y				,	//ͷ���еĴ��ڸ߶�
	input	[SHORT_REG_WD-1:0]			iv_offset_x				,	//ͷ���е�ˮƽƫ��
	input	[SHORT_REG_WD-1:0]			iv_offset_y				,	//ͷ���еĴ�ֱ����
	input	[REG_WD-1:0]				iv_trailer_size_y		,	//β���е���Ч�߶��ֶ�
	//  ===============================================================================================
	//  ���Ĳ��֣��С�������Ч������
	//  ===============================================================================================
	output								o_trailer_flag          ,	//β����־
	output								o_fval					,	//������ͷβ�ĳ��źţ�����Ҫ���źŵ����������ȵ�һ����Ч10��clk���½���Ҫ�ͺ������һ����Ч����10��ʱ�����ϣ��Ա�֤֡������������
	output								o_data_valid			,	//������ͷβ��������Ч�ź�
	output	[DATA_WD-1:0]				ov_data
	);

	//	ref signals
	//FSM Parameter Define
	parameter	S_IDLE		= 3'd0;
	parameter	S_TIMESTAMP	= 3'd1;
	parameter	S_LEADER	= 3'd2;
	parameter	S_IMAGE		= 3'd3;
	parameter	S_CHUNK		= 3'd4;
	parameter	S_TRAILER	= 3'd5;
	parameter	S_EXT		= 3'd6;

	reg		[2:0]	current_state	= S_IDLE;
	reg		[2:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	reg		[63:0]			state_ascii;
	always @ ( * ) begin
		case(current_state)
			3'd0 :	state_ascii	<= "S_IDLE";
			3'd1 :	state_ascii	<= "S_TIMESTAMP";
			3'd2 :	state_ascii	<= "S_LEADER";
			3'd3 :	state_ascii	<= "S_IMAGE";
			3'd4 :	state_ascii	<= "S_CHUNK";
			3'd5 :	state_ascii	<= "S_TRAILER";
			3'd6 :	state_ascii	<= "S_EXT";
		endcase
	end
	// synthesis translate_on

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

	//����ʱ�����ڣ��� ns Ϊ��λ
	parameter		CLK_PERIOD_NS		= 1000000/PIX_CLK_FREQ_KHZ;

	//fval���� FVAL_TS_STABLE_NS ֮���ڱ�ʱ�����ڣ�timestamp�����ȶ�
	//��fval�������غ��½��ض������ʱ������������ǰ�ʱ����ŵ�leader���У��½����ǰ�ʱ�������chunk����
	localparam		TIMESTAMP_DELAY		= (FVAL_TS_STABLE_NS/CLK_PERIOD_NS)+1;
	//�˴��� TIMESTAMP_DELAY+5 ��ԭ���� CHUNK_SIZE = TIMESTAMP_DELAY+5
	localparam		PIPE_DELAY_WIDTH	= log2(TIMESTAMP_DELAY+5+1);
	//������С�Ŀ��ȣ�3
	localparam		PIPE_WIDTH			= (PIPE_DELAY_WIDTH > 3) ? PIPE_DELAY_WIDTH : 3;
	localparam		FID_LENTH			= 32'h8	;	//frameid ����
	localparam		TS_LENTH			= 32'h8	;	//timestamp ����

	localparam		PAYLOAD_SHIFT_NUM		= log2(DATA_WD/8);

	localparam		LEADER_SIZE			= 7;	//LEADER SIZE 52BYTE������4byte
	localparam		TRAILER_SIZE_CHUNK	= 7;	//CHUNKģʽ�£�TRAILER SIZE 56BYTE ��������36byte��ȣ�����20byte���൱�ڶ���2�İ�
	localparam		CHUNK_SIZE			= TIMESTAMP_DELAY+5;	//CHUNK�������40byte
	localparam		EXT_SIZE			= 10;	//fval lval �½�����ʱ

	reg									fval_dly				= 1'b0;
	wire								fval_rise				;
	wire								fval_fall				;
	reg									stream_enable_reg		= 1'b0;
	reg		[PIPE_DELAY_WIDTH-1:0]		pipe_cnt				= {PIPE_DELAY_WIDTH{1'b0}};
	reg		[3:0]						ext_cnt					= 4'b0;
	wire	[63:0]						blockid					;
	wire	[46:0]						blockid_low47			;
	reg		[63:0]						data_reg				= 64'b0;
	reg									data_valid				= 1'b0;
	reg									fval_reg				= 1'b0;
	reg									trailer_flag			= 1'b0;
	reg									chunk_mode_active_dly	;
	reg									chunkid_en_ts_dly		;
	reg									chunkid_en_fid_dly		;
	reg		[7:0]						chunk_layout_id			= 8'h0;
	reg									chunk_mode_active_latch	= 1'b0;

	reg 	[REG_WD-1:0]				payload_cnt				;	//����ͼ���С������
	reg 	[REG_WD-1:0]				act_payload_cnt			;
	reg		[15:0]						status					= 16'b0;
	wire	[REG_WD-1:0]				valid_payload_size_tmp	;	//��Ч��ͼ������
	reg		[REG_WD-1:0]				valid_payload_size		;	//��Ч��ͼ������


	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***edge***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	fval ��ȡ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk ) begin
		fval_dly	<= i_fval;
	end
	assign	fval_rise	= (fval_dly==1'b0 && i_fval==1'b1) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_dly==1'b1 && i_fval==1'b0) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	��se=0�� fval������
	//	1.��se=0��ʱ�� stream_enable_reg ����Ϊ0
	//	2.��se=1��ʱ��֪��fval�����أ�stream_enable_reg������Ϊ1.
	//	3.Ŀ���Ǳ�֤se=1֮�������֡
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_stream_enable==1'b0) begin
			stream_enable_reg	<= 1'b0;
		end
		else if(fval_rise==1'b1) begin
			stream_enable_reg	<= 1'b1;
		end
	end

	//	===============================================================================================
	//	se ����������Ĵ����Ķ�������ʱע����
	//	��u3vЭ���У���se=1��ʱ�����������޸ļĴ�����
	//	===============================================================================================
	//	//	-------------------------------------------------------------------------------------
	//	//	se ��ȡ����
	//	//	-------------------------------------------------------------------------------------
	//	always @ (posedge clk) begin
	//		stream_enable_dly	<= i_stream_enable;
	//	end
	//	assign	se_rise	= (stream_enable_dly==1'b0 && i_stream_enable==1'b1) ? 1'b1 : 1'b0;
	//
	//	//	-------------------------------------------------------------------------------------
	//	//	����chunkʹ���ź�
	//	//	-------------------------------------------------------------------------------------
	//	always @ (posedge clk) begin
	//		if(se_rise) begin
	//			chunk_mode_active_latch	<= i_chunk_mode_active	;
	//			chunkid_en_ts_latch		<= i_chunkid_en_ts		;
	//			chunkid_en_fid_latch	<= i_chunkid_en_fid	;
	//		end
	//	end

	//	===============================================================================================
	//	ref ***main***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	pipe_cnt ÿ��״̬�£���pipe_cnt��Ϊ�������ӵļ�����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(current_state)
			//	-------------------------------------------------------------------------------------
			//	TIMESTAMP ״̬�£��ȴ� timestamp �����ȶ�
			//	--timestamp��Ҫ����110ns�����ȶ�
			//	-------------------------------------------------------------------------------------
			S_TIMESTAMP	:
			if(pipe_cnt==(TIMESTAMP_DELAY-1)) begin
				pipe_cnt	<= 'b0;
			end
			else begin
				pipe_cnt	<= pipe_cnt + 1'b1;
			end
			//	-------------------------------------------------------------------------------------
			//	LEADER ״̬�£��������ﵽ LEADER_SIZE pipe_cnt����
			//	-------------------------------------------------------------------------------------
			S_LEADER	:
			if(pipe_cnt==(LEADER_SIZE-1)) begin
				pipe_cnt	<= 'b0;
			end
			else begin
				pipe_cnt	<= pipe_cnt + 1'b1;
			end
			//	-------------------------------------------------------------------------------------
			//	S_TRAILER ״̬�£���2��trailer����
			//	-- �ﵽ TRAILER_SIZE_CHUNK ʱ��pipe_cnt���㣬������chunk�Ƿ�ʹ�ܣ�trailerд���һ��������û�������
			//	-------------------------------------------------------------------------------------
			S_TRAILER	:
			if(pipe_cnt==(TRAILER_SIZE_CHUNK-1)) begin
				pipe_cnt	<= 'b0;
			end
			else begin
				pipe_cnt	<= pipe_cnt + 1'b1;
			end
			//	-------------------------------------------------------------------------------------
			//	CHUNK ״̬�£��������ﵽ CHUNK_SIZE pipe_cnt����
			//	-------------------------------------------------------------------------------------
			S_CHUNK	:
			if(pipe_cnt==(CHUNK_SIZE-1)) begin
				pipe_cnt	<= 'b0;
			end
			else begin
				pipe_cnt	<= pipe_cnt + 1'b1;
			end
			//	-------------------------------------------------------------------------------------
			//	���� ״̬�£������� pipe_cnt ����
			//	-------------------------------------------------------------------------------------
			default	:
			pipe_cnt	<= 'b0;
		endcase
	end

	//	-------------------------------------------------------------------------------------
	//	��ʱ������������չ�� fval�½��غ� lval�½���֮��ľ���
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_EXT) begin
			ext_cnt	<= ext_cnt + 1'b1;
		end
		else begin
			ext_cnt	<= 'b0;
		end
	end

	//  ===============================================================================================
	//  ref ***block_id***
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	blockid
	//	--��dspʵ�� 47bit �ӷ���ÿ��1000֡���㣬47bit�ܹ����� 4462 �꣬�㹻��
	//	-------------------------------------------------------------------------------------
	reg		[46:0]		adder_a		= 47'b0;
	reg					adder_ce	= 1'b0;
	wire	[46:0]		adder_sum	;
	reg		[46:0]		blockid_low47_reg	= 47'h0;

	//	-------------------------------------------------------------------------------------
	//	���� dsp�ӷ���ģ��
	//	1.��ce=1 sclr=0��ʱ��s=a+1
	//	2.�ӷ���λ��Ϊ47bit
	//	3.�ӷ�����ʱ���ã���fval��Ч�ڼ䣬��Ϊact payload cnt����������fval������ʱ����Ϊblockid�ļ�������
	//	-------------------------------------------------------------------------------------
	u3v_adder_47 u3v_adder_47_inst (
	.clk	(clk				),
	.ce		(adder_ce			),
	.sclr	(!stream_enable_reg | fval_rise	),
	.a		(adder_a			),
	.s		(adder_sum			)
	);

	//	-------------------------------------------------------------------------------------
	//	�л���Ҫ�ۼӵ�����
	//	1.��ext�׶Σ���������blockid��
	//	2.�������׶Σ��������Ǽӷ�֮�ͣ����ۼӵ�Ч����
	//	-------------------------------------------------------------------------------------
	always @ (*) begin
		if(current_state==S_EXT) begin
			adder_a	<= blockid_low47_reg;
		end
		else begin
			adder_a	<= adder_sum;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	dsp�ӷ���ʹ�ܿ���
	//	1.��ext�׶ε����һ��ʱ�����ڣ��ӷ���ʹ�ܴ򿪣�blockid+1����idle״̬���ӷ����Ľ����ֵ��blockid��
	//	2.��image�׶Σ���ͼ����Ч��ʱ�򣬼ӷ����򿪣���ͼ�������Ч����
	//	3.�����׶Σ��ӷ�����ʹ��
	//	-------------------------------------------------------------------------------------
	always @ (*) begin
		if(current_state==S_EXT && ext_cnt==(EXT_SIZE-1)) begin
			adder_ce	<= 1'b1;
		end
		else if(current_state==S_IMAGE && i_data_valid==1'b1) begin
			adder_ce	<= 1'b1;
		end
		else begin
			adder_ce	<= 1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	block id ƴ�ӣ�blockidֻ��47bitλ��������Ѿ����
	//	1.�� se=0 ��ʱ��block����
	//	2.�� se=1 �Ҿ���һ������֮֡����idle״̬��blockid����Ϊ�ӷ����ļӷ�֮��
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(stream_enable_reg==1'b0) begin
			blockid_low47_reg	<= 'b0;
		end
		else if(current_state==S_IDLE) begin
			blockid_low47_reg	<= adder_sum;
		end
	end
	assign	blockid	= {17'h0,blockid_low47_reg};

	//	===============================================================================================
	//	ref ***chunk_layoutid***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	��chunkʹ���źŴ���
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		chunk_mode_active_dly	<= i_chunk_mode_active	;
		chunkid_en_ts_dly		<= i_chunkid_en_ts		;
		chunkid_en_fid_dly		<= i_chunkid_en_fid		;
	end
	//	-------------------------------------------------------------------------------------
	//	chunk_layoutid
	//	--��chunkʹ���ź��иı��ʱ�� id++
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(chunk_mode_active_dly^i_chunk_mode_active || chunkid_en_ts_dly^i_chunkid_en_ts || chunkid_en_fid_dly^i_chunkid_en_fid) begin
			chunk_layout_id	<= chunk_layout_id + 1'b1;
		end
	end

	//	===============================================================================================
	//	ref ***ov_status ov_valid_payload_size***
	//	===============================================================================================
	//  ===============================================================================================
	//  ���ݼ����������ͼ�������ڼ��ʵ�ʸ����������õ�iv_chunk_size_img�Ƚ��ж��Ƿ�overrun
	//  ===============================================================================================
	//	ͳ��image_flag�ڼ��������Ч����
	always @ (posedge clk) begin
		if(fval_rise) begin
			act_payload_cnt	<= 0;
		end
		else if(fval_fall) begin
			act_payload_cnt	<= adder_sum<<PAYLOAD_SHIFT_NUM;
		end
	end

	//��ʵ���ֽ�������iv_chunk_size_imgʱ˵�������������Ҫ�ô���״̬λ
	always @ (posedge clk) begin
		if(act_payload_cnt[REG_WD-1:3]>iv_chunk_size_img[REG_WD-1:3]) begin
			status	<= 16'hA101;
		end
		else begin
			status	<= 16'H0000;
		end
	end

	//ȡʵ���ֽ�����iv_chunk_size_img����ֵ�е���Сֵ��Ϊvalid payloadsize
	assign	valid_payload_size_tmp	= (act_payload_cnt[REG_WD-1:3]>iv_chunk_size_img[REG_WD-1:3]) ? iv_chunk_size_img : act_payload_cnt;

	always @ (posedge clk) begin
		case({i_chunk_mode_active,i_chunkid_en_ts,i_chunkid_en_fid})
			3'b100	: valid_payload_size	<= valid_payload_size_tmp + 8;
			3'b110	: valid_payload_size	<= valid_payload_size_tmp + 24;
			3'b101	: valid_payload_size	<= valid_payload_size_tmp + 24;
			3'b111	: valid_payload_size	<= valid_payload_size_tmp + 40;
			default	: valid_payload_size	<= valid_payload_size_tmp;
		endcase
	end

	//	===============================================================================================
	//	ref ***output***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	***��CHUNK����ģʽ***
	//	STREAM	:	LEADER	|	IMAGE	|	TRAILER
	//					|	|			|		|
	//				52byte	|			|	32byte
	//						|--payload--|
	//
	//
	//	***CHUNK����ģʽ***
	//	STREAM	:	LEADER	|	IMAGE 	ID1 LENGTH1		FRAMEID	ID2	LENGTH2		TIMESTAMP	ID3	LENGTH3		|	TRAILER
	//					|	|			|		|			|	|		|			|		|		|		|		|
	//				52byte	|			4byte	4byte	8byte	4byte	4byte		8byte	4byte	4byte	|	36byte
	//						|																				|
	//						|-------------------------------    payload    ---------------------------------|
	//
	//	���CHUNKģʽ��ȣ�CHUNK ģʽ�£�payloadҪ���40byte
	//
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(current_state)
			S_LEADER	:
			case(pipe_cnt)
				//{{leader_size,reserved},magic_key}=={{leader_size,0},LV3U}
				0		: data_reg	<= {{16'd52,16'd0},32'h4c563355};
				//blockid
				1		: data_reg	<= blockid[63:0];
				//{timestamp[31:0],payload_type,reserved} payload_type-����ֻ֧��Image��0x0001����Image Extended Chunk��0x4001��
				2		: data_reg	<= {iv_timestamp[31:0],{1'b0,i_chunk_mode_active,{14'h0001},16'h0000}};
				//{pixel_format,timestamp[63:32]}
				3		: data_reg	<= {iv_pixel_format,iv_timestamp[63:32]};
				//{size_y,size_x}
				4		: data_reg	<= {{16'h00,iv_size_y},{16'h00,iv_size_x}};
				//{offset_y,offset_x}
				5		: data_reg	<= {{16'h00,iv_offset_y},{16'h00,iv_offset_x}};
				//{dummy_word_by_dh,reserved,padding_x} dummy_word_by_dh��dh�Լ����ӵ����ݣ�Ϊ�����8byte�Ŀռ�
				6		: data_reg	<= {32'h0,32'h0};
				default	: data_reg	<= {32'h0,32'h0};
				//				default	: data_reg	<= iv_data;
			endcase

			S_TRAILER	:
			case(pipe_cnt)
				//trailer��ͷҪ��д��һЩ����
				0		: data_reg	<= {32'h0,32'h0};
				//{{trailer_size,reserved},magic_key}=={{trailer_size,0},TV3U} //����ʹ��λ����һ��ƴ�ӣ���i_chunk_mode_activeʹ�ܣ�����Ϊ36������Ϊ32
				1		: data_reg	<= {{13'h4,i_chunk_mode_active,2'b00,16'd0},32'h54563355};
				//blockid
				2		: data_reg	<= blockid[63:0];
				//{valid_payload_size[31:0],{reserved,status}} status-����ֻ֧��Image��0x0001����Image Extended Chunk��0x4001��
				3		: data_reg	<= {valid_payload_size[31:0],{16'h00,status}}	;
				//{size_y,valid_payload_size[63:32]}
				4		: data_reg	<= {{16'h00,iv_trailer_size_y},32'h0};
				//{dummy_word_by_dh,chunk_layout_id} chunk_layout_idΪ0 dummy_word_by_dh��dh�Լ����ӵ����ݣ�Ϊ�����8byte�Ŀռ�
				5		: data_reg	<= {32'h0,{24'h0,chunk_layout_id}};
				//trailer��βҪ��д��һЩ����
				6		: data_reg	<= {32'h0,32'h0};
				default	: data_reg	<= {32'h0,32'h0};
				//				default	: data_reg	<= iv_data;
			endcase

			S_CHUNK		:
			case(pipe_cnt)
				//image id length
				TIMESTAMP_DELAY		: data_reg	<= {iv_chunk_size_img,32'h1};
				//frameid
				TIMESTAMP_DELAY+1	: data_reg	<= blockid[63:0];
				//frameid id length
				TIMESTAMP_DELAY+2	: data_reg	<= {FID_LENTH,32'h2};
				//timestamp
				TIMESTAMP_DELAY+3	: data_reg	<= iv_timestamp[63:0];
				//timestamp id length
				TIMESTAMP_DELAY+4	: data_reg	<= {TS_LENTH,32'h3};
				default	: data_reg	<= {32'h0,32'h0};
				//				default	: data_reg	<= iv_data;
			endcase

			default	:
			data_reg	<= iv_data;
		endcase
	end
	assign	ov_data	= data_reg	;

	//	-------------------------------------------------------------------------------------
	//	������Ч�ź�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(current_state)
			//	-------------------------------------------------------------------------------------
			//	����״̬ ʱ���״̬ չ��״̬ ���ݶ���Ч
			//	-------------------------------------------------------------------------------------
			S_IDLE,S_TIMESTAMP,S_EXT	:
			data_valid	<= 1'b0;
			//	-------------------------------------------------------------------------------------
			//	leader trailer ״̬ ����һֱ��Ч
			//	-------------------------------------------------------------------------------------
			S_LEADER,S_TRAILER	:
			data_valid	<= 1'b1;
			//	-------------------------------------------------------------------------------------
			//	chunk ״̬ ������ʹ���źţ�ѡ����ʵ���Ч����
			//	-------------------------------------------------------------------------------------
			S_CHUNK	:
			case(pipe_cnt)
				//image id length
				TIMESTAMP_DELAY		: data_valid	<= i_chunk_mode_active;
				//frameid
				TIMESTAMP_DELAY+1	: data_valid	<= i_chunk_mode_active&i_chunkid_en_fid;
				//frameid id length
				TIMESTAMP_DELAY+2	: data_valid	<= i_chunk_mode_active&i_chunkid_en_fid;
				//timestamp
				TIMESTAMP_DELAY+3	: data_valid	<= i_chunk_mode_active&i_chunkid_en_ts;
				//timestamp id length
				TIMESTAMP_DELAY+4	: data_valid	<= i_chunk_mode_active&i_chunkid_en_ts;
				default	: data_valid	<= 1'b0;
			endcase

			//	-------------------------------------------------------------------------------------
			//	ͼ����ʱ�����������ʹ���źţ��ж������Ч
			//	-------------------------------------------------------------------------------------
			S_IMAGE	:
			data_valid	<= i_data_valid;
			//	-------------------------------------------------------------------------------------
			//	����״̬����Ч
			//	-------------------------------------------------------------------------------------
			default	:
			data_valid	<= 1'b0;
		endcase
	end
	assign	o_data_valid	= data_valid;


	//	-------------------------------------------------------------------------------------
	//	��� fval
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			fval_reg	<= 1'b0;
		end
		else if(current_state==S_TIMESTAMP) begin
			fval_reg	<= 1'b1;
		end
	end
	assign	o_fval	= fval_reg;

	//	-------------------------------------------------------------------------------------
	//	��� trailer flag
	//	-- trailer_flag �� data_valid ��ǰ����һ��
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_TRAILER && pipe_cnt<=(TRAILER_SIZE_CHUNK-2)) begin
			trailer_flag	<= 1'b1;
		end
		else begin
			trailer_flag	<= 1'b0;
		end
	end
	assign	o_trailer_flag	= trailer_flag;

	//	===============================================================================================
	//	ref ***FSM***
	//	===============================================================================================
	//FSM Sequential Logic
	always @ (posedge clk) begin
		current_state	<= next_state;
	end

	//FSM Conbinatial Logic
	always @ ( * ) begin
		case(current_state)
			//	-------------------------------------------------------------------------------------
			//	����״̬
			//	-------------------------------------------------------------------------------------
			S_IDLE	:
			if(fval_rise) begin
				next_state	= S_TIMESTAMP;
			end
			else begin
				next_state	= S_IDLE;
			end
			//	-------------------------------------------------------------------------------------
			//	�ȴ�ʱ���״̬
			//	--fval������֮��110ns��ʱ��������ȶ�
			//	-------------------------------------------------------------------------------------
			S_TIMESTAMP	:
			if(pipe_cnt==(TIMESTAMP_DELAY-1)) begin
				next_state	= S_LEADER;
			end
			else begin
				next_state	= S_TIMESTAMP;
			end
			//	-------------------------------------------------------------------------------------
			//	leader״̬
			//	--�����״̬����leader����
			//	-------------------------------------------------------------------------------------
			S_LEADER	:
			if(pipe_cnt==(LEADER_SIZE-1)) begin
				next_state	= S_IMAGE;
			end
			else begin
				next_state	= S_LEADER;
			end
			//	-------------------------------------------------------------------------------------
			//	image״̬
			//	--�����״̬����ͼ������
			//	-------------------------------------------------------------------------------------
			S_IMAGE	:
			if(fval_fall) begin
				next_state	= S_CHUNK;
			end
			else begin
				next_state	= S_IMAGE;
			end
			//	-------------------------------------------------------------------------------------
			//	chunk״̬
			//	--�����״̬���� chunk ����
			//	-------------------------------------------------------------------------------------
			S_CHUNK	:
			if(pipe_cnt==(CHUNK_SIZE-1)) begin
				next_state	= S_TRAILER;
			end
			else begin
				next_state	= S_CHUNK;
			end
			//	-------------------------------------------------------------------------------------
			//	trailer״̬
			//	--�����״̬����trailer���ݣ�������chunk�Ƿ�ʹ��
			//	-------------------------------------------------------------------------------------
			S_TRAILER	:
			if(pipe_cnt==(TRAILER_SIZE_CHUNK-1)) begin
				next_state	= S_EXT;
			end
			else begin
				next_state	= S_TRAILER;
			end
			//	-------------------------------------------------------------------------------------
			//	ext״̬
			//	--����չ��fval��ʹ��fval��lval�½���֮�䱣��һ�ξ���
			//	-------------------------------------------------------------------------------------
			S_EXT	:
			if(ext_cnt==(EXT_SIZE-1)) begin
				next_state	= S_IDLE;
			end
			else begin
				next_state	= S_EXT;
			end

			default	:
			next_state	= S_IDLE;
		endcase
	end


endmodule