//-------------------------------------------------------------------------------------------------
//  -- Corporation  : MicroRTL.com
//  -- Email        : haitaox2013@gmail.com
//  -- Module       :
//-------------------------------------------------------------------------------------------------
//  -- Description  : 同步fifo，位宽8，深度16，存储器由SRL16E(LUT)组成.灵感来源于picoblaze uart bb_fifo
//					1.当fifo空时，如果读写同时有效。相当于写进了一个数据，但是读不起作用，fifo变为非空-与bb_fifo相同
//					2.当fifo满时，如果读写同时有效。相当于读走了一个数据，但是写不起作用，fifo变为非满-与bb_fifo不同，bb_fifo的满信号还是有效。即写也起作用了。
//-------------------------------------------------------------------------------------------------
//  -- Changelog    :
//  -- Author       | Date                  | Content
//  -- Michael      | 2014/12/6 16:21:34	|
//-------------------------------------------------------------------------------------------------
//`include			"_def.v"
//time unit/precision
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module sync_fifo_srl_w8d16 (
	input				reset		,	//复位信号，高有效
	input				clk			,	//时钟信号
	input	[7:0]		iv_din		,	//8bit输入信号
	input				i_wr		,	//写信号，高有效
	output				o_full		,	//满信号，高有效
	output				o_half_full	,	//半满信号，高有效
	input				i_rd		,	//读信号，高有效
	output	[7:0]		ov_dout		,	//8bit输出数据
	output				o_empty			//空信号，高有效
	);

	//	ref signals
	wire				valid_wr	;
	reg		[3:0]		pointer		= 4'b0000;
	wire				full_int	;
	wire				pointer_zero	;
	wire				half_full_int	;

	wire	[7:0]		store_data		;
	reg					empty_reg		= 1'b0;

	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	存储器
	//	SRL16是一个不带复位的移位寄存器，A3-A0选择输出的bit
	//  -------------------------------------------------------------------------------------
	genvar i;
	generate
		for (i = 0 ; i <= 7 ; i = i+1) begin : data_width_loop
			SRL16E # (
			.INIT   (16'h0000)
			)
			storage_srl (
			.D  	(iv_din[i]		),
			.CE 	(valid_wr		),
			.CLK	(clk			),
			.A0 	(pointer[0]		),
			.A1 	(pointer[1]		),
			.A2 	(pointer[2]		),
			.A3 	(pointer[3]		),
			.Q  	(store_data[i]	)
			);
		end //generate data_width_loop;
	endgenerate

	//  -------------------------------------------------------------------------------------
	//	valid_wr
	//  -------------------------------------------------------------------------------------
	//当存储器满时，写的状态与读的状态有关
	//如果读写同时有效，可以写入新数据
	//如果读无效，则不允许写入新数据
	//当存储器不满时，写信号有效
	assign	valid_wr	= (full_int) ? (((i_wr==1'b1)&&(i_rd==1'b1)) ? 1'b1 : 1'b0) : i_wr	;

	//  -------------------------------------------------------------------------------------
	//	pointer
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			pointer	<= 'b0;
		end
		else begin
			//当不空不满时，只写不读，计数器++
			//当不空不满时，只读不写，计数器--
			if((empty_reg==1'b0)&&(full_int==1'b0)) begin
				if((i_wr==1'b1)&&(i_rd==1'b0)) begin
					pointer	<= pointer + 1'b1;
				end
				else if((i_wr==1'b0)&&(i_rd==1'b1)) begin
					if(pointer_zero==1'b1) begin
						pointer	<= pointer;
					end
					else begin
						pointer	<= pointer - 1'b1;
					end
				end
			end

			//当计数器满的时候，只允许读，不允许写
			else if(full_int==1'b1) begin
				if(i_rd==1'b1) begin
					pointer	<= pointer - 1'b1;
				end
			end

			//			//当计数器空的时候，只允许写，不允许读.但是指针不变.这一段不用写出来
			//			else if(empty_reg==1'b1) begin
			//				if(i_wr==1'b1) begin
			//					pointer	<= pointer;
			//				end
			//			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	empty_reg
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			empty_reg	<= 1'b1;
		end
		else begin
			if((pointer_zero==1'b1)&&(i_wr==1'b1)) begin
				empty_reg	<= 1'b0;
			end
			else if((pointer_zero==1'b1)&&(i_rd==1'b1)) begin
				empty_reg	<= 1'b1;
			end
		end
	end
	assign	pointer_zero	= (pointer==4'b0000) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	满信号
	//  -------------------------------------------------------------------------------------
	assign	full_int		= (pointer==4'b1111) ? 1'b1 : 1'b0;
	assign	half_full_int	= pointer[3];

	//  -------------------------------------------------------------------------------------
	//	输出
	//  -------------------------------------------------------------------------------------
	assign	o_full			= full_int;
	assign	o_empty			= empty_reg;
	assign	o_half_full		= half_full_int;
	assign	ov_dout			= store_data;


endmodule
