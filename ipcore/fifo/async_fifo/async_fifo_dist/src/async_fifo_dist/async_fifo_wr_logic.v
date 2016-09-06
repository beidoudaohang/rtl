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
//  -- Michael      | 2016/09/06 10:52:45	|
//-------------------------------------------------------------------------------------------------
//`include			"_def.v"
//time unit/precision
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------


module async_fifo_wr_logic # (
	parameter						ADDR_WIDTH			= 8	//���λ��ַ�����жϿ�����־��������fifo��ַ����� 6-���32 7-���64
	)
	(
	input							clk					,	//ʱ��
	input							reset				,	//ͬ����λ
	input							i_wr_en				,	//дʹ��
	input	[ADDR_WIDTH-1:0]		iv_rd_addr_bin		,	//����ַ��2�����룬����ʱ����
	output	[ADDR_WIDTH-1:0]		ov_wr_addr_bin		,	//д��ַ��2�����룬��������ģ��
	output	[ADDR_WIDTH-2:0]		ov_wr_addr_dpram	,	//д��ַ��2�����룬��dpramģ��
	output							o_wr_en				,	//dpramдʹ��
	output							o_fifo_full				//fifo����־
	);

	//ref signals
	wire							valid_wr			;
	reg								fifo_full_reg		= 1'b1;
	reg		[ADDR_WIDTH-1:0]		wr_addr_cnt			= 1;
	reg		[ADDR_WIDTH-1:0]		wr_addr_cnt_next1	= 2;
	reg		[ADDR_WIDTH-1:0]		wr_addr_cnt_next2	= 3;
	wire							full_equation		;


	//ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	д��Ч
	//	1.��������дʹ����Чʱ��д�ź���Ч
	//	-------------------------------------------------------------------------------------
	assign	valid_wr	= (i_wr_en==1'b1 && fifo_full_reg==1'b0) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	���ź�
	//	1.����д��ַ�����λ���ȣ��ҵ�λ���ʱ����
	//	2.��д��Ч �� д��ַ+1֮�󣬶�д��ַ�����λ���ȣ���λ���ʱ����
	//	-------------------------------------------------------------------------------------
	assign	full_equation	= (wr_addr_cnt_next1[ADDR_WIDTH-1]!=iv_rd_addr_bin[ADDR_WIDTH-1] && wr_addr_cnt_next1[ADDR_WIDTH-2:0]==iv_rd_addr_bin[ADDR_WIDTH-2:0]) ? 1'b1 :
	(valid_wr==1'b1 && wr_addr_cnt_next2[ADDR_WIDTH-1]!=iv_rd_addr_bin[ADDR_WIDTH-1] && wr_addr_cnt_next2[ADDR_WIDTH-2:0]==iv_rd_addr_bin[ADDR_WIDTH-2:0]) ? 1'b1 :
	1'b0;

	always @ (posedge clk) begin
		if(reset) begin
			fifo_full_reg	<= 1'b1;
		end
		else begin
			fifo_full_reg	<= full_equation;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	д��ַ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			wr_addr_cnt			<= 1;
			wr_addr_cnt_next1	<= 2;
			wr_addr_cnt_next2	<= 3;
		end
		else begin
			if(valid_wr) begin
				wr_addr_cnt			<= wr_addr_cnt + 1;
				wr_addr_cnt_next1	<= wr_addr_cnt + 2;
				wr_addr_cnt_next2	<= wr_addr_cnt + 3;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	���
	//  -------------------------------------------------------------------------------------
	assign	o_fifo_full 		= fifo_full_reg;
	assign	ov_wr_addr_bin 		= wr_addr_cnt;
	assign	ov_wr_addr_dpram	= wr_addr_cnt[ADDR_WIDTH-1:0];
	assign	o_wr_en 			= valid_wr;

endmodule
