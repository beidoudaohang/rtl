//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : trigger_extend
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/2 17:20:57	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :展宽模块，由于Sensor的触发信号对低电平时间有要求，trigger至少要1行的时间宽度，8192宽度足矣
//              1)  : 输入信号是1个时钟宽度的高脉冲
//
//              2)  : 输出信号是展宽为8192宽度的低脉冲
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module trigger_extend (
	input			clk					,	//时钟
	//寄存器
	input			i_trigger_mode		,	//触发模式，0-连续模式，1-触发模式
	input			i_stream_enable		,	//流使能信号
	input			i_acquisition_start	,	//开采信号，0-停采，1-开采
	//触发信号
	input			i_din				,	//输入触发信号
	output			o_dout_n				//输出触发信号，低电平有效
	);

	//	ref signals
	parameter				EXTEND_LENGTH	= 8192;	//要展宽的长度
	reg						enable			= 1'b0;
	reg						extending		= 1'b0;
	reg		[12:0]			extend_cnt		= 13'b0;
	reg						dout_reg		= 1'b1;
	

	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	使能信号，在io通道的最后1级模块做输出控制
	//	1.当三个使能信号都使能时，输出1
	//	2.当三个使能信号有1个是0时，输出0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		enable	<= i_trigger_mode&i_stream_enable&i_acquisition_start;
	end

	//  -------------------------------------------------------------------------------------
	//	正在展宽的标志
	//	1.当展宽计数器与展宽长度相等时，输出0
	//	2.当输入信号是1且使能有效时，输出1，开始展宽
	//	3.使能信号并不会打断正在展宽的信号
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(extend_cnt==EXTEND_LENGTH-1) begin
			extending	<= 1'b0;
		end
		else if(i_din==1'b1 && enable==1'b1) begin
			extending	<= 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	展宽计数器
	//	1.当展宽计数器与展宽长度相等时，展宽计数器清零
	//	2.当正在展宽标志=1时，展宽计数器+1
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(extend_cnt==EXTEND_LENGTH-1) begin
			extend_cnt	<= 13'b0;
		end
		else if(extending) begin
			extend_cnt	<= extend_cnt + 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	输出取反向
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		dout_reg	<= !extending;
	end
	assign	o_dout_n	= dout_reg;


endmodule
