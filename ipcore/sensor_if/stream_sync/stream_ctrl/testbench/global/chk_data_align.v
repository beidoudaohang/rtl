//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : chk_data_align
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/19 13:48:24	:|  初始版本
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
//`timescale 1ns/1ps
`timescale 1ns/1ns
//-------------------------------------------------------------------------------------------------

module chk_data_align # (
	parameter		REG_WD					= 32	,	//寄存器位宽
	parameter		DATA_DEPTH 				= 64	,	//数据深度
	parameter		DATA_IN_WIDTH			= 10	,	//输入数据位宽
	parameter		DATA_OUT_WIDTH			= 32	,	//输出数据位宽
	parameter		STOP_ON_ERROR			= 1			//出现错误是否停止
	)
	(
	input							i_chk_en		,	//检查开关
	input	[REG_WD-1:0]			iv_pixel_format	,	//像素格式寄存器，0x01080001:Mono8、0x01100003:Mono10、0x01080008:BayerGR8、0x0110000C:BayerGR10
	input							clk_in			,	//输入时钟
	input							i_fval_in		,	//输入场信号
	input							i_lval_in		,	//输入行信号
	input	[DATA_IN_WIDTH-1:0]		iv_pix_data_in	,	//输入数据
	input							clk_out			,	//输出时钟
	input							i_fval_out		,	//输出场信号
	input							i_lval_out		,	//输出行信号
	input	[DATA_OUT_WIDTH-1:0]	iv_pix_data_out		//输出数据

	);

	//	ref signals
	reg		[DATA_IN_WIDTH-1:0]		mem	[DATA_DEPTH-1:0]	;
	reg		[11:0]					addr_a	= 12'b0	;	//地址12bit，最大深度是4k
	reg		[11:0]					addr_b	= 12'b0	;
	reg								format8_sel	= 1'b0	;
	wire	[DATA_OUT_WIDTH-1:0]	data_group_8	;
	wire	[DATA_OUT_WIDTH-1:0]	data_group_10	;

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***判断数据格式***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	Mono8		- 0x01080001	-> 0x1081	-> 0001,0000,1000,,,,0001
	//	Mono10		- 0x01100003	-> 0x1103	-> 0001,0001,0000,,,,0011
	//	BayerGR8	- 0x01080008	-> 0x1088	-> 0001,0000,1000,,,,1000
	//	BayerGR10	- 0x0110000C	-> 0x110C	-> 0001,0001,0000,,,,1100
	//											   --------!-!-------!!!!
	//                                                     ^    ^       ^------bit0
	//                                             bit20---|    |---bit16
	//	标记上 ! 的，就是参与比较的bit.分别是 bit
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	format8_sel
	//	1.判断像素格式是否选中8bit像素格式
	//	2.使用6bit判断依据
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_out) begin
		case({iv_pixel_format[20],iv_pixel_format[19],iv_pixel_format[3:0]})
			6'b010001	: format8_sel	<= 1'b1;
			6'b011000	: format8_sel	<= 1'b1;
			default		: format8_sel	<= 1'b0;
		endcase
	end

	//  ===============================================================================================
	//	ref ***存储器操作***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	输入时钟域
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_in) begin
		if(i_fval_in==1'b1 && i_lval_in==1'b1 && i_chk_en==1'b1) begin
			addr_a	<= addr_a + 1'b1;
		end
	end

	always @ (posedge clk_in) begin
		if(i_fval_in==1'b1 && i_lval_in==1'b1 && i_chk_en==1'b1) begin
			mem[addr_a]	<= iv_pix_data_in;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	输出时钟域
	//	1.像素格式是8bit，每个周期，地址+4
	//	1.像素格式是10bit，每个周期，地址+2
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_out) begin
		if(i_fval_out==1'b1 && i_lval_out==1'b1 && i_chk_en==1'b1) begin
			if(format8_sel) begin
				addr_b	<= addr_b + 3'b100;
			end
			else begin
				addr_b	<= addr_b + 2'b10;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	检测数据
	//	1.当输出行信号使能且比较开关打开时，才能比较，否则，没有任何动作
	//	2.如果输出的数据与ram中的数据不一样，则打印错误消息。根据参数，选择是否停止。
	//	-------------------------------------------------------------------------------------
	assign	data_group_8	= {mem[addr_b+3][DATA_IN_WIDTH-1:DATA_IN_WIDTH-8],mem[addr_b+2][DATA_IN_WIDTH-1:DATA_IN_WIDTH-8],mem[addr_b+1][DATA_IN_WIDTH-1:DATA_IN_WIDTH-8],mem[addr_b][DATA_IN_WIDTH-1:DATA_IN_WIDTH-8]};
	assign	data_group_10	= {6'b0,mem[addr_b+1],6'b0,mem[addr_b]};
	always @ (posedge clk_out) begin
		if(i_fval_out==1'b1 && i_lval_out==1'b1 && i_chk_en==1'b1) begin
			if(format8_sel) begin
				if(iv_pix_data_out!=data_group_8) begin
					$display ("%m:time is %t ERROR input data is %h,mem data is %h",$time,iv_pix_data_out,data_group_8);
					if(STOP_ON_ERROR) begin
						$stop;
					end
				end
			end
			else begin
				if(iv_pix_data_out!=data_group_10) begin
					$display ("%m:time is %t ERROR input data is %h,mem data is %h",$time,iv_pix_data_out,data_group_10);
					if(STOP_ON_ERROR) begin
						$stop;
					end
				end
			end

		end
	end






endmodule
