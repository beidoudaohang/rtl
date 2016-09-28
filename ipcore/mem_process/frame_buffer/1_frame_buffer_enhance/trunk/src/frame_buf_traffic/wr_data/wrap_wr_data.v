//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : wrap_wr_data
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/6/9 16:24:48	:|  初始版本
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
//`include			"wrap_wr_data_def.v"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wrap_wr_data (
	input			clk		,
	input			reset	,
	input			i_fval	,
	input			i_dval	,
	input	[22:0]	iv_frame_size	,
	output	[31:0]	ov_image_dout
	);

	//	ref signals

	wire					crc_en	;
	wire	[31:0]			wv_image_data	;
	wire	[15:0]			wv_crc_out	;
	reg		[22:0]			frame_size_cnt	= 'b0;
	
	
	
	//	ref ARCHITECTURE


	gen_wr_data gen_wr_data_inst (
	.clk			(clk	),
	.ov_image_data	(wv_image_data	)
	);


	assign	crc_en	= i_fval&i_dval;
	crc_16 crc_16_inst (
	.reset			(reset | !i_fval),
	.clk			(clk			),
	.data_in		(wv_image_data	),
	.crc_en			(crc_en			),
	.crc_out		(wv_crc_out		)
	);
	
	always @ (posedge clk) begin
		if(i_fval == 1'b0) begin
			frame_size_cnt	<= 23'b0;
		end
		else begin
			if(i_dval == 1'b1) begin
				frame_size_cnt	<= frame_size_cnt + 1'b1;
			end
		end
	end

	assign	crc_switch	= (frame_size_cnt == iv_frame_size) ? 1'b1 : 1'b0	;
	assign	ov_image_dout	= crc_switch ? {wv_crc_out,wv_crc_out} : wv_image_data;
	

endmodule
