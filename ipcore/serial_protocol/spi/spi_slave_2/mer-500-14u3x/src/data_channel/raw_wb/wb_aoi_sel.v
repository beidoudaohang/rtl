//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : wb_aoi_sel
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/2/13 10:29:24	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : ��ȡ��aoi����
//              1)  : �г��źš�RGB��־���������ݣ��ӳ�2��
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wb_aoi_sel # (
	parameter					SENSOR_DAT_WIDTH	= 10	,	//sensor ���ݿ���
	parameter					WB_OFFSET_WIDTH		= 12	,	//��ƽ��ģ��ƫ��λ�üĴ�������
	parameter					REG_WD				= 32		//�Ĵ���λ��
	)
	(
	input							clk						,	//ʱ������
	input							i_fval					,	//���ź�
	input							i_lval					,	//���ź�
	input	[SENSOR_DAT_WIDTH-1:0]	iv_pix_data				,	//ͼ������
	input							i_r_flag				,	//��ɫ������־ R
	input							i_g_flag				,	//��ɫ������־ G
	input							i_b_flag				,	//��ɫ������־ B
	input							i_interrupt_en			,	//�Զ���ƽ���ж�ʹ�ܣ�0:��ʹ�ܣ�1:ʹ�ܡ������ʹ�ܸ��жϣ����رհ�ƽ��ͳ�ƹ��ܣ��Խ�ʡ���ġ�
	output							o_interrupt_en			,	//�����ж�=0��o_interrupt_en=0��һ֡ͳ����Чʱ����i_fval�½��أ�o_interrupt_en=1
	input							i_interrupt_pin			,	//�ж�ģ��������ж��źţ�1-�ж���Ч�����ж�������ʱ��������ɫ����ͳ��ֵ�ʹ��ڼĴ������˿�
	input	[REG_WD-1:0]			iv_pixel_format			,	//0x01080001:Mono8��0x01100003:Mono10��0x01080008:BayerGR8��0x0110000C:BayerGR10���ڰ�ʱ��������ƽ��ͳ�ơ�
	input	[2:0]					iv_test_image_sel		,	//����ͼѡ��Ĵ���,000:��ʵͼ,001:����ͼ��1�Ҷ�ֵ֡����,110:����ͼ��2��ֹ��б����,010:����ͼ��3������б����
	input	[WB_OFFSET_WIDTH-1:0]	iv_wb_offset_x_start	,	//��ƽ��ͳ�������x������ʼ�㣬�̼����õĸüĴ���ֵӦ���������ROI��ƫ��
	input	[WB_OFFSET_WIDTH-1:0]	iv_wb_offset_width		,	//��ƽ��ͳ������Ŀ���
	input	[WB_OFFSET_WIDTH-1:0]	iv_wb_offset_y_start	,	//��ƽ��ͳ�������y������ʼ�㣬�̼����õĸüĴ���ֵӦ���������ROI��ƫ��
	input	[WB_OFFSET_WIDTH-1:0]	iv_wb_offset_height		,	//��ƽ��ͳ������ĸ߶�
	output	[WB_OFFSET_WIDTH-1:0]	ov_wb_offset_width		,	//������ͳ�ƴ��ڣ���ƽ��ͳ������Ŀ���
	output	[WB_OFFSET_WIDTH-1:0]	ov_wb_offset_height		,	//������ͳ�ƴ��ڣ���ƽ��ͳ������ĸ߶�
	output							o_fval					,	//����Ч
	output							o_lval					,	//����Ч
	output	[SENSOR_DAT_WIDTH-1:0]	ov_pix_data				,	//ͼ������
	output							o_r_flag				,	//��ɫ������� R
	output							o_g_flag				,	//��ɫ������� G
	output							o_b_flag					//��ɫ������� B
	);

	//	ref signals
	reg								lval_dly0				= 1'b0;
	reg								lval_reg				= 1'b0;
	wire							lval_fall				;
	reg								fval_dly0				= 1'b0;
	reg								fval_dly1				= 1'b0;
	wire							fval_rise				;
	wire							fval_fall				;
	reg								int_pin_dly					= 1'b0;
	wire							int_pin_rise				;

	reg								interrupt_en_int		= 1'b0;
	reg								mono_sel				= 1'b0;
	reg								int_reg					= 1'b0;
	wire							aoi_enable				;
	reg								width_height_0			= 1'b0;
	reg		[WB_OFFSET_WIDTH-1:0]	wb_offset_x_start_reg	= {WB_OFFSET_WIDTH{1'b0}};
	//	reg		[WB_OFFSET_WIDTH-1:0]	wb_offset_x_end_reg		= {WB_OFFSET_WIDTH{1'b0}};
	reg		[WB_OFFSET_WIDTH-1:0]	wb_offset_width_reg		= {WB_OFFSET_WIDTH{1'b0}};
	reg		[WB_OFFSET_WIDTH-1:0]	wb_offset_y_start_reg	= {WB_OFFSET_WIDTH{1'b0}};
	//	reg		[WB_OFFSET_WIDTH-1:0]	wb_offset_y_end_reg		= {WB_OFFSET_WIDTH{1'b0}};
	reg		[WB_OFFSET_WIDTH-1:0]	wb_offset_height_reg	= {WB_OFFSET_WIDTH{1'b0}};
	reg		[WB_OFFSET_WIDTH-1:0]	wb_offset_width_latch	= {WB_OFFSET_WIDTH{1'b0}};
	reg		[WB_OFFSET_WIDTH-1:0]	wb_offset_height_latch	= {WB_OFFSET_WIDTH{1'b0}};

	reg		[WB_OFFSET_WIDTH-1:0]	line_cnt				= {WB_OFFSET_WIDTH{1'b0}};
	reg		[WB_OFFSET_WIDTH-1:0]	pix_cnt					= {WB_OFFSET_WIDTH{1'b0}};
	reg								x_enable				= 1'b0;
	reg								y_enable				= 1'b0;
	reg								r_flag_dly0				= 1'b0;
	reg								r_flag_reg				= 1'b0;
	reg								g_flag_dly0				= 1'b0;
	reg								g_flag_reg				= 1'b0;
	reg								b_flag_dly0				= 1'b0;
	reg								b_flag_reg				= 1'b0;
	reg		[SENSOR_DAT_WIDTH-1:0]	pix_data_dly0			= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]	pix_data_dly1			= {SENSOR_DAT_WIDTH{1'b0}};



	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***��ʱ ȡ����***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	����Чȡ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_dly0	<= i_lval;
	end
	assign	lval_fall	= (lval_dly0==1'b1 && i_lval==1'b0) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	����Чȡ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_dly0	<= i_fval;
		fval_dly1	<= fval_dly0;
	end
	assign	fval_rise	= (fval_dly0==1'b0 && i_fval==1'b1) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_dly1==1'b1 && fval_dly0==1'b0) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	�ж�ȡ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		int_pin_dly	<= i_interrupt_pin;
	end
	assign	int_pin_rise	= (int_pin_dly==1'b0 && i_interrupt_pin==1'b1) ? 1'b1 : 1'b0;

	//  ===============================================================================================
	//	ref ***��Чʱ��***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref aoi �г��ź���Чʱ��
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	interrupt_en_int �ڲ��ж�ʹ��
	//	1.���ж���Чʱ����������
	//	2.��fval�����ص�ʱ�򣬲��ܸ��£�Ϊ���Ǳ�֤����֡
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_interrupt_en) begin
			interrupt_en_int	<= 1'b0;
		end
		else if(fval_rise) begin
			interrupt_en_int	<= i_interrupt_en;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	Mono8		- 0x01080001	-> 0x1081	-> 0001,0000,1000,,,,0001
	//	Mono10		- 0x01100003	-> 0x1103	-> 0001,0001,0000,,,,0011
	//	BayerGR8	- 0x01080008	-> 0x1088	-> 0001,0000,1000,,,,1000
	//	BayerGR10	- 0x0110000C	-> 0x110C	-> 0001,0001,0000,,,,1100
	//											   --------!-!-------!!!!
	//                                                     ^    ^       ^------bit0
	//                                             bit20---|    |---bit16
	//	����� ! �ģ����ǲ���Ƚϵ�bit.�ֱ��� bit
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	mono_sel
	//	1.�ж����ظ�ʽ�Ƿ�ѡ�кڰ�ģʽ
	//	2.ʹ��6bit�ж�����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case({iv_pixel_format[20],iv_pixel_format[19],iv_pixel_format[3:0]})
			6'b010001	: mono_sel	<= 1'b1;
			6'b100011	: mono_sel	<= 1'b1;
			default		: mono_sel	<= 1'b0;
		endcase
	end

	//  -------------------------------------------------------------------------------------
	//	�жϿ����Ƿ�Ϊ0�����Ϊ0����ȡ��ʹ��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(wb_offset_width_reg=={WB_OFFSET_WIDTH{1'b0}} || wb_offset_height_reg=={WB_OFFSET_WIDTH{1'b0}}) begin
			width_height_0	<= 1'b1;
		end
		else begin
			width_height_0	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	aoi �г� �ź����ʹ��
	//	1.���ڲ��ж��ź�=1 �� ���ظ�ʽ�ǲ�ɫ�� �� δѡ�в���ͼ��ʱ�򣬲��ܹ����aoi�г��ź�
	//	2.�ڲ��ж��ź��ڰ�ƽ��ģ���ڲ�����Чʱ�������ظ�ʽ�Ͳ���ͼѡ��Ĵ����������ⲿ������Чʱ��
	//	3.��ͼ����߲���0ʱ
	//  -------------------------------------------------------------------------------------
	assign	aoi_enable	= (interrupt_en_int==1'b1 && mono_sel==1'b0 && iv_test_image_sel==3'b000 && width_height_0==1'b0) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	-- ref ������Ϣ��Чʱ��
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	�ڳ���Ч�����������洰��λ�üĴ���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_rise) begin
			wb_offset_x_start_reg	<= iv_wb_offset_x_start;
			wb_offset_width_reg		<= iv_wb_offset_width;
			wb_offset_y_start_reg	<= iv_wb_offset_y_start;
			wb_offset_height_reg	<= iv_wb_offset_height;
			//			wb_offset_x_end_reg		<= iv_wb_offset_x_start + iv_wb_offset_width;
			//			wb_offset_y_end_reg		<= iv_wb_offset_y_start + iv_wb_offset_height;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	���ж�ʹ�������ص�ʱ�򣬽��ڲ��Ŀ��߼Ĵ������浽�˿���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(int_pin_rise) begin
			wb_offset_width_latch	<= wb_offset_width_reg;
			wb_offset_height_latch	<= wb_offset_height_reg;
		end
	end
	assign	ov_wb_offset_width	= wb_offset_width_latch;
	assign	ov_wb_offset_height	= wb_offset_height_latch;

	//  -------------------------------------------------------------------------------------
	//	int_reg �ж����
	//	1.aoi_enable=0ʱ��o_interrupt_en���0
	//	2.aoi_enable=1ʱ����fval�½����ж�aoi_enable�Ƿ�ʹ��
	//	--2.1��aoi_enable=1ʱ��o_interrupt_en���1
	//	--2.2��aoi_enable=0ʱ��o_interrupt_en���0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!aoi_enable) begin
			int_reg	<= 1'b0;
		end
		else begin
			if(fval_fall) begin
				int_reg	<= aoi_enable;
			end
		end
	end
	assign	o_interrupt_en	= int_reg;

	//  ===============================================================================================
	//	ref ***x y ����ʹ��***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	--ref �뷽��ʹ����صļ�����
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	�м�����
	//	1.����Ч=0ʱ������������
	//	2.����Ч=1�����½�����Чʱ������������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_fval) begin
			line_cnt	<= {WB_OFFSET_WIDTH{1'b0}};
		end
		else begin
			if(lval_fall) begin
				line_cnt	<= line_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	���ؼ�����
	//	1.����Ч=0ʱ������������
	//	2.����Ч=1ʱ
	//	--2.1����Ч=0ʱ������������
	//	--2.2����Ч=1ʱ������������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_fval) begin
			pix_cnt	<= {WB_OFFSET_WIDTH{1'b0}};
		end
		else begin
			if(!i_lval) begin
				pix_cnt	<= {WB_OFFSET_WIDTH{1'b0}};
			end
			else if(i_lval) begin
				pix_cnt	<= pix_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	--ref x_enable ˮƽ����ʹ���ź�
	//	1.��AOIʹ���ź�=0ʱ��x_enable����
	//	2.��AOIʹ���ź�=1ʱ��������fval=1ʱ��pix_cnt=x�Ŀ�ʼλ��ʱ��x_enable=1
	//	3.��AOIʹ���ź�=1ʱ��������fval=1ʱ����pix_cnt=x�Ľ���λ��ʱ��x_enable=0
	//	4.��AOIʹ���ź�=1ʱ��������fval=0ʱ��x_enable����
	//	5.��fval�����ص�ʱ��ɼ�����Ĵ�����Ҫ��fval���ӳ��ź���Ϊʹ�ܣ������ʹ����һ�ε�����ֵ
	//	6.������������������end<start�����֡��y_enable�ź�����쳣����֡ͳ�ƽ������
	//	7.ע��˴�������fval_dly0����Ϊaoi_enable����fval_dly0��ͬ��λ��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!aoi_enable) begin
			x_enable	<= 1'b0;
		end
		else begin
			if(fval_dly0) begin
				if(i_lval) begin
					if(pix_cnt==wb_offset_x_start_reg) begin
						x_enable	<= 1'b1;
					end
					else if(pix_cnt==(wb_offset_x_start_reg+wb_offset_width_reg)) begin
						x_enable	<= 1'b0;
					end
				end
				else begin
					x_enable	<= 1'b0;
				end
			end
			else begin
				x_enable	<= 1'b0;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	--ref y_enable ˮƽ����ʹ���ź�
	//	1.��AOIʹ���ź�=0ʱ��y_enable����
	//	2.��AOIʹ���ź�=1ʱ��������fval=1ʱ��line_cnt=y�Ŀ�ʼλ��ʱ��y_enable=1
	//	3.��AOIʹ���ź�=1ʱ��������fval=1ʱ����line_cnt=y�Ľ���λ��ʱ��y_enable=0
	//	4.��AOIʹ���ź�=1ʱ��������fval=0ʱ��y_enable����
	//	5.��fval�����ص�ʱ��ɼ�����Ĵ�����Ҫ��fval���ӳ��ź���Ϊʹ�ܣ������ʹ����һ�ε�����ֵ
	//	6.������������������end<start�����֡��y_enable�ź�����쳣����֡ͳ�ƽ������
	//	7.ע��˴�������fval_dly0����Ϊaoi_enable����fval_dly0��ͬ��λ��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!aoi_enable) begin
			y_enable	<= 1'b0;
		end
		else begin
			if(fval_dly0) begin
				if(line_cnt==wb_offset_y_start_reg) begin
					y_enable	<= 1'b1;
				end
				else if(line_cnt==(wb_offset_y_start_reg+wb_offset_height_reg)) begin
					y_enable	<= 1'b0;
				end
			end
			else begin
				y_enable	<= 1'b0;
			end
		end
	end

	//  ===============================================================================================
	//	ref ***���***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	lval �����ʱ2��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_reg	<= x_enable&y_enable;
	end
	assign	o_lval	= lval_reg;
	assign	o_fval	= fval_dly1;

	//  -------------------------------------------------------------------------------------
	//	��ɫ�����������Ҳ�ӳ�3�ģ������������ʹ��ʱ�������
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	R ���� �ӳ�2�����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		r_flag_dly0	<= i_r_flag;
	end
	always @ (posedge clk) begin
		if(x_enable&y_enable) begin
			r_flag_reg	<= r_flag_dly0;
		end
		else begin
			r_flag_reg	<= 1'b0;
		end
	end
	assign	o_r_flag	= r_flag_reg;

	//  -------------------------------------------------------------------------------------
	//	G ���� �ӳ�2�����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		g_flag_dly0	<= i_g_flag;
	end
	always @ (posedge clk) begin
		if(x_enable&y_enable) begin
			g_flag_reg	<= g_flag_dly0;
		end
		else begin
			g_flag_reg	<= 1'b0;
		end
	end
	assign	o_g_flag	= g_flag_reg;

	//  -------------------------------------------------------------------------------------
	//	B ���� �ӳ�2�����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		b_flag_dly0	<= i_b_flag;
	end
	always @ (posedge clk) begin
		if(x_enable&y_enable) begin
			b_flag_reg	<= b_flag_dly0;
		end
		else begin
			b_flag_reg	<= 1'b0;
		end
	end
	assign	o_b_flag	= b_flag_reg;

	//  -------------------------------------------------------------------------------------
	//	����������ӳ�2��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		pix_data_dly0	<= iv_pix_data;
		pix_data_dly1	<= pix_data_dly0;
	end
	assign	ov_pix_data	= pix_data_dly1;



endmodule