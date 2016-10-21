//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : wb_bayer_sel
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/2/13 10:22:58	:|  初始版本
//  -- 邢海涛       :| 2015/10/16 10:26:13	:|  1.将mono_sel信号转移到白平衡的第一级模块
//												2.根据u3v协议，考虑所有的像素格式
//												3.当选择黑白时，不输出 rgb flag ，节省功耗
//												4.改为多通道的版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 根据Sensor的bayer格式，拆分出 R G B 三个颜色分量
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wb_bayer_sel # (
	parameter	BAYER_PATTERN		= "GR"	,	//"GR" "RG" "GB" "BG"
	parameter	SENSOR_DAT_WIDTH	= 10	,	//sensor 数据宽度
	parameter	CHANNEL_NUM			= 4		,	//通道数
	parameter	REG_WD				= 32		//寄存器位宽
	)
	(
	input											clk					,	//像素时钟
	input											i_fval				,	//场有效
	input											i_lval				,	//数据有效
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data			,	//图像数据
	input	[REG_WD-1:0]							iv_pixel_format		,	//0x01080001:Mono8、0x01100003:Mono10、0x01080008:BayerGR8、0x0110000C:BayerGR10。黑白时，不做白平衡统计，不做乘法。
	output											o_mono_sel			,	//选中黑白格式
	output	[CHANNEL_NUM-1:0]						ov_r_flag			,	//R 标志
	output	[CHANNEL_NUM-1:0]						ov_g_flag			,	//G 标志
	output	[CHANNEL_NUM-1:0]						ov_b_flag			,	//B 标志
	output											o_fval				,	//场有效
	output											o_lval				,	//行有效
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data				//图像数据
	);

	//	ref signals
	reg												lval_dly		= 1'b0;
	wire											lval_fall		;
	reg												fval_dly		= 1'b0;
	reg		[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		pix_data_dly	= {(SENSOR_DAT_WIDTH*CHANNEL_NUM){1'b0}};
	reg												mono_sel		= 1'b0;
	reg												line_cnt		= 1'b0;
	reg		[CHANNEL_NUM-1:0]						r_flag			= {CHANNEL_NUM{1'b0}};
	reg		[CHANNEL_NUM-1:0]						g_flag			= {CHANNEL_NUM{1'b0}};
	reg		[CHANNEL_NUM-1:0]						b_flag			= {CHANNEL_NUM{1'b0}};

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	USB3 Vision 	version 1.0.1	March, 2015
	//	table 5-14: Recommended Pixel Formats
	//
	//	Mono1p			0x01010037
	//	Mono2p			0x01020038
	//	Mono4p			0x01040039
	//	Mono8			0x01080001
	//	Mono10			0x01100003
	//	Mono10p			0x010a0046
	//	Mono12			0x01100005
	//	Mono12p			0x010c0047
	//	Mono14			0x01100025
	//	Mono16			0x01100007
	//
	//	BayerGR8		0x01080008
	//	BayerGR10		0x0110000C
	//	BayerGR10p		0x010A0056
	//	BayerGR12		0x01100010
	//	BayerGR12p		0x010C0057
	//	BayerGR16		0x0110002E
	//
	//	BayerRG8		0x01080009
	//	BayerRG10		0x0110000D
	//	BayerRG10p		0x010A0058
	//	BayerRG12		0x01100011
	//	BayerRG12p		0x010C0059
	//	BayerRG16		0x0110002F
	//
	//	BayerGB8		0x0108000A
	//	BayerGB10		0x0110000E
	//	BayerGB10p		0x010A0054
	//	BayerGB12		0x01100012
	//	BayerGB12p		0x010C0055
	//	BayerGB16		0x01100030
	//
	//	BayerBG8		0x0108000B
	//	BayerBG10		0x0110000F
	//	BayerBG10p		0x010A0052
	//	BayerBG12		0x01100013
	//	BayerBG12p		0x010C0053
	//	BayerBG16		0x01100031

	//	BGR8			0x02180015
	//	BGR10			0x02300019
	//	BGR10p			0x021E0048
	//	BGR12			0x0230001B
	//	BGR12p			0x02240049
	//	BGR14			0x0230004A
	//	BGR16			0x0230004B

	//	BGRa8			0x02200017
	//	BGRa10			0x0240004C
	//	BGRa10p			0x0228004D
	//	BGRa12			0x0240004E
	//	BGRa12p			0x0230004F
	//	BGRa14			0x02400050
	//	BGRa16			0x02400051
	//
	//	YCbCr8			0x0218005B
	//	YCbCr422_8		0x0210003B
	//	YCbCr411_8		0x020C005A
	//
	//	--如果要判断黑白格式，只需要判断低7bit就可以
	//	-------------------------------------------------------------------------------------

	//  ===============================================================================================
	//	ref ***延时 取边沿***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	行有效取边沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_dly	<= i_lval;
	end
	assign	lval_fall	= (lval_dly==1'b1 && i_lval==1'b0) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	延时 fval
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_dly	<= i_fval;
	end

	//  -------------------------------------------------------------------------------------
	//	延时 pix data
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		pix_data_dly	<= iv_pix_data;
	end

	//  ===============================================================================================
	//	ref ***提取颜色分量***
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	判断颜色格式
	//	--根据u3v协议，判断出黑白的像素格式
	//	--只需要判断低7bit即可
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(iv_pixel_format[6:0])
			7'h37	: mono_sel	<= 1'b1	;		//	Mono1p			0x01010037
			7'h38	: mono_sel	<= 1'b1	;		//	Mono2p			0x01020038
			7'h39	: mono_sel	<= 1'b1	;		//	Mono4p			0x01040039
			7'h01	: mono_sel	<= 1'b1	;		//	Mono8			0x01080001
			7'h03	: mono_sel	<= 1'b1	;		//	Mono10			0x01100003
			7'h46	: mono_sel	<= 1'b1	;		//	Mono10p			0x010a0046
			7'h05	: mono_sel	<= 1'b1	;		//	Mono12			0x01100005
			7'h47	: mono_sel	<= 1'b1	;		//	Mono12p			0x010c0047
			7'h25	: mono_sel	<= 1'b1	;		//	Mono14			0x01100025
			7'h07	: mono_sel	<= 1'b1	;		//	Mono16			0x01100007
			default	: mono_sel	<= 1'b0	;		//	others
		endcase
	end
	assign	o_mono_sel	= mono_sel;

	//  -------------------------------------------------------------------------------------
	//	行计数器，奇数行和偶数行的bayer格式不一样
	//	--当帧消隐时，line_cnt复位。
	//	--当选择黑白格式时，line_cnt复位。节省功耗。
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_fval==1'b0 || mono_sel==1'b1) begin
			line_cnt	<= 1'b0;
		end
		else begin
			if(lval_fall) begin
				line_cnt	<= !line_cnt;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	pattern 差分颜色分量
	//	--每种颜色分量分别输出 rgb flab
	//	--当行消隐时或者选中黑白格式是，不输出 rgb flag ，节省功耗
	//  -------------------------------------------------------------------------------------
	generate
		if(BAYER_PATTERN=="GR") begin
			if(CHANNEL_NUM==1) begin
				//	-------------------------------------------------------------------------------------
				//	单通道时，rgb 分别产生
				//  -------------------------------------------------------------------------------------
				//	ref GR pattern single channel
				//	line 0
				//	DATA		r flag		g flag		b flag
				//	GRGR		0101		1010		0000
				//
				//	line 1
				//	DATA		r flag		g flag		b flag
				//	BGBG		0000		0101		1010
				//
				//  -------------------------------------------------------------------------------------
				always @ (posedge clk) begin
					if(i_lval==1'b0 || mono_sel==1'b1) begin
						r_flag	<= {CHANNEL_NUM{1'b0}};
						g_flag	<= {CHANNEL_NUM{1'b0}};
						b_flag	<= {CHANNEL_NUM{1'b0}};
					end
					else begin
						if(!line_cnt) begin
							r_flag	<= g_flag;
							g_flag	<= ~g_flag;
							b_flag	<= {CHANNEL_NUM{1'b0}};
						end
						else begin
							r_flag	<= {CHANNEL_NUM{1'b0}};
							g_flag	<= b_flag;
							b_flag	<= ~b_flag;
						end
					end
				end
			end
			else begin
				//	-------------------------------------------------------------------------------------
				//	多通道时，rgb在一行中一直有效
				//  -------------------------------------------------------------------------------------
				//	ref GR pattern mult channel
				//	line 0
				//		DATA		r flag		g flag		b flag
				//	CH0	GGGG		0000		1111		0000
				//	CH1	RRRR		1111		0000		0000
				//	CH2	GGGG		0000		1111		0000
				//	CH3	RRRR		1111		0000		0000
				//
				//	line 1
				//		DATA		r flag		g flag		b flag
				//	CH0	BBBB		0000		0000		1111
				//	CH1	GGGG		0000		1111		0000
				//	CH2	BBBB		0000		0000		1111
				//	CH3	GGGG		0000		1111		0000
				//
				//  -------------------------------------------------------------------------------------
				always @ (posedge clk) begin
					if(i_lval==1'b0 || mono_sel==1'b1) begin
						r_flag	<= {CHANNEL_NUM{1'b0}};
						g_flag	<= {CHANNEL_NUM{1'b0}};
						b_flag	<= {CHANNEL_NUM{1'b0}};
					end
					else begin
						if(!line_cnt) begin
							r_flag	<= {(CHANNEL_NUM/2){2'b10}};
							g_flag	<= {(CHANNEL_NUM/2){2'b01}};
							b_flag	<= {CHANNEL_NUM{1'b0}};
						end
						else begin
							r_flag	<= {CHANNEL_NUM{1'b0}};
							g_flag	<= {(CHANNEL_NUM/2){2'b10}};
							b_flag	<= {(CHANNEL_NUM/2){2'b01}};
						end
					end
				end
			end
		end

		else if(BAYER_PATTERN=="RG") begin
			if(CHANNEL_NUM==1) begin
				//	-------------------------------------------------------------------------------------
				//	单通道时，rgb 分别产生
				//  -------------------------------------------------------------------------------------
				//	ref RG pattern single channel
				//	line 0
				//	DATA		r flag		g flag		b flag
				//	RGRG		1010		0101		0000
				//
				//	line 1
				//	DATA		r flag		g flag		b flag
				//	GBGB		0000		1010		0101
				//
				//  -------------------------------------------------------------------------------------
				always @ (posedge clk) begin
					if(i_lval==1'b0 || mono_sel==1'b1) begin
						r_flag	<= {CHANNEL_NUM{1'b0}};
						g_flag	<= {CHANNEL_NUM{1'b0}};
						b_flag	<= {CHANNEL_NUM{1'b0}};
					end
					else begin
						if(!line_cnt) begin
							r_flag	<= ~r_flag;
							g_flag	<= r_flag;
							b_flag	<= {CHANNEL_NUM{1'b0}};
						end
						else begin
							r_flag	<= {CHANNEL_NUM{1'b0}};
							g_flag	<= ~g_flag;
							b_flag	<= g_flag;
						end
					end
				end
			end
			else begin
				//	-------------------------------------------------------------------------------------
				//	多通道时，rgb在一行中一直有效
				//  -------------------------------------------------------------------------------------
				//	ref RG pattern mult channel
				//	line 0
				//		DATA		r flag		g flag		b flag
				//	CH0	RRRR		1111		0000		0000
				//	CH1	GGGG		0000		1111		0000
				//	CH2	RRRR		1111		0000		0000
				//	CH3	GGGG		0000		1111		0000
				//
				//	line 1
				//		DATA		r flag		g flag		b flag
				//	CH0	GGGG		0000		1111		0000
				//	CH1	BBBB		0000		0000		1111
				//	CH2	GGGG		0000		1111		0000
				//	CH3	BBBB		0000		0000		1111
				//
				//  -------------------------------------------------------------------------------------
				always @ (posedge clk) begin
					if(i_lval==1'b0 || mono_sel==1'b1) begin
						r_flag	<= {CHANNEL_NUM{1'b0}};
						g_flag	<= {CHANNEL_NUM{1'b0}};
						b_flag	<= {CHANNEL_NUM{1'b0}};
					end
					else begin
						if(!line_cnt) begin
							r_flag	<= {(CHANNEL_NUM/2){2'b01}};
							g_flag	<= {(CHANNEL_NUM/2){2'b10}};
							b_flag	<= {CHANNEL_NUM{1'b0}};
						end
						else begin
							r_flag	<= {CHANNEL_NUM{1'b0}};
							g_flag	<= {(CHANNEL_NUM/2){2'b01}};
							b_flag	<= {(CHANNEL_NUM/2){2'b10}};
						end
					end
				end
			end
		end

		else if(BAYER_PATTERN=="GB") begin
			if(CHANNEL_NUM==1) begin
				//	-------------------------------------------------------------------------------------
				//	单通道时，rgb 分别产生
				//  -------------------------------------------------------------------------------------
				//	ref GB pattern single channel
				//	line 0
				//	DATA		r flag		g flag		b flag
				//	GBGB		0000		1010		0101
				//
				//	line 1
				//	DATA		r flag		g flag		b flag
				//	RGRG		1010		0101		0000
				//
				//  -------------------------------------------------------------------------------------
				always @ (posedge clk) begin
					if(i_lval==1'b0 || mono_sel==1'b1) begin
						r_flag	<= {CHANNEL_NUM{1'b0}};
						g_flag	<= {CHANNEL_NUM{1'b0}};
						b_flag	<= {CHANNEL_NUM{1'b0}};
					end
					else begin
						if(!line_cnt) begin
							r_flag	<= {CHANNEL_NUM{1'b0}};
							g_flag	<= ~g_flag;
							b_flag	<= g_flag;
						end
						else begin
							r_flag	<= ~r_flag;
							g_flag	<= r_flag;
							b_flag	<= {CHANNEL_NUM{1'b0}};
						end
					end
				end
			end
			else begin
				//	-------------------------------------------------------------------------------------
				//	多通道时，rgb在一行中一直有效
				//  -------------------------------------------------------------------------------------
				//	ref GB pattern mult channel
				//	line 0
				//		DATA		r flag		g flag		b flag
				//	CH0	GGGG		0000		1111		0000
				//	CH1	BBBB		0000		0000		1111
				//	CH2	GGGG		0000		1111		0000
				//	CH3	BBBB		0000		0000		1111
				//
				//	line 1
				//		DATA		r flag		g flag		b flag
				//	CH0	RRRR		1111		0000		0000
				//	CH1	GGGG		0000		1111		0000
				//	CH2	RRRR		1111		0000		0000
				//	CH3	GGGG		0000		1111		0000
				//
				//  -------------------------------------------------------------------------------------
				always @ (posedge clk) begin
					if(i_lval==1'b0 || mono_sel==1'b1) begin
						r_flag	<= {CHANNEL_NUM{1'b0}};
						g_flag	<= {CHANNEL_NUM{1'b0}};
						b_flag	<= {CHANNEL_NUM{1'b0}};
					end
					else begin
						if(!line_cnt) begin
							r_flag	<= {CHANNEL_NUM{1'b0}};
							g_flag	<= {(CHANNEL_NUM/2){2'b01}};
							b_flag	<= {(CHANNEL_NUM/2){2'b10}};
						end
						else begin
							r_flag	<= {(CHANNEL_NUM/2){2'b01}};
							g_flag	<= {(CHANNEL_NUM/2){2'b10}};
							b_flag	<= {CHANNEL_NUM{1'b0}};
						end
					end
				end
			end
		end

		else if(BAYER_PATTERN=="BG") begin
			if(CHANNEL_NUM==1) begin
				//	-------------------------------------------------------------------------------------
				//	单通道时，rgb 分别产生
				//  -------------------------------------------------------------------------------------
				//	ref BG pattern single channel
				//	line 0
				//	DATA		r flag		g flag		b flag
				//	BGBG		0000		0101		1010
				//
				//	line 1
				//	DATA		r flag		g flag		b flag
				//	GRGR		0101		1010		0000
				//
				//  -------------------------------------------------------------------------------------
				always @ (posedge clk) begin
					if(i_lval==1'b0 || mono_sel==1'b1) begin
						r_flag	<= {CHANNEL_NUM{1'b0}};
						g_flag	<= {CHANNEL_NUM{1'b0}};
						b_flag	<= {CHANNEL_NUM{1'b0}};
					end
					else begin
						if(!line_cnt) begin
							r_flag	<= {CHANNEL_NUM{1'b0}};
							g_flag	<= b_flag;
							b_flag	<= ~b_flag;
						end
						else begin
							r_flag	<= g_flag;
							g_flag	<= ~g_flag;
							b_flag	<= {CHANNEL_NUM{1'b0}};
						end
					end
				end
			end
			else begin
				//	-------------------------------------------------------------------------------------
				//	多通道时，rgb在一行中一直有效
				//  -------------------------------------------------------------------------------------
				//	ref BG pattern mult channel
				//	line 0
				//		DATA		r flag		g flag		b flag
				//	CH0	BBBB		0000		0000		1111
				//	CH1	GGGG		0000		1111		0000
				//	CH2	BBBB		0000		0000		1111
				//	CH3	GGGG		0000		1111		0000
				//
				//	line 1
				//		DATA		r flag		g flag		b flag
				//	CH1	GGGG		0000		1111		0000
				//	CH2	RRRR		1111		0000		0000
				//	CH3	GGGG		0000		1111		0000
				//	CH0	RRRR		1111		0000		0000
				//
				//  -------------------------------------------------------------------------------------
				always @ (posedge clk) begin
					if(i_lval==1'b0 || mono_sel==1'b1) begin
						r_flag	<= {CHANNEL_NUM{1'b0}};
						g_flag	<= {CHANNEL_NUM{1'b0}};
						b_flag	<= {CHANNEL_NUM{1'b0}};
					end
					else begin
						if(!line_cnt) begin
							r_flag	<= {CHANNEL_NUM{1'b0}};
							g_flag	<= {(CHANNEL_NUM/2){2'b10}};
							b_flag	<= {(CHANNEL_NUM/2){2'b01}};
						end
						else begin
							r_flag	<= {(CHANNEL_NUM/2){2'b10}};
							g_flag	<= {(CHANNEL_NUM/2){2'b01}};
							b_flag	<= {CHANNEL_NUM{1'b0}};
						end
					end
				end
			end
		end

		//  -------------------------------------------------------------------------------------
		//	输入其他的参数，错误
		//  -------------------------------------------------------------------------------------
		else begin
			always @ (posedge clk) begin
				r_flag	<= {CHANNEL_NUM{1'b0}};
				g_flag	<= {CHANNEL_NUM{1'b0}};
				b_flag	<= {CHANNEL_NUM{1'b0}};
			end
		end

	endgenerate

	//  -------------------------------------------------------------------------------------
	//	输出颜色分量标志
	//  -------------------------------------------------------------------------------------
	assign	ov_r_flag	= r_flag;
	assign	ov_g_flag	= g_flag;
	assign	ov_b_flag	= b_flag;

	//  ===============================================================================================
	//	ref ***输出像素数据***
	//  ===============================================================================================
	assign	o_fval		= 	fval_dly;
	assign	o_lval		= 	lval_dly;
	assign	ov_pix_data	= 	pix_data_dly;



endmodule
