//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : wb_aoi_sel
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/2/13 10:29:24	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 提取出aoi区域
//              1)  : 行场信号、RGB标志、像素数据，延迟2拍
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wb_aoi_sel # (
	parameter					SENSOR_DAT_WIDTH	= 10	,	//sensor 数据宽度
	parameter					CHANNEL_NUM			= 4		,	//通道数
	parameter					WB_OFFSET_WIDTH		= 12	,	//白平衡模块偏移位置寄存器宽度
	parameter					REG_WD				= 32		//寄存器位宽
	)
	(
	input										clk						,	//时钟输入
	input										i_fval					,	//场信号
	input										i_lval					,	//行信号
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	iv_pix_data				,	//图像数据
	input	[CHANNEL_NUM-1:0]					iv_r_flag				,	//颜色分量标志 R
	input	[CHANNEL_NUM-1:0]					iv_g_flag				,	//颜色分量标志 G
	input	[CHANNEL_NUM-1:0]					iv_b_flag				,	//颜色分量标志 B
	input										i_interrupt_en			,	//自动白平衡中断使能，0:不使能，1:使能。如果不使能该中断，将关闭白平衡统计功能，以节省功耗。
	output										o_interrupt_en			,	//输入中断=0，o_interrupt_en=0。一帧统计有效时，在i_fval下降沿，o_interrupt_en=1
	input										i_interrupt_pin			,	//中断模块输出的中断信号，1-中断有效。在中断上升沿时，锁存颜色分量统计值和窗口寄存器到端口
	input										i_mono_sel				,	//1:选中黑白模式，模块不工作。0：选中彩色模式，模块工作。
	input	[2:0]								iv_test_image_sel		,	//测试图选择寄存器,000:真实图,001:测试图像1灰度值帧递增,110:测试图像2静止的斜条纹,010:测试图像3滚动的斜条纹
	input	[WB_OFFSET_WIDTH-1:0]				iv_wb_offset_x_start	,	//白平衡统计区域的x坐标起始点，固件设置的该寄存器值应该是相对于ROI的偏移
	input	[WB_OFFSET_WIDTH-1:0]				iv_wb_offset_width		,	//白平衡统计区域的宽度
	input	[WB_OFFSET_WIDTH-1:0]				iv_wb_offset_y_start	,	//白平衡统计区域的y坐标起始点，固件设置的该寄存器值应该是相对于ROI的偏移
	input	[WB_OFFSET_WIDTH-1:0]				iv_wb_offset_height		,	//白平衡统计区域的高度
	output	[WB_OFFSET_WIDTH-1:0]				ov_wb_offset_width		,	//锁存后的统计窗口，白平衡统计区域的宽度
	output	[WB_OFFSET_WIDTH-1:0]				ov_wb_offset_height		,	//锁存后的统计窗口，白平衡统计区域的高度
	output										o_fval					,	//场有效
	output										o_lval					,	//行有效
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	ov_pix_data				,	//图像数据
	output	[CHANNEL_NUM-1:0]					ov_r_flag				,	//颜色分量输出 R
	output	[CHANNEL_NUM-1:0]					ov_g_flag				,	//颜色分量输出 G
	output	[CHANNEL_NUM-1:0]					ov_b_flag					//颜色分量输出 B
	);

	//	ref signals
	//LOG2函数
	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction
	//对通道个数取对数
	//--1通道，REDUCE_BIT=0
	//--2通道，REDUCE_BIT=1
	//--4通道，REDUCE_BIT=2
	//--8通道，REDUCE_BIT=3
	//--16通道，REDUCE_BIT=4
	localparam	REDUCE_BIT			= log2(CHANNEL_NUM);
	//总的aoi寄存器宽度减去通道数的对数，就是实际上使用的寄存器宽度，只有X方向的参数需要移位，Y方向的不需要
	localparam	WB_OFFSET_WIDTH_RB	= WB_OFFSET_WIDTH-REDUCE_BIT;

	reg												lval_dly0				= 1'b0;
	reg												lval_reg				= 1'b0;
	wire											lval_fall				;
	reg												fval_dly0				= 1'b0;
	reg												fval_dly1				= 1'b0;
	wire											fval_rise				;
	wire											fval_fall				;
	reg												int_pin_dly					= 1'b0;
	wire											int_pin_rise				;

	reg												interrupt_en_int		= 1'b0;
	reg												int_reg					= 1'b0;
	wire											aoi_enable				;
	reg												width_height_0			= 1'b0;
	reg		[WB_OFFSET_WIDTH_RB-1:0]				wb_offset_x_start_reg	= {WB_OFFSET_WIDTH_RB{1'b0}};
	//	reg		[WB_OFFSET_WIDTH_RB-1:0]			wb_offset_x_end_reg		= {WB_OFFSET_WIDTH_RB{1'b0}};
	reg		[WB_OFFSET_WIDTH_RB-1:0]				wb_offset_width_reg		= {WB_OFFSET_WIDTH_RB{1'b0}};
	reg		[WB_OFFSET_WIDTH-1:0]					wb_offset_y_start_reg	= {WB_OFFSET_WIDTH{1'b0}};
	//	reg		[WB_OFFSET_WIDTH-1:0]				wb_offset_y_end_reg		= {WB_OFFSET_WIDTH{1'b0}};
	reg		[WB_OFFSET_WIDTH-1:0]					wb_offset_height_reg	= {WB_OFFSET_WIDTH{1'b0}};
	reg		[WB_OFFSET_WIDTH_RB-1:0]				wb_offset_width_latch	= {WB_OFFSET_WIDTH_RB{1'b0}};
	reg		[WB_OFFSET_WIDTH-1:0]					wb_offset_height_latch	= {WB_OFFSET_WIDTH{1'b0}};

	reg		[WB_OFFSET_WIDTH-1:0]					line_cnt				= {WB_OFFSET_WIDTH{1'b0}};
	reg		[WB_OFFSET_WIDTH_RB-1:0]				pix_cnt					= {WB_OFFSET_WIDTH_RB{1'b0}};
	reg												x_enable				= 1'b0;
	reg												y_enable				= 1'b0;
	reg		[CHANNEL_NUM-1:0]						r_flag_dly0				= 'b0;
	reg		[CHANNEL_NUM-1:0]						r_flag_reg				= 'b0;
	reg		[CHANNEL_NUM-1:0]						g_flag_dly0				= 'b0;
	reg		[CHANNEL_NUM-1:0]						g_flag_reg				= 'b0;
	reg		[CHANNEL_NUM-1:0]						b_flag_dly0				= 'b0;
	reg		[CHANNEL_NUM-1:0]						b_flag_reg				= 'b0;
	reg		[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		pix_data_dly0			= {(SENSOR_DAT_WIDTH*CHANNEL_NUM){1'b0}};
	reg		[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		pix_data_dly1			= {(SENSOR_DAT_WIDTH*CHANNEL_NUM){1'b0}};



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

	//判断宽度为全0，消耗很多逻辑，不做这一层保护
	//	//  -------------------------------------------------------------------------------------
	//	//	判断宽高是否为0，如果为0，则取消使能
	//	//  -------------------------------------------------------------------------------------
	//	always @ (posedge clk) begin
	//		if(wb_offset_width_reg=={WB_OFFSET_WIDTH_RB{1'b0}} || wb_offset_height_reg=={WB_OFFSET_WIDTH{1'b0}}) begin
	//			width_height_0	<= 1'b1;
	//		end
	//		else begin
	//			width_height_0	<= 1'b0;
	//		end
	//	end

	//  -------------------------------------------------------------------------------------
	//	aoi 行场 信号输出使能
	//	1.当内部中断信号=1 且 像素格式是彩色的 且 未选中测试图的时候，才能够输出aoi行场信号
	//	2.内部中断信号在白平衡模块内部做生效时机，像素格式和测试图选择寄存器都是在外部做的生效时机
	//	3.当图像宽高不是0时
	//  -------------------------------------------------------------------------------------
	//	assign	aoi_enable	= (interrupt_en_int==1'b1 && i_mono_sel==1'b0 && iv_test_image_sel==3'b000 && width_height_0==1'b0) ? 1'b1 : 1'b0;
	assign	aoi_enable	= (interrupt_en_int==1'b1 && i_mono_sel==1'b0 && iv_test_image_sel==3'b000) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	-- ref 窗口信息生效时机
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	在场有效的上升沿锁存窗口位置寄存器
	//	--固件设置的aoi区域都是以每个像素为单位，如果是多通道的话，必须要对aoi参数做除法
	//	--1通道：位宽全部有效
	//	--2通道：每个时钟有2个像素，位宽/2
	//	--4通道：每个时钟有4个像素，位宽/4
	//	--8通道：每个时钟有8个像素，位宽/8
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_rise) begin
			wb_offset_x_start_reg	<= iv_wb_offset_x_start[WB_OFFSET_WIDTH-1:REDUCE_BIT];
			wb_offset_width_reg		<= iv_wb_offset_width[WB_OFFSET_WIDTH-1:REDUCE_BIT];
			wb_offset_y_start_reg	<= iv_wb_offset_y_start[WB_OFFSET_WIDTH-1:0];
			wb_offset_height_reg	<= iv_wb_offset_height[WB_OFFSET_WIDTH-1:0];

			//经过实际测试，没有必要增加end寄存器，这里不是最差路径，在这里做pipeline没有意义
			//wb_offset_x_end_reg		<= iv_wb_offset_x_start[WB_OFFSET_WIDTH-1:REDUCE_BIT] + iv_wb_offset_width[WB_OFFSET_WIDTH-1:REDUCE_BIT];
			//wb_offset_y_end_reg		<= iv_wb_offset_y_start[WB_OFFSET_WIDTH-1:0] + iv_wb_offset_height[WB_OFFSET_WIDTH-1:0];
		end
	end

	//  -------------------------------------------------------------------------------------
	//	在中断使能上升沿的时候，将内部的宽高寄存器锁存到端口上
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(int_pin_rise) begin
			wb_offset_width_latch	<= wb_offset_width_reg;
			wb_offset_height_latch	<= wb_offset_height_reg;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	返回到寄存器模块的时候，还要把丢掉的低位数据补上
	//	-------------------------------------------------------------------------------------
	assign	ov_wb_offset_width	= {wb_offset_width_latch,{REDUCE_BIT{1'b0}}};
	assign	ov_wb_offset_height	= wb_offset_height_latch;

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
	//	1.aoi不使能时，不统计颜色分量的灰度信息，因此计数器无需动作
	//	2.场有效=0时，计数器清零
	//	3.场有效=1且行下降沿有效时，计数器自增
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!aoi_enable || !i_fval) begin
			line_cnt	<= {WB_OFFSET_WIDTH_RB{1'b0}};
		end
		else begin
			if(lval_fall) begin
				line_cnt	<= line_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	像素计数器
	//	1.aoi不使能时，不统计颜色分量的灰度信息，因此计数器无需动作
	//	2.场有效=0时，计数器清零
	//	3.场有效=1时
	//	--3.1行有效=0时，计数器清零
	//	--3.2行有效=1时，计数器自增
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!aoi_enable || !i_fval || !i_lval) begin
			pix_cnt	<= {WB_OFFSET_WIDTH_RB{1'b0}};
		end
		else begin
			if(i_lval) begin
				pix_cnt	<= pix_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	--ref x_enable 水平方向使能信号
	//	1.当AOI使能信号=0时，或fval=0时，或lval=0时，x_enable清零
	//	2.当AOI使能信号=1时，且fval=1，且lval=1，pix_cnt=x的开始位置时，x_enable=1
	//	3.当AOI使能信号=1时，且fval=1，且lval=1，pix_cnt=x的结束位置时，x_enable=0
	//	4.在fval上升沿的时候采集坐标寄存器，要用fval的延迟信号作为使能，否则会使用上一次的坐标值
	//	5.如果结束点溢出，导致end<start，则该帧的x_enable信号输出异常，该帧统计结果出错
	//	6.注意此处必须用fval_dly0，因为aoi_enable是与fval_dly0是同相位的
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(aoi_enable==1'b0 || fval_dly0==1'b0 || i_lval==1'b0) begin
			x_enable	<= 1'b0;
		end
		else begin
			if(pix_cnt==wb_offset_x_start_reg) begin
				x_enable	<= 1'b1;
			end
			//在此处直接用加法表达式，没有必要再为了加法再做一个pipeline，此处不是关键路径
			else if(pix_cnt==(wb_offset_x_start_reg+wb_offset_width_reg)) begin
				x_enable	<= 1'b0;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	--ref y_enable 水平方向使能信号
	//	1.当AOI使能信号=0时，或fval=0时，y_enable清零
	//	2.当AOI使能信号=1时，且fval=1，且lval=1，line_cnt=x的开始位置时，y_enable=1
	//	3.当AOI使能信号=1时，且fval=1，且lval=1，line_cnt=x的结束位置时，y_enable=0
	//	4.在fval上升沿的时候采集坐标寄存器，要用fval的延迟信号作为使能，否则会使用上一次的坐标值
	//	5.如果结束点溢出，导致end<start，则该帧的y_enable信号输出异常，该帧统计结果出错
	//	6.注意此处必须用fval_dly0，因为aoi_enable是与fval_dly0是同相位的
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(aoi_enable==1'b0 || fval_dly0==1'b0) begin
			y_enable	<= 1'b0;
		end
		else begin
			if(line_cnt==wb_offset_y_start_reg) begin
				y_enable	<= 1'b1;
			end
			else if(line_cnt==(wb_offset_y_start_reg+wb_offset_height_reg)) begin
				y_enable	<= 1'b0;
			end
		end
	end

	//  ===============================================================================================
	//	ref ***输出***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	lval 输出延时2拍
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_reg	<= x_enable&y_enable;
	end
	assign	o_lval	= lval_reg;
	assign	o_fval	= fval_dly1;

	//  -------------------------------------------------------------------------------------
	//	颜色分量的输出，也延迟3拍，当方向输出不使能时，不输出
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	R 分量 延迟2拍输出
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		r_flag_dly0	<= iv_r_flag;
	end
	always @ (posedge clk) begin
		if(x_enable&y_enable) begin
			r_flag_reg	<= r_flag_dly0;
		end
		else begin
			r_flag_reg	<= 'b0;
		end
	end
	assign	ov_r_flag	= r_flag_reg;

	//  -------------------------------------------------------------------------------------
	//	G 分量 延迟2拍输出
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		g_flag_dly0	<= iv_g_flag;
	end
	always @ (posedge clk) begin
		if(x_enable&y_enable) begin
			g_flag_reg	<= g_flag_dly0;
		end
		else begin
			g_flag_reg	<= 'b0;
		end
	end
	assign	ov_g_flag	= g_flag_reg;

	//  -------------------------------------------------------------------------------------
	//	B 分量 延迟2拍输出
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		b_flag_dly0	<= iv_b_flag;
	end
	always @ (posedge clk) begin
		if(x_enable&y_enable) begin
			b_flag_reg	<= b_flag_dly0;
		end
		else begin
			b_flag_reg	<= 'b0;
		end
	end
	assign	ov_b_flag	= b_flag_reg;

	//  -------------------------------------------------------------------------------------
	//	数据输出，延迟2拍
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		pix_data_dly0	<= iv_pix_data;
		pix_data_dly1	<= pix_data_dly0;
	end
	assign	ov_pix_data	= pix_data_dly1;



endmodule