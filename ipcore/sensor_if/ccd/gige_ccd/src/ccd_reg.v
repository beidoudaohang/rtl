
//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : ccd_reg.v
//  -- �����       : ��
//-------------------------------------------------------------------------------------------------
//
//  --�޸ļ�¼  :
//
//  -- ����         :| �޸�����     :|  �޸�˵��
//---------------------------------------------------------------------------------------
//  -- ��       	:| 09/16/2013   :|  ��ʼ�汾
//  -- ��Сƽ      	:| 04/29/2015   :|  �����޸ģ���Ӧ��ICX445 sensor
//
//---------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale      1ns/100ps
//-------------------------------------------------------------------------------------------------

`include "SHARP_RJ33J3_DEF.v"

module ccd_reg (
	input                                   		clk      			,   //ʱ��
	input											reset				,	//��λ������Ч
	input                                   		i_reg_active    	,   //
	input		[`FRAME_WD-1:0]						iv_frame_period		,   //֡���ڼĴ���
	input		[`FRAME_WD-1:0]						iv_headblank_end	,   //
	input		[`FRAME_WD-1:0]						iv_vref_start		,   //ROI��ʼ����
	input		[`FRAME_WD-1:0]						iv_tailblank_start	,   //ROI��������
	input		[`FRAME_WD-1:0]						iv_tailblank_end	,   //
	input		[`FRAME_WD-1:0]						iv_exp_line			,	//
	input		[`EXP_WD-1:0]						iv_exp_reg			,   //�ع�׶�ʱ�Ӹ����Ĵ���

	output	reg	[`FRAME_WD-1:0]						ov_frame_period		,   //֡���ڼĴ���
	output	reg	[`FRAME_WD-1:0]						ov_headblank_end	,   //֡���ڼĴ���
	output	reg	[`FRAME_WD-1:0]						ov_vref_start		,   //ROI��ʼ����
	output	reg	[`FRAME_WD-1:0]						ov_tailblank_start	,   //ROI��������
	output	reg	[`FRAME_WD-1:0]						ov_tailblank_end	,   //֡���ڼĴ���
	output	reg	[22:0]								ov_tailblank_num	,	//
	output	reg	[22:0]								ov_headblank_num	,	//
	output	reg	[`FRAME_WD-1:0]						ov_exp_start_reg	,	//�ع���ʼ��λ�üĴ���
	output	reg	[`EXP_WD-1:0]						ov_exp_line_reg		,	//�ع�����ʱ�Ӹ����Ĵ���
	output	reg	[`EXP_WD-1:0]						ov_exp_reg			,   //�ع�ʱ�Ӹ����Ĵ���
	output	reg	[`EXP_WD-1:0]						ov_exp_xsg_reg			//�ع�xsgʱ�Ӹ����Ĵ���
	);

	//  ===============================================================================================
	//  ��һ���֣�ģ�������Ҫ�õ����ź�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  �Ĵ�������������
	//  -------------------------------------------------------------------------------------
	reg										reg_active_dly_0	;
	wire		[`FRAME_WD-1:0]				frame_period		;
	wire		[`EXP_WD-1:0]				exp_line_reg		;
	wire		[22:0]						wv_headblank_num	;
	wire		[22:0]						wv_tailblank_num	;

	//  ===============================================================================================
	//  �ڶ����֣�ģ��ʵ����
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  ����˵���� ���ع������ʹ�ó˷���������Ӻ�1�����ڣ�
	//  -------------------------------------------------------------------------------------
	line_exp_mult line_exp_mult_inst (
	.clk					(clk									), 	//ʱ��
	.a						({3'b0,iv_exp_line}						), 	//������
	.b						(`LINE_PIX								), 	//������
	.p						(exp_line_reg							)	//�ع�����ʱ�Ӹ����Ĵ���
	);

	//  -------------------------------------------------------------------------------------
	//  ����˵���� ��ͷ�շ�����
	//  -------------------------------------------------------------------------------------
	blank_mult headblank_mult_inst (
	.clk					(clk									), 	//ʱ��
	.a						({3'b0,(ov_headblank_end - `FRAME_WD'd8)}		), 		//ICX445, XSG(2) + DUMMY(2) ������,�������еĵ�6�п�ʼ���п췭
	.b						(4'd8									), 	//
	.p						(wv_headblank_num						)	//
	);

	//  -------------------------------------------------------------------------------------
	//  ����˵���� ��β�շ�����
	//  -------------------------------------------------------------------------------------
	blank_mult tailblank_mult_inst (
	.clk					(clk									), 	//ʱ��
	.a						({3'b0,(iv_tailblank_end - iv_tailblank_start)}	), 	//������
	.b						(4'd8									), 	//
	.p						(wv_tailblank_num						)	//
	);

	//  ===============================================================================================
	//  �������֣��߼�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  ����˵������ʱ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			reg_active_dly_0 	<= 1'b0;
		end
		else begin
			reg_active_dly_0 	<= i_reg_active;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  ����˵����readout����Ĵ���
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//  ���icx445����ʼ���У�2(XSG)+2(DUMMY)+8(BLACK)   ��������ǽ������صĵ�10�п�ʼ���п췭
	//                    ʹ�ó�ͷ�����ؽ��к�����ǯλ�����bug  ID148��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			ov_headblank_end 	<= 	`HEADBLANK_END_DEFVALUE;
			ov_vref_start 		<= 	`VSYNC_START_DEFVALUE;
			ov_tailblank_start 	<= 	`TAILBLANK_START_DEFVALUE;
			ov_tailblank_end 	<= 	`TAILBLANK_END_DEFVALUE;
			ov_tailblank_num	<=	23'd0;
			ov_headblank_num	<=	23'd0;
		end
		else if(reg_active_dly_0) begin
			ov_headblank_end 	<= 	iv_headblank_end + `FRAME_WD'd6;	//������14�к�ʼ���п췭 ��
			ov_vref_start 		<= 	iv_vref_start;
			ov_tailblank_start 	<= 	iv_tailblank_start;
			ov_tailblank_end 	<= 	iv_tailblank_end;
			ov_headblank_num	<=	wv_headblank_num;
			ov_tailblank_num	<=	wv_tailblank_num;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  ����˵�����ع���ؼĴ���
	//  ���ع�ʱ���֡�������ʱ���ع���ʼ�źŲ��ܴ�xsg��ʼ��xsgռ����4�У�
	//  -------------------------------------------------------------------------------------

	//		assign	frame_period	=	(iv_exp_line >= iv_frame_period)	?	(iv_exp_line + `FRAME_WD'd4)	:	(iv_frame_period + `FRAME_WD'd4)	;
	assign	frame_period	=	((iv_exp_line + `FRAME_WD'd4) >= iv_frame_period)	?	(iv_exp_line + `FRAME_WD'd4)	:	iv_frame_period 	;

	always @ (posedge clk) begin
		if(reset) begin
			ov_frame_period 	<= 	`FRAME_PERIOD_DEFVALUE;
			ov_exp_start_reg	<=	`EXPOSURE_START_LINE;
		end
		else if(reg_active_dly_0) begin
			ov_frame_period 	<= 	frame_period;
			ov_exp_start_reg 	<= 	frame_period - iv_exp_line;
		end
	end

	always @ (posedge clk) begin
		if(reset) begin
			ov_exp_line_reg		<= 	`EXPOSURE_LINE_REG_DEFVALUE;
			ov_exp_reg			<= 	`EXPOSURE_REG_DEFVALUE;
			ov_exp_xsg_reg		<=	`EXPOSURE_REG_DEFVALUE - `EXPOSURE_LINE_REG_DEFVALUE;
		end
		else if(reg_active_dly_0) begin
			ov_exp_line_reg		<= 	exp_line_reg;
			ov_exp_reg			<= 	iv_exp_reg;
			ov_exp_xsg_reg		<= 	iv_exp_reg - exp_line_reg;
		end
	end

endmodule