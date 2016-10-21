//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : line_mode
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/12/1 10:10:06	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : �����������ͷ���Ĺ���
//              1)  : �ⲿ��4���ź��ߣ��ֱ�Ϊline0��line1��line2��line3
//
//              2)  : line0���롢line1�����line2 line3˫��
//
//              3)  :
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module line_mode_and_inverter (
	//ʱ��
	input				clk				,	//ʱ��
	//ǰ��ģ�黥���ź�
	input				i_optocoupler	,	//line0 ����
	input	[1:0]		iv_gpio			,	//line2 3 ˫���ź�����˿�
	output				o_optocoupler	,	//line1 ���
	output	[1:0]		ov_gpio			,	//line2 3 ˫���ź�����˿�
	//�Ĵ�������
	input				i_line2_mode	,	//line2���������ģʽ��0���룬1���
	input				i_line3_mode	,	//line3���������ģʽ��0���룬1���
	input				i_line0_invert	,	//0������1����
	input				i_line1_invert	,	//0������1����
	input				i_line2_invert	,	//0������1����
	input				i_line3_invert	,	//0������1����
	output	[3:0]		ov_line_status	,	//line״̬�Ĵ�����bit0-line0 bit1-line1 bit2-line2 bit3-line3����ӳ��·�ϵ�ʵ��״̬
	//��ģ�黥���ź�
	output	[2:0]		ov_linein		,	//3·�����ź� line0 2 3
	input	[2:0]		iv_lineout			//3·����ź� line1 2 3
	);

	//	ref signals
	//��������
	reg			line0_in_mode	= 1'b0;
	reg			line2_in_mode	= 1'b0;
	reg			line3_in_mode	= 1'b0;
	reg			line0_in_invert	= 1'b0;
	reg			line2_in_invert	= 1'b0;
	reg			line3_in_invert	= 1'b0;

	//�������
	reg			line1_out_invert	= 1'b0;
	reg			line2_out_invert	= 1'b0;
	reg			line3_out_invert	= 1'b0;
	reg			line1_out_mode	= 1'b0;
	reg			line2_out_mode	= 1'b0;
	reg			line3_out_mode	= 1'b0;

	//״̬�Ĵ���
	reg		[3:0]		line_status_reg	= 4'b0;


	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref ***��������***
	//  ===============================================================================================
	//  ===============================================================================================
	//	-- ref line mode �����������
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	line0�������źţ�����������������л�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		line0_in_mode	<= i_optocoupler;
	end

	//  -------------------------------------------------------------------------------------
	//	˫���źţ�����Ϊ���ʱ����������Ϊ0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_line2_mode) begin	//0-����
			line2_in_mode	<= iv_gpio[0];
		end
		else begin	//1-���
			line2_in_mode	<= 1'b0;
		end
	end

	always @ (posedge clk) begin
		if(!i_line3_mode) begin	//0-����
			line3_in_mode	<= iv_gpio[1];
		end
		else begin	//1-���
			line3_in_mode	<= 1'b0;
		end
	end

	//  ===============================================================================================
	//	-- ref line invert ���Կ���
	//  ===============================================================================================
	//	line0
	always @ (posedge clk) begin
		if(!i_line0_invert) begin	//0-������
			line0_in_invert	<= line0_in_mode;
		end
		else begin	//1-����
			line0_in_invert	<= !line0_in_mode;
		end
	end

	//	line2
	always @ (posedge clk) begin
		if(!i_line2_invert) begin	//0-������
			line2_in_invert	<= line2_in_mode;
		end
		else begin	//1-����
			line2_in_invert	<= !line2_in_mode;
		end
	end

	//	line3
	always @ (posedge clk) begin
		if(!i_line3_invert) begin	//0-������
			line3_in_invert	<= line3_in_mode;
		end
		else begin	//1-����
			line3_in_invert	<= !line3_in_mode;
		end
	end

	//  ===============================================================================================
	//	-- ref ���
	//  ===============================================================================================
	assign	ov_linein	= {line3_in_invert,line2_in_invert,line0_in_invert};

	//  ===============================================================================================
	//	ref ***�������***
	//  ===============================================================================================
	//  ===============================================================================================
	//	-- ref line invert ���Կ���
	//  ===============================================================================================
	//	line1
	always @ (posedge clk) begin
		if(!i_line1_invert) begin	//0-������
			line1_out_invert	<= iv_lineout[0];
		end
		else begin	//1-����
			line1_out_invert	<= !iv_lineout[0];
		end
	end

	//	line2
	always @ (posedge clk) begin
		if(!i_line2_invert) begin	//0-������
			line2_out_invert	<= iv_lineout[1];
		end
		else begin	//1-����
			line2_out_invert	<= !iv_lineout[1];
		end
	end

	//	line3
	always @ (posedge clk) begin
		if(!i_line3_invert) begin	//0-������
			line3_out_invert	<= iv_lineout[2];
		end
		else begin	//1-����
			line3_out_invert	<= !iv_lineout[2];
		end
	end

	//  ===============================================================================================
	//	-- ref line mode �����������
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	line1������źţ�����������������л�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		line1_out_mode	<= line1_out_invert;
	end

	//  -------------------------------------------------------------------------------------
	//	˫���źţ�����Ϊ����ʱ��Ҫ���0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_line2_mode) begin	//0-����
			line2_out_mode	<= 1'b0;
		end
		else begin	//1-���
			line2_out_mode	<= line2_out_invert;
		end
	end

	always @ (posedge clk) begin
		if(!i_line3_mode) begin	//0-����
			line3_out_mode	<= 1'b0;
		end
		else begin	//1-���
			line3_out_mode	<= line3_out_invert;
		end
	end

	//  ===============================================================================================
	//	-- ref �˿����
	//  ===============================================================================================
	assign	o_optocoupler	= line1_out_mode;
	assign	ov_gpio			= {line3_out_mode,line2_out_mode};

	//  ===============================================================================================
	//	ref ***line status ״̬�Ĵ���***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	1. line_status[0]��ӳline0������״̬����line_inverter֮��Circuit_dependentģ���Ѿ��Ե�·�����뷴�����˵�����
	//	2. line_status[1]��ӳline1�����״̬�����ڵ�·�з�������ã������line_inverter֮����ȡ��
	//	3. ��line2��Ϊ����ʱ��line_status[2]��ӳline2������״̬����line_inverter֮�󡣵�line2��Ϊ���ʱ��line_status[2]��ӳlne2�����״̬�����ڵ�·�з�������ã������line_inverter֮����ȡ��
	//	4. Status[3]��status[2]����
	//  -------------------------------------------------------------------------------------
	//	line0
	always @ (posedge clk) begin
		line_status_reg[0]	<= line0_in_invert;
	end
	//	line1
	always @ (posedge clk) begin
		line_status_reg[1]	<= !line1_out_invert;
	end
	//	line2
	always @ (posedge clk) begin
		if(!i_line2_mode) begin	//0-����
			line_status_reg[2]	<= line2_in_invert;
		end
		else begin	//1-���
			line_status_reg[2]	<= !line2_out_invert;
		end
	end
	//	line3
	always @ (posedge clk) begin
		if(!i_line3_mode) begin	//0-����
			line_status_reg[3]	<= line3_in_invert;
		end
		else begin	//1-���
			line_status_reg[3]	<= !line3_out_invert;
		end
	end

	//	���
	assign	ov_line_status	= line_status_reg;



endmodule
