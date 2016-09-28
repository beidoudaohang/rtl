
//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : mv_ccd.v
//  -- �����       : ��
//-------------------------------------------------------------------------------------------------
//
//  --�޸ļ�¼  :
//
//  -- ����         :| �޸�����     :|  �޸�˵��
//---------------------------------------------------------------------------------------
//  -- ��       	:| 09/17/2013   :|  ��ʼ�汾
//  -- ��Сƽ      	:| 04/29/2015   :|  �����޸ģ���Ӧ��ICX445 sensor
//  -- �Ϻ���      	:| 2015/12/7    :|  ��ֲ��u3ƽ̨
//---------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1)  :
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale      1ns/100ps
//-------------------------------------------------------------------------------------------------

`include "SHARP_RJ33J3_DEF.v"

module mv_ccd (
	input                                   		clk      				,   //ʱ��
	input											reset					,	//ʱ�Ӹ�λ������Ч
	input											i_acquisition_start		,	//clk_pixʱ���򣬿����źţ�0-ͣ�ɣ�1-����
	input											i_stream_enable			,	//clk_pixʱ������ʹ���źţ�0-ͣ�ɣ�1-����
	input											i_trigger				,   //��CCDģ��Ĵ����ź�
	input											i_triggermode			,   //��CCDģ��Ĳɼ�ģʽ�ź�
	input		[`LINE_WD-1:0]						iv_href_start			,   //����Ч��ʼ�Ĵ���
	input		[`LINE_WD-1:0]						iv_href_end				,   //����Ч�����Ĵ���
	input		[`LINE_WD-1:0]						iv_hd_rising			,   //hd��Ч��ʼ�Ĵ���
	input		[`LINE_WD-1:0]						iv_hd_falling			,   //hd��Ч�����Ĵ���
	input		[`LINE_WD-1:0]						iv_sub_rising			,   //sub��Ч��ʼ�Ĵ���
	input		[`LINE_WD-1:0]						iv_sub_falling			,   //sub��Ч�����Ĵ���
	input		[`FRAME_WD-1:0]						iv_vd_rising			,   //vd��Ч��ʼ�Ĵ���
	input		[`FRAME_WD-1:0]						iv_vd_falling			,   //vd��Ч�����Ĵ���
	input		[`EXP_WD-1:0]						iv_xsg_width			,	//XSG���
	input		[`FRAME_WD-1:0]						iv_frame_period			,   //֡���ڼĴ���
	input		[`FRAME_WD-1:0]						iv_headblank_end		,   //
	input		[`FRAME_WD-1:0]						iv_vref_start			,   //ROI��ʼ����
	input		[`FRAME_WD-1:0]						iv_tailblank_start		,   //ROI��������
	input		[`FRAME_WD-1:0]						iv_tailblank_end		,   //
	input		[`FRAME_WD-1:0]						iv_exp_line				,	//�ع�׶����в��������Ĵ���
	input		[`EXP_WD-1:0]						iv_exp_reg				,   //�ع�׶�ʱ�Ӹ����Ĵ���

	//�ڲ��ź�
	input											i_ad_parm_valid			,	//
	output											o_strobe				,   //������ź�
	output											o_integration			,   //�����ź�
	output											o_href					,   //����Ч�ź�
	output											o_vref					,   //����Ч�ź�
	output	reg										o_ccd_stop_flag			,	//
	output	reg										o_exposure_end			,	//
	output	reg										o_trigger_mask			,	//���δ�����־
	output											o_trigger_mask_flag		,	//����

	//AD �ӿ��ź�
	output											o_hd				,   //AD�����ź�HD
	output											o_vd				,   //AD�����ź�VD

	//CCD �ӿ��ź�
	output											o_sub				,   //SUB�ź�
	output		[`XSG_WD-1:0]						ov_xsg				,   //֡��ת�ź�
	output		[`XV_WD-1:0]						ov_xv					//��ֱ��ת�ź�
	);

	//  ===============================================================================================
	//  ��һ���֣�ģ�������Ҫ�õ����ź�
	//  ===============================================================================================

	wire                                   			w_reg_active    	;   //

	wire		[`FRAME_WD-1:0]						wv_frame_period		;   //��Чʱ�����֡���ڼĴ���
	wire		[`FRAME_WD-1:0]						wv_headblank_end	;   //
	wire		[`FRAME_WD-1:0]						wv_vref_start		;   //��Чʱ�����ROI��ʼ����
	wire		[`FRAME_WD-1:0]						wv_tailblank_start	;   //��Чʱ�����ROI��������
	wire		[`FRAME_WD-1:0]						wv_tailblank_end	;   //��Чʱ����ĳ�β��������
	wire		[22:0]								wv_tailblank_num	;	//
	wire		[22:0]								wv_headblank_num	;	//

	wire		[`FRAME_WD-1:0]						wv_exp_start_reg	;	//
	wire		[`EXP_WD-1:0]						wv_exp_reg			;   //�ع�׶�ʱ�Ӹ����Ĵ���
	wire		[`EXP_WD-1:0]						wv_exp_line_reg		;	//�ع�����ʱ�Ӹ����Ĵ���
	wire		[`EXP_WD-1:0]						wv_exp_xsg_reg		;	//
	reg			[1:0]								start_acquisit_shift	;	//
	reg			[`FRAME_PIX_CNT_WD-1:0] 			ccd_stop_cnt			;	//
	reg												stop_a_frame_flag		;	//
	reg			[1:0]								stop_a_frame_flag_shift	;	//
	wire											w_exposure_end			;	//
	reg												exposure_end_dly1		;
	reg												exposure_end_dly2		;
	reg												exposure_end_dly3		;


	//  ===============================================================================================
	//  �ڶ����֣�ʵ����ģ��
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  ccd_controller ģ�� : ����CCD��AD��־�ź�
	//  -------------------------------------------------------------------------------------
	ccd_controller ccd_controller_inst (
	.clk					(clk									),
	.reset					(reset									),
	.i_acquisition_start	(i_acquisition_start					),
	.i_stream_enable		(i_stream_enable						),
	.i_triggermode			(i_triggermode							),
	.i_trigger				(i_trigger								),
	.iv_href_start			(iv_href_start							),
	.iv_href_end			(iv_href_end							),
	.iv_hd_rising			(iv_hd_rising							),
	.iv_hd_falling			(iv_hd_falling							),
	.iv_vd_rising			(iv_vd_rising							),
	.iv_vd_falling			(iv_vd_falling							),
	.iv_sub_rising			(iv_sub_rising							),
	.iv_sub_falling			(iv_sub_falling							),
	.iv_xsg_width			(iv_xsg_width							),
	.iv_frame_period		(wv_frame_period						),
	.iv_headblank_end		(wv_headblank_end						),
	.iv_headblank_num		(wv_headblank_num						),
	.iv_vref_start	   		(wv_vref_start							),
	.iv_tailblank_start		(wv_tailblank_start						),
	.iv_tailblank_end		(wv_tailblank_end						),
	.iv_tailblank_num		(wv_tailblank_num						),
	.iv_exp_start_reg		(wv_exp_start_reg						),
	.iv_exp_line_reg		(wv_exp_line_reg						),
	.iv_exp_reg				(wv_exp_reg								),
	.iv_exp_xsg_reg			(wv_exp_xsg_reg							),

	.i_ad_parm_valid		(i_ad_parm_valid						),
	.i_ccd_stop_flag		(o_ccd_stop_flag						),
	.o_trigger_mask			(o_trigger_mask_flag					),
	.o_integration			(o_integration							),
	.o_exposure_end			(w_exposure_end							),
	.o_reg_active			(w_reg_active							),

	.o_vd					(o_vd									),
	.o_hd					(o_hd									),
	.o_vref					(o_vref									),
	.o_href					(o_href									),
	.o_sub                 	(o_sub									),
	.ov_xsg                 (ov_xsg									),
	.ov_xv                 	(ov_xv									)
	);

	//  -------------------------------------------------------------------------------------
	//  ccd_reg ģ�� : ccd�Ĵ�����Ч����ģ��
	//  -------------------------------------------------------------------------------------
	ccd_reg	ccd_reg_inst (
	.clk					(clk									),
	.reset					(reset									),
	.i_reg_active   		(w_reg_active							),
	.iv_frame_period		(iv_frame_period						),
	.iv_headblank_end		(iv_headblank_end						),
	.iv_vref_start	   		(iv_vref_start							),
	.iv_tailblank_start		(iv_tailblank_start						),
	.iv_tailblank_end		(iv_tailblank_end						),
	.iv_exp_line			(iv_exp_line							),
	.iv_exp_reg				(iv_exp_reg								),
	.ov_frame_period		(wv_frame_period						),
	.ov_headblank_end		(wv_headblank_end						),
	.ov_headblank_num		(wv_headblank_num						),
	.ov_vref_start	   		(wv_vref_start							),
	.ov_tailblank_start		(wv_tailblank_start						),
	.ov_tailblank_num		(wv_tailblank_num						),
	.ov_tailblank_end		(wv_tailblank_end						),
	.ov_exp_start_reg		(wv_exp_start_reg						),
	.ov_exp_line_reg		(wv_exp_line_reg						),
	.ov_exp_reg				(wv_exp_reg								),
	.ov_exp_xsg_reg			(wv_exp_xsg_reg							)
	);

	//  ===============================================================================================
	//  �������֣�ͣ�ɺ��һ��֡�����߼���ICX618 8.32MS,
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	i_start_acquisit ȡ��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		start_acquisit_shift	<= {start_acquisit_shift[0],i_start_acquisit};
	end

	//  -------------------------------------------------------------------------------------
	//	stop_a_frame_flag ȡ��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		stop_a_frame_flag_shift	<={stop_a_frame_flag_shift[0],stop_a_frame_flag};
	end

	//  -------------------------------------------------------------------------------------
	//	ͣ�ɺ��8.32ms: stop_a_frame_flag
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			stop_a_frame_flag	<=	1'b0;
		end
		else if(ccd_stop_cnt == `FRAME_PIXEL_CNT) begin
			stop_a_frame_flag	<=	1'b0;
		end
		else if(start_acquisit_shift == 2'b10) begin
			stop_a_frame_flag	<=  1'b1;
		end
	end

	always @ (posedge clk) begin
		if(reset) begin
			ccd_stop_cnt	<=	`FRAME_PIX_CNT_WD'd0;
		end
		else if(stop_a_frame_flag) begin
			ccd_stop_cnt	<=	ccd_stop_cnt + 1'b1;
		end
		else begin
			ccd_stop_cnt 	<=  `FRAME_PIX_CNT_WD'd0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	ͣ�ɺ��70ms: o_ccd_stop_flag
	//  -------------------------------------------------------------------------------------
	always @ ( posedge clk ) begin
		if(reset) begin
			o_ccd_stop_flag	<=	1'b1;
		end
		else if(start_acquisit_shift == 2'b01) begin
			o_ccd_stop_flag	<=	1'b0;
		end
		else if(stop_a_frame_flag_shift == 2'b10) begin
			o_ccd_stop_flag	<=  1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	��������������Ч�źš��������ڼ䣬���յ���һ�������źź󣬴��������ź���Ч
	//	�������ڼ��ڣ�����ж�������źű����Σ���ֻ����һ�������¼�����һ����������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset)
		o_trigger_mask	<=	1'b0;
		else if(o_trigger_mask_flag)
		begin
			if(!o_trigger_mask && i_trigger)
			o_trigger_mask	<=	1'b1;
		end
		else
		o_trigger_mask	<=  1'b0;
	end

	//  ===============================================================================================
	//  ���Ĳ��֣��ع�����źżӿ�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	�ع�����źżӿ�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		exposure_end_dly1	<=	w_exposure_end;
		exposure_end_dly2	<=	exposure_end_dly1;
		exposure_end_dly3	<=	exposure_end_dly2;
	end

	always @ (posedge clk) begin
		o_exposure_end	<=	 exposure_end_dly3 || exposure_end_dly2 || exposure_end_dly1 || w_exposure_end;
	end

endmodule