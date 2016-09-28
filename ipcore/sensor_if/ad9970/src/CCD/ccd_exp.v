`timescale 1ns/1ns
`include "RJ33J3DEF.v"

module ccd_exp(

	input						pixclk				,		//像素时钟
	input						reset				,       //复位
	input						i_triggersel_m		,       //采集模式
	input						i_exposure_start	,       //曝光开始
	input						i_waitflag			,       //等待阶段标志
	input	[`EXP_WD-1 :0]		iv_exposure_reg_m	,       //曝光时间寄存器
	input	[`REG_WD-1:0]		iv_vcount			,       //垂直计数器

	output	reg					o_xsub_last_m		,       //补充的SUB信号
	output	reg					o_xsg_start			,       //帧翻转阶段开始信号
	output	reg					o_strobe			,       //闪光灯
	output	reg					o_exposure_preflag	,       //曝光阶段标志，包含SUB
	output	reg             	o_exp_over			,       //曝光结束
	output	reg					o_integration               //积分信号

	);


	reg			[`EXP_WD-1 :0]	exposure_count		= {`EXP_WD{1'b1}};
	reg							xsub_last			;
	reg							exposure_flag		;
	reg			[1:0]			exposure_flag_shift	;
	reg			[`EXP_WD-1 :0]	exposure_reg		= {`EXP_WD{1'b0}};			//SUB宽度 + 曝光时间
	reg			[1:0]			exposure_start_shift;


	//--------------------------------------------------------
	//4-2-1
	//最后一个SUB信号：xsub_last_m
	//为了实现精确曝光，曝光起始时刻，补一个sub信号，只有在连采和触发模式的等待阶段才补。水平正程补sub会影响图像
	//--------------------------------------------------------
	//触发信号来后立即补一个sub信号，以提高曝光精度
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_xsub_last_m	<= 1'b1;
		end
		else if(i_triggersel_m ==1'b0) begin
			o_xsub_last_m	<= 1'b1;
		end
		else if(i_waitflag) begin
			o_xsub_last_m	<= xsub_last;
		end
		else begin
			o_xsub_last_m	<= 1'b1;
		end
	end

	// =================================================================================================
	//4-2-2
	//精确曝光控制
	//无论触发模式还是连采模式，在exposure_start信号后立即启动曝光
	// =================================================================================================
	//计算曝光时间，开始计数
	always@(posedge pixclk) begin
		if(iv_exposure_reg_m < (`XSG1_FALLING -`XSUB_WIDTH + 32'h1)) begin
			exposure_reg <= `XSG1_FALLING + 32'h1;
		end
		else begin
			exposure_reg <=	`XSUB_WIDTH + iv_exposure_reg_m;
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			exposure_start_shift <=  2'b00;
		end
		else begin
			exposure_start_shift <= {exposure_start_shift[0],i_exposure_start};
		end
	end

	always@(posedge pixclk ) begin
		if(exposure_start_shift[1:0] == 2'b01) begin				//曝光开始
			exposure_count	<=	{`EXP_WD{1'b0}};					//曝光计数器从零开始计数
		end
		else if (exposure_count >= exposure_reg) begin
			exposure_count	<=	exposure_count;						//计到曝光值后保持
		end
		else begin
			exposure_count	<=	exposure_count + 1'b1;
		end
	end

	//============================================================================================
	//生成中间标志：补充sub,曝光标志,帧翻转起始标志
	//============================================================================================
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			xsub_last	<= 1'b1;
		end
		else begin
			if(exposure_count == `EXP_WD'h000000) begin	//曝光开始
				xsub_last	<= 1'b0;
			end
			else if(exposure_count == (`EXP_WD'h000000 + `XSUB_WIDTH)) begin
				xsub_last	<= 1'b1;
			end
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			exposure_flag	<=1'b0;
		end
		else begin
			if(exposure_count == (`EXP_WD'h000000 + `XSUB_WIDTH)) begin	//曝光开始
				exposure_flag		<=	1'b1;
			end
			else if(exposure_count == exposure_reg) begin
				exposure_flag		<=	1'b0;
			end
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_xsg_start	<= 1'b0;
		end
		else begin
			if(exposure_count == (exposure_reg - `XSG1_FALLING)) begin
				o_xsg_start	<= 1'b1;
			end
			else begin
				o_xsg_start	<= 1'b0;
			end
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_exposure_preflag	<= 1'b0;
		end
		else begin
			if(exposure_count == `EXP_WD'h000000) begin
				o_exposure_preflag	<= 1'b1;
			end
			else if(exposure_count == exposure_reg) begin
				o_exposure_preflag	<= 1'b0;
			end
		end
	end

	//--------------------------------------------------------
	//4-2-3
	//曝光结束标志：exposure_flag_m
	//曝光结束时刻exposure_flag_m置1，triggeren的下降沿变清0。用这个信号的上升沿给触发模式的vcount清0，启动触发模式的传输。
	//--------------------------------------------------------
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			exposure_flag_shift	<= 2'b00;
		end
		else begin
			exposure_flag_shift	<= {exposure_flag_shift[0],exposure_flag};
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_exp_over	<= 1'b0;
		end
		else if(exposure_flag_shift[1:0] == 2'b10) begin
			o_exp_over	<= 1'b1;
		end
		else begin
			o_exp_over	<= 1'b0;
		end
	end
	//--------------------------------------------------------
	//4-2-4
	//闪光灯信号	：Strobe   高电平有效，从曝光开始时刻生效，到传输开始时刻无效。
	//积分信号输出  ：Integration
	//--------------------------------------------------------
	//原代码是分触发和连续模式的，这里改为用曝光启动信号统一。
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_strobe	<= 1'b0;
		end
		else if(iv_vcount==`REG_WD'h0001) begin
			o_strobe	<= 1'b0;
		end
		else if(exposure_start_shift == 2'b01) begin
			o_strobe	<= 1'b1;
		end
	end

	//Integration
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_integration <= 1'b0;
		end
		else begin
			o_integration <= exposure_flag;
		end
	end

endmodule