//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : hispi_if
//  -- �����       : �ܽ�
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �ܽ�       :| 2015/08/11 13:46:45	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : HiSPi�ӿ�ģ�飬ֻ������Packetized-SPģʽ
//              1)  : ����slectIO����sensor���͵����ݣ�sensorλ��Ϊ12bit��selectIO�Ľ⴮��������Ϊ6
//
//              2)  : ����word�߽���룬���ͬ����
//
//              3)  : ����fval��lval��pixel_data�ź�,fval��lval��ʱ�����Ǳ��ض����
//				fval:____|--------------------------------------------|_____
//				lval:____|----|____|----|____|----|____|----|____|----|_____
//				data:____|<-->|____|<-->|____|<-->|____|<-->|____|<-->|_____
//				4)	������Ч���ȱ�����4��������
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ns
//-------------------------------------------------------------------------------------------------

module hispi_if  #(
	parameter	SER_FIRST_BIT		= "LSB"		,	//"LSB" or "MSB" , first bit to the receiver
	parameter	END_STYLE			= "LITTLE"	,	//"LITTLE" or "BIG" , "LITTLE" - {CHANNEL3 CHANNE2 CHANNEL1 CHANNEL0}. "BIG" - {CHANNEL0 CHANNEL1 CHANNEL2 CHANNEL3}.
	parameter	SENSOR_DAT_WIDTH	= 12		,	//sensor ���ݿ��
	parameter	RATIO				= 6			,	//�⴮����
	parameter	CHANNEL_NUM			= 4				//sensor ͨ������
	)
	(
	input										clk						,	//ʱ��
	input										reset					,	//��λ
	input	[RATIO*CHANNEL_NUM-1:0]				iv_data					,	//���벢������
	input										i_bitslip_en			,	//bitslipʹ������
	output										o_bitslip				,	//bitslip��λʹ��
	output										o_data_valid			,	//�⴮��������ź�
	output										o_first_frame_detect	,	//��⵽��һ������֡
	input	[15:0]								iv_line_length			,	//����Ч���ݵĳ���
	output										o_clk_en				,	//ʱ��ʹ���ź�
	output										o_fval					,	//������ź�
	output										o_lval					,	//������ź�
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	ov_pix_data					//�����������
	);

	//  -------------------------------------------------------------------------------------
	//  �����������źš�����
	//  -------------------------------------------------------------------------------------
	wire												w_data_valid	;
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]			wv_data_bitslip	;
	wire												w_clk_en		;


	//  -------------------------------------------------------------------------------------
	//  ����bitslipģ��
	//  -------------------------------------------------------------------------------------
	bitslip # (
	.SER_FIRST_BIT		(SER_FIRST_BIT		),
	.END_STYLE			(END_STYLE			),
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	),	//sensor��������λ��
	.RATIO				(RATIO				),	//�⴮����
	.CHANNEL_NUM		(CHANNEL_NUM		)	//ͨ����
	)
	bitslip_inst (
	.clk				(clk				),	//���벢��ʱ��
	.reset				(reset				),	//��λ�ź�
	.iv_data			(iv_data			),	//���벢������
	.iv_line_length		(iv_line_length		),	//������
	.i_bitslip_en		(i_bitslip_en		),	//bitslipʹ�ܣ��ߵ�ƽʱ���ж������
	.o_bitslip			(o_bitslip			),	//bitslip����
	.o_data_valid		(w_data_valid		),	//ͨ��������Ч�ź�
	.o_clk_en			(w_clk_en			),
	.ov_data			(wv_data_bitslip	)
	);
	assign	o_data_valid	= w_data_valid;

	//  -------------------------------------------------------------------------------------
	//  ����HiSPi����ģ��
	//  -------------------------------------------------------------------------------------
	hispi_receiver # (
	.SER_FIRST_BIT				(SER_FIRST_BIT			),
	.END_STYLE					(END_STYLE				),
	.SENSOR_DAT_WIDTH			(SENSOR_DAT_WIDTH		),
	.CHANNEL_NUM				(CHANNEL_NUM			)
	)
	hispi_receiver_inst (
	.clk						(clk					),
	.reset						(reset					),
	.i_clk_en					(w_clk_en				),
	.i_data_valid				(w_data_valid			),
	.iv_data					(wv_data_bitslip		),
	.i_bitslip_en				(i_bitslip_en			),
	.o_first_frame_detect		(o_first_frame_detect	),
	.o_clk_en					(o_clk_en				),
	.o_fval						(o_fval					),
	.o_lval						(o_lval					),
	.ov_pix_data				(ov_pix_data			)
	);




endmodule