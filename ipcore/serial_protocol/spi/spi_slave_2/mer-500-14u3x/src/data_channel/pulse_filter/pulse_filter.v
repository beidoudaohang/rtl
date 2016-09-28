//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : pulse_filter
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/8 9:42:03	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : ram的宽度是18bit，深度是3072，因此支持的像素位宽最大是18bit，行长度是3072.如果位宽只有8bit，建议重新例化ram，改为8bit的存储器。
//
//              2)  : 对帧头的2行和帧尾的2行不做滤波处理，对行头的2个像素和行尾的2个像素不做滤波处理
//
//              3)  : 有4个行缓存，数据延迟时间在2行以上
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module pulse_filter # (
	parameter	SENSOR_DAT_WIDTH	= 10	,	//sensor 数据宽度
	parameter	SHORT_REG_WD		= 16		//短寄存器位宽
	)
	(
	//Sensor输入信号
	input								clk					,	//像素时钟
	input								i_fval				,	//场信号，i_fval上下边沿与i_lval相距10个时钟周期
	input								i_lval				,	//行信号
	input	[SENSOR_DAT_WIDTH-1:0]		iv_pix_data			,	//图像数据
	//寄存器数据
	input								i_pulse_filter_en	,	//坏点校正开关,0:不使能坏点校正,1:使能坏点校正
	input	[SHORT_REG_WD-1:0]			iv_roi_pic_width	,	//行宽度
	//输出
	output								o_fval				,	//场有效，o_fval与o_lval的上升沿有2行的时间，下降沿有10个时钟的间隔
	output								o_lval				,	//行有效
	output	[SENSOR_DAT_WIDTH-1:0]		ov_pix_data				//图像数据
	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	固定参数
	//	-------------------------------------------------------------------------------------
	localparam	COMPARE_LVAL_DELAY	= 5		;	//后级 compare 模块对lval的延时
	localparam	LINE_HIDE_PIX_NUM	= 30	;	//重新生成的2行，行消隐数值
	localparam	LINE2FRAME_PIX_NUM	= 10	;	//重新生成的2行，最后一行的下降沿与o_fval的下降沿的距离

	wire	[3:0]						wv_buffer_wr_en		;
	wire	[11:0]						wv_buffer_wr_addr	;
	wire	[9:0]						wv_buffer_wr_din	;
	wire	[SENSOR_DAT_WIDTH-1:0]		wv_lower_line		;
	wire								w_reset_buffer		;
	wire	[3:0]						wv_buffer_rd_en		;
	wire	[11:0]						wv_buffer_rd_addr	;
	wire	[9:0]						wv_buffer_rd_dout0	;
	wire	[9:0]						wv_buffer_rd_dout1	;
	wire	[9:0]						wv_buffer_rd_dout2	;
	wire	[9:0]						wv_buffer_rd_dout3	;
	wire	[SENSOR_DAT_WIDTH-1:0]		wv_upper_line	;
	wire	[SENSOR_DAT_WIDTH-1:0]		wv_mid_line		;
	wire								w_lval_delay	;
	wire								w_fval_delay	;


	//	ref ARCHITECTURE


	//  -------------------------------------------------------------------------------------
	//	buffer写模块
	//  -------------------------------------------------------------------------------------
	pulser_filter_wr # (
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	)
	)
	pulser_filter_wr_inst (
	.clk				(clk				),
	.i_fval				(i_fval				),
	.i_lval				(i_lval				),
	.iv_pix_data		(iv_pix_data		),
	.ov_buffer_wr_en	(wv_buffer_wr_en	),
	.ov_buffer_wr_addr	(wv_buffer_wr_addr	),
	.ov_buffer_wr_din	(wv_buffer_wr_din	),
	.ov_lower_line		(wv_lower_line		)
	);

	//  -------------------------------------------------------------------------------------
	//	buffer读模块
	//  -------------------------------------------------------------------------------------
	pulse_filter_rd # (
	.COMPARE_LVAL_DELAY	(COMPARE_LVAL_DELAY	),
	.LINE_HIDE_PIX_NUM	(LINE_HIDE_PIX_NUM	),
	.LINE2FRAME_PIX_NUM	(LINE2FRAME_PIX_NUM	),
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	),
	.SHORT_REG_WD		(SHORT_REG_WD		)
	)
	pulse_filter_rd_inst (
	.clk				(clk				),
	.iv_roi_pic_width	(iv_roi_pic_width	),
	.i_fval				(i_fval				),
	.i_lval				(i_lval				),
	.o_reset_buffer		(w_reset_buffer	),
	.ov_buffer_rd_en	(wv_buffer_rd_en	),
	.ov_buffer_rd_addr	(wv_buffer_rd_addr	),
	.iv_buffer_rd_dout0	(wv_buffer_rd_dout0	),
	.iv_buffer_rd_dout1	(wv_buffer_rd_dout1	),
	.iv_buffer_rd_dout2	(wv_buffer_rd_dout2	),
	.iv_buffer_rd_dout3	(wv_buffer_rd_dout3	),
	.o_fval				(w_fval_delay		),
	.o_lval				(w_lval_delay		),
	.ov_upper_line		(wv_upper_line		),
	.ov_mid_line		(wv_mid_line		)
	);

	//  -------------------------------------------------------------------------------------
	//	buffer模块，包含4个行缓存，每个行缓存的宽度是18bit，深度是3072
	//	没有必要复位，去掉了复位信号
	//  -------------------------------------------------------------------------------------
	pulse_filter_buffer pulse_filter_buffer_inst (
	.clk				(clk				),
	.iv_buffer_wr_en	(wv_buffer_wr_en	),
	.iv_buffer_wr_addr	(wv_buffer_wr_addr	),
	.iv_buffer_wr_din	(wv_buffer_wr_din	),
//	.i_reset_buffer		(w_reset_buffer		),
	.i_reset_buffer		(1'b0				),
	.iv_buffer_rd_en	(wv_buffer_rd_en	),
	.iv_buffer_rd_addr	(wv_buffer_rd_addr	),
	.ov_buffer_rd_dout0	(wv_buffer_rd_dout0	),
	.ov_buffer_rd_dout1	(wv_buffer_rd_dout1	),
	.ov_buffer_rd_dout2	(wv_buffer_rd_dout2	),
	.ov_buffer_rd_dout3	(wv_buffer_rd_dout3	)
	);

	//  -------------------------------------------------------------------------------------
	//	比较模块，完成滤波功能
	//  -------------------------------------------------------------------------------------
	pulse_filter_compare # (
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	)
	)
	pulse_filter_compare_inst (
	.clk				(clk				),
	.i_pulse_filter_en	(i_pulse_filter_en	),
	.i_fval				(i_fval				),
	.i_fval_delay		(w_fval_delay		),
	.i_lval_delay		(w_lval_delay		),
	.iv_upper_line		(wv_upper_line		),
	.iv_mid_line		(wv_mid_line		),
	.iv_lower_line		(wv_lower_line		),
	.o_fval				(o_fval				),
	.o_lval				(o_lval				),
	.ov_pix_data		(ov_pix_data		)
	);



endmodule