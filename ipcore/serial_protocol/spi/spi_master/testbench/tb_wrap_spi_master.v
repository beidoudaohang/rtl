//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : tb_wrap_spi_master
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/3/4 16:22:58	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//`include			"tb_wrap_spi_master_def.v"
//���浥λ/����
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
