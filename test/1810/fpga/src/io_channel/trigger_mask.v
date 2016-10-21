//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : trigger_mask
//  -- 设计者       : 周金剑
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 周金剑       :| 2015/10/28 16:36:04	:|  初始版本
//  -- 周金剑       :| 2015/11/17 14:09:07	:|  根据固件设置的间隔来屏蔽trigger信号
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :trigger信号屏蔽
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module  trigger_mask # (
    parameter   PIX_CLK_FREQ_KHZ    = 55000
    )
	(
	input				clk					,//时钟，clk_pix，55MHz
	input				i_trigger			,//clk_pix时钟域，输入触发信号
	input				i_stream_enable		,//clk_pix时钟域，流使能信号
	input				i_acquisition_start	,//clk_pix时钟域，开采信号，0-停采，1-开采
	input   [31:0]      iv_trigger_interval ,//clk_pix时钟域，触发模式最小间隔
	input				i_trigger_mode		,//clk_pix时钟域，触发模式，0-连续模式，1-触发模式
	output				o_trigger			,//clk_pix时钟域，输出触发信号
	input				i_fval				,//解串时钟域，110MHz,输入场信号
	input				i_trigger_status	 //解串时钟域，1-有触发信号且触发帧未输出完毕，0-无触发信号或触发帧输出完毕
	);
    //  -------------------------------------------------------------------------------------
	//	ref 本地常数
	//  -------------------------------------------------------------------------------------
	localparam  [7:0]  CNT_1US =   PIX_CLK_FREQ_KHZ/1000;
	//  -------------------------------------------------------------------------------------
	//	ref 变量定义
	//  -------------------------------------------------------------------------------------
	reg			enable					;
	reg [1:0]   fval_shift              ;

	reg			trigger_mode_shift		;
	reg			trigger_mode			;
	wire		trigger_mode_rise		;

	reg			trigger_reg				;

	reg [7:0]   timer_cnt_1us           ;
	reg         timer_1us_flag          ;
	reg	[31:0]	trigger_interval_cnt	;
	reg [31:0]  trigger_interval_cnt_lock=32'd100000;//必须赋初值，防止在上电之后切换到外触发模式时出问题

	reg			tigger_filter=0			;//1-过滤i_trigger信号，0-输出i_tigger信号
    reg	[1:0]	trigger_status_shift;
	wire		trigger_status;
	//  -------------------------------------------------------------------------------------
	//	ref 异步信号打两拍
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		trigger_status_shift	<=	{trigger_status_shift[0],i_trigger_status};
	end
	assign	trigger_status	=	trigger_status_shift[1];
	//  -------------------------------------------------------------------------------------
	//	ref 使能信号
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		enable	<= i_stream_enable & i_acquisition_start;
	end
	//  -------------------------------------------------------------------------------------
	//	ref 异步信号打两拍
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
	    fval_shift  <=  {fval_shift[0],i_fval};
	end
    //  -------------------------------------------------------------------------------------
	//	ref 产生i_trigger_mode的上升沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		trigger_mode_shift	<=	i_trigger_mode;
		if(!fval_shift[1])
			trigger_mode	<=	i_trigger_mode;
	end
	assign	trigger_mode_rise	=	({trigger_mode_shift,i_trigger_mode}==2'b01);

	//  -------------------------------------------------------------------------------------
	//	ref 1us计数器
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
	    if(timer_cnt_1us>=CNT_1US-1)begin
	        timer_cnt_1us	<=	8'd0;
	        timer_1us_flag	<=	1'b1;
	    end
	    else begin
	        timer_cnt_1us	<=	timer_cnt_1us	+	1'd1;
	        timer_1us_flag	<=	1'b0;
	    end
	end
	//  -------------------------------------------------------------------------------------
	//	ref 记录触发信号之后的时间，单位us
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
	    if(trigger_reg | trigger_mode_rise)begin
	        trigger_interval_cnt	<=	32'd0;
	    end
	    else if(timer_1us_flag)begin
	        trigger_interval_cnt	<=	trigger_interval_cnt	+	1'd1;
	    end
	end
	//  -------------------------------------------------------------------------------------
	//	ref 非屏蔽阶段才允许输入trigger信号
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(enable & (!(tigger_filter | trigger_status)) & trigger_mode)
			trigger_reg	<=	i_trigger & i_trigger_mode;
		else
			trigger_reg	<=	1'b0;
	end
	//  -------------------------------------------------------------------------------------
	//	ref trigger_reg为1时锁存iv_trigger_interval
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(trigger_reg)
			trigger_interval_cnt_lock	<=	iv_trigger_interval;
		else
		    trigger_interval_cnt_lock	<=	trigger_interval_cnt_lock;
	end
	//  -------------------------------------------------------------------------------------
	//	ref 产生tigger_filter信号
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(trigger_reg | trigger_mode_rise)
			tigger_filter	<=	1'b1;
		else if(trigger_interval_cnt>trigger_interval_cnt_lock)
			tigger_filter	<=	1'b0;
	end

	//  -------------------------------------------------------------------------------------
	//	ref 输出o_trigger信号
	//  -------------------------------------------------------------------------------------
	assign	o_trigger	=	trigger_reg;

endmodule