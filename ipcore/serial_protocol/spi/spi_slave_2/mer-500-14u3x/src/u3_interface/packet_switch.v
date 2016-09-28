//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : packet_switch
//  -- �����       : ��ǿ
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- ��ǿ         :| 2014/12/1 10:31:08	:|  ���ݼ���Ԥ������
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������
//              1)  : ʵ��֡��ģ����FIFO��ȡ�������U3_interface
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module packet_switch #(
	parameter			REG_WD 									=	32	//�Ĵ���λ��
)
(
//  ===============================================================================================
//  ��һ���֣�ʱ�Ӹ�λ
//  ===============================================================================================
	input								clk						,		//ʱ���źţ�clk_gpifʱ����
	input								reset					,		//��λ�źţ��ߵ�ƽ��Ч��clk_gpifʱ����

//  ===============================================================================================
//  �ڶ����֣����üĴ���
//  ===============================================================================================

	input								i_chunkmodeactive		,		//chunk�ܿ��أ�clk_gpifʱ����,δ������Чʱ�����ƣ�0)leader��52  trailer��32     1)leader��52  trailer��36
	input								i_framebuffer_empty		,		//framebuffer���FIFO�ձ�־���ߵ�ƽ��Ч��clk_gpifʱ����,
	input		[REG_WD-1			:0] iv_payload_size			,		//payload_size��С�Ĵ�����clk_gpifʱ����,δ������Чʱ������

//  ===============================================================================================
//  �������֣���־�ź�
//  ===============================================================================================
	input								i_change_flag			,		//leader��payload��trailer���л���־��ÿ����������ɺ��л�
	output	reg							o_leader_flag			,		//ͷ����־
	output	reg							o_trailer_flag			,		//β����־
	output	reg							o_payload_flag			,		//���ذ���־
	output	reg	[REG_WD-1			:0] ov_packet_size					//��ǰ������Ӧ�İ���С
);
//  ===============================================================================================
//  �ڲ������궨��
//  ===============================================================================================
	localparam 			IMAGE_LEADER_LENGTH 					=	13		;	//IMAGE��ʽ��LEADER��С
	localparam			IMAGE_TRAILER_LENGTH 					=	8		;	//IMAGE��ʽ��TRAILER��С
    localparam     		IMAGE_EXTEND_CHUNK_LEADER_LENGTH  		=	13		;	//IMAGE_EXTEND_CHUNK��ʽ��LEADER��С
    localparam     		IMAGE_EXTEND_CHUNK_TRAILER_LENGTH 		=	9		;	//IMAGE_EXTEND_CHUNK��ʽ��TRAILER��С

 	localparam 			IDLE 									=	3'B000	;
 	localparam 			LEADER 									=	3'B001	;
 	localparam 			PAYLOAD									=	3'B010	;
 	localparam 			TRAILER									=	3'B100	;
//  ===============================================================================================
//  �Ĵ�������
//  ===============================================================================================
	reg			[2					:0] current_state		;
	reg			[2					:0] next_state			;
	reg     							w_chunkmodeactive	;
	reg			[REG_WD-1			:0] payload_size_reg	;
//  ===============================================================================================
//  ��Чʱ������,ͣ��ʱ��Ч
//  ===============================================================================================
	always @ ( posedge	clk )
	begin
		if ( reset )
			begin
				w_chunkmodeactive 	<= i_chunkmodeactive;
				payload_size_reg	<= iv_payload_size;
			end
	end
//  ===============================================================================================
//  ״̬��
//	��Ϊ�ĸ�״̬������״̬��ͷ��״̬�����ذ�״̬��β��״̬��ÿ��״̬�����Ӧ�ı�־�Ͱ���С�Ĵ�
//  ��
//	��λ�ص�IDLE״̬
//	i_framebuffer_empty,fifo�ǿ�����IDLE״̬
//	i_change_flag����־�����л�״̬
//  ===============================================================================================
	always @ (posedge clk ) begin
		if(reset)
	   		current_state <= IDLE;
		else
	   		current_state <= next_state;
		end

	always @ * begin
	    next_state = IDLE;
	    case( current_state )
		IDLE:
			begin
				if ( !i_framebuffer_empty )		//��Ϊ��ȫ��ǰ�˸��룬ֻ��ѡ���FIFO�ǿ���Ϊ��������
					next_state = LEADER;
				else
					next_state = IDLE;
			end
		LEADER:									//i_change_flag�����л���־
			begin
				if ( i_change_flag )
					next_state = PAYLOAD;
				else
					next_state = LEADER;
			end
		PAYLOAD:								//i_change_flag�����л���־
			begin
				if ( i_change_flag )
					next_state = TRAILER;
				else
					next_state = PAYLOAD;
			end
		TRAILER:								//i_change_flag�����л���־
			begin
				if ( i_change_flag )
					next_state = IDLE;
				else
					next_state = TRAILER;
			end
	    endcase
	end

	always @ (posedge clk ) begin
		if( reset ) begin						//����źŸ���ֵ
			o_leader_flag	<=	1'b0;
			o_trailer_flag	<=	1'b0;
			o_payload_flag	<=	1'b0;
			ov_packet_size	<=	32'h0;
		end
		else begin
			o_leader_flag	<=	1'b0;
			o_trailer_flag	<=	1'b0;
			o_payload_flag	<=	1'b0;
			ov_packet_size	<=	32'h0;
			case( next_state )
				LEADER:
					begin
					o_leader_flag	<=	1'b1;
					ov_packet_size	<=	32'h34;				//52
					end
				PAYLOAD:
					begin
					o_payload_flag	<=	1'b1;
					ov_packet_size	<=	payload_size_reg;
					end
				TRAILER:
					begin
					o_trailer_flag	<=	1'b1;
					if ( w_chunkmodeactive )
						ov_packet_size	<=	32'h24;			//chunk��ʱtrailer����36
					else
						ov_packet_size	<=	32'h20;			//chunk�ر�ʱtrailer����32
					end
				default	:;
			endcase
		end
	end
endmodule