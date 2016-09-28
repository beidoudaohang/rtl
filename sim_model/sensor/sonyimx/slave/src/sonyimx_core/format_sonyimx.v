//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : format_sonyimx
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/10/14 11:40:28	:|  ��ʼ�汾
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

module format_sonyimx # (
	parameter			DATA_WIDTH			= 10		,	//����λ��
	parameter			CHANNEL_NUM			= 8			//ͨ����
	)
	(
	input											clk							,	//ʱ��
	input											i_fval						,	//����Ч
	input											i_lval						,	//����Ч
	input		[DATA_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data					,	//��������
	output											o_fval						,	//����Ч
	output											o_lval						,	//����Ч
	output		[DATA_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data						//��������
	);


	//	ref signals

	localparam		SAV_1_V		= (DATA_WIDTH==10) ? 10'h3FF : 12'hFFF;
	localparam		SAV_2_V		= (DATA_WIDTH==10) ? 10'h000 : 12'h000;
	localparam		SAV_3_V		= (DATA_WIDTH==10) ? 10'h000 : 12'h000;
	localparam		SAV_4_V		= (DATA_WIDTH==10) ? 10'h200 : 12'h800;

	localparam		EAV_1_V		= (DATA_WIDTH==10) ? 10'h3FF : 12'hFFF;
	localparam		EAV_2_V		= (DATA_WIDTH==10) ? 10'h000 : 12'h000;
	localparam		EAV_3_V		= (DATA_WIDTH==10) ? 10'h000 : 12'h000;
	localparam		EAV_4_V		= (DATA_WIDTH==10) ? 10'h274 : 12'h9D0;

	localparam		SAV_1_IV	= (DATA_WIDTH==10) ? 10'h3FF : 12'hFFF;
	localparam		SAV_2_IV	= (DATA_WIDTH==10) ? 10'h000 : 12'h000;
	localparam		SAV_3_IV	= (DATA_WIDTH==10) ? 10'h000 : 12'h000;
	localparam		SAV_4_IV	= (DATA_WIDTH==10) ? 10'h2AC : 12'hAB0;

	localparam		EAV_1_IV	= (DATA_WIDTH==10) ? 10'h3FF : 12'hFFF;
	localparam		EAV_2_IV	= (DATA_WIDTH==10) ? 10'h000 : 12'h000;
	localparam		EAV_3_IV	= (DATA_WIDTH==10) ? 10'h000 : 12'h000;
	localparam		EAV_4_IV	= (DATA_WIDTH==10) ? 10'h2DB : 12'hD60;


	reg		[DATA_WIDTH*CHANNEL_NUM-1:0]		data_reg[4:0];
	reg		[DATA_WIDTH*CHANNEL_NUM-1:0]		pix_data;
	reg		[8:0]								fval_shift;
	reg		[8:0]								lval_shift;


	//	ref ARCHITECTURE

	always @ (posedge clk) begin
		fval_shift	<=	{fval_shift[7:0],i_fval};
		lval_shift	<=	{lval_shift[7:0],i_lval};
	end

	always @ (posedge clk) begin
		data_reg[0]	<= iv_pix_data;
		data_reg[1]	<= data_reg[0];
		data_reg[2]	<= data_reg[1];
		data_reg[3]	<= data_reg[2];
		data_reg[4]	<= data_reg[3];
	end

	always @ (posedge clk) begin
		if(i_fval) begin
			case(lval_shift)
				9'b000000001	:		pix_data	<= {CHANNEL_NUM{SAV_1_V[DATA_WIDTH-1:0]}};
				9'b000000011	:		pix_data	<= {CHANNEL_NUM{SAV_2_V[DATA_WIDTH-1:0]}};
				9'b000000111	:		pix_data	<= {CHANNEL_NUM{SAV_3_V[DATA_WIDTH-1:0]}};
				9'b000001111	:		pix_data	<= {CHANNEL_NUM{SAV_4_V[DATA_WIDTH-1:0]}};
				9'b111100000	:		pix_data	<= {CHANNEL_NUM{EAV_1_V[DATA_WIDTH-1:0]}};
				9'b111000000	:		pix_data	<= {CHANNEL_NUM{EAV_2_V[DATA_WIDTH-1:0]}};
				9'b110000000	:		pix_data	<= {CHANNEL_NUM{EAV_3_V[DATA_WIDTH-1:0]}};
				9'b100000000	:		pix_data	<= {CHANNEL_NUM{EAV_4_V[DATA_WIDTH-1:0]}};
				default			:		pix_data	<= data_reg[4];
			endcase
		end
		else begin
			case(lval_shift)
				9'b000000001	:		pix_data	<= {CHANNEL_NUM{SAV_1_IV[DATA_WIDTH-1:0]}};
				9'b000000011	:		pix_data	<= {CHANNEL_NUM{SAV_2_IV[DATA_WIDTH-1:0]}};
				9'b000000111	:		pix_data	<= {CHANNEL_NUM{SAV_3_IV[DATA_WIDTH-1:0]}};
				9'b000001111	:		pix_data	<= {CHANNEL_NUM{SAV_4_IV[DATA_WIDTH-1:0]}};
				9'b111100000	:		pix_data	<= {CHANNEL_NUM{EAV_1_IV[DATA_WIDTH-1:0]}};
				9'b111000000	:		pix_data	<= {CHANNEL_NUM{EAV_2_IV[DATA_WIDTH-1:0]}};
				9'b110000000	:		pix_data	<= {CHANNEL_NUM{EAV_3_IV[DATA_WIDTH-1:0]}};
				9'b100000000	:		pix_data	<= {CHANNEL_NUM{EAV_4_IV[DATA_WIDTH-1:0]}};
				default			:		pix_data	<= data_reg[4];
			endcase
		end
	end

	assign	o_fval		= fval_shift[5];
	assign	o_lval		= lval_shift[5];
	assign	ov_pix_data	= pix_data;

endmodule
