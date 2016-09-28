//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : pattern_model
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2013/5/24 10:08:24	:|  初始版本
//  -- 邢海涛       :| 2014/6/9 14:52:56	:|  将参数改为端口，方便调试的时候改变帧率
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :	产生 fval 和 dval 时序
//              1)  : 采用parameter的定义方式而非define
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//		宏定义说明如下：
//
//					|<-------	FRAME_ACTIVE_PIX_NUM					------->|<--FRAME_HIDE_PIX_NUM->|
//					_____________________________________________________________						______
//	fval	________|															|_______________________|
//							_________		_________		   	_________
//	dval	________________|		|_______|		|____****___|		|________________________________
//
//					|<-	  ->|		|<-	  ->|<-   ->|					|<-   ->|
//						|				|		|							|
//			FRAME_TO_LINE_PIX_NUM <-----|-------|----------------------------
//							LINE_HIDE_PIX_NUM	|
//								LINE_ACTIVE_PIX_NUM

//-------------------------------------------------------------------------------------------------
//`include        "pattern_model_def.v"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

//module pattern_model # (
//	parameter		LINE_ACTIVE_PIX_NUM		= 100,
//	parameter		LINE_HIDE_PIX_NUM		= 20,
//	parameter		LINE_ACTIVE_NUMBER		= 4,
//	parameter		FRAME_HIDE_PIX_NUM		= 100,
//	parameter		FRAME_TO_LINE_PIX_NUM	= 10
//	)

module pattern_model (
	input			clk,
	input			reset,

	input	[15:0]	iv_line_active_pix_num		,//行有效的像素个数
	input	[15:0]	iv_line_hide_pix_num		,//行消隐的像素个数
	input	[15:0]	iv_line_active_num			,//一帧中的行数
	input	[15:0]	iv_frame_hide_pix_num		,//帧消隐的像素个数
	input	[7:0]	iv_frame_to_line_pix_num	,//从帧开始到行开始的像素个数，从行结束到帧结束的像素个数

	output			o_fval,
	output			o_dval
	);

	//ref signals


	reg		[31:0]		pix_per_frame = 0;
	reg					fval = 1'b0;
	reg		[7:0]		pix_between_frame_line 	= 8'b0;
	reg		[16:0]		pix_per_whole_line 		= 17'b0;
	reg					dval 		= 1'b0;
	reg		[15:0]		line_num 	= 0;
	wire				line_num_less;
	reg					gap_between_frame_line = 1'b0;
	reg					gap_between_frame_line_d = 1'b0;

	//	parameter 			FRAME_ACTIVE_PIX_NUM = LINE_ACTIVE_PIX_NUM * LINE_ACTIVE_NUMBER + LINE_HIDE_PIX_NUM * (LINE_ACTIVE_NUMBER - 1) + FRAME_TO_LINE_PIX_NUM * 2;

	wire			[31:0]	total_active_pix_num	;
	wire			[31:0]	total_hide_pix_num		;
	reg				[31:0]	frame_active_pix_num	;
	reg				[31:0]	whole_frame_pix_num	;
	reg				[15:0]	whole_line_pix_num	;

	//  -------------------------------------------------------------------------------------
	//
	//  -------------------------------------------------------------------------------------


	//ref ARCHITECTURE

	//  ===============================================================================================
	//	输出
	//  ===============================================================================================
	assign	o_fval		= fval;
	assign	o_dval		= dval;

	//  ===============================================================================================
	//	参数计算
	//  ===============================================================================================
	mult_pattern mult_pattern_inst (
	.clk	(clk						),
	.a		(iv_line_active_num			),
	.b		(iv_line_active_pix_num		),
	.p		(total_active_pix_num		)
	);

	mult_pattern mult_pattern_inst1 (
	.clk	(clk						),
	.a		(iv_line_active_num-1'b1	),
	.b		(iv_line_hide_pix_num		),
	.p		(total_hide_pix_num			)
	);

	always @ (posedge clk) begin
		frame_active_pix_num	<= total_active_pix_num + total_hide_pix_num + {iv_frame_to_line_pix_num,1'b0};
	end

	always @ (posedge clk) begin
		whole_frame_pix_num		<= frame_active_pix_num + iv_frame_hide_pix_num - 1'b1;
	end

	always @ (posedge clk) begin
		whole_line_pix_num		<= iv_line_active_pix_num + iv_line_hide_pix_num - 1'b1;
	end




	//  ===============================================================================================
	//	计算流程
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  帧有效 fval 计数
	//	pix per frame 记录了一整帧的pix数目
	//  -------------------------------------------------------------------------------------
	always @ (posedge reset or posedge clk) begin
		if(reset) begin
			pix_per_frame	<= 'b0;
		end else begin
			if(pix_per_frame == whole_frame_pix_num) begin
				pix_per_frame	<= 'b0;
			end else begin
				pix_per_frame	<= pix_per_frame + 1'b1;
			end
		end
	end

	//当超过消隐区的数值时，fval有效
	//复位之后，先进入消隐区
	always @ (posedge clk) begin
		if(pix_per_frame < iv_frame_hide_pix_num) begin
			fval	<= 1'b0;
		end else begin
			fval	<= 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  帧有效 fval 与数据有效 dval 之间的空隙
	//	pix between frame line 指的是帧有效的边沿和行有效的边沿之间的距离
	//  -------------------------------------------------------------------------------------
	always @ (posedge reset or posedge clk) begin
		if(reset) begin
			pix_between_frame_line	<= 'b0;
		end else begin
			if(fval == 1'b1) begin
				if(pix_between_frame_line != (iv_frame_to_line_pix_num - 2'b10)) begin
					pix_between_frame_line	<= pix_between_frame_line + 1'b1;
				end
			end else begin
				pix_between_frame_line	<= 'b0;
			end
		end
	end

	always @ (posedge clk) begin
		if(pix_between_frame_line == (iv_frame_to_line_pix_num - 2'b10)) begin
			gap_between_frame_line	<= 1'b1;
		end else begin
			gap_between_frame_line	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  行像素计数器
	//	pix per whole line 记录的是一行中(行有效时间 + 行消隐时间)像素点数
	//	总行数小于指定的行数且帧有效边沿与行有效边沿的条件满足
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(line_num < iv_line_active_num) begin
			if(fval&gap_between_frame_line) begin
				if(pix_per_whole_line	== whole_line_pix_num) begin
					pix_per_whole_line	<= 0;
				end else begin
					pix_per_whole_line	<= pix_per_whole_line + 1;
				end
			end
		end else begin
			pix_per_whole_line	<= 0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  行个数计数器
	//  -------------------------------------------------------------------------------------
	always @ (posedge reset or posedge clk) begin
		if(reset) begin
			line_num	<= 0;
		end else begin
			if(gap_between_frame_line == 1'b0) begin
				line_num	<= 0;
			end else begin
				if(pix_per_whole_line == iv_line_active_pix_num - 1'b1) begin
					line_num	<= line_num + 1;
				end
			end
		end
	end

	assign	line_num_less	= (line_num < iv_line_active_num) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//  数据有效 dval 的逻辑
	//  -------------------------------------------------------------------------------------
	//--1 帧有效和数据有效之间的间隔
	//--2 处于行有效期内

	always @ (posedge clk) begin
		//		if((gap_between_frame_line == 1'b1)&&(pix_per_whole_line < LINE_ACTIVE_PIX_NUM )&&(line_num < LINE_ACTIVE_NUMBER)) begin
		//		if((gap_between_frame_line == 1'b1)&&(pix_per_whole_line < LINE_ACTIVE_PIX_NUM )&&(line_num_d < LINE_ACTIVE_NUMBER)) begin
		if((gap_between_frame_line == 1'b1)&&(pix_per_whole_line < iv_line_active_pix_num )&&(line_num_less == 1'b1)) begin
			dval	<= 1'b1;
		end else begin
			dval	<= 1'b0;
		end
	end



endmodule
