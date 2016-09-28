//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : bfm_spi_master
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/4/13 16:05:13	:|  ��ʼ�汾
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
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
module bfm_spi_master # (
	parameter	SPI_FIRST_DATA		= "MSB"	,	//"MSB" or "LSB"
	parameter	SPI_CS_POL			= "LOW"	,	//"HIGH" or "LOW" ��cs��Чʱ�ĵ�ƽ
	parameter	SPI_LEAD_TIME		= 1		,	//��ʼʱ��CS �� CLK �ľ��룬��λ��ʱ�����ڣ���ѡ 1 2 3
	parameter	SPI_LAG_TIME		= 1		,	//����ʱ��CS �� CLK �ľ��룬��λ��ʱ�����ڣ���ѡ 1 2 3
	parameter	SPI_DEBUG			= 0			//�Ƿ������ӡ��Ϣ
	)
	(
	input				cmd_fifo_full		,
	input				rdback_fifo_empty	,
	input	[8:0]		rdback_fifo_dout	,
	input				clk_fifo
	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	�õ�������
	//	-------------------------------------------------------------------------------------
	reg					i_cmd_fifo_wr		= 1'b0;
	reg		[8:0]		iv_cmd_fifo_din		= 9'b0;
	reg					i_rdback_fifo_rd	= 1'b0;

	//	ref ARCHITECTURE
	//	===============================================================================================
	//	ref ***bfm***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	--ref spi д���� 5byte
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
			//	д��1��byte
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
			//	д��2��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_addr_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 2 byte is %h",$stime,spi_addr_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��3��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_addr_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 3 byte is %h",$stime,spi_addr_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��4��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 4 byte is %h",$stime,spi_data_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��5��byte
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
	//	--ref spi д���� 4byte
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
			//	д��1��byte
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
			//	д��2��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_addr_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 2 byte is %h",$stime,spi_addr_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��3��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_addr_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 3 byte is %h",$stime,spi_addr_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��4��byte
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
	//	--ref spi д���� 6byte
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
			//	д��1��byte
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
			//	д��2��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_addr_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 2 byte is %h",$stime,spi_addr_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��3��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_addr_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 3 byte is %h",$stime,spi_addr_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��4��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 4 byte is %h",$stime,spi_data_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��5��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 5 byte is %h",$stime,spi_data_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��6��byte
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
	//	--ref spi д���� 19byte
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
			//	д��1��byte
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
			//	д��2��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_addr_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 2 byte is %h",$stime,spi_addr_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��3��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_addr_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 3 byte is %h",$stime,spi_addr_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��4��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data0_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 4 byte is %h",$stime,spi_data0_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��5��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data0_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 5 byte is %h",$stime,spi_data0_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��6��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data1_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 6 byte is %h",$stime,spi_data1_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��7��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data1_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 7 byte is %h",$stime,spi_data1_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��8��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data2_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 8 byte is %h",$stime,spi_data2_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��9��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data2_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 9 byte is %h",$stime,spi_data2_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��10��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data3_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 10 byte is %h",$stime,spi_data3_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��11��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data3_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 11 byte is %h",$stime,spi_data3_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��12��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data4_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 12 byte is %h",$stime,spi_data4_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��13��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data4_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 13 byte is %h",$stime,spi_data4_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��14��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data5_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 14 byte is %h",$stime,spi_data5_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��15��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data5_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 15 byte is %h",$stime,spi_data5_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��16��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data6_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 16 byte is %h",$stime,spi_data6_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��17��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data6_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 17 byte is %h",$stime,spi_data6_byte_l);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��18��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b1;
			iv_cmd_fifo_din	= spi_data7_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 18 byte is %h",$stime,spi_data7_byte_h);
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	= 1'b0;

			//	-------------------------------------------------------------------------------------
			//	д��19��byte
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
	//	--ref spi д���� 1byte
	//	-------------------------------------------------------------------------------------
	task spi_wr_cmd_1byte;
		input	[8:0]	spi_cmd_byte;
		begin
			#1
			$display("at time %0d ns\t ******spi rd cmd -1 byte\t: cmd is 0x%02x",$stime,spi_cmd_byte[7:0]);
			wait (cmd_fifo_full==1'b0);
			if(SPI_DEBUG)	$display("at time %0d ns\t ***spi wr function***",$stime);
			//	-------------------------------------------------------------------------------------
			//	д��1��byte
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
	//	--ref spi ������ 5byte
	//	-------------------------------------------------------------------------------------
	task spi_rd_cmd_5byte;
		integer 		i	;
		reg		[7:0]	receive_data	[4:0]	;
		begin
			wait (rdback_fifo_empty==1'b0);
			if(SPI_DEBUG)	$display("at time %0d ns\t ***spi rd function***",$stime);
			//	-------------------------------------------------------------------------------------
			//	����������5��byte
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
	//	--ref spi ������ 4byte
	//	-------------------------------------------------------------------------------------
	task spi_rd_cmd_4byte;
		integer 		i	;
		reg		[7:0]	receive_data	[4:0]	;
		begin
			wait (rdback_fifo_empty==1'b0);
			if(SPI_DEBUG)	$display("at time %0d ns\t ***spi rd function***",$stime);
			//	-------------------------------------------------------------------------------------
			//	����������5��byte
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
	//	--ref spi ������ 6byte
	//	-------------------------------------------------------------------------------------
	task spi_rd_cmd_6byte;
		integer 		i	;
		reg		[7:0]	receive_data	[5:0]	;
		begin
			wait (rdback_fifo_empty==1'b0);
			if(SPI_DEBUG)	$display("at time %0d ns\t ***spi rd function***",$stime);
			//	-------------------------------------------------------------------------------------
			//	����������5��byte
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
	//	--ref spi ������ 19byte
	//	-------------------------------------------------------------------------------------
	task spi_rd_cmd_19byte;
		integer 		i	;
		reg		[7:0]	receive_data	[18:0]	;
		begin
			wait (rdback_fifo_empty==1'b0);
			if(SPI_DEBUG)	$display("at time %0d ns\t ***spi rd function***",$stime);
			//	-------------------------------------------------------------------------------------
			//	����������19��byte
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
	//	--ref spi ������ 1byte
	//	-------------------------------------------------------------------------------------
	task spi_rd_cmd_1byte;
		integer 		i	;
		reg		[7:0]	receive_data	[0:0]	;
		begin
			wait (rdback_fifo_empty==1'b0);
			if(SPI_DEBUG)	$display("at time %0d ns\t ***spi rd function***",$stime);
			//	-------------------------------------------------------------------------------------
			//	����������5��byte
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
