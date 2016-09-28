//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : sensor_noise
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/4/16 13:59:24	:|  初始版本
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

module sensor_noise # (
	parameter						DATA_WIDTH			= 8			//数据位宽
	)
	(
	input							clk							,	//时钟
	input	[15:0]					iv_line_active_pix_num		,	//行宽
	input							i_fval						,	//场有效
	input							i_lval						,	//行有效
	input	[DATA_WIDTH-1:0]		iv_pix_data					,	//像素数据
	output							o_fval						,	//场有效
	output							o_lval						,	//行有效
	output	[DATA_WIDTH-1:0]		ov_pix_data						//像素数据
	);

	//	ref signals
	reg		[7:0]					lfsr_reg	= 8'hab;
	wire							lfsr_seed	;
	reg		[7:0]					time_cnt	= 8'b0;
	wire							noise_en	;
	wire	[DATA_WIDTH-1:0]		noise_data	;


	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	lfsr 产生随机数
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lfsr_reg	<= {lfsr_reg[6:0],lfsr_seed};
	end
	assign	lfsr_seed	= lfsr_reg[0] ^ lfsr_reg[2] ^ lfsr_reg[7];

	//	-------------------------------------------------------------------------------------
	//	时间计数器
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_fval) begin
			time_cnt	<= 8'h0;
		end
		else begin
			if(i_lval) begin
				if(time_cnt==lfsr_reg) begin
					time_cnt	<= 8'h0;
				end
				else begin
					time_cnt	<= time_cnt + 1'b1;
				end
			end
		end
	end

	assign	noise_en	= (i_fval==1'b1 && i_lval==1'b1 && time_cnt==lfsr_reg) ? 1'b1 : 1'b0;
	assign	noise_data	= {{(DATA_WIDTH-8){1'b0}},lfsr_reg[7:0]};
	assign	o_fval		= i_fval;
	assign	o_lval		= i_lval;
	assign	ov_pix_data	= (noise_en==1'b1) ? noise_data : iv_pix_data;



endmodule
