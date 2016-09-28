//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : u3v_format
//  -- �����       : ��ǿ
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- ��ǿ         :| 2014/11/28 9:56:10	:|  ���ݼ���Ԥ������
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������
//              1)  : ��ͼ��ǰ�����ͷ��
//
//              2)  : ��ͼ�������chunk���PAYLOAD
//
//              3)  : ��ͼ��β�����β��
//
//				4)	: ͷ���е����ֽ�����ֶ�,���ǲ�ʹ����䷽������ֵ�̶�Ϊ0,��֧��chunk_layout_id Ĭ��ֵΪ0
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module u3v_format #(
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
	input								i_data_valid			,		//����ͨ·�����������Ч�źţ���־32λ����Ϊ��Ч����
	input		[DATA_WD-1			:0]	iv_data					,       //����ͨ·ƴ�Ӻõ�32bit���ݣ���������Ч���룬������ʱ�Ӷ���
	//  ===============================================================================================
	//  �������֣����ƼĴ�����chunk��Ϣ��ֻ���Ĵ���
	//  ===============================================================================================
	input								i_stream_enable			,		//��ʹ���źţ�����ʱ��ʱ����=0�����������ֹͣ��chunk�е�BLOCK IDΪ0
	input								i_acquisition_start     ,       //�����źţ�����ʱ��ʱ����=0����־����֡����������β�������ֹͣ
	input		[REG_WD-1			:0]	iv_pixel_format         ,       //���ظ�ʽ�����������leader��,����ͨ·������Чʱ�����ƣ���ģ�鲻���ٽ�����Чʱ������
	input								i_chunk_mode_active     ,       //chunk�ܿ��أ����ش�Payload Typeʹ��Ϊimage extend chunk ���ͣ�chunk�ر�Ϊimage����
	input								i_chunkid_en_ts         ,       //ʱ���chunkʹ��
	input								i_chunkid_en_fid        ,		//frame id chunkʹ��
	input		[REG_WD-1			:0]	iv_chunk_size_img       ,		//ͼ�񳤶ȣ����ֽ�Ϊ��λ����pixel formatΪ8bitʱ��һ������ռһ���ֽڣ���pixel format 10 bitʱ��һ������ռ�������ֽڡ�

	input		[LONG_REG_WD-1		:0]	iv_timestamp			, 		//ͷ���е�ʱ����ֶ�,�ɿ���ͨ�����͹���,iv_timestamp�ڳ��ź�������8��ʱ��֮������ȶ�
	input		[SHORT_REG_WD-1		:0]	iv_size_x				, 		//ͷ���еĴ��ڿ��
	input		[SHORT_REG_WD-1		:0]	iv_size_y				, 		//ͷ���еĴ��ڸ߶�
	input		[SHORT_REG_WD-1		:0]	iv_offset_x				, 		//ͷ���е�ˮƽƫ��
	input		[SHORT_REG_WD-1		:0]	iv_offset_y				, 		//ͷ���еĴ�ֱ����
	input		[REG_WD-1			:0]	iv_trailer_size_y		, 		//β���е���Ч�߶��ֶ�
	//  ===============================================================================================
	//  ���Ĳ��֣��С�������Ч������
	//  ===============================================================================================
	output								o_trailer_flag          ,		//β����־
	output								o_fval					,       //�����ͷβ�ĳ��źţ�����Ҫ���źŵ����������ȵ�һ����Ч10��clk���½���Ҫ�ͺ������һ����Ч����10��ʱ�����ϣ��Ա�֤֡������������
	output								o_data_valid			,       //�����ͷβ��������Ч�ź�
	output		[DATA_WD-1			:0]	ov_data                         //
	);
	//  ===============================================================================================
	//  u3v_format_control������
	//  ===============================================================================================
	wire								w_leader_valid			;
	wire		[DATA_WD-1			:0]	wv_leader_data			;
	wire                                w_payload_valid         ;
	wire        [DATA_WD-1			:0]	wv_payload_data         ;
	wire                                w_trailer_valid         ;
	wire        [DATA_WD-1			:0]	wv_trailer_data         ;
	wire								w_leader_flag           ;
	wire								w_image_flag            ;
	wire								w_chunk_flag            ;
	wire        [LONG_REG_WD-1		:0]	wv_blockid              ;
	wire		[REG_WD-1			:0]	wv_valid_payload_size	;
	wire		[SHORT_REG_WD-1		:0]	wv_status				;
//  ===============================================================================================
//  u3v_format_control������
//  ===============================================================================================
	u3v_format_control # (
	.DATA_WD						(DATA_WD					),
	.SHORT_REG_WD					(SHORT_REG_WD				),
	.REG_WD 						(REG_WD						),
	.LONG_REG_WD					(LONG_REG_WD				)
	)
	u3v_format_control_inst(
	.reset							(reset						),	//��λ�źţ��ߵ�ƽ��Ч������ʱ��ʱ����
	.clk							(clk						),	//ʱ���źţ�����ʱ��ʱ����ͬ�ڲ�����ʱ��
	.i_fval							(i_fval						),	//����ͨ·����ĳ��źţ�����ʱ��ʱ����,fval���ź��Ǿ�������ͨ���ӿ���ĳ��źţ���ͷ�������leader����������Ч��ͼ�����ݣ�ͣ���ڼ䱣�ֵ͵�ƽ
	.i_leader_valid					(w_leader_valid				),	//�����ͷ��������Ч�ź�
	.iv_leader_data         		(wv_leader_data         	),	//ͷ������
	.i_payload_valid				(w_payload_valid			),	//������Ч
	.iv_payload_data        		(wv_payload_data        	),	//��������
	.i_trailer_valid				(w_trailer_valid			),	//�����ͷ��������Ч�ź�
	.iv_trailer_data        		(wv_trailer_data        	),	//ͷ������
	.i_chunk_mode_active			(i_chunk_mode_active		),	//chunk�ܿ���
	.i_stream_enable				(i_stream_enable			),	//��ʹ���źţ�����ʱ��ʱ����=0��chunk�е�BLOCK IDΪ0
	.o_leader_flag					(w_leader_flag				),	//ͷ����־
	.o_image_flag					(w_image_flag				),	//���ذ��е�ͼ����Ϣ��־
	.o_chunk_flag					(w_chunk_flag				),	//���chunk��Ϣ��־
	.o_trailer_flag         		(o_trailer_flag         	),	//β����־
	.ov_blockid						(wv_blockid					),	//ͷ����chunk��β����blockid��Ϣ����һ֡��block ID��0��ʼ��������һ֡block IDΪ0
	.o_fval							(o_fval						),	//�����ͷβ��֡��Ϣ�ĳ��ź�
	.o_data_valid					(o_data_valid				),	//�����ͷβ��������Ч�ź�
	.ov_data                		(ov_data                	)	//����U3VЭ������ݰ�
	);
//  ===============================================================================================
//  leader������
//  ===============================================================================================
	leader # (
	.DATA_WD						(DATA_WD					),	//�����������λ������ʹ��ͬһ���
	.SHORT_REG_WD 					(SHORT_REG_WD 				),	//�̼Ĵ���λ��
	.REG_WD 						(REG_WD 					),	//�Ĵ���λ��
	.LONG_REG_WD 					(LONG_REG_WD 				)	//���Ĵ���λ��
	)
	leader_inst(
	.reset							(reset						),	//��λ�źţ��ߵ�ƽ��Ч������ʱ��ʱ����
	.clk							(clk						),	//ʱ���źţ�����ʱ��ʱ����ͬ�ڲ�����ʱ��
	.i_leader_flag					(w_leader_flag				),	//ͷ����־
	.iv_pixel_format        		(iv_pixel_format        	),	//���ظ�ʽ�����������leader��
	.i_chunk_mode_active    		(i_chunk_mode_active    	),	//chunk�ܿ��أ����ش�Payload Typeʹ��Ϊimage extend chunk ���ͣ�chunk�ر�Ϊimage����
	.iv_blockid						(wv_blockid					),	//ͷ����chunk��β����blockid��Ϣ����һ֡��block ID��0��ʼ��������һ֡block IDΪ0
	.iv_timestamp					(iv_timestamp				),	//ͷ���е�ʱ����ֶ�,iv_timestamp�ڳ��ź�������8��ʱ��֮������ȶ�
	.iv_size_x						(iv_size_x					),	//ͷ���еĴ��ڿ��
	.iv_size_y						(iv_size_y					),	//ͷ���еĴ��ڸ߶�
	.iv_offset_x					(iv_offset_x				),	//ͷ���е�ˮƽƫ��
	.iv_offset_y					(iv_offset_y				),	//ͷ���еĴ�ֱ����
	.o_data_valid					(w_leader_valid				),	//�����ͷ��������Ч�ź�
	.ov_data                		(wv_leader_data     		)	//ͷ������
	);
//  ===============================================================================================
//  payload������
//  ===============================================================================================

	payload # (
	.DATA_WD						(DATA_WD					),	//�����������λ������ʹ��ͬһ���
	.SHORT_REG_WD 					(SHORT_REG_WD 				),	//�̼Ĵ���λ��
	.REG_WD 						(REG_WD 					),	//�Ĵ���λ��
	.LONG_REG_WD 					(LONG_REG_WD 				)	//���Ĵ���λ��
	)
	payload_inst(
	.reset							(reset						),	//��λ�źţ��ߵ�ƽ��Ч������ʱ��ʱ����
	.clk							(clk						),	//ʱ���źţ�����ʱ��ʱ����ͬ�ڲ�����ʱ��
	.i_image_flag					(w_image_flag				),	//���ذ��е�ͼ����Ϣ��־
	.i_chunk_flag					(w_chunk_flag				),	//���chunk��Ϣ��־
	.i_data_valid					(i_data_valid				),	//����ͨ·�����������Ч�źţ���־32λ����Ϊ��Ч����
	.iv_data						(iv_data					),	//����ͨ·ƴ�Ӻõ�32bit���ݣ���������Ч���룬������ʱ�Ӷ���
	.i_chunk_mode_active    		(i_chunk_mode_active    	),	//chunk�ܿ��أ����ش�Payload Typeʹ��Ϊimage extend chunk ���ͣ�chunk�ر�Ϊimage����
	.i_chunkid_en_ts        		(i_chunkid_en_ts        	),	//ʱ���chunkʹ��
	.i_chunkid_en_fid       		(i_chunkid_en_fid       	),	//frame id chunkʹ��
	.iv_chunk_size_img      		(iv_chunk_size_img      	),	//ͼ�񳤶ȣ����ֽ�Ϊ��λ����pixel formatΪ8bitʱ��һ������ռһ���ֽڣ���pixel format 10 bitʱ��һ������ռ�������ֽڡ�
	.iv_pixel_format        		(iv_pixel_format        	),	//���ظ�ʽ
	.iv_timestamp					(iv_timestamp				),	//ʱ���
	.iv_blockid			        	(wv_blockid		            ),  //blockid
	.i_stream_enable				(i_stream_enable			),
	.ov_valid_payload_size			(wv_valid_payload_size		),	//��Чͼ�����ݣ�����chunk�������ظ�ʽ
	.ov_status						(wv_status					),	//�м�����ź�
	.o_data_valid					(w_payload_valid			),	//�����payload��chunk��������Ч�ź�
	.ov_data                		(wv_payload_data        	)	//payload��chunk����
	);
//  ===============================================================================================
//  trailer������
//  ===============================================================================================

	trailer #(
	.DATA_WD						(DATA_WD					),	//�����������λ������ʹ��ͬһ���
	.SHORT_REG_WD 					(SHORT_REG_WD 				),	//�̼Ĵ���λ��
	.REG_WD 						(REG_WD 					),	//�Ĵ���λ��
	.LONG_REG_WD 					(LONG_REG_WD 				)	//���Ĵ���λ��
	)
	trailer_inst(
	.reset							(reset						),	//��λ�źţ��ߵ�ƽ��Ч������ʱ��ʱ����
	.clk							(clk						),	//ʱ���źţ�����ʱ��ʱ����ͬ�ڲ�����ʱ��
	.i_trailer_flag					(o_trailer_flag				),	//ͷ����־
	.i_chunk_mode_active    		(i_chunk_mode_active    	), 	//chunk�ܿ��أ����ش�Payload Typeʹ��Ϊimage extend chunk ���ͣ�chunk�ر�Ϊimage����
	.i_chunkid_en_ts        		(i_chunkid_en_ts        	),	//ʱ���chunkʹ��
	.i_chunkid_en_fid       		(i_chunkid_en_fid       	),	//frame id chunkʹ��
	.iv_blockid						(wv_blockid					),	//ͷ����chunk��β����blockid��Ϣ����һ֡��block ID��0��ʼ��������һ֡block IDΪ0
	.iv_status						(wv_status					),	//β���еĵ�ǰ֡״̬������֡�治���ڶ�ʧ�������ݵ��������״̬Ϊ0
	.iv_valid_payload_size			(wv_valid_payload_size		),	//β���е���Ч���ش�С�ֶ�
	.iv_trailer_size_y				(iv_size_y					),	//β���е���Ч�߶��ֶ�
	.o_data_valid					(w_trailer_valid			),	//�����ͷβ��������Ч�ź�
	.ov_data                		(wv_trailer_data        	) 	//
	);
endmodule