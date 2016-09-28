//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : ccd_sharp_module
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/8/10 10:18:16	:|  初始版本
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

module ccd_sharp_module # (
	parameter	DATA_WIDTH			= 14				,	//像素数据位宽
	parameter	IMAGE_WIDTH			= 1320				,	//图像宽度
	parameter	IMAGE_HEIGHT		= 976				,	//图像高度
	parameter	BLACK_VFRONT		= 8					,	//场头黑行个数
	parameter	BLACK_VREAR			= 2					,	//场尾黑行个数
	parameter	BLACK_HFRONT		= 12				,	//行头黑像素个数
	parameter	BLACK_HREAR			= 40				,	//行尾黑像素个数
	parameter	DUMMY_VFRONT		= 2					,	//场头哑行个数
	parameter	DUMMY_VREAR			= 0					,	//场尾哑行个数
	parameter	DUMMY_HFRONT		= 4					,	//行头哑像素个数
	parameter	DUMMY_HREAR			= 0					,	//行尾哑像素个数
	parameter	DUMMY_INIT_VALUE	= 16				,	//DUMMY初始值
	parameter	BLACK_INIT_VALUE	= 32				,	//BLACK初始值
	parameter	IMAGE_SOURCE		= "RANDOM"			,	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC" or "PIX_INC"
	parameter	SOURCE_FILE_PATH	= "source_file/"		//数据源文件路径
	)
	(
	input							xv1			,	//垂直驱动
	input							xv2			,	//垂直驱动
	input							xv3			,	//垂直驱动
	input							xv4			,	//垂直驱动
	input							xsg			,	//曝光结束信号

	input							hl			,	//水平驱动
	input							h1			,	//水平驱动
	input							h2			,	//水平驱动
	input							rs			,	//水平驱动

	output	[DATA_WIDTH-1:0]		ov_pix_data		//输出像素数据
	);

	//	ref signals
	wire	w_line_change	;
	wire	w_frame_change	;

	//	ref ARCHITECTURE
	//	-------------------------------------------------------------------------------------
	//	垂直翻转模块
	//	-------------------------------------------------------------------------------------
	ccd_sharp_vshift ccd_sharp_vshift_inst (
	.xv1			(xv1			),
	.xv2			(xv2			),
	.xv3			(xv3			),
	.xv4			(xv4			),
	.xsg			(xsg			),
	.o_line_change	(w_line_change	),
	.o_frame_change	(w_frame_change	)
	);

	//	-------------------------------------------------------------------------------------
	//	水平翻转模块
	//	-------------------------------------------------------------------------------------
	ccd_sharp_hshift # (
	.DATA_WIDTH			(DATA_WIDTH			),
	.IMAGE_WIDTH		(IMAGE_WIDTH		),
	.BLACK_VFRONT		(BLACK_VFRONT		),
	.BLACK_VREAR		(BLACK_VREAR		),
	.BLACK_HFRONT		(BLACK_HFRONT		),
	.BLACK_HREAR		(BLACK_HREAR		),
	.DUMMY_VFRONT		(DUMMY_VFRONT		),
	.DUMMY_VREAR		(DUMMY_VREAR		),
	.DUMMY_HFRONT		(DUMMY_HFRONT		),
	.DUMMY_HREAR		(DUMMY_HREAR		),
	.DUMMY_INIT_VALUE	(DUMMY_INIT_VALUE	),
	.BLACK_INIT_VALUE	(BLACK_INIT_VALUE	),
	.IMAGE_SOURCE		(IMAGE_SOURCE		),
	.SOURCE_FILE_PATH	(SOURCE_FILE_PATH	)
	)
	ccd_sharp_hshift_inst (
	.i_line_change		(w_line_change		),
	.i_frame_change		(w_frame_change		),
	.hl					(hl					),
	.h1					(h1					),
	.h2					(h2					),
	.rs					(rs					),
	.ov_pix_data		(ov_pix_data		)
	);

endmodule
