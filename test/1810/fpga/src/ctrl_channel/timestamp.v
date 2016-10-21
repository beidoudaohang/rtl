//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : timestamp
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/12 16:01:50	:|  初始版本
//  -- 邢海涛       :| 2016/4/25 17:39:57	:|  添加时钟周期的parameter
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

module timestamp # (
	parameter		CLK_PERIOD_NS			= 25	,	//时间戳寄存器的周期
	parameter		LONG_REG_WD				= 64		//长寄存器位宽
	)
	(
	input							clk					,	//40MHz时钟
	input							reset				,	//40MHz时钟
	input							i_fval				,	//clk_pix时钟域，场有效，在上下边沿锁存时间戳到ov_timestamp_u3
	output	[LONG_REG_WD-1:0]		ov_timestamp_u3		,	//clk_osc_bufg时钟域，时间戳，给u3v format模块
	input							i_timestamp_load	,	//clk_osc_bufg时钟域，检测到上升沿，锁存时间戳到ov_timestamp_reg
	output	[LONG_REG_WD-1:0]		ov_timestamp_reg		//clk_osc_bufg时钟域，时间戳，给寄存器模块
	);

	//	ref signals

	reg		[LONG_REG_WD-1:0]		timestamp_cnt	= {LONG_REG_WD{1'b0}};
	reg		[LONG_REG_WD-1:0]		timestamp_reg	= {LONG_REG_WD{1'b0}};
	reg		[LONG_REG_WD-1:0]		timestamp_u3	= {LONG_REG_WD{1'b0}};


	reg		[2:0]		fval_shift	= 3'b000;
	wire				fval_rise		;
	wire				fval_fall		;

	//	ref ARCHITECTURE


	//  -------------------------------------------------------------------------------------
	//	跨时钟域处理，生成fval的上升沿和下降沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_shift	<= {fval_shift[1:0],i_fval};
	end
	assign	fval_rise	= (fval_shift[2:1]==2'b01) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_shift[2:1]==2'b10) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	内部计数器
	//	1.复位信号是DCM72 lock 锁定之后的输出，因此输入时钟锁定之后，时间戳才会技术
	//	2.时钟是40MHz，周期是25ns，时间戳的单位是ns，因此计数器每次要累加25(0x19)
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			timestamp_cnt	<= {LONG_REG_WD{1'b0}};
		end
		else begin
			timestamp_cnt	<= timestamp_cnt + CLK_PERIOD_NS;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	timestamp_reg
	//	1.i_timestamp_load是自清零信号，在i_timestamp_load=1的时候，将内部计数器锁存到端口上
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_timestamp_load) begin
			timestamp_reg	<= timestamp_cnt;
		end
	end
	assign	ov_timestamp_reg	= timestamp_reg;

	//  -------------------------------------------------------------------------------------
	//	timestamp_u3
	//	1.在fval上升沿时，将内部计数器锁存到端口上
	//	2.在fval下降沿时，将内部计数器锁存到端口上
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_rise) begin
			timestamp_u3	<= timestamp_cnt;
		end
		else if(fval_fall) begin
			timestamp_u3	<= timestamp_cnt;
		end
	end
	assign	ov_timestamp_u3	= timestamp_u3;





endmodule
