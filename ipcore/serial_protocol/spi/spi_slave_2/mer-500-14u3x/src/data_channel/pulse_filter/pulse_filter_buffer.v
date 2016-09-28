//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : pulse_filter_buffer
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/2/11 14:49:15	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : ram 管理模块
//              1)  : 共有4个ram，每个ram的宽度是10bit，深度是3072，每个ram占用了 3 个 ram16k
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module pulse_filter_buffer (
	input			clk					,	//时钟
	input	[3:0]	iv_buffer_wr_en		,	//写使能
	input	[11:0]	iv_buffer_wr_addr	,	//写地址
	input	[9:0]	iv_buffer_wr_din	,	//写数据
	input			i_reset_buffer		,	//复位
	input	[3:0]	iv_buffer_rd_en		,	//读使能
	input	[11:0]	iv_buffer_rd_addr	,	//读地址
	output	[9:0]	ov_buffer_rd_dout0	,	//读数据0
	output	[9:0]	ov_buffer_rd_dout1	,	//读数据1
	output	[9:0]	ov_buffer_rd_dout2	,	//读数据2
	output	[9:0]	ov_buffer_rd_dout3		//读数据3
	);

	//	ref signals



	//	ref ARCHITECTURE

	pulse_filter_ram_w10d3072 pulse_filter_ram_w10d3072_inst0 (
	.clka		(clk				),
	.ena		(iv_buffer_wr_en[0]	),
	.wea		(iv_buffer_wr_en[0]	),
	.addra		(iv_buffer_wr_addr	),
	.dina		(iv_buffer_wr_din	),
	.clkb		(clk				),
	.rstb		(i_reset_buffer		),
	.enb		(iv_buffer_rd_en[0]	),
	.addrb		(iv_buffer_rd_addr	),
	.doutb		(ov_buffer_rd_dout0	)
	);

	pulse_filter_ram_w10d3072 pulse_filter_ram_w10d3072_inst1 (
	.clka		(clk				),
	.ena		(iv_buffer_wr_en[1]	),
	.wea		(iv_buffer_wr_en[1]	),
	.addra		(iv_buffer_wr_addr	),
	.dina		(iv_buffer_wr_din	),
	.clkb		(clk				),
	.rstb		(i_reset_buffer		),
	.enb		(iv_buffer_rd_en[1]	),
	.addrb		(iv_buffer_rd_addr	),
	.doutb		(ov_buffer_rd_dout1	)
	);

	pulse_filter_ram_w10d3072 pulse_filter_ram_w10d3072_inst2 (
	.clka		(clk				),
	.ena		(iv_buffer_wr_en[2]	),
	.wea		(iv_buffer_wr_en[2]	),
	.addra		(iv_buffer_wr_addr	),
	.dina		(iv_buffer_wr_din	),
	.clkb		(clk				),
	.rstb		(i_reset_buffer		),
	.enb		(iv_buffer_rd_en[2]	),
	.addrb		(iv_buffer_rd_addr	),
	.doutb		(ov_buffer_rd_dout2	)
	);

	pulse_filter_ram_w10d3072 pulse_filter_ram_w10d3072_inst3 (
	.clka		(clk				),
	.ena		(iv_buffer_wr_en[3]	),
	.wea		(iv_buffer_wr_en[3]	),
	.addra		(iv_buffer_wr_addr	),
	.dina		(iv_buffer_wr_din	),
	.clkb		(clk				),
	.rstb		(i_reset_buffer		),
	.enb		(iv_buffer_rd_en[3]	),
	.addrb		(iv_buffer_rd_addr	),
	.doutb		(ov_buffer_rd_dout3	)
	);



endmodule
