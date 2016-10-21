//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2016 -2020.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : width_cut
//  -- 设计者       : 陕天龙
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 陕天龙       :| 2016/3/28 9:48:27	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ns
//-------------------------------------------------------------------------------------------------
module width_cut #(
	parameter			SENSOR_DAT_WIDTH			= 10					,	//sensor 数据宽度
	parameter			CHANNEL_NUM					= 8						,	//串行数据通道数量
	parameter			SENSOR_MAX_WIDTH			= 1920					,	//Sensor最大的行有效宽度，以像素时钟为单位
	parameter			SHORT_REG_WD				= 16						//短寄存器位宽
	)
	(
	input											clk						,	//时钟
	input											i_fval					,	//输入场信号
	input											i_lval					,	//输入行信号
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_data					,	//输入数据
	input	[SHORT_REG_WD-1:0]						iv_offset_x				,	//ROI起始x
	input	[SHORT_REG_WD-1:0]						iv_offset_width			,	//ROI宽度
	output											o_fval					,	//输出场有效信号
	output											o_lval					,	//输出行有效信号
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data					//输出像素数据
	);

	//	-------------------------------------------------------------------------------------
	//
	//	-------------------------------------------------------------------------------------
	localparam			SHIFT_WIDTH					= log2(CHANNEL_NUM)		;
	localparam			CNT_WIDTH					= log2(SENSOR_MAX_WIDTH+1);

	reg		[CNT_WIDTH-1:0]							width_cnt	= 'b0		;	//行宽度计数
	wire	[CNT_WIDTH-1:0]							offset_x_start			;
	wire	[CNT_WIDTH-1:0]							offset_width			;

	reg		[1:0]									fval_shift	= 'b0		;
	reg												lval_reg	= 'b0		;
	reg		[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		pix_data	= 'b0		;

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
	//	场信号延时
	//	===============================================================================================
	always @ (posedge clk) begin
		fval_shift <= {fval_shift[0],i_fval};
	end

	assign	o_fval = fval_shift[0];


	//	===============================================================================================
	//	ref 剪切窗口
	//	===============================================================================================
	assign	offset_x_start	= (iv_offset_x >> SHIFT_WIDTH);
	assign	offset_width	= (iv_offset_width >> SHIFT_WIDTH);

	always @ (posedge clk) begin
		if (i_lval==1'b1) begin
			width_cnt <= width_cnt + 1;
		end
		else begin
			width_cnt <= 0;
		end
	end

	always @ (posedge clk) begin
		if (i_fval==1'b1) begin
			if (i_lval==1'b1) begin
				if (width_cnt==(offset_x_start+offset_width)) begin
					lval_reg <= 1'b0;
				end
				else if (width_cnt==offset_x_start) begin
					lval_reg <= 1'b1;
				end
			end
			else begin
				lval_reg <= 1'b0;
			end
		end
		else begin
			lval_reg <= 1'b0;
		end
	end

	assign	o_lval	= lval_reg;


	//	===============================================================================================
	//	数据延时
	//	===============================================================================================
	always @ (posedge clk) begin
		pix_data <= iv_data;
	end

	assign	ov_pix_data	= pix_data;



endmodule