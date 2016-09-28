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
	//	spi д����
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

			//	-------------------------------------------------------------------------------------
			//	д��2��byte
			//	-------------------------------------------------------------------------------------
			wait (cmd_fifo_full==1'b0);
			@ (posedge clk_fifo);
			iv_cmd_fifo_din	<= spi_addr_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 2 byte is %h",$stime,spi_addr_byte_h);
			wait (cmd_fifo_full==1'b0);
			//	-------------------------------------------------------------------------------------
			//	д��3��byte
			//	-------------------------------------------------------------------------------------
			@ (posedge clk_fifo);
			iv_cmd_fifo_din	<= spi_addr_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 3 byte is %h",$stime,spi_addr_byte_l);
			wait (cmd_fifo_full==1'b0);
			//	-------------------------------------------------------------------------------------
			//	д��4��byte
			//	-------------------------------------------------------------------------------------
			@ (posedge clk_fifo);
			iv_cmd_fifo_din	<= spi_data_byte_h;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 4 byte is %h",$stime,spi_data_byte_h);
			wait (cmd_fifo_full==1'b0);
			//	-------------------------------------------------------------------------------------
			//	д��5��byte
			//	-------------------------------------------------------------------------------------
			@ (posedge clk_fifo);
			iv_cmd_fifo_din	<= spi_data_byte_l;
			if(SPI_DEBUG)	$display("at time %0d ns\t wr 5 byte is %h",$stime,spi_data_byte_l);
			wait (cmd_fifo_full==1'b0);
			//	-------------------------------------------------------------------------------------
			//	ȡ��д�ź�
			//	-------------------------------------------------------------------------------------
			@ (posedge clk_fifo);
			i_cmd_fifo_wr	<= 1'b0;
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	spi ������
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
