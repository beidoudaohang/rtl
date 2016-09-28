//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : packet_switch
//  -- 设计者       : 张强
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 张强         :| 2014/12/1 10:31:08	:|  根据技术预研整理
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述
//              1)  : 实现帧存模块后端FIFO读取，输出给U3_interface
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module packet_switch #(
	parameter			REG_WD 									=	32	//寄存器位宽
)
(
//  ===============================================================================================
//  第一部分：时钟复位
//  ===============================================================================================
	input								clk						,		//时钟信号，clk_gpif时钟域
	input								reset					,		//复位信号，高电平有效，clk_gpif时钟域

//  ===============================================================================================
//  第二部分：配置寄存器
//  ===============================================================================================

	input								i_chunkmodeactive		,		//chunk总开关，clk_gpif时钟域,未经过生效时机控制，0)leader：52  trailer：32     1)leader：52  trailer：36
	input								i_framebuffer_empty		,		//framebuffer后端FIFO空标志，高电平有效，clk_gpif时钟域,
	input		[REG_WD-1			:0] iv_payload_size			,		//payload_size大小寄存器，clk_gpif时钟域,未经过生效时机控制

//  ===============================================================================================
//  第三部分：标志信号
//  ===============================================================================================
	input								i_change_flag			,		//leader、payload、trailer中切换标志，每个包发送完成后切换
	output	reg							o_leader_flag			,		//头包标志
	output	reg							o_trailer_flag			,		//尾包标志
	output	reg							o_payload_flag			,		//负载包标志
	output	reg	[REG_WD-1			:0] ov_packet_size					//当前包所对应的包大小
);
//  ===============================================================================================
//  内部参数宏定义
//  ===============================================================================================
	localparam 			IMAGE_LEADER_LENGTH 					=	13		;	//IMAGE格式的LEADER大小
	localparam			IMAGE_TRAILER_LENGTH 					=	8		;	//IMAGE格式的TRAILER大小
    localparam     		IMAGE_EXTEND_CHUNK_LEADER_LENGTH  		=	13		;	//IMAGE_EXTEND_CHUNK格式的LEADER大小
    localparam     		IMAGE_EXTEND_CHUNK_TRAILER_LENGTH 		=	9		;	//IMAGE_EXTEND_CHUNK格式的TRAILER大小

 	localparam 			IDLE 									=	3'B000	;
 	localparam 			LEADER 									=	3'B001	;
 	localparam 			PAYLOAD									=	3'B010	;
 	localparam 			TRAILER									=	3'B100	;
//  ===============================================================================================
//  寄存器定义
//  ===============================================================================================
	reg			[2					:0] current_state		;
	reg			[2					:0] next_state			;
	reg     							w_chunkmodeactive	;
	reg			[REG_WD-1			:0] payload_size_reg	;
//  ===============================================================================================
//  生效时机控制,停采时生效
//  ===============================================================================================
	always @ ( posedge	clk )
	begin
		if ( reset )
			begin
				w_chunkmodeactive 	<= i_chunkmodeactive;
				payload_size_reg	<= iv_payload_size;
			end
	end
//  ===============================================================================================
//  状态机
//	分为四个状态；空闲状态、头包状态、负载包状态、尾包状态，每个状态输出对应的标志和包大小寄存
//  器
//	复位回到IDLE状态
//	i_framebuffer_empty,fifo非空跳出IDLE状态
//	i_change_flag，标志到来切换状态
//  ===============================================================================================
	always @ (posedge clk ) begin
		if(reset)
	   		current_state <= IDLE;
		else
	   		current_state <= next_state;
		end

	always @ * begin
	    next_state = IDLE;
	    case( current_state )
		IDLE:
			begin
				if ( !i_framebuffer_empty )		//因为完全和前端隔离，只能选后端FIFO非空作为启动条件
					next_state = LEADER;
				else
					next_state = IDLE;
			end
		LEADER:									//i_change_flag轮流切换标志
			begin
				if ( i_change_flag )
					next_state = PAYLOAD;
				else
					next_state = LEADER;
			end
		PAYLOAD:								//i_change_flag轮流切换标志
			begin
				if ( i_change_flag )
					next_state = TRAILER;
				else
					next_state = PAYLOAD;
			end
		TRAILER:								//i_change_flag轮流切换标志
			begin
				if ( i_change_flag )
					next_state = IDLE;
				else
					next_state = TRAILER;
			end
	    endcase
	end

	always @ (posedge clk ) begin
		if( reset ) begin						//输出信号赋初值
			o_leader_flag	<=	1'b0;
			o_trailer_flag	<=	1'b0;
			o_payload_flag	<=	1'b0;
			ov_packet_size	<=	32'h0;
		end
		else begin
			o_leader_flag	<=	1'b0;
			o_trailer_flag	<=	1'b0;
			o_payload_flag	<=	1'b0;
			ov_packet_size	<=	32'h0;
			case( next_state )
				LEADER:
					begin
					o_leader_flag	<=	1'b1;
					ov_packet_size	<=	32'h34;				//52
					end
				PAYLOAD:
					begin
					o_payload_flag	<=	1'b1;
					ov_packet_size	<=	payload_size_reg;
					end
				TRAILER:
					begin
					o_trailer_flag	<=	1'b1;
					if ( w_chunkmodeactive )
						ov_packet_size	<=	32'h24;			//chunk打开时trailer长度36
					else
						ov_packet_size	<=	32'h20;			//chunk关闭时trailer长度32
					end
				default	:;
			endcase
		end
	end
endmodule