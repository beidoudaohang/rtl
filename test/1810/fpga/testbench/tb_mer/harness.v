//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : harness
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/9 17:18:50	:|  初始版本
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
`define		TESTCASE	testcase_1
module harness ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	parameter	SENSOR_DAT_WIDTH			= `TESTCASE.SENSOR_DAT_WIDTH			;
	parameter	PHY_NUM						= `TESTCASE.PHY_NUM						;
	parameter	PHY_CH_NUM					= `TESTCASE.PHY_CH_NUM					;
	parameter	PIX_CLK_FREQ_KHZ			= `TESTCASE.PIX_CLK_FREQ_KHZ			;
	parameter	BAYER_PATTERN				= `TESTCASE.BAYER_PATTERN				;
	parameter	SENSOR_MAX_WIDTH			= `TESTCASE.SENSOR_MAX_WIDTH			;
//	parameter	SENSOR_MAX_LENGTH			= `TESTCASE.SENSOR_MAX_LENGTH			;
	parameter	SENSOR_MAX_HEIGHT			= `TESTCASE.SENSOR_MAX_HEIGHT			;
	parameter	SHORT_LINE_LENGTH_PCK		= `TESTCASE.SHORT_LINE_LENGTH_PCK		;
	parameter	DIFF_TERM					= `TESTCASE.DIFF_TERM					;
	parameter	IOSTANDARD					= `TESTCASE.IOSTANDARD					;
	parameter	SER_FIRST_BIT				= `TESTCASE.SER_FIRST_BIT				;
	parameter	END_STYLE					= `TESTCASE.END_STYLE					;
	parameter	SER_DATA_RATE				= `TESTCASE.SER_DATA_RATE				;
	parameter	DESER_CLOCK_ARC				= `TESTCASE.DESER_CLOCK_ARC			;
	parameter	DESER_WIDTH					= `TESTCASE.DESER_WIDTH				;
	parameter	CLKIN_PERIOD_PS				= `TESTCASE.CLKIN_PERIOD_PS			;
	parameter	DATA_DELAY_TYPE				= `TESTCASE.DATA_DELAY_TYPE			;
	parameter	DATA_DELAY_VALUE			= `TESTCASE.DATA_DELAY_VALUE			;
	parameter	BITSLIP_ENABLE				= `TESTCASE.BITSLIP_ENABLE				;
	parameter	PLL_RESET_SIMULATION		= `TESTCASE.PLL_RESET_SIMULATION		;
//	parameter	DESER_CLK_FREQ_KHZ			= `TESTCASE.DESER_CLK_FREQ_KHZ			;
	parameter	NUM_DQ_PINS					= `TESTCASE.NUM_DQ_PINS				;
	parameter	MEM_ADDR_WIDTH				= `TESTCASE.MEM_ADDR_WIDTH				;
	parameter	MEM_BANKADDR_WIDTH			= `TESTCASE.MEM_BANKADDR_WIDTH			;
	parameter	DDR3_MEMCLK_FREQ			= `TESTCASE.DDR3_MEMCLK_FREQ			;
	parameter	MEM_ADDR_ORDER				= `TESTCASE.MEM_ADDR_ORDER				;
	parameter	DDR3_RST_ACT_LOW			= `TESTCASE.DDR3_RST_ACT_LOW			;
	parameter	DDR3_MEM_DENSITY			= `TESTCASE.DDR3_MEM_DENSITY			;
	parameter	DDR3_TCK_SPEED				= `TESTCASE.DDR3_TCK_SPEED				;
	parameter	DDR3_SIMULATION				= `TESTCASE.DDR3_SIMULATION			;
	parameter	DDR3_P0_MASK_SIZE			= `TESTCASE.DDR3_P0_MASK_SIZE			;
	parameter	DDR3_P1_MASK_SIZE			= `TESTCASE.DDR3_P1_MASK_SIZE			;
	parameter	DDR3_CALIB_SOFT_IP			= `TESTCASE.DDR3_CALIB_SOFT_IP			;
	parameter	GPIF_DAT_WIDTH				= `TESTCASE.GPIF_DAT_WIDTH				;
	parameter	NUM_GPIO					= `TESTCASE.NUM_GPIO					;

	parameter	DDR3_16_DQ_MCB_8_DQ		= 0   ;
	localparam	DRAM_DQ_WIRE_WIDTH		= (DDR3_16_DQ_MCB_8_DQ==1) ? 16 : NUM_DQ_PINS;

	//	-------------------------------------------------------------------------------------
	//	输出的信号
	//	-------------------------------------------------------------------------------------
	wire	[DRAM_DQ_WIRE_WIDTH-1:0]	mcb1_dram_dq		;
	wire	[MEM_ADDR_WIDTH-1:0]		mcb1_dram_a			;
	wire	[MEM_BANKADDR_WIDTH-1:0]	mcb1_dram_ba		;
	wire								mcb1_dram_ras_n		;
	wire								mcb1_dram_cas_n		;
	wire								mcb1_dram_we_n		;
	wire								mcb1_dram_odt		;
	wire								mcb1_dram_reset_n	;
	wire								mcb1_dram_cke		;
	wire								mcb1_dram_udm		;
	wire								mcb1_dram_dm		;
	wire								mcb1_dram_ck		;
	wire								mcb1_dram_ck_n		;
	wire								mcb1_dram_udqs		;
	wire								mcb1_dram_udqs_n	;
	wire								mcb1_dram_dqs		;
	wire								mcb1_dram_dqs_n		;
	wire								mcb1_rzq			;
	wire								mcb1_zio			;

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	输入
	//	-------------------------------------------------------------------------------------
	wire								clk_osc					;
	wire	[PHY_NUM-1:0]				pix_clk_p					;
	wire	[PHY_NUM-1:0]				pix_clk_n					;
	wire	[PHY_CH_NUM*PHY_NUM-1:0]	iv_pix_data_p				;
	wire	[PHY_CH_NUM*PHY_NUM-1:0]	iv_pix_data_n				;
	wire								i_sensor_strobe			;
	wire								i_usb_flagb_n				;
	wire								i_usb_spi_sck				;
	wire								i_usb_spi_mosi				;
	wire								i_spi_cs_n_fpga			;
	wire								i_optocoupler				;
	wire	[NUM_GPIO-1:0]				iv_gpio					;
	wire								i_flash_hold				;

	//	-------------------------------------------------------------------------------------
	//	输出
	//	-------------------------------------------------------------------------------------
	wire							o_trigger					;
	wire							o_sensor_reset_n			;
	wire							o_clk_sensor				;
	wire							o_clk_usb_pclk				;
	wire	[GPIF_DAT_WIDTH-1:0]	ov_usb_data				;
	wire	[1:0]					ov_usb_fifoaddr			;
	wire							o_usb_slwr_n				;
	wire							o_usb_pktend_n				;
	wire							o_usb_spi_miso				;
	wire							o_optocoupler				;
	wire	[NUM_GPIO-1:0]			ov_gpio					;
	wire							o_f_led_gre				;
	wire							o_f_led_red				;
	wire							o_flash_hold				;
	wire							o_usb_int					;
	wire							o_unused_pin				;
	wire							scl		;
	wire							sda		;

	//	-------------------------------------------------------------------------------------
	//	交互
	//	-------------------------------------------------------------------------------------

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	引入输入信号
	//	-------------------------------------------------------------------------------------
	assign	clk_osc				= `TESTCASE.clk_osc	;
	assign	pix_clk_p			= `TESTCASE.pix_clk_p	;
	assign	pix_clk_n			= `TESTCASE.pix_clk_n	;
	assign	iv_pix_data_p		= `TESTCASE.iv_pix_data_p	;
	assign	iv_pix_data_n		= `TESTCASE.iv_pix_data_n	;
	assign	i_sensor_strobe		= `TESTCASE.i_sensor_strobe	;

	assign	i_usb_spi_sck		= `TESTCASE.i_usb_spi_sck	;
	assign	i_usb_spi_mosi		= `TESTCASE.i_usb_spi_mosi	;
	assign	i_spi_cs_n_fpga		= `TESTCASE.i_spi_cs_n_fpga	;

	assign	i_optocoupler		= `TESTCASE.i_optocoupler	;
	assign	iv_gpio				= `TESTCASE.iv_gpio	;

	assign	i_flash_hold		= `TESTCASE.i_flash_hold	;

	//	-------------------------------------------------------------------------------------
	//	例化 bfm 模块
	//	-------------------------------------------------------------------------------------
	bfm_spi_cmd bfm_spi_cmd ();

	//	-------------------------------------------------------------------------------------
	//	例化 dut buffe 模型
	//	-------------------------------------------------------------------------------------
	mer_1810_21u3x # (
	.SENSOR_DAT_WIDTH			(SENSOR_DAT_WIDTH			),
	.PHY_NUM					(PHY_NUM					),
	.PHY_CH_NUM					(PHY_CH_NUM					),
	.PIX_CLK_FREQ_KHZ			(PIX_CLK_FREQ_KHZ			),
	.BAYER_PATTERN				(BAYER_PATTERN				),
	.SENSOR_MAX_WIDTH			(SENSOR_MAX_WIDTH			),
	.SENSOR_MAX_HEIGHT			(SENSOR_MAX_HEIGHT			),
	.SHORT_LINE_LENGTH_PCK		(SHORT_LINE_LENGTH_PCK		),
	.DIFF_TERM					(DIFF_TERM					),
	.IOSTANDARD					(IOSTANDARD					),
	.SER_FIRST_BIT				(SER_FIRST_BIT				),
	.END_STYLE					(END_STYLE					),
	.SER_DATA_RATE				(SER_DATA_RATE				),
	.DESER_CLOCK_ARC			(DESER_CLOCK_ARC			),
	.DESER_WIDTH				(DESER_WIDTH				),
	.CLKIN_PERIOD_PS			(CLKIN_PERIOD_PS			),
	.DATA_DELAY_TYPE			(DATA_DELAY_TYPE			),
	.DATA_DELAY_VALUE			(DATA_DELAY_VALUE			),
	.BITSLIP_ENABLE				(BITSLIP_ENABLE				),
	.PLL_RESET_SIMULATION		(PLL_RESET_SIMULATION		),

	.NUM_DQ_PINS				(NUM_DQ_PINS				),
	.MEM_ADDR_WIDTH				(MEM_ADDR_WIDTH				),
	.MEM_BANKADDR_WIDTH			(MEM_BANKADDR_WIDTH			),
	.DDR3_MEMCLK_FREQ			(DDR3_MEMCLK_FREQ			),
	.MEM_ADDR_ORDER				(MEM_ADDR_ORDER				),
	.DDR3_RST_ACT_LOW			(DDR3_RST_ACT_LOW			),
	.DDR3_MEM_DENSITY			(DDR3_MEM_DENSITY			),
	.DDR3_TCK_SPEED				(DDR3_TCK_SPEED				),
	.DDR3_SIMULATION			(DDR3_SIMULATION			),
	.DDR3_P0_MASK_SIZE			(DDR3_P0_MASK_SIZE			),
	.DDR3_P1_MASK_SIZE			(DDR3_P1_MASK_SIZE			),
	.DDR3_CALIB_SOFT_IP			(DDR3_CALIB_SOFT_IP			),
	.GPIF_DAT_WIDTH				(GPIF_DAT_WIDTH				),
	.NUM_GPIO					(NUM_GPIO					)
	)
	mer_1810_21u3x_inst (
	.clk_osc					(clk_osc					),
	.pix_clk_p					(pix_clk_p					),
	.pix_clk_n					(pix_clk_n					),
	.iv_pix_data_p				(iv_pix_data_p				),
	.iv_pix_data_n				(iv_pix_data_n				),
	.i_sensor_strobe			(i_sensor_strobe			),
	.o_trigger					(o_trigger					),
	.o_sensor_reset_n			(o_sensor_reset_n			),
	.o_clk_sensor				(o_clk_sensor				),
	.o_clk_usb_pclk				(o_clk_usb_pclk				),
	.ov_usb_data				(ov_usb_data				),
	.ov_usb_fifoaddr			(ov_usb_fifoaddr			),
	.o_usb_slwr_n				(o_usb_slwr_n				),
	.o_usb_pktend_n				(o_usb_pktend_n				),
	.i_usb_flagb_n				(i_usb_flagb_n				),
	.i_usb_spi_sck				(i_usb_spi_sck				),
	.i_usb_spi_mosi				(i_usb_spi_mosi				),
	.i_spi_cs_n_fpga			(i_spi_cs_n_fpga			),
	.o_usb_spi_miso				(o_usb_spi_miso				),
	.i_optocoupler				(i_optocoupler				),
	.iv_gpio					(iv_gpio					),
	.o_optocoupler				(o_optocoupler				),
	.ov_gpio					(ov_gpio					),
	.o_f_led_gre				(o_f_led_gre				),
	.o_f_led_red				(o_f_led_red				),
	.mcb1_dram_dq				(mcb1_dram_dq				),
	.mcb1_dram_a				(mcb1_dram_a				),
	.mcb1_dram_ba				(mcb1_dram_ba				),
	.mcb1_dram_ras_n			(mcb1_dram_ras_n			),
	.mcb1_dram_cas_n			(mcb1_dram_cas_n			),
	.mcb1_dram_we_n				(mcb1_dram_we_n				),
	.mcb1_dram_odt				(mcb1_dram_odt				),
	.mcb1_dram_reset_n			(mcb1_dram_reset_n			),
	.mcb1_dram_cke				(mcb1_dram_cke				),
	.mcb1_dram_dm				(mcb1_dram_dm				),
	.mcb1_dram_udqs				(mcb1_dram_udqs				),
	.mcb1_dram_udqs_n			(mcb1_dram_udqs_n			),
	.mcb1_rzq					(mcb1_rzq					),
	.mcb1_dram_udm				(mcb1_dram_udm				),
	.mcb1_dram_dqs				(mcb1_dram_dqs				),
	.mcb1_dram_dqs_n			(mcb1_dram_dqs_n			),
	.mcb1_dram_ck				(mcb1_dram_ck				),
	.mcb1_dram_ck_n				(mcb1_dram_ck_n				),
	.i_flash_hold				(i_flash_hold				),
	.o_flash_hold				(o_flash_hold				),
	.o_usb_int					(o_usb_int					),
	.o_unused_pin				(o_unused_pin				),
	.scl						(scl						),
	.sda						(sda						)
	);


	PULLUP i2c_scl_pullup (.O(scl));
	PULLUP i2c_sda_pullup (.O(sda));
	PULLUP spi_miso_pullup (.O(o_usb_spi_miso));

	//	-------------------------------------------------------------------------------------
	//	3014 gpif 仿真模型
	//	-------------------------------------------------------------------------------------
	slave_fifo # (
	.SLAVE_DPTH				(16'h2000				)
	)
	slave_fifo_inst(
	.reset_n				(1'b1					),
	.i_usb_rd				(1'b1		    		),
	.iv_usb_addr			(ov_usb_fifoaddr    	),
	.i_usb_wr				(o_usb_slwr_n	    	),
	.iv_usb_data			(ov_usb_data	    	),
	.i_usb_pclk				(o_clk_usb_pclk	    	),
	.i_usb_pkt				(o_usb_pktend_n	    	),
	.i_usb_cs				(1'b0		    		),
	.i_usb_oe				(1'b1		    		),
	.i_pc_busy				(1'b0					),
	.o_flaga				(						),
	.o_flagb				(i_usb_flagb_n			)
	);

	//	-------------------------------------------------------------------------------------
	//	DDR3 仿真模型
	//	-------------------------------------------------------------------------------------
	PULLDOWN zio_pulldown3 (.O(mcb1_zio));   PULLDOWN rzq_pulldown3 (.O(mcb1_rzq));
	generate
		//	-------------------------------------------------------------------------------------
		//	如果DDR3是16bit，但MCB却是8bit
		//	-------------------------------------------------------------------------------------
		if(DDR3_16_DQ_MCB_8_DQ==1) begin
			PULLDOWN mcb1_dram_dq_8 (.O(mcb1_dram_dq[8]));
			PULLDOWN mcb1_dram_dq_9 (.O(mcb1_dram_dq[9]));
			PULLDOWN mcb1_dram_dq_10 (.O(mcb1_dram_dq[10]));
			PULLDOWN mcb1_dram_dq_11 (.O(mcb1_dram_dq[11]));
			PULLDOWN mcb1_dram_dq_12 (.O(mcb1_dram_dq[12]));
			PULLDOWN mcb1_dram_dq_13 (.O(mcb1_dram_dq[13]));
			PULLDOWN mcb1_dram_dq_14 (.O(mcb1_dram_dq[14]));
			PULLDOWN mcb1_dram_dq_15 (.O(mcb1_dram_dq[15]));

			ddr3_model_c3 ddr3_model_c3_inst (
			.ck         	(mcb1_dram_ck					),
			.ck_n       	(mcb1_dram_ck_n					),
			.cke        	(mcb1_dram_cke					),
			.cs_n       	(1'b0							),
			.ras_n      	(mcb1_dram_ras_n				),
			.cas_n      	(mcb1_dram_cas_n				),
			.we_n       	(mcb1_dram_we_n					),
			.dm_tdqs    	({mcb1_dram_udm,mcb1_dram_dm}	),
			.ba         	(mcb1_dram_ba					),
			.addr       	(mcb1_dram_a					),
			.dq         	(mcb1_dram_dq					),
			.dqs      		({mcb1_dram_udqs,mcb1_dram_dqs}	),
			.dqs_n      	({mcb1_dram_udqs_n,mcb1_dram_dqs_n}),
			.tdqs_n     	(								),
			.odt        	(mcb1_dram_odt					),
			.rst_n      	(mcb1_dram_reset_n				)
			);
		end
		//	-------------------------------------------------------------------------------------
		//	DDR3和MCB都是8bit
		//	-------------------------------------------------------------------------------------
		else if(NUM_DQ_PINS==8) begin
			ddr3_model_c3 ddr3_model_c3_inst (
			.ck         	(mcb1_dram_ck					),
			.ck_n       	(mcb1_dram_ck_n					),
			.cke        	(mcb1_dram_cke					),
			.cs_n       	(1'b0							),
			.ras_n      	(mcb1_dram_ras_n				),
			.cas_n      	(mcb1_dram_cas_n				),
			.we_n       	(mcb1_dram_we_n					),
			.dm_tdqs    	(mcb1_dram_dm					),
			.ba         	(mcb1_dram_ba					),
			.addr       	(mcb1_dram_a					),
			.dq         	(mcb1_dram_dq					),
			.dqs        	(mcb1_dram_dqs					),
			.dqs_n      	(mcb1_dram_dqs_n				),
			.tdqs_n     	(								),
			.odt        	(mcb1_dram_odt					),
			.rst_n      	(mcb1_dram_reset_n				)
			);
		end
		//	-------------------------------------------------------------------------------------
		//	DDR3和MCB都是16bit
		//	-------------------------------------------------------------------------------------
		else if(NUM_DQ_PINS==16) begin
			ddr3_model_c3 ddr3_model_c3_inst (
			.ck         	(mcb1_dram_ck					),
			.ck_n       	(mcb1_dram_ck_n					),
			.cke        	(mcb1_dram_cke					),
			.cs_n       	(1'b0							),
			.ras_n      	(mcb1_dram_ras_n				),
			.cas_n      	(mcb1_dram_cas_n				),
			.we_n       	(mcb1_dram_we_n					),
			.dm_tdqs    	({mcb1_dram_udm,mcb1_dram_dm}	),
			.ba         	(mcb1_dram_ba					),
			.addr       	(mcb1_dram_a					),
			.dq         	(mcb1_dram_dq					),
			.dqs        	({mcb1_dram_udqs,mcb1_dram_dqs}	),
			.dqs_n      	({mcb1_dram_udqs_n,mcb1_dram_dqs_n}),
			.tdqs_n     	(								),
			.odt        	(mcb1_dram_odt					),
			.rst_n      	(mcb1_dram_reset_n				)
			);
		end
	endgenerate








	//generate vcd file
	//initial begin
	//$dumpfile("test.vcd");
	//$dumpvars(1,top_frame_buffer_inst);
	//end

	//for lattice simulation
	//GSR   GSR_INST (.GSR (1'b1)); //< global reset sig>
	//PUR   PUR_INST (.PUR (1'b1)); //<powerup reset sig>



endmodule
