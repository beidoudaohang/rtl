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
//  -- Michael      | 2014/12/8 14:44:37	|
//-------------------------------------------------------------------------------------------------
//`include			"_def.v"
//time unit/precision
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module uart_tx_bit (
	input				clk				,	//主时钟，至少是 i_16x_baud_en 的2倍
	input				i_16x_baud_en	,	//波特率的16倍速率使能信号，高电平有效，1个clk的宽度
	input	[7:0]		iv_fifo_dout	,	//fifo输出的数据
	input				i_fifo_empty	,	//fifo的空信号
	output				o_fifo_rd		,	//读fifo信号
	output				o_uart_tx_ser		//uart发送端口
	);

	//	ref signals
	reg		[3:0]		en_16_cnt	= 4'b0;
	reg		[3:0]		tx_bit_cnt	= 4'b0;
	reg					fifo_rd_int	= 1'b0;
	reg		[9:0]		shift_reg	= 10'b0;
	reg					state_cnt	= 1'b0;

	//	ref ARCHITECTURE


	//  -------------------------------------------------------------------------------------
	//	每个bit的时间相当于16个 i_16x_baud_en
	//	当处于状态1(移位)时，计数器累加
	//	当处于状态0(读fifo)时，计数器清零
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(state_cnt) begin
			if(i_16x_baud_en) begin
				en_16_cnt	<= en_16_cnt + 1'b1;
			end
		end
		else begin
			en_16_cnt	<= 'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	发送的 bit 的计数器
	//	当处于状态1(移位)时，每计数16次，发送一个
	//	当处于状态0(读fifo)时，计数器清零
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(state_cnt) begin
			if((i_16x_baud_en==1'b1)&&(en_16_cnt==4'b1111)) begin
				tx_bit_cnt	<= tx_bit_cnt + 1'b1;
			end
		end
		else begin
			tx_bit_cnt	<= 'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	读fifo，1个时钟宽度
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((state_cnt==1'b0)&&(i_fifo_empty==1'b0)&&(i_16x_baud_en==1'b1)) begin
			fifo_rd_int	<= 1'b1;
		end
		else begin
			fifo_rd_int	<= 1'b0;
		end
	end
	assign	o_fifo_rd	= fifo_rd_int;

	//  -------------------------------------------------------------------------------------
	//	移位寄存器
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(state_cnt) begin
			if((i_16x_baud_en==1'b1)&&(en_16_cnt==4'b1111)) begin
				shift_reg	<= {shift_reg[0],shift_reg[9:1]};
			end
		end
		else begin
			shift_reg	<= {1'b1,iv_fifo_dout,1'b0};	//stop + 8bit + start
		end
	end
	assign	o_uart_tx_ser	= (state_cnt==1'b1) ? shift_reg[0] : 1'b1;

	//  -------------------------------------------------------------------------------------
	//	状态判断
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(state_cnt)
			//  -------------------------------------------------------------------------------------
			//	状态0-读fifo。该状态相当于复位寄存器的状态
			//  -------------------------------------------------------------------------------------
			1'b0 : begin
				if((i_fifo_empty==1'b0)&&(i_16x_baud_en==1'b1)) begin
					state_cnt	<= 1'b1;
				end
				else begin
					state_cnt	<= 1'b0;
				end
			end
			//  -------------------------------------------------------------------------------------
			//	状态1-移位
			//  -------------------------------------------------------------------------------------
			1'b1 : begin
				if((i_16x_baud_en==1'b1)&&(en_16_cnt==4'b1111)&&(tx_bit_cnt==4'b1001)) begin
					state_cnt	<= 1'b0;
				end
				else begin
					state_cnt	<= 1'b1;
				end
			end
			default : begin

			end
		endcase
	end

endmodule
