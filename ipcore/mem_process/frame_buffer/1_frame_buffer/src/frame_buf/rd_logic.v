//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : rd_logic
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2013/6/13 14:33:26	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :	读逻辑模块
//              1)  : 将MCB RD FIFO 中的数据搬移到后级FIFO之中
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

module rd_logic # (
	parameter		RD_WR_WITH_PRE		= "FALSE"	,//read write command end with precharge command
	parameter		DDR3_MEM_DENSITY	= "1Gb"		//DDR3 容量 "1Gb" "512Mb"
	)
	(
	//工作时钟和复位
	input						clk					,
	input						reset				,
	//外部控制信号
	input	[2:0]				iv_frame_depth		,//帧缓存深度，已同步
	input	[22:0]				iv_frame_size		,//帧缓存大小，已同步
	input						i_frame_en			,//使能开关，已同步，高有效
	//后级FIFO
	output						o_buf_rst			,//后级FIFO复位，高有效
	output	[32:0]				ov_buf_din			,//后级FIFO数据输入，33bit
	output						o_buf_wr_en			,//后级FIFO写使能，高有效
	input						i_buf_pf			,//后级FIFO编程满，高有效
	input						i_buf_empty			,//后级FIFO空，高有效
	input						i_buf_dout32		,//后级FIFO数据MSB
	//rd logic
	output	[1:0]				ov_rd_frame_ptr		,//读指针
	output						o_rd_req			,//读请求，高有效
	input						i_rd_ack			,//读允许，高有效
	output						o_reading			,//正在读，高有效
	//wr logic
	input	[1:0]				iv_wr_frame_ptr		,//写指针
	input	[16:0]				iv_wr_addr			,//写地址
	input						i_writing			,//正在写信号
	//MCB FIFO
	input						i_calib_done		,//MCB校准完成，高有效
	output						o_p3_cmd_en			,//MCB CMD 写使能，高有效
	output	[2:0]				ov_p3_cmd_instr		,//MCB CMD 指令
	output	[5:0]				ov_p3_cmd_bl		,//MCB CMD 突发长度
	output	[29:0]				ov_p3_cmd_byte_addr	,//MCB CMD 起始地址
	input						i_p3_cmd_empty		,//MCB CMD 空，高有效
	input						i_p3_cmd_full		,//MCB CMD 满，高有效
	output						o_p3_rd_en			,//MCB RD FIFO 写使能，高有效
	input	[31:0]				iv_p3_rd_data		,//MCB RD FIFO 数据输出
	input						i_p3_rd_full		,//MCB RD FIFO 满，高有效
	input						i_p3_rd_empty		,//MCB RD FIFO 空，高有效
	input						i_p3_rd_overflow	,//MCB RD FIFO 溢出，高有效
	input						i_p3_rd_error		,//MCB RD FIFO 出错，高有效
	input						i_p2_cmd_empty		//MCB CMD 空，高有效
	);

	//	ref signals

	//FSM Parameter Define
	parameter	S_IDLE		= 3'd0;
	parameter	S_REQ		= 3'd1;
	parameter	S_CMD		= 3'd2;
	parameter	S_RD		= 3'd3;
	parameter	S_CHK		= 3'd4;

	reg		[2:0]	current_state;
	reg		[2:0]	next_state;

	//FSM for sim
	// synthesis translate_off
	integer			state_ascii;
	always @ ( * ) begin
		case(current_state)
			3'd0 :	state_ascii	<= "S_IDLE";
			3'd1 :	state_ascii	<= "S_REQ";
			3'd2 :	state_ascii	<= "S_CMD";
			3'd3 :	state_ascii	<= "S_RD";
			3'd4 :	state_ascii	<= "S_CHK";
		endcase
	end
	// synthesis translate_on

	reg		[1:0]					calib_done_shift 	= 2'b0;
	reg		[2:0]					frame_depth_reg 	= 3'b0;
	reg		[22:0]					frame_size_reg 		= 23'b0;
	reg								frame_done_reg 		= 1'b0;
	reg								p2_cmd_empty 		= 1'b0;
	reg								p2_cmd_empty_sync 	= 1'b0;
	wire							fifo_rd_int			;
	reg								writing_d 			= 1'b0;
	wire							writing_rise		;
	reg								reading_d 			= 1'b0;
	reg								reading 			= 1'b0;
	wire							reading_rise		;
	reg								fresh_frame 		= 1'b0;
	reg								able_to_read 		= 1'b0;
	reg		[1:0]					rd_frame_ptr 		= 2'b0;

	reg								able_to_burst		;
	reg								fifo_rd_reg 		= 1'b0;
	reg		[5:0]					word_cnt 			= 6'b111111;
	reg		[16:0]					rd_addr 			= 17'b0;
	wire							ctrl_bit			;
	reg								rd_req_reg 			= 1'b0;
	reg								reading_reg 		= 1'b0;
	reg								addr_less 			= 1'b0;
	wire							frame_en_int		;
	reg								rd_cmd_reg 			= 1'b0;
	reg								buf_empty 			= 1'b0;
	reg								buf_empty_sync 		= 1'b0;
	reg								buf_dout32 			= 1'b0;
	reg								buf_dout32_sync 	= 1'b0;

	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//  异步信号采样
	//  -------------------------------------------------------------------------------------

	//只在一帧开始的时候采样配置信息
	//复位后，帧缓存深度为1。帧缓存深度是有外部控制的，需要外部提供一个初始值。
	//当外部配置的数值不是 1 2 4时，采用上一次正确配置的数值。
	always @ (posedge clk) begin
		if(reset) begin
			frame_depth_reg		<= 3'b001;
		end
		else begin
			if(current_state == S_IDLE) begin
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

	//	//帧缓存大小
	//	always @ (posedge clk) begin
	//		frame_size_d		<= iv_frame_size;
	//	end
	//只在一帧开始的时候采样配置信息
	always @ (posedge clk) begin
		if(current_state == S_IDLE) begin
			frame_size_reg	<= iv_frame_size;
		end
		else if(fifo_rd_int == 1'b1) begin			//如果有残包也可以继续计数，此时该计数器已经无用了
			frame_size_reg	<= frame_size_reg - 1'b1;
		end
	end

	//MCB P2 CMD 空信号
	always @ (posedge clk) begin
		p2_cmd_empty		<= i_p2_cmd_empty;
		p2_cmd_empty_sync	<= p2_cmd_empty;
	end

	//后级FIFO空信号
	always @ (posedge clk) begin
		buf_empty		<= i_buf_empty;
		buf_empty_sync	<= buf_empty;
	end

	//一帧结束符号标志位
	always @ (posedge clk) begin
		buf_dout32		<= i_buf_dout32;
		buf_dout32_sync	<= buf_dout32;
	end

	//  -------------------------------------------------------------------------------------
	//  calib_done 属于 mcb drp clk 时钟域
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		calib_done_shift	<= {calib_done_shift[0],i_calib_done};
	end

	//  -------------------------------------------------------------------------------------
	//  内部处理过后的使能开关
	//  -------------------------------------------------------------------------------------
	assign	frame_en_int	= (current_state == S_IDLE) ? i_frame_en : 1'b1;

	//  -------------------------------------------------------------------------------------
	//  后级FIFO复位
	//	方法1	在接收到使能信号无效之后，要后级模块把数据都读走了，即后级模块先停
	//	方法2	帧缓存模块接收到使能信号之后，不管后级fifo情况如果，都会复位后级fifo
	//	方法3	只有主复位
	//  -------------------------------------------------------------------------------------
	//	//	**************方法1**************
	//	//	后级FIFO复位的两个条件
	//	//	1.主复位有效
	//	//	2.1 当读模块处于IDLE状态且此时使能信号为无效
	//	//	2.2 后级FIFO已经读空了
	//	//	2.3	后级模块已经把帧结尾读出来了
	//	//	2.2 2.3是保证在复位后级FIFO之前，后级模块把一帧的数据都读走了
	//	assign	o_buf_rst	= (~frame_en_int & buf_empty_sync & buf_dout32_sync) | reset;

	//	//	**************方法2**************
	//	//	不理会后级FIFO的状态，在空闲状态判断到使能取消，就会将后级FIFO清空
	//	assign	o_buf_rst	= ~frame_en_int;

	//	**************方法3**************
	assign	o_buf_rst	= reset;
	//  -------------------------------------------------------------------------------------
	//  单帧倒换逻辑中，当前帧是否有效信号。
	//  -------------------------------------------------------------------------------------
	//读写模块处于同一时钟域，判断writing的上升沿
	always @ (posedge clk) begin
		writing_d	<= i_writing;
	end
	assign	writing_rise	= (~writing_d) & i_writing;
	//判断reading的上升沿
	always @ (posedge clk) begin
		reading_d	<= reading_reg;
	end
	assign	reading_rise	= (~reading_d) & reading_reg;

	//帧可读信号
	always @ (posedge clk) begin
		if(frame_en_int == 1'b0) begin			//处于空闲状态且使能关闭，清零该信号
			fresh_frame	<= 1'b0;
		end
		else begin
			if(writing_rise == 1'b1) begin										//启动写了，那就有一帧可读
				fresh_frame	<= 1'b1;
			end
			else if(reading_rise == 1'b1) begin								//启动读了，那就无帧可读。读写不可能同时有效。
				fresh_frame	<= 1'b0;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//  在rd_ack的CYCLE内，根据读写的状态，判断是否能够读
	//  -------------------------------------------------------------------------------------
	//这一段要用组合逻辑，因为必须要在1CLK内作出帧倒换逻辑的判断
	always @ ( * ) begin
		case(frame_depth_reg)
			3'b001 :			//1 frame
			begin
				able_to_read		<= fresh_frame;						//1帧倒换，如果当前帧更新过，就可以读
			end
			3'b010,3'b100 :			//2 4 frames
			begin
				//实际工程，读指针能够进入写指针
				`ifndef	TERRIBLE_TRAFFIC
					if(rd_frame_ptr != iv_wr_frame_ptr) begin				//4帧倒换，读写指针不一样，可以读
						able_to_read	<= 1'b1;
					end
					else begin
						able_to_read	<= 1'b0;
					end
					//仿真最大带宽，读指针不能进入写指针，且读写同时开始。
				`elsif TERRIBLE_TRAFFIC
					if(rd_frame_ptr != iv_wr_frame_ptr) begin				//4帧倒换，读指针不能进入写指针
						if((rd_frame_ptr != (iv_wr_frame_ptr-1'b1))&&(addr_less == 1'b1)) begin
							able_to_read	<= 1'b1;
						end
						else begin
							able_to_read	<= 1'b0;
						end
					end
					else begin
						able_to_read	<= 1'b0;
					end
				`endif
			end
			default :
			begin
				able_to_read		<= 1'b0;
			end
		endcase
	end

	//	assign	ov_p3_cmd_byte_addr		= {{3'b0},rd_frame_ptr,rd_addr,{8'b0}};
	//  -------------------------------------------------------------------------------------
	//	UG388 pg63 对地址分布有详细的描述
	//	地址分布只与ddr3的大小有关
	//	每次读写的长度是256yte，因此，低8bit固定为0
	//	512Mb的大小，地址要减一位
	//  -------------------------------------------------------------------------------------
	generate
		if(DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p3_cmd_byte_addr	= {{4'b0},rd_frame_ptr,rd_addr[15:0],{8'b0}};
		end
		else begin
			assign	ov_p3_cmd_byte_addr	= {{3'b0},rd_frame_ptr,rd_addr[16:0],{8'b0}};
		end
	endgenerate

	//  -------------------------------------------------------------------------------------
	//  在rd_ack的CYCLE内，如果能够读，那么读指针累加
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(frame_depth_reg)
			3'b001 :
			rd_frame_ptr	<= 'b0;										//1帧倒换，读指针固定为全0
			3'b010 :													//2帧倒换
			if(frame_en_int == 1'b0) begin
				rd_frame_ptr	<= 'b0;									//开关关闭，读指针回到初始状态
			end
			else begin
				if((i_rd_ack == 1'b1)&&(able_to_read == 1'b1)) begin	//在ack的CYCLE内，且地址策略可以读
					rd_frame_ptr[1]	<= 1'b0;							//MSB固定为0
					rd_frame_ptr[0]	<= ~rd_frame_ptr[0];				//LSB取反，实现了自增
				end
			end
			3'b100 :													//4帧倒换
			if(frame_en_int == 1'b0) begin
				rd_frame_ptr	<= 'b0;									//开关关闭，读指针回到初始状态
			end
			else begin
				if((i_rd_ack == 1'b1)&&(able_to_read == 1'b1)) begin	//在ack的CYCLE内，且地址策略可以读
					rd_frame_ptr	<= rd_frame_ptr + 1'b1;				//读指针自增
				end
			end
			default :
			rd_frame_ptr	<= 'b0;
		endcase
	end
	assign	ov_rd_frame_ptr = rd_frame_ptr;

	//  -------------------------------------------------------------------------------------
	//  CMD FIFO
	//  -------------------------------------------------------------------------------------
	//判断读地址小于写地址的逻辑.读地址小于写地址，且这个写地址已经被MCB接收了。ff，提高时序性能，这里是关键路径。
	always @ (posedge clk) begin
		if((rd_addr[16:0] < iv_wr_addr[16:0])&&(p2_cmd_empty_sync == 1'b1)) begin
			addr_less	<= 1'b1;
		end
		else begin
			addr_less	<= 1'b0;
		end
	end

	//判断当前状态是否能发出读burst的逻辑
	always @ ( * ) begin
		case(frame_depth_reg)
			3'b001 :							//单帧倒换，如果此时也在写，读地址小于写地址时才能读
			if(i_writing == 1'b1) begin
				able_to_burst	<= addr_less;
			end
			else begin
				able_to_burst	<= 1'b1;
			end
			3'b010,3'b100 :							//2 4帧倒换，同一帧时，读地址需小于写地址。不同帧时，可以立即读。
			if(rd_frame_ptr == iv_wr_frame_ptr) begin
				if(i_writing == 1'b1) begin
					able_to_burst	<= addr_less;
				end
				else begin
					able_to_burst	<= 1'b1;
				end
			end
			else begin
				able_to_burst	<= 1'b1;
			end
			default :							//其他不认识的配置信息，不允许读
			able_to_burst	<= 1'b0;
		endcase
	end

	//这里不是关键路径，用组合逻辑，节省资源
	//	assign	cmd_en_int	= (current_state == S_CMD) ? (able_to_burst & ~i_p3_cmd_full & ~i_buf_pf) : 1'b0;
	//	assign	o_p3_cmd_en	= cmd_en_int;

	always @ (posedge clk) begin
		if(current_state == S_CMD) begin
			rd_cmd_reg	<= able_to_burst & ~i_p3_cmd_full & ~i_buf_pf;
		end
		else begin
			rd_cmd_reg	<= 1'b0;
		end
	end

	assign	o_p3_cmd_en		= rd_cmd_reg;
	assign	ov_p3_cmd_bl 	= 6'b111111;
	
	generate
		if(RD_WR_WITH_PRE=="TRUE") begin
			assign	ov_p3_cmd_instr	= 3'b011;	//read with auto precharge
		end
		else begin
			assign	ov_p3_cmd_instr	= 3'b001;	//read without auto precharge
		end
	endgenerate
	
	//  -------------------------------------------------------------------------------------
	//  transfer MCB RD FIFO
	//  -------------------------------------------------------------------------------------
	//当FIFO空了，不能再读，此处必须是组合逻辑
	assign	fifo_rd_int		= (current_state == S_RD) ? (~i_p3_rd_empty) : 1'b0;
	assign	o_p3_rd_en		= fifo_rd_int;

	//如果有残包，残留数据是不能写入后级FIFO的，因此要用frame_done_reg信号作处理
	//最后还要写入控制数据
	assign	o_buf_wr_en		= (fifo_rd_int & ~frame_done_reg) | ctrl_bit;

	//一帧写完了，在CHK状态，向后级FIFO写入控制符
	assign	ctrl_bit		= (current_state == S_CHK) ? frame_done_reg : 1'b0;

	//后级FIFO的有效位宽33位，最高位是控制数据标识符
	assign	ov_buf_din		= {ctrl_bit,iv_p3_rd_data};

	//  -------------------------------------------------------------------------------------
	//  读 MCB RD FIFO 计数器
	//  -------------------------------------------------------------------------------------
	//记录从MCB RD FIFO中转移了多少个数据
	always @ (posedge clk) begin
		if(current_state == S_IDLE) begin
			word_cnt	<= 6'b111111;
		end
		else if(fifo_rd_int == 1'b1) begin
			word_cnt	<= word_cnt + 1'b1;
		end
	end

	//当读出来最后一个数据的时候，信号有效
	always @ (posedge clk) begin
		if(current_state == S_IDLE) begin
			frame_done_reg	<= 1'b0;
		end
		else if((|frame_size_reg == 1'b0)&&(fifo_rd_int == 1'b1)) begin
			frame_done_reg	<= 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  RD ADDR
	//	每发出一个读burst命令，地址+1
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		//		if((i_rd_ack == 1'b1)&&(able_to_read == 1'b1)) begin	//在一帧开始的时候，清空计数器。在reading上升沿的时候，清零寄存器
		if(current_state == S_IDLE) begin	//在一帧开始的时候，清空计数器。在reading上升沿的时候，清零寄存器
			rd_addr	<= 'b0;
		end
		else if(rd_cmd_reg == 1'b1) begin
			rd_addr	<= rd_addr + 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  读请求逻辑，与JUDGE交互
	//	时序需要和说明文档中保持一致
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((current_state == S_REQ)&&(i_rd_ack == 1'b0)) begin
			rd_req_reg	<= 1'b1;
		end
		else begin
			rd_req_reg	<= 1'b0;
		end
	end
	assign	o_rd_req	= rd_req_reg;

	always @ (posedge clk) begin
		if(current_state == S_IDLE) begin
			reading_reg	<= 1'b0;
		end
		else if((i_rd_ack == 1'b1)&&(able_to_read == 1'b1)) begin
			reading_reg	<= 1'b1;
		end
	end
	assign	o_reading	= reading_reg;

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
			S_IDLE :
			//启动读一帧的程序需要满足三个条件
			//1 使能打开 2 后级fifo有足够的空间 3 DDR3校正完成了
			//4 able_to_read 允许读，加上这一条的原因是避免在 IDLE状态和REQ状态频繁跳转
			//一旦进入了读程序，只有读完了一帧数据或者复位 才会返回到IDLE状态
			if((i_frame_en == 1'b1)&&(i_buf_pf == 1'b0)&&(calib_done_shift[1] == 1'b1)&&(able_to_read == 1'b1)) begin
				next_state	<= S_REQ;
			end
			else begin
				next_state	<= S_IDLE;
			end

			//向JUDGE模块请求状态，读一帧的条件满足了，还不能开始读，要向JUDGE模块申请，目的是为了避免读写同时进入工作状态
			//当JUDGE模块允许读的时候，根据读写状态和帧倒换策略，判断是否有可读帧
			//able_to_read信号就是当前状态是否有可读帧的信号
			S_REQ :
			if((i_rd_ack == 1'b1)&&(able_to_read == 1'b1)) begin
				next_state	<= S_CMD;
			end
			else if((i_rd_ack == 1'b1)&&(able_to_read == 1'b0)) begin
				next_state	<= S_IDLE;
			end
			else begin
				next_state	<= S_REQ;
			end

			//如果有可读帧，那么就要开始读操作了。
			//发出读操作需满足3个条件
			//1 后级FIFO 有足够的空间 2 MCB CMD FIFO 没有满 3 当前的地址策略允许读操作
			//由于读指针可以进入写指针，所以必须保证读地址要小于写地址
			S_CMD :
			if((able_to_burst == 1'b1)&&(i_p3_cmd_full == 1'b0)&&(i_buf_pf == 1'b0)) begin
				next_state	<= S_RD;
			end
			else begin
				next_state	<= S_CMD;
			end

			//将MCB RD FIFO中的数据搬移到 后级 FIFO 中，每次搬移64个
			S_RD :
			if((word_cnt == 6'b111110)&&(fifo_rd_int == 1'b1)) begin		//将MCB RD FIFO中64组数据全部读出
				next_state	<= S_CHK;
			end
			else begin
				next_state	<= S_RD;
			end

			//一次读burst结束了，如果一帧数据已经读完了，那么就要返回IDLE。否则，继续读。
			S_CHK :
			if(frame_done_reg == 1'b1) begin								//判断是否已经读出了一帧的数据
				next_state	<= S_IDLE;
			end
			else begin
				next_state	<= S_CMD;
			end
			default :
			next_state	<= S_IDLE;
		endcase
	end


endmodule
