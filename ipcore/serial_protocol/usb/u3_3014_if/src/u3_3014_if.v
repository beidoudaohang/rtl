//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : u3_3014_if
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/4/9 11:00:36	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : U3芯片 cy3014 接口模块。与u3v协议想结合。
//              1)  : 分 leader payload trailer 三大块传输。每一块成为一个 sector
//
//              2)  : 当一个sector结束时，最后一个数据要跟随 pktend
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module u3_3014_if # (
	parameter				DATA_WIDTH			= 32		,	//GPIF数据宽度，目前固定为32
	parameter				REG_WIDTH			= 32		,	//寄存器位宽
	parameter				FRAME_SIZE_WIDTH	= 22		,	//一帧大小位宽，单位是DATA_WIDTH，当DATA_WIDTH=32时。FRAME_SIZE_WIDTH=22 -> 16Mbyte.23 -> 32Mbyte.24 -> 64Mbyte.
	parameter				DMA_SIZE			= 14'h1000		//DMA SIZE大小.DATA_WIDTH*DMA_SIZE=3014 DMA SIZE
	)
	(
	//	-------------------------------------------------------------------------------------
	//  时钟复位信号
	//	-------------------------------------------------------------------------------------
	input								clk					,	//时钟
	input								reset				,	//复位
	//	-------------------------------------------------------------------------------------
	//  与前端数据接口
	//	-------------------------------------------------------------------------------------
	input	[DATA_WIDTH:0]				iv_data				,	//帧存读出的数据，最高bit为控制位
	input								i_buf_empty			,	//FIFO空标志，高电平有效
	output								o_buf_rd			,	//FIFO读信号，高电平有效
	//	-------------------------------------------------------------------------------------
	//	控制部分
	//	-------------------------------------------------------------------------------------
	input								i_stream_enable		,	//流使能信号，高有效
	input	[REG_WIDTH-1:0]				iv_payload_size		,	//paylod大小,字节为单位
	input								i_chunk_mode_active	,	//chunk总开关，chunk开关影响leader和trailer的大小，通过判断chunk开关可以知道leader和trailer长度
	input	[REG_WIDTH-1:0]				iv_transfer_count	,	//等量数据块个数
	input	[REG_WIDTH-1:0]				iv_transfer_size	,	//等量数据块大小
	input	[REG_WIDTH-1:0]				iv_transfer1_size	,	//transfer1大小
	input	[REG_WIDTH-1:0]				iv_transfer2_size	,	//transfer2大小
	//	-------------------------------------------------------------------------------------
	//	GPIF接口信号
	//	-------------------------------------------------------------------------------------
	input								i_usb_flagb_n		,	//异步时钟域，USB满信号，低有效。延时3个时钟有效，切换DMA地址后标志指示当前DMA状态。如果当前DMA中没有数据FLAGB会拉高，如果PC阻塞，当前FIFO还没有读出，该标志可能长时间拉低
	output	[1:0]						ov_usb_addr			,	//GPIF 线程地址 2bit，地址切换顺序要和固件保持一致，目前约定为2'b00,2'b11切换
	output								o_usb_slwr_n		,	//GPIF 写信号，低有效
	output	[DATA_WIDTH-1:0]			ov_usb_data			,	//GPIF 数据信号
	output								o_usb_pktend_n			//GPIF 包结束信号，低有效。pktend与slwr同时有效，表示包结束。
	);

	//	ref signals
	//FSM Parameter Define
	parameter	S_IDLE			= 3'd0;
	parameter	S_CHK_HEADER	= 3'd1;
	parameter	S_DMA_SENDING	= 3'd2;
	parameter	S_CHK_FLAG		= 3'd3;
	parameter	S_SECTOR_OVER	= 3'd4;
	parameter	S_ADD_PKTEND	= 3'd5;

	reg		[2:0]	current_state	= S_IDLE;
	reg		[2:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	reg		[127:0]			state_ascii;
	always @ ( * ) begin
		case(current_state)
			3'd0 :	state_ascii	<= "S_IDLE";
			3'd1 :	state_ascii	<= "S_CHK_HEADER";
			3'd2 :	state_ascii	<= "S_DMA_SENDING";
			3'd3 :	state_ascii	<= "S_CHK_FLAG";
			3'd4 :	state_ascii	<= "S_SECTOR_OVER";
			3'd5 :	state_ascii	<= "S_ADD_PKTEND";
		endcase
	end
	// synthesis translate_on

	reg		[2:0]						flagb_shift		= 3'b000;
	wire								flagb_rise		;
	wire								flagb_fall		;
	reg		[2:0]						se_shift		= 3'b0;
	
	wire								mult_en				;
	wire	[47:0]						wv_pc_buffer_size	;
	reg									urb_is_larger		= 1'b0;
	wire	[FRAME_SIZE_WIDTH-1:0]		require_size	;

	wire								buf_rd_header	;
	wire								buf_rd_dma		;
	wire								buf_rd_pktend	;

	reg		[13:0]						dma_cnt			= 14'b0;
	reg		[REG_WIDTH-3:0]				sector_size_cnt	= {(REG_WIDTH-2){1'b0}};
	reg		[REG_WIDTH-1:0]				sector_size_reg	= {REG_WIDTH{1'b0}};
	reg		[1:0]						sector_cnt		= 2'b0;

	wire								gpif_wr_n			;
	wire								gpif_pktend_n		;
	wire	[DATA_WIDTH-1:0]			gpif_data			;
	reg		[1:0]						gpif_addr			= 2'b0;
	reg									gpif_wr_n_reg		= 1'b1;
	reg									gpif_pktend_n_reg	= 1'b1;
	reg		[DATA_WIDTH-1:0]			gpif_data_reg		= {DATA_WIDTH{1'b0}};
	reg		[1:0]						gpif_addr_reg		= 2'b0;

	//	ref ARCHITECTURE



	//	===============================================================================================
	//	ref ***延时 取边沿***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	flagb 延时
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		flagb_shift	<= {flagb_shift[1:0],i_usb_flagb_n};
	end
	assign	flagb_rise	= (flagb_shift[2:1]==2'b01) ? 1'b1 : 1'b0;
	assign	flagb_fall	= (flagb_shift[2:1]==2'b10) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	i_stream_enable 延时
	//	1.开采之后，frame buffer后端会复位，等待后端fifo处于复位之中，再启动
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		se_shift	<= {se_shift[1:0],i_stream_enable};
	end

	//	===============================================================================================
	//	ref ***判断urb与payload_size***
	//  计算PC URB大小，iv_transfer_size*iv_transfer_count
	//  寄存器位宽有所调整，我们支持的图像大小不超过16MB,所以require_size_cnt 24bits足够
	//  乘法器只允许在停采期间计算，开始采集后，需保持不变，所以使用reset取反做时钟使能，流水线延时5clk
	//  计算PC URB大小主要是用来判断是否添加短包
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  例化乘法器
	//  -------------------------------------------------------------------------------------
	urb_mult_a32b16 urb_mult_a32b16_inst(
	.clk	(clk						),
	.ce		(mult_en					),
	.a		(iv_transfer_size			),
	.b		(iv_transfer_count[15:0]	),
	.p		(wv_pc_buffer_size			)
	);
	assign	mult_en  = ~i_stream_enable;

	//	-------------------------------------------------------------------------------------
	//	计算urb与比较
	//	-------------------------------------------------------------------------------------
	assign	require_size = wv_pc_buffer_size[FRAME_SIZE_WIDTH-1:0];
	always @ (posedge clk) begin
		if(reset==1'b1 || i_stream_enable==1'b0) begin
			urb_is_larger	<= 1'b0;
		end
		else begin
			if(require_size>iv_payload_size[FRAME_SIZE_WIDTH-1:0 ]) begin
				urb_is_larger	<= 1'b1;
			end
			else begin
				urb_is_larger	<= 1'b0;
			end
		end
	end

	//	===============================================================================================
	//	ref ***前端FIFO读操作***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	fifo 读
	//	1.在chk header状态，当前端fifo不空、数据最高bit=0时，才能读。
	//	2.在dma sending状态，当前端fifo不空才能读。
	//	3.在sector over状态，当前端fifo不空才能读。
	//	-------------------------------------------------------------------------------------
	assign	buf_rd_header	= (current_state==S_CHK_HEADER && i_buf_empty==1'b0 && iv_data[DATA_WIDTH]==1'b0) ? 1'b1 : 1'b0;
	assign	buf_rd_dma		= (current_state==S_DMA_SENDING && i_buf_empty==1'b0) ? 1'b1 : 1'b0;
	assign	buf_rd_pktend	= (current_state==S_SECTOR_OVER && i_buf_empty==1'b0) ? 1'b1 : 1'b0;

	assign	o_buf_rd		= buf_rd_header | buf_rd_dma | buf_rd_pktend;

	//	===============================================================================================
	//	ref ***GPIF 操作***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	在add pktend状态，要发出包结束信号，同时也要发出写信号
	//	-------------------------------------------------------------------------------------
	assign	gpif_wr_add	= (current_state==S_ADD_PKTEND) ? 1'b1 : 1'b0;
	//	-------------------------------------------------------------------------------------
	//	GPIF wr
	//	1.当读dma数据和写包结束的时候，写信号有效
	//	-------------------------------------------------------------------------------------
	assign	gpif_wr_n	= (buf_rd_dma==1'b1 || buf_rd_pktend==1'b1 || gpif_wr_add==1'b1) ? 1'b0 : 1'b1;
	//	-------------------------------------------------------------------------------------
	//	GPIF pktend
	//	1.只在发送包结束的时候，pktend有效
	//	-------------------------------------------------------------------------------------
	assign	gpif_pktend_n	= (buf_rd_pktend==1'b1 || gpif_wr_add==1'b1) ? 1'b0 : 1'b1;
	//	-------------------------------------------------------------------------------------
	//	GPIF data
	//	1.数据最高位不要
	//	-------------------------------------------------------------------------------------
	assign	gpif_data	= iv_data[DATA_WIDTH-1:0];

	//	-------------------------------------------------------------------------------------
	//	GPIF addr
	//	1.只在流停止的时候，才会复位地址。idle的时候不复位
	//	2.一个dma发完了，或者包结束发完了，就要切换地址。在flagb下降的时候切换地址
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_stream_enable) begin
			gpif_addr	<= 2'b0;
		end
		else if(current_state==S_CHK_FLAG && flagb_fall==1'b1) begin
			gpif_addr	<= ~gpif_addr;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	数据、使能、地址打拍
	//	1.输出信号要放到iob上再打一拍，在本模块外面做这件事
	//	2.此处的打拍是为了缩短数据和iob之间的距离
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		gpif_wr_n_reg		<= gpif_wr_n;
		gpif_pktend_n_reg	<= gpif_pktend_n;
		gpif_data_reg		<= gpif_data;
		gpif_addr_reg		<= gpif_addr;
	end
	assign	o_usb_slwr_n	= gpif_wr_n_reg;
	assign	o_usb_pktend_n	= gpif_pktend_n_reg;
	assign	ov_usb_data		= gpif_data_reg;
	assign	ov_usb_addr		= gpif_addr_reg;

	//	===============================================================================================
	//	ref ***主要计数器***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	dma大小计数器
	//	1.在空闲状态和进入dma sending之前，必须清零
	//	2.在dma sending状态，每读一次，计数器+1
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE || current_state==S_CHK_FLAG) begin
			dma_cnt	<= 14'b0;
		end
		else if(buf_rd_dma==1'b1 || buf_rd_pktend==1'b1) begin
			dma_cnt	<= dma_cnt + 1'b1;
		end
	end

	//	===============================================================================================
	//	ref ***切换sector***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	sector计数器
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			sector_cnt	<= 2'b00;
		end
		else if(current_state==S_SECTOR_OVER && i_buf_empty==1'b0) begin
			sector_cnt	<= sector_cnt + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	sector_size_reg,以字节为单位
	//	1.sector_cnt==2'b00 - leader 状态，52个字节
	//	2.sector_cnt==2'b01 - payload 状态，寄存器数据
	//	3.sector_cnt==2'b10 - trailer 状态，chunk打开-36字节，chunk关闭-32字节
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(sector_cnt==2'b00) begin
			sector_size_reg	<= 52;
		end
		else if(sector_cnt==2'b01) begin
			sector_size_reg	<= iv_payload_size;
		end
		else begin
			if(i_chunk_mode_active) begin
				sector_size_reg	<= 36;
			end
			else begin
				sector_size_reg	<= 32;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	sector大小计数器，以DATA_WIDTH为单位
	//	1.当空闲状态和sector结束状态，计数器清零
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE || current_state==S_SECTOR_OVER) begin
			sector_size_cnt	<= {(REG_WIDTH-2){1'b0}};
		end
		else if(buf_rd_dma) begin
			sector_size_cnt	<= sector_size_cnt + 1'b1;
		end
	end

	//	===============================================================================================
	//	ref ***FSM***
	//	===============================================================================================
	//FSM Sequential Logic
	//	-------------------------------------------------------------------------------------
	//	1.当复位信号=1或者流使能停止，状态机立即返回idle。
	//	2.当流停止时，3014也会复位，因此，状态机可以立即返回
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset==1'b1 || se_shift[2]==1'b0) begin
			current_state	<= S_IDLE;
		end else begin
			current_state	<= next_state;
		end
	end

	//FSM Conbinatial Logic
	always @ ( * ) begin
		case(current_state)
			//	-------------------------------------------------------------------------------------
			//	空闲状态
			//	1.如果流使能打开，前端非空的话，就可以进入下一状态
			//	2.如果不满足，则继续等待
			//	-------------------------------------------------------------------------------------
			S_IDLE	:
			if(se_shift[2]==1'b1 && i_buf_empty==1'b0) begin
				next_state	= S_CHK_HEADER;
			end
			else begin
				next_state	= S_IDLE;
			end
			//	-------------------------------------------------------------------------------------
			//	检查图像头
			//	1.在一帧图像开始的时候，会有图像头和图像尾，要把头尾剥离
			//	2.当最高bit是0且buf不空时，说明数据已经不是头尾了，可以进入下一个状态
			//	3.否则，继续等待
			//	-------------------------------------------------------------------------------------
			S_CHK_HEADER	:
			if(iv_data[DATA_WIDTH]==1'b1 && i_buf_empty==1'b0) begin
				next_state	= S_DMA_SENDING;
			end
			else begin
				next_state	= S_CHK_HEADER;
			end
			//	-------------------------------------------------------------------------------------
			//	DMA发送
			//	1.当发送的数据量与3014的DMA SIZE一致时，检查 flagb 的上升沿
			//	2.当发送的数据量不足3014的DMA SIZE，且满足sector size时，说明sector结束
			//	3.其他，停在DMA_SENDING状态
			//	-------------------------------------------------------------------------------------
			S_DMA_SENDING	:
			if(dma_cnt==DMA_SIZE-1 && buf_rd_dma==1'b1) begin
				next_state	= S_CHK_FLAG;
			end
			else if(sector_size_cnt==(sector_size_reg[REG_WIDTH-1:2]-2) && buf_rd_dma==1'b1) begin
				next_state	= S_SECTOR_OVER;
			end
			else begin
				next_state	= S_DMA_SENDING;
			end
			//	-------------------------------------------------------------------------------------
			//	检查flagb状态
			//	1.当flagb上升沿，说明socket 地址切换成功
			//	--如果sector_cnt==2'b11说明是最后1个sector发送成功，返回idle
			//	--如果不是，返回DMA 发送状态
			//	2.否则，继续等待
			//	-------------------------------------------------------------------------------------
			S_CHK_FLAG	:
			if(flagb_rise) begin
				if(sector_cnt==2'b11) begin
					next_state	= S_IDLE;
				end
				else begin
					next_state	= S_DMA_SENDING;
				end
			end
			else begin
				next_state	= S_CHK_FLAG;
			end
			//	-------------------------------------------------------------------------------------
			//	sector 结束，
			//	1.在本状态会发出一个pktend，因此要检查前端的fifo状态，不空的时候，才可以发数.
			//	2.如果 sector_cnt==2'b01 说明是payload
			//	--2.1如果sector大小是整Kbyte倍数
			//	----如果pc的urb size 大于payload size，说明pc buffer 开的比较大，整Kbyte无法结束，要再发一个短包
			//	----如果pc的urb不大于payload size，则这个sector发送成功，下面返回DMA 发送状态
			//	--2.2如果sector大小不是整Kbyte倍数，则这个sector发送成功，下面返回DMA 发送状态
			//	3.如果是其他sector，发送完包结束信号之后，要判断flagb的状态
			//	-------------------------------------------------------------------------------------
			S_SECTOR_OVER	:
			if(!i_buf_empty) begin
				if(sector_cnt==2'b01) begin
					if(sector_size_reg[9:2]==8'h00) begin
						if(urb_is_larger==1'b1) begin
							next_state	= S_ADD_PKTEND;
						end
						else begin
							next_state	= S_CHK_FLAG;
						end
					end
					else begin
						next_state	= S_CHK_FLAG;
					end
				end
				else begin
					next_state	= S_CHK_FLAG;
				end
			end
			else begin
				next_state	= S_SECTOR_OVER;
			end
			//	-------------------------------------------------------------------------------------
			//	添加的包结束
			//	1.当pc buffer所开的urb大于payload size，且payloadsize是整k倍数时，无法结束pc的buffer，需要再发一个4字节的短包到pc
			//	2.发完短包之后，返回DMA 发送状态，继续发数
			//	-------------------------------------------------------------------------------------
			S_ADD_PKTEND	:
			next_state	= S_CHK_FLAG;
			default	:
			next_state	= S_IDLE;
		endcase
	end


endmodule
