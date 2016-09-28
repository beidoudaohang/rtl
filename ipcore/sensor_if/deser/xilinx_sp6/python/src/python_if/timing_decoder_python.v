
//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : timing_decoder_python.v
//  -- 设计者       : 禹剑
//-------------------------------------------------------------------------------------------------
//
//  --修改记录  :
//
//  -- 作者         :| 修改日期     :|  修改说明
//---------------------------------------------------------------------------------------
//  -- 禹剑       	:| 04/17/2013   :|  初始版本
//	-- 陕天龙		:| 2015/9/1 14:08:10	:|	添加说明
//---------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : 采用参数传递，注释掉了给参数赋初值0的代码
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale      1ns/100ps
//-------------------------------------------------------------------------------------------------

module timing_decoder_python #(
	parameter	SENSOR_DAT_WIDTH	= 10		,	//sensor 数据宽度
	parameter	CHANNEL_NUM			= 4				//sensor 通道数量
	)
	(
	input                                   			clk      			,   //时钟
	input												reset				,	//复位，高有效
	input												clk_en				,
	input       [SENSOR_DAT_WIDTH-1:0]			 		iv_ctrl             ,   //控制信号
	input      	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_data             ,   //数据信号
	output  reg 										o_dval				,   //输出
	output  reg 										o_fval				,   //输出
	output												o_clk_en			,
	output  reg [SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		ov_data                 //输出
	);

	//  ===============================================================================================
	//  第一部分：模块设计中要用到的信号
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  寄存器、线网定义
	//  -------------------------------------------------------------------------------------

	localparam	FS		= 10'h2aa	;
	localparam	FSS		= 10'h22a	;
	localparam	FE		= 10'h32a	;	//BIT_MODE'h32a
	localparam	FSE		= 10'h3aa	;	//BIT_MODE'h3aa
	localparam	TR		= 10'h3a6	;	//空闲状态
	localparam	LS		= 10'h0aa	;	//BIT_MODE'h0aa
	localparam	LE		= 10'h12a	;	//BIT_MODE'h12a
	localparam	IMG		= 10'h035	;	//BIT_MODE'h035
	localparam	BL		= 10'h015	;	//BIT_MODE'h015
	localparam	CRC		= 10'h059	;	//BIT_MODE'h059
	localparam	ID		= 10'h010	;	//参数值原本为0，仿真需要暂改为10'h010

	reg			[SENSOR_DAT_WIDTH-1:0]					ctrl_dly_0		=  'b0;
	reg			[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		data_dly_0		=  'b0;

	reg			[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	data_dly_1		=  'b0;
	reg			[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	data_dly_2		=  'b0;
	reg			[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	data_dly_3		=  'b0;
	reg			[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	data_dly_4		=  'b0;
	reg			[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	data_dly_5		=  'b0;
	reg			[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	data_dly_6		=  'b0;

	reg												fval_reg_0		='b0	;
	reg												fval_reg_1		='b0	;
	reg												fval_reg_2		='b0	;
	reg												fval_reg_3		='b0	;
	reg												fval_reg_4		='b0	;

	reg												dval_reg_0		='b0	;
	reg												dval_reg_1		='b0	;
	reg												dval_reg_2		='b0	;
	reg												dval_reg_3		='b0	;
	reg												dval_reg_4		='b0	;

	reg												dval			='b0	;
	reg												fval			='b0	;

	reg			[      						1 : 0]	dval_shift	='b0		;
	reg			[      						7 : 0]	fval_shift	='b0		;

	//  ===============================================================================================
	//  第二部分：逻辑
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  输入信号
	//  -------------------------------------------------------------------------------------

	always @ ( posedge clk )
	begin
		if (clk_en) begin
			ctrl_dly_0	<=	iv_ctrl;
			data_dly_0	<=	iv_data;
		end
	end

	assign	o_clk_en	= clk_en;

	//  -------------------------------------------------------------------------------------
	//  解析FS、FE
	//  -------------------------------------------------------------------------------------

	always @ ( posedge clk )
	begin
		if(reset)
		begin
			fval_reg_0	<=	1'b0;
		end
		else
		if (clk_en) begin
			if((ctrl_dly_0 == LS) || (ctrl_dly_0 == FS) || (ctrl_dly_0 == FSS))
			begin
				fval_reg_0	<=	1'b1;
			end
			else if((ctrl_dly_0 == FE) || (ctrl_dly_0 == FSE))
			begin
				fval_reg_0	<=	1'b0;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//  解析LS、LE
	//  -------------------------------------------------------------------------------------
	/*
	always @ ( posedge clk )
	begin
	if(reset)
	begin
	dval_reg_0	<=	1'b0;
	end
	else if((ctrl_dly_0 == LS) || (ctrl_dly_0 == FS) || (ctrl_dly_0 == FSS))
	begin
	dval_reg_0	<=	1'b1;
	end
	else if((ctrl_dly_0 == LE) || (ctrl_dly_0 == FE) || (ctrl_dly_0 == FSE))
	begin
	dval_reg_0	<=	1'b0;
	end
	end
	*/

	always @ ( posedge clk )
	begin
		if(reset)
		begin
			dval_reg_0	<=	1'b0;
		end
		else if (clk_en) begin
			if(ctrl_dly_0 == IMG)
			begin
				dval_reg_0	<=	1'b1;
			end
			else begin
				dval_reg_0	<=	1'b0;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//  同步场
	//  -------------------------------------------------------------------------------------

	always @ ( posedge clk )
	begin
		if (clk_en) begin
			fval_reg_1	<=	fval_reg_0;
			fval_reg_2	<=	fval_reg_1;
			fval_reg_3	<=	fval_reg_2;
			fval_reg_4	<=	fval_reg_3;
		end
	end

	always @ ( posedge clk )
	begin
		if (clk_en) begin
			fval	<= 	fval_reg_0 | fval_reg_1 | fval_reg_2 | fval_reg_3 | fval_reg_4;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  同步场
	//  -------------------------------------------------------------------------------------

	always @ ( posedge clk )
	begin
		if (clk_en) begin
			dval_reg_1	<=	dval_reg_0;
			dval_reg_2	<=	dval_reg_1;
			dval_reg_3	<=	dval_reg_2;
			dval_reg_4	<=	dval_reg_3;
		end
	end

	always @ ( posedge clk )
	begin
		if (clk_en) begin
			dval	<= 	dval_reg_0 | dval_reg_1 | dval_reg_2 | dval_reg_3 | dval_reg_4;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  同步行场 数据
	//  -------------------------------------------------------------------------------------

	always @ ( posedge clk )
	begin
		if (clk_en) begin
			data_dly_1	<=	data_dly_0;
			data_dly_2	<= 	data_dly_1;
			data_dly_3	<= 	data_dly_2;
			data_dly_4	<= 	data_dly_3;
			data_dly_5	<= 	data_dly_4;
			data_dly_6	<= 	data_dly_5;
		end
	end

	always @ ( posedge clk )
	begin
		if (clk_en) begin
			fval_shift	<=	{fval_shift[6:0],fval};
		end
	end

	always @ ( posedge clk )
	begin
		if (clk_en) begin
			dval_shift	<=	{dval_shift[0],dval};
		end
	end

	//  -------------------------------------------------------------------------------------
	//  输出
	//  -------------------------------------------------------------------------------------

	always @ ( posedge clk )
	begin
		if(reset)
		begin
			o_dval		<=	1'b0;
			o_fval		<=	1'b0;
			ov_data		<=	'b0;
		end
		else
		if (clk_en) begin
			o_dval		<=	dval_shift[1];
			o_fval		<=	fval_shift[0] | fval_shift[1] | fval_shift[2] | fval_shift[3] | fval_shift[4] | fval_shift[5] | fval_shift[6] | fval_shift[7];
			ov_data		<=	data_dly_6;
		end
	end


endmodule
