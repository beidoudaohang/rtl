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


module bin2gray # (
	parameter	DATA_WIDTH 			= 8			,	//数据位宽
	parameter	TIME_DOMAIN 		= "ASYNC"	,	//"ASYNC" "SYNC" 异步和同步的延时不一样
	parameter	RESET_VALUE 		= 0				//"ASYNC" "SYNC" 异步和同步的延时不一样
	)
	(
	input							clk			,	//时钟
	input							reset		,	//复位
	input	[DATA_WIDTH-1:0] 		iv_bin		,	//输入的2进制码
	output	[DATA_WIDTH-1:0] 		ov_gray			//输出的格雷码
	);

	//ref signals
	reg		[DATA_WIDTH-1:0]		bin_dly0		= {DATA_WIDTH{1'b0}};
	reg		[DATA_WIDTH-1:0]		bin_dly1		= {DATA_WIDTH{1'b0}};
	reg		[DATA_WIDTH-1:0]		gray_reg	= {DATA_WIDTH{1'b0}};
	integer							j			;	// for loop variables

	//ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	时钟域转换部分
	//	1.如果是异步时钟域，那么需要打两拍
	//	2.如果是同步时钟域，则不需要提前处理
	//	-------------------------------------------------------------------------------------
	generate
		if(TIME_DOMAIN=="ASYNC") begin : async_time_domain
			always @ (posedge clk) begin
				if(reset) begin
					bin_dly0	<= RESET_VALUE;
					bin_dly1	<= RESET_VALUE;
				end
				else begin
					bin_dly0	<= iv_bin;
					bin_dly1	<= bin_dly0;
				end
			end
		end
		else begin : sync_time_domain
			always @ ( * ) begin
				if(reset) begin
					bin_dly1	<= RESET_VALUE;
				end
				else begin
					bin_dly1	<= iv_bin;
				end
			end
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	二进制转换到格雷码的公式
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			gray_reg	<= RESET_VALUE;
		end
		else begin
			gray_reg[DATA_WIDTH-1]	<= bin_dly1[DATA_WIDTH-1];
			for (j=0;j<=DATA_WIDTH-2;j=j+1) begin
				gray_reg[j]	<= bin_dly1[j] ^ bin_dly1[j+1];
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	时序参数
	//	1.异步时钟域，3拍的延时
	//	2.同步时钟域，1拍的延时
	//	-------------------------------------------------------------------------------------
	assign	ov_gray = gray_reg;

endmodule