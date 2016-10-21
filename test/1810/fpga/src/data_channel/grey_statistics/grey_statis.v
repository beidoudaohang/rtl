//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : grey_statis
//  -- 设计者       : 陕天龙
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//	-- 陕天龙		:| 2015/10/14 10:13:14	:|	初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 灰度统计模块
//              1)  : 根据 aoi 行场信号，累加每个像素
//
//              2)  : o_fval延时1个时钟
//
//              3)  : 统计高8bit
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module grey_statis # (
	parameter						SENSOR_DAT_WIDTH	= 10	,	//sensor 数据宽度
	parameter						CHANNEL_NUM			= 4		,	//sensor 通道数量
	parameter						GREY_STATIS_WIDTH	= 48	,	//灰度统计模块统计值宽度
	parameter						REG_WD				= 32		//寄存器位宽
	)
	(
	//Sensor输入信号
	input											clk						,	//像素时钟
	input											i_fval					,	//场信号
	input											i_lval					,	//行信号
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data				,	//图像数据
	//其他模块输入
	input											i_interrupt_pin			,	//中断模块输出的中断信号，1-中断有效。在中断上升沿时，锁存灰度统计值和窗口寄存器到端口
	output	[GREY_STATIS_WIDTH-1:0]					ov_grey_statis_sum			//该寄存器值为图像灰度统计值总和
	);


	//	ref signals

	reg												fval_dly0		= 1'b0;
	wire											fval_rise		;
	reg												int_pin_dly		= 1'b0;
	wire											int_pin_rise	;
	reg		[GREY_STATIS_WIDTH-1:0]					grey_statis		= {GREY_STATIS_WIDTH{1'b0}};
	reg		[GREY_STATIS_WIDTH-1:0]					grey_statis_reg	= {GREY_STATIS_WIDTH{1'b0}};


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
	//	ref ***统计像素***
	//  ===============================================================================================
	generate
		if 	(CHANNEL_NUM == 1) begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					grey_statis	<= {GREY_STATIS_WIDTH{1'b0}};
				end
				else begin
					if(i_lval) begin
						grey_statis	<= grey_statis + iv_pix_data[(SENSOR_DAT_WIDTH-1):(SENSOR_DAT_WIDTH-8)];
					end
				end
			end
		end
		else if (CHANNEL_NUM == 2) begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					grey_statis	<= {GREY_STATIS_WIDTH{1'b0}};
				end
				else begin
					if(i_lval) begin
						grey_statis	<= grey_statis + iv_pix_data[(2*SENSOR_DAT_WIDTH-1):(2*SENSOR_DAT_WIDTH-8)]
													   + iv_pix_data[(SENSOR_DAT_WIDTH-1):(SENSOR_DAT_WIDTH-8)];
					end
				end
			end
		end
		else if (CHANNEL_NUM == 4) begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					grey_statis	<= {GREY_STATIS_WIDTH{1'b0}};
				end
				else begin
					if(i_lval) begin
						grey_statis	<= grey_statis + iv_pix_data[(4*SENSOR_DAT_WIDTH-1):(4*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(3*SENSOR_DAT_WIDTH-1):(3*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(2*SENSOR_DAT_WIDTH-1):(2*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(SENSOR_DAT_WIDTH-1):(SENSOR_DAT_WIDTH-8)];
					end
				end
			end
		end
		else if (CHANNEL_NUM == 8) begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					grey_statis	<= {GREY_STATIS_WIDTH{1'b0}};
				end
				else begin
					if(i_lval) begin
						grey_statis	<= grey_statis + iv_pix_data[(8*SENSOR_DAT_WIDTH-1):(8*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(7*SENSOR_DAT_WIDTH-1):(7*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(6*SENSOR_DAT_WIDTH-1):(6*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(5*SENSOR_DAT_WIDTH-1):(5*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(4*SENSOR_DAT_WIDTH-1):(4*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(3*SENSOR_DAT_WIDTH-1):(3*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(2*SENSOR_DAT_WIDTH-1):(2*SENSOR_DAT_WIDTH-8)]
												   + iv_pix_data[(SENSOR_DAT_WIDTH-1):(SENSOR_DAT_WIDTH-8)];
					end
				end
			end
		end
	endgenerate

	//  ===============================================================================================
	//	ref ***输出统计结果***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	在中断信号的上升沿，将内部统计结果锁存到端口上
	//  -------------------------------------------------------------------------------------

	always @ (posedge clk) begin
		if(int_pin_rise) begin
			grey_statis_reg <= grey_statis;
		end
	end

	assign	ov_grey_statis_sum	= grey_statis_reg;


endmodule
