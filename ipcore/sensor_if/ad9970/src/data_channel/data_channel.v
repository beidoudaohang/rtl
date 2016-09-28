//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : data_channel
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/10/9 17:17:38	:|  ��ʼ�汾
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

module data_channel # (
	parameter	SER_FIRST_BIT		= "LSB"	;
	parameter	END_STYLE			= "LITTLE"	;
	parameter	SER_DATA_RATE		= "DDR"	;
	parameter	DESER_CLOCK_ARC		= "BUFPLL"	;
	parameter	CHANNEL_NUM			= 4	;
	parameter	DESER_WIDTH			= 6	;
	parameter	CLKIN_PERIOD_PS		= 3030	;
	parameter	DATA_DELAY_TYPE		= "DIFF_PHASE_DETECTOR"	;
	parameter	DATA_DELAY_VALUE	= 0	;
	parameter	BITSLIP_ENABLE		= "TRUE"	;
	)
	(
	input			clk		,
	input			reset	,


	);

	//	ref signals



	//	ref ARCHITECTURE
	deser_wrap # (
	.SER_FIRST_BIT		(SER_FIRST_BIT		),
	.END_STYLE			(END_STYLE			),
	.SER_DATA_RATE		(SER_DATA_RATE		),
	.DESER_CLOCK_ARC	(DESER_CLOCK_ARC	),
	.CHANNEL_NUM		(CHANNEL_NUM		),
	.DESER_WIDTH		(DESER_WIDTH		),
	.CLKIN_PERIOD_PS	(CLKIN_PERIOD_PS	),
	.DATA_DELAY_TYPE	(DATA_DELAY_TYPE	),
	.DATA_DELAY_VALUE	(DATA_DELAY_VALUE	),
	.BITSLIP_ENABLE		(BITSLIP_ENABLE		)
	)
	deser_wrap_inst (
	.i_clk_p			(i_clk_p			),
	.i_clk_n			(i_clk_n			),
	.iv_data_p			(iv_data_p			),
	.iv_data_n			(iv_data_n			),
	.reset				(reset				),
	.iv_bitslip			(iv_bitslip			),
	.o_bufpll_lock		(o_bufpll_lock		),
	.clk_recover		(clk_recover		),
	.reset_recover		(reset_recover		),
	.ov_data_recover	(ov_data_recover	)
	);






endmodule
