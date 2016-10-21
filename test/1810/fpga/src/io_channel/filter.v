//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : filter
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/1 13:22:57	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :实现对输入信号的滤波功能
//              1)  : 上下边沿分别滤波
//
//              2)  : 固有滤波时间是10个时钟
//
//              3)  :
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module filter # (
	parameter		TRIG_FILTER_WIDTH					= 19	//触发信号滤波模块寄存器宽度
	)
	(
	//系统信号
	input								clk					,	//时钟，72MHz
	//寄存器数据
	input	[TRIG_FILTER_WIDTH-1:0]		iv_filter_rise		,	//上升沿滤波参数
	input	[TRIG_FILTER_WIDTH-1:0]		iv_filter_fall		,	//下降沿滤波参数
	//FPGA模块信号
	input								i_din				,	//滤波模块输入
	output								o_dout					//滤波模块输出
	);

	//	ref signals

	localparam							FIXED_FILTER_NUM	= 10;	//固定的滤波长度

	reg		[TRIG_FILTER_WIDTH-1:0]		filter_rise_reg		= {TRIG_FILTER_WIDTH{1'b0}};	//可变的上升沿滤波寄存器
	reg		[TRIG_FILTER_WIDTH-1:0]		filter_fall_reg		= {TRIG_FILTER_WIDTH{1'b0}};	//可变的下降沿滤波寄存器
	reg		[TRIG_FILTER_WIDTH-1:0]		filter_rise_cnt		= {TRIG_FILTER_WIDTH{1'b0}};	//可变的上升沿滤波计数器
	reg		[TRIG_FILTER_WIDTH-1:0]		filter_fall_cnt		= {TRIG_FILTER_WIDTH{1'b0}};	//可变的下降沿滤波计数器
	reg									filter_sig			= 1'b0;	//可变长度滤波后的信号


	//	ref ARCHITECTURE
	//  -------------------------------------------------------------------------------------
	//	filter模块内的滤波计数器回到初始状态时，才能更新滤波参数寄存器
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(filter_rise_cnt=={TRIG_FILTER_WIDTH{1'b0}}) begin
			filter_rise_reg	<= iv_filter_rise + (FIXED_FILTER_NUM-1);
		end
	end

	always @ (posedge clk) begin
		if(filter_fall_cnt=={TRIG_FILTER_WIDTH{1'b0}}) begin
			filter_fall_reg	<= iv_filter_fall + (FIXED_FILTER_NUM-1);
		end
	end

	//  -------------------------------------------------------------------------------------
	//	上升沿滤波计数器
	//	1.当输入信号是0时，上升沿计数器清零
	//	2.当输入信号是1时，上升沿计数器计数
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_din) begin
			filter_rise_cnt	<= {TRIG_FILTER_WIDTH{1'b0}};
		end
		else if(i_din) begin
			if(filter_rise_cnt==filter_rise_reg) begin
				filter_rise_cnt	<= filter_rise_cnt;
			end
			else begin
				filter_rise_cnt	<= filter_rise_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	下降沿滤波计数器
	//	1.当输入信号是1时，下降沿计数器清零
	//	2.当输入信号是0时，下降沿计数器计数
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_din) begin
			filter_fall_cnt	<= {TRIG_FILTER_WIDTH{1'b0}};
		end
		else if(!i_din) begin
			if(filter_fall_cnt==filter_fall_reg) begin
				filter_fall_cnt	<= filter_fall_cnt;
			end
			else begin
				filter_fall_cnt	<= filter_fall_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	输出
	//	1.当上升沿计数器=固定滤波长度 且 输入信号是1，输出1
	//	1.当下降沿沿计数器=固定滤波长度 且 输入信号是0，输出0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(filter_rise_cnt==filter_rise_reg && i_din==1'b1) begin
			filter_sig	<= 1'b1;
		end
		else if(filter_fall_cnt==filter_fall_reg && i_din==1'b0) begin
			filter_sig	<= 1'b0;
		end
	end

	assign	o_dout	= filter_sig;





endmodule

