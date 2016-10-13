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
//  -- 邢海涛       :| 2013/6/14 14:00:40	:|  初始版本
//  -- 张强         :| 2014/11/27 10:16:54	:|  移植到MER-U3V工程，根据产品要求适当修改
//  -- 张强         :| 2015/10/15 17:22:35	:|  将port口扩展为64bit宽度
//  -- 邢海涛       :| 2016/9/14 16:25:07	:|  多ROI版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :	帧缓存模块顶层
//						1）完成帧图像经前端FIFO数据写入和读出，MCBP2口数据写入的过程
//						2）完成写指针（图像计数）地址变换、写地址（字节计数）变换以及其他控制命令生成
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
module wrap_wr_logic # (
	parameter	DATA_WD										= 64		,	//输出数据位宽，这里使用同一宽度
	parameter	DDR3_MEM_DENSITY							= "1Gb"		,	//DDR3 容量 "2Gb" "1Gb" "512Mb"
	parameter	DDR3_MASK_SIZE								= 8			,	//mask size
	parameter	BURST_SIZE									= 32		,	//BURST_SIZE大小
	parameter	PTR_WIDTH									= 2			,	//读写指针的位宽，1-最大2帧 2-最大4帧 3-最大8帧 4-最大16帧 5-最大32帧
	parameter	WR_ADDR_WIDTH   							= 19		,	//帧内地址位宽
	parameter	WORD_CNT_WIDTH								= 5			,	//word cnt 位宽
	parameter	MCB_BURST_BYTE_NUM_WIDTH					= 8			,	//MCB BYTE ADDR 低位为0的个数
	parameter	SENSOR_MAX_WIDTH							= 1280		,	//Sensor最大的行有效宽度
	parameter	LEADER_START_ADDR							= 0			,	//leader的首地址
	parameter	TRAILER_START_ADDR							= 2			,	//trailer的首地址
	parameter	CHUNK_START_ADDR							= 4			,	//chunk的首地址
	parameter	IMAGE_START_ADDR							= 6			,	//image的首地址
	parameter	TRAILER_FINAL_START_ADDR					= 254		,	//trailer_final的首地址
	parameter	REG_WD  						 			= 32			//寄存器位宽
	)
	(
	//	===============================================================================================
	//	图像输入时钟域
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  图像输入数据
	//  -------------------------------------------------------------------------------------
	input							clk_in								,	//前端FIFO写入数据时钟
	input							i_fval								,	//场有效信号，高有效，clk_in时钟域,i_fval的上升沿要比i_dval的上升沿提前，i_fval的下降沿要比i_dval的下降沿滞后；i_fval和i_dval上升沿之间要有足够的空隙，最小值是MAX(6*clk_in,6*clk_frame_buf)；i_fval和i_dval下降沿之间要有足够的空隙，最小值是1*clk_in + 7*clk_frame_buf
	input							i_dval								,	//数据有效信号，高有效，clk_in时钟域，数据有效不向行信号一样连续，可以是断续的信号
	input							i_leader_flag						,	//头包标志
	input							i_image_flag						,	//图像标志
	input							i_chunk_flag						,	//chunk标志
	input							i_trailer_flag						,	//尾包标志
	input	[DATA_WD-1:0]			iv_image_din						,	//图像数据，32位宽，clk_in时钟域
	output							o_front_fifo_overflow				,	//帧存前端FIFO溢出 0:帧存前端FIFO没有溢出 1:帧存前端FIFO出现过溢出的现象
	//	===============================================================================================
	//	帧缓存工作时钟域
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  与 wrap_rd_logic 交互
	//  -------------------------------------------------------------------------------------
	input							clk									,	//MCB
	input							reset								,	//复位信号
	output	[PTR_WIDTH-1:0]			ov_wr_ptr							,	//写指针,以帧为单位
	output	[WR_ADDR_WIDTH-1:0]			ov_wr_addr							,	//P2口命令使能信号，标志写地址已经生效，在仲裁保证下，数据能够写入DDR，此信号对地址判断非常重要
	output							o_wr_ptr_change						,	//写指针正在变化信号，输出给读模块，此时读指针不能变化
	input	[PTR_WIDTH-1 :0]		iv_rd_ptr							,	//读指针,以帧为单位
	input							i_reading							,	//正在读标志
	output							o_writing							,	//正在写标志
	//  -------------------------------------------------------------------------------------
	//  控制数据
	//  -------------------------------------------------------------------------------------
	input							i_stream_enable						,	//流停止信号，clk时钟域，信号有效时允许数据完整帧写入帧存，无效时立即停止写入，并复位读写地址指针，清帧存
	input	[PTR_WIDTH-1:0]			iv_frame_depth						,	//帧缓存深度 可设置为 1 - 31.
	output	[PTR_WIDTH-1:0]			ov_frame_depth						,	//帧缓存深度 可设置为 1 - 31.经过生效时机的。
	//  -------------------------------------------------------------------------------------
	//  MCB端口
	//  -------------------------------------------------------------------------------------
	input							i_calib_done						,	//MCB校准完成信号，高有效，时钟域未知
	output							o_wr_cmd_en							,	//MCB CMD FIFO 写信号，高有效
	output	[2:0]					ov_wr_cmd_instr						,	//MCB CMD FIFO 指令
	output	[5:0]					ov_wr_cmd_bl						,	//MCB CMD FIFO 突发长度
	output	[29:0]					ov_wr_cmd_byte_addr					,	//MCB CMD FIFO 起始地址
	input							i_wr_cmd_empty						,	//MCB CMD FIFO 空信号，高有效
	input							i_wr_cmd_full						,	//MCB CMD FIFO 慢信号，高有效
	output							o_wr_en								,	//MCB WR FIFO 写信号，高有效
	output	[DDR3_MASK_SIZE-1:0]	ov_wr_mask							,	//MCB WR 屏蔽信号
	output	[DATA_WD-1:0]			ov_wr_data							,	//MCB WR FIFO 写数据
	input							i_wr_full								//MCB WR FIFO 满信号，高有效
	);



	//	ref signals

	localparam	MAX_LINE_DATA				= SENSOR_MAX_WIDTH*2;			//BIT10 12 模式下 一行的数据量
	localparam	MIN_FRONT_FIFO_DEPTH		= MAX_LINE_DATA/(DATA_WD/8);	//前端fifo深度的最小值
	localparam	FRONT_FIFO_DEPTH			= (MIN_FRONT_FIFO_DEPTH<=256) ? 256 : ((MIN_FRONT_FIFO_DEPTH<=512) ? 512 : ((MIN_FRONT_FIFO_DEPTH<=1024) ? 1024 : 2048));


	//FSM Parameter Define
	parameter	S_IDLE		= 3'd0;
	parameter	S_PTR		= 3'd1;
	parameter	S_WR		= 3'd2;
	parameter	S_CMD		= 3'd3;
	parameter	S_FLAG		= 3'd4;

	reg		[2:0]	current_state	= S_IDLE;
	reg		[2:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	reg		[127:0]			state_ascii;
	always @ ( * ) begin
		case(current_state)
			3'd0 :	state_ascii	<= "S_IDLE";
			3'd1 :	state_ascii	<= "S_PTR";
			3'd2 :	state_ascii	<= "S_WR";
			3'd3 :	state_ascii	<= "S_CMD";
			3'd4 :	state_ascii	<= "S_FLAG";
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
	//	for 循环展开之后
	//  -------------------------------------------------------------------------------------
	//	i		最大帧数	frame_depth范围		byte_addr实际排布
	//	i=0		1			1					{{(30-WR_ADDR_WIDTH-MCB_BURST_BYTE_NUM_WIDTH){1'b0}},wr_addr[WR_ADDR_WIDTH-1:0],{(MCB_BURST_BYTE_NUM_WIDTH){1'b0}}}
	//	i=1		2			2       			{{(30-WR_ADDR_WIDTH-MCB_BURST_BYTE_NUM_WIDTH){1'b0}},wr_ptr[0:0],wr_addr[WR_ADDR_WIDTH-2:0],{(MCB_BURST_BYTE_NUM_WIDTH){1'b0}}}
	//	i=2		4			3-4					{{(30-WR_ADDR_WIDTH-MCB_BURST_BYTE_NUM_WIDTH){1'b0}},wr_ptr[1:0],wr_addr[WR_ADDR_WIDTH-3:0],{(MCB_BURST_BYTE_NUM_WIDTH){1'b0}}}
	//	i=3 	8			5-8					{{(30-WR_ADDR_WIDTH-MCB_BURST_BYTE_NUM_WIDTH){1'b0}},wr_ptr[2:0],wr_addr[WR_ADDR_WIDTH-4:0],{(MCB_BURST_BYTE_NUM_WIDTH){1'b0}}}
	//	i=4		16			9-16				{{(30-WR_ADDR_WIDTH-MCB_BURST_BYTE_NUM_WIDTH){1'b0}},wr_ptr[3:0],wr_addr[WR_ADDR_WIDTH-5:0],{(MCB_BURST_BYTE_NUM_WIDTH){1'b0}}}
	//	i=5		32			17-32				{{(30-WR_ADDR_WIDTH-MCB_BURST_BYTE_NUM_WIDTH){1'b0}},wr_ptr[4:0],wr_addr[WR_ADDR_WIDTH-6:0],{(MCB_BURST_BYTE_NUM_WIDTH){1'b0}}}
	//	i=6		64			33-64				{{(30-WR_ADDR_WIDTH-MCB_BURST_BYTE_NUM_WIDTH){1'b0}},wr_ptr[5:0],wr_addr[WR_ADDR_WIDTH-7:0],{(MCB_BURST_BYTE_NUM_WIDTH){1'b0}}}
	//	i=7		128			65-128				{{(30-WR_ADDR_WIDTH-MCB_BURST_BYTE_NUM_WIDTH){1'b0}},wr_ptr[6:0],wr_addr[WR_ADDR_WIDTH-8:0],{(MCB_BURST_BYTE_NUM_WIDTH){1'b0}}}
	//	i=8		256			129-256				{{(30-WR_ADDR_WIDTH-MCB_BURST_BYTE_NUM_WIDTH){1'b0}},wr_ptr[7:0],wr_addr[WR_ADDR_WIDTH-9:0],{(MCB_BURST_BYTE_NUM_WIDTH){1'b0}}}
	//	......
	//	-------------------------------------------------------------------------------------
	function [WR_ADDR_WIDTH-1:0] ptr_and_addr;
		input	[PTR_WIDTH-1:0]	ptr_int;
		input	[WR_ADDR_WIDTH-1:0]	addr_int;
		input	[PTR_WIDTH-1:0]	depth_int;
		integer	i;
		integer	j;
		begin
			if(depth_int==1) begin
				ptr_and_addr	= addr_int;
			end
			for(i=1;i<=PTR_WIDTH;i=i+1) begin
				if(depth_int>=(2**(i-1)+1) && depth_int<=2**i) begin
					for(j=0;j<WR_ADDR_WIDTH;j=j+1) begin
						if(j<WR_ADDR_WIDTH-i) begin
							ptr_and_addr[j]	= addr_int[j];
						end
						else begin
							ptr_and_addr[j]	= ptr_int[j+i-WR_ADDR_WIDTH];
						end
					end
				end
			end
		end
	endfunction



	reg		[2:0]						fval_shift			= 3'b000;
	wire								fval_rise			;
	wire								fval_fall			;
	reg									stream_enable_reg	= 1'b0;
	reg		[1:0]						calib_done_shift	= 2'b00;
	reg									active_flag_dly		= 1'b0;
	wire								active_flag_fall	;
	reg		[PTR_WIDTH-1:0]				frame_depth_reg 	= 'b0;
	wire								reset_fifo			;
	wire								fifo_wr_en			;
	wire								fifo_full			;
	wire	[DATA_WD+4:0]				fifo_din			;
	wire								fifo_rd_en			;
	reg									front_fifo_overflow	= 1'b0;
	reg									wr_cmd_en			= 1'b0;
	wire	[WR_ADDR_WIDTH-1:0]				ptr_and_addr_int	;
	wire								fifo_empty			;
	wire								fifo_prog_empty		;
	wire	[DATA_WD+4:0]				fifo_dout			;

	reg		[PTR_WIDTH-1:0]				wr_ptr				= 'b0;
	reg		[WR_ADDR_WIDTH-1:0]				wr_addr				= 'b0;
	reg		[WORD_CNT_WIDTH-1:0]		word_cnt 			= {(WORD_CNT_WIDTH){1'b1}};
	reg									able_to_write 		= 1'b0;
	wire								leader_flag			;
	wire								trailer_flag		;
	wire								chunk_flag			;
	wire								image_flag			;
	wire								trailer_final_flag	;
	wire								active_flag			;
	reg		[2:0]						flag_cnt			= 3'b0;
	wire	[WR_ADDR_WIDTH-1:0]				start_addr			;
	reg									wr_ptr_change		= 1'b0;
	reg									writing_reg			= 1'b0;



	//	ref ARCHITECTURE


	//	===============================================================================================
	//	ref ***edge***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	fval 上升沿
	//	-------------------------------------------------------------------------------------

	always @ (posedge clk) begin
		fval_shift	<= {fval_shift[1:0],i_fval};
	end
	assign	fval_rise	= (fval_shift[2:1]==2'b01) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_shift[2:1]==2'b10) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	stream_enable_reg
	//	1.当 i_stream_enable =0时，立即变为0
	//	2.当 i_stream_enable =1 且 fval rise 的时候，才能变为1
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_stream_enable==1'b0) begin
			stream_enable_reg	<= 1'b0;
		end
		else if(fval_rise==1'b1) begin
			stream_enable_reg	<= 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	i_calib_done 时钟域未知，需要打2拍处理
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		calib_done_shift	<= {calib_done_shift[0],i_calib_done};
	end

	//	-------------------------------------------------------------------------------------
	//	当前选中的flag的边沿
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		active_flag_dly	<= active_flag;
	end
	assign	active_flag_fall	= (active_flag_dly==1'b1 && active_flag==1'b0) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	frame_depth_reg 帧存深度寄存器
	//	1.在空闲状态采样 frame_depth
	//	2.如果是0，则保护为1
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			if(iv_frame_depth==0) begin
				frame_depth_reg	<= 1;
			end
			else begin
				frame_depth_reg	<= iv_frame_depth;
			end
		end
	end
	assign	ov_frame_depth	= frame_depth_reg;

	//	===============================================================================================
	//	ref ***front fifo***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	front fifo 例化
	//	-------------------------------------------------------------------------------------
	generate
		//	-------------------------------------------------------------------------------------
		//	sensor行宽小于等于1024
		//	-------------------------------------------------------------------------------------
		if(FRONT_FIFO_DEPTH==256) begin
			frame_buf_front_fifo_w69d256_pe128 frame_buf_front_fifo_w69d256_pe128_inst (
			.rst			(reset_fifo			),
			.wr_clk			(clk_in				),
			.wr_en			(fifo_wr_en			),
			.full			(fifo_full			),
			.din			(fifo_din			),
			.rd_clk			(clk				),
			.rd_en			(fifo_rd_en			),
			.empty			(fifo_empty			),
			.prog_empty		(fifo_prog_empty	),
			.dout			(fifo_dout			)
			);
		end
		//	-------------------------------------------------------------------------------------
		//	sensor行宽小于等于2048
		//	-------------------------------------------------------------------------------------
		else if(FRONT_FIFO_DEPTH==512) begin
			frame_buf_front_fifo_w69d512_pe256 frame_buf_front_fifo_w69d512_pe256_inst (
			.rst			(reset_fifo			),
			.wr_clk			(clk_in				),
			.wr_en			(fifo_wr_en			),
			.full			(fifo_full			),
			.din			(fifo_din			),
			.rd_clk			(clk				),
			.rd_en			(fifo_rd_en			),
			.empty			(fifo_empty			),
			.prog_empty		(fifo_prog_empty	),
			.dout			(fifo_dout			)
			);
		end
		//	-------------------------------------------------------------------------------------
		//	sensor行宽小于等于4096
		//	-------------------------------------------------------------------------------------
		else if(FRONT_FIFO_DEPTH==1024) begin
			frame_buf_front_fifo_w69d1024_pe512 frame_buf_front_fifo_w69d1024_pe512_inst (
			.rst			(reset_fifo			),
			.wr_clk			(clk_in				),
			.wr_en			(fifo_wr_en			),
			.full			(fifo_full			),
			.din			(fifo_din			),
			.rd_clk			(clk				),
			.rd_en			(fifo_rd_en			),
			.empty			(fifo_empty			),
			.prog_empty		(fifo_prog_empty	),
			.dout			(fifo_dout			)
			);
		end
		//	-------------------------------------------------------------------------------------
		//	sensor行宽小于等于8192
		//	-------------------------------------------------------------------------------------
		else if(FRONT_FIFO_DEPTH==2048) begin
			frame_buf_front_fifo_w69d2048_pe1024 frame_buf_front_fifo_w69d2048_pe1024_inst (
			.rst			(reset_fifo			),
			.wr_clk			(clk_in				),
			.wr_en			(fifo_wr_en			),
			.full			(fifo_full			),
			.din			(fifo_din			),
			.rd_clk			(clk				),
			.rd_en			(fifo_rd_en			),
			.empty			(fifo_empty			),
			.prog_empty		(fifo_prog_empty	),
			.dout			(fifo_dout			)
			);
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	fifo 复位
	//	1.时钟复位 fval上升沿 停采直到fval上升沿 这三个条件，每一个都能够复位
	//	2.异步fifo的复位信号可以是任意时钟域的，因为在fifo内部还会做同步处理。此处的信号都是clk时钟域的。
	//	-------------------------------------------------------------------------------------
	assign	reset_fifo	= reset | fval_rise | !stream_enable_reg;

	//	-------------------------------------------------------------------------------------
	//	fifo 写使能
	//	clk_in时钟域，在场信号、数据信号有效的时候，且fifo不满的时候，才能写
	//	-------------------------------------------------------------------------------------
	assign	fifo_wr_en	= i_fval & i_dval & !fifo_full;

	//	-------------------------------------------------------------------------------------
	//	fifo 输入数据
	//	1.fifo输入数据共有69bit，高5bit是flag，低64bit是数据
	//	-------------------------------------------------------------------------------------
	assign	fifo_din	= {i_trailer_flag,i_image_flag,i_chunk_flag,i_trailer_flag,i_leader_flag,iv_image_din};

	//  -------------------------------------------------------------------------------------
	//  FIFO 读信号
	//	1.当处在写状态时，如果前级fifo不空，后级fifo不满，开采信号有效，则读信号有效
	//	2.用组合逻辑来做，否则会导致多读出数据
	//  -------------------------------------------------------------------------------------
	assign	fifo_rd_en	= (current_state==S_WR) & !fifo_empty & !i_wr_full & stream_enable_reg;

	//	-------------------------------------------------------------------------------------
	//	帧存前端溢出检测
	//	1.一旦出现前端fifo溢出的情况，就设为1，没有办法复位，除非重新上电
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_in) begin
		if(fifo_wr_en && fifo_full) begin
			front_fifo_overflow <= 1'b1;
		end
	end
	assign o_front_fifo_overflow = front_fifo_overflow;

	//	===============================================================================================
	//	ref ***mcb fifo operation***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	mcb wr fifo 写使能信号与fifo的读使能信号是同一个
	//	-------------------------------------------------------------------------------------
	assign	o_wr_en		= fifo_rd_en;

	//	-------------------------------------------------------------------------------------
	//	没有mask的byte，全部要写入到fifo中
	//	-------------------------------------------------------------------------------------
	assign	ov_wr_mask	= 'b0;

	//	-------------------------------------------------------------------------------------
	//	写指令
	//	1.根据参数定义，可以有2种命令方式
	//	2.3'b010 -> with precharge; 3'b000 -> without precharge
	//	-------------------------------------------------------------------------------------
	assign	ov_wr_cmd_instr	= 3'b000;

	//	-------------------------------------------------------------------------------------
	//	MCB CMD FIFO 写信号
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	当处于 CMD 状态时，如果cmd fifo不满，就可以写入一个新的命令
		//	-------------------------------------------------------------------------------------
		if((current_state==S_CMD && i_wr_cmd_full==1'b0)) begin
			wr_cmd_en	<= 1'b1;
		end
		//	-------------------------------------------------------------------------------------
		//	当处于 FLAG 状态时，如果cmd fifo不满，就可以写入一个新的命令
		//	-------------------------------------------------------------------------------------
		else if(current_state==S_FLAG && i_wr_cmd_full==1'b0) begin
			wr_cmd_en	<= 1'b1;
		end
		else begin
			wr_cmd_en	<= 1'b0;
		end
	end
	assign	o_wr_cmd_en	= wr_cmd_en;

	//  -------------------------------------------------------------------------------------
	//  MCB fifo 写数据
	//	1.前级FIFO输出直接送到MCB的fifo中
	//	2.前级FIFO具有 first word fall through的特点，当不空的时候，第一个数据已经放到端口上了
	//	3.在前级FIFO和MCB WR FIFO之间没有加流水线，目的是减少资源。实际上这里并不会是关键路径，不需要打拍。
	//  -------------------------------------------------------------------------------------
	assign	ov_wr_data	= fifo_dout[DATA_WD-1:0];

	//	-------------------------------------------------------------------------------------
	//	写长度
	//	1.burst_length=word_cnt，当图像有残包的时候，不会将多余的数据写入DDR
	//	2.当停采的时候，写入64个数据，目的是保证所有开停采操作会绝对清空 mcb wr fifo
	//	-------------------------------------------------------------------------------------
	assign	ov_wr_cmd_bl	= (stream_enable_reg==1'b1) ? {{(6-WORD_CNT_WIDTH){1'b0}},word_cnt} : 6'b111111;

	//  -------------------------------------------------------------------------------------
	//	mcb 地址拼接
	//	1.UG388 pg63 对地址分布有详细的描述
	//	2.burst_size 大小不同，最低位固定为0的个数也不同
	//	3.由于 iv_frame_depth 输入端口位宽是16，可以支持的最大缓存深度为2**16-1=65535帧
	//	4.根据当前设定的帧缓存深度，灵活改变存储位置
	//	-------------------------------------------------------------------------------------
	assign	ptr_and_addr_int	= ptr_and_addr(wr_ptr[PTR_WIDTH-1:0],wr_addr[WR_ADDR_WIDTH-1:0],frame_depth_reg[PTR_WIDTH-1:0]);
	assign	ov_wr_cmd_byte_addr	= {{(30-WR_ADDR_WIDTH-MCB_BURST_BYTE_NUM_WIDTH){1'b0}},ptr_and_addr_int[WR_ADDR_WIDTH-1:0],{(MCB_BURST_BYTE_NUM_WIDTH){1'b0}}};

	//	===============================================================================================
	//	ref ***ptr addr cnt***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	写指针逻辑
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	当帧存深度是1帧或者复位信号有效或者使能无效时，写指针复位
		//	-------------------------------------------------------------------------------------
		if(frame_depth_reg==1 || reset==1'b1 || stream_enable_reg==1'b0) begin
			wr_ptr	<= 0;
		end
		else begin
			//	-------------------------------------------------------------------------------------
			//	只有在 PTR 状态和 wr_ptr_change=1的时候，才能改变写指针
			//	-------------------------------------------------------------------------------------
			if(current_state==S_PTR && wr_ptr_change==1'b1) begin
				//	-------------------------------------------------------------------------------------
				//	当正在读的时候，写指针不能进入读指针
				//	-------------------------------------------------------------------------------------
				if(i_reading==1'b1) begin
					//	-------------------------------------------------------------------------------------
					//	当写指针已经达到最大值时
					//	1.如果读模块正在读0号内存，那么写指针要跳过读指针，实现写跨越
					//	2.如果读模块没有在读0号内存，那么写指针写0号地址
					//	-------------------------------------------------------------------------------------
					if(wr_ptr==(frame_depth_reg-1)) begin
						if(iv_rd_ptr==0) begin
							wr_ptr	<= 1;
						end
						else begin
							wr_ptr	<= 0;
						end
					end
					//	-------------------------------------------------------------------------------------
					//	当写指针没有达到最大值，但是读指针到达最大值时
					//	1.如果写指针+1=读指针，那么写指针写0号地址
					//	2.如果写指针+1!=读指针，那么写指针自增
					//	-------------------------------------------------------------------------------------
					else if(iv_rd_ptr==(frame_depth_reg-1)) begin
						if((wr_ptr+1'b1)==iv_rd_ptr) begin
							wr_ptr	<= 0;
						end
						else begin
							wr_ptr	<= wr_ptr + 1'b1;
						end
					end
					//	-------------------------------------------------------------------------------------
					//	其他情况，读写指针都不是最大值
					//	1.如果写指针+1=读指针，那么写指针要跳过读指针，实现写跨越
					//	2.如果写指针+1!=读指针，那么写指针自增
					//	-------------------------------------------------------------------------------------
					else begin
						if((wr_ptr+1'b1)==iv_rd_ptr) begin
							wr_ptr	<= iv_rd_ptr + 1'b1;
						end
						else begin
							wr_ptr	<= wr_ptr + 1'b1;
						end
					end
				end
				//	-------------------------------------------------------------------------------------
				//	当正在读=0时，说明读模块没有占用任何内存，写指针可以任意进入
				//	1.如果写指针达到了最大值，则写0号内存
				//	2.如果写指针没有达到了最大值，则写指针自增
				//	-------------------------------------------------------------------------------------
				else begin
					if(wr_ptr==(frame_depth_reg-1)) begin
						wr_ptr	<= 0;
					end
					else begin
						wr_ptr	<= wr_ptr + 1'b1;
					end
				end
			end
		end
	end
	assign	ov_wr_ptr		= wr_ptr;

	//  -------------------------------------------------------------------------------------
	//  写地址逻辑
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	在idle状态下，地址清零
		//	-------------------------------------------------------------------------------------
		if(current_state==S_IDLE) begin
			wr_addr	<= 'b0;
		end
		//	-------------------------------------------------------------------------------------
		//	在flag状态下，当写命令发出之后，写地址切换为下一个flag的地址
		//	-------------------------------------------------------------------------------------
		else if(current_state==S_FLAG && wr_cmd_en==1'b1) begin
			wr_addr	<= start_addr;
		end
		//	-------------------------------------------------------------------------------------
		//	在其他状态下，当写命令发出之后，写地址自增
		//	-------------------------------------------------------------------------------------
		else if(wr_cmd_en==1'b1) begin
			wr_addr	<= wr_addr + 1'b1;
		end
	end
	assign	ov_wr_addr	= wr_addr;

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
			word_cnt	<= {(WORD_CNT_WIDTH){1'b1}};
		end
		//	-------------------------------------------------------------------------------------
		//	1.在flag状态且写命令有效，计数器复位
		//	2.因为切换flag的时候，有可能此时的word_cnt并没有达到最大值，因此需要手动清零
		//	-------------------------------------------------------------------------------------
		else if(current_state==S_FLAG && wr_cmd_en==1'b1) begin
			word_cnt	<= {(WORD_CNT_WIDTH){1'b1}};
		end
		//	-------------------------------------------------------------------------------------
		//	其他条件下，每读一次前端fifo，word_cnt自增
		//	-------------------------------------------------------------------------------------
		else if(fifo_rd_en==1'b1) begin
			word_cnt	<= word_cnt + 1'b1;
		end
	end


	//	-------------------------------------------------------------------------------------
	//	flag 重命名
	//	-------------------------------------------------------------------------------------
	assign	leader_flag				= fifo_dout[DATA_WD];
	assign	trailer_flag			= fifo_dout[DATA_WD+1];
	assign	chunk_flag				= fifo_dout[DATA_WD+2];
	assign	image_flag				= fifo_dout[DATA_WD+3];
	assign	trailer_final_flag		= fifo_dout[DATA_WD+4];

	//	-------------------------------------------------------------------------------------
	//	active_flag 当前选中的flag
	//	-------------------------------------------------------------------------------------
	assign	active_flag		= fifo_dout[DATA_WD+flag_cnt];

	//	-------------------------------------------------------------------------------------
	//	flag_cnt
	//	当前flag下降沿的时候，计数器自增
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			flag_cnt	<= 'b0;
		end
		else if(active_flag_fall) begin
			flag_cnt	<= flag_cnt + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	start addr 每个flag的起始地址
	//	1.根据flag_cnt 判断当前处于哪一个状态
	//	2.此处可以使用组合逻辑，也可以使用时序逻辑。根据实际布线的情况，如果此处为关键路径，可以改为时序逻辑。
	//	-------------------------------------------------------------------------------------
	//				________
	//	active_flag	       |____________________
	//				       ___
	//	af_fall		_______| |__________________
	//                         ___
	//	wr_cmd		___________| |______________
	//
	//	flag_cnt	|  0     |  1               |
	//
	//	state		|  WR  |C| F |  WR          |
	//
	//	start_addr	|  0     |  1               |
	//
	//	word_cnt	|  0         |  1           |
	//
	//	-------------------------------------------------------------------------------------
	assign	start_addr	=
	(flag_cnt==0) ? LEADER_START_ADDR : (
	(flag_cnt==1) ? TRAILER_START_ADDR : (
	(flag_cnt==2) ? CHUNK_START_ADDR : (
	(flag_cnt==3) ? IMAGE_START_ADDR : (
	(flag_cnt==4) ? TRAILER_FINAL_START_ADDR : (
	LEADER_START_ADDR
	)))));

	//	===============================================================================================
	//	ref ***wr rd communication***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	当状态机处于 PTR 状态的时候，wr_ptr_change设置为1，其他状态都设置为0
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_PTR) begin
			wr_ptr_change	<= 1'b1;
		end
		else begin
			wr_ptr_change	<= 1'b0;
		end
	end
	assign	o_wr_ptr_change	= wr_ptr_change;

	//  -------------------------------------------------------------------------------------
	//  正在写
	//	1.当处于idle状态时，正在写信号清零
	//	2.当处于 PTR 状态且 wr_ptr_change=1的时候，才能变为1，这是要和 wr_ptr 一起改变的原因
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			writing_reg	<= 1'b0;
		end
		else if(current_state==S_PTR && wr_ptr_change==1'b1) begin
			//	-------------------------------------------------------------------------------------
			//	1.在单帧时，如果一帧正在读，则正在写不使能
			//	2.不满足上一个条件，则正在写使能
			//	-------------------------------------------------------------------------------------
			if(frame_depth_reg==1 && i_reading==1'b1) begin
				writing_reg	<= 1'b0;
			end
			else begin
				writing_reg	<= 1'b1;
			end
		end
	end
	assign	o_writing	= writing_reg;

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
			//	1.开采有效 2.校准完成 3.前端fifo处于可编程空的状态 4.允许写
			//	-------------------------------------------------------------------------------------
			if(stream_enable_reg==1'b1 && calib_done_shift[1]==1'b1 && fifo_prog_empty==1'b1) begin
				next_state	= S_PTR;
			end
			else begin
				next_state	= S_IDLE;
			end
			S_PTR	:
			//	-------------------------------------------------------------------------------------
			//	PTR状态持续时间2个CLK，在PTR期间发出wr_ptr_change信号，wr_ptr_change信号的周期是2个时钟周期
			//	当看到 wr_ptr_change=1的时候，可以判断状态跳转
			//	PTR -> IDLE
			//	1.在单帧时，如果一帧正在读，返回IDLE状态
			//	PTR -> WR
			//	1.不满足跳转到IDLE的条件，就跳转到WR状态
			//	-------------------------------------------------------------------------------------
			if(wr_ptr_change==1'b1) begin
				if(frame_depth_reg==1 && i_reading==1'b1) begin
					next_state	= S_IDLE;
				end
				else begin
					next_state	= S_WR;
				end
			end
			else begin
				next_state	= S_PTR;
			end
			S_WR	:
			//	-------------------------------------------------------------------------------------
			//	WR -> IDLE
			//	1.前端fifo空 2.fval=0 3.上一次发出cmd之后，没有从前端fifo中取数据
			//	-------------------------------------------------------------------------------------
			if((fifo_empty==1'b1 && fval_shift[1]==1'b0 && word_cnt==(BURST_SIZE-1)) || (stream_enable_reg==1'b0 && word_cnt==(BURST_SIZE-1))) begin
				next_state	= S_IDLE;
			end
			//	-------------------------------------------------------------------------------------
			//	WR -> CMD
			//	1.从前端fifo中读出的数据量是 BURST_SIZE-2 且 正在读前端fifo 或
			//	2.前端fifo空 且 fval=0 且 从前端fifo中读取了一部分数据 或
			//	3.停采
			//	-------------------------------------------------------------------------------------
			else if((word_cnt==(BURST_SIZE-2) && fifo_rd_en==1'b1) || (fifo_empty==1'b1 && fval_shift[1]==1'b0 && word_cnt!=(BURST_SIZE-1)) || stream_enable_reg==1'b0) begin
				next_state	= S_CMD;
			end
			//	-------------------------------------------------------------------------------------
			//	WR -> FLAG
			//	1.当前flag下降沿
			//	-------------------------------------------------------------------------------------
			else if(active_flag_fall==1'b1) begin
				next_state	= S_FLAG;
			end
			else begin
				next_state	= S_WR;
			end
			S_CMD	:
			//	-------------------------------------------------------------------------------------
			//	CMD -> FLAG
			//	1.当前flag下降沿
			//	-------------------------------------------------------------------------------------
			if(active_flag_fall==1'b1) begin
				next_state	= S_FLAG;
			end
			//	-------------------------------------------------------------------------------------
			//	CMD -> WR
			//	1.当前flag没有下降沿
			//	2.wr cmd fifo没有满
			//	-------------------------------------------------------------------------------------
			else if(i_wr_cmd_full==1'b0) begin
				next_state	= S_WR;
			end
			else begin
				next_state	= S_CMD;
			end
			S_FLAG	:
			//	-------------------------------------------------------------------------------------
			//	进入到FLAG状态，word cnt很可能不是31，因此要手动复位。所以要保证写信号和cmd信号不能同时有效
			//	FLAG的宽度至少2个时钟周期，CMD在FLAG的最后一个周期产生，这样 mcb wr fifo en 和 mcb wr cmd 就不会同时生效
			//	-------------------------------------------------------------------------------------
			//	-------------------------------------------------------------------------------------
			//	FLAG -> WR
			//	1.wr cmd en 有效 且 当前不是最后一个flag
			//	-------------------------------------------------------------------------------------
			if(wr_cmd_en==1'b1) begin
				next_state	= S_WR;
			end
			else begin
				next_state	= S_FLAG;
			end
			default	:
			next_state	= S_IDLE;
		endcase
	end


endmodule