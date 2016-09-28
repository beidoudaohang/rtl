//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : bfm_spi_master
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/4/13 16:05:13	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
module bfm_spi_master # (
	parameter	SPI_FIRST_DATA		= "MSB"	,	//"MSB" or "LSB"
	parameter	SPI_CS_POL			= "LOW"	,	//"HIGH" or "LOW" ，cs有效时的电平
	parameter	SPI_LEAD_TIME		= 1		,	//开始时，CS 与 CLK 的距离，单位是时钟周期，可选 1 2 3
	parameter	SPI_LAG_TIME		= 1		,	//结束时，CS 与 CLK 的距离，单位是时钟周期，可选 1 2 3
	parameter	SPI_DEBUG			= 0			//是否输出打印信息
	)
	(
	input				cmd_fifo_full		,
	input				rdback_fifo_empty	,
	input	[8:0]		rdback_fifo_dout	,
	input				clk_fifo
	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	用到的数据
	//	-------------------------------------------------------------------------------------
	reg					i_cmd_fifo_wr		= 1'b0;
	reg		[8:0]		iv_cmd_fifo_din		= 9'b0;
	reg					i_rdback_fifo_rd	= 1'b0;

	//	ref ARCHITECTURE
	//	===============================================================================================
	//	ref ***bfm***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	spi 写任务
	//	-------------------------------------------------------------------------------------
	task spi_wr_cmd_5byte;
		input	[8:0]	spi_cmd_byte;
		input	[8:0]	spi_addr_byte_h;
		input	[8:0]	spi_addr_byte_l;
		input	[8:0]	spi_data_byte_h;
		input	[8:0]	spi_data_byte_l;
		begin
			#1
			if(spi_cmd_byte[0]) begin
				$display("at time %0d ns\t ******spi rd cmd\t: addr is 0x%02x%02x",$stime,spi_addr_byte_h[7:0],spi_addr_byte_l[7:0]);
			end
			else begin
				$display("at time %0d ns\t ******spi wr cmd\t: addr is 0x%02x%02x,wr data is 0x%02x%02x",$stime,spi_addr_byte_h[7:0],spi_addr_byte_l[7:0],spi_data_byte_h[7:0],spi_data_byte_l[7:0]);
			end
			wait (cmd_fifo_full==1'b0);
			if(SPI_DEBUG)	$display("at time %0d ns\t ***spi wr function***",$stime);
			//	-------------------------------------------------------------------------------------
			//	写第1个byte
			//	-------------------------------------------------------------------------------------
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_cmd_byte;
			if(iv_cmd_fifo_din[0]) begin
				if(SPI_DEBUG)	$display("at time %0d ns\t wr 1 byte is %h,spi read operation",$stime,spi_cmd_byte);
			end
			else begin
				if(SPI_DEBUG)	$display("at time %0d ns\t wr 1 byte is %h,spi wr operation",$stime,spi_cmd_byte);
			end

			//	-------------------------------------------------------------------------------------
			//	写第2个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			iv_cmd_fifo_din	<= spi_addr_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 2 byte is %h",$stime,spi_addr_byte_h);
			wait (cmd_fifo_full==1'b0);
			//	-------------------------------------------------------------------------------------
			//	写第3个byte
			//	-------------------------------------------------------------------------------------
			@ (posedge clk_fifo);
			iv_cmd_fifo_din	<= spi_addr_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 3 byte is %h",$stime,spi_addr_byte_l);
			wait (cmd_fifo_full==1'b0);
			//	-------------------------------------------------------------------------------------
			//	写第4个byte
			//	-------------------------------------------------------------------------------------
			@ (posedge clk_fifo);
			iv_cmd_fifo_din	<= spi_data_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 4 byte is %h",$stime,spi_data_byte_h);
			wait (cmd_fifo_full==1'b0);
			//	-------------------------------------------------------------------------------------
			//	写第5个byte
			//	-------------------------------------------------------------------------------------
			@ (posedge clk_fifo);
			iv_cmd_fifo_din	<= spi_data_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 5 byte is %h",$stime,spi_data_byte_l);
			wait (cmd_fifo_full==1'b0);
			//	-------------------------------------------------------------------------------------
			//	取消写信号
			//	-------------------------------------------------------------------------------------
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	<= 1'b0;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	spi 读任务
	//	-------------------------------------------------------------------------------------
	task spi_rd_cmd_5byte;
		integer 		i	;
		reg		[7:0]	receive_data	[4:0]	;
		begin
			wait (rdback_fifo_empty==1'b0);
			if(SPI_DEBUG)	$display("at time %0d ns\t ***spi rd function***",$stime);
			//	-------------------------------------------------------------------------------------
			//	连续读出来5个byte
			//	-------------------------------------------------------------------------------------
			for(i=0;i<5;i=i+1) begin
				@ (posedge clk_fifo);
				wait (rdback_fifo_empty==1'b0);
				i_rdback_fifo_rd<= 1'b1;
				if(SPI_DEBUG)	$display("at time %0d ns\t rd %0d byte is %h",$stime,i+1,rdback_fifo_dout);
				receive_data[i]	<= rdback_fifo_dout;
				@ (posedge clk_fifo);
				i_rdback_fifo_rd<= 1'b0;
			end
			$display("at time %0d ns\t ******spi get data\t: rd data is 0x%02x%02x",$stime,receive_data[3],receive_data[4]);
		end

	endtask


endmodule
