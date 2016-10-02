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
//  -- 张强       	:| 2014/11/27 10:16:54	:|  移植到MER-U3V工程，去掉仲裁模块
//	-- 张强			:| 2015/10/15 15:01:05	:|	为适应多通道串行cmossensor将写入port扩展到64bits
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :	帧缓存模块顶层
//              1)  : 包含以下模块
//					1.DDR3控制器
//					2.写逻辑顶层
//					3.读逻辑顶层
//
//              2)  : 对复位信号做了同步化的处理
//
//              3)  : 对使能信号采样，并且复位时，使能信号无效
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps

module frame_buffer # (
	parameter	BUF_DEPTH_WD				= 3						,	//帧存深度位宽,我们最大支持4帧深度，多一位进位位
	parameter	NUM_DQ_PINS					= 16					,	//DDR3数据宽度
	parameter	MEM_BANKADDR_WIDTH			= 3						,	//DDR3bank宽度
	parameter	MEM_ADDR_WIDTH				= 13					,	//DDR3地址宽度
	parameter	DDR3_MEMCLK_FREQ			= 320					,	//DDR3时钟频率
	parameter	MEM_ADDR_ORDER				= "ROW_BANK_COLUMN"		,	//DDR3地址排布顺序
	parameter 	DDR3_RST_ACT_LOW          	= 0						,   // # = 1 for active low reset,# = 0 for active high reset.
	parameter 	DDR3_INPUT_CLK_TYPE       	= "SINGLE_ENDED"		,   // input clock type DIFFERENTIAL or SINGLE_ENDED
	parameter	SKIP_IN_TERM_CAL			= 1						,	//不校准输入电阻，节省功耗
	parameter	DDR3_MEM_DENSITY			= "1Gb"					,	//DDR3容量
	parameter	DDR3_TCK_SPEED				= "15E"					,	//DDR3的速度等级
//	parameter	DDR3_SIMULATION				= "FALSE"				,	//打开仿真可以加速仿真速度，但是实际布局布线时，不能打开仿真。
	parameter	DDR3_SIMULATION				= "TRUE"				,	//打开仿真可以加速仿真速度，但是实际布局布线时，不能打开仿真。
	parameter	DDR3_CALIB_SOFT_IP			= "TRUE"				,	//仿真时，可以不使能校准逻辑
	parameter	DDR3_P0_MASK_SIZE			= 8						,	//p0口mask size
	parameter	DDR3_P1_MASK_SIZE			= 8						,	//p1口mask size
	parameter	DATA_WD						= 64					,	//输入数据位宽，
	parameter	GPIF_DAT_WIDTH				= 32					,	//输出数据位宽，
	parameter	FSIZE_WD					= 25					,	//帧大小宽度定义
	parameter	BSIZE_WD					= 9						,	//一次BURST 操作所占的位宽
	parameter	REG_WD   					= 32
	)
	(
//  ===============================================================================================
//  视频输入时钟域
//  ===============================================================================================
	input									clk_vin					,	//本地像素时钟，多通道sensor为数据通路时钟
	input									i_fval					,	//clk_pix时钟域，场有效信号
	input									i_dval					,	//clk_pix时钟域，数据有效信号
	input									i_trailer_flag			,	//clk_pix时钟域，尾包标志
	input		[DATA_WD-1				:0]	iv_image_din			,	//clk_pix时钟域，图像数据
	input									i_stream_en_clk_in		,	//流停止信号，clk_in时钟域，信号有效时允许数据完整帧写入帧存，无效时立即停止写入，并复位读写地址指针，清帧存
//  ===============================================================================================
//  视频输出时钟域
//  ===============================================================================================
	input									clk_vout				,	//gpif 时钟，100MHz
	input									i_buf_rd				,   //clk_gpif时钟域，后级模块读使能
	output									o_back_buf_empty		,	//clk_gpif时钟域，帧存后端FIFO空标志，用来指示帧存中是否有数据可读
	output		[GPIF_DAT_WIDTH-1		:0]	ov_frame_dout			,   //clk_gpif时钟域，后级FIFO数据输出，宽度32bit
	output									o_frame_valid			,	//clk_gpif时钟域，帧存输出数据有效
//  ===============================================================================================
//  帧缓存工作时钟
//  ===============================================================================================
	input									clk_frame_buf			,	//帧存时钟，
	input									reset_frame_buf			,	//帧存时钟的复位信号
//  ===============================================================================================
//  控制数据
//  ===============================================================================================
	input									i_stream_en				,	//clk_frame_buf时钟域，流使能信号，SE=1等待完整帧，SE=0立即停止，屏蔽前端数据写入
	input		[BUF_DEPTH_WD-1			:0]	iv_frame_depth			,   //clk_frame_buf时钟域，帧缓存深度
	input		[FSIZE_WD -1			:0]	iv_payload_size_frame_buf,   //clk_frame_buf时钟域，payload大小，不是帧存大小，支持32M以下图像大小
	input		[FSIZE_WD -1			:0]	iv_payload_size_pix		,
	input									i_chunkmodeactive		,	//clk_frame_buf时钟域，chunk总开关，chunk开关影响leader和trailer的大小，通过判断chunk开关可以知道leader和trailer长度
//  ===============================================================================================
//  PLL PORT
//  ===============================================================================================
	input									i_async_rst				,	//MCB 复位信号，高有效
	input									i_sysclk_2x				,	//MCB 工作时钟
	input									i_sysclk_2x_180			,	//MCB 工作时钟
	input									i_pll_ce_0				,	//MCB 移位使能信号
	input									i_pll_ce_90				,	//MCB 移位使能信号
	input									i_mcb_drp_clk			,	//MCB DRP 时钟，
	input									i_bufpll_mcb_lock		,	//BUFPLL_MCB 锁定信号
//  ===============================================================================================
//  MCB Status
//  ===============================================================================================
	output									o_calib_done			,	//clk_frame_buf时钟域，DDR3校准完成信号，高有效
	output									o_wr_error				,	//MCB写端口出现错误，高有效
	output									o_rd_error				,	//MCB读端口出现错误，高有效
//  ===============================================================================================
//  External Memory
//  ===============================================================================================
	inout  		[NUM_DQ_PINS-1			:0]	mcb1_dram_dq			,	//数据信号
	output 		[MEM_ADDR_WIDTH-1		:0]	mcb1_dram_a         	,	//地址信号
	output 		[MEM_BANKADDR_WIDTH-1	:0]	mcb1_dram_ba        	,	//Bank地址信号
	output									mcb1_dram_ras_n     	,	//行地址选通
	output									mcb1_dram_cas_n     	,	//列地址选通
	output									mcb1_dram_we_n      	,	//写信号
	output									mcb1_dram_odt       	,	//阻抗匹配信号
	output									mcb1_dram_reset_n   	,	//复位信号
	output									mcb1_dram_cke       	,	//时钟使能信号
	output									mcb1_dram_dm        	,	//低字节数据屏蔽信号
	inout 									mcb1_dram_udqs      	,	//高字节地址选通信号正
	inout 									mcb1_dram_udqs_n    	,	//高字节地址选通信号负
	inout 									mcb1_rzq            	,	//驱动校准
	output									mcb1_dram_udm       	,	//高字节数据屏蔽信号
	inout 									mcb1_dram_dqs       	,	//低字节	数据选通信号正
	inout 									mcb1_dram_dqs_n     	,	//低字节数据选通信号负
	output									mcb1_dram_ck        	,	//时钟正
	output									mcb1_dram_ck_n      		//时钟负

	);
//  -------------------------------------------------------------------------------------
//	常数定义
//  -------------------------------------------------------------------------------------
	localparam	DDR3_MEMCLK_PERIOD	= 1000000/DDR3_MEMCLK_FREQ	;
	localparam	BURST_SIZE			= 7'h40						;
	localparam	ADDR_WD   			= 19-BUF_DEPTH_WD			;//帧内地址位宽 19=30-2-9,9bit由64位宽864深度决定，128M对应27位，wr_frame_ptr含一个进位bit所以-2
//  ===============================================================================================
//  线网定义
//  ===============================================================================================
	wire									w_p_in_cmd_en         	;	//wrap_wr_logic输出，clk_frame_buf时钟域，mcb p2 口写信号
	wire		[2						:0]	wv_p_in_cmd_instr     	;	//wrap_wr_logic输出，clk_frame_buf时钟域，mcb p2 口写命令
	wire		[5						:0]	wv_p_in_cmd_bl        	;	//wrap_wr_logic输出，clk_frame_buf时钟域，mcb p2 口写数据的长度
	wire		[29						:0]	wv_p_in_cmd_byte_addr 	;	//wrap_wr_logic输出，clk_frame_buf时钟域，mcb p2 口写数据的地址
	wire									w_p_in_cmd_empty      	;	//mig_core输出，clk_frame_buf时钟域，mcb p2 口命令fifo空
	wire									w_p_in_cmd_full       	;	//mig_core输出，clk_frame_buf时钟域，mcb p2 口命令fifo慢
	wire									w_p_in_wr_en          	;	//wrap_wr_logic输出，clk_frame_buf时钟域，mcb p2 口写数据的地址
	wire		[DDR3_P1_MASK_SIZE-1	:0]	wv_p_in_wr_mask       	;	//wrap_wr_logic输出，clk_frame_buf时钟域，mcb p2 口写数据屏蔽信号
	wire		[DATA_WD-1				:0]	wv_p_in_wr_data       	;	//wrap_wr_logic输出，clk_frame_buf时钟域，mcb p2 口写数据
	wire									w_p_in_wr_full        	;	//mig_core输出，clk_frame_buf时钟域，mcb p2 口数据fifo空
	wire									w_p_in_wr_empty       	;	//mig_core输出，clk_frame_buf时钟域，mcb p2 口数据fifo满
	wire		[6						:0]	wv_p_in_wr_count		;	//mig_core输出，clk_frame_buf时钟域，mcb p2 口数据fifo数据个数

	wire									w_p_out_cmd_en         	;	//wrap_rd_logic输出，clk_frame_buf时钟域，mcb p3 口读信号
	wire		[2						:0]	wv_p_out_cmd_instr     	;	//wrap_rd_logic输出，clk_frame_buf时钟域，mcb p3 口读命令
	wire		[5						:0]	wv_p_out_cmd_bl        	;	//wrap_rd_logic输出，clk_frame_buf时钟域，mcb p3 口读数据的长度
	wire		[29						:0]	wv_p_out_cmd_byte_addr 	;	//wrap_rd_logic输出，clk_frame_buf时钟域，mcb p3 口读数据的地址
	wire									w_p_out_cmd_empty      	;	//mig_core输出，clk_frame_buf时钟域，mcb p3 口命令fifo空
	wire									w_p_out_cmd_full       	;	//mig_core输出，clk_frame_buf时钟域，mcb p3 口命令fifo慢
	wire									w_p_out_rd_en          	;	//wrap_rd_logic输出，clk_frame_buf时钟域，mcb p3 口读数据的地址
	wire		[DATA_WD-1				:0]	wv_p_out_rd_data       	;	//wrap_rd_logic输出，clk_frame_buf时钟域，mcb p3 口读数据屏蔽信号
	wire									w_p_out_rd_full        	;	//wrap_rd_logic输出，clk_frame_buf时钟域，mcb p3 口读数据
	wire									w_p_out_rd_empty       	;	//mig_core输出，clk_frame_buf时钟域，mcb p3 口数据fifo空
	wire									w_p_out_rd_overflow    	;	//mig_core输出，clk_frame_buf时钟域，mcb p3 口数据fifo溢出
	wire		[6						:0]	wv_p_out_rd_count		;	//mig_core输出，clk_frame_buf时钟域，mcb p3 口数据fifo数据个数

	wire		[BUF_DEPTH_WD-1			:0]	wv_wr_frame_ptr     	;	//wrap_wr_logic输出，clk_frame_buf时钟域，写指针
	wire		[ADDR_WD-1				:0]	wv_wr_addr          	;	//wrap_wr_logic输出，clk_frame_buf时钟域，写地址
	wire		[BUF_DEPTH_WD-1			:0]	wv_rd_frame_ptr 		;	//wrap_wr_logic输出，clk_frame_buf时钟域，读指针
	wire		[BUF_DEPTH_WD-1			:0]	wv_frame_depth			;	//帧缓存深度，clk时钟域，可设置为 2-8任意值，具体深度可以停止采集才能更新帧存深度,经过停采生效时机控制。
	wire									w_wr_frame_ptr_changing	;//clk_frame_buf时钟域，写指针正在变化信号，输出给读模块，此时读指针不能变化
	wire									w_se_2_fvalrise			;	//停采到下一帧场信号上升沿，为了避免一帧之内的重同步，将信号展宽后传给读模块，clk_vin时钟域，低电平标志停采

//  ===============================================================================================
//  MCB例化
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//  MCB (Memory Controller Block) DDR3控制器模块
//  -------------------------------------------------------------------------------------

	mig_core # (
	.C1_P0_MASK_SIZE						(8						),
	.C1_P0_DATA_PORT_SIZE					(64						),
	.C1_P1_MASK_SIZE						(8						),
	.C1_P1_DATA_PORT_SIZE					(64						),
	.DEBUG_EN								(0						),
	.C1_MEMCLK_PERIOD						(DDR3_MEMCLK_PERIOD		),
	.C1_CALIB_SOFT_IP						(DDR3_CALIB_SOFT_IP		),
	.C1_SIMULATION							(DDR3_SIMULATION		),
	.C1_RST_ACT_LOW							(DDR3_RST_ACT_LOW		),
	.C1_INPUT_CLK_TYPE						(DDR3_INPUT_CLK_TYPE	),
	.C1_MEM_ADDR_ORDER						(MEM_ADDR_ORDER			),
	.C1_NUM_DQ_PINS							(NUM_DQ_PINS			),
	.C1_MEM_ADDR_WIDTH						(MEM_ADDR_WIDTH			),
	.C1_MEM_BANKADDR_WIDTH					(MEM_BANKADDR_WIDTH		)
	)
	mig_core_inst (
	.mcb1_dram_dq							(mcb1_dram_dq			),
	.mcb1_dram_a							(mcb1_dram_a			),
	.mcb1_dram_ba							(mcb1_dram_ba			),
	.mcb1_dram_ras_n						(mcb1_dram_ras_n		),
	.mcb1_dram_cas_n						(mcb1_dram_cas_n		),
	.mcb1_dram_we_n							(mcb1_dram_we_n			),
	.mcb1_dram_odt							(mcb1_dram_odt			),
	.mcb1_dram_reset_n						(mcb1_dram_reset_n		),
	.mcb1_dram_cke							(mcb1_dram_cke			),
	.mcb1_dram_dm							(mcb1_dram_dm			),
	.mcb1_dram_udqs							(mcb1_dram_udqs			),
	.mcb1_dram_udqs_n						(mcb1_dram_udqs_n		),
	.mcb1_rzq								(mcb1_rzq				),
//	.mcb1_zio								(mcb1_zio				),
	.mcb1_dram_udm							(mcb1_dram_udm			),
	.mcb1_dram_dqs							(mcb1_dram_dqs			),
	.mcb1_dram_dqs_n						(mcb1_dram_dqs_n		),
	.mcb1_dram_ck							(mcb1_dram_ck			),
	.mcb1_dram_ck_n							(mcb1_dram_ck_n			),
	.c1_calib_done							(o_calib_done			),
    .c1_p0_cmd_clk							(clk_frame_buf			),
    .c1_p0_cmd_en							(w_p_in_cmd_en			),
	.c1_p0_cmd_instr						(wv_p_in_cmd_instr		),
	.c1_p0_cmd_bl							(wv_p_in_cmd_bl			),
	.c1_p0_cmd_byte_addr					(wv_p_in_cmd_byte_addr	),
	.c1_p0_cmd_empty						(w_p_in_cmd_empty		),
	.c1_p0_cmd_full							(w_p_in_cmd_full		),
    .c1_p0_wr_clk							(clk_frame_buf			),
    .c1_p0_wr_en							(w_p_in_wr_en			),
	.c1_p0_wr_mask							(wv_p_in_wr_mask		),
	.c1_p0_wr_data							(wv_p_in_wr_data		),
	.c1_p0_wr_full							(w_p_in_wr_full			),
	.c1_p0_wr_empty							(w_p_in_wr_empty		),
	.c1_p0_wr_count							(wv_p_in_wr_count		),
	.c1_p0_wr_underrun						(w_p_in_wr_underrun_nc	),
	.c1_p0_wr_error							(o_wr_error				),
    .c1_p0_rd_clk							(clk_frame_buf			),
    .c1_p0_rd_en							(1'b0					),
	.c1_p0_rd_data							(						),
	.c1_p0_rd_full							(						),
	.c1_p0_rd_empty							(						),
	.c1_p0_rd_count							(						),
	.c1_p0_rd_overflow						(						),
	.c1_p0_rd_error							(						),
	.c1_p1_cmd_clk							(clk_frame_buf			),
	.c1_p1_cmd_en							(w_p_out_cmd_en			),
	.c1_p1_cmd_instr						(wv_p_out_cmd_instr		),
	.c1_p1_cmd_bl							(wv_p_out_cmd_bl		),
	.c1_p1_cmd_byte_addr					(wv_p_out_cmd_byte_addr	),
	.c1_p1_cmd_empty						(w_p_out_cmd_empty		),
	.c1_p1_cmd_full							(w_p_out_cmd_full		),
	.c1_p1_wr_clk							(clk_frame_buf			),
	.c1_p1_wr_en							(1'b0					),
	.c1_p1_wr_mask							(8'h00					),
	.c1_p1_wr_data							(64'h0					),
	.c1_p1_wr_full							(						),
	.c1_p1_wr_empty							(						),
	.c1_p1_wr_count							(						),
	.c1_p1_wr_underrun						(						),
	.c1_p1_wr_error							(						),
	.c1_p1_rd_clk							(clk_frame_buf			),
	.c1_p1_rd_en							(w_p_out_rd_en			),
	.c1_p1_rd_data							(wv_p_out_rd_data		),
	.c1_p1_rd_full							(w_p_out_rd_full		),
	.c1_p1_rd_empty							(w_p_out_rd_empty		),
	.c1_p1_rd_count							(wv_p_out_rd_count		),
	.c1_p1_rd_overflow						(w_p_out_rd_overflow	),
	.c1_p1_rd_error     					(o_rd_error     		),
	.c1_async_rst							(i_async_rst			),
	.c1_sysclk_2x							(i_sysclk_2x			),
	.c1_sysclk_2x_180						(i_sysclk_2x_180		),
	.c1_pll_ce_0							(i_pll_ce_0				),
	.c1_pll_ce_90							(i_pll_ce_90			),
	.c1_pll_lock							(i_bufpll_mcb_lock		),
	.c1_mcb_drp_clk							(i_mcb_drp_clk			)
	);

//  ===============================================================================================
//  wrap_wr_logic例化
//  ===============================================================================================
	wrap_wr_logic # (
	.DATA_WD								(DATA_WD				),
	.BUF_DEPTH_WD							(BUF_DEPTH_WD			),
	.ADDR_WD								(ADDR_WD   				),
	.BURST_SIZE								(BURST_SIZE				),
	.DDR3_P0_MASK_SIZE						(DDR3_P0_MASK_SIZE		),
	.BSIZE_WD								(BSIZE_WD				)
	)
	wrap_wr_logic_inst(
	.clk_vin								(clk_vin				),
	.i_fval									(i_fval					),
	.i_dval									(i_dval					),
	.i_trailer_flag							(i_trailer_flag			),
	.iv_image_din							(iv_image_din			),
	.i_stream_en_clk_in						(i_stream_en_clk_in		),
	.i_stream_en							(i_stream_en			),
	.iv_frame_depth							(iv_frame_depth			),
	.ov_frame_depth							(wv_frame_depth			),
	.clk									(clk_frame_buf			),
	.reset									(reset_frame_buf		),
	.ov_wr_frame_ptr						(wv_wr_frame_ptr		),
	.ov_wr_addr								(wv_wr_addr				),
	.iv_rd_frame_ptr						(wv_rd_frame_ptr		),
	.o_wr_frame_ptr_changing				(w_wr_frame_ptr_changing),
	.o_se_2_fvalrise						(w_se_2_fvalrise		),
	.i_calib_done							(o_calib_done			),
	.o_p_in_cmd_en							(w_p_in_cmd_en			),
	.ov_p_in_cmd_instr						(wv_p_in_cmd_instr		),
	.ov_p_in_cmd_bl							(wv_p_in_cmd_bl			),
	.ov_p_in_cmd_byte_addr					(wv_p_in_cmd_byte_addr	),
	.i_p_in_cmd_empty						(w_p_in_cmd_empty		),
	.o_p_in_wr_en							(w_p_in_wr_en			),
	.ov_p_in_wr_mask						(wv_p_in_wr_mask		),
	.ov_p_in_wr_data						(wv_p_in_wr_data		),
	.i_p_in_wr_full							(w_p_in_wr_full			)
	);
//  ===============================================================================================
//  wrap_rd_logic例化
//  ===============================================================================================
	wrap_rd_logic # (
	.DATA_WD								(DATA_WD				),
	.GPIF_DAT_WIDTH							(GPIF_DAT_WIDTH			),
	.BUF_DEPTH_WD							(BUF_DEPTH_WD			),
	.REG_WD									(REG_WD					),
	.BURST_SIZE								(BURST_SIZE				),
	.FSIZE_WD								(FSIZE_WD				),//帧大小宽度定义
	.BSIZE_WD								(BSIZE_WD				) //一次BURST 操作所占的位宽
	)
	wrap_rd_logic_inst (
	.clk_vout								(clk_vout				),
	.i_buf_rd								(i_buf_rd				),
	.o_back_buf_empty						(o_back_buf_empty		),
	.o_frame_valid							(o_frame_valid			),
	.ov_frame_dout							(ov_frame_dout			),
	.i_se_2_fvalrise						(w_se_2_fvalrise		),
	.iv_frame_depth							(wv_frame_depth			),
	.iv_payload_size						(iv_payload_size_frame_buf),
	.i_chunkmodeactive						(i_chunkmodeactive		),
	.i_wr_frame_ptr_changing				(w_wr_frame_ptr_changing),
	.clk									(clk_frame_buf		    ),
	.reset									(reset_frame_buf		),
	.iv_wr_frame_ptr						(wv_wr_frame_ptr		),
	.iv_wr_addr								(wv_wr_addr				),
	.ov_rd_frame_ptr						(wv_rd_frame_ptr		),
	.i_calib_done							(o_calib_done			),
	.i_p_out_cmd_empty						(w_p_out_cmd_empty		),
	.o_p_out_cmd_en							(w_p_out_cmd_en			),
	.ov_p_out_cmd_instr						(wv_p_out_cmd_instr		),
	.ov_p_out_cmd_bl						(wv_p_out_cmd_bl		),
	.ov_p_out_cmd_byte_addr					(wv_p_out_cmd_byte_addr	),
	.iv_p_out_rd_data						(wv_p_out_rd_data		),
	.i_p_out_rd_empty						(w_p_out_rd_empty		),
	.o_p_out_rd_en							(w_p_out_rd_en			)
	);
endmodule