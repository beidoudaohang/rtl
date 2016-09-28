//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : grey_statistics
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/5 14:52:08	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 灰度值统计模块，
//              1)  : 模块的parameter支持的数据位宽为 8-16.
//
//              2)  : 当pixel format的数据位宽为8时，统计低8bit；其他情况下，统计全部位数。
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module grey_statistics # (
	parameter						SENSOR_DAT_WIDTH	= 10	,	//sensor 数据宽度
	parameter						GREY_OFFSET_WIDTH	= 12	,	//灰度统计模块偏移位置寄存器宽度
	parameter						GREY_STATIS_WIDTH	= 48	,	//灰度统计模块统计值宽度
	parameter						REG_WD				= 32		//寄存器位宽
	)
	(
	//Sensor输入信号
	input								clk						,	//像素时钟
	input								i_fval					,	//场信号
	input								i_lval					,	//行信号
	input	[SENSOR_DAT_WIDTH-1:0]		iv_pix_data				,	//图像数据
	//灰度统计相关寄存器
	input								i_interrupt_en			,	//2A中断使能，2A指的是自动曝光和自动增益，这两个功能在FPGA中由一个模块实现，因此如果要开启任意一项功能，就必须打开该中断如果不使能该中断，将关闭2A模块，以节省功耗
	input	[2:0]						iv_test_image_sel		,	//测试图选择寄存器,000:真实图,001:测试图像1灰度值帧递增,110:测试图像2静止的斜条纹,010:测试图像3滚动的斜条纹
	input	[REG_WD-1:0]				iv_pixel_format			,	//像素格式寄存器0x01080001:Mono8、0x01100003:Mono10、0x01080008:BayerGR8、0x0110000C:BayerGR10
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_x_start	,	//灰度值统计区域的x坐标起始点，固件设置的该寄存器值应该是相对于ROI的偏移
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_width	,	//灰度值统计区域的宽度
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_y_start	,	//灰度值统计区域的y坐标起始点，固件设置的该寄存器值应该是相对于ROI的偏移
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_height	,	//灰度值统计区域的高度
	output	[GREY_STATIS_WIDTH-1:0]		ov_grey_statis_sum		,	//该寄存器值为图像灰度统计值总和。如果像素格式为8bit，该值为像素8bit统计值。如果像素格式为10bit，该值为像素10bit统计值。
	output	[GREY_OFFSET_WIDTH-1:0]		ov_grey_offset_width	,	//锁存后的统计窗口，灰度值统计区域的宽度
	output	[GREY_OFFSET_WIDTH-1:0]		ov_grey_offset_height	,	//锁存后的统计窗口，灰度值统计区域的高度
	//其他模块交互
	output								o_interrupt_en			,	//输入中断=0，o_interrupt_en=0。一帧统计有效时，在i_fval下降沿，o_interrupt_en=1
	input								i_interrupt_pin			,	//中断模块输出的中断信号，1-中断有效。在中断上升沿时，锁存灰度统计值和窗口寄存器到端口
	output								o_fval						//输出场信号，保证在场下降沿之前，统计值已经确定
	);

	//	ref signals
	wire							w_lval		;
	wire	[SENSOR_DAT_WIDTH-1:0]	wv_pix_data	;

	//	ref ARCHITECTURE

	grey_aoi_sel # (
	.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH		),
	.GREY_OFFSET_WIDTH		(GREY_OFFSET_WIDTH		)
	)
	grey_aoi_sel_inst (
	.clk					(clk					),
	.i_fval					(i_fval					),
	.i_lval					(i_lval					),
	.iv_pix_data			(iv_pix_data			),
	.i_interrupt_en			(i_interrupt_en			),
	.iv_test_image_sel		(iv_test_image_sel		),
	.iv_grey_offset_x_start	(iv_grey_offset_x_start	),
	.iv_grey_offset_width	(iv_grey_offset_width	),
	.iv_grey_offset_y_start	(iv_grey_offset_y_start	),
	.iv_grey_offset_height	(iv_grey_offset_height	),
	.ov_grey_offset_width	(ov_grey_offset_width	),
	.ov_grey_offset_height	(ov_grey_offset_height	),
	.o_interrupt_en			(o_interrupt_en			),
	.i_interrupt_pin		(i_interrupt_pin		),
	.o_fval					(o_fval					),
	.o_lval					(w_lval					),
	.ov_pix_data			(wv_pix_data			)
	);

	grey_statis # (
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	),
	.GREY_STATIS_WIDTH	(GREY_STATIS_WIDTH	),
	.REG_WD				(REG_WD				)
	)
	grey_statis_inst (
	.clk				(clk				),
	.i_fval				(o_fval				),
	.i_lval				(w_lval				),
	.iv_pix_data		(wv_pix_data		),
	.i_interrupt_pin	(i_interrupt_pin	),
	.iv_pixel_format	(iv_pixel_format	),
	.ov_grey_statis_sum	(ov_grey_statis_sum	)
	);
	

endmodule