//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : ad_timing_generation
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/8/9 13:22:15	:|  ��ʼ�汾
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

module ad_timing_generation (
	input				clk					,	//�ڲ�ʱ��
	input				i_vd				,	//vd�źţ��첽ʱ����
	input				i_hd				,	//hd�źţ��첽ʱ����
	//sync word
	input				i_sync_align_loc	,	//ͬ����λ�ã�0���ұߣ�1�����
	input	[12:0]		iv_sync_start_loc	,	//ͬ������ʼλ��
	input	[15:0]		iv_sync_word0		,	//Synchronization Word 0 data bits.
	input	[15:0]		iv_sync_word1		,	//Synchronization Word 1 data bits.
	input	[15:0]		iv_sync_word2		,	//Synchronization Word 2 data bits.
	input	[15:0]		iv_sync_word3		,	//Synchronization Word 3 data bits.
	input	[15:0]		iv_sync_word4		,	//Synchronization Word 4 data bits.
	input	[15:0]		iv_sync_word5		,	//Synchronization Word 5 data bits.
	input	[15:0]		iv_sync_word6		,	//Synchronization Word 6 data bits.
	output				o_sync_word_sel		,	//sync_wordѡ���ź�
	output	[15:0]		ov_sync_word		,	//sync_word����
	//hblk
	input	[12:0]		iv_hblk_tog1		,	//hblk���
	input	[12:0]		iv_hblk_tog2		,	//hblk�յ�
	output				o_hblk_n				//hblk�ź�
	);

	//	ref signals

	reg		[2:0]		hd_shift		= 3'b0;
	reg		[10:0]		hd_fall_shift	= 11'b0;
	wire				hd_fall			;
	reg		[12:0]		hcount			= 13'b0;
	reg		[12:0]		hcount_max		= 13'b0;
	reg		[12:0]		sync_start_pos	= 13'b0;
	reg		[12:0]		sync_end_pos	= 13'b0;
	reg					sync_word_sel	= 1'b0;
	reg					sync_word_sel_dly	= 1'b0;
	reg		[2:0]		sync_word_cnt	= 3'b0;
	reg		[15:0]		sync_word_reg	= 16'b0;

	reg		[12:0]		hblk_start_pos	= 13'b0;
	reg		[12:0]		hblk_end_pos	= 13'b0;
	reg					hblk_reg		= 1'b0;



	//	ref ARCHITECTURE
	//	===============================================================================================
	//	ref ***hcount ������***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	�ж�hd�ı���
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		hd_shift	<= {hd_shift[1:0],i_hd};
	end
	assign	hd_fall	= (hd_shift[2:1]==2'b10) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	��ʱhd���½���
	//	ad9970�ֲ���������hd�½���֮��12��ʱ�����ڣ��ŻḴλhcount
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		hd_fall_shift	<= {hd_fall_shift[10:0],hd_fall};
	end

	//	-------------------------------------------------------------------------------------
	//	���ؼ�����
	//	��ʱһ��ʱ��֮�󣬲ŻḴλ
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(hd_fall_shift[10]==1'b1) begin
//		if(hd_fall_shift[8]==1'b1) begin
			hcount	<= 13'b0;
		end
		else begin
			hcount	<= hcount + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	����hcount�����ֵ
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(hd_fall_shift[10]==1'b1) begin
//		if(hd_fall_shift[8]==1'b1) begin
			hcount_max	<= hcount;
		end
	end

	//	===============================================================================================
	//	ref ***sync word***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	ͬ����Ƕ��λ��
	//	--Ϊ�˺ͺ���ģ����룬��ǰ2�Ĳ���
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_sync_align_loc==1'b0) begin
			sync_start_pos	<= iv_sync_start_loc-1;
			sync_end_pos	<= iv_sync_start_loc+7-1;
		end
		else begin
			sync_start_pos	<= hcount_max-iv_sync_start_loc-7+1;
			sync_end_pos	<= hcount_max-iv_sync_start_loc+1;
		end
	end

	always @ (posedge clk) begin
		if(hcount==sync_end_pos) begin
			sync_word_sel	<= 1'b0;
		end
		else if(hcount==sync_start_pos) begin
			sync_word_sel	<= 1'b1;
		end
	end

	always @ (posedge clk) begin
		sync_word_sel_dly	<= sync_word_sel;
	end
	assign	o_sync_word_sel	= sync_word_sel_dly;

	//	-------------------------------------------------------------------------------------
	//	ͬ���ּ�����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!sync_word_sel) begin
			sync_word_cnt	<= 3'b0;
		end
		else begin
			sync_word_cnt	<= sync_word_cnt + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	ѡ��ͬ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(sync_word_sel) begin
			case(sync_word_cnt)
				0		: sync_word_reg	<= iv_sync_word0;
				1		: sync_word_reg	<= iv_sync_word1;
				2		: sync_word_reg	<= iv_sync_word2;
				3		: sync_word_reg	<= iv_sync_word3;
				4		: sync_word_reg	<= iv_sync_word4;
				5		: sync_word_reg	<= iv_sync_word5;
				6		: sync_word_reg	<= iv_sync_word6;
				default	: sync_word_reg	<= 16'b0;
			endcase
		end
		else begin
			sync_word_reg	<= 16'b0;
		end
	end
	assign	ov_sync_word	= sync_word_reg	;

	//	===============================================================================================
	//	ref ***hblk***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	ͬ����Ƕ��λ��
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(iv_hblk_tog1 <= iv_hblk_tog1) begin
			hblk_start_pos	<= iv_hblk_tog1;
			hblk_end_pos	<= iv_hblk_tog2;
		end
		else begin
			hblk_start_pos	<= iv_hblk_tog2;
			hblk_end_pos	<= iv_hblk_tog1;
		end
	end

	always @ (posedge clk) begin
		if(hcount==hblk_start_pos) begin
			hblk_reg	<= 1'b0;
		end
		else if(hcount==hblk_end_pos) begin
			hblk_reg	<= 1'b1;
		end
	end
	assign	o_hblk_n	= hblk_reg;

endmodule
