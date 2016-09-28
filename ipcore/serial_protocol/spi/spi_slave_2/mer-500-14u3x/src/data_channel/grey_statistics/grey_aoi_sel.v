//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : grey_aoi_sel
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/3/18 15:21:40	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : �Ҷ�ͳ�ƴ��� �жϹ���
//              1)  : ���ݹ̼����õĴ��ڣ����aoi �г��ź�
//
//              2)  : �����ж�
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module grey_aoi_sel # (
	parameter						SENSOR_DAT_WIDTH	= 10	,	//sensor ���ݿ��
	parameter						GREY_OFFSET_WIDTH	= 12		//�Ҷ�ͳ��ģ��ƫ��λ�üĴ������
	)
	(
	//Sensor�����ź�
	input								clk						,	//����ʱ��
	input								i_fval					,	//���ź�
	input								i_lval					,	//���ź�
	input	[SENSOR_DAT_WIDTH-1:0]		iv_pix_data				,	//ͼ������
	//�Ҷ�ͳ����ؼĴ���
	input								i_interrupt_en			,	//2A�ж�ʹ�ܣ�2Aָ�����Զ��ع���Զ����棬������������FPGA����һ��ģ��ʵ�֣�������Ҫ��������һ��ܣ��ͱ���򿪸��ж������ʹ�ܸ��жϣ����ر�2Aģ�飬�Խ�ʡ����
	input	[2:0]						iv_test_image_sel		,	//����ͼѡ��Ĵ���,000:��ʵͼ,001:����ͼ��1�Ҷ�ֵ֡����,110:����ͼ��2��ֹ��б����,010:����ͼ��3������б����
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_x_start	,	//�Ҷ�ֵͳ�������x������ʼ�㣬�̼����õĸüĴ���ֵӦ���������ROI��ƫ��
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_width	,	//�Ҷ�ֵͳ������Ŀ��
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_y_start	,	//�Ҷ�ֵͳ�������y������ʼ�㣬�̼����õĸüĴ���ֵӦ���������ROI��ƫ��
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_height	,	//�Ҷ�ֵͳ������ĸ߶�
	output	[GREY_OFFSET_WIDTH-1:0]		ov_grey_offset_width	,	//������ͳ�ƴ��ڣ��Ҷ�ֵͳ������Ŀ��
	output	[GREY_OFFSET_WIDTH-1:0]		ov_grey_offset_height	,	//������ͳ�ƴ��ڣ��Ҷ�ֵͳ������ĸ߶�
	//����ģ�齻��
	output								o_interrupt_en			,	//�����ж�=0��o_interrupt_en=0��һ֡ͳ����Чʱ����i_fval�½��أ�o_interrupt_en=1
	input								i_interrupt_pin			,	//�ж�ģ��������ж��źţ�1-�ж���Ч�����ж�������ʱ������Ҷ�ͳ��ֵ�ʹ��ڼĴ������˿�
	output								o_fval					,	//����Ч
	output								o_lval					,	//����Ч
	output	[SENSOR_DAT_WIDTH-1:0]		ov_pix_data					//ͼ������
	);

	//	ref signals
	reg									lval_dly0				= 1'b0;
	reg									lval_reg				= 1'b0;
	wire								lval_fall				;
	reg									fval_dly0				= 1'b0;
	reg									fval_dly1				= 1'b0;
	wire								fval_rise				;
	wire								fval_fall				;
	reg									int_pin_dly				= 1'b0;
	wire								int_pin_rise			;
	reg									interrupt_en_int		= 1'b0;
	reg									int_reg					= 1'b0;
	wire								aoi_enable				;
	reg									width_height_0			= 1'b0;
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_x_start_reg	= {GREY_OFFSET_WIDTH{1'b0}};
	//	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_x_end_reg	= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_width_reg	= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_y_start_reg	= {GREY_OFFSET_WIDTH{1'b0}};
	//	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_y_end_reg	= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_height_reg	= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_width_latch	= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_height_latch= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		line_cnt				= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		pix_cnt					= {GREY_OFFSET_WIDTH{1'b0}};
	reg									x_enable				= 1'b0;
	reg									y_enable				= 1'b0;
	reg		[SENSOR_DAT_WIDTH-1:0]		pix_data_dly0			= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		pix_data_dly1			= {SENSOR_DAT_WIDTH{1'b0}};


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
	//	�жϿ���Ƿ�Ϊ0�����Ϊ0����ȡ��ʹ��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(grey_offset_width_reg=={GREY_OFFSET_WIDTH{1'b0}} || grey_offset_height_reg=={GREY_OFFSET_WIDTH{1'b0}}) begin
			width_height_0	<= 1'b1;
		end
		else begin
			width_height_0	<= 1'b0;
		end
	end
	
	//  -------------------------------------------------------------------------------------
	//	aoi �г� �ź����ʹ��
	//	1.���ڲ��ж��ź�=1 �� δѡ�в���ͼ��ʱ�򣬲��ܹ����aoi�г��ź�
	//	2.�ڲ��ж��ź��ڻҶ�ͳ��ģ���ڲ�����Чʱ��������ͼѡ��Ĵ��������ⲿ������Чʱ��
	//	3.��ͼ���߲���0ʱ
	//  -------------------------------------------------------------------------------------
	assign	aoi_enable	= (interrupt_en_int==1'b1 && iv_test_image_sel==3'b000 && width_height_0==1'b0) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	-- ref ������Ϣ��Чʱ��
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	�ڳ���Ч�����������洰��λ�üĴ���
	//	1.ͬʱ�����ֵ����ֵ��ӣ���Ϊ�����㡣����������2���Ĵ���
	//	2.�����������2���Ĵ���������if���ʽ�����ӷ�������߼���ʱ�ͻ����ӳ�.
	//		----����synplify��֤�������statisģ���е�64bit�ӷ��߼��ǹؼ�·������if���üӷ����ʽҲ������ɶ������ʱ��
	//	3.������Ĵ����������������������֮�������˵���̼����ڸı䴰�ڣ���ʱͳ��������д�������һ֡ʱ�ͻ�ָ�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_rise) begin
			grey_offset_x_start_reg	<= iv_grey_offset_x_start;
			grey_offset_width_reg	<= iv_grey_offset_width;
			grey_offset_y_start_reg	<= iv_grey_offset_y_start;
			grey_offset_height_reg	<= iv_grey_offset_height;
			//			grey_offset_x_end_reg	<= iv_grey_offset_x_start + iv_grey_offset_width;
			//			grey_offset_y_end_reg	<= iv_grey_offset_y_start + iv_grey_offset_height;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	���ж�ʹ�������ص�ʱ�򣬽��ڲ��Ŀ�߼Ĵ������浽�˿���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(int_pin_rise) begin
			grey_offset_width_latch	<= grey_offset_width_reg;
			grey_offset_height_latch<= grey_offset_height_reg;
		end
	end
	assign	ov_grey_offset_width	= grey_offset_width_latch;
	assign	ov_grey_offset_height	= grey_offset_height_latch;

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
			line_cnt	<= {GREY_OFFSET_WIDTH{1'b0}};
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
			pix_cnt	<= {GREY_OFFSET_WIDTH{1'b0}};
		end
		else begin
			if(!i_lval) begin
				pix_cnt	<= {GREY_OFFSET_WIDTH{1'b0}};
			end
			else begin
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
	//	6.������������������end<start�����֡��x_enable�ź�����쳣����֡ͳ�ƽ������
	//	7.ע��˴�������fval_dly0����Ϊaoi_enable����fval_dly0��ͬ��λ��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!aoi_enable) begin
			x_enable	<= 1'b0;
		end
		else begin
			if(i_fval) begin
				if(i_lval) begin
					if(pix_cnt==grey_offset_x_start_reg) begin
						x_enable	<= 1'b1;
					end
					else if(pix_cnt==(grey_offset_x_start_reg+grey_offset_width_reg)) begin
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
				if(line_cnt==grey_offset_y_start_reg) begin
					y_enable	<= 1'b1;
				end
				else if(line_cnt==(grey_offset_y_start_reg+grey_offset_height_reg)) begin
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
	//	lval ���һ����ʱ��2��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_reg	<= x_enable&y_enable;
	end
	assign	o_lval	= lval_reg;
	assign	o_fval	= fval_dly1;

	//  -------------------------------------------------------------------------------------
	//	�����������lval��Ҳ�ӳ�2��
	//	1.��Ҫ��λ������ʹ��LUT SRL�ṹ
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		pix_data_dly0	<= iv_pix_data;
		pix_data_dly1	<= pix_data_dly0;
	end
	assign	ov_pix_data	= pix_data_dly1;


endmodule
