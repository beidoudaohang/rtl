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
//	-- 邢海涛		:| 2016/9/14 16:25:37	:|	多ROI版本
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
	parameter	NUM_DQ_PINS					= 16					,	//DDR3数据宽度
	parameter	MEM_BANKADDR_WIDTH			= 3						,	//DDR3bank宽度
	parameter	MEM_ADDR_WIDTH				= 13					,	//DDR3地址宽度
	parameter	DDR3_MEMCLK_FREQ			= 320					,	//DDR3时钟频率
	parameter	MEM_ADDR_ORDER				= "ROW_BANK_COLUMN"		,	//DDR3地址排布顺序
	parameter	SKIP_IN_TERM_CAL			= 1						,	//不校准输入电阻，节省功耗
	parameter	DDR3_MEM_DENSITY			= "1Gb"					,	//DDR3容量
	parameter	DDR3_TCK_SPEED				= "15E"					,	//DDR3的速度等级
	parameter	DDR3_SIMULATION				= "TRUE"				,	//打开仿真可以加速仿真速度，但是实际布局布线时，不能打开仿真。
	parameter	DDR3_CALIB_SOFT_IP			= "TRUE"				,	//仿真时，可以不使能校准逻辑
	parameter	DATA_WD						= 64					,	//输入数据位宽，MCB 读写 FIFO 位宽
	parameter	BACK_DATA_WD				= 32					,	//后端输出数据位宽
	parameter	SHORT_REG_WD   				= 16					,	//短寄存器位宽
	parameter	REG_WD   					= 32					,	//寄存器位宽
	parameter	MROI_MAX_NUM 				= 8						,	//Multi-ROI的最大个数
	parameter	SENSOR_MAX_WIDTH			= 4912					,	//Sensor最大的行有效宽度，以像素时钟为单位
	parameter	SENSOR_ALL_PIX_DIV4			= 1920					,	//Sensor最大窗口下，所有像素的个数/4
	parameter	PTR_WIDTH					= 2							//读写指针的位宽，1-最大2帧 2-最大4帧 3-最大8帧 4-最大16帧 5-最大32帧
	)
	(
	//  ===============================================================================================
	//  图像输入时钟域
	//  ===============================================================================================
	input									clk_in					,	//图像输入时钟
	input									i_fval					,	//clk_in时钟域，场有效信号
	input									i_dval					,	//clk_in时钟域，数据有效信号
	input									i_leader_flag			,	//clk_in时钟域，头包标志
	input									i_image_flag			,	//clk_in时钟域，图像标志
	input									i_chunk_flag			,	//clk_in时钟域，chunk标志
	input									i_trailer_flag			,	//clk_in时钟域，尾包标志
	input	[DATA_WD-1:0]					iv_din					,	//clk_in时钟域，数据输入
	output									o_buf_overflow			,	//clk_in时钟域，帧存前端FIFO溢出 0:帧存前端FIFO没有溢出 1:帧存前端FIFO出现过溢出的现象
	//  ===============================================================================================
	//  图像输出时钟域
	//  ===============================================================================================
	input									clk_out					,	//图像输出时钟
	input									i_buf_rd				,   //clk_out时钟域，后级模块读使能
	output									o_back_buf_empty		,	//clk_out时钟域，帧存后端FIFO空标志，用来指示帧存中是否有数据可读
	output	[BACK_DATA_WD-1:0]				ov_dout					,   //clk_out时钟域，后级FIFO数据输出
	//  ===============================================================================================
	//  帧缓存工作时钟
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	时钟复位
	//	-------------------------------------------------------------------------------------
	input									clk_frame_buf			,	//帧存时钟
	input									reset_frame_buf			,	//帧存时钟的复位信号
	//	-------------------------------------------------------------------------------------
	//	控制数据
	//	-------------------------------------------------------------------------------------
	input									i_stream_enable			,	//流使能信号，SE=1等待完整帧，SE=0立即停止，屏蔽前端数据写入
	input	[SHORT_REG_WD-1:0]				iv_frame_depth			,   //帧缓存深度
	input									i_chunk_mode_active		,	//chunk总开关，chunk开关影响leader和trailer的大小，通过判断chunk开关可以知道leader和trailer长度
	//	-------------------------------------------------------------------------------------
	//	多ROI寄存器
	//	-------------------------------------------------------------------------------------
	input									iv_multi_roi_global_en	,	//Multi-ROI 全局使能
	input	[MROI_MAX_NUM*REG_WD-1:0]		iv_payload_size_mroi	,	//Multi-ROI payload size 集合
	input	[MROI_MAX_NUM*REG_WD-1:0]		iv_image_size_mroi		,	//Multi-ROI image size 集合
	input	[MROI_MAX_NUM*SHORT_REG_WD-1:0]	iv_roi_pic_width		,	//sensor输出图像的总宽度
	input	[MROI_MAX_NUM*SHORT_REG_WD-1:0]	iv_roi_pic_width_mroi	,	//Multi-ROI pic_width 集合
	input	[MROI_MAX_NUM*REG_WD-1:0]		iv_start_mroi			,	//Multi-ROI 帧存其实地址 集合
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
	output									o_calib_done			,	//DDR3校准完成信号，高有效，时钟域未知
	output									o_wr_error				,	//MCB写端口出现错误，高有效，时钟域未知
	output									o_rd_error				,	//MCB读端口出现错误，高有效，时钟域未知
	//  ===============================================================================================
	//  External Memory
	//  ===============================================================================================
	inout  	[NUM_DQ_PINS-1:0]				mcb1_dram_dq			,	//数据信号
	output 	[MEM_ADDR_WIDTH-1:0]			mcb1_dram_a         	,	//地址信号
	output 	[MEM_BANKADDR_WIDTH-1:0]		mcb1_dram_ba        	,	//Bank地址信号
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


	//	ref signals

	//	===============================================================================================
	//	busrt相关参数
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	最大的burst的长度
	//	可选 64 32 16 8 4 2 1。必须是2的n次方，最大是64。
	//	-------------------------------------------------------------------------------------
	localparam	BURST_SIZE					= 32;
	//	-------------------------------------------------------------------------------------
	//	MCB fifo 位宽的byte个数
	//	-------------------------------------------------------------------------------------
	localparam	MCB_BYTE_NUM				= DATA_WD/8;
	//	-------------------------------------------------------------------------------------
	//	MCB fifo 位宽的byte个数对应的位宽
	//	-------------------------------------------------------------------------------------
	localparam	MCB_BYTE_NUM_WIDTH			= log2(MCB_BYTE_NUM);
	//	-------------------------------------------------------------------------------------
	//	每次burst的数据量，以byte为单位
	//	-------------------------------------------------------------------------------------
	localparam	MCB_BURST_BYTE_NUM			= BURST_SIZE*MCB_BYTE_NUM;


	//	===============================================================================================
	//	地址相关参数
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	refer to ug388 v2.3 p63
	//	mcb 地址空间排布，不同容量的DDR3，不同最大位宽
	//	1. 512Mb - 26
	//	2. 1Gb   - 27
	//	3. 2Gb   - 28
	//	如果定义错误，则按照1Gb的方式定义位宽，因为现在默认是1Gb
	//	-------------------------------------------------------------------------------------
	localparam	BYTE_ADDR_WIDTH		= (DDR3_MEM_DENSITY=="512Mb") ? 26 : ((DDR3_MEM_DENSITY=="2Gb") ? 28 : 27);
	//	-------------------------------------------------------------------------------------
	//	MCB BYTE ADDR 低位为0的个数
	//	-------------------------------------------------------------------------------------
	localparam	MCB_BURST_BYTE_NUM_WIDTH		= log2(MCB_BURST_BYTE_NUM);

	//	-------------------------------------------------------------------------------------
	//	读写计数器 wr_addr rd_addr 的最大位宽
	//	考虑到单帧的情况，byte addr只由 wr_addr 决定，与 wr_ptr 无关，因此 wr_addr 的最大位宽=实际有效的位宽
	//	-------------------------------------------------------------------------------------
	localparam	WR_ADDR_WIDTH				= BYTE_ADDR_WIDTH-MCB_BURST_BYTE_NUM_WIDTH;
	localparam	RD_ADDR_WIDTH				= BYTE_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH;

	//	===============================================================================================
	//	各个flag的地址分配，每个flag占用的数据量的单位是 一个 max burst 的数据量
	//	1.帧存中的数据分布方式为，以MAX_BURST_LENGTH=32，MROI_MAX_NUM=8为例说明
	//	-------------------------------------------------------------------------------------
	//					addr			max_data		addr_size
	//	-------------------------------------------------------------------------------------
	//	leader			0				56*8=448		(448/256)+1=2
	//
	//	trailer			2				36*8=288		(288/256)+1=2
	//
	//	chunk			4				40*8=320		(320/256)+1=2
	//
	//	image			6				na				na
	//
	//	trailer_final	{n(1'b1),1'b0}	36				(36/256)+1=1
	//	-------------------------------------------------------------------------------------
	//
	//	2.帧存中的数据分布方式为，以MAX_BURST_LENGTH=64，MROI_MAX_NUM=8为例说明
	//	-------------------------------------------------------------------------------------
	//					addr			max_data		addr_size
	//	-------------------------------------------------------------------------------------
	//	leader			0				56*16=896		(896/256)+1=4
	//
	//	trailer			4				36*16=576		(576/256)+1=3
	//
	//	chunk			7				40*16=640		(640/256)+1=3
	//
	//	image			10				na				na
	//
	//	trailer_final	{n(1'b1),1'b0}	36				(36/256)+1=1
	//	-------------------------------------------------------------------------------------
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	leader的地址
	//	-------------------------------------------------------------------------------------
	localparam	LEADER_START_ADDR				= 0;
	localparam	EACH_LEADER_SIZE				= 52;

	localparam	EACH_LEADER_SIZE_CEIL			= cdiv(EACH_LEADER_SIZE,MCB_BYTE_NUM)*MCB_BYTE_NUM;
	localparam	LEADER_REMAINDER				= remain(EACH_LEADER_SIZE,MCB_BYTE_NUM);

	localparam	MAX_LEADER_DATA					= EACH_LEADER_SIZE_CEIL*MROI_MAX_NUM;
	localparam	MAX_LEADER_ADDR_SIZE			= cdiv(MAX_LEADER_DATA,MCB_BYTE_NUM);

	localparam	MAX_LEADER_DATA_WIDTH			= log2(MAX_LEADER_DATA+1)-MCB_BYTE_NUM_WIDTH;

	//	-------------------------------------------------------------------------------------
	//	trailer的地址
	//	-------------------------------------------------------------------------------------
	localparam	TRAILER_START_ADDR				= LEADER_START_ADDR + MAX_LEADER_ADDR_SIZE;
	localparam	EACH_TRAILER_SIZE				= 32;
	localparam	EACH_TRAILER_SIZE_CHUNK			= 36;

	localparam	EACH_TRAILER_SIZE_CEIL			= cdiv(EACH_TRAILER_SIZE,MCB_BYTE_NUM)*MCB_BYTE_NUM;
	localparam	EACH_TRAILER_SIZE_CHUNK_CEIL	= cdiv(EACH_TRAILER_SIZE_CHUNK,MCB_BYTE_NUM)*MCB_BYTE_NUM;

	localparam	TRAILER_REMAINDER				= remain(EACH_TRAILER_SIZE,MCB_BYTE_NUM);
	localparam	TRAILER_CHUNK_REMAINDER			= remain(EACH_TRAILER_SIZE_CHUNK,MCB_BYTE_NUM);

	localparam	MAX_TRAILER_DATA				= EACH_TRAILER_SIZE_CHUNK_CEIL*MROI_MAX_NUM;
	localparam	MAX_TRAILER_ADDR_SIZE			= cdiv(MAX_TRAILER_DATA,MCB_BYTE_NUM);

	localparam	MAX_TRAILER_DATA_WIDTH			= log2(MAX_TRAILER_DATA+1)-MCB_BYTE_NUM_WIDTH;

	//	-------------------------------------------------------------------------------------
	//	chunk的地址
	//	-------------------------------------------------------------------------------------
	localparam	CHUNK_START_ADDR				= TRAILER_START_ADDR + MAX_TRAILER_ADDR_SIZE;
	localparam	EACH_CHUNK_SIZE					= 40;
	localparam	CHUNK_REMAINDER					= 1'b0;
	localparam	MAX_CHUNK_DATA					= EACH_CHUNK_SIZE*MROI_MAX_NUM;
	localparam	MAX_CHUNK_ADDR_SIZE				= cdiv(MAX_CHUNK_DATA,MCB_BYTE_NUM);

	localparam	MAX_CHUNK_DATA_WIDTH			= log2(MAX_CHUNK_DATA+1)-MCB_BYTE_NUM_WIDTH;

	//	-------------------------------------------------------------------------------------
	//	image的地址
	//	-------------------------------------------------------------------------------------
	localparam	IMAGE_START_ADDR				= CHUNK_START_ADDR + MAX_CHUNK_ADDR_SIZE;

	//	-------------------------------------------------------------------------------------
	//	trailer_final的地址
	//	-------------------------------------------------------------------------------------
	localparam	MAX_TRAILER_FINAL_DATA			= EACH_TRAILER_SIZE_CHUNK_CEIL*1;
	localparam	MAX_TRAILER_FINAL_ADDR_SIZE		= cdiv(MAX_TRAILER_FINAL_DATA,MCB_BYTE_NUM);
	localparam	TRAILER_FINAL_START_ADDR		= {{(WR_ADDR_WIDTH-MAX_TRAILER_FINAL_ADDR_SIZE){1'b1}},{(MAX_TRAILER_FINAL_ADDR_SIZE){1'b0}}};

	//	===============================================================================================
	//	计数器的位宽计算
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	所有leader数据量之和 / 8，单位是byte
	//  -------------------------------------------------------------------------------------
	localparam	MAX_LEADER_DATA_DIV8		= cdiv(MAX_LEADER_DATA,8);
	//  -------------------------------------------------------------------------------------
	//	image数据量 / 8，单位是byte
	//  -------------------------------------------------------------------------------------
	localparam	MAX_IMAGE_DATA_DIV8			= SENSOR_ALL_PIX_DIV4;
	//	-------------------------------------------------------------------------------------
	//	一个flag的最大数据量取决于 leader和image谁大
	//	-------------------------------------------------------------------------------------
	localparam	MAX_FLAG_DATA_DIV8			= (MAX_LEADER_DATA_DIV8>=MAX_IMAGE_DATA_DIV8) ? MAX_LEADER_DATA_DIV8 : MAX_IMAGE_DATA_DIV8;
	//	-------------------------------------------------------------------------------------
	//	flag 中数据计数器的位宽
	//	1.log2(MAX_FLAG_DATA_DIV8+1)+3 表示在10/12像素格式下，sensor最大的数据量，所需要的位宽
	//	2.-MCB_BYTE_NUM_WIDTH 由于MCB不是以1个byte位单位，因此还要减去MCB的位宽
	//	-------------------------------------------------------------------------------------
	localparam	WORD_CNT_FLAG_WIDTH			= log2(cdiv(MAX_FLAG_DATA_DIV8,MCB_BURST_BYTE_NUM)*MCB_BURST_BYTE_NUM+1)+3-MCB_BYTE_NUM_WIDTH;
	//	-------------------------------------------------------------------------------------
	//	line 中数据计数器的位宽
	//	1.log2(SENSOR_MAX_WIDTH*2+1) 表示在10/12像素格式下，sensor一行的最大数据量，所需要的位宽
	//	2.-MCB_BYTE_NUM_WIDTH 由于MCB不是以1个byte位单位，因此还要减去MCB的位宽
	//	-------------------------------------------------------------------------------------
	localparam	WORD_CNT_LINE_WIDTH			= log2(cdiv(SENSOR_MAX_WIDTH*2,MCB_BURST_BYTE_NUM)*MCB_BURST_BYTE_NUM+1)-MCB_BYTE_NUM_WIDTH;
	//	-------------------------------------------------------------------------------------
	//	burst 中数据计数器的位宽
	//	1.以 n byte 为单位
	//	-------------------------------------------------------------------------------------
	localparam	WORD_CNT_WIDTH				= log2(BURST_SIZE);
	//	-------------------------------------------------------------------------------------
	//	chunk大小的位宽
	//	-------------------------------------------------------------------------------------
	localparam	CHUNK_SIZE_WIDTH			= log2(EACH_CHUNK_SIZE+1);

	//	===============================================================================================
	//	其他参数
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	mask size
	//	-------------------------------------------------------------------------------------
	localparam	DDR3_MASK_SIZE	= MCB_BYTE_NUM;
	//	-------------------------------------------------------------------------------------
	//	DDR3时钟周期
	//	-------------------------------------------------------------------------------------
	localparam	DDR3_MEMCLK_PERIOD	= 1000000/DDR3_MEMCLK_FREQ	;
	//	-------------------------------------------------------------------------------------
	//	读模块中的flag的个数，是4个
	//	分别是 leader image chunk trailer
	//	-------------------------------------------------------------------------------------
	localparam	FLAG_NUM			= 4;




	//	ref functions
	//	-------------------------------------------------------------------------------------
	//	取对数，上取整
	//	-------------------------------------------------------------------------------------
	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction

	//	-------------------------------------------------------------------------------------
	//	除法上取整
	//	-------------------------------------------------------------------------------------
	function integer cdiv;
		input integer	dividend;	//被除数
		input integer	divisior;	//除数
		integer			division;	//商

		begin
			//此处的除法是下取整
			division	= dividend/divisior;
			//如果 商*除数=被除数 ，则是整除。否则，存在省略的小数部分，商要加1
			cdiv		= (division*divisior==dividend) ? division : division+1;
		end
	endfunction

	//	-------------------------------------------------------------------------------------
	//	判断除法是否有余数。0：没有余数 1：有余数
	//	-------------------------------------------------------------------------------------
	function [0:0] remain;
		input integer	dividend;	//被除数
		input integer	divisior;	//除数
		integer			division;	//商
		begin
			//此处的除法是下取整
			division	= dividend/divisior;
			//如果 商*除数=被除数 ，则是整除。否则，存在省略的小数部分，则非整除。
			remain		= (division*divisior==dividend) ? 1'b0 : 1'b1;
		end
	endfunction






	//	ref ARCHITECTURE

	wrap_wr_logic # (
	.DATA_WD						(DATA_WD						),
	.DDR3_MEM_DENSITY				(DDR3_MEM_DENSITY				),
	.DDR3_MASK_SIZE					(DDR3_MASK_SIZE					),
	.BURST_SIZE						(BURST_SIZE						),
	.PTR_WIDTH						(PTR_WIDTH						),
	.WR_ADDR_WIDTH					(WR_ADDR_WIDTH					),
	.WORD_CNT_WIDTH					(WORD_CNT_WIDTH					),
	.MCB_BURST_BYTE_NUM_WIDTH		(MCB_BURST_BYTE_NUM_WIDTH		),
	.SENSOR_MAX_WIDTH				(SENSOR_MAX_WIDTH				),
	.LEADER_START_ADDR				(LEADER_START_ADDR				),
	.TRAILER_START_ADDR				(TRAILER_START_ADDR				),
	.CHUNK_START_ADDR				(CHUNK_START_ADDR				),
	.IMAGE_START_ADDR				(IMAGE_START_ADDR				),
	.TRAILER_FINAL_START_ADDR		(TRAILER_FINAL_START_ADDR		),
	.REG_WD							(REG_WD							)
	)
	wrap_wr_logic_inst (
	.clk_in							(clk_in							),
	.i_fval							(i_fval							),
	.i_dval							(i_dval							),
	.i_leader_flag					(i_leader_flag					),
	.i_image_flag					(i_image_flag					),
	.i_chunk_flag					(i_chunk_flag					),
	.i_trailer_flag					(i_trailer_flag					),
	.iv_image_din					(iv_image_din					),
	.o_front_fifo_overflow			(o_front_fifo_overflow			),
	.clk							(clk_frame_buf					),
	.reset							(reset_frame_buf				),
	.ov_wr_ptr						(wv_wr_ptr						),
	.ov_wr_addr						(wv_wr_addr						),
	.o_wr_ptr_change				(w_wr_ptr_change				),
	.iv_rd_ptr						(wv_rd_ptr						),
	.i_reading						(w_reading						),
	.o_writing						(w_writing						),
	.i_stream_enable				(i_stream_enable				),
	.iv_frame_depth					(iv_frame_depth					),
	.ov_frame_depth					(wv_frame_depth					),
	.i_calib_done					(i_calib_done					),
	.o_wr_cmd_en					(w_wr_cmd_en					),
	.ov_wr_cmd_instr				(wv_wr_cmd_instr				),
	.ov_wr_cmd_bl					(wv_wr_cmd_bl					),
	.ov_wr_cmd_byte_addr			(wv_wr_cmd_byte_addr			),
	.i_wr_cmd_empty					(w_wr_cmd_empty					),
	.i_wr_cmd_full					(w_wr_cmd_full					),
	.o_wr_en						(w_wr_en						),
	.ov_wr_mask						(wv_wr_mask						),
	.ov_wr_data						(wv_wr_data						),
	.i_wr_full						(w_wr_full						)
	);










endmodule
