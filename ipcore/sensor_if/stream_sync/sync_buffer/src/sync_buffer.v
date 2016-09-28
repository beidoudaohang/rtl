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
	//控制信号
	input											i_enable			,	//使能信号，0-fifo不使能，1-fifo使能，已经经过了完整帧控制
	//本地时钟域
	input											clk_pix				,	//本地时钟域
	output											o_fval				,	//场有效，展宽o_fval，o_fval的前后沿包住l_fval约10个时钟
	output											o_lval				,	//行有效
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data				//图像数据
	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	本地参数
	//	-------------------------------------------------------------------------------------
	//	localparam			FIFO_BUFFER_TYPE			= "BRAM";	//"BRAM" or "DRAM"，block ram或者分布式ram
	localparam			FIFO_BUFFER_TYPE			= "DRAM";	//"BRAM" or "DRAM"，block ram或者分布式ram
	localparam			FVAL_EXTEND_VALUE			= 20	;	//FVAL总共要展宽的宽度，以像素时钟为单位
	localparam			EXT_WIDTH					= log2(FVAL_EXTEND_VALUE-1)	;	//fval展宽计数器总共需要的位宽

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


	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		pix_data_wr	;
	wire											lval_wr		;

	reg		[2:0]									fval_shift		= 3'b0;
	wire											fval_rise		;
	wire											fval_fall		;
	reg												fval_reg		= 1'b0;
	reg		[EXT_WIDTH-1:0]							fval_ext_cnt	= (FVAL_EXTEND_VALUE-1);
	wire											fval_extend		;
	wire											reset_fifo		;
	wire											fifo_wr_en		;
	wire	[71:0]									fifo_din		;
	reg												fifo_rd_en		= 1'b0;
	reg		[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		pix_data_reg	= 'b0;
	reg												lval_reg		= 1'b0;
	wire											fifo_full		;
	wire											fifo_prog_empty	;
	wire	[71:0]									fifo_dout		;

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
		if(i_enable) begin
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
	//	fval_ext_cnt
	//	--不使能的时候，计数器是最大值，计数器初始化之后，也是最大值
	//	--fval下降沿之后，计数器清零
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(i_enable==1'b0) begin
			fval_ext_cnt<=FVAL_EXTEND_VALUE-1;
		end
		else begin
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
	end

	//	-------------------------------------------------------------------------------------
	//	当计数器小于最大值时， fval_extend 输出1
	//	-------------------------------------------------------------------------------------
	assign	fval_extend	= (fval_ext_cnt<(FVAL_EXTEND_VALUE-1)) ? 1'b1 : 1'b0;

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
	assign	reset_fifo	= !i_enable;

	//  -------------------------------------------------------------------------------------
	//	FIFO 写
	//	1.当不满的时候的时候，就可以一直写。
	//	2.fifo复位的时候，fifo是满的状态，当fifo脱离复位的时候，满信号拉低
	//  -------------------------------------------------------------------------------------
	assign	fifo_wr_en	= !fifo_full & i_clk_en;

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
		if(i_enable) begin
			if(fifo_prog_empty == 1'b0) begin
				fifo_rd_en	<= 1'b1;
			end
		end
		else begin
			fifo_rd_en	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	FIFO 数据输入
	//	1.FIFO 的数据宽度是18bit
	//	2.将lval放在bit0，剩余的bit放数据
	//  -------------------------------------------------------------------------------------
	assign	fifo_din	= {{(72-SENSOR_DAT_WIDTH*CHANNEL_NUM-1){1'b0}},pix_data_wr[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0],lval_wr};

	//  -------------------------------------------------------------------------------------
	//	行信号输出
	//	1.在fval有效期间，lval是从fifo中读出来的数
	//	2.在fval无效期间，lval屏蔽为0
	//	3.fval_reg信号受使能信号(i_enable)控制，因此无需再添加enable的逻辑
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

	//  -------------------------------------------------------------------------------------
	//	FIFO 数据输出
	//	1.在fval有效期间，像素数据是从fifo中读出来的数
	//	2.在fval无效期间，像素数据屏蔽为0
	//	3.fval_reg信号受使能信号(i_enable)控制，因此无需再添加enable的逻辑
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(fval_reg==1'b1 && fifo_rd_en==1'b1) begin
			pix_data_reg[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	<= fifo_dout[SENSOR_DAT_WIDTH*CHANNEL_NUM:1];
		end
		else begin
			pix_data_reg[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	<= {(SENSOR_DAT_WIDTH*CHANNEL_NUM){1'b0}};
		end
	end

	generate
		//  -------------------------------------------------------------------------------------
		//	例化FIFO
		//	1.BRAM表示Block Ram，DRAM表示Distributed Ram
		//	2.fifo宽度是18bit，深度是16，BRAM DRAM 都是如此。没有用到18bit的宽度，布局布线阶段会自动优化，不会浪费资源。
		//	3.fifo的写时钟是 clk_sensor_pix ，fifo的读时钟是 clk_pix ，这两个时钟同源异相
		//  -------------------------------------------------------------------------------------
		if(FIFO_BUFFER_TYPE=="BRAM") begin
			sync_buffer_fifo_bram_w72d32 sync_buffer_fifo_bram_w72d32_inst (
			.rst			(reset_fifo					),
			.wr_clk			(clk_sensor_pix				),
			.wr_en			(fifo_wr_en					),
			.full			(fifo_full					),
			.din			(fifo_din					),
			.rd_clk			(clk_pix					),
			.rd_en			(fifo_rd_en					),
			.empty			(							),
			.prog_empty		(fifo_prog_empty			),
			.dout			(fifo_dout					)
			);
		end
		else if(FIFO_BUFFER_TYPE=="DRAM") begin
			sync_buffer_fifo_dram_w72d32 sync_buffer_fifo_dram_w72d32_inst (
			.rst			(reset_fifo					),
			.wr_clk			(clk_sensor_pix				),
			.wr_en			(fifo_wr_en					),
			.full			(fifo_full					),
			.din			(fifo_din					),
			.rd_clk			(clk_pix					),
			.rd_en			(fifo_rd_en					),
			.empty			(							),
			.prog_empty		(fifo_prog_empty			),
			.dout			(fifo_dout					)
			);
		end
	endgenerate

	assign	ov_pix_data	= pix_data_reg;


endmodule