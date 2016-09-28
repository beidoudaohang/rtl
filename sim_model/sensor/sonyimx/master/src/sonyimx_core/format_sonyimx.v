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
	output	reg [DATA_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data						//��������
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
//	localparam		SAV_1_V		= 10'h3FF;
//	localparam		SAV_2_V		= 10'h000;
//	localparam		SAV_3_V		= 10'h000;
//	localparam		SAV_4_V		= 10'h200;
//
//	localparam		EAV_1_V		= 10'h3FF;
//	localparam		EAV_2_V		= 10'h000;
//	localparam		EAV_3_V		= 10'h000;
//	localparam		EAV_4_V		= 10'h274;
//
//	localparam		SAV_1_IV	= 10'h3FF;
//	localparam		SAV_2_IV	= 10'h000;
//	localparam		SAV_3_IV	= 10'h000;
//	localparam		SAV_4_IV	= 10'h2AC;
//
//	localparam		EAV_1_IV	= 10'h3FF;
//	localparam		EAV_2_IV	= 10'h000;
//	localparam		EAV_3_IV	= 10'h000;
//	localparam		EAV_4_IV	= 10'h2DB;

	reg		[DATA_WIDTH*CHANNEL_NUM-1:0]		data_reg[3:0];
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
	end

	always @ (posedge clk) begin
		case({i_fval,{lval_shift}})
			10'b1000000001	:		ov_pix_data	<= {{SAV_1_V},{SAV_1_V},{SAV_1_V},{SAV_1_V},{SAV_1_V},{SAV_1_V},{SAV_1_V},{SAV_1_V}};
			10'b1000000011	:		ov_pix_data	<= {{SAV_2_V},{SAV_2_V},{SAV_2_V},{SAV_2_V},{SAV_2_V},{SAV_2_V},{SAV_2_V},{SAV_2_V}};
			10'b1000000111	:		ov_pix_data	<= {{SAV_3_V},{SAV_3_V},{SAV_3_V},{SAV_3_V},{SAV_3_V},{SAV_3_V},{SAV_3_V},{SAV_3_V}};
			10'b1000001111	:		ov_pix_data	<= {{SAV_4_V},{SAV_4_V},{SAV_4_V},{SAV_4_V},{SAV_4_V},{SAV_4_V},{SAV_4_V},{SAV_4_V}};
			10'b1111100000	:		ov_pix_data	<= {{EAV_1_V},{EAV_1_V},{EAV_1_V},{EAV_1_V},{EAV_1_V},{EAV_1_V},{EAV_1_V},{EAV_1_V}};
			10'b1111000000	:		ov_pix_data	<= {{EAV_2_V},{EAV_2_V},{EAV_2_V},{EAV_2_V},{EAV_2_V},{EAV_2_V},{EAV_2_V},{EAV_2_V}};
			10'b1110000000	:		ov_pix_data	<= {{EAV_3_V},{EAV_3_V},{EAV_3_V},{EAV_3_V},{EAV_3_V},{EAV_3_V},{EAV_3_V},{EAV_3_V}};
			10'b1100000000	:		ov_pix_data	<= {{EAV_4_V},{EAV_4_V},{EAV_4_V},{EAV_4_V},{EAV_4_V},{EAV_4_V},{EAV_4_V},{EAV_4_V}};
			default			:		ov_pix_data	<= data_reg[3];
		endcase
	end



	assign	o_fval	= fval_shift[5];
	assign	o_lval	= lval_shift[5];


endmodule
