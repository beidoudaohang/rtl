//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : pulser_filter_wr
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/2/11 14:43:36	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 写ram模块
//              1)  : 循环写4个ram
//
//              2)  : 输入当前正在传输的行，且要与rd模块输出的数据对齐
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module pulser_filter_wr # (
	parameter					SENSOR_DAT_WIDTH	= 10		//sensor 数据宽度
	)
	(
	input								clk					,	//像素时钟
	input								i_fval				,	//场信号，i_fval上下边沿与i_lval相距10个时钟周期
	input								i_lval				,	//行信号
	input	[SENSOR_DAT_WIDTH-1:0]		iv_pix_data			,	//图像数据
	output	[3:0]						ov_buffer_wr_en		,	//ram写使能
	output	[11:0]						ov_buffer_wr_addr	,	//ram写地址
	output	[9:0]						ov_buffer_wr_din	,	//ram写数据
	output	[SENSOR_DAT_WIDTH-1:0]		ov_lower_line			//当前输入的数据，经过打拍之后，与rd模块输出的2行数据对齐
	);

	//	ref signals
	reg									lval_dly			= 1'b0;
	wire								lval_fall			;
	reg		[1:0]						lval_cnt			= 2'b0;
	reg		[3:0]						buffer_wr_en		= 4'b0;
	reg		[11:0]						buffer_wr_addr		= 12'b0;
	reg		[SENSOR_DAT_WIDTH-1:0]		buffer_wr_din_dly0	= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		buffer_wr_din_dly1	= {SENSOR_DAT_WIDTH{1'b0}};
	reg		[SENSOR_DAT_WIDTH-1:0]		buffer_wr_din_dly2	= {SENSOR_DAT_WIDTH{1'b0}};


	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***取边沿***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	判断lval的边沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_dly	<= i_lval;
	end
	assign	lval_fall	= (lval_dly==1'b1 && i_lval==1'b0) ? 1'b1 : 1'b0;

	//	===============================================================================================
	//	ref ***循环写ram***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	lval边沿计数器
	//	1.当场消隐时，计数器清零
	//	2.当场有效是，每过一行，计数器自增
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_fval) begin
			lval_cnt	<= 2'b00;
		end
		else begin
			if(lval_fall) begin
				lval_cnt	<= lval_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	buffer写信号
	//	1.当帧消隐时，写使能清零
	//	2.当帧有效时，根据行号，循环写到4个ram中。第一行写到ram0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_fval) begin
			buffer_wr_en	<= 4'b0000;
		end
		else begin
			case(lval_cnt)
				2'b00	: buffer_wr_en	<= {3'b000,i_lval};
				2'b01	: buffer_wr_en	<= {2'b00,i_lval,1'b0};
				2'b10	: buffer_wr_en	<= {1'b0,i_lval,2'b00};
				2'b11	: buffer_wr_en	<= {i_lval,3'b000};
				default	: buffer_wr_en	<= 4'b0000;
			endcase
		end
	end
	assign	ov_buffer_wr_en	= buffer_wr_en;

	//  -------------------------------------------------------------------------------------
	//	buffer写地址
	//	1.每行结束，写地址归零
	//	2.写地址 根据 lval_dly自增，因为要滞后写使能1拍
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!lval_dly) begin
			buffer_wr_addr	<= 12'h0;
		end
		else begin
			buffer_wr_addr	<= buffer_wr_addr + 1'b1;
		end
	end
	assign	ov_buffer_wr_addr	= buffer_wr_addr;

	//  -------------------------------------------------------------------------------------
	//	buffer写数据
	//	1.i_lval打了一拍作为写使能，数据也要相应的打一拍
	//	2.没有用到的数据位，高位补零
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		buffer_wr_din_dly0	<= iv_pix_data;
	end
	assign	ov_buffer_wr_din	= {{(10-SENSOR_DAT_WIDTH){1'b0}},buffer_wr_din_dly0};

	//	===============================================================================================
	//	ref ***输出当前写入行***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	经过延迟之后的buffer写数据，目的是与rd模块读出的数据对齐
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		buffer_wr_din_dly1	<= buffer_wr_din_dly0;
		buffer_wr_din_dly2	<= buffer_wr_din_dly1;
	end
	assign	ov_lower_line	= buffer_wr_din_dly2;



endmodule
