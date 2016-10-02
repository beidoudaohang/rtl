//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : ad_lvds_serializer
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/8/9 14:11:30	:|  ��ʼ�汾
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

module ad_lvds_serializer (
	input				clk				,	//����ʱ��
	input				reset			,	//����ʱ�Ӹ�λ
	input	[15:0]		iv_pix_data		,	//��������
	//lvds�˿�
	output				o_tckp			,	//���ʱ�� p��
	output				o_tckn			,	//���ʱ�� n��
	output				o_dout0p		,	//�������0 p��
	output				o_dout0n		,	//�������0 n��
	output				o_dout1p		,	//�������1 p��
	output				o_dout1n			//�������1 n��
	);

	//	ref signals
	reg		[2:0]		ser_cnt			= 3'b0;
	reg		[15:0]		pix_data_dly0	= 16'b0;
	reg		[7:0]		shifter_ch0		= 8'b0;
	reg		[7:0]		shifter_ch1		= 8'b0;
	reg					clk_ser_dly		= 1'b0;

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	���л�������
	//	1.ÿ��ͨ���Ĵ�������8bit����˼�������3bit����0��7�ۼ�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			ser_cnt	<= 3'b0;
		end
		else begin
			ser_cnt	<= ser_cnt + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	�ӷ����Ͽ���lvds serializerͨ��Ҳ����1�ĵ���ʱ
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(ser_cnt==3'h7) begin
			pix_data_dly0	<= iv_pix_data;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	����ͨ��1
	//	1.�����л�������=7ʱ�����²��мĴ�������ֵ
	//	2.�����л���������������ֵʱ�������λ�Ƴ�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(ser_cnt==3'h7) begin
			shifter_ch1	<= pix_data_dly0[15:8];
		end
		else begin
			shifter_ch1	<= {shifter_ch1[6:0],1'b0};
		end
	end

	//	-------------------------------------------------------------------------------------
	//	����ͨ��0
	//	1.�����л�������=7ʱ�����²��мĴ�������ֵ
	//	2.�����л���������������ֵʱ�������λ�Ƴ�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(ser_cnt==3'h7) begin
			shifter_ch0	<= pix_data_dly0[7:0];
		end
		else begin
			shifter_ch0	<= {shifter_ch0[6:0],1'b0};
		end
	end

	//	-------------------------------------------------------------------------------------
	//	ʱ��2��Ƶ
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		clk_ser_dly	<= !clk_ser_dly;
	end

	//	-------------------------------------------------------------------------------------
	//	lvds���
	//	-------------------------------------------------------------------------------------
	assign	o_tckp		= clk_ser_dly;
	assign	o_tckn		= !clk_ser_dly;
	assign	o_dout0p	= shifter_ch0[7];
	assign	o_dout0n	= !shifter_ch0[7];
	assign	o_dout1p	= shifter_ch1[7];
	assign	o_dout1n	= !shifter_ch1[7];


endmodule