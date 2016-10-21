//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : data_align
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/5 15:44:31	:|  初始版本
//	-- 陕天龙		:| 2015/9/1 13:52:59	:|	添加说明
//	-- 陕天龙		:| 2015/11/10 11:31:04	:|	支持源代码modelsim仿真
//	-- 陕天龙		:| 2015/12/8 16:37:58	:|	最高可支持八通道，128bit数据拼接
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 数据拼接模块
//              1)  : 根据pixel format的数据位宽，选择拼接方式。输出位宽固定为64bit
//
//              2)  : 如果pixel format的数据位宽是8bit，选择输入数据的高8bit，每4个像素拼接为1个32bit数据，先到来的数据放在低位
//
//              3)  : 如果pixel format的数据位宽是10bit，选择输入数据高10bit，每2个像素拼接为1个32bit数据，先到来的数据放在低位
//
//              4)  : 暂不支持8通道
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module data_align # (
	parameter	SENSOR_DAT_WIDTH	= 10	,	//sensor 数据宽度
	parameter	CHANNEL_NUM			= 8		,	//sensor 通道数量
	parameter	REG_WD				= 32	,	//寄存器位宽
	parameter	DATA_WD				= 128		//输入输出数据位宽，这里使用同一宽度
	)
	(
	//Sensor输入信号
	input										clk				,	//像素时钟
	input										i_fval			,	//场信号
	input										i_lval			,	//行信号
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	iv_pix_data		,	//图像数据
	//灰度统计相关寄存器
	input	[REG_WD-1:0]						iv_pixel_format	,	//像素格式寄存器，0x01080001:Mono8、0x01100003:Mono10、0x01080008:BayerGR8、0x0110000C:BayerGR10
	//输出
	output										o_fval			,	//场有效
	output										o_pix_data_en	,	//数据有效信号，数据拼接之后的使能信号，相当于时钟的2分频或者4分频
	output	[DATA_WD-1:0]						ov_pix_data			//图像数据
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
	localparam									DATAEN_8B		= DATA_WD/(8*CHANNEL_NUM);
	localparam									REDUCE_8B		= log2(DATAEN_8B);

	localparam									DATAEN_10B		= DATA_WD/(16*CHANNEL_NUM);
	localparam									REDUCE_10B		= log2(DATAEN_10B);

	reg											format8_sel		= 1'b0;
	reg		[DATA_WD-1:0]						pix_data_shift	= {DATA_WD{1'b0}};
	reg		[DATA_WD-1:0]						pix_data_reg	= {DATA_WD{1'b0}};
	reg		[3:0]								pix_cnt			= 3'b0;
	reg											data_en			= 1'b0;
	reg											data_en_dly		= 1'b0;
	reg											fval_dly0		= 1'b0;
	reg											fval_dly1		= 1'b0;

	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref ***判断数据格式***
	//  ===============================================================================================
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
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	format8_sel
	//	1.判断像素格式是否选中8bit像素格式
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case (iv_pixel_format[6:0])
			7'h01		: format8_sel	<= 1'b1;
			7'h08		: format8_sel	<= 1'b1;
			7'h09		: format8_sel	<= 1'b1;
			7'h0A		: format8_sel	<= 1'b1;
			7'h0B		: format8_sel	<= 1'b1;
			7'h15		: format8_sel	<= 1'b1;
			7'h17		: format8_sel	<= 1'b1;
			7'h5B		: format8_sel	<= 1'b1;
			7'h3B		: format8_sel	<= 1'b1;
			7'h5A		: format8_sel	<= 1'b1;
			default		: format8_sel	<= 1'b0;
		endcase
	end

	//  ===============================================================================================
	//	ref ***数据移位***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	数据移位寄存器
	//	1.当场消隐时，移位寄存器清零
	//	2.当场有效且行有效时，如果像素格式是8bit，每个像素占据1个byte，只取像素的高8bit
	//	3.当场有效且行有效时，如果像素格式是10bit，每个像素占据2个byte，，只取像素的高10bit，高位填充0
	//	4.数据移位寄存器位宽-64bit
	//	5.10BIT格式暂不支持8通道
	//  -------------------------------------------------------------------------------------
	generate
		if (CHANNEL_NUM == 1) begin
			always @ (posedge clk) begin
				if(!i_fval) begin
					pix_data_shift	<= {DATA_WD{1'b0}};
				end
				else begin
					if(i_lval) begin
						if(format8_sel) begin
							pix_data_shift	<= {iv_pix_data[SENSOR_DAT_WIDTH-1:SENSOR_DAT_WIDTH-8],pix_data_shift[DATA_WD-1:8]};
						end
						else begin
							pix_data_shift	<= {{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[SENSOR_DAT_WIDTH-1:0],pix_data_shift[DATA_WD-1:16]};
						end
					end
				end
			end
		end
		else if (CHANNEL_NUM == 2) begin
			always @ (posedge clk) begin
				if(!i_fval) begin
					pix_data_shift	<= {DATA_WD{1'b0}};
				end
				else begin
					if(i_lval) begin
						if(format8_sel) begin
							pix_data_shift	<= {iv_pix_data[2*SENSOR_DAT_WIDTH-1:2*SENSOR_DAT_WIDTH-8],iv_pix_data[SENSOR_DAT_WIDTH-1:SENSOR_DAT_WIDTH-8],
												pix_data_shift[DATA_WD-1:16]};
						end
						else begin
							pix_data_shift	<= {{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[2*SENSOR_DAT_WIDTH-1:SENSOR_DAT_WIDTH],{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[SENSOR_DAT_WIDTH-1:0],
												pix_data_shift[DATA_WD-1:32]};
						end
					end
				end
			end
		end
		else if (CHANNEL_NUM == 4) begin
			always @ (posedge clk) begin
				if(!i_fval) begin
					pix_data_shift	<= {DATA_WD{1'b0}};
				end
				else begin
					if(i_lval) begin
						if(format8_sel) begin
							pix_data_shift	<= {iv_pix_data[4*SENSOR_DAT_WIDTH-1:4*SENSOR_DAT_WIDTH-8],iv_pix_data[3*SENSOR_DAT_WIDTH-1:3*SENSOR_DAT_WIDTH-8],
												iv_pix_data[2*SENSOR_DAT_WIDTH-1:2*SENSOR_DAT_WIDTH-8],iv_pix_data[SENSOR_DAT_WIDTH-1:SENSOR_DAT_WIDTH-8],
												pix_data_shift[DATA_WD-1:32]};
						end
						else begin
							pix_data_shift	<= {{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[4*SENSOR_DAT_WIDTH-1:3*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[3*SENSOR_DAT_WIDTH-1:2*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[2*SENSOR_DAT_WIDTH-1:SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[SENSOR_DAT_WIDTH-1:0],
												pix_data_shift[DATA_WD-1:64]};
						end
					end
				end
			end
		end
		else if (CHANNEL_NUM == 8) begin
			always @ (posedge clk) begin
				if(!i_fval) begin
					pix_data_shift	<= {DATA_WD{1'b0}};
				end
				else begin
					if(i_lval) begin
						if(format8_sel) begin
							pix_data_shift	<= {iv_pix_data[8*SENSOR_DAT_WIDTH-1:8*SENSOR_DAT_WIDTH-8],iv_pix_data[7*SENSOR_DAT_WIDTH-1:7*SENSOR_DAT_WIDTH-8],
												iv_pix_data[6*SENSOR_DAT_WIDTH-1:6*SENSOR_DAT_WIDTH-8],iv_pix_data[5*SENSOR_DAT_WIDTH-1:5*SENSOR_DAT_WIDTH-8],
												iv_pix_data[4*SENSOR_DAT_WIDTH-1:4*SENSOR_DAT_WIDTH-8],iv_pix_data[3*SENSOR_DAT_WIDTH-1:3*SENSOR_DAT_WIDTH-8],
												iv_pix_data[2*SENSOR_DAT_WIDTH-1:2*SENSOR_DAT_WIDTH-8],iv_pix_data[SENSOR_DAT_WIDTH-1:SENSOR_DAT_WIDTH-8],
												pix_data_shift[DATA_WD-1:64]};
						end
						else begin
							pix_data_shift	<= {{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[8*SENSOR_DAT_WIDTH-1:7*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[7*SENSOR_DAT_WIDTH-1:6*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[6*SENSOR_DAT_WIDTH-1:5*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[5*SENSOR_DAT_WIDTH-1:4*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[4*SENSOR_DAT_WIDTH-1:3*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[3*SENSOR_DAT_WIDTH-1:2*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[2*SENSOR_DAT_WIDTH-1:1*SENSOR_DAT_WIDTH],
												{(16-SENSOR_DAT_WIDTH){1'b0}},iv_pix_data[SENSOR_DAT_WIDTH-1:0]};
						end
					end
				end
			end
		end
	endgenerate


	//  -------------------------------------------------------------------------------------
	//	像素计数器
	//	1.场消隐时，清零
	//	2.场有效且行有效时，计数器累加
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_fval) begin
			pix_cnt	<= 4'b0;
		end
		else begin
			if(i_lval) begin
				pix_cnt	<= pix_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	像素格式8bit
	//	CHANNEL_NUM=1时，pix_cnt[3:0]=15；
	//	CHANNEL_NUM=2时，pix_cnt[2:0]=7；
	//	CHANNEL_NUM=4时，pix_cnt[1:0]=3；
	//	CHANNEL_NUM=8时，pix_cnt[0:0]=1；
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	像素格式10bit
	//	CHANNEL_NUM=1时，pix_cnt[2:0]=7；
	//	CHANNEL_NUM=2时，pix_cnt[1:0]=3；
	//	CHANNEL_NUM=4时，pix_cnt[0:0]=1；
	//	CHANNEL_NUM=8时，无条件；
	//  -------------------------------------------------------------------------------------
	generate
		if (DATAEN_10B == 1) begin		// CHANNEL_NUM=8
			always @ (posedge clk) begin
				if(!i_fval) begin
					data_en	<= 1'b0;
				end
				else begin
					if(i_lval) begin
						if(format8_sel) begin
							if(pix_cnt[REDUCE_8B - 1 : 0] == (DATAEN_8B - 1)) begin
								data_en	<= 1'b1;
							end
							else begin
								data_en	<= 1'b0;
							end
						end
						else begin
							data_en	<= 1'b1;
						end
					end
					else begin
						data_en	<= 1'b0;
					end
				end
			end
		end
		else begin
			always @ (posedge clk) begin
				if(!i_fval) begin
					data_en	<= 1'b0;
				end
				else begin
					if(i_lval) begin
						if(format8_sel) begin
							if(pix_cnt[REDUCE_8B - 1 : 0] == (DATAEN_8B - 1)) begin
								data_en	<= 1'b1;
							end
							else begin
								data_en	<= 1'b0;
							end
						end
						else begin
							if(pix_cnt[REDUCE_10B - 1 : 0] == (DATAEN_10B - 1)) begin
								data_en	<= 1'b1;
							end
							else begin
								data_en	<= 1'b0;
							end
						end
					end
					else begin
						data_en	<= 1'b0;
					end
				end
			end
		end
	endgenerate

	//  ===============================================================================================
	//	ref ***行场信号、数据输出***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	fval 输出
	//	1.从结尾处看，数据延时了2个时钟输出，因此要对fval延时2个时钟周期
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_dly0	<= i_fval;
		fval_dly1	<= fval_dly0;
	end

	//	-------------------------------------------------------------------------------------
	//	对data_en延时1拍，因为数据的处理滞后了一拍，所以要延时
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		data_en_dly	<= data_en;
	end

	//	-------------------------------------------------------------------------------------
	//	判断输出数据，如果不使能，则输出为全零
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(data_en) begin
			pix_data_reg	<= pix_data_shift;
		end
		else begin
			pix_data_reg	<= {DATA_WD{1'b0}};
		end
	end

	//  -------------------------------------------------------------------------------------
	//	输出
	//  -------------------------------------------------------------------------------------
	assign	o_pix_data_en	= data_en_dly;
	assign	ov_pix_data		= pix_data_reg;
	assign	o_fval			= fval_dly1;



endmodule
