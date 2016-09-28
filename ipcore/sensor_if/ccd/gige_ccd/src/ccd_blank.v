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
//  -- 邢海涛       :| 2015/12/7 10:10:59	:|  移植到u3上
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

module ccd_blank # (
	parameter	XV_WIDTH						= 4				,
	parameter	XV_DEFAULT_VALUE				= 4'b1100		,
	parameter	XV_VALUE1						= 4'b1100		,
	parameter	XV_VALUE2						= 4'b1000		,
	parameter	XV_VALUE3						= 4'b1001		,
	parameter	XV_VALUE4						= 4'b0001		,
	parameter	XV_VALUE5						= 4'b0011		,
	parameter	XV_VALUE6						= 4'b0010		,
	parameter	XV_VALUE7						= 4'b0110		,
	parameter	XV_VALUE8						= 4'b0100		,
	parameter	LINE_START_POS					= 40			,	//每一行开始翻转的时间点
	parameter	LINE_PERIOD						= 1532			,	//行周期
	parameter	ONE_LINE_BLANK_NUM				= 4				,	//每一行快翻的行数
	parameter	ONE_BLANK_STATE_NUM				= 8					//每一次快翻的状态个数
	)
	(
	input							clk					,	//时钟
	input							reset				,	//复位
	input		[12:0]				iv_hcount			,	//行计数器
	input							i_blank_flag		,	//快翻使能标志
	input       [12:0]				iv_blank_num		,	//场头空跑个数寄存器，指的是所有被快翻的行的个数
	output		[XV_WIDTH-1:0]		ov_xv					//xv信号
	);

	//	ref signals

	//	-------------------------------------------------------------------------------------
	//	参数定义
	//	-------------------------------------------------------------------------------------
	localparam	ONE_STATE_CLK_NUM		= ((LINE_PERIOD-LINE_START_POS*2)/(ONE_LINE_BLANK_NUM*ONE_BLANK_STATE_NUM))	;	//每个快翻状态中时钟个数
	localparam	CLK_CNT_WIDTH			= log2(ONE_STATE_CLK_NUM-1);
	localparam	STATE_CNT_WIDTH			= log2(ONE_BLANK_STATE_NUM-1);
	localparam	BLANK_CNT_WIDTH			= log2(ONE_LINE_BLANK_NUM);	//必须要比最大值大一个

	localparam	LINE_END_POS			= LINE_PERIOD-LINE_START_POS;	//每一行结束翻转的时间点

	//	-------------------------------------------------------------------------------------
	//	取对数，上取整
	//	-------------------------------------------------------------------------------------
	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction

	//	-------------------------------------------------------------------------------------
	//	信号定义
	//	-------------------------------------------------------------------------------------
	reg									blank_flag_int	= 1'b0;
	reg		[CLK_CNT_WIDTH-1:0]			clk_cnt			= 'b0;
	reg		[STATE_CNT_WIDTH-1:0]		state_cnt		= 'b0;
	reg		[BLANK_CNT_WIDTH-1:0]		blank_cnt		= 'b0;
	reg		[XV_WIDTH-1	:0]				xv_reg			= XV_DEFAULT_VALUE;



	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***翻转计数器***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	blank_flag_int 内部产生快翻的使能标志
	//	--当i_blank_flag=0时，内部标志清零
	//	--已经产生的快翻个数小于要求的快翻个数时，在每一行的开始和结尾处，产生内部内部标志
	//	--当已经产生的快翻个数等于要求的快翻个数时，说明已经产生了足够的快翻，此时内部标志清零
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_blank_flag) begin
			blank_flag_int	<= 1'b0;
		end
		else begin
			if(blank_cnt<iv_blank_num) begin
				if(iv_hcount==LINE_START_POS) begin
					blank_flag_int	<= 1'b1;
				end
				else if(iv_hcount==LINE_END_POS) begin
					blank_flag_int	<= 1'b0;
				end
			end
			else begin
				blank_flag_int	<= 1'b1;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	clk_cnt 每个状态的时钟个数计数器
	//	--当blank_flag_int=0时，clk_cnt清零
	//	--当clk_cnt=最大值时，从0开始计数
	//	--其他情况下，累加
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!blank_flag_int) begin
			clk_cnt	<= 'b0;
		end
		else begin
			if(clk_cnt==(ONE_STATE_CLK_NUM-1)) begin
				clk_cnt	<= 'b0;
			end
			else begin
				clk_cnt	<= clk_cnt + 1'b1;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	state_cnt 一个快翻中状态个数计数器
	//	--当blank_flag_int=0时，state_cnt清零
	//	--当clk_cnt计数到最大值时，如果state_cnt也为最大值，说明一个blank结束了，state_cnt要清零
	//	--如果state_cnt没有达到最大值，state_cnt累加
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!blank_flag_int) begin
			state_cnt	<= 'b0;
		end
		else begin
			if(clk_cnt==(ONE_STATE_CLK_NUM-1)) begin
				if(state_cnt==(ONE_BLANK_STATE_NUM-1)) begin
					state_cnt	<= 'b0;
				end
				else begin
					state_cnt	<= state_cnt + 1'b1;
				end
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	blank_cnt 快翻个数
	//	--当i_blank_flag=0时，blank_cnt清零
	//	--当clk_cnt计数到最大值且state_cnt也为最大值，说明一个blank结束了，blank_cnt累加
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_blank_flag) begin
			blank_cnt	<= 'b0;
		end
		else begin
			if(clk_cnt==(ONE_STATE_CLK_NUM-1) && state_cnt==(ONE_BLANK_STATE_NUM-1)) begin
				blank_cnt	<= blank_cnt + 1'b1;
			end
		end
	end

	//	===============================================================================================
	//	ref ***输出***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	xv输出 补偿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(blank_flag_int) begin
			case(blank_cnt)
				0 : begin
					xv_reg	<= XV_VALUE1;
				end
				1 : begin
					xv_reg	<= XV_VALUE2;
				end
				2 : begin
					xv_reg	<= XV_VALUE3;
				end
				3 : begin
					xv_reg	<= XV_VALUE4;
				end
				4 : begin
					xv_reg	<= XV_VALUE5;
				end
				5 : begin
					xv_reg	<= XV_VALUE6;
				end
				6 : begin
					xv_reg	<= XV_VALUE7;
				end
				7 : begin
					xv_reg	<= XV_VALUE8;
				end
			endcase
		end
		else begin
			xv_reg	<= XV_DEFAULT_VALUE;
		end
	end
	assign	ov_xv	= xv_reg;

endmodule
