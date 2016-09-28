//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : bfm_python
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/4/3 15:04:32	:|  初始版本
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
module bfm_python # (
	parameter	IMAGE_SRC				= "RANDOM"			,	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC" or "FRAME_INC_NO_RST"
	parameter	DATA_WIDTH				= 12				,	//数据宽度
	parameter	SENSOR_CLK_DELAY_VALUE	= 0					,	//Sensor 芯片内部延时 单位ns
	parameter	CLK_DATA_ALIGN			= "RISING"			,	//"RISING" - 输出时钟的上升沿与数据对齐。"FALLING" - 输出时钟的下降沿与数据对齐
	parameter	FVAL_LVAL_ALIGN			= "FALSE"			,	//"TRUE" - fval 与 lval 之间的距离固定为3个时钟。"FALSE" - fval 与 lval 之间的距离自由设定
	parameter	SOURCE_FILE_PATH		= "source_file/"	,	//数据源文件路径
	parameter	GEN_FILE_EN				= 0					,	//0-生成的图像不写入文件，1-生成的图像写入文件
	parameter	GEN_FILE_PATH			= "gen_file/"		,	//产生的数据要写入的路径
	parameter	NOISE_EN				= 0						//0-不加入噪声，1-加入噪声

	)
	(
	input		clk			,
	input		o_fval
	);

	//	ref signals
	//  -------------------------------------------------------------------------------------
	//	可以配置的寄存器和线网
	//  -------------------------------------------------------------------------------------
	reg		[15:0]		iv_width					= 16'd16	;
	reg		[15:0]		iv_line_hide				= 16'd10	;
	reg		[15:0]		iv_height					= 16'd16	;
	reg		[15:0]		iv_frame_hide				= 16'd5		;
	reg		[15:0]		iv_front_porch				= 16'd4		;
	reg		[15:0]		iv_back_porch				= 16'd3		;

	reg					reset		= 1'b0;
	reg					i_pause_en	= 1'b0;
	reg					i_continue_lval	= 1'b0;

	reg					pll_init_done	= 1'b0;
	reg					data_init_done	= 1'b0;

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***task***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	--ref sensor pattern
	//  -------------------------------------------------------------------------------------
	task pattern_2para;
		input	[15:0]		width_input;
		input	[15:0]		height_input;
		begin
			#200
			iv_width			= width_input	;
			iv_line_hide		= 16'd10		;
			iv_height			= height_input	;
			iv_front_porch		= iv_line_hide/2		;
			iv_back_porch		= iv_line_hide/2		;
			iv_frame_hide		= 10'd5	;
		end
	endtask

	task pattern_5para;
		input	[15:0]				width_input			;
		input	[15:0]				line_hide_input		;
		input	[15:0]				height_input		;
		input	[15:0]				frame_hide_input	;
		input	[15:0]				porch_input			;
		begin
			#200
			iv_width			= width_input		;
			iv_line_hide		= line_hide_input	;
			iv_height			= height_input		;
			iv_frame_hide		= frame_hide_input	;
			iv_front_porch		= porch_input		;
			iv_back_porch		= porch_input		;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref sensor 大小动态切换
	//	-------------------------------------------------------------------------------------
	task pattern_random;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		width;
		reg		[15:0]		height;
		begin
			//	-------------------------------------------------------------------------------------
			//	在 start point 和 stop point 之间，产生一个随机数
			//	-------------------------------------------------------------------------------------
			width	= $random()%(end_point-start_point)+start_point;
			width	= width+4-width%4;
			height	= $random()%(end_point-start_point)+start_point;
			height	= height+4-height%4;
			@ (negedge o_fval);
			reset	= 1'b1;
			@ (posedge clk);
			pattern_2para(width,height);
			@ (posedge clk);
			reset	= 1'b0;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref sensor 复位
	//	-------------------------------------------------------------------------------------
	task reset_high;
		begin
			#1
			reset	= 1'b1;
		end
	endtask

	task reset_low;
		begin
			#1
			reset	= 1'b0;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	循环复位sensor，使之产生不同大小的图像
	//	-------------------------------------------------------------------------------------
	task reset_repeat;
		integer		i;
		begin
			reset	= 1'b0;
			for(i=1;i<30;i=i+1) begin
				wait(o_fval==1'b1);
				repeat(i) @ (posedge clk);
				reset	= 1'b1;
				@ (posedge clk);
				reset	= 1'b0;
				repeat(20) @ (posedge clk);
			end
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	循环复位sensor，使之产生不同大小的图像
	//	-------------------------------------------------------------------------------------
	task reset_random;
		input	[15:0]		start_point	;
		input	[15:0]		end_point	;

		reg		[15:0]		time_slot;
		begin
			//	-------------------------------------------------------------------------------------
			//	在 start point 和 stop point 之间，产生一个随机数
			//	-------------------------------------------------------------------------------------
			time_slot	= $random()%(end_point-start_point)+start_point;
			@ (posedge o_fval);
			repeat(time_slot) @ (posedge clk);
			reset	= 1'b1;
			@ (posedge clk);
			reset	= 1'b0;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref pause_en 暂停
	//	-------------------------------------------------------------------------------------
	task pause_high;
		begin
			#1
			i_pause_en	= 1'b1;
		end
	endtask

	task pause_low;
		begin
			#1
			i_pause_en	= 1'b0;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref continue_lval 暂停
	//	-------------------------------------------------------------------------------------
	task continue_lval_high;
		begin
			#1
			i_continue_lval	= 1'b1;
		end
	endtask

	task continue_lval_low;
		begin
			#1
			i_continue_lval	= 1'b0;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref pll_init_done
	//	-------------------------------------------------------------------------------------
	task pll_init_done_high;
		begin
			#1
			pll_init_done	= 1'b1;
		end
	endtask

	task pll_init_done_low;
		begin
			#1
			pll_init_done	= 1'b0;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref data_init_done
	//	-------------------------------------------------------------------------------------
	task data_init_done_high;
		begin
			#1
			data_init_done	= 1'b1;
		end
	endtask

	task data_init_done_low;
		begin
			#1
			data_init_done	= 1'b0;
		end
	endtask







endmodule
