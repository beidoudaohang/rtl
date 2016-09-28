//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : bfm_ad9970
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/7/15 13:34:25	:|  ��ʼ�汾
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

module bfm_ad9970 ();

	//	ref signals
	reg						i_lvds_pattern_en	= 1'b0		;
	reg		[15:0]			iv_lvds_pattern		= 16'h55aa	;
	reg						i_sync_align_loc	= 1'b0	;
	reg		[12:0]			iv_sync_start_loc	= 13'b0	;
	reg		[15:0]			iv_sync_word0		= 16'h5a58	;
	reg		[15:0]			iv_sync_word1		= 16'h5a58	;
	reg		[15:0]			iv_sync_word2		= 16'h5a58	;
	reg		[15:0]			iv_sync_word3		= 16'h5a58	;
	reg		[15:0]			iv_sync_word4		= 16'h5a58	;
	reg		[15:0]			iv_sync_word5		= 16'h5a58	;
	reg		[15:0]			iv_sync_word6		= 16'h5a58	;

	reg		[12:0]			iv_hblk_tog1		= 13'd0	;
	reg		[12:0]			iv_hblk_tog2		= 13'd142	;
	reg						i_hl_mask_pol		= 1'b1	;
	reg						i_h1_mask_pol		= 1'b1	;
	reg						i_h2_mask_pol		= 1'b0	;

	reg		[3:0]			iv_tclk_delay		= 4'b0	;

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	--ref lvds pattern
	//	-------------------------------------------------------------------------------------
	task lvds_pattern_en_high;
		begin
			#1
			i_lvds_pattern_en	= 1'b1;
		end
	endtask

	task lvds_pattern_en_low;
		begin
			#1
			i_lvds_pattern_en	= 1'b0;
		end
	endtask

	task lvds_pattern;
		input	[15:0]		lvds_pattern_input;
		begin
			#1
			iv_lvds_pattern	= lvds_pattern_input;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref sync word
	//	-------------------------------------------------------------------------------------
	task sync_align_right;
		begin
			#1
			i_sync_align_loc	= 1'b0;
		end
	endtask

	task sync_align_left;
		begin
			#1
			i_sync_align_loc	= 1'b1;
		end
	endtask

	task sync_start_loc;
		input	[12:0]		iv_sync_start_loc_in;
		begin
			#1
			iv_sync_start_loc		= iv_sync_start_loc_in	;
		end
	endtask

	task sync_word;
		input	[15:0]		sync_word0;
		input	[15:0]		sync_word1;
		input	[15:0]		sync_word2;
		input	[15:0]		sync_word3;
		input	[15:0]		sync_word4;
		input	[15:0]		sync_word5;
		input	[15:0]		sync_word6;
		begin
			#1
			iv_sync_word0		= sync_word0	;
			iv_sync_word1		= sync_word1	;
			iv_sync_word2		= sync_word2	;
			iv_sync_word3		= sync_word3	;
			iv_sync_word4		= sync_word4	;
			iv_sync_word5		= sync_word5	;
			iv_sync_word6		= sync_word6	;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref hblk
	//	-------------------------------------------------------------------------------------
	task hblk_tog1;
		input	[12:0]		hblk_tog1_input;
		begin
			#1
			iv_hblk_tog1		= hblk_tog1_input	;
		end
	endtask

	task hblk_tog2;
		input	[12:0]		hblk_tog2_input;
		begin
			#1
			iv_hblk_tog2		= hblk_tog2_input	;
		end
	endtask

	task hl_h1_h2_mask_pol;
		input	[2:0]		hl_h1_h2_mask_input;
		begin
			#1
			i_hl_mask_pol		= hl_h1_h2_mask_input[0]	;
			i_h1_mask_pol		= hl_h1_h2_mask_input[1]	;
			i_h2_mask_pol		= hl_h1_h2_mask_input[2]	;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref lvds serializer
	//	-------------------------------------------------------------------------------------
	task tclk_delay;
		input	[3:0]		iv_tclk_delay_in;
		begin
			#1
			iv_tclk_delay		= iv_tclk_delay_in	;
		end
	endtask

endmodule
