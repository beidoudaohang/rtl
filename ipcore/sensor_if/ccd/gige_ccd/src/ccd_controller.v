
//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : ccd_controller.v
//  -- �����       : ��
//-------------------------------------------------------------------------------------------------
//
//  --�޸ļ�¼  :
//
//  -- ����         :| �޸�����     :|  �޸�˵��
//---------------------------------------------------------------------------------------
//  -- ��       	:| 09/17/2013   :|  ��ʼ�汾
//  -- ��Сƽ      	:| 04/29/2015   :|  �����޸ģ���Ӧ��ICX445 sensor
//
//---------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1)  : ����CCD��AD��־�ź�
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale      1ns/100ps
//-------------------------------------------------------------------------------------------------

`include "SHARP_RJ33J3_DEF.v"

module  ccd_controller # (
	parameter	XV_WIDTH						= 4			;
	parameter	HB_XV_DEFAULT_VALUE				= 4'b1100	;
	parameter	HB_XV_VALUE1					= 4'b1100	;
	parameter	HB_XV_VALUE2					= 4'b1000	;
	parameter	HB_XV_VALUE3					= 4'b1001	;
	parameter	HB_XV_VALUE4					= 4'b0001	;
	parameter	HB_XV_VALUE5					= 4'b0011	;
	parameter	HB_XV_VALUE6					= 4'b0010	;
	parameter	HB_XV_VALUE7					= 4'b0110	;
	parameter	HB_XV_VALUE8					= 4'b0100	;
	parameter	HB_LINE_START_POS				= 40		;	//ÿһ�п�ʼ��ת��ʱ���
	parameter	LINE_PERIOD						= 1532		;	//������
	parameter	ONE_LINE_BLANK_NUM				= 4			;	//ÿһ�п췭������
	parameter	ONE_BLANK_STATE_NUM				= 8			;	//ÿһ�ο췭��״̬����

	)
	(
	input                                   		clk      			,   //ʱ��
	input											reset				,	//ʱ�Ӹ�λ������Ч
	input											i_acquisition_start		,	//clk_pixʱ���򣬿����źţ�0-ͣ�ɣ�1-����
	input											i_stream_enable			,	//clk_pixʱ������ʹ���źţ�0-ͣ�ɣ�1-����
	input											i_triggermode		,   //��CCDģ��Ĳɼ�ģʽ�ź�
	input											i_trigger			,   //��CCDģ��Ĵ����ź�

	input		[`LINE_WD-1:0]						iv_href_start		,   //����Ч��ʼ�Ĵ���
	input		[`LINE_WD-1:0]						iv_href_end			,   //����Ч�����Ĵ���
	input		[`LINE_WD-1:0]						iv_hd_rising		,   //hd��Ч��ʼ�Ĵ���
	input		[`LINE_WD-1:0]						iv_hd_falling		,   //hd��Ч�����Ĵ���
	input		[`LINE_WD-1:0]						iv_sub_rising		,   //sub��Ч��ʼ�Ĵ���
	input		[`LINE_WD-1:0]						iv_sub_falling		,   //sub��Ч�����Ĵ���
	input		[`FRAME_WD-1:0]						iv_vd_rising		,   //vd��Ч��ʼ�Ĵ���
	input		[`FRAME_WD-1:0]						iv_vd_falling		,   //vd��Ч�����Ĵ���
	input		[`EXP_WD-1:0]						iv_xsg_width		,	//XSG���
	input		[`FRAME_WD-1:0]						iv_frame_period		,   //֡���ڼĴ���
	input		[`FRAME_WD-1:0]						iv_headblank_end	,   //
	input		[22:0]								iv_headblank_num	,	//
	input		[`FRAME_WD-1:0]						iv_vref_start		,   //ROI��ʼ����
	input		[`FRAME_WD-1:0]						iv_tailblank_start	,   //ROI��������
	input		[22:0]								iv_tailblank_num	,	//
	input		[`FRAME_WD-1:0]						iv_tailblank_end	,   //
	input		[`EXP_WD-1:0]						iv_exp_reg			,   //�ع�׶�ʱ�Ӹ����Ĵ���
	input		[`EXP_WD-1:0]						iv_exp_line_reg		,	//�ع�����ʱ�Ӹ����Ĵ���
	input		[`FRAME_WD-1:0]						iv_exp_start_reg	,	//
	input		[`EXP_WD-1:0]						iv_exp_xsg_reg		,	//
	//�ڲ��ź�
	input											i_ad_parm_valid		,	//
	input											i_ccd_stop_flag		,	//
	output											o_trigger_mask		,	//���α�־
	output    										o_integration       ,	//�����ź�
	output											o_reg_active		,	//
	output											o_exposure_end		,	//
	output											o_href				,   //����Ч�ź�
	output											o_vref				,   //����Ч�ź�
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
	wire											w_headblank_flag	;
	wire											w_tailblank_flag	;
	wire											w_xsg_flag			;
	wire											w_exp_line_end		;	//���ع������־����������֡��ת
	wire											w_readout_flag		;
	wire  		[`FRAME_WD-1:0]						wv_vcount			;
	wire											w_hend				;
	wire		[12:0]								wv_hcount			;
	wire		[`XV_WD-1:0]						wv_xv_xsg			;
	wire		[`XV_WD-1:0]						wv_xv_tailblank		;
	wire		[`XV_WD-1:0]						wv_xv_headblank		;


	//  ===============================================================================================
	//  �ڶ����֣�ʵ����ģ��
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  ccd_readout ģ�� : ����ccd�������ڱ�־
	//  -------------------------------------------------------------------------------------
	ccd_readout ccd_readout_inst (
	.clk					(clk									),
	.reset					(reset									),
	.iv_frame_period		(iv_frame_period						),
	.i_exp_line_end			(w_exp_line_end							),
	.i_ccd_stop_flag		(i_ccd_stop_flag						),
	.i_hend					(w_hend									),
	.o_readout_flag			(w_readout_flag							),
	.o_xsg_flag				(w_xsg_flag								),
	.ov_vcount				(wv_vcount								)
	);

	//  -------------------------------------------------------------------------------------
	//  ccd_blank ģ�� : ���ɳ�ͷ���ٷ�ת
	//  -------------------------------------------------------------------------------------
	ccd_blank # (
	.XV_WIDTH				(XV_WIDTH				),
	.XV_DEFAULT_VALUE		(HB_XV_DEFAULT_VALUE	),
	.XV_VALUE1				(HB_XV_VALUE1			),
	.XV_VALUE2				(HB_XV_VALUE2			),
	.XV_VALUE3				(HB_XV_VALUE3			),
	.XV_VALUE4				(HB_XV_VALUE4			),
	.XV_VALUE5				(HB_XV_VALUE5			),
	.XV_VALUE6				(HB_XV_VALUE6			),
	.XV_VALUE7				(HB_XV_VALUE7			),
	.XV_VALUE8				(HB_XV_VALUE8			),
	.LINE_START_POS			(HB_LINE_START_POS		),
	.LINE_PERIOD			(LINE_PERIOD			),
	.ONE_LINE_BLANK_NUM		(ONE_LINE_BLANK_NUM		),
	.ONE_BLANK_STATE_NUM	(ONE_BLANK_STATE_NUM	),
	)
	ccd_blank_hb_inst (
	.clk					(clk					),
	.reset					(reset					),
	.iv_hcount				(wv_hcount				),
	.i_blank_flag			(w_headblank_flag		),
	.iv_blank_num			(iv_headblank_num		),
	.ov_xv					(wv_xv_headblank		)
	);

	//  -------------------------------------------------------------------------------------
	//  ccd_blank ģ�� : ���ɳ�β���ٷ�ת
	//  -------------------------------------------------------------------------------------
	ccd_blank # (
	.XV_WIDTH				(XV_WIDTH				),
	.XV_DEFAULT_VALUE		(TB_XV_DEFAULT_VALUE	),
	.XV_VALUE1				(TB_XV_VALUE1			),
	.XV_VALUE2				(TB_XV_VALUE2			),
	.XV_VALUE3				(TB_XV_VALUE3			),
	.XV_VALUE4				(TB_XV_VALUE4			),
	.XV_VALUE5				(TB_XV_VALUE5			),
	.XV_VALUE6				(TB_XV_VALUE6			),
	.XV_VALUE7				(TB_XV_VALUE7			),
	.XV_VALUE8				(TB_XV_VALUE8			),
	.LINE_START_POS			(TB_LINE_START_POS		),
	.LINE_PERIOD			(LINE_PERIOD			),
	.ONE_LINE_BLANK_NUM		(ONE_LINE_BLANK_NUM		),
	.ONE_BLANK_STATE_NUM	(ONE_BLANK_STATE_NUM	),
	)
	ccd_blank_tb_inst (
	.clk					(clk					),
	.reset					(reset					),
	.iv_hcount				(wv_hcount				),
	.i_blank_flag			(w_tailblank_flag		),
	.iv_blank_num			(iv_tailblank_num		),
	.ov_xv					(wv_xv_tailblank		)
	);

	//  -------------------------------------------------------------------------------------
	//  ccd_exp ģ�� : ccd�ع����ģ��
	//  -------------------------------------------------------------------------------------
	ccd_exp	ccd_exp_inst (
	.clk					(clk									),	//ʱ��
	.reset					(reset									),	//��λ������Ч
	.iv_exp_reg	    		(iv_exp_reg								),	//�ع�ʱ�Ӹ����Ĵ���
	.iv_exp_line_reg		(iv_exp_line_reg						),	//�ع�����ʱ�Ӹ����Ĵ���
	.iv_exp_start_reg		(iv_exp_start_reg						),	//�ع⿪ʼ��λ�üĴ���
	.iv_vcount				(wv_vcount								), 	//֡���ڼ�����
	.i_readout_flag			(w_readout_flag							), 	//ccd������־���˱�־��Ч�£����ܴ��hcount
	.i_start_acquisit		(i_start_acquisit						), 	//��CCDģ��Ŀ����ź�
	.i_triggermode			(i_triggermode							), 	//��CCDģ��Ĳɼ�ģʽ�ź�
	.i_trigger				(i_trigger								),  //��CCDģ��Ĵ����ź�
	.i_xsg_flag				(w_xsg_flag								),  //֡��ת�׶α�־
	.i_exposure_end	   	 	(o_exposure_end							),	//�ع������־
	.o_reg_active			(o_reg_active							),	//�Ĵ�����Ч��־
	.ov_hcount				(wv_hcount								), 	//�����ڼ�����
	.o_hend					(w_hend									), 	//�����ڱ��
	.o_exp_line_end			(w_exp_line_end							),	//���ع������־����������֡��ת�׶�
	.o_trigger_mask			(o_trigger_mask							),  //���α�־
	.o_integration			(o_integration							)	//�����ź�
	);

	//  -------------------------------------------------------------------------------------
	//  ccd_xsg ģ�� : ccd xsg�׶ο���ģ��
	//  -------------------------------------------------------------------------------------
	ccd_xsg	ccd_xsg_inst (
	.clk					(clk									),	//ʱ��
	.reset					(reset									),	//��λ������Ч
	.iv_exp_xsg_reg			(iv_exp_xsg_reg							),	//
	.iv_xsg_width			(iv_xsg_width							),	//
	.i_xsg_flag				(w_xsg_flag								),	//֡��ת�׶α�־
	.o_exposure_end	   	 	(o_exposure_end							),	//�ع������־
	.ov_xv_xsg				(wv_xv_xsg								),	//XSG�ź�
	.ov_xsg					(ov_xsg									)   //֡��ת�׶�XV
	);

	//  -------------------------------------------------------------------------------------
	//  ccd_flag ģ�� : ����ccd��ad��־
	//  -------------------------------------------------------------------------------------
	ccd_flag ccd_flag_inst (
	.clk					(clk									),	//ʱ��
	.reset					(reset									),	//��λ������Ч
	.iv_href_start			(iv_href_start							),	//����Ч��ʼ�Ĵ���
	.iv_href_end	   	 	(iv_href_end							),	//����Ч�����Ĵ���
	.iv_hd_rising	   	 	(iv_hd_rising							),	//hd��Ч�����Ĵ���
	.iv_hd_falling	   	 	(iv_hd_falling							),	//hd��Ч�����Ĵ���
	.iv_vd_rising	   	 	(iv_vd_rising							),	//����Ч�����Ĵ���
	.iv_vd_falling	   	 	(iv_vd_falling							),	//����Ч�����Ĵ���
	.iv_sub_rising			(iv_sub_rising							), 	//sub��Ч��ʼ�Ĵ���
	.iv_sub_falling			(iv_sub_falling							), 	//sub��Ч�����Ĵ���
	.iv_headblank_end		(iv_headblank_end						),	//
	.iv_vref_start			(iv_vref_start							),	//����Ч��ʼ�Ĵ���
	.iv_tailblank_start		(iv_tailblank_start						),	//ROI��������
	.iv_tailblank_end		(iv_tailblank_end						),	//ROI��������
	.iv_xv_tailblank		(wv_xv_tailblank						),	//
	.iv_xv_headblank		(wv_xv_headblank						),	//
	.iv_xv_xsg				(wv_xv_xsg								),	//
	.iv_vcount				(wv_vcount								), 	//֡���ڼ�����
	.iv_hcount				(wv_hcount								), 	//�����ڼ�����
	.i_readout_flag			(w_readout_flag							),	//ccd������־���˱�־��Ч�£����ܴ��hcount
	.i_xsg_flag				(w_xsg_flag								),	//
	.i_ad_parm_valid		(i_ad_parm_valid						),	//
	.i_integration			(o_integration							),	//
	.o_headblank_flag		(w_headblank_flag						),	//
	.o_tailblank_flag		(w_tailblank_flag						),	//
	.o_href					(o_href									),	//֡��ת�׶α�־
	.o_vref					(o_vref									),	//֡��ת����������ccd readout״̬��
	.o_vd					(o_vd									),	//
	.o_hd					(o_hd									),  //
	.o_sub					(o_sub									),  //SUB�ź�
	.ov_xv					(ov_xv									)
	);

endmodule