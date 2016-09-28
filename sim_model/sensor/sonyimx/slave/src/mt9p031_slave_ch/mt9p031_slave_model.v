//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : mt9p031_slave_model
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

module mt9p031_slave_model # (
	parameter			IMAGE_SRC				= "RANDOM"			,	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC" or "FRAME_INC_NO_RST" or "PIX_INC_NO_FVAL" or "PIX_INC"
	parameter			DATA_WIDTH				= 12				,	//数据宽度
	parameter			CHANNEL_NUM				= 4					,	//通道数
	parameter			VBLANK_LINE				= 22				,	//Vertical blanking period
	parameter			FRAME_INFO_LINE			= 1					,	//Frame information line
	parameter			IGNORE_OB_LINE			= 6					,	//Ignored OB
	parameter			VEFFECT_OB_LINE			= 4					,	//Vertical effective OB
	parameter			SOURCE_FILE_PATH		= "source_file/"	,	//数据源文件路径
	parameter			GEN_FILE_EN				= 0					,	//0-生成的图像不写入文件，1-生成的图像写入文件
	parameter			GEN_FILE_PATH			= "gen_file/"		,	//产生的数据要写入的路径
	parameter			NOISE_EN				= 0						//0-不加入噪声，1-加入噪声

	)
	(
	input										clk							,	//时钟
	input										reset						,	//复位
	input										i_xtrig						,	//触发信号，上升沿之后，新的一帧开始传输
	input										i_xhs						,	//行有效信号，上升沿之后，新的一行开始传输
	input										i_xvs						,	//场有效信号，没有用到
	input										i_xclr						,	//复位信号，低有效
	input										i_pause_en					,	//1:暂停，立刻暂停 0:恢复
	input										i_continue_lval				,	//1:消隐的时候也有行信号输出，0:消隐的时候没有行信号输出
	input	[15:0]								iv_width					,	//行有效的像素个数，行宽最大64k
	input	[15:0]								iv_height					,	//一帧中的行数，行数最多64k
	output										o_fval						,	//场有效
	output										o_lval						,	//行有效
	output	[DATA_WIDTH*CHANNEL_NUM-1:0]		ov_dout							//数据
	);

	//	ref signals
	wire									w_fval			;
	wire									w_lval			;
	wire									w_fval_data		;
	wire									w_lval_data		;
	wire	[DATA_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data		;
	wire									w_fval_noise	;
	wire									w_lval_noise	;
	wire	[DATA_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_noise		;

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***产生行场时序***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	产生 fval 和 lval 时序
	//  -------------------------------------------------------------------------------------
	frame_line_pattern # (
	.VBLANK_LINE		(VBLANK_LINE		),
	.FRAME_INFO_LINE	(FRAME_INFO_LINE	),
	.IGNORE_OB_LINE		(IGNORE_OB_LINE		),
	.VEFFECT_OB_LINE	(VEFFECT_OB_LINE	)
	)
	frame_line_pattern_inst (
	.clk				(clk				),
	.reset				(reset				),
	.i_xtrig			(i_xtrig			),
	.i_xhs				(i_xhs				),
	.i_xvs				(i_xvs				),
	.i_xclr				(i_xclr				),
	.i_pause_en			(i_pause_en			),
	.i_continue_lval	(1'b1				),
	.iv_width			(iv_width			),
	.iv_line_hide		(16'd10				),
	.iv_height			(iv_height			),
	.iv_frame_hide		(16'd5				),
	.iv_front_porch		(16'd5				),
	.iv_back_porch		(16'd5				),
	.o_fval				(w_fval				),
	.o_lval				(w_lval				)
	);

	//  -------------------------------------------------------------------------------------
	//	产生 数据
	//  -------------------------------------------------------------------------------------
	data_pattern # (
	.IMAGE_SRC			(IMAGE_SRC			),
	.CHANNEL_NUM		(CHANNEL_NUM		),
	.SOURCE_FILE_PATH	(SOURCE_FILE_PATH	),
	.DATA_WIDTH			(DATA_WIDTH			)
	)
	data_pattern_inst (
	.clk				(clk				),
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
			.DATA_WIDTH				(DATA_WIDTH				),
			.CHANNEL_NUM			(CHANNEL_NUM			)
			)
			sensor_noise_inst (
			.clk					(clk					),
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
	assign	o_fval	= w_fval_noise;
	assign	o_lval	= w_lval_noise;
	assign	ov_dout	= wv_pix_data_noise;

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
			.CHANNEL_NUM	(CHANNEL_NUM	),
			.FILE_PATH		(GEN_FILE_PATH	)
			)
			file_write_inst (
			.clk			(clk			),
			.reset			(1'b0			),
			.i_fval			(o_fval			),
			.i_lval			(o_lval			),
			.iv_din			(ov_dout		)
			);
		end
	endgenerate


endmodule
