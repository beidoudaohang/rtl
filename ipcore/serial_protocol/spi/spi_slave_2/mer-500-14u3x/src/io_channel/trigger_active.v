//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : trigger_active
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/1 13:25:30	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :提取输入信号的边沿
//              1)  : 最小的输入信号宽度是1个时钟
//
//              2)  : 输出信号宽度是1个时钟
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module trigger_active (
	//系统输入
	input			clk					,	//时钟72MHz

	//寄存器输入
	input			i_trigger_soft		,	//软触发输入
	input	[3:0]	iv_trigger_source	,	//选择输入源，0001-软触发，0010-line0，0100-line2，1000-line3
	input			i_trigger_active	,	//0-下降沿有效，1上升沿有效

	//FPGA模块交互信号
	input			i_din				,	//触发信号输入
	output			o_dout					//触发信号输出
	);

	//	ref signals
	reg				triggerl_sel		= 1'b0;	//触发源选择
	reg				triggerl_sel_dly	= 1'b0;	//输入信号打一拍，用于判断输入信号的边沿
	wire			triggerl_sel_rise	;	//上升沿标识
	wire			triggerl_sel_fall	;	//下降沿标识
	reg				dout_reg			= 1'b0;	//输出寄存器

	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	选择外触发或者软触发
	//	1.当选择软触发时，触发源切换为软触发
	//	2.当选择外触发时，触发源切换为外触发
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(iv_trigger_source==4'b0001) begin
			triggerl_sel	<= i_trigger_soft;
		end
		else begin
			triggerl_sel	<= i_din;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	判断边沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		triggerl_sel_dly	<= triggerl_sel;
	end
	assign	triggerl_sel_rise	= (triggerl_sel_dly==1'b0 && triggerl_sel==1'b1) ? 1'b1 : 1'b0;
	assign	triggerl_sel_fall	= (triggerl_sel_dly==1'b1 && triggerl_sel==1'b0) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	极性选择
	//	0-下降沿有效，1上升沿有效
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_trigger_active) begin
			dout_reg	<= triggerl_sel_fall;
		end
		else begin
			dout_reg	<= triggerl_sel_rise;
		end
	end
	assign	o_dout	= dout_reg;


endmodule
