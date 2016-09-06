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

module dpram_dist # (
	parameter		FIFO_WIDTH			= 8		,	//fifo 数据宽度
	parameter		ADDR_WIDTH			= 6		,	//最高位地址用于判断空满标志，不用于fifo地址，因此 6-深度32 7-深度64
	parameter		MAX_ADDR_WIDTH		= 8			//fifo 数据最大宽度
	)
	(
	//写时钟域
	input							clk_wr		,	//写时钟
	input							i_wr		,	//写使能
	input	[ADDR_WIDTH-2:0]		iv_wr_addr	,	//写地址
	input	[FIFO_WIDTH-1:0]		iv_din		,	//写数据
	//读时钟域
	input							clk_rd		,	//读时钟
	input	[ADDR_WIDTH-2:0]		iv_rd_addr	,	//读地址
	output	[FIFO_WIDTH-1:0]		ov_dout			//读数据
	);

	//	ref signals
	wire	[FIFO_WIDTH-1:0]		wv_dout		;
	reg		[FIFO_WIDTH-1:0]		dout_reg	= 'b0;
	wire	[MAX_ADDR_WIDTH-1:0]	wv_wr_addr	;
	wire	[MAX_ADDR_WIDTH-1:0]	wv_rd_addr	;

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	地址位宽拼接
	//	-------------------------------------------------------------------------------------
	assign	wv_wr_addr	= {{(MAX_ADDR_WIDTH-ADDR_WIDTH+1){1'b0}},iv_wr_addr[ADDR_WIDTH-2:0]};
	assign	wv_rd_addr	= {{(MAX_ADDR_WIDTH-ADDR_WIDTH+1){1'b0}},iv_rd_addr[ADDR_WIDTH-2:0]};

	//  -------------------------------------------------------------------------------------
	//	存储器
	//  -------------------------------------------------------------------------------------
	genvar i;
	generate
		if(MAX_ADDR_WIDTH==6) begin
			for(i=0;i<FIFO_WIDTH;i=i+1) begin : data_width_loop_in_depth32
				RAM32X1D #(
				.INIT(32'h00000000) // Initial contents of RAM
				)
				RAM32X1D_inst (
				.DPO	(wv_dout[i]		),	// Read-only 1-bit data output
				.SPO	(				),	// Rw/ 1-bit data output
				.A0		(wv_wr_addr[0]	),	// Rw/ address[0] input bit
				.A1		(wv_wr_addr[1]	),	// Rw/ address[1] input bit
				.A2		(wv_wr_addr[2]	),	// Rw/ address[2] input bit
				.A3		(wv_wr_addr[3]	),	// Rw/ address[3] input bit
				.A4		(wv_wr_addr[4]	),	// Rw/ address[4] input bit
				.D		(iv_din[i]		),	// Write 1-bit data input
				.DPRA0	(wv_rd_addr[0]	),	// Read-only address[0] input bit
				.DPRA1	(wv_rd_addr[1]	),	// Read-only address[1] input bit
				.DPRA2	(wv_rd_addr[2]	),	// Read-only address[2] input bit
				.DPRA3	(wv_rd_addr[3]	),	// Read-only address[3] input bit
				.DPRA4	(wv_rd_addr[4]	),	// Read-only address[4] input bit
				.WCLK	(clk_wr			),	// Write clock input
				.WE		(i_wr			)	// Write enable input
				);
			end
		end
		else if(MAX_ADDR_WIDTH==7) begin
			for(i=0;i<FIFO_WIDTH;i=i+1) begin : data_width_loop_in_depth64
				RAM64X1D #(
				.INIT(64'h0000000000000000) // Initial contents of RAM
				)
				RAM64X1D_inst (
				.DPO	(wv_dout[i]		),	// Read-only 1-bit data output
				.SPO	(				),	// Rw/ 1-bit data output
				.A0		(wv_wr_addr[0]	),	// Rw/ address[0] input bit
				.A1		(wv_wr_addr[1]	),	// Rw/ address[1] input bit
				.A2		(wv_wr_addr[2]	),	// Rw/ address[2] input bit
				.A3		(wv_wr_addr[3]	),	// Rw/ address[3] input bit
				.A4		(wv_wr_addr[4]	),	// Rw/ address[4] input bit
				.A5		(wv_wr_addr[5]	),	// Rw/ address[5] input bit
				.D		(iv_din[i]		),	// Write 1-bit data input
				.DPRA0	(wv_rd_addr[0]	),	// Read-only address[0] input bit
				.DPRA1	(wv_rd_addr[1]	),	// Read-only address[1] input bit
				.DPRA2	(wv_rd_addr[2]	),	// Read-only address[2] input bit
				.DPRA3	(wv_rd_addr[3]	),	// Read-only address[3] input bit
				.DPRA4	(wv_rd_addr[4]	),	// Read-only address[4] input bit
				.DPRA5	(wv_rd_addr[5]	),	// Read-only address[5] input bit
				.WCLK	(clk_wr			),	// Write clock input
				.WE		(i_wr			)	// Write enable input
				);
			end
		end
	endgenerate

	//	always @ (posedge clk_rd) begin
	//		if(clk_rd) begin
	//			dout_reg	<= wv_dout;
	//		end
	//	end
	assign	ov_dout		= wv_dout;

endmodule
