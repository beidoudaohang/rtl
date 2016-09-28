//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : blank_run
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/1/10 11:22:23	:|  初始版本
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
`include "RJ33J3DEF.v"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module blank_run # (

	parameter	LINE_START_POSITION	= `HEADBLANK_LINE_START_POSITION,
	parameter	LINE_END_POSITION	= `HEADBLANK_LINE_END_POSITION,
	parameter	STATE_WIDTH			= `HEADBLANK_STATE_WIDTH,

	parameter	XV_DEFAULT_VALUE	= `XV_BLANKHEAD_DEFAULTVALUE,
	parameter	XV_VALUE1			= `V_BLANKHEAD_VALUE1,
	parameter	XV_VALUE2			= `V_BLANKHEAD_VALUE2,
	parameter	XV_VALUE3			= `V_BLANKHEAD_VALUE3,
	parameter	XV_VALUE4			= `V_BLANKHEAD_VALUE4,
	parameter	XV_VALUE5			= `V_BLANKHEAD_VALUE5,
	parameter	XV_VALUE6			= `V_BLANKHEAD_VALUE6,
	parameter	XV_VALUE7			= `V_BLANKHEAD_VALUE7,
	parameter	XV_VALUE8			= `V_BLANKHEAD_VALUE8
	)
	(
	input							clk					,
	input							reset				,
	input		[`REG_WD-1	:0]		iv_hcount			,
	input							i_blank_flag		,
	input       [`REG_WD-1	:0]		iv_blank_number		,       //场头空跑个数寄存器
	output		[`V_WIDTH-1	:0]		ov_xv
	);



	reg		[`V_WIDTH-1	:0]		xv	= XV_DEFAULT_VALUE;
	reg							blank_gen = 1'b0;
	reg		[5:0]				blank_state_cnt	= 6'b0;
	reg		[2:0]				blank_state_num	= 3'b0;
	reg							blank_unit_done = 1'b0;
	reg							blank_realflag = 1'b0;
	reg		[9:0]				hb_numbercount = 10'b0;
	reg		[`REG_WD-1:0]		blank_number_minus	= 'b0;
	//	ref signals


	//	ref ARCHITECTURE


	//  ===============================================================================================
	//	翻转计数和输出
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	场头翻转使能信号
	//  -------------------------------------------------------------------------------------
	always @ ( * ) begin
		if(blank_realflag == 1'b1) begin
			if((iv_hcount >= LINE_START_POSITION)&&(iv_hcount <= LINE_END_POSITION)) begin
				blank_gen	<= 1'b1;
			end
			else begin
				blank_gen	<= 1'b0;
			end
		end
		else begin
			blank_gen	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	小单元计数器，每8个小单元组成一个大单元
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!blank_gen) begin
			blank_state_cnt	<= 6'b0;
		end
		else begin
			if(blank_state_cnt == (STATE_WIDTH - 1)) begin
				blank_state_cnt	<= 6'b0;
			end
			else begin
				blank_state_cnt	<= blank_state_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	大单元计数器，一个大单元表示翻转一行
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!blank_gen) begin
			blank_state_num	<= 'b0;
		end
		else if(blank_state_cnt == (STATE_WIDTH - 1)) begin
			blank_state_num	<= blank_state_num + 1'b1;
		end
	end

	//	//  -------------------------------------------------------------------------------------
	//	//	xv输出
	//	//  -------------------------------------------------------------------------------------
	//	always @ (posedge clk) begin
	//		if(blank_gen) begin
	//			case(blank_state_num)
	//				3'd0 : begin
	//					xv	<= XV_VALUE1;
	//				end
	//				3'd1 : begin
	//					xv	<= XV_VALUE2;
	//				end
	//				3'd2 : begin
	//					xv	<= XV_VALUE3;
	//				end
	//				3'd3 : begin
	//					xv	<= XV_VALUE4;
	//				end
	//				3'd4 : begin
	//					xv	<= XV_VALUE5;
	//				end
	//				3'd5 : begin
	//					xv	<= XV_VALUE6;
	//				end
	//				3'd6 : begin
	//					xv	<= XV_VALUE7;
	//				end
	//				3'd7 : begin
	//					xv	<= XV_VALUE8;
	//				end
	//			endcase
	//		end
	//		else begin
	//			xv	<= XV_DEFAULT_VALUE;
	//		end
	//	end
	//	assign	ov_xv	= xv;

	//  -------------------------------------------------------------------------------------
	//	xv输出 补偿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(blank_gen) begin
			case(blank_state_num)
				3'd0 : begin
					if((blank_state_cnt >= 0)&&(blank_state_cnt <= (STATE_WIDTH - 1 - `XV_FALLING_EDGE_COMPENSATION))) begin
						xv	<= XV_VALUE1;
					end
					else begin
						xv	<= XV_VALUE2;
					end
				end
				3'd1 : begin
					if((blank_state_cnt >= 0)&&(blank_state_cnt <= (STATE_WIDTH - 1 - `XV_RISING_EDGE_COMPENSATION))) begin
						xv	<= XV_VALUE2;
					end
					else begin
						xv	<= XV_VALUE3;
					end
				end
				3'd2 : begin
					if((blank_state_cnt >= 0)&&(blank_state_cnt <= (STATE_WIDTH - 1 - `XV_FALLING_EDGE_COMPENSATION))) begin
						xv	<= XV_VALUE3;
					end
					else begin
						xv	<= XV_VALUE4;
					end
				end
				3'd3 : begin
					if((blank_state_cnt >= 0)&&(blank_state_cnt <= (STATE_WIDTH - 1 - `XV_RISING_EDGE_COMPENSATION))) begin
						xv	<= XV_VALUE4;
					end
					else begin
						xv	<= XV_VALUE5;
					end
				end
				3'd4 : begin
					if((blank_state_cnt >= 0)&&(blank_state_cnt <= (STATE_WIDTH - 1 - `XV_FALLING_EDGE_COMPENSATION))) begin
						xv	<= XV_VALUE5;
					end
					else begin
						xv	<= XV_VALUE6;
					end
				end
				3'd5 : begin
					if((blank_state_cnt >= 0)&&(blank_state_cnt <= (STATE_WIDTH - 1 - `XV_RISING_EDGE_COMPENSATION))) begin
						xv	<= XV_VALUE6;
					end
					else begin
						xv	<= XV_VALUE7;
					end
				end
				3'd6 : begin
					if((blank_state_cnt >= 0)&&(blank_state_cnt <= (STATE_WIDTH - 1 - `XV_FALLING_EDGE_COMPENSATION))) begin
						xv	<= XV_VALUE7;
					end
					else begin
						xv	<= XV_VALUE8;
					end
				end
				3'd7 : begin
					if((blank_state_cnt >= 0)&&(blank_state_cnt <= (STATE_WIDTH - 1 - `XV_RISING_EDGE_COMPENSATION))) begin
						xv	<= XV_VALUE8;
					end
					else begin
						xv	<= XV_DEFAULT_VALUE;
					end
				end
			endcase
		end
		else begin
			xv	<= XV_DEFAULT_VALUE;
		end
	end
	assign	ov_xv	= xv;

	//  ===============================================================================================
	//	翻转个数计数
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	xv输出
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk or posedge reset) begin
		if(reset) begin
			blank_unit_done	<= 1'b0;
		end
		else begin
			if((blank_state_num == 3'd7)&&(blank_state_cnt == (STATE_WIDTH - 1))) begin
				blank_unit_done	<= 1'b1;
			end
			else begin
				blank_unit_done	<= 1'b0;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	翻转个数计数器，暂定一行的时间内翻转4次
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk or posedge reset) begin
		if(reset) begin
			hb_numbercount		<= 10'h0;
		end
		else if(!i_blank_flag) begin
			hb_numbercount		<= 10'h0;
		end
		else if(blank_unit_done) begin
			if(hb_numbercount != iv_blank_number) begin
				hb_numbercount	<= hb_numbercount + 1'b1;
			end
		end
	end


	//	-------------------------------------------------------------------------------------
	//	为了增强时序性，添加一个寄存器
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		blank_number_minus	<= iv_blank_number - 1'b1;
	end

	//  -------------------------------------------------------------------------------------
	//	场头翻转有效标志，如果超出了翻转个数，就要取消使能
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk or posedge reset) begin
		if(reset) begin
			blank_realflag	<= 1'b0;
		end
		else if(i_blank_flag == 1'b0) begin
			blank_realflag	<= 1'b0;
		end
		else if((hb_numbercount == 10'h0)&&(i_blank_flag == 1'b1)) begin
			blank_realflag	<= 1'b1;
		end
		else if(blank_unit_done) begin
//			if(hb_numbercount == (iv_blank_number - 1'b1)) begin
			if(hb_numbercount == blank_number_minus) begin
				blank_realflag	<= 1'b0;
			end
		end
	end

endmodule
