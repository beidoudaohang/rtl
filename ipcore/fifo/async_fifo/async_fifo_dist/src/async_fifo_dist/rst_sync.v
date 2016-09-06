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


module rst_sync # (
	parameter	RESET_LENGTH = 2
	)
	(
	input		clk			,	//时钟
	input		reset_in	,	//复位输入
	output		reset_out		//复位输出
	);

	//	ref signals

	reg	[RESET_LENGTH-1:0]	reset_shift = {RESET_LENGTH{1'b1}};

	//	ref ARCHITECTURE

	//异步复位，同步释放
	always @ (posedge clk or posedge reset_in) begin
		if(reset_in) begin
			reset_shift <= {RESET_LENGTH{1'b1}};
		end else begin
			reset_shift	<= {reset_shift[RESET_LENGTH-2:0],1'b0};
		end
	end
	assign	reset_out	= reset_shift[RESET_LENGTH-1];




endmodule
