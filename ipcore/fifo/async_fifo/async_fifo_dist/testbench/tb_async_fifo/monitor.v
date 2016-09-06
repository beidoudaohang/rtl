//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : monitor
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/3/16 17:48:47	:|  ��ʼ�汾
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
//`timescale 1ns/1ps
`timescale 1ns/1ns
//-------------------------------------------------------------------------------------------------
`define		TESTCASE	testcase_1
module monitor ();

	//	ref signals
	
	parameter	FIFO_WIDTH	= `TESTCASE.FIFO_WIDTH	;
		
	wire						clk_rd	;
	wire						reset_async	;
	wire						o_fifo_empty	;
	wire						i_rd_en	;
	wire						empty	;
	wire	[FIFO_WIDTH-1:0]	ov_fifo_dout	;
	wire	[FIFO_WIDTH-1:0]	dout	;
	
	reg		[FIFO_WIDTH-1:0]	async_rd_cnt	= 0;
	reg		[FIFO_WIDTH-1:0]	ip_rd_cnt		= 0;
	
	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	����
	//	-------------------------------------------------------------------------------------
	assign	clk_rd			= `TESTCASE.clk_rd;
	assign	reset_async		= `TESTCASE.reset_async;
	assign	o_fifo_empty	= harness.o_fifo_empty;
	assign	i_rd_en			= harness.i_rd_en;
	assign	empty			= harness.empty;
	assign	ov_fifo_dout	= harness.ov_fifo_dout;
	assign	dout			= harness.dout;

	//	-------------------------------------------------------------------------------------
	//	���
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_rd) begin
		if(reset_async) begin
			async_rd_cnt	<= 0;
		end
		else if(o_fifo_empty==1'b0 && i_rd_en==1'b1) begin
			async_rd_cnt	<= async_rd_cnt + 1'b1;
		end
	end

	always @ (posedge clk_rd) begin
		if(reset_async) begin
			ip_rd_cnt	<= 0;
		end
		else if(empty==1'b0 && i_rd_en==1'b1) begin
			ip_rd_cnt	<= ip_rd_cnt + 1'b1;
		end
	end

	always @ (posedge clk_rd) begin
		if(o_fifo_empty==1'b0 && i_rd_en==1'b1 && async_rd_cnt!=ov_fifo_dout) begin
			$display("%m: at time %t ERROR: async_rd_cnt is 0x%x!,ov_fifo_dout is 0x%x", $time,async_rd_cnt,ov_fifo_dout);
			//			$stop;
		end
	end

	always @ (posedge clk_rd) begin
		if(empty==1'b0 && i_rd_en==1'b1 && async_rd_cnt!=dout) begin
			$display("%m: at time %t ERROR: ip_rd_cnt is 0x%x!,dout is 0x%x", $time,ip_rd_cnt,dout);
			//			$stop;
		end
	end




endmodule
