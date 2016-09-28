//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : payload
//  -- �����       : ��ǿ
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- ��ǿ         :| 2014/11/28 9:56:10	:|  ���ݼ���Ԥ������
//	-- ��ǿ         :| 2015/7/09 15:40:02   :|  ����u3v1.01Э�����OVERRUN���֣��Է��͵����ݽ���ͳ��
//	-- ��ǿ         :| 2015/7/19 15:44:23   :|  chunk�ɴ�0��ʼ�޸�Ϊ��1��ʼ
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������
//              1)  : U3V��ʽpayloadģ�飬��ϳɷ���U3V��ʽpayload��,����chunk��Ϣ
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module payload # (
	parameter			DATA_WD					= 32	,	//�����������λ������ʹ��ͬһ���
	parameter			SHORT_REG_WD 			= 16	,	//�̼Ĵ���λ��
	parameter			REG_WD 					= 32	,	//�Ĵ���λ��
	parameter			LONG_REG_WD 			= 64		//���Ĵ���λ��
	)
	(
//  ===============================================================================================
//  ��һ���֣�ʱ�Ӹ�λ
//  ===============================================================================================
	input							reset				,	//��λ�źţ��ߵ�ƽ��Ч������ʱ��ʱ����
	input							clk					,	//ʱ���źţ�����ʱ��ʱ����ͬ�ڲ�����ʱ��
//  ===============================================================================================
//  �ڶ����֣��С��������ݡ�������Ч
//  ===============================================================================================

	input							i_image_flag		,	//���ذ��е�ͼ����Ϣ��־
	input							i_chunk_flag		,	//���chunk��Ϣ��־
	input							i_data_valid		,	//����ͨ·�����������Ч�źţ���־32λ����Ϊ��Ч����
	input		[DATA_WD-1:0]		iv_data				,	//����ͨ·ƴ�Ӻõ�32bit���ݣ���������Ч���룬������ʱ�Ӷ���
//  ===============================================================================================
//  �������֣����ƼĴ�����chunk��Ϣ��ֻ���Ĵ���
//  ===============================================================================================
	input							i_chunk_mode_active	,	//chunk�ܿ��أ����ش�Payload Typeʹ��Ϊimage extend chunk ���ͣ�chunk�ر�Ϊimage����
	input							i_chunkid_en_ts		,	//ʱ���chunkʹ��
	input							i_chunkid_en_fid	,	//frame id chunkʹ��
	input		[REG_WD-1:0]		iv_chunk_size_img	,	//ͼ�񳤶ȣ����ֽ�Ϊ��λ����pixel formatΪ8bitʱ��һ������ռһ���ֽڣ���pixel format 10 bitʱ��һ������ռ�������ֽڡ�
	input		[REG_WD-1:0]		iv_pixel_format		,	//ͼ�����ظ�ʽ��Ӱ��ͼ���С
	input		[LONG_REG_WD-1	:0]	iv_timestamp		, 	//ͷ���е�ʱ����ֶ�
	input		[LONG_REG_WD-1	:0]	iv_blockid			,	//ͷ����chunk��β����blockid��Ϣ����һ֡��block ID��0��ʼ��������һ֡block IDΪ0
	input							i_stream_enable		,	//��ʹ���źţ�����ʱ��ʱ����=0�����������ֹͣ��chunk�е�BLOCK IDΪ0
//  ===============================================================================================
//  ���Ĳ��֣��С�������Ч������
//  ===============================================================================================
	output  reg [REG_WD-1       :0]	ov_valid_payload_size	,	//��Ч��ͼ������
	output	reg	[15				:0] ov_status			,	//��ӵ�β����״̬�Ĵ���
	output	reg						o_data_valid		,	//�����payload��chunk��������Ч�ź�
	output	reg	[DATA_WD-1:0]		ov_data					//payload��chunk����
	);
//  ===============================================================================================
//  ���ز���
//  ===============================================================================================
	localparam						CHUNK_LENTH		=	4'd10	;	//chunk����10
	localparam						FID_LENTH		=	32'H8	;	//frameid ����
	localparam						TS_LENTH		=	32'H8	;	//timestamp ����
//  ===============================================================================================
//  �����ͼĴ�������
//  ===============================================================================================
	reg			[3				:0]	count           = 	4'h0	;	//���������������CHUNK������
	reg								chunk_valid		=	1'b0	;	//chunk������Ч��־
	reg			[DATA_WD-1		:0]	chunk_data					;	//chun����
	reg 		[REG_WD-1       :0]	payload_cnt					;	//����ͼ���С������
	reg 		[1				:0]	image_flag_shift	=2'b00	;
	reg 							format8_sel					;	//����ռ��1���ֽڻ��������ֽ�
	reg 		[REG_WD-1       :0]	act_payload_cnt				;	//����ͼ���С������
	reg 		[REG_WD-1       :0]	wv_valid_payload_size_m		;	//��Ч��ͼ������
	reg			[1				:0]	stream_enable_shift	=2'b00	;	//��ʹ����λ�Ĵ���
	reg								chunk_mode_active_m	=1'b0	;	//
	reg								chunkid_en_ts_m		=1'b0	;	//
	reg								chunkid_en_fid_m	=1'b0	;	//
//  ===============================================================================================
//  ��Чʱ�������ڼ���
//  ===============================================================================================

	always @ (posedge clk) begin
		stream_enable_shift	<=	{stream_enable_shift[0],i_stream_enable};
	end

	always @ (posedge clk) begin
		if( stream_enable_shift == 2'b01  )
			begin
				chunk_mode_active_m	<=	i_chunk_mode_active	;
				chunkid_en_ts_m		<=	i_chunkid_en_ts		;
				chunkid_en_fid_m	<=  i_chunkid_en_fid	;
			end
	end

//  ===============================================================================================
//  i_chunk_flag�ڼ���
//  ===============================================================================================
	always @ (posedge clk) begin
		if(i_chunk_flag) begin
			count	<=	count + 4'h1;
		end
		else begin
			count	<=	4'h0;
		end
	end
//  ===============================================================================================
//  ����chunk�ź�
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//  ����chunk����
//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if ( reset )
			chunk_data	<= 	32'h0;
		else  begin
				case ( count )
					4'h1	:	chunk_data	<=	32'h1						;
					4'h2	:   chunk_data	<=	iv_chunk_size_img			;
					4'h3	:   chunk_data	<=	iv_blockid[31:0]			;
					4'h4	:   chunk_data	<=	iv_blockid[63:32]			;
					4'h5	:   chunk_data	<=	32'h2						;
					4'h6	:   chunk_data	<=	FID_LENTH					;
					4'h7	:   chunk_data	<=	iv_timestamp[31:0]			;
					4'h8	:   chunk_data	<=	iv_timestamp[63:32]			;
					4'h9	:   chunk_data	<=	32'h3						;
					4'ha	:   chunk_data	<=	TS_LENTH					;
					default	:  	chunk_data	<= 	32'h0						;
				endcase
			end
	end
//  -------------------------------------------------------------------------------------
//  ����chunk��Ч��־
//  ͨ���ж�ʹ��λ������Ч��־������������ʹ�ܣ��������Ч������Ҳ�Ͳ������
//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if ( reset )
			chunk_valid <= 	1'b0;
		else  begin
			case ( count )
				4'h1	:	chunk_valid	<=	chunk_mode_active_m						;
				4'h2	:   chunk_valid	<=	chunk_mode_active_m						;
				4'h3	:   chunk_valid	<=	chunk_mode_active_m	&chunkid_en_fid_m	;
				4'h4	:   chunk_valid	<=	chunk_mode_active_m	&chunkid_en_fid_m	;
				4'h5	:   chunk_valid	<=	chunk_mode_active_m	&chunkid_en_fid_m	;
				4'h6	:   chunk_valid	<=	chunk_mode_active_m	&chunkid_en_fid_m	;
				4'h7	:   chunk_valid	<=	chunk_mode_active_m	&chunkid_en_ts_m	;
				4'h8	:   chunk_valid	<=	chunk_mode_active_m	&chunkid_en_ts_m	;
				4'h9	:   chunk_valid	<=	chunk_mode_active_m	&chunkid_en_ts_m	;
				4'ha	:   chunk_valid	<=	chunk_mode_active_m	&chunkid_en_ts_m	;
				default	:  	chunk_valid <= 	1'b0									;
			endcase
		end
	end
//  ===============================================================================================
//  �������
//  ===============================================================================================
	always @ (posedge clk ) begin
		if ( reset )begin
			o_data_valid	<=	1'b0	;
			ov_data			<=	32'h0	;
		end
		else if ( i_image_flag && i_data_valid ) begin
			o_data_valid	<=	1'b1	;
			ov_data			<=	iv_data	;
		end
		else if ( chunk_valid ) begin
			o_data_valid	<=	1'b1	;
			ov_data			<=	chunk_data	;
		end
		else begin
			o_data_valid	<=	1'b0	;
			ov_data			<=	32'h0	;
		end
	end

//  ===============================================================================================
//  ���ݼ����������ͼ�������ڼ��ʵ�ʸ����������õ�iv_chunk_size_img�Ƚ��ж��Ƿ�overrun
//  ===============================================================================================
	always @ (posedge clk ) begin
		image_flag_shift	<= { image_flag_shift[0],i_image_flag };
	end
//	ͳ��image_flag�ڼ��������Ч����
	always @ (posedge clk ) begin
		if ( reset )begin
			payload_cnt			<=	32'h0	;
		end
		else if (image_flag_shift == 2'b01 )begin
			payload_cnt			<=	32'h0	;
		end
		else if ( i_image_flag &i_data_valid )begin
			payload_cnt		<=	payload_cnt + 32'h1	;
		end
	end

//����ʵ���ֽ���
	always @ (posedge clk ) begin
		if ( image_flag_shift == 2'b10 )
			act_payload_cnt	<= payload_cnt<<2;
	end

//��ʵ���ֽ�������iv_chunk_size_imgʱ˵�������������Ҫ�ô���״̬λ
	always @ (posedge clk ) begin
		if( act_payload_cnt > iv_chunk_size_img ) begin
			ov_status	<= 16'hA101;
		end
		else begin
			ov_status	<= 16'H0000;
		end
	end

//ȡʵ���ֽ�����iv_chunk_size_img����ֵ�е���Сֵ��Ϊvalid payloadsize
	always @ (posedge clk ) begin
		if( act_payload_cnt > iv_chunk_size_img ) begin
			wv_valid_payload_size_m	<= iv_chunk_size_img;
		end
		else begin
			wv_valid_payload_size_m	<= act_payload_cnt;
		end
	end

	always @ (posedge clk ) begin
		case({ i_chunk_mode_active,i_chunkid_en_ts,i_chunkid_en_fid })
			3'b100:	ov_valid_payload_size	<= wv_valid_payload_size_m + 8;
			3'b110:	ov_valid_payload_size	<= wv_valid_payload_size_m + 24;
			3'b101:	ov_valid_payload_size	<= wv_valid_payload_size_m + 24;
			3'b111:	ov_valid_payload_size	<= wv_valid_payload_size_m + 40;
			default:ov_valid_payload_size	<= wv_valid_payload_size_m;
		endcase
		end
endmodule