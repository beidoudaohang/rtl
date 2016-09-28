//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : bfm_ccd
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/8/13 13:58:52	:|  ��ʼ�汾
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
`include "SHARP_RJ33J3_DEF.v"


module bfm_ccd ();

	//	ref signals
	reg		[`FRAME_WD-1:0]		iv_exp_line;
	reg		[`EXP_WD-1:0]		iv_exp_reg;

	reg		[`FRAME_WD-1:0]		iv_frame_period;
	reg		[`FRAME_WD-1:0]		iv_headblank_end;
	reg		[`FRAME_WD-1:0]		iv_vref_start;
	reg		[`FRAME_WD-1:0]		iv_tailblank_start;
	reg		[`FRAME_WD-1:0]		iv_tailblank_end;

	reg		[`LINE_WD-1:0]		iv_href_start;	//����Ч��ʼ�Ĵ���
	reg		[`LINE_WD-1:0]		iv_href_end;	//����Ч�����Ĵ���
	reg		[16-1:0]			iv_roi_offset_x;	//����Ч�����Ĵ���
	reg		[16-1:0]			iv_roi_pic_width;	//����Ч�����Ĵ���


	//	ref ARCHITECTURE


	task readout_reg_cfg;

		input [31:0] offsetx;
		input [31:0] offsety;
		input [31:0] width;
		input [31:0] height;

		reg [31:0] headblank_num;
		reg [31:0] tailblank_num;

		begin
			if(((offsety + 16)/8 -1)>1000) begin
				headblank_num	= 0;
			end
			else begin
				headblank_num	= (offsety + 16)/8 -1;
			end
			iv_headblank_end  	= headblank_num + 2 ;
			iv_vref_start 		= iv_headblank_end + (offsety + 16) - headblank_num*8 ;
			iv_tailblank_start 	= iv_vref_start + height;
			if(((996 - (height + offsety + 16))/8-1)>1000) begin
				tailblank_num	= 0;
			end
			else begin
				tailblank_num	= (996 - (height + offsety + 16))/8-1 ;	//4+4+8
			end

			iv_tailblank_end	= tailblank_num + iv_tailblank_start;
			iv_frame_period  	= iv_tailblank_end + 2;

			iv_href_start		= `HREF_START_AD_DEFVALUE;
			iv_href_end			= `HREF_END_AD_DEFVALUE;

			iv_roi_offset_x		= offsetx;
			iv_roi_pic_width	= width;

			$display(" iv_frame_period is %d\n iv_headblank_end is %d\n iv_vref_start is %d\n iv_tailblank_start is %d\n iv_tailblank_start is  %d\n",iv_frame_period,iv_headblank_end,iv_vref_start,iv_tailblank_start,iv_tailblank_start);
			$display(" iv_href_start is %d\n iv_href_end is %d\n",iv_href_start,iv_href_end);
			$display(" iv_roi_offset_x is %d\n iv_roi_pic_width is %d\n",iv_roi_offset_x,iv_roi_pic_width);
		end
	endtask

	task exp_time_us;
		input	[15:0]	exp_time_input;
		begin
			iv_exp_reg	= (exp_time_input*45)+31+100;
			iv_exp_line	= (((iv_exp_reg/`LINE_PIX)-1)>30000) ? 0 : ((iv_exp_reg/`LINE_PIX)-1);
		end
	endtask





endmodule
