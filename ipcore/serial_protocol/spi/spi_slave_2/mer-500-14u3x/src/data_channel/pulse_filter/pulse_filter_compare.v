//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : pulse_filter_compare
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/2/11 15:56:14	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : ���9�����ݱȽϵĹ���
//              1)  : ǰ��ģ�������3�����ݣ��м�����Ҫ�˲����У��������ǲο���
//
//              2)  : ֡ͷ֡β2�С���ͷ��β2���ز������˲������ǻ���Ϊ���������˲�������
//
//              3)  :
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module pulse_filter_compare # (
	parameter					SENSOR_DAT_WIDTH	= 10		//sensor ���ݿ��
	)
	(
	input								clk					,	//����ʱ��
	input								i_pulse_filter_en	,	//����У������,0:��ʹ�ܻ���У��,1:ʹ�ܻ���У��
	input								i_fval				,	//���źţ�ԭʼ��fval�ź�
	input								i_fval_delay		,	//���źţ�rdģ���������i_fval��ʱ2��ʱ��
	input								i_lval_delay		,	//���źţ�rdģ���������ԭʼlval��ȣ����ƽ����2��
	input	[SENSOR_DAT_WIDTH-1:0]		iv_upper_line		,	//��Ҫ�Ƚϵ������е�����һ��
	input	[SENSOR_DAT_WIDTH-1:0]		iv_mid_line			,	//��Ҫ�Ƚϵ������е��м�һ�У�Ҳ��Ҫ�������
	input	[SENSOR_DAT_WIDTH-1:0]		iv_lower_line		,	//��Ҫ�Ƚϵ������е�����һ��
	output								o_fval				,	//����ĳ��ź�
	output								o_lval				,	//��������ź�
	output	[SENSOR_DAT_WIDTH-1:0]		ov_pix_data				//�������������
	);

	//	ref signals
	reg									lval_delay_dly0		= 1'b0;
	reg									lval_delay_dly1		= 1'b0;
	reg									lval_delay_dly2		= 1'b0;
	reg									lval_delay_dly3		= 1'b0;
	reg									lval_delay_dly4		= 1'b0;
	reg									lval_delay_dly5		= 1'b0;
	reg									lval_delay_dly6		= 1'b0;
	wire								lval_delay_fall		;
	reg		[1:0]						lval_delay_cnt		= 2'b0;
	reg									compare_line		= 1'b0;
	reg									compare_line_dly0	= 1'b0;
	reg									compare_line_dly1	= 1'b0;
	reg									compare_line_dly2	= 1'b0;
	reg									compare_line_dly3	= 1'b0;
	wire								compare_pix			;
	reg									fval_reg			= 1'b0;
	reg									enable				= 1'b0;

	reg		[SENSOR_DAT_WIDTH-1:0]		upper_line_dly0		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		upper_line_dly1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		upper_line_dly2		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		upper_line_dly3		= {SENSOR_DAT_WIDTH{1'b0}};

	reg		[SENSOR_DAT_WIDTH-1:0]		mid_line_dly0		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		mid_line_dly1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		mid_line_dly2		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		mid_line_dly3		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		mid_line_dly4		= {SENSOR_DAT_WIDTH{1'b0}};

	reg		[SENSOR_DAT_WIDTH-1:0]		lower_line_dly0		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		lower_line_dly1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		lower_line_dly2		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		lower_line_dly3		= {SENSOR_DAT_WIDTH{1'b0}};

	wire	[SENSOR_DAT_WIDTH-1:0]		data_upper_left		;
	wire	[SENSOR_DAT_WIDTH-1:0]		data_upper_mid		;
	wire	[SENSOR_DAT_WIDTH-1:0]		data_upper_right	;
	wire	[SENSOR_DAT_WIDTH-1:0]		data_mid_left		;
	wire	[SENSOR_DAT_WIDTH-1:0]		data_mid_mid		;
	wire	[SENSOR_DAT_WIDTH-1:0]		data_mid_right		;
	wire	[SENSOR_DAT_WIDTH-1:0]		data_lower_left		;
	wire	[SENSOR_DAT_WIDTH-1:0]		data_lower_mid		;
	wire	[SENSOR_DAT_WIDTH-1:0]		data_lower_right	;

	reg		[SENSOR_DAT_WIDTH-1:0]		max_1cycle_1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		max_1cycle_2		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		max_1cycle_3		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		max_1cycle_4		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		max_2cycle_1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		max_2cycle_2		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		max_3cycle_1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		min_1cycle_1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		min_1cycle_2		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		min_1cycle_3		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		min_1cycle_4		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		min_2cycle_1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		min_2cycle_2		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		min_3cycle_1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		data_out_reg		= {SENSOR_DAT_WIDTH{1'b0}};


	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref ***ȡ����***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	�ж�����lval�ı���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_delay_dly0	<= i_lval_delay;
	end
	assign	lval_delay_fall		= (lval_delay_dly0==1'b1 && i_lval_delay==1'b0) ? 1'b1 : 1'b0;

	//  ===============================================================================================
	//	ref ***��Чʱ��***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	enable ʹ���źţ���֤����֡
	//	1.fval_reg=o_fval
	//	2.��o_fval=0ʱ��enable=i_pulse_filter_en
	//	2.��o_fval=1ʱ��enable���ֲ���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!fval_reg) begin
			enable	<= i_pulse_filter_en;
		end
	end

	//  ===============================================================================================
	//	ref ***ѡ��Ƚ�����***
	//	1.compare_pix		- ��ÿһ����Ҫ�˲��ĵ㣬��ͷ����β��2�����ز������˲�
	//	2.compare_line		- ��ÿһ֡��Ҫ�˲����У�֡ͷ��֡β��2�в������˲�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//                                _________________________________________________
	//	lval_delay_dly2      _________|                                               |______________
	//                                    _________________________________________________
	//	lval_delay_dly4      _____________|                                               |__________
	//                                        _________________________________________________
	//	lval_delay_dly6      _________________|                                               |______
	//                                        _________________________________________
	//	compare_pix          _________________|                                       |______________
	//
	//  -------------------------------------------------------------------------------------
	//	compare_pix
	//	1.ÿһ����Ҫ�Ƚϵ����أ���ͷ�ͽ�β��2�����ز����˲�����
	//	2.�� lval_delay_dly4 Ϊ��������lval_delay_dly4 ��ǰ���� ���������ض�ȥ����
	//  -------------------------------------------------------------------------------------
	assign	compare_pix	= lval_delay_dly2&lval_delay_dly4&lval_delay_dly6;

	//  -------------------------------------------------------------------------------------
	//	lval���ؼ�����
	//	1.��չ����fval=0ʱ������������
	//	2.��չ����fval=1ʱ��lval�½���ʱ������������
	//	3.lval_delay_cnt λ��2bit�������жϿ�ʼ��2�У�2bit�㹻
	//	4.lval_delay_cnt �ڵ���2'b10֮����Ա��֣������ͻ��ʡ���ġ�Ҳ���Լ������ӣ��������Խ�ʡ��Դ��ʡ�����ж��߼���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_fval_delay) begin
			lval_delay_cnt	<= 2'b00;
		end
		else begin
			if(lval_delay_fall==1'b1) begin
				lval_delay_cnt	<= lval_delay_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//                  _________________________________________________
	//	i_fval         _|                                               |______________________
	//                           _________________________________________________________
	//	i_fval_delay   __________|                                                       |_____
	//                              ____    ____    ____    ____           ____    ____
	//	i_lval_delay   _____________|  |____|  |____|  |____|  |____...____|  |____|  |________
	//                                          _________________________
	//	compare_line   _________________________|                       |______________________
	//
	//                  |-2 line-|----2 line----|                       |-----2 line-----|
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	compare_line
	//	1.��ͷ���в��Ƚ�
	//	2.ĩβ���в��Ƚ�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!(i_fval&i_fval_delay)) begin
			compare_line	<= 1'b0;
		end
		else begin
			if(lval_delay_cnt==2'b10) begin
				compare_line	<= 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	compare_line �ӳ��źţ���Ϊo_lval�����ӳ٣����ԱȽ������ź�ҲҪ�ӳ�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		compare_line_dly0	<= compare_line;
		compare_line_dly1	<= compare_line_dly0;
		compare_line_dly2	<= compare_line_dly1;
		compare_line_dly3	<= compare_line_dly2;
	end

	//  ===============================================================================================
	//	ref ***������ʱ�����ǩ***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	�������ݴ���
	//	1.���ĵ�Ŀ���Ǳ���֮ǰ���������ݣ�Ϊ�Ժ�����ݱȽ��ṩ����
	//	2.mid line ��Ҫ���������
	//	3.upper line��lower line �ṩ�Ƚ�����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		upper_line_dly0	<= iv_upper_line;
		upper_line_dly1	<= upper_line_dly0;
		upper_line_dly2	<= upper_line_dly1;
		upper_line_dly3	<= upper_line_dly2;
	end

	always @ (posedge clk) begin
		mid_line_dly0	<= iv_mid_line;
		mid_line_dly1	<= mid_line_dly0;
		mid_line_dly2	<= mid_line_dly1;
		mid_line_dly3	<= mid_line_dly2;
		mid_line_dly4	<= mid_line_dly3;
	end

	always @ (posedge clk) begin
		lower_line_dly0	<= iv_lower_line;
		lower_line_dly1	<= lower_line_dly0;
		lower_line_dly2	<= lower_line_dly1;
		lower_line_dly3	<= lower_line_dly2;
	end

	//  -------------------------------------------------------------------------------------
	//	Ϊ���ݴ��ϱ�ǩ
	//
	//	upper line  :      P22  P24  P26
	//	mid line    :      P42  P44  P46
	//	lower line  :      P62  P64  P66
	//
	//	1.��������Ϊ9������㣬��ߵĵ���ʱ���ϱ��ұߵĵ�Ҫ��
	//	2.�ϱ߱ߵĵ���ʱ���ϱ��±ߵĵ�Ҫ��
	//	3.P44���˲��㣬��Χ��8�������˲�������
	//	4.���Կ��� P44 ��ʵ�� mid_line_dly1 ���������Ҫ�����
	//
	//  -------------------------------------------------------------------------------------
	assign	data_upper_left	= upper_line_dly3;
	assign	data_upper_mid	= upper_line_dly1;
	assign	data_upper_right= iv_upper_line;

	assign	data_mid_left	= mid_line_dly3;
	assign	data_mid_mid	= mid_line_dly1;
	assign	data_mid_right	= iv_mid_line;

	assign	data_lower_left	= lower_line_dly3;
	assign	data_lower_mid	= lower_line_dly1;
	assign	data_lower_right= iv_lower_line;

	//  ===============================================================================================
	//	ref ***���ݱȽ�***
	//	1.���������Ƚϵķ�������Ҫ�ҳ�8�����ص�����ֵ����Сֵ
	//	2.����3�ֱȽϣ����ܵó����ֵ����Сֵ
	//	3.�ڱȽ�֮ǰ���˲����� mid_line_dly1 ������3�ֱȽ�֮�� mid_line_dly4 �����ֵ����Сֵ�Ƕ����
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref ��һ�ֱȽ�
	//	1.���Ƚ�4�Σ�8�����������Ƚϣ��ҳ�4���ϴ�ֵ��4����Сֵ
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(data_upper_left<=data_upper_mid) begin
			max_1cycle_1	<= data_upper_mid;
			min_1cycle_1	<= data_upper_left;
		end
		else begin
			max_1cycle_1	<= data_upper_left;
			min_1cycle_1	<= data_upper_mid;
		end
	end

	always @ (posedge clk) begin
		if(data_lower_left<=data_lower_mid) begin
			max_1cycle_2	<= data_lower_mid;
			min_1cycle_2	<= data_lower_left;
		end
		else begin
			max_1cycle_2	<= data_lower_left;
			min_1cycle_2	<= data_lower_mid;
		end
	end

	always @ (posedge clk) begin
		if(data_mid_left<=data_mid_right) begin
			max_1cycle_3	<= data_mid_right;
			min_1cycle_3	<= data_mid_left;
		end
		else begin
			max_1cycle_3	<= data_mid_left;
			min_1cycle_3	<= data_mid_right;
		end
	end

	always @ (posedge clk) begin
		if(data_upper_right<=data_lower_right) begin
			max_1cycle_4	<= data_lower_right;
			min_1cycle_4	<= data_upper_right;
		end
		else begin
			max_1cycle_4	<= data_upper_right;
			min_1cycle_4	<= data_lower_right;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	-- ref �ڶ��ֱȽ�
	//	1.���Ƚ�2�Σ���4���ϴ�ֵ�ͽ�Сֵ�У��ҳ�2���ϴ�ֵ��2����Сֵ
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(max_1cycle_1<=max_1cycle_2) begin
			max_2cycle_1	<= max_1cycle_2;
		end
		else begin
			max_2cycle_1	<= max_1cycle_1;
		end
	end

	always @ (posedge clk) begin
		if(min_1cycle_1<=min_1cycle_2) begin
			min_2cycle_1	<= min_1cycle_1;
		end
		else begin
			min_2cycle_1	<= min_1cycle_2;
		end
	end

	always @ (posedge clk) begin
		if(max_1cycle_3<=max_1cycle_4) begin
			max_2cycle_2	<= max_1cycle_4;
		end
		else begin
			max_2cycle_2	<= max_1cycle_3;
		end
	end

	always @ (posedge clk) begin
		if(min_1cycle_3<=min_1cycle_4) begin
			min_2cycle_2	<= min_1cycle_3;
		end
		else begin
			min_2cycle_2	<= min_1cycle_4;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	-- ref �����ֱȽ�
	//	1.���Ƚ�1�Σ���2���ϴ�ֵ�ͽ�Сֵ�У��ҳ�1�����ֵ��1����Сֵ
	//	2.���ˣ�8�������е����ֵ����Сֵ�Ѿ��ҳ���
	//	3.����ʱ3��
	//	4.��ʼ�Ƚ�ʱ���м���˲����� mid_line_dly1 ������ʱ3��֮�������ֵ����Сֵ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(max_2cycle_1<=max_2cycle_2) begin
			max_3cycle_1	<= max_2cycle_2;
		end
		else begin
			max_3cycle_1	<= max_2cycle_1;
		end
	end

	always @ (posedge clk) begin
		if(min_2cycle_1<=min_2cycle_2) begin
			min_3cycle_1	<= min_2cycle_1;
		end
		else begin
			min_3cycle_1	<= min_2cycle_2;
		end
	end

	//  ===============================================================================================
	//	ref ***�������***
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//
	//	clk                   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^
	//                        _________________________________________________
	//	i_lval_delay         _|                                               |______________________
	//                            _________________________________________________
	//	lval_delay_dly0      _____|                                               |__________________
	//                                _________________________________________________
	//	lval_delay_dly1      _________|                                               |______________
	//                                    _________________________________________________
	//	lval_delay_dly2      _____________|                                               |__________
	//                                        _________________________________________________
	//	lval_delay_dly3      _________________|                                               |______
	//                                            _________________________________________________
	//	lval_delay_dly4      _____________________|                                               |__
	//
	//	mid line dly4        ---------------------|D0 |D1 |D2 |D3      -------------     |Dn-1|Dn |--
	//
	//	-------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	�������
	//	1.������Чʱ���������Ϊȫ�� ��mid_line_dly4 �� Ҫ�˲������ݣ��������ЧҲӦ�ö�Ӧ����ʱ�źš�
	//	2.������Ч�ұȽ�ʹ�ܴ�ʱ���ڿ��ԱȽϵĽ׶Σ����бȽϡ�
	//	2.1--compare_line �Ǹ���lval�½��صó��ģ���ʱ3�����ڼ��ɡ�
	//	2'2.--���ԭʼ���ݴ����ܱߵ����ֵ�������ܱߵ����ֵ�滻ԭʼ����
	//	2'3.--���ԭʼ����С���ܱߵ���Сֵ�������ܱߵ���Сֵ�滻ԭʼ����
	//	3.������Чʱ���ڲ����ԱȽϵĽ׶Σ�ֱ���������
	//	4.������Чʱ���ڱȽ�ʹ��û�д�ʱ��ֱ���������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(lval_delay_dly4) begin
			if(enable&compare_line_dly3&compare_pix) begin
				if(mid_line_dly4>max_3cycle_1) begin
					data_out_reg	<= max_3cycle_1;
				end
				else if(mid_line_dly4<min_3cycle_1) begin
					data_out_reg	<= min_3cycle_1;
				end
				else begin
					data_out_reg	<= mid_line_dly4;
				end
			end
			else begin
				data_out_reg	<= mid_line_dly4;
			end
		end
		else begin
			data_out_reg	<= 'b0;
		end
	end
	assign	ov_pix_data	= data_out_reg;

	//  -------------------------------------------------------------------------------------
	//	����Ч���
	//	1.�� lval_delay_dly4 ��ʱ���������ݴ�һ�� �����lval_delay_dly5����������Ƕ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_delay_dly1	<= lval_delay_dly0;
		lval_delay_dly2	<= lval_delay_dly1;
		lval_delay_dly3	<= lval_delay_dly2;
		lval_delay_dly4	<= lval_delay_dly3;
		lval_delay_dly5	<= lval_delay_dly4;
		lval_delay_dly6	<= lval_delay_dly5;
	end
	assign	o_lval	= lval_delay_dly5;

	//  -------------------------------------------------------------------------------------
	//	����Ч���
	//	1.i_fval_delay��i_fval�ͺ�2�е�ʱ�䣬�������ź����Ľ��������o_fval�ͻ���ǰo_lval 2�г���
	//	2.����ֱ�ӽ�i_fval_delay��Ϊo_fval����Ϊ�п��������������̫�̣����o_fval��o_lval֮��Ŀ�϶̫С
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_reg	<= i_fval|i_fval_delay;
	end
	assign	o_fval	= fval_reg;

endmodule