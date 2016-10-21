//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : wb_statis
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/2/13 10:30:32	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 根据前级输入的统计区域，完成分量统计
//              1)  : G分量统计值/2 其他分量统计值不变
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wb_statis # (
	parameter					SENSOR_DAT_WIDTH	= 10	,	//sensor 数据宽度
	parameter					CHANNEL_NUM			= 4		,	//通道数
	parameter					WB_STATIS_WIDTH		= 29	,	//白平衡模块统计值宽度
	parameter					REG_WD				= 32		//寄存器位宽
	)
	(
	input										clk						,	//像素时钟
	input										i_fval					,	//场信号
	input										i_lval					,	//行信号
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	iv_pix_data				,	//图像数据
	input	[CHANNEL_NUM-1:0]					iv_r_flag				,	//颜色分量标志 R
	input	[CHANNEL_NUM-1:0]					iv_g_flag				,	//颜色分量标志 G
	input	[CHANNEL_NUM-1:0]					iv_b_flag				,	//颜色分量标志 B
	input										i_interrupt_pin			,	//中断模块输出的中断信号，1-中断有效。在中断上升沿时，锁存颜色分量统计值和窗口寄存器到端口
	output	[WB_STATIS_WIDTH-1:0]				ov_wb_statis_r			,	//如果像素格式为8bit，该值为图像R分量8bit统计值。如果像素格式为大于8bit，该值为图像R分量高8bit统计值。
	output	[WB_STATIS_WIDTH-1:0]				ov_wb_statis_g			,	//如果像素格式为8bit，该值为图像G分量8bit统计值除以2的结果。如果像素格式为大于8bit，该值为图像G分量高8bit统计值除以2的结果。
	output	[WB_STATIS_WIDTH-1:0]				ov_wb_statis_b				//如果像素格式为8bit，该值为图像B分量8bit统计值。如果像素格式为大于8bit，该值为图像B分量高8bit统计值。
	);

	//	ref signals
	reg									fval_dly0			= 1'b0;
	reg									fval_dly1			= 1'b0;
	wire								fval_rise			;
	reg									int_pin_dly			= 1'b0;
	wire								int_pin_rise		;
	reg		[WB_STATIS_WIDTH-1:0]		wb_statis_r			= 'b0;
	reg		[WB_STATIS_WIDTH:0]			wb_statis_g			= 'b0;
	reg		[WB_STATIS_WIDTH-1:0]		wb_statis_b			= 'b0;
	reg		[WB_STATIS_WIDTH-1:0]		wb_statis_r_reg		= {WB_STATIS_WIDTH{1'b0}};
	reg		[WB_STATIS_WIDTH-1:0]		wb_statis_g_reg		= {WB_STATIS_WIDTH{1'b0}};
	reg		[WB_STATIS_WIDTH-1:0]		wb_statis_b_reg		= {WB_STATIS_WIDTH{1'b0}};
	wire	[SENSOR_DAT_WIDTH-1:0]		wv_data_lane		[CHANNEL_NUM-1:0]	;


	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***延时 取边沿***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	场有效取边沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_dly0	<= i_fval;
	end
	assign	fval_rise	= (fval_dly0==1'b0 && i_fval==1'b1) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	中断取边沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		int_pin_dly	<= i_interrupt_pin;
	end
	assign	int_pin_rise	= (int_pin_dly==1'b0 && i_interrupt_pin==1'b1) ? 1'b1 : 1'b0;

	//  ===============================================================================================
	//	ref ***统计颜色分量***
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	划分通道
	//	--每个通道的位宽是 DESER_WIDTH 个bit
	//	--小端，最低的通道在低byte。
	//	-------------------------------------------------------------------------------------
	genvar	i;
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			assign	wv_data_lane[i]	= iv_pix_data[SENSOR_DAT_WIDTH*(i+1)-1:SENSOR_DAT_WIDTH*i];
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	定义统计函数，把所需要的颜色分量加起来
	//	--每个颜色分量都是相间排列的
	//	--只统计每个颜色分量的高8bit
	//	-------------------------------------------------------------------------------------
	function [WB_STATIS_WIDTH-1:0] rgb_sum;
		input	start;
		integer	j;
		begin
			rgb_sum	= 0;
			for(j=start;j<CHANNEL_NUM;j=j+2) begin
				rgb_sum	= rgb_sum + wv_data_lane[j][SENSOR_DAT_WIDTH-1:SENSOR_DAT_WIDTH-8];
			end
		end
	endfunction

	//  -------------------------------------------------------------------------------------
	//	r分量
	//	1.当场上升沿时，复位内部计数器
	//	2.当分量标志有效时，加上输入的像素数据
	//	3.颜色分量标志只在lval有效时=1，因此不需要lval作为条件
	//	4.只统计高8bit
	//  -------------------------------------------------------------------------------------
	generate
		if(CHANNEL_NUM==1) begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					wb_statis_r	<= {WB_STATIS_WIDTH{1'b0}};
				end
				else begin
					if(iv_r_flag[0]) begin
						wb_statis_r	<= wb_statis_r + rgb_sum(0);
					end
				end
			end
		end
		else begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					wb_statis_r	<= {WB_STATIS_WIDTH{1'b0}};
				end
				else begin
					if(iv_r_flag[0]) begin
						wb_statis_r	<= wb_statis_r + rgb_sum(0);
					end
					else if(iv_r_flag[1]) begin
						wb_statis_r	<= wb_statis_r + rgb_sum(1);
					end
				end
			end
		end
	endgenerate

	//  -------------------------------------------------------------------------------------
	//	g分量
	//  -------------------------------------------------------------------------------------
	generate
		if(CHANNEL_NUM==1) begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					wb_statis_g	<= {(WB_STATIS_WIDTH+1){1'b0}};
				end
				else begin
					if(iv_g_flag[0]) begin
						wb_statis_g	<= wb_statis_g + rgb_sum(0);
					end
				end
			end
		end
		else begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					wb_statis_g	<= {(WB_STATIS_WIDTH+1){1'b0}};
				end
				else begin
					if(iv_g_flag[0]) begin
						wb_statis_g	<= wb_statis_g + rgb_sum(0);
					end
					else if(iv_g_flag[1]) begin
						wb_statis_g	<= wb_statis_g + rgb_sum(1);
					end
				end
			end
		end
	endgenerate

	//  -------------------------------------------------------------------------------------
	//	g分量
	//  -------------------------------------------------------------------------------------
	generate
		if(CHANNEL_NUM==1) begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					wb_statis_b	<= {WB_STATIS_WIDTH{1'b0}};
				end
				else begin
					if(iv_b_flag[0]) begin
						wb_statis_b	<= wb_statis_b + rgb_sum(0);
					end
				end
			end
		end
		else begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					wb_statis_b	<= {WB_STATIS_WIDTH{1'b0}};
				end
				else begin
					if(iv_b_flag[0]) begin
						wb_statis_b	<= wb_statis_b + rgb_sum(0);
					end
					else if(iv_b_flag[1]) begin
						wb_statis_b	<= wb_statis_b + rgb_sum(1);
					end
				end
			end
		end
	endgenerate

	//  ===============================================================================================
	//	ref ***输出统计结果***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	r分量，在中断信号的上升沿，将内部统计结果锁存到端口上
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(int_pin_rise) begin
			wb_statis_r_reg	<= wb_statis_r;
		end
	end
	assign	ov_wb_statis_r	= wb_statis_r_reg;

	//  -------------------------------------------------------------------------------------
	//	g分量，在中断信号的上升沿，将内部统计结果锁存到端口上，输出值要除以2
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(int_pin_rise) begin
			wb_statis_g_reg	<= wb_statis_g[WB_STATIS_WIDTH:1];
		end
	end
	assign	ov_wb_statis_g	= wb_statis_g_reg;

	//  -------------------------------------------------------------------------------------
	//	b分量，在中断信号的上升沿，将内部统计结果锁存到端口上
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(int_pin_rise) begin
			wb_statis_b_reg	<= wb_statis_b;
		end
	end
	assign	ov_wb_statis_b	= wb_statis_b_reg;


endmodule
