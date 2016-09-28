//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : wrap_wr_logic
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2013/5/30 9:31:41	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :	写逻辑顶层
//              1)  : 包括前端FIFO，FIFO复位控制模块，写逻辑模块
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//`include			"frame_buffer_def.v"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wrap_wr_logic # (
	parameter		RD_WR_WITH_PRE		= "FALSE"	,//read write command end with precharge command
	parameter		DDR3_MEM_DENSITY	= "1Gb"		//DDR3 容量 "1Gb" "512Mb"
	)
	(
	//  -------------------------------------------------------------------------------------
	//  视频输入时钟域
	//  -------------------------------------------------------------------------------------
	input						clk_vin,
	input						i_fval,					//场有效信号，高有效
	input						i_dval,					//数据有效信号，高有效
	input	[31:0]				iv_image_din,			//图像数据
	output						o_front_fifo_full,
	//  -------------------------------------------------------------------------------------
	//  控制数据
	//  -------------------------------------------------------------------------------------
	input						i_frame_en,				//使能开关
	input	[2:0]				iv_frame_depth,			//帧缓存深度 可设置为 1 2 4
	//  -------------------------------------------------------------------------------------
	//  帧缓存工作时钟域
	//  -------------------------------------------------------------------------------------
	input						clk,
	input						reset,
	output	[1:0]				ov_wr_frame_ptr,		//写指针
	output	[16:0]				ov_wr_addr,				//写地址
	output						o_wr_req,				//写请求，高有效
	input						i_wr_ack,				//写允许，高有效
	output						o_writing,				//正在写，高有效
	input	[1:0]				iv_rd_frame_ptr,		//读指针
	input						i_reading,				//正在读，高有效

	//  -------------------------------------------------------------------------------------
	//  MCB端口
	//  -------------------------------------------------------------------------------------
	input						i_calib_done,			//MCB校准完成信号，高有效
	output						o_p2_cmd_en,			//MCB CMD FIFO 写信号，高有效
	output	[2:0]				ov_p2_cmd_instr,        //MCB CMD FIFO 指令
	output	[5:0]				ov_p2_cmd_bl,           //MCB CMD FIFO 突发长度
	output	[29:0]				ov_p2_cmd_byte_addr,    //MCB CMD FIFO 起始地址
	input						i_p2_cmd_empty,         //MCB CMD FIFO 空信号，高有效
	input						i_p2_cmd_full,          //MCB CMD FIFO 满信号，高有效
	output						o_p2_wr_en,				//MCB WR FIFO 写信号，高有效
	output	[3:0]				ov_p2_wr_mask,          //MCB WR 屏蔽信号
	output	[31:0]				ov_p2_wr_data,          //MCB WR FIFO 写数据
	input						i_p2_wr_full,           //MCB WR FIFO 满信号，高有效
	input						i_p2_wr_empty           //MCB WR FIFO 空信号，高有效
	);

	//ref signals

	wire						w_front_buf_rst;
	wire						w_front_buf_full;
	wire						w_front_buf_pf_nc;
	wire						w_front_buf_rd;
	wire						w_front_buf_empty;
	wire						w_front_buf_pe;
	wire	[35:0]				wv_front_buf_dout;
	wire	[35:0]				wv_front_buf_din;



	//ref ARCHITECTURE


	fifo_con fifo_con_inst (
	.clk					(clk_vin			),
	.i_fval					(i_fval				),
	.o_rst_buf				(w_front_buf_rst	)
	);

	fifo_w36d256_pf180_pe6 front_buf_inst (
	.rst					(w_front_buf_rst	),
	.wr_clk					(clk_vin			),
	.wr_en					(i_dval				),
	.full					(w_front_buf_full	),
	.prog_full				(w_front_buf_pf_nc	),
	.din					(wv_front_buf_din	),
	.rd_clk					(clk				),
	.rd_en					(w_front_buf_rd		),
	.empty					(w_front_buf_empty	),
	.prog_empty				(w_front_buf_pe		),
	.dout					(wv_front_buf_dout	)
	);

	wr_logic # (
	.RD_WR_WITH_PRE			(RD_WR_WITH_PRE		),
	.DDR3_MEM_DENSITY		(DDR3_MEM_DENSITY	)
	)
	wr_logic_inst (
	.clk					(clk					),
	.reset					(reset					),
	.iv_frame_depth			(iv_frame_depth			),
	.i_frame_en				(i_frame_en				),
	.i_fval					(i_fval					),
	.iv_buf_dout			(wv_front_buf_dout[31:0]),
	.o_buf_rd_en			(w_front_buf_rd			),
	.i_buf_pe				(w_front_buf_pe			),
	.i_buf_empty			(w_front_buf_empty		),
	.ov_wr_frame_ptr		(ov_wr_frame_ptr		),
	.ov_wr_addr				(ov_wr_addr				),
	.o_wr_req				(o_wr_req				),
	.i_wr_ack				(i_wr_ack				),
	.o_writing				(o_writing				),
	.iv_rd_frame_ptr		(iv_rd_frame_ptr		),
	.i_reading				(i_reading				),
	.i_calib_done			(i_calib_done			),
	.o_p2_cmd_en			(o_p2_cmd_en			),
	.ov_p2_cmd_instr		(ov_p2_cmd_instr		),
	.ov_p2_cmd_bl			(ov_p2_cmd_bl			),
	.ov_p2_cmd_byte_addr	(ov_p2_cmd_byte_addr	),
	.i_p2_cmd_empty			(i_p2_cmd_empty			),
	.i_p2_cmd_full			(i_p2_cmd_full			),
	.o_p2_wr_en				(o_p2_wr_en				),
	.ov_p2_wr_mask			(ov_p2_wr_mask			),
	.ov_p2_wr_data			(ov_p2_wr_data			),
	.i_p2_wr_full			(i_p2_wr_full			),
	.i_p2_wr_empty			(i_p2_wr_empty			)
	);


	assign	wv_front_buf_din	= {4'b0,iv_image_din};
	assign	o_front_fifo_full	= w_front_buf_full;



endmodule
