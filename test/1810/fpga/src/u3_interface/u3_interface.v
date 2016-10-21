//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : u3_interface
//  -- 设计者       : 张强
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 张强         :| 2014/11/28 17:40:36	:|  根据技术预研整理
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module	u3_interface # (
	parameter								DATA_WD      		=32		,		//GPIF数据宽度
	parameter								REG_WD 				=32		,		//寄存器位宽
	parameter								DMA_SIZE			=14'H2000,		//DMA SIZE大小
	parameter								PACKET_SIZE_WD		=23				//图像大小位宽,单位4字节,支持到最大32MB图像
//	parameter								DMA_SIZE			=14'H1000		//DMA SIZE大小
	)

	(
	//  ===============================================================================================
	//  第一部分：时钟复位信号
	//  ===============================================================================================

	input									clk							,		//u3接口和framebuffer后端时钟,和o_clk_usb_pclk同频，不同相
	input									reset						,		//复位信号，clk_gpif时钟域，高有效
	//  ===============================================================================================
	//  第二部分：数据流控制信号
	//  ===============================================================================================

	input									i_data_valid				,		//帧存后端输出的数据有效信号，clk_gpif时钟域，高有效
	input		[DATA_WD-1:0]				iv_data						,		//帧存读出的32位数据，clk_gpif时钟域
	input									i_framebuffer_empty			,		//framebuffer后端FIFO空标志，高电平有效，clk_gpif时钟域,
	output									o_fifo_rd					,		//读取帧存后端FIFO信号，clk_gpif时钟域,和i_data_valid信号共同指示数据有效

	//  ===============================================================================================
	//  第三部分：控制寄存器
	//  ===============================================================================================
	input		[REG_WD-1:0]				iv_payload_size				,		//clk时钟域信号，paylod大小,4字节为单位，控制通道输入的以字节为单位的值，需要除以4
	input									i_chunkmodeactive			,		//clk时钟域信号，chunk总开关，chunk开关影响leader和trailer的大小，通过判断chunk开关可以知道leader和trailer长度
	input		[REG_WD-1:0]				iv_transfer_count			,		//等量数据块个数
	input		[REG_WD-1:0]				iv_transfer_size			,		//等量数据块大小
	input		[REG_WD-1:0]				iv_transfer1_size			,       //transfer1大小
	input		[REG_WD-1:0]				iv_transfer2_size			,       //transfer2大小

	//  ===============================================================================================
	//  第四部分：GPIF接口信号
	//  ===============================================================================================

	input									i_usb_flagb					,		//异步时钟域，USB满信号，发送完32k字节数据后3个时钟会拉低，切换DMA地址后标志指示当前FIFO状态，如果当前FIFO中没有数据FLAGB会拉高，如果PC阻塞，当前FIFO还没有读出，该标志可能长时间拉低
	output		[1:0]						ov_usb_fifoaddr				,		//clk_gpif时钟域,GPIF 线程地址 2bit，地址切换顺序要和固件保持一致，目前约定为2'b00,2'b11切换
	output									o_usb_slwr_n				,		//clk_gpif时钟域,GPIF 写信号
	output		[DATA_WD-1:0]				ov_usb_data					,		//clk_gpif时钟域,GPIF 数据信号
	output									o_usb_pktend_n				,		//clk_gpif时钟域,GPIF 包结束信号
	output									o_usb_pktend_n_for_test		,		//GPIF 包结束信号，输出到测试引脚
	output									o_usb_wr_for_led					//GPIF 写信号 - 给led_ctrl模块

	);

	wire									w_leader_flag				;
	wire									w_trailer_flag              ;
	wire									w_payload_flag              ;
	wire									w_change_flag              	;
	wire		[REG_WD-1:0]				wv_packet_size              ;
	wire									w_chunkmodeactive			;

	//  ===============================================================================================
	//  u3_transfer例化
	//  ===============================================================================================
	u3_transfer # (
	.DATA_WD      				(DATA_WD      		),	//GPIF数据宽度
	.REG_WD 					(REG_WD 			),	//寄存器位宽
	.PACKET_SIZE_WD				(PACKET_SIZE_WD		),	//图像大小位宽,单位4字节,支持到最大32MB图像
	.DMA_SIZE					(DMA_SIZE			)	//DMA SIZE大小
	)
	u3_transfer_inst (
	.clk						(clk				),	//u3接口和framebuffer后端时钟,clk_usb_pclk
	.reset						(reset				),	//复位信号，clk_usb_pclk时钟域，高有效
	.o_fifo_rd					(o_fifo_rd			),	//读取帧存后端FIFO信号，clk_gpif时钟域,和i_data_valid信号共同指示数据有效，framebuffer后级模块读使能，高有效
	.i_data_valid				(i_data_valid		),	//帧存后端输出的数据有效信号，clk_usb_pclk时钟域，高有效
	.iv_data					(iv_data			),	//帧存读出的32位数据，clk_usb_pclk时钟域
	.i_framebuffer_empty		(i_framebuffer_empty),	//后端FIFO空标志，与数据对齐，clk_usb_pclk时钟域
	.i_leader_flag				(w_leader_flag		),	//leader包标志,clk_usb_pclk时钟域
	.i_trailer_flag				(w_trailer_flag		),	//trailer包标志,clk_usb_pclk时钟域
	.i_payload_flag				(w_payload_flag		),	//payload包标志,clk_usb_pclk时钟域
	.i_chunkmodeactive			(w_chunkmodeactive	),	//chunk总开关，经过生效时机控制，0)leader：52  trailer：32     1)leader：52  trailer：36
	.o_change_flag				(w_change_flag		),	//leader、payload、trailer中切换标志，每个包发送完成后切换,单周期宽度
	.iv_packet_size				(wv_packet_size		),	//当前包对应的数据量大小，用于读出framebuffer中的数据包含leader+payload+trailer，固件内为64位宽，FPGA内部只使用低32位
	.iv_transfer_count			(iv_transfer_count	),	//等量数据块个数
	.iv_transfer_size			(iv_transfer_size	),	//等量数据块大小
	.iv_transfer1_size			(iv_transfer1_size	),	//transfer1大小
	.iv_transfer2_size			(iv_transfer2_size	),	//transfer2大小
	.i_usb_flagb				(i_usb_flagb		),	//USB满信号，发送完32k字节数据后3个时钟会拉低，切换DMA地址后标志指示当前FIFO状态，如果当前FIFO中没有数据FLAGB会拉高，如果PC阻塞，当前FIFO还没有读出，该标志可能长时间拉低
	.ov_usb_fifoaddr			(ov_usb_fifoaddr	),	//GPIF 线程地址 2bit，地址切换顺序要和固件保持一致，目前约定为2'b00,2'b11切换
	.o_usb_slwr_n				(o_usb_slwr_n		),	//GPIF 写信号
	.ov_usb_data				(ov_usb_data		),	//GPIF 数据信号
	.o_usb_pktend_n				(o_usb_pktend_n		),	//GPIF 包结束信号
	.o_usb_pktend_n_for_test	(o_usb_pktend_n_for_test),	//GPIF 包结束信号，输出到测试引脚
	.o_usb_wr_for_led			(o_usb_wr_for_led	)	//GPIF 写信号 - 给led_ctrl模块
	);

	//  ===============================================================================================
	//  packet_switchr例化
	//  ===============================================================================================
	packet_switch # (
	.REG_WD 					(REG_WD 			)	//寄存器位宽
	)
	packet_switch_inst(
	.clk						(clk				),	//时钟信号，clk_usb_pclk时钟域
	.reset						(reset				),	//复位信号，高电平有效，clk_usb_pclk时钟域
	.i_chunkmodeactive			(i_chunkmodeactive	),	//????生效时机控制//chunk总开关，未同步，未经过生效时机控制，0)leader：52  trailer：32     1)leader：52  trailer：36
	.i_framebuffer_empty		(i_framebuffer_empty),	////framebuffer后端FIFO空标志，高电平有效，clk_gpif时钟域
	.iv_payload_size			(iv_payload_size	),	//payload_size大小寄存器，未同步，未经过生效时机控制
	.i_change_flag				(w_change_flag		),	//leader、payload、trailer中切换标志，每个包发送完成后切换
	.o_leader_flag				(w_leader_flag		),	//头包标志
	.o_trailer_flag				(w_trailer_flag		),	//尾包标志
	.o_payload_flag				(w_payload_flag		),	//负载包标志
	.o_chunkmodeactive			(w_chunkmodeactive	),	//经过生效时机控制的chunk开关
	.ov_packet_size				(wv_packet_size		)	//当前包所对应的包大小
	);
endmodule