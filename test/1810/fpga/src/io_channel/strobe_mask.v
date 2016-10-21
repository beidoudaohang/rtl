//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : strobe_mask
//  -- 设计者       : 张少强
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 张少强       :| 2016/07/19 16:49:40	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 该模块是专为AR1820 sensor设计的闪光灯信号构造模块，可以输出与sensor各行公共曝
//						光时间同步的闪光灯信号
//              1)  :
//
//              2)  :
//
//              3)  :
//
//-------------------------------------------------------------------------------------------------
//`include			"strobe_mask_def.v"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module strobe_mask # (
	parameter					PIX_CLK_FREQ_KHZ	= 55000			,//像素时钟频率，以Khz为单位
	parameter					SHORT_LINE_LENGTH_PCK	=	5568	,//sensor短行周期设置值，这个值是写入sensor寄存器的十进制表示
	parameter					PHY_NUM				= 2				,//phy个数
	parameter					PHY_CH_NUM			= 4				,//每个Phy通道数
	parameter					SIMULATION			= "FALSE"
	)
	(
	input						clk								,//输入时钟，clk_pix时钟域，55Mhz
	input						i_strobe						,//异步信号，闪光灯输入信号，sensor输出
	input						i_acquisition_start				,//clk_pix时钟域，开采信号，0-停采，1-开采
	input						i_stream_enable					,//clk_pix时钟域，流使能信号，0-停采，1-开采
	input						i_trigger						,//clk_pix时钟域，持续1个时钟周期的脉冲，表示触发开始,高脉冲触发
	input						i_pll_lock						,//异步信号，解串pll锁定信号，解串模块输出，低电平时失锁
	input						i_fval							,//异步信号，解串时钟域，帧信号
	input						i_lval							,//异步信号，解串时钟域，行信号
	input						i_trigger_mode					,//clk_pix时钟域，data_mask输出的trigger_mode信号，0连采 1触发
	output						o_strobe						 //本模块闪光灯信号输出
	);

	//  ===============================================================================================
	//	-ref : wires and regs
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	内部宏定义
	//	-------------------------------------------------------------------------------------
	localparam					LONG_LINE_LENGTH_PCK		=	2 * SHORT_LINE_LENGTH_PCK											;
	localparam					FIX_TIME					=	(SIMULATION == "TRUE") ? 10 : (30 * PIX_CLK_FREQ_KHZ / 1000)		;//仿真时缩短固定时间为10clk
	localparam					LPERIOD_LENGTH_COMPARE		=	(LONG_LINE_LENGTH_PCK + SHORT_LINE_LENGTH_PCK) / (2 * 8)			;//取长、短行周期的平均数作为比较阈值
	localparam					LONG_LENGTH					=	(LONG_LINE_LENGTH_PCK * 7) / (PHY_NUM * PHY_CH_NUM) - FIX_TIME		;//延长时间=7*行周期-30us
	localparam					SHORT_LENGTH				=	(SHORT_LINE_LENGTH_PCK * 7) / (PHY_NUM * PHY_CH_NUM) - FIX_TIME		;//延长时间=7*行周期-30us
	localparam					LPERIOD_WIDTH				=	log2(LONG_LINE_LENGTH_PCK/8 + 1)									;//行周期计数器位宽由最长行周期决定
	localparam					EXTEND_WIDTH				=	log2(LONG_LENGTH + 1)												;

	//	-------------------------------------------------------------------------------------
	//	打拍寄存及边沿提取
	//	-------------------------------------------------------------------------------------
	reg		[2:0]				fval_shift					=	3'b0	;//异步信号，需要延迟两拍，[1]和[2]用于提取边沿
	wire						w_fval_rise								;//帧上升沿
	wire						w_fval_fall								;//帧下降沿
	reg		[2:0]				lval_shift					=	3'b0	;//异步信号，此处比fval多延迟一拍，用于在fval上升沿后做判断
	wire						w_lval_rise								;//行上升沿
	reg							lval_rise_dly				=	1'b0	;//将行上升沿延时一拍
	reg		[2:0]				pll_lock_shift				=	3'b0	;//i_pll_lock是异步信号，需要打拍处理
	wire						w_pll_lock_rise							;
	reg		[2:0]				strobe_shift				=	3'b0	;//sensor输出的闪光灯信号为异步信号，需要打拍
	wire						w_strobe_rise							;
	//	-------------------------------------------------------------------------------------
	//	计数器
	//	-------------------------------------------------------------------------------------
	reg		[LPERIOD_WIDTH-1:0]	lperiod_cnt					=	'b0		;//行周期计数器
	reg		[1:0]				lval_rise_cnt				=	2'b0	;//计数行个数
	reg		[EXTEND_WIDTH:0]	extend_cnt					=	'b0		;	//展宽长度计数器,位宽比rv_extend_length大1位的作用是防止溢出，因为计数器要计数到rv_extend_length+1才会停止，
	//	-------------------------------------------------------------------------------------
	//	others
	//	-------------------------------------------------------------------------------------
	reg							lperiod_length_upload					;//	统计行周期更新时机寄存器，为1时将计数值更新到行周期寄存器
	reg		[LPERIOD_WIDTH-1:0]	lperiod_length				=	'b0		;//行周期寄存器
	reg							fval_extend					=	1'b0	;//fval展宽后的信号
	reg		[EXTEND_WIDTH-1:0]	extend_length				=	LONG_LENGTH;//展宽长度，初始值为较大的值，可以防止误闪光
	wire						w_extend_timeup							;//展宽时间到标志位
	reg							trigger_status				=	1'b0	;//标志处于触发阶段
	reg							first_enable				=	1'b0	;//触发模式下，闪光灯有效输出阶段
	reg							strobe_enable				= 	1'b0	;//闪光灯使能
	reg							strobe_reg					=	1'b0	;
	//	===============================================================================================
	//	function
	//	===============================================================================================
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
	//	===============================================================================================
	//	 The Detail Design
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	打拍寄存及边沿提取
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_shift <= {fval_shift[1:0],i_fval};
	end
	assign w_fval_rise = (fval_shift[2:1] == 2'b01)? 1'b1 : 1'b0;
	assign w_fval_fall = (fval_shift[2:1] == 2'b10)? 1'b1 : 1'b0;

	always @ (posedge clk) begin
		lval_shift <= {lval_shift[1:0],i_lval};
	end
	assign w_lval_rise = (lval_shift[2:1] == 2'b01)? 1'b1 : 1'b0;
	always @ (posedge clk) begin
		lval_rise_dly <= w_lval_rise;
	end

	always @ (posedge clk) begin
		pll_lock_shift <= {pll_lock_shift[1:0],i_pll_lock};
	end
	assign w_pll_lock_rise = (pll_lock_shift[2:1] == 2'b01)? 1'b1 : 1'b0;

	always @ (posedge clk) begin
		strobe_shift <= {strobe_shift[1:0],i_strobe};
	end
	assign w_strobe_rise = (strobe_shift[2:1] == 2'b01)? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	-ref 1. catch lval period
	//	-------------------------------------------------------------------------------------
	//	-------------------------------------------------------------------------------------
	//	记录行数
	//	1.帧消隐归0
	//	2.每行开始++
	//	3.统计到第2行停止
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_shift[1]==1'b0) begin
			lval_rise_cnt <= 2'd0;
		end
		else begin
			if(lval_rise_cnt >= 2'd2) begin
				lval_rise_cnt <= lval_rise_cnt;
			end
			else if(lval_rise_dly) begin
				lval_rise_cnt <= lval_rise_cnt + 1'b1;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	统计第1行的行周期（没有第0行）
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(lval_rise_cnt == 2'd0) begin
			lperiod_cnt <= 'b0;
		end
		else if(lval_rise_cnt == 2'd1) begin
			if(lperiod_cnt == {LPERIOD_WIDTH{1'b1}}) begin
				lperiod_cnt <= lperiod_cnt		;//计数器防止溢出保护
			end
			else begin
				lperiod_cnt <= lperiod_cnt + 1'b1;
			end
		end
	end
	//	-------------------------------------------------------------------------------------
	//	更新统计的行周期
	//	每当upload标志位为高电平时，将计数器的值给寄存器
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((lval_rise_cnt == 2'd1) && (lval_rise_dly == 1'b1)) begin//指示在第2行行初更新
			lperiod_length_upload <= 1'b1;
		end
		else begin
			lperiod_length_upload <= 1'b0;
		end
	end

	always @ (posedge clk) begin
		if(lperiod_length_upload) begin
			lperiod_length <= lperiod_cnt	;
		end
	end
	//	===============================================================================================
	//	-ref 2.extend fval
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	展宽fval
	//	1.使用打拍后的信号展宽:fval_shift[1]
	//	2.fval上升沿置1
	//	3.展宽时间到（w_extend_timeup）后才归0
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(w_fval_rise) begin
			fval_extend <= 1'b1;
		end
		else if(w_extend_timeup) begin
			fval_extend <= 1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	w_extend_timeup
	//	-------------------------------------------------------------------------------------
	assign w_extend_timeup = (extend_cnt == {1'b0,extend_length})? 1'b1 : 1'b0;
	//	-------------------------------------------------------------------------------------
	//	extend_length
	//	1.行周期寄存器与“最长周期和最短周期的平均值”比较，决定fval延长的长度
	//	2.更新时机为fval下降沿
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(w_fval_fall) begin
			if(lperiod_length > LPERIOD_LENGTH_COMPARE) begin
				extend_length <= LONG_LENGTH;
			end
			else begin
				extend_length <= SHORT_LENGTH;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	extend_cnt
	//	延展计数器从fval的下降沿开始从0计数，直到刚好大于展宽长度时停止；
	//	延展计数器在fval有效期间归0
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_shift[1]) begin
			extend_cnt <= 'b0;
		end
		else begin
			if(extend_cnt > {1'b0,extend_length}) begin
				extend_cnt <= extend_cnt;
			end
			else begin
				extend_cnt <= extend_cnt + 1'b1;
			end
		end
	end

	//	===============================================================================================
	//	-ref 3.o_strobe
	//	闪光灯输出逻辑
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	srobe_enable
	//	在停流（！i_stream_enable	）或停采（！i_acquisition_start）时不输出闪光灯信号
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_stream_enable & i_acquisition_start) begin
			strobe_enable	 <= 1'b1;
		end
		else begin
			strobe_enable	 <= 1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	触发模式下的一些标志位
	//	trigger_status
	//	指示触发状态，从接收到i_trigger信号开始，到pll_lock恢复锁定后结束
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(strobe_enable	) begin
			if(i_trigger) begin
				trigger_status <= 1'b1;
			end
			else if(w_pll_lock_rise) begin
				trigger_status <= 1'b0;
			end
		end
		else begin
			trigger_status <= 1'b0;
		end
	end
	//	-------------------------------------------------------------------------------------
	//	first_enable
	//	first_enable的作用是标志在触发模式下的闪光灯有效输出阶段
	//	1.触发状态下，i_pll上升沿时置1
	//	2.fval上升沿后归0
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(strobe_enable	) begin
			if(trigger_status & w_pll_lock_rise) begin
				first_enable <= 1'b1;
			end
			else if(w_fval_rise) begin
				first_enable <= 1'b0;
			end
		end
		else begin
			first_enable <= 1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	strobe_reg
	//	闪光灯输出分为连续模式和触发模式两种情况
	//	1.r_strobe_enable为1时闪光灯才会有输出
	//	2.连续模式下
	//		a.pll失锁时，没有输出
	//		b.r_fval_extend高电平时，停止输出
	//		c.查找帧消隐(fval_extend=0)期间i_strobe的上升沿，开始输出
	//	3.触发模式下
	//		a.仅在r_first_enable期间才会有输出
	//		b.fval上升沿时，停止输出
	//		c.查找帧消隐期间i_strobe的上升沿，开始输出
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(strobe_enable	) begin
			if(i_trigger_mode == 1'b0) begin //连续模式下
				if(!pll_lock_shift[1]) begin
					strobe_reg <= 1'b0;
				end
				else if(fval_extend) begin
					strobe_reg <= 1'b0;
				end
				else if(!fval_extend && w_strobe_rise) begin
					strobe_reg <= 1'b1;
				end
			end
			else begin //触发模式下
				if(first_enable) begin
					if(w_fval_rise) begin
						strobe_reg <= 1'b0;
					end
					else if(!fval_shift[1] && w_strobe_rise) begin
						strobe_reg <= 1'b1;
					end
				end
				else begin
					strobe_reg <= 1'b0;
				end
			end
		end
		else begin
			strobe_reg <= 1'b0;
		end
	end
	assign o_strobe = strobe_reg;
endmodule
