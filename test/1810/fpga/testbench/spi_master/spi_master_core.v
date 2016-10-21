//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : spi_master_core
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/10/29 15:19:11	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : 只支持mode0模式，cpol=0 cpha=0
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module spi_master_core # (
	parameter	SPI_FIRST_DATA	= "MSB"	,	//"MSB" or "LSB"
	parameter	SPI_CS_POL		= "LOW"	,	//"HIGH" or "LOW" ，cs有效时的电平
	parameter	SPI_LEAD_TIME	= 1		,	//开始时，CS 与 CLK 的距离，单位是时钟周期，可选 1 2 3
	parameter	SPI_LAG_TIME	= 1			//结束时，CS 与 CLK 的距离，单位是时钟周期，可选 1 2 3
	)
	(
	//时钟和复位
	input			clk					,	//模块工作时钟
	//spi接口信号 4 wire
	output			o_spi_clk			,	//spi 时钟
	output			o_spi_cs			,	//spi 片选，低有效
	output			o_spi_mosi			,	//主输出，从输入
	input			i_spi_miso			,	//主输入，从输出
	//命令fifo 接口
	output			o_cmd_fifo_rd		,	//cmd fifo 读使能
	input	[8:0]	iv_cmd_fifo_dout	,	//cmd fifo 数据输出，bit8 表示是第一个字节
	input			i_cmd_fifo_empty	,	//cmd fifo 空信号
	//读数据fifo 接口
	output			o_rdback_fifo_wr	,	//rdback fifo 写使能
	output	[7:0]	ov_rdback_fifo_din		//rdback fifo 写数据
	);

	//	ref signals
	//FSM Parameter Define
	parameter	S_IDLE		= 3'd0;
	parameter	S_CHK_BIT	= 3'd1;
	parameter	S_LEAD_DLY	= 3'd2;
	parameter	S_SHIFT		= 3'd3;
	parameter	S_LAG_DLY	= 3'd4;


	reg		[2:0]	current_state	= S_IDLE;
	reg		[2:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	reg		[79:0]			state_ascii;
	always @ ( * ) begin
		case(current_state)
			3'd0 :	state_ascii	= "S_IDLE";
			3'd1 :	state_ascii	= "S_CHK_BIT";
			3'd2 :	state_ascii	= "S_LEAD_DLY";
			3'd3 :	state_ascii	= "S_SHIFT";
			3'd4 :	state_ascii	= "S_LAG_DLY";
		endcase
	end
	// synthesis translate_on


	//	ref ARCHITECTURE
	reg					cmd_fifo_rd	= 1'b0;
	reg		[1:0]		cs_delay_cnt	= 2'b0;
	reg		[2:0]		bit_cnt	= 3'b0;
	reg		[7:0]		mosi_shift_reg	= 8'b0;
	reg					spi_cs_reg	= 1'b1;
	wire				spi_clk_en;
	reg		[8:0]		miso_shift_reg	= 9'b0;
	reg					spi_clk_en_dly	= 1'b0;
	reg					rdback_fifo_wr	= 1'b0;


	//  ===============================================================================================
	//	ref 1 cmd fifo 读操作
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	cmd fifo 的读操作
	//	1.当状态处于 S_CHK_BIT ，读cmd fifo
	//	2.当状态处于 S_SHIFT ，当bit cnt=7 且 cmd fifo非空 且 cmd fifo 数据输出的bit8是0 ，读cmd fifo
	//	3.如果 iv_cmd_fifo_dout[8]==1'b1，说明是下一组操作，要重新开始
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_CHK_BIT) begin
			cmd_fifo_rd	<= 1'b1;
		end
		else if(current_state==S_SHIFT) begin
			if(bit_cnt==3'h7 && i_cmd_fifo_empty==1'b0 && iv_cmd_fifo_dout[8]==1'b0) begin
				cmd_fifo_rd	<= 1'b1;
			end
			else begin
				cmd_fifo_rd	<= 1'b0;
			end
		end
		else begin
			cmd_fifo_rd	<= 1'b0;
		end
	end
	assign	o_cmd_fifo_rd	= cmd_fifo_rd;

	//  ===============================================================================================
	//	ref 2 spi wr 流程
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	cs 延时计数器
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_LEAD_DLY) begin
			if(cs_delay_cnt==SPI_LEAD_TIME) begin
				cs_delay_cnt	<= 2'b0;
			end
			else begin
				cs_delay_cnt	<= cs_delay_cnt + 1'b1;
			end
		end
		else if(current_state==S_LAG_DLY) begin
			if(cs_delay_cnt==SPI_LAG_TIME) begin
				cs_delay_cnt	<= 2'b0;
			end
			else begin
				cs_delay_cnt	<= cs_delay_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	bit 计数器
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_SHIFT) begin
			bit_cnt	<= bit_cnt + 1'b1;
		end
		else begin
			bit_cnt	<= 'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	mosi移位寄存器
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_SHIFT) begin
			if(bit_cnt==3'h7) begin
				mosi_shift_reg	<= iv_cmd_fifo_dout[7:0];
			end
			else begin
				mosi_shift_reg	<= {mosi_shift_reg[6:0],mosi_shift_reg[7]};
			end
		end
		else if(current_state==S_CHK_BIT) begin
			mosi_shift_reg	<= iv_cmd_fifo_dout[7:0];
		end
	end

	assign	o_spi_mosi	= (current_state==S_SHIFT) ? mosi_shift_reg[7] : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	cs 逻辑
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(current_state)
			S_LEAD_DLY,S_SHIFT,S_LAG_DLY : begin
				spi_cs_reg	<= 1'b0;
			end
			default : begin
				spi_cs_reg	<= 1'b1;
			end
		endcase
	end
	assign	o_spi_cs	= spi_cs_reg;

	//  -------------------------------------------------------------------------------------
	//	时钟
	//  -------------------------------------------------------------------------------------
	assign	spi_clk_en	= (current_state==S_SHIFT) ? 1'b1 : 1'b0;
	ODDR2 # (
	.DDR_ALIGNMENT	("C0"			),	// Sets output alignment to "NONE", "C0" or "C1"
	.INIT			(1'b0			),  // Sets initial state of the Q output to 1'b0 or 1'b1
	.SRTYPE			("ASYNC"		)	// Specifies "SYNC" or "ASYNC" set/reset
	)
	ODDR2_spi_clk_inst (
	.Q				(o_spi_clk		),
	.C0				(!clk			),
	.C1				(clk			),
	.CE				(spi_clk_en		),
	.D0				(1'b1			),
	.D1				(1'b0			),
	.R				(1'b0			),
	.S				(1'b0			)
	);

	//  ===============================================================================================
	//	ref 3 spi 状态机
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	状态机
	//  -------------------------------------------------------------------------------------
	//FSM Sequential Logic
	always @ (posedge clk) begin
		current_state	<= next_state;
	end

	//FSM Conbinatial Logic
	always @ ( * ) begin
		case(current_state)
			//  -------------------------------------------------------------------------------------
			//	当命令fifo不空的时候，进入读fifo状态
			//  -------------------------------------------------------------------------------------
			S_IDLE :
			if(!i_cmd_fifo_empty) begin
				next_state	= S_CHK_BIT;
			end
			else begin
				next_state	= S_IDLE;
			end
			//  -------------------------------------------------------------------------------------
			//	1.如果最高bit是1，说明是第一个数据，进入后面的状态
			//	2.如果最高bit是0，说明不是第一个数据，回到idle
			//  -------------------------------------------------------------------------------------
			S_CHK_BIT :
			if(iv_cmd_fifo_dout[8]==1'b1) begin
				next_state	= S_LEAD_DLY;
			end
			else begin
				next_state	= S_IDLE;
			end
			//  -------------------------------------------------------------------------------------
			//	当延时时间到了的时候，进入下一个状态
			//  -------------------------------------------------------------------------------------
			S_LEAD_DLY :
			if(cs_delay_cnt==SPI_LEAD_TIME) begin
				next_state	= S_SHIFT;
			end
			else begin
				next_state	= S_LEAD_DLY;
			end
			//  -------------------------------------------------------------------------------------
			//	1.移位到最后一个bit，如果此时fifo空了，认为一次操作结束，进入 S_LAG_DLY 状态
			//	2.移位到最后一个bit，如果此时fifo不空，但是数据bit8=1，进入 S_LAG_DLY 状态
			//	3.其他情况，停在shift状态
			//  -------------------------------------------------------------------------------------
			S_SHIFT :
			if(bit_cnt==3'h7) begin
				if(i_cmd_fifo_empty==1'b1) begin
					next_state	= S_LAG_DLY;
				end
				else if(iv_cmd_fifo_dout[8]==1'b1) begin
					next_state	= S_LAG_DLY;
				end
				else begin
					next_state	= S_SHIFT;
				end
			end
			else begin
				next_state	= S_SHIFT;
			end
			//  -------------------------------------------------------------------------------------
			//	尾部延时结束之后，进入idle状态
			//  -------------------------------------------------------------------------------------
			S_LAG_DLY :
			if(cs_delay_cnt==SPI_LAG_TIME) begin
				next_state	= S_IDLE;
			end
			else begin
				next_state	= S_LAG_DLY;
			end
			default :
			next_state	= S_IDLE;
		endcase
	end

	//  ===============================================================================================
	//	ref 4 spi rd 流程
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	使用iddr2接收数据，在clk下降沿接收数据，在clk上升沿将数据打出来
	//  -------------------------------------------------------------------------------------
	IDDR2 # (
	.DDR_ALIGNMENT	("C1"	),	// Sets output alignment to "NONE", "C0" or "C1"
	.INIT_Q0		(1'b0	),	// Sets initial state of the Q0 output to 1'b0 or 1'b1
	.INIT_Q1		(1'b0	),	// Sets initial state of the Q1 output to 1'b0 or 1'b1
	.SRTYPE			("SYNC"	)	// Specifies "SYNC" or "ASYNC" set/reset
	)
	IDDR2_miso_inst (
	.Q0				(miso_iddr2	),	// 1-bit output captured with C0 clock
	.Q1				(			),	// 1-bit output captured with C1 clock
	.C0				(!clk		),	// 1-bit clock input
	.C1				(clk		),	// 1-bit clock input
	.CE				(1'b1		),	// 1-bit clock enable input
	.D				(i_spi_miso	),	// 1-bit DDR data input
	.R				(1'b0		),	// 1-bit reset input
	.S				(1'b0		)	// 1-bit set input
	);

	//  -------------------------------------------------------------------------------------
	//	miso 移位输入
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		spi_clk_en_dly	<= spi_clk_en;
	end

	always @ (posedge clk) begin
		if(spi_clk_en_dly) begin
			miso_shift_reg[7:0]	<= {miso_shift_reg[6:0],miso_iddr2};
		end
		else begin
			miso_shift_reg[7:0]	<= 8'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	miso_shift_reg bit8 表示spi 移位的第一个byte
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!spi_clk_en_dly) begin
			miso_shift_reg[8]	<= 1'b1;
		end
		else begin
			if(rdback_fifo_wr) begin
				miso_shift_reg[8]	<= 1'b0;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	rdback fifo 写操作
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(spi_clk_en_dly==1'b1 && bit_cnt==3'h0) begin
			rdback_fifo_wr	<= 1'b1;
		end
		else begin
			rdback_fifo_wr	<= 1'b0;
		end
	end
	assign	o_rdback_fifo_wr	= rdback_fifo_wr;
	assign	ov_rdback_fifo_din	= miso_shift_reg;



endmodule
