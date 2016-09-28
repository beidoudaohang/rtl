//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : hispi_if
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/10/27 13:37:39	:|  初始版本
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

module hispi_if # (
	parameter		SER_FIRST_BIT			= "LSB"		,	//"LSB" or "MSB" , first bit to the receiver
	parameter		DESER_WIDTH				= 6			,	//解串因子
	parameter		CHANNEL_NUM				= 4			,	//通道数
	parameter		SENSOR_DAT_WIDTH		= 12		,	//像素数据宽度
	parameter		TD_OFFSET_WIDTH			= 13		
	)
	(
	input										clk					,	//时钟
	input										reset				,	//复位
	input	[DESER_WIDTH*CHANNEL_NUM-1:0]		iv_data				,	//输入并行数据
	input	[TD_OFFSET_WIDTH-1:0]				iv_td_offset_x_start,	//起始x
	input	[TD_OFFSET_WIDTH-1:0]				iv_td_offset_width	,	//宽度
	input	[TD_OFFSET_WIDTH-1:0]				iv_td_offset_y_start,	//起始y（暂未用）
	input	[TD_OFFSET_WIDTH-1:0]				iv_td_offset_height	,	//高度（暂未用）
	output										o_first_frame_detect,	//检测到第一个完整帧
	output										o_clk_en			,	//时钟使能信号
	output										o_fval				,	//输出场有效信号
	output										o_lval				,	//输出行有效信号
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	ov_pix_data		 		//输出像素数据

	);

	//	ref signals
	wire												w_clk_en	;
	wire												w_sync		;
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]			wv_data		;


	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	通道对齐模块
	//	-------------------------------------------------------------------------------------
	word_aligner_top # (
	.SER_FIRST_BIT	(SER_FIRST_BIT	),
	.DESER_WIDTH	(DESER_WIDTH	),
	.CHANNEL_NUM	(CHANNEL_NUM	)
	)
	word_aligner_top_inst (
	.clk			(clk			),
	.reset			(reset			),
	.iv_data		(iv_data		),
	.o_clk_en		(w_clk_en		),
	.o_sync			(w_sync			),
	.ov_data		(wv_data		)
	);

	//	-------------------------------------------------------------------------------------
	//	时序解析模块
	//	-------------------------------------------------------------------------------------
	timing_decoder # (
	.SER_FIRST_BIT			(SER_FIRST_BIT			),
	.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH		),
	.CHANNEL_NUM			(CHANNEL_NUM			),
	.TD_OFFSET_WIDTH		(TD_OFFSET_WIDTH		)
	)
	timing_decoder_inst (
	.clk					(clk					),
	.reset					(reset					),
	.i_clk_en				(w_clk_en				),
	.i_sync					(w_sync					),
	.iv_data				(wv_data				),
	.iv_td_offset_x_start	(iv_td_offset_x_start	),	//起始x
	.iv_td_offset_width		(iv_td_offset_width		),	//宽度
	.iv_td_offset_y_start	(iv_td_offset_y_start	),	//起始y（暂未用）
	.iv_td_offset_height	(iv_td_offset_height	),	//高度（暂未用）
	.o_first_frame_detect	(o_first_frame_detect	),
	.o_clk_en				(o_clk_en				),
	.o_fval					(o_fval					),
	.o_lval					(o_lval					),
	.ov_pix_data			(ov_pix_data			)
	);


endmodule
