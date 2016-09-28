//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : linesource_and_useroutput
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/12/1 14:40:40	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :ѡ��������źš��û��Զ������ģ��
//              1)  : ��������3��useroutputֵ
//
//              2)  : ����3�������ÿһ��line�������4��ѡ��
//						�ֱ�������ƺ�3���Զ����ƽ
//              3)  :
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module linesource_and_useroutput (
	//ʱ��
	input				clk					,	//ʱ���ź�
	//����ģ������
	input				i_strobe			,	//�����˲����������ź�
	//�Ĵ����ź�
	input	[2:0]		iv_useroutput_level	,	//����3��useroutputֵ��bit0-useroutput0��bit1-useroutput1��bit2-useroutput2
	input	[2:0]		iv_line_source1		,	//line1���Դ��0-�ر�(��֧��)��1-�ع⣬2-useroutput0��3-useroutput1��4-useroutput2
	input	[2:0]		iv_line_source2		,	//line2���Դ��0-�ر�(��֧��)��1-�ع⣬2-useroutput0��3-useroutput1��4-useroutput2
	input	[2:0]		iv_line_source3		,	//line3���Դ��0-�ر�(��֧��)��1-�ع⣬2-useroutput0��3-useroutput1��4-useroutput2
	//���������FPGAģ��
	output	[2:0]		ov_lineout				//����ѡ��֮���line����źţ�line0 2 3
	);

	//	ref signals
	reg		[2:0]		lineout		= 3'b0;

	//	ref ARCHITECTURE
	//  -------------------------------------------------------------------------------------
	//	line1���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(iv_line_source1)
			3'b001	: lineout[0]	<= i_strobe;
			3'b010	: lineout[0]	<= iv_useroutput_level[0];
			3'b011	: lineout[0]	<= iv_useroutput_level[1];
			3'b100	: lineout[0]	<= iv_useroutput_level[2];
			default	: lineout[0]	<= iv_useroutput_level[0];
		endcase
	end

	//  -------------------------------------------------------------------------------------
	//	line2���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(iv_line_source2)
			3'b001	: lineout[1]	<= i_strobe;
			3'b010	: lineout[1]	<= iv_useroutput_level[0];
			3'b011	: lineout[1]	<= iv_useroutput_level[1];
			3'b100	: lineout[1]	<= iv_useroutput_level[2];
			default	: lineout[1]	<= iv_useroutput_level[0];
		endcase
	end
	
	//  -------------------------------------------------------------------------------------
	//	line3���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(iv_line_source3)
			3'b001	: lineout[2]	<= i_strobe;
			3'b010	: lineout[2]	<= iv_useroutput_level[0];
			3'b011	: lineout[2]	<= iv_useroutput_level[1];
			3'b100	: lineout[2]	<= iv_useroutput_level[2];
			default	: lineout[2]	<= iv_useroutput_level[0];
		endcase
	end	
	assign	ov_lineout	= lineout;





endmodule
