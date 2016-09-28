//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : chk_inout_data
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/19 11:15:35	:|  初始版本
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

module chk_inout_data # (
	parameter	DATA_WIDTH 		= 8		,	//数据宽度
	parameter	DATA_DEPTH 		= 64	,	//数据深度
	parameter	STOP_ON_ERROR	= 1			//出现错误是否停止
	)
	(
	input						i_chk_en		,	//检查开关
	input						clk_in			,	//输入时钟
	input						i_fval_in		,	//输入场信号，暂未用到
	input						i_lval_in		,	//输入行信号
	input	[DATA_WIDTH-1:0]	iv_pix_data_in	,	//输入数据
	input						clk_out			,	//输出时钟
	input						i_fval_out		,	//输出场信号，暂未用到
	input						i_lval_out		,	//输出行信号
	input	[DATA_WIDTH-1:0]	iv_pix_data_out		//输出数据
	);

	//	ref signals
	reg		[DATA_WIDTH-1:0]	mem	[DATA_DEPTH-1:0]	;
	reg		[11:0]				addr_a	= 12'b0	;	//地址12bit，最大深度是4k
	reg		[11:0]				addr_b	= 12'b0	;
	wire	[DATA_WIDTH-1:0]	data_in_mem	;
	
	//	ref ARCHITECTURE

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
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_out) begin
		if(i_fval_out==1'b1 && i_lval_out==1'b1 && i_chk_en==1'b1) begin
			addr_b	<= addr_b + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	检测数据
	//	1.当输出行信号使能且比较开关打开时，才能比较，否则，没有任何动作
	//	2.如果输出的数据与ram中的数据不一样，则打印错误消息。根据参数，选择是否停止。
	//	-------------------------------------------------------------------------------------
	assign	data_in_mem	= mem[addr_b]	;
	always @ (posedge clk_out) begin
		if(i_fval_out==1'b1 && i_lval_out==1'b1 && i_chk_en==1'b1) begin
			if(iv_pix_data_out!=data_in_mem) begin
				$display ("%m:time is %t ERROR: input data is %h,mem data is %h",$time,iv_pix_data_out,data_in_mem);
				if(STOP_ON_ERROR) begin
					$stop;
				end
			end
			else begin
				//				$display ("time is %t,ok,input data is %h,mem data is %h",$time,iv_pix_data_out,mem[addr_b]);
			end
		end
	end

endmodule
