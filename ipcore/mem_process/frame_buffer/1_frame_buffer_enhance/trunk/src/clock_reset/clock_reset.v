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
	output			clk_pix				,	//��������ʱ�ӣ�72Mhz
	output			reset_pix			,	//��������ʱ�ӵĸ�λ�ź�
	//sensor
	output			o_clk_sensor		,	//Sensor��ʱ�ӣ�20Mhz����40M����������������MT9P031�ֲᣬ�ڸ�λ��ʱ��Sensor��Ҫ����ʱ��
	output			o_reset_senser_n	,	//Sensor�ĸ�λ�źţ�����Ч��1ms��ȣ�FPGA������ɺ������������������в���λSensor
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
	parameter	DDR3_PLL_CLKOUT3_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 5	: ((DDR3_MEMCLK_FREQ==360) ? 4	: ((DDR3_MEMCLK_FREQ==330) ? 7	: ((DDR3_MEMCLK_FREQ==320) ? 7	: 7)));
	parameter	DDR3_PLL_CLKOUT4_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 5	: ((DDR3_MEMCLK_FREQ==360) ? 5	: ((DDR3_MEMCLK_FREQ==330) ? 8	: ((DDR3_MEMCLK_FREQ==320) ? 5	: 5)));
	parameter	DDR3_PLL_CLKOUT5_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 5	: ((DDR3_MEMCLK_FREQ==360) ? 5	: ((DDR3_MEMCLK_FREQ==330) ? 8	: ((DDR3_MEMCLK_FREQ==320) ? 5	: 5)));
	parameter	DDR3_PLL_CLKFBOUT_MULT	= (DDR3_MEMCLK_FREQ==400) ? 20	: ((DDR3_MEMCLK_FREQ==360) ? 18	: ((DDR3_MEMCLK_FREQ==330) ? 33	: ((DDR3_MEMCLK_FREQ==320) ? 16	: 16)));
	parameter	DDR3_PLL_DIVCLK_DIVIDE	= (DDR3_MEMCLK_FREQ==400) ? 1	: ((DDR3_MEMCLK_FREQ==360) ? 1	: ((DDR3_MEMCLK_FREQ==330) ? 2	: ((DDR3_MEMCLK_FREQ==320) ? 1	: 1)));

	wire				clk_osc_ibufg		;
	reg		[3:0]		pwr_cnt				= 4'b0;
	wire				pwr_reset			;
	wire				clk_sensor			;
	wire				dcm72_locked		;
	wire				dcm100_locked		;
	reg		[16:0]		reset_cnt_sensor	= 17'b0;
	wire				dcm72_locked_inv	;
	wire				dcm100_locked_inv	;
	wire				reset_u3_interface_int	;
	wire				clk_gpif_inv		;
	wire				clk_sensor_inv		;


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
	//	�پ���bufg������
	//  -------------------------------------------------------------------------------------
	BUFG bufg_osc_inst (
	.I	(clk_osc_ibufg	),
	.O	(clk_osc_bufg	)
	);

	//  -------------------------------------------------------------------------------------
	//	�ϵ縴λ�߼�
	//	1.fpga ���سɹ�֮�󣬻�� dcm pll������λ�źţ���λ�źſ����8��ʱ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_osc_bufg) begin
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
	.sys_clk				(clk_osc_bufg				),
	.sys_rst				(pwr_reset					),
	.async_rst				(async_rst					),
	.sysclk_2x				(sysclk_2x					),
	.sysclk_2x_180			(sysclk_2x_180				),
	.pll_ce_0				(pll_ce_0					),
	.pll_ce_90				(pll_ce_90					),
	.mcb_drp_clk			(mcb_drp_clk				),
	.bufpll_mcb_lock		(bufpll_mcb_lock			),
	.pll_lock				(					),
	.clk_out3				(					),
	.clk_out4				(					),
	.clk_out5				(					)
	);

	//  -------------------------------------------------------------------------------------
	//	-- ref DCM72
	//	clk0	- 40MHz	����DCM�����������߼�δ�õ�
	//	clkfx	- 72MHz ����ʱ��
	//	clkdv	- 20MHz �����Sensor��ʱ��
	//  -------------------------------------------------------------------------------------
	dcm72 dcm72_inst (
	.clk_in		(clk_osc_bufg	),
	.dcm_reset	(pwr_reset		),
	.clk0_out	(				),
	.clk_fx_out	(clk_pix		),
	.clk_dv_out	(clk_sensor		),
	.locked		(dcm72_locked	)
	);
	assign	dcm72_locked_inv	= !dcm72_locked;
	assign	clk_sensor_inv		= !clk_sensor;

	//  -------------------------------------------------------------------------------------
	//	-- ref DCM100
	//	clkfx	- 100MHz gpifʱ�ӡ�frame_bufgʱ�ӡ�Ŀǰ������ʱ����ϲ�Ϊ1���������������ϻ���2��
	//  -------------------------------------------------------------------------------------
	dcm100 dcm100_inst (
	.clk_in		(clk_osc_bufg	),
	.dcm_reset	(pwr_reset		),
	.clk_fx_out	(clk_gpif		),
	.locked		(dcm100_locked	)
	);
	assign	dcm100_locked_inv	= !dcm100_locked;
	assign	clk_gpif_inv		= !clk_gpif;

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
	.reset_in	(dcm72_locked_inv	),
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
	.reset_in	(dcm72_locked_inv	),
	.enable		(1'b1				),
	.reset_out	(reset_pix			)
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
	.R					(1'b0			),// 1-bit reset input
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
	//	40MHz��ʱ�ӣ�������25ns��1ms��׼ȷ����ֵ��0x9c40��Ϊ�˼���ƣ�ֻ�ж�bit16��������0x10000�൱����ʱ��1.638ms
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_osc_bufg) begin
		if(i_reset_sensor) begin
			reset_cnt_sensor	<= 'b0;
		end
		else if(reset_cnt_sensor[16] == 1'b1) begin
			reset_cnt_sensor	<= reset_cnt_sensor;
		end
		else begin
			reset_cnt_sensor	<= reset_cnt_sensor + 1'b1;
		end
	end
	assign	o_reset_senser_n	= reset_cnt_sensor[16];

	//  ===============================================================================================
	//	ref ***����***
	//  ===============================================================================================
	assign	clk_frame_buf		= clk_gpif		;
	assign	reset_frame_buf		= reset_gpif	;
	assign	o_sensor_reset_done	= o_reset_senser_n	;





endmodule
