/**********************************************************************************************
-- Module		: CCD_Top
-- File			: CCD_Top.v
-- Description	: It is a general top document of the CCD module
-- Simulator	: Modelsim 6.2c / Windows XP2
-- Synthesizer	: Synplify8.0 / Windows XP2
-- Author / Designer	: Song Weiming (songwm@daheng-image.com)
-- Copyright (c) notice : Daheng image Vision 2007-2010
--------------------------------------------------------------------
--------------------------------------------------------------------
-- Revision Number	: 1
-- Modifier			: LuDawei (ludw@daheng-image.com)
-- Description		: Initial Design
-- Revision Number	: 2
-- Modifier			: ������ (liuhj@daheng-image.com)
-- Description		: CCD_Topģ���޸ġ���Ϊ3���֣�3-1����ģʽ��3-2����ģʽ��3-3ģʽ�л�
//----------------------------------------------------------------------------
// Modification history :
// 2007-12-28 : quartus-V1
// 2008-01-18 : LuDawei: finished
// 2012-06-01 ����������V2
***********************************************************************************************/
`timescale 1ns/1ns
`include "RJ33J3DEF.v"

module			ccd_top (
	input						pixclk			    		,	//����ʱ��
	input						reset		        		,	//��λ
	input                       i_triggerin					,	//��CCDģ��Ĵ����ź�
	input						i_triggersel				,	//�ɼ�ģʽѡ���ź�
	input		[`REG_WD-1:0]	iv_href_start				,	//����Ч��ʼ�Ĵ���
	input		[`REG_WD-1:0]	iv_href_end					,	//����Ч�����Ĵ���
	input		[`EXP_WD-1:0]	iv_exposure_reg				,	//�ع�Ĵ�������λ����ʱ��
	input		[`REG_WD-1:0]	iv_exposure_linereg			,	//���ع�Ĵ�������λ������
	input		[`REG_WD-1:0]	iv_frame_period				,	//֡���ڼĴ���
//	input		[`REG_WD-1:0]	iv_hperiod					,	//�����ڼĴ���
	input		[`REG_WD-1:0]	iv_headblank_number			,	//��ͷ���ܴ����Ĵ���
	//	input		[`REG_WD-1:0]	iv_headblank_start			,	//��ͷ���ܿ�ʼ�Ĵ���
	input		[`REG_WD-1:0]	iv_vsync_start				,	//����Ч��ʼ(��ͷ���ܽ���)�Ĵ���
	//	input		[`REG_WD-1:0]	iv_vsync_fpga_start			,	//����Ч�����ʼ(��ͷ���ܽ���)�Ĵ���
	input		[`REG_WD-1:0]	iv_tailblank_start			,	//��β���ܿ�ʼ(����Ч����)�Ĵ���
	input		[`REG_WD-1:0]	iv_tailblank_number			,	//��β���ܸ���
	input		[`REG_WD-1:0]	iv_tailblank_end			,	//��β���ܽ���(����Ч����)�Ĵ���
	//	input						i_xsb_falling_direc			,	//xsub�½��ز����ķ���0��ǰ��1�ͺ�
	//	input       [`REG_WD-1:0]   iv_xsb_falling_compensation ,	//xsub��������ֵ
	//	input						i_xsb_rising_direc			,	//xsub�����ز����ķ���0��ǰ��1�ͺ�
	//	input       [`REG_WD-1:0]   iv_xsb_rising_compensation	,	//xsub��������ֵ
	output						o_strobe					,	//������ź�
	output						o_integration				,	//�����ź�
	output						o_triggerready				,	//���������źţ��͵�ƽ��Ч
	output						o_xsub						,	//SUB�ź�
	output						o_hd						,	//AD�����ź�HD
	output						o_vd						,	//AD�����ź�VD
	output		[`XSG_WD-1:0]	ov_xsg						,	//֡��ת�ź�
	output						o_href						,	//����Ч�ź�
	output						o_vsync						,	//����Ч�ź�
	output		[`V_WIDTH-1:0]	ov_xv						,	//��ֱ��ת�ź�
	output		[`V_WIDTH-1:0]	ov_xvs							//��ֱ��ת�ź�
	);

	//************************************

	/**********************************************************************************************
	1���Ĵ�������������
	exposure_flag**				�������ع�ϵ���ź�
	***********************************************************************************************/
	wire						w_exposure_start		;
	wire						w_exposure_preflag	;
	wire             			w_exp_over			;
	wire						w_xsg_start			;
	wire						w_hend				;
	wire						w_xsub_last_m			;
	wire		[`REG_WD-1 :0]	wv_frame_period_m		;
	wire		[`REG_WD-1 :0]	wv_hperiod			;
	wire		[`REG_WD-1 :0]	wv_headblank_number_m	;
	wire		[`REG_WD-1 :0]	wv_headblank_start_m	;
	wire		[`REG_WD-1 :0]	wv_tailblank_start_m	;
	wire		[`REG_WD-1 :0]	wv_tailblank_number_m	;
	wire		[`REG_WD-1 :0]	wv_tailblank_end_m		;
	wire		[`REG_WD-1 :0]	wv_vsync_start_m	;
	wire		[`REG_WD-1 :0]	wv_vsync_fpga_start_m	;
	wire		[`REG_WD-1 :0]	wv_href_start_m		;
	wire		[`REG_WD-1 :0]	wv_href_end_m			;
	wire		[`EXP_WD-1 :0]	wv_exposure_reg_m		;
	wire		[`REG_WD-1 :0]	wv_exposure_linereg_m	;
	wire						w_triggersel_m		;
	wire		[`REG_WD-1 :0]	wv_vcount				;
	wire		[`REG_WD-1 :0]	wv_hcount				;
	wire						w_vcount_clear		;
//	wire		[`REG_WD-1 :0]	wv_triggerenreg_m		;
	reg			[`REG_WD-1 :0]	wv_triggerenreg_m		;
//	wire		[`REG_WD-1 :0]	wv_contlineexp_start	;
	reg			[`REG_WD-1 :0]	wv_contlineexp_start	;
	wire						w_xsg_flag			;
	wire						w_xsg_clear			;

	wire						w_xsb_falling_direc			;
	wire		[`REG_WD-1 :0]	wv_xsb_falling_compensation ;
	wire						w_xsb_rising_direc          ;
	wire		[`REG_WD-1 :0]	wv_xsb_rising_compensation  ;

	//	assign		wv_triggerenreg_m		= wv_frame_period_m-wv_exposure_linereg_m + 1'b1;		//����λ��̫��ǰ����һ֡���ܴ����ɹ�,�����2���ܱ�֤��С���عⴥ���ɹ�
	//	assign 		wv_contlineexp_start 	= wv_frame_period_m-wv_exposure_linereg_m + 1'b1;		//���ع����һ�㣬��֤��β������ɲŽ���xsg_flag
	//	-------------------------------------------------------------------------------------
	//	��ǿʱ���ԣ���һ��
	//	-------------------------------------------------------------------------------------
	always @ (posedge pixclk) begin
		wv_triggerenreg_m		<= wv_frame_period_m-wv_exposure_linereg_m + 1'b1;		//����λ��̫��ǰ����һ֡���ܴ����ɹ�,�����2���ܱ�֤��С���عⴥ���ɹ�
		wv_contlineexp_start 	= wv_frame_period_m-wv_exposure_linereg_m + 1'b1;		//���ع����һ�㣬��֤��β������ɲŽ���xsg_flag
	end

	assign		ov_xvs					= w_xsg_flag ? `XV_DEFVALUE : ov_xv;		//֡��ת�׶α���Ĭ��ֵ�������׶κ�XV��ͬ
	/**********************************************************************************************
	2��ģ������,��ģ�鶨�����£�
	ccd_contr
	counter_triggerdelay
	counter_lineexp
	***********************************************************************************************/
	ccd_controler ccd_controler_inst (
	.pixclk					(pixclk					),
	.reset					(reset					),
	.ov_xv					(ov_xv					),
	.ov_xsg					(ov_xsg					),
	.o_xsub					(o_xsub					),
	.o_hd					(o_hd					),
	.o_vd					(o_vd					),
	.iv_frame_period		(wv_frame_period_m		),
	.iv_hperiod				(wv_hperiod				),
	.iv_headblank_start		(wv_headblank_start_m	),
	.iv_tailblank_start		(wv_tailblank_start_m	),
	.iv_tailblank_number	(wv_tailblank_number_m	),
	.iv_tailblank_end		(wv_tailblank_end_m		),
	.iv_vsync_start			(wv_vsync_start_m		),
	.iv_vsync_fpga_start	(wv_vsync_fpga_start_m	),
	.iv_headblank_number	(wv_headblank_number_m	),
	.i_exposure_flag		(w_exposure_preflag		),
	.i_xsub_last			(w_xsub_last_m			),
	.iv_href_start			(wv_href_start_m		),
	.iv_href_end			(wv_href_end_m			),
	.iv_vcount				(wv_vcount				),
	.i_xsg_start			(w_xsg_start			),
	.i_waitflag				(w_waitflag				),
	.i_triggersel			(w_triggersel_m			),

	.i_xsb_falling_direc		(w_xsb_falling_direc			),
	.iv_xsb_falling_compensation(wv_xsb_falling_compensation	),
	.i_xsb_rising_direc			(w_xsb_rising_direc				),
	.iv_xsb_rising_compensation	(wv_xsb_rising_compensation		),

	.o_href					(o_href					),
	.o_vsync				(o_vsync				),
	.o_xsg_flag				(w_xsg_flag				),
	.o_xsg_clear			(w_xsg_clear			),
	.o_hend					(w_hend					),
	.ov_hcount				(wv_hcount				)
	);

	counter	 counter_v_inst		(
	.clk					(pixclk					),
	.hend					(w_hend					),
	.i_clk_en				(1'b1					),
	.i_aclr					(w_vcount_clear			),
	.ov_q					(wv_vcount				)
	);


	ccd_reg	ccd_reg_inst (
	.pixclk							(pixclk 				),
	.reset							(reset					),
	.iv_vcount						(wv_vcount 				),
	.i_integration					(o_integration			),
	.i_triggersel					(i_triggersel			),
	.iv_href_start					(iv_href_start			),
	.iv_href_end					(iv_href_end			),
	.iv_exposure_reg				(iv_exposure_reg		),
	.iv_exposure_linereg			(iv_exposure_linereg	),
	.iv_frame_period				(iv_frame_period		),
//	.iv_hperiod						(iv_hperiod				),
	.iv_headblank_number			(iv_headblank_number	),
	//	.iv_headblank_start				(iv_headblank_start		),
	.iv_tailblank_start				(iv_tailblank_start		),
	.iv_tailblank_number			(iv_tailblank_number	),
	.iv_tailblank_end				(iv_tailblank_end		),
	.iv_vsync_start					(iv_vsync_start			),
	//	.iv_vsync_fpga_start			(iv_vsync_fpga_start	),
	//	.i_xsb_falling_direc			(i_xsb_falling_direc			),
	//	.iv_xsb_falling_compensation	(iv_xsb_falling_compensation	),
	//	.i_xsb_rising_direc				(i_xsb_rising_direc				),
	//	.iv_xsb_rising_compensation		(iv_xsb_rising_compensation		),
	.o_triggersel_act				(w_triggersel_m			),
	.ov_frame_period_m				(wv_frame_period_m		),
	.ov_hperiod						(wv_hperiod				),
	.ov_headblank_number_m			(wv_headblank_number_m 	),
	.ov_headblank_start_m			(wv_headblank_start_m	),
	.ov_tailblank_start_m			(wv_tailblank_start_m	),
	.ov_tailblank_number_m			(wv_tailblank_number_m	),
	.ov_tailblank_end_m				(wv_tailblank_end_m		),
	.ov_vsync_start_m				(wv_vsync_start_m	),
	.ov_vsync_fpga_start_m			(wv_vsync_fpga_start_m	),
	.ov_href_start_m				(wv_href_start_m		),
	.ov_href_end_m					(wv_href_end_m			),
	.ov_exposure_reg_m				(wv_exposure_reg_m		),
	.ov_exposure_linereg_m			(wv_exposure_linereg_m 	),
	.o_xsb_falling_direc_m			(w_xsb_falling_direc			),
	.ov_xsb_falling_compensation_m	(wv_xsb_falling_compensation	),
	.o_xsb_rising_direc_m			(w_xsb_rising_direc				),
	.ov_xsb_rising_compensation_m	(wv_xsb_rising_compensation		)
	);

	ccd_trig ccd_trig_inst		(
	.pixclk					(pixclk					),
	.reset					(reset					),
	.i_triggerin			(i_triggerin			),
	.iv_triggerenreg_m		(wv_triggerenreg_m		),
	.iv_contlineexp_start  	(wv_contlineexp_start  	),
	.i_hend					(w_hend					),
	.i_triggersel_m			(w_triggersel_m			),
	.iv_frame_period_m		(wv_frame_period_m		),
	.iv_vcount				(wv_vcount				),
	.iv_hcount				(wv_hcount				),
	.o_exposure_start		(w_exposure_start		),
	.o_triggerready       	(o_triggerready       	)
	);

	ccd_exp ccd_exp_inst		(
	.pixclk					(pixclk					),
	.reset					(reset					),
	.i_triggersel_m			(w_triggersel_m			),
	.i_exposure_start		(w_exposure_start		),
	.i_waitflag				(w_waitflag				),
	.iv_exposure_reg_m		(wv_exposure_reg_m		),
	.iv_vcount				(wv_vcount				),
	.o_xsg_start			(w_xsg_start			),
	.o_xsub_last_m			(w_xsub_last_m			),
	.o_strobe				(o_strobe				),
	.o_exposure_preflag		(w_exposure_preflag		),
	.o_exp_over		 		(w_exp_over		    	),
	.o_integration        	(o_integration        	)
	);

	ccd_vclear ccd_vclear_inst	(
	.pixclk					(pixclk					),
	.reset					(reset					),
	.iv_frame_period_m		(wv_frame_period_m		),
	.iv_vcount				(wv_vcount				),
	.i_xsg_clear			(w_xsg_clear			),
	.i_xsg_start    		(w_xsg_start			),
	.i_triggersel_m			(w_triggersel_m			),
	.i_hend					(w_hend					),
	.o_vcount_clear			(w_vcount_clear			),
	.o_waitflag		    	(w_waitflag				)
	);

endmodule