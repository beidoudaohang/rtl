//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : clock_reset
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/6/5 14:07:54	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module clock_reset # (
	parameter		DDR3_MEMCLK_FREQ	= 320	//Memory data transfer clock frequency DDR3-640:3125 DDR3-660:3030 DDR3-720:2778 DDR3-800:2500
	)
	(
	//  -------------------------------------------------------------------------------------
	//	外部晶振输入
	//  -------------------------------------------------------------------------------------
	input			clk_osc				,	//输入引脚，40MHz，接外部晶振
	//  -------------------------------------------------------------------------------------
	//	寄存器信号
	//  -------------------------------------------------------------------------------------
	input			i_reset_sensor		,	//clk_osc_bufg时钟域，复位sensor使能信号，1个时钟周期宽度
	input			i_stream_enable		,	//clk_gpif时钟域，流开采信号，没有生效时机。停采时复位u3 interface模块。
	//  -------------------------------------------------------------------------------------
	//	时钟复位输出
	//  -------------------------------------------------------------------------------------
	//经过全局缓冲的原始时钟
	output			clk_osc_bufg		,	//40MHz时钟，全局缓冲驱动
	output			reset_osc_bufg		,	//40MHz时钟的复位信号
	//mcb
	output			async_rst			,	//异步复位，只提供给MCB
	output			sysclk_2x			,	//高速时钟，只提供给MCB
	output			sysclk_2x_180		,	//高速时钟，只提供给MCB
	output 			pll_ce_0			,	//高速片选，只提供给MCB
	output 			pll_ce_90			,	//高速片选，只提供给MCB
	output			mcb_drp_clk			,	//calib逻辑时钟，只提供给MCB
	output			bufpll_mcb_lock		,	//bufpll_mcb 锁定信号，只提供给MCB
	//frame buf
	output			clk_frame_buf		,	//帧存时钟，与gpif时钟是同一个源头，为了保证模块独立性，帧存还是使用单独的时钟名称
	output			reset_frame_buf		,	//帧存时钟的复位信号，与gpif时钟域的复位信号是同一个源头
	//data channel
	output			clk_pix				,	//本地像素时钟，55Mhz
	output			reset_pix			,	//本地像素时钟的复位信号
	output			clk_pix_2x			,	//本地时钟，110Mhz
	output			reset_pix_2x		,	//本地像素时钟的复位信号
	//sensor
	output			o_clk_sensor		,	//Sensor的时钟，20Mhz，由40M晶振分配而来
	output			o_sensor_reset_n	,	//Sensor的复位信号，低有效，1ms宽度，FPGA配置完成后立即输出。相机运行中不复位Sensor
	output			o_sensor_reset_done	,	//sensor复位完成信号，供固件查询，固件查询到该标志才能复位
	//usb
	output			o_clk_usb_pclk		,	//fx3014 gpif 时钟
	output			clk_gpif			,	//gpif 时钟，100MHz
	output			reset_gpif			,	//gpif 时钟的复位信号
	output			reset_u3_interface		//u3 interface 模块复位
	);

	//	ref signals

	//PLL的参数
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
	//	ref ***输入时钟和上电复位***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	先经过ibufg缓冲器
	//  -------------------------------------------------------------------------------------
	IBUFG ibufg_osc_inst (
	.I	(clk_osc		),
	.O	(clk_osc_ibufg	)
	);

	//  -------------------------------------------------------------------------------------
	//	再经过bufio2缓冲器，20MHz
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
	//	上电复位逻辑
	//	1.fpga 加载成功之后，会对 dcm pll产生复位信号，复位信号宽度是8个时钟周期
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
	//	1.该PLL主要用于生成MCB所需要的时钟， sysclk_2x sysclk_2x_180 是高速时钟，普通逻辑不可用
	//	2.mcb_drp_clk 是慢速时钟，MCB中的Calibration逻辑使用的时钟，最高频率可以达到100MHz左右，其他逻辑也可以使用
	//	3.clk_out3 4 5 是PLL的其他输出端口，目前没有用到
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
	//	clk0	- 40MHz	用于DCM反馈，其他逻辑未用到
	//	clkfx	- 55MHz 像素时钟
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
	//	clkfx	- 100MHz gpif时钟、frame_bufg时钟。目前这两个时钟域合并为1个，但是在命名上还是2个
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
	//	ref ***复位管理***
	//	1.采用异步复位、同步释放的处理方法
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	clk_osc_bufg时钟域复位
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
	//	clk_pix时钟域复位
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
	//	clk_pix_2x时钟域复位
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
	//	clk_gpif时钟域复位
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
	//	u3_interface模块复位
	//	1.当流停止或者DCM失锁的时候，复位有效
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
	//	ref ***时钟输出***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	20MHz的sensor时钟输出
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
	//	100MHz 的 usb gpif 时钟
	//	1.输出时钟 o_clk_usb_pclk 与 C0的相位对齐
	//	2.C0是clk_gpif的反向信号，因此 o_clk_usb_pclk 与 clk_gpif 是反向的
	//	3.3014是在上升沿采样，因此在FPGA输出时，要对时钟反向
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
	//	ref ***复位输出***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	手册要求
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
	.CLOCL_FREQ_MHZ				(20		),	//时钟的频率，Mhz
	.SENSOR_HARD_RESET_TIME		(1000	),	//senosr硬件复位时间，us
	.SENSOR_CLK_DELAY_TIME		(200	),	//硬件复位结束之后，sensor时钟的等待时间，us
	.SENSOR_INITIAL_DONE_TIME	(2950	)	//硬件复位结束之后的等待时间，us
	)
	sensor_reset_inst
	(
	.clk						(clk_sensor					),	//输入时钟
	.reset						(reset_sensor				),	//复位信号
	.i_sensor_reset				(i_reset_sensor				),	//固件给的复位命令
	.o_sensor_reset_n			(o_sensor_reset_n			),	//输出的sensor硬件复位信号
	.o_clk_sensor_ouput_reset	(clk_sensor_ouput_reset		),	//时钟输出使能
	.o_sensor_initial_done		(o_sensor_reset_done		)	//输出的sensor内部初始化完成信号
	);



endmodule