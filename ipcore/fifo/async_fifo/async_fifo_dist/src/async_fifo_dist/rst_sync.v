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
	input		clk			,	//ʱ��
	input		reset_in	,	//��λ����
	output		reset_out		//��λ���
	);

	//	ref signals

	reg	[RESET_LENGTH-1:0]	reset_shift = {RESET_LENGTH{1'b1}};

	//	ref ARCHITECTURE

	//�첽��λ��ͬ���ͷ�
	always @ (posedge clk or posedge reset_in) begin
		if(reset_in) begin
			reset_shift <= {RESET_LENGTH{1'b1}};
		end else begin
			reset_shift	<= {reset_shift[RESET_LENGTH-2:0],1'b0};
		end
	end
	assign	reset_out	= reset_shift[RESET_LENGTH-1];




endmodule
