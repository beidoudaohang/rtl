// +FHDR========================================================================
// Copyright (c) 2011 daheng-image, Inc. All rights reserved
// =============================================================================
// FILE NAME  		: testdata
// DEPARTMENT 		: hardware
// AUTHOR     		: zhangqiang
// AUTHOR?S EMAIL 	: zhangqiang@daheng-image.com
// PCB     			:
// tools			: Quartus11.0
// =============================================================================
// testdata 模块主要用来生成测试图功能，测试图分两种：
//			一是：与行场位置存在一定关系的测试数据(本模块实现与行场相关的测试数据)
//			二是：与行场位置无关，从文件读入的数据
// =============================================================================
`timescale 1 ns/ 1 ps
`define							DS_DAT_WD 			64
module hv_data
#(
	parameter	DS_DAT_WD  = 64
)

 (
    input							clk					,
    input							reset_n         	,
	input							i_dval          	,
	input							i_fval          	,
	input							i_trailer_flag      ,
	output	reg						o_dval          	,
	output	reg						o_fval          	,
	output	reg						o_trailer_flag		,
    output	reg	[	DS_DAT_WD-1: 0] ov_data
);




    reg			[	DS_DAT_WD-1: 0]testdata1_line_start;
    reg			[			   2: 0]dval_shift			;
    reg			[			   2: 0]fval_shift			;
    reg			[			   2: 0]trailer_shift		;
    reg			[	DS_DAT_WD-1: 0]testdata1			;
    reg			[	DS_DAT_WD-1: 0]testdata2			;


// =============================================================================
// shift
// data from dval and fval
// =============================================================================

	always@(posedge clk or negedge reset_n)
	    begin
	    	if(!reset_n)
		    	begin
		    		dval_shift	<=	3'b000;
		    		fval_shift	<=	3'b000;
		    	end
	    	else
	    		begin
		    		dval_shift	<=	{dval_shift[1:0],i_dval};
		    		fval_shift	<=	{fval_shift[1:0],i_fval};
		    		trailer_shift<=	{trailer_shift[1:0],i_trailer_flag};
	    		end
	    end

// =============================================================================
// test data1
// data from dval and fval
// testdata1_line_start increase from 1
// =============================================================================


	always@(posedge clk or negedge reset_n)
	    begin
	    	if(!reset_n)
		    	testdata1	<=	{DS_DAT_WD{1'b0}};
		    else if ( i_fval & dval_shift[0] )
		    	//testdata1	<=	{$random}%{{1'b1},{DS_DAT_WD{1'b0}}};
		    	//testdata1	<=	{{$random},{$random}};
				//testdata1	<=	{32'h0,{$random}};
				testdata1	<=	testdata1 + 1;
	    end
// =============================================================================
// dval and fval delay
// =============================================================================

	always@(posedge clk or negedge reset_n)
		begin
		    if (!reset_n)
		       	ov_data	<= {DS_DAT_WD{1'b0}};
		    else if ( dval_shift[1] && fval_shift[1] )
		     	ov_data	<= testdata1;
		    else
		    	ov_data	<= {DS_DAT_WD{1'b0}};
		end

	always@(posedge clk or negedge reset_n)
		begin
		    if (!reset_n)
				begin
					o_dval	<=	1'b0;
					o_fval  <=	1'b0;
				end
			else
				begin
					o_dval	<=	dval_shift[1];
					o_fval  <=	fval_shift[1];
					o_trailer_flag <= trailer_shift[1];
				end
		end

endmodule
