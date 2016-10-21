//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : packet_switch
//  -- 设计者       : 张强、周金剑
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 张强         :| 2014/12/1 10:31:08	:|  根据技术预研整理
//  -- 张强         :| 2015/10/25 11:35:35	:|  帧存port口位宽改为64bits后，修改leader包和trailer
//												包对应的长度，按照8字节上取整。
//  -- 周金剑       :| 2016/9/22 14:29:57	:|  修改为支持multi-roi的版本
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
	parameter										REG_WD 				=	32,	//寄存器位宽
	parameter										MROI_MAX_NUM 		= 	8	//Multi-ROI的最大个数
	)
	(
	//  ===============================================================================================
	//  第一部分：时钟复位
	//  ===============================================================================================
	input											clk						,	//时钟信号，clk_gpif时钟域
	input											reset					,	//复位信号，高电平有效，clk_gpif时钟域
	//  ===============================================================================================
	//  第二部分：配置寄存器
	//  ===============================================================================================
	input											i_chunkmodeactive		,	//chunk总开关，clk_gpif时钟域,未经过生效时机控制，0)leader：52  trailer：32     1)leader：52  trailer：36
	input											i_framebuffer_empty		,	//framebuffer后端FIFO空标志，高电平有效，clk_gpif时钟域,
	//  ===============================================================================================
	//  第三部分：multi-roi
	//  ===============================================================================================
	input											i_multi_roi_total_en	,	//multi-roi总开关，1-multi-roi模式，0-single-roi模式
	input		[7							:0]		iv_roi_num				,	//u3_transfer模块从leader提取的roi的num号	
	input		[REG_WD*MROI_MAX_NUM-1	:0]			iv_payload_size_mroi	,	//multi-roi模式下roi1-roi7的payload_size的集合
	//  ===============================================================================================
	//  第四部分：标志信号
	//  ===============================================================================================
	input											i_change_flag			,	//leader、payload、trailer中切换标志，每个包发送完成后切换	                                    		
	output	reg										o_leader_flag			,	//头包标志
	output	reg										o_trailer_flag			,	//尾包标志
	output	reg										o_payload_flag			,	//负载包标志
	output	reg	[REG_WD-1					:0] 	ov_packet_size				//当前包所对应的包大小
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
	reg			[2							:0] current_state			;
	reg			[2							:0] next_state				;
	reg											multi_roi_total_en_reg	;
	reg											chunkmodeactive			;
	reg			[REG_WD-1					:0] payload_size_temp		;
	reg			[REG_WD-1					:0] payload_size_mroi_reg	[MROI_MAX_NUM-1:0];
	//  ===============================================================================================
	//  生效时机控制,停采时生效
	//  ===============================================================================================
	always @ (posedge clk)begin
		if(reset)begin
			chunkmodeactive 		<=	i_chunkmodeactive	;
			multi_roi_total_en_reg	<=	i_multi_roi_total_en;
		end
	end
	
	genvar i;
	generate
		for(i=0;i<MROI_MAX_NUM;i=i+1) begin:U
			always @ (posedge clk)begin
				if(reset)
					payload_size_mroi_reg[i]	<=	iv_payload_size_mroi[REG_WD*(i+1)-1:REG_WD*i];
			end
		end
	endgenerate
		
	//  ===============================================================================================
	//  选择输出payload_size
	//	1、single-roi时，直接使用iv_payload_size
	//	2、multi-roi时，根据iv_roi_num选择输出
	//	roi0对应iv_payload_size
	//	roi(n)对应payload_size_mroi_reg[n*REG_WD-1:(n-1)*REG_WD]
	//  ===============================================================================================
	always @ (posedge clk)begin
		if(~multi_roi_total_en_reg)begin
			payload_size_temp	<=	payload_size_mroi_reg[0];
		end
		else begin
			case(iv_roi_num)
				0	: begin
					payload_size_temp	<=	payload_size_mroi_reg[0];
				end
				1	: begin
					payload_size_temp	<=	payload_size_mroi_reg[1];
				end
				2	: begin
					payload_size_temp	<=	payload_size_mroi_reg[2];
				end                                                       
				3	: begin                                               
					payload_size_temp	<=	payload_size_mroi_reg[3];
				end                                                
				4	: begin                                        
					payload_size_temp	<=	payload_size_mroi_reg[4];
				end                                                
				5	: begin                                        
					payload_size_temp	<=	payload_size_mroi_reg[5];
				end                                                
				6	: begin                                        
					payload_size_temp	<=	payload_size_mroi_reg[6];
				end                                                       
				7	: begin                                               
					payload_size_temp	<=	payload_size_mroi_reg[7];
				end                                                       
				default	: begin                                           
					payload_size_temp	<=	payload_size_mroi_reg[0];                                                     
				end
			endcase				
		end
	end
	//  ===============================================================================================
	//  状态机
	//	分为四个状态；空闲状态、头包状态、负载包状态、尾包状态，每个状态输出对应的标志和包大小寄存器
	//	复位回到IDLE状态
	//	i_framebuffer_empty,fifo非空跳出IDLE状态
	//	i_change_flag，标志到来切换状态
	//  ===============================================================================================
	always @ (posedge clk)begin
		if(reset)
	   		current_state <= IDLE;
		else
	   		current_state <= next_state;
	end

	always @ * begin
	    next_state = IDLE;
	    case(current_state)
			IDLE	:begin
				if (!i_framebuffer_empty)			//因为完全和前端隔离，只能选后端FIFO非空作为启动条件
					next_state = LEADER;
				else
					next_state = IDLE;
			end
			LEADER	:begin							//i_change_flag轮流切换标志			
				if (i_change_flag)
					next_state = PAYLOAD;
				else
					next_state = LEADER;
			end
			PAYLOAD	:begin							//i_change_flag轮流切换标志			
				if (i_change_flag)
					next_state = TRAILER;
				else
					next_state = PAYLOAD;
			end
			TRAILER	:begin							//i_change_flag轮流切换标志		
				if (i_change_flag)
					next_state = IDLE;
				else
					next_state = TRAILER;
			end
	    endcase
	end

	always @ (posedge clk)begin
		if(reset)begin								//输出信号赋初值
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
			case(next_state)
				LEADER	:begin					
					o_leader_flag	<=	1'b1;
					ov_packet_size	<=	32'h34;		//leader时，每1个clk写入64bits（8bytes），写入52byte需要7clks，所以多写入4个bytes
				end
				PAYLOAD	:begin					
					o_payload_flag	<=	1'b1;
					ov_packet_size	<=	payload_size_temp;
				end
				TRAILER	:begin				
					o_trailer_flag	<=	1'b1;
					if (chunkmodeactive)
						ov_packet_size	<=	32'h24;	//chunk打开时trailer长度36，每1个clk写入64bits（8bytes），所以实际写入40bytes
					else
						ov_packet_size	<=	32'h20;	//chunk关闭时trailer长度32
				end
				default	:;
			endcase
		end
	end
	
endmodule