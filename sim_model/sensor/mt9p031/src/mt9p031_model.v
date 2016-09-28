//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : mt9p031_model
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/5/26 16:15:13	:|  初始版本
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
`timescale 1ns/100ps
//-------------------------------------------------------------------------------------------------

module mt9p031_model # (
	parameter			IMAGE_SRC				= "RANDOM"			,	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC" or "FRAME_INC_NO_RST"
	parameter			DATA_WIDTH				= 12				,	//数据宽度
	parameter			SENSOR_CLK_DELAY_VALUE	= 0					,	//Sensor 芯片内部延时 单位ns
	parameter			CLK_DATA_ALIGN			= "RISING"			,	//"RISING" - 输出时钟的上升沿与数据对齐。"FALLING" - 输出时钟的下降沿与数据对齐
	parameter			FVAL_LVAL_ALIGN			= "FALSE"			,	//"TRUE" - fval 与 lval 之间的距离固定为3个时钟。"FALSE" - fval 与 lval 之间的距离自由设定
	parameter			SOURCE_FILE_PATH		= "source_file/"	,	//数据源文件路径
	parameter			GEN_FILE_EN				= 0					,	//0-生成的图像不写入文件，1-生成的图像写入文件
	parameter			GEN_FILE_PATH			= "gen_file/"		,	//产生的数据要写入的路径
	parameter			NOISE_EN				= 0						//0-不加入噪声，1-加入噪声
	)
	(
	input								clk							,	//时钟
	input								reset						,	//复位
	input								i_pause_en					,	//1:暂停，立刻暂停 0:恢复
	input								i_continue_lval				,	//1:消隐的时候也有行信号输出，0:消隐的时候没有行信号输出
	input	[15:0]						iv_width					,	//行有效的像素个数，行宽最大64k
	input	[15:0]						iv_line_hide				,	//行消隐的像素个数，行消隐最大64k
	input	[15:0]						iv_height					,	//一帧中的行数，行数最多64k
	input	[15:0]						iv_frame_hide				,	//帧消隐的行数，行数最多64k
	input	[15:0]						iv_front_porch				,	//前沿，fval上升沿和lval上升沿之间的距离，前沿后沿之后不能超过行消隐
	input	[15:0]						iv_back_porch				,	//后沿，fval下降沿和lval下降沿之间的距离
	output								o_clk_pix					,	//输出的时钟
	output								o_fval						,	//场有效
	output								o_lval						,	//行有效
	output	[DATA_WIDTH-1:0]			ov_dout							//数据
	);

	//	ref signals
	wire						w_fval			;
	wire						w_lval			;
	wire						clk_int			;
	wire						w_fval_data		;
	wire						w_lval_data		;
	wire	[DATA_WIDTH-1:0]	wv_pix_data		;
	wire						w_fval_noise	;
	wire						w_lval_noise	;
	wire	[DATA_WIDTH-1:0]	wv_pix_data_noise		;

	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref ***共用信号预处理***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	时钟延迟
	//  -------------------------------------------------------------------------------------
	assign	#SENSOR_CLK_DELAY_VALUE	clk_int	= clk;

	//  -------------------------------------------------------------------------------------
	//	时钟输出
	//  -------------------------------------------------------------------------------------
	generate
		if(CLK_DATA_ALIGN=="RISING") begin
			assign	o_clk_pix	= clk_int;
		end
		else begin
			assign	o_clk_pix	= !clk_int;
		end
	endgenerate

	//  ===============================================================================================
	//	ref ***产生行场时序***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	产生 fval 和 lval 时序
	//  -------------------------------------------------------------------------------------
	frame_line_pattern # (
	.FVAL_LVAL_ALIGN	(FVAL_LVAL_ALIGN	)
	)
	frame_line_pattern_inst (
	.clk				(clk_int			),
	.reset				(reset				),
	.i_pause_en			(i_pause_en			),
	.i_continue_lval	(i_continue_lval	),
	.iv_width			(iv_width			),
	.iv_line_hide		(iv_line_hide		),
	.iv_height			(iv_height			),
	.iv_frame_hide		(iv_frame_hide		),
	.iv_front_porch		(iv_front_porch		),
	.iv_back_porch		(iv_back_porch		),
	.o_fval				(w_fval				),
	.o_lval				(w_lval				)
	);

	//  -------------------------------------------------------------------------------------
	//	产生 数据
	//  -------------------------------------------------------------------------------------
	data_pattern # (
	.IMAGE_SRC			(IMAGE_SRC			),
	.SOURCE_FILE_PATH	(SOURCE_FILE_PATH	),
	.DATA_WIDTH			(DATA_WIDTH			)
	)
	data_pattern_inst (
	.clk				(clk_int			),
	.reset				(reset				),
	.i_fval				(w_fval				),
	.i_lval				(w_lval				),
	.o_fval				(w_fval_data		),
	.o_lval				(w_lval_data		),
	.ov_dout			(wv_pix_data		)
	);

	//  -------------------------------------------------------------------------------------
	//	加入噪声
	//  -------------------------------------------------------------------------------------
	generate
		if(NOISE_EN==1) begin
			sensor_noise # (
			.DATA_WIDTH				(DATA_WIDTH				)
			)
			sensor_noise_inst (
			.clk					(clk_int				),
			.iv_line_active_pix_num	(iv_line_active_pix_num	),
			.i_fval					(w_fval_data			),
			.i_lval					(w_lval_data			),
			.iv_pix_data			(wv_pix_data			),
			.o_fval					(w_fval_noise			),
			.o_lval					(w_lval_noise			),
			.ov_pix_data			(wv_pix_data_noise		)
			);
		end
		else begin
			assign	w_fval_noise		= w_fval_data;
			assign	w_lval_noise		= w_lval_data;
			assign	wv_pix_data_noise	= wv_pix_data;
		end
	endgenerate

	//  -------------------------------------------------------------------------------------
	//	fval lval相位
	//  -------------------------------------------------------------------------------------
	generate
		if(FVAL_LVAL_ALIGN=="TRUE")begin
			fval_lval_phase # (
			.DATA_WIDTH	(DATA_WIDTH		)
			)
			fval_lval_phase_inst (
			.clk		(clk_int		),
			.reset		(reset			),
			.i_fval		(w_fval_noise	),
			.i_lval		(w_lval_noise	),
			.iv_din		(wv_pix_data_noise	),
			.o_fval		(o_fval			),
			.o_lval		(o_lval			),
			.ov_dout	(ov_dout		)
			);
		end
		else begin
			assign	o_fval	= w_fval_noise;
			assign	o_lval	= w_lval_noise;
			assign	ov_dout	= wv_pix_data_noise;
		end
	endgenerate

	//  ===============================================================================================
	//	ref ***文件操作***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	生成的像素数据写入到文件当中
	//  -------------------------------------------------------------------------------------
	generate
		if(GEN_FILE_EN==1) begin
			file_write # (
			.DATA_WIDTH		(DATA_WIDTH		),
			.FILE_PATH		(GEN_FILE_PATH	)
			)
			file_write_inst (
			.clk			(clk_int		),
			.reset			(1'b0			),
			.i_fval			(o_fval			),
			.i_lval			(o_lval			),
			.iv_din			(ov_dout		)
			);
		end
	endgenerate


endmodule
