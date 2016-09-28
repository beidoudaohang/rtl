//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : gpif_reg_list
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/3/5 15:39:34	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : gpifʱ����ļĴ����б�
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

module gpif_reg_list # (
	parameter		SPI_ADDR_LENGTH			= 16	,	//spi ��ַ�ĳ���
	parameter		SHORT_REG_WD			= 16	,	//�̼Ĵ���λ��
	parameter		REG_WD					= 32	,	//�Ĵ���λ��
	parameter		LONG_REG_WD				= 64	,	//���Ĵ���λ��
	parameter		REG_INIT_VALUE			= "TRUE"	//�Ĵ����Ƿ��г�ʼֵ
	)
	(
	//  ===============================================================================================
	//	�����ź�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spiʱ����
	//  -------------------------------------------------------------------------------------
	input								i_wr_en					,	//дʹ��
	input								i_rd_en					,	//��ʹ��
	input								i_cmd_is_rd				,	//����������
	input	[SPI_ADDR_LENGTH-1:0]		iv_addr					,	//��д��ַ
	input	[SHORT_REG_WD-1:0]			iv_wr_data				,	//д����
	//  -------------------------------------------------------------------------------------
	//	gpif ʱ����
	//  -------------------------------------------------------------------------------------
	input								clk_gpif				,	//gpif ʱ�ӣ�100MHz
	output								o_gpif_sel				,	//gpif ʱ����ѡ��
	output	[SHORT_REG_WD-1:0]			ov_gpif_rd_data			,	//������

	//  ===============================================================================================
	//	���������ǼĴ���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ͨ��
	//  -------------------------------------------------------------------------------------
	output								o_stream_enable_gpif				,	//clk_gpifʱ������ʹ���ź�
	//  -------------------------------------------------------------------------------------
	//	u3 interface
	//  -------------------------------------------------------------------------------------
	output	[REG_WD-1:0]				ov_si_payload_transfer_size			,	//clk_gpifʱ���򣬵������ݿ��С
	output	[REG_WD-1:0]				ov_si_payload_transfer_count		,	//clk_gpifʱ���򣬵������ݿ����
	output	[REG_WD-1:0]				ov_si_payload_final_transfer1_size	,	//clk_gpifʱ����transfer1��С
	output	[REG_WD-1:0]				ov_si_payload_final_transfer2_size	,	//clk_gpifʱ����transfer2��С
	output	[REG_WD-1:0]				ov_payload_size_gpif				,	//clk_gpifʱ�������ݵĴ�С��������ͷ��β����Э��Ҫ��64bit������ֻ����32bit���ɣ���32bit��0
	output								o_chunk_mode_active_gpif				//clk_gpifʱ����chunk���ؼĴ���
	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	�̶�����
	//	2592*1944�ķֱ���
	//	-------------------------------------------------------------------------------------
	//	localparam	INIT_VALUE_SE				= (REG_INIT_VALUE=="TRUE") ? 1'b1 : 1'b0;
	localparam	INIT_VALUE_SE				= 1'b0;
	localparam	INIT_VALUE_PAYLOAD_SIZE_3	= (REG_INIT_VALUE=="TRUE") ? 16'h004c : {SHORT_REG_WD{1'b0}};
	localparam	INIT_VALUE_PAYLOAD_SIZE_4	= (REG_INIT_VALUE=="TRUE") ? 16'he300 : {SHORT_REG_WD{1'b0}};
	localparam	INIT_VALUE_TRANSFER_SIZE_H	= (REG_INIT_VALUE=="TRUE") ? 16'h0010 : {SHORT_REG_WD{1'b0}};
	localparam	INIT_VALUE_TRANSFER_SIZE_L	= (REG_INIT_VALUE=="TRUE") ? 16'h0000 : {SHORT_REG_WD{1'b0}};
	localparam	INIT_VALUE_TRANSFER_COUNT_H	= (REG_INIT_VALUE=="TRUE") ? 16'h0000 : {SHORT_REG_WD{1'b0}};
	localparam	INIT_VALUE_TRANSFER_COUNT_L	= (REG_INIT_VALUE=="TRUE") ? 16'h0004 : {SHORT_REG_WD{1'b0}};
	localparam	INIT_VALUE_TRANSFER1_SIZE_H	= (REG_INIT_VALUE=="TRUE") ? 16'h000C : {SHORT_REG_WD{1'b0}};
	localparam	INIT_VALUE_TRANSFER1_SIZE_L	= (REG_INIT_VALUE=="TRUE") ? 16'hE000 : {SHORT_REG_WD{1'b0}};
	localparam	INIT_VALUE_TRANSFER2_SIZE_H	= (REG_INIT_VALUE=="TRUE") ? 16'h0000 : {SHORT_REG_WD{1'b0}};
	localparam	INIT_VALUE_TRANSFER2_SIZE_L	= (REG_INIT_VALUE=="TRUE") ? 16'h0400 : {SHORT_REG_WD{1'b0}};


	//  ===============================================================================================
	//	���ƼĴ���
	//  ===============================================================================================
	reg		[2:0]					wr_en_shift							= 3'b0;
	wire							wr_en_rise							;
	reg		[SHORT_REG_WD:0]		data_out_reg						= {(SHORT_REG_WD+1){1'b0}};

	//  ===============================================================================================
	//	���������ǼĴ���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ͨ��
	//  -------------------------------------------------------------------------------------
	reg								param_cfg_done							= 1'b0;
	reg								stream_enable_gpif						= INIT_VALUE_SE;
	//  -------------------------------------------------------------------------------------
	//	u3 interface
	//  -------------------------------------------------------------------------------------
	reg		[SHORT_REG_WD-1:0]		si_payload_transfer_size_h				= INIT_VALUE_TRANSFER_SIZE_H;
	reg		[SHORT_REG_WD-1:0]		si_payload_transfer_size_h_group		= INIT_VALUE_TRANSFER_SIZE_H;
	reg		[SHORT_REG_WD-1:0]		si_payload_transfer_size_l				= INIT_VALUE_TRANSFER_SIZE_L;
	reg		[SHORT_REG_WD-1:0]		si_payload_transfer_size_l_group		= INIT_VALUE_TRANSFER_SIZE_L;
	reg		[SHORT_REG_WD-1:0]		si_payload_transfer_count_h				= INIT_VALUE_TRANSFER_COUNT_H;
	reg		[SHORT_REG_WD-1:0]		si_payload_transfer_count_h_group		= INIT_VALUE_TRANSFER_COUNT_H;
	reg		[SHORT_REG_WD-1:0]		si_payload_transfer_count_l				= INIT_VALUE_TRANSFER_COUNT_L;
	reg		[SHORT_REG_WD-1:0]		si_payload_transfer_count_l_group		= INIT_VALUE_TRANSFER_COUNT_L;
	reg		[SHORT_REG_WD-1:0]		si_payload_final_transfer1_size_h		= INIT_VALUE_TRANSFER1_SIZE_H;
	reg		[SHORT_REG_WD-1:0]		si_payload_final_transfer1_size_h_group	= INIT_VALUE_TRANSFER1_SIZE_H;
	reg		[SHORT_REG_WD-1:0]		si_payload_final_transfer1_size_l		= INIT_VALUE_TRANSFER1_SIZE_L;
	reg		[SHORT_REG_WD-1:0]		si_payload_final_transfer1_size_l_group	= INIT_VALUE_TRANSFER1_SIZE_L;
	reg		[SHORT_REG_WD-1:0]		si_payload_final_transfer2_size_h		= INIT_VALUE_TRANSFER2_SIZE_H;
	reg		[SHORT_REG_WD-1:0]		si_payload_final_transfer2_size_h_group	= INIT_VALUE_TRANSFER2_SIZE_H;
	reg		[SHORT_REG_WD-1:0]		si_payload_final_transfer2_size_l		= INIT_VALUE_TRANSFER2_SIZE_L;
	reg		[SHORT_REG_WD-1:0]		si_payload_final_transfer2_size_l_group	= INIT_VALUE_TRANSFER2_SIZE_L;
	reg		[SHORT_REG_WD-1:0]		payload_size_3							= INIT_VALUE_PAYLOAD_SIZE_3;
	reg		[SHORT_REG_WD-1:0]		payload_size_3_group					= INIT_VALUE_PAYLOAD_SIZE_3;
	reg		[SHORT_REG_WD-1:0]		payload_size_4							= INIT_VALUE_PAYLOAD_SIZE_4;
	reg		[SHORT_REG_WD-1:0]		payload_size_4_group					= INIT_VALUE_PAYLOAD_SIZE_4;
	reg								chunk_mode_active						= 1'b0;

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	-- ref ***д����***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref д��صļĴ���
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	��pix ʱ����ȡд�źŵ�������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_gpif) begin
		wr_en_shift	<= {wr_en_shift[1:0],i_wr_en};
	end
	assign	wr_en_rise	= (wr_en_shift[2:1]==2'b01) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	-- ref д���̼Ĵ�������
	//	�� wr_en_rise ��ʱ��iv_addr�Ѿ��ȶ�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_gpif) begin
		if(wr_en_rise) begin
			case(iv_addr[8:0])
				//  -------------------------------------------------------------------------------------
				//	ͨ��
				//  -------------------------------------------------------------------------------------
				9'h20	: param_cfg_done					<= iv_wr_data[0];
				9'h30	: stream_enable_gpif				<= iv_wr_data[0];
				//  -------------------------------------------------------------------------------------
				//	u3 interface
				//  -------------------------------------------------------------------------------------
				9'hb4	: si_payload_transfer_size_h		<= iv_wr_data[SHORT_REG_WD-1:0];
				9'hb5	: si_payload_transfer_size_l		<= iv_wr_data[SHORT_REG_WD-1:0];
				9'hb6	: si_payload_transfer_count_h		<= iv_wr_data[SHORT_REG_WD-1:0];
				9'hb7	: si_payload_transfer_count_l		<= iv_wr_data[SHORT_REG_WD-1:0];
				9'hb8	: si_payload_final_transfer1_size_h	<= iv_wr_data[SHORT_REG_WD-1:0];
				9'hb9	: si_payload_final_transfer1_size_l	<= iv_wr_data[SHORT_REG_WD-1:0];
				9'hba	: si_payload_final_transfer2_size_h	<= iv_wr_data[SHORT_REG_WD-1:0];
				9'hbb	: si_payload_final_transfer2_size_l	<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h37	: payload_size_3					<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h38	: payload_size_4					<= iv_wr_data[SHORT_REG_WD-1:0];
				9'ha0	: chunk_mode_active					<= iv_wr_data[0];
				default : ;
			endcase
		end
		else begin
			//������Ĵ���
			param_cfg_done	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	-- ref ������Ч
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	�����С������Ч
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_gpif) begin
		if(param_cfg_done) begin
			payload_size_3_group	<= payload_size_3;
			payload_size_4_group	<= payload_size_4;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	SI transfer ������Ч
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_gpif) begin
		if(param_cfg_done) begin
			si_payload_transfer_size_h_group	<= si_payload_transfer_size_h;
			si_payload_transfer_size_l_group	<= si_payload_transfer_size_l;
			si_payload_transfer_count_h_group	<= si_payload_transfer_count_h;
			si_payload_transfer_count_l_group	<= si_payload_transfer_count_l;
			si_payload_final_transfer1_size_h_group	<= si_payload_final_transfer1_size_h;
			si_payload_final_transfer1_size_l_group	<= si_payload_final_transfer1_size_l;
			si_payload_final_transfer2_size_h_group	<= si_payload_final_transfer2_size_h;
			si_payload_final_transfer2_size_l_group	<= si_payload_final_transfer2_size_l;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	-- ref ���
	//  -------------------------------------------------------------------------------------
	assign	o_stream_enable_gpif		= stream_enable_gpif;
	//  -------------------------------------------------------------------------------------
	//	u3 interface
	//  -------------------------------------------------------------------------------------
	assign	ov_si_payload_transfer_size			= {si_payload_transfer_size_h_group,si_payload_transfer_size_l_group};
	assign	ov_si_payload_transfer_count		= {si_payload_transfer_count_h_group,si_payload_transfer_count_l_group};
	assign	ov_si_payload_final_transfer1_size	= {si_payload_final_transfer1_size_h_group,si_payload_final_transfer1_size_l_group};
	assign	ov_si_payload_final_transfer2_size	= {si_payload_final_transfer2_size_h_group,si_payload_final_transfer2_size_l_group};
	assign	ov_payload_size_gpif				= {payload_size_3_group,payload_size_4_group};
	assign	o_chunk_mode_active_gpif			= chunk_mode_active;
	//  ===============================================================================================
	//	ref ***������***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref �����̼Ĵ�������
	//	��, data_out_reg ���bit˵���Ƿ�ѡ���˸�ʱ������������Ϊ�Ĵ�������
	//	�������Ǵ��첽�߼���i_rd_en iv_addr �����첽�źţ������ź��ȶ�֮�����Ҳ�ͻ��ȶ�
	//  -------------------------------------------------------------------------------------
	always @ ( * ) begin
		//������ַѡ�е�ʱ��sel����Ϊ��Ч
		if(i_rd_en) begin
			case(iv_addr[8:0])
				//  -------------------------------------------------------------------------------------
				//	ͨ��
				//  -------------------------------------------------------------------------------------
				//				9'h20	: data_out_reg		<= {1'b1,{(SHORT_REG_WD-1){1'b0}},param_cfg_done};	//pix ʱ�����Ѿ�����
				//				9'h30	: data_out_reg		<= {1'b1,{(SHORT_REG_WD-1){1'b0}},stream_enable_gpif};	//pix ʱ�����Ѿ�����
				//  -------------------------------------------------------------------------------------
				//	u3 interface
				//  -------------------------------------------------------------------------------------
				//read write
				9'hb4	: data_out_reg		<= {1'b1,si_payload_transfer_size_h[SHORT_REG_WD-1:0]};
				9'hb5	: data_out_reg		<= {1'b1,si_payload_transfer_size_l[SHORT_REG_WD-1:0]};
				9'hb6	: data_out_reg		<= {1'b1,si_payload_transfer_count_h[SHORT_REG_WD-1:0]};
				9'hb7	: data_out_reg		<= {1'b1,si_payload_transfer_count_l[SHORT_REG_WD-1:0]};
				9'hb8	: data_out_reg		<= {1'b1,si_payload_final_transfer1_size_h[SHORT_REG_WD-1:0]};
				9'hb9	: data_out_reg		<= {1'b1,si_payload_final_transfer1_size_l[SHORT_REG_WD-1:0]};
				9'hba	: data_out_reg		<= {1'b1,si_payload_final_transfer2_size_h[SHORT_REG_WD-1:0]};
				9'hbb	: data_out_reg		<= {1'b1,si_payload_final_transfer2_size_l[SHORT_REG_WD-1:0]};

				//				9'h35	: data_out_reg		<= {1'b1,{SHORT_REG_WD{1'b0}}};	//payload_size1	//pix ʱ�����Ѿ�����
				//				9'h36	: data_out_reg		<= {1'b1,{SHORT_REG_WD{1'b0}}};	//payload_size2	//pix ʱ�����Ѿ�����
				//				9'h37	: data_out_reg		<= {1'b1,payload_size_3[SHORT_REG_WD-1:0]};	//pix ʱ�����Ѿ�����
				//				9'h38	: data_out_reg		<= {1'b1,payload_size_4[SHORT_REG_WD-1:0]};	//pix ʱ�����Ѿ�����
				//				9'ha0	: data_out_reg		<= {1'b1,{(SHORT_REG_WD-1){1'b0}},chunk_mode_active};	//frame_buf ʱ�����Ѿ�����

				default	: data_out_reg		<= {(SHORT_REG_WD+1){1'b0}};

			endcase
		end
		//����ʹ��ȡ����ʱ��sel���ܸ�λΪ0
		else begin
			data_out_reg	<= {(SHORT_REG_WD+1){1'b0}};
		end
	end
	assign	o_gpif_sel		= data_out_reg[SHORT_REG_WD];
	assign	ov_gpif_rd_data	= data_out_reg[SHORT_REG_WD-1:0];

endmodule