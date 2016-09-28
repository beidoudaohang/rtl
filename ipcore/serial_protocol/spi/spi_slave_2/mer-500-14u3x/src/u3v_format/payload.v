//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : payload
//  -- 设计者       : 张强
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 张强         :| 2014/11/28 9:56:10	:|  根据技术预研整理
//	-- 张强         :| 2015/7/09 15:40:02   :|  根据u3v1.01协议添加OVERRUN部分，对发送的数据进行统计
//	-- 张强         :| 2015/7/19 15:44:23   :|  chunk由从0开始修改为从1开始
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述
//              1)  : U3V格式payload模块，组合成符合U3V格式payload包,包含chunk信息
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module payload # (
	parameter			DATA_WD					= 32	,	//输入输出数据位宽，这里使用同一宽度
	parameter			SHORT_REG_WD 			= 16	,	//短寄存器位宽
	parameter			REG_WD 					= 32	,	//寄存器位宽
	parameter			LONG_REG_WD 			= 64		//长寄存器位宽
	)
	(
//  ===============================================================================================
//  第一部分：时钟复位
//  ===============================================================================================
	input							reset				,	//复位信号，高电平有效，像素时钟时钟域
	input							clk					,	//时钟信号，像素时钟时钟域，同内部像素时钟
//  ===============================================================================================
//  第二部分：行、场、数据、数据有效
//  ===============================================================================================

	input							i_image_flag		,	//负载包中的图像信息标志
	input							i_chunk_flag		,	//添加chunk信息标志
	input							i_data_valid		,	//数据通路输出的数据有效信号，标志32位数据为有效数据
	input		[DATA_WD-1:0]		iv_data				,	//数据通路拼接好的32bit数据，与数据有效对齐，与像素时钟对齐
//  ===============================================================================================
//  第三部分：控制寄存器、chunk信息和只读寄存器
//  ===============================================================================================
	input							i_chunk_mode_active	,	//chunk总开关，开关打开Payload Type使用为image extend chunk 类型，chunk关闭为image类型
	input							i_chunkid_en_ts		,	//时间戳chunk使能
	input							i_chunkid_en_fid	,	//frame id chunk使能
	input		[REG_WD-1:0]		iv_chunk_size_img	,	//图像长度，以字节为单位，当pixel format为8bit时，一个像素占一个字节，当pixel format 10 bit时，一个像素占用两个字节。
	input		[REG_WD-1:0]		iv_pixel_format		,	//图像像素格式，影像图像大小
	input		[LONG_REG_WD-1	:0]	iv_timestamp		, 	//头包中的时间戳字段
	input		[LONG_REG_WD-1	:0]	iv_blockid			,	//头包、chunk、尾包的blockid信息，第一帧的block ID从0开始计数，第一帧block ID为0
	input							i_stream_enable		,	//流使能信号，像素时钟时钟域，=0，后端流立即停止，chunk中的BLOCK ID为0
//  ===============================================================================================
//  第四部分：行、数据有效、数据
//  ===============================================================================================
	output  reg [REG_WD-1       :0]	ov_valid_payload_size	,	//有效的图像数据
	output	reg	[15				:0] ov_status			,	//添加到尾包的状态寄存器
	output	reg						o_data_valid		,	//添加完payload和chunk的数据有效信号
	output	reg	[DATA_WD-1:0]		ov_data					//payload和chunk数据
	);
//  ===============================================================================================
//  本地参数
//  ===============================================================================================
	localparam						CHUNK_LENTH		=	4'd10	;	//chunk长度10
	localparam						FID_LENTH		=	32'H8	;	//frameid 长度
	localparam						TS_LENTH		=	32'H8	;	//timestamp 长度
//  ===============================================================================================
//  线网和寄存器定义
//  ===============================================================================================
	reg			[3				:0]	count           = 	4'h0	;	//计数器，用来添加CHUNK的内容
	reg								chunk_valid		=	1'b0	;	//chunk数据有效标志
	reg			[DATA_WD-1		:0]	chunk_data					;	//chun数据
	reg 		[REG_WD-1       :0]	payload_cnt					;	//发送图像大小计数器
	reg 		[1				:0]	image_flag_shift	=2'b00	;
	reg 							format8_sel					;	//数据占用1个字节还是两个字节
	reg 		[REG_WD-1       :0]	act_payload_cnt				;	//发送图像大小计数器
	reg 		[REG_WD-1       :0]	wv_valid_payload_size_m		;	//有效的图像数据
	reg			[1				:0]	stream_enable_shift	=2'b00	;	//流使能移位寄存器
	reg								chunk_mode_active_m	=1'b0	;	//
	reg								chunkid_en_ts_m		=1'b0	;	//
	reg								chunkid_en_fid_m	=1'b0	;	//
//  ===============================================================================================
//  生效时机控制内计数
//  ===============================================================================================

	always @ (posedge clk) begin
		stream_enable_shift	<=	{stream_enable_shift[0],i_stream_enable};
	end

	always @ (posedge clk) begin
		if( stream_enable_shift == 2'b01  )
			begin
				chunk_mode_active_m	<=	i_chunk_mode_active	;
				chunkid_en_ts_m		<=	i_chunkid_en_ts		;
				chunkid_en_fid_m	<=  i_chunkid_en_fid	;
			end
	end

//  ===============================================================================================
//  i_chunk_flag内计数
//  ===============================================================================================
	always @ (posedge clk) begin
		if(i_chunk_flag) begin
			count	<=	count + 4'h1;
		end
		else begin
			count	<=	4'h0;
		end
	end
//  ===============================================================================================
//  构造chunk信号
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//  构造chunk内容
//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if ( reset )
			chunk_data	<= 	32'h0;
		else  begin
				case ( count )
					4'h1	:	chunk_data	<=	32'h1						;
					4'h2	:   chunk_data	<=	iv_chunk_size_img			;
					4'h3	:   chunk_data	<=	iv_blockid[31:0]			;
					4'h4	:   chunk_data	<=	iv_blockid[63:32]			;
					4'h5	:   chunk_data	<=	32'h2						;
					4'h6	:   chunk_data	<=	FID_LENTH					;
					4'h7	:   chunk_data	<=	iv_timestamp[31:0]			;
					4'h8	:   chunk_data	<=	iv_timestamp[63:32]			;
					4'h9	:   chunk_data	<=	32'h3						;
					4'ha	:   chunk_data	<=	TS_LENTH					;
					default	:  	chunk_data	<= 	32'h0						;
				endcase
			end
	end
//  -------------------------------------------------------------------------------------
//  构造chunk有效标志
//  通过判断使能位控制有效标志的输出，如果不使能，则输出无效，数据也就不能输出
//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if ( reset )
			chunk_valid <= 	1'b0;
		else  begin
			case ( count )
				4'h1	:	chunk_valid	<=	chunk_mode_active_m						;
				4'h2	:   chunk_valid	<=	chunk_mode_active_m						;
				4'h3	:   chunk_valid	<=	chunk_mode_active_m	&chunkid_en_fid_m	;
				4'h4	:   chunk_valid	<=	chunk_mode_active_m	&chunkid_en_fid_m	;
				4'h5	:   chunk_valid	<=	chunk_mode_active_m	&chunkid_en_fid_m	;
				4'h6	:   chunk_valid	<=	chunk_mode_active_m	&chunkid_en_fid_m	;
				4'h7	:   chunk_valid	<=	chunk_mode_active_m	&chunkid_en_ts_m	;
				4'h8	:   chunk_valid	<=	chunk_mode_active_m	&chunkid_en_ts_m	;
				4'h9	:   chunk_valid	<=	chunk_mode_active_m	&chunkid_en_ts_m	;
				4'ha	:   chunk_valid	<=	chunk_mode_active_m	&chunkid_en_ts_m	;
				default	:  	chunk_valid <= 	1'b0									;
			endcase
		end
	end
//  ===============================================================================================
//  数据输出
//  ===============================================================================================
	always @ (posedge clk ) begin
		if ( reset )begin
			o_data_valid	<=	1'b0	;
			ov_data			<=	32'h0	;
		end
		else if ( i_image_flag && i_data_valid ) begin
			o_data_valid	<=	1'b1	;
			ov_data			<=	iv_data	;
		end
		else if ( chunk_valid ) begin
			o_data_valid	<=	1'b1	;
			ov_data			<=	chunk_data	;
		end
		else begin
			o_data_valid	<=	1'b0	;
			ov_data			<=	32'h0	;
		end
	end

//  ===============================================================================================
//  数据计数，输出的图像数据期间的实际个数，与设置的iv_chunk_size_img比较判断是否overrun
//  ===============================================================================================
	always @ (posedge clk ) begin
		image_flag_shift	<= { image_flag_shift[0],i_image_flag };
	end
//	统计image_flag期间的数据有效个数
	always @ (posedge clk ) begin
		if ( reset )begin
			payload_cnt			<=	32'h0	;
		end
		else if (image_flag_shift == 2'b01 )begin
			payload_cnt			<=	32'h0	;
		end
		else if ( i_image_flag &i_data_valid )begin
			payload_cnt		<=	payload_cnt + 32'h1	;
		end
	end

//计算实际字节数
	always @ (posedge clk ) begin
		if ( image_flag_shift == 2'b10 )
			act_payload_cnt	<= payload_cnt<<2;
	end

//当实际字节数大于iv_chunk_size_img时说明数据溢出，需要置错误状态位
	always @ (posedge clk ) begin
		if( act_payload_cnt > iv_chunk_size_img ) begin
			ov_status	<= 16'hA101;
		end
		else begin
			ov_status	<= 16'H0000;
		end
	end

//取实际字节数与iv_chunk_size_img两个值中的最小值作为valid payloadsize
	always @ (posedge clk ) begin
		if( act_payload_cnt > iv_chunk_size_img ) begin
			wv_valid_payload_size_m	<= iv_chunk_size_img;
		end
		else begin
			wv_valid_payload_size_m	<= act_payload_cnt;
		end
	end

	always @ (posedge clk ) begin
		case({ i_chunk_mode_active,i_chunkid_en_ts,i_chunkid_en_fid })
			3'b100:	ov_valid_payload_size	<= wv_valid_payload_size_m + 8;
			3'b110:	ov_valid_payload_size	<= wv_valid_payload_size_m + 24;
			3'b101:	ov_valid_payload_size	<= wv_valid_payload_size_m + 24;
			3'b111:	ov_valid_payload_size	<= wv_valid_payload_size_m + 40;
			default:ov_valid_payload_size	<= wv_valid_payload_size_m;
		endcase
		end
endmodule