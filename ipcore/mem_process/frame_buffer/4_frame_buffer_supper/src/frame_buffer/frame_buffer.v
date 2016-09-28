//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : frame_buffer
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2013/6/14 14:00:40	:|  初始版本
//  -- 邢海涛       :| 2015/9/28 13:13:59	:|  1.不带前后端 buf
//												2.2个写端口 p2 p4.2个读端口 p3 p5
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :	帧缓存模块顶层
//              1)  : 包含以下模块
//					1.DDR3控制器
//					2.写逻辑顶层
//					3.读逻辑顶层
//					4.仲裁模块
//
//              2)  : 对复位信号做了同步化的处理
//
//              3)  : 对使能信号采样，并且复位时，使能信号无效
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module frame_buffer # (
	parameter		NUM_DQ_PINS			= 16					,	//External memory data width
	parameter		MEM_BANKADDR_WIDTH	= 3						,	//External memory bank address width
	parameter		MEM_ADDR_WIDTH		= 13					,	//External memory address width.
	parameter		DDR3_MEMCLK_FREQ	= 320					,	//Memory data transfer clock frequency DDR3-640:3125 DDR3-660:3030 DDR3-720:2778 DDR3-800:2500
	parameter		MEM_ADDR_ORDER		= "ROW_BANK_COLUMN"		,	//"ROW_BANK_COLUMN" or "BANK_ROW_COLUMN"
	parameter		SKIP_IN_TERM_CAL	= 1						,	//1-calib input term 0-not calib input term.1 will decrease power consumption
	parameter		DDR3_MEM_DENSITY	= "1Gb"					,	//DDR3 容量 "1Gb" "512Mb"
	parameter		DDR3_TCK_SPEED		= "187E"				,	//DDR3 speed "187E" "15E" "125"
	parameter		DDR3_SIMULATION		= "FALSE"				,	//仿真模式，加速MCB仿真速度
	parameter		DDR3_CALIB_SOFT_IP	= "TRUE"				,	//使能calibration模块
	parameter		DATA_WIDTH			= 32					,	//数据宽度
	parameter		PTR_WIDTH			= 2						,	//读写指针的位宽，1-最大2帧 2-最大4帧 3-最大8帧 4-最大16帧 5-最大32帧
	parameter		FRAME_SIZE_WIDTH	= 25					,	//一帧大小位宽，当DDR3是1Gbit时，最大容量是128Mbyte，当mcb p3 口位宽是32时，25位宽的size计数器就足够了
	parameter		TERRIBLE_TRAFFIC	= "TRUE"				,	//读写最差的情况，TRUE-同时读写不同帧的同一地址，FALSE-同时读写同一帧的同一地址
	parameter		SECTION_NUM			= 4							//每一帧中有多少个段，每段都有一个起始地址，和一个使能位
	)
	(
	//	-------------------------------------------------------------------------------------
	//	固定的配置数据
	//	-------------------------------------------------------------------------------------
	input	[18:0]								iv_start_addr_sec0	,	//固定数，0段的起始地址
	input	[18:0]								iv_start_addr_sec1	,	//固定数，1段的起始地址
	input	[18:0]								iv_start_addr_sec2	,	//固定数，2段的起始地址
	input	[18:0]								iv_start_addr_sec3	,	//固定数，3段的起始地址
	input	[18:0]								iv_start_addr_sec4	,	//固定数，4段的起始地址
	input	[18:0]								iv_start_addr_sec5	,	//固定数，5段的起始地址
	input	[18:0]								iv_start_addr_sec6	,	//固定数，6段的起始地址
	input	[18:0]								iv_start_addr_sec7	,	//固定数，7段的起始地址
	//  -------------------------------------------------------------------------------------
	//  视频输入时钟域
	//  -------------------------------------------------------------------------------------
	input										clk_front			,	//前级时钟
	input										reset_front			,	//前级时钟，复位信号
	input										i_fval				,	//场有效信号，高有效
	input										i_sval				,	//段落有效信号，高有效，section_valid
	input										i_dval				,	//数据有效信号，高有效
	input	[DATA_WIDTH-1:0]					iv_image_din		,	//图像数据
	input	[PTR_WIDTH-1:0]						iv_frame_depth_front		,	//前端时钟域，帧缓存深度
	input										i_start_full_frame_front	,	//前端时钟域，使能开关，保证一帧完整操作
	input										i_start_quick_front			,	//前端时钟域，使能开关，立即停
	input	[SECTION_NUM-1:0]					iv_section_en_front			,	//一帧中每个段的使能位
	//  -------------------------------------------------------------------------------------
	//  视频输出时钟域
	//  -------------------------------------------------------------------------------------
	input										clk_back				,	//后级时钟
	input										reset_back				,	//后级时钟，复位信号
	input										i_buf_rd				,	//后级模块读使能，高有效
	output										o_buf_empty				,	//后级FIFO空，高有效
	output										o_buf_pe				,	//后级FIFO编程空，高有效
	output	[DATA_WIDTH:0]						ov_image_dout			,	//后级FIFO数据输出，宽度34bit
	input	[PTR_WIDTH-1:0]						iv_frame_depth_back		,	//后端时钟域，帧缓存深度
	input										i_start_full_frame_back	,	//后端时钟域，使能开关，保证一帧完整操作
	input										i_start_quick_back		,	//后端时钟域，使能开关，立即停
	input	[18:0]								iv_size_sec0_back		,	//后端时钟域，0段的大小
	input	[18:0]								iv_size_sec1_back		,	//后端时钟域，1段的大小
	input	[18:0]								iv_size_sec2_back		,	//后端时钟域，2段的大小
	input	[18:0]								iv_size_sec3_back		,	//后端时钟域，3段的大小
	input	[18:0]								iv_size_sec4_back		,	//后端时钟域，4段的大小
	input	[18:0]								iv_size_sec5_back		,	//后端时钟域，5段的大小
	input	[18:0]								iv_size_sec6_back		,	//后端时钟域，6段的大小
	input	[18:0]								iv_size_sec7_back		,	//后端时钟域，7段的大小
	//  -------------------------------------------------------------------------------------
	//  PLL PORT
	//  -------------------------------------------------------------------------------------
	input										async_rst			,	//MCB 复位信号，高有效
	input										sysclk_2x			,	//MCB 工作时钟
	input										sysclk_2x_180		,	//MCB 工作时钟
	input										pll_ce_0			,	//MCB 移位使能信号
	input										pll_ce_90			,	//MCB 移位使能信号
	input										mcb_drp_clk			,	//MCB DRP 时钟，
	input										bufpll_mcb_lock		,	//BUFPLL_MCB 锁定信号
	//  -------------------------------------------------------------------------------------
	//  MCB Status
	//  -------------------------------------------------------------------------------------
	output										o_calib_done		,	//DDR3校准完成信号，高有效
	output										o_wr_error			,	//MCB写端口出现错误，高有效
	output										o_rd_error			,	//MCB读端口出现错误，高有效
	//  -------------------------------------------------------------------------------------
	//  External Memory
	//  -------------------------------------------------------------------------------------
	inout  	[NUM_DQ_PINS-1:0]       			mcb1_dram_dq		,	//数据信号
	output 	[MEM_ADDR_WIDTH-1:0]    			mcb1_dram_a			,   //地址信号
	output 	[MEM_BANKADDR_WIDTH-1:0]			mcb1_dram_ba		,   //Bank地址信号
	output										mcb1_dram_ras_n		,   //行地址选通
	output										mcb1_dram_cas_n		,   //列地址选通
	output										mcb1_dram_we_n		,   //写信号
	output										mcb1_dram_odt		,   //阻抗匹配信号
	output										mcb1_dram_reset_n	,   //复位信号
	output										mcb1_dram_cke		,   //时钟使能信号
	output										mcb1_dram_udm		,   //高字节数据屏蔽信号
	output										mcb1_dram_dm		,   //低字节数据屏蔽信号
	inout										mcb1_dram_udqs		,   //高字节地址选通信号正
	inout										mcb1_dram_udqs_n	,   //高字节地址选通信号负
	inout 										mcb1_dram_dqs		,   //低字节数据选通信号正
	inout 										mcb1_dram_dqs_n		,   //低字节数据选通信号负
	inout 										mcb1_rzq			,   //驱动校准
	inout 										mcb1_zio			,   //高字节数据屏蔽信号
	output										mcb1_dram_ck		,   //时钟正
	output										mcb1_dram_ck_n		,	//时钟负
	//  -------------------------------------------------------------------------------------
	//  frame buf module version
	//  -------------------------------------------------------------------------------------
	output	[15:0]								ov_frame_buf_version	//帧缓存模块版本号
	);

	//  ===============================================================================================
	//	ref ***函数***
	//  ===============================================================================================
	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction

	localparam	SECTION_NUM_WIDTH	= log2(SECTION_NUM);

	//	ref signals

	//  -------------------------------------------------------------------------------------
	//	常数定义
	//  -------------------------------------------------------------------------------------
	//ddr3的时序参数
	localparam	DDR3_MEM_TRAS	= (DDR3_TCK_SPEED=="187E") ? 37500 : ((DDR3_TCK_SPEED=="15E") ? 36000 : ((DDR3_TCK_SPEED=="125") ? 35000 : 35000));
	localparam	DDR3_MEM_TRCD	= (DDR3_TCK_SPEED=="187E") ? 13130 : ((DDR3_TCK_SPEED=="15E") ? 13500 : ((DDR3_TCK_SPEED=="125") ? 13750 : 13750));
	localparam	DDR3_MEM_TREFI	= (DDR3_TCK_SPEED=="187E") ? 7800000 : ((DDR3_TCK_SPEED=="15E") ? 7800000 : ((DDR3_TCK_SPEED=="125") ? 7800000 : 7800000));
	localparam	DDR3_MEM_TRFC	= (DDR3_TCK_SPEED=="187E") ? 160000 : ((DDR3_TCK_SPEED=="15E") ? 160000 : ((DDR3_TCK_SPEED=="125") ? 160000 : 160000));
	localparam	DDR3_MEM_TRP	= (DDR3_TCK_SPEED=="187E") ? 13130 : ((DDR3_TCK_SPEED=="15E") ? 13500 : ((DDR3_TCK_SPEED=="125") ? 13750 : 13750));
	localparam	DDR3_MEM_TWR	= (DDR3_TCK_SPEED=="187E") ? 15000 : ((DDR3_TCK_SPEED=="15E") ? 15000 : ((DDR3_TCK_SPEED=="125") ? 15000 : 15000));
	localparam	DDR3_MEM_TRTP	= (DDR3_TCK_SPEED=="187E") ? 7500 : ((DDR3_TCK_SPEED=="15E") ? 7500 : ((DDR3_TCK_SPEED=="125") ? 7500 : 7500));
	localparam	DDR3_MEM_TWTR	= (DDR3_TCK_SPEED=="187E") ? 7500 : ((DDR3_TCK_SPEED=="15E") ? 7500 : ((DDR3_TCK_SPEED=="125") ? 7500 : 7500));

	//ddr3地址线宽度
	localparam	RD_WR_WITH_PRE	= "FALSE"	;	//读写命令后面不加上预充电命令 "TRUE" or "FALSE"


	//Memory data transfer clock period DDR3-640:3125 DDR3-660:3030 DDR3-720:2778 DDR3-800:2500
	localparam	DDR3_MEMCLK_PERIOD	= 1000000/DDR3_MEMCLK_FREQ;

	//  -------------------------------------------------------------------------------------
	//	变量定义
	//  -------------------------------------------------------------------------------------
	wire	[PTR_WIDTH-1:0]		wv_wr_frame_ptr		;
	wire	[PTR_WIDTH-1:0]		wv_rd_frame_ptr		;
	wire	[18:0]				wv_wr_addr			;
	wire						w_wr_req			;
	wire						w_wr_ack			;
	wire						w_writing			;
	wire						w_rd_req			;
	wire						w_rd_ack			;
	wire						w_reading			;

	wire						c1_calib_done		;
	wire						w_p2_cmd_en			;
	wire	[2:0]				wv_p2_cmd_instr		;
	wire	[5:0]				wv_p2_cmd_bl		;
	wire	[29:0]				wv_p2_cmd_byte_addr	;
	wire						w_p2_cmd_empty		;
	wire						w_p2_cmd_full		;
	wire						w_p2_wr_en			;
	wire	[3:0]				wv_p2_wr_mask		;
	wire	[DATA_WIDTH-1:0]	wv_p2_wr_data		;
	wire						w_p2_wr_full		;
	wire						w_p2_wr_empty		;
	wire	[6:0]				wv_p2_wr_count		;
	wire						w_p2_wr_underrun_nc	;
	wire						w_p2_wr_error		;
	wire						w_p3_cmd_en			;
	wire	[2:0]				wv_p3_cmd_instr		;
	wire	[5:0]				wv_p3_cmd_bl		;
	wire	[29:0]				wv_p3_cmd_byte_addr	;
	wire						w_p3_cmd_empty		;
	wire						w_p3_cmd_full		;
	wire						w_p3_rd_en			;
	wire	[DATA_WIDTH-1:0]	wv_p3_rd_data		;
	wire						w_p3_rd_full		;
	wire						w_p3_rd_empty		;
	wire	[6:0]				wv_p3_rd_count		;
	wire						w_p3_rd_overflow	;
	wire						w_p3_rd_error		;

	wire						w_p4_cmd_en			;
	wire	[2:0]				wv_p4_cmd_instr		;
	wire	[5:0]				wv_p4_cmd_bl		;
	wire	[29:0]				wv_p4_cmd_byte_addr	;
	wire						w_p4_cmd_empty		;
	wire						w_p4_cmd_full		;
	wire						w_p4_wr_en			;
	wire	[3:0]				wv_p4_wr_mask		;
	wire	[DATA_WIDTH-1:0]	wv_p4_wr_data		;
	wire						w_p4_wr_full		;
	wire						w_p4_wr_empty		;
	wire	[6:0]				wv_p4_wr_count		;
	wire						w_p4_wr_underrun_nc	;
	wire						w_p4_wr_error		;
	wire						w_p5_cmd_en			;
	wire	[2:0]				wv_p5_cmd_instr		;
	wire	[5:0]				wv_p5_cmd_bl		;
	wire	[29:0]				wv_p5_cmd_byte_addr	;
	wire						w_p5_cmd_empty		;
	wire						w_p5_cmd_full		;
	wire						w_p5_rd_en			;
	wire	[DATA_WIDTH-1:0]	wv_p5_rd_data		;
	wire						w_p5_rd_full		;
	wire						w_p5_rd_empty		;
	wire	[6:0]				wv_p5_rd_count		;
	wire						w_p5_rd_overflow	;
	wire						w_p5_rd_error		;

	//	ref ARCHITECTURE


	//  -------------------------------------------------------------------------------------
	//  ref version
	//  -------------------------------------------------------------------------------------
	assign	ov_frame_buf_version = 16'h0202;

	//  -------------------------------------------------------------------------------------
	//  输出信号
	//  -------------------------------------------------------------------------------------
	assign	o_calib_done	= c1_calib_done;
	assign	o_wr_error		= w_p2_wr_error;
	assign	o_rd_error		= w_p3_rd_error;

	//  -------------------------------------------------------------------------------------
	//  写逻辑顶层模块
	//  -------------------------------------------------------------------------------------
	wr_logic # (
	.DATA_WIDTH				(DATA_WIDTH				),
	.PTR_WIDTH				(PTR_WIDTH				),
	.RD_WR_WITH_PRE			(RD_WR_WITH_PRE			),
	.DDR3_MEM_DENSITY		(DDR3_MEM_DENSITY		),
	.TERRIBLE_TRAFFIC		(TERRIBLE_TRAFFIC		),
	)
	wr_logic_inst (
	.clk					(clk_front				),
	.reset					(reset_front			),
	.i_fval					(i_fval					),
	.i_sval					(i_sval					),
	.i_dval					(i_dval					),
	.iv_image_din			(iv_image_din			),
	.iv_frame_depth			(iv_frame_depth_front	),
	.i_start_full_frame		(i_start_full_frame_front	),
	.i_start_quick			(i_start_quick_front	),

	.iv_start_addr_sec0		(iv_start_addr_sec0		),
	.iv_start_addr_sec1		(iv_start_addr_sec1		),
	.iv_start_addr_sec2		(iv_start_addr_sec2		),
	.iv_start_addr_sec3		(iv_start_addr_sec3		),
	.iv_start_addr_sec4		(iv_start_addr_sec4		),
	.iv_start_addr_sec5		(iv_start_addr_sec5		),
	.iv_start_addr_sec6		(iv_start_addr_sec6		),
	.iv_start_addr_sec7		(iv_start_addr_sec7		),

	.ov_wr_frame_ptr		(wv_wr_frame_ptr		),
	.ov_wr_addr				(wv_wr_addr				),
	.o_wr_req				(w_wr_req				),
	.i_wr_ack				(w_wr_ack				),
	.o_writing				(w_writing				),
	.iv_rd_frame_ptr		(wv_rd_frame_ptr		),
	.i_reading				(w_reading				),
	.i_calib_done			(c1_calib_done			),

	.o_p2_cmd_en			(w_p2_cmd_en			),
	.ov_p2_cmd_instr		(wv_p2_cmd_instr		),
	.ov_p2_cmd_bl			(wv_p2_cmd_bl			),
	.ov_p2_cmd_byte_addr	(wv_p2_cmd_byte_addr	),
	.i_p2_cmd_empty			(w_p2_cmd_empty			),
	.i_p2_cmd_full			(w_p2_cmd_full			),
	.o_p2_wr_en				(w_p2_wr_en				),
	.ov_p2_wr_mask			(wv_p2_wr_mask			),
	.ov_p2_wr_data			(wv_p2_wr_data			),
	.i_p2_wr_full			(w_p2_wr_full			),
	.i_p2_wr_empty			(w_p2_wr_empty			),

	.o_p4_cmd_en			(w_p4_cmd_en			),
	.ov_p4_cmd_instr		(wv_p4_cmd_instr		),
	.ov_p4_cmd_bl			(wv_p4_cmd_bl			),
	.ov_p4_cmd_byte_addr	(wv_p4_cmd_byte_addr	),
	.i_p4_cmd_empty			(w_p4_cmd_empty			),
	.i_p4_cmd_full			(w_p4_cmd_full			),
	.o_p4_wr_en				(w_p4_wr_en				),
	.ov_p4_wr_mask			(wv_p4_wr_mask			),
	.ov_p4_wr_data			(wv_p4_wr_data			),
	.i_p4_wr_full			(w_p4_wr_full			),
	.i_p4_wr_empty			(w_p4_wr_empty			)

	);

	//  -------------------------------------------------------------------------------------
	//  读逻辑顶层模块
	//  -------------------------------------------------------------------------------------
	rd_logic # (
	.DATA_WIDTH				(DATA_WIDTH				),
	.PTR_WIDTH				(PTR_WIDTH				),
	.RD_WR_WITH_PRE			(RD_WR_WITH_PRE			),
	.DDR3_MEM_DENSITY		(DDR3_MEM_DENSITY		),
	.FRAME_SIZE_WIDTH		(FRAME_SIZE_WIDTH		),
	.TERRIBLE_TRAFFIC		(TERRIBLE_TRAFFIC		),
	.SECTION_NUM			(SECTION_NUM			)
	)
	rd_logic_inst (
	.clk					(clk_back				),
	.reset					(reset_back				),
	.i_buf_rd				(i_buf_rd				),
	.o_buf_empty			(o_buf_empty			),
	.o_buf_pe				(o_buf_pe				),
	.ov_image_dout			(ov_image_dout			),
	.iv_frame_depth			(iv_frame_depth_back	),
	.i_start_full_frame		(i_start_full_frame_back),
	.i_start_quick			(i_start_quick_back		),
	.iv_size_sec0			(iv_size_sec0_back		),
	.iv_size_sec1			(iv_size_sec1_back		),
	.iv_size_sec2			(iv_size_sec2_back		),
	.iv_size_sec3			(iv_size_sec3_back		),
	.iv_size_sec4			(iv_size_sec4_back		),
	.iv_size_sec5			(iv_size_sec5_back		),
	.iv_size_sec6			(iv_size_sec6_back		),
	.iv_size_sec7			(iv_size_sec7_back		),
	.ov_rd_frame_ptr		(wv_rd_frame_ptr		),
	.o_rd_req				(w_rd_req				),
	.i_rd_ack				(w_rd_ack				),
	.o_reading				(w_reading				),
	.iv_wr_frame_ptr		(wv_wr_frame_ptr		),
	.iv_wr_addr				(wv_wr_addr				),
	.i_writing				(w_writing				),
	.i_calib_done			(c1_calib_done			),

	.o_p3_cmd_en			(w_p3_cmd_en			),
	.ov_p3_cmd_instr		(wv_p3_cmd_instr		),
	.ov_p3_cmd_bl			(wv_p3_cmd_bl			),
	.ov_p3_cmd_byte_addr	(wv_p3_cmd_byte_addr	),
	.i_p3_cmd_empty			(w_p3_cmd_empty			),
	.i_p3_cmd_full			(w_p3_cmd_full			),
	.o_p3_rd_en				(w_p3_rd_en				),
	.iv_p3_rd_data			(wv_p3_rd_data			),
	.i_p3_rd_full			(w_p3_rd_full			),
	.i_p3_rd_empty			(w_p3_rd_empty			),
	.i_p3_rd_overflow		(w_p3_rd_overflow		),
	.i_p3_rd_error			(w_p3_rd_error			),

	.o_p5_cmd_en			(w_p5_cmd_en			),
	.ov_p5_cmd_instr		(wv_p5_cmd_instr		),
	.ov_p5_cmd_bl			(wv_p5_cmd_bl			),
	.ov_p5_cmd_byte_addr	(wv_p5_cmd_byte_addr	),
	.i_p5_cmd_empty			(w_p5_cmd_empty			),
	.i_p5_cmd_full			(w_p5_cmd_full			),
	.o_p5_rd_en				(w_p5_rd_en				),
	.iv_p5_rd_data			(wv_p5_rd_data			),
	.i_p5_rd_full			(w_p5_rd_full			),
	.i_p5_rd_empty			(w_p5_rd_empty			),
	.i_p5_rd_overflow		(w_p5_rd_overflow		),
	.i_p5_rd_error			(w_p5_rd_error			)
	);

	//  -------------------------------------------------------------------------------------
	//  读写仲裁模块
	//  -------------------------------------------------------------------------------------
	judge judge_inst (
	.clk					(clk_front		),
	.i_wr_req				(w_wr_req		),
	.i_rd_req				(w_rd_req		),
	.o_wr_ack				(w_wr_ack		),
	.o_rd_ack				(w_rd_ack		)
	);

	//  -------------------------------------------------------------------------------------
	//  MCB (Memory Controller Block) DDR3控制器模块
	//  -------------------------------------------------------------------------------------
//	mig_core # (
//	.C3_P0_MASK_SIZE		(4						),
//	.C3_P0_DATA_PORT_SIZE	(32						),
//	.C3_P1_MASK_SIZE		(4						),
//	.C3_P1_DATA_PORT_SIZE	(32						),
//	.DEBUG_EN				(0						),
//	.C3_MEMCLK_PERIOD		(DDR3_MEMCLK_PERIOD		),
//	.C3_CALIB_SOFT_IP		(DDR3_CALIB_SOFT_IP		),
//	.C3_SIMULATION			(DDR3_SIMULATION		),
//	.C3_MEM_ADDR_ORDER		(MEM_ADDR_ORDER			),
//	.C3_NUM_DQ_PINS			(NUM_DQ_PINS			),
//	.C3_MEM_ADDR_WIDTH		(MEM_ADDR_WIDTH			),
//	.C3_MEM_BANKADDR_WIDTH	(MEM_BANKADDR_WIDTH		),
//	.SKIP_IN_TERM_CAL		(SKIP_IN_TERM_CAL		),
//	.DDR3_MEM_DENSITY		(DDR3_MEM_DENSITY		),
//	.DDR3_MEM_TRAS			(DDR3_MEM_TRAS			),
//	.DDR3_MEM_TRCD			(DDR3_MEM_TRCD			),
//	.DDR3_MEM_TREFI			(DDR3_MEM_TREFI			),
//	.DDR3_MEM_TRFC			(DDR3_MEM_TRFC			),
//	.DDR3_MEM_TRP			(DDR3_MEM_TRP			),
//	.DDR3_MEM_TWR			(DDR3_MEM_TWR			),
//	.DDR3_MEM_TRTP			(DDR3_MEM_TRTP			),
//	.DDR3_MEM_TWTR			(DDR3_MEM_TWTR			)
//	)
//	mig_core_inst (
//	.mcb3_dram_dq			(mcb3_dram_dq		),
//	.mcb3_dram_a			(mcb3_dram_a		),
//	.mcb3_dram_ba			(mcb3_dram_ba		),
//	.mcb3_dram_ras_n		(mcb3_dram_ras_n	),
//	.mcb3_dram_cas_n		(mcb3_dram_cas_n	),
//	.mcb3_dram_we_n			(mcb3_dram_we_n		),
//	.mcb3_dram_odt			(mcb3_dram_odt		),
//	.mcb3_dram_reset_n		(mcb3_dram_reset_n	),
//	.mcb3_dram_cke			(mcb3_dram_cke		),
//	.mcb3_dram_dm			(mcb3_dram_dm		),
//	.mcb3_dram_udqs			(mcb3_dram_udqs		),
//	.mcb3_dram_udqs_n		(mcb3_dram_udqs_n	),
//	.mcb3_rzq				(mcb3_rzq			),
//	.mcb3_zio				(mcb3_zio			),
//	.mcb3_dram_udm			(mcb3_dram_udm		),
//	.mcb3_dram_dqs			(mcb3_dram_dqs		),
//	.mcb3_dram_dqs_n		(mcb3_dram_dqs_n	),
//	.mcb3_dram_ck			(mcb3_dram_ck		),
//	.mcb3_dram_ck_n			(mcb3_dram_ck_n		),
//	.c3_calib_done			(c1_calib_done		),
//	.c3_p2_cmd_clk			(clk_frame_buf		),
//	.c3_p2_cmd_en			(w_p2_cmd_en		),
//	.c3_p2_cmd_instr		(wv_p2_cmd_instr	),
//	.c3_p2_cmd_bl			(wv_p2_cmd_bl		),
//	.c3_p2_cmd_byte_addr	(wv_p2_cmd_byte_addr),
//	.c3_p2_cmd_empty		(w_p2_cmd_empty		),
//	.c3_p2_cmd_full			(w_p2_cmd_full		),
//	.c3_p2_wr_clk			(clk_front			),
//	.c3_p2_wr_en			(w_p2_wr_en			),
//	.c3_p2_wr_mask			(wv_p2_wr_mask		),
//	.c3_p2_wr_data			(wv_p2_wr_data		),
//	.c3_p2_wr_full			(w_p2_wr_full		),
//	.c3_p2_wr_empty			(w_p2_wr_empty		),
//	.c3_p2_wr_count			(wv_p2_wr_count		),
//	.c3_p2_wr_underrun		(w_p2_wr_underrun_nc),
//	.c3_p2_wr_error			(w_p2_wr_error		),
//	.c3_p3_cmd_clk			(clk_frame_buf		),
//	.c3_p3_cmd_en			(w_p3_cmd_en		),
//	.c3_p3_cmd_instr		(wv_p3_cmd_instr	),
//	.c3_p3_cmd_bl			(wv_p3_cmd_bl		),
//	.c3_p3_cmd_byte_addr	(wv_p3_cmd_byte_addr),
//	.c3_p3_cmd_empty		(w_p3_cmd_empty		),
//	.c3_p3_cmd_full			(w_p3_cmd_full		),
//	.c3_p3_rd_clk			(clk_back			),
//	.c3_p3_rd_en			(w_p3_rd_en			),
//	.c3_p3_rd_data			(wv_p3_rd_data		),
//	.c3_p3_rd_full			(w_p3_rd_full		),
//	.c3_p3_rd_empty			(w_p3_rd_empty		),
//	.c3_p3_rd_count			(wv_p3_rd_count		),
//	.c3_p3_rd_overflow		(w_p3_rd_overflow	),
//	.c3_p3_rd_error			(w_p3_rd_error		),
//	.c3_async_rst			(async_rst			),
//	.c3_sysclk_2x			(sysclk_2x			),
//	.c3_sysclk_2x_180		(sysclk_2x_180		),
//	.c3_pll_ce_0			(pll_ce_0			),
//	.c3_pll_ce_90			(pll_ce_90			),
//	.c3_pll_lock			(bufpll_mcb_lock	),
//	.c3_mcb_drp_clk			(mcb_drp_clk		)
//	);

	mig_core # (
	.C3_P0_MASK_SIZE		(4						),
	.C3_P0_DATA_PORT_SIZE	(32						),
	.C3_P1_MASK_SIZE		(4						),
	.C3_P1_DATA_PORT_SIZE	(32						),
	.DEBUG_EN				(0						),
	.C1_MEMCLK_PERIOD		(DDR3_MEMCLK_PERIOD		),
	.C1_CALIB_SOFT_IP		(DDR3_CALIB_SOFT_IP		),
	.C1_SIMULATION			(DDR3_SIMULATION		),
	.C1_MEM_ADDR_ORDER		(MEM_ADDR_ORDER			),
	.C1_NUM_DQ_PINS			(NUM_DQ_PINS			),
	.C1_MEM_ADDR_WIDTH		(MEM_ADDR_WIDTH			),
	.C1_MEM_BANKADDR_WIDTH	(MEM_BANKADDR_WIDTH		),
	.SKIP_IN_TERM_CAL		(SKIP_IN_TERM_CAL		),
	.DDR3_MEM_DENSITY		(DDR3_MEM_DENSITY		),
	.DDR3_MEM_TRAS			(DDR3_MEM_TRAS			),
	.DDR3_MEM_TRCD			(DDR3_MEM_TRCD			),
	.DDR3_MEM_TREFI			(DDR3_MEM_TREFI			),
	.DDR3_MEM_TRFC			(DDR3_MEM_TRFC			),
	.DDR3_MEM_TRP			(DDR3_MEM_TRP			),
	.DDR3_MEM_TWR			(DDR3_MEM_TWR			),
	.DDR3_MEM_TRTP			(DDR3_MEM_TRTP			),
	.DDR3_MEM_TWTR			(DDR3_MEM_TWTR			)
	)
	mig_core_inst (
	.mcb1_dram_dq			(mcb1_dram_dq		),
	.mcb1_dram_a			(mcb1_dram_a		),
	.mcb1_dram_ba			(mcb1_dram_ba		),
	.mcb1_dram_ras_n		(mcb1_dram_ras_n	),
	.mcb1_dram_cas_n		(mcb1_dram_cas_n	),
	.mcb1_dram_we_n			(mcb1_dram_we_n		),
	.mcb1_dram_odt			(mcb1_dram_odt		),
	.mcb1_dram_reset_n		(mcb1_dram_reset_n	),
	.mcb1_dram_cke			(mcb1_dram_cke		),
	.mcb1_dram_dm			(mcb1_dram_dm		),
	.mcb1_dram_udqs			(mcb1_dram_udqs		),
	.mcb1_dram_udqs_n		(mcb1_dram_udqs_n	),
	.mcb1_rzq				(mcb1_rzq			),
	.mcb1_zio				(mcb1_zio			),
	.mcb1_dram_udm			(mcb1_dram_udm		),
	.mcb1_dram_dqs			(mcb1_dram_dqs		),
	.mcb1_dram_dqs_n		(mcb1_dram_dqs_n	),
	.mcb1_dram_ck			(mcb1_dram_ck		),
	.mcb1_dram_ck_n			(mcb1_dram_ck_n		),
	.c1_calib_done			(c1_calib_done		),
	.c1_p2_cmd_clk			(clk_front			),
	.c1_p2_cmd_en			(wv_p2_cmd_en		),
	.c1_p2_cmd_instr		(wv_p2_cmd_instr	),
	.c1_p2_cmd_bl			(wv_p2_cmd_bl		),
	.c1_p2_cmd_byte_addr	(wv_p2_cmd_byte_addr),
	.c1_p2_cmd_empty		(w_p2_cmd_empty		),
	.c1_p2_cmd_full			(w_p2_cmd_full		),
	.c1_p2_wr_clk			(clk_front			),
	.c1_p2_wr_en			(w_p2_wr_en			),
	.c1_p2_wr_mask			(wv_p2_wr_mask		),
	.c1_p2_wr_data			(wv_p2_wr_data		),
	.c1_p2_wr_full			(w_p2_wr_full		),
	.c1_p2_wr_empty			(w_p2_wr_empty		),
	.c1_p2_wr_count			(wv_p2_wr_count		),
	.c1_p2_wr_underrun		(w_p2_wr_underrun	),
	.c1_p2_wr_error			(w_p2_wr_error		),
	.c1_p3_cmd_clk			(clk_back			),
	.c1_p3_cmd_en			(w_p3_cmd_en		),
	.c1_p3_cmd_instr		(wv_p3_cmd_instr	),
	.c1_p3_cmd_bl			(wv_p3_cmd_bl		),
	.c1_p3_cmd_byte_addr	(wv_p3_cmd_byte_addr),
	.c1_p3_cmd_empty		(w_p3_cmd_empty		),
	.c1_p3_cmd_full			(w_p3_cmd_full		),
	.c1_p3_rd_clk			(clk_back			),
	.c1_p3_rd_en			(w_p3_rd_en			),
	.c1_p3_rd_data			(wv_p3_rd_data		),
	.c1_p3_rd_full			(w_p3_rd_full		),
	.c1_p3_rd_empty			(w_p3_rd_empty		),
	.c1_p3_rd_count			(wv_p3_rd_count		),
	.c1_p3_rd_overflow		(w_p3_rd_overflow	),
	.c1_p3_rd_error			(w_p3_rd_error		),
	.c1_p4_cmd_clk			(clk_front			),
	.c1_p4_cmd_en			(w_p4_cmd_en		),
	.c1_p4_cmd_instr		(wv_p4_cmd_instr	),
	.c1_p4_cmd_bl			(wv_p4_cmd_bl		),
	.c1_p4_cmd_byte_addr	(wv_p4_cmd_byte_addr),
	.c1_p4_cmd_empty		(w_p4_cmd_empty		),
	.c1_p4_cmd_full			(w_p4_cmd_full		),
	.c1_p4_wr_clk			(clk_front			),
	.c1_p4_wr_en			(w_p4_wr_en			),
	.c1_p4_wr_mask			(wv_p4_wr_mask		),
	.c1_p4_wr_data			(wv_p4_wr_data		),
	.c1_p4_wr_full			(w_p4_wr_full		),
	.c1_p4_wr_empty			(w_p4_wr_empty		),
	.c1_p4_wr_count			(wv_p4_wr_count		),
	.c1_p4_wr_underrun		(w_p4_wr_underrun	),
	.c1_p4_wr_error			(w_p4_wr_error		),
	.c1_p5_cmd_clk			(clk_back			),
	.c1_p5_cmd_en			(w_p5_cmd_en		),
	.c1_p5_cmd_instr		(wv_p5_cmd_instr	),
	.c1_p5_cmd_bl			(wv_p5_cmd_bl		),
	.c1_p5_cmd_byte_addr	(wv_p5_cmd_byte_addr),
	.c1_p5_cmd_empty		(w_p5_cmd_empty		),
	.c1_p5_cmd_full			(w_p5_cmd_full		),
	.c1_p5_rd_clk			(clk_back			),
	.c1_p5_rd_en			(w_p5_rd_en			),
	.c1_p5_rd_data			(wv_p5_rd_data		),
	.c1_p5_rd_full			(w_p5_rd_full		),
	.c1_p5_rd_empty			(w_p5_rd_empty		),
	.c1_p5_rd_count			(wv_p5_rd_count		),
	.c1_p5_rd_overflow		(w_p5_rd_overflow	),
	.c1_p5_rd_error			(w_p5_rd_error		)
	);

endmodule