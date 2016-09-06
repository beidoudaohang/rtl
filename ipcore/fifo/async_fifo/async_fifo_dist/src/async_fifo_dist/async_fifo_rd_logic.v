//-------------------------------------------------------------------------------------------------
//  -- Corporation  : MicroRTL.com
//  -- Email        : haitaox2013@gmail.com
//  -- Module       :
//-------------------------------------------------------------------------------------------------
//  -- Description  :
//
//-------------------------------------------------------------------------------------------------
//  -- Changelog    :
//  -- Author       | Date                  | Content
//  -- Michael      | 2016/09/06 10:52:45	|
//-------------------------------------------------------------------------------------------------
//`include			"_def.v"
//time unit/precision
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------


module async_fifo_rd_logic # (
	parameter						ADDR_WIDTH		= 8		//最高位地址用于判断空满标志，不用于fifo地址，因此 6-深度32 7-深度64
	)
	(
	input							clk					,	//时钟
	input							reset				,	//同步复位
	input							i_rd_en				,	//读使能
	input	[ADDR_WIDTH-1:0]		iv_wr_addr_bin		,	//写地址的2进制码，本地时钟域
	output	[ADDR_WIDTH-1:0]		ov_rd_addr_bin		,	//读地址的2进制码，给格雷码模块
	output	[ADDR_WIDTH-2:0]		ov_rd_addr_dpram	,	//读地址的2进制码，给dpram模块
	output							o_rd_en				,	//dpram读使能
	output							o_fifo_empty			//fifo空标志
	);

	//ref signals
	wire							valid_rd			;
	reg								fifo_empty_reg		= 1'b1;
	reg		[ADDR_WIDTH-1:0]		rd_addr_cnt			= 'b0;
	reg		[ADDR_WIDTH-1:0]		rd_addr_cnt_next1	= 1;
	reg		[ADDR_WIDTH-1:0]		rd_addr_cnt_next2	= 2;
	wire							empty_equation		;




	//ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	读有效
	//	当不空且读使能有效时，读信号有效
	//	-------------------------------------------------------------------------------------
	assign	valid_rd	= (i_rd_en==1'b1 && fifo_empty_reg==1'b0) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	空信号
	//	1.当前是空的状态时，当下一个读地址==写地址相等，空
	//	2.当前是非空的状态时，当读有效 且 下一个读地址==写地址相等，空
	//	-------------------------------------------------------------------------------------
	assign	empty_equation	=
	(fifo_empty_reg==1'b1 && rd_addr_cnt_next1==iv_wr_addr_bin) ? 1'b1 :
	(fifo_empty_reg==1'b0 && valid_rd==1'b1 && rd_addr_cnt_next1==iv_wr_addr_bin) ? 1'b1 :
	1'b0;

	always @ (posedge clk) begin
		if(reset) begin
			fifo_empty_reg	<= 1'b1;
		end
		else begin
			fifo_empty_reg	<= empty_equation;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	读地址计数器
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			rd_addr_cnt			<= 0;
			rd_addr_cnt_next1	<= 1;
		end
		else begin
			if(fifo_empty_reg) begin
				if(rd_addr_cnt_next1!=iv_wr_addr_bin) begin
					rd_addr_cnt			<= rd_addr_cnt + 1;
					rd_addr_cnt_next1	<= rd_addr_cnt + 2;
				end
			end
			else begin
				if(valid_rd) begin
					if(rd_addr_cnt_next1==iv_wr_addr_bin) begin
						rd_addr_cnt			<= rd_addr_cnt;
						rd_addr_cnt_next1	<= rd_addr_cnt_next1;
					end
					else begin
						rd_addr_cnt			<= rd_addr_cnt + 1;
						rd_addr_cnt_next1	<= rd_addr_cnt + 2;
					end
				end
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	输出
	//  -------------------------------------------------------------------------------------
	assign	o_fifo_empty 		= fifo_empty_reg;
	assign	ov_rd_addr_bin		= rd_addr_cnt;
	assign	ov_rd_addr_dpram	= rd_addr_cnt[ADDR_WIDTH-1:0];
	assign	o_rd_en 			= valid_rd;

endmodule
