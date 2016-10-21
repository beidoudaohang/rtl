//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : grey_statis
//  -- �����       : ������
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//	-- ������		:| 2015/10/14 10:13:14	:|	��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : �Ҷ�ͳ��ģ��
//              1)  : ���� aoi �г��źţ��ۼ�ÿ������
//
//              2)  : o_fval��ʱ1��ʱ��
//
//              3)  : ͳ�Ƹ�8bit
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module grey_statis # (
	parameter						SENSOR_DAT_WIDTH	= 10	,	//sensor ���ݿ��
	parameter						CHANNEL_NUM			= 4		,	//sensor ͨ������
	parameter						GREY_STATIS_WIDTH	= 48	,	//�Ҷ�ͳ��ģ��ͳ��ֵ���
	parameter						REG_WD				= 32		//�Ĵ���λ��
	)
	(
	//Sensor�����ź�
	input											clk						,	//����ʱ��
	input											i_fval					,	//���ź�
	input											i_lval					,	//���ź�
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data				,	//ͼ������
	//����ģ������
	input											i_interrupt_pin			,	//�ж�ģ��������ж��źţ�1-�ж���Ч�����ж�������ʱ������Ҷ�ͳ��ֵ�ʹ��ڼĴ������˿�
	output	[GREY_STATIS_WIDTH-1:0]					ov_grey_statis_sum			//�üĴ���ֵΪͼ��Ҷ�ͳ��ֵ�ܺ�
	);


	//	ref signals

	reg												fval_dly0		= 1'b0;
	wire											fval_rise		;
	reg												int_pin_dly		= 1'b0;
	wire											int_pin_rise	;
	reg		[GREY_STATIS_WIDTH-1:0]					grey_statis		= {GREY_STATIS_WIDTH{1'b0}};
	reg		[GREY_STATIS_WIDTH-1:0]					grey_statis_reg	= {GREY_STATIS_WIDTH{1'b0}};


	//	ref ARCHITECTURE


	//  ===============================================================================================
	//	ref ***��ʱ ȡ����***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	����Чȡ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_dly0	<= i_fval;
	end
	assign	fval_rise	= (fval_dly0==1'b0 && i_fval==1'b1) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	�ж�ȡ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		int_pin_dly	<= i_interrupt_pin;
	end
	assign	int_pin_rise	= (int_pin_dly==1'b0 && i_interrupt_pin==1'b1) ? 1'b1 : 1'b0;

	//  ===============================================================================================
	//	ref ***ͳ������***
	//  ===============================================================================================
	generate
		if 	(CHANNEL_NUM == 1) begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					grey_statis	<= {GREY_STATIS_WIDTH{1'b0}};
				end
				else begin
					if(i_lval) begin
						grey_statis	<= grey_statis + iv_pix_data[(SENSOR_DAT_WIDTH-1):(SENSOR_DAT_WIDTH-8)];
					end
				end
			end
		end
		else if (CHANNEL_NUM == 2) begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					grey_statis	<= {GREY_STATIS_WIDTH{1'b0}};
				end
				else begin
					if(i_lval) begin
						grey_statis	<= grey_statis + iv_pix_data[(2*SENSOR_DAT_WIDTH-1):(2*SENSOR_DAT_WIDTH-8)]
													   + iv_pix_data[(SENSOR_DAT_WIDTH-1):(SENSOR_DAT_WIDTH-8)];
					end
				end
			end
		end
		else if (CHANNEL_NUM == 4) begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					grey_statis	<= {GREY_STATIS_WIDTH{1'b0}};
				end
				else begin
					if(i_lval) begin
						grey_statis	<= grey_statis + iv_pix_data[(4*SENSOR_DAT_WIDTH-1):(4*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(3*SENSOR_DAT_WIDTH-1):(3*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(2*SENSOR_DAT_WIDTH-1):(2*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(SENSOR_DAT_WIDTH-1):(SENSOR_DAT_WIDTH-8)];
					end
				end
			end
		end
		else if (CHANNEL_NUM == 8) begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					grey_statis	<= {GREY_STATIS_WIDTH{1'b0}};
				end
				else begin
					if(i_lval) begin
						grey_statis	<= grey_statis + iv_pix_data[(8*SENSOR_DAT_WIDTH-1):(8*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(7*SENSOR_DAT_WIDTH-1):(7*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(6*SENSOR_DAT_WIDTH-1):(6*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(5*SENSOR_DAT_WIDTH-1):(5*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(4*SENSOR_DAT_WIDTH-1):(4*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(3*SENSOR_DAT_WIDTH-1):(3*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(2*SENSOR_DAT_WIDTH-1):(2*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(SENSOR_DAT_WIDTH-1):(SENSOR_DAT_WIDTH-8)];
					end
				end
			end
		end
	endgenerate

	//  ===============================================================================================
	//	ref ***���ͳ�ƽ��***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	���ж��źŵ������أ����ڲ�ͳ�ƽ�����浽�˿���
	//  -------------------------------------------------------------------------------------

	always @ (posedge clk) begin
		if(int_pin_rise) begin
			grey_statis_reg <= grey_statis;
		end
	end

	assign	ov_grey_statis_sum	= grey_statis_reg;


endmodule
