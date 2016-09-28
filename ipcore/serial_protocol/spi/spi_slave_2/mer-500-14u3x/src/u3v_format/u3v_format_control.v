//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : u3v_format_control
//  -- 设计者       : 张强
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 张强         :| 2014/12/3 10:37:03	:|  根据技术预研整理
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述
//              1)  : U3V格式控制模块，用来生成各阶段标志、控制leader、payload、trailer顺序拼接和时序衔接。
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module u3v_format_control #	(
	parameter							DATA_WD			=32		,		//输入输出数据位宽，这里使用同一宽度
	parameter							SHORT_REG_WD 	=16		,		//短寄存器位宽
	parameter							REG_WD 			=32		,		//寄存器位宽
	parameter							LONG_REG_WD 	=64				//长寄存器位宽
)
(
//  ===============================================================================================
//  第一部分：时钟复位
//  ===============================================================================================
	input								reset					,		//复位信号，高电平有效，像素时钟时钟域
	input								clk						,		//时钟信号，像素时钟时钟域，同内部像素时钟
//  ===============================================================================================
//  第二部分：行、场、数据、数据有效
//  ===============================================================================================
	input								i_fval					,       //数据通路输出的场信号，像素时钟时钟域,fval的信号是经过数据通道加宽过的场信号，场头可以添加leader、并包含有效的图像数据，停采期间保持低电平
	input								i_leader_valid			,		//添加完头的数据有效信号
	input		[DATA_WD-1			:0]	iv_leader_data          ,		//头包数据
	input								i_payload_valid			,		//添加完头的数据有效信号
	input		[DATA_WD-1			:0]	iv_payload_data         ,		//头包数据
	input								i_trailer_valid			,		//添加完头的数据有效信号
	input		[DATA_WD-1			:0]	iv_trailer_data         ,		//头包数据
	input								i_chunk_mode_active		,		//chunk开关

//  ===============================================================================================
//  第三部分：控制寄存器和输出标志
//  ===============================================================================================

	input								i_stream_enable			,		//流使能信号，像素时钟时钟域，=0，chunk中的BLOCK ID为0
	output	reg							o_leader_flag			,       //头包标志
	output	reg							o_image_flag			,       //负载包中的图像信息标志
	output	reg							o_chunk_flag			,		//添加chunk信息标志
	output	reg							o_trailer_flag          ,		//尾包标志
	output	reg	[LONG_REG_WD-1		:0]	ov_blockid				,		//头包、chunk、尾包的blockid信息，第一帧的block ID从0开始计数，第一帧block ID为0
	output	reg							o_fval					,       //添加完头尾和帧信息的场信号
	output	reg							o_data_valid			,       //添加完头尾的数据有效信号
	output	reg	[DATA_WD-1			:0]	ov_data                         //满足U3V协议的数据包
	);

//  ===============================================================================================
//  本地参数定义：通过参数定义确定标志输出的位置，注意参数不能使用最大值31
//  fval上升沿到leader前沿预留10个宽度
//  leader_flag宽度13
//  chunk_flag宽度10
//  trailer_flag宽度9
//	trailer_flag到fval下降沿10
//  ===============================================================================================
	localparam							LEADER_FLAG_RISING 	=6'd10		;		//leaer_flag上升沿位置		leader前预留13个宽度
	localparam							LEADER_FLAG_FALING 	=6'd23		;		//leaer_flag下降沿位置  	leader宽度13
	localparam							CHUNK_FLAG_RISING 	=6'd1		;		//chunk_flag上升沿位置
	localparam							CHUNK_FLAG_FALING 	=6'd11		;		//chunk_flag下降沿位置		chunk宽度10
	localparam							TRAILER_FLAG_RISING =6'd20		;		//trailer_flag上升沿位置
	localparam							TRAILER_FLAG_FALING =6'd31		;		//trailer_flag下降沿位置	trailer宽度9+2 方便frame_buffer模块添加trailer
	localparam							FVAL_FALING 		=6'd40		;		//o_fval下降沿位置			fval下降沿预留9个宽度
//  ===============================================================================================
//  寄存器定义
//  ===============================================================================================
	reg		[4						:0]	leader_count					;		//用于添加头的计数器
	reg		[5						:0]	trailer_count					;		//用于添加尾的计数器
	reg		[2						:0]	fval_shift			=3'b000		;		//fval移位寄存器
	reg									w_trailer_flag					;		//尾包标志延时一拍
//  ===============================================================================================
//  取场信号i_fval的边沿
//  ===============================================================================================
	always @ (posedge clk ) begin
		fval_shift	<=	{fval_shift[1:0],i_fval};
	end
//  ===============================================================================================
//  使用边沿启动计数
//  ===============================================================================================
	always @ ( posedge clk) begin
		if ( fval_shift[2:1] == 2'b01 ) begin				//上升沿计数器复位
			leader_count	<=	 5'h00;
		end
		else if ( leader_count >= 5'h1f ) begin
			leader_count	<=	 5'h1f;
		end
		else begin
			leader_count	<=	leader_count + 5'h01;
		end
	end


	always @ ( posedge clk) begin
		if ( fval_shift[2:1] == 2'b10 ) begin				//下降沿计数器复位
			trailer_count	<=	 6'h00;
		end
		else if ( trailer_count >= 6'h3f ) begin
			trailer_count	<=	 6'h3f;
		end
		else begin
			trailer_count	<=	trailer_count + 6'h01;
		end
	end
//  ===============================================================================================
//  生成标志
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//  leader_count在LEADER_FLAG_RISING 和LEADER_FLAG_FALING 范围内输出标志
//  -------------------------------------------------------------------------------------

	always @ ( posedge clk) begin
		if ( reset ) begin
			o_leader_flag	<=	1'b0	;
		end
		else if ( (leader_count >= LEADER_FLAG_RISING-1)  && (leader_count < LEADER_FLAG_FALING-1) ) begin
			o_leader_flag	<=	 1'b1;
		end
		else begin
			o_leader_flag	<=	 1'b0;
		end
	end
//  -------------------------------------------------------------------------------------
//  o_chunk_flag在CHUNK_FLAG_RISING 和CHUNK_FLAG_FALING 范围内且o_chunk_mode_active打开，输出标志
//  -------------------------------------------------------------------------------------
	always @ ( posedge clk) begin
		if ( reset ) begin
			o_chunk_flag	<=	1'b0	;
		end
		else if ( (trailer_count >= CHUNK_FLAG_RISING)  && (trailer_count < CHUNK_FLAG_FALING) && i_chunk_mode_active ) begin
			o_chunk_flag	<=	 1'b1;
		end
		else begin
			o_chunk_flag	<=	 1'b0;
		end
	end
//  -------------------------------------------------------------------------------------
//
//  -------------------------------------------------------------------------------------
//  -------------------------------------------------------------------------------------
//  o_trailer_flag在TRAILER_FLAG_RISING 和TRAILER_FLAG_FALING 范围内且o_chunk_mode_active打开，输出标志
//  -------------------------------------------------------------------------------------

	always @ ( posedge clk) begin
		if ( reset ) begin
			o_trailer_flag	<=	1'b0	;
		end
		else if ( (trailer_count >= TRAILER_FLAG_RISING)  && (trailer_count <= TRAILER_FLAG_FALING) ) begin
			o_trailer_flag	<=	 1'b1;
		end
		else begin
			o_trailer_flag	<=	 1'b0;
		end
	end
//  -------------------------------------------------------------------------------------
//  o_image_flag,leader_flag之后输出o_image_flag，场有效为低时输出0
//  -------------------------------------------------------------------------------------

	always @ ( posedge clk) begin
		if ( reset ) begin
			o_image_flag	<=	1'b0	;
		end
		else if (leader_count == LEADER_FLAG_FALING-1) begin
			o_image_flag	<=	 1'b1;
		end
		else if ( !i_fval ) begin
			o_image_flag	<=	 1'b0;
		end
	end
//  -------------------------------------------------------------------------------------
//  o_fval 场有效到为计数器记到FVAL_FALING
//  -------------------------------------------------------------------------------------

	always @ ( posedge clk) begin
		if ( reset ) begin
			o_fval	<=	1'b0	;
		end
		else if (i_fval) begin
			o_fval	<=	1'b1	;
		end
		else if ( trailer_count == FVAL_FALING ) begin
			o_fval	<=	 1'b0;
		end
	end

//  ===============================================================================================
//  block_id
//  ===============================================================================================
	always @ (posedge clk) begin
		if ( reset ) begin
			ov_blockid	<=	64'hffff_ffff_ffff_ffff;
		end
		else if ( !i_stream_enable) begin		// 顶层模块保证 i_stream_enable 属于clk时钟域
			ov_blockid	<=	64'hffff_ffff_ffff_ffff;
		end
		else if ( fval_shift[2:1] == 2'b01 ) begin
			ov_blockid	<=	ov_blockid + 64'h1;
		end
	end

//  ===============================================================================================
//  由i_trailer_valid调整为o_trailer_flag延时一拍，为了frame_buffer模块识别尾包
//	w_trailer_flag  _________|——————————————————————————————————|_____________
//	尾包数据有效     _________|——————————————————————————————————|_____________
//	尾包数据	     ____________X=============================X_______________
//
//	有效标志前后各留一个空数据
//  ===============================================================================================

	always @ ( posedge clk ) begin
		w_trailer_flag	<=	o_trailer_flag ;
	end

	always @ ( posedge clk ) begin
		if (  reset )begin
			o_data_valid	<=	1'b0	;
		end
		else begin
			o_data_valid	<=	i_leader_valid | i_payload_valid | w_trailer_flag ;	// 由i_trailer_valid调整为o_trailer_flag，为了frame_buffer模块识别尾包
		end
	end

	always @ (posedge clk) begin
		if (  reset )begin
			ov_data	<=	{DATA_WD{1'b0}}	;
		end
		else if ( i_leader_valid ) begin
			ov_data	<=	iv_leader_data	;
		end
		else if ( i_payload_valid ) begin
			ov_data	<=	iv_payload_data	;
		end
		else if ( i_trailer_valid ) begin
			ov_data	<=	iv_trailer_data	;
		end
		else begin
			ov_data	<=	{DATA_WD{1'b0}}	;
		end
	end
endmodule