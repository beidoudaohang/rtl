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


module gray2bin # (
	parameter	DATA_WIDTH 			= 8			,	//����λ��
	parameter	TIME_DOMAIN 		= "ASYNC"	,	//"ASYNC" "SYNC" �첽��ͬ������ʱ��һ��
	parameter	RESET_VALUE 		= 0				//"ASYNC" "SYNC" �첽��ͬ������ʱ��һ��
	)
	(
	input							clk			,	//ʱ��
	input							reset		,	//��λ
	input	[DATA_WIDTH-1:0]		iv_gray		,	//����ĸ�����
	output	[DATA_WIDTH-1:0]		ov_bin			//�����2������
	);

	//ref signals
	reg		[DATA_WIDTH-1:0]		gray_in_dly0 	= {DATA_WIDTH{1'b0}};
	reg		[DATA_WIDTH-1:0]		gray_in_dly1	= {DATA_WIDTH{1'b0}};
	reg		[DATA_WIDTH-1:0]		bin_reg			= {DATA_WIDTH{1'b0}};
	reg		[DATA_WIDTH-1:0]		tmp				= {DATA_WIDTH{1'b0}};
	integer           				j				;	// for loop variables

	//ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	ʱ����ת������
	//	1.������첽ʱ������ô��Ҫ������
	//	2.�����ͬ��ʱ��������Ҫ��ǰ����
	//	-------------------------------------------------------------------------------------
	generate
		if(TIME_DOMAIN=="ASYNC") begin : async_time_domain
			always @ (posedge clk) begin
				if(reset) begin
					gray_in_dly0	<= RESET_VALUE;
					gray_in_dly1	<= RESET_VALUE;
				end
				else begin
					gray_in_dly0	<= iv_gray;
					gray_in_dly1	<= gray_in_dly0;
				end
			end
		end
		else begin : sync_time_domain
			always @ ( * ) begin
				if(reset) begin
					gray_in_dly1	<= RESET_VALUE;
				end
				else begin
					gray_in_dly1	<= iv_gray;
				end
			end
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	������ת����������Ĺ�ʽ
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			bin_reg	<= RESET_VALUE;
		end
		else begin
			bin_reg[DATA_WIDTH-1]	<= gray_in_dly1[DATA_WIDTH-1];
			for(j=DATA_WIDTH-2;j>=0;j=j-1) begin
				bin_reg[j]	<= gray_in_dly1[j] ^ bin_reg[j+1];
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	ʱ�����
	//	1.�첽ʱ����3�ĵ���ʱ
	//	2.ͬ��ʱ����1�ĵ���ʱ
	//	-------------------------------------------------------------------------------------
	assign	ov_bin = bin_reg;

endmodule