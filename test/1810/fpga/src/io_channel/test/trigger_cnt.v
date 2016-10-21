//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : trigger_cnt
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/5/19 15:57:07	:|  ��ʼ�汾
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

module trigger_cnt (
	input				clk						,	//ʱ��

	input				i_trigger_mode			,	//����ģʽ��0-����ģʽ��1-����ģʽ
	input				i_stream_enable			,	//��ʹ���ź�
	input				i_acquisition_start		,	//�����źţ�0-ͣ�ɣ�1-����

	input				i_linein_sel			,	//trigger_sel֮����ź�
	input				i_linein_filter			,	//trigger_filter֮����ź�
	input				i_linein_active			,	//trigger_active֮����ź�
	input				i_trigger_n				,	//�����trigger�ź�
	input				i_trigger_soft			,	//�����ź�

	output	[15:0]		ov_linein_sel_rise_cnt		,	//i_linein_sel�������ؼ�����
	output	[15:0]		ov_linein_sel_fall_cnt		,	//i_linein_sel���½��ؼ�����
	output	[15:0]		ov_linein_filter_rise_cnt	,	//i_linein_filter�������ؼ�����
	output	[15:0]		ov_linein_filter_fall_cnt	,	//i_linein_filter���½��ؼ�����
	output	[15:0]		ov_linein_active_cnt		,	//i_linein_active�������ؼ�����
	output	[15:0]		ov_trigger_n_rise_cnt		,	//i_trigger_n�������ؼ�����
	output	[15:0]		ov_trigger_soft_cnt				//i_trigger_soft�ļ�����

	);

	//	ref signals

	reg					enable			= 1'b0;
	reg					linein_sel_dly	= 1'b0;
	wire				linein_sel_rise	;
	wire				linein_sel_fall	;
	reg					linein_filter_dly	= 1'b0;
	wire				linein_filter_rise	;
	wire				linein_filter_fall	;
	reg					trigger_n_dly	= 1'b0;
	wire				trigger_n_rise	;

	reg		[15:0]		linein_sel_rise_cnt	= 16'b0;
	reg		[15:0]		linein_sel_fall_cnt	= 16'b0;
	reg		[15:0]		linein_filter_rise_cnt	= 16'b0;
	reg		[15:0]		linein_filter_fall_cnt	= 16'b0;
	reg		[15:0]		linein_active_cnt	= 16'b0;
	reg		[15:0]		trigger_n_rise_cnt	= 16'b0;
	reg		[15:0]		trigger_soft_cnt	= 16'b0;

	//	ref ARCHITECTURE


	//synchronous clock domain

	//	===============================================================================================
	//	ref ***�ж�ʹ��***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ʹ���źţ���ioͨ�������1��ģ�����������
	//	1.������ʹ���źŶ�ʹ��ʱ�����1
	//	2.������ʹ���ź���1����0ʱ�����0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		enable	<= i_trigger_mode&i_stream_enable&i_acquisition_start;
	end

	//	===============================================================================================
	//	ref ***��ȡ����***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	line sel ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		linein_sel_dly	<= i_linein_sel;
	end
	assign	linein_sel_rise	= (linein_sel_dly==1'b0 && i_linein_sel==1'b1) ? 1'b1 : 1'b0;
	assign	linein_sel_fall	= (linein_sel_dly==1'b1 && i_linein_sel==1'b0) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	line filter ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		linein_filter_dly	<= i_linein_filter;
	end
	assign	linein_filter_rise	= (linein_filter_dly==1'b0 && i_linein_filter==1'b1) ? 1'b1 : 1'b0;
	assign	linein_filter_fall	= (linein_filter_dly==1'b1 && i_linein_filter==1'b0) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	trigger ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		trigger_n_dly	<= i_trigger_n;
	end
	assign	trigger_n_rise	= (trigger_n_dly==1'b0 && i_trigger_n==1'b1) ? 1'b1 : 1'b0;

	//	===============================================================================================
	//	ref ***����***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	line sel ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!enable) begin
			linein_sel_rise_cnt	<= 'b0;
		end
		else begin
			if(linein_sel_rise) begin
				linein_sel_rise_cnt	<= linein_sel_rise_cnt + 1'b1;
			end
		end
	end
	assign	ov_linein_sel_rise_cnt	= linein_sel_rise_cnt;

	always @ (posedge clk) begin
		if(!enable) begin
			linein_sel_fall_cnt	<= 'b0;
		end
		else begin
			if(linein_sel_fall) begin
				linein_sel_fall_cnt	<= linein_sel_fall_cnt + 1'b1;
			end
		end
	end
	assign	ov_linein_sel_fall_cnt	= linein_sel_fall_cnt;

	//	-------------------------------------------------------------------------------------
	//	line filter ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!enable) begin
			linein_filter_rise_cnt	<= 'b0;
		end
		else begin
			if(linein_filter_rise) begin
				linein_filter_rise_cnt	<= linein_filter_rise_cnt + 1'b1;
			end
		end
	end
	assign	ov_linein_filter_rise_cnt	= linein_filter_rise_cnt;

	always @ (posedge clk) begin
		if(!enable) begin
			linein_filter_fall_cnt	<= 'b0;
		end
		else begin
			if(linein_filter_fall) begin
				linein_filter_fall_cnt	<= linein_filter_fall_cnt + 1'b1;
			end
		end
	end
	assign	ov_linein_filter_fall_cnt	= linein_filter_fall_cnt;

	//	-------------------------------------------------------------------------------------
	//	line active ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!enable) begin
			linein_active_cnt	<= 'b0;
		end
		else begin
			if(i_linein_active) begin
				linein_active_cnt	<= linein_active_cnt + 1'b1;
			end
		end
	end
	assign	ov_linein_active_cnt	= linein_active_cnt;

	//	-------------------------------------------------------------------------------------
	//	trigger_n ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!enable) begin
			trigger_n_rise_cnt	<= 'b0;
		end
		else begin
			if(trigger_n_rise) begin
				trigger_n_rise_cnt	<= trigger_n_rise_cnt + 1'b1;
			end
		end
	end
	assign	ov_trigger_n_rise_cnt	= trigger_n_rise_cnt;

	//	-------------------------------------------------------------------------------------
	//	trigger soft ����
	//	1.1bit���壬������ȡ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!enable) begin
			trigger_soft_cnt	<= 'b0;
		end
		else begin
			if(i_trigger_soft) begin
				trigger_soft_cnt	<= trigger_soft_cnt + 1'b1;
			end
		end
	end
	assign	ov_trigger_soft_cnt	= trigger_soft_cnt;


endmodule
