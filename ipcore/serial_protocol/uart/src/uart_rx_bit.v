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
//  -- Michael      | 2014/12/8 17:30:48	|
//-------------------------------------------------------------------------------------------------
//`include			"_def.v"
//time unit/precision
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module uart_rx_bit (
	input				clk				,	//主时钟，至少是 i_16x_baud_en 的2倍
	input				i_uart_rx_ser	,	//uart接收端口
	input				i_16x_baud_en	,	//波特率的16倍速率使能信号，高电平有效，1个clk的宽度
	output				o_fifo_wr		,	//fifo读信号
	output	[7:0]		ov_fifo_din			//输出给fifo的数据
	);

	//	ref signals
	reg					ser_d0			= 1'b0;
	reg					ser_d1			= 1'b0;
	reg					sample0			= 1'b0;
	reg					sample1			= 1'b0;
	wire				ser_rx_fall		;
	reg		[3:0]		en_16_cnt		= 4'b0;
	reg		[3:0]		rx_bit_cnt		= 4'b0;
	reg		[7:0]		shift_reg		= 8'b0;
	reg					state_cnt		= 1'b0;
	reg					fifo_wr_int		= 1'b0;
	reg		[7:0]		fifo_din_int	= 8'b0;

	//	ref ARCHITECTURE


	//  -------------------------------------------------------------------------------------
	//	异步时钟域的同步
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		ser_d0	<= i_uart_rx_ser;
		ser_d1	<= ser_d0;
	end

	//  -------------------------------------------------------------------------------------
	//	在 使能 信号处采样
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_16x_baud_en==1'b1) begin
			sample0	<= ser_d1;
			sample1	<= sample0;
		end
	end
	assign	ser_rx_fall	= ((sample0==1'b1)&&(ser_d1==1'b0)) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	一个bit中包含16个使能
	//	当处于状态1(移位)时，计数器累加
	//	当处于状态0(等待起始位)时，计数器清零
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_16x_baud_en) begin
			if((state_cnt==1'b0)&&(ser_rx_fall==1'b1)) begin
				en_16_cnt	<= 4'b0001;
			end
			else begin
				en_16_cnt	<= en_16_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	收到的bit数
	//	当处于状态1(移位)时，每计数16次，接收一个
	//	当处于状态0(等待起始位)时，计数器清零
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(state_cnt) begin
			if((en_16_cnt==4'b1111)&&(i_16x_baud_en==1'b1)) begin
				rx_bit_cnt	<= rx_bit_cnt + 1'b1;
			end
		end
		else begin
			rx_bit_cnt	<= 'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	在bit的中间采样
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(state_cnt) begin
			if((i_16x_baud_en==1'b1)&&(en_16_cnt==4'b0111)) begin
				if((rx_bit_cnt>=4'b0001)||(rx_bit_cnt<=4'b1000)) begin
					shift_reg	<= {ser_d1,shift_reg[7:1]};
				end
			end
		end
		else begin
			shift_reg	<= 'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	fifo的操作
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(state_cnt) begin
			if((i_16x_baud_en==1'b1)&&(rx_bit_cnt==4'b1001)&&(en_16_cnt==4'b0111)) begin
				fifo_wr_int		<= 1'b1;
				fifo_din_int	<= shift_reg;
			end
			else begin
				fifo_wr_int		<= 1'b0;
				fifo_din_int	<= 'b0;
			end
		end
		else begin
			fifo_wr_int		<= 1'b0;
			fifo_din_int	<= 'b0;
		end
	end

	assign	o_fifo_wr		= fifo_wr_int;
	assign	ov_fifo_din		= fifo_din_int;

	//  -------------------------------------------------------------------------------------
	//	0为idle状态 1为传输状态
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//  -------------------------------------------------------------------------------------
		//	状态0-等待起始位
		//  -------------------------------------------------------------------------------------
		if(state_cnt==1'b0) begin
			if((i_16x_baud_en==1'b1)&&(sample1==1'b1)&&(sample0==1'b0)) begin
				state_cnt	<= 1'b1;
			end
			else begin
				state_cnt	<= 1'b0;
			end
		end
		//  -------------------------------------------------------------------------------------
		//	状态1-移位输入信号
		//  -------------------------------------------------------------------------------------
		else begin
			if((i_16x_baud_en==1'b1)&&(rx_bit_cnt==4'b1001)&&(en_16_cnt==4'b0111)) begin
				state_cnt	<= 1'b0;
			end
			else begin
				state_cnt	<= 1'b1;
			end
		end
	end

endmodule
