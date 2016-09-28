//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : u3v_format
//  -- 设计者       : 张强
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 张强         :| 2014/11/28 9:56:10	:|  根据技术预研整理
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述
//              1)  : 在图像前端添加头包
//
//              2)  : 在图像中添加chunk组成PAYLOAD
//
//              3)  : 在图像尾部添加尾包
//
//				4)	: 头包中的行字节填充字段,我们不使用填充方案，该值固定为0,不支持chunk_layout_id 默认值为0
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module u3v_format #(
	parameter							DATA_WD			=32		,		//输入输出数据位宽，这里使用同一宽度
	parameter							SHORT_REG_WD 	=16		,		//短寄存器位宽
	parameter							REG_WD 			=32		,		//寄存器位宽
	parameter							LONG_REG_WD 	=64				//长寄存器位宽
	)
	(
	//  ===============================================================================================
	//  第一部分：时钟复位
	//  ===============================================================================================
	input								reset					,		//复位信号，高电平有效，像素时钟时钟域
	input								clk						,		//时钟信号，像素时钟时钟域，同内部像素时钟
	//  ===============================================================================================
	//  第二部分：行、场、数据、数据有效
	//  ===============================================================================================

	input								i_fval					,       //数据通路输出的场信号，像素时钟时钟域,fval的信号是经过数据通道加宽过的场信号，场头可以添加leader、并包含有效的图像数据，停采期间保持低电平
	input								i_data_valid			,		//数据通路输出的数据有效信号，标志32位数据为有效数据
	input		[DATA_WD-1			:0]	iv_data					,       //数据通路拼接好的32bit数据，与数据有效对齐，与像素时钟对齐
	//  ===============================================================================================
	//  第三部分：控制寄存器、chunk信息和只读寄存器
	//  ===============================================================================================
	input								i_stream_enable			,		//流使能信号，像素时钟时钟域，=0，后端流立即停止，chunk中的BLOCK ID为0
	input								i_acquisition_start     ,       //开采信号，像素时钟时钟域，=0，标志完整帧，需等添加完尾包后才能停止
	input		[REG_WD-1			:0]	iv_pixel_format         ,       //像素格式，用于添加在leader中,数据通路已做生效时机控制，本模块不需再进行生效时机控制
	input								i_chunk_mode_active     ,       //chunk总开关，开关打开Payload Type使用为image extend chunk 类型，chunk关闭为image类型
	input								i_chunkid_en_ts         ,       //时间戳chunk使能
	input								i_chunkid_en_fid        ,		//frame id chunk使能
	input		[REG_WD-1			:0]	iv_chunk_size_img       ,		//图像长度，以字节为单位，当pixel format为8bit时，一个像素占一个字节，当pixel format 10 bit时，一个像素占用两个字节。

	input		[LONG_REG_WD-1		:0]	iv_timestamp			, 		//头包中的时间戳字段,由控制通道传送过来,iv_timestamp在场信号上升沿8个时钟之后才能稳定
	input		[SHORT_REG_WD-1		:0]	iv_size_x				, 		//头包中的窗口宽度
	input		[SHORT_REG_WD-1		:0]	iv_size_y				, 		//头包中的窗口高度
	input		[SHORT_REG_WD-1		:0]	iv_offset_x				, 		//头包中的水平偏移
	input		[SHORT_REG_WD-1		:0]	iv_offset_y				, 		//头包中的垂直便宜
	input		[REG_WD-1			:0]	iv_trailer_size_y		, 		//尾包中的有效高度字段
	//  ===============================================================================================
	//  第四部分：行、数据有效、数据
	//  ===============================================================================================
	output								o_trailer_flag          ,		//尾包标志
	output								o_fval					,       //添加完头尾的场信号，且需要场信号的上升沿领先第一个有效10个clk，下降沿要滞后于最后一个有效数据10个时钟以上，以保证帧存正常工作。
	output								o_data_valid			,       //添加完头尾的数据有效信号
	output		[DATA_WD-1			:0]	ov_data                         //
	);
	//  ===============================================================================================
	//  u3v_format_control例化：
	//  ===============================================================================================
	wire								w_leader_valid			;
	wire		[DATA_WD-1			:0]	wv_leader_data			;
	wire                                w_payload_valid         ;
	wire        [DATA_WD-1			:0]	wv_payload_data         ;
	wire                                w_trailer_valid         ;
	wire        [DATA_WD-1			:0]	wv_trailer_data         ;
	wire								w_leader_flag           ;
	wire								w_image_flag            ;
	wire								w_chunk_flag            ;
	wire        [LONG_REG_WD-1		:0]	wv_blockid              ;
	wire		[REG_WD-1			:0]	wv_valid_payload_size	;
	wire		[SHORT_REG_WD-1		:0]	wv_status				;
//  ===============================================================================================
//  u3v_format_control例化：
//  ===============================================================================================
	u3v_format_control # (
	.DATA_WD						(DATA_WD					),
	.SHORT_REG_WD					(SHORT_REG_WD				),
	.REG_WD 						(REG_WD						),
	.LONG_REG_WD					(LONG_REG_WD				)
	)
	u3v_format_control_inst(
	.reset							(reset						),	//复位信号，高电平有效，像素时钟时钟域
	.clk							(clk						),	//时钟信号，像素时钟时钟域，同内部像素时钟
	.i_fval							(i_fval						),	//数据通路输出的场信号，像素时钟时钟域,fval的信号是经过数据通道加宽过的场信号，场头可以添加leader、并包含有效的图像数据，停采期间保持低电平
	.i_leader_valid					(w_leader_valid				),	//添加完头的数据有效信号
	.iv_leader_data         		(wv_leader_data         	),	//头包数据
	.i_payload_valid				(w_payload_valid			),	//负载有效
	.iv_payload_data        		(wv_payload_data        	),	//负载数据
	.i_trailer_valid				(w_trailer_valid			),	//添加完头的数据有效信号
	.iv_trailer_data        		(wv_trailer_data        	),	//头包数据
	.i_chunk_mode_active			(i_chunk_mode_active		),	//chunk总开关
	.i_stream_enable				(i_stream_enable			),	//流使能信号，像素时钟时钟域，=0，chunk中的BLOCK ID为0
	.o_leader_flag					(w_leader_flag				),	//头包标志
	.o_image_flag					(w_image_flag				),	//负载包中的图像信息标志
	.o_chunk_flag					(w_chunk_flag				),	//添加chunk信息标志
	.o_trailer_flag         		(o_trailer_flag         	),	//尾包标志
	.ov_blockid						(wv_blockid					),	//头包、chunk、尾包的blockid信息，第一帧的block ID从0开始计数，第一帧block ID为0
	.o_fval							(o_fval						),	//添加完头尾和帧信息的场信号
	.o_data_valid					(o_data_valid				),	//添加完头尾的数据有效信号
	.ov_data                		(ov_data                	)	//满足U3V协议的数据包
	);
//  ===============================================================================================
//  leader例化：
//  ===============================================================================================
	leader # (
	.DATA_WD						(DATA_WD					),	//输入输出数据位宽，这里使用同一宽度
	.SHORT_REG_WD 					(SHORT_REG_WD 				),	//短寄存器位宽
	.REG_WD 						(REG_WD 					),	//寄存器位宽
	.LONG_REG_WD 					(LONG_REG_WD 				)	//长寄存器位宽
	)
	leader_inst(
	.reset							(reset						),	//复位信号，高电平有效，像素时钟时钟域
	.clk							(clk						),	//时钟信号，像素时钟时钟域，同内部像素时钟
	.i_leader_flag					(w_leader_flag				),	//头包标志
	.iv_pixel_format        		(iv_pixel_format        	),	//像素格式，用于添加在leader中
	.i_chunk_mode_active    		(i_chunk_mode_active    	),	//chunk总开关，开关打开Payload Type使用为image extend chunk 类型，chunk关闭为image类型
	.iv_blockid						(wv_blockid					),	//头包、chunk、尾包的blockid信息，第一帧的block ID从0开始计数，第一帧block ID为0
	.iv_timestamp					(iv_timestamp				),	//头包中的时间戳字段,iv_timestamp在场信号上升沿8个时钟之后才能稳定
	.iv_size_x						(iv_size_x					),	//头包中的窗口宽度
	.iv_size_y						(iv_size_y					),	//头包中的窗口高度
	.iv_offset_x					(iv_offset_x				),	//头包中的水平偏移
	.iv_offset_y					(iv_offset_y				),	//头包中的垂直便宜
	.o_data_valid					(w_leader_valid				),	//添加完头的数据有效信号
	.ov_data                		(wv_leader_data     		)	//头包数据
	);
//  ===============================================================================================
//  payload例化：
//  ===============================================================================================

	payload # (
	.DATA_WD						(DATA_WD					),	//输入输出数据位宽，这里使用同一宽度
	.SHORT_REG_WD 					(SHORT_REG_WD 				),	//短寄存器位宽
	.REG_WD 						(REG_WD 					),	//寄存器位宽
	.LONG_REG_WD 					(LONG_REG_WD 				)	//长寄存器位宽
	)
	payload_inst(
	.reset							(reset						),	//复位信号，高电平有效，像素时钟时钟域
	.clk							(clk						),	//时钟信号，像素时钟时钟域，同内部像素时钟
	.i_image_flag					(w_image_flag				),	//负载包中的图像信息标志
	.i_chunk_flag					(w_chunk_flag				),	//添加chunk信息标志
	.i_data_valid					(i_data_valid				),	//数据通路输出的数据有效信号，标志32位数据为有效数据
	.iv_data						(iv_data					),	//数据通路拼接好的32bit数据，与数据有效对齐，与像素时钟对齐
	.i_chunk_mode_active    		(i_chunk_mode_active    	),	//chunk总开关，开关打开Payload Type使用为image extend chunk 类型，chunk关闭为image类型
	.i_chunkid_en_ts        		(i_chunkid_en_ts        	),	//时间戳chunk使能
	.i_chunkid_en_fid       		(i_chunkid_en_fid       	),	//frame id chunk使能
	.iv_chunk_size_img      		(iv_chunk_size_img      	),	//图像长度，以字节为单位，当pixel format为8bit时，一个像素占一个字节，当pixel format 10 bit时，一个像素占用两个字节。
	.iv_pixel_format        		(iv_pixel_format        	),	//像素格式
	.iv_timestamp					(iv_timestamp				),	//时间戳
	.iv_blockid			        	(wv_blockid		            ),  //blockid
	.i_stream_enable				(i_stream_enable			),
	.ov_valid_payload_size			(wv_valid_payload_size		),	//有效图像数据，不含chunk，含像素格式
	.ov_status						(wv_status					),	//中间测试信号
	.o_data_valid					(w_payload_valid			),	//添加完payload和chunk的数据有效信号
	.ov_data                		(wv_payload_data        	)	//payload和chunk数据
	);
//  ===============================================================================================
//  trailer例化：
//  ===============================================================================================

	trailer #(
	.DATA_WD						(DATA_WD					),	//输入输出数据位宽，这里使用同一宽度
	.SHORT_REG_WD 					(SHORT_REG_WD 				),	//短寄存器位宽
	.REG_WD 						(REG_WD 					),	//寄存器位宽
	.LONG_REG_WD 					(LONG_REG_WD 				)	//长寄存器位宽
	)
	trailer_inst(
	.reset							(reset						),	//复位信号，高电平有效，像素时钟时钟域
	.clk							(clk						),	//时钟信号，像素时钟时钟域，同内部像素时钟
	.i_trailer_flag					(o_trailer_flag				),	//头包标志
	.i_chunk_mode_active    		(i_chunk_mode_active    	), 	//chunk总开关，开关打开Payload Type使用为image extend chunk 类型，chunk关闭为image类型
	.i_chunkid_en_ts        		(i_chunkid_en_ts        	),	//时间戳chunk使能
	.i_chunkid_en_fid       		(i_chunkid_en_fid       	),	//frame id chunk使能
	.iv_blockid						(wv_blockid					),	//头包、chunk、尾包的blockid信息，第一帧的block ID从0开始计数，第一帧block ID为0
	.iv_status						(wv_status					),	//尾包中的当前帧状态，对于帧存不存在丢失部分数据的情况，该状态为0
	.iv_valid_payload_size			(wv_valid_payload_size		),	//尾包中的有效负载大小字段
	.iv_trailer_size_y				(iv_size_y					),	//尾包中的有效高度字段
	.o_data_valid					(w_trailer_valid			),	//添加完头尾的数据有效信号
	.ov_data                		(wv_trailer_data        	) 	//
	);
endmodule