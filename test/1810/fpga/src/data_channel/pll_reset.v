//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : pll_reset
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/10/27 15:28:59	:|  初始版本
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

module pll_reset # (
	parameter	PLL_CHECK_CLK_PERIOD_NS		= 25		,	//pll检测时钟的周期
	parameter	PLL_RESET_SIMULATION		= "FALSE"		//解串PLL复位，使能仿真模式，复位时间变短，加速仿真
	)
	(
	input			clk					,
	input			i_pll_lock			,
	input			i_sensor_init_done	,
	output			o_pll_reset
	);

	//	ref signals

	localparam	WAIT_TIME_NS	= 2000000	;//复位检测间隔时间 NS
	localparam	RESET_TIME_NS	= 500000	;//复位时间 NS
	localparam	WAIT_CNT_NUM	= WAIT_TIME_NS/PLL_CHECK_CLK_PERIOD_NS;
	localparam	WAIT_CNT_WIDTH	= log2(WAIT_CNT_NUM+1);
	localparam	RESET_CNT_NUM	= (PLL_RESET_SIMULATION=="TRUE") ? 10 : (RESET_TIME_NS/PLL_CHECK_CLK_PERIOD_NS);
	localparam	RESET_CNT_WIDTH	= log2(RESET_CNT_NUM+1);

	reg		[WAIT_CNT_WIDTH-1:0]		wait_cnt		= 'b0;
	reg		[RESET_CNT_WIDTH-1:0]		reset_cnt		= 'b0;
	reg									pll_lock_dly0	= 1'b1;
	reg									pll_lock_dly1	= 1'b1;
	reg									state			= 1'b0;
	reg									reset_reg		= 1'b0;

	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	refer to ds162 v1.2 Table 52: PLL Specification
	//	-------------------------------------------------------------------------------------
	//	Symbol      | Description                | Device | Speed Grade     | Units
	//	                                         |           -3 -3N -2 -1L
	//	TLOCKMAX    | PLL Maximum Lock Time      | All    | 100 100 100 100 | μs
	//	RSTMINPULSE | Minimum Reset Pulse Width  | All    | 5   5   5   5   | ns
	//	-------------------------------------------------------------------------------------

	//	-------------------------------------------------------------------------------------
	//	两次采样pll lock
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		pll_lock_dly0	<= i_pll_lock;
		pll_lock_dly1	<= pll_lock_dly0;
	end

	//	-------------------------------------------------------------------------------------
	//	状态寄存器
	//	-- 0 ：锁定状态，如果发现lock信号为低，则启动复位状态
	//	-- 1 ：复位状态，如果发现计数器计满，且当前pll没有锁定，则发出复位信号
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(state==1'b0) begin
			if(pll_lock_dly1==1'b0) begin
				state	<= 1'b1;
			end
		end
		else begin
			if(wait_cnt==WAIT_CNT_NUM-1) begin
				state	<= 1'b0;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	复位wait计数器
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(state==1'b1) begin
			if(wait_cnt==WAIT_CNT_NUM-1) begin
				wait_cnt	<= 'b0;
			end
			else begin
				wait_cnt	<= wait_cnt + 1'b1;
			end
		end
		else begin
			wait_cnt	<= 'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	reset计数器
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(state==1'b1) begin
			if(reset_cnt>=RESET_CNT_NUM-1) begin
				reset_cnt	<= RESET_CNT_NUM;
			end
			else begin
				reset_cnt	<= reset_cnt + 1'b1;
			end
		end
		else begin
			reset_cnt	<= 'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	输出复位信号
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(state==1'b1) begin
			if(reset_cnt<=RESET_CNT_NUM-1) begin
				reset_reg	<= 1'b1;
			end
			else begin
				reset_reg	<= 1'b0;
			end
		end
		else begin
			reset_reg	<= 'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	如果sensor初始化没有完成，则复位
	//	-------------------------------------------------------------------------------------
	assign	o_pll_reset	= reset_reg | !i_sensor_init_done;

endmodule
