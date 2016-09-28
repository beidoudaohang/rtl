//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : pulse_filter_rd
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/2/11 15:44:38	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 该模块主要功能是从buffer模块读取数据，共包括4个主要的部分
//              1)  : 控制逻辑部分，包括对行场信号边沿的提取工作，和控制计数器
//
//              2)  : RAM操作部分，包括了RAM的复位、读使能、地址
//
//              3)  : 输出选择部分，选择 upper line和mid line，其中mid line是将要被滤波的行。lower line是wr模块提供的。
//
//				4)  : 帧尾重新生成2行，当i_fval结束时，还要再生成2个lval
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module pulse_filter_rd # (
	parameter					COMPARE_LVAL_DELAY	= 5		,	//后级 compare 模块对lval的延时
	parameter					LINE_HIDE_PIX_NUM	= 30	,	//重新生成的2行，行消隐数值
	parameter					LINE2FRAME_PIX_NUM	= 10	,	//重新生成的2行，最后一行的下降沿与o_fval的下降沿的距离
	parameter					SENSOR_DAT_WIDTH	= 10	,	//sensor 数据宽度
	parameter					SHORT_REG_WD		= 16		//短寄存器位宽
	)
	(
	input								clk					,	//像素时钟
	input	[SHORT_REG_WD-1:0]			iv_roi_pic_width	,	//行宽度
	input								i_fval				,	//场信号
	input								i_lval				,	//行信号
	output								o_reset_buffer		,	//ram 复位
	output	[3:0]						ov_buffer_rd_en		,	//ram 读使能
	output	[11:0]						ov_buffer_rd_addr	,	//ram 读地址
	input	[9:0]						iv_buffer_rd_dout0	,	//ram0 数据输出
	input	[9:0]						iv_buffer_rd_dout1	,	//ram1 数据输出
	input	[9:0]						iv_buffer_rd_dout2	,	//ram2 数据输出
	input	[9:0]						iv_buffer_rd_dout3	,	//ram3 数据输出
	output								o_fval				,	//输出场有效
	output								o_lval				,	//输出行有效
	output	[SENSOR_DAT_WIDTH-1:0]		ov_upper_line		,	//输出比较行-上面的一行
	output	[SENSOR_DAT_WIDTH-1:0]		ov_mid_line				//输出比较行-中间的一行
	);

	//	ref signals

	//	-------------------------------------------------------------------------------------
	//	本地参数
	//	1.本模块的延时周期数=规定的的延时周期数+后面的模块对o_lval造成的延时周期数
	//	-------------------------------------------------------------------------------------
	localparam		LINE2FRAME_PIX_NUM_RD	= (LINE2FRAME_PIX_NUM+COMPARE_LVAL_DELAY);


	reg									lval_dly0			= 1'b0;
	reg									lval_dly1			= 1'b0;
	reg									lval_dly2			= 1'b0;
	wire								lval_fall			;
	reg									lval_trailer_dly0	= 1'b0;
	reg									lval_trailer_dly1	= 1'b0;
	wire								lval_trailer_fall	;
	reg									fval_dly0			= 1'b0;
	wire								fval_fall			;
	wire								fval_extend			;
	reg									lval_reg			= 1'b0;

	reg		[1:0]						lval_cnt			= 2'b0;
	reg		[1:0]						lval_cnt_dly0		= 2'b0;
	reg		[1:0]						lval_cnt_dly1		= 2'b0;
	reg									fval_reg			= 1'b0;
	reg		[1:0]						buffer_rd_en		= 2'b0;
	reg		[11:0]						buffer_rd_addr		= 12'b0;
	reg		[9:0]						upper_line_reg		= 10'b0;
	reg		[9:0]						mid_line_reg		= 10'b0;

	reg									gen_2line			= 1'b0;
	reg		[4:0]						gen_2line_hide_cnt	= 5'b0;
	reg		[11:0]						gen_2line_valid_cnt	= 12'b0;
	reg									lval_trailer		= 1'b0;
	reg		[1:0]						lval_trailer_cnt	= 2'b0;


	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***取边沿***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	判断输入lval的边沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_dly0	<= i_lval;
		lval_dly1	<= lval_dly0;
	end
	assign	lval_fall	= (lval_dly0==1'b1 && i_lval==1'b0) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	判断输入fval的边沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_dly0	<= i_fval;
	end
	assign	fval_fall	= (fval_dly0==1'b1 && i_fval==1'b0) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	判断lval_trailer的边沿
	//	1.lval_trailer是在帧尾重新生成的行信号
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_trailer_dly0	<= lval_trailer;
		lval_trailer_dly1	<= lval_trailer_dly0;
	end
	assign	lval_trailer_fall	= (lval_trailer_dly0==1'b1 && lval_trailer==1'b0) ? 1'b1 : 1'b0;

	//  ===============================================================================================
	//	ref ***帧尾重新生成2行***
	//	1.rd 模块会将lval信号向后平移2行，当 i_fval=0时，i_lval也为0，只能在模块内部重新生成2行 lval
	//	2.寄存器设置行有效，行消隐固定为传入参数，fval与lval下降沿之间的距离由参数决定
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	gen_2line 生成帧尾2行的标志
	//	1.当i_fval下降沿时，标志置位
	//	2.当已经产生了2个lval，且lval与fval之间的距离满足参数时，标志清零
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_fall) begin
			gen_2line	<= 1'b1;
		end
		else begin
			if(lval_trailer_cnt==2'b10 && gen_2line_hide_cnt==(LINE2FRAME_PIX_NUM_RD+1)) begin
				gen_2line	<= 1'b0;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	产生的帧尾2行的消隐计数器
	//	1.当产生标志=0时，计数器清零
	//	2.当产生标志=1且产生的lval=0时，计数器自增
	//	2.当产生标志=1且产生的lval=1时，计数器归零
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!gen_2line) begin
			gen_2line_hide_cnt	<= 5'b0;
		end
		else begin
			if(!lval_trailer) begin
				gen_2line_hide_cnt	<= gen_2line_hide_cnt + 1'b1;
			end
			else begin
				gen_2line_hide_cnt	<= 5'b0;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	产生的帧尾2行的行有效计数器
	//	1.当产生标志=0时，计数器清零
	//	2.当产生标志=1且产生的lval=0时，计数器自增
	//	3.此处无需判断 gen_2line 的状态，因为在 gen_2line=0时， lval_trailer 也等于0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!lval_trailer) begin
			gen_2line_valid_cnt	<= 5'b0;
		end
		else begin
			gen_2line_valid_cnt	<= gen_2line_valid_cnt + 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	新生成的lval
	//	1.当消隐计数器计数到参数设置值时，lval变为1
	//	2.当已经产生了2个lval，那么lval_trailer一定要输出0
	//	3.当还没有产生2个lval时：
	//	--3.1当有效计数器计数到行宽度-1时，lval变为0
	//	--3.2减法放在了if表达式之中，增加了组合逻辑路径，节省了reg，fmax还是在180以上
	//	4.如果不判断 lval cnt，单纯靠 hide cnt 和 valid cnt 时，会有如下问题：
	//	--当LINE2FRAME_PIX_NUM_RD大于LINE_HIDE_PIX_NUM时，就会多产生出1个lval，当然目前的参数配置来看不会有这个问题
	//	--但是为了模块的通用性考虑，还是应该加上 lval_cnt 的条件判断
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!gen_2line) begin
			lval_trailer	<= 1'b0;
		end
		else begin
			if(lval_trailer_cnt==2'b10) begin
				lval_trailer	<= 1'b0;
			end
			else begin
				if(gen_2line_hide_cnt==(LINE_HIDE_PIX_NUM-1)) begin
					lval_trailer	<= 1'b1;
				end
				else if(gen_2line_valid_cnt==(iv_roi_pic_width[11:0]-1)) begin
					lval_trailer	<= 1'b0;
				end
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	lval_trailer_cnt
	//	1.在 lval_trailer 的下降沿计数
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!gen_2line) begin
			lval_trailer_cnt	<= 2'b0;
		end
		else begin
			if(lval_trailer_fall) begin
				lval_trailer_cnt	<= lval_trailer_cnt + 1'b1;
			end
		end
	end

	//  ===============================================================================================
	//	ref ***处理行场信号***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//                  ______________________________________________________________
	//	i_fval         _|                                                            |_____________________________
	//                                                                               __________________
	//  gen_2line      ______________________________________________________________|                |____________
	//                  _______________________________________________________________________________
	//	fval_extend    _|                                                                             |____________
	//                      ____    ____      ____    ____            ____    ____
	//	i_lval         _____|  |____|  |______|  |____|  |____....____|  |____|  |_________________________________
	//                                                                                  ____    ____
	//	lval_gen       _________________________________________________________________|  |____|  |_______________
	//
	//                                    _____________________________________________________________
	//	o_fval         ___________________|                                                           |____________
	//
	//                                        ____    ____            ____    ____      ____    ____
	//	o_lval         _______________________|  |____|  |____....____|  |____|  |______|  |____|  |_______________
	//
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	fval_extend - 展宽之后的fval
	//	1.gen_2line是在i_fval下降沿产生的
	//	2.fval_dly0 与 gen_2line 的高电平之间衔接紧密，没有低电平
	//	3.fval_extend 与 i_fval 相比，向后延时1拍，帧尾多出了2行的时间
	//  -------------------------------------------------------------------------------------
	assign	fval_extend		= fval_dly0 | gen_2line;

	//  -------------------------------------------------------------------------------------
	//	lval边沿计数器
	//	1.当展宽后的 fval =0 时，lval_cnt 清零
	//	2.当展宽后的 fval =1 时，在 i_lval 的下降沿 或者 重新生成的 lval_trailer 的下降沿时，计数器自增
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!fval_extend) begin
			lval_cnt	<= 2'b00;
		end
		else begin
			if(lval_fall==1'b1 || lval_trailer_fall==1'b1) begin
				lval_cnt	<= lval_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	fval_reg - 输出的场信号
	//	1.当i_fval=0且gen_2line=0时，才能将fval_reg清零
	//	2.帧有效两行之后，fval_reg=1
	//	3.o_fval 与 i_fval 相比，向后平移了2行
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!fval_extend) begin
			fval_reg	<= 1'b0;
		end
		else if(lval_cnt==2'b10) begin
			fval_reg	<= 1'b1;
		end
	end
	assign	o_fval	= fval_reg;

	//  -------------------------------------------------------------------------------------
	//	重新生成lval
	//	1.当o_fval=0时，o_lval=0
	//	2.新生成的lval包括 (1)屏蔽了前两行的原始i_lval (2)帧尾重新生成的两行
	//	3.ram 读信号是i_lval和lval_trailer打拍之后的信号，ram延时1个时钟周期，ram输出的数据与dly1是对齐的
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!fval_reg) begin
			lval_reg	<= 1'b0;
		end
		else begin
			lval_reg	<= lval_dly1|lval_trailer_dly1;
		end
	end
	assign	o_lval	= lval_reg;

	//  -------------------------------------------------------------------------------------
	//	延迟 lval cnt
	//	1.ram输出有1个时钟延时
	//	2.ram读信号根据 lval_cnt切换
	//	3.当lval改变时，ram读信号不能立即切换，要延迟2个时钟
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_cnt_dly0	<= lval_cnt;
		lval_cnt_dly1	<= lval_cnt_dly0;
	end

	//  ===============================================================================================
	//	ref ***RAM的操作***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref RAM 复位
	//	1.当处于帧消隐时，复位RAM， fval_extend 比原始的i_fval多2行时间，因为前2行也要写入到ram中，不能复位
	//	2.从帧有效到第一个行有效，有大约10个时钟的时间，需要保证FIFO能够从复位状态恢复工作
	//  -------------------------------------------------------------------------------------
	assign	o_reset_buffer	= !fval_extend;

	//  -------------------------------------------------------------------------------------
	//	-- ref RAM 读
	//	1.当帧消隐时，读信号全为零 ，此处需要用 o_fval作为使能，因为前两行是不读的
	//	2.当帧有效时，根据lval cnt选取两行
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!fval_reg) begin
			buffer_rd_en	<= 2'b00;
		end
		else begin
			case(lval_cnt[0])
				1'b0	: buffer_rd_en	<= {1'b0,i_lval|lval_trailer};
				1'b1	: buffer_rd_en	<= {i_lval|lval_trailer,1'b0};
				default	: buffer_rd_en	<= 2'b00;
			endcase
		end
	end
	assign	ov_buffer_rd_en[0]	= buffer_rd_en[0];
	assign	ov_buffer_rd_en[2]	= buffer_rd_en[0];
	assign	ov_buffer_rd_en[1]	= buffer_rd_en[1];
	assign	ov_buffer_rd_en[3]	= buffer_rd_en[1];

	//  -------------------------------------------------------------------------------------
	//	-- ref RAM 读地址
	//	1.当帧有效时，读使能在i_lval时产生，读地址要之后一个时钟再变化
	//	2.在重新生成的2行下，也要读ram
	//	3.当帧消隐时，ram读地址清零
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_reg) begin
			if(lval_dly0==1'b1 || lval_trailer_dly0==1'b1) begin
				buffer_rd_addr	<= buffer_rd_addr + 1'b1;
			end
			else if(lval_dly0==1'b0 || lval_trailer_dly0==1'b0) begin
				buffer_rd_addr	<= 12'h0;
			end
		end
		else begin
			buffer_rd_addr	<= 12'h0;
		end
	end
	assign	ov_buffer_rd_addr	= buffer_rd_addr;

	//  ===============================================================================================
	//	ref ***输出选择***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	选择输出的上一行数据
	//	1.帧有效时，根据lval_cnt的状态，选择ram
	//	2.帧消隐时，输出数据清零
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_reg) begin
			case(lval_cnt_dly1)
				2'b10	: upper_line_reg	<= iv_buffer_rd_dout2;
				2'b11	: upper_line_reg	<= iv_buffer_rd_dout3;
				2'b00	: upper_line_reg	<= iv_buffer_rd_dout0;
				2'b01	: upper_line_reg	<= iv_buffer_rd_dout1;
				default	: upper_line_reg	<= 10'b0;
			endcase
		end
		else begin
			upper_line_reg	<= 10'b0;
		end
	end
	assign	ov_upper_line	= upper_line_reg[SENSOR_DAT_WIDTH-1:0];

	//  -------------------------------------------------------------------------------------
	//	输出选择的中间行数据
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_reg) begin
			case(lval_cnt_dly1)
				2'b10	: mid_line_reg	<= iv_buffer_rd_dout0;
				2'b11	: mid_line_reg	<= iv_buffer_rd_dout1;
				2'b00	: mid_line_reg	<= iv_buffer_rd_dout2;
				2'b01	: mid_line_reg	<= iv_buffer_rd_dout3;
				default	: mid_line_reg	<= 10'b0;
			endcase
		end
		else begin
			mid_line_reg	<= 10'b0;
		end
	end
	assign	ov_mid_line	= mid_line_reg[SENSOR_DAT_WIDTH-1:0];


endmodule
