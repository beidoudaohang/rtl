//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : strobe_filter
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/1/12 17:13:14	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 对strobe信号滤波，MT9P031的曝光信号有bug，需要对其滤波
//              1)  : 当strobe宽度小于等于1行宽度时，不能发出strobe信号
//
//              2)  : 当strobe宽度大于1行宽度时，才能输出strobe信号
//
//              3)  : 输出的strobe信号宽度不变，位置向后挪了1行
//
//              4)  : 在模块内部统计行宽度，由于lval是异步时钟域，有可能少采样1个，需要注意此处
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module strobe_filter (
	input				clk						,	//像素时钟，72MHz
	input				i_acquisition_start		,	//开采信号，0-停采，1-开采
	input				i_stream_enable			,	//流使能信号，0-停采，1-开采
	input				i_fval					,	//场有效信号，异步信号，与i_lval边沿对齐
	input				i_lval					,	//行有效信号，异步信号，与i_fval边沿对齐
	input				i_sensor_strobe			,	//曝光信号，异步信号，当曝光信号宽度小于1行时，不能输出曝光信号
	output	[12:0]		ov_strobe_length_reg	,	//测量的strobe宽度
	output				o_strobe_filter				//经过滤波后的曝光信号
	);

	//	ref signals
	reg		[1:0]		fval_shift				= 2'b0;
	reg		[3:0]		lval_shift				= 4'b0;
	wire				lval_rise				;
	reg		[1:0]		strobe_shift			= 2'b0;
	wire				strobe_int				;
	reg		[1:0]		lval_rise_cnt			= 2'b0;
	wire				lperiod_length_upload	;
	reg		[12:0]		lperiod_length_cnt		= 13'h0000;
	reg		[12:0]		lperiod_length_reg		= 13'h1fff;
	reg		[12:0]		strobe_length_reg		= 13'h1fff;
	reg		[12:0]		strobe_length_cnt		= 13'h0000;
	reg					enable					= 1'b0;
	reg					strobe_dout				= 1'b0;



	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref 异步信号跨时钟域处理
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	fval 打两拍
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_shift	<= {fval_shift[0],i_fval};
	end

	//  -------------------------------------------------------------------------------------
	//	lval 打四拍，因为fval和lval是边沿对齐的，要在fval=1的时候找lval的上升沿，需要对lva多延时2拍
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_shift	<= {lval_shift[2:0],i_lval};
	end
	assign	lval_rise	= (lval_shift[3]==1'b0 && lval_shift[2]==1'b1) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	strobe 打两拍
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		strobe_shift	<= {strobe_shift[0],i_sensor_strobe};
	end

	//	-------------------------------------------------------------------------------------
	//	如果strobe信号出现在fval=1之内，是要滤掉的。
	//	1.从测试结果看，如果strobe出现在fval=1之内，肯定是1行的宽度。
	//	2.加上屏蔽的目的是增强滤波的健壮性
	//	-------------------------------------------------------------------------------------
	assign	strobe_int	= (fval_shift[1]==1'b1) ? 1'b0 : strobe_shift[1];

	//  ===============================================================================================
	//	ref 行周期计数，在fval=1的时候计数
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	lval上升沿个数计数器
	//	1.当fval=0时,计数器清零
	//	2.当在fval=1且lval上升沿到来时,cnt++
	//	3.当lval cnt计数器到了1'b1时,计数器保持
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!fval_shift[1]) begin
			lval_rise_cnt	<= 2'b0;
		end
		else begin
			if(lval_rise) begin
				if(lval_rise_cnt==2'b10) begin
					lval_rise_cnt	<= lval_rise_cnt;
				end
				else begin
					lval_rise_cnt	<= lval_rise_cnt + 1'b1;
				end
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	当lval rise cnt和lval rise都等于1时，upload标志=1.
	//	1.此时说明在fval=1期间已经有了2个lval的上升沿
	//  -------------------------------------------------------------------------------------
	assign	lperiod_length_upload	= (lval_rise_cnt==2'b01 && lval_rise==1'b1) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	行周期计数器
	//	1.当lval rise cnt=0时，行周期计数器归零
	//	2.当lval rise cnt=1时，行周期计数器++
	//	3.当lval rise cnt=1时，如果行周期计数器全1,保持
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(lval_rise_cnt==2'b0) begin
			lperiod_length_cnt	<= 'b0;
		end
		else if(lval_rise_cnt==2'b01) begin
			if(lperiod_length_cnt==13'h1ff0) begin
				lperiod_length_cnt	<= lperiod_length_cnt;
			end
			else begin
				lperiod_length_cnt	<= lperiod_length_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	行周期寄存器
	//	1.当加载信号有效时，表明新的行周期长度已经计算出来，寄存器=计数器+15。此处的10是为了保证1行宽度的strobe也会被滤掉
	//	2.行周期寄存器上电初始值是全1，为的是Sensor第一帧输出，fval=1开始时就有strobe，不会造成误触发闪光灯
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(lperiod_length_upload) begin
			lperiod_length_reg	<= lperiod_length_cnt+4'hf;
		end
	end
	
	//  ===============================================================================================
	//	ref strobe 滤波
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	strobe 滤波长度寄存器
	//	1.当strobe 长度计数器归零时，才能更新 strobe 长度寄存器
	//	2.strobe长度寄存器上电初始值是全1，为的是Sensor第一帧输出，fval=1开始时就有strobe，不会造成误触发闪光灯
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(strobe_length_cnt==13'h0000) begin
			strobe_length_reg	<= lperiod_length_reg;
		end
	end
	assign	ov_strobe_length_reg	= strobe_length_reg;
	
	//  -------------------------------------------------------------------------------------
	//	strobe 滤波长度计数器
	//	1.当strobe输出是0时，如果strobe输入是1，则计数器++。如果计数器=寄存器，则保持
	//	2.当strobe输出是0时，如果strobe输入是0，则计数器归零
	//	3.当strobe输出是1时，如果strobe输入是1，则计数器保持
	//	4.当strobe输出是1时，如果strobe输入是0，则计数器--。如果计数器=全0，则保持
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!strobe_dout) begin
			if(strobe_int) begin
				if(strobe_length_cnt==strobe_length_reg) begin
					strobe_length_cnt	<= strobe_length_cnt;
				end
				else begin
					strobe_length_cnt	<= strobe_length_cnt + 1'b1;
				end
			end
			else begin
				strobe_length_cnt	<= 13'b0;
			end
		end
		else begin
			if(strobe_int) begin
				strobe_length_cnt	<= strobe_length_cnt;
			end
			else begin
				if(strobe_length_cnt==13'h0000) begin
					strobe_length_cnt	<= strobe_length_cnt;
				end
				else begin
					strobe_length_cnt	<= strobe_length_cnt - 1'b1;
				end
			end
		end
	end

	//  ===============================================================================================
	//	ref 输出
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	使能信号
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		enable	<= i_stream_enable&i_acquisition_start;
	end

	//  -------------------------------------------------------------------------------------
	//	strobe输出
	//	1.如果使能无效，输出立即为0
	//	2.如果使能有效，且strobe输入是1，且滤波计数器达到了滤波寄存器的长度，输出1
	//	3.如果使能有效，且strobe输入是0，且滤波寄存器=全零，输出0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!enable) begin
			strobe_dout	<= 1'b0;
		end
		else begin
			if(strobe_int==1'b1 && strobe_length_cnt==strobe_length_reg) begin
				strobe_dout	<= 1'b1;
			end
			else if(strobe_int==1'b0 && strobe_length_cnt==13'h0000) begin
				strobe_dout	<= 1'b0;
			end
		end
	end

	assign	o_strobe_filter	= strobe_dout;


endmodule
