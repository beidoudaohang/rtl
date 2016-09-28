//--------------------------------------------------------
//4-1
//触发阶段
//阶段描述：触发阶段从触发信号来开始，到启动CCD曝光结束。输入信号是TriggerIn，最终输出信号Exposure_start，作为启动下一阶段的信号
//--------------------------------------------------------
`timescale 1ns/1ns
`include "RJ33J3DEF.v"

module ccd_trig(

	input						pixclk				,		//像素时钟
	input						reset				,       //复位
	input                       i_triggerin			,       //触发输入
	input						i_hend				,       //场尾标志
	input						i_triggersel_m		,       //采集模式
	input		[`REG_WD-1:0]	iv_vcount			,       //行计数
	input		[`REG_WD-1:0]	iv_hcount			,       //行计数
	input		[`REG_WD-1 :0]	iv_triggerenreg_m	,       //触发允许位置寄存器
	input		[`REG_WD-1 :0]	iv_frame_period_m	,		//
	input		[`REG_WD-1 :0]	iv_contlineexp_start,       //连续模式下曝光开始位置寄存器
	output						o_exposure_start	,       //曝光开始标志
	output		reg				o_triggerready              //触发允许标志

	);

	reg							contexp_trigger		;
	reg							triexp_trigger		;
	reg							triggeren			;
	reg         [ 2        :0]  triggerin_shift     ;
	reg			[ 2        :0]	triggeren_shift		;
	reg			[ 2        :0]	triggersel_m_shift	;
	reg							tri_mask			;
	reg			[`REG_WD-1:0]	mask_count			;
	reg							triggeren_m			;
	reg			[ 2        :0]	triggeren_m_shift	;
	//--------------------------------------------------------
	//4-1-1
	//提取触发信号：触发信号TriggerIn的边缘
	//--------------------------------------------------------
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triggerin_shift	<= 3'b0;
		end
		else begin
			triggerin_shift	<= {triggerin_shift[1:0],i_triggerin};
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triggersel_m_shift	<= 3'b0;
		end
		else begin
			triggersel_m_shift	<= {triggersel_m_shift[1:0],i_triggersel_m};
		end
	end
	//--------------------------------------------------------
	//4-1-2
	//生成触发允许信号：TriggerEn
	//不允许的优先级高于外触发
	//--------------------------------------------------------
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triggeren_m	<= 1'b1;
		end
		else if((iv_vcount > 0)&&(iv_vcount < iv_triggerenreg_m)) begin			//zhangq 2014/1/28 15:50:59
			triggeren_m	<= 1'b0;
		end
		else begin
			triggeren_m	<= 1'b1;
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triggeren_m_shift	<= 3'b0;
		end
		else begin
			triggeren_m_shift	<= {triggeren_m_shift[1:0],triggeren_m};
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triggeren	<= 1'b0;
		end
		else if((i_triggersel_m == 1'b0)||(tri_mask==1'b0)) begin
			triggeren	<= 1'b0;
		end
		else if(triggeren_m_shift[2:1] == 2'b01) begin
			triggeren	<= 1'b0;
		end
		else if(triggerin_shift[2:1] == 2'b01) begin
			triggeren	<= 1'b1;
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triggeren_shift	<= 3'b0;
		end
		else begin
			triggeren_shift	<= {triggeren_shift[1:0],triggeren};
		end
	end

	//--------------------------------------------------------
	//4-1-3
	//生成辅助信号：TriggerReady，此信号直接输出，供调试用，没有其他功能。
	//--------------------------------------------------------
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_triggerready <= 1'b0;
		end
		else begin
			o_triggerready <= triggeren;
		end
	end

	//--------------------------------------------------------
	//4-1-4
	//触发模式下启动曝光的信号：TriExp_Trigger
	//取触发允许信号的上升沿，作为触发模式下的曝光起始信号
	//--------------------------------------------------------
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triexp_trigger	<= 1'b0;
		end
		else if(triggeren_shift[2:1] == 2'b01) begin
			triexp_trigger	<= 1'b1;
		end
		else begin
			triexp_trigger	<= 1'b0;
		end
	end

	always @ (posedge pixclk) begin
		if(triggersel_m_shift[2:1] == 2'b01) begin
			mask_count	<=	`REG_WD'b0;
		end
		else if(mask_count > iv_frame_period_m) begin
			mask_count	<=	iv_frame_period_m + 1'b1;
		end
		else if(i_hend) begin
			mask_count	<=	mask_count + 1'b1;
		end
	end

	always @ (posedge pixclk) begin
		if(mask_count > iv_frame_period_m) begin
			tri_mask	<= 1'b1;
		end
		else begin
			tri_mask	<= 1'b0;
		end
	end
	//--------------------------------------------------------
	//4-1-5
	//连续模式下，曝光启动信号：ContExp_Trigger
	//--------------------------------------------------------

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			contexp_trigger	<= 1'b0;
		end
		else begin
			if((iv_vcount == iv_contlineexp_start)&&(iv_hcount == `XSUB_WIDTH)) begin	//sub结束之后，立即开始曝光
				contexp_trigger	<= 1'b1;
			end
			else begin
				contexp_trigger	<= 1'b0;
			end
		end
	end

	//--------------------------------------------------------
	//4-1-6
	//曝光启动信号：Exposure_start
	//曝光启动信号。连续模式和触发模式的曝光阶段最终都由这个信号启动
	//--------------------------------------------------------
	assign o_exposure_start	= (i_triggersel_m == 1'b0) ? contexp_trigger : triexp_trigger;

endmodule