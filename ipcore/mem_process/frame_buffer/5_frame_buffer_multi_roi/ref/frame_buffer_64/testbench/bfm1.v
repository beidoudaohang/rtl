//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : bfm1
//  -- �����       : ��ǿ
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- ��ǿ         :| 2015/4/8 16:46:01	:|
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
module bfm1;
	localparam							DATA_WD			=32		;		//�����������λ������ʹ��ͬһ���
	localparam							SHORT_REG_WD 	=16		;		//�̼Ĵ���λ��
	localparam							REG_WD 			=32		;		//�Ĵ���λ��
	localparam							LONG_REG_WD 	=64		;		//���Ĵ���λ��
	localparam							BUF_DEPTH_WD	=4		;		//֡�����λ��,�������֧��8֡��ȣ���һλ��λλ
// task1
task config_imagesize ;

	input								i_chunkmodeactive		;
	input		[BUF_DEPTH_WD-1		:0]	iv_frame_depth			;
	input		[SHORT_REG_WD-1		:0]	iv_size_x				; 		//���ڿ��
	input		[SHORT_REG_WD-1		:0]	iv_size_y				; 		//���ڸ߶�
	input		[SHORT_REG_WD-1		:0]	iv_offset_x				; 		//ˮƽƫ��
	input		[SHORT_REG_WD-1		:0]	iv_offset_y				; 		//��ֱ����
	input		[SHORT_REG_WD-1		:0]	iv_h_period 			;
	input		[SHORT_REG_WD-1		:0]	iv_v_petiod 			;

	output								o_chunkmodeactive		;
	output		[BUF_DEPTH_WD-1		:0]	ov_frame_depth			;
	output		[SHORT_REG_WD-1		:0]	ov_h_period 			;
	output		[SHORT_REG_WD-1		:0]	ov_v_petiod 			;
	output		[SHORT_REG_WD-1		:0]	ov_size_x				; 		//���ڿ��
	output		[SHORT_REG_WD-1		:0]	ov_size_y				; 		//���ڸ߶�
	output		[SHORT_REG_WD-1		:0]	ov_offset_x				; 		//ˮƽƫ��
	output		[SHORT_REG_WD-1		:0]	ov_offset_y				; 		//��ֱ����
	output		[LONG_REG_WD-1		:0]	ov_payload_size_frame_buf; 		//��Ч���ش�С�ֶ�
	output		[LONG_REG_WD-1		:0]	ov_payload_size_pix      ;
	output		[SHORT_REG_WD-1		:0]	ov_u3v_size				;

	begin
		assign	o_chunkmodeactive			= i_chunkmodeactive		;
		assign	ov_frame_depth				= iv_frame_depth		;
		assign	ov_h_period 				= iv_h_period 			;
		assign	ov_v_petiod 	        	= iv_v_petiod 			;
		assign	ov_size_x					= iv_size_x				;
		assign	ov_size_y					= iv_size_y				;
		assign	ov_offset_x					= iv_offset_x			;
		assign	ov_offset_y					= iv_offset_y			;
		assign	ov_payload_size_frame_buf	= ov_size_x*ov_size_y 	;
		assign	ov_payload_size_pix			= ov_size_x*ov_size_y 	;
		assign	ov_u3v_size					= 16'hB					;
	end
endtask

endmodule
