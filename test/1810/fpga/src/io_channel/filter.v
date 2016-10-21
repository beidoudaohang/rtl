//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : filter
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/12/1 13:22:57	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :ʵ�ֶ������źŵ��˲�����
//              1)  : ���±��طֱ��˲�
//
//              2)  : �����˲�ʱ����10��ʱ��
//
//              3)  :
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module filter # (
	parameter		TRIG_FILTER_WIDTH					= 19	//�����ź��˲�ģ��Ĵ������
	)
	(
	//ϵͳ�ź�
	input								clk					,	//ʱ�ӣ�72MHz
	//�Ĵ�������
	input	[TRIG_FILTER_WIDTH-1:0]		iv_filter_rise		,	//�������˲�����
	input	[TRIG_FILTER_WIDTH-1:0]		iv_filter_fall		,	//�½����˲�����
	//FPGAģ���ź�
	input								i_din				,	//�˲�ģ������
	output								o_dout					//�˲�ģ�����
	);

	//	ref signals

	localparam							FIXED_FILTER_NUM	= 10;	//�̶����˲�����

	reg		[TRIG_FILTER_WIDTH-1:0]		filter_rise_reg		= {TRIG_FILTER_WIDTH{1'b0}};	//�ɱ���������˲��Ĵ���
	reg		[TRIG_FILTER_WIDTH-1:0]		filter_fall_reg		= {TRIG_FILTER_WIDTH{1'b0}};	//�ɱ���½����˲��Ĵ���
	reg		[TRIG_FILTER_WIDTH-1:0]		filter_rise_cnt		= {TRIG_FILTER_WIDTH{1'b0}};	//�ɱ���������˲�������
	reg		[TRIG_FILTER_WIDTH-1:0]		filter_fall_cnt		= {TRIG_FILTER_WIDTH{1'b0}};	//�ɱ���½����˲�������
	reg									filter_sig			= 1'b0;	//�ɱ䳤���˲�����ź�


	//	ref ARCHITECTURE
	//  -------------------------------------------------------------------------------------
	//	filterģ���ڵ��˲��������ص���ʼ״̬ʱ�����ܸ����˲������Ĵ���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(filter_rise_cnt=={TRIG_FILTER_WIDTH{1'b0}}) begin
			filter_rise_reg	<= iv_filter_rise + (FIXED_FILTER_NUM-1);
		end
	end

	always @ (posedge clk) begin
		if(filter_fall_cnt=={TRIG_FILTER_WIDTH{1'b0}}) begin
			filter_fall_reg	<= iv_filter_fall + (FIXED_FILTER_NUM-1);
		end
	end

	//  -------------------------------------------------------------------------------------
	//	�������˲�������
	//	1.�������ź���0ʱ�������ؼ���������
	//	2.�������ź���1ʱ�������ؼ���������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_din) begin
			filter_rise_cnt	<= {TRIG_FILTER_WIDTH{1'b0}};
		end
		else if(i_din) begin
			if(filter_rise_cnt==filter_rise_reg) begin
				filter_rise_cnt	<= filter_rise_cnt;
			end
			else begin
				filter_rise_cnt	<= filter_rise_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	�½����˲�������
	//	1.�������ź���1ʱ���½��ؼ���������
	//	2.�������ź���0ʱ���½��ؼ���������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_din) begin
			filter_fall_cnt	<= {TRIG_FILTER_WIDTH{1'b0}};
		end
		else if(!i_din) begin
			if(filter_fall_cnt==filter_fall_reg) begin
				filter_fall_cnt	<= filter_fall_cnt;
			end
			else begin
				filter_fall_cnt	<= filter_fall_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	���
	//	1.�������ؼ�����=�̶��˲����� �� �����ź���1�����1
	//	1.���½����ؼ�����=�̶��˲����� �� �����ź���0�����0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(filter_rise_cnt==filter_rise_reg && i_din==1'b1) begin
			filter_sig	<= 1'b1;
		end
		else if(filter_fall_cnt==filter_fall_reg && i_din==1'b0) begin
			filter_sig	<= 1'b0;
		end
	end

	assign	o_dout	= filter_sig;





endmodule

