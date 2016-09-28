//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : deserializer
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/9/18 10:50:31	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : ����ʱ�����ݽ⴮ģ��
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

module deserializer # (
	parameter	DIFF_TERM				= "TRUE"			,	//Differential Termination
	parameter	IOSTANDARD				= "LVDS_33"			,	//Specifies the I/O standard for this buffer
	parameter	SER_FIRST_BIT			= "LSB"				,	//"LSB" or "MSB" , first bit to the receiver
	parameter	END_STYLE				= "LITTLE"			,	//"LITTLE" or "BIG" , "LITTLE" - {CHANNEL3 CHANNE2 CHANNEL1 CHANNEL0}. "BIG" - {CHANNEL0 CHANNEL1 CHANNEL2 CHANNEL3}.
	parameter	SER_DATA_RATE			= "DDR"				,	//"DDR" or "SDR" ����Ĵ���ʱ�Ӳ�����ʽ
	parameter	DESER_CLOCK_ARC			= "BUFPLL"			,	//"BUFPLL" or "BUFIO2" , deserializer clock achitecture
	parameter	CHANNEL_NUM				= 4					,	//���ͨ������
	parameter	DESER_WIDTH				= 6					,	//ÿ��ͨ���⴮��� 2-8
	parameter	CLKIN_PERIOD_PS			= 3030				,	//����ʱ��Ƶ�ʣ�PSΪ��λ��ֻ��BUFPLL��ʽ�����á�
	parameter	DATA_DELAY_TYPE			= "DIFF_PHASE_DETECTOR"	,	//"DEFAULT", "DIFF_PHASE_DETECTOR", "FIXED", "VARIABLE_FROM_HALF_MAX", "VARIABLE_FROM_ZERO"
	parameter	DATA_DELAY_VALUE		= 0					,	//0-255������ܳ��� 1 UI
	parameter	BITSLIP_ENABLE			= "TRUE"				//"TRUE" "FALSE" iserdes �ֱ߽���빦��
	)
	(
	//	-------------------------------------------------------------------------------------
	//	��ִ���ʱ������
	//	-------------------------------------------------------------------------------------
	input											i_clk_p				,	//���ʱ������
	input											i_clk_n				,	//���ʱ������
	input		[CHANNEL_NUM-1:0]					iv_data_p			,	//�����������
	input		[CHANNEL_NUM-1:0]					iv_data_n			,	//�����������
	//	-------------------------------------------------------------------------------------
	//	�����ź�
	//	-------------------------------------------------------------------------------------
	input											reset				,	//��λ�źţ�bufpll��ʽ�£���λ�⴮pll��bufio2��ʽ�£���λxxxxxx
	input		[CHANNEL_NUM-1:0]					iv_bitslip			,	//�ֽڱ߽�������ÿ����������λһ��
	output											o_bufpll_lock		,	//bufpll lock �ź�
	//	-------------------------------------------------------------------------------------
	//	�⴮�ָ�����ʱ������
	//	-------------------------------------------------------------------------------------
	output											clk_recover			,	//�ָ�ʱ��
	output											reset_recover		,	//�ָ�ʱ����λ�ź�
	output		[DESER_WIDTH*CHANNEL_NUM-1:0]		ov_data_recover			//�����������
	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	���������BUFPLL�⴮ʱ�ӣ���������ISERDES�ˣ�������ʽ������SDR
	//	-------------------------------------------------------------------------------------
	localparam		SER_DATA_RATE_ISERDES	= (DESER_CLOCK_ARC=="BUFPLL") ? "SDR" : SER_DATA_RATE;

	wire				clk_io	;
	wire				clk_io_inv	;
	wire				serdesstrobe	;
	wire				bufpll_lock	;

	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//  ʵ�����⴮ʱ�ӽṹ�� bufpll or bufio2
	//  -------------------------------------------------------------------------------------
	generate
		if(DESER_CLOCK_ARC=="BUFPLL") begin
			deser_clk_gen_bufpll # (
			.DIFF_TERM				(DIFF_TERM			),
			.IOSTANDARD				(IOSTANDARD			),
			.SER_DATA_RATE			(SER_DATA_RATE		),
			.DESER_WIDTH			(DESER_WIDTH		),
			.CLKIN_PERIOD_PS		(CLKIN_PERIOD_PS	)
			)
			deser_clk_gen_bufpll_inst (
			.clkin_p				(i_clk_p			),
			.clkin_n				(i_clk_n			),
			.reset					(reset				),
			.clk_recover			(clk_recover		),
			.clk_io					(clk_io				),
			.serdesstrobe			(serdesstrobe		),
			.bufpll_lock			(bufpll_lock		)
			);
			assign	clk_io_inv	= 1'b0;
		end
		else if(DESER_CLOCK_ARC=="BUFIO2") begin
			deser_clk_gen_bufio2 # (
			.DIFF_TERM				(DIFF_TERM			),
			.IOSTANDARD				(IOSTANDARD			),
			.SER_DATA_RATE			(SER_DATA_RATE		),
			.DESER_WIDTH			(DESER_WIDTH		)
			)
			deser_clk_gen_bufio2_inst (
			.clkin_p				(i_clk_p			),
			.clkin_n				(i_clk_n			),
			.clk_recover			(clk_recover		),
			.clk_io					(clk_io				),
			.clk_io_inv				(clk_io_inv			),
			.serdesstrobe			(serdesstrobe		)
			);
			assign	bufpll_lock	= !reset;
		end
	endgenerate
	assign	o_bufpll_lock	= bufpll_lock;

	//  -------------------------------------------------------------------------------------
	//  �ָ�ʱ�Ӹ�λ�ź�
	//  -------------------------------------------------------------------------------------
	reset_sync # (
	.INITIALISE		(2'b11	)
	)
	reset_sync_inst (
	.reset_in		(!bufpll_lock		),
	.clk			(clk_recover		),
	.enable			(1'b1				),
	.reset_out		(reset_recover		)
	);

	//  -------------------------------------------------------------------------------------
	//  ʵ�������ݽ⴮
	//  -------------------------------------------------------------------------------------
	deser_data # (
	.DIFF_TERM			(DIFF_TERM			),
	.IOSTANDARD			(IOSTANDARD			),
	.SER_FIRST_BIT		(SER_FIRST_BIT		),
	.END_STYLE			(END_STYLE			),
	.SER_DATA_RATE		(SER_DATA_RATE_ISERDES	),
	.CHANNEL_NUM		(CHANNEL_NUM		),
	.DESER_WIDTH		(DESER_WIDTH		),
	.DATA_DELAY_TYPE	(DATA_DELAY_TYPE	),
	.DATA_DELAY_VALUE	(DATA_DELAY_VALUE	),
	.BITSLIP_ENABLE		(BITSLIP_ENABLE		)
	)
	deser_data_inst (
	.iv_data_p			(iv_data_p			),
	.iv_data_n			(iv_data_n			),
	.clk_io				(clk_io				),
	.clk_io_inv			(clk_io_inv			),
	.serdesstrobe		(serdesstrobe		),
	.iv_bitslip			(iv_bitslip			),
	.clk_recover		(clk_recover		),
	.reset_recover		(reset_recover		),
	.ov_data_recover	(ov_data_recover	)
	);

endmodule
