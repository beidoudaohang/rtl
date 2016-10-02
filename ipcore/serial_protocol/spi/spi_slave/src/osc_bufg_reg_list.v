//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : osc_bufg_reg_list
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/3/6 10:54:03	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : osc bufg ʱ����ļĴ����б�
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

module osc_bufg_reg_list # (
	parameter		SPI_ADDR_LENGTH			= 16	,	//spi ��ַ�ĳ���
	parameter		SHORT_REG_WD			= 16	,	//�̼Ĵ���λ��
	parameter		REG_WD					= 32	,	//�Ĵ���λ��
	parameter		LONG_REG_WD				= 64		//���Ĵ���λ��
	)
	(
	//  ===============================================================================================
	//	�����ź�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spiʱ����
	//  -------------------------------------------------------------------------------------
	input								i_wr_en					,	//дʹ�ܣ�clk_sampleʱ����
	input								i_rd_en					,	//��ʹ�ܣ�clk_sampleʱ����
	input								i_cmd_is_rd				,	//���������ˣ�clk_sampleʱ����
	input	[SPI_ADDR_LENGTH-1:0]		iv_addr					,	//��д��ַ��clk_sampleʱ����
	input	[SHORT_REG_WD-1:0]			iv_wr_data				,	//д���ݣ�clk_sampleʱ����
	//  -------------------------------------------------------------------------------------
	//	40MHz ʱ����
	//  -------------------------------------------------------------------------------------
	input								clk_osc_bufg			,	//osc bufg ʱ�ӣ�40MHz
	output								o_osc_bufg_sel			,	//osc bufg ʱ����ѡ��
	output	[SHORT_REG_WD-1:0]			ov_osc_bufg_rd_data		,	//������

	//  ===============================================================================================
	//	���������ǼĴ���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	clk reset top
	//  -------------------------------------------------------------------------------------
	output								o_reset_sensor		,	//clk_osc_bufgʱ���򣬸�λSensor�Ĵ���
	//  -------------------------------------------------------------------------------------
	//	ʱ��� 40MHz ʱ����
	//  -------------------------------------------------------------------------------------
	output								o_timestamp_load	,	//clk_osc_bufgʱ����ʱ��������źţ�������
	input	[LONG_REG_WD-1:0]			iv_timestamp		,	//clk_osc_bufgʱ����ʱ���
	//  -------------------------------------------------------------------------------------
	//	DNA 1MHz ʱ����
	//  -------------------------------------------------------------------------------------
	input	[LONG_REG_WD-1:0]			iv_dna_reg			,	//clk_osc_bufgʱ����dna����
	output	[LONG_REG_WD-1:0]			ov_encrypt_reg		,	//clk_osc_bufgʱ���򣬹̼����õļ���ֵ
	input								i_encrypt_state			//clk_dnaʱ���򣬼���״̬
	);

	//	ref signals

	//  ===============================================================================================
	//	���ƼĴ���
	//  ===============================================================================================
	reg		[2:0]						wr_en_shift		= 3'b0;
	wire								wr_en_rise		;
	reg		[SHORT_REG_WD:0]			data_out_reg	= {(SHORT_REG_WD+1){1'b0}};

	//  ===============================================================================================
	//	���������ǼĴ���
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ͨ��
	//  -------------------------------------------------------------------------------------
	reg									param_cfg_done	= 1'b0;
	//  -------------------------------------------------------------------------------------
	//	clk reset top
	//  -------------------------------------------------------------------------------------
	reg									reset_sensor	= 1'b0;
	//  -------------------------------------------------------------------------------------
	//	ʱ��� 40MHz ʱ����
	//  -------------------------------------------------------------------------------------
	reg									timestamp_load	= 1'b0;
	//  -------------------------------------------------------------------------------------
	//	DNA 1MHz ʱ����
	//  -------------------------------------------------------------------------------------
	reg		[SHORT_REG_WD-1:0]			encrypt_reg1		= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			encrypt_reg1_group	= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			encrypt_reg2		= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			encrypt_reg2_group	= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			encrypt_reg3		= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			encrypt_reg3_group	= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			encrypt_reg4		= {SHORT_REG_WD{1'b0}};
	reg		[SHORT_REG_WD-1:0]			encrypt_reg4_group	= {SHORT_REG_WD{1'b0}};

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***д����***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref д��صļĴ���
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	��pix ʱ����ȡд�źŵ�������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_osc_bufg) begin
		wr_en_shift	<= {wr_en_shift[1:0],i_wr_en};
	end
	assign	wr_en_rise	= (wr_en_shift[2:1]==2'b01) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	-- ref д���̼Ĵ�������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_osc_bufg) begin
		if(wr_en_rise) begin
			case(iv_addr[8:0])
				//  -------------------------------------------------------------------------------------
				//	ͨ��
				//  -------------------------------------------------------------------------------------
				9'h20	: param_cfg_done	<= iv_wr_data[0];
				//  -------------------------------------------------------------------------------------
				//	clk reset top
				//  -------------------------------------------------------------------------------------
				9'h3a	: reset_sensor		<= iv_wr_data[0];
				//  -------------------------------------------------------------------------------------
				//	ʱ��� 40MHz ʱ����
				//  -------------------------------------------------------------------------------------
				9'hd0	: timestamp_load	<= iv_wr_data[0];
				//  -------------------------------------------------------------------------------------
				//	DNA 1MHz ʱ����
				//  -------------------------------------------------------------------------------------
				9'h164	: encrypt_reg1		<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h165	: encrypt_reg2		<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h166	: encrypt_reg3		<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h167	: encrypt_reg4		<= iv_wr_data[SHORT_REG_WD-1:0];

				default : ;
			endcase
		end
		else begin
			//������Ĵ���
			param_cfg_done	<= 1'b0;
			reset_sensor	<= 1'b0;
			timestamp_load	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	-- ref ������Ч
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	���ܼĴ��������Ч
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_osc_bufg) begin
		if(param_cfg_done) begin
			encrypt_reg1_group	<= encrypt_reg1;
			encrypt_reg2_group	<= encrypt_reg2;
			encrypt_reg3_group	<= encrypt_reg3;
			encrypt_reg4_group	<= encrypt_reg4;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	-- ref ���
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	clk reset top
	//  -------------------------------------------------------------------------------------
	assign	o_reset_sensor		= reset_sensor;
	//  -------------------------------------------------------------------------------------
	//	ʱ��� 40MHz ʱ����
	//  -------------------------------------------------------------------------------------
	assign	o_timestamp_load	= timestamp_load;
	//  -------------------------------------------------------------------------------------
	//	DNA 1MHz ʱ����
	//  -------------------------------------------------------------------------------------
	assign	ov_encrypt_reg		= {encrypt_reg1_group,encrypt_reg2_group,encrypt_reg3_group,encrypt_reg4_group};

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
				//				9'h20	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},param_cfg_done};	//pix ʱ�����Ѿ�����
				
				//  -------------------------------------------------------------------------------------
				//	clk reset top
				//  -------------------------------------------------------------------------------------
				//read write
				9'h3a	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},reset_sensor};
				//  -------------------------------------------------------------------------------------
				//	ʱ��� 40MHz ʱ����
				//  -------------------------------------------------------------------------------------
				//read write
				9'hd0	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},timestamp_load};

				//read only
				9'hd1	: data_out_reg	<= {1'b1,iv_timestamp[LONG_REG_WD-1:LONG_REG_WD-SHORT_REG_WD]};
				9'hd2	: data_out_reg	<= {1'b1,iv_timestamp[LONG_REG_WD-SHORT_REG_WD-1:LONG_REG_WD-REG_WD]};
				9'hd3	: data_out_reg	<= {1'b1,iv_timestamp[REG_WD-1:REG_WD-SHORT_REG_WD]};
				9'hd4	: data_out_reg	<= {1'b1,iv_timestamp[SHORT_REG_WD-1:0]};

				//  -------------------------------------------------------------------------------------
				//	DNA 1MHz ʱ����
				//  -------------------------------------------------------------------------------------
				//read write
				9'h164	: data_out_reg	<= {1'b1,encrypt_reg1[SHORT_REG_WD-1:0]};
				9'h165	: data_out_reg	<= {1'b1,encrypt_reg2[SHORT_REG_WD-1:0]};
				9'h166	: data_out_reg	<= {1'b1,encrypt_reg3[SHORT_REG_WD-1:0]};
				9'h167	: data_out_reg	<= {1'b1,encrypt_reg4[SHORT_REG_WD-1:0]};

				//read only
				9'h160	: data_out_reg	<= {1'b1,iv_dna_reg[LONG_REG_WD-1:LONG_REG_WD-SHORT_REG_WD]};
				9'h161	: data_out_reg	<= {1'b1,iv_dna_reg[LONG_REG_WD-SHORT_REG_WD-1:LONG_REG_WD-REG_WD]};
				9'h162	: data_out_reg	<= {1'b1,iv_dna_reg[REG_WD-1:REG_WD-SHORT_REG_WD]};
				9'h163	: data_out_reg	<= {1'b1,iv_dna_reg[SHORT_REG_WD-1:0]};
				9'h168	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},i_encrypt_state};

				default	: data_out_reg	<= {(SHORT_REG_WD+1){1'b0}};

			endcase
		end
		//����ʹ��ȡ����ʱ��sel���ܸ�λΪ0
		else begin
			data_out_reg	<= {(SHORT_REG_WD+1){1'b0}};
		end
	end
	assign	o_osc_bufg_sel		= data_out_reg[SHORT_REG_WD];
	assign	ov_osc_bufg_rd_data	= data_out_reg[SHORT_REG_WD-1:0];

	//  ===============================================================================================
	//	-- ref ֻ���Ĵ�����latch
	//	�ڶ�֮ǰ�������е�ֻ���Ĵ�����һ�ģ�����������
	//  ===============================================================================================
	//	iv_timestamp �ڶ�֮ǰ�Ѿ���������һ�Σ�iv_dna_reg��i_encrypt_state ����ı䡣�������Ĵ��������Կ����ǹ̶���������������
	
	
endmodule