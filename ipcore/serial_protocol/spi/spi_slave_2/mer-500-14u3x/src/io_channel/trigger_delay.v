//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : trigger_delay
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/12/1 13:26:13	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :��ʱģ��
//              1)  :�����źŵĿ�����1��ʱ��
//
//              2)  :����źŵĿ�����1��ʱ��
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module trigger_delay # (
	parameter		TRIG_DELAY_WIDTH		= 28			//�����ź���ʱģ��Ĵ�������
	)
	(
	//ϵͳ����
	input							clk					,	//ʱ��72MHz
	//�Ĵ�������
	input	[TRIG_DELAY_WIDTH-1:0]	iv_trigger_delay	,	//�ӳٲ���
	//FPGAģ���ź�
	input							i_din				,	//����Ĵ����źţ�һ���ߵ�ƽ����
	output							o_dout					//����Ĵ����źţ�һ���ߵ�ƽ����
	);


	//	ref signals
	reg		[TRIG_DELAY_WIDTH-1:0]		trigger_delay_reg	= {TRIG_DELAY_WIDTH{1'b0}};
	reg		[TRIG_DELAY_WIDTH-1:0]		trigger_delay_cnt	= {TRIG_DELAY_WIDTH{1'b0}};
	reg									delaying			= 1'b0;
	reg									delaying_dly		= 1'b0;
	reg									delaying_fall		= 1'b0;
	
	
	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	�������ӳټĴ�����0ʱ�����ܸ��´����ӳټĴ���
	//	1.�ӳ�ģ����С�ӳ�1��ʱ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(trigger_delay_cnt=={TRIG_DELAY_WIDTH{1'b0}}) begin
			trigger_delay_reg	<= iv_trigger_delay+1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	�����ӳٵı�־
	//	1.���ӳټ��������ӳټĴ������ʱ�����0
	//	2.�������ź���1ʱ�����1
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(trigger_delay_cnt==trigger_delay_reg) begin
			delaying	<= 1'b0;
		end
		else if(i_din) begin
			delaying	<= 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	�ӳټ�����
	//	1.���ӳټ��������ӳټĴ������ʱ���ӳټ���������
	//	2.�������ӳٱ�־=1ʱ���ӳټ�����+1
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(trigger_delay_cnt==trigger_delay_reg) begin
			trigger_delay_cnt	<= {TRIG_DELAY_WIDTH{1'b0}};
		end
		else if(delaying) begin
			trigger_delay_cnt	<= trigger_delay_cnt + 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	��delaying�½���ʱ������1bit����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		delaying_dly	<= delaying;
	end

	always @ (posedge clk) begin
		if(delaying_dly==1'b1 && delaying==1'b0) begin
			delaying_fall	<= 1'b1;
		end
		else begin
			delaying_fall	<= 1'b0;
		end
	end
	assign	o_dout	= delaying_fall;






endmodule