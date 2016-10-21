//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : trigger_delay
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/1 13:26:13	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :延时模块
//              1)  :输入信号的宽度是1个时钟
//
//              2)  :输出信号的宽度是1个时钟
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module trigger_delay # (
	parameter		TRIG_DELAY_WIDTH		= 28			//触发信号延时模块寄存器宽度
	)
	(
	//系统输入
	input							clk					,	//时钟55MHz
	//寄存器数据
	input	[TRIG_DELAY_WIDTH-1:0]	iv_trigger_delay	,	//延迟参数
	//FPGA模块信号
	input							i_din				,	//输入的触发信号，一个高电平脉冲
	output							o_dout					//输出的触发信号，一个高电平脉冲
	);


	//	ref signals
	reg		[TRIG_DELAY_WIDTH-1:0]		trigger_delay_reg	= {TRIG_DELAY_WIDTH{1'b0}};
	reg		[TRIG_DELAY_WIDTH-1:0]		trigger_delay_cnt	= {TRIG_DELAY_WIDTH{1'b0}};
	reg									delaying			= 1'b0;
	reg									delaying_dly		= 1'b0;
	reg									delaying_fall		= 1'b0;
	
	
	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	当触发延迟寄存器是0时，才能更新触发延迟寄存器
	//	1.延迟模块最小延迟1个时钟周期
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(trigger_delay_cnt=={TRIG_DELAY_WIDTH{1'b0}}) begin
			trigger_delay_reg	<= iv_trigger_delay+1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	正在延迟的标志
	//	1.当延迟计数器与延迟寄存器相等时，输出0
	//	2.当输入信号是1时，输出1
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(trigger_delay_cnt==trigger_delay_reg) begin
			delaying	<= 1'b0;
		end
		else if(i_din) begin
			delaying	<= 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	延迟计数器
	//	1.当延迟计数器与延迟寄存器相等时，延迟计数器清零
	//	2.当正在延迟标志=1时，延迟计数器+1
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(trigger_delay_cnt==trigger_delay_reg) begin
			trigger_delay_cnt	<= {TRIG_DELAY_WIDTH{1'b0}};
		end
		else if(delaying) begin
			trigger_delay_cnt	<= trigger_delay_cnt + 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	当delaying下降沿时，发出1bit脉冲
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		delaying_dly	<= delaying;
	end

	always @ (posedge clk) begin
		if(delaying_dly==1'b1 && delaying==1'b0) begin
			delaying_fall	<= 1'b1;
		end
		else begin
			delaying_fall	<= 1'b0;
		end
	end
	assign	o_dout	= delaying_fall;






endmodule