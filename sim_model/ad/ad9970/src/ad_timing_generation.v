//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : ad_timing_generation
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/8/9 13:22:15	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module ad_timing_generation (
	input				clk					,	//内部时钟
	input				i_vd				,	//vd信号，异步时钟域
	input				i_hd				,	//hd信号，异步时钟域
	//sync word
	input				i_sync_align_loc	,	//同步字位置，0：右边，1：左边
	input	[12:0]		iv_sync_start_loc	,	//同步字起始位置
	input	[15:0]		iv_sync_word0		,	//Synchronization Word 0 data bits.
	input	[15:0]		iv_sync_word1		,	//Synchronization Word 1 data bits.
	input	[15:0]		iv_sync_word2		,	//Synchronization Word 2 data bits.
	input	[15:0]		iv_sync_word3		,	//Synchronization Word 3 data bits.
	input	[15:0]		iv_sync_word4		,	//Synchronization Word 4 data bits.
	input	[15:0]		iv_sync_word5		,	//Synchronization Word 5 data bits.
	input	[15:0]		iv_sync_word6		,	//Synchronization Word 6 data bits.
	output				o_sync_word_sel		,	//sync_word选中信号
	output	[15:0]		ov_sync_word		,	//sync_word数据
	//hblk
	input	[12:0]		iv_hblk_tog1		,	//hblk起点
	input	[12:0]		iv_hblk_tog2		,	//hblk终点
	output				o_hblk_n				//hblk信号
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
	//	ref ***hcount 计数器***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	判断hd的边沿
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		hd_shift	<= {hd_shift[1:0],i_hd};
	end
	assign	hd_fall	= (hd_shift[2:1]==2'b10) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	延时hd的下降沿
	//	ad9970手册描述，在hd下降沿之后12个时钟周期，才会复位hcount
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		hd_fall_shift	<= {hd_fall_shift[10:0],hd_fall};
	end

	//	-------------------------------------------------------------------------------------
	//	像素计数器
	//	延时一段时间之后，才会复位
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
	//	保存hcount的最大值
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
	//	同步字嵌入位置
	//	--为了和后续模块对齐，提前2拍产生
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
	//	同步字计数器
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
	//	选择同步字
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
	//	同步字嵌入位置
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
