//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : sync_buffer
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/4 16:54:58	:|  初始版本
//  -- 邢海涛       :| 2015/10/20 16:59:27	:|  独立出 buffer 功能，去掉sensor接口部分和寄存器控制部分
//	-- 周金剑		：
//	-- 张少强		：2016/8/1 14:24:51		：| 1.修改读使能信号，防止读空 2.补充注释
//	-- 张少强		：2016/8/2 9:58:38		：| 1.源程序中，有根据i_fval高低决定输入fifo的数据是否有效的选择机制，以此来减少毛刺，但本设计中i_fval作为fifo写使能的标志位，所以这个选择机制可以去掉。
//											  | 2.补充错误指示标志wrong_status
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 完成2部分内容
//              1)  : Sensor数据 跨时钟域同步
//						在两个同频异相的时钟之间做同步处理
//              2)  : Sensor 行场数据整型
//						Sensor输入的行场信号是边沿对齐的，不利于数据通道处理，整型之后，fval会包住lval，前后各有10个时钟
//              3)  :
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module sync_buffer # (
	parameter					SENSOR_DAT_WIDTH	= 12	,	//sensor 数据宽度
	parameter					PHY_CH_NUM			= 4		,	//每路HiSPi PHY数据通道的数量
	parameter					PHY_NUM				= 2			//HiSPi PHY的数量
	)
	(
	//Sensor时钟域
	input	[PHY_NUM-1:0]								clk_recover			,	//sensor恢复时钟
	input	[PHY_NUM-1:0]								reset_recover		,	//sensor恢复时钟的复位信号
	input	[PHY_NUM-1:0]								iv_clk_en			,	//时钟使能信号
	input	[PHY_NUM-1:0]								iv_fval				,	//sensor输出的场有效信号，与clk_sensor_pix上升沿对齐，iv_fval上升沿与iv_lval下降沿对齐，iv_fval下降沿沿与iv_lval下降沿对齐
	input	[PHY_NUM-1:0]								iv_lval				,	//sensor输出的行有效信号，与clk_sensor_pix上升沿对齐，iv_fval上升沿与iv_lval下降沿对齐，iv_fval下降沿沿与iv_lval下降沿对齐，iv_fval无效期间也有可能输出
	input	[SENSOR_DAT_WIDTH*PHY_NUM*PHY_CH_NUM-1:0]	iv_pix_data			,	//sensor输出的图像数据，与clk_sensor_pix上升沿对齐
	//控制信号
	input												i_fifo_reset		,	//内部fifo复位信号
	//本地时钟域
	input												clk_pix				,	//本地时钟域
	output												o_fval				,	//场有效，展宽o_fval，o_fval的前后沿包住l_fval约20几个时钟
	output												o_lval				,	//行有效
	output	[SENSOR_DAT_WIDTH*PHY_NUM*PHY_CH_NUM-1:0]	ov_pix_data			,	//图像数据
	output												o_sync_buffer_error			//引出出错检测脚，当不同的phy解析出的lval不同时，引脚置1
	);


	//	-------------------------------------------------------------------------------------
	//	本地参数
	//	-------------------------------------------------------------------------------------
	localparam			CHANNEL_NUM					=	PHY_NUM*PHY_CH_NUM			;
	localparam			FVAL_EXTEND_VALUE			= 	50							;	//FVAL总共要展宽的宽度，以像素时钟为单位
	localparam			EXT_WIDTH					= 	log2(FVAL_EXTEND_VALUE-1+1)	;	//fval展宽计数器总共需要的位宽

	//	-------------------------------------------------------------------------------------
	//	取对数，上取整
	//	-------------------------------------------------------------------------------------
	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction


	wire	[SENSOR_DAT_WIDTH*PHY_CH_NUM-1:0]		pix_data_wr		[PHY_NUM-1:0]			;//待写入fifo的像素数据
	wire	[PHY_NUM-1:0]							lval_wr									;//待写入fifo的行信号

	reg		[2:0]									fval_shift		= 3'b0					;//帧信号打拍寄存
	wire											fval_rise								;//帧信号上升沿标志位
	wire											fval_fall								;//帧信号下降沿标志位
	reg												fval_reg		= 1'b0					;//展宽后的帧信号
	reg		[EXT_WIDTH-1:0]							fval_ext_cnt	= (FVAL_EXTEND_VALUE-1)	;//帧信号展宽计数器
	wire											fval_extend								;//帧信号展宽部分
	wire	[PHY_NUM-1:0]							reset_fifo								;//fifo复位信号
	wire	[PHY_NUM-1:0]							fifo_wr_en								;//fifo写使能
	wire	[SENSOR_DAT_WIDTH*PHY_CH_NUM:0]			fifo_din		[PHY_NUM-1:0]			;//fifo输入数据，这是像素数据和lval合并后的信号
	reg												fifo_rd_en		= 1'b0					;//fifo读信号
	wire											w_fifo_rd_en							;//w_fifo_rd_en比fifo_rd_en提前一个周期拉低，防止读空
	reg		[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		pix_data_reg	= 'b0					;//将两路phy 总共8路数据合并后的信号{pix0 pix1……pix7}
	reg												lval_reg		= 1'b0					;//从fifo读出后的行信号
	wire	[PHY_NUM-1:0]							fifo_full								;//fifo满标志位，由Fifo内部生成，在读操作时，清0可能会有滞后
	wire	[PHY_NUM-1:0]							fifo_prog_empty							;//fifo编程空标志位，写操作时，清0可能会有滞后
	wire	[PHY_NUM-1:0]							fifo_empty								;//fifo空标志位，写操作时，清0可能会有滞后
	wire	[SENSOR_DAT_WIDTH*PHY_CH_NUM:0]			fifo_dout		[PHY_NUM-1:0]			;//fifo输出数据，这是像素数据和lval合并后的信号
	wire	[PHY_NUM-1:0]							lval_mul								;//fifo输出的每个Phy的lval
	reg												wrong_status	= 1'b0					;//错误指示标志

	//  ===============================================================================================
	//	ref ***fval 逻辑***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	fval 取边沿
	//	1.异步时钟域传输，需要打三拍
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		fval_shift	<= {fval_shift[1:0],iv_fval[0]};
	end
	assign	fval_rise	= (fval_shift[2:1] == 2'b01) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_shift[2:1] == 2'b10) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	fval_reg
	//	1.展宽fval的逻辑，当fval下降沿来临时，展宽50个时钟周期
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(fval_rise) begin
			fval_reg	<= 1'b1;
		end
		else if(!fval_shift[2]) begin
			fval_reg	<= fval_extend;
		end
	end
	assign	o_fval	= fval_reg;

	//  -------------------------------------------------------------------------------------
	//	fval_ext_cnt
	//	fval下降沿复位；其余时刻计数到FVAL_EXTEND_VALUE
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(fval_fall==1'b1) begin
			fval_ext_cnt	<= 'b0;
		end
		else begin
			if(fval_ext_cnt==(FVAL_EXTEND_VALUE-1)) begin
				fval_ext_cnt	<= fval_ext_cnt;
			end
			else begin
				fval_ext_cnt	<= fval_ext_cnt + 1'b1;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	当计数器小于最大值时， fval_extend 输出1
	//	-------------------------------------------------------------------------------------
	assign	fval_extend	= (fval_ext_cnt<(FVAL_EXTEND_VALUE-1)) ? 1'b1 : 1'b0;

	//  ===============================================================================================
	//	ref ***FIFO 操作***
	//  ===============================================================================================
	genvar	i;
	generate
		for(i=0;i<PHY_NUM;i=i+1)begin
			//  -------------------------------------------------------------------------------------
			//	-ref FIFO 复位
			//	1.当恢复时钟复位或者强制复位的时候，复位内部fifo
			//  -------------------------------------------------------------------------------------
			assign	reset_fifo[i]	= reset_recover[i] | i_fifo_reset;
			//  -------------------------------------------------------------------------------------
			//	-ref FIFO 写使能
			//	写需要具备三个条件
			//	1.fifo非满 2.输入i_fval有效 3.解串时钟有效
			//  -------------------------------------------------------------------------------------
			assign	fifo_wr_en[i]	= !fifo_full[i] & iv_fval[i] & iv_clk_en[i];
			//	-------------------------------------------------------------------------------------
			//	-ref FIFO 数据输入
			//	1.FIFO 的数据宽度是49bit
			//	2.将lval放在bit0，剩余的bit放数据高位
			//	-------------------------------------------------------------------------------------
			assign	pix_data_wr[i]	= iv_pix_data[SENSOR_DAT_WIDTH*PHY_CH_NUM*(i+1)-1:SENSOR_DAT_WIDTH*PHY_CH_NUM*i];
			assign	lval_wr[i]		= iv_lval[i] ;
			assign	fifo_din[i]		= {pix_data_wr[i],lval_wr[i]};
			//  -------------------------------------------------------------------------------------
			//	例化FIFO
			//	1.BRAM表示Block Ram
			//	2.fifo宽度是49bit，深度是64
			//	3.FIFO类型为first-word fall-through
			//	4.fifo的写时钟是 clk_recover ，fifo的读时钟是 clk_pix ，这两个时钟同源异相
			//  -------------------------------------------------------------------------------------
			sync_buffer_fifo_bram_w49d64_pe20 sync_buffer_fifo_bram_w49d64_pe20_inst (
			.rst			(reset_fifo[i]				),
			.wr_clk			(clk_recover[i]				),
			.wr_en			(fifo_wr_en[i]				),
			.full			(fifo_full[i]				),
			.din			(fifo_din[i]				),
			.rd_clk			(clk_pix					),
			.rd_en			(w_fifo_rd_en				),
			.empty			(fifo_empty[i]				),
			.prog_empty		(fifo_prog_empty[i]			),
			.dout			(fifo_dout[i]				)
			);
		end
	endgenerate
			//  -------------------------------------------------------------------------------------
			//	FIFO 读
			//	时序如下
			//	pix_clk			:__|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|
			//	fifo_empty		:------|_________________________|----
			//	fifo_prog_empty	:--------------|_________|-----------
			//	fifo_rd_en		:__________________|-----------------|________
			//	w_fifo_rd_en	:__________________|-------------|____________
			//	o_lval			:______________________|-------------|________
			//	ov_pix_data		:______________________|vvvvvvvvvvvvv|________
			//  -------------------------------------------------------------------------------------
			//	-ref fifo读使能
			//	1.当fifo积累到非编程空时开始读（因为读写两端数据量跨时钟域传输延迟，所以此时真实的数据量已经大于非编程空的设定值，这里是20）
			//	2.当FIFO空时，结束读（因为读写时钟速度相同，所以fifo出现空，说明写操作已经停止几个周期了，此时fifo空标志位指示准确，fifo里已经没有数据了）
			//	3.读标志位采用always赋值，fifo_rd_en会比empty信号延后一个周期，会出现读空问题，需要将fifo_rd_en与非空信号线与
			//  -------------------------------------------------------------------------------------
			always @ (posedge clk_pix) begin
				//每个phy都积累到足够多的数开始读
				if(fifo_prog_empty == {PHY_NUM{1'b0}}) begin
					fifo_rd_en	<= 1'b1;
				end
				//所有phy都空时才结束读
				else if(fifo_empty == {PHY_NUM{1'b1}})begin
					fifo_rd_en	<= 1'b0;
				end
			end
			assign	w_fifo_rd_en = fifo_rd_en && (fifo_empty != {PHY_NUM{1'b1}});//此处将fifo_rd_en和"至少一个非空"信号相与，使其提前一个周期拉低，防止读空操作

			//  -------------------------------------------------------------------------------------
			//	-ref 行信号输出
			//	1.从fifo读出来的lval有效
			//	2.不从fifo读出来的屏蔽为0
			//	3.取phy0的lval输出
			//  -------------------------------------------------------------------------------------
			always @ (posedge clk_pix) begin
				if(w_fifo_rd_en==1'b1) begin
					lval_reg	<= lval_mul[0];//即phy0的lval
				end
				else begin
					lval_reg	<= 1'b0;
				end
			end
			assign	o_lval	= lval_reg ;
			//  -------------------------------------------------------------------------------------
			//	-ref 出错检测标志
			//	1.如果某个时刻两个通道输出的lval不一样，则指示出错
			//  -------------------------------------------------------------------------------------
			always @ (posedge clk_pix) begin
				if(w_fifo_rd_en==1'b1) begin
					if(lval_mul == {PHY_NUM{1'b0}}) begin
						wrong_status <= wrong_status;
					end
					else if(lval_mul == {PHY_NUM{1'b1}}) begin
						wrong_status <= wrong_status;
					end
					else begin
						wrong_status <= 1'b1;
					end
				end
			end
			assign o_sync_buffer_error = wrong_status;
	genvar j;
	generate
		for(j=0;j<PHY_NUM;j=j+1) begin
		//  -------------------------------------------------------------------------------------
		//	-ref 数据输出
		//	1.从fifo读出来的数据有效
		//	2.不从fifo读出来的屏蔽为0
		//	3.两路phy做合并处理
		//  -------------------------------------------------------------------------------------
			always @ (posedge clk_pix) begin
				if(w_fifo_rd_en==1'b1) begin
					pix_data_reg[(j+1)*SENSOR_DAT_WIDTH*PHY_CH_NUM-1:j*(SENSOR_DAT_WIDTH*PHY_CH_NUM)]	<= fifo_dout[j][SENSOR_DAT_WIDTH*PHY_CH_NUM:1];
				end
				else begin
					pix_data_reg[(j+1)*SENSOR_DAT_WIDTH*PHY_CH_NUM-1:j*(SENSOR_DAT_WIDTH*PHY_CH_NUM)]	<= {(SENSOR_DAT_WIDTH*PHY_CH_NUM){1'b0}};
				end
			end
			assign	ov_pix_data	= pix_data_reg;
			assign lval_mul[j]	= fifo_dout[j][0];
		end
	endgenerate

endmodule