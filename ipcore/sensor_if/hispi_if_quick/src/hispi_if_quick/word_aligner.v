//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : word_aligner
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/10/26 16:54:06	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module word_aligner # (
	parameter		SER_FIRST_BIT			= "LSB"		,	//"LSB" or "MSB" , first bit to the receiver
	parameter		DESER_WIDTH				= 6				//解串因子
	)
	(
	input									clk			,	//输入并行时钟
	input									reset		,	//并行时钟域复位信号
	input	[DESER_WIDTH-1:0]				iv_data		,	//输入并行数据
	output									o_clk_en	,	//时钟使能信号
	output									o_sync		,	//控制数据标识
	output	[2*DESER_WIDTH-1:0]				ov_data			//已经对齐后的数据
	);

	//	ref signals
	localparam	SYNC_WORD	= {{4*DESER_WIDTH{1'b0}},{2*DESER_WIDTH{1'b1}}};

	reg		[6*DESER_WIDTH-1:0]				din_shift		= {(3*DESER_WIDTH){2'b10}};
	wire	[6*DESER_WIDTH-1:0]				window_0		;
	wire	[6*DESER_WIDTH-1:0]				window_1		;
	wire	[6*DESER_WIDTH-1:0]				window_2		;
	wire	[6*DESER_WIDTH-1:0]				window_3		;
	wire	[6*DESER_WIDTH-1:0]				window_4		;
	wire	[6*DESER_WIDTH-1:0]				window_5		;
	reg										div_cnt			= 1'b0;
	reg										div_cnt_lock	= 1'b0;
	reg										sync_reg		= 1'b0;
	reg										sync_reg_dly0	= 1'b0;
	reg										sync_reg_dly1	= 1'b0;
	reg		[2:0]							window_num		= 3'b0;
	reg		[2*DESER_WIDTH-1:0]				word_align_reg	= {(2*DESER_WIDTH){1'b1}};

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	时钟分频计数器，用于产生时钟使能信号
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			div_cnt	<= 1'b0;
		end
		else begin
			div_cnt	<= div_cnt + 1'b1;
		end
	end
	assign	o_clk_en	= div_cnt;

	//	-------------------------------------------------------------------------------------
	//	24bit移位寄存器
	//	--缓存2个word数据
	//	--串行数据是lsb的方式，首先进来的数据是低低字节，移位寄存器要从左往右移动
	//	--最好加上复位信号，多个通道之间，在同一时刻开始移位。复位信号要是clk时钟域的同步信号
	//	--复位之后是全1
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			din_shift	<= {(3*DESER_WIDTH){2'b10}};
		end
		else begin
			din_shift	<= {iv_data,din_shift[6*DESER_WIDTH-1:DESER_WIDTH]};
		end
	end

	//	-------------------------------------------------------------------------------------
	//	字节边界窗口
	//	--解串模块每次输出6bit数据，因此只有6个窗口
	//	--使能信号 高 低 期间，各有6个窗口，因此共有12个窗口
	//	-------------------------------------------------------------------------------------
	assign	window_0	= {iv_data[DESER_WIDTH-1:0],din_shift[6*DESER_WIDTH-1:DESER_WIDTH]};
	assign	window_1	= {iv_data[DESER_WIDTH-2:0],din_shift[6*DESER_WIDTH-1:DESER_WIDTH-1]};
	assign	window_2	= {iv_data[DESER_WIDTH-3:0],din_shift[6*DESER_WIDTH-1:DESER_WIDTH-2]};
	assign	window_3	= {iv_data[DESER_WIDTH-4:0],din_shift[6*DESER_WIDTH-1:DESER_WIDTH-3]};
	assign	window_4	= {iv_data[DESER_WIDTH-5:0],din_shift[6*DESER_WIDTH-1:DESER_WIDTH-4]};
	assign	window_5	= {iv_data[DESER_WIDTH-6:0],din_shift[6*DESER_WIDTH-1:DESER_WIDTH-5]};

	//	-------------------------------------------------------------------------------------
	//	判断同步字
	//	--只要有一个窗口与同步字一样，说明这个窗口就是最佳字边界
	//	--保存该窗口编号和当前的en状态
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			window_num		<= 3'd0;
			div_cnt_lock	<= 1'b0;
		end
		else begin
			if(window_0==SYNC_WORD) begin
				window_num		<= 3'd0;
				div_cnt_lock	<= div_cnt;
			end
			else if(window_1==SYNC_WORD) begin
				window_num		<= 3'd1;
				div_cnt_lock	<= div_cnt;
			end
			else if(window_2==SYNC_WORD) begin
				window_num		<= 3'd2;
				div_cnt_lock	<= div_cnt;
			end
			else if(window_3==SYNC_WORD) begin
				window_num		<= 3'd3;
				div_cnt_lock	<= div_cnt;
			end
			else if(window_4==SYNC_WORD) begin
				window_num		<= 3'd4;
				div_cnt_lock	<= div_cnt;
			end
			else if(window_5==SYNC_WORD) begin
				window_num		<= 3'd5;
				div_cnt_lock	<= div_cnt;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	同步字之后是控制字
	//	--解析了同步字之后，可以顺便把控制字的位置也固定了
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(window_0==SYNC_WORD) begin
			sync_reg		<= 1'b1;
		end
		else if(window_1==SYNC_WORD) begin
			sync_reg		<= 1'b1;
		end
		else if(window_2==SYNC_WORD) begin
			sync_reg		<= 1'b1;
		end
		else if(window_3==SYNC_WORD) begin
			sync_reg		<= 1'b1;
		end
		else if(window_4==SYNC_WORD) begin
			sync_reg		<= 1'b1;
		end
		else if(window_5==SYNC_WORD) begin
			sync_reg		<= 1'b1;
		end
		else if(div_cnt==div_cnt_lock) begin
			sync_reg		<= 1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	延时2拍之后，控制字的位置和输出对齐
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(div_cnt==div_cnt_lock) begin
			sync_reg_dly0	<= sync_reg;
			sync_reg_dly1	<= sync_reg_dly0;
		end
	end
	assign o_sync	= sync_reg_dly1;

	//	-------------------------------------------------------------------------------------
	//	输出数据
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(div_cnt==div_cnt_lock) begin
			case(window_num)
				0		: word_align_reg	<= window_0[4*DESER_WIDTH-1:2*DESER_WIDTH];
				1		: word_align_reg	<= window_1[4*DESER_WIDTH-1:2*DESER_WIDTH];
				2		: word_align_reg	<= window_2[4*DESER_WIDTH-1:2*DESER_WIDTH];
				3		: word_align_reg	<= window_3[4*DESER_WIDTH-1:2*DESER_WIDTH];
				4		: word_align_reg	<= window_4[4*DESER_WIDTH-1:2*DESER_WIDTH];
				5		: word_align_reg	<= window_5[4*DESER_WIDTH-1:2*DESER_WIDTH];
				default	: word_align_reg	<= window_0[4*DESER_WIDTH-1:2*DESER_WIDTH];
			endcase
		end
	end
	assign	ov_data	= word_align_reg;

endmodule
