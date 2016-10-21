//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : packet_switch
//  -- �����       : ��ǿ���ܽ�
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- ��ǿ         :| 2014/12/1 10:31:08	:|  ���ݼ���Ԥ������
//  -- ��ǿ         :| 2015/10/25 11:35:35	:|  ֡��port��λ���Ϊ64bits���޸�leader����trailer
//												����Ӧ�ĳ��ȣ�����8�ֽ���ȡ����
//  -- �ܽ�       :| 2016/9/22 14:29:57	:|  �޸�Ϊ֧��multi-roi�İ汾
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
	parameter										REG_WD 				=	32,	//�Ĵ���λ��
	parameter										MROI_MAX_NUM 		= 	8	//Multi-ROI��������
	)
	(
	//  ===============================================================================================
	//  ��һ���֣�ʱ�Ӹ�λ
	//  ===============================================================================================
	input											clk						,	//ʱ���źţ�clk_gpifʱ����
	input											reset					,	//��λ�źţ��ߵ�ƽ��Ч��clk_gpifʱ����
	//  ===============================================================================================
	//  �ڶ����֣����üĴ���
	//  ===============================================================================================
	input											i_chunkmodeactive		,	//chunk�ܿ��أ�clk_gpifʱ����,δ������Чʱ�����ƣ�0)leader��52  trailer��32     1)leader��52  trailer��36
	input											i_framebuffer_empty		,	//framebuffer���FIFO�ձ�־���ߵ�ƽ��Ч��clk_gpifʱ����,
	//  ===============================================================================================
	//  �������֣�multi-roi
	//  ===============================================================================================
	input											i_multi_roi_total_en	,	//multi-roi�ܿ��أ�1-multi-roiģʽ��0-single-roiģʽ
	input		[7							:0]		iv_roi_num				,	//u3_transferģ���leader��ȡ��roi��num��	
	input		[REG_WD*MROI_MAX_NUM-1	:0]			iv_payload_size_mroi	,	//multi-roiģʽ��roi1-roi7��payload_size�ļ���
	//  ===============================================================================================
	//  ���Ĳ��֣���־�ź�
	//  ===============================================================================================
	input											i_change_flag			,	//leader��payload��trailer���л���־��ÿ����������ɺ��л�	                                    		
	output	reg										o_leader_flag			,	//ͷ����־
	output	reg										o_trailer_flag			,	//β����־
	output	reg										o_payload_flag			,	//���ذ���־
	output	reg	[REG_WD-1					:0] 	ov_packet_size				//��ǰ������Ӧ�İ���С
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
	reg			[2							:0] current_state			;
	reg			[2							:0] next_state				;
	reg											multi_roi_total_en_reg	;
	reg											chunkmodeactive			;
	reg			[REG_WD-1					:0] payload_size_temp		;
	reg			[REG_WD-1					:0] payload_size_mroi_reg	[MROI_MAX_NUM-1:0];
	//  ===============================================================================================
	//  ��Чʱ������,ͣ��ʱ��Ч
	//  ===============================================================================================
	always @ (posedge clk)begin
		if(reset)begin
			chunkmodeactive 		<=	i_chunkmodeactive	;
			multi_roi_total_en_reg	<=	i_multi_roi_total_en;
		end
	end
	
	genvar i;
	generate
		for(i=0;i<MROI_MAX_NUM;i=i+1) begin:U
			always @ (posedge clk)begin
				if(reset)
					payload_size_mroi_reg[i]	<=	iv_payload_size_mroi[REG_WD*(i+1)-1:REG_WD*i];
			end
		end
	endgenerate
		
	//  ===============================================================================================
	//  ѡ�����payload_size
	//	1��single-roiʱ��ֱ��ʹ��iv_payload_size
	//	2��multi-roiʱ������iv_roi_numѡ�����
	//	roi0��Ӧiv_payload_size
	//	roi(n)��Ӧpayload_size_mroi_reg[n*REG_WD-1:(n-1)*REG_WD]
	//  ===============================================================================================
	always @ (posedge clk)begin
		if(~multi_roi_total_en_reg)begin
			payload_size_temp	<=	payload_size_mroi_reg[0];
		end
		else begin
			case(iv_roi_num)
				0	: begin
					payload_size_temp	<=	payload_size_mroi_reg[0];
				end
				1	: begin
					payload_size_temp	<=	payload_size_mroi_reg[1];
				end
				2	: begin
					payload_size_temp	<=	payload_size_mroi_reg[2];
				end                                                       
				3	: begin                                               
					payload_size_temp	<=	payload_size_mroi_reg[3];
				end                                                
				4	: begin                                        
					payload_size_temp	<=	payload_size_mroi_reg[4];
				end                                                
				5	: begin                                        
					payload_size_temp	<=	payload_size_mroi_reg[5];
				end                                                
				6	: begin                                        
					payload_size_temp	<=	payload_size_mroi_reg[6];
				end                                                       
				7	: begin                                               
					payload_size_temp	<=	payload_size_mroi_reg[7];
				end                                                       
				default	: begin                                           
					payload_size_temp	<=	payload_size_mroi_reg[0];                                                     
				end
			endcase				
		end
	end
	//  ===============================================================================================
	//  ״̬��
	//	��Ϊ�ĸ�״̬������״̬��ͷ��״̬�����ذ�״̬��β��״̬��ÿ��״̬�����Ӧ�ı�־�Ͱ���С�Ĵ���
	//	��λ�ص�IDLE״̬
	//	i_framebuffer_empty,fifo�ǿ�����IDLE״̬
	//	i_change_flag����־�����л�״̬
	//  ===============================================================================================
	always @ (posedge clk)begin
		if(reset)
	   		current_state <= IDLE;
		else
	   		current_state <= next_state;
	end

	always @ * begin
	    next_state = IDLE;
	    case(current_state)
			IDLE	:begin
				if (!i_framebuffer_empty)			//��Ϊ��ȫ��ǰ�˸��룬ֻ��ѡ���FIFO�ǿ���Ϊ��������
					next_state = LEADER;
				else
					next_state = IDLE;
			end
			LEADER	:begin							//i_change_flag�����л���־			
				if (i_change_flag)
					next_state = PAYLOAD;
				else
					next_state = LEADER;
			end
			PAYLOAD	:begin							//i_change_flag�����л���־			
				if (i_change_flag)
					next_state = TRAILER;
				else
					next_state = PAYLOAD;
			end
			TRAILER	:begin							//i_change_flag�����л���־		
				if (i_change_flag)
					next_state = IDLE;
				else
					next_state = TRAILER;
			end
	    endcase
	end

	always @ (posedge clk)begin
		if(reset)begin								//����źŸ���ֵ
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
			case(next_state)
				LEADER	:begin					
					o_leader_flag	<=	1'b1;
					ov_packet_size	<=	32'h34;		//leaderʱ��ÿ1��clkд��64bits��8bytes����д��52byte��Ҫ7clks�����Զ�д��4��bytes
				end
				PAYLOAD	:begin					
					o_payload_flag	<=	1'b1;
					ov_packet_size	<=	payload_size_temp;
				end
				TRAILER	:begin				
					o_trailer_flag	<=	1'b1;
					if (chunkmodeactive)
						ov_packet_size	<=	32'h24;	//chunk��ʱtrailer����36��ÿ1��clkд��64bits��8bytes��������ʵ��д��40bytes
					else
						ov_packet_size	<=	32'h20;	//chunk�ر�ʱtrailer����32
				end
				default	:;
			endcase
		end
	end
	
endmodule