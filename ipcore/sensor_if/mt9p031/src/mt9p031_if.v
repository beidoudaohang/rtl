//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : mt9p031_if
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/10/20 15:44:47	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 将 mer-500-14u3x sync buffer中的与mt9p031接口相关的部分提取出来，出口就是时钟、使能和数据
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

module mt9p031_if # (
	parameter	SENSOR_DAT_WIDTH	= 10		//sensor 数据宽度
	)
	(
	//Sensor时钟域
	input								clk_sensor_pix		,	//sensor输入的像素时钟,72Mhz,与本地72Mhz同频但不同相，可认为完全异步的两个信号，如果sensor复位，sensor时钟可能停止输出，而内部时钟不停止
	input								i_fval				,	//sensor输出的场有效信号，与clk_sensor_pix上升沿对齐，i_fval上升沿与i_lval下降沿对齐，i_fval下降沿沿与i_lval下降沿对齐
	input								i_lval				,	//sensor输出的行有效信号，与clk_sensor_pix上升沿对齐，i_fval上升沿与i_lval下降沿对齐，i_fval下降沿沿与i_lval下降沿对齐，i_fval无效期间也有可能输出
	input	[SENSOR_DAT_WIDTH-1:0]		iv_pix_data			,	//sensor输出的图像数据，与clk_sensor_pix上升沿对齐，电路连接10根数据线
	//输出信号
	input								o_clk_sensor_pix	,	//上升沿有效
	output								o_fval				,	//场有效，高有效
	output								o_lval				,	//行有效，高有效
	output	[SENSOR_DAT_WIDTH-1:0]		ov_pix_data				//图像数据
	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	本地参数
	//	1.Sensor接收引脚默认不使用idelay调节，因为外部电路延时已经做得很好
	//	2.Sensor接收引脚idelay 数值默认为0
	//	3.跨时钟域转换的FIFO，可以选择BRAM或者DRAM。宽度18，深度16。
	//	-------------------------------------------------------------------------------------
	localparam			SENSOR_DAT_IDELAY_EN		= 0		;	//idelay使能
	localparam			SENSOR_DAT_IDELAY_VALUE		= 0		;	//idelay延时值

	wire	[SENSOR_DAT_WIDTH-1:0]			wv_pix_data_delay	;
	wire									w_fval_delay	;
	wire									w_lval_delay	;
	wire									clk_sensor_pix_bufg	;
	wire									clk_sensor_pix_bufg_inv	;

	reg		[SENSOR_DAT_WIDTH-1:0]			pix_data_iob	= 'b0;
	reg										fval_iob		= 1'b0;
	reg										lval_iob		= 1'b0;

	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref ***接收Sensor数据***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	输入的时钟 数据 同步信号 用idelay延时 选择性编译该模块
	//  -------------------------------------------------------------------------------------
	idelay_top # (
	.SENSOR_DAT_WIDTH			(SENSOR_DAT_WIDTH			),
	.SENSOR_DAT_IDELAY_EN		(SENSOR_DAT_IDELAY_EN		),
	.SENSOR_DAT_IDELAY_VALUE	(SENSOR_DAT_IDELAY_VALUE	)
	)
	idelay_top_inst (
	.iv_pix_data				(iv_pix_data		),
	.i_fval						(i_fval				),
	.i_lval						(i_lval				),
	.ov_pix_data_delay			(wv_pix_data_delay	),
	.o_fval_delay				(w_fval_delay		),
	.o_lval_delay				(w_lval_delay		)
	);

	//  -------------------------------------------------------------------------------------
	//	随路时钟用全局时钟资源缓冲，全局缓冲器之后反向，这样做可以分析时钟与输入信号的skew
	//  -------------------------------------------------------------------------------------
	BUFG bufg_inst (
	.I	(clk_sensor_pix			),
	.O	(clk_sensor_pix_bufg	)
	);
	assign	clk_sensor_pix_bufg_inv	= !clk_sensor_pix_bufg;

	//  -------------------------------------------------------------------------------------
	//	在IOB上使能register，这样可以把延时锁定在引脚最近的位置
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_sensor_pix_bufg_inv) begin
		pix_data_iob	<= wv_pix_data_delay;
		fval_iob		<= w_fval_delay;
		lval_iob		<= w_lval_delay;
	end

	//	-------------------------------------------------------------------------------------
	//	输出
	//	-------------------------------------------------------------------------------------
	assign	o_clk_sensor_pix	= clk_sensor_pix_bufg_inv;
	assign	o_fval				= fval_iob;
	assign	o_lval				= lval_iob;
	assign	ov_pix_data			= pix_data_iob;


	//	-------------------------------------------------------------------------------------
	//	以下为 UCF 示例约束，需要手动添加到 UCF 中，在 RTL 代码中不需要，仅仅作为提示
	//	-------------------------------------------------------------------------------------
	//	##	-------------------------------------------------------------------------------------
	//	##	-- ref clk constraint
	//	##	-------------------------------------------------------------------------------------
	//	NET "clk_sensor_pix" TNM_NET = "TNM_clk_sensor_pix";
	//	TIMESPEC "TS_clk_sensor_pix" = PERIOD "TNM_clk_sensor_pix" 72 MHz HIGH 50 %;
	//
	//	##	-------------------------------------------------------------------------------------
	//	##	-- ref input constraint
	//	##	-------------------------------------------------------------------------------------
	//	##	-------------------------------------------------------------------------------------
	//	##	sensor输入接口约束
	//	##	sensor数据频率是72MHz，UI理想宽度是13.8ns，从测试波形来看，前后宽度至少有4.5ns
	//	##	-------------------------------------------------------------------------------------
	//	INST "iv_pix_data<?>"	TNM = "TNM_IN_SENSOR";
	//	INST "i_fval"			TNM = "TNM_IN_SENSOR";
	//	INST "i_lval"			TNM = "TNM_IN_SENSOR";
	//	TIMEGRP "TNM_IN_SENSOR" OFFSET = IN 4 ns VALID 8 ns BEFORE "clk_sensor_pix" FALLING;
	//
	//
	//	INST "data_channel_inst/sync_buffer_inst/pix_data_iob_*" 	IOB=TRUE;
	//	INST "data_channel_inst/sync_buffer_inst/fval_iob" 			IOB=TRUE;
	//	INST "data_channel_inst/sync_buffer_inst/lval_iob" 			IOB=TRUE;

endmodule
