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
//  -- Michael      | 2014/3/26 15:30:42	|
//-------------------------------------------------------------------------------------------------
//`include			"_def.v"
//time unit/precision
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module top_breath_led (
	input			sys_clk,
//	input	reset,
	output	[3:0]	ov_fpga_led
	);


	wire			sys_clk_ibufg	;
	wire			dcm_reset		;
	wire			dcm_lock		;
	wire			clk_10m_reset	;
	wire			clk_10m	;
	wire			clk_40m	;

	reg		[7:0]	pwr_up_cnt	= 8'b0;
	reg		[1:0]	shift_reset = 2'b11;

	reg		[5:0]		count_64	= 6'h0	;
	reg		[11:0]		count_2k	= 12'h0	;
	reg		[63:0]		shifter	= 64'h0	;


	//	ref signals



	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	时钟复位
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ibufg
	//  -------------------------------------------------------------------------------------
	IBUFG IBUFG_inst (
	.O		(sys_clk_ibufg	),	// Clock buffer output
	.I		(sys_clk		)	// Clock buffer input (connect directly to top-level port)
	);

	//  -------------------------------------------------------------------------------------
	//	上电复位dcm，时钟采用ibufg输出的时钟
	//  -------------------------------------------------------------------------------------
	always @ (posedge sys_clk_ibufg) begin
		if(pwr_up_cnt[7] == 1'b0) begin
			pwr_up_cnt	<= pwr_up_cnt + 1'b1;
		end
	end
	assign	dcm_reset = !pwr_up_cnt[7];

	//  -------------------------------------------------------------------------------------
	//	DCM
	//  -------------------------------------------------------------------------------------
	dcm dcm_inst (
	.CLK_IN1	(sys_clk_ibufg	),
	.CLK_OUT1	(clk_10m		),
	.CLK_OUT2	(clk_40m		),
	.RESET		(dcm_reset		),
	.LOCKED		(dcm_lock		)
	);

	//  -------------------------------------------------------------------------------------
	//	10M时钟域的复位信号
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_10m or negedge dcm_lock) begin
		if(!dcm_lock) begin
			shift_reset	<= 2'b11;
		end
		else begin
			shift_reset	<= {shift_reset[0],1'b0};
		end
	end
	assign	clk_10m_reset	= shift_reset[1];

	//  ===============================================================================================
	//	产生PWM波形
	//	1. 64bit shifter 10MHz clk driver
	//	2. 6.4us shift all 64bit
	//	3. Shifter init value is 64'h0
	//	3. every shifter shift 2048 times,Tall = 6.4us * 2048 = 13ms.Then high bit add once.
	//	4. from 64bit0 to 64bit1,T = 13ms * 64 = 839ms
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	0-63 cnt
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_10m) begin
		if(clk_10m_reset) begin
			count_64	<= 'b0;
		end
		else begin
			if(count_64 == 6'b111111) begin
				count_64	<= 'b0;
			end
			else begin
				count_64	<= count_64 + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	2048 cnt
	//	当移位器的64bit都移走之后，计数器++
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_10m) begin
		if(clk_10m_reset) begin
			count_2k	<= 'b0;
		end
		else begin
			if(count_64 == 6'b111111) begin
				if(count_2k[11]) begin
					count_2k	<= 'b0;
				end
				else begin
					count_2k	<= count_2k + 1'b1;
				end
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	64bit shifter
	//	已经移位了2048次，需要改变数据了
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_10m) begin
		if(clk_10m_reset) begin
			shifter	<= 'b0;
		end
		else begin
			if((count_64 == 6'b111111)&&(count_2k[11] == 1'b1)) begin
				shifter	<= {shifter[61:0],shifter[63],!shifter[62]};
			end
			else begin
				shifter	<= {shifter[62:0],shifter[63]};
			end
		end
	end

	//  ===============================================================================================
	//	输出
	//  ===============================================================================================

	assign	ov_fpga_led[0]		= shifter[63];
	assign	ov_fpga_led[2:1]	= 3'b000;
	assign	ov_fpga_led[3]		= 1'b1;



endmodule
