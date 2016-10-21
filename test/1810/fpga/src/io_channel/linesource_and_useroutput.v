//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : linesource_and_useroutput
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/1 14:40:40	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :选择输出的信号、用户自定义输出模块
//              1)  : 可以设置3个useroutput值
//
//              2)  : 共有3个输出，每一个line的输出有4种选择
//						分别是闪光灯和3个自定义电平
//              3)  :
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module linesource_and_useroutput (
	//时钟
	input				clk					,	//时钟信号
	//其他模块输入
	input				i_strobe			,	//经过滤波后的闪光灯信号
	//寄存器信号
	input	[2:0]		iv_useroutput_level	,	//配置3个useroutput值，bit0-useroutput0，bit1-useroutput1，bit2-useroutput2
	input	[2:0]		iv_line_source1		,	//line1输出源，0-关闭(不支持)，1-曝光，2-useroutput0，3-useroutput1，4-useroutput2
	input	[2:0]		iv_line_source2		,	//line2输出源，0-关闭(不支持)，1-曝光，2-useroutput0，3-useroutput1，4-useroutput2
	input	[2:0]		iv_line_source3		,	//line3输出源，0-关闭(不支持)，1-曝光，2-useroutput0，3-useroutput1，4-useroutput2
	//输出到其他FPGA模块
	output	[2:0]		ov_lineout				//经过选择之后的line输出信号，line0 2 3
	);

	//	ref signals
	reg		[2:0]		lineout		= 3'b0;

	//	ref ARCHITECTURE
	//  -------------------------------------------------------------------------------------
	//	line1输出
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(iv_line_source1)
			3'b001	: lineout[0]	<= i_strobe;
			3'b010	: lineout[0]	<= iv_useroutput_level[0];
			3'b011	: lineout[0]	<= iv_useroutput_level[1];
			3'b100	: lineout[0]	<= iv_useroutput_level[2];
			default	: lineout[0]	<= iv_useroutput_level[0];
		endcase
	end

	//  -------------------------------------------------------------------------------------
	//	line2输出
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(iv_line_source2)
			3'b001	: lineout[1]	<= i_strobe;
			3'b010	: lineout[1]	<= iv_useroutput_level[0];
			3'b011	: lineout[1]	<= iv_useroutput_level[1];
			3'b100	: lineout[1]	<= iv_useroutput_level[2];
			default	: lineout[1]	<= iv_useroutput_level[0];
		endcase
	end
	
	//  -------------------------------------------------------------------------------------
	//	line3输出
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(iv_line_source3)
			3'b001	: lineout[2]	<= i_strobe;
			3'b010	: lineout[2]	<= iv_useroutput_level[0];
			3'b011	: lineout[2]	<= iv_useroutput_level[1];
			3'b100	: lineout[2]	<= iv_useroutput_level[2];
			default	: lineout[2]	<= iv_useroutput_level[0];
		endcase
	end	
	assign	ov_lineout	= lineout;





endmodule
