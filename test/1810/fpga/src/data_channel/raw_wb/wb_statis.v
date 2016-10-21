//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : wb_statis
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/2/13 10:30:32	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : ����ǰ�������ͳ��������ɷ���ͳ��
//              1)  : G����ͳ��ֵ/2 ��������ͳ��ֵ����
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wb_statis # (
	parameter					SENSOR_DAT_WIDTH	= 10	,	//sensor ���ݿ��
	parameter					CHANNEL_NUM			= 4		,	//ͨ����
	parameter					WB_STATIS_WIDTH		= 29	,	//��ƽ��ģ��ͳ��ֵ���
	parameter					REG_WD				= 32		//�Ĵ���λ��
	)
	(
	input										clk						,	//����ʱ��
	input										i_fval					,	//���ź�
	input										i_lval					,	//���ź�
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	iv_pix_data				,	//ͼ������
	input	[CHANNEL_NUM-1:0]					iv_r_flag				,	//��ɫ������־ R
	input	[CHANNEL_NUM-1:0]					iv_g_flag				,	//��ɫ������־ G
	input	[CHANNEL_NUM-1:0]					iv_b_flag				,	//��ɫ������־ B
	input										i_interrupt_pin			,	//�ж�ģ��������ж��źţ�1-�ж���Ч�����ж�������ʱ��������ɫ����ͳ��ֵ�ʹ��ڼĴ������˿�
	output	[WB_STATIS_WIDTH-1:0]				ov_wb_statis_r			,	//������ظ�ʽΪ8bit����ֵΪͼ��R����8bitͳ��ֵ��������ظ�ʽΪ����8bit����ֵΪͼ��R������8bitͳ��ֵ��
	output	[WB_STATIS_WIDTH-1:0]				ov_wb_statis_g			,	//������ظ�ʽΪ8bit����ֵΪͼ��G����8bitͳ��ֵ����2�Ľ����������ظ�ʽΪ����8bit����ֵΪͼ��G������8bitͳ��ֵ����2�Ľ����
	output	[WB_STATIS_WIDTH-1:0]				ov_wb_statis_b				//������ظ�ʽΪ8bit����ֵΪͼ��B����8bitͳ��ֵ��������ظ�ʽΪ����8bit����ֵΪͼ��B������8bitͳ��ֵ��
	);

	//	ref signals
	reg									fval_dly0			= 1'b0;
	reg									fval_dly1			= 1'b0;
	wire								fval_rise			;
	reg									int_pin_dly			= 1'b0;
	wire								int_pin_rise		;
	reg		[WB_STATIS_WIDTH-1:0]		wb_statis_r			= 'b0;
	reg		[WB_STATIS_WIDTH:0]			wb_statis_g			= 'b0;
	reg		[WB_STATIS_WIDTH-1:0]		wb_statis_b			= 'b0;
	reg		[WB_STATIS_WIDTH-1:0]		wb_statis_r_reg		= {WB_STATIS_WIDTH{1'b0}};
	reg		[WB_STATIS_WIDTH-1:0]		wb_statis_g_reg		= {WB_STATIS_WIDTH{1'b0}};
	reg		[WB_STATIS_WIDTH-1:0]		wb_statis_b_reg		= {WB_STATIS_WIDTH{1'b0}};
	wire	[SENSOR_DAT_WIDTH-1:0]		wv_data_lane		[CHANNEL_NUM-1:0]	;


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
	//	ref ***ͳ����ɫ����***
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	����ͨ��
	//	--ÿ��ͨ����λ���� DESER_WIDTH ��bit
	//	--С�ˣ���͵�ͨ���ڵ�byte��
	//	-------------------------------------------------------------------------------------
	genvar	i;
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			assign	wv_data_lane[i]	= iv_pix_data[SENSOR_DAT_WIDTH*(i+1)-1:SENSOR_DAT_WIDTH*i];
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	����ͳ�ƺ�����������Ҫ����ɫ����������
	//	--ÿ����ɫ��������������е�
	//	--ֻͳ��ÿ����ɫ�����ĸ�8bit
	//	-------------------------------------------------------------------------------------
	function [WB_STATIS_WIDTH-1:0] rgb_sum;
		input	start;
		integer	j;
		begin
			rgb_sum	= 0;
			for(j=start;j<CHANNEL_NUM;j=j+2) begin
				rgb_sum	= rgb_sum + wv_data_lane[j][SENSOR_DAT_WIDTH-1:SENSOR_DAT_WIDTH-8];
			end
		end
	endfunction

	//  -------------------------------------------------------------------------------------
	//	r����
	//	1.����������ʱ����λ�ڲ�������
	//	2.��������־��Чʱ�������������������
	//	3.��ɫ������־ֻ��lval��Чʱ=1����˲���Ҫlval��Ϊ����
	//	4.ֻͳ�Ƹ�8bit
	//  -------------------------------------------------------------------------------------
	generate
		if(CHANNEL_NUM==1) begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					wb_statis_r	<= {WB_STATIS_WIDTH{1'b0}};
				end
				else begin
					if(iv_r_flag[0]) begin
						wb_statis_r	<= wb_statis_r + rgb_sum(0);
					end
				end
			end
		end
		else begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					wb_statis_r	<= {WB_STATIS_WIDTH{1'b0}};
				end
				else begin
					if(iv_r_flag[0]) begin
						wb_statis_r	<= wb_statis_r + rgb_sum(0);
					end
					else if(iv_r_flag[1]) begin
						wb_statis_r	<= wb_statis_r + rgb_sum(1);
					end
				end
			end
		end
	endgenerate

	//  -------------------------------------------------------------------------------------
	//	g����
	//  -------------------------------------------------------------------------------------
	generate
		if(CHANNEL_NUM==1) begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					wb_statis_g	<= {(WB_STATIS_WIDTH+1){1'b0}};
				end
				else begin
					if(iv_g_flag[0]) begin
						wb_statis_g	<= wb_statis_g + rgb_sum(0);
					end
				end
			end
		end
		else begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					wb_statis_g	<= {(WB_STATIS_WIDTH+1){1'b0}};
				end
				else begin
					if(iv_g_flag[0]) begin
						wb_statis_g	<= wb_statis_g + rgb_sum(0);
					end
					else if(iv_g_flag[1]) begin
						wb_statis_g	<= wb_statis_g + rgb_sum(1);
					end
				end
			end
		end
	endgenerate

	//  -------------------------------------------------------------------------------------
	//	g����
	//  -------------------------------------------------------------------------------------
	generate
		if(CHANNEL_NUM==1) begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					wb_statis_b	<= {WB_STATIS_WIDTH{1'b0}};
				end
				else begin
					if(iv_b_flag[0]) begin
						wb_statis_b	<= wb_statis_b + rgb_sum(0);
					end
				end
			end
		end
		else begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					wb_statis_b	<= {WB_STATIS_WIDTH{1'b0}};
				end
				else begin
					if(iv_b_flag[0]) begin
						wb_statis_b	<= wb_statis_b + rgb_sum(0);
					end
					else if(iv_b_flag[1]) begin
						wb_statis_b	<= wb_statis_b + rgb_sum(1);
					end
				end
			end
		end
	endgenerate

	//  ===============================================================================================
	//	ref ***���ͳ�ƽ��***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	r���������ж��źŵ������أ����ڲ�ͳ�ƽ�����浽�˿���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(int_pin_rise) begin
			wb_statis_r_reg	<= wb_statis_r;
		end
	end
	assign	ov_wb_statis_r	= wb_statis_r_reg;

	//  -------------------------------------------------------------------------------------
	//	g���������ж��źŵ������أ����ڲ�ͳ�ƽ�����浽�˿��ϣ����ֵҪ����2
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(int_pin_rise) begin
			wb_statis_g_reg	<= wb_statis_g[WB_STATIS_WIDTH:1];
		end
	end
	assign	ov_wb_statis_g	= wb_statis_g_reg;

	//  -------------------------------------------------------------------------------------
	//	b���������ж��źŵ������أ����ڲ�ͳ�ƽ�����浽�˿���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(int_pin_rise) begin
			wb_statis_b_reg	<= wb_statis_b;
		end
	end
	assign	ov_wb_statis_b	= wb_statis_b_reg;


endmodule
