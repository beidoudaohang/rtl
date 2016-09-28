//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : wr_logic
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2013/6/3 16:03:55	:|  初始版本
//  -- 邢海涛       :| 2013/8/6 15:35:23	:|  去掉了 fval_fall_reg ，改为fval_shift[1]
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :	写逻辑模块
//              1)  : 将前级FIFO中的数据转移到MCB WR FIFO中
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//`include			"frame_buffer_def.v"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wr_logic # (
	parameter		RD_WR_WITH_PRE		= "FALSE"	,//read write command end with precharge command
	parameter		DDR3_MEM_DENSITY	= "1Gb"		//DDR3 容量 "1Gb" "512Mb"
	)
	(
	//工作时钟和复位
	input						clk					,
	input						reset				,
	//外部控制信号
	input	[2:0]				iv_frame_depth		,//帧缓存深度 可设置为 1 2 4
	input						i_frame_en			,//使能开关
	//场有效信号，图像时钟域
	input						i_fval				,//场有效信号，高有效，异步信号
	//前级FIFO
	input	[31:0]				iv_buf_dout			,//前级FIFO数据输出
	output						o_buf_rd_en			,//前级FIFO读使能，高有效
	input						i_buf_pe			,//前级FIFO编程空标志位，高有效
	input						i_buf_empty			,//前级FIFO空标志位，高有效
	//wr logic
	output	[1:0]				ov_wr_frame_ptr		,//写指针
	output	[16:0]				ov_wr_addr			,//写地址
	output						o_writing			,//正在写，高有效
	//judge
	output						o_wr_req			,//写请求，高有效
	input						i_wr_ack			,//写允许，高有效
	//rd logic
	input	[1:0]				iv_rd_frame_ptr		,//读指针
	input						i_reading			,//正在读，高有效
	//MCB FIFO
	input						i_calib_done		,//MCB校准完成信号，高有效
	output						o_p2_cmd_en			,//MCB CMD FIFO 写信号，高有效
	output	[2:0]				ov_p2_cmd_instr		,//MCB CMD FIFO 指令
	output	[5:0]				ov_p2_cmd_bl		,//MCB CMD FIFO 突发长度
	output	[29:0]				ov_p2_cmd_byte_addr	,//MCB CMD FIFO 起始地址
	input						i_p2_cmd_empty		,//MCB CMD FIFO 空信号，高有效
	input						i_p2_cmd_full		,//MCB CMD FIFO 满信号，高有效

	output						o_p2_wr_en			,//MCB WR FIFO 写信号，高有效
	output	[3:0]				ov_p2_wr_mask		,//MCB WR 屏蔽信号
	output	[31:0]				ov_p2_wr_data		,//MCB WR FIFO 写数据
	input						i_p2_wr_full		,//MCB WR FIFO 满信号，高有效
	input						i_p2_wr_empty		//MCB WR FIFO 空信号，高有效
	);

	//ref signals

	//FSM Parameter Define
	parameter	S_IDLE		= 2'd0;
	parameter	S_REQ		= 2'd1;
	parameter	S_WR		= 2'd2;
	parameter	S_CMD		= 2'd3;

	reg		[1:0]	current_state;
	reg		[1:0]	next_state;

	//FSM for sim
	// synthesis translate_off
	integer			state_ascii;
	always @ ( * ) begin
		case(current_state)
			2'd0 :	state_ascii	<= "S_IDLE";
			2'd1 :	state_ascii	<= "S_REQ";
			2'd2 :	state_ascii	<= "S_WR";
			2'd3 :	state_ascii	<= "S_CMD";
		endcase
	end
	// synthesis translate_on

	reg		[1:0]				calib_done_shift 	= 2'b0;
	reg		[2:0]				fval_shift 			= 3'b100;
	wire						fval_rise			;
	wire						fval_fall			;

	reg							buf_rd_reg 			= 1'b0;
	wire						buf_rd_int			;
	reg		[5:0]				word_cnt 			= 6'b111111;
	reg							cmd_en_reg 			= 1'b0;


	`ifdef	TERRIBLE_TRAFFIC			//如果定义了仿真开销最大的情况，写指针复位在10位置
		reg		[1:0]				wr_frame_ptr 		= 2'b01;
	`else
		reg		[1:0]				wr_frame_ptr 		= 2'b00;
	`endif

	reg		[16:0]				wr_addr 			= 17'b0;
	reg							able_to_write 		= 1'b0;
	reg							wr_req_reg 			= 1'b0;
	reg		[2:0]				frame_depth_d 		= 3'b0;
	reg		[2:0]				frame_depth_reg 	= 3'b0;
	reg							fval_rise_reg 		= 1'b0;
	wire						frame_en_int		;
	reg							writing 			= 1'b0;
	reg							wr_cmd_reg 			= 1'b0;


	//ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//  calib_done 属于 mcb drp clk 时钟域
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		calib_done_shift	<= {calib_done_shift[0],i_calib_done};
	end

	//  -------------------------------------------------------------------------------------
	//  场有效上升沿
	//  -------------------------------------------------------------------------------------

	//异步信号采样
	always @ (posedge clk) begin
		fval_shift	<= {fval_shift[1:0],i_fval};
	end

	assign	fval_rise	= (fval_shift[2:1] == 2'b01) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_shift[2:1] == 2'b10) ? 1'b1 : 1'b0;

	always @ (posedge clk) begin
		if(reset) begin
			fval_rise_reg	<= 1'b0;
		end
		else begin
			if(fval_rise == 1'b1) begin
				fval_rise_reg	<= 1'b1;
			end
			else if(fval_fall == 1'b1) begin
				fval_rise_reg	<= 1'b0;
			end
		end
	end

	//在场有效上升沿时采样 frame_depth
	//复位后，帧缓存深度为0。帧缓存深度是有外部控制的，需要外部提供一个初始值。
	//当外部配置的数值不是 1 2 4时，采用上一次正确配置的数值。
	always @ (posedge clk) begin
		if(reset) begin
			frame_depth_reg		<= iv_frame_depth;
		end else begin
			if(fval_rise == 1'b1) begin
				case(iv_frame_depth)
					3'b001 :
					frame_depth_reg		<= 3'b001;
					3'b010 :
					frame_depth_reg		<= 3'b010;
					3'b100 :
					frame_depth_reg		<= 3'b100;
					default :
					frame_depth_reg		<= frame_depth_reg;
				endcase
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//  内部处理过后的使能开关
	//  -------------------------------------------------------------------------------------
	assign	frame_en_int	= (current_state == S_IDLE) ? i_frame_en : 1'b1;

	//  -------------------------------------------------------------------------------------
	//  读前级FIFO
	//  -------------------------------------------------------------------------------------
	//必须考虑MCB WR FIFO 的满状态，
	assign	buf_rd_int		= (current_state == S_WR) ? (~i_buf_empty & ~i_p2_wr_full) : 1'b0;
	assign	o_buf_rd_en		= buf_rd_int;

	//在前级FIFO和MCB WR FIFO之间没有加流水线，目的是减少资源。33 FFs。实际上这里并不会是关键路径。
	assign	o_p2_wr_en		= buf_rd_int;
	assign	ov_p2_wr_data	= iv_buf_dout;
	assign	ov_p2_wr_mask	= 4'b0000;

	//一组burst的计数器，计满64个
	always @ (posedge clk) begin
		if(current_state == S_IDLE) begin		//在一帧开始的时候，清空计数器。与wr_adddr一同清零。
			word_cnt	<= 6'b111111;
		end
		else if(buf_rd_int == 1'b1) begin
			word_cnt	<= word_cnt + 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  CMD FIFO
	//  -------------------------------------------------------------------------------------
	//	assign	cmd_en_int	= (current_state == S_CMD) ? (~i_p2_cmd_full) : 1'b0;
	//	assign	o_p2_cmd_en	= cmd_en_int;	//用组合逻辑，减少了一个ff

	always @ (posedge clk) begin
		if((current_state == S_CMD)) begin
			wr_cmd_reg	<= ~i_p2_cmd_full;
		end
		else begin
			wr_cmd_reg	<= 1'b0;
		end
	end

	assign	o_p2_cmd_en	= wr_cmd_reg;

	generate
		if(RD_WR_WITH_PRE=="TRUE") begin
			assign	ov_p2_cmd_instr	= 3'b010;	//write with auto precharge
		end
		else begin
			assign	ov_p2_cmd_instr	= 3'b000;		//write without auto precharge
		end
	endgenerate

	assign	ov_p2_cmd_bl	= word_cnt;		//此处必须是word_cnt，当图像有残包的时候，不会将多余的数据写入DDR

	//  -------------------------------------------------------------------------------------
	//  写地址逻辑
	//  -------------------------------------------------------------------------------------
	//每次写burst之后，地址累加
	always @ (posedge clk) begin
		if((i_wr_ack == 1'b1)&&(able_to_write == 1'b1)) begin		//在一帧开始的时候，清空计数器。在writing上升沿的时候，清零寄存器
			wr_addr	<= 'b0;
			//		end else if(cmd_en_int == 1'b1) begin
		end
		else if(wr_cmd_reg == 1'b1) begin
			wr_addr	<= wr_addr + 1;
		end
	end
	assign	ov_wr_addr	= wr_addr;

	//  -------------------------------------------------------------------------------------
	//  读请求逻辑
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((current_state == S_REQ)&&(i_wr_ack == 1'b0)) begin
			wr_req_reg	<= 1'b1;
		end
		else begin
			wr_req_reg	<= 1'b0;
		end
	end
	assign	o_wr_req	= wr_req_reg;

	always @ (posedge clk) begin
		if(current_state == S_IDLE) begin
			writing	<= 1'b0;
		end
		else if((i_wr_ack == 1'b1)&&(able_to_write == 1'b1)) begin
			writing	<= 1'b1;
		end
	end

	assign	o_writing	= writing;
	//  -------------------------------------------------------------------------------------
	//  写指针逻辑
	//  -------------------------------------------------------------------------------------

	//此次必须是组合逻辑
	always @ ( * ) begin
		case(frame_depth_reg)
			3'b001 :		//1 frame	当不读的时候，就可以写
			begin
				able_to_write		<= !i_reading;
			end
			3'b010 :		//2 frames	写不丢帧
			begin
				able_to_write		<= 1'b1;
			end
			3'b100 :		//4 frames	写不丢帧
			begin
				able_to_write		<= 1'b1;
			end
			default :
			begin
				able_to_write		<= 1'b0;					//配置错误，状态机不会往下跳转
			end
		endcase
	end

	assign	ov_wr_frame_ptr				= wr_frame_ptr;
	//	assign	ov_p2_cmd_byte_addr			= {{3'b0},wr_frame_ptr,wr_addr,{8'b0}};
	//  -------------------------------------------------------------------------------------
	//	UG388 pg63 对地址分布有详细的描述
	//	地址分布只与ddr3的大小有关
	//	每次读写的长度是256yte，因此，低8bit固定为0
	//	512Mb的大小，地址要减一位
	//  -------------------------------------------------------------------------------------
	generate
		if(DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p2_cmd_byte_addr	= {{4'b0},wr_frame_ptr,wr_addr[15:0],{8'b0}};
		end
		else begin
			assign	ov_p2_cmd_byte_addr	= {{3'b0},wr_frame_ptr,wr_addr[16:0],{8'b0}};
		end
	endgenerate

	always @ (posedge clk) begin
		case(frame_depth_reg)
			3'b001 :						//1 frame
			wr_frame_ptr	<= 'b0;
			3'b010 :						//2 frames
			if(frame_en_int == 1'b0) begin			//当处于IDLE状态且使能关闭的时候，指针复位
				wr_frame_ptr	<= 'b0;
			end
			else begin
				if(i_wr_ack == 1'b1) begin											//在写允许的cycle内移动写指针
					if(i_reading == 1'b1) begin
						if(wr_frame_ptr[0] == ~iv_rd_frame_ptr[0]) begin			//读模块正在读且要写的下一帧与读指针相同
							wr_frame_ptr[1]	<= 1'b0;								//2帧倒换，MSB固定为0
							wr_frame_ptr[0]	<= wr_frame_ptr[0];						//LSB不变，即实现了帧跨域
						end
						else begin												//读模块正在读且要写的下一帧与读指针不相同
							wr_frame_ptr[1]	<= 1'b0;								//2帧倒换，MSB固定为0
							wr_frame_ptr[0]	<= ~wr_frame_ptr[0];					//LSB取反，实现了+1操作
						end
					end
					else begin													//读模块不在读，写指针可以进入任意一帧
						wr_frame_ptr[1]	<= 1'b0;									//2帧倒换，MSB固定为0
						wr_frame_ptr[0]	<= ~wr_frame_ptr[0];						//LSB取反，实现了+1操作
					end
				end
			end
			3'b100 :						//4 frames
			if(frame_en_int == 1'b0) begin			//当处于IDLE状态且使能关闭的时候，指针复位
				`ifdef	TERRIBLE_TRAFFIC			//如果定义了仿真开销最大的情况，写指针复位在10位置
					wr_frame_ptr	<= 2'b01;
				`else
					wr_frame_ptr	<= 2'b00;
				`endif
			end
			else begin
				if(i_wr_ack == 1'b1) begin											//在写允许的cycle内移动写指针
					if(i_reading == 1'b1) begin
						if((wr_frame_ptr + 1) == iv_rd_frame_ptr) begin				//读模块正在读且要写的下一帧与读指针相同
							wr_frame_ptr	<= iv_rd_frame_ptr + 1;					//写地址=读地址+1，实现了帧跨域
						end
						else begin												//读模块正在读且要写的下一帧与读指针不相同
							wr_frame_ptr	<= wr_frame_ptr + 1;					//写地址自增
						end
					end
					else begin													//读模块不在读，写指针可以进入任意一帧
						wr_frame_ptr	<= wr_frame_ptr + 1;						//写地址自增
					end
				end
			end
			default :
			//			wr_frame_ptr	<= 'b0;		//帧缓存深度改变的时候，写指针不复位。只有使能取消的时候，才会复位。
			;
		endcase
	end

	//  -------------------------------------------------------------------------------------
	//	ref FSM 状态机逻辑
	//  -------------------------------------------------------------------------------------
	//FSM Sequential Logic
	always @ (posedge clk) begin
		if(reset == 1'b1) begin
			current_state	<= S_IDLE;
		end
		else begin
			current_state	<= next_state;
		end
	end

	//FSM Conbinatial Logic
	always @ ( * ) begin
		case(current_state)

			//开始一帧写操作的程序，需要满足一下三个条件
			//1 fval上升沿有效
			//2 前端FIFO中的数据不是很多
			//3 开关已经打开
			//4 DDR3校正完成
			//进入写状态之后，只有一帧写完了或者复位，才能回到IDLE状态
			S_IDLE :
			if((fval_rise_reg == 1'b1)&&(i_buf_pe == 1'b1)&&(i_frame_en == 1'b1)&&(calib_done_shift[1] == 1'b1)) begin
				next_state	= S_REQ;
			end
			else begin
				next_state	= S_IDLE;
			end

			//为了避免读写同时进入工作状态，需要JUDGE模块做处理
			//在ACK的1clk周期内作判断，根据当前的读写状态和帧倒换侧率，看是否有可读帧
			S_REQ :
			if((i_wr_ack == 1'b1)&&(able_to_write == 1'b1)) begin
				next_state	= S_WR;
			end
			else if((i_wr_ack == 1'b1)&&(able_to_write == 1'b0)) begin
				next_state	= S_IDLE;
			end
			else begin
				next_state	= S_REQ;
			end

			//前级FIFO，不空，就把数据转移到 MCB WR FIFO 中
			//每次写64组数据，启动一次burst
			//fval的下降沿认为是一帧的结束信号
			S_WR :
			if((word_cnt == 6'b111110)&&(buf_rd_int == 1'b1)) begin			//计数器满了，启动一次写burst
				next_state	= S_CMD;
				//			end else if((word_cnt == 6'b111111)&&(fval_fall_reg == 1'b1)&&(i_buf_empty == 1'b1)) begin	//计数器没有计数，但是一帧结束了，说明没有残包，返回空闲状态
			end
			else if((word_cnt == 6'b111111)&&(fval_shift[1] == 1'b0)&&(i_buf_empty == 1'b1)) begin	//计数器没有计数，但是一帧结束了，说明没有残包，返回空闲状态

				next_state	= S_IDLE;
				//			end else if((fval_fall_reg == 1'b1)&&(i_buf_empty == 1'b1)) begin	//计数器没有满，一帧已经结束，前端FIFO空了
			end
			else if((fval_shift[1] == 1'b0)&&(i_buf_empty == 1'b1)) begin	//计数器没有满，一帧已经结束，前端FIFO空了
				next_state	= S_CMD;
			end
			else begin
				next_state	= S_WR;
			end

			//当cmd fifo不满的时候，可以写命令
			S_CMD :
			if(i_p2_cmd_full == 1'b0) begin				//检查CMD FIFO的满标志位
				//				if((i_buf_empty == 1'b1)&&(fval_fall_reg == 1'b1)) begin			//前端FIFO空了并且下降沿也来了，说明一帧所有的数据都读完了，返回初始状态
				if((i_buf_empty == 1'b1)&&(fval_shift[1] == 1'b0)) begin			//前端FIFO空了并且场有效无效，说明一帧所有的数据都读完了，返回初始状态
					next_state	= S_IDLE;
				end
				else begin							//前端FIFO没有空，说明还有数据残留在FIFO中
					next_state	= S_WR;
				end
			end
			else begin
				next_state	= S_CMD;
			end
			default :
			next_state	= S_IDLE;
		endcase
	end



endmodule
