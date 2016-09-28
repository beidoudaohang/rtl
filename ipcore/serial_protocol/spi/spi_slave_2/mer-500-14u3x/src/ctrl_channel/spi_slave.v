//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : spi_slave
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/2 17:55:38	:|  初始版本
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

module spi_slave # (
	parameter			SPI_CMD_LENGTH		= 8			,	//spi 命令的长度
	parameter			SPI_CMD_WR			= 8'h80		,	//spi 写命令
	parameter			SPI_CMD_RD			= 8'h81		,	//spi 读命令
	parameter			SPI_ADDR_LENGTH		= 16		,	//spi 地址的长度
	parameter			SPI_DATA_LENGTH		= 16			//spi 数据的长度
	)
	(
	input							clk_spi_sample		,	//spi 采样时钟
	//spi时钟域
	input							i_spi_clk			,	//spi时钟，上升沿采样， 时钟的高电平宽度至少是 主时钟周期 的3倍
	input							i_spi_cs_n			,	//spi片选，低有效
	input							i_spi_mosi			,	//spi输入数据
	output							o_spi_miso_data		,	//spi输出数据
	output							o_spi_miso_data_en	,	//spi miso有效信号，0-spi——mosi 三态 1-输出数据
	//解析后的数据，主时钟域
	output							o_wr_en				,	//写使能
	output							o_rd_en				,	//读使能
	output							o_cmd_is_rd			,	//读命令到来
	output	[SPI_ADDR_LENGTH-1:0]	ov_addr				,	//读写地址，共用
	output	[SPI_DATA_LENGTH-1:0]	ov_wr_data			,	//写数据
	input							i_pix_sel			,	//pix时钟域被选择
	input	[SPI_DATA_LENGTH-1:0]	iv_pix_rd_data		,	//pix时钟域的读数据
	input							i_frame_buf_sel		,	//frame buf时钟域被选择
	input	[SPI_DATA_LENGTH-1:0]	iv_frame_buf_rd_data,	//frame buf时钟域的读数据
	input							i_gpif_sel			,	//gpif时钟域被选择
	input	[SPI_DATA_LENGTH-1:0]	iv_gpif_rd_data		,	//gpif时钟域的读数据
	input							i_osc_bufg_sel		,	//40MHz时钟域被选择
	input	[SPI_DATA_LENGTH-1:0]	iv_osc_bufg_rd_data	,	//40MHz时钟域的读数据
	input							i_fix_sel			,	//固定电平被选择
	input	[SPI_DATA_LENGTH-1:0]	iv_fix_rd_data			//固定电平的读数据
	);

	//	ref signals

	//从 cmd length、 addr length、 data length中选一个最大的出来，作为shifter的长度
	localparam	SPI_SHFITER_LENGTH	= (SPI_CMD_LENGTH>=SPI_ADDR_LENGTH && SPI_CMD_LENGTH>=SPI_DATA_LENGTH) ? SPI_CMD_LENGTH :
	((SPI_ADDR_LENGTH>=SPI_CMD_LENGTH && SPI_ADDR_LENGTH>=SPI_DATA_LENGTH) ? SPI_ADDR_LENGTH :
	SPI_DATA_LENGTH);

	//将bit位宽换算为byte位宽
	localparam	SPI_CMD_BYTE_LENGTH		= SPI_CMD_LENGTH/8;
	localparam	SPI_ADDR_BYTE_LENGTH	= SPI_ADDR_LENGTH/8;
	localparam	SPI_DATA_BYTE_LENGTH	= SPI_DATA_LENGTH/8;
	localparam	ONCE_CNT_WIDTH			= log2(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH+SPI_DATA_BYTE_LENGTH+1);
	localparam	CONTINUE_CNT_WIDTH		= log2(SPI_DATA_BYTE_LENGTH);

	//  ===============================================================================================
	//	ref ***函数***
	//  ===============================================================================================
	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction


	wire									spi_clk_inv			;
	reg		[2:0]							sck_rising_cnt		= 3'b0;
	reg		[ONCE_CNT_WIDTH-1:0]			once_byte_cnt		= {ONCE_CNT_WIDTH{1'b0}};
	reg		[CONTINUE_CNT_WIDTH-1:0]		continue_byte_cnt	= {CONTINUE_CNT_WIDTH{1'b0}};
	reg		[SPI_SHFITER_LENGTH-1:0]		spi_data_shifter	= {SPI_SHFITER_LENGTH{1'b0}};
	reg										cmd_wr				= 1'b0;
	reg										cmd_rd				= 1'b0;
	reg		[SPI_ADDR_LENGTH-1:0]			addr_reg			= {SPI_ADDR_LENGTH{1'b0}};
	reg		[SPI_DATA_LENGTH-1:0]			wr_data_reg			= {SPI_DATA_LENGTH{1'b0}};
	reg										wr_en				= 1'b0;
	reg		[5:0]							wr_en_extend		= 6'b0;
	reg										rd_en				= 1'b0;
	reg		[SPI_DATA_LENGTH-1:0]			rd_data_reg			= {SPI_DATA_LENGTH{1'b0}};
	reg										rd_data_shift_ena	= 1'b0;


	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***处理时钟***
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	时钟反向
	//	-------------------------------------------------------------------------------------
	assign	spi_clk_inv	= !i_spi_clk;

	//  ===============================================================================================
	//	ref ***接收mosi数据***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	sck_rising_cnt 对spi clk的上升沿计数
	//	cs有效时，cnt不断累加，0-7不断循环
	//  -------------------------------------------------------------------------------------
	always @ (posedge i_spi_clk or posedge i_spi_cs_n) begin
		if(i_spi_cs_n) begin
			sck_rising_cnt	<= 3'b0;
		end
		else begin
			sck_rising_cnt	<= sck_rising_cnt + 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	once_byte_cnt
	//	cs有效时，每8个sclk rising edge，计数器+1
	//	在cmd 和 addr 阶段计数
	//  -------------------------------------------------------------------------------------
	always @ (posedge i_spi_clk or posedge i_spi_cs_n) begin
		if(i_spi_cs_n) begin
			once_byte_cnt	<= 'b0;
		end
		else begin
			if(sck_rising_cnt==3'd7) begin
				if(once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH+SPI_DATA_BYTE_LENGTH+1)) begin
					once_byte_cnt	<= once_byte_cnt;
				end
				else begin
					once_byte_cnt	<= once_byte_cnt + 1'b1;
				end
			end
		end
	end

	reg			once_cnt_over_flow	= 1'b0;
	always @ (posedge i_spi_clk or posedge i_spi_cs_n) begin
		if(i_spi_cs_n) begin
			once_cnt_over_flow	<= 1'b0;
		end
		else begin
			if(once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH+SPI_DATA_BYTE_LENGTH)) begin
				once_cnt_over_flow	<= 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	data_cnt
	//	cs有效时，每8个sclk rising edge，计数器+1
	//	在data阶段计数
	//  -------------------------------------------------------------------------------------
	always @ (posedge i_spi_clk or posedge i_spi_cs_n) begin
		if(i_spi_cs_n) begin
			continue_byte_cnt	<= 'b0;
		end
		else begin
			if(sck_rising_cnt==3'd7) begin
				if(once_cnt_over_flow==1'b1) begin
					if(continue_byte_cnt==(SPI_DATA_BYTE_LENGTH-1)) begin
						continue_byte_cnt	<= 'b0;
					end
					else begin
						continue_byte_cnt	<= continue_byte_cnt + 1'b1;
					end
				end
				else begin
					continue_byte_cnt	<= 'b0;
				end
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	spi_data_shifter 数据移位寄存器，其宽度=命令、地址、数据的最大宽度
	//  -------------------------------------------------------------------------------------
	always @ (posedge i_spi_clk or posedge i_spi_cs_n) begin
		if(i_spi_cs_n) begin
			spi_data_shifter	<= {SPI_SHFITER_LENGTH{1'b0}};
		end
		else begin
			spi_data_shifter	<= {spi_data_shifter[SPI_SHFITER_LENGTH-2:0],i_spi_mosi};
		end
	end

	//  ===============================================================================================
	//	ref ***解析 命令、地址***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	cmd_wr cmd_rd 解析命令寄存器
	//	1.当cs=1时，命令寄存器清零
	//	2.当cs=0时，sck计数器=命令长度时，如果数据=写命令，则写命令有效
	//	3.当cs=0时，sck计数器=命令长度时，如果数据=读命令，则读命令有效
	//  -------------------------------------------------------------------------------------
	always @ (posedge i_spi_clk or posedge i_spi_cs_n) begin
		if(i_spi_cs_n) begin
			cmd_wr	<= 1'b0;
			cmd_rd	<= 1'b0;
		end
		else begin
			if(sck_rising_cnt==3'd0 && once_byte_cnt==SPI_CMD_BYTE_LENGTH) begin
				case(spi_data_shifter[SPI_CMD_LENGTH-1:0])
					SPI_CMD_WR : begin
						cmd_wr	<= 1'b1;
						cmd_rd	<= 1'b0;
					end
					SPI_CMD_RD : begin
						cmd_wr	<= 1'b0;
						cmd_rd	<= 1'b1;
					end
					default : begin
						cmd_wr	<= 1'b0;
						cmd_rd	<= 1'b0;
					end
				endcase
			end
		end
	end
	assign	o_cmd_is_rd	= cmd_rd;

	//  -------------------------------------------------------------------------------------
	//	addr_reg 读写共用，在解析完地址之后就输出
	//	1.当sck计数到地址时，提取出地址
	//  -------------------------------------------------------------------------------------
	always @ (posedge i_spi_clk) begin
		if(sck_rising_cnt==3'd7 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH-1)) begin
			addr_reg	<= {spi_data_shifter[SPI_ADDR_LENGTH-2:0],i_spi_mosi};
		end
		else if(cmd_wr==1'b1) begin
			if(once_cnt_over_flow==1'b1 && sck_rising_cnt==3'd0 && continue_byte_cnt==0) begin
				addr_reg	<= addr_reg + 1'b1;
			end
		end
		else if(cmd_rd==1'b1) begin
			if(sck_rising_cnt==3'd7 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH+SPI_DATA_BYTE_LENGTH-1)) begin
				addr_reg	<= addr_reg + 1'b1;
			end
			else if(once_cnt_over_flow==1'b1 && sck_rising_cnt==3'd7 && continue_byte_cnt==(SPI_DATA_BYTE_LENGTH-1)) begin
				addr_reg	<= addr_reg + 1'b1;
			end
		end
	end
	assign	ov_addr	= addr_reg;

	//  ===============================================================================================
	//	ref ***写操作解析***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	wr data
	//	1.当sck计数到最后时，提取出写数据
	//  -------------------------------------------------------------------------------------
	always @ (posedge i_spi_clk) begin
		if(sck_rising_cnt==3'd0 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH+SPI_DATA_BYTE_LENGTH)) begin
			wr_data_reg	<= spi_data_shifter[SPI_DATA_LENGTH-1:0];
		end
		else if(once_cnt_over_flow==1'b1 && sck_rising_cnt==3'd0 && continue_byte_cnt==0) begin
			wr_data_reg	<= spi_data_shifter[SPI_DATA_LENGTH-1:0];
		end
	end
	assign	ov_wr_data	= wr_data_reg;

	//  -------------------------------------------------------------------------------------
	//	wr en
	//	1.当spi接收了4个数据的时候，写使能取消。此时是下一个spi操作接收到半个字节的时候
	//	2.当spi是写命令，且sck计数到最后一个时，写使能=1
	//  -------------------------------------------------------------------------------------
	always @ (posedge i_spi_clk) begin
		if(sck_rising_cnt==4) begin
			wr_en	<= 1'b0;
		end
		else if(sck_rising_cnt==3'd0 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH+SPI_DATA_BYTE_LENGTH)) begin
			wr_en	<= cmd_wr;
		end
		else if(once_cnt_over_flow==1'b1 && sck_rising_cnt==3'd0 && continue_byte_cnt==0) begin
			wr_en	<= cmd_wr;
		end
	end
	assign	o_wr_en	= wr_en;

	//  ===============================================================================================
	//	ref ***读操作解析***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	rd en
	//	1.cs=1时，读使能=0
	//	2.当spi是读命令，且sck计数到地址时，读使能=1
	//  -------------------------------------------------------------------------------------
	always @ (posedge i_spi_clk) begin
		if(sck_rising_cnt==3) begin
			rd_en	<= 1'b0;
		end
		else if(sck_rising_cnt==3'd7 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH-1)) begin
			rd_en	<= cmd_rd;
		end
		else if(sck_rising_cnt==3'd7 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH+SPI_DATA_BYTE_LENGTH-1)) begin
			rd_en	<= cmd_rd;
		end
		else if(once_cnt_over_flow==1'b1 && sck_rising_cnt==3'd7 && continue_byte_cnt==(SPI_DATA_BYTE_LENGTH-1)) begin
			rd_en	<= cmd_rd;
		end
	end
	assign	o_rd_en	= rd_en;

	//  -------------------------------------------------------------------------------------
	//	选择输入的寄存器数据
	//	1.当sck上升沿计数为 cmd + addr 时，在sck的下降沿，从寄存器模块获取数据
	//	2.寄存器模块输出的数据都是各自时钟域的，与spi采样时钟域可能是异步的，需要保证在采样时刻数据已经稳定，这一点要用时序约束保证
	//	3.数据选择是有优先级的，因为一个寄存器可能存在于多个时钟域当中
	//	4.当读数据移位使能打开，且sck下降沿时，读数据寄存器移位
	//
	//  -------------------------------------------------------------------------------------
	always @ (posedge spi_clk_inv) begin
		if((sck_rising_cnt==3'd0 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH))
		||(sck_rising_cnt==3'd0 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH+SPI_DATA_BYTE_LENGTH))
		||(once_cnt_over_flow==1'b1 && sck_rising_cnt==3'd0 && continue_byte_cnt==0)
		) begin

			if(i_fix_sel) begin
				rd_data_reg	<= iv_fix_rd_data	;
			end
			else if(i_pix_sel) begin
				rd_data_reg	<= iv_pix_rd_data	;
			end
			else if(i_gpif_sel) begin
				rd_data_reg	<= iv_gpif_rd_data	;
			end
			else if(i_frame_buf_sel) begin
				rd_data_reg	<= iv_frame_buf_rd_data	;
			end
			else if(i_osc_bufg_sel) begin
				rd_data_reg	<= iv_osc_bufg_rd_data	;
			end
			else begin
				rd_data_reg	<= {SPI_DATA_LENGTH{1'b0}}	;
			end
		end
//		else if(rd_data_shift_ena) begin
		else begin
			rd_data_reg	<= {rd_data_reg[SPI_DATA_LENGTH-2:0],rd_data_reg[SPI_DATA_LENGTH-1]};
		end
	end

	//  -------------------------------------------------------------------------------------
	//	读数据寄存器移位使能，也作为miso的三态使能标志
	//	1.当sck上升沿计数为 cmd + addr 时，在sck的下降沿，读数据寄存器移位使能打开
	//  -------------------------------------------------------------------------------------
	always @ (posedge spi_clk_inv or posedge i_spi_cs_n) begin
		if(i_spi_cs_n) begin
			rd_data_shift_ena	<= 1'b0;
		end
		//		else if(sck_rising_cnt==(SPI_CMD_LENGTH+SPI_ADDR_LENGTH) && cmd_rd==1'b1) begin
		else if(sck_rising_cnt==3'd0 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH) && cmd_rd==1'b1) begin
			rd_data_shift_ena	<= 1'b1;
		end
	end

	//  ===============================================================================================
	//	ref ***发出miso数据***
	//  ===============================================================================================
	assign	o_spi_miso_data_en	= rd_data_shift_ena;
	assign	o_spi_miso_data		= rd_data_reg[SPI_DATA_LENGTH-1];

	//要在顶层模块中例化三态逻辑
	//	assign	o_spi_miso	= o_spi_miso_data_en ? o_spi_miso_data : 1'bz;







endmodule

