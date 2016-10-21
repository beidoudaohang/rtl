//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : trigger_cnt
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/5/19 15:57:07	:|  初始版本
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

module trigger_cnt (
	input				clk						,	//时钟

	input				i_trigger_mode			,	//触发模式，0-连续模式，1-触发模式
	input				i_stream_enable			,	//流使能信号
	input				i_acquisition_start		,	//开采信号，0-停采，1-开采

	input				i_linein_sel			,	//trigger_sel之后的信号
	input				i_linein_filter			,	//trigger_filter之后的信号
	input				i_linein_active			,	//trigger_active之后的信号
	input				i_trigger_n				,	//输出的trigger信号
	input				i_trigger_soft			,	//软触发信号

	output	[15:0]		ov_linein_sel_rise_cnt		,	//i_linein_sel的上升沿计数器
	output	[15:0]		ov_linein_sel_fall_cnt		,	//i_linein_sel的下降沿计数器
	output	[15:0]		ov_linein_filter_rise_cnt	,	//i_linein_filter的上升沿计数器
	output	[15:0]		ov_linein_filter_fall_cnt	,	//i_linein_filter的下降沿计数器
	output	[15:0]		ov_linein_active_cnt		,	//i_linein_active的上升沿计数器
	output	[15:0]		ov_trigger_n_rise_cnt		,	//i_trigger_n的上升沿计数器
	output	[15:0]		ov_trigger_soft_cnt				//i_trigger_soft的计数器

	);

	//	ref signals

	reg					enable			= 1'b0;
	reg					linein_sel_dly	= 1'b0;
	wire				linein_sel_rise	;
	wire				linein_sel_fall	;
	reg					linein_filter_dly	= 1'b0;
	wire				linein_filter_rise	;
	wire				linein_filter_fall	;
	reg					trigger_n_dly	= 1'b0;
	wire				trigger_n_rise	;

	reg		[15:0]		linein_sel_rise_cnt	= 16'b0;
	reg		[15:0]		linein_sel_fall_cnt	= 16'b0;
	reg		[15:0]		linein_filter_rise_cnt	= 16'b0;
	reg		[15:0]		linein_filter_fall_cnt	= 16'b0;
	reg		[15:0]		linein_active_cnt	= 16'b0;
	reg		[15:0]		trigger_n_rise_cnt	= 16'b0;
	reg		[15:0]		trigger_soft_cnt	= 16'b0;

	//	ref ARCHITECTURE


	//synchronous clock domain

	//	===============================================================================================
	//	ref ***判断使能***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	使能信号，在io通道的最后1级模块做输出控制
	//	1.当三个使能信号都使能时，输出1
	//	2.当三个使能信号有1个是0时，输出0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		enable	<= i_trigger_mode&i_stream_enable&i_acquisition_start;
	end

	//	===============================================================================================
	//	ref ***提取边沿***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	line sel 边沿
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		linein_sel_dly	<= i_linein_sel;
	end
	assign	linein_sel_rise	= (linein_sel_dly==1'b0 && i_linein_sel==1'b1) ? 1'b1 : 1'b0;
	assign	linein_sel_fall	= (linein_sel_dly==1'b1 && i_linein_sel==1'b0) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	line filter 边沿
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		linein_filter_dly	<= i_linein_filter;
	end
	assign	linein_filter_rise	= (linein_filter_dly==1'b0 && i_linein_filter==1'b1) ? 1'b1 : 1'b0;
	assign	linein_filter_fall	= (linein_filter_dly==1'b1 && i_linein_filter==1'b0) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	trigger 边沿
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		trigger_n_dly	<= i_trigger_n;
	end
	assign	trigger_n_rise	= (trigger_n_dly==1'b0 && i_trigger_n==1'b1) ? 1'b1 : 1'b0;

	//	===============================================================================================
	//	ref ***计数***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	line sel 计数
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!enable) begin
			linein_sel_rise_cnt	<= 'b0;
		end
		else begin
			if(linein_sel_rise) begin
				linein_sel_rise_cnt	<= linein_sel_rise_cnt + 1'b1;
			end
		end
	end
	assign	ov_linein_sel_rise_cnt	= linein_sel_rise_cnt;

	always @ (posedge clk) begin
		if(!enable) begin
			linein_sel_fall_cnt	<= 'b0;
		end
		else begin
			if(linein_sel_fall) begin
				linein_sel_fall_cnt	<= linein_sel_fall_cnt + 1'b1;
			end
		end
	end
	assign	ov_linein_sel_fall_cnt	= linein_sel_fall_cnt;

	//	-------------------------------------------------------------------------------------
	//	line filter 计数
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!enable) begin
			linein_filter_rise_cnt	<= 'b0;
		end
		else begin
			if(linein_filter_rise) begin
				linein_filter_rise_cnt	<= linein_filter_rise_cnt + 1'b1;
			end
		end
	end
	assign	ov_linein_filter_rise_cnt	= linein_filter_rise_cnt;

	always @ (posedge clk) begin
		if(!enable) begin
			linein_filter_fall_cnt	<= 'b0;
		end
		else begin
			if(linein_filter_fall) begin
				linein_filter_fall_cnt	<= linein_filter_fall_cnt + 1'b1;
			end
		end
	end
	assign	ov_linein_filter_fall_cnt	= linein_filter_fall_cnt;

	//	-------------------------------------------------------------------------------------
	//	line active 计数
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!enable) begin
			linein_active_cnt	<= 'b0;
		end
		else begin
			if(i_linein_active) begin
				linein_active_cnt	<= linein_active_cnt + 1'b1;
			end
		end
	end
	assign	ov_linein_active_cnt	= linein_active_cnt;

	//	-------------------------------------------------------------------------------------
	//	trigger_n 计数
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!enable) begin
			trigger_n_rise_cnt	<= 'b0;
		end
		else begin
			if(trigger_n_rise) begin
				trigger_n_rise_cnt	<= trigger_n_rise_cnt + 1'b1;
			end
		end
	end
	assign	ov_trigger_n_rise_cnt	= trigger_n_rise_cnt;

	//	-------------------------------------------------------------------------------------
	//	trigger soft 计数
	//	1.1bit脉冲，无需提取边沿
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!enable) begin
			trigger_soft_cnt	<= 'b0;
		end
		else begin
			if(i_trigger_soft) begin
				trigger_soft_cnt	<= trigger_soft_cnt + 1'b1;
			end
		end
	end
	assign	ov_trigger_soft_cnt	= trigger_soft_cnt;


endmodule
