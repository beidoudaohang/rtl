/**********************************************************************************************
寄存器生效时机模块：
(1)顶层CPU写入的关于曝光时间窗口尺寸等寄存器，并不能立即起作用，不然将引起参数的不匹配
(2)理论上参数寄存器的作用时机应该在一轮操作完成之后，新一轮开始操作之前。为此我们选择帧翻转
信号Xsg作为时机的切入点
***********************************************************************************************/
`timescale 1ns/1ns
`include "RJ33J3DEF.v"

module	ccd_reg(
	input						pixclk					,		//像素时钟
	input						reset					,       //复位
	input		[`REG_WD-1 :0]	iv_vcount				,       //垂直计数器
	input						i_integration			,       //积分信号
	//input reg
	input						i_triggersel			,       //采集模式
	input		[`REG_WD-1:0]	iv_href_start			,       //行起始寄存器
	input		[`REG_WD-1:0]	iv_href_end				,       //行结束寄存器
	input		[`EXP_WD-1:0]	iv_exposure_reg			,       //曝光寄存器，单位像素时钟
	input		[`REG_WD-1:0]	iv_exposure_linereg		,       //行曝光寄存器
	input		[`REG_WD-1:0]	iv_frame_period			,       //帧周期寄存器
//	input		[`REG_WD-1:0]	iv_hperiod				,       //行周期寄存器
	input		[`REG_WD-1:0]	iv_headblank_number		,       //场头空跑个数寄存器
//	input		[`REG_WD-1:0]	iv_headblank_start		,       //场头空跑起始寄存器
	input		[`REG_WD-1:0]	iv_tailblank_start		,       //场尾空跑起始位置寄存器
	input		[`REG_WD-1:0]	iv_tailblank_number		,       //场尾空跑个数
	input		[`REG_WD-1:0]	iv_tailblank_end		,       //场尾空跑结束位置寄存器
	input		[`REG_WD-1:0]	iv_vsync_start			,       //场有效开始寄存器
//	input		[`REG_WD-1:0]	iv_vsync_fpga_start		,       //场有效开始寄存器
	
//	input						i_xsb_falling_direc			,	//xsub下降沿补偿的方向，0提前，1滞后
//	input		[`REG_WD-1 :0]	iv_xsb_falling_compensation ,	//xsub补偿的数值
//	input						i_xsb_rising_direc          ,	//xsub上升沿补偿的方向，0提前，1滞后
//	input		[`REG_WD-1 :0]	iv_xsb_rising_compensation	,	//xsub补偿的数值
	
	//output reg
	output	reg					o_triggersel_act		,       //生效时机控制之后的采集模式寄存器
	output	reg	[`REG_WD-1 :0]	ov_frame_period_m		,       //帧周期寄存器
	output	reg	[`REG_WD-1 :0]	ov_hperiod				,       //行周期寄存器
	output	reg	[`REG_WD-1 :0]	ov_headblank_number_m	,       //场头空跑个数寄存器
	output	reg	[`REG_WD-1 :0]	ov_headblank_start_m	,       //场头空跑个数寄存器
	output	reg	[`REG_WD-1 :0]	ov_tailblank_start_m	,       //场尾空跑起始位置寄存器
	output	reg	[`REG_WD-1 :0]	ov_tailblank_number_m	,       //场尾空跑结束位置寄存器
	output	reg	[`REG_WD-1 :0]	ov_tailblank_end_m		,       //场尾空跑个数
	output	reg	[`REG_WD-1 :0]	ov_vsync_start_m		,       //场有效开始寄存器
	output	reg	[`REG_WD-1 :0]	ov_vsync_fpga_start_m	,       //场有效开始寄存器
	output	reg	[`REG_WD-1 :0]	ov_href_start_m			,       //行起始寄存器
	output	reg	[`REG_WD-1 :0]	ov_href_end_m			,       //行结束寄存器
	output	reg	[`EXP_WD-1 :0]	ov_exposure_reg_m		,       //曝光寄存器，单位像素时钟
	output	reg	[`REG_WD-1 :0]	ov_exposure_linereg_m	,      	//行曝光寄存器
	output	reg					o_xsb_falling_direc_m			,	//xsub下降沿补偿的方向，0提前，1滞后
	output	reg	[`REG_WD-1 :0]	ov_xsb_falling_compensation_m 	,	//xsub补偿的数值
	output	reg					o_xsb_rising_direc_m          	,	//xsub上升沿补偿的方向，0提前，1滞后
	output	reg	[`REG_WD-1 :0]	ov_xsb_rising_compensation_m		//xsub补偿的数值
	);


	reg		[`REG_WD-1 :0]		frame_period_dly0 = 1'b0;
	reg		[`REG_WD-1 :0]		frame_period_dly1 = 1'b0;
	reg		[`REG_WD-1 :0]		exposure_linereg_dly0 = 1'b0;
	reg		[`REG_WD-1 :0]		exposure_linereg_dly1 = 1'b0;



	//--------------------------------------------------------
	//1、reg 同步
	//--------------------------------------------------------
	always @ (posedge pixclk) begin
		frame_period_dly0	<= iv_frame_period;
		frame_period_dly1	<= frame_period_dly0;
	end

	always @ (posedge pixclk) begin
		exposure_linereg_dly0	<= iv_exposure_linereg;
		exposure_linereg_dly1	<= exposure_linereg_dly0;
	end

	//--------------------------------------------------------
	//2、寄存器生效
	//--------------------------------------------------------
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			ov_headblank_start_m 			<= `HEADBLANK_START_DEFVALUE 	;
			ov_headblank_number_m 			<= `HEADBLANK_NUMBER_DEFVALUE 	;
			ov_vsync_start_m 				<= `VSYNC_START_DEFVALUE     ;
			ov_vsync_fpga_start_m 			<= `VSYNC_START_FPGA_DEFVALUE	;
			ov_tailblank_start_m 			<= `TAILBLANK_START_DEFVALUE 	;
			ov_tailblank_number_m 			<= `TAILBLANK_NUMBER_DEFVALUE 	;
			ov_tailblank_end_m				<= `TAILBLANK_END_DEFVALUE 		;
			ov_frame_period_m 				<= `FRAME_PERIOD_DEFVALUE 	    ;
			ov_hperiod						<= `H_PERIOD					;
			ov_href_start_m 				<= `HREF_START_DEFVALUE      	;
			ov_href_end_m 					<= `HREF_END_DEFVALUE        	;
			o_triggersel_act				<= 1'B0							;
			ov_exposure_linereg_m			<= `EXPOSURE_LINEREG_DEFVALUE	;
			ov_exposure_reg_m				<= `EXPOSURE_DEFVALUE			;
			o_xsb_falling_direc_m			<= 1'b0			;
			ov_xsb_falling_compensation_m	<= `REG_WD'b0	;
			o_xsb_rising_direc_m			<= 1'b0	;
			ov_xsb_rising_compensation_m	<= `REG_WD'b0	;
			
		end
		else if((iv_vcount == 16'h0000)&&(i_integration == 1'b0)) begin		//不能在曝光的时间里更新寄存器
			ov_headblank_start_m			<= `REG_WD'b1	;
			ov_headblank_number_m			<= iv_headblank_number	;
			ov_vsync_start_m				<= iv_vsync_start		;
			ov_vsync_fpga_start_m			<= iv_vsync_start+1'b1	;
			ov_tailblank_start_m			<= iv_tailblank_start	;
			ov_tailblank_number_m			<= iv_tailblank_number	;
			ov_tailblank_end_m				<= iv_tailblank_end		;
//			ov_hperiod						<= iv_hperiod			;
			ov_hperiod						<= `H_PERIOD			;
			ov_href_start_m					<= iv_href_start		;
			ov_href_end_m					<= iv_href_end			;
			o_triggersel_act				<= i_triggersel			;
			ov_exposure_reg_m				<= iv_exposure_reg		;
			ov_exposure_linereg_m			<= exposure_linereg_dly1		;
			o_xsb_falling_direc_m			<= 1'b0			;
			ov_xsb_falling_compensation_m   <= `REG_WD'b0	;
			o_xsb_rising_direc_m            <= 1'b0			;
			ov_xsb_rising_compensation_m    <= `REG_WD'b0	;
			
			if(frame_period_dly1 >= exposure_linereg_dly1 + 16'h4) begin
				ov_frame_period_m			<= frame_period_dly1;
			end
			else begin
				ov_frame_period_m			<= exposure_linereg_dly1 + 16'h4;
			end
		end
	end
	
endmodule