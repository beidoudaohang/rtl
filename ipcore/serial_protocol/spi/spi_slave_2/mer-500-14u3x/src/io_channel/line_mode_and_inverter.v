//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : line_mode
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/1 10:10:06	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 完成输入输出和反向的功能
//              1)  : 外部有4根信号线，分别为line0、line1、line2和line3
//
//              2)  : line0输入、line1输出、line2 line3双向
//
//              3)  :
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module line_mode_and_inverter (
	//时钟
	input				clk				,	//时钟
	//前级模块互联信号
	input				i_optocoupler	,	//line0 输入
	input	[1:0]		iv_gpio			,	//line2 3 双向信号输入端口
	output				o_optocoupler	,	//line1 输出
	output	[1:0]		ov_gpio			,	//line2 3 双向信号输出端口
	//寄存器控制
	input				i_line2_mode	,	//line2的输入输出模式，0输入，1输出
	input				i_line3_mode	,	//line3的输入输出模式，0输入，1输出
	input				i_line0_invert	,	//0不反向，1反向
	input				i_line1_invert	,	//0不反向，1反向
	input				i_line2_invert	,	//0不反向，1反向
	input				i_line3_invert	,	//0不反向，1反向
	output	[3:0]		ov_line_status	,	//line状态寄存器，bit0-line0 bit1-line1 bit2-line2 bit3-line3，反映电路上的实际状态
	//后级模块互联信号
	output	[2:0]		ov_linein		,	//3路输入信号 line0 2 3
	input	[2:0]		iv_lineout			//3路输出信号 line1 2 3
	);

	//	ref signals
	//输入流程
	reg			line0_in_mode	= 1'b0;
	reg			line2_in_mode	= 1'b0;
	reg			line3_in_mode	= 1'b0;
	reg			line0_in_invert	= 1'b0;
	reg			line2_in_invert	= 1'b0;
	reg			line3_in_invert	= 1'b0;

	//输出流程
	reg			line1_out_invert	= 1'b0;
	reg			line2_out_invert	= 1'b0;
	reg			line3_out_invert	= 1'b0;
	reg			line1_out_mode	= 1'b0;
	reg			line2_out_mode	= 1'b0;
	reg			line3_out_mode	= 1'b0;

	//状态寄存器
	reg		[3:0]		line_status_reg	= 4'b0;


	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref ***输入流程***
	//  ===============================================================================================
	//  ===============================================================================================
	//	-- ref line mode 输入输出控制
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	line0是输入信号，无需做输入输出的切换
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		line0_in_mode	<= i_optocoupler;
	end

	//  -------------------------------------------------------------------------------------
	//	双向信号，当设为输出时，输入屏蔽为0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_line2_mode) begin	//0-输入
			line2_in_mode	<= iv_gpio[0];
		end
		else begin	//1-输出
			line2_in_mode	<= 1'b0;
		end
	end

	always @ (posedge clk) begin
		if(!i_line3_mode) begin	//0-输入
			line3_in_mode	<= iv_gpio[1];
		end
		else begin	//1-输出
			line3_in_mode	<= 1'b0;
		end
	end

	//  ===============================================================================================
	//	-- ref line invert 极性控制
	//  ===============================================================================================
	//	line0
	always @ (posedge clk) begin
		if(!i_line0_invert) begin	//0-不反向
			line0_in_invert	<= line0_in_mode;
		end
		else begin	//1-反向
			line0_in_invert	<= !line0_in_mode;
		end
	end

	//	line2
	always @ (posedge clk) begin
		if(!i_line2_invert) begin	//0-不反向
			line2_in_invert	<= line2_in_mode;
		end
		else begin	//1-反向
			line2_in_invert	<= !line2_in_mode;
		end
	end

	//	line3
	always @ (posedge clk) begin
		if(!i_line3_invert) begin	//0-不反向
			line3_in_invert	<= line3_in_mode;
		end
		else begin	//1-反向
			line3_in_invert	<= !line3_in_mode;
		end
	end

	//  ===============================================================================================
	//	-- ref 输出
	//  ===============================================================================================
	assign	ov_linein	= {line3_in_invert,line2_in_invert,line0_in_invert};

	//  ===============================================================================================
	//	ref ***输出流程***
	//  ===============================================================================================
	//  ===============================================================================================
	//	-- ref line invert 极性控制
	//  ===============================================================================================
	//	line1
	always @ (posedge clk) begin
		if(!i_line1_invert) begin	//0-不反向
			line1_out_invert	<= iv_lineout[0];
		end
		else begin	//1-反向
			line1_out_invert	<= !iv_lineout[0];
		end
	end

	//	line2
	always @ (posedge clk) begin
		if(!i_line2_invert) begin	//0-不反向
			line2_out_invert	<= iv_lineout[1];
		end
		else begin	//1-反向
			line2_out_invert	<= !iv_lineout[1];
		end
	end

	//	line3
	always @ (posedge clk) begin
		if(!i_line3_invert) begin	//0-不反向
			line3_out_invert	<= iv_lineout[2];
		end
		else begin	//1-反向
			line3_out_invert	<= !iv_lineout[2];
		end
	end

	//  ===============================================================================================
	//	-- ref line mode 输入输出控制
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	line1是输出信号，无需做输入输出的切换
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		line1_out_mode	<= line1_out_invert;
	end

	//  -------------------------------------------------------------------------------------
	//	双向信号，当设为输入时，要输出0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_line2_mode) begin	//0-输入
			line2_out_mode	<= 1'b0;
		end
		else begin	//1-输出
			line2_out_mode	<= line2_out_invert;
		end
	end

	always @ (posedge clk) begin
		if(!i_line3_mode) begin	//0-输入
			line3_out_mode	<= 1'b0;
		end
		else begin	//1-输出
			line3_out_mode	<= line3_out_invert;
		end
	end

	//  ===============================================================================================
	//	-- ref 端口输出
	//  ===============================================================================================
	assign	o_optocoupler	= line1_out_mode;
	assign	ov_gpio			= {line3_out_mode,line2_out_mode};

	//  ===============================================================================================
	//	ref ***line status 状态寄存器***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	1. line_status[0]反映line0的输入状态，在line_inverter之后。Circuit_dependent模块已经对电路的输入反向做了抵消。
	//	2. line_status[1]反映line1的输出状态，由于电路有反向的作用，因此在line_inverter之后，再取反
	//	3. 当line2设为输入时，line_status[2]反映line2的输入状态，在line_inverter之后。当line2设为输出时，line_status[2]反映lne2的输出状态，由于电路有反向的作用，因此在line_inverter之后，再取反
	//	4. Status[3]与status[2]相似
	//  -------------------------------------------------------------------------------------
	//	line0
	always @ (posedge clk) begin
		line_status_reg[0]	<= line0_in_invert;
	end
	//	line1
	always @ (posedge clk) begin
		line_status_reg[1]	<= !line1_out_invert;
	end
	//	line2
	always @ (posedge clk) begin
		if(!i_line2_mode) begin	//0-输入
			line_status_reg[2]	<= line2_in_invert;
		end
		else begin	//1-输出
			line_status_reg[2]	<= !line2_out_invert;
		end
	end
	//	line3
	always @ (posedge clk) begin
		if(!i_line3_mode) begin	//0-输入
			line_status_reg[3]	<= line3_in_invert;
		end
		else begin	//1-输出
			line_status_reg[3]	<= !line3_out_invert;
		end
	end

	//	输出
	assign	ov_line_status	= line_status_reg;



endmodule
