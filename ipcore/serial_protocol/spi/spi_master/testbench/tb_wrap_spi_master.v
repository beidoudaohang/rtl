//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : tb_wrap_spi_master
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/4 16:22:58	:|  初始版本
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
//`include			"tb_wrap_spi_master_def.v"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module tb_wrap_spi_master ();

	//	ref signals
	reg				clk	= 1'b0;
	reg				reset	= 1'b0;
	reg				i_cmd_fifo_wr	= 1'b0;
	reg		[8:0]	iv_cmd_fifo_din	= 9'b0;
	wire			o_cmd_fifo_full;
	wire			o_spi_clk;
	wire			o_spi_cs;
	wire			o_spi_mosi;
	reg				i_spi_miso	= 1'b0;


	//	ref ARCHITECTURE

	wrap_spi_master # (
	.SPI_CLKDIV			(20					),
	.SPI_FIRST_DATA		("MSB"				),
	.SPI_CS_POL			("LOW"				),
	.SPI_LEAD_TIME		(1					),
	.SPI_LAG_TIME		(1					)
	)
	wrap_spi_master_inst (
	.clk				(clk				),
	.reset				(reset				),
	.i_cmd_fifo_wr		(i_cmd_fifo_wr		),
	.iv_cmd_fifo_din	(iv_cmd_fifo_din	),
	.o_cmd_fifo_full	(o_cmd_fifo_full	),
	.o_spi_clk			(o_spi_clk			),
	.o_spi_cs			(o_spi_cs			),
	.o_spi_mosi			(o_spi_mosi			),
	.i_spi_miso			(i_spi_miso			)
	);




	initial begin
		//$display($time, "Starting the Simulation...");
		//$monitor($time, "count1 is %d,count2 is %b,count3 is %h",cnt1,cnt2,cnt3);
		reset = 1'b1;
		#200
		reset = 1'b0;
		#10000
		$stop;

	end

	always #5 clk = ~clk;


	initial begin
		//$display("** ");
		//#1000000
		wait (reset==1'b0);
		repeat (10) 	@ (posedge clk);
		@ (posedge clk);
		i_cmd_fifo_wr	<= 1'b1;
		iv_cmd_fifo_din	<= 9'h180;
		@ (posedge clk);
		iv_cmd_fifo_din	<= 9'h000;
		@ (posedge clk);
		iv_cmd_fifo_din	<= 9'h001;
		@ (posedge clk);
		iv_cmd_fifo_din	<= 9'h0ab;
		@ (posedge clk);
		iv_cmd_fifo_din	<= 9'h0ba;
		@ (posedge clk);
		i_cmd_fifo_wr	<= 1'b1;
		iv_cmd_fifo_din	<= 9'h181;
		@ (posedge clk);
		iv_cmd_fifo_din	<= 9'h000;
		@ (posedge clk);
		iv_cmd_fifo_din	<= 9'h002;
		@ (posedge clk);
		iv_cmd_fifo_din	<= 9'h0ff;
		@ (posedge clk);
		iv_cmd_fifo_din	<= 9'h0ff;
		
	end






	//generate vcd file
	//initial begin
	//$dumpfile("test.vcd");
	//$dumpvars(1,top_frame_buffer_inst);
	//end

	//for lattice simulation
	//GSR   GSR_INST (.GSR (1'b1)); //< global reset sig>
	//PUR   PUR_INST (.PUR (1'b1)); //<powerup reset sig>



endmodule
