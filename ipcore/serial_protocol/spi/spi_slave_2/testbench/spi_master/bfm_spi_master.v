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
	//	--ref spi 写任务 5byte
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
				$display("at time %0d ns\t ******spi rd cmd -5 byte\t: addr is 0x%02x%02x",$stime,spi_addr_byte_h[7:0],spi_addr_byte_l[7:0]);
			end
			else begin
				$display("at time %0d ns\t ******spi wr cmd -5 byte\t: addr is 0x%02x%02x,wr data is 0x%02x%02x",$stime,spi_addr_byte_h[7:0],spi_addr_byte_l[7:0],spi_data_byte_h[7:0],spi_data_byte_l[7:0]);
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
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第2个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_addr_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 2 byte is %h",$stime,spi_addr_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第3个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_addr_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 3 byte is %h",$stime,spi_addr_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第4个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 4 byte is %h",$stime,spi_data_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第5个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 5 byte is %h",$stime,spi_data_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref spi 写任务 4byte
	//	-------------------------------------------------------------------------------------
	task spi_wr_cmd_4byte;
		input	[8:0]	spi_cmd_byte;
		input	[8:0]	spi_addr_byte_h;
		input	[8:0]	spi_addr_byte_l;
		input	[8:0]	spi_data_byte_h;
		begin
			#1
			if(spi_cmd_byte[0]) begin
				$display("at time %0d ns\t ******spi rd cmd -4 byte\t: addr is 0x%02x%02x",$stime,spi_addr_byte_h[7:0],spi_addr_byte_l[7:0]);
			end
			else begin
				$display("at time %0d ns\t ******spi wr cmd -4 byte\t: addr is 0x%02x%02x,wr data is 0x%02x",$stime,spi_addr_byte_h[7:0],spi_addr_byte_l[7:0],spi_data_byte_h[7:0]);
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
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第2个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_addr_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 2 byte is %h",$stime,spi_addr_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第3个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_addr_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 3 byte is %h",$stime,spi_addr_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第4个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 4 byte is %h",$stime,spi_data_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;



		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref spi 写任务 6byte
	//	-------------------------------------------------------------------------------------
	task spi_wr_cmd_6byte;
		input	[8:0]	spi_cmd_byte;
		input	[8:0]	spi_addr_byte_h;
		input	[8:0]	spi_addr_byte_l;
		input	[8:0]	spi_data_byte_h;
		input	[8:0]	spi_data_byte_l;
		input	[8:0]	spi_wrong_byte;
		begin
			#1
			if(spi_cmd_byte[0]) begin
				$display("at time %0d ns\t ******spi rd cmd -6 byte\t: addr is 0x%02x%02x",$stime,spi_addr_byte_h[7:0],spi_addr_byte_l[7:0]);
			end
			else begin
				$display("at time %0d ns\t ******spi wr cmd -6 byte\t: addr is 0x%02x%02x,wr data is 0x%02x%02x%02x",$stime,spi_addr_byte_h[7:0],spi_addr_byte_l[7:0],spi_data_byte_h[7:0],spi_data_byte_l[7:0],spi_wrong_byte);
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
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第2个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_addr_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 2 byte is %h",$stime,spi_addr_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第3个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_addr_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 3 byte is %h",$stime,spi_addr_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第4个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 4 byte is %h",$stime,spi_data_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第5个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 5 byte is %h",$stime,spi_data_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第6个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_wrong_byte;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 6 byte is %h",$stime,spi_wrong_byte);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref spi 写任务 19byte
	//	-------------------------------------------------------------------------------------
	task spi_wr_cmd_19byte;
		input	[8:0]	spi_cmd_byte;
		input	[8:0]	spi_addr_byte_h;
		input	[8:0]	spi_addr_byte_l;
		input	[8:0]	spi_data0_byte_h;
		input	[8:0]	spi_data0_byte_l;
		input	[8:0]	spi_data1_byte_h;
		input	[8:0]	spi_data1_byte_l;
		input	[8:0]	spi_data2_byte_h;
		input	[8:0]	spi_data2_byte_l;
		input	[8:0]	spi_data3_byte_h;
		input	[8:0]	spi_data3_byte_l;
		input	[8:0]	spi_data4_byte_h;
		input	[8:0]	spi_data4_byte_l;
		input	[8:0]	spi_data5_byte_h;
		input	[8:0]	spi_data5_byte_l;
		input	[8:0]	spi_data6_byte_h;
		input	[8:0]	spi_data6_byte_l;
		input	[8:0]	spi_data7_byte_h;
		input	[8:0]	spi_data7_byte_l;
		begin
			#1
			if(spi_cmd_byte[0]) begin
				$display("at time %0d ns\t ******spi rd cmd -19 byte\t: addr is 0x%02x%02x",$stime,spi_addr_byte_h[7:0],spi_addr_byte_l[7:0]);
			end
			else begin
				$display("at time %0d ns\t ******spi wr cmd -19 byte\t: addr is 0x%02x%02x,wr data is 0x%02x%02x",$stime,spi_addr_byte_h[7:0],spi_addr_byte_l[7:0],spi_data0_byte_h[7:0],spi_data0_byte_l[7:0]);
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
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第2个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_addr_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 2 byte is %h",$stime,spi_addr_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第3个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_addr_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 3 byte is %h",$stime,spi_addr_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第4个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data0_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 4 byte is %h",$stime,spi_data0_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第5个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data0_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 5 byte is %h",$stime,spi_data0_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第6个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data1_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 6 byte is %h",$stime,spi_data1_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第7个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data1_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 7 byte is %h",$stime,spi_data1_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第8个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data2_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 8 byte is %h",$stime,spi_data2_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第9个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data2_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 9 byte is %h",$stime,spi_data2_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第10个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data3_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 10 byte is %h",$stime,spi_data3_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第11个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data3_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 11 byte is %h",$stime,spi_data3_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第12个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data4_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 12 byte is %h",$stime,spi_data4_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第13个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data4_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 13 byte is %h",$stime,spi_data4_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第14个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data5_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 14 byte is %h",$stime,spi_data5_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第15个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data5_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 15 byte is %h",$stime,spi_data5_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第16个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data6_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 16 byte is %h",$stime,spi_data6_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第17个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data6_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 17 byte is %h",$stime,spi_data6_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第18个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data7_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 18 byte is %h",$stime,spi_data7_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	写第19个byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data7_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 19 byte is %h",$stime,spi_data7_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;


		end
	endtask


	//	-------------------------------------------------------------------------------------
	//	--ref spi 写任务 1byte
	//	-------------------------------------------------------------------------------------
	task spi_wr_cmd_1byte;
		input	[8:0]	spi_cmd_byte;
		begin
			#1
			$display("at time %0d ns\t ******spi rd cmd -1 byte\t: cmd is 0x%02x",$stime,spi_cmd_byte[7:0]);
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
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref spi 读任务 5byte
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
				wait (rdback_fifo_empty==1'b0);
				@ (posedge clk_fifo);
				wait (rdback_fifo_empty==1'b0);
				@ (posedge clk_fifo);
				i_rdback_fifo_rd<= 1'b1;
				if(SPI_DEBUG)	$display("at time %0d ns\t rd %0d byte is %h",$stime,i+1,rdback_fifo_dout);
				receive_data[i]	<= rdback_fifo_dout;
				@ (posedge clk_fifo);
				i_rdback_fifo_rd<= 1'b0;
			end
			$display("at time %0d ns\t ******spi get data -5 byte\t: rd data is 0x%02x%02x",$stime,receive_data[3],receive_data[4]);
		end

	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref spi 读任务 4byte
	//	-------------------------------------------------------------------------------------
	task spi_rd_cmd_4byte;
		integer 		i	;
		reg		[7:0]	receive_data	[4:0]	;
		begin
			wait (rdback_fifo_empty==1'b0);
			if(SPI_DEBUG)	$display("at time %0d ns\t ***spi rd function***",$stime);
			//	-------------------------------------------------------------------------------------
			//	连续读出来5个byte
			//	-------------------------------------------------------------------------------------
			for(i=0;i<4;i=i+1) begin
				wait (rdback_fifo_empty==1'b0);
				@ (posedge clk_fifo);
				wait (rdback_fifo_empty==1'b0);
				@ (posedge clk_fifo);
				i_rdback_fifo_rd<= 1'b1;
				if(SPI_DEBUG)	$display("at time %0d ns\t rd %0d byte is %h",$stime,i+1,rdback_fifo_dout);
				receive_data[i]	<= rdback_fifo_dout;
				@ (posedge clk_fifo);
				i_rdback_fifo_rd<= 1'b0;
			end
			$display("at time %0d ns\t ******spi get data -4 byte\t: rd data is 0x%02x%02x",$stime,receive_data[3],receive_data[4]);
		end

	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref spi 读任务 6byte
	//	-------------------------------------------------------------------------------------
	task spi_rd_cmd_6byte;
		integer 		i	;
		reg		[7:0]	receive_data	[5:0]	;
		begin
			wait (rdback_fifo_empty==1'b0);
			if(SPI_DEBUG)	$display("at time %0d ns\t ***spi rd function***",$stime);
			//	-------------------------------------------------------------------------------------
			//	连续读出来5个byte
			//	-------------------------------------------------------------------------------------
			for(i=0;i<6;i=i+1) begin
				wait (rdback_fifo_empty==1'b0);
				@ (posedge clk_fifo);
				wait (rdback_fifo_empty==1'b0);
				@ (posedge clk_fifo);
				i_rdback_fifo_rd<= 1'b1;
				if(SPI_DEBUG)	$display("at time %0d ns\t rd %0d byte is %h",$stime,i+1,rdback_fifo_dout);
				receive_data[i]	<= rdback_fifo_dout;
				@ (posedge clk_fifo);
				i_rdback_fifo_rd<= 1'b0;
			end
			$display("at time %0d ns\t ******spi get data -6 byte\t: rd data is 0x%02x%02x",$stime,receive_data[3],receive_data[4]);
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref spi 读任务 19byte
	//	-------------------------------------------------------------------------------------
	task spi_rd_cmd_19byte;
		integer 		i	;
		reg		[7:0]	receive_data	[18:0]	;
		begin
			wait (rdback_fifo_empty==1'b0);
			if(SPI_DEBUG)	$display("at time %0d ns\t ***spi rd function***",$stime);
			//	-------------------------------------------------------------------------------------
			//	连续读出来19个byte
			//	-------------------------------------------------------------------------------------
			for(i=0;i<19;i=i+1) begin
				wait (rdback_fifo_empty==1'b0);
				@ (posedge clk_fifo);
				wait (rdback_fifo_empty==1'b0);
				@ (posedge clk_fifo);
				i_rdback_fifo_rd<= 1'b1;
				if(SPI_DEBUG)	$display("at time %0d ns\t rd %0d byte is %h",$stime,i+1,rdback_fifo_dout);
				receive_data[i]	<= rdback_fifo_dout;
				@ (posedge clk_fifo);
				i_rdback_fifo_rd<= 1'b0;
			end
			$display("at time %0d ns\t ******spi get data -19 byte\t: rd data is 0x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",$stime,
			receive_data[3],receive_data[4],receive_data[5],receive_data[6],receive_data[7],receive_data[8],receive_data[9],receive_data[10],
			receive_data[11],receive_data[12],receive_data[13],receive_data[14],receive_data[15],receive_data[16],receive_data[17],receive_data[18]
			);
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	--ref spi 读任务 1byte
	//	-------------------------------------------------------------------------------------
	task spi_rd_cmd_1byte;
		integer 		i	;
		reg		[7:0]	receive_data	[0:0]	;
		begin
			wait (rdback_fifo_empty==1'b0);
			if(SPI_DEBUG)	$display("at time %0d ns\t ***spi rd function***",$stime);
			//	-------------------------------------------------------------------------------------
			//	连续读出来5个byte
			//	-------------------------------------------------------------------------------------
			for(i=0;i<1;i=i+1) begin
				wait (rdback_fifo_empty==1'b0);
				@ (posedge clk_fifo);
				wait (rdback_fifo_empty==1'b0);
				@ (posedge clk_fifo);
				i_rdback_fifo_rd<= 1'b1;
				if(SPI_DEBUG)	$display("at time %0d ns\t rd %0d byte is %h",$stime,i+1,rdback_fifo_dout);
				receive_data[i]	<= rdback_fifo_dout;
				@ (posedge clk_fifo);
				i_rdback_fifo_rd<= 1'b0;
			end
			$display("at time %0d ns\t ******spi get data -1 byte\t: rd data is 0x%02x",$stime,receive_data[0],);
		end
	endtask

endmodule
