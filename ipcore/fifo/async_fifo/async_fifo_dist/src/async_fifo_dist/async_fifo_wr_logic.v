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


module async_fifo_wr_logic # (
	parameter						ADDR_WIDTH			= 8	//最高位地址用于判断空满标志，不用于fifo地址，因此 6-深度32 7-深度64
	)
	(
	input							clk					,	//时钟
	input							reset				,	//同步复位
	input							i_wr_en				,	//写使能
	input	[ADDR_WIDTH-1:0]		iv_rd_addr_bin		,	//读地址的2进制码，本地时钟域
	output	[ADDR_WIDTH-1:0]		ov_wr_addr_bin		,	//写地址的2进制码，给格雷码模块
	output	[ADDR_WIDTH-2:0]		ov_wr_addr_dpram	,	//写地址的2进制码，给dpram模块
	output							o_wr_en				,	//dpram写使能
	output							o_fifo_full				//fifo满标志
	);

	//ref signals
	wire							valid_wr			;
	reg								fifo_full_reg		= 1'b1;
	reg		[ADDR_WIDTH-1:0]		wr_addr_cnt			= 1;
	reg		[ADDR_WIDTH-1:0]		wr_addr_cnt_next1	= 2;
	reg		[ADDR_WIDTH-1:0]		wr_addr_cnt_next2	= 3;
	wire							full_equation		;


	//ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	写有效
	//	1.当不满且写使能有效时，写信号有效
	//	-------------------------------------------------------------------------------------
	assign	valid_wr	= (i_wr_en==1'b1 && fifo_full_reg==1'b0) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	满信号
	//	1.当读写地址的最高位不等，且低位相等时，满
	//	2.当写有效 且 写地址+1之后，读写地址的最高位不等，低位相等时，满
	//	-------------------------------------------------------------------------------------
	assign	full_equation	= (wr_addr_cnt_next1[ADDR_WIDTH-1]!=iv_rd_addr_bin[ADDR_WIDTH-1] && wr_addr_cnt_next1[ADDR_WIDTH-2:0]==iv_rd_addr_bin[ADDR_WIDTH-2:0]) ? 1'b1 :
	(valid_wr==1'b1 && wr_addr_cnt_next2[ADDR_WIDTH-1]!=iv_rd_addr_bin[ADDR_WIDTH-1] && wr_addr_cnt_next2[ADDR_WIDTH-2:0]==iv_rd_addr_bin[ADDR_WIDTH-2:0]) ? 1'b1 :
	1'b0;

	always @ (posedge clk) begin
		if(reset) begin
			fifo_full_reg	<= 1'b1;
		end
		else begin
			fifo_full_reg	<= full_equation;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	写地址计数器
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			wr_addr_cnt			<= 1;
			wr_addr_cnt_next1	<= 2;
			wr_addr_cnt_next2	<= 3;
		end
		else begin
			if(valid_wr) begin
				wr_addr_cnt			<= wr_addr_cnt + 1;
				wr_addr_cnt_next1	<= wr_addr_cnt + 2;
				wr_addr_cnt_next2	<= wr_addr_cnt + 3;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	输出
	//  -------------------------------------------------------------------------------------
	assign	o_fifo_full 		= fifo_full_reg;
	assign	ov_wr_addr_bin 		= wr_addr_cnt;
	assign	ov_wr_addr_dpram	= wr_addr_cnt[ADDR_WIDTH-1:0];
	assign	o_wr_en 			= valid_wr;

endmodule
