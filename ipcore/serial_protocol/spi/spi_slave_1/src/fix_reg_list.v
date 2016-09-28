//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : fix_reg_list
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/6 11:24:55	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : fix时钟域的寄存器列表
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

module fix_reg_list # (
	parameter		SPI_ADDR_LENGTH				= 16	,	//spi 地址的长度
	parameter		SHORT_REG_WD				= 16	,	//短寄存器位宽
	parameter		REG_WD						= 32	,	//寄存器位宽
	parameter		LONG_REG_WD					= 64		//长寄存器位宽
	)
	(
	//  ===============================================================================================
	//	控制信号
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spi时钟域
	//  -------------------------------------------------------------------------------------
	input								clk_spi_sample	,	//主时钟
	input								i_rd_en			,	//读使能
	input	[SPI_ADDR_LENGTH-1:0]		iv_addr			,	//读写地址
	//  -------------------------------------------------------------------------------------
	//	固定电平
	//  -------------------------------------------------------------------------------------
	output								o_fix_sel		,	//固定时钟域被选择
	output	[SHORT_REG_WD-1:0]			ov_fix_rd_data		//读数据
	);

	//	ref signals
	
	//  ===============================================================================================
	//	ref 版本号
	//  ===============================================================================================
	localparam	VENDOR_ID		= 16'h4448;
	localparam	PRODUCT_ID		= 16'h1234;
	localparam	FPGA_VERSION_H	= 16'h0101;
	localparam	FPGA_VERSION_L	= 16'h010c;

	//  ===============================================================================================
	//	控制寄存器
	//  ===============================================================================================
	reg		[SHORT_REG_WD:0]			data_out_reg= {(SHORT_REG_WD+1){1'b0}};

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***读过程***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref 读过程寄存器操作
	//	读, data_out_reg 最高bit说明是否选中了该时钟域，余下内容为寄存器数据
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_spi_sample) begin
		//当读地址选中的时候，pix sel拉高为有效
		if(i_rd_en) begin
			case(iv_addr[8:0])
				//  -------------------------------------------------------------------------------------
				//	版本
				//  -------------------------------------------------------------------------------------
				9'h00	: data_out_reg	<= {1'b1,VENDOR_ID};
				9'h01	: data_out_reg	<= {1'b1,PRODUCT_ID};
				9'h02	: data_out_reg	<= {1'b1,FPGA_VERSION_H};
				9'h03	: data_out_reg	<= {1'b1,FPGA_VERSION_L};
	
				default	: data_out_reg	<= {(SHORT_REG_WD+1){1'b0}};

			endcase
		end
		//当读使能取消的时候，sel才能复位为0
		else begin
			data_out_reg	<= {(SHORT_REG_WD+1){1'b0}};
		end
	end
	assign	o_fix_sel		= data_out_reg[SHORT_REG_WD];
	assign	ov_fix_rd_data	= data_out_reg[SHORT_REG_WD-1:0];


endmodule