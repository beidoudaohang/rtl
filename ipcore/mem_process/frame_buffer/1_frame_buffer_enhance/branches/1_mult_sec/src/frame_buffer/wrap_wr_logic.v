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
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wrap_wr_logic # (
	parameter		DATA_WIDTH			= 32		,	//数据宽度
	parameter		PTR_WIDTH			= 2			,	//读写指针的位宽，1-最大2帧 2-最大4帧 3-最大8帧 4-最大16帧 5-最大32帧
	parameter		RD_WR_WITH_PRE		= "FALSE"	,	//read write command end with precharge command
	parameter		DDR3_MEM_DENSITY	= "1Gb"		,	//DDR3 容量 "1Gb" "512Mb"
	parameter		TERRIBLE_TRAFFIC	= "TRUE"		//读写最差的情况，TRUE-同时读写不同帧的同一地址，FALSE-同时读写同一帧的同一地址
	)
	(
	//	===============================================================================================
	//	视频输入时钟域
	//	===============================================================================================
	input											clk_front			,	//前端时钟
	input											i_fval				,	//场有效信号
	input											i_sval				,	//段落有效信号，section_valid
	input											i_dval				,	//数据有效信号
	input	[DATA_WIDTH-1:0]						iv_image_din		,	//图像数据
	output											o_front_fifo_full	,	//前端fifo满
	//	===============================================================================================
	//	帧存输入时钟域
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	时钟
	//	-------------------------------------------------------------------------------------
	input											clk					,	//帧存时钟
	input											reset				,	//帧存复位
	//	-------------------------------------------------------------------------------------
	//	每一段的起始地址
	//	-------------------------------------------------------------------------------------
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec0	,	//固定数，0段的起始地址
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec1	,	//固定数，1段的起始地址
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec2	,	//固定数，2段的起始地址
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec3	,	//固定数，3段的起始地址
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec4	,	//固定数，4段的起始地址
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec5	,	//固定数，5段的起始地址
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec6	,	//固定数，6段的起始地址
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec7	,	//固定数，7段的起始地址
	//	-------------------------------------------------------------------------------------
	//	每一段的大小
	//	-------------------------------------------------------------------------------------
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec0		,	//0段的大小
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec1		,	//1段的大小
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec2		,	//2段的大小
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec3		,	//3段的大小
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec4		,	//4段的大小
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec5		,	//5段的大小
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec6		,	//6段的大小
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec7		,	//7段的大小
	//  -------------------------------------------------------------------------------------
	//  控制数据
	//  -------------------------------------------------------------------------------------
	input	[PTR_WIDTH-1:0]							iv_frame_depth		,	//帧缓存深度 可设置为 0 - 31，设为0表示1帧，设为1时表示2帧
	input											i_start_full_frame	,	//使能开关，保证一帧完整操作
	input											i_start_quick		,	//使能开关，立即停
	//  -------------------------------------------------------------------------------------
	//	交互数据
	//  -------------------------------------------------------------------------------------
	output	[PTR_WIDTH-1:0]							ov_wr_frame_ptr		,	//写指针
	output	[18:0]									ov_wr_addr			,	//写地址
	output											o_wr_req			,	//写请求，高有效
	input											i_wr_ack			,	//写允许，高有效
	output											o_writing			,	//正在写，高有效
	input	[PTR_WIDTH-1:0]							iv_rd_frame_ptr		,	//读指针
	input											i_reading			,	//正在读，高有效
	//	===============================================================================================
	//	MCB端口
	//	===============================================================================================
	input											i_calib_done		,	//MCB校准完成信号，高有效
	output											o_p2_cmd_en			,	//MCB CMD FIFO 写信号，高有效
	output	[2:0]									ov_p2_cmd_instr		,	//MCB CMD FIFO 指令
	output	[5:0]									ov_p2_cmd_bl		,	//MCB CMD FIFO 突发长度
	output	[29:0]									ov_p2_cmd_byte_addr	,	//MCB CMD FIFO 起始地址
	input											i_p2_cmd_empty		,	//MCB CMD FIFO 空信号，高有效
	input											i_p2_cmd_full		,	//MCB CMD FIFO 满信号，高有效
	output											o_p2_wr_en			,	//MCB WR FIFO 写信号，高有效
	output	[3:0]									ov_p2_wr_mask		,	//MCB WR 屏蔽信号
	output	[DATA_WIDTH-1:0]						ov_p2_wr_data		,	//MCB WR FIFO 写数据
	input											i_p2_wr_full		,	//MCB WR FIFO 满信号，高有效
	input											i_p2_wr_empty		 	//MCB WR FIFO 空信号，高有效
	);

	//ref signals
	wire						w_reset_front_buf;
	wire						w_front_buf_pf_nc;
	wire						w_front_buf_rd;
	wire						w_front_buf_empty;
	wire						w_front_buf_pe;
	wire	[35:0]				wv_front_buf_dout;
	wire	[35:0]				wv_front_buf_din;

	//ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	前端fifo控制模块
	//	-------------------------------------------------------------------------------------
	fifo_ctrl fifo_ctrl_inst (
	.clk					(clk_front			),
	.i_fval					(i_fval				),
	.i_sval					(i_sval				),
	.iv_image_din			(iv_image_din		),
	.ov_front_buf_din		(wv_front_buf_din	),
	.o_reset_front_buf		(w_reset_front_buf	)
	);

	//	-------------------------------------------------------------------------------------
	//	前端fifo
	//	-------------------------------------------------------------------------------------
	fifo_w36d256_pf180_pe6 front_buf_inst (
	.rst					(w_reset_front_buf	),
	.wr_clk					(clk_front			),
	.wr_en					(i_dval				),
	.full					(o_front_fifo_full	),
	.prog_full				(w_front_buf_pf_nc	),
	.din					(wv_front_buf_din	),
	.rd_clk					(clk				),
	.rd_en					(w_front_buf_rd		),
	.empty					(w_front_buf_empty	),
	.prog_empty				(w_front_buf_pe		),
	.dout					(wv_front_buf_dout	)
	);

	//	-------------------------------------------------------------------------------------
	//	帧存写逻辑
	//	-------------------------------------------------------------------------------------
	wr_logic # (
	.DATA_WIDTH				(DATA_WIDTH			),
	.PTR_WIDTH				(PTR_WIDTH			),
	.RD_WR_WITH_PRE			(RD_WR_WITH_PRE		),
	.DDR3_MEM_DENSITY		(DDR3_MEM_DENSITY	),
	.TERRIBLE_TRAFFIC		(TERRIBLE_TRAFFIC	)
	)
	wr_logic_inst (
	.i_fval					(i_fval					),
	.clk					(clk					),
	.reset					(reset					),
	.iv_frame_depth			(iv_frame_depth			),
	.i_start_full_frame		(i_start_full_frame		),
	.i_start_quick			(i_start_quick			),
	.iv_buf_dout			(wv_front_buf_dout[DATA_WIDTH-1:0]	),
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





endmodule