//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : grey_aoi_sel
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/18 15:21:40	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 灰度统计窗口 中断管理
//              1)  : 根据固件设置的窗口，输出aoi 行场信号
//
//              2)  : 管理中断
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module grey_aoi_sel # (
	parameter						SENSOR_DAT_WIDTH	= 10	,	//sensor 数据宽度
	parameter						GREY_OFFSET_WIDTH	= 12		//灰度统计模块偏移位置寄存器宽度
	)
	(
	//Sensor输入信号
	input								clk						,	//像素时钟
	input								i_fval					,	//场信号
	input								i_lval					,	//行信号
	input	[SENSOR_DAT_WIDTH-1:0]		iv_pix_data				,	//图像数据
	//灰度统计相关寄存器
	input								i_interrupt_en			,	//2A中断使能，2A指的是自动曝光和自动增益，这两个功能在FPGA中由一个模块实现，因此如果要开启任意一项功能，就必须打开该中断如果不使能该中断，将关闭2A模块，以节省功耗
	input	[2:0]						iv_test_image_sel		,	//测试图选择寄存器,000:真实图,001:测试图像1灰度值帧递增,110:测试图像2静止的斜条纹,010:测试图像3滚动的斜条纹
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_x_start	,	//灰度值统计区域的x坐标起始点，固件设置的该寄存器值应该是相对于ROI的偏移
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_width	,	//灰度值统计区域的宽度
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_y_start	,	//灰度值统计区域的y坐标起始点，固件设置的该寄存器值应该是相对于ROI的偏移
	input	[GREY_OFFSET_WIDTH-1:0]		iv_grey_offset_height	,	//灰度值统计区域的高度
	output	[GREY_OFFSET_WIDTH-1:0]		ov_grey_offset_width	,	//锁存后的统计窗口，灰度值统计区域的宽度
	output	[GREY_OFFSET_WIDTH-1:0]		ov_grey_offset_height	,	//锁存后的统计窗口，灰度值统计区域的高度
	//其他模块交互
	output								o_interrupt_en			,	//输入中断=0，o_interrupt_en=0。一帧统计有效时，在i_fval下降沿，o_interrupt_en=1
	input								i_interrupt_pin			,	//中断模块输出的中断信号，1-中断有效。在中断上升沿时，锁存灰度统计值和窗口寄存器到端口
	output								o_fval					,	//场有效
	output								o_lval					,	//行有效
	output	[SENSOR_DAT_WIDTH-1:0]		ov_pix_data					//图像数据
	);

	//	ref signals
	reg									lval_dly0				= 1'b0;
	reg									lval_reg				= 1'b0;
	wire								lval_fall				;
	reg									fval_dly0				= 1'b0;
	reg									fval_dly1				= 1'b0;
	wire								fval_rise				;
	wire								fval_fall				;
	reg									int_pin_dly				= 1'b0;
	wire								int_pin_rise			;
	reg									interrupt_en_int		= 1'b0;
	reg									int_reg					= 1'b0;
	wire								aoi_enable				;
	reg									width_height_0			= 1'b0;
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_x_start_reg	= {GREY_OFFSET_WIDTH{1'b0}};
	//	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_x_end_reg	= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_width_reg	= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_y_start_reg	= {GREY_OFFSET_WIDTH{1'b0}};
	//	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_y_end_reg	= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_height_reg	= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_width_latch	= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		grey_offset_height_latch= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		line_cnt				= {GREY_OFFSET_WIDTH{1'b0}};
	reg		[GREY_OFFSET_WIDTH-1:0]		pix_cnt					= {GREY_OFFSET_WIDTH{1'b0}};
	reg									x_enable				= 1'b0;
	reg									y_enable				= 1'b0;
	reg		[SENSOR_DAT_WIDTH-1:0]		pix_data_dly0			= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		pix_data_dly1			= {SENSOR_DAT_WIDTH{1'b0}};


	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***延时 取边沿***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	行有效取边沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_dly0	<= i_lval;
	end
	assign	lval_fall	= (lval_dly0==1'b1 && i_lval==1'b0) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	场有效取边沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_dly0	<= i_fval;
		fval_dly1	<= fval_dly0;
	end
	assign	fval_rise	= (fval_dly0==1'b0 && i_fval==1'b1) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_dly1==1'b1 && fval_dly0==1'b0) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	中断取边沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		int_pin_dly	<= i_interrupt_pin;
	end
	assign	int_pin_rise	= (int_pin_dly==1'b0 && i_interrupt_pin==1'b1) ? 1'b1 : 1'b0;

	//  ===============================================================================================
	//	ref ***生效时机***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref aoi 行场信号生效时机
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	interrupt_en_int 内部中断使能
	//	1.当中断无效时，立即拉低
	//	2.在fval上升沿的时候，才能更新，为的是保证完整帧
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_interrupt_en) begin
			interrupt_en_int	<= 1'b0;
		end
		else if(fval_rise) begin
			interrupt_en_int	<= i_interrupt_en;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	判断宽高是否为0，如果为0，则取消使能
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(grey_offset_width_reg=={GREY_OFFSET_WIDTH{1'b0}} || grey_offset_height_reg=={GREY_OFFSET_WIDTH{1'b0}}) begin
			width_height_0	<= 1'b1;
		end
		else begin
			width_height_0	<= 1'b0;
		end
	end
	
	//  -------------------------------------------------------------------------------------
	//	aoi 行场 信号输出使能
	//	1.当内部中断信号=1 且 未选中测试图的时候，才能够输出aoi行场信号
	//	2.内部中断信号在灰度统计模块内部做生效时机，测试图选择寄存器是在外部做的生效时机
	//	3.当图像宽高不是0时
	//  -------------------------------------------------------------------------------------
	assign	aoi_enable	= (interrupt_en_int==1'b1 && iv_test_image_sel==3'b000 && width_height_0==1'b0) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	-- ref 窗口信息生效时机
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	在场有效的上升沿锁存窗口位置寄存器
	//	1.同时将起点值与宽高值相加，作为结束点。这样会增加2个寄存器
	//	2.如果不增加这2个寄存器，会在if表达式中做加法，组合逻辑延时就会大大延长.
	//		----经过synplify验证，后面的statis模块中的64bit加法逻辑是关键路径。在if中用加法表达式也不会造成额外的延时。
	//	3.结束点寄存器不做溢出保护，如果相加之后溢出，说明固件正在改变窗口，此时统计区域会有错误，在下一帧时就会恢复
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_rise) begin
			grey_offset_x_start_reg	<= iv_grey_offset_x_start;
			grey_offset_width_reg	<= iv_grey_offset_width;
			grey_offset_y_start_reg	<= iv_grey_offset_y_start;
			grey_offset_height_reg	<= iv_grey_offset_height;
			//			grey_offset_x_end_reg	<= iv_grey_offset_x_start + iv_grey_offset_width;
			//			grey_offset_y_end_reg	<= iv_grey_offset_y_start + iv_grey_offset_height;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	在中断使能上升沿的时候，将内部的宽高寄存器锁存到端口上
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(int_pin_rise) begin
			grey_offset_width_latch	<= grey_offset_width_reg;
			grey_offset_height_latch<= grey_offset_height_reg;
		end
	end
	assign	ov_grey_offset_width	= grey_offset_width_latch;
	assign	ov_grey_offset_height	= grey_offset_height_latch;

	//  -------------------------------------------------------------------------------------
	//	int_reg 中断输出
	//	1.aoi_enable=0时，o_interrupt_en输出0
	//	2.aoi_enable=1时，在fval下降沿判断aoi_enable是否使能
	//	--2.1当aoi_enable=1时，o_interrupt_en输出1
	//	--2.2当aoi_enable=0时，o_interrupt_en输出0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!aoi_enable) begin
			int_reg	<= 1'b0;
		end
		else begin
			if(fval_fall) begin
				int_reg	<= aoi_enable;
			end
		end
	end
	assign	o_interrupt_en	= int_reg;

	//  ===============================================================================================
	//	ref ***x y 方向使能***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	--ref 与方向使能相关的计数器
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	行计数器
	//	1.场有效=0时，计数器清零
	//	2.场有效=1且行下降沿有效时，计数器自增
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_fval) begin
			line_cnt	<= {GREY_OFFSET_WIDTH{1'b0}};
		end
		else begin
			if(lval_fall) begin
				line_cnt	<= line_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	像素计数器
	//	1.场有效=0时，计数器清零
	//	2.场有效=1时
	//	--2.1行有效=0时，计数器清零
	//	--2.2行有效=1时，计数器自增
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_fval) begin
			pix_cnt	<= {GREY_OFFSET_WIDTH{1'b0}};
		end
		else begin
			if(!i_lval) begin
				pix_cnt	<= {GREY_OFFSET_WIDTH{1'b0}};
			end
			else begin
				pix_cnt	<= pix_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	--ref x_enable 水平方向使能信号
	//	1.当AOI使能信号=0时，x_enable清零
	//	2.当AOI使能信号=1时，当处于fval=1时，pix_cnt=x的开始位置时，x_enable=1
	//	3.当AOI使能信号=1时，当处于fval=1时，当pix_cnt=x的结束位置时，x_enable=0
	//	4.当AOI使能信号=1时，当处于fval=0时，x_enable清零
	//	5.在fval上升沿的时候采集坐标寄存器，要用fval的延迟信号作为使能，否则会使用上一次的坐标值
	//	6.如果结束点溢出，导致end<start，则该帧的x_enable信号输出异常，该帧统计结果出错
	//	7.注意此处必须用fval_dly0，因为aoi_enable是与fval_dly0是同相位的
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!aoi_enable) begin
			x_enable	<= 1'b0;
		end
		else begin
			if(i_fval) begin
				if(i_lval) begin
					if(pix_cnt==grey_offset_x_start_reg) begin
						x_enable	<= 1'b1;
					end
					else if(pix_cnt==(grey_offset_x_start_reg+grey_offset_width_reg)) begin
						x_enable	<= 1'b0;
					end
				end
				else begin
					x_enable	<= 1'b0;
				end
			end
			else begin
				x_enable	<= 1'b0;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	--ref y_enable 水平方向使能信号
	//	1.当AOI使能信号=0时，y_enable清零
	//	2.当AOI使能信号=1时，当处于fval=1时，line_cnt=y的开始位置时，y_enable=1
	//	3.当AOI使能信号=1时，当处于fval=1时，当line_cnt=y的结束位置时，y_enable=0
	//	4.当AOI使能信号=1时，当处于fval=0时，y_enable清零
	//	5.在fval上升沿的时候采集坐标寄存器，要用fval的延迟信号作为使能，否则会使用上一次的坐标值
	//	6.如果结束点溢出，导致end<start，则该帧的y_enable信号输出异常，该帧统计结果出错
	//	7.注意此处必须用fval_dly0，因为aoi_enable是与fval_dly0是同相位的
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!aoi_enable) begin
			y_enable	<= 1'b0;
		end
		else begin
			if(fval_dly0) begin
				if(line_cnt==grey_offset_y_start_reg) begin
					y_enable	<= 1'b1;
				end
				else if(line_cnt==(grey_offset_y_start_reg+grey_offset_height_reg)) begin
					y_enable	<= 1'b0;
				end
			end
			else begin
				y_enable	<= 1'b0;
			end
		end
	end

	//  ===============================================================================================
	//	ref ***输出***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	lval 输出一共延时了2拍
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_reg	<= x_enable&y_enable;
	end
	assign	o_lval	= lval_reg;
	assign	o_fval	= fval_dly1;

	//  -------------------------------------------------------------------------------------
	//	数据输出跟随lval，也延迟2拍
	//	1.不要复位，可以使用LUT SRL结构
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		pix_data_dly0	<= iv_pix_data;
		pix_data_dly1	<= pix_data_dly0;
	end
	assign	ov_pix_data	= pix_data_dly1;


endmodule
