//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : serializer_sonyimx
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/10/14 10:41:56	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
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

module serializer_sonyimx # (
	parameter			DATA_WIDTH			= 10		,	//数据位宽
	parameter			CHANNEL_NUM			= 8			,	//通道数
	parameter			CLKIN_PERIOD		= 27.778
	)
	(
	input										clk					,	//时钟
	input										i_clk_en			,	//时钟使能
	input	[DATA_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data			,	//像素数据
	output										o_clk_p				,
	output										o_clk_n				,
	output	[CHANNEL_NUM-1:0]					ov_data_p			,
	output	[CHANNEL_NUM-1:0]					ov_data_n
	);

	//	ref signals
	wire	[DATA_WIDTH-1:0]					wv_data_lane	[CHANNEL_NUM-1:0]	;
	reg		[DATA_WIDTH-1:0]					shifter_data	[CHANNEL_NUM-1:0]	;
	reg											clk_ser_dly	= 1'b0;
	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***串行化***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	划分通道
	//	--每个通道的位宽是 DATA_WIDTH 个bit
	//	--大端，最高的通道在低byte。小端，最低的通道在低byte。
	//	-------------------------------------------------------------------------------------
	genvar	i;
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			assign	wv_data_lane[i]	= iv_pix_data[DATA_WIDTH*(i+1)-1:DATA_WIDTH*i];
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	串行通道1
	//	1.当使能有效时时，更新并行寄存器的数值
	//	2.当串行化计数器是其他数值时，将最高位移出
	//	-------------------------------------------------------------------------------------
	genvar	ch;
	generate
		for(ch=0;ch<CHANNEL_NUM;ch=ch+1) begin
			always @ (posedge clk) begin
				if(i_clk_en) begin
					shifter_data[ch]	<= wv_data_lane[ch];
				end
				else begin
					shifter_data[ch]	<= {shifter_data[ch][DATA_WIDTH-2:0],shifter_data[ch][DATA_WIDTH-1]};
				end
			end
		end
	endgenerate


	//	-------------------------------------------------------------------------------------
	//	时钟2分频
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		clk_ser_dly	<= !clk_ser_dly;
	end

	//	===============================================================================================
	//	ref ***输出***
	//	===============================================================================================
	assign	o_clk_p	=  clk_ser_dly;
	assign	o_clk_n	=  !clk_ser_dly;
	genvar	j;
	generate
		for(j=0;j<CHANNEL_NUM;j=j+1) begin
			assign	ov_data_p[j]	= shifter_data[j][DATA_WIDTH-1];
			assign	ov_data_n[j]	= !shifter_data[j][DATA_WIDTH-1];
		end
	endgenerate


endmodule
