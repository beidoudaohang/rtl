//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : wrap_rd_logic
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2013/6/14 13:40:52	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :	读逻辑顶层
//              1)  : 读逻辑模块和后级FIFO
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wrap_rd_logic # (
	parameter		DATA_WIDTH			= 32		,	//数据宽度
	parameter		PTR_WIDTH			= 2			,	//读写指针的位宽，1-最大2帧 2-最大4帧 3-最大8帧 4-最大16帧 5-最大32帧
	parameter		RD_WR_WITH_PRE		= "FALSE"	,	//read write command end with precharge command
	parameter		DDR3_MEM_DENSITY	= "1Gb"		,	//DDR3 容量 "1Gb" "512Mb"
	parameter		FRAME_SIZE_WIDTH	= 25		,	//一帧大小位宽，当DDR3是1Gbit时，最大容量是128Mbyte，当mcb p3 口位宽是32时，25位宽的size计数器就足够了
	parameter		TERRIBLE_TRAFFIC	= "TRUE"		//读写最差的情况，TRUE-同时读写不同帧的同一地址，FALSE-同时读写同一帧的同一地址
	)
	(
	//  -------------------------------------------------------------------------------------
	//  后端时钟域
	//  -------------------------------------------------------------------------------------
	input							clk_back				,	//后级时钟
	input							i_buf_rd				,	//后级模块读使能，高有效
	output							o_buf_empty				,	//后级FIFO空，高有效
	output							o_buf_pe				,	//后级FIFO编程空，高有效
	output	[DATA_WIDTH:0]			ov_image_dout			,	//后级FIFO数据输出，宽度33bit
	//  -------------------------------------------------------------------------------------
	//  控制数据
	//  -------------------------------------------------------------------------------------
	input	[PTR_WIDTH-1:0]			iv_frame_depth			,	//帧缓存深度，已同步
	input	[FRAME_SIZE_WIDTH-1:0]	iv_frame_size			,	//帧缓存大小，已同步
	input							i_chunk_mode_active		,	//chunk开关
	input							i_start_full_frame		,	//使能开关，保证一帧完整操作
	input							i_start_quick			,	//使能开关，立即停
	//  -------------------------------------------------------------------------------------
	//  帧缓存工作时钟域
	//  -------------------------------------------------------------------------------------
	input							clk						,	//帧存时钟
	input							reset					,	//帧存复位
	output	[PTR_WIDTH-1:0]			ov_rd_frame_ptr			,	//读指针
	output							o_rd_req				,	//读请求，高有效
	input							i_rd_ack				,	//读允许，高有效
	output							o_reading				,	//正在读，高有效
	input	[PTR_WIDTH-1:0]			iv_wr_frame_ptr			,	//写指针
	input	[18:0]					iv_wr_addr				,	//写地址
	input							i_writing				,	//正在写信号
	//  -------------------------------------------------------------------------------------
	//  MCB端口
	//  -------------------------------------------------------------------------------------
	input							i_calib_done			,	//MCB校准完成，高有效
	output							o_p3_cmd_en				,	//MCB CMD 写使能，高有效
	output	[2:0]					ov_p3_cmd_instr			,	//MCB CMD 指令
	output	[5:0]					ov_p3_cmd_bl			,	//MCB CMD 突发长度
	output	[29:0]					ov_p3_cmd_byte_addr		,	//MCB CMD 起始地址
	input							i_p3_cmd_empty			,	//MCB CMD 空，高有效
	input							i_p3_cmd_full			,	//MCB CMD 满，高有效
	output							o_p3_rd_en				,	//MCB RD FIFO 写使能，高有效
	input	[DATA_WIDTH-1:0]		iv_p3_rd_data			,	//MCB RD FIFO 数据输出
	input							i_p3_rd_full			,	//MCB RD FIFO 满，高有效
	input							i_p3_rd_empty			,	//MCB RD FIFO 空，高有效
	input							i_p3_rd_overflow		,	//MCB RD FIFO 溢出，高有效
	input							i_p3_rd_error			,	//MCB RD FIFO 出错，高有效
	input							i_p2_cmd_empty				//MCB CMD 空，高有效
	);

	//	ref signals
	wire							w_reset_back_buf	;
	wire	[DATA_WIDTH:0]			wv_back_buf_din		;
	wire							w_back_buf_pf		;
	wire							w_back_buf_full		;
	wire	[35:0]					wv_buf_dout			;
	wire							w_buf_empty			;
	wire							w_buf_dout32		;
	wire	[35:0]					wv_back_buf_din_comb;


	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	帧存读模块
	//	-------------------------------------------------------------------------------------
	rd_logic # (
	.DATA_WIDTH				(DATA_WIDTH			),
	.PTR_WIDTH				(PTR_WIDTH			),
	.RD_WR_WITH_PRE			(RD_WR_WITH_PRE		),
	.DDR3_MEM_DENSITY		(DDR3_MEM_DENSITY	),
	.FRAME_SIZE_WIDTH		(FRAME_SIZE_WIDTH	),
	.TERRIBLE_TRAFFIC		(TERRIBLE_TRAFFIC	)
	)
	rd_logic_inst (
	.clk					(clk				),
	.reset					(reset				),
	.iv_frame_depth			(iv_frame_depth		),
	.iv_frame_size			(iv_frame_size		),
	.i_chunk_mode_active	(i_chunk_mode_active),
	.i_start_full_frame		(i_start_full_frame	),
	.i_start_quick			(i_start_quick		),
	.o_reset_back_buf		(w_reset_back_buf	),
	.ov_buf_din				(wv_back_buf_din	),
	.o_buf_wr_en			(back_buf_wr		),
	.i_buf_pf				(w_back_buf_pf		),
	.i_buf_full				(w_back_buf_full	),
	.i_buf_empty			(w_buf_empty		),
	.i_buf_dout32			(w_buf_dout32		),
	.ov_rd_frame_ptr		(ov_rd_frame_ptr	),
	.o_rd_req				(o_rd_req			),
	.i_rd_ack				(i_rd_ack			),
	.o_reading				(o_reading			),
	.iv_wr_frame_ptr		(iv_wr_frame_ptr	),
	.iv_wr_addr				(iv_wr_addr			),
	.i_writing				(i_writing			),
	.i_calib_done			(i_calib_done		),
	.o_p3_cmd_en			(o_p3_cmd_en		),
	.ov_p3_cmd_instr		(ov_p3_cmd_instr	),
	.ov_p3_cmd_bl			(ov_p3_cmd_bl		),
	.ov_p3_cmd_byte_addr	(ov_p3_cmd_byte_addr),
	.i_p3_cmd_empty			(i_p3_cmd_empty		),
	.i_p3_cmd_full			(i_p3_cmd_full		),
	.o_p3_rd_en				(o_p3_rd_en			),
	.iv_p3_rd_data			(iv_p3_rd_data		),
	.i_p3_rd_full			(i_p3_rd_full		),
	.i_p3_rd_empty			(i_p3_rd_empty		),
	.i_p3_rd_overflow		(i_p3_rd_overflow	),
	.i_p3_rd_error			(i_p3_rd_error		),
	.i_p2_cmd_empty			(i_p2_cmd_empty		)
	);

	//	-------------------------------------------------------------------------------------
	//	后端FIFO
	//	-------------------------------------------------------------------------------------
	fifo_w36d256_pf180_pe6 back_buf_inst (
	.rst					(w_reset_back_buf		),
	.wr_clk					(clk					),
	.wr_en					(back_buf_wr			),
	.full					(w_back_buf_full		),
	.prog_full				(w_back_buf_pf			),
	.din					(wv_back_buf_din_comb	),
	.rd_clk					(clk_back				),
	.rd_en					(i_buf_rd				),
	.empty					(w_buf_empty			),
	.prog_empty				(o_buf_pe				),
	.dout					(wv_buf_dout			)
	);

	assign	ov_image_dout			= wv_buf_dout[DATA_WIDTH:0];
	assign	o_buf_empty				= w_buf_empty;
	assign	w_buf_dout32			= wv_buf_dout[DATA_WIDTH];
	assign	wv_back_buf_din_comb	= {3'b0,wv_back_buf_din};

endmodule