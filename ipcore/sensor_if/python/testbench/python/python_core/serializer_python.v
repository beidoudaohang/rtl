//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : serializer_python
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/10/14 10:41:56	:|  ��ʼ�汾
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

module serializer_python # (
	parameter			DATA_WIDTH			= 8		,	//����λ��
	parameter			CHANNEL_NUM			= 4			//ͨ����
	)
	(
	input										clk					,	//ʱ��
	input										i_clk_en			,	//ʱ��ʹ��
	input	[DATA_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data			,	//��������
	input	[DATA_WIDTH-1:0]					iv_ctrl_data		,	//����ͨ��
	output										o_clk_p				,
	output										o_clk_n				,
	output	[CHANNEL_NUM-1:0]					ov_data_p			,
	output	[CHANNEL_NUM-1:0]					ov_data_n			,
	output										o_ctrl_p			,
	output										o_ctrl_n
	);

	//	ref signals
	wire	[DATA_WIDTH-1:0]					wv_data_lane	[CHANNEL_NUM-1:0]	;
	reg		[DATA_WIDTH-1:0]					shifter_data	[CHANNEL_NUM-1:0]	;
	reg		[DATA_WIDTH-1:0]					shifter_ctrl		;
	reg											clk_ser_dly	= 1'b0;
	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***���л�***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	����ͨ��
	//	--ÿ��ͨ����λ���� DATA_WIDTH ��bit
	//	--��ˣ���ߵ�ͨ���ڵ�byte��С�ˣ���͵�ͨ���ڵ�byte��
	//	-------------------------------------------------------------------------------------
	genvar	i;
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			assign	wv_data_lane[i]	= iv_pix_data[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i];
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	����ͨ��1
	//	1.��ʹ����Чʱʱ�����²��мĴ�������ֵ
	//	2.�����л���������������ֵʱ�������λ�Ƴ�
	//	-------------------------------------------------------------------------------------
	genvar	ch;
	generate
		for(ch=0;ch<CHANNEL_NUM;ch=ch+1) begin
			always @ (posedge clk) begin
				if(i_clk_en) begin
					shifter_data[ch]	<= wv_data_lane[ch];
				end
				else begin
					shifter_data[ch]	<= {shifter_data[ch][DATA_WIDTH-2:0],shifter_data[ch][DATA_WIDTH-1]};
				end
			end
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	����ͨ��2-����ͨ�����л�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_clk_en) begin
			shifter_ctrl	<= iv_ctrl_data;
		end
		else begin
			shifter_ctrl	<= {shifter_ctrl[DATA_WIDTH-2:0],shifter_ctrl[DATA_WIDTH-1]};
		end
	end

	//	-------------------------------------------------------------------------------------
	//	ʱ��2��Ƶ
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		clk_ser_dly	<= !clk_ser_dly;
	end

	//	===============================================================================================
	//	ref ***���***
	//	===============================================================================================
	assign	o_clk_p	= clk_ser_dly;
	assign	o_clk_n	= !clk_ser_dly;
	genvar	j;
	generate
		for(j=0;j<CHANNEL_NUM;j=j+1) begin
			assign	ov_data_p[j]	= shifter_data[j][DATA_WIDTH-1];
			assign	ov_data_n[j]	= !shifter_data[j][DATA_WIDTH-1];
		end
	endgenerate
	assign	o_ctrl_p	= shifter_ctrl[DATA_WIDTH-1];
	assign	o_ctrl_n	= !shifter_ctrl[DATA_WIDTH-1];


endmodule