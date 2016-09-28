//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : gpif_reg_list
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/5 15:39:34	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     : gpif时钟域的寄存器列表
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

module gpif_reg_list # (
	parameter		SPI_ADDR_LENGTH			= 16	,	//spi 地址的长度
	parameter		SHORT_REG_WD			= 16	,	//短寄存器位宽
	parameter		REG_WD					= 32	,	//寄存器位宽
	parameter		LONG_REG_WD				= 64	,	//长寄存器位宽
	parameter		REG_INIT_VALUE			= "TRUE"	//寄存器是否有初始值
	)
	(
	//  ===============================================================================================
	//	控制信号
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spi时钟域
	//  -------------------------------------------------------------------------------------
	input								i_wr_en					,	//写使能
	input								i_rd_en					,	//读使能
	input								i_cmd_is_rd				,	//读命令来了
	input	[SPI_ADDR_LENGTH-1:0]		iv_addr					,	//读写地址
	input	[SHORT_REG_WD-1:0]			iv_wr_data				,	//写数据
	//  -------------------------------------------------------------------------------------
	//	gpif 时钟域
	//  -------------------------------------------------------------------------------------
	input								clk_gpif				,	//gpif 时钟，100MHz
	output								o_gpif_sel				,	//gpif 时钟域被选择
	output	[SHORT_REG_WD-1:0]			ov_gpif_rd_data			,	//读数据

	//  ===============================================================================================
	//	以下内容是寄存器
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	通用
	//  -------------------------------------------------------------------------------------
	output								o_stream_enable_gpif				,	//clk_gpif时钟域，流使能信号
	//  -------------------------------------------------------------------------------------
	//	u3 interface
	//  -------------------------------------------------------------------------------------
	output	[REG_WD-1:0]				ov_si_payload_transfer_size			,	//clk_gpif时钟域，等量数据块大小
	output	[REG_WD-1:0]				ov_si_payload_transfer_count		,	//clk_gpif时钟域，等量数据块个数
	output	[REG_WD-1:0]				ov_si_payload_final_transfer1_size	,	//clk_gpif时钟域，transfer1大小
	output	[REG_WD-1:0]				ov_si_payload_final_transfer2_size	,	//clk_gpif时钟域，transfer2大小
	output	[REG_WD-1:0]				ov_payload_size_gpif				,	//clk_gpif时钟域，数据的大小但不包含头包尾包，协议要求64bit，我们只是用32bit即可，高32bit补0
	output								o_chunk_mode_active_gpif				//clk_gpif时钟域，chunk开关寄存器
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
	localparam	INIT_VALUE_TRANSFER_SIZE_H	= (REG_INIT_VALUE=="TRUE") ? 16'h0010 : {SHORT_REG_WD{1'b0}};
	localparam	INIT_VALUE_TRANSFER_SIZE_L	= (REG_INIT_VALUE=="TRUE") ? 16'h0000 : {SHORT_REG_WD{1'b0}};
	localparam	INIT_VALUE_TRANSFER_COUNT_H	= (REG_INIT_VALUE=="TRUE") ? 16'h0000 : {SHORT_REG_WD{1'b0}};
	localparam	INIT_VALUE_TRANSFER_COUNT_L	= (REG_INIT_VALUE=="TRUE") ? 16'h0004 : {SHORT_REG_WD{1'b0}};
	localparam	INIT_VALUE_TRANSFER1_SIZE_H	= (REG_INIT_VALUE=="TRUE") ? 16'h000C : {SHORT_REG_WD{1'b0}};
	localparam	INIT_VALUE_TRANSFER1_SIZE_L	= (REG_INIT_VALUE=="TRUE") ? 16'hE000 : {SHORT_REG_WD{1'b0}};
	localparam	INIT_VALUE_TRANSFER2_SIZE_H	= (REG_INIT_VALUE=="TRUE") ? 16'h0000 : {SHORT_REG_WD{1'b0}};
	localparam	INIT_VALUE_TRANSFER2_SIZE_L	= (REG_INIT_VALUE=="TRUE") ? 16'h0400 : {SHORT_REG_WD{1'b0}};


	//  ===============================================================================================
	//	控制寄存器
	//  ===============================================================================================
	reg		[2:0]					wr_en_shift							= 3'b0;
	wire							wr_en_rise							;
	reg		[SHORT_REG_WD:0]		data_out_reg						= {(SHORT_REG_WD+1){1'b0}};

	//  ===============================================================================================
	//	以下内容是寄存器
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	通用
	//  -------------------------------------------------------------------------------------
	reg								param_cfg_done							= 1'b0;
	reg								stream_enable_gpif						= INIT_VALUE_SE;
	//  -------------------------------------------------------------------------------------
	//	u3 interface
	//  -------------------------------------------------------------------------------------
	reg		[SHORT_REG_WD-1:0]		si_payload_transfer_size_h				= INIT_VALUE_TRANSFER_SIZE_H;
	reg		[SHORT_REG_WD-1:0]		si_payload_transfer_size_h_group		= INIT_VALUE_TRANSFER_SIZE_H;
	reg		[SHORT_REG_WD-1:0]		si_payload_transfer_size_l				= INIT_VALUE_TRANSFER_SIZE_L;
	reg		[SHORT_REG_WD-1:0]		si_payload_transfer_size_l_group		= INIT_VALUE_TRANSFER_SIZE_L;
	reg		[SHORT_REG_WD-1:0]		si_payload_transfer_count_h				= INIT_VALUE_TRANSFER_COUNT_H;
	reg		[SHORT_REG_WD-1:0]		si_payload_transfer_count_h_group		= INIT_VALUE_TRANSFER_COUNT_H;
	reg		[SHORT_REG_WD-1:0]		si_payload_transfer_count_l				= INIT_VALUE_TRANSFER_COUNT_L;
	reg		[SHORT_REG_WD-1:0]		si_payload_transfer_count_l_group		= INIT_VALUE_TRANSFER_COUNT_L;
	reg		[SHORT_REG_WD-1:0]		si_payload_final_transfer1_size_h		= INIT_VALUE_TRANSFER1_SIZE_H;
	reg		[SHORT_REG_WD-1:0]		si_payload_final_transfer1_size_h_group	= INIT_VALUE_TRANSFER1_SIZE_H;
	reg		[SHORT_REG_WD-1:0]		si_payload_final_transfer1_size_l		= INIT_VALUE_TRANSFER1_SIZE_L;
	reg		[SHORT_REG_WD-1:0]		si_payload_final_transfer1_size_l_group	= INIT_VALUE_TRANSFER1_SIZE_L;
	reg		[SHORT_REG_WD-1:0]		si_payload_final_transfer2_size_h		= INIT_VALUE_TRANSFER2_SIZE_H;
	reg		[SHORT_REG_WD-1:0]		si_payload_final_transfer2_size_h_group	= INIT_VALUE_TRANSFER2_SIZE_H;
	reg		[SHORT_REG_WD-1:0]		si_payload_final_transfer2_size_l		= INIT_VALUE_TRANSFER2_SIZE_L;
	reg		[SHORT_REG_WD-1:0]		si_payload_final_transfer2_size_l_group	= INIT_VALUE_TRANSFER2_SIZE_L;
	reg		[SHORT_REG_WD-1:0]		payload_size_3							= INIT_VALUE_PAYLOAD_SIZE_3;
	reg		[SHORT_REG_WD-1:0]		payload_size_3_group					= INIT_VALUE_PAYLOAD_SIZE_3;
	reg		[SHORT_REG_WD-1:0]		payload_size_4							= INIT_VALUE_PAYLOAD_SIZE_4;
	reg		[SHORT_REG_WD-1:0]		payload_size_4_group					= INIT_VALUE_PAYLOAD_SIZE_4;
	reg								chunk_mode_active						= 1'b0;

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	-- ref ***写过程***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref 写相关的寄存器
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	在pix 时钟域取写信号的上升沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_gpif) begin
		wr_en_shift	<= {wr_en_shift[1:0],i_wr_en};
	end
	assign	wr_en_rise	= (wr_en_shift[2:1]==2'b01) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	-- ref 写过程寄存器操作
	//	当 wr_en_rise 的时候，iv_addr已经稳定
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_gpif) begin
		if(wr_en_rise) begin
			case(iv_addr[8:0])
				//  -------------------------------------------------------------------------------------
				//	通用
				//  -------------------------------------------------------------------------------------
				9'h20	: param_cfg_done					<= iv_wr_data[0];
				9'h30	: stream_enable_gpif				<= iv_wr_data[0];
				//  -------------------------------------------------------------------------------------
				//	u3 interface
				//  -------------------------------------------------------------------------------------
				9'hb4	: si_payload_transfer_size_h		<= iv_wr_data[SHORT_REG_WD-1:0];
				9'hb5	: si_payload_transfer_size_l		<= iv_wr_data[SHORT_REG_WD-1:0];
				9'hb6	: si_payload_transfer_count_h		<= iv_wr_data[SHORT_REG_WD-1:0];
				9'hb7	: si_payload_transfer_count_l		<= iv_wr_data[SHORT_REG_WD-1:0];
				9'hb8	: si_payload_final_transfer1_size_h	<= iv_wr_data[SHORT_REG_WD-1:0];
				9'hb9	: si_payload_final_transfer1_size_l	<= iv_wr_data[SHORT_REG_WD-1:0];
				9'hba	: si_payload_final_transfer2_size_h	<= iv_wr_data[SHORT_REG_WD-1:0];
				9'hbb	: si_payload_final_transfer2_size_l	<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h37	: payload_size_3					<= iv_wr_data[SHORT_REG_WD-1:0];
				9'h38	: payload_size_4					<= iv_wr_data[SHORT_REG_WD-1:0];
				9'ha0	: chunk_mode_active					<= iv_wr_data[0];
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
	always @ (posedge clk_gpif) begin
		if(param_cfg_done) begin
			payload_size_3_group	<= payload_size_3;
			payload_size_4_group	<= payload_size_4;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	SI transfer 成组生效
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_gpif) begin
		if(param_cfg_done) begin
			si_payload_transfer_size_h_group	<= si_payload_transfer_size_h;
			si_payload_transfer_size_l_group	<= si_payload_transfer_size_l;
			si_payload_transfer_count_h_group	<= si_payload_transfer_count_h;
			si_payload_transfer_count_l_group	<= si_payload_transfer_count_l;
			si_payload_final_transfer1_size_h_group	<= si_payload_final_transfer1_size_h;
			si_payload_final_transfer1_size_l_group	<= si_payload_final_transfer1_size_l;
			si_payload_final_transfer2_size_h_group	<= si_payload_final_transfer2_size_h;
			si_payload_final_transfer2_size_l_group	<= si_payload_final_transfer2_size_l;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	-- ref 输出
	//  -------------------------------------------------------------------------------------
	assign	o_stream_enable_gpif		= stream_enable_gpif;
	//  -------------------------------------------------------------------------------------
	//	u3 interface
	//  -------------------------------------------------------------------------------------
	assign	ov_si_payload_transfer_size			= {si_payload_transfer_size_h_group,si_payload_transfer_size_l_group};
	assign	ov_si_payload_transfer_count		= {si_payload_transfer_count_h_group,si_payload_transfer_count_l_group};
	assign	ov_si_payload_final_transfer1_size	= {si_payload_final_transfer1_size_h_group,si_payload_final_transfer1_size_l_group};
	assign	ov_si_payload_final_transfer2_size	= {si_payload_final_transfer2_size_h_group,si_payload_final_transfer2_size_l_group};
	assign	ov_payload_size_gpif				= {payload_size_3_group,payload_size_4_group};
	assign	o_chunk_mode_active_gpif			= chunk_mode_active;
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
				//				9'h20	: data_out_reg		<= {1'b1,{(SHORT_REG_WD-1){1'b0}},param_cfg_done};	//pix 时钟域已经定义
				//				9'h30	: data_out_reg		<= {1'b1,{(SHORT_REG_WD-1){1'b0}},stream_enable_gpif};	//pix 时钟域已经定义
				//  -------------------------------------------------------------------------------------
				//	u3 interface
				//  -------------------------------------------------------------------------------------
				//read write
				9'hb4	: data_out_reg		<= {1'b1,si_payload_transfer_size_h[SHORT_REG_WD-1:0]};
				9'hb5	: data_out_reg		<= {1'b1,si_payload_transfer_size_l[SHORT_REG_WD-1:0]};
				9'hb6	: data_out_reg		<= {1'b1,si_payload_transfer_count_h[SHORT_REG_WD-1:0]};
				9'hb7	: data_out_reg		<= {1'b1,si_payload_transfer_count_l[SHORT_REG_WD-1:0]};
				9'hb8	: data_out_reg		<= {1'b1,si_payload_final_transfer1_size_h[SHORT_REG_WD-1:0]};
				9'hb9	: data_out_reg		<= {1'b1,si_payload_final_transfer1_size_l[SHORT_REG_WD-1:0]};
				9'hba	: data_out_reg		<= {1'b1,si_payload_final_transfer2_size_h[SHORT_REG_WD-1:0]};
				9'hbb	: data_out_reg		<= {1'b1,si_payload_final_transfer2_size_l[SHORT_REG_WD-1:0]};

				//				9'h35	: data_out_reg		<= {1'b1,{SHORT_REG_WD{1'b0}}};	//payload_size1	//pix 时钟域已经定义
				//				9'h36	: data_out_reg		<= {1'b1,{SHORT_REG_WD{1'b0}}};	//payload_size2	//pix 时钟域已经定义
				//				9'h37	: data_out_reg		<= {1'b1,payload_size_3[SHORT_REG_WD-1:0]};	//pix 时钟域已经定义
				//				9'h38	: data_out_reg		<= {1'b1,payload_size_4[SHORT_REG_WD-1:0]};	//pix 时钟域已经定义
				//				9'ha0	: data_out_reg		<= {1'b1,{(SHORT_REG_WD-1){1'b0}},chunk_mode_active};	//frame_buf 时钟域已经定义

				default	: data_out_reg		<= {(SHORT_REG_WD+1){1'b0}};

			endcase
		end
		//当读使能取消的时候，sel才能复位为0
		else begin
			data_out_reg	<= {(SHORT_REG_WD+1){1'b0}};
		end
	end
	assign	o_gpif_sel		= data_out_reg[SHORT_REG_WD];
	assign	ov_gpif_rd_data	= data_out_reg[SHORT_REG_WD-1:0];

endmodule