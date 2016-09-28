// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2010 by Lattice Semiconductor Corporation
// --------------------------------------------------------------------
//
// Permission:
//
//   Lattice Semiconductor grants permission to use this code for use
//   in synthesis for any Lattice programmable logic product.  Other
//   use of this code, including the selling or duplication of any
//   portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL or Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Lattice Semiconductor provides no warranty
//   regarding the use or functionality of this code.
//
// --------------------------------------------------------------------
//
//               Lattice Semiconductor Corporation
//               5555 NE Moore Court
//               Hillsboro, OR 97214
//               U.S.A
//
//               TEL: 1-800-Lattice (USA and Canada)
//
//               web: http://www.latticesemi.com/
//               email: techsupport@latticesemi.com
//
// --------------------------------------------------------------------
//
//  Project:     XO2 LVDS 7:1 Reference Design
//  File:        word_align_ctl_xo2.v
//  Title:       Word alignment control for XO2
//  Description: Examines the deserialized clock output
//                and generates a slip control signal
//                until the correct "1100011" word is found.
//
// --------------------------------------------------------------------
//
// --------------------------------------------------------------------
// Code Revision History :
// --------------------------------------------------------------------
// Ver: | Author   | Mod. Date  | Changes Made:
// V1.0 | shossner | 2010-04-15 | Initial Release
//
// --------------------------------------------------------------------

//----------------------------------------------------------------------------
//                                                                          --
//                         ENTITY DECLARATION                               --
//                                                                          --
//----------------------------------------------------------------------------
module word_align_ctl (
	// inputs
	input   wire        	clk			,   	// clk -> sclk
	input   wire        	rst			,   	// asynchronous reset
	input   wire        	i_hd		, 		// i_hd
	input   wire  [15:0] 	sync_word	,   	// deserializer (IDDRX71) output
	// outputs
	output  reg         	o_slip_done		,
	output  reg         	o_sync_word_flag,
	output  reg         	slip            ,	// slip command to deserializer
	output	reg		[15:0]	ov_sync_word
	);


	//	ref signals
	localparam	AD_SYNC_WORD	= 16'h5a58;
	reg     	[7:0]   wcount			= 8'b0;          // word counter
	reg			[2:0]	hd_shift		= 3'b0;

	//	ref ARCHITECTURE
	//	-------------------------------------------------------------------------------------
	//	判断hd的下降沿
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk or negedge rst) begin
		if( !rst ) begin
			hd_shift <= 3'b000;
		end
		else begin
			hd_shift <= {hd_shift[1:0],i_hd};
		end
	end

	//  -------------------------------------------------------------------------------------
	//	wcount 不需要复位信号，因为在hd的下降沿处才会复位
	//		[7:4] == 4'ha时，检测同步序列
	//		[7:4] == 4'hb时，展宽sync_ok信号
	//		[7:4] == 4'hc时，计数器的最大值，保持
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk or negedge rst) begin
		if( !rst ) begin
			wcount	<= 8'h00;
		end
		else begin
			if(hd_shift[2:1] == 2'b10) begin
				wcount	<= 8'h00;
			end
			else begin
				if(wcount[7:4] == 4'hc) begin
					wcount	<= wcount;
				end
				else begin
					wcount	<= wcount + 1'b1;
				end
			end
		end
	end

	//   Creates a slip pulse 2 clocks high, followed by
	//    6 clocks low to allow for alignment latency

	always @ (posedge clk or negedge rst) begin
		if (!rst) begin
			slip 			<= 1'b0;
			o_slip_done		<= 1'b0;
		end
		else if((wcount[7:0] >= 8'ha8)&&(wcount[7:0] <= 8'hab)) begin
			if(sync_word != AD_SYNC_WORD) begin
				slip 		<= 1'b1;
				o_slip_done	<= 1'b0;
			end
			else begin
				o_slip_done	<=	1'b1;
			end
		end
		else begin
			slip 	<= 1'b0;
		end
	end


	always @ (posedge clk or negedge rst) begin
		if (!rst) begin
			o_sync_word_flag	<= 1'b0;
		end
		else if(wcount[7:4] == 4'ha) begin
			if(sync_word == AD_SYNC_WORD) begin
				o_sync_word_flag	<= 1'b1;
			end
			else begin
				o_sync_word_flag	<= 1'b0;
			end
		end
		else begin
			o_sync_word_flag	<= 1'b0;
		end
	end


	always @ (posedge clk) begin
		ov_sync_word	<= sync_word;
	end


endmodule
