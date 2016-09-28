//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : interupt
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/5 15:54:33	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 中断管理模块
//              1)  : 负责中断状态和中断引脚
//
//              2)  : 3014的中断引脚高有效，高电平最少100ns
//
//              3)  : 中断允许时，开采之后第一个完整帧会输出中断信号
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module interrupt # (
	parameter			REG_WD			= 32	,	//寄存器位宽
	parameter			TIME_INTERVAL	= 3600000	//中断间隔
	)
	(
	//Sensor输入信号
	input					clk					,	//像素时钟
	input					i_fval				,	//场信号，灰度统计模块输出
	//中断相关寄存器
	input					i_acquisition_start	,	//开采信号，0-停采，1-开采
	input					i_stream_enable		,	//流使能信号，0-停采，1-开采
	input					i_interrupt_en_grey	,	//2a中断使能，高有效
	input					i_interrupt_en_wb	,	//白平衡中断使能，高有效
	input	[1:0]			iv_interrupt_clear	,	//中断自清零信号，高有效，控制通道自清零，bit0-清2a中断，bit1-清白平衡中断
	output	[1:0]			ov_interrupt_state	,	//中断状态，与中断使能对应，高有效。bit0-2a中断状态，bit1-白平衡中断状态
	output					o_interrupt				//发到外部的中断信号，中断频率20Hz以下。高有效，宽度最少是100ns
	);

	//	ref signals
	reg		[1:0]			fval_shift			= 2'b0;
	wire					fval_rise			;
	wire					fval_fall			;
	reg						fval_fall_dly0		= 1'b0;
	reg						fval_fall_dly1		= 1'b0;
	reg						fval_rise_reg		= 1'b0;
	reg						full_frame_state	= 1'b0;
	reg		[1:0]			internal_state		= 2'b0;
	reg		[1:0]			interface_state		= 2'b0;
	reg		[21:0]			div_72m_50ms_cnt	= TIME_INTERVAL;
	reg						time_up				= 1'b0;
	reg						int_rise			= 1'b0;
	reg		[4:0]			extend_int_cnt		= 5'b10000;	//默认值是最大值，保证中断输出在上电的时候是低电平
	reg						interrupt_reg		= 1'b0;

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***取边沿***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	fval 取边沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_shift	<= {fval_shift[0],i_fval};
	end
	assign	fval_rise	= (fval_shift[1:0]==2'b01) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_shift[1:0]==2'b10) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	fval延时信号
	//	1.fval_fall			- fval下降沿，用于推断完整帧状态
	//	2.fval_fall_dly0	- fval打一拍，用于推断内部中断状态
	//	3.fval_fall_dly1	- fval打两拍，用于推断中断引脚的状态
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_fall_dly0	<= fval_fall;
		fval_fall_dly1	<= fval_fall_dly0;
	end
	
	//  ===============================================================================================
	//	ref ***完整帧***
	//	1.当两个开采信号都使能时，看到一个fval上升沿和一个fval下降沿，才认为是1个完整帧
	//	2.这样就把开采之后的第一帧的中断丢弃，即使是完整帧，也会丢弃。但是对于3a来说影响不大。重要的是保证完整帧
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	fval 上升沿寄存器
	//	1.当使能无效时，寄存器清零
	//	2.当使能有效时，在fval上升沿的时候，寄存器置1
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((i_acquisition_start&i_stream_enable)==1'b0) begin
			fval_rise_reg	<= 1'b0;
		end
		else begin
			if(fval_rise) begin
				fval_rise_reg	<= 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	fval 下降沿寄存器
	//	1.当上升沿寄存器有效时，在fval下降沿的时候，寄存器置1
	//	2.当上升沿寄存器无效时，寄存器清零
	//	3.先上升沿，后下降沿的顺序
	//	4.当上升沿和下降沿寄存器都有效的时候，说明在使能有效的时候，经历一个完整帧
	//	5.这样会造成开采之后，第一帧的3a统计不发出中断。目的是为了防止开采后的第一帧可能会是残帧，导致统计错误。
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_rise_reg) begin
			if(fval_fall) begin
				full_frame_state	<= 1'b1;
			end
		end
		else begin
			full_frame_state	<= 1'b0;
		end
	end

	//  ===============================================================================================
	//	ref ***内部中断状态***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	--ref 2a-内部中断状态
	//	1.完整帧使能无效时，内部中断状态立即清零
	//	2.完整帧使能有效时，中断使能无效，内部中断状态清零
	//	3.完整帧使能有效时，中断使能有效，在场信号下降沿(打一拍之后的信号)时，内部中断状态置1
	//	4.完整帧使能有效时，中断使能有效，clear有效时，内部中断状态清零
	//	5.3 4 同时发生，3优先
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!full_frame_state) begin
			internal_state[0]	<= 1'b0;
		end
		else begin
			if(!i_interrupt_en_grey) begin
				internal_state[0]	<= 1'b0;
			end
			else begin
				if(fval_fall_dly0) begin
					internal_state[0]	<= 1'b1;
				end
				else if(iv_interrupt_clear[0]) begin
					internal_state[0]	<= 1'b0;
				end
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	--ref wb-内部中断状态
	//	1.完整帧使能无效时，内部中断状态立即清零
	//	2.完整帧使能有效时，中断使能无效，内部中断状态清零
	//	3.完整帧使能有效时，中断使能有效，在场信号下降沿(打一拍之后的信号)时，内部中断状态置1
	//	4.完整帧使能有效时，中断使能有效，clear有效时，内部中断状态清零
	//	5.3 4 同时发生，3优先
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!full_frame_state) begin
			internal_state[1]	<= 1'b0;
		end
		else begin
			if(!i_interrupt_en_wb) begin
				internal_state[1]	<= 1'b0;
			end
			else begin
				if(fval_fall_dly0) begin
					internal_state[1]	<= 1'b1;
				end
				else if(iv_interrupt_clear[1]) begin
					internal_state[1]	<= 1'b0;
				end
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	ref ***接口中断状态***
	//	1.内部中断状态清零时，接口中断状态清零
	//	2.内部中断状态=1时，在int上升沿时，接口中断状态=1
	//  -------------------------------------------------------------------------------------
	genvar j;
	generate
		for(j=0;j<=1;j=j+1) begin
			always @ (posedge clk) begin
				if(!internal_state[j]) begin
					interface_state[j]	<= 1'b0;
				end
				else begin
					if(int_rise) begin
						interface_state[j]	<= 1'b1;
					end
				end
			end
		end
	endgenerate
	assign	ov_interrupt_state	= interface_state;

	//  ===============================================================================================
	//	ref ***50ms 中断间隔**
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref 50ms计数器
	//	1.72MHz的时钟，需要计数到3600000，才会是50ms，16进制是0x36EE80，22位宽
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(int_rise) begin
			div_72m_50ms_cnt	<= 22'b0;
		end
		else begin
			if(div_72m_50ms_cnt==TIME_INTERVAL) begin
				div_72m_50ms_cnt	<= div_72m_50ms_cnt;
			end
			else begin
				div_72m_50ms_cnt	<= div_72m_50ms_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	计数时间到标志
	//	1.当计数到达50ms时，time up=1
	//	2.当计数未到达50ms时，time up=0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(div_72m_50ms_cnt==TIME_INTERVAL) begin
			time_up	<= 1'b1;
		end
		else begin
			time_up	<= 1'b0;
		end
	end
	
	//  -------------------------------------------------------------------------------------
	//	--ref 中断发出标志
	//	1.当50ms时间到了，且fval下降沿(打两拍之后的信号)有效，如果中断状态时全零，则输出为0
	//	2.当50ms时间到了，且fval下降沿(打两拍之后的信号)有效，如果中断状态时至少有1个1，则输出为1
	//	3.否则，中断标志=0
	//	4.中断标志高电平宽度是1个时钟周期
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(time_up&fval_fall_dly1) begin
			if(internal_state[1:0]==2'b00) begin
				int_rise	<= 1'b0;
			end
			else begin
				int_rise	<= 1'b1;
			end
		end
		else begin
			int_rise	<= 1'b0;
		end
	end

	//  ===============================================================================================
	//	ref ***发出中断***
	//	3014的中断信号是高有效，最低宽度是100ns
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	中断展宽寄存器
	//	1.当中断标志有效时，展宽寄存器清零
	//	2.当中断标志无效时，如果计数器最高位=1，则停止计数，否则继续计数
	//	3.72MHz的频率，计数16个周期，宽度是222ns
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(int_rise) begin
			extend_int_cnt	<= 5'b0;
		end
		else begin
			if(extend_int_cnt[4]==1'b1) begin
				extend_int_cnt	<= extend_int_cnt;
			end
			else begin
				extend_int_cnt	<= extend_int_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	中断寄存器，对展宽寄存器最高位取反
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		interrupt_reg	<= !extend_int_cnt[4];
	end
	assign	o_interrupt	= interrupt_reg;



endmodule