`timescale 1ns/1ns
`include "RJ33J3DEF.v"

module	ccd_vclear(

	input						pixclk				,		//像素时钟
	input						reset				,       //复位
	input		[`REG_WD-1:0]	iv_frame_period_m	,       //帧周期寄存器
	input		[`REG_WD-1:0]	iv_vcount			,       //垂直计数器
	input		            	i_xsg_start   		,       //曝光标志
	input						i_xsg_clear			,
	input						i_triggersel_m		,       //采集模式
	input						i_hend				,       //行尾标志

	output	reg					o_vcount_clear		,       //垂直计数器复位标志
	output	reg					o_waitflag                  //等待阶段标志

	);


	reg							convcount_clear			;
	reg							trivcount_clear			;
	reg							triwaitflag				;
	reg			[2:0]			trivcount_clear_shift	;
	reg							exposure_end			;		//曝光结束与hend对齐
	reg							exposure_end_ext		;		//为了防止exposure_end过窄加宽该信号
	reg							xsg_start2vcount1		;		//为生成wait_flag设置的标志


	//--------------------------------------------------------
	//4-3-1
	//Vcount计数器清零信号：Vcount_clear
	//--------------------------------------------------------
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			convcount_clear	<= 1'b1;	//1-clear
		end
		else begin
			if(iv_vcount >= iv_frame_period_m + 1'b1) begin
				convcount_clear	<= 1'b1;
			end
			else begin
				convcount_clear	<= 1'b0;
			end
		end
	end

	//曝光结束信号到hend，该信号最小宽度1clk，最小宽度时不能复位vcount，
	//为了保证能够稳定复位vcount将该信号加宽
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			exposure_end <= 1'b0;
		end
		else if(i_xsg_clear) begin
			exposure_end <= 1'b1;
		end
		else if(i_hend) begin
			exposure_end <= 1'b0;
		end
	end
	//加宽exposure_end，同时需要保证加宽后的信号与i_hend对齐，否则trivcount_clear就不与i_hend对齐
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			exposure_end_ext <= 1'b0;
		end
		else if(exposure_end && i_hend) begin	//添加i_hend仿真不会零帧
			exposure_end_ext <= 1'b1;
		end
		else if(i_hend) begin
			exposure_end_ext <= 1'b0;
		end
	end
	//exposure_end_ext到来或者没有计数到iv_frame_period_m，计数都会维持
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			trivcount_clear <= 1'b1;
		end
		else begin
			if(exposure_end_ext || ((iv_vcount > 0)&&(iv_vcount <= iv_frame_period_m))) begin		//没有等号小数曝光会零帧
				trivcount_clear <= 1'b0;
			end
			else begin
				trivcount_clear <= 1'b1;
			end
		end
	end

	//触发模式和连续模式的计数器清零信号在此统一0
	always@(posedge pixclk) begin
		if(i_triggersel_m) begin
			o_vcount_clear	<= trivcount_clear;
		end
		else begin
			o_vcount_clear	<= convcount_clear;
		end
	end
	//--------------------------------------------------------
	//4-4
	//等待阶段：
	//	 (1)触发信号的到来在时间上具有很大的随机性，当触发频率很低的时候，相机将有很大一部分时间处于
	//		触发等待的时间
	//	 (2)在触发等待的这段时间里，有两方面互相矛盾的因素需要考虑：功耗和垂直寄存器的翻转。
	//	 (3)触发等待标志从TriVcount_clear_shift上升沿到下一帧曝光开始阶段，为了保证帧翻转效果，曝光到vcount=1阶段需屏蔽
	//--------------------------------------------------------
	//	产生由曝光结束到iv_vcount == 16'h0001的标志
	always@(posedge pixclk or posedge reset) begin
		if (reset) begin
			xsg_start2vcount1 <= 1'b0;
		end
		else if(i_xsg_start) begin
			xsg_start2vcount1 <= 1'b1;
		end
		else if (iv_vcount == 16'h0001) begin
			xsg_start2vcount1 <= 1'b0;
		end
	end
	//对trivcount_clear移位，取上升沿
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			trivcount_clear_shift <= 3'b000;
		end
		else if(i_hend) begin						//使用hend同步保证复位信号与hend对齐	一个行周期宽度
			trivcount_clear_shift <= {trivcount_clear_shift[1:0],trivcount_clear};
		end
	end
	//从TriVcount_clear_shift上升沿到下一帧曝光开始阶段，为触发等待标志
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triwaitflag	<= 1'b0;
		end
		else if(xsg_start2vcount1) begin
			triwaitflag	<= 1'b0;
		end
		else if(trivcount_clear_shift == 3'b001) begin
			triwaitflag	<= 1'b1;
		end
	end
	//只在触发模式下输出
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_waitflag <= 1'b0;
		end
		else if (i_triggersel_m == 1'b0) begin
			o_waitflag <= 1'b0;
		end
		else begin
			o_waitflag <= triwaitflag;
		end
	end

endmodule