//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : stream_ctrl
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/4 16:54:58	:|  初始版本
//  -- 邢海涛       :| 2015/10/21 9:56:38	:|  从 sync_buffer 模块分离出流控制功能
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 完成2部分内容
//              1)  : 寄存器生效时机
//						数据通道共用的寄存器，需要在这个模块中做生效时机，在输入的fval上升沿时，采样寄存器
//				2)  : 开停采控制，输出经过完整帧控制的使能信号
//
//				3)  :
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module stream_ctrl # (
	parameter					SENSOR_DAT_WIDTH	= 10	,	//sensor 数据宽度
	parameter					CHANNEL_NUM			= 4		,	//串行数据通道数量
	parameter					REG_WD				= 32		//寄存器位宽
	)
	(
	//本地时钟域
	input											clk					,	//本地时钟域
	input											i_fval				,	//clk_pix时钟域，sync buffer输出的fval信号
	input											i_lval				,	//clk_pix时钟域，sync buffer输出的lval信号
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data			,	//clk_pix时钟域，sync buffer输出的pix data信号
	output											o_fval				,	//场有效，展宽o_fval，o_fval的前后沿包住l_fval约10个时钟
	output											o_lval				,	//行有效
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data			,	//图像数据
	//控制信号
	input											i_acquisition_start	,	//开采信号，0-停采，1-开采
	input											i_stream_enable		,	//流使能信号
	input											i_encrypt_state		,	//数据通路输出，dna 时钟域，加密状态。加密不通过，不输出图像
	//寄存器数据
	input	[REG_WD-1:0]							iv_pixel_format		,	//像素格式寄存器
	input	[2:0]									iv_test_image_sel	,	//测试图选择寄存器,000:真实图,001:测试图像1灰度值帧递增,110:测试图像2静止的斜条纹,010:测试图像3滚动的斜条纹
	//控制生效时机的寄存器
	output											o_full_frame_state	,	//完整帧状态,该寄存器用来保证停采时输出完整帧,0:停采时，已经传输完一帧数据,1:停采时，还在传输一帧数据
	output	[REG_WD-1:0]							ov_pixel_format		,	//在sync buffer中做生效时机控制
	output	[2:0]									ov_test_image_sel		//在sync buffer中做生效时机控制
	);

	//	ref signals
	reg												fval_dly			= 1'b0;
	wire											fval_rise			;
	reg												encrypt_state_dly0	= 1'b0;
	reg												encrypt_state_dly1	= 1'b0;
	reg												enable				= 1'b0;
	reg												fval_reg			= 1'b0;
	reg												lval_reg			= 1'b0;
	reg		[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		pix_data_reg		= 8'b0;
	reg												full_frame_state	= 1'b0;
	reg		[REG_WD-1:0]							pixel_format_reg	= {REG_WD{1'b0}};
	reg		[2:0]									test_image_sel_reg	= 3'b000;

	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref ***流使能控制***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	fval 取边沿
	//	1.异步时钟域传输，需要打三拍
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_dly	<= i_fval;
	end
	assign	fval_rise	= (fval_dly==1'b0 && i_fval==1'b1) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	加密状态同步
	//	1.i_encrypt_state是 osc bufg时钟域的信号，两次采样通过到pix时钟域
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		encrypt_state_dly0	<= i_encrypt_state;
		encrypt_state_dly1	<= encrypt_state_dly0;
	end

	//  -------------------------------------------------------------------------------------
	//	enable 完整帧使能控制信号
	//	1.在 i_fval 与 o_fval 都是低电平时，更新enable寄存器，enable=两个开采信号与加密状态的与结果
	//	2.在 i_fval 与 o_fval 至少有1个高电平时，保持enable寄存器，保证完整帧
	//	3.i_fval=1 o_fval=0时，下一个时钟周期，o_fval=1，此时不能再做完整帧判断，因为下一个周期肯定会输出fval
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_fval==1'b0 && o_fval==1'b0) begin
			enable	<= i_stream_enable & i_acquisition_start & encrypt_state_dly1;
		end
	end

	//  ===============================================================================================
	//	ref ***数据输出***
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	fval reg
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(enable==1'b0) begin
			fval_reg	<= 1'b0;
		end
		else begin
			fval_reg	<= i_fval;
		end
	end
	assign	o_fval	= fval_reg;

	//	-------------------------------------------------------------------------------------
	//	lval reg
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(enable==1'b0) begin
			lval_reg	<= 1'b0;
		end
		else begin
			lval_reg	<= i_lval;
		end
	end
	assign	o_lval	= lval_reg;

	//	-------------------------------------------------------------------------------------
	//	pix_data_reg
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(enable==1'b0) begin
			pix_data_reg	<= 'b0;
		end
		else begin
			pix_data_reg	<= iv_pix_data;
		end
	end
	assign	ov_pix_data	= pix_data_reg;

	//  ===============================================================================================
	//	ref ***标志、寄存器操作***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref 完整帧标志
	//	1.当 i_stream_enable=0时，清零完整帧标志
	//	2.当 i_fval_sync=0时，清零完整帧标志
	//	3.当 i_fval_sync=1且i_acquisition_start=0时，完整帧置位
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_stream_enable || !o_fval) begin
			full_frame_state	<= 1'b0;
		end
		else begin
			if(o_fval==1'b1 && i_acquisition_start==1'b0) begin
				full_frame_state	<= 1'b1;
			end
		end
	end
	assign	o_full_frame_state	= full_frame_state;

	//  -------------------------------------------------------------------------------------
	//	-- ref 寄存器生效时机控制
	//	1.当fval_rise=1，即一帧来临时，更新寄存器
	//	2.其他时刻，保持像素格式寄存器
	//	3.这些寄存器都是在数据通道中不止一个模块使用，因此要在数据通道的最前端控制
	//  -------------------------------------------------------------------------------------
	//	像素格式寄存器
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_rise) begin
			pixel_format_reg	<= iv_pixel_format;
		end
	end
	assign	ov_pixel_format		= pixel_format_reg;

	//  -------------------------------------------------------------------------------------
	//	测试图选择寄存器
	//	--如果写入的是非法值，则保留上一次的结果
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_rise) begin
			if(iv_test_image_sel==3'b000 || iv_test_image_sel==3'b001 || iv_test_image_sel==3'b110 || iv_test_image_sel==3'b010) begin
				test_image_sel_reg	<= iv_test_image_sel;
			end
		end
	end
	assign	ov_test_image_sel		= test_image_sel_reg;

endmodule