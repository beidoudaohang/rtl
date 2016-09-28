//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : testbench_def
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
//  -- 模块描述     :定义testbench的各项参数，仅供仿真使用
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------







//影响帧缓存的因素主要包括以下几种
//(1)图像大小
//(2)帧存深度
//(3)行消隐时间和行有效时间
//(4)图像输入时钟
//(5)帧缓存工作时钟
//(6)停开采信号
//(7)ddr3速率
//  ===============================================================================================
//	ref 测试帧缓存的功能
//  ===============================================================================================

//  ===============================================================================================
//	--ref 1.测试帧倒换策略
//  ===============================================================================================
////  -------------------------------------------------------------------------------------
////	测试用例1.1
////	4帧倒换 有残包
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			100
//`define			LINE_HIDE_PIX_NUM			10
//`define			LINE_ACTIVE_NUMBER			10
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				10

////  -------------------------------------------------------------------------------------
////	测试用例1.2
////	2帧倒换 有残包
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			100
//`define			LINE_HIDE_PIX_NUM			10
//`define			LINE_ACTIVE_NUMBER			10
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b010		//2 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				10

////  -------------------------------------------------------------------------------------
////	测试用例1.3
////	1帧倒换 有残包
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			100
//`define			LINE_HIDE_PIX_NUM			10
//`define			LINE_ACTIVE_NUMBER			10
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b001		//1 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				10

////  -------------------------------------------------------------------------------------
////	测试用例1.4
////	4帧倒换 无残包
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			128
//`define			LINE_HIDE_PIX_NUM			10
//`define			LINE_ACTIVE_NUMBER			10
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				10

////  -------------------------------------------------------------------------------------
////	测试用例1.5
////	2帧倒换 无残包
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			128
//`define			LINE_HIDE_PIX_NUM			10
//`define			LINE_ACTIVE_NUMBER			10
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b010		//2 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				10

////  -------------------------------------------------------------------------------------
////	测试用例1.6
////	1帧倒换 无残包
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			128
//`define			LINE_HIDE_PIX_NUM			10
//`define			LINE_ACTIVE_NUMBER			10
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b001		//1 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				10


//  ===============================================================================================
//	--ref 2.测试图像大小
//  ===============================================================================================
////  -------------------------------------------------------------------------------------
////	测试用例2.1
////	有残包，图像大小为 80 byte 小于 256 byte。图像很小，一帧图像不够一次写burst的数据量。
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			2
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				10
//

////  -------------------------------------------------------------------------------------
////	测试用例2.2
////	无残包，图像大小等于 256 byte。一帧图像等于一次写burst的数据量。
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			16
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				10

////  -------------------------------------------------------------------------------------
////	测试用例2.3
////	有残包，图像大小中等 8016 byte。
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			501
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				5

////  -------------------------------------------------------------------------------------
////	测试用例2.4
////	无残包，图像大小中等 8192 byte。
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			512
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				5
//
////  -------------------------------------------------------------------------------------
////	测试用例2.5
////	有残包，图像比较大 229360 byte。
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			14335
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				2
//
//
////  -------------------------------------------------------------------------------------
////	测试用例2.6
////	无残包，图像比较大 229360 byte。
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			14336
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				2
//


//  ===============================================================================================
//	--ref 3.测试停开采信号
//  ===============================================================================================
////  -------------------------------------------------------------------------------------
////	测试用例3.1
////	读写3帧之后，停采，停止一段时间之后，再开采
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM				100
//`define			LINE_HIDE_PIX_NUM				200
//`define			LINE_ACTIVE_NUMBER				3
//`define			FRAME_HIDE_PIX_NUM				200
//`define			FRAME_TO_LINE_PIX_NUM			100
//
//`define			FRAME_DEPTH						3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD					20	//50MHz
//`define			CLK_OUT_PERIOD					10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD			10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM					10
//
//`define			SIM_CHANGE_FRAME_EN


////  -------------------------------------------------------------------------------------
////	测试用例3.2
////	读写3帧之后，停采，停止一段时间之后，改变帧存深度，再开采
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			200
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//

//`define			FRAME_DEPTH0				3'b100		//4 frame
//`define			FRAME_DEPTH1				3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				10
//
//`define			SIM_CHANGE_FRAME_EN
//`define			SIM_CHANGE_FRAME_DEPTH


////  -------------------------------------------------------------------------------------
////	测试用例3.3
////	读写3帧之后，停采，停止一段时间之后，改变图像大小，再开采
////  -------------------------------------------------------------------------------------
//pattern model
//`define			LINE_ACTIVE_PIX_NUM0			65
//`define			LINE_HIDE_PIX_NUM0				50
//`define			LINE_ACTIVE_NUMBER0				5
//`define			FRAME_HIDE_PIX_NUM0				100
//`define			FRAME_TO_LINE_PIX_NUM0			50
//
////test
//`define			LINE_ACTIVE_PIX_NUM1			100
//`define			LINE_HIDE_PIX_NUM1				200
//`define			LINE_ACTIVE_NUMBER1				3
//`define			FRAME_HIDE_PIX_NUM1				200
//`define			FRAME_TO_LINE_PIX_NUM1			100
//
//`define			FRAME_DEPTH						3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
//仿真多少幅图像
//`define			SIM_FRAME_NUM				10
//
//`define			SIM_CHANGE_FRAME_EN
//`define			SIM_CHANGE_FRAME_SIZE

//  ===============================================================================================
//	--ref 4.测试复位信号
//  ===============================================================================================

////  -------------------------------------------------------------------------------------
////	测试用例4.1
////	读写3帧之后，复位一段时间，再取消复位
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			200
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH						3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				10
//
//`define			SIM_CHANGE_RST


//  ===============================================================================================
//	--ref 5.测试后级拥堵现象
//  ===============================================================================================
////  -------------------------------------------------------------------------------------
////	测试用例5.1
////	4帧倒换
////	在读第二帧的时候，停止读一段时间，再读
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			200
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH						3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				10
//
//`define			SIM_BACKEND_BLOCK

////  -------------------------------------------------------------------------------------
////	测试用例5.2
////	2帧倒换
////	在读第二帧的时候，停止读一段时间，再读
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			200
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH						3'b010		//2 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				10
//
//`define			SIM_BACKEND_BLOCK

////  -------------------------------------------------------------------------------------
////	测试用例5.3
////	1帧倒换
////	在读第二帧的时候，停止读一段时间，再读
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			200
//`define			LINE_HIDE_PIX_NUM			5
//`define			LINE_ACTIVE_NUMBER			4
//`define			FRAME_HIDE_PIX_NUM			50
//`define			FRAME_TO_LINE_PIX_NUM		20
//
//`define			FRAME_DEPTH						3'b001		//1 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				10
//
//`define			SIM_BACKEND_BLOCK


//  ===============================================================================================
//	ref 测试帧缓存的带宽性能
//  ===============================================================================================
//  ===============================================================================================
//	--ref 6.测试帧缓存的带宽性能
//	一帧中只有一行，没有行消隐时间。Fvin <= Fframe_buf * 0.85。
//  ===============================================================================================

////  -------------------------------------------------------------------------------------
////	测试用例6.1
////	图像大小是256byte的整数倍，一帧中只有一行，前级输入时钟=帧缓存时钟*85%
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10000
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				20	//50MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10	//100MHz
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				11.76	//85MHz
//`define			CLK_OUT_PERIOD				10		//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				1
//`define			SIM_DELAY_TIME_NUM			6000

////  -------------------------------------------------------------------------------------
////	测试用例6.2
////	图像大小不是256byte的整数倍，图像有残包。一帧中只有一行，前级带宽8.16Gbps，已经十分接近帧缓存模块的最大带宽。
////	帧缓存工作时钟155MHz，因为只有大于150MHz的时候，帧缓存模块才能达到最大带宽。
////	需要帧缓存工作在170MHz的频率，PLL倍频一般只能到200MHz 或者 160MHz，而且170MHz的频率也太大了些
////	前端的时钟频率是127.5MHz，一帧中只有一行，前端带宽为 32bit*127.5MHz=510Mbye/s
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10005
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				7.84	//127.5MHz
//`define			CLK_OUT_PERIOD				7.84	//127.5MHz
//`define			CLK_FRAME_BUF_PERIOD		5.88	//170MHz
//
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				2
////写完一帧之后才会读，读写不同帧，ddr3的效率会更低
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM			6000



////  -------------------------------------------------------------------------------------
////	测试用例6.3
////	前端的时钟频率是150MHz，一帧中只有一行，前端带宽为 32bit*150MHz=600Mbye/s
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10005
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				6.667	//150MHz
//`define			CLK_OUT_PERIOD				6.667	//150MHz
//`define			CLK_FRAME_BUF_PERIOD		5		//200MHz
//
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				2
////写完一帧之后才会读，读写不同帧，ddr3的效率会更低
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM			6000
//
////  -------------------------------------------------------------------------------------
////	测试用例6.4
////	前端的时钟频率是160MHz，一帧中只有一行，前端带宽为 32bit*160MHz=640Mbye/s
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10005
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				6.25	//150MHz
//`define			CLK_OUT_PERIOD				6.25	//150MHz
//`define			CLK_FRAME_BUF_PERIOD		5		//200MHz
//
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				2
////写完一帧之后才会读，读写不同帧，ddr3的效率会更低
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM			6000



////  -------------------------------------------------------------------------------------
////	测试用例6.4
////	图像大小是256byte的整数倍，图像没有残包。一帧中只有一行，前级带宽比较小。Fvin = Fframe_buf * 0.85
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10000
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				23.53	//42.5MHz
//`define			CLK_OUT_PERIOD				20		//50MHz
//`define			CLK_FRAME_BUF_PERIOD		20		//50MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				1
////写完一帧之后才会读，读写不同帧，ddr3的效率会更低
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM			6000


//  ===============================================================================================
//	--ref 7.测试帧缓存的带宽性能。
//	一帧中有多行，需要调节行消隐时间。Fvin > Fframe_buf 。
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	测试用例7.1
//	图像大小是256byte的整数倍，一帧中只有一行，前级输入时钟=帧缓存时钟*85%
//  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10000
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100		//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				10		//100MHz
//`define			CLK_OUT_PERIOD				20		//50MHz
//`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				1
////写完一帧之后才会读，读写不同帧，ddr3的效率会更低
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM			6000

//  ===============================================================================================
//	--ref 8.MCB 位宽为8bit 800Mbps 测试带宽性能
//	8bit的理论带宽为 8pin * 800Mbps = 6.4Gbps = 800Mbyte/s，即能处理的前端带宽最大为400Mbyte/s
//	控制器的时钟为150MHz时，32bit*150MHz=4.8Gbps=600Mbyte，这是理论上的带宽
//  ===============================================================================================
////  -------------------------------------------------------------------------------------
////	测试用例8.1
////	前端的时钟频率是80MHz，一帧中只有一行，前端带宽为 32bit*80MHz=320Mbye/s
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10005
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
////UNIT ns
////`define			CLK_IN_PERIOD				7.84	//127.5MHz
////`define			CLK_OUT_PERIOD				5.88	//170MHz
////`define			CLK_FRAME_BUF_PERIOD		5.88	//170MHz
//
//////UNIT ns
////`define			CLK_IN_PERIOD				7.84	//127.5MHz
////`define			CLK_OUT_PERIOD				6.25	//160MHz
////`define			CLK_FRAME_BUF_PERIOD		6.25	//160MHz
////
////UNIT ns
//`define			CLK_IN_PERIOD				12.5	//80MHz
//`define			CLK_OUT_PERIOD				6.45	//155MHz
//`define			CLK_FRAME_BUF_PERIOD		6.45	//155MHz
//
////UNIT ns
////`define			CLK_IN_PERIOD				7.84	//127.5MHz
////`define			CLK_OUT_PERIOD				6.667	//150MHz
////`define			CLK_FRAME_BUF_PERIOD		6.667	//150MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				1
////写完一帧之后才会读，读写不同帧，ddr3的效率会更低
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM			6000


////  -------------------------------------------------------------------------------------
////	测试用例8.2
////	前端的时钟频率是85MHz，一帧中只有一行，前端带宽为 32bit*85MHz=340Mbye/s
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10005
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				11.764	//85MHz
//`define			CLK_OUT_PERIOD				11.764	//85MHz
//`define			CLK_FRAME_BUF_PERIOD		8.334	//120MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				2
////写完一帧之后才会读，读写不同帧，ddr3的效率会更低
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM			6000



////  -------------------------------------------------------------------------------------
////	测试用例8.3
////	前端的时钟频率是90MHz，一帧中只有一行，前端带宽为 32bit*90MHz=360Mbye/s 带宽太大
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			3000
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				11.111	//90MHz
//`define			CLK_OUT_PERIOD				11.111	//90MHz
//`define			CLK_FRAME_BUF_PERIOD		6.25	//160MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				2
////写完一帧之后才会读，读写不同帧，ddr3的效率会更低
////`define			SIM_READ_DELAY


////  -------------------------------------------------------------------------------------
////	测试用例8.4
////	前端的时钟频率是100MHz，一帧中只有一行，前端带宽为 32bit*100MHz=400Mbye/s.
////	DDR3的极限，仿真不能通过
////  -------------------------------------------------------------------------------------
//pattern model
`define			LINE_ACTIVE_PIX_NUM			10005
`define			LINE_HIDE_PIX_NUM			0
`define			LINE_ACTIVE_NUMBER			1
`define			FRAME_HIDE_PIX_NUM			200
`define			FRAME_TO_LINE_PIX_NUM		100

`define			FRAME_DEPTH					3'b100	//4 frame

//UNIT ns
`define			CLK_IN_PERIOD				10	//100MHz
`define			CLK_OUT_PERIOD				6.45	//155MHz
`define			CLK_FRAME_BUF_PERIOD		6.45	//155MHz

//仿真多少幅图像
`define			SIM_FRAME_NUM				1



//  ===============================================================================================
//	--ref 9.MCB 位宽为8bit 660Mbps 测试带宽性能
//	8bit的理论带宽为 8pin * 660Mbps = 5.28Gbps = 660Mbyte/s，即能处理的前端带宽最大为330Mbyte/s
//	扣除ddr3的协议开销，经过计算，总带宽可以达到569Mbyte/s
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	测试用例9.1
//	前端的时钟频率是70MHz，一帧中只有一行，前端带宽为 32bit*70MHz=280Mbye/s
//  -------------------------------------------------------------------------------------
////pattern model
////`define			LINE_ACTIVE_PIX_NUM			10005
//`define			LINE_ACTIVE_PIX_NUM			100
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				14.285	//70MHz
//`define			CLK_OUT_PERIOD				14.285	//70MHz
//`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				2
////写完一帧之后才会读，读写不同帧，ddr3的效率会更低
////`define			SIM_READ_DELAY
////`define			SIM_DELAY_TIME_NUM	8000

////  -------------------------------------------------------------------------------------
////	测试用例9.2
////	前端的时钟频率是71MHz，一帧中只有一行，前端带宽为 32bit*71MHz=284Mbye/s
////	ddr3的带宽能够满足当前的前端输入带宽
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10005
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				14.084	//71MHz
//`define			CLK_OUT_PERIOD				14.084	//71MHz
////`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
////`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
////`define			CLK_FRAME_BUF_PERIOD		11.363	//88MHz
//`define			CLK_FRAME_BUF_PERIOD		10.638	//94MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				2
////写完一帧之后才会读，读写不同帧，ddr3的效率会更低
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM	8000

////  -------------------------------------------------------------------------------------
////	测试用例9.3
////	前端的时钟频率是71.25MHz，一帧中只有一行，前端带宽为 32bit*71.25MHz=285Mbye/s
////	ddr3的带宽能够满足当前的前端输入带宽
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			20000
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		300
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				14.034	//71.25MHz
//`define			CLK_OUT_PERIOD				14.034	//71.25MHz
////`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
////`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
////`define			CLK_FRAME_BUF_PERIOD		11.363	//88MHz
////`define			CLK_FRAME_BUF_PERIOD		10.638	//94MHz
//`define			CLK_FRAME_BUF_PERIOD		11.9	//84MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				6
//////写完一帧之后才会读，读写不同帧，ddr3的效率会更低
////`define			SIM_READ_DELAY
////`define			SIM_DELAY_TIME_NUM	8000

////  -------------------------------------------------------------------------------------
////	测试用例9.4
////	前端的时钟频率是71.5MHz，一帧中只有一行，前端带宽为 32bit*71.5MHz=286Mbye/s
////////	超过了ddr3的带宽
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			3000
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				13.986	//71.5MHz
//`define			CLK_OUT_PERIOD				13.986	//71.5MHz
//`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
////`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
////`define			CLK_FRAME_BUF_PERIOD		11.363	//88MHz
////`define			CLK_FRAME_BUF_PERIOD		10.638	//94MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				10
////写完一帧之后才会读，读写不同帧，ddr3的效率会更低
////`define			SIM_READ_DELAY
////`define			SIM_DELAY_TIME_NUM	0

////  -------------------------------------------------------------------------------------
////	测试用例9.4
////	前端的时钟频率是71.75MHz，一帧中只有一行，前端带宽为 32bit*71.75MHz=287Mbye/s
//////	超过了ddr3的带宽
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			20000
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				13.936	//71.75MHz
//`define			CLK_OUT_PERIOD				13.936	//71.75MHz
//`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
////`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
////`define			CLK_FRAME_BUF_PERIOD		11.363	//88MHz
////`define			CLK_FRAME_BUF_PERIOD		10.638	//94MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				2
////写完一帧之后才会读，读写不同帧，ddr3的效率会更低
////`define			SIM_READ_DELAY
////`define			SIM_DELAY_TIME_NUM	8000

////  -------------------------------------------------------------------------------------
////	测试用例9.4
////	前端的时钟频率是72MHz，一帧中只有一行，前端带宽为 32bit*72MHz=288Mbye/s
////	超过了ddr3的带宽
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			10005
//`define			LINE_HIDE_PIX_NUM			0
//`define			LINE_ACTIVE_NUMBER			1
//`define			FRAME_HIDE_PIX_NUM			200
//`define			FRAME_TO_LINE_PIX_NUM		100
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				13.888	//72MHz
//`define			CLK_OUT_PERIOD				13.888	//72MHz
//`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				2
////写完一帧之后才会读，读写不同帧，ddr3的效率会更低
//`define			SIM_READ_DELAY
//`define			SIM_DELAY_TIME_NUM	8000




//  ===============================================================================================
//	--ref 10.测试ddr3 660Mbps 在python1300上的性能，
//	python1300的时钟为72MHz，行有效320个clk，行消隐4个clk。
//	在zero-rot下，总带宽为 1280*1024*210fps=275.251Mbyte/s，与284Mbyte/s的速度还是有差距，理论上可以通过
//  ===============================================================================================
////  -------------------------------------------------------------------------------------
////	测试用例10.1 一帧的时间太长，因此仿真的时间要缩短一些。
////	前端的时钟频率是72MHz，一帧中有30行，总的数据量为30行*320组数据*4byte=38400byte
////	38400byte/(275.251Mbyte/s) = 139.5us = 10044clk .数据有效时间为 30*320+29*4=9716.所以帧消隐时间总共是328个
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			320
//`define			LINE_HIDE_PIX_NUM			4
////`define			LINE_ACTIVE_NUMBER			30
//`define			LINE_ACTIVE_NUMBER			10
//`define			FRAME_HIDE_PIX_NUM			300
//`define			FRAME_TO_LINE_PIX_NUM		28
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				13.888	//72MHz
//`define			CLK_OUT_PERIOD				13.888	//72MHz
//
////`define			CLK_IN_PERIOD				100	//10MHz
////`define			CLK_OUT_PERIOD				100	//10MHz
//
////`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
////`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
//`define			CLK_FRAME_BUF_PERIOD		10.638	//94MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				2
////写完一帧之后才会读，读写不同帧，ddr3的效率会更低
////`define			SIM_READ_DELAY
////`define			SIM_DELAY_TIME_NUM	8000
//

////  -------------------------------------------------------------------------------------
////	测试用例10.2 实际的python波形 用于板上测试
////	python1300分辨率为1280*1024，帧率为210fps，总的带宽约为274Mbyte/s.行有效320clk，行消隐4clk
////	前端的时钟频率是72MHz，一帧中有1024行，总的数据量为1024行*320组数据*4byte = 1310720 byte
////	1310720byte/(275.251Mbyte/s) = 4762us = 342857 clk .数据有效时间为 1024*320+1023*4=331772.所以帧消隐时间总共是11085个clk
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			320
//`define			LINE_HIDE_PIX_NUM			4
//`define			LINE_ACTIVE_NUMBER			1024
//`define			FRAME_HIDE_PIX_NUM			11060
//`define			FRAME_TO_LINE_PIX_NUM		25
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				13.888	//72MHz
//`define			CLK_OUT_PERIOD				13.888	//72MHz
////`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
////`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
//`define			CLK_FRAME_BUF_PERIOD		11.363	//88MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				2
//////写完一帧之后才会读，读写不同帧，ddr3的效率会更低
////`define			SIM_READ_DELAY
////`define			SIM_DELAY_TIME_NUM	8000

////  -------------------------------------------------------------------------------------
////	测试用例10.3 比python1300的行消隐少一个CLK
////	行有效320CLK，行消隐3CLK，带宽=72*4*320/323=285.325MByte/s
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			320
//`define			LINE_HIDE_PIX_NUM			3
//`define			LINE_ACTIVE_NUMBER			1024
////`define			FRAME_HIDE_PIX_NUM			11060
//`define			FRAME_HIDE_PIX_NUM			10
//`define			FRAME_TO_LINE_PIX_NUM		25
//
//`define			FRAME_DEPTH					3'b100	//4 frame
//
//
////UNIT ns
//`define			CLK_IN_PERIOD				13.888	//72MHz
//`define			CLK_OUT_PERIOD				13.888	//72MHz
////`define			CLK_FRAME_BUF_PERIOD		8.333	//120MHz
////`define			CLK_FRAME_BUF_PERIOD		10		//100MHz
////`define			CLK_FRAME_BUF_PERIOD		11.363	//88MHz
//`define			CLK_FRAME_BUF_PERIOD		10.868	//92MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				2
//////写完一帧之后才会读，读写不同帧，ddr3的效率会更低
////`define			SIM_READ_DELAY
////`define			SIM_DELAY_TIME_NUM	8000

//  ===============================================================================================
//	ref 其他测试项
//  ===============================================================================================
////  -------------------------------------------------------------------------------------
////	测试帧缓存的带宽性能，苏阳有问题的版本
////  -------------------------------------------------------------------------------------
////pattern model
//`define			LINE_ACTIVE_PIX_NUM			120
//`define			LINE_HIDE_PIX_NUM			1
//`define			LINE_ACTIVE_NUMBER			1024
//`define			FRAME_HIDE_PIX_NUM			120
//`define			FRAME_TO_LINE_PIX_NUM		10
//
//`define			FRAME_DEPTH						3'b010		//2 frame
//
////UNIT ns
//`define			CLK_IN_PERIOD				10	//100MHz
//`define			CLK_OUT_PERIOD				10	//100MHz
//`define			CLK_FRAME_BUF_PERIOD		7.5	//133MHz
//
////仿真多少幅图像
//`define			SIM_FRAME_NUM				10






//  ===============================================================================================
//	*** do not modify ***
//  ===============================================================================================
`define			FRAME_SIZE					(`LINE_ACTIVE_PIX_NUM * `LINE_ACTIVE_NUMBER) - 1

