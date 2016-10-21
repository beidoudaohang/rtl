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
//  -- �Ϻ���       :| 2016/4/25 17:40:31	:|  1.��� FVAL_TS_STABLE_NS ����
//												2.���ʱ�ӳ���60MHzʱ��chunk�е�ʱ����ɲ��ȵ�����
//	-- ����ǿ		:| 2016/9/20 15:25:14	:|  1.���������ִ����ʽ
//												2.��Ӷ�roi�������
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ����������������1810Ϊ��
//			u3v_format # (
//			.PIX_CLK_FREQ_KHZ			(PIX_CLK_FREQ_KHZ			),
//			.FVAL_TS_STABLE_NS			(FVAL_TS_STABLE_NS			),
//			.DATA_WD					(DATA_WD					),
//			.SHORT_REG_WD				(SHORT_REG_WD				),
//			.REG_WD						(REG_WD						),
//			.LONG_REG_WD				(LONG_REG_WD				),
//			.MROI_MAX_NUM				(16							)
//			)
//			u3v_format_inst (
//			.clk						(clk						),
//			.reset						(reset						),
//			.i_fval						(i_fval						),
//			.i_data_valid				(i_data_valid				),
//			.iv_data					(iv_data					),
//			.i_stream_enable			(i_stream_enable			),
//			.i_acquisition_start		(i_acquisition_start		),
//			.iv_pixel_format			(iv_pixel_format			),
//			.i_chunk_mode_active		(i_chunk_mode_active		),
//			.i_chunkid_en_ts			(i_chunkid_en_ts			),
//			.i_chunkid_en_fid			(i_chunkid_en_fid			),
//			.iv_timestamp				(iv_timestamp				),
//			.iv_chunk_size_img			(iv_chunk_size_img			),
//			.i_multi_roi_global_en				(i_multi_roi_global_en				),
//			.iv_multi_roi_single_en			(iv_multi_roi_single_en			),
//			.iv_chunk_size_img_mroi		(iv_chunk_size_img_mroi		),
//			.iv_offset_x_mroi			(iv_offset_x_mroi			),
//			.iv_offset_y_mroi			(iv_offset_y_mroi			),
//			.iv_size_x_mroi				(iv_size_x_mroi				),
//			.iv_size_y_mroi				(iv_size_y_mroi				),
//			.iv_trailer_size_y_mroi		(iv_trailer_size_y_mroi		),
//			.o_fval						(o_fval						),
//			.o_data_valid				(o_data_valid				),
//			.o_leader_flag				(o_leader_flag				),
//			.o_image_flag				(o_image_flag				),
//			.o_chunk_flag				(o_chunk_flag				),
//			.o_trailer_flag				(o_trailer_flag				),
//			.ov_data					(ov_data					)
//			);
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module u3v_format # (
	parameter	PIX_CLK_FREQ_KHZ	= 72000	,	//����ʱ�ӵ�Ƶ�ʣ���khzΪ��λ
	parameter	FVAL_TS_STABLE_NS	= 95	,	//��fval�������ȶ�����ʱ�����ʱ��
	parameter	DATA_WD				= 64	,	//�����������λ������ʹ��ͬһ���
	parameter	SHORT_REG_WD 		= 16	,	//�̼Ĵ���λ��
	parameter	REG_WD 				= 32	,	//�Ĵ���λ��
	parameter	LONG_REG_WD 		= 64	,	//���Ĵ���λ��
	parameter	MROI_MAX_NUM 		= 8			//Multi-ROI��������,���֧��2^8
	)
	(
	//  ===============================================================================================
	//  ��һ���֣�ʱ�Ӹ�λ
	//  ===============================================================================================
	input											clk						,	//ʱ���źţ�����ʱ��ʱ����ͬ�ڲ�����ʱ��
	input											reset					,	//��λ�źţ��ݲ�ʹ��,�ߵ�ƽ��Ч������ʱ��ʱ����
	//  ===============================================================================================
	//  �ڶ����֣��С��������ݡ�������Ч
	//  ===============================================================================================
	input											i_fval					,	//����ͨ·����ĳ��źţ�����ʱ��ʱ����,fval���ź��Ǿ�������ͨ���ӿ���ĳ��źţ���ͷ�������leader����������Ч��ͼ�����ݣ�ͣ���ڼ䱣�ֵ͵�ƽ
	input											i_data_valid			,	//����ͨ·�����������Ч�źţ���־32λ����Ϊ��Ч����
	input	[DATA_WD-1:0]							iv_data					,	//����ͨ·ƴ�Ӻõ�32bit���ݣ���������Ч���룬������ʱ�Ӷ���
	//  ===============================================================================================
	//  �������֣����ƼĴ�����chunk��Ϣ
	//  ===============================================================================================
	input											i_stream_enable			,	//��ʹ���źţ�����ʱ��ʱ����=0�����������ֹͣ��chunk�е�BLOCK IDΪ0
	input											i_acquisition_start     ,	//�����źţ��ݲ�ʹ�ã�����ʱ��ʱ����=0����־����֡����������β�������ֹͣ
	input	[REG_WD-1:0]							iv_pixel_format         ,	//���ظ�ʽ�����������leader��,����ͨ·������Чʱ�����ƣ���ģ�鲻���ٽ�����Чʱ������
	input											i_chunk_mode_active     ,	//chunk�ܿ��أ����ش�Payload Typeʹ��Ϊimage extend chunk ���ͣ�chunk�ر�Ϊimage����
	input											i_chunkid_en_ts         ,	//ʱ���chunkʹ��
	input											i_chunkid_en_fid        ,	//frame id chunkʹ��
	input	[LONG_REG_WD-1:0]						iv_timestamp			,	//ͷ���е�ʱ����ֶ�,�ɿ���ͨ�����͹���
	//  ===============================================================================================
	//  ���Ĳ��֣�������Ϣ2
	//  ===============================================================================================
	input	[REG_WD-1:0]							iv_chunk_size_img		,	//ͼ�񳤶ȣ����ֽ�Ϊ��λ����pixel formatΪ8bitʱ��һ������ռһ���ֽڣ���pixel format 10 bitʱ��һ������ռ�������ֽڡ�
	//  ===============================================================================================
	//  ���岿�֣���roi��Ϣ
	//  ===============================================================================================
	input											i_multi_roi_global_en			,	//roi�ܿ���
	input	[MROI_MAX_NUM-1:0]						iv_multi_roi_single_en		,	//ÿ��roi��ʹ���źţ�����bit0��Ӧroi0��ʹ��
	input	[REG_WD*MROI_MAX_NUM-1:0]				iv_chunk_size_img_mroi	,	//ͼ�񳤶ȣ����ֽ�Ϊ��λ����pixel formatΪ8bitʱ��һ������ռһ���ֽڣ���pixel format 10 bitʱ��һ������ռ�������ֽڡ�
	input	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_offset_x_mroi		,	//ͷ���е�ˮƽƫ��
	input	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_offset_y_mroi		,	//ͷ���еĴ�ֱ����
	input	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_size_x_mroi			,	//ͷ���еĴ��ڿ��
	input	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_size_y_mroi			,	//ͷ���еĴ��ڸ߶�
	input	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_trailer_size_y_mroi	,	//β���е���Ч�߶��ֶ�
	//  ===============================================================================================
	//  �������֣��С�������Ч������
	//  ===============================================================================================
	output											o_fval					,	//�����ͷβ�ĳ��źţ�����Ҫ���źŵ����������ȵ�һ����Ч10��clk���½���Ҫ�ͺ������һ����Ч����10��ʱ�����ϣ��Ա�֤֡������������
	output											o_data_valid			,	//�����ͷβ��������Ч�ź�
	output											o_leader_flag			,	//ͷ����־
	output											o_image_flag			,	//ͼ���־
	output											o_chunk_flag			,	//chunk��־
	output											o_trailer_flag			,	//β����־����imag_flagǰ
	output											o_trailer_final_flag	,	//���һ��roi��β����־,��image_flag��
	output	[DATA_WD-1:0]							ov_data						//�������
	);

//	===============================================================================================
//	functions
//	===============================================================================================
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
	//	-------------------------------------------------------------------------------------
	//	ȡ���ֵ
	//	-------------------------------------------------------------------------------------
	function integer max(input integer n1, input integer n2);
		max = (n1 > n2) ? n1 : n2;
	endfunction
//	===============================================================================================
//	�궨��
//	===============================================================================================
	//����ʱ�����ڣ��� ns Ϊ��λ
	localparam						CLK_PERIOD_NS		= 1000000/PIX_CLK_FREQ_KHZ;
	localparam						PAYLOAD_SHIFT_NUM	= log2(DATA_WD/8);//��Чpayload�����������ʱ��������λ
	//	-------------------------------------------------------------------------------------
	//	״̬����״̬ͣ��ʱ��
	//	-------------------------------------------------------------------------------------
	localparam						TIMESTAMP_DELAY		= (FVAL_TS_STABLE_NS/CLK_PERIOD_NS)+1; //��fval�����ػ����½��غ�ʱ�����Ҫ�ȶ�������ʱ��
	localparam						LEADER_SIZE			= 7;//��roi��S_LEADER״̬��clk��
	localparam						CHUNK_SIZE			= 5;//��roi��S_CHUNK״̬��clk��
	localparam						TRAILER_SIZE		= 5;
	localparam						EXT_SIZE			= 10;	//fval lval �½�����ʱ
	//	-------------------------------------------------------------------------------------
	//	һЩ������Ҫ���ݵ�������Ϣ
	//	-------------------------------------------------------------------------------------
	localparam						FID_LENTH			= 32'h8	;	//frameid ����
	localparam						TS_LENTH			= 32'h8	;	//timestamp ����
	//	-------------------------------------------------------------------------------------
	//	һЩ��������λ��
	//	-------------------------------------------------------------------------------------
	localparam						MROI_NUM_WD = log2(MROI_MAX_NUM)+1;//roi����������λ��
	localparam						PER_ROI_CNT_WD	= log2( max(max(max(max(TIMESTAMP_DELAY,LEADER_SIZE),CHUNK_SIZE),TRAILER_SIZE),EXT_SIZE) )+1;
	//	-------------------------------------------------------------------------------------
	//	FSM Parameter Define
	//	-------------------------------------------------------------------------------------
	parameter						S_IDLE			= 8'b0000_0000;	//IDLE״̬
	parameter						S_TIMESTAMP		= 8'b0000_0001;	//S_TIMESTAMP1״̬������i_fval�����غ�ȴ�ʱ����ȶ�
	parameter						S_LEADER		= 8'b0000_0010;	//S_LEADER״̬���ڴ���ͷ��
	parameter						S_CHUNK			= 8'b0000_0100;	//S_CHUNK״̬���ڴ���chunk��Ϣ����chunk��ʹ��ʱ����������в�����chunk���ݣ���S_CHUNK״̬��Ȼ���ڣ����������
	parameter						S_TRAILER		= 8'b0000_1000;	//S_TRAILER״̬���ڴ���β����Ϣ
	parameter						S_IMAGE			= 8'b0001_0000;	//S_IMAGE״̬���ڴ�����������
	parameter						S_F_TRAILER		= 8'b0010_0000;	//S_F_TRAILER״̬������֡β�������һ����Чroi��trailer��
	parameter						S_EXT			= 8'b0100_0000;	//S_EXT״̬������ʱfval�½���
//	===============================================================================================
//	wirs and regs
//	===============================================================================================
	reg									chunk_mode_active_dly	;	//i_chunk_mode_active�źŴ���
	reg									chunkid_en_ts_dly		;	//i_chunkid_en_ts�źŴ���
	reg									chunkid_en_fid_dly		;	//i_chunkid_en_fid�źŴ���
	reg									fval_dly				;	//i_fval�źŴ���
	wire								fval_rise				;	//fval������
	wire								fval_fall				;	//fval�½���
//	reg									enable					;	//i_stream_enable & i_acquisition_start
	reg		[MROI_MAX_NUM-1:0]			multi_roi_single_en_reg = 'b0;	//������Чʱ�����iv_per_roi_enable
	reg		[MROI_MAX_NUM-1:0]			multi_roi_single_en_shift= 'b0;	//��λ�Ĵ����������жϵ�ǰ�Ƿ�Ϊ���һ����Чroi
	reg		[MROI_NUM_WD-1:0]			last_roi_num		=	{MROI_NUM_WD{1'b1}};	//��¼���һ����Чroi���
	wire								is_last_roi				;	//��ǰroi����ĩ��ЧroiΪ1������Ϊ0
	reg									stream_enable_reg		;	//��i_stream_enable�͵�ƽ�ӳ�ֱ��i_fval������
	reg		[7:0]						current_state	= S_IDLE;	//��ǰ״̬
	reg		[7:0]						next_state		= S_IDLE;	//��һ״̬
	reg		[PER_ROI_CNT_WD-1:0]		per_roi_cnt		= 'b0	;	//��roiģʽ�£�ÿ��״̬����ĳ��roi�ļ�������roiģʽ�£�ÿ��״̬�ļ���
	reg		[MROI_NUM_WD-1:0]			roi_num_cnt		= 'b0	;	//״̬����ÿ��״̬������roi
	//	-------------------------------------------------------------------------------------
	//	����źżĴ���
	//	-------------------------------------------------------------------------------------
	reg									data_valid_reg			;	//o_data_valid=data_valid_reg
	reg		[DATA_WD-1:0]				data_reg				;	//ov_data=data_reg
	reg									fval_reg				;	//o_fval = fval_reg
	reg									leader_flag_reg			;	//o_leader_flag = leader_flag_reg
	reg									image_flag_reg			;	//o_image_flag = image_flag_reg
	reg									chunk_flag_reg			;	//o_chunk_flag = chunk_flag_reg
	reg									trailer_flag_reg		;	//o_trailer_flag = trailer_flag_reg
	reg									trailer_final_flag_reg	;	//o_trailer_final_flag = trailer_final_flag_reg

	//	-------------------------------------------------------------------------------------
	//	adder
	//	-------------------------------------------------------------------------------------
	reg		[46:0]		adder_a		= 47'b0;
	reg					adder_b		= 1'b0;
	reg					adder_ce	= 1'b0;
	wire	[46:0]		adder_sum	;
	reg					adder_clr	;
	//	-------------------------------------------------------------------------------------
	//	blockid
	//	-------------------------------------------------------------------------------------
	reg		[46:0]						blockid_low47_acc	= 'b0	;	//ÿ֡�����ۼ�������n��nΪroi��
	reg		[46:0]						blockid_low47_roi	= 'b0	;	//��roi blockid�ĵ�47λ
	reg 	[REG_WD-1:0]				chunk_size_img_reg		;	//���ݵ�roi���߶�roi������õ�iv_chunk_size_img����iv_chunk_size_img_mroi[REG_WD-1:0]

	//	-------------------------------------------------------------------------------------
	//	status/valid_payload
	//	-------------------------------------------------------------------------------------
	reg 	[REG_WD-1:0]							act_payload_cnt			;
	reg		[REG_WD-1:0]							valid_payload_size		;
	reg		[15 :     0]							status			= 'b0	;
	//	-------------------------------------------------------------------------------------
	//	chunk_layout_id
	//	-------------------------------------------------------------------------------------
	reg		[7:0]						chunk_layout_id			= 8'h0;
	//	-------------------------------------------------------------------------------------
	//	�Ӷ˿��зֽ����roi��Ϣ
	//	-------------------------------------------------------------------------------------
	wire	[REG_WD-1 : 0]				per_chunk_size_img_mroi	[MROI_MAX_NUM-1:0]	;
	wire	[SHORT_REG_WD-1:0]			per_offset_x_mroi		[MROI_MAX_NUM-1:0]	;
	wire	[SHORT_REG_WD-1:0]			per_offset_y_mroi		[MROI_MAX_NUM-1:0]	;
	wire	[SHORT_REG_WD-1:0]			per_size_x_mroi			[MROI_MAX_NUM-1:0]	;
	wire	[SHORT_REG_WD-1:0]			per_size_y_mroi			[MROI_MAX_NUM-1:0]	;
	wire	[SHORT_REG_WD-1:0]			per_trailer_size_y_mroi	[MROI_MAX_NUM-1:0]	;
	wire	[REG_WD-1 : 0]				valid_payload_size_mroi	[MROI_MAX_NUM-1:0]	;
//	===============================================================================================
//	�����roi��Ϣ��������һ��ģ�������߼����Խ���ֿ�
//	===============================================================================================
	genvar	i;
	generate
		for(i=0;i<MROI_MAX_NUM;i=i+1) begin
			assign per_chunk_size_img_mroi[i] = iv_chunk_size_img_mroi[(i+1)*REG_WD-1:i*REG_WD];
			assign per_offset_x_mroi[i]		=	iv_offset_x_mroi[(i+1)*SHORT_REG_WD-1:i*SHORT_REG_WD];
			assign per_offset_y_mroi[i]		=	iv_offset_y_mroi[(i+1)*SHORT_REG_WD-1:i*SHORT_REG_WD];
			assign per_size_x_mroi[i]		=	iv_size_x_mroi[(i+1)*SHORT_REG_WD-1:i*SHORT_REG_WD];
			assign per_size_y_mroi[i]		=	iv_size_y_mroi[(i+1)*SHORT_REG_WD-1:i*SHORT_REG_WD];
			assign per_trailer_size_y_mroi[i]	=	iv_trailer_size_y_mroi[(i+1)*REG_WD-1:i*REG_WD];
			assign valid_payload_size_mroi[i]	= iv_chunk_size_img_mroi[(i+1)*REG_WD-1:i*REG_WD];
		end
	endgenerate
//	===============================================================================================
//	���ļ�������ȡ
//	===============================================================================================
	always @ (posedge clk) begin
		fval_dly <= i_fval;
	end
	assign fval_rise = {fval_dly,i_fval} == 2'b01 ? 1'b1 : 1'b0;
	assign fval_fall = {fval_dly,i_fval} == 2'b10 ? 1'b1 : 1'b0;

	//	��chunkʹ���źŴ���
	always @ (posedge clk) begin
		chunk_mode_active_dly	<= i_chunk_mode_active	;
		chunkid_en_ts_dly		<= i_chunkid_en_ts		;
		chunkid_en_fid_dly		<= i_chunkid_en_fid		;
	end
//	===============================================================================================
//	��Чʱ���Լ�����ѡ��
//	===============================================================================================

	//roi λʹ����i_fval��������Ч
	always @ (posedge clk) begin
		if(fval_rise) begin
			multi_roi_single_en_reg <= iv_multi_roi_single_en;
		end
		else begin
			multi_roi_single_en_reg <= multi_roi_single_en_reg;
		end
	end


	//��i_stream_enable�͵�ƽ�ӳ�ֱ��i_fval������
	always @ (posedge clk) begin
		if(!i_stream_enable) begin
			stream_enable_reg <= 1'b0;
		end
		else if(fval_rise) begin
			stream_enable_reg <= 1'b1;
		end
	end

	always @ (posedge clk) begin
		if(i_multi_roi_global_en) begin //��roi������£��õ���chunkֵ
			chunk_size_img_reg <= iv_chunk_size_img;
		end
		else begin //��roi����£���roi0��chunk���ܵ�
			chunk_size_img_reg <= per_chunk_size_img_mroi[0];
		end
	end
	//	-------------------------------------------------------------------------------------
	//	instantiate adder
	//	��Ч��������blockid��ͳ�ƶ��ڼӷ�������ɣ��ӷ������÷�ʱ���õķ���
	//	-------------------------------------------------------------------------------------
	u3v_adder_47 u3v_adder_47_inst (
	.clk	(clk				),
	.ce		(adder_ce			),
	.sclr	(adder_clr			),
	.a		(adder_a			),
	.b		(adder_b			),
	.s		(adder_sum			)
	);

	// adder_clr
	always @ (posedge clk) begin
		if(!stream_enable_reg) begin //ͣ��ʱ��λ�ӷ�������ģ�����ʱ�����ƣ�ͣ��ʱ��һ���������S_IDLE״̬���ӷ�������λ��blockid_accҲ��ͬ����0
			adder_clr <= 1'b1;
		end
		else if(fval_rise)begin //ÿ֡�������ظ�λ�ӷ������������һ֡�����adder_sum��Ϣ
			adder_clr <= 1'b1;
		end
		else if((current_state == S_CHUNK)&&(per_roi_cnt == CHUNK_SIZE - 1)&&(roi_num_cnt == MROI_MAX_NUM - 1)) begin//���ʱ�����ͳ��blockid��ͳ���������ķֽ�㣬�ӷ���Ӧ����0
			adder_clr <= 1'b1;
		end
		else begin
			adder_clr <= 1'b0;
		end
	end
	// adder_ce
	always @ (posedge clk) begin
		case(current_state)
			S_IMAGE:	//�ӷ�������ͳ����Ч����ʱ�ӽ׶�
				adder_ce <= i_data_valid;
			S_LEADER, S_CHUNK, S_TRAILER: //�ӷ�������ͳ��blockid�׶�
				//��Ч����
				// 1. ��ǰroi��ѡ��
				// 2. per_roi_cnt==2ʱ�Ѿ�����ÿ��roi����blockid�Ľ׶Σ���ʱִ���ۼ�
				adder_ce <= (per_roi_cnt==2);
			default:
				adder_ce <= 1'b0;
		endcase
	end

	 // adder_a
	always @ (*) begin
		case(current_state)
			S_IMAGE: begin	//�ӷ�������ͳ����Ч����ʱ�ӽ׶�
				adder_a <= adder_sum; //��S_IMAGE֮ǰ����0�ӷ�������˴�0��ʼ�ۼ�
			end

			S_LEADER, S_CHUNK, S_TRAILER: begin //�ӷ�������ͳ��blockid�׶�
				if(roi_num_cnt == 0) begin //��һ��roi���ӷ�����blockid_low47_acc�õ���ʼֵ
					adder_a <= blockid_low47_acc;
				end
				else begin //֮������ڿ�ʼ�ۼӣ�blockid_low47_roi����ÿ��roi��Ҫ�����blockid
					adder_a <= blockid_low47_roi;
				end
			end

			default: begin
				adder_a <= 'b0;
			end
		endcase
	end

	// adder_b
	always @ (posedge clk) begin
		case(current_state)
			S_IMAGE: begin	//�ӷ�������ͳ����Ч����ʱ�ӽ׶�
				adder_b <= 1'b1; //��S_IMAGE֮ǰ����0�ӷ�������˴�0��ʼ�ۼ�
			end

			S_LEADER, S_CHUNK, S_TRAILER: begin //�ӷ�������ͳ��blockid�׶�
				adder_b <= multi_roi_single_en_reg[roi_num_cnt];
			end

			default: begin
				adder_b <= 'b0;
			end
		endcase
	end
	//	-------------------------------------------------------------------------------------
	//	-ref blockid_low47_roi
	//
	//				leader		| chunk		| trailer  	||leader		| chunk		| trailer
	// 				|roi0---roi1|roi0---roi1|roi0---roi1| roi0---roi1|roi0---roi1|roi0---roi1|
	//	low47_roi	|0------1---|0------1---|0------1---| 2------3---|2------3---|2------3---|
	//	low47_acc	0									|2
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(current_state)
			S_LEADER, S_CHUNK, S_TRAILER: begin
				if(per_roi_cnt == 'b0) begin  //����blockid_low47_roi�Ľ׶���ÿ��roi�ĵ�һ�����ڣ���֤������blockidʱ�Ѿ���ɸ���
					if(roi_num_cnt == 0) begin
						blockid_low47_roi <= blockid_low47_acc;//��һ��roi��blockid_low47_acc��ȡ����ֵ
					end
					else begin
						blockid_low47_roi <= adder_sum;//�ӷ����ۼ�ֵ������blockid_low47_roi�й���ȡ��
					end
				end
			end
			default:
				blockid_low47_roi <= blockid_low47_roi;
		endcase
	end

	always @ (posedge clk) begin
		if((current_state == S_IDLE) && (!stream_enable_reg)) begin //S_IDLE�ڼ����se���ͣ�blockid_low47_acc��Ҫ����0
			blockid_low47_acc <= 'b0;
		end
		else if((current_state == S_CHUNK)&&(per_roi_cnt == CHUNK_SIZE - 1)&&(roi_num_cnt == MROI_MAX_NUM - 1)) begin//trailer���ĵ����ڶ������ڸ���blockid_low47_acc����Ϊ֮��ӷ����ᱻ��������ͳ�������������Լӷ������ۼ�ֵӦ��ʱȡ��
			blockid_low47_acc <= adder_sum;
		end
	end
	//	-------------------------------------------------------------------------------------
	//	-ref  status
	//	-------------------------------------------------------------------------------------

	//	ͳ��image_flag�ڼ��������Ч����
	always @ (posedge clk) begin
		if(fval_rise) begin
			act_payload_cnt	<= 0;
		end
		else if(fval_fall) begin
			act_payload_cnt	<= adder_sum<<PAYLOAD_SHIFT_NUM;
		end
	end

	// ͳ��payload�͸���payload�Ƚϣ����ݱȽϽ��ȷ��status
	always @ (posedge clk) begin
		if(act_payload_cnt[REG_WD-1:3]>chunk_size_img_reg[REG_WD-1:3]) begin
			status	<= 16'hA101;
			valid_payload_size <= act_payload_cnt;
		end
		else if(act_payload_cnt[REG_WD-1:3]<chunk_size_img_reg[REG_WD-1:3]) begin
			status	<= 16'hA100;
			valid_payload_size <= act_payload_cnt;
		end
		else begin
			status	<= 16'h0000;
			valid_payload_size <= valid_payload_size_mroi[last_roi_num];
		end
	end

	//	-------------------------------------------------------------------------------------
	//	-ref valid_payload_size_mroi
	//	-------------------------------------------------------------------------------------


	//	-------------------------------------------------------------------------------------
	//	-ref chunk_layoutid
	//	--��chunkʹ���ź��иı��ʱ�� id++
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(chunk_mode_active_dly^i_chunk_mode_active || chunkid_en_ts_dly^i_chunkid_en_ts || chunkid_en_fid_dly^i_chunkid_en_fid) begin
			chunk_layout_id	<= chunk_layout_id + 1'b1;
		end
	end

	//	===============================================================================================
	//	Ѱ�����һ��roi
	//	===============================================================================================
	// ��leader������׶Σ�
	//	1.ÿ��roi�ĵ�2�����ڽ�roiλʹ�ܼĴ�������һλ
	//	2.ÿ��roi�ĵ�3�������ж�roiλʹ�ܼĴ����Ƿ�Ϊ0�����Ϊ0����ǰroiΪ���һ����Чroi
	always @ (posedge clk) begin
		if(fval_rise) begin
			multi_roi_single_en_shift <= iv_multi_roi_single_en;
		end
		else if((current_state == S_LEADER) && (per_roi_cnt == 1)) begin
			multi_roi_single_en_shift <= multi_roi_single_en_shift >> 1;
		end
	end

	always @ (posedge clk) begin
		if(fval_rise) begin
			last_roi_num <= {MROI_NUM_WD{1'b1}};
		end
		if((current_state == S_LEADER) && (per_roi_cnt == 2)) begin
			if(multi_roi_single_en_shift == 0) begin
				last_roi_num <= roi_num_cnt;
			end
		end
	end

	assign is_last_roi = (last_roi_num == roi_num_cnt) ? 1'b1 : 1'b0;
//	===============================================================================================
//	״̬�����
//	===============================================================================================
	//	===============================================================================================
	//	ref ***FSM***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	-ref FSM Sequential Logic
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			current_state	<= S_IDLE;
		end
		else begin
			current_state	<= next_state;
		end
	end
	//	===============================================================================================
	//	-ref FSM pipeline
	//	===============================================================================================

	//	roi_num_cnt	0---------------1---------------2����������������--M-1-------------0
	//	per_roi_cnt 0--1--2����--N-1--0--1--2����--N-1--0����������������--0--1--2����--N-1--0
	//	���� M=MROI_MAX_NUM   N=XXX_SIZE

	//	per_roi_cnt
	always @ (posedge clk) begin
		case(current_state)
			S_IDLE, S_IMAGE: begin
				per_roi_cnt <= 'b0;
			end

			S_TIMESTAMP : begin
				if(per_roi_cnt == TIMESTAMP_DELAY - 1) begin
					per_roi_cnt <= 'b0;
				end
				else begin
					per_roi_cnt <= per_roi_cnt + 1'b1;
				end
			end

			S_LEADER: begin
				if(per_roi_cnt == LEADER_SIZE - 1) begin
					per_roi_cnt <= 'b0;
				end
				else begin
					per_roi_cnt <= per_roi_cnt + 1'b1;
				end
			end

			S_CHUNK: begin
				if(per_roi_cnt == CHUNK_SIZE - 1) begin
					per_roi_cnt <= 'b0;
				end
				else begin
					per_roi_cnt <= per_roi_cnt + 1'b1;
				end
			end

			S_TRAILER, S_F_TRAILER: begin
				if(per_roi_cnt == TRAILER_SIZE - 1) begin
					per_roi_cnt <= 'b0;
				end
				else begin
					per_roi_cnt <= per_roi_cnt + 1'b1;
				end
			end

			S_EXT: begin
				if(per_roi_cnt == EXT_SIZE - 1) begin
					per_roi_cnt <= 'b0;
				end
				else begin
					per_roi_cnt <= per_roi_cnt + 1'b1;
				end
			end

			default: begin
				per_roi_cnt <= 'b0;
			end
		endcase
	end

	//	roi_num_cnt
	//	ÿ��״̬�£���roi���ڵݼ�
	always @ (posedge clk) begin
		case(current_state)
			S_IDLE, S_TIMESTAMP, S_IMAGE, S_F_TRAILER, S_EXT: begin
				roi_num_cnt <= 'b0;
			end

			S_LEADER: begin
				if(per_roi_cnt == LEADER_SIZE - 1) begin
					if(roi_num_cnt == MROI_MAX_NUM - 1) begin
						roi_num_cnt <= 'b0;
					end
					else begin
						roi_num_cnt <= roi_num_cnt + 1'b1;
					end
				end
			end

			S_TRAILER: begin
				if(per_roi_cnt == TRAILER_SIZE - 1) begin
					if(roi_num_cnt == MROI_MAX_NUM - 1) begin
						roi_num_cnt <= 'b0;
					end
					else begin
						roi_num_cnt <= roi_num_cnt + 1'b1;
					end
				end
			end

			S_CHUNK: begin
				if(per_roi_cnt == CHUNK_SIZE - 1) begin
					if(roi_num_cnt == MROI_MAX_NUM - 1) begin
						roi_num_cnt <= 'b0;
					end
					else begin
						roi_num_cnt <= roi_num_cnt + 1'b1;
					end
				end
			end

			default: begin
				roi_num_cnt <= 'b0;
			end
		endcase
	end


	//	-------------------------------------------------------------------------------------
	//	-ref FSM Conbinatial Logic
	//	-------------------------------------------------------------------------------------
	always @ ( * ) begin
		case(current_state)
			S_IDLE: begin //i_fval��������ʱS_IDLE��ת��S_TIMESTAMP������
				if(fval_rise) begin
					next_state = S_TIMESTAMP;
				end
				else begin
					next_state = S_IDLE;
				end
			end

			S_TIMESTAMP: begin
				//��S_TIMESTAMP״̬ͣ��һ��ʱ�䣬ʹʱ����ȶ�����������ת��S_LEADER״̬
				if(per_roi_cnt == TIMESTAMP_DELAY - 1) begin
					next_state = S_LEADER;
				end
				else begin
					next_state = S_TIMESTAMP;
				end
			end

			S_LEADER: begin
				//��ת������1.ÿ��roi�������leader�� 2.��������roi
				if((per_roi_cnt == LEADER_SIZE - 1)&&(roi_num_cnt == MROI_MAX_NUM - 1)) begin
					next_state = S_TRAILER;
				end

				else begin
					next_state = S_LEADER;
				end
			end

			S_TRAILER: begin
				//��ת������1.ÿ��roi�������trailer�� 2.��������roi
				if((per_roi_cnt == TRAILER_SIZE - 1)&&(roi_num_cnt == MROI_MAX_NUM - 1)) begin
					next_state = S_CHUNK;
				end

				else begin
					next_state = S_TRAILER;
				end
			end

			S_CHUNK: begin
				//��ת������1.ÿ��roi�������CHUNK�� 2.��������roi
				if((per_roi_cnt == CHUNK_SIZE - 1)&&(roi_num_cnt == MROI_MAX_NUM - 1)) begin
					next_state = S_IMAGE;
				end

				else begin
					next_state = S_CHUNK;
				end
			end

			S_IMAGE: begin //��ת������i_fval�½���
				if(fval_fall) begin
					next_state = S_F_TRAILER;
				end
				else begin
					next_state = S_IMAGE;
				end
			end

			S_F_TRAILER: begin
				//��ת������1.ÿ��roi�������trailer�� 2.��������roi
				if(per_roi_cnt == TRAILER_SIZE - 1) begin
					next_state = S_EXT;
				end

				else begin
					next_state = S_F_TRAILER;
				end
			end



			S_EXT: begin
				//��S_EXTͣ��һ��ʱ�䣬��fval�½����ӳ�һ��ʱ������ת
				if(per_roi_cnt == EXT_SIZE - 1) begin
					next_state = S_IDLE;
				end
				else begin
					next_state = S_EXT;
				end
			end

			default: begin
				next_state = S_IDLE;
			end
		endcase
	end

	//	-------------------------------------------------------------------------------------
	//	-ref FSM Output Logic
	//	-------------------------------------------------------------------------------------
	//	--ref o_data_valid
	always @ (posedge clk) begin
		case(current_state)
			S_IDLE, S_TIMESTAMP, S_EXT: begin
				data_valid_reg <= 1'b0;
			end

			S_LEADER, S_TRAILER: begin
				if(multi_roi_single_en_reg[roi_num_cnt]) begin//ֻ�е�ǰroi��ѡ�в���Ч
					data_valid_reg <= 1'b1;
				end
				else begin
					data_valid_reg <= 1'b0;
				end
			end

			S_CHUNK: begin
				if(multi_roi_single_en_reg[roi_num_cnt]) begin//ֻ�е�ǰroi��ѡ�в���Ч
					case(per_roi_cnt)
						//image id length
						0 : data_valid_reg	<= i_chunk_mode_active;
						//frameid
						1 : data_valid_reg	<= i_chunk_mode_active&i_chunkid_en_fid;
						//frameid id length
						2 : data_valid_reg	<= i_chunk_mode_active&i_chunkid_en_fid;
						//timestamp
						3 : data_valid_reg	<= i_chunk_mode_active&i_chunkid_en_ts;
						//timestamp id length
						4 : data_valid_reg	<= i_chunk_mode_active&i_chunkid_en_ts;
						default	: data_valid_reg	<= 1'b0;
					endcase
				end
				else begin
					data_valid_reg <= 1'b0;
				end
			end

			S_IMAGE: begin
				data_valid_reg <= i_data_valid;
			end

			S_F_TRAILER: begin
				data_valid_reg <= 1'b1;
			end

			default: begin
				data_valid_reg <= 1'b0;
			end
		endcase
	end
	assign o_data_valid = data_valid_reg;

	//	--ref ov_data


	always @ (posedge clk) begin
		case(current_state)
			S_IDLE, S_TIMESTAMP, S_EXT: begin
				data_reg <= 'b0;
			end

			S_LEADER: begin
				case(per_roi_cnt)
					//{{leader_size,reserved},magic_key}=={{leader_size,0},LV3U}
					0		: data_reg	<= {{16'd52,16'd0},32'h4c563355};
					//blockid
					1		: data_reg	<= {17'b0,blockid_low47_roi[46:0]};
					//{timestamp[31:0],payload_type,reserved} payload_type-����ֻ֧��Image��0x0001����Image Extended Chunk��0x4001��
					2		: data_reg	<= {iv_timestamp[31:0],{1'b0,i_chunk_mode_active,{14'h0001},16'h0000}};
					//{pixel_format,timestamp[63:32]}
					3		: data_reg	<= {iv_pixel_format,iv_timestamp[63:32]};
					//{size_y,size_x}
					4		: data_reg	<= {{16'h00,per_size_y_mroi[roi_num_cnt]},{16'h00,per_size_x_mroi[roi_num_cnt]}};
					//{offset_y,offset_x}
					5		: data_reg	<= {{16'h00,per_offset_y_mroi[roi_num_cnt]},{16'h00,per_offset_x_mroi[roi_num_cnt]}};
					//{reserved_byte,reserved_byte,(��ǰroiΪ���һ��roiʱ���1),roi��,padding_x}
					6		: data_reg	<= {16'h0,{7'h0,is_last_roi},{{(8-MROI_NUM_WD){1'h0}},roi_num_cnt},32'h0};
					default	: data_reg	<= {32'h0,32'h0};
				endcase
			end

			S_TRAILER: begin
				case(per_roi_cnt)
					//{{trailer_size,reserved},magic_key}=={{trailer_size,0},TV3U} //����ʹ��λ����һ��ƴ�ӣ���i_chunk_mode_activeʹ�ܣ�����Ϊ36������Ϊ32
					0		: data_reg	<= {{13'h4,i_chunk_mode_active,2'b00,16'd0},32'h54563355};
					//blockid
					1		: data_reg	<= {17'b0,blockid_low47_roi};
					//{valid_payload_size[31:0],{reserved,status}} statusΪ0��valid_payload_sizeΪÿ��roi��chunk_size_img
					2		: data_reg	<= {valid_payload_size_mroi[roi_num_cnt],{16'h00,16'b0}}	;
					//{size_y,valid_payload_size[63:32]}
					3		: data_reg	<= {{16'h00,per_trailer_size_y_mroi[roi_num_cnt]},32'h0};
					//{dummy_word_by_dh,chunk_layout_id} chunk_layout_idΪ0 dummy_word_by_dh��dh�Լ���ӵ����ݣ�Ϊ�����8byte�Ŀռ�
					4		: data_reg	<= {32'h0,{24'h0,chunk_layout_id}};
					default	: data_reg	<= {32'h0,32'h0};
				endcase
			end

			S_CHUNK: begin
				case(per_roi_cnt)
					//image id length
					0		: data_reg	<= {per_chunk_size_img_mroi[roi_num_cnt],32'h1};
					//frameid
					1		: data_reg	<= {17'b0,blockid_low47_roi[46:0]};
					//frameid id length
					2		: data_reg	<= {FID_LENTH,32'h2};
					//timestamp
					3		: data_reg	<= iv_timestamp[63:0];
					//timestamp id length
					4		: data_reg	<= {TS_LENTH,32'h3};
					default	: data_reg	<= {32'h0,32'h0};
					//				default	: data_reg	<= iv_data;
				endcase
			end

			S_IMAGE: begin
				data_reg <= iv_data;
			end

			S_F_TRAILER: begin
				case(per_roi_cnt)
					//{{trailer_size,reserved},magic_key}=={{trailer_size,0},TV3U} //����ʹ��λ����һ��ƴ�ӣ���i_chunk_mode_activeʹ�ܣ�����Ϊ36������Ϊ32
					0		: data_reg	<= {{13'h4,i_chunk_mode_active,2'b00,16'd0},32'h54563355};
					//blockid
					1		: data_reg	<= {17'b0,(blockid_low47_acc - 1)};//blockid_low47_acc���������һ֡�ĵ�һ����Чroi��blockid�����Ǳ�֡�����һ����Чroi��blokcidӦ��1
					//{valid_payload_size[31:0],{reserved,status}} status-����ֻ֧��Image��0x0001����Image Extended Chunk��0x4001��
					2		: data_reg	<= {valid_payload_size,{16'h00,status}};
					//{size_y,valid_payloasd_size[63:32]}
					3		: data_reg	<= {{16'h00,per_trailer_size_y_mroi[last_roi_num]},32'h0};
					//{dummy_word_by_dh,chunk_layout_id} chunk_layout_idΪ0 dummy_word_by_dh��dh�Լ���ӵ����ݣ�Ϊ�����8byte�Ŀռ�
					4		: data_reg	<= {32'h0,{24'h0,chunk_layout_id}};
					default	: data_reg	<= {32'h0,32'h0};
				endcase
			end

			default: begin
				data_reg <= 'b0;
			end
		endcase
	end

	assign ov_data = data_reg;

	// --ref o_fval
	always @ (posedge clk) begin
		if(current_state == S_TIMESTAMP) begin
			fval_reg <= 1'b1;
		end
		else if(current_state == S_IDLE) begin
			fval_reg <= 1'b0;
		end
	end
	assign o_fval = fval_reg;

	// --ref o_leader_flag / o_image_flag / o_chunk_flag / o_trailer_flag / o_trailer_final_flag
	always @ (posedge clk) begin
		if(current_state == S_LEADER) begin
			leader_flag_reg <= 1'b1;
		end
		else begin
			leader_flag_reg <= 1'b0;
		end
	end
	assign o_leader_flag = leader_flag_reg;

	always @ (posedge clk) begin
		if(current_state == S_IMAGE) begin
			image_flag_reg <= 1'b1;
		end
		else begin
			image_flag_reg <= 1'b0;
		end
	end
	assign o_image_flag = image_flag_reg;

	always @ (posedge clk) begin
		if(current_state == S_TRAILER) begin
			trailer_flag_reg <= 1'b1;
		end
		else begin
			trailer_flag_reg <= 1'b0;
		end
	end
	assign o_trailer_flag = trailer_flag_reg;

	always @ (posedge clk) begin
		if(current_state == S_CHUNK) begin
			chunk_flag_reg <= 1'b1;
		end
		else begin
			chunk_flag_reg <= 1'b0;
		end
	end
	assign o_chunk_flag = chunk_flag_reg;

	always @ (posedge clk) begin
		if(current_state == S_F_TRAILER) begin
			trailer_final_flag_reg <= 1'b1;
		end
		else begin
			trailer_final_flag_reg <= 1'b0;
		end
	end
	assign o_trailer_final_flag = trailer_final_flag_reg;

endmodule