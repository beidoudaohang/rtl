//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : frame_buf_reg_list
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/6 10:45:54	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : frame_buf时钟域的寄存器列表
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

module frame_buf_reg_list # (
	parameter		SPI_ADDR_LENGTH			= 16	,	//spi 地址的长度
	parameter		SHORT_REG_WD			= 16	,	//短寄存器位宽
	parameter		REG_WD					= 32	,	//寄存器位宽
	parameter		LONG_REG_WD				= 64	,	//长寄存器位宽
	parameter		BUF_DEPTH_WD			= 4		,	//帧存深度位宽,我们最大支持8帧深度，多一位进位位
	parameter		REG_INIT_VALUE			= "TRUE"	//寄存器是否有初始值
	)
	(
	//  ===============================================================================================
	//	控制信号
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spi时钟域
	//  -------------------------------------------------------------------------------------
	input								i_wr_en					,	//写使能，clk_sample时钟域
	input								i_rd_en					,	//读使能，clk_sample时钟域
	input								i_cmd_is_rd				,	//读命令来了，clk_sample时钟域
	input	[SPI_ADDR_LENGTH-1:0]		iv_addr					,	//读写地址，clk_sample时钟域
	input	[SHORT_REG_WD-1:0]			iv_wr_data				,	//写数据，clk_sample时钟域
	//  -------------------------------------------------------------------------------------
	//	frame buf 时钟域
	//  -------------------------------------------------------------------------------------
	input								clk_frame_buf			,	//帧存时钟100MHz
	output								o_frame_buf_sel			,	//帧存时钟域被选择
	output	[SHORT_REG_WD-1:0]			ov_frame_buf_rd_data	,	//读数据

	//  ===============================================================================================
	//	以下内容是寄存器
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	通用
	//  -------------------------------------------------------------------------------------
	output								o_stream_enable_frame_buf		,	//clk_frame_buf时钟域，流使能信号
	//  -------------------------------------------------------------------------------------
	//	frame buffer
	//  -------------------------------------------------------------------------------------
	output	[REG_WD-1:0]				ov_payload_size_frame_buf		,	//clk_frame_buf时钟域，数据的大小但不包含头包尾包，协议要求64bit，我们只是用32bit即可，高32bit补0
	output	[BUF_DEPTH_WD-1:0]			ov_frame_buffer_depth			,	//clk_frame_buf时钟域，帧存深度，2-8
	output								o_chunk_mode_active_frame_buf		//clk_frame_buf时钟域，chunk开关寄存器
	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	固定参数
	//	2592*1944的分辨率
	//	-------------------------------------------------------------------------------------
	//	localparam	INIT_VALUE_SE				= (REG_INIT_VALUE=="TRUE") ? 1'b1 : 1'b0;
	localparam	INIT_VALUE_SE				= 1'b0;
	localparam	INIT_VALUE_PAYLOAD_SIZE_3	= (REG_INIT_VALUE=="TRUE") ? 16'h004c : {SHORT_REG_WD{1'b0}};
	localparam	INIT_VALUE_PAYLOAD_SIZE_4	= (REG_INIT_VALUE=="TRUE") ? 16'he300 : {SHORT_REG_WD{1'b0}};


	//  ===============================================================================================
	//	控制寄存器
	//  ===============================================================================================
	reg		[2:0]					wr_en_shift				= 3'b0;
	wire							wr_en_rise				;
	reg		[SHORT_REG_WD:0]		data_out_reg			= {(SHORT_REG_WD+1){1'b0}};

	//  ===============================================================================================
	//	以下内容是寄存器
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	通用
	//  -------------------------------------------------------------------------------------
	reg								param_cfg_done			= 1'b0;
	reg								stream_enable_frame_buf	= INIT_VALUE_SE;
	//  -------------------------------------------------------------------------------------
	//	frame buffer
	//  -------------------------------------------------------------------------------------
	reg		[SHORT_REG_WD-1:0]		payload_size_3			= INIT_VALUE_PAYLOAD_SIZE_3;
	reg		[SHORT_REG_WD-1:0]		payload_size_3_group	= INIT_VALUE_PAYLOAD_SIZE_3;
	reg		[SHORT_REG_WD-1:0]		payload_size_4			= INIT_VALUE_PAYLOAD_SIZE_4;
	reg		[SHORT_REG_WD-1:0]		payload_size_4_group	= INIT_VALUE_PAYLOAD_SIZE_4;
	reg		[BUF_DEPTH_WD-1:0]		frame_buffer_depth		= 2;
	reg								chunk_mode_active		= 1'b0;

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***写过程***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref 写相关的寄存器
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	在pix 时钟域取写信号的上升沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_frame_buf) begin
		wr_en_shift	<= {wr_en_shift[1:0],i_wr_en};
	end
	assign	wr_en_rise	= (wr_en_shift[2:1]==2'b01) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	-- ref 写过程寄存器操作
	//	当 wr_en_rise 的时候，iv_addr已经稳定
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_frame_buf) begin
		if(wr_en_rise) begin
			case(iv_addr[8:0])
				//  -------------------------------------------------------------------------------------
				//	通用
				//  -------------------------------------------------------------------------------------
				9'h20	: param_cfg_done			<= iv_wr_data[0];
				9'h30	: stream_enable_frame_buf	<= iv_wr_data[0];
				//  -------------------------------------------------------------------------------------
				//	frame buffer
				//  -------------------------------------------------------------------------------------
				9'h37	: payload_size_3			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h38	: payload_size_4			<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h44	: frame_buffer_depth		<= iv_wr_data[BUF_DEPTH_WD-1:0];
				9'ha0	: chunk_mode_active			<= iv_wr_data[0];
				default : ;
			endcase
		end
		else begin
			//自清零寄存器
			param_cfg_done	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	-- ref 成组生效
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	传输大小成组生效
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_frame_buf) begin
		if(param_cfg_done) begin
			payload_size_3_group	<= payload_size_3;
			payload_size_4_group	<= payload_size_4;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	-- ref 输出
	//  -------------------------------------------------------------------------------------
	assign	o_stream_enable_frame_buf		= stream_enable_frame_buf;
	//  -------------------------------------------------------------------------------------
	//	frame buffer
	//  -------------------------------------------------------------------------------------
	assign	ov_payload_size_frame_buf		= {payload_size_3_group,payload_size_4_group};
	assign	ov_frame_buffer_depth			= frame_buffer_depth;
	assign	o_chunk_mode_active_frame_buf	= chunk_mode_active;

	//  ===============================================================================================
	//	ref ***读过程***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref 读过程寄存器操作
	//	读, data_out_reg 最高bit说明是否选中了该时钟域，余下内容为寄存器数据
	//	读过程是纯异步逻辑，i_rd_en iv_addr 都是异步信号，输入信号稳定之后，输出也就会稳定
	//  -------------------------------------------------------------------------------------
	always @ ( * ) begin
		//当读地址选中的时候，sel拉高为有效
		if(i_rd_en) begin
			case(iv_addr[8:0])
				//  -------------------------------------------------------------------------------------
				//	通用
				//  -------------------------------------------------------------------------------------
				//				9'h20	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},param_cfg_done};	//pix 时钟域已经定义
				//				9'h30	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},stream_enable_frame_buf};	//pix 时钟域已经定义
				//  -------------------------------------------------------------------------------------
				//	u3 interface
				//  -------------------------------------------------------------------------------------
				//read write
				//				9'h35	: data_out_reg	<= {1'b1,{SHORT_REG_WD{1'b0}}};	//payload_size1	//pix 时钟域已经定义
				//				9'h36	: data_out_reg	<= {1'b1,{SHORT_REG_WD{1'b0}}};	//payload_size2	//pix 时钟域已经定义
				//				9'h37	: data_out_reg	<= {1'b1,payload_size_3[SHORT_REG_WD-1:0]};	//pix 时钟域已经定义
				//				9'h38	: data_out_reg	<= {1'b1,payload_size_4[SHORT_REG_WD-1:0]};	//pix 时钟域已经定义
				9'h44	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-BUF_DEPTH_WD){1'b0}},frame_buffer_depth[BUF_DEPTH_WD-1:0]};
				9'ha0	: data_out_reg	<= {1'b1,{(SHORT_REG_WD-1){1'b0}},chunk_mode_active};

				default	: data_out_reg	<= {(SHORT_REG_WD+1){1'b0}};

			endcase
		end
		//当读使能取消的时候，sel才能复位为0
		else begin
			data_out_reg	<= {(SHORT_REG_WD+1){1'b0}};
		end
	end
	assign	o_frame_buf_sel			= data_out_reg[SHORT_REG_WD];
	assign	ov_frame_buf_rd_data	= data_out_reg[SHORT_REG_WD-1:0];


endmodule