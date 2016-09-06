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


module async_fifo_rd_logic # (
	parameter						ADDR_WIDTH		= 8		//���λ��ַ�����жϿ�����־��������fifo��ַ����� 6-���32 7-���64
	)
	(
	input							clk					,	//ʱ��
	input							reset				,	//ͬ����λ
	input							i_rd_en				,	//��ʹ��
	input	[ADDR_WIDTH-1:0]		iv_wr_addr_bin		,	//д��ַ��2�����룬����ʱ����
	output	[ADDR_WIDTH-1:0]		ov_rd_addr_bin		,	//����ַ��2�����룬��������ģ��
	output	[ADDR_WIDTH-2:0]		ov_rd_addr_dpram	,	//����ַ��2�����룬��dpramģ��
	output							o_rd_en				,	//dpram��ʹ��
	output							o_fifo_empty			//fifo�ձ�־
	);

	//ref signals
	wire							valid_rd			;
	reg								fifo_empty_reg		= 1'b1;
	reg		[ADDR_WIDTH-1:0]		rd_addr_cnt			= 'b0;
	reg		[ADDR_WIDTH-1:0]		rd_addr_cnt_next1	= 1;
	reg		[ADDR_WIDTH-1:0]		rd_addr_cnt_next2	= 2;
	wire							empty_equation		;




	//ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	����Ч
	//	�������Ҷ�ʹ����Чʱ�����ź���Ч
	//	-------------------------------------------------------------------------------------
	assign	valid_rd	= (i_rd_en==1'b1 && fifo_empty_reg==1'b0) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	���ź�
	//	1.��ǰ�ǿյ�״̬ʱ������һ������ַ==д��ַ��ȣ���
	//	2.��ǰ�Ƿǿյ�״̬ʱ��������Ч �� ��һ������ַ==д��ַ��ȣ���
	//	-------------------------------------------------------------------------------------
	assign	empty_equation	=
	(fifo_empty_reg==1'b1 && rd_addr_cnt_next1==iv_wr_addr_bin) ? 1'b1 :
	(fifo_empty_reg==1'b0 && valid_rd==1'b1 && rd_addr_cnt_next1==iv_wr_addr_bin) ? 1'b1 :
	1'b0;

	always @ (posedge clk) begin
		if(reset) begin
			fifo_empty_reg	<= 1'b1;
		end
		else begin
			fifo_empty_reg	<= empty_equation;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	����ַ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			rd_addr_cnt			<= 0;
			rd_addr_cnt_next1	<= 1;
		end
		else begin
			if(fifo_empty_reg) begin
				if(rd_addr_cnt_next1!=iv_wr_addr_bin) begin
					rd_addr_cnt			<= rd_addr_cnt + 1;
					rd_addr_cnt_next1	<= rd_addr_cnt + 2;
				end
			end
			else begin
				if(valid_rd) begin
					if(rd_addr_cnt_next1==iv_wr_addr_bin) begin
						rd_addr_cnt			<= rd_addr_cnt;
						rd_addr_cnt_next1	<= rd_addr_cnt_next1;
					end
					else begin
						rd_addr_cnt			<= rd_addr_cnt + 1;
						rd_addr_cnt_next1	<= rd_addr_cnt + 2;
					end
				end
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	���
	//  -------------------------------------------------------------------------------------
	assign	o_fifo_empty 		= fifo_empty_reg;
	assign	ov_rd_addr_bin		= rd_addr_cnt;
	assign	ov_rd_addr_dpram	= rd_addr_cnt[ADDR_WIDTH-1:0];
	assign	o_rd_en 			= valid_rd;

endmodule
