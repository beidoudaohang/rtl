//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : clock_reset
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/6/5 14:07:54	:|  ��ʼ�汾
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

module clock_reset # (
	parameter		DDR3_MEMCLK_FREQ	= 320	//Memory data transfer clock frequency DDR3-640:3125 DDR3-660:3030 DDR3-720:2778 DDR3-800:2500
	)
	(
	//  -------------------------------------------------------------------------------------
	//	�ⲿ��������
	//  -------------------------------------------------------------------------------------
	input			clk_osc				,	//�������ţ�40MHz�����ⲿ����
	//  -------------------------------------------------------------------------------------
	//	�Ĵ����ź�
	//  -------------------------------------------------------------------------------------
	input			i_reset_sensor		,	//clk_osc_bufgʱ���򣬸�λsensorʹ���źţ�1��ʱ�����ڿ��
	input			i_stream_enable		,	//clk_gpifʱ�����������źţ�û����Чʱ����ͣ��ʱ��λu3 interfaceģ�顣
	//  -------------------------------------------------------------------------------------
	//	ʱ�Ӹ�λ���
	//  -------------------------------------------------------------------------------------
	//����ȫ�ֻ����ԭʼʱ��
	output			clk_osc_bufg		,	//40MHzʱ�ӣ�ȫ�ֻ�������
	output			reset_osc_bufg		,	//40MHzʱ�ӵĸ�λ�ź�
	//mcb
	output			async_rst			,	//�첽��λ��ֻ�ṩ��MCB
	output			sysclk_2x			,	//����ʱ�ӣ�ֻ�ṩ��MCB
	output			sysclk_2x_180		,	//����ʱ�ӣ�ֻ�ṩ��MCB
	output 			pll_ce_0			,	//����Ƭѡ��ֻ�ṩ��MCB
	output 			pll_ce_90			,	//����Ƭѡ��ֻ�ṩ��MCB
	output			mcb_drp_clk			,	//calib�߼�ʱ�ӣ�ֻ�ṩ��MCB
	output			bufpll_mcb_lock		,	//bufpll_mcb �����źţ�ֻ�ṩ��MCB
	//frame buf
	output			clk_frame_buf		,	//֡��ʱ�ӣ���gpifʱ����ͬһ��Դͷ��Ϊ�˱�֤ģ������ԣ�֡�滹��ʹ�õ�����ʱ������
	output			reset_frame_buf		,	//֡��ʱ�ӵĸ�λ�źţ���gpifʱ����ĸ�λ�ź���ͬһ��Դͷ
	//data channel
	output			clk_pix				,	//��������ʱ�ӣ�55Mhz
	output			reset_pix			,	//��������ʱ�ӵĸ�λ�ź�
	output			clk_pix_2x			,	//����ʱ�ӣ�110Mhz
	output			reset_pix_2x		,	//��������ʱ�ӵĸ�λ�ź�
	//sensor
	output			o_clk_sensor		,	//Sensor��ʱ�ӣ�20Mhz����40M����������
	output			o_sensor_reset_n	,	//Sensor�ĸ�λ�źţ�����Ч��1ms��ȣ�FPGA������ɺ������������������в���λSensor
	output			o_sensor_reset_done	,	//sensor��λ����źţ����̼���ѯ���̼���ѯ���ñ�־���ܸ�λ
	//usb
	output			o_clk_usb_pclk		,	//fx3014 gpif ʱ��
	output			clk_gpif			,	//gpif ʱ�ӣ�100MHz
	output			reset_gpif			,	//gpif ʱ�ӵĸ�λ�ź�
	output			reset_u3_interface		//u3 interface ģ�鸴λ
	);

	//	ref signals

	//PLL�Ĳ���
	parameter	DDR3_PLL_CLKIN_PERIOD	= 25000;
	parameter	DDR3_PLL_CLKOUT0_DIVIDE	= 1;
	parameter	DDR3_PLL_CLKOUT1_DIVIDE	= 1;
	parameter	DDR3_PLL_CLKOUT2_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 16	: ((DDR3_MEMCLK_FREQ==360) ? 16	: ((DDR3_MEMCLK_FREQ==330) ? 16	: ((DDR3_MEMCLK_FREQ==320) ? 16	: 16)));
	parameter	DDR3_PLL_CLKOUT3_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 5	: ((DDR3_MEMCLK_FREQ==360) ? 4	: ((DDR3_MEMCLK_FREQ==330) ? 5	: ((DDR3_MEMCLK_FREQ==320) ? 5	: 5)));
	parameter	DDR3_PLL_CLKOUT4_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 5	: ((DDR3_MEMCLK_FREQ==360) ? 5	: ((DDR3_MEMCLK_FREQ==330) ? 8	: ((DDR3_MEMCLK_FREQ==320) ? 5	: 5)));
	parameter	DDR3_PLL_CLKOUT5_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 5	: ((DDR3_MEMCLK_FREQ==360) ? 5	: ((DDR3_MEMCLK_FREQ==330) ? 8	: ((DDR3_MEMCLK_FREQ==320) ? 5	: 5)));
	parameter	DDR3_PLL_CLKFBOUT_MULT	= (DDR3_MEMCLK_FREQ==400) ? 20	: ((DDR3_MEMCLK_FREQ==360) ? 18	: ((DDR3_MEMCLK_FREQ==330) ? 33	: ((DDR3_MEMCLK_FREQ==320) ? 16	: 16)));
	parameter	DDR3_PLL_DIVCLK_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 1	: ((DDR3_MEMCLK_FREQ==360) ? 1	: ((DDR3_MEMCLK_FREQ==330) ? 2	: ((DDR3_MEMCLK_FREQ==320) ? 1	: 1)));

	wire				clk_osc_ibufg		;
	wire				clk_osc_bufio2		;
	reg		[3:0]		pwr_cnt				= 4'b0;
	wire				pwr_reset			;
	wire				clk_sensor			;
	wire				dcm_pix_locked		;
	wire				dcm100_locked		;
	wire				clk_sensor_ouput_reset	;
	wire				dcm_pix_locked_inv	;
	wire				dcm100_locked_inv	;
	wire				reset_u3_interface_int	;
	wire				clk_gpif_inv		;
	wire				clk_sensor_inv		;

	wire				pll_lock		;
	wire				pll_lock_inv	;

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***����ʱ�Ӻ��ϵ縴λ***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	�Ⱦ���ibufg������
	//  -------------------------------------------------------------------------------------
	IBUFG ibufg_osc_inst (
	.I	(clk_osc		),
	.O	(clk_osc_ibufg	)
	);

	//  -------------------------------------------------------------------------------------
	//	�پ���bufio2��������20MHz
	//  -------------------------------------------------------------------------------------
	BUFIO2 #(
	.DIVIDE			(1				),	// DIVCLK divider (1,3-8)
	.DIVIDE_BYPASS	("TRUE"			),	// Bypass the divider circuitry (TRUE/FALSE)
	.I_INVERT		("FALSE"		),	// Invert clock (TRUE/FALSE)
	.USE_DOUBLER	("FALSE"		)	// Use doubler circuitry (TRUE/FALSE)
	)
	BUFIO2_inst (
	.I				(clk_osc_ibufg	),	// 1-bit input: Clock input (connect to IBUFG)
	.DIVCLK			(clk_osc_bufio2	),	// 1-bit output: Divided clock output
	.IOCLK			(				),	// 1-bit output: I/O output clock
	.SERDESSTROBE	(				)	// 1-bit output: Output SERDES strobe (connect to ISERDES2/OSERDES2)
	);

	//  -------------------------------------------------------------------------------------
	//	�ϵ縴λ�߼�
	//	1.fpga ���سɹ�֮�󣬻�� dcm pll������λ�źţ���λ�źſ����8��ʱ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_osc_ibufg) begin
		if(pwr_cnt[3] == 1'b0) begin
			pwr_cnt	<= pwr_cnt + 1'b1;
		end
	end
	assign	pwr_reset	= !pwr_cnt[3];

	//  ===============================================================================================
	//	ref ***PLL & DCM***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref ddr3 pll
	//	1.��PLL��Ҫ��������MCB����Ҫ��ʱ�ӣ� sysclk_2x sysclk_2x_180 �Ǹ���ʱ�ӣ���ͨ�߼�������
	//	2.mcb_drp_clk ������ʱ�ӣ�MCB�е�Calibration�߼�ʹ�õ�ʱ�ӣ����Ƶ�ʿ��Դﵽ100MHz���ң������߼�Ҳ����ʹ��
	//	3.clk_out3 4 5 ��PLL����������˿ڣ�Ŀǰû���õ�
	//  -------------------------------------------------------------------------------------
	infrastructure # (
	.C_INCLK_PERIOD  		(DDR3_PLL_CLKIN_PERIOD		),
	.C_CLKOUT0_DIVIDE		(DDR3_PLL_CLKOUT0_DIVIDE	),
	.C_CLKOUT1_DIVIDE		(DDR3_PLL_CLKOUT1_DIVIDE	),
	.C_CLKOUT2_DIVIDE		(DDR3_PLL_CLKOUT2_DIVIDE	),
	.C_CLKOUT3_DIVIDE		(DDR3_PLL_CLKOUT3_DIVIDE	),
	.C_CLKOUT4_DIVIDE		(DDR3_PLL_CLKOUT4_DIVIDE	),
	.C_CLKOUT5_DIVIDE		(DDR3_PLL_CLKOUT5_DIVIDE	),
	.C_CLKFBOUT_MULT 		(DDR3_PLL_CLKFBOUT_MULT		),
	.C_DIVCLK_DIVIDE 		(DDR3_PLL_DIVCLK_DIVIDE		)
	)
	ddr3_pll_inst (
	.sys_clk				(clk_osc_bufio2				),
	.sys_rst				(pwr_reset					),
	.async_rst				(async_rst					),
	.sysclk_2x				(sysclk_2x					),
	.sysclk_2x_180			(sysclk_2x_180				),
	.pll_ce_0				(pll_ce_0					),
	.pll_ce_90				(pll_ce_90					),
	.mcb_drp_clk			(mcb_drp_clk				),
	.bufpll_mcb_lock		(bufpll_mcb_lock			),
	.pll_lock				(pll_lock					),
	.clk_out3				(							),
	.clk_out4				(							),
	.clk_out5				(							)
	);
	assign	pll_lock_inv	= !pll_lock;

	//  -------------------------------------------------------------------------------------
	//	-- ref DCM55
	//	clk0	- 40MHz	����DCM�����������߼�δ�õ�
	//	clkfx	- 55MHz ����ʱ��
	//  -------------------------------------------------------------------------------------
	dcm_pix dcm_pix_inst (
	.clk_in			(clk_osc_bufio2	),
	.dcm_reset		(pwr_reset		),
	.clk_fx_out		(clk_pix_2x		),
	.clk_fxdv_out	(clk_pix		),
	.locked			(dcm_pix_locked	)
	);
	assign	dcm_pix_locked_inv	= !dcm_pix_locked;

	//  -------------------------------------------------------------------------------------
	//	-- ref DCM100
	//	clkfx	- 100MHz gpifʱ�ӡ�frame_bufgʱ�ӡ�Ŀǰ������ʱ����ϲ�Ϊ1���������������ϻ���2��
	//  -------------------------------------------------------------------------------------
	dcm100 dcm100_inst (
	.clk_in			(clk_osc_bufio2	),//40MHz
	.dcm_reset		(pwr_reset		),
	.clk_fx_out		(clk_gpif		),//100MHz
	.clk_0_out		(clk_osc_bufg	),//40MHz
	.clk_dv_out		(clk_sensor		),//20MHz
	.locked			(dcm100_locked	)
	);
	assign	dcm100_locked_inv	= !dcm100_locked;
	assign	clk_gpif_inv		= !clk_gpif;
	assign	clk_frame_buf		= clk_gpif;
	assign	clk_sensor_inv		= !clk_sensor;

	//  ===============================================================================================
	//	ref ***��λ����***
	//	1.�����첽��λ��ͬ���ͷŵĴ�����
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	clk_osc_bufgʱ����λ
	//  -------------------------------------------------------------------------------------
	reset_sync # (
	.INITIALISE	(2'b11	)
	)
	reset_sync_osc_inst (
	.clk		(clk_osc_bufg		),
	.reset_in	(dcm100_locked_inv	),
	.enable		(1'b1				),
	.reset_out	(reset_osc_bufg		)
	);

	//  -------------------------------------------------------------------------------------
	//	clk_pixʱ����λ
	//  -------------------------------------------------------------------------------------
	reset_sync # (
	.INITIALISE	(2'b11	)
	)
	reset_sync_pix_inst (
	.clk		(clk_pix			),
	.reset_in	(dcm_pix_locked_inv	),
	.enable		(1'b1				),
	.reset_out	(reset_pix			)
	);

	//  -------------------------------------------------------------------------------------
	//	clk_pix_2xʱ����λ
	//  -------------------------------------------------------------------------------------
	reset_sync # (
	.INITIALISE	(2'b11	)
	)
	reset_sync_pix_2x_inst (
	.clk		(clk_pix_2x			),
	.reset_in	(dcm_pix_locked_inv	),
	.enable		(1'b1				),
	.reset_out	(reset_pix_2x		)
	);
	//  -------------------------------------------------------------------------------------
	//	clk_gpifʱ����λ
	//  -------------------------------------------------------------------------------------
	reset_sync # (
	.INITIALISE	(2'b11	)
	)
	reset_sync_gpif_inst (
	.clk		(clk_gpif			),
	.reset_in	(dcm100_locked_inv	),
	.enable		(1'b1				),
	.reset_out	(reset_gpif			)
	);
	assign	reset_frame_buf	= reset_gpif;

	//  -------------------------------------------------------------------------------------
	//	u3_interfaceģ�鸴λ
	//	1.����ֹͣ����DCMʧ����ʱ�򣬸�λ��Ч
	//  -------------------------------------------------------------------------------------
	assign	reset_u3_interface_int	= (i_stream_enable==1'b0 || dcm100_locked==1'b0) ? 1'b1 : 1'b0;
	reset_sync # (
	.INITIALISE	(2'b11	)
	)
	reset_sync_u3_inst (
	.clk		(clk_gpif				),
	.reset_in	(reset_u3_interface_int	),
	.enable		(1'b1					),
	.reset_out	(reset_u3_interface		)
	);

	//  ===============================================================================================
	//	ref ***ʱ�����***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	20MHz��sensorʱ�����
	//  -------------------------------------------------------------------------------------
	ODDR2 # (
	.DDR_ALIGNMENT		("C0"			),// Sets output alignment to "NONE", "C0" or "C1"
	.INIT				(1'b0			),// Sets initial state of the Q output to 1'b0 or 1'b1
	.SRTYPE				("ASYNC"		)// Specifies "SYNC" or "ASYNC" set/reset
	)
	ODDR2_clk_sensor_inst (
	.Q					(o_clk_sensor	),// 1-bit DDR output data
	.C0					(clk_sensor_inv	),// 1-bit clock input
	.C1					(clk_sensor		),// 1-bit clock input
	.CE					(1'b1			),// 1-bit clock enable input
	.D0					(1'b0			),// 1-bit data input (associated with C0)
	.D1					(1'b1			),// 1-bit data input (associated with C1)
	.R					(clk_sensor_ouput_reset	),// 1-bit reset input
	.S					(1'b0			)// 1-bit set input
	);

	//  -------------------------------------------------------------------------------------
	//	100MHz �� usb gpif ʱ��
	//	1.���ʱ�� o_clk_usb_pclk �� C0����λ����
	//	2.C0��clk_gpif�ķ����źţ���� o_clk_usb_pclk �� clk_gpif �Ƿ����
	//	3.3014���������ز����������FPGA���ʱ��Ҫ��ʱ�ӷ���
	//  -------------------------------------------------------------------------------------
	ODDR2 # (
	.DDR_ALIGNMENT	("C0"			),	// Sets output alignment to "NONE", "C0" or "C1"
	.INIT			(1'b0			),  // Sets initial state of the Q output to 1'b0 or 1'b1
	.SRTYPE			("ASYNC"		)	// Specifies "SYNC" or "ASYNC" set/reset
	)
	ODDR2_txc_inst (
	.Q				(o_clk_usb_pclk	),// 1-bit DDR output data
	.C0				(clk_gpif_inv	),// 1-bit clock input
	.C1				(clk_gpif		),// 1-bit clock input
	.CE				(1'b1			),// 1-bit clock enable input
	.D0				(1'b1			),// 1-bit data input (associated with C0)
	.D1				(1'b0			),// 1-bit data input (associated with C1)
	.R				(1'b0			),// 1-bit reset input
	.S				(1'b0			)// 1-bit set input
	);

	//  ===============================================================================================
	//	ref ***��λ���***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	�ֲ�Ҫ��
	//                        __________________________________________________
	//	POWER   ______________|
	//                        !
	//                        !              !         !
	//                        !              ! >=100us !___  ____  ____  ____  ____
	//	INCK    ______________!______________!_________|  |__|  |__|  |__|  |__|  |__
	//                        !              !         !
	//                        ! 200us-500ms  !_________!_____________________________
	//	XSHUTDOWN_____________!______________|         !
	//                        !              !         !   >=20us  !
	//          _______________________________________!___________!
	//	XCE                                            !           |_________________
	//                                                 !           !
	//                                                 !           !
	//
	//  -------------------------------------------------------------------------------------
	sensor_reset  # (
	.CLOCL_FREQ_MHZ				(20		),	//ʱ�ӵ�Ƶ�ʣ�Mhz
	.SENSOR_HARD_RESET_TIME		(1000	),	//senosrӲ����λʱ�䣬us
	.SENSOR_CLK_DELAY_TIME		(200	),	//Ӳ����λ����֮��sensorʱ�ӵĵȴ�ʱ�䣬us
	.SENSOR_INITIAL_DONE_TIME	(2950	)	//Ӳ����λ����֮��ĵȴ�ʱ�䣬us
	)
	sensor_reset_inst
	(
	.clk						(clk_sensor					),	//����ʱ��
	.reset						(reset_sensor				),	//��λ�ź�
	.i_sensor_reset				(i_reset_sensor				),	//�̼����ĸ�λ����
	.o_sensor_reset_n			(o_sensor_reset_n			),	//�����sensorӲ����λ�ź�
	.o_clk_sensor_ouput_reset	(clk_sensor_ouput_reset		),	//ʱ�����ʹ��
	.o_sensor_initial_done		(o_sensor_reset_done		)	//�����sensor�ڲ���ʼ������ź�
	);



endmodule