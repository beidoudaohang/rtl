//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : wb_gain
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/2/13 10:31:49	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : ��ɫ��������ģ��
//              1)  : ������ʱ3��ʱ��
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wb_gain # (
	parameter					SENSOR_DAT_WIDTH	= 10		,	//sensor ���ݿ��
	parameter					CHANNEL_NUM			= 4			,	//ͨ����
	parameter					WB_GAIN_WIDTH		= 11		,	//��ƽ��ģ������Ĵ������
	parameter					WB_RATIO			= 8			,	//��ƽ��������ӣ��˷�������Ҫ���ƶ���λ
	parameter					REG_WD				= 32			//�Ĵ���λ��
	)
	(
	input											clk					,	//ʱ������
	input											i_fval				,	//���ź�
	input											i_lval				,	//���ź�
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data			,	//ͼ������
	input	[CHANNEL_NUM-1:0]						iv_r_flag			,	//��ɫ������־ R
	input	[CHANNEL_NUM-1:0]						iv_g_flag			,	//��ɫ������־ G
	input	[CHANNEL_NUM-1:0]						iv_b_flag			,	//��ɫ������־ B
	input											i_mono_sel			,	//1:ѡ�кڰ�ģʽ��ģ�鲻������0��ѡ�в�ɫģʽ��ģ�鹤����
	input	[2:0]									iv_test_image_sel	,	//����ͼѡ��Ĵ���,000:��ʵͼ,001:����ͼ��1�Ҷ�ֵ֡����,110:����ͼ��2��ֹ��б����,010:����ͼ��3������б����
	input	[WB_GAIN_WIDTH-1:0]						iv_wb_gain_r		,	//��ƽ��R������R����С������256��Ľ����ȡֵ��Χ[0:2047]
	input	[WB_GAIN_WIDTH-1:0]						iv_wb_gain_g		,	//��ƽ��G������G����С������256��Ľ����ȡֵ��Χ[0:2047]
	input	[WB_GAIN_WIDTH-1:0]						iv_wb_gain_b		,	//��ƽ��B������B����С������256��Ľ����ȡֵ��Χ[0:2047]
	output											o_fval				,	//����Ч��o_fval��o_lval����λҪ��֤���������λһ��
	output											o_lval				,	//����Ч
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data				//ͼ������
	);

	//	ref signals
	localparam				GAIN_COE_ONE	= {1'b1,{WB_RATIO{1'b0}}};

	wire													gain_enable		;
	reg		[WB_GAIN_WIDTH-1:0]								gain_coe		[CHANNEL_NUM-1:0];
	wire	[SENSOR_DAT_WIDTH-1:0]							wv_data_lane		[CHANNEL_NUM-1:0];
	reg		[SENSOR_DAT_WIDTH-1:0]							pix_data_reg	[CHANNEL_NUM-1:0];
	wire	[16:0]											wb_mult_a		[CHANNEL_NUM-1:0];
	wire	[16:0]											wb_mult_b		[CHANNEL_NUM-1:0];
	wire	[33:0]											wb_mult_p		[CHANNEL_NUM-1:0];
	wire													wb_mult_ce		;
	//	wire	[(WB_GAIN_WIDTH+SENSOR_DAT_WIDTH-1):0]			gain_all_data	;	//DSP�����������Ч������λ
	wire	[(WB_GAIN_WIDTH+SENSOR_DAT_WIDTH-WB_RATIO-1):0]	gain_reduce		[CHANNEL_NUM-1:0];	//DSP�����������Ч������λ��λ֮��Ľ��
	wire	[(WB_GAIN_WIDTH-WB_RATIO-1):0]					gain_overflow	[CHANNEL_NUM-1:0];	//DSP�����������Ч������λ�����λ
	reg														fval_dly0		= 1'b0;
	reg														fval_dly1		= 1'b0;
	reg														fval_reg		= 1'b0;
	reg														lval_dly0		= 1'b0;
	reg														lval_dly1		= 1'b0;
	reg														lval_reg		= 1'b0;
	reg		[WB_GAIN_WIDTH-1:0]								wb_gain_r_m		= 0	;	//������Чʱ�����Ƶİ�ƽ����������
	reg		[WB_GAIN_WIDTH-1:0]								wb_gain_g_m		= 0	;   //������Чʱ�����Ƶİ�ƽ������̷���
	reg		[WB_GAIN_WIDTH-1:0]								wb_gain_b_m		= 0	;   //������Чʱ�����Ƶİ�ƽ�����������

	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref ***��Чʱ��***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	�˷�����ʹ�ܿ���
	//	1.�����ظ�ʽ�ǲ�ɫ����û��ѡ�в���ͼʱ���Ż����˷�����
	//	2.����ֱ���������
	//  -------------------------------------------------------------------------------------
	assign	gain_enable	= (i_mono_sel==1'b0 && iv_test_image_sel==3'b000) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	����ϵ�� gain coefficient
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_fval) begin
			wb_gain_r_m	<=  iv_wb_gain_r;
			wb_gain_g_m <=  iv_wb_gain_g;
			wb_gain_b_m <=  iv_wb_gain_b;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	��ȡÿ��ͨ��������ϵ��
	//	-------------------------------------------------------------------------------------
	genvar	i;
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			always @ ( * ) begin
				case({iv_r_flag[i],iv_g_flag[i],iv_b_flag[i]})
					3'b100	: gain_coe[i]	<= wb_gain_r_m;
					3'b010	: gain_coe[i]	<= wb_gain_g_m;
					3'b001	: gain_coe[i]	<= wb_gain_b_m;
					default	: gain_coe[i]	<= GAIN_COE_ONE;
				endcase
			end
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	����ͨ��
	//	--ÿ��ͨ����λ���� SENSOR_DAT_WIDTH ��bit
	//	--С�ˣ���͵�ͨ���ڵ�byte��
	//	-------------------------------------------------------------------------------------
	genvar	ch;
	generate
		for(ch=0;ch<CHANNEL_NUM;ch=ch+1) begin
			assign	wv_data_lane[ch]	= iv_pix_data[SENSOR_DAT_WIDTH*(ch+1)-1:SENSOR_DAT_WIDTH*ch];
		end
	endgenerate

	//  ===============================================================================================
	//	ref ***�˷������***
	//  ===============================================================================================
	genvar	j;
	generate
		//  -------------------------------------------------------------------------------------
		//	�˷���ʹ��
		//	1.������Чʹ��������ʹ�ܴ򿪵�ʱ�򣬳˷����Ż�ʹ�ܣ����ڳ˷�������ʱΪ2�����ʹ���ź�Ҫ��lval��һ��
		//	2.���򣬳˷���ʹ�ܹر�
		//  -------------------------------------------------------------------------------------
//		assign	wb_mult_ce	= gain_enable&i_lval;
		assign	wb_mult_ce	= gain_enable&(i_lval|lval_dly0);
		for(j=0;j<CHANNEL_NUM;j=j+1) begin
			//  -------------------------------------------------------------------------------------
			//	�˷�����������˿�
			//	1.����˿ڶ���17bitλ��������������λ���㣬��Ҫ��0�����λ
			//	2.�˷���a��������ϵ��
			//	3.�˷���b������������
			//	4.�˷�����2�����붼û�д��ģ�ֱ��ʹ�����������
			//  -------------------------------------------------------------------------------------
			assign	wb_mult_a[j]	= {{(17-WB_GAIN_WIDTH){1'b0}},gain_coe[j][WB_GAIN_WIDTH-1:0]};
			assign	wb_mult_b[j]	= {{(17-SENSOR_DAT_WIDTH){1'b0}},wv_data_lane[j][SENSOR_DAT_WIDTH-1:0]};

			//  -------------------------------------------------------------------------------------
			//	�˷���
			//	1.ceʹ�ܣ�����������ݵ�ʱ��ʹ�ܹرգ���ʡ����
			//	2.�˷�������λ��17�����λ��34��Ŀ���Ƿ�����չ��DSP�ĸ�bitû���õ����ڲ��ֲ���ʱ�ᱻ�Ż���
			//	3.�ڲ���2��pipelin���˷�������ʱ2��
			//  -------------------------------------------------------------------------------------
			wb_mult_a17b17p34 wb_mult_a17b17p34_inst (
			.clk	(clk			),
			.ce		(wb_mult_ce		),
			.a		(wb_mult_a[j]	),
			.b		(wb_mult_b[j]	),
			.p		(wb_mult_p[j]	)
			);
		end
	endgenerate

	//  -------------------------------------------------------------------------------------
	//	���λ�Ľ���
	//	�˷�����������Ҫ���� WB_RATIO λ����Ϊ�˷�����ϵ����ʵ�ʵ�ϵ���ж�Ӧ��ϵ������ ����2λ���൱������ϵ����ʵ��ϵ����4����
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	��������λ
	//	1.wb_mult_p		- �˷����ܹ�λ����34bit
	//	2.gain_all_data	- DSP��������ʵ����Чλ���� WB_GAIN_WIDTH + SENSOR_DAT_WIDTH����A�ڵĿ�� + B�ڵĿ�ȣ���λ��ȫ0
	//	3.gain_reduce	- DSP�������е���Ч����λ���� SENSOR_DAT_WIDTH + WB_RATIO�������а��������λ
	//	4.gain_overflow	- ���λ���� WB_GAIN_WIDTH + SENSOR_DAT_WIDTH - (SENSOR_DAT_WIDTH + WB_RATIO) = SENSOR_DAT_WIDTH - WB_RATIO
	//  -------------------------------------------------------------------------------------
	//	assign	gain_all_data	= wb_mult_p[(WB_GAIN_WIDTH+SENSOR_DAT_WIDTH-1):0];
	genvar	k;
	generate
		for(k=0;k<CHANNEL_NUM;k=k+1) begin
			assign	gain_reduce[k]		= wb_mult_p[k][(WB_GAIN_WIDTH+SENSOR_DAT_WIDTH-1):WB_RATIO];
			assign	gain_overflow[k]	= wb_mult_p[k][(WB_GAIN_WIDTH+SENSOR_DAT_WIDTH-1):SENSOR_DAT_WIDTH+WB_RATIO];
		end
	endgenerate

	//  ===============================================================================================
	//	ref ***�������***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	�������������
	//	1.���˷����治ʹ��ʱ
	//	--1.1���г�����Чʱ��ֱ��������������
	//	--1.2������ʱ����������Ϊ0
	//	2.���˷�����ʹ��ʱ
	//	--2.1���г�����Чʱ
	//	----2.1.1������λ��1���֣�˵���Ѿ����������Ч����Ϊȫ1
	//	----2.1.2�����λ��ȫ0���֣�˵��û�����������˷���������
	//	--2.2������ʱ����������Ϊ0
	//	�����Ļ�������2�ĵĲ�һ��������gain_enable�Ĳ������Ǿ�������֡���Ƶģ���˶Ժ���Ӱ�첻��
	//  -------------------------------------------------------------------------------------
	genvar	l;
	generate
		for(l=0;l<CHANNEL_NUM;l=l+1) begin
			always @ (posedge clk) begin
				if(gain_enable==1'b0) begin
					if(i_fval==1'b1 && i_lval==1'b1) begin
						pix_data_reg[l]	<= wv_data_lane[l];
					end
					else begin
						pix_data_reg[l]	<= {SENSOR_DAT_WIDTH{1'b0}};
					end
				end
				else begin
					if(fval_dly1==1'b1 && lval_dly1==1'b1) begin
						if(|gain_overflow[l]) begin
							pix_data_reg[l]	<= {SENSOR_DAT_WIDTH{1'b1}};
						end
						else begin
							pix_data_reg[l]	<= gain_reduce[l][SENSOR_DAT_WIDTH-1:0];
						end
					end
					else begin
						pix_data_reg[l]	<= {SENSOR_DAT_WIDTH{1'b0}};
					end
				end
			end
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	����ͨ��������
	//	-------------------------------------------------------------------------------------
	genvar	m;
	generate
		for(m=0;m<CHANNEL_NUM;m=m+1) begin
			assign	ov_pix_data[SENSOR_DAT_WIDTH*(m+1)-1:SENSOR_DAT_WIDTH*m]	= pix_data_reg[m];
		end
	endgenerate

	//  -------------------------------------------------------------------------------------
	//	�г��ź��ӳ� ���ӳ�3��
	//	--gain_enable��Чʱ��ʹ�ó˷�����������1����ʱ
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_dly0	<= i_fval;
		fval_dly1	<= fval_dly0;
	end

	always @ (posedge clk) begin
		if(!gain_enable) begin
			fval_reg	<= i_fval;
		end
		else begin
			fval_reg	<= fval_dly1;
		end
	end
	assign	o_fval	= fval_reg ;

	//	-------------------------------------------------------------------------------------
	//	�����볡�ź�=0ʱ����������ź�Ҫ����
	//	--gain_enable��Чʱ��ʹ�ó˷�����������1����ʱ
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_dly0	<= i_lval;
		lval_dly1	<= lval_dly0;
	end

	always @ (posedge clk) begin
		if(!gain_enable) begin
			if(i_fval==1'b0) begin
				lval_reg	<= 1'b0;
			end
			else begin
				lval_reg	<= i_lval;
			end
		end
		else begin
			if(fval_dly1==1'b0) begin
				lval_reg	<= 1'b0;
			end
			else begin
				lval_reg	<= lval_dly1;
			end
		end
	end
	assign	o_lval	= lval_reg;


endmodule
