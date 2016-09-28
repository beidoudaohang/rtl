//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : u3v_format_control
//  -- �����       : ��ǿ
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- ��ǿ         :| 2014/12/3 10:37:03	:|  ���ݼ���Ԥ������
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������
//              1)  : U3V��ʽ����ģ�飬�������ɸ��׶α�־������leader��payload��trailer˳��ƴ�Ӻ�ʱ���νӡ�
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module u3v_format_control #	(
	parameter							DATA_WD			=32		,		//�����������λ������ʹ��ͬһ���
	parameter							SHORT_REG_WD 	=16		,		//�̼Ĵ���λ��
	parameter							REG_WD 			=32		,		//�Ĵ���λ��
	parameter							LONG_REG_WD 	=64				//���Ĵ���λ��
)
(
//  ===============================================================================================
//  ��һ���֣�ʱ�Ӹ�λ
//  ===============================================================================================
	input								reset					,		//��λ�źţ��ߵ�ƽ��Ч������ʱ��ʱ����
	input								clk						,		//ʱ���źţ�����ʱ��ʱ����ͬ�ڲ�����ʱ��
//  ===============================================================================================
//  �ڶ����֣��С��������ݡ�������Ч
//  ===============================================================================================
	input								i_fval					,       //����ͨ·����ĳ��źţ�����ʱ��ʱ����,fval���ź��Ǿ�������ͨ���ӿ���ĳ��źţ���ͷ�������leader����������Ч��ͼ�����ݣ�ͣ���ڼ䱣�ֵ͵�ƽ
	input								i_leader_valid			,		//�����ͷ��������Ч�ź�
	input		[DATA_WD-1			:0]	iv_leader_data          ,		//ͷ������
	input								i_payload_valid			,		//�����ͷ��������Ч�ź�
	input		[DATA_WD-1			:0]	iv_payload_data         ,		//ͷ������
	input								i_trailer_valid			,		//�����ͷ��������Ч�ź�
	input		[DATA_WD-1			:0]	iv_trailer_data         ,		//ͷ������
	input								i_chunk_mode_active		,		//chunk����

//  ===============================================================================================
//  �������֣����ƼĴ����������־
//  ===============================================================================================

	input								i_stream_enable			,		//��ʹ���źţ�����ʱ��ʱ����=0��chunk�е�BLOCK IDΪ0
	output	reg							o_leader_flag			,       //ͷ����־
	output	reg							o_image_flag			,       //���ذ��е�ͼ����Ϣ��־
	output	reg							o_chunk_flag			,		//���chunk��Ϣ��־
	output	reg							o_trailer_flag          ,		//β����־
	output	reg	[LONG_REG_WD-1		:0]	ov_blockid				,		//ͷ����chunk��β����blockid��Ϣ����һ֡��block ID��0��ʼ��������һ֡block IDΪ0
	output	reg							o_fval					,       //�����ͷβ��֡��Ϣ�ĳ��ź�
	output	reg							o_data_valid			,       //�����ͷβ��������Ч�ź�
	output	reg	[DATA_WD-1			:0]	ov_data                         //����U3VЭ������ݰ�
	);

//  ===============================================================================================
//  ���ز������壺ͨ����������ȷ����־�����λ�ã�ע���������ʹ�����ֵ31
//  fval�����ص�leaderǰ��Ԥ��10�����
//  leader_flag���13
//  chunk_flag���10
//  trailer_flag���9
//	trailer_flag��fval�½���10
//  ===============================================================================================
	localparam							LEADER_FLAG_RISING 	=6'd10		;		//leaer_flag������λ��		leaderǰԤ��13�����
	localparam							LEADER_FLAG_FALING 	=6'd23		;		//leaer_flag�½���λ��  	leader���13
	localparam							CHUNK_FLAG_RISING 	=6'd1		;		//chunk_flag������λ��
	localparam							CHUNK_FLAG_FALING 	=6'd11		;		//chunk_flag�½���λ��		chunk���10
	localparam							TRAILER_FLAG_RISING =6'd20		;		//trailer_flag������λ��
	localparam							TRAILER_FLAG_FALING =6'd31		;		//trailer_flag�½���λ��	trailer���9+2 ����frame_bufferģ�����trailer
	localparam							FVAL_FALING 		=6'd40		;		//o_fval�½���λ��			fval�½���Ԥ��9�����
//  ===============================================================================================
//  �Ĵ�������
//  ===============================================================================================
	reg		[4						:0]	leader_count					;		//�������ͷ�ļ�����
	reg		[5						:0]	trailer_count					;		//�������β�ļ�����
	reg		[2						:0]	fval_shift			=3'b000		;		//fval��λ�Ĵ���
	reg									w_trailer_flag					;		//β����־��ʱһ��
//  ===============================================================================================
//  ȡ���ź�i_fval�ı���
//  ===============================================================================================
	always @ (posedge clk ) begin
		fval_shift	<=	{fval_shift[1:0],i_fval};
	end
//  ===============================================================================================
//  ʹ�ñ�����������
//  ===============================================================================================
	always @ ( posedge clk) begin
		if ( fval_shift[2:1] == 2'b01 ) begin				//�����ؼ�������λ
			leader_count	<=	 5'h00;
		end
		else if ( leader_count >= 5'h1f ) begin
			leader_count	<=	 5'h1f;
		end
		else begin
			leader_count	<=	leader_count + 5'h01;
		end
	end


	always @ ( posedge clk) begin
		if ( fval_shift[2:1] == 2'b10 ) begin				//�½��ؼ�������λ
			trailer_count	<=	 6'h00;
		end
		else if ( trailer_count >= 6'h3f ) begin
			trailer_count	<=	 6'h3f;
		end
		else begin
			trailer_count	<=	trailer_count + 6'h01;
		end
	end
//  ===============================================================================================
//  ���ɱ�־
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//  leader_count��LEADER_FLAG_RISING ��LEADER_FLAG_FALING ��Χ�������־
//  -------------------------------------------------------------------------------------

	always @ ( posedge clk) begin
		if ( reset ) begin
			o_leader_flag	<=	1'b0	;
		end
		else if ( (leader_count >= LEADER_FLAG_RISING-1)  && (leader_count < LEADER_FLAG_FALING-1) ) begin
			o_leader_flag	<=	 1'b1;
		end
		else begin
			o_leader_flag	<=	 1'b0;
		end
	end
//  -------------------------------------------------------------------------------------
//  o_chunk_flag��CHUNK_FLAG_RISING ��CHUNK_FLAG_FALING ��Χ����o_chunk_mode_active�򿪣������־
//  -------------------------------------------------------------------------------------
	always @ ( posedge clk) begin
		if ( reset ) begin
			o_chunk_flag	<=	1'b0	;
		end
		else if ( (trailer_count >= CHUNK_FLAG_RISING)  && (trailer_count < CHUNK_FLAG_FALING) && i_chunk_mode_active ) begin
			o_chunk_flag	<=	 1'b1;
		end
		else begin
			o_chunk_flag	<=	 1'b0;
		end
	end
//  -------------------------------------------------------------------------------------
//
//  -------------------------------------------------------------------------------------
//  -------------------------------------------------------------------------------------
//  o_trailer_flag��TRAILER_FLAG_RISING ��TRAILER_FLAG_FALING ��Χ����o_chunk_mode_active�򿪣������־
//  -------------------------------------------------------------------------------------

	always @ ( posedge clk) begin
		if ( reset ) begin
			o_trailer_flag	<=	1'b0	;
		end
		else if ( (trailer_count >= TRAILER_FLAG_RISING)  && (trailer_count <= TRAILER_FLAG_FALING) ) begin
			o_trailer_flag	<=	 1'b1;
		end
		else begin
			o_trailer_flag	<=	 1'b0;
		end
	end
//  -------------------------------------------------------------------------------------
//  o_image_flag,leader_flag֮�����o_image_flag������ЧΪ��ʱ���0
//  -------------------------------------------------------------------------------------

	always @ ( posedge clk) begin
		if ( reset ) begin
			o_image_flag	<=	1'b0	;
		end
		else if (leader_count == LEADER_FLAG_FALING-1) begin
			o_image_flag	<=	 1'b1;
		end
		else if ( !i_fval ) begin
			o_image_flag	<=	 1'b0;
		end
	end
//  -------------------------------------------------------------------------------------
//  o_fval ����Ч��Ϊ�������ǵ�FVAL_FALING
//  -------------------------------------------------------------------------------------

	always @ ( posedge clk) begin
		if ( reset ) begin
			o_fval	<=	1'b0	;
		end
		else if (i_fval) begin
			o_fval	<=	1'b1	;
		end
		else if ( trailer_count == FVAL_FALING ) begin
			o_fval	<=	 1'b0;
		end
	end

//  ===============================================================================================
//  block_id
//  ===============================================================================================
	always @ (posedge clk) begin
		if ( reset ) begin
			ov_blockid	<=	64'hffff_ffff_ffff_ffff;
		end
		else if ( !i_stream_enable) begin		// ����ģ�鱣֤ i_stream_enable ����clkʱ����
			ov_blockid	<=	64'hffff_ffff_ffff_ffff;
		end
		else if ( fval_shift[2:1] == 2'b01 ) begin
			ov_blockid	<=	ov_blockid + 64'h1;
		end
	end

//  ===============================================================================================
//  ��i_trailer_valid����Ϊo_trailer_flag��ʱһ�ģ�Ϊ��frame_bufferģ��ʶ��β��
//	w_trailer_flag  _________|��������������������������������������������������������������������|_____________
//	β��������Ч     _________|��������������������������������������������������������������������|_____________
//	β������	     ____________X=============================X_______________
//
//	��Ч��־ǰ�����һ��������
//  ===============================================================================================

	always @ ( posedge clk ) begin
		w_trailer_flag	<=	o_trailer_flag ;
	end

	always @ ( posedge clk ) begin
		if (  reset )begin
			o_data_valid	<=	1'b0	;
		end
		else begin
			o_data_valid	<=	i_leader_valid | i_payload_valid | w_trailer_flag ;	// ��i_trailer_valid����Ϊo_trailer_flag��Ϊ��frame_bufferģ��ʶ��β��
		end
	end

	always @ (posedge clk) begin
		if (  reset )begin
			ov_data	<=	{DATA_WD{1'b0}}	;
		end
		else if ( i_leader_valid ) begin
			ov_data	<=	iv_leader_data	;
		end
		else if ( i_payload_valid ) begin
			ov_data	<=	iv_payload_data	;
		end
		else if ( i_trailer_valid ) begin
			ov_data	<=	iv_trailer_data	;
		end
		else begin
			ov_data	<=	{DATA_WD{1'b0}}	;
		end
	end
endmodule