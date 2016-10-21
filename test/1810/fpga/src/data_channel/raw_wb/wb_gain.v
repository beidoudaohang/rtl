//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : wb_gain
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/2/13 10:31:49	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 颜色分量增益模块
//              1)  : 总体延时3个时钟
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wb_gain # (
	parameter					SENSOR_DAT_WIDTH	= 10		,	//sensor 数据宽度
	parameter					CHANNEL_NUM			= 4			,	//通道数
	parameter					WB_GAIN_WIDTH		= 11		,	//白平衡模块增益寄存器宽度
	parameter					WB_RATIO			= 8			,	//白平衡调节因子，乘法增益需要右移多少位
	parameter					REG_WD				= 32			//寄存器位宽
	)
	(
	input											clk					,	//时钟输入
	input											i_fval				,	//场信号
	input											i_lval				,	//行信号
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data			,	//图像数据
	input	[CHANNEL_NUM-1:0]						iv_r_flag			,	//颜色分量标志 R
	input	[CHANNEL_NUM-1:0]						iv_g_flag			,	//颜色分量标志 G
	input	[CHANNEL_NUM-1:0]						iv_b_flag			,	//颜色分量标志 B
	input											i_mono_sel			,	//1:选中黑白模式，模块不工作。0：选中彩色模式，模块工作。
	input	[2:0]									iv_test_image_sel	,	//测试图选择寄存器,000:真实图,001:测试图像1灰度值帧递增,110:测试图像2静止的斜条纹,010:测试图像3滚动的斜条纹
	input	[WB_GAIN_WIDTH-1:0]						iv_wb_gain_r		,	//白平衡R分量，R分量小数乘以256后的结果，取值范围[0:2047]
	input	[WB_GAIN_WIDTH-1:0]						iv_wb_gain_g		,	//白平衡G分量，G分量小数乘以256后的结果，取值范围[0:2047]
	input	[WB_GAIN_WIDTH-1:0]						iv_wb_gain_b		,	//白平衡B分量，B分量小数乘以256后的结果，取值范围[0:2047]
	output											o_fval				,	//场有效，o_fval与o_lval的相位要保证与输入的相位一致
	output											o_lval				,	//行有效
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data				//图像数据
	);

	//	ref signals
	localparam				GAIN_COE_ONE	= {1'b1,{WB_RATIO{1'b0}}};

	wire													gain_enable		;
	reg		[WB_GAIN_WIDTH-1:0]								gain_coe		[CHANNEL_NUM-1:0];
	wire	[SENSOR_DAT_WIDTH-1:0]							wv_data_lane		[CHANNEL_NUM-1:0];
	reg		[SENSOR_DAT_WIDTH-1:0]							pix_data_reg	[CHANNEL_NUM-1:0];
	wire	[16:0]											wb_mult_a		[CHANNEL_NUM-1:0];
	wire	[16:0]											wb_mult_b		[CHANNEL_NUM-1:0];
	wire	[33:0]											wb_mult_p		[CHANNEL_NUM-1:0];
	wire													wb_mult_ce		;
	//	wire	[(WB_GAIN_WIDTH+SENSOR_DAT_WIDTH-1):0]			gain_all_data	;	//DSP结果中所有有效的数据位
	wire	[(WB_GAIN_WIDTH+SENSOR_DAT_WIDTH-WB_RATIO-1):0]	gain_reduce		[CHANNEL_NUM-1:0];	//DSP结果中所有有效的数据位移位之后的结果
	wire	[(WB_GAIN_WIDTH-WB_RATIO-1):0]					gain_overflow	[CHANNEL_NUM-1:0];	//DSP结果中所有有效的数据位的溢出位
	reg														fval_dly0		= 1'b0;
	reg														fval_dly1		= 1'b0;
	reg														fval_reg		= 1'b0;
	reg														lval_dly0		= 1'b0;
	reg														lval_dly1		= 1'b0;
	reg														lval_reg		= 1'b0;
	reg		[WB_GAIN_WIDTH-1:0]								wb_gain_r_m		= 0	;	//经过生效时机控制的白平衡参数红分量
	reg		[WB_GAIN_WIDTH-1:0]								wb_gain_g_m		= 0	;   //经过生效时机控制的白平衡参数绿分量
	reg		[WB_GAIN_WIDTH-1:0]								wb_gain_b_m		= 0	;   //经过生效时机控制的白平衡参数蓝分量

	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref ***生效时机***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	乘法增益使能控制
	//	1.当像素格式是彩色，且没有选中测试图时，才会做乘法增益
	//	2.否则，直接输出数据
	//  -------------------------------------------------------------------------------------
	assign	gain_enable	= (i_mono_sel==1'b0 && iv_test_image_sel==3'b000) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	增益系数 gain coefficient
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_fval) begin
			wb_gain_r_m	<=  iv_wb_gain_r;
			wb_gain_g_m <=  iv_wb_gain_g;
			wb_gain_b_m <=  iv_wb_gain_b;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	提取每个通道的增益系数
	//	-------------------------------------------------------------------------------------
	genvar	i;
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			always @ ( * ) begin
				case({iv_r_flag[i],iv_g_flag[i],iv_b_flag[i]})
					3'b100	: gain_coe[i]	<= wb_gain_r_m;
					3'b010	: gain_coe[i]	<= wb_gain_g_m;
					3'b001	: gain_coe[i]	<= wb_gain_b_m;
					default	: gain_coe[i]	<= GAIN_COE_ONE;
				endcase
			end
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	划分通道
	//	--每个通道的位宽是 SENSOR_DAT_WIDTH 个bit
	//	--小端，最低的通道在低byte。
	//	-------------------------------------------------------------------------------------
	genvar	ch;
	generate
		for(ch=0;ch<CHANNEL_NUM;ch=ch+1) begin
			assign	wv_data_lane[ch]	= iv_pix_data[SENSOR_DAT_WIDTH*(ch+1)-1:SENSOR_DAT_WIDTH*ch];
		end
	endgenerate

	//  ===============================================================================================
	//	ref ***乘法器相关***
	//  ===============================================================================================
	genvar	j;
	generate
		//  -------------------------------------------------------------------------------------
		//	乘法器使能
		//	1.当行有效使能且增益使能打开的时候，乘法器才会使能，由于乘法器的延时为2，因此使能信号要比lval宽一拍
		//	2.否则，乘法器使能关闭
		//  -------------------------------------------------------------------------------------
//		assign	wb_mult_ce	= gain_enable&i_lval;
		assign	wb_mult_ce	= gain_enable&(i_lval|lval_dly0);
		for(j=0;j<CHANNEL_NUM;j=j+1) begin
			//  -------------------------------------------------------------------------------------
			//	乘法器两个输入端口
			//	1.输入端口都是17bit位宽，如果输入的数据位宽不足，需要用0补充高位
			//	2.乘法器a口是增益系数
			//	3.乘法器b口是像素数据
			//	4.乘法器的2个输入都没有打拍，直接使用输入的数据
			//  -------------------------------------------------------------------------------------
			assign	wb_mult_a[j]	= {{(17-WB_GAIN_WIDTH){1'b0}},gain_coe[j][WB_GAIN_WIDTH-1:0]};
			assign	wb_mult_b[j]	= {{(17-SENSOR_DAT_WIDTH){1'b0}},wv_data_lane[j][SENSOR_DAT_WIDTH-1:0]};

			//  -------------------------------------------------------------------------------------
			//	乘法器
			//	1.ce使能，当不输出数据的时候，使能关闭，节省功耗
			//	2.乘法器输入位宽17，输出位宽34，目的是方便扩展。DSP的高bit没有用到，在布局布线时会被优化。
			//	3.内部有2个pipelin，乘法器总延时2拍
			//  -------------------------------------------------------------------------------------
			wb_mult_a17b17p34 wb_mult_a17b17p34_inst (
			.clk	(clk			),
			.ce		(wb_mult_ce		),
			.a		(wb_mult_a[j]	),
			.b		(wb_mult_b[j]	),
			.p		(wb_mult_p[j]	)
			);
		end
	endgenerate

	//  -------------------------------------------------------------------------------------
	//	溢出位的解释
	//	乘法增益结果还需要右移 WB_RATIO 位，因为乘法增益系数与实际的系数有对应关系。比如 右移2位，相当于增益系数是实际系数的4倍。
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	增益的溢出位
	//	1.wb_mult_p		- 乘法器总共位宽是34bit
	//	2.gain_all_data	- DSP输出结果的实际有效位宽是 WB_GAIN_WIDTH + SENSOR_DAT_WIDTH，即A口的宽度 + B口的宽度，高位是全0
	//	3.gain_reduce	- DSP输出结果中的有效数据位宽是 SENSOR_DAT_WIDTH + WB_RATIO，这其中包含了溢出位
	//	4.gain_overflow	- 溢出位宽是 WB_GAIN_WIDTH + SENSOR_DAT_WIDTH - (SENSOR_DAT_WIDTH + WB_RATIO) = SENSOR_DAT_WIDTH - WB_RATIO
	//  -------------------------------------------------------------------------------------
	//	assign	gain_all_data	= wb_mult_p[(WB_GAIN_WIDTH+SENSOR_DAT_WIDTH-1):0];
	genvar	k;
	generate
		for(k=0;k<CHANNEL_NUM;k=k+1) begin
			assign	gain_reduce[k]		= wb_mult_p[k][(WB_GAIN_WIDTH+SENSOR_DAT_WIDTH-1):WB_RATIO];
			assign	gain_overflow[k]	= wb_mult_p[k][(WB_GAIN_WIDTH+SENSOR_DAT_WIDTH-1):SENSOR_DAT_WIDTH+WB_RATIO];
		end
	endgenerate

	//  ===============================================================================================
	//	ref ***数据输出***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	输出的像素数据
	//	1.当乘法增益不使能时
	//	--1.1当行场都有效时，直接输出输入的数据
	//	--1.2当消隐时，数据屏蔽为0
	//	2.当乘法增益使能时
	//	--2.1当行场都有效时
	//	----2.1.1如果溢出位有1出现，说明已经溢出，则有效数据为全1
	//	----2.1.2如果高位是全0出现，说明没有溢出，输出乘法器输出结果
	//	--2.2当消隐时，数据屏蔽为0
	//	这样的话，会有2拍的不一样。由于gain_enable的参数都是经过完整帧控制的，因此对后面影响不大。
	//  -------------------------------------------------------------------------------------
	genvar	l;
	generate
		for(l=0;l<CHANNEL_NUM;l=l+1) begin
			always @ (posedge clk) begin
				if(gain_enable==1'b0) begin
					if(i_fval==1'b1 && i_lval==1'b1) begin
						pix_data_reg[l]	<= wv_data_lane[l];
					end
					else begin
						pix_data_reg[l]	<= {SENSOR_DAT_WIDTH{1'b0}};
					end
				end
				else begin
					if(fval_dly1==1'b1 && lval_dly1==1'b1) begin
						if(|gain_overflow[l]) begin
							pix_data_reg[l]	<= {SENSOR_DAT_WIDTH{1'b1}};
						end
						else begin
							pix_data_reg[l]	<= gain_reduce[l][SENSOR_DAT_WIDTH-1:0];
						end
					end
					else begin
						pix_data_reg[l]	<= {SENSOR_DAT_WIDTH{1'b0}};
					end
				end
			end
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	各个通道组合输出
	//	-------------------------------------------------------------------------------------
	genvar	m;
	generate
		for(m=0;m<CHANNEL_NUM;m=m+1) begin
			assign	ov_pix_data[SENSOR_DAT_WIDTH*(m+1)-1:SENSOR_DAT_WIDTH*m]	= pix_data_reg[m];
		end
	endgenerate

	//  -------------------------------------------------------------------------------------
	//	行场信号延迟 共延迟3拍
	//	--gain_enable有效时，使用乘法器，增加了1拍延时
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_dly0	<= i_fval;
		fval_dly1	<= fval_dly0;
	end

	always @ (posedge clk) begin
		if(!gain_enable) begin
			fval_reg	<= i_fval;
		end
		else begin
			fval_reg	<= fval_dly1;
		end
	end
	assign	o_fval	= fval_reg ;

	//	-------------------------------------------------------------------------------------
	//	当输入场信号=0时，输出的行信号要屏蔽
	//	--gain_enable有效时，使用乘法器，增加了1拍延时
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_dly0	<= i_lval;
		lval_dly1	<= lval_dly0;
	end

	always @ (posedge clk) begin
		if(!gain_enable) begin
			if(i_fval==1'b0) begin
				lval_reg	<= 1'b0;
			end
			else begin
				lval_reg	<= i_lval;
			end
		end
		else begin
			if(fval_dly1==1'b0) begin
				lval_reg	<= 1'b0;
			end
			else begin
				lval_reg	<= lval_dly1;
			end
		end
	end
	assign	o_lval	= lval_reg;


endmodule
