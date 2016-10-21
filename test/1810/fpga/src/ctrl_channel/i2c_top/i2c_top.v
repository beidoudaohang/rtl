//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : i2c_ctrl
//  -- 设计者       : 周金剑
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 周金剑       :| 2015/10/20 16:43:05	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :i2c顶层模块，该模块只能执行写操作
//					子模块:
//					1、trigger_cmd_ram，存储触发模式下，配置sensor寄存器的地址和数据
//					2、continuous_cmd_fifo，储存连续模式下待更新的参数
//					3、i2c_ctrl，i2c的读写控制模块，只支持固定的16位地址和16位数据，i2c器件地址固定为0x20
//					4、i2c_master_wb_top，i2c master模块，将sensor寄存器的地址和数据以i2c的协议发送到sensor
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
module i2c_top # (
	parameter	I2C_MASTER_CLOCK_FREQ_KHZ	= 55000	,
	parameter	I2C_CLOCK_FREQ_KHZ			= 400
	)
	(
	input				reset				,//复位信号
	input				clk					,//时钟，clk_pix,55MHz
	input				i_trigger_mode		,//解串时钟域，110MHz
	//trigger
	input				i_trigger			,//clk_pix时钟域，触发信号
	//参数设置接口
	input		[ 4:0]	iv_i2c_ram_addr		,//clk_pix时钟域，RAM写地址
	input		[15:0]	iv_i2c_cmd_addr		,//clk_pix时钟域，RAM数据的高16bit，对于sensor内部寄存器地址
	input		[15:0]	iv_i2c_cmd_data		,//clk_pix时钟域，RAM数据的低16bit，对于sensor内部寄存器数据
	input				i_i2c_ram_wren		,//clk_pix时钟域，RAM写信号
	//i2c触发命令开始发送
	output				o_state_idle		,//clk_pix时钟域，i2c状态机空闲
	output				o_trigger_start		,//clk_pix时钟域，1-表示i2c开始发送
	//i2c信号
	input        		i_scl_pad			,//clk_pix时钟域，scl输入信号
	output       		o_scl_pad			,//clk_pix时钟域，scl输出信号
	output       		o_scl_padoen		,//clk_pix时钟域，scl输出使能
	input        		i_sda_pad			,//clk_pix时钟域，sda输入信号
	output       		o_sda_pad			,//clk_pix时钟域，sda输出信号
	output       		o_sda_padoen		 //clk_pix时钟域，sda输出使能
	);
	//  -------------------------------------------------------------------------------------
	//	变量定义
	//  -------------------------------------------------------------------------------------
	reg		[2:0]   trigger_mode;
	wire            trigger_mode_rise;
	wire            trigger_mode_fall;
	wire            fifo_reset  ;
	//连续采集FIFO
	wire	[31:0]	w_fifo_data	;
	wire			w_fifo_wren	;
	wire			w_fifo_full	;
	wire			w_fifo_empty;
	wire			w_fifo_rden	;
	wire	[31:0]	w_fifo_q	;
	wire			w_fifo_rdy	;
	//触发采集RAM
	wire	[4:0]	w_ram_addr	;
	wire	[31:0]	w_ram_data	;
	wire			w_ram_wren	;
	wire	[4:0]	w_ram_rdaddr;
	wire	[31:0]	w_ram_q		;
	//i2c_top相关信号
	wire	[2:0]	w_wb_adr	;
	wire	[7:0]	w_wb_wdat	;
	wire			w_wb_we		;
	wire			w_wb_stb	;
	wire			w_wb_cyc	;
	wire			w_done		;//1-表示发完一个字节数据
	//  -------------------------------------------------------------------------------------
	//	RAM和FIFO信号控制
	//  -------------------------------------------------------------------------------------
	assign	w_fifo_data	=	{iv_i2c_cmd_addr,iv_i2c_cmd_data};						//数据拼接
	assign	w_fifo_wren	=	i_i2c_ram_wren & (!w_fifo_full) & (!trigger_mode[1]);	//在连续模式时，fifo非满即可写

	assign	w_ram_addr	=	iv_i2c_ram_addr;										//RAM写地址
	assign	w_ram_data	=	{iv_i2c_cmd_addr,iv_i2c_cmd_data};						//RAM写数据
	assign	w_ram_wren	=	i_i2c_ram_wren ;										//RAM写使能

	assign	w_fifo_rdy	=	trigger_mode[1] ? 1'b0 : (!w_fifo_empty);				//触发模式时不fifo的rdy信号置0，连续模式才会判断rdy信号

    //  -------------------------------------------------------------------------------------
	//	切换到触发模式时，复位FIFO
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
	    trigger_mode    <=  {trigger_mode[1:0],i_trigger_mode}	;
	end
	assign	trigger_mode_rise   =   (trigger_mode[2:1]==2'b01)	;//i_trigger_mode的上升沿
	assign  trigger_mode_fall   =   (trigger_mode[2:1]==2'b10)	;//i_trigger_mode的下降沿
	assign  fifo_reset          =   trigger_mode_rise | reset	;//在i_trigger_mode的上升沿复位FIFO


	//  -------------------------------------------------------------------------------------
	//	RAM例化，该RAM包含初始化文件
	//  -------------------------------------------------------------------------------------
	trigger_cmd_ram_w32d32 trigger_cmd_ram_w32d32_inst(
  	.clka				(clk				),
  	.addra				(w_ram_addr			),
  	.dina				(w_ram_data			),
  	.wea				(w_ram_wren			),
  	.clkb				(clk				),
  	.addrb				(w_ram_rdaddr		),
  	.doutb				(w_ram_q			)
	);

	//  -------------------------------------------------------------------------------------
	//	连续采集模式FIFO例化
	//  -------------------------------------------------------------------------------------
	continuous_cmd_fifo continuous_cmd_fifo_inst(
  	.rst				(fifo_reset         ),
  	.clk				(clk				),
  	.din				(w_fifo_data		),
  	.wr_en				(w_fifo_wren		),
  	.full				(w_fifo_full		),
  	.rd_en				(w_fifo_rden		),
  	.dout				(w_fifo_q			),
  	.empty				(w_fifo_empty		)
	);

	//  -------------------------------------------------------------------------------------
	//	i2c_ctrl例化
	//  -------------------------------------------------------------------------------------
	i2c_ctrl i2c_ctrl_inst (
	.reset				(reset				),
	.clk				(clk				),
	//trigger
	.i_trigger			(i_trigger 			),
	//i_trigger_mode下降沿
	.i_trigger_mode_fall(trigger_mode_fall	),
	//fifo控制信号
	.o_fifo_rden		(w_fifo_rden		),
	.iv_fifo_q			(w_fifo_q			),
	.i_fifo_rdy			(w_fifo_rdy			),
	//ram控制信号
	.ov_ram_addr		(w_ram_rdaddr		),
	.iv_ram_q			(w_ram_q			),
	//i2c master控制信号
	.ov_wb_adr			(w_wb_adr			),
	.ov_wb_dat			(w_wb_wdat			),
	.o_wb_we			(w_wb_we			),
	.o_wb_stb			(w_wb_stb			),
	.o_wb_cyc			(w_wb_cyc			),
	.i_done				(w_done				),
	.o_state_idle		(o_state_idle		),
	.o_trigger_start	(o_trigger_start	)
	);

	//  -------------------------------------------------------------------------------------
	//	i2c_master_wb_top例化
	//  -------------------------------------------------------------------------------------
	i2c_master_wb_top #(
	.I2C_MASTER_CLOCK_FREQ_KHZ	(I2C_MASTER_CLOCK_FREQ_KHZ	),
	.I2C_CLOCK_FREQ_KHZ			(I2C_CLOCK_FREQ_KHZ			)
	)
	i2c_master_wb_top_inst (
	.wb_clk_i					(clk						),
	.wb_rst_i					(reset						),
	.arst_i						(reset						),
	.wb_adr_i					(w_wb_adr					),
	.wb_dat_i					(w_wb_wdat					),
	.wb_dat_o					(							),
	.wb_we_i					(w_wb_we					),
	.wb_stb_i					(w_wb_stb					),
	.wb_cyc_i					(w_wb_cyc					),
	.wb_ack_o					(							),
	.wb_inta_o					(							),
	.done						(w_done						),
	.scl_pad_i					(i_scl_pad					),
	.scl_pad_o					(o_scl_pad					),
	.scl_padoen_o				(o_scl_padoen				),
	.sda_pad_i					(i_sda_pad					),
	.sda_pad_o					(o_sda_pad					),
	.sda_padoen_o				(o_sda_padoen				)
	);


endmodule
