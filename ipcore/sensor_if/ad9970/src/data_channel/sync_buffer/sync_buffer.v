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
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : 完成3部分内容
//              1)  : Sensor数据 跨时钟域同步
//						在两个同频异相的时钟之间做同步处理
//              2)  : Sensor 行场数据整型
//						Sensor输入的行场信号是边沿对齐的，不利于数据通道处理，整型之后，fval会包住lval，前后各有10个时钟
//              3)  : 寄存器生效时机
//						数据通道共用的寄存器，需要在这个模块中做生效时机，在输入的fval上升沿时，采样寄存器
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module sync_buffer # (
	parameter					SENSOR_DAT_WIDTH	= 10	,	//sensor 数据宽度
	parameter					CHANNEL_NUM			= 4		,	//串行数据通道数量
	parameter					REG_WD				= 32		//寄存器位宽
	)
	(
	//Sensor时钟域
	input											clk_sensor_pix		,	//sensor输入的像素时钟,72Mhz,与本地72Mhz同频但不同相，可认为完全异步的两个信号，如果sensor复位，sensor时钟可能停止输出，而内部时钟不停止
	input											i_clk_en			,
	input											i_fval				,	//sensor输出的场有效信号，与clk_sensor_pix上升沿对齐，i_fval上升沿与i_lval下降沿对齐，i_fval下降沿沿与i_lval下降沿对齐
	input											i_lval				,	//sensor输出的行有效信号，与clk_sensor_pix上升沿对齐，i_fval上升沿与i_lval下降沿对齐，i_fval下降沿沿与i_lval下降沿对齐，i_fval无效期间也有可能输出
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data			,	//sensor输出的图像数据，与clk_sensor_pix上升沿对齐，电路连接10根数据线
	//寄存器数据
	input											i_acquisition_start	,	//开采信号，0-停采，1-开采
	input											i_stream_enable		,	//流使能信号
	input											i_encrypt_state		,	//数据通路输出，dna 时钟域，加密状态。加密不通过，不输出图像
	input	[REG_WD-1:0]							iv_pixel_format		,	//像素格式寄存器
	input	[2:0]									iv_test_image_sel	,	//测试图选择寄存器,000:真实图,001:测试图像1灰度值帧递增,110:测试图像2静止的斜条纹,010:测试图像3滚动的斜条纹
	output											o_full_frame_state	,	//完整帧状态,该寄存器用来保证停采时输出完整帧,0:停采时，已经传输完一帧数据,1:停采时，还在传输一帧数据
	output	[REG_WD-1:0]							ov_pixel_format		,	//在sync buffer中做生效时机控制
	output	[2:0]									ov_test_image_sel	,	//在sync buffer中做生效时机控制
	//本地时钟域
	input											clk_pix				,	//本地时钟域
	output											o_fval				,	//场有效，展宽o_fval，o_fval的前后沿包住l_fval约10个时钟
	output											o_lval				,	//行有效
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data				//图像数据
	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	本地参数
	//	1.Sensor接收引脚默认不使用idelay调节，因为外部电路延时已经做得很好
	//	2.Sensor接收引脚idelay 数值默认为0
	//	3.跨时钟域转换的FIFO，可以选择BRAM或者DRAM。宽度18，深度16。
	//	-------------------------------------------------------------------------------------
	localparam			FIFO_BUFFER_TYPE			= "BRAM";	//"BRAM" or "DRAM"，block ram或者分布式ram

	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		pix_data_wr	;
	wire											lval_wr		;

	reg		[2:0]									fval_shift		= 3'b0;
	wire											fval_rise		;
	wire											fval_fall		;
	reg												fval_reg		= 1'b0;
	reg		[5:0]									delay_60_cnt	= 6'd59;
	wire											fval_extend		;
	reg												enable			= 1'b0;
	reg												encrypt_state_dly0	= 1'b0;
	reg												encrypt_state_dly1	= 1'b0;
	wire											reset_fifo		;
	wire											fifo_wr_en		;
	wire	[17:0]									fifo_din		[CHANNEL_NUM-1:0];
	reg												fifo_rd_en		= 1'b0;
	reg		[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		pix_data_reg	= 8'b0;
	reg												lval_reg		= 1'b0;
	wire	[CHANNEL_NUM-1:0]						fifo_full		;
	wire	[CHANNEL_NUM-1:0]						fifo_prog_empty	;
	wire	[17:0]									fifo_dout		[CHANNEL_NUM-1:0];

	reg												full_frame_state	= 1'b0;
	reg		[REG_WD-1:0]							pixel_format_reg	= {REG_WD{1'b0}};
	reg		[2:0]									test_image_sel_reg	= 3'b000;


	//	ref ARCHITECTURE


	//  ===============================================================================================
	//	ref ***fval 逻辑***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	fval 取边沿
	//	1.异步时钟域传输，需要打三拍
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		fval_shift	<= {fval_shift[1:0],i_fval};
	end
	assign	fval_rise	= (fval_shift[2]==1'b0 && fval_shift[1]==1'b1) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_shift[2]==1'b1 && fval_shift[1]==1'b0) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	fval_reg
	//	1.展宽fval的逻辑，当fval下降沿来临时，展宽20个时钟周期
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(enable) begin
			if(fval_rise) begin
				fval_reg	<= 1'b1;
			end
			else if(!fval_shift[2]) begin
				fval_reg	<= fval_extend;
			end
		end
		else begin
			fval_reg	<= 1'b0;
		end
	end
	assign	o_fval	= fval_reg;

	//  -------------------------------------------------------------------------------------
	//	delay_60_cnt
	//	fval下降沿之后，延时20个时钟周期的计数器
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(enable==1'b0) begin
			delay_60_cnt<=6'd59;
		end
		else begin
			if(fval_fall==1'b1) begin
				delay_60_cnt	<= 6'b0;
			end
			else begin
				if(delay_60_cnt==6'd59) begin
					delay_60_cnt	<= delay_60_cnt;
				end
				else begin
					delay_60_cnt	<= delay_60_cnt + 1'b1;
				end
			end
		end
	end
	assign	fval_extend	= (delay_60_cnt<6'd59) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	enable 完整帧使能控制信号
	//	1.在o_fval与fval_shift[1]都是低电平时，更新enable寄存器，enable=两个开采信号与加密状态的与结果
	//	2.在o_fval与fval_shift[1]至少有1个高电平时，保持enable寄存器，保证完整帧
	//	3.fval_shift[1]=1 o_fval=0时，下一个时钟周期，o_fval=1，此时不能再做完整帧判断，因为下一个周期肯定会输出fval
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(fval_shift[1]==1'b0 && fval_reg==1'b0) begin
			enable	<= i_stream_enable & i_acquisition_start & encrypt_state_dly1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	加密状态同步
	//	1.i_encrypt_state是 osc bufg时钟域的信号，两次采样通过到pix时钟域
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		encrypt_state_dly0	<= i_encrypt_state;
		encrypt_state_dly1	<= encrypt_state_dly0;
	end

	//  ===============================================================================================
	//	ref ***FIFO 操作***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref FIFO 读、写、复位、数据
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	FIFO 复位
	//	1.当使能无效时，复位fifo
	//  -------------------------------------------------------------------------------------
	assign	reset_fifo	= !enable;

	//  -------------------------------------------------------------------------------------
	//	FIFO 写
	//	1.当不满的时候的时候，就可以一直写。
	//	2.fifo复位的时候，fifo是满的状态，当fifo脱离复位的时候，满信号拉低
	//  -------------------------------------------------------------------------------------
	assign	fifo_wr_en	= !fifo_full[0] & i_clk_en;

	//	-------------------------------------------------------------------------------------
	//	写入fifo数据需要与输入场有效做判断
	//	1.需要添加fval为高的条件，如果在fval为低时，lval有毛刺，且毛刺很靠近fval，就会造成多输出数据了
	//	-------------------------------------------------------------------------------------
	assign	pix_data_wr	= (i_fval==1'b1) ? iv_pix_data : {SENSOR_DAT_WIDTH*CHANNEL_NUM{1'b0}};
	assign	lval_wr		= (i_fval==1'b1) ? i_lval : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	FIFO 读
	//	1.当使能有效时，半空信号无效之后,就可以一直读
	//	2.当使能无效时，读信号屏蔽为0
	//	3.半空信号之后才开始读，是为了保证固定的延时，是的fval和lval之间的距离保持在10个时钟周期左右
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(enable) begin
			if(fifo_prog_empty[0] == 1'b0) begin
				fifo_rd_en	<= 1'b1;
			end
		end
		else begin
			fifo_rd_en	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	行信号输出
	//	1.在fval有效期间，lval是从fifo中读出来的数
	//	2.在fval无效期间，lval屏蔽为0
	//	3.fval_reg信号受使能信号(enable)控制，因此无需再添加enable的逻辑
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(fval_reg==1'b1 && fifo_rd_en==1'b1) begin
			lval_reg	<= fifo_dout[0];
		end
		else begin
			lval_reg	<= 1'b0;
		end
	end
	assign	o_lval	= lval_reg;


	genvar i;
	generate

		for(i=0;i<CHANNEL_NUM;i=i+1) begin

			//  -------------------------------------------------------------------------------------
			//	FIFO 数据输入
			//	1.FIFO 的数据宽度是18bit
			//	2.将lval放在bit0，剩余的bit放数据
			//  -------------------------------------------------------------------------------------
			assign	fifo_din[i]	= {{(18-SENSOR_DAT_WIDTH-1){1'b0}},pix_data_wr[SENSOR_DAT_WIDTH*(i+1)-1:SENSOR_DAT_WIDTH*i],lval_wr};

			//  -------------------------------------------------------------------------------------
			//	FIFO 数据输出
			//	1.在fval有效期间，像素数据是从fifo中读出来的数
			//	2.在fval无效期间，像素数据屏蔽为0
			//	3.fval_reg信号受使能信号(enable)控制，因此无需再添加enable的逻辑
			//  -------------------------------------------------------------------------------------
			always @ (posedge clk_pix) begin
				if(fval_reg==1'b1 && fifo_rd_en==1'b1) begin
					pix_data_reg[SENSOR_DAT_WIDTH*(i+1)-1:SENSOR_DAT_WIDTH*i]	<= fifo_dout[i][SENSOR_DAT_WIDTH:1];
				end
				else begin
					pix_data_reg[SENSOR_DAT_WIDTH*(i+1)-1:SENSOR_DAT_WIDTH*i]	<= {SENSOR_DAT_WIDTH{1'b0}};
				end
			end

			//  -------------------------------------------------------------------------------------
			//	例化FIFO
			//	1.BRAM表示Block Ram，DRAM表示Distributed Ram
			//	2.fifo宽度是18bit，深度是16，BRAM DRAM 都是如此。没有用到18bit的宽度，布局布线阶段会自动优化，不会浪费资源。
			//	3.fifo的写时钟是 clk_sensor_pix ，fifo的读时钟是 clk_pix ，这两个时钟同源异相
			//  -------------------------------------------------------------------------------------
			if(FIFO_BUFFER_TYPE=="BRAM") begin
				sync_buffer_fifo_bram_w18d32 sync_buffer_fifo_bram_w18d32_inst (
				.rst			(reset_fifo					),
				.wr_clk			(clk_sensor_pix				),
				.wr_en			(fifo_wr_en					),
				.full			(fifo_full[i]				),
				.din			(fifo_din[i]				),
				.rd_clk			(clk_pix					),
				.rd_en			(fifo_rd_en					),
				.empty			(							),
				.prog_empty		(fifo_prog_empty[i]			),
				.dout			(fifo_dout[i]				)
				);
			end
			else if(FIFO_BUFFER_TYPE=="DRAM") begin
				sync_buffer_fifo_dram_w18d32 sync_buffer_fifo_dram_w18d32_inst (
				.rst			(reset_fifo					),
				.wr_clk			(clk_sensor_pix				),
				.wr_en			(fifo_wr_en					),
				.full			(fifo_full[i]				),
				.din			(fifo_din[i]				),
				.rd_clk			(clk_pix					),
				.rd_en			(fifo_rd_en					),
				.empty			(							),
				.prog_empty		(fifo_prog_empty[i]			),
				.dout			(fifo_dout[i]				)
				);
			end
		end
	endgenerate

	assign	ov_pix_data	= pix_data_reg;

	//  ===============================================================================================
	//	ref ***标志、寄存器操作***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref 完整帧标志
	//	1.当 i_stream_enable=0时，清零完整帧标志
	//	2.当 o_fval=0时，清零完整帧标志
	//	3.当 o_fval=1且i_acquisition_start=0时，清零完整帧置位
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(!i_stream_enable) begin
			full_frame_state	<= 1'b0;
		end
		else if(!fval_reg) begin
			full_frame_state	<= 1'b0;
		end
		else begin
			if(fval_reg==1'b1 && i_acquisition_start==1'b0) begin
				full_frame_state	<= 1'b1;
			end
		end
	end
	assign	o_full_frame_state	= full_frame_state;

	//  -------------------------------------------------------------------------------------
	//	-- ref 寄存器生效时机控制
	//	1.当fval_rise=1，即一帧来临时，更新寄存器
	//	2.其他时刻，保持像素格式寄存器
	//	3.这些寄存器都是在数据通道中不止一个模块使用，因此要在数据通道的最前端控制
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	像素格式寄存器
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(fval_rise) begin
			pixel_format_reg	<= iv_pixel_format;
		end
	end
	assign	ov_pixel_format		= pixel_format_reg;

	//  -------------------------------------------------------------------------------------
	//	测试图选择寄存器
	//	如果写入的是非法值，则保留上一次的结果
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(fval_rise) begin
			if(iv_test_image_sel==3'b000 || iv_test_image_sel==3'b001 || iv_test_image_sel==3'b110 || iv_test_image_sel==3'b010) begin
				test_image_sel_reg	<= iv_test_image_sel;
			end
		end
	end
	assign	ov_test_image_sel		= test_image_sel_reg;


endmodule