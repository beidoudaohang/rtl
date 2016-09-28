//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : hispi_if
//  -- 设计者       : 周金剑
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 周金剑       :| 2015/08/11 13:46:45	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : HiSPi接口模块，只适用于Packetized-SP模式
//              1)  : 利用slectIO接收sensor发送的数据，sensor位宽为12bit，selectIO的解串因子设置为6
//
//              2)  : 进行word边界对齐，检测同步字
//
//              3)  : 产生fval、lval和pixel_data信号,fval和lval在时序上是边沿对齐的
//				fval:____|--------------------------------------------|_____
//				lval:____|----|____|----|____|----|____|----|____|----|_____
//				data:____|<-->|____|<-->|____|<-->|____|<-->|____|<-->|_____
//				4)	：行有效长度必须是4的整数倍
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ns
//-------------------------------------------------------------------------------------------------

module hispi_if  #(
	parameter	SER_FIRST_BIT		= "LSB"		,	//"LSB" or "MSB" , first bit to the receiver
	parameter	END_STYLE			= "LITTLE"	,	//"LITTLE" or "BIG" , "LITTLE" - {CHANNEL3 CHANNE2 CHANNEL1 CHANNEL0}. "BIG" - {CHANNEL0 CHANNEL1 CHANNEL2 CHANNEL3}.
	parameter	SENSOR_DAT_WIDTH	= 12		,	//sensor 数据宽度
	parameter	RATIO				= 6			,	//解串因子
	parameter	CHANNEL_NUM			= 4				//sensor 通道数量
	)
	(
	input										clk						,	//时钟
	input										reset					,	//复位
	input	[RATIO*CHANNEL_NUM-1:0]				iv_data					,	//输入并行数据
	input										i_bitslip_en			,	//bitslip使能输入
	output										o_bitslip				,	//bitslip移位使能
	output										o_data_valid			,	//解串对齐完成信号
	output										o_first_frame_detect	,	//检测到第一个完整帧
	input	[15:0]								iv_line_length			,	//行有效数据的长度
	output										o_clk_en				,	//时钟使能信号
	output										o_fval					,	//输出场信号
	output										o_lval					,	//输出行信号
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	ov_pix_data					//输出像素数据
	);

	//  -------------------------------------------------------------------------------------
	//  定义线网型信号、常数
	//  -------------------------------------------------------------------------------------
	wire												w_data_valid	;
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]			wv_data_bitslip	;
	wire												w_clk_en		;


	//  -------------------------------------------------------------------------------------
	//  例化bitslip模块
	//  -------------------------------------------------------------------------------------
	bitslip # (
	.SER_FIRST_BIT		(SER_FIRST_BIT		),
	.END_STYLE			(END_STYLE			),
	.SENSOR_DAT_WIDTH	(SENSOR_DAT_WIDTH	),	//sensor像素数据位宽
	.RATIO				(RATIO				),	//解串因子
	.CHANNEL_NUM		(CHANNEL_NUM		)	//通道数
	)
	bitslip_inst (
	.clk				(clk				),	//输入并行时钟
	.reset				(reset				),	//复位信号
	.iv_data			(iv_data			),	//输入并行数据
	.iv_line_length		(iv_line_length		),	//行周期
	.i_bitslip_en		(i_bitslip_en		),	//bitslip使能，高电平时进行对齐操作
	.o_bitslip			(o_bitslip			),	//bitslip脉冲
	.o_data_valid		(w_data_valid		),	//通道数据有效信号
	.o_clk_en			(w_clk_en			),
	.ov_data			(wv_data_bitslip	)
	);
	assign	o_data_valid	= w_data_valid;

	//  -------------------------------------------------------------------------------------
	//  例化HiSPi处理模块
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