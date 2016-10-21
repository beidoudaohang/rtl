//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : data_mask
//  -- 设计者       : 周金剑
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 周金剑       :| 2015/10/26 14:09:17	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 在连续采集模式下，通过所有的图像的数据；在触发采集模式下，只通过
//					触发帧，过滤除触发帧之外的图像数据。
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module data_mask #(
	parameter		SENSOR_DAT_WIDTH			= 12					,	//sensor 数据宽度
	parameter		CHANNEL_NUM					= 4						,	//串行数据通道数量
	parameter		CLK_FREQ_KHZ				= 55000					,	//时钟频率，55000KHz
	parameter		TRIGGER_STATUS_INTERVAL		= 1100					 	//trigger_status异常时间，110ms
	)
	(
	input											clk					,	//时钟
	//控制信号
	input											i_pll_lock			,	//解串时钟域，解串pll锁定信号
	input											i_acquisition_start	,	//开采信号，0-停采，1-开采
	input											i_stream_enable		,	//流使能信号
	input											i_trigger_start		,	//clk_pix时钟域，持续大概13个i2c命令周期.1:i2c restart命令开始
	input											i_trigger_mode		,	//clk_pix时钟域，ctrl_channel输出，0-连续采集，1-触发采集
	//图像数据
	input											i_fval				,	//解串时钟域，输入场信号
	input											i_lval				,	//解串时钟域，输入行信号
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data			,	//解串时钟域，输入图像数据
	//输出trigger_mode信号
	output											o_trigger_mode		,	//解串时钟域，输出trigger_mode信号
	output											o_trigger_status	,	//解串时钟域，1-有触发信号且触发帧未输出完毕，0-无触发信号或触发帧输出完毕
	//输出信号
	output											o_fval				,	//解串时钟域，输出场信号
	output											o_lval				,	//解串时钟域，输出行信号
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data			 	//解串时钟域，输出图像数据
	);

	//	ref signals


	//  -------------------------------------------------------------------------------------
	//	ref localparam
	//  -------------------------------------------------------------------------------------
	localparam	TRIGGER_STATUS_INTERVAL_CNT	=	CLK_FREQ_KHZ*TRIGGER_STATUS_INTERVAL;

	//  -------------------------------------------------------------------------------------
	//	ref reg & wire
	//  -------------------------------------------------------------------------------------
	reg		[2:0]								trigger_start_shift			= 3'b0;
	wire										trigger_start_rise			;
	reg		[2:0]								pll_lock_shift				= 3'b0;
	wire										pll_lock_rise				;
	reg											enable						= 1'b0;
	reg		[6:0]								trigger_mode_shfit			= 7'b0;
	reg											lval_dly					= 1'b0;
	reg											fval_dly					= 1'b0;
	wire										fval_rise					;
	wire										fval_fall					;
	reg											image_enable_dly			= 1'b0;
	wire										image_enable_fall			;


	reg											trigger_mode_lock			= 1'b0;

	wire										counter_reset				;//计数器复位信号
	wire	[31:0]								counter_q					;//计数器输出
	wire										trigger_status_reset		;//trigger_status复位信号

	reg											trigger_status				= 1'b0;
	reg											pll_lock_for_trig			= 1'b0;//restart之后，解串PLL已稳定锁定
	reg											pll_lock_for_continue		= 1'b0;//restart之后，解串PLL已稳定锁定
	reg											image_enable				= 1'b0;//图像输出使能，1-输出图像，0-不输出图像

	reg		[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	pix_data_dly				= 'b0;
	reg		[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	pix_data_reg				= 'b0;
	reg											fval_reg					= 1'b0;
	reg											lval_reg					= 1'b0;


	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref create edge
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	i_trigger_start 取边沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		trigger_start_shift	<=	{trigger_start_shift[1:0],i_trigger_start};
	end
	assign		trigger_start_rise	= (trigger_start_shift[2:1]==2'b01);

	//  -------------------------------------------------------------------------------------
	//	i_pll_lock 取边沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		pll_lock_shift	<=	{pll_lock_shift[1:0],i_pll_lock};
	end
	assign		pll_lock_rise	= (pll_lock_shift[2:1]==2'b01);

	//	-------------------------------------------------------------------------------------
	//	使能信号
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		enable	<= i_acquisition_start & i_stream_enable;
	end

	//  -------------------------------------------------------------------------------------
	//	行场信号
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_dly	<=	i_fval;
		lval_dly	<=	i_lval;
	end
	assign	fval_rise	= (fval_dly==1'b0 && i_fval==1'b1) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_dly==1'b1 && i_fval==1'b0) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	image_enable
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		image_enable_dly	<= image_enable;
	end
	assign	image_enable_fall	= {image_enable_dly,image_enable}==2'b10;

	//  ===============================================================================================
	//	ref trigger mode
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	trigger_mode 延时
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		trigger_mode_shfit	<=	{trigger_mode_shfit[5:0],i_trigger_mode};
	end
	//  -------------------------------------------------------------------------------------
	//	trigger_mode_lock
	//	在场消隐期间
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_fval==1'b0 && trigger_status==1'b0) begin
			trigger_mode_lock	<= trigger_mode_shfit[6];
		end
	end

	//  -------------------------------------------------------------------------------------
	//	纠错机制，防止trigger_status=1时发生失锁造成模块异常
	//	加法器，用DSP时间32bit加法
	//	-------------------------------------------------------------------------------------
	binary_counter binary_counter_inst (
	.clk				(clk					),
	.sclr				(counter_reset			),
	.q					(counter_q				)
	);

	//在 trigger_status 为0 或者 计数满的时候，加法器清零
	assign	counter_reset			= (trigger_status==1'b0 || (counter_q==TRIGGER_STATUS_INTERVAL_CNT)) ? 1'b1 : 1'b0;
	//当计数器满的时候， trigger_status 复位
	assign	trigger_status_reset	= (counter_q==TRIGGER_STATUS_INTERVAL_CNT) ? 1'b1 : 1'b0;

	//  ===============================================================================================
	//	ref cut one frame in trigger mode
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	trigger_status 高电平持续的时间表示 从触发信号发出 到 一帧图像接收完
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	trigger_status=1持续1100ms，则将trigger_status置0
		//	-------------------------------------------------------------------------------------
		if(trigger_status_reset) begin
			trigger_status	<=	1'b0;
		end
		//	-------------------------------------------------------------------------------------
		//	i2c开始发送，则将trigger_status控制置为1，表示逻辑进入触发状态
		//	-------------------------------------------------------------------------------------
		else if(trigger_start_rise) begin
			trigger_status	<=	1'b1;
		end
		//	-------------------------------------------------------------------------------------
		//	在场消隐期间且停采的时候，则trigger_status置0，中断触发过程
		//	大曝光时间下，触发信号之后，在曝光时间停采，需要立即停止
		//	-------------------------------------------------------------------------------------
		else if(i_fval==1'b0 && enable==1'b0) begin
			trigger_status	<=	1'b0;
		end
		//	-------------------------------------------------------------------------------------
		//	触发帧输出完毕后trigger_status置为0
		//	-------------------------------------------------------------------------------------
		else if(image_enable_fall) begin
			trigger_status	<=	1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	pll_lock_for_trig
	//	i2c restart命令发送后，解串PLL的lock会变低，此时我们将PLL复位1ms，复位结束后进入稳定的锁定状态，
	//	通过检测在trigger_status=1时，解串PLL的lock信号出现上升沿，就认为解串PLL稳定锁定了
	//	该信号只在触发状态下有效
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(trigger_status) begin
			if(pll_lock_rise) begin
				pll_lock_for_trig		<=	1'b1;
			end
		end
		else begin
			pll_lock_for_trig		<=	1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	pll_lock_for_continue
	//	该信号是为了解决触发切连续时残帧的问题
	//	触发且连续的时候，会发出 restart sensor 的命令。PLL会失锁。
	//	因此在连续模式下，要看到 pll lock rise ，才认为是一个完整帧
	//	连续模式下开采也会有restart的操作，固件有一套开采的流程，通过固件的流程屏蔽了残帧
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!trigger_mode_lock) begin
			if(pll_lock_rise) begin
				pll_lock_for_continue		<=	1'b1;
			end
		end
		else begin
			pll_lock_for_continue		<=	1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	image_enable 图像使能信号
	//	连续模式下，一直为1
	//	触发模式下，抓取触发信号之后的第一个完整帧
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//	-------------------------------------------------------------------------------------
		//	连续模式下，只要pll lock有过一次上升沿，则一直为高
		//	-------------------------------------------------------------------------------------
		if(!trigger_mode_lock) begin
			if(pll_lock_for_continue) begin
				image_enable	<=	1'b1;
			end
			else begin
				image_enable	<=	1'b0;
			end
		end
		//	-------------------------------------------------------------------------------------
		//	触发模式下，要抓取sensor restart 之后的第一个完整帧
		//	1.pll_lock_for_trig==1 表示触发信号已经发出，且pll lock已经重新锁定
		//	2.fval rise==1 表示pll lock之后，有一个完整帧来了，这就是我们要抓取的第一个完整帧
		//	3.fval fall==1 表示一个触发已经结束
		//	-------------------------------------------------------------------------------------
		else begin
			if(pll_lock_for_trig) begin
				if(fval_rise) begin
					image_enable	<=	1'b1;
				end
				else if(fval_fall) begin
					image_enable	<=	1'b0;
				end
			end
			else begin
				image_enable	<=	1'b0;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	ref output
	//  -------------------------------------------------------------------------------------
	//	-------------------------------------------------------------------------------------
	//	触发相关信号输出
	//	-------------------------------------------------------------------------------------
	assign	o_trigger_mode		= trigger_mode_lock;
	assign	o_trigger_status	= trigger_status;

	//  -------------------------------------------------------------------------------------
	//	数据输出
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_fval==1'b1 && i_lval==1'b1) begin
			pix_data_dly	<=	iv_pix_data;
		end
	end

	always @ (posedge clk) begin
		if(fval_dly & lval_dly & image_enable) begin
			pix_data_reg	<=	pix_data_dly;
		end
		else begin
			pix_data_reg	<=	{SENSOR_DAT_WIDTH*CHANNEL_NUM{1'b1}};
		end
	end
	assign	ov_pix_data	= pix_data_reg;

	//	-------------------------------------------------------------------------------------
	//	行场信号输出
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_reg	<=	fval_dly & image_enable;
		lval_reg	<=	lval_dly & image_enable;
	end
	assign	o_fval	= fval_reg;
	assign	o_lval	= lval_reg;


endmodule