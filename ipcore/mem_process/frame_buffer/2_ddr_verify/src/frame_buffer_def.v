//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : frame_buffer_def
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2013/5/27 13:12:02	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :	宏定义模块
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------

//  **************************************************************************************************************
//	ref 1 用户可配置区 *******************************************************************************************
//  **************************************************************************************************************

//  ===============================================================================================
//	-- ref 1.1 DDR3 芯片配置
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	---- ref 1.1.1 DDR3 数据线个数
//  -------------------------------------------------------------------------------------
`define	DDR3_16_DQ
//`define	DDR3_8_DQ

//  -------------------------------------------------------------------------------------
//	---- ref 1.1.2 DDR3 大小
//  -------------------------------------------------------------------------------------
//`define	DDR3_MEM_DENSITY_512Mb
`define	DDR3_MEM_DENSITY_1Gb

//  -------------------------------------------------------------------------------------
//	---- ref 1.1.3 DDR3 时钟最小周期
//  -------------------------------------------------------------------------------------
//`define	DDR3_TCK_187E
`define	DDR3_TCK_15E
//`define	DDR3_TCK_125


//  ===============================================================================================
//	-- ref 1.2 MCB 配置
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	---- ref 1.2.1 DDR3 实际频率
//  -------------------------------------------------------------------------------------
//`define	DDR3_800
//`define	DDR3_720
`define	DDR3_660
//`define	DDR3_640

//  -------------------------------------------------------------------------------------
//	-- ref 1.2.2 MCB 地址排布
//  -------------------------------------------------------------------------------------
`define	MEM_ADDR_ORDER   			"ROW_BANK_COLUMN"
//`define	MEM_ADDR_ORDER   			"BANK_ROW_COLUMN"


//  ===============================================================================================
//	-- ref 1.3 仿真控制
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	---- ref 1.3.1 MCB为8bit，ddr3芯片为16bit。此时ddr3的容量若为1Gb，MCB其实认为是512Mb。
//  -------------------------------------------------------------------------------------
//`define	DDR3_16_DQ_MCB_8_DQ

//  -------------------------------------------------------------------------------------
//	---- ref 1.3.2 读写命令是否带有自动预充电的功能
//	实际工程中，读写不带有预充电的功能，每次读写都带有precharge，会造成功耗加大
//  -------------------------------------------------------------------------------------
//`define	RD_WR_WITH_PRE

//  -------------------------------------------------------------------------------------
//	---- ref 1.3.3 仿真最大带宽，读指针不能进入写指针，且读写同时开始。
//	实际工程时，取消这个宏定义
//  -------------------------------------------------------------------------------------
//`define	TERRIBLE_TRAFFIC

//  -------------------------------------------------------------------------------------
//	---- ref 1.3.3 仿真开关
//	仿真的时候，定义 SIMULATION 可以加快仿真的速度
//  -------------------------------------------------------------------------------------
//`define	SIMULATION

`ifdef SIMULATION
	//仿真时候的宏定义
	`define	DDR3_CALIB_SOFT_IP			"FALSE"		//不使能calibration模块
	`define	DDR3_SIMULATION				"TRUE"		//仿真模式，加速MCB仿真速度
//	`define	DDR3_HW_TESTING				"FALSE"		//测试地址很窄
	`define	DDR3_HW_TESTING				"TRUE"		//测试地址很宽，地址全覆盖
	
`else
	//综合时候的宏定义
	`define	DDR3_CALIB_SOFT_IP			"TRUE"		//使能calibration模块
	`define	DDR3_SIMULATION				"FALSE"		//布局布线模式
	`define	DDR3_HW_TESTING				"TRUE"		//测试地址很宽，地址全覆盖
	
`endif

//  ===============================================================================================
//	-- ref 1.3 Traffic的类型
//  ===============================================================================================
//`define	TRAFFIC_TYPE_ADDR_AS_DATA
`define	TRAFFIC_TYPE_HAMMER
//`define	TRAFFIC_TYPE_NEIGHBOR
//`define	TRAFFIC_TYPE_WALKING_1S
//`define	TRAFFIC_TYPE_WALKING_0S
//`define	TRAFFIC_TYPE_PRBS

`ifdef	TRAFFIC_TYPE_ADDR_AS_DATA
	`define	TRAFFIC_DATA_MODE	4'b0010
`elsif	TRAFFIC_TYPE_HAMMER
	`define	TRAFFIC_DATA_MODE	4'b0011
`elsif	TRAFFIC_TYPE_NEIGHBOR
	`define	TRAFFIC_DATA_MODE	4'b0100
`elsif	TRAFFIC_TYPE_WALKING_1S
	`define	TRAFFIC_DATA_MODE	4'b0101	
`elsif	TRAFFIC_TYPE_WALKING_0S
	`define	TRAFFIC_DATA_MODE	4'b0110	
`elsif	TRAFFIC_TYPE_PRBS
	`define	TRAFFIC_DATA_MODE	4'b0111
`endif
	

//  **************************************************************************************************************
//	ref 2 用户不可配置区 *****************************************************************************************
//  **************************************************************************************************************

//  ===============================================================================================
//	-- ref 2.1 宏定义作用到MCB上
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	---- ref 2.1.1 DDR3 数据线宏定义
//  -------------------------------------------------------------------------------------
`ifdef	DDR3_16_DQ
	`define	NUM_DQ_PINS				16					//External memory data width
`elsif	DDR3_8_DQ
	`define	NUM_DQ_PINS				8					//External memory data width
`endif

//  -------------------------------------------------------------------------------------
//	---- ref 2.1.2 DDR3 大小宏定义
//  -------------------------------------------------------------------------------------
`ifdef	DDR3_MEM_DENSITY_1Gb
	`define	DDR3_MEM_DENSITY		"1Gb"				//"1Gb" "512Mb"
`elsif	DDR3_MEM_DENSITY_512Mb
	`define	DDR3_MEM_DENSITY		"512Mb"				//"1Gb" "512Mb"
`endif

//  -------------------------------------------------------------------------------------
//	---- ref 2.1.3 DDR3 地址线宽度宏定义
//  -------------------------------------------------------------------------------------
`ifdef	DDR3_MEM_DENSITY_512Mb
	`ifdef	DDR3_8_DQ
		`define	MEM_ADDR_WIDTH		13					//External memory address width
	`elsif	DDR3_16_DQ
		`define	MEM_ADDR_WIDTH		12					//External memory address width
	`endif
`elsif	DDR3_MEM_DENSITY_1Gb
	`ifdef	DDR3_8_DQ
		`define	MEM_ADDR_WIDTH		14					//External memory address width
	`elsif	DDR3_16_DQ
		`define	MEM_ADDR_WIDTH		13					//External memory address width
	`endif
`endif

//  -------------------------------------------------------------------------------------
//	---- ref 2.1.4 DDR3 BANK 地址线宽度宏定义
//  -------------------------------------------------------------------------------------
`define	MEM_BANKADDR_WIDTH   		3					//External memory bank address width

//  -------------------------------------------------------------------------------------
//	---- ref 2.1.5 DDR3 时序参数宏定义
//  -------------------------------------------------------------------------------------
`ifdef	DDR3_TCK_187E
	`define	DDR3_MEM_TRAS		37500
	`define	DDR3_MEM_TRCD		13130
	`define	DDR3_MEM_TREFI		7800000
	`define	DDR3_MEM_TRFC		160000
	`define	DDR3_MEM_TRP		13130
	`define	DDR3_MEM_TWR		15000
	`define	DDR3_MEM_TRTP		7500
	`define	DDR3_MEM_TWTR		7500

`elsif	DDR3_TCK_15E
	`define	DDR3_MEM_TRAS		36000
	`define	DDR3_MEM_TRCD		13500
	`define	DDR3_MEM_TREFI		7800000
	`define	DDR3_MEM_TRFC		160000
	`define	DDR3_MEM_TRP		13500
	`define	DDR3_MEM_TWR		15000
	`define	DDR3_MEM_TRTP		7500
	`define	DDR3_MEM_TWTR		7500

`elsif	DDR3_TCK_125
	`define	DDR3_MEM_TRAS		35000
	`define	DDR3_MEM_TRCD		13750
	`define	DDR3_MEM_TREFI		7800000
	`define	DDR3_MEM_TRFC		160000
	`define	DDR3_MEM_TRP		13750
	`define	DDR3_MEM_TWR		15000
	`define	DDR3_MEM_TRTP		7500
	`define	DDR3_MEM_TWTR		7500

`endif


//  ===============================================================================================
//	-- ref 2.2 宏定义作用到其他模块上
//  ===============================================================================================

//  -------------------------------------------------------------------------------------
//	---- ref 2.2.1 PLL 宏定义
//  -------------------------------------------------------------------------------------
`ifdef DDR3_800
	`define	DDR3_MEMCLK_PERIOD			2500			//DDR3-800 的工作时钟频率是400MHz，周期是2500ps.根据实际频率填写
	//PLL参数
	`define	DDR3_PLL_CLKIN_PERIOD		25000			//PLL输入频率，单位是ps
	`define	DDR3_PLL_CLKOUT0_DIVIDE		1				//ddr3 2倍频 800MHz
	`define	DDR3_PLL_CLKOUT1_DIVIDE		1				//ddr3 2倍频 800MHz 相位相反
	`define	DDR3_PLL_CLKOUT2_DIVIDE		8				//mcb drp 时钟 100MHz
	`define	DDR3_PLL_CLKOUT3_DIVIDE		5				//帧缓存工作时钟 160
	`define	DDR3_PLL_CLKOUT4_DIVIDE		5
	`define	DDR3_PLL_CLKOUT5_DIVIDE		5
	`define	DDR3_PLL_CLKFBOUT_MULT		20
	`define	DDR3_PLL_DIVCLK_DIVIDE		1

`elsif DDR3_720
	`define	DDR3_MEMCLK_PERIOD			2778			//DDR3-720 的工作时钟频率是360MHz，周期是2778ps.根据实际频率填写
	//PLL参数
	`define	DDR3_PLL_CLKIN_PERIOD		25000			//PLL输入频率，单位是ps
	`define	DDR3_PLL_CLKOUT0_DIVIDE		1
	`define	DDR3_PLL_CLKOUT1_DIVIDE		1
	`define	DDR3_PLL_CLKOUT2_DIVIDE		8
	`define	DDR3_PLL_CLKOUT3_DIVIDE		4
	`define	DDR3_PLL_CLKOUT4_DIVIDE		5
	`define	DDR3_PLL_CLKOUT5_DIVIDE		5
	`define	DDR3_PLL_CLKFBOUT_MULT		18
	`define	DDR3_PLL_DIVCLK_DIVIDE		1

`elsif DDR3_660
	`define	DDR3_MEMCLK_PERIOD			3030			//DDR3-660 的工作时钟频率是330MHz，周期是3125ps.根据实际频率填写
	//PLL参数
	`define	DDR3_PLL_CLKIN_PERIOD		25000			//PLL输入频率，单位是ps
	`define	DDR3_PLL_CLKOUT0_DIVIDE		1				//ddr3 2倍频 6600MHz
	`define	DDR3_PLL_CLKOUT1_DIVIDE		1				//ddr3 2倍频 660MHz 相位相反
	`define	DDR3_PLL_CLKOUT2_DIVIDE		8				//mcb drp 时钟 82.5MHz
	`define	DDR3_PLL_CLKOUT3_DIVIDE		7				//帧缓存工作时钟 94.286MHz
	//	`define	DDR3_PLL_CLKOUT3_DIVIDE		6			//帧缓存工作时钟 110MHz
	`define	DDR3_PLL_CLKOUT4_DIVIDE		8
	`define	DDR3_PLL_CLKOUT5_DIVIDE		8
	`define	DDR3_PLL_CLKFBOUT_MULT		33
	`define	DDR3_PLL_DIVCLK_DIVIDE		2

`elsif DDR3_640
	`define	DDR3_MEMCLK_PERIOD			3125			//DDR3-640 的工作时钟频率是320MHz，周期是3125ps.根据实际频率填写
	//PLL参数
	`define	DDR3_PLL_CLKIN_PERIOD		25000			//PLL输入频率，单位是ps
	`define	DDR3_PLL_CLKOUT0_DIVIDE		1
	`define	DDR3_PLL_CLKOUT1_DIVIDE		1
	`define	DDR3_PLL_CLKOUT2_DIVIDE		8
	`define	DDR3_PLL_CLKOUT3_DIVIDE		4
	`define	DDR3_PLL_CLKOUT4_DIVIDE		5
	`define	DDR3_PLL_CLKOUT5_DIVIDE		5
	`define	DDR3_PLL_CLKFBOUT_MULT		16
	`define	DDR3_PLL_DIVCLK_DIVIDE		1


`endif


