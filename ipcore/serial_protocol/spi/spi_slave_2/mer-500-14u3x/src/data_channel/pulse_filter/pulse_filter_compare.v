//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : pulse_filter_compare
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/2/11 15:56:14	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 完成9个数据比较的功能
//              1)  : 前级模块输出了3行数据，中间行是要滤波的行，上下行是参考行
//
//              2)  : 帧头帧尾2行、行头行尾2像素不参与滤波，但是会作为其他像素滤波的依据
//
//              3)  :
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module pulse_filter_compare # (
	parameter					SENSOR_DAT_WIDTH	= 10		//sensor 数据宽度
	)
	(
	input								clk					,	//像素时钟
	input								i_pulse_filter_en	,	//坏点校正开关,0:不使能坏点校正,1:使能坏点校正
	input								i_fval				,	//场信号，原始的fval信号
	input								i_fval_delay		,	//场信号，rd模块输出，比i_fval延时2行时间
	input								i_lval_delay		,	//行信号，rd模块输出，与原始lval相比，向后平移了2行
	input	[SENSOR_DAT_WIDTH-1:0]		iv_upper_line		,	//需要比较的三行中的上面一行
	input	[SENSOR_DAT_WIDTH-1:0]		iv_mid_line			,	//需要比较的三行中的中间一行，也是要输出的行
	input	[SENSOR_DAT_WIDTH-1:0]		iv_lower_line		,	//需要比较的三行中的下面一行
	output								o_fval				,	//输出的场信号
	output								o_lval				,	//输出的行信号
	output	[SENSOR_DAT_WIDTH-1:0]		ov_pix_data				//输出的像素数据
	);

	//	ref signals
	reg									lval_delay_dly0		= 1'b0;
	reg									lval_delay_dly1		= 1'b0;
	reg									lval_delay_dly2		= 1'b0;
	reg									lval_delay_dly3		= 1'b0;
	reg									lval_delay_dly4		= 1'b0;
	reg									lval_delay_dly5		= 1'b0;
	reg									lval_delay_dly6		= 1'b0;
	wire								lval_delay_fall		;
	reg		[1:0]						lval_delay_cnt		= 2'b0;
	reg									compare_line		= 1'b0;
	reg									compare_line_dly0	= 1'b0;
	reg									compare_line_dly1	= 1'b0;
	reg									compare_line_dly2	= 1'b0;
	reg									compare_line_dly3	= 1'b0;
	wire								compare_pix			;
	reg									fval_reg			= 1'b0;
	reg									enable				= 1'b0;

	reg		[SENSOR_DAT_WIDTH-1:0]		upper_line_dly0		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		upper_line_dly1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		upper_line_dly2		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		upper_line_dly3		= {SENSOR_DAT_WIDTH{1'b0}};

	reg		[SENSOR_DAT_WIDTH-1:0]		mid_line_dly0		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		mid_line_dly1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		mid_line_dly2		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		mid_line_dly3		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		mid_line_dly4		= {SENSOR_DAT_WIDTH{1'b0}};

	reg		[SENSOR_DAT_WIDTH-1:0]		lower_line_dly0		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		lower_line_dly1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		lower_line_dly2		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		lower_line_dly3		= {SENSOR_DAT_WIDTH{1'b0}};

	wire	[SENSOR_DAT_WIDTH-1:0]		data_upper_left		;
	wire	[SENSOR_DAT_WIDTH-1:0]		data_upper_mid		;
	wire	[SENSOR_DAT_WIDTH-1:0]		data_upper_right	;
	wire	[SENSOR_DAT_WIDTH-1:0]		data_mid_left		;
	wire	[SENSOR_DAT_WIDTH-1:0]		data_mid_mid		;
	wire	[SENSOR_DAT_WIDTH-1:0]		data_mid_right		;
	wire	[SENSOR_DAT_WIDTH-1:0]		data_lower_left		;
	wire	[SENSOR_DAT_WIDTH-1:0]		data_lower_mid		;
	wire	[SENSOR_DAT_WIDTH-1:0]		data_lower_right	;

	reg		[SENSOR_DAT_WIDTH-1:0]		max_1cycle_1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		max_1cycle_2		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		max_1cycle_3		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		max_1cycle_4		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		max_2cycle_1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		max_2cycle_2		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		max_3cycle_1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		min_1cycle_1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		min_1cycle_2		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		min_1cycle_3		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		min_1cycle_4		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		min_2cycle_1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		min_2cycle_2		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		min_3cycle_1		= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		data_out_reg		= {SENSOR_DAT_WIDTH{1'b0}};


	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref ***取边沿***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	判断输入lval的边沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_delay_dly0	<= i_lval_delay;
	end
	assign	lval_delay_fall		= (lval_delay_dly0==1'b1 && i_lval_delay==1'b0) ? 1'b1 : 1'b0;

	//  ===============================================================================================
	//	ref ***生效时机***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	enable 使能信号，保证完整帧
	//	1.fval_reg=o_fval
	//	2.当o_fval=0时，enable=i_pulse_filter_en
	//	2.当o_fval=1时，enable保持不变
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!fval_reg) begin
			enable	<= i_pulse_filter_en;
		end
	end

	//  ===============================================================================================
	//	ref ***选择比较区域***
	//	1.compare_pix		- 是每一行需要滤波的点，行头和行尾的2个像素不参与滤波
	//	2.compare_line		- 是每一帧需要滤波的行，帧头和帧尾的2行不参与滤波
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//                                _________________________________________________
	//	lval_delay_dly2      _________|                                               |______________
	//                                    _________________________________________________
	//	lval_delay_dly4      _____________|                                               |__________
	//                                        _________________________________________________
	//	lval_delay_dly6      _________________|                                               |______
	//                                        _________________________________________
	//	compare_pix          _________________|                                       |______________
	//
	//  -------------------------------------------------------------------------------------
	//	compare_pix
	//	1.每一行需要比较的像素，开头和结尾的2个像素不做滤波处理
	//	2.以 lval_delay_dly4 为基础，将lval_delay_dly4 的前两个 后两个像素都去掉了
	//  -------------------------------------------------------------------------------------
	assign	compare_pix	= lval_delay_dly2&lval_delay_dly4&lval_delay_dly6;

	//  -------------------------------------------------------------------------------------
	//	lval边沿计数器
	//	1.当展宽后的fval=0时，计数器清零
	//	2.当展宽后的fval=1时，lval下降沿时，计数器自增
	//	3.lval_delay_cnt 位宽2bit，用于判断开始的2行，2bit足够
	//	4.lval_delay_cnt 在等于2'b10之后可以保持，这样就会节省功耗。也可以继续增加，这样可以节省资源，省掉了判断逻辑。
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_fval_delay) begin
			lval_delay_cnt	<= 2'b00;
		end
		else begin
			if(lval_delay_fall==1'b1) begin
				lval_delay_cnt	<= lval_delay_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//                  _________________________________________________
	//	i_fval         _|                                               |______________________
	//                           _________________________________________________________
	//	i_fval_delay   __________|                                                       |_____
	//                              ____    ____    ____    ____           ____    ____
	//	i_lval_delay   _____________|  |____|  |____|  |____|  |____...____|  |____|  |________
	//                                          _________________________
	//	compare_line   _________________________|                       |______________________
	//
	//                  |-2 line-|----2 line----|                       |-----2 line-----|
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	compare_line
	//	1.开头两行不比较
	//	2.末尾两行不比较
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!(i_fval&i_fval_delay)) begin
			compare_line	<= 1'b0;
		end
		else begin
			if(lval_delay_cnt==2'b10) begin
				compare_line	<= 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	compare_line 延迟信号，因为o_lval会有延迟，所以比较周期信号也要延迟
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		compare_line_dly0	<= compare_line;
		compare_line_dly1	<= compare_line_dly0;
		compare_line_dly2	<= compare_line_dly1;
		compare_line_dly3	<= compare_line_dly2;
	end

	//  ===============================================================================================
	//	ref ***数据延时、打标签***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	输入数据打拍
	//	1.打拍的目的是保存之前的输入数据，为以后的数据比较提供依据
	//	2.mid line 是要输出的数据
	//	3.upper line、lower line 提供比较依据
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		upper_line_dly0	<= iv_upper_line;
		upper_line_dly1	<= upper_line_dly0;
		upper_line_dly2	<= upper_line_dly1;
		upper_line_dly3	<= upper_line_dly2;
	end

	always @ (posedge clk) begin
		mid_line_dly0	<= iv_mid_line;
		mid_line_dly1	<= mid_line_dly0;
		mid_line_dly2	<= mid_line_dly1;
		mid_line_dly3	<= mid_line_dly2;
		mid_line_dly4	<= mid_line_dly3;
	end

	always @ (posedge clk) begin
		lower_line_dly0	<= iv_lower_line;
		lower_line_dly1	<= lower_line_dly0;
		lower_line_dly2	<= lower_line_dly1;
		lower_line_dly3	<= lower_line_dly2;
	end

	//  -------------------------------------------------------------------------------------
	//	为数据打上标签
	//
	//	upper line  :      P22  P24  P26
	//	mid line    :      P42  P44  P46
	//	lower line  :      P62  P64  P66
	//
	//	1.可以想象为9个坐标点，左边的点在时间上比右边的点要早
	//	2.上边边的点在时间上比下边的点要早
	//	3.P44是滤波点，周围的8个点是滤波的依据
	//	4.可以看到 P44 其实是 mid_line_dly1 ，这个点是要输出的
	//
	//  -------------------------------------------------------------------------------------
	assign	data_upper_left	= upper_line_dly3;
	assign	data_upper_mid	= upper_line_dly1;
	assign	data_upper_right= iv_upper_line;

	assign	data_mid_left	= mid_line_dly3;
	assign	data_mid_mid	= mid_line_dly1;
	assign	data_mid_right	= iv_mid_line;

	assign	data_lower_left	= lower_line_dly3;
	assign	data_lower_mid	= lower_line_dly1;
	assign	data_lower_right= iv_lower_line;

	//  ===============================================================================================
	//	ref ***数据比较***
	//	1.采用两两比较的方法，需要找出8个像素点的最大值和最小值
	//	2.经过3轮比较，才能得出最大值和最小值
	//	3.在比较之前，滤波点是 mid_line_dly1 ，经过3轮比较之后， mid_line_dly4 与最大值和最小值是对齐的
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref 第一轮比较
	//	1.共比较4次，8个像素两两比较，找出4个较大值和4个较小值
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(data_upper_left<=data_upper_mid) begin
			max_1cycle_1	<= data_upper_mid;
			min_1cycle_1	<= data_upper_left;
		end
		else begin
			max_1cycle_1	<= data_upper_left;
			min_1cycle_1	<= data_upper_mid;
		end
	end

	always @ (posedge clk) begin
		if(data_lower_left<=data_lower_mid) begin
			max_1cycle_2	<= data_lower_mid;
			min_1cycle_2	<= data_lower_left;
		end
		else begin
			max_1cycle_2	<= data_lower_left;
			min_1cycle_2	<= data_lower_mid;
		end
	end

	always @ (posedge clk) begin
		if(data_mid_left<=data_mid_right) begin
			max_1cycle_3	<= data_mid_right;
			min_1cycle_3	<= data_mid_left;
		end
		else begin
			max_1cycle_3	<= data_mid_left;
			min_1cycle_3	<= data_mid_right;
		end
	end

	always @ (posedge clk) begin
		if(data_upper_right<=data_lower_right) begin
			max_1cycle_4	<= data_lower_right;
			min_1cycle_4	<= data_upper_right;
		end
		else begin
			max_1cycle_4	<= data_upper_right;
			min_1cycle_4	<= data_lower_right;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	-- ref 第二轮比较
	//	1.共比较2次，从4个较大值和较小值中，找出2个较大值和2个较小值
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(max_1cycle_1<=max_1cycle_2) begin
			max_2cycle_1	<= max_1cycle_2;
		end
		else begin
			max_2cycle_1	<= max_1cycle_1;
		end
	end

	always @ (posedge clk) begin
		if(min_1cycle_1<=min_1cycle_2) begin
			min_2cycle_1	<= min_1cycle_1;
		end
		else begin
			min_2cycle_1	<= min_1cycle_2;
		end
	end

	always @ (posedge clk) begin
		if(max_1cycle_3<=max_1cycle_4) begin
			max_2cycle_2	<= max_1cycle_4;
		end
		else begin
			max_2cycle_2	<= max_1cycle_3;
		end
	end

	always @ (posedge clk) begin
		if(min_1cycle_3<=min_1cycle_4) begin
			min_2cycle_2	<= min_1cycle_3;
		end
		else begin
			min_2cycle_2	<= min_1cycle_4;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	-- ref 第三轮比较
	//	1.共比较1次，在2个较大值和较小值中，找出1个最大值和1个最小值
	//	2.至此，8个数据中的最大值和最小值已经找出来
	//	3.共延时3拍
	//	4.开始比较时，中间的滤波点是 mid_line_dly1 ，再延时3拍之后，与最大值和最小值对齐
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(max_2cycle_1<=max_2cycle_2) begin
			max_3cycle_1	<= max_2cycle_2;
		end
		else begin
			max_3cycle_1	<= max_2cycle_1;
		end
	end

	always @ (posedge clk) begin
		if(min_2cycle_1<=min_2cycle_2) begin
			min_3cycle_1	<= min_2cycle_1;
		end
		else begin
			min_3cycle_1	<= min_2cycle_2;
		end
	end

	//  ===============================================================================================
	//	ref ***数据输出***
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//
	//	clk                   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^   ^
	//                        _________________________________________________
	//	i_lval_delay         _|                                               |______________________
	//                            _________________________________________________
	//	lval_delay_dly0      _____|                                               |__________________
	//                                _________________________________________________
	//	lval_delay_dly1      _________|                                               |______________
	//                                    _________________________________________________
	//	lval_delay_dly2      _____________|                                               |__________
	//                                        _________________________________________________
	//	lval_delay_dly3      _________________|                                               |______
	//                                            _________________________________________________
	//	lval_delay_dly4      _____________________|                                               |__
	//
	//	mid line dly4        ---------------------|D0 |D1 |D2 |D3      -------------     |Dn-1|Dn |--
	//
	//	-------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	数据输出
	//	1.当行无效时，输出屏蔽为全零 。mid_line_dly4 是 要滤波的数据，因此行有效也应该对应的延时信号。
	//	2.当行有效且比较使能打开时，在可以比较的阶段，进行比较。
	//	2.1--compare_line 是根据lval下降沿得出的，延时3个周期即可。
	//	2'2.--如果原始数据大于周边的最大值，则用周边的最大值替换原始数据
	//	2'3.--如果原始数据小于周边的最小值，则用周边的最小值替换原始数据
	//	3.当行有效时，在不可以比较的阶段，直接输出数据
	//	4.当行有效时，在比较使能没有打开时，直接输出数据
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(lval_delay_dly4) begin
			if(enable&compare_line_dly3&compare_pix) begin
				if(mid_line_dly4>max_3cycle_1) begin
					data_out_reg	<= max_3cycle_1;
				end
				else if(mid_line_dly4<min_3cycle_1) begin
					data_out_reg	<= min_3cycle_1;
				end
				else begin
					data_out_reg	<= mid_line_dly4;
				end
			end
			else begin
				data_out_reg	<= mid_line_dly4;
			end
		end
		else begin
			data_out_reg	<= 'b0;
		end
	end
	assign	ov_pix_data	= data_out_reg;

	//  -------------------------------------------------------------------------------------
	//	行有效输出
	//	1.在 lval_delay_dly4 的时候对输出数据打一拍 ，因此lval_delay_dly5与输出数据是对齐的
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_delay_dly1	<= lval_delay_dly0;
		lval_delay_dly2	<= lval_delay_dly1;
		lval_delay_dly3	<= lval_delay_dly2;
		lval_delay_dly4	<= lval_delay_dly3;
		lval_delay_dly5	<= lval_delay_dly4;
		lval_delay_dly6	<= lval_delay_dly5;
	end
	assign	o_lval	= lval_delay_dly5;

	//  -------------------------------------------------------------------------------------
	//	场有效输出
	//	1.i_fval_delay比i_fval滞后2行的时间，用两个信号相或的结果，这样o_fval就会提前o_lval 2行出现
	//	2.不能直接将i_fval_delay作为o_fval，因为有可能输入的行消隐太短，造成o_fval和o_lval之间的空隙太小
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_reg	<= i_fval|i_fval_delay;
	end
	assign	o_fval	= fval_reg;

endmodule