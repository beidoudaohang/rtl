//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : spi_master
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/4 16:05:54	:|  初始版本
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

module spi_master # (
	parameter	SPI_FIRST_DATA		= "MSB"	,	//"MSB" or "LSB"
	parameter	SPI_CS_POL			= "LOW"	,	//"HIGH" or "LOW" ，cs有效时的电平
	parameter	SPI_LEAD_TIME		= 1		,	//开始时，CS 与 CLK 的距离，单位是时钟周期，可选 1 2 3
	parameter	SPI_LAG_TIME		= 1			//结束时，CS 与 CLK 的距离，单位是时钟周期，可选 1 2 3
	)
	(
	//时钟和复位
	input				clk_fifo			,	//cmd fifo 写时钟
	input				reset_fifo			,	//cmd fifo 复位
	//cmd fifo操作
	input				i_cmd_fifo_wr		,	//cmd fifo写信号
	input	[8:0]		iv_cmd_fifo_din		,	//cmd fifo写数据
	output				o_cmd_fifo_full		,	//cmd fifo满信号
	//rdback fifo操作
	input				i_rdback_fifo_rd	,	//rdback fifo读信号
	output	[8:0]		ov_rdback_fifo_dout	,	//rdback fifo读出数据
	output				o_rdback_fifo_empty	,	//rdback fifo空信号
	//spi接口时钟
	input				spi_clk				,	//模块工作时钟
	//spi接口信号 4 wire
	output				o_spi_clk			,	//spi 时钟
	output				o_spi_cs			,	//spi 片选
	output				o_spi_mosi			,	//主输出，从输入
	input				i_spi_miso				//主输入，从输出
	);

	//	ref signals
	wire				w_cmd_fifo_rd		;
	wire				w_cmd_fifo_empty	;
	wire	[8:0]		wv_cmd_fifo_dout	;
	wire				w_rdback_fifo_wr	;
	wire	[7:0]		wv_rdback_fifo_din	;

	//	ref ARCHITECTURE


	distri_fifo_w9d32 cmd_fifo_inst (
	.rst		(reset_fifo			),
	.wr_clk		(clk_fifo			),
	.wr_en		(i_cmd_fifo_wr		),
	.full		(o_cmd_fifo_full	),
	.din		(iv_cmd_fifo_din	),
	.rd_clk		(spi_clk			),
	.rd_en		(w_cmd_fifo_rd		),
	.empty		(w_cmd_fifo_empty	),
	.dout		(wv_cmd_fifo_dout	)
	);

	distri_fifo_w9d32 rdback_fifo_inst (
	.rst		(reset_fifo			),
	.wr_clk		(spi_clk			),
	.wr_en		(w_rdback_fifo_wr	),
	.full		(w_rdback_fifo_full	),
	.din		({1'b0,wv_rdback_fifo_din}	),
	.rd_clk		(clk_fifo			),
	.rd_en		(i_rdback_fifo_rd	),
	.empty		(o_rdback_fifo_empty),
	.dout		(ov_rdback_fifo_dout)
	);

	spi_master_core # (
	.SPI_FIRST_DATA		(SPI_FIRST_DATA	),
	.SPI_CS_POL			(SPI_CS_POL		),
	.SPI_LEAD_TIME		(SPI_LEAD_TIME	),
	.SPI_LAG_TIME		(SPI_LAG_TIME	)
	)
	spi_master_core_inst (
	.clk				(spi_clk			),
	.o_spi_clk			(o_spi_clk			),
	.o_spi_cs			(o_spi_cs			),
	.o_spi_mosi			(o_spi_mosi			),
	.i_spi_miso			(i_spi_miso			),
	.o_cmd_fifo_rd		(w_cmd_fifo_rd		),
	.iv_cmd_fifo_dout	(wv_cmd_fifo_dout	),
	.i_cmd_fifo_empty	(w_cmd_fifo_empty	),
	.o_rdback_fifo_wr	(w_rdback_fifo_wr	),
	.ov_rdback_fifo_din	(wv_rdback_fifo_din	)
	);



endmodule
