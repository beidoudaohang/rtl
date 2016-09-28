/**********************************************************************************************
�Ĵ�����Чʱ��ģ�飺
(1)����CPUд��Ĺ����ع�ʱ�䴰�ڳߴ�ȼĴ��������������������ã���Ȼ����������Ĳ�ƥ��
(2)�����ϲ����Ĵ���������ʱ��Ӧ����һ�ֲ������֮����һ�ֿ�ʼ����֮ǰ��Ϊ������ѡ��֡��ת
�ź�Xsg��Ϊʱ���������
***********************************************************************************************/
`timescale 1ns/1ns
`include "RJ33J3DEF.v"

module	ccd_reg(
	input						pixclk					,		//����ʱ��
	input						reset					,       //��λ
	input		[`REG_WD-1 :0]	iv_vcount				,       //��ֱ������
	input						i_integration			,       //�����ź�
	//input reg
	input						i_triggersel			,       //�ɼ�ģʽ
	input		[`REG_WD-1:0]	iv_href_start			,       //����ʼ�Ĵ���
	input		[`REG_WD-1:0]	iv_href_end				,       //�н����Ĵ���
	input		[`EXP_WD-1:0]	iv_exposure_reg			,       //�ع�Ĵ�������λ����ʱ��
	input		[`REG_WD-1:0]	iv_exposure_linereg		,       //���ع�Ĵ���
	input		[`REG_WD-1:0]	iv_frame_period			,       //֡���ڼĴ���
//	input		[`REG_WD-1:0]	iv_hperiod				,       //�����ڼĴ���
	input		[`REG_WD-1:0]	iv_headblank_number		,       //��ͷ���ܸ����Ĵ���
//	input		[`REG_WD-1:0]	iv_headblank_start		,       //��ͷ������ʼ�Ĵ���
	input		[`REG_WD-1:0]	iv_tailblank_start		,       //��β������ʼλ�üĴ���
	input		[`REG_WD-1:0]	iv_tailblank_number		,       //��β���ܸ���
	input		[`REG_WD-1:0]	iv_tailblank_end		,       //��β���ܽ���λ�üĴ���
	input		[`REG_WD-1:0]	iv_vsync_start			,       //����Ч��ʼ�Ĵ���
//	input		[`REG_WD-1:0]	iv_vsync_fpga_start		,       //����Ч��ʼ�Ĵ���
	
//	input						i_xsb_falling_direc			,	//xsub�½��ز����ķ���0��ǰ��1�ͺ�
//	input		[`REG_WD-1 :0]	iv_xsb_falling_compensation ,	//xsub��������ֵ
//	input						i_xsb_rising_direc          ,	//xsub�����ز����ķ���0��ǰ��1�ͺ�
//	input		[`REG_WD-1 :0]	iv_xsb_rising_compensation	,	//xsub��������ֵ
	
	//output reg
	output	reg					o_triggersel_act		,       //��Чʱ������֮��Ĳɼ�ģʽ�Ĵ���
	output	reg	[`REG_WD-1 :0]	ov_frame_period_m		,       //֡���ڼĴ���
	output	reg	[`REG_WD-1 :0]	ov_hperiod				,       //�����ڼĴ���
	output	reg	[`REG_WD-1 :0]	ov_headblank_number_m	,       //��ͷ���ܸ����Ĵ���
	output	reg	[`REG_WD-1 :0]	ov_headblank_start_m	,       //��ͷ���ܸ����Ĵ���
	output	reg	[`REG_WD-1 :0]	ov_tailblank_start_m	,       //��β������ʼλ�üĴ���
	output	reg	[`REG_WD-1 :0]	ov_tailblank_number_m	,       //��β���ܽ���λ�üĴ���
	output	reg	[`REG_WD-1 :0]	ov_tailblank_end_m		,       //��β���ܸ���
	output	reg	[`REG_WD-1 :0]	ov_vsync_start_m		,       //����Ч��ʼ�Ĵ���
	output	reg	[`REG_WD-1 :0]	ov_vsync_fpga_start_m	,       //����Ч��ʼ�Ĵ���
	output	reg	[`REG_WD-1 :0]	ov_href_start_m			,       //����ʼ�Ĵ���
	output	reg	[`REG_WD-1 :0]	ov_href_end_m			,       //�н����Ĵ���
	output	reg	[`EXP_WD-1 :0]	ov_exposure_reg_m		,       //�ع�Ĵ�������λ����ʱ��
	output	reg	[`REG_WD-1 :0]	ov_exposure_linereg_m	,      	//���ع�Ĵ���
	output	reg					o_xsb_falling_direc_m			,	//xsub�½��ز����ķ���0��ǰ��1�ͺ�
	output	reg	[`REG_WD-1 :0]	ov_xsb_falling_compensation_m 	,	//xsub��������ֵ
	output	reg					o_xsb_rising_direc_m          	,	//xsub�����ز����ķ���0��ǰ��1�ͺ�
	output	reg	[`REG_WD-1 :0]	ov_xsb_rising_compensation_m		//xsub��������ֵ
	);


	reg		[`REG_WD-1 :0]		frame_period_dly0 = 1'b0;
	reg		[`REG_WD-1 :0]		frame_period_dly1 = 1'b0;
	reg		[`REG_WD-1 :0]		exposure_linereg_dly0 = 1'b0;
	reg		[`REG_WD-1 :0]		exposure_linereg_dly1 = 1'b0;



	//--------------------------------------------------------
	//1��reg ͬ��
	//--------------------------------------------------------
	always @ (posedge pixclk) begin
		frame_period_dly0	<= iv_frame_period;
		frame_period_dly1	<= frame_period_dly0;
	end

	always @ (posedge pixclk) begin
		exposure_linereg_dly0	<= iv_exposure_linereg;
		exposure_linereg_dly1	<= exposure_linereg_dly0;
	end

	//--------------------------------------------------------
	//2���Ĵ�����Ч
	//--------------------------------------------------------
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			ov_headblank_start_m 			<= `HEADBLANK_START_DEFVALUE 	;
			ov_headblank_number_m 			<= `HEADBLANK_NUMBER_DEFVALUE 	;
			ov_vsync_start_m 				<= `VSYNC_START_DEFVALUE     ;
			ov_vsync_fpga_start_m 			<= `VSYNC_START_FPGA_DEFVALUE	;
			ov_tailblank_start_m 			<= `TAILBLANK_START_DEFVALUE 	;
			ov_tailblank_number_m 			<= `TAILBLANK_NUMBER_DEFVALUE 	;
			ov_tailblank_end_m				<= `TAILBLANK_END_DEFVALUE 		;
			ov_frame_period_m 				<= `FRAME_PERIOD_DEFVALUE 	    ;
			ov_hperiod						<= `H_PERIOD					;
			ov_href_start_m 				<= `HREF_START_DEFVALUE      	;
			ov_href_end_m 					<= `HREF_END_DEFVALUE        	;
			o_triggersel_act				<= 1'B0							;
			ov_exposure_linereg_m			<= `EXPOSURE_LINEREG_DEFVALUE	;
			ov_exposure_reg_m				<= `EXPOSURE_DEFVALUE			;
			o_xsb_falling_direc_m			<= 1'b0			;
			ov_xsb_falling_compensation_m	<= `REG_WD'b0	;
			o_xsb_rising_direc_m			<= 1'b0	;
			ov_xsb_rising_compensation_m	<= `REG_WD'b0	;
			
		end
		else if((iv_vcount == 16'h0000)&&(i_integration == 1'b0)) begin		//�������ع��ʱ������¼Ĵ���
			ov_headblank_start_m			<= `REG_WD'b1	;
			ov_headblank_number_m			<= iv_headblank_number	;
			ov_vsync_start_m				<= iv_vsync_start		;
			ov_vsync_fpga_start_m			<= iv_vsync_start+1'b1	;
			ov_tailblank_start_m			<= iv_tailblank_start	;
			ov_tailblank_number_m			<= iv_tailblank_number	;
			ov_tailblank_end_m				<= iv_tailblank_end		;
//			ov_hperiod						<= iv_hperiod			;
			ov_hperiod						<= `H_PERIOD			;
			ov_href_start_m					<= iv_href_start		;
			ov_href_end_m					<= iv_href_end			;
			o_triggersel_act				<= i_triggersel			;
			ov_exposure_reg_m				<= iv_exposure_reg		;
			ov_exposure_linereg_m			<= exposure_linereg_dly1		;
			o_xsb_falling_direc_m			<= 1'b0			;
			ov_xsb_falling_compensation_m   <= `REG_WD'b0	;
			o_xsb_rising_direc_m            <= 1'b0			;
			ov_xsb_rising_compensation_m    <= `REG_WD'b0	;
			
			if(frame_period_dly1 >= exposure_linereg_dly1 + 16'h4) begin
				ov_frame_period_m			<= frame_period_dly1;
			end
			else begin
				ov_frame_period_m			<= exposure_linereg_dly1 + 16'h4;
			end
		end
	end
	
endmodule