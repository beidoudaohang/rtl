//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : ad_14bit_adc
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/8/9 13:51:09	:|  初始版本
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

module ad_14bit_adc (
	input				clk			,
	input	[13:0]		iv_pix_data	,
	output	[13:0]		ov_pix_data
	);

	//	ref signals

	reg		[13:0]		pix_data_dly0	= 14'b0;
	reg		[13:0]		pix_data_dly1	= 14'b0;
	reg		[13:0]		pix_data_dly2	= 14'b0;
	reg		[13:0]		pix_data_dly3	= 14'b0;
	reg		[13:0]		pix_data_dly4	= 14'b0;
	reg		[13:0]		pix_data_dly5	= 14'b0;
	reg		[13:0]		pix_data_dly6	= 14'b0;
	reg		[13:0]		pix_data_dly7	= 14'b0;
	reg		[13:0]		pix_data_dly8	= 14'b0;
	reg		[13:0]		pix_data_dly9	= 14'b0;
	reg		[13:0]		pix_data_dly10	= 14'b0;
	reg		[13:0]		pix_data_dly11	= 14'b0;
	reg		[13:0]		pix_data_dly12	= 14'b0;
	reg		[13:0]		pix_data_dly13	= 14'b0;
	reg		[13:0]		pix_data_dly14	= 14'b0;


	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	延时15个时钟周期
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		pix_data_dly0	<= iv_pix_data		;
		pix_data_dly1	<= pix_data_dly0	;
		pix_data_dly2	<= pix_data_dly1	;
		pix_data_dly3	<= pix_data_dly2	;
		pix_data_dly4	<= pix_data_dly3	;
		pix_data_dly5	<= pix_data_dly4	;
		pix_data_dly6	<= pix_data_dly5	;
		pix_data_dly7	<= pix_data_dly6	;
		pix_data_dly8	<= pix_data_dly7	;
		pix_data_dly9	<= pix_data_dly8	;
		pix_data_dly10	<= pix_data_dly9	;
		pix_data_dly11	<= pix_data_dly10	;
		pix_data_dly12	<= pix_data_dly11	;
		pix_data_dly13	<= pix_data_dly12	;
		pix_data_dly14	<= pix_data_dly13	;
	end
	assign	ov_pix_data	= pix_data_dly14	;





endmodule
