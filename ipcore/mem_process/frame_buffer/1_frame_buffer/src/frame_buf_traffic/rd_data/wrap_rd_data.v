//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : wrap_rd_data
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/6/9 16:50:28	:|  初始版本
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
//`include			"wrap_rd_data_def.v"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wrap_rd_data (
	input			clk		,
	input			reset	,
	input			i_buf_empty	,
	output			o_buf_rd	,
	input	[22:0]	iv_frame_size	,
	input	[32:0]	iv_image_din	,
	output			o_good_frame	,
	output			o_bad_frame

	);

	//	ref signals
	reg		[22:0]	frame_size_cnt 	= 23'b0;
	reg		good_frame_reg 	= 1'b0;
	reg		bad_frame_reg 	= 1'b0;
	wire			[15:0]	wv_crc_out	;
	wire			[31:0]	crc_combin	;
	
	//	ref ARCHITECTURE


	crc_16 crc_16_inst (
	.reset			(reset | iv_image_din[32]),
	.clk			(clk			),
	.data_in		(iv_image_din[31:0]	),
	.crc_en			(o_buf_rd		),
	.crc_out		(wv_crc_out		)
	);
	assign	crc_combin	= {wv_crc_out,wv_crc_out};

	always @ (posedge clk) begin
		if(iv_image_din[32] == 1'b1) begin
			frame_size_cnt	<= 23'b0;
		end
		else begin
			if(o_buf_rd == 1'b1) begin
				frame_size_cnt	<= frame_size_cnt + 1'b1;
			end
		end
	end

	always @ (posedge clk) begin
		if((frame_size_cnt == iv_frame_size)&&(o_buf_rd == 1'b1)) begin
			if(crc_combin == iv_image_din[31:0]) begin
				good_frame_reg	<= 1'b1;
				bad_frame_reg	<= 1'b0;
			end
			else begin
				good_frame_reg	<= 1'b0;
				bad_frame_reg	<= 1'b1;
			end
		end
		else begin
			good_frame_reg	<= 1'b0;
			bad_frame_reg	<= 1'b0;
		end
	end
	assign	o_good_frame	= good_frame_reg;
	assign	o_bad_frame	= bad_frame_reg;
	assign	o_buf_rd	= !i_buf_empty;





endmodule
