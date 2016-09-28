//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : python_module
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/10/13 16:27:21	:|  初始版本
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

module python_module # (
	parameter	DATA_WIDTH 		= 10	,
	parameter	CHANNEL_NUM		= 4
	)
	(
	input									clk_para		,	//并行时钟
	input									clk_ser			,	//串行时钟
	input									i_init_done		,	//数据寄存器配置完成
	input									i_clk_en		,	//时钟使能信号
	input									i_fval			,
	input									i_lval			,
	input	[DATA_WIDTH*CHANNEL_NUM-1:0]	iv_pix_data		,
	output									o_clk_p			,
	output									o_clk_n			,
	output	[CHANNEL_NUM-1:0]				ov_data_p		,
	output	[CHANNEL_NUM-1:0]				ov_data_n		,
	output									o_ctrl_p		,
	output									o_ctrl_n
	);

	//	ref signals




	reg		[4:0]						bit_cnt		= 5'b0;
	reg		[3:0]						pix_cnt		= 4'b0;	//16个pix，完成一次循环。
	reg		[2*DATA_WIDTH-1:0]			ch0_shift	= 'b0;
	reg		[2*DATA_WIDTH-1:0]			ch1_shift	= 'b0;
	reg		[2*DATA_WIDTH-1:0]			ch2_shift	= 'b0;
	reg		[2*DATA_WIDTH-1:0]			ch3_shift	= 'b0;
	reg		[2*DATA_WIDTH-1:0]			ch0_shift_reg	= 'b0;
	reg		[2*DATA_WIDTH-1:0]			ch1_shift_reg	= 'b0;
	reg		[2*DATA_WIDTH-1:0]			ch2_shift_reg	= 'b0;
	reg		[2*DATA_WIDTH-1:0]			ch3_shift_reg	= 'b0;
	reg		[2*DATA_WIDTH-1:0]			ctrl_shift	= 'b0;
	reg		[2*DATA_WIDTH-1:0]			ctrl_shift_reg	= 'b0;


	wire											w_fval_map	;
	wire											w_lval_map	;
	wire	[DATA_WIDTH*CHANNEL_NUM-1:0]			wv_pix_data_map	;
	wire											w_fval_format	;
	wire											w_lval_format	;
	wire	[DATA_WIDTH*CHANNEL_NUM-1:0]			wv_pix_data_format	;
	wire	[DATA_WIDTH*CHANNEL_NUM-1:0]			wv_pix_data_ctrlin	;
	wire	[DATA_WIDTH-1:0]						wv_ctrl_data_ctrlin	;



	//	ref ARCHITECTURE

	//	===============================================================================================
	//
	//	===============================================================================================
	map_python # (
	.DATA_WIDTH		(DATA_WIDTH		),
	.CHANNEL_NUM	(CHANNEL_NUM	)
	)
	map_python_inst (
	.clk			(clk_para		),
	.i_fval			(i_fval			),
	.i_lval			(i_lval			),
	.iv_pix_data	(iv_pix_data	),
	.o_fval			(w_fval_map		),
	.o_lval			(w_lval_map		),
	.ov_pix_data	(wv_pix_data_map)
	);

	format_python # (
	.DATA_WIDTH		(DATA_WIDTH		),
	.CHANNEL_NUM	(CHANNEL_NUM	)
	)
	format_python_inst (
	.clk			(clk_para			),
	.i_fval			(w_fval_map			),
	.i_lval			(w_lval_map			),
	.iv_pix_data	(wv_pix_data_map	),
	.o_fval			(w_fval_format		),
	.o_lval			(w_lval_format		),
	.ov_pix_data	(wv_pix_data_format	)
	);

	ctrl_insert_python # (
	.DATA_WIDTH		(DATA_WIDTH				),
	.CHANNEL_NUM	(CHANNEL_NUM			)
	)
	ctrl_insert_python_inst (
	.clk			(clk_para				),
	.i_init_done	(i_init_done			),
	.i_fval			(w_fval_format			),
	.i_lval			(w_lval_format			),
	.iv_pix_data	(wv_pix_data_format		),
	.o_fval			(						),
	.o_lval			(						),
	.ov_pix_data	(wv_pix_data_ctrlin		),
	.ov_ctrl_data	(wv_ctrl_data_ctrlin	)
	);

	serializer_python # (
	.DATA_WIDTH		(DATA_WIDTH			),
	.CHANNEL_NUM	(CHANNEL_NUM		)
	)
	serializer_python_inst (
	.clk			(clk_ser				),
	.i_clk_en		(i_clk_en				),
	.iv_pix_data	(wv_pix_data_ctrlin		),
	.iv_ctrl_data	(wv_ctrl_data_ctrlin	),
	.o_clk_p		(o_clk_p				),
	.o_clk_n		(o_clk_n				),
	.ov_data_p		(ov_data_p				),
	.ov_data_n		(ov_data_n				),
	.o_ctrl_p		(o_ctrl_p				),
	.o_ctrl_n		(o_ctrl_n				)
	);


endmodule
