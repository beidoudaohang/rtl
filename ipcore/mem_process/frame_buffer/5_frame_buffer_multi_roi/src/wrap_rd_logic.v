//--------------------------------s-----------------------------------------------------------------
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
//  -- 张强         :| 2014/11/27 10:16:54	:|  移植到MER-U3V工程，根据产品要求适当修改
//  -- 张强         :| 2015/10/15 17:22:35	:|  将port口扩展为64bit宽度
//  -- 邢海涛       :| 2016/9/14 16:25:07	:|  多ROI版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :	读逻辑顶层
//              1)  : 完成帧图像从MCBP3口读出，写入后端FIFO，并供后端FIFO读出的逻辑，
//              2)  : 完成读出数据统计，保证读出数据和u3v协议要求数据相等
//              3)  : 完成读指针（图像计数）地址变换、读地址（字节计数）变换以及其他控制命令生成
//
//-------------------------------------------------------------------------------------------------

//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wrap_rd_logic # (
	parameter	DATA_WD										= 64		,	//输出数据位宽，这里使用同一宽度
	parameter	DDR3_MEM_DENSITY							= "1Gb"		,	//DDR3 容量 "2Gb" "1Gb" "512Mb"
	parameter	GPIF_DATA_WD								= 32		,	//后端输出数据位宽
	parameter	BURST_SIZE									= 32		,	//BURST_SIZE大小

	parameter	PTR_WIDTH									= 2			,	//读写指针的位宽，1-最大1帧 2-最大3帧 3-最大7帧 4-最大15帧 5-最大31帧 ... 16-最大65535帧
	parameter	WR_ADDR_WIDTH   							= 21		,	//帧内写地址位宽
	parameter	RD_ADDR_WIDTH								= 24		,	//帧内读地址位宽
	parameter	WORD_CNT_WIDTH								= 5			,	//word cnt 位宽
	parameter	WORD_CNT_LINE_WIDTH							= 11		,	//每一行计数器的位宽
	parameter	WORD_CNT_FLAG_WIDTH							= 23		,	//每个flag计数器的位宽

	parameter	BYTE_ADDR_WIDTH								= 27		,	//有效地址位宽，DDR3容量不同，位宽不同
	parameter	CHUNK_SIZE_WIDTH							= 6			,	//chunk size位宽
	parameter	MCB_BYTE_NUM_WIDTH							= 3			,	//mcb 数据宽度对应的位宽

	parameter	LEADER_ADDR_WIDTH							= 6			,	//leader addr 的计数器位宽
	parameter	CHUNK_ADDR_WIDTH							= 6			,	//chunk addr 的计数器位宽

	parameter	LEADER_START_ADDR							= 0			,	//leader的首地址
	parameter	TRAILER_START_ADDR							= 2			,	//trailer的首地址
	parameter	CHUNK_START_ADDR							= 4			,	//chunk的首地址
	parameter	IMAGE_START_ADDR							= 6			,	//image的首地址
	parameter	TRAILER_FINAL_START_ADDR					= {{19{1'b1}},8'b0}		,	//trailer_final的首地址

	parameter	MROI_MAX_NUM 								= 8			,	//Multi-ROI的最大个数
	parameter	RD_FLAG_NUM									= 4			,	//读flag的个数

	parameter	EACH_LEADER_SIZE_CEIL						= 56		,
	parameter	EACH_CHUNK_SIZE								= 40		,
	parameter	EACH_TRAILER_SIZE_CEIL						= 32		,
	parameter	EACH_TRAILER_SIZE_CHUNK_CEIL				= 40		,

	parameter	LEADER_REMAINDER							= 1'b1		,
	parameter	TRAILER_REMAINDER							= 1'b0		,
	parameter	TRAILER_CHUNK_REMAINDER						= 1'b1		,

	parameter	SHORT_REG_WD  								= 16		,	//短寄存器位宽
	parameter	REG_WD  									= 32			//寄存器位宽
	)
	(
	//	===============================================================================================
	//	图像输出时钟域
	//	===============================================================================================
	input										clk_out					,	//后级时钟，同U3_ITERFACE 模块时钟域
	input										i_buf_rd				,	//后级模块读使能，高有效，clk_out时钟域
	output										o_back_buf_empty		,	//后级FIFO空信号，高有效，clk_out时钟域
	output	[GPIF_DATA_WD:0]					ov_dout					,	//后级FIFO数据输出，宽度32bit
	//	===============================================================================================
	//	帧缓存工作时钟域
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	多ROI寄存器
	//	-------------------------------------------------------------------------------------
	input	[MROI_MAX_NUM*REG_WD-1:0]			iv_payload_size_mroi	,	//Multi-ROI payload size 集合
	input	[MROI_MAX_NUM*REG_WD-1:0]			iv_image_size_mroi		,	//Multi-ROI image size 集合
	input	[SHORT_REG_WD-1:0]					iv_roi_pic_width		,	//sensor输出图像的总宽度
	input	[MROI_MAX_NUM*SHORT_REG_WD-1:0]		iv_roi_pic_width_mroi	,	//Multi-ROI pic_width 集合
	input	[MROI_MAX_NUM*REG_WD-1:0]			iv_start_mroi			,	//Multi-ROI 帧存其实地址 集合
	input										i_multi_roi_global_en	,	//Multi-ROI 全局使能
	//  -------------------------------------------------------------------------------------
	//  与 wrap_wr_logic 交互
	//  -------------------------------------------------------------------------------------
	input										clk						,	//MCB 工作时钟
	input										reset					,	//clk时钟域复位信号
	input	[PTR_WIDTH-1:0]						iv_wr_ptr				,	//写指针
	input	[WR_ADDR_WIDTH-1:0]					iv_wr_addr				,	//写地址,应该是命令生效之后的写地址
	output	[PTR_WIDTH-1:0]						ov_rd_ptr				,	//读指针
	input										i_writing				,	//正在写
	output										o_reading				,	//正在读
	output										o_chunk_mode_active		,	//chunk mode active 经过生效时机控制
	//  -------------------------------------------------------------------------------------
	//  控制数据
	//  -------------------------------------------------------------------------------------
	input										i_stream_enable			,	//流停止信号，clk时钟域，信号有效时允许数据完整帧写入帧存，无效时立即停止写入，并复位读写地址指针，清帧存
	input	[REG_WD-1:0]						iv_pixel_format			,	//像素格式寄存器
	input	[PTR_WIDTH-1:0]						iv_frame_depth			,	//帧缓存深度，已同步,wrap_wr_logic模块已做生效时机控制
	input										i_wr_ptr_changing		,	//写指针正在变化信号，此时读指针不能变化
	input										i_chunk_mode_active		,	//chunk总开关，chunk开关影响leader和trailer的大小，通过判断chunk开关可以知道leader和trailer长度
	//  -------------------------------------------------------------------------------------
	//  MCB端口
	//  -------------------------------------------------------------------------------------
	input										i_calib_done			,	//MCB校准完成，高有效
	input										i_wr_cmd_empty			,	//MCB CMD 空，高有效
	input										i_rd_cmd_empty			,	//MCB CMD 空，高有效
	input										i_rd_cmd_full			,	//MCB CMD 满，高有效
	output										o_rd_cmd_en				,	//MCB CMD 写使能，高有效
	output	[2:0]								ov_rd_cmd_instr			,	//MCB CMD 指令
	output	[5:0]								ov_rd_cmd_bl			,	//MCB CMD 突发长度
	output	[29:0]								ov_rd_cmd_byte_addr		,	//MCB CMD 起始地址
	input	[DATA_WD-1:0]						iv_rd_data				,	//MCB RD FIFO 数据输出
	input										i_rd_empty				,	//MCB RD FIFO 空，高有效
	output										o_rd_en						//MCB RD FIFO 读使能，高有效
	);



	//	ref signals
	localparam	ROI_CNT_WIDTH				= log2(MROI_MAX_NUM);
	localparam	FLAG_CNT_WIDTH				= log2(RD_FLAG_NUM+1);

	//FSM Parameter Define
	parameter	S_IDLE		= 3'd0;
	parameter	S_PTR		= 3'd1;
	parameter	S_CMD		= 3'd2;
	parameter	S_RD		= 3'd3;
	parameter	S_LINE		= 3'd4;
	parameter	S_FLAG		= 3'd5;
	parameter	S_ROI		= 3'd6;

	reg		[2:0]	current_state	= S_IDLE;
	reg		[2:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	reg		[127:0]			state_ascii;
	always @ ( * ) begin
		case(current_state)
			3'd0 :	state_ascii	<= "S_IDLE";
			3'd1 :	state_ascii	<= "S_PTR";
			3'd2 :	state_ascii	<= "S_CMD";
			3'd3 :	state_ascii	<= "S_RD";
			3'd4 :	state_ascii	<= "S_LINE";
			3'd5 :	state_ascii	<= "S_FLAG";
			3'd6 :	state_ascii	<= "S_ROI";
		endcase
	end
	// synthesis translate_on

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
	//	动态位宽拼接
	//	1.由于verilog中的位宽拼接运算符中不允许出现变量，因此用function的方式实现动态位宽拼接
	//	function for循环展开之后
	//	-------------------------------------------------------------------------------------
	//	i		              ptr_and_addr
	//
	//	i=0		        |------------------------|
	//	i=1		        ||-----------------------|
	//	i=2		        | |----------------------|
	//	i=3		        |  |---------------------|
	//	i=4		        |   |--------------------|
	//	i=5		        |    |-------------------|
	//                    ^           ^
	//			        |ptr |       addr        |
	//	-------------------------------------------------------------------------------------
	//	地址排布 for循环展开之后
	//  -------------------------------------------------------------------------------------
	//	i		对应frame_depth数值		byte_addr实际排布
	//	i=0		1						{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_addr[RD_ADDR_WIDTH-1:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	i=1		2       				{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_ptr[0:0],rd_addr[RD_ADDR_WIDTH-2:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	i=2		3-4						{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_ptr[1:0],rd_addr[RD_ADDR_WIDTH-3:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	i=3 	5-8						{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_ptr[2:0],rd_addr[RD_ADDR_WIDTH-4:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	i=4		9-16					{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_ptr[3:0],rd_addr[RD_ADDR_WIDTH-5:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	i=5		17-32					{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_ptr[4:0],rd_addr[RD_ADDR_WIDTH-6:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	i=6		33-64					{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_ptr[5:0],rd_addr[RD_ADDR_WIDTH-7:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	i=7		65-128					{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_ptr[6:0],rd_addr[RD_ADDR_WIDTH-8:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	i=8		129-256					{{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},rd_ptr[7:0],rd_addr[RD_ADDR_WIDTH-9:0],{(MCB_BYTE_NUM_WIDTH){1'b0}}}
	//	......
	//	-------------------------------------------------------------------------------------
	function [RD_ADDR_WIDTH-1:0] ptr_and_addr;
		input	[PTR_WIDTH-1:0]			ptr_int;
		input	[RD_ADDR_WIDTH-1:0]		addr_int;
		input	[PTR_WIDTH-1:0]			depth_int;
		integer	i;
		integer	j;
		begin
			if(depth_int==1) begin
				ptr_and_addr	= addr_int;
			end
			for(i=1;i<=PTR_WIDTH;i=i+1) begin
				if(depth_int>=(2**(i-1)+1) && depth_int<=2**i) begin
					for(j=0;j<RD_ADDR_WIDTH;j=j+1) begin
						if(j<RD_ADDR_WIDTH-i) begin
							ptr_and_addr[j]	= addr_int[j];
						end
						else begin
							ptr_and_addr[j]	= ptr_int[j+i-RD_ADDR_WIDTH];
						end
					end
				end
			end
		end
	endfunction

	//	-------------------------------------------------------------------------------------
	//	edge
	//	-------------------------------------------------------------------------------------
	reg										stream_enable_dly	= 1'b0;
	wire									stream_enable_rise	;
	reg		[1:0]							calib_done_shift	= 2'b00;
	reg										writing_dly 		= 1'b0;
	wire									writing_rise		;
	reg										reading_dly 		= 1'b0;
	wire									reading_rise		;
	//	-------------------------------------------------------------------------------------
	//	reg active time
	//	-------------------------------------------------------------------------------------
	reg										format8_sel			= 1'b0;
	reg										chunk_mode_active	= 1'b0;

	//	-------------------------------------------------------------------------------------
	//	divide roi
	//	-------------------------------------------------------------------------------------
	wire	[SHORT_REG_WD-1:0]										roi_pic_width_ch[MROI_MAX_NUM-1:0]	;	//重新划分通道
	wire	[SHORT_REG_WD-1:0]										roi_pic_width_global				;	//总行宽，只在 multi-roi 模式下 才会设置该寄存器
	wire	[SHORT_REG_WD-1:0]										roi_pic_width_global_format_temp	;	//经过format控制的总行宽，如果像素格式不是8，则*2
	wire	[WORD_CNT_LINE_WIDTH+MCB_BYTE_NUM_WIDTH-1:0]			roi_pic_width_global_format			;	//经过format控制的总行宽，如果像素格式不是8，则*2
	wire	[SHORT_REG_WD-1:0]										roi_pic_width_active_format_temp	;	//当前的宽度，如果像素格式不是8，则*2
	wire	[WORD_CNT_LINE_WIDTH+MCB_BYTE_NUM_WIDTH-1:0]			roi_pic_width_active_format			;	//当前的宽度，如果像素格式不是8，则*2
	wire	[REG_WD-1:0]											payload_size_ch[MROI_MAX_NUM-1:0]	;	//重新划分通道
	wire	[REG_WD-1:0]											image_size_ch[MROI_MAX_NUM-1:0]		;	//重新划分通道
	wire	[REG_WD-1:0]											start_mroi_ch[MROI_MAX_NUM-1:0]		;	//重新划分通道

	//	-------------------------------------------------------------------------------------
	//	back fifo
	//	-------------------------------------------------------------------------------------
	wire									reset_fifo			;
	wire									fifo_wr_en			;
	wire									fifo_full			;
	wire									fifo_prog_full		;
	wire	[65:0]							fifo_din			;

	//	-------------------------------------------------------------------------------------
	//	mcb fifo operation
	//	-------------------------------------------------------------------------------------
	wire									mcb_rd_en			;
	reg										rd_cmd_en			= 1'b0;
	wire	[RD_ADDR_WIDTH-1:0]				ptr_and_addr_int	;

	//	-------------------------------------------------------------------------------------
	//	ptr addr cnt
	//	-------------------------------------------------------------------------------------
	reg		[PTR_WIDTH-1:0]					rd_ptr				= 'b0;
	reg		[RD_ADDR_WIDTH-1:0]				rd_addr				= 'b0;
	reg		[LEADER_ADDR_WIDTH-1:0]			leader_addr			= 'b0;
	reg		[BYTE_ADDR_WIDTH-1:0]			trailer_addr		= 'b0;
	reg		[CHUNK_ADDR_WIDTH-1:0]			chunk_addr			= 'b0;
	reg		[BYTE_ADDR_WIDTH-1:0]			image_addr			= 'b0;

	//	-------------------------------------------------------------------------------------
	//	word cnt
	//	-------------------------------------------------------------------------------------
	reg		[WORD_CNT_WIDTH-1:0]			word_cnt			= 'b0;	//单位是 n byte,n 是mcb fifo 的宽度
	reg		[WORD_CNT_LINE_WIDTH-1:0]		word_cnt_line		= 1;	//单位是 n byte,n 是mcb fifo 的宽度
	reg		[WORD_CNT_FLAG_WIDTH-1:0]		word_cnt_flag		= 1;	//单位是 n byte,n 是mcb fifo 的宽度

	//	-------------------------------------------------------------------------------------
	//	num cnt
	//	-------------------------------------------------------------------------------------
	reg		[FLAG_CNT_WIDTH-1:0]			flag_num_cnt		= 'b0;

	//	-------------------------------------------------------------------------------------
	//	size
	//	-------------------------------------------------------------------------------------
	reg		[CHUNK_SIZE_WIDTH-1:0]							chunk_size				= 'b0;	//单位是byte
	reg		[WORD_CNT_LINE_WIDTH+MCB_BYTE_NUM_WIDTH-1:0]	line_word_size			= 'b0;	//单位是byte
	reg		[WORD_CNT_FLAG_WIDTH+MCB_BYTE_NUM_WIDTH-1:0]	flag_word_size			= 'b0;	//单位是byte
	reg														remainder_head			= 1'b0;
	reg														remainder_tail			= 1'b0;

	//	-------------------------------------------------------------------------------------
	//	parser leader info
	//	-------------------------------------------------------------------------------------
	reg		[ROI_CNT_WIDTH-1:0]				roi_num				= 'b0;
	reg										last_roi			= 1'b0;

	//	-------------------------------------------------------------------------------------
	//	fsm flag
	//	-------------------------------------------------------------------------------------
	wire									burst_done			;			//一个burst数据量足够
	wire									line_done			;			//一行数据量足够
	reg										flag_done_reg		= 1'b0;		//一行数据量足够
	wire									flag_done_int		;			//一行数据量足够组合
	wire									flag_done			;			//一flag数据量足够
	reg										line_done_reg		= 1'b0;		//一flag数据量足够
	wire									line_done_int		;			//一flag数据量足够组合
	wire									line_equal			;			//当前roi的宽度是否与总宽度相等
	wire									last_flag			;			//最后一个flag标志位

	wire									dummy_head			;
	wire									dummy_tail			;

	reg										able_to_read		= 1'b0;
	reg										pipe_cnt			= 1'b0;

	reg										reading_reg 		= 1'b0;
	reg										fresh_frame 		= 1'b0;
	wire									ptr_move			;	//指针可以移动信号






	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***edge***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	stream_enable 开关
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		stream_enable_dly	<= i_stream_enable;
	end
	assign	stream_enable_rise	= (stream_enable_dly==1'b0 && i_stream_enable==1'b1) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	i_calib_done 时钟域未知，需要打2拍处理
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		calib_done_shift	<= {calib_done_shift[0],i_calib_done};
	end

	//	-------------------------------------------------------------------------------------
	//	判断writing的上升沿
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		writing_dly	<= i_writing;
	end
	assign	writing_rise	= (writing_dly==1'b0 && i_writing==1'b1) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	判断writing的上升沿
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		reading_dly	<= reading_reg;
	end
	assign	reading_rise	= (reading_dly==1'b0 && reading_reg==1'b1) ? 1'b1 : 1'b0;

	//	===============================================================================================
	//	ref ***reg activate time***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	USB3 Vision 	version 1.0.1	March, 2015
	//	table 5-14: Recommended Pixel Formats
	//
	//	Mono1p			0x01010037
	//	Mono2p			0x01020038
	//	Mono4p			0x01040039
	//	Mono8			0x01080001
	//	Mono10			0x01100003
	//	Mono10p			0x010a0046
	//	Mono12			0x01100005
	//	Mono12p			0x010c0047
	//	Mono14			0x01100025
	//	Mono16			0x01100007
	//
	//	BayerGR8		0x01080008
	//	BayerGR10		0x0110000C
	//	BayerGR10p		0x010A0056
	//	BayerGR12		0x01100010
	//	BayerGR12p		0x010C0057
	//	BayerGR16		0x0110002E
	//
	//	BayerRG8		0x01080009
	//	BayerRG10		0x0110000D
	//	BayerRG10p		0x010A0058
	//	BayerRG12		0x01100011
	//	BayerRG12p		0x010C0059
	//	BayerRG16		0x0110002F
	//
	//	BayerGB8		0x0108000A
	//	BayerGB10		0x0110000E
	//	BayerGB10p		0x010A0054
	//	BayerGB12		0x01100012
	//	BayerGB12p		0x010C0055
	//	BayerGB16		0x01100030
	//
	//	BayerBG8		0x0108000B
	//	BayerBG10		0x0110000F
	//	BayerBG10p		0x010A0052
	//	BayerBG12		0x01100013
	//	BayerBG12p		0x010C0053
	//	BayerBG16		0x01100031

	//	BGR8			0x02180015
	//	BGR10			0x02300019
	//	BGR10p			0x021E0048
	//	BGR12			0x0230001B
	//	BGR12p			0x02240049
	//	BGR14			0x0230004A
	//	BGR16			0x0230004B

	//	BGRa8			0x02200017
	//	BGRa10			0x0240004C
	//	BGRa10p			0x0228004D
	//	BGRa12			0x0240004E
	//	BGRa12p			0x0230004F
	//	BGRa14			0x02400050
	//	BGRa16			0x02400051
	//
	//	YCbCr8			0x0218005B
	//	YCbCr422_8		0x0210003B
	//	YCbCr411_8		0x020C005A
	//  -------------------------------------------------------------------------------------
	//	format8_sel
	//	1.判断像素格式是否选中8bit像素格式
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(stream_enable_rise==1'b1) begin
			case (iv_pixel_format[6:0])
				7'h01		: format8_sel	<= 1'b1;
				7'h08		: format8_sel	<= 1'b1;
				7'h09		: format8_sel	<= 1'b1;
				7'h0A		: format8_sel	<= 1'b1;
				7'h0B		: format8_sel	<= 1'b1;
				7'h15		: format8_sel	<= 1'b1;
				7'h17		: format8_sel	<= 1'b1;
				7'h5B		: format8_sel	<= 1'b1;
				7'h3B		: format8_sel	<= 1'b1;
				7'h5A		: format8_sel	<= 1'b1;
				default		: format8_sel	<= 1'b0;
			endcase
		end
	end

	//	-------------------------------------------------------------------------------------
	//	在se上升沿采样 chunk mode 开关
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(stream_enable_rise==1'b1) begin
			chunk_mode_active	<= i_chunk_mode_active;
		end
	end
	assign	o_chunk_mode_active	= chunk_mode_active;

	//	===============================================================================================
	//	ref ***divide roi***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	划分行宽
	//	-------------------------------------------------------------------------------------
	genvar	i;
	generate
		for(i=0;i<MROI_MAX_NUM;i=i+1) begin
			assign	roi_pic_width_ch[i]	= iv_roi_pic_width_mroi[SHORT_REG_WD*(i+1)-1:SHORT_REG_WD*i];
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	总行宽
	//	1.当打开 multi-roi 全局开关的时候，总行宽=iv_roi_pic_width，这个寄存器的地址是 0x2b03
	//	2.当关闭 multi-roi 全局开关的时候，总行宽=roi_pic_width_ch[0]，这个寄存器的地址是 0x42
	//	-------------------------------------------------------------------------------------
	assign	roi_pic_width_global			= (i_multi_roi_global_en==1'b1) ? iv_roi_pic_width : roi_pic_width_ch[0];

	//	-------------------------------------------------------------------------------------
	//	经过format控制的总行宽
	//	1.8bit模式下，行宽不变
	//	2.10 12bit模式下，行宽*2
	//	-------------------------------------------------------------------------------------
	assign	roi_pic_width_global_format_temp	= (format8_sel==1'b1) ? roi_pic_width_global : roi_pic_width_global<<1;
	assign	roi_pic_width_global_format			= roi_pic_width_global_format_temp[WORD_CNT_LINE_WIDTH+MCB_BYTE_NUM_WIDTH-1:0];

	//	-------------------------------------------------------------------------------------
	//	经过format控制的当前roi的行宽
	//	1.8bit模式下，行宽不变
	//	2.10 12bit模式下，行宽*2
	//	-------------------------------------------------------------------------------------
	assign	roi_pic_width_active_format_temp	= (format8_sel==1'b1) ? roi_pic_width_ch[roi_num] : roi_pic_width_ch[roi_num]<<1;
	assign	roi_pic_width_active_format			= roi_pic_width_active_format_temp[WORD_CNT_LINE_WIDTH+MCB_BYTE_NUM_WIDTH-1:0];

	//	-------------------------------------------------------------------------------------
	//	划分payload_size
	//	-------------------------------------------------------------------------------------
	genvar	j;
	generate
		for(j=0;j<MROI_MAX_NUM;j=j+1) begin
			assign	payload_size_ch[j]	= iv_payload_size_mroi[REG_WD*(j+1)-1:REG_WD*j];
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	划分image_size
	//	-------------------------------------------------------------------------------------
	genvar	k;
	generate
		for(k=0;k<MROI_MAX_NUM;k=k+1) begin
			assign	image_size_ch[k]	= iv_image_size_mroi[REG_WD*(k+1)-1:REG_WD*k];
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	划分start_mroi
	//	-------------------------------------------------------------------------------------
	genvar	l;
	generate
		for(l=0;l<MROI_MAX_NUM;l=l+1) begin
			assign	start_mroi_ch[l]	= iv_start_mroi[REG_WD*(l+1)-1:REG_WD*l];
		end
	endgenerate

	//	===============================================================================================
	//	ref ***back fifo***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	back fifo 例化
	//	-------------------------------------------------------------------------------------
	frame_buf_back_fifo_ww66wd512rw33wd1024_pf440 frame_buf_back_fifo_ww66wd512rw33wd1024_pf440_inst (
	.rst			(reset_fifo			),
	.wr_clk			(clk				),
	.wr_en			(fifo_wr_en			),
	.full			(fifo_full			),
	.prog_full		(fifo_prog_full		),
	.din			(fifo_din			),
	.rd_clk			(clk_out			),
	.rd_en			(i_buf_rd			),
	.empty			(o_back_buf_empty	),
	.dout			(ov_dout			)
	);

	//	-------------------------------------------------------------------------------------
	//	fifo 复位
	//	1.reset有效(帧存时钟域)
	//	2.停采
	//	-------------------------------------------------------------------------------------
	assign	reset_fifo	= reset | !i_stream_enable;

	//	-------------------------------------------------------------------------------------
	//	fifo 写使能
	//	1.mcb rd fifo 读使能有效
	//	2.一行没有结束
	//	3.一个flag没有结束
	//	-------------------------------------------------------------------------------------
	//	assign	fifo_wr_en	= (mcb_rd_en==1'b1 && line_done==1'b0 && flag_done==1'b0) ? 1'b1 : 1'b0;
	assign	fifo_wr_en	= (mcb_rd_en==1'b1 && line_done_reg==1'b0 && flag_done_reg==1'b0) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	fifo 输入数据
	//	1.FIFO 64bit转为32bit，高32位先输出，所以交换高低32bit输入
	//	2.存在一种情况，一行或者一个flag结尾的位置，数据量不是8byte，需要把多余的4byte标记出来，ctrl_bit就是标志位
	//	-------------------------------------------------------------------------------------
	assign	fifo_din	= {dummy_head,iv_rd_data[GPIF_DATA_WD-1:0],dummy_tail,iv_rd_data[DATA_WD-1:GPIF_DATA_WD]};

	//	===============================================================================================
	//	ref ***mcb fifo operation***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	mcb rd fifo 读使能信号
	//	1.读状态 2.mcb rd fifo 不空 3.后端fifo不满
	//	-------------------------------------------------------------------------------------
	assign	mcb_rd_en	= (current_state==S_RD && i_rd_empty==1'b0 && fifo_full==1'b0) ? 1'b1 : 1'b0;
	assign	o_rd_en		= mcb_rd_en;

	//	-------------------------------------------------------------------------------------
	//	mcb rd cmd fifo 使能信号
	//	1.只在 CMD 状态才能发出使能信号
	//	2.发出使能信号的条件与 CMD 跳转到 RD 的条件是一样的
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_CMD && able_to_read==1'b1) begin
			rd_cmd_en	<= 1'b1;
		end
		else begin
			rd_cmd_en	<= 1'b0;
		end
	end
	assign	o_rd_cmd_en	= rd_cmd_en;

	//	-------------------------------------------------------------------------------------
	//	读指令
	//	1.根据参数定义，可以有2种命令方式
	//	2.3'b011 -> with precharge; 3'b001 -> without precharge
	//	-------------------------------------------------------------------------------------
	assign	ov_rd_cmd_instr	= 3'b001;

	//	-------------------------------------------------------------------------------------
	//	读长度
	//	1.每次读的长度固定为 BURST_SIZE
	//	2.line结尾 flag结尾 最后一个burst，会多读出来数据，需要对这部分数据做处理
	//	-------------------------------------------------------------------------------------
	assign	ov_rd_cmd_bl 	= BURST_SIZE-1;

	//  -------------------------------------------------------------------------------------
	//	mcb 地址拼接
	//	1.UG388 pg63 对地址分布有详细的描述
	//	2.burst_size 大小不同，最低位固定为0的个数也不同
	//	3.由于 iv_frame_depth 输入端口位宽是16，可以支持的最大缓存深度为2**16-1=65535帧
	//	4.根据当前设定的帧缓存深度，灵活改变存储位置
	//	-------------------------------------------------------------------------------------
	assign	ptr_and_addr_int	= ptr_and_addr(rd_ptr[PTR_WIDTH-1:0],rd_addr[RD_ADDR_WIDTH-1:0],iv_frame_depth[PTR_WIDTH-1:0]);
	assign	ov_rd_cmd_byte_addr	= {{(30-RD_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH){1'b0}},ptr_and_addr_int[RD_ADDR_WIDTH-1:0],{MCB_BYTE_NUM_WIDTH{1'b0}}};

	//	===============================================================================================
	//	ref ***ptr addr cnt***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	读指针逻辑
	//	1.当帧存深度是1帧或者复位信号有效或者使能无效时，读指针复位
	//	2.其他情况下，当写允许=1且可以读(读写指针不一样)，读指针自增
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(iv_frame_depth==1 || reset==1'b1 || i_stream_enable==1'b0) begin
			rd_ptr	<= 'b0;
		end
		else begin
			//	-------------------------------------------------------------------------------------
			//	只有在 PTR 状态和 wr_ptr_change=0的时候，才能改变读指针
			//	-------------------------------------------------------------------------------------
			if(current_state==S_PTR && i_wr_ptr_changing==1'b0) begin
				//	-------------------------------------------------------------------------------------
				//	当多帧的时候，如果读指针!=写指针，说明有新的数据，那么读可以进入写
				//	-------------------------------------------------------------------------------------
				if(rd_ptr!=iv_wr_ptr) begin
					//	-------------------------------------------------------------------------------------
					//	如果读指针达到缓存深度的最大值，那么读指针要归零。
					//	--如果此时写指针也为0，那么读进入写，此时读地址要小于等于写地址
					//	-------------------------------------------------------------------------------------
					if(rd_ptr==(iv_frame_depth-1)) begin
						rd_ptr	<= 0;
					end
					//	-------------------------------------------------------------------------------------
					//	如果读指针没有达到缓存深度的最大值，那么读指针自增。
					//	-------------------------------------------------------------------------------------
					else begin
						rd_ptr	<= rd_ptr + 1'b1;
					end
				end
				//	-------------------------------------------------------------------------------------
				//	当多帧的时候，读指针=写指针，说明数据没有刷新过，FSM返回idle状态，读指针不能改变
				//	-------------------------------------------------------------------------------------
			end
		end
	end
	assign	ov_rd_ptr		= rd_ptr;

	//  -------------------------------------------------------------------------------------
	//  写地址逻辑
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	在idle状态下，地址清零
		//	-------------------------------------------------------------------------------------
		if(current_state==S_IDLE) begin
			rd_addr	<= leader_addr[LEADER_ADDR_WIDTH-1:MCB_BYTE_NUM_WIDTH];
		end
		//	-------------------------------------------------------------------------------------
		//	在 LINE 状态下，更新读地址
		//	-------------------------------------------------------------------------------------
		else if(current_state==S_LINE) begin
			rd_addr	<= image_addr[BYTE_ADDR_WIDTH-1:MCB_BYTE_NUM_WIDTH];
		end
		//	-------------------------------------------------------------------------------------
		//	在 FLAG 状态下，更新读地址
		//	-------------------------------------------------------------------------------------
		else if(current_state==S_FLAG) begin
			if(flag_num_cnt==1) begin
				rd_addr	<= image_addr[BYTE_ADDR_WIDTH-1:MCB_BYTE_NUM_WIDTH];
			end
			else if(flag_num_cnt==2) begin
				rd_addr	<= chunk_addr[CHUNK_ADDR_WIDTH-1:MCB_BYTE_NUM_WIDTH];
			end
			else if(flag_num_cnt==3) begin
				rd_addr	<= trailer_addr[BYTE_ADDR_WIDTH-1:MCB_BYTE_NUM_WIDTH];
			end
		end
		//	-------------------------------------------------------------------------------------
		//	在 ROI 状态下，更新读地址
		//	-------------------------------------------------------------------------------------
		else if(current_state==S_ROI) begin
			rd_addr	<= leader_addr[LEADER_ADDR_WIDTH-1:MCB_BYTE_NUM_WIDTH];
		end
		//	-------------------------------------------------------------------------------------
		//	在其他状态下，当读命令发出之后，写地址自增
		//	-------------------------------------------------------------------------------------
		else if(rd_cmd_en==1'b1) begin
			rd_addr	<= rd_addr + BURST_SIZE;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	计算leader地址
	//	1.在idle状态的时候，复位为leader的开始地址
	//	2.在一帧结束的时候，复位为leader的开始地址，因为在idle状态 (1) leader_addr	<= LEADER_START_ADDR; (2) rd_addr	<= leader_addr[LEADER_ADDR_WIDTH-1:MCB_BYTE_NUM_WIDTH];
	//		如果idle只有1拍，则 rd_addr 不会更新为初始值
	//	2.在读 leader 的时候，每出现一个 cmd ，地址累加
	//	3.累加的数值是 leader大小/8 上取整
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			leader_addr	<= LEADER_START_ADDR;
		end
		else if(current_state==S_ROI && last_roi==1'b1) begin
			leader_addr	<= LEADER_START_ADDR;
		end
		else if(flag_num_cnt==0 && rd_cmd_en==1'b1) begin
			leader_addr	<= leader_addr + EACH_LEADER_SIZE_CEIL;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	计算chunk地址
	//	1.在idle状态的时候，复位为chunk的开始地址
	//	2.在读 chunk 的时候，每出现一个 cmd ，地址累加
	//	3.累加的数值是从寄存器动态获取，chunk大小都是8的倍数
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			chunk_addr	<= CHUNK_START_ADDR;
		end
		else if(flag_num_cnt==2 && rd_cmd_en==1'b1) begin
			chunk_addr	<= chunk_addr + chunk_size;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	计算trailer地址
	//	1.在idle状态的时候，复位为trailer的开始地址
	//	2.在读 trailer 的时候，每出现一个 cmd ，地址累加
	//	3.累加的数值是 trailer大小/8 上取整
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			trailer_addr	<= TRAILER_START_ADDR;
		end
		else if(flag_num_cnt==3 && last_roi==1'b1) begin
			trailer_addr	<= TRAILER_FINAL_START_ADDR;
		end
		else if(flag_num_cnt==3 && rd_cmd_en==1'b1) begin
			trailer_addr	<= trailer_addr + EACH_TRAILER_SIZE_CHUNK_CEIL;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	计算image地址
	//	1.在leader阶段，地址切换为对应的roi的起始地址
	//	2.在line状态，起点要加上行宽，必须在 pipe_cnt=0的时候累加，因为在pipe_cnt=1的时候，rd_addr会更新 image_addr
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(flag_num_cnt==0) begin
			image_addr	<= start_mroi_ch[roi_num]+IMAGE_START_ADDR;
		end
		else if(current_state==S_LINE && pipe_cnt==1'b0) begin
			//			image_addr	<= image_addr + roi_pic_width_active_format;
			image_addr	<= image_addr + roi_pic_width_global_format;
		end
	end

	//	===============================================================================================
	//	ref ***word cnt***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	word_cnt 一组burst计数器
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	1.一组burst的计数器，计满 burst_size
		//	2.不需要再判断reset，因为reset=1，就会进入idle状态
		//	3.在一帧开始的时候，清空计数器。与wr_addr一同清零。
		//	-------------------------------------------------------------------------------------
		if(current_state==S_IDLE) begin
			word_cnt	<= 'b0;
		end
		//	-------------------------------------------------------------------------------------
		//	进入到 LINE FLAG ROI 状态，说明一行 一个flag 一个roi 结束了，此时word_cnt需要复位
		//	-------------------------------------------------------------------------------------
		else if(current_state==S_LINE || current_state==S_FLAG || current_state==S_ROI) begin
			word_cnt	<= 'b0;
		end
		//	-------------------------------------------------------------------------------------
		//	其他条件下，每读一次mcb rd fifo，word_cnt自增
		//	-------------------------------------------------------------------------------------
		else if(mcb_rd_en==1'b1) begin
			word_cnt	<= word_cnt + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	word_cnt_line 在图像阶段，一行数据计数器
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	1.在idle状态，复位
		//	2.在line状态，且pipe_cnt=1，此时要从line状态跳出，复位
		//	-------------------------------------------------------------------------------------
		if(current_state==S_IDLE || (current_state==S_LINE && pipe_cnt==1'b1)) begin
			word_cnt_line	<= 1;
		end
		//	-------------------------------------------------------------------------------------
		//	1.只有image flag期间计数
		//	-------------------------------------------------------------------------------------
		else if(flag_num_cnt==1 && mcb_rd_en==1'b1 && line_done_reg==1'b0) begin
			word_cnt_line	<= word_cnt_line + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	word_cnt_flag 一个FLAG数据计数器
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	1.在idle状态，复位
		//	2.在flag状态，且pipe_cnt=1，此时要从line状态跳出，复位
		//	-------------------------------------------------------------------------------------
		if(current_state==S_IDLE || (current_state==S_FLAG && pipe_cnt==1'b1)) begin
			word_cnt_flag	<= 1;
		end
		//	-------------------------------------------------------------------------------------
		//	1.只有image flag期间计数
		//	-------------------------------------------------------------------------------------
		else if(mcb_rd_en==1'b1 && line_done_reg==1'b0 && flag_done_reg==1'b0) begin
			word_cnt_flag	<= word_cnt_flag + 1'b1;
		end
	end

	//	===============================================================================================
	//	ref ***num cnt***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	flag_num_cnt
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	1.在idle状态，复位
		//	2.在roi状态，复位。 从flag状态跳出，必须要经过roi状态
		//	-------------------------------------------------------------------------------------
		if(current_state==S_IDLE || current_state==S_ROI) begin
			flag_num_cnt	<= 'b0;
		end
		//	-------------------------------------------------------------------------------------
		//	1.当处于flag状态且pipe cnt=0，flag计数器自增
		//	-------------------------------------------------------------------------------------
		else if(current_state==S_FLAG && pipe_cnt==1'b0) begin
			//	-------------------------------------------------------------------------------------
			//	如果chunk没有打开，跳过chunk
			//	-------------------------------------------------------------------------------------
			if(chunk_mode_active==1'b0 && flag_num_cnt==1'b1) begin
				flag_num_cnt	<= flag_num_cnt + 2;
			end
			else begin
				flag_num_cnt	<= flag_num_cnt + 1'b1;
			end
		end
	end

	//	//	-------------------------------------------------------------------------------------
	//	//	roi_num_cnt
	//	//	-------------------------------------------------------------------------------------
	//	always @ (posedge clk) begin
	//		//	-------------------------------------------------------------------------------------
	//		//	只在idle状态复位
	//		//	-------------------------------------------------------------------------------------
	//		if(current_state==S_IDLE) begin
	//			roi_num_cnt	<= 'b0;
	//		end
	//		//	-------------------------------------------------------------------------------------
	//		//	1.当处于roi状态且pipe cnt=0，roi计数器自增
	//		//	-------------------------------------------------------------------------------------
	//		else if(current_state==S_ROI && pipe_cnt==1'b0) begin
	//			roi_num_cnt	<= roi_num_cnt + 1'b1;
	//		end
	//	end

	//	===============================================================================================
	//	ref ***size***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	在se上升沿采样 chunk size，用roi0的 payload size 和 image_size 的差表示
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(stream_enable_rise==1'b1) begin
			chunk_size	<= payload_size_ch[0] - image_size_ch[0];
		end
	end

	//	-------------------------------------------------------------------------------------
	//	1.flag_word_size	每个flag的大小，以byte为单位
	//	2.line_word_size	图像状态下，每一行的大小，以byte为单位
	//	3.remainder			flag或者line的大小 除以"MCB FIFO 的宽度(默认是8byte)"之后是否有余数。1：有余数 0：没有余数
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(flag_num_cnt)
			//	-------------------------------------------------------------------------------------
			//	leader
			//	1.flag_word_size
			//	--52byte 不是8的整数倍，所以要写为56byte
			//	2.remainder_head
			//	--起点是8的整数倍，没有余数
			//	3.remainder_tail
			//	--最后一个数据，有4byte是多余的
			//	-------------------------------------------------------------------------------------
			0	: begin
				flag_word_size	<= EACH_LEADER_SIZE_CEIL;
				remainder_head	<= 1'b0;
				remainder_tail	<= LEADER_REMAINDER;
			end
			//	-------------------------------------------------------------------------------------
			//	image
			//	1.flag_word_size
			//	--图像大小就是flag的大小
			//	2.line_word_size
			//	--如果起始点有余数，或者行宽有余数，需要加上一个数据量，这个数据量不是 1 byte ，而是 n byte。
			//	--如果没有余数，那么就等于行宽
			//	3.remainder_head
			//	--如果起始点不是8的倍数，那么就标记出来
			//	3.remainder_tail
			//	--如果一行的数据量不是8的倍数，那么就标记出来
			//	-------------------------------------------------------------------------------------
			1	: begin
				flag_word_size	<= image_size_ch[roi_num];
				if(remainder_head|remainder_tail) begin
					line_word_size	<= roi_pic_width_active_format + {1'b1,{MCB_BYTE_NUM_WIDTH{1'b0}}};
				end
				else begin
					line_word_size	<= roi_pic_width_active_format;
				end
				remainder_head	<= image_addr[MCB_BYTE_NUM_WIDTH-1];
				remainder_tail	<= roi_pic_width_active_format[MCB_BYTE_NUM_WIDTH-1];
			end
			//	-------------------------------------------------------------------------------------
			//	chunk
			//	1.flag_word_size
			//	--数据量是通过 payload_size - image_size 得到的
			//	2.remainder_head
			//	--起始点永远是8的倍数
			//	3.remainder_tail
			//	--chunk大小永远是8的倍数
			//	-------------------------------------------------------------------------------------
			2	: begin
				flag_word_size	<= chunk_size;
				remainder_head	<= 1'b0;
				remainder_tail	<= 1'b0;
			end
			//	-------------------------------------------------------------------------------------
			//	trailer
			//	1.flag_word_size
			//	--与chunk开关的长度有关
			//	2.remainder_head
			//	--起点永远是8的倍数
			//	3.remainder_tail
			//	--关闭chunk的时候，trailer的大小是32byte
			//	--打开chunk的时候，trailer的大小是36byte，有余数
			//	-------------------------------------------------------------------------------------
			3	: begin
				if(chunk_mode_active==1'b0) begin
					flag_word_size	<= EACH_TRAILER_SIZE_CEIL;
					remainder_head	<= 1'b0;
					remainder_tail	<= TRAILER_REMAINDER;
				end
				else begin
					flag_word_size	<= EACH_TRAILER_SIZE_CHUNK_CEIL;
					remainder_head	<= 1'b0;
					remainder_tail	<= TRAILER_CHUNK_REMAINDER;
				end
			end
			default	: begin
				flag_word_size	<= flag_word_size;
				remainder_head	<= 1'b0;
				remainder_tail	<= 1'b0;
			end
		endcase
	end

	//	===============================================================================================
	//	ref ***parse leader info***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	从leader中解析 roi num 和 last roi 的信息
	//
	//	<BYTE3><BYTE2><BYTE1><BYTE0><  RESERVED  ><  PADDING_X >
	//
	//	BYTE0	: bit[7:0]	roi_num
	//	BYTE1	: bit[0] 	last_roi
	//			: bit[7:1]	reserved
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//		if(flag_num_cnt==0 && word_cnt_flag==flag_word_size[WORD_CNT_FLAG_WIDTH+MCB_BYTE_NUM_WIDTH-1:MCB_BYTE_NUM_WIDTH]-1 && mcb_rd_en==1'b1) begin
		//		if(flag_num_cnt==0 && word_cnt_flag[LEADER_ADDR_WIDTH-MCB_BYTE_NUM_WIDTH-1:0]==flag_word_size[LEADER_ADDR_WIDTH-1:MCB_BYTE_NUM_WIDTH] && mcb_rd_en==1'b1) begin
		if(flag_num_cnt==0 && flag_done==1'b1) begin
			roi_num		<= iv_rd_data[GPIF_DATA_WD+ROI_CNT_WIDTH-1:GPIF_DATA_WD];
			last_roi	<= iv_rd_data[GPIF_DATA_WD+8];
		end
	end

	//	===============================================================================================
	//	ref ***fsm flag***
	//	FSM 跳转需要的标志位
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	burst_done 数据量是否满足一个burst
	//	word cnt 从0开始计数，这一点与写不一样
	//	-------------------------------------------------------------------------------------
	assign	burst_done		= (word_cnt==(BURST_SIZE-1) && mcb_rd_en==1'b1) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	line_done 数据量是否满足一行
	//	1.当读最后一个数据的时候，就要拉高
	//	2.由于一个burst的长度是固定的，因此读出的数据量可能会超过一行的长度
	//	-------------------------------------------------------------------------------------
	assign	line_done	= (word_cnt_line==line_word_size[WORD_CNT_LINE_WIDTH+MCB_BYTE_NUM_WIDTH-1:MCB_BYTE_NUM_WIDTH] && mcb_rd_en==1'b1) ? 1'b1 : 1'b0;

	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	在 word_cnt_line 清零的时候，line_done_reg 也清零
		//	-------------------------------------------------------------------------------------
		if(current_state==S_IDLE || (current_state==S_LINE && pipe_cnt==1'b1)) begin
			line_done_reg	<= 1'b0;
		end
		//	-------------------------------------------------------------------------------------
		//	当line_done=1的时候，拉高
		//	-------------------------------------------------------------------------------------
		else if(line_done==1'b1) begin
			line_done_reg	<= 1'b1;
		end
	end
	assign	line_done_int	= line_done | line_done_reg;

	//	-------------------------------------------------------------------------------------
	//	flag_done 数据量是否满足一个flag
	//	1.当读最后一个数据的时候，就要拉高
	//	2.由于一个burst的长度是固定的，因此读出的数据量可能会超过一个flag的长度
	//	-------------------------------------------------------------------------------------
	assign	flag_done	= (word_cnt_flag==flag_word_size[WORD_CNT_FLAG_WIDTH+MCB_BYTE_NUM_WIDTH-1:MCB_BYTE_NUM_WIDTH] && mcb_rd_en==1'b1) ? 1'b1 : 1'b0;

	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	在 word_cnt_flag 复位的时候，同时 清零 flag_done_reg
		//	-------------------------------------------------------------------------------------
		if(current_state==S_IDLE || (current_state==S_FLAG && pipe_cnt==1'b1)) begin
			flag_done_reg	<= 1'b0;
		end
		else if(flag_done==1'b1) begin
			flag_done_reg	<= 1'b1;
		end
	end
	assign	flag_done_int	= flag_done | flag_done_reg;


	assign	line_equal		= (roi_pic_width_ch[roi_num]==roi_pic_width_global) ? 1'b1 : 1'b0;
	assign	last_flag		= (flag_num_cnt==RD_FLAG_NUM) ? 1'b1 : 1'b0;


	assign	dummy_head		= (remainder_head==1'b1 && word_cnt_line==1) ? 1'b1 : 1'b0;
	assign	dummy_tail		= (remainder_tail==1'b1 && (line_done==1'b1 || flag_done==1'b1)) ? 1'b1 : 1'b0;
	//	assign	dummy_tail		= (remainder_tail==1'b1 && (line_done_int==1'b1 || flag_done_int==1'b1)) ? 1'b1 : 1'b0;

	reg		[WR_ADDR_WIDTH-1:0]			wr_addr_sub ='b0;

	always @ (posedge clk) begin
		if(iv_wr_addr==0) begin
			wr_addr_sub	<= 0;
		end
		else begin
			wr_addr_sub	<= iv_wr_addr - 1'b1;
		end
	end


	//	-------------------------------------------------------------------------------------
	//	可以读的条件
	//	able_to_read是 a.从CMD跳转到RD的条件，也是 b.在CMD状态发出命令的条件
	//	-------------------------------------------------------------------------------------
	always @ ( * ) begin
		//	-------------------------------------------------------------------------------------
		//	当 rd cmd fifo 不满的时候，才能判断是否进入下一个状态。否则，停留在CMD状态
		//	-------------------------------------------------------------------------------------
		if(i_rd_cmd_full==1'b0) begin
			//	-------------------------------------------------------------------------------------
			//	如果读写指针相等，且此时正在写，那么读地址要小于写地址且mcb wr cmd fifo是空的
			//	-------------------------------------------------------------------------------------
//			if(rd_ptr==iv_wr_ptr && i_writing==1'b1 && rd_addr<{{iv_wr_addr-1},{(RD_ADDR_WIDTH-WR_ADDR_WIDTH){1'b0}}} && i_wr_cmd_empty==1'b1) begin
//			if(rd_ptr==iv_wr_ptr && i_writing==1'b1 && rd_addr<{iv_wr_addr,{(RD_ADDR_WIDTH-WR_ADDR_WIDTH){1'b0}}} && i_wr_cmd_empty==1'b1) begin
			if(rd_ptr==iv_wr_ptr && i_writing==1'b1 && rd_addr<{wr_addr_sub,{(RD_ADDR_WIDTH-WR_ADDR_WIDTH){1'b0}}} && i_wr_cmd_empty==1'b1) begin
				able_to_read	<= 1'b1;
			end
			//	-------------------------------------------------------------------------------------
			//	如果读写指针相等，且此时不在写
			//	-------------------------------------------------------------------------------------
			else if(rd_ptr==iv_wr_ptr && i_writing==1'b0) begin
				able_to_read	<= 1'b1;
			end
			//	-------------------------------------------------------------------------------------
			//	如果读写指针不相等
			//	-------------------------------------------------------------------------------------
			else if(rd_ptr!=iv_wr_ptr) begin
				able_to_read	<= 1'b1;
			end
			//	-------------------------------------------------------------------------------------
			//	否则，继续停留在CMD状态
			//	-------------------------------------------------------------------------------------
			else begin
				able_to_read	<= 1'b0;
			end
		end
		else begin
			able_to_read	<= 1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	pipe_cnt
	//	1.LINE FLAG ROI 这三个状态中，
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_LINE || current_state==S_FLAG || current_state==S_ROI) begin
			pipe_cnt	<= !pipe_cnt;
		end
		else begin
			pipe_cnt	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  单帧倒换逻辑中，当前帧是否有效信号。
	//	1.当使能关闭 fresh_frame清零
	//	2.开采时，在writing上升沿时，fresh_frame=1，表示有数据可读
	//	3.开采时，在reading上升沿时，fresh_frame=0，表示已经读取当前帧
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_stream_enable==1'b0) begin
			fresh_frame	<= 1'b0;
		end
		else begin
			if(writing_rise==1'b1) begin
				fresh_frame	<= 1'b1;
			end
			else if(reading_rise==1'b1) begin
				fresh_frame	<= 1'b0;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//  正在读
	//	1.当处于idle状态时，正在读信号清零
	//	2.当处于 PTR 状态且 wr_ptr_change=0的时候，才能变为1，这是要和 rd_ptr 一起改变的原因
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			reading_reg	<= 1'b0;
		end
		else if(current_state==S_PTR && i_wr_ptr_changing==1'b0) begin
			//	-------------------------------------------------------------------------------------
			//	当单帧的时候，如果写刷新过，则可以读。否则，返回idle状态。
			//	-------------------------------------------------------------------------------------
			if(iv_frame_depth==1'b1) begin
				if(fresh_frame==1'b1) begin
					reading_reg	<= 1'b1;
				end
				else begin
					reading_reg	<= 1'b0;
				end
			end
			//	-------------------------------------------------------------------------------------
			//	当多帧的时候，如果读指针!=写指针，说明有新的数据，那么读可以进入写
			//	-------------------------------------------------------------------------------------
			else if(rd_ptr!=iv_wr_ptr) begin
				reading_reg	<= 1'b1;
			end
			//	-------------------------------------------------------------------------------------
			//	当多帧的时候，读指针=写指针，说明数据没有刷新过，返回idle状态
			//	-------------------------------------------------------------------------------------
			else begin
				reading_reg	<= 1'b0;
			end
		end
	end
	assign	o_reading	= reading_reg;

	//	-------------------------------------------------------------------------------------
	//	ptr_move 读指针可以移动的信号
	//	当单帧的时候，如果写刷新过，则可以读。否则，返回idle状态。
	//	当多帧的时候，如果读指针!=写指针，说明有新的数据，那么读可以进入写
	//	-------------------------------------------------------------------------------------
	assign	ptr_move	= (iv_frame_depth==1 && fresh_frame==1'b1) ? 1'b1 : ((iv_frame_depth!=1 && rd_ptr!=iv_wr_ptr) ? 1'b1 : 1'b0);

	//	===============================================================================================
	//	ref ***FSM***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	FSM Sequential Logic
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			current_state	<= S_IDLE;
		end
		else begin
			current_state	<= next_state;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	FSM Conbinatial Logic
	//	-------------------------------------------------------------------------------------
	always @ ( * ) begin
		case(current_state)
			S_IDLE	:
			//	-------------------------------------------------------------------------------------
			//	IDLE -> PTR
			//	1.开采有效 2.校准完成
			//	3.指针可以移动信号，添加这个信号之后，在帧消隐期间，状态机会一直停留在idle状态，而不是 idle ptr 两个状态之间互相跳跃
			//	在idle时不需要判断后端fifo的状态，在读mcb rd fifo的时候判断后端fifo满状态
			//	-------------------------------------------------------------------------------------
			if(i_stream_enable==1'b1 && calib_done_shift[1]==1'b1 && ptr_move==1'b1) begin
				next_state	= S_PTR;
			end
			else begin
				next_state	= S_IDLE;
			end
			S_PTR	:
			//	-------------------------------------------------------------------------------------
			//	只有在 wr_ptr_change=1 的时候，才能够切换读指针。否则在PTR状态等待。
			//	wr_ptr_change信号的宽度是2个时钟周期，因此最多等待2个时钟周期
			//	这样做的目的是防止读写指针同时变化
			//	-------------------------------------------------------------------------------------
			if(i_wr_ptr_changing==1'b0) begin
				if(ptr_move==1'b1) begin
					next_state	= S_CMD;
				end
				else begin
					next_state	= S_IDLE;
				end
			end
			else begin
				next_state	= S_PTR;
			end
			S_CMD	:
			//	-------------------------------------------------------------------------------------
			//	CMD -> RD
			//	1.当 rd cmd fifo 不满的时候，才能判断是否进入下一个状态。否则，停留在CMD状态
			//	2.读写指针相等，且此时正在写，那么读地址要小于写地址且mcb wr cmd fifo是空的
			//	3.读写指针相等，且此时不在写
			//	4.读写指针不相等
			//	-------------------------------------------------------------------------------------
			if(able_to_read==1'b1) begin
				next_state	= S_RD;
			end
			else begin
				next_state	= S_CMD;
			end
			S_RD	:
			//	-------------------------------------------------------------------------------------
			//	RD -> IDLE
			//	1.数据量满足一个burst
			//	2.停采
			//	-------------------------------------------------------------------------------------
			if(i_stream_enable==1'b0 && burst_done==1'b1) begin
				next_state	= S_IDLE;
			end
			//	-------------------------------------------------------------------------------------
			//	RD -> LINE
			//	1.数据量满足一个burst
			//	2.在 image flag 阶段
			//	3.满足一行的数据量
			//	4.开采
			//	-------------------------------------------------------------------------------------
			else if(i_stream_enable==1'b1 && flag_num_cnt==1 && burst_done==1'b1 && line_done_int==1'b1) begin
				next_state	= S_LINE;
			end
			//	-------------------------------------------------------------------------------------
			//	RD -> FLAG (如果roi的行宽与sensor输出的行宽相等，就没有必要换行，当一个flag读完之后，进入flag状态)
			//	1.数据量满足一个burst
			//	2.在 image flag 阶段
			//	3.满足一个flag的数据量
			//	4.当前ROI的行宽与总行宽相等
			//	5.开采
			//	-------------------------------------------------------------------------------------
			else if(i_stream_enable==1'b1 && flag_num_cnt==1 && burst_done==1'b1 && flag_done_int==1'b1 && line_equal==1'b1) begin
				next_state	= S_FLAG;
			end
			//	-------------------------------------------------------------------------------------
			//	RD -> FLAG (非图像阶段，是不会进入到line状态的)
			//	1.数据量满足一个burst
			//	2.不在 image flag 阶段
			//	3.满足一个flag的数据量
			//	5.开采
			//	-------------------------------------------------------------------------------------
			else if(i_stream_enable==1'b1 && flag_num_cnt!=1 && burst_done==1'b1 && flag_done_int==1'b1) begin
				next_state	= S_FLAG;
			end
			//	-------------------------------------------------------------------------------------
			//	RD -> CMD
			//	1.数据量满足一个burst
			//	2.不满足一行的数据量
			//	4.开采
			//	-------------------------------------------------------------------------------------
			else if(i_stream_enable==1'b1 && burst_done==1'b1 && line_done_int==1'b0) begin
				next_state	= S_CMD;
			end
			//	-------------------------------------------------------------------------------------
			//	其他条件，停留在RD状态
			//	-------------------------------------------------------------------------------------
			else begin
				next_state	= S_RD;
			end
			S_LINE	:
			//	-------------------------------------------------------------------------------------
			//	LINE -> CMD
			//	1.不满足一个flag的数据量
			//	-------------------------------------------------------------------------------------
			if(flag_done_int==1'b0 && pipe_cnt==1'b1) begin
				next_state	= S_CMD;
			end
			//	-------------------------------------------------------------------------------------
			//	LINE -> FLAG
			//	1.满足一个flag的数据量
			//	-------------------------------------------------------------------------------------
			else if(flag_done_int==1'b1 && pipe_cnt==1'b1) begin
				next_state	= S_FLAG;
			end
			else begin
				next_state	= S_LINE;
			end
			S_FLAG	:
			//	-------------------------------------------------------------------------------------
			//	FLAG -> CMD
			//	1.当前flag不是最后一个flag
			//	-------------------------------------------------------------------------------------
			if(last_flag==1'b0 && pipe_cnt==1'b1) begin
				next_state	= S_CMD;
			end
			//	-------------------------------------------------------------------------------------
			//	FLAG -> IDLE
			//	1.当前flag是最后一个flag
			//	-------------------------------------------------------------------------------------
			else if(last_flag==1'b1 && pipe_cnt==1'b1) begin
				next_state	= S_ROI;
			end
			else begin
				next_state	= S_FLAG;
			end
			S_ROI	:
			//	-------------------------------------------------------------------------------------
			//	ROI -> CMD
			//	1.当前ROI不是最后一个ROI
			//	-------------------------------------------------------------------------------------
			if(last_roi==1'b0 && pipe_cnt==1'b1) begin
				next_state	= S_CMD;
			end
			//	-------------------------------------------------------------------------------------
			//	FLAG -> IDLE
			//	1.当前ROI是最后一个ROI
			//	-------------------------------------------------------------------------------------
			else if(last_roi==1'b1 && pipe_cnt==1'b1) begin
				next_state	= S_IDLE;
			end
			else begin
				next_state	= S_ROI;
			end
			default	:
			next_state	= S_IDLE;
		endcase
	end


endmodule
