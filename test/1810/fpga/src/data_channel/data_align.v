//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : data_align
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/12/5 15:44:31	:|  ��ʼ�汾
//	-- ������		:| 2015/9/1 13:52:59	:|	���˵��
//	-- ������		:| 2015/11/10 11:31:04	:|	֧��Դ����modelsim����
//	-- ������		:| 2015/12/8 16:37:58	:|	��߿�֧�ְ�ͨ����128bit����ƴ��
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : ����ƴ��ģ��
//              1)  : ����pixel format������λ��ѡ��ƴ�ӷ�ʽ�����λ��̶�Ϊ64bit
//
//              2)  : ���pixel format������λ����8bit��ѡ���������ݵĸ�8bit��ÿ4������ƴ��Ϊ1��32bit���ݣ��ȵ��������ݷ��ڵ�λ
//
//              3)  : ���pixel format������λ����10bit��ѡ���������ݸ�10bit��ÿ2������ƴ��Ϊ1��32bit���ݣ��ȵ��������ݷ��ڵ�λ
//
//              4)  : �ݲ�֧��8ͨ��
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module data_align # (
	parameter	SENSOR_DAT_WIDTH	= 10	,	//sensor ���ݿ��
	parameter	CHANNEL_NUM			= 8		,	//sensor ͨ������
	parameter	REG_WD				= 32	,	//�Ĵ���λ��
	parameter	DATA_WD				= 128		//�����������λ������ʹ��ͬһ���
	)
	(
	//Sensor�����ź�
	input										clk				,	//����ʱ��
	input										i_fval			,	//���ź�
	input										i_lval			,	//���ź�
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	iv_pix_data		,	//ͼ������
	//�Ҷ�ͳ����ؼĴ���
	input	[REG_WD-1:0]						iv_pixel_format	,	//���ظ�ʽ�Ĵ�����0x01080001:Mono8��0x01100003:Mono10��0x01080008:BayerGR8��0x0110000C:BayerGR10
	//���
	output										o_fval			,	//����Ч
	output										o_pix_data_en	,	//������Ч�źţ�����ƴ��֮���ʹ���źţ��൱��ʱ�ӵ�2��Ƶ����4��Ƶ
	output	[DATA_WD-1:0]						ov_pix_data			//ͼ������
	);

	//	ref signals

	//LOG2����
	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction
	//��ͨ������ȡ����
	localparam									DATAEN_8B		= DATA_WD/(8*CHANNEL_NUM);
	localparam									REDUCE_8B		= log2(DATAEN_8B);

	localparam									DATAEN_10B		= DATA_WD/(16*CHANNEL_NUM);
	localparam									REDUCE_10B		= log2(DATAEN_10B);

	reg											format8_sel		= 1'b0;
	reg		[DATA_WD-1:0]						pix_data_shift	= {DATA_WD{1'b0}};
	reg		[DATA_WD-1:0]						pix_data_reg	= {DATA_WD{1'b0}};
	reg		[3:0]								pix_cnt			= 3'b0;
	reg											data_en			= 1'b0;
	reg											data_en_dly		= 1'b0;
	reg											fval_dly0		= 1'b0;
	reg											fval_dly1		= 1'b0;

	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref ***�ж����ݸ�ʽ***
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	USB3 Vision 	version 1.0.1	March, 2015
	//	table 5-14: Recommended Pixel Formats
	//
	//	Mono1p			0x01010037
	//	Mono2p			0x01020038
	//	Mono4p			0x01040039
	//	Mono8			0x01080001
	//	Mono10			0x01100003
	//	Mono10p			0x010a0046
	//	Mono12			0x01100005
	//	Mono12p			0x010c0047
	//	Mono14			0x01100025
	//	Mono16			0x01100007
	//
	//	BayerGR8		0x01080008
	//	BayerGR10		0x0110000C
	//	BayerGR10p		0x010A0056
	//	BayerGR12		0x01100010
	//	BayerGR12p		0x010C0057
	//	BayerGR16		0x0110002E
	//
	//	BayerRG8		0x01080009
	//	BayerRG10		0x0110000D
	//	BayerRG10p		0x010A0058
	//	BayerRG12		0x01100011
	//	BayerRG12p		0x010C0059
	//	BayerRG16		0x0110002F
	//
	//	BayerGB8		0x0108000A
	//	BayerGB10		0x0110000E
	//	BayerGB10p		0x010A0054
	//	BayerGB12		0x01100012
	//	BayerGB12p		0x010C0055
	//	BayerGB16		0x01100030
	//
	//	BayerBG8		0x0108000B
	//	BayerBG10		0x0110000F
	//	BayerBG10p		0x010A0052
	//	BayerBG12		0x01100013
	//	BayerBG12p		0x010C0053
	//	BayerBG16		0x01100031

	//	BGR8			0x02180015
	//	BGR10			0x02300019
	//	BGR10p			0x021E0048
	//	BGR12			0x0230001B
	//	BGR12p			0x02240049
	//	BGR14			0x0230004A
	//	BGR16			0x0230004B

	//	BGRa8			0x02200017
	//	BGRa10			0x0240004C
	//	BGRa10p			0x0228004D
	//	BGRa12			0x0240004E
	//	BGRa12p			0x0230004F
	//	BGRa14			0x02400050
	//	BGRa16			0x02400051
	//
	//	YCbCr8			0x0218005B
	//	YCbCr422_8		0x0210003B
	//	YCbCr411_8		0x020C005A
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	format8_sel
	//	1.�ж����ظ�ʽ�Ƿ�ѡ��8bit���ظ�ʽ
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case (iv_pixel_format[6:0])
			7'h01		: format8_sel	<= 1'b1;
			7'h08		: format8_sel	<= 1'b1;
			7'h09		: format8_sel	<= 1'b1;
			7'h0A		: format8_sel	<= 1'b1;
			7'h0B		: format8_sel	<= 1'b1;
			7'h15		: format8_sel	<= 1'b1;
			7'h17		: format8_sel	<= 1'b1;
			7'h5B		: format8_sel	<= 1'b1;
			7'h3B		: format8_sel	<= 1'b1;
			7'h5A		: format8_sel	<= 1'b1;
			default		: format8_sel	<= 1'b0;
		endcase
	end

	//  ===============================================================================================
	//	ref ***������λ***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	������λ�Ĵ���
	//	1.��������ʱ����λ�Ĵ�������
	//	2.������Ч������Чʱ��������ظ�ʽ��8bit��ÿ������ռ��1��byte��ֻȡ���صĸ�8bit
	//	3.������Ч������Чʱ��������ظ�ʽ��10bit��ÿ������ռ��2��byte����ֻȡ���صĸ�10bit����λ���0
	//	4.������λ�Ĵ���λ��-64bit
	//	5.10BIT��ʽ�ݲ�֧��8ͨ��
	//  -------------------------------------------------------------------------------------
	generate
		if (CHANNEL_NUM == 1) begin
			always @ (posedge clk) begin
				if(!i_fval) begin
					pix_data_shift	<= {DATA_WD{1'b0}};
				end
				else begin
					if(i_lval) begin
						if(format8_sel) begin
							pix_data_shift	<= {iv_pix_data[SENSOR_DAT_WIDTH-1:SENSOR_DAT_WIDTH-8],pix_data_shift[DATA_WD-1:8]};
						end
						else begin
							pix_data_shift	<= {{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[SENSOR_DAT_WIDTH-1:0],pix_data_shift[DATA_WD-1:16]};
						end
					end
				end
			end
		end
		else if (CHANNEL_NUM == 2) begin
			always @ (posedge clk) begin
				if(!i_fval) begin
					pix_data_shift	<= {DATA_WD{1'b0}};
				end
				else begin
					if(i_lval) begin
						if(format8_sel) begin
							pix_data_shift	<= {iv_pix_data[2*SENSOR_DAT_WIDTH-1:2*SENSOR_DAT_WIDTH-8],iv_pix_data[SENSOR_DAT_WIDTH-1:SENSOR_DAT_WIDTH-8],
												pix_data_shift[DATA_WD-1:16]};
						end
						else begin
							pix_data_shift	<= {{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[2*SENSOR_DAT_WIDTH-1:SENSOR_DAT_WIDTH],{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[SENSOR_DAT_WIDTH-1:0],
												pix_data_shift[DATA_WD-1:32]};
						end
					end
				end
			end
		end
		else if (CHANNEL_NUM == 4) begin
			always @ (posedge clk) begin
				if(!i_fval) begin
					pix_data_shift	<= {DATA_WD{1'b0}};
				end
				else begin
					if(i_lval) begin
						if(format8_sel) begin
							pix_data_shift	<= {iv_pix_data[4*SENSOR_DAT_WIDTH-1:4*SENSOR_DAT_WIDTH-8],iv_pix_data[3*SENSOR_DAT_WIDTH-1:3*SENSOR_DAT_WIDTH-8],
												iv_pix_data[2*SENSOR_DAT_WIDTH-1:2*SENSOR_DAT_WIDTH-8],iv_pix_data[SENSOR_DAT_WIDTH-1:SENSOR_DAT_WIDTH-8],
												pix_data_shift[DATA_WD-1:32]};
						end
						else begin
							pix_data_shift	<= {{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[4*SENSOR_DAT_WIDTH-1:3*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[3*SENSOR_DAT_WIDTH-1:2*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[2*SENSOR_DAT_WIDTH-1:SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[SENSOR_DAT_WIDTH-1:0],
												pix_data_shift[DATA_WD-1:64]};
						end
					end
				end
			end
		end
		else if (CHANNEL_NUM == 8) begin
			always @ (posedge clk) begin
				if(!i_fval) begin
					pix_data_shift	<= {DATA_WD{1'b0}};
				end
				else begin
					if(i_lval) begin
						if(format8_sel) begin
							pix_data_shift	<= {iv_pix_data[8*SENSOR_DAT_WIDTH-1:8*SENSOR_DAT_WIDTH-8],iv_pix_data[7*SENSOR_DAT_WIDTH-1:7*SENSOR_DAT_WIDTH-8],
												iv_pix_data[6*SENSOR_DAT_WIDTH-1:6*SENSOR_DAT_WIDTH-8],iv_pix_data[5*SENSOR_DAT_WIDTH-1:5*SENSOR_DAT_WIDTH-8],
												iv_pix_data[4*SENSOR_DAT_WIDTH-1:4*SENSOR_DAT_WIDTH-8],iv_pix_data[3*SENSOR_DAT_WIDTH-1:3*SENSOR_DAT_WIDTH-8],
												iv_pix_data[2*SENSOR_DAT_WIDTH-1:2*SENSOR_DAT_WIDTH-8],iv_pix_data[SENSOR_DAT_WIDTH-1:SENSOR_DAT_WIDTH-8],
												pix_data_shift[DATA_WD-1:64]};
						end
						else begin
							pix_data_shift	<= {{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[8*SENSOR_DAT_WIDTH-1:7*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[7*SENSOR_DAT_WIDTH-1:6*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[6*SENSOR_DAT_WIDTH-1:5*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[5*SENSOR_DAT_WIDTH-1:4*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[4*SENSOR_DAT_WIDTH-1:3*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[3*SENSOR_DAT_WIDTH-1:2*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[2*SENSOR_DAT_WIDTH-1:1*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[SENSOR_DAT_WIDTH-1:0]};
						end
					end
				end
			end
		end
	endgenerate


	//  -------------------------------------------------------------------------------------
	//	���ؼ�����
	//	1.������ʱ������
	//	2.����Ч������Чʱ���������ۼ�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_fval) begin
			pix_cnt	<= 4'b0;
		end
		else begin
			if(i_lval) begin
				pix_cnt	<= pix_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	���ظ�ʽ8bit
	//	CHANNEL_NUM=1ʱ��pix_cnt[3:0]=15��
	//	CHANNEL_NUM=2ʱ��pix_cnt[2:0]=7��
	//	CHANNEL_NUM=4ʱ��pix_cnt[1:0]=3��
	//	CHANNEL_NUM=8ʱ��pix_cnt[0:0]=1��
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	���ظ�ʽ10bit
	//	CHANNEL_NUM=1ʱ��pix_cnt[2:0]=7��
	//	CHANNEL_NUM=2ʱ��pix_cnt[1:0]=3��
	//	CHANNEL_NUM=4ʱ��pix_cnt[0:0]=1��
	//	CHANNEL_NUM=8ʱ����������
	//  -------------------------------------------------------------------------------------
	generate
		if (DATAEN_10B == 1) begin		// CHANNEL_NUM=8
			always @ (posedge clk) begin
				if(!i_fval) begin
					data_en	<= 1'b0;
				end
				else begin
					if(i_lval) begin
						if(format8_sel) begin
							if(pix_cnt[REDUCE_8B - 1 : 0] == (DATAEN_8B - 1)) begin
								data_en	<= 1'b1;
							end
							else begin
								data_en	<= 1'b0;
							end
						end
						else begin
							data_en	<= 1'b1;
						end
					end
					else begin
						data_en	<= 1'b0;
					end
				end
			end
		end
		else begin
			always @ (posedge clk) begin
				if(!i_fval) begin
					data_en	<= 1'b0;
				end
				else begin
					if(i_lval) begin
						if(format8_sel) begin
							if(pix_cnt[REDUCE_8B - 1 : 0] == (DATAEN_8B - 1)) begin
								data_en	<= 1'b1;
							end
							else begin
								data_en	<= 1'b0;
							end
						end
						else begin
							if(pix_cnt[REDUCE_10B - 1 : 0] == (DATAEN_10B - 1)) begin
								data_en	<= 1'b1;
							end
							else begin
								data_en	<= 1'b0;
							end
						end
					end
					else begin
						data_en	<= 1'b0;
					end
				end
			end
		end
	endgenerate

	//  ===============================================================================================
	//	ref ***�г��źš��������***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	fval ���
	//	1.�ӽ�β������������ʱ��2��ʱ����������Ҫ��fval��ʱ2��ʱ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_dly0	<= i_fval;
		fval_dly1	<= fval_dly0;
	end

	//	-------------------------------------------------------------------------------------
	//	��data_en��ʱ1�ģ���Ϊ���ݵĴ����ͺ���һ�ģ�����Ҫ��ʱ
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		data_en_dly	<= data_en;
	end

	//	-------------------------------------------------------------------------------------
	//	�ж�������ݣ������ʹ�ܣ������Ϊȫ��
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(data_en) begin
			pix_data_reg	<= pix_data_shift;
		end
		else begin
			pix_data_reg	<= {DATA_WD{1'b0}};
		end
	end

	//  -------------------------------------------------------------------------------------
	//	���
	//  -------------------------------------------------------------------------------------
	assign	o_pix_data_en	= data_en_dly;
	assign	ov_pix_data		= pix_data_reg;
	assign	o_fval			= fval_dly1;



endmodule
