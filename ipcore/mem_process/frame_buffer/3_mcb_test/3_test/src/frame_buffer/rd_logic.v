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
//  -- 邢海涛       :| 2015/3/31 9:31:24	:|  1.修改注释
//												2.帧存深度可变，1帧-32帧，且每一帧最大容量跟随深度而变
//												3.添加使能信号，分别是完整帧停开采和立即停开采
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
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module rd_logic # (
	parameter		DATA_WIDTH			= 32		,	//数据宽度
	parameter		PTR_WIDTH			= 2			,	//读写指针的位宽，1-最大2帧 2-最大4帧 3-最大8帧 4-最大16帧 5-最大32帧
	parameter		RD_WR_WITH_PRE		= "FALSE"	,	//read write command end with precharge command
	parameter		DDR3_MEM_DENSITY	= "1Gb"		,	//DDR3 容量 "1Gb" "512Mb"
	parameter		FRAME_SIZE_WIDTH	= 25		,	//一帧大小位宽，当DDR3是1Gbit时，最大容量是128Mbyte，当mcb p3 口位宽是32时，25位宽的size计数器就足够了
	parameter		TERRIBLE_TRAFFIC	= "TRUE"		//读写最差的情况，TRUE-同时读写不同帧的同一地址，FALSE-同时读写同一帧的同一地址
	)
	(
	//工作时钟和复位
	input							clk					,	//时钟
	input							reset				,	//复位
	//外部控制信号
	input	[PTR_WIDTH-1:0]			iv_frame_depth		,	//帧缓存深度，已同步
	input	[FRAME_SIZE_WIDTH-1:0]	iv_frame_size		,	//帧缓存大小，已同步
	input							i_chunk_mode_active	,	//chunk开关
	input							i_start_full_frame	,	//使能开关，保证一帧完整操作
	input							i_start_quick		,	//使能开关，立即停
	//后级FIFO
	output							o_reset_back_buf	,	//后级FIFO复位，高有效
	output	[DATA_WIDTH:0]			ov_buf_din			,	//后级FIFO数据输入，33bit
	output							o_buf_wr_en			,	//后级FIFO写使能，高有效
	input							i_buf_pf			,	//后级FIFO编程满，高有效
	input							i_buf_full			,	//后级FIFO满，高有效
	input							i_buf_empty			,	//后级FIFO空，高有效
	input							i_buf_dout32		,	//后级FIFO数据MSB
	//rd logic
	output	[PTR_WIDTH-1:0]			ov_rd_frame_ptr		,	//读指针
	output							o_rd_req			,	//读请求，高有效
	input							i_rd_ack			,	//读允许，高有效
	output							o_reading			,	//正在读，高有效
	//wr logic
	input	[PTR_WIDTH-1:0]			iv_wr_frame_ptr		,	//写指针
	input	[18:0]					iv_wr_addr			,	//写地址
	input							i_writing			,	//正在写信号
	//MCB FIFO
	input							i_calib_done		,	//MCB校准完成，高有效
	output							o_p3_cmd_en			,	//MCB CMD 写使能，高有效
	output	[2:0]					ov_p3_cmd_instr		,	//MCB CMD 指令
	output	[5:0]					ov_p3_cmd_bl		,	//MCB CMD 突发长度
	output	[29:0]					ov_p3_cmd_byte_addr	,	//MCB CMD 起始地址
	input							i_p3_cmd_empty		,	//MCB CMD 空，高有效
	input							i_p3_cmd_full		,	//MCB CMD 满，高有效
	output							o_p3_rd_en			,	//MCB RD FIFO 写使能，高有效
	input	[DATA_WIDTH-1:0]		iv_p3_rd_data		,	//MCB RD FIFO 数据输出
	input							i_p3_rd_full		,	//MCB RD FIFO 满，高有效
	input							i_p3_rd_empty		,	//MCB RD FIFO 空，高有效
	input							i_p3_rd_overflow	,	//MCB RD FIFO 溢出，高有效
	input							i_p3_rd_error		,	//MCB RD FIFO 出错，高有效
	input							i_p2_cmd_empty			//MCB CMD 空，高有效
	);

	//	ref signals

	//FSM Parameter Define
	parameter	S_IDLE		= 2'd0;
	parameter	S_REQ		= 2'd1;
	parameter	S_CMD		= 2'd2;
	parameter	S_RD		= 2'd3;

	reg		[1:0]	current_state	= S_IDLE;
	reg		[1:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	reg		[199:0]		state_ascii;
	always @ ( * ) begin
		case(current_state)
			2'd0 :	state_ascii	<= "S_IDLE";
			2'd1 :	state_ascii	<= "S_REQ";
			2'd2 :	state_ascii	<= "S_CMD";
			2'd3 :	state_ascii	<= "S_RD";
		endcase
	end
	// synthesis translate_on

	//	-------------------------------------------------------------------------------------
	//	固定参数
	//	1.读指针复位值。
	//	--当模拟最差环境时，写指针的复位值是1。否则读指针的复位值是0。
	//	2.MCB写命令
	//	--默认不带precharge，会节省一些电量消耗
	//	-------------------------------------------------------------------------------------
	localparam	RD_FRAME_PTR_RESET_VALUE	= (TERRIBLE_TRAFFIC=="TRUE") ? 1 : 0;
	localparam	RD_CMD_INSTR				= (RD_WR_WITH_PRE=="TRUE") ? 3'b011 : 3'b001;

	reg		[1:0]					calib_done_shift 	= 2'b0;
	reg		[PTR_WIDTH-1:0]			frame_depth_reg 	= 1;
	reg								start_full_frame_int= 1'b0;
	wire							enable				;
	reg								enable_dly			= 1'b0;
	wire							enable_rise			;
	reg		[FRAME_SIZE_WIDTH-1:0]	frame_size_reg 		= {FRAME_SIZE_WIDTH{1'b0}};
	reg								frame_done_reg 		= 1'b0;
	wire							fifo_rd_int			;
	reg								writing_dly 		= 1'b0;
	wire							writing_rise		;
	reg								reading_dly 		= 1'b0;
	reg								reading 			= 1'b0;
	wire							reading_rise		;
	reg								fresh_frame 		= 1'b0;
	reg								able_to_read 		= 1'b0;
	reg		[PTR_WIDTH-1:0]			rd_frame_ptr 		= RD_FRAME_PTR_RESET_VALUE;
	reg								addr_less_int		= 1'b0;
	reg								fifo_rd_reg 		= 1'b0;
	reg		[5:0]					word_cnt 			= 6'b111111;
	reg		[18:0]					rd_addr 			= 19'b0;
	wire	[1:0]					ctrl_bit			;
	reg								rd_req_reg 			= 1'b0;
	reg								reading_reg 		= 1'b0;
	reg		[18:0]					wr_addr_sub 		= 19'b0;
	reg								addr_less 			= 1'b0;
	reg								rd_cmd_reg 			= 1'b0;
	reg								buf_dout32 			= 1'b0;
	reg								buf_dout32_sync 	= 1'b0;

	reg								back_buf_wr_en		= 1'b0;
	reg		[DATA_WIDTH:0]			back_buf_din		= {(DATA_WIDTH+1){1'b0}};


	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***延时 提取边沿***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  calib_done 属于 mcb drp clk 时钟域
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		calib_done_shift	<= {calib_done_shift[0],i_calib_done};
	end

	//	-------------------------------------------------------------------------------------
	//	判断writing的上升沿
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		writing_dly	<= i_writing;
	end
	assign	writing_rise	= (writing_dly==1'b0 && i_writing==1'b1) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	判断writing的上升沿
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		reading_dly	<= reading_reg;
	end
	assign	reading_rise	= (reading_dly==1'b0 && reading_reg==1'b1) ? 1'b1 : 1'b0;

	//	===============================================================================================
	//	ref ***寄存器生效时机***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	frame_depth_reg 帧存深度寄存器
	//	1.在空闲状态采样 frame_depth
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			frame_depth_reg		<= iv_frame_depth;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	帧缓存大小
	//	1.在idle状态采样配置信息
	//	--当打开chunk时，leader=52byte trailer=32byte
	//	--当关闭chunk时，leader=52byte trailer=36byte
	//	2.每发出一次读命令，计数器-1
	//	3.当最后一个burst读出的数据大于实际数据量时，frame size reg会溢出，但是已经输出了帧结束标志，溢出也就无所谓了
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			if(!i_chunk_mode_active) begin
				frame_size_reg	<= iv_frame_size + 8'd21 - 1'b1;
			end
			else begin
				frame_size_reg	<= iv_frame_size + 8'd22 - 1'b1;
			end
		end
		else if(fifo_rd_int==1'b1) begin
			frame_size_reg	<= frame_size_reg - 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  完整帧使能内部信号
	//	1.只在idle状态下采样完整帧使能信号
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			start_full_frame_int	<= i_start_full_frame;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	使能信号
	//	1.两个使能信号的与结果，作为最终的使能信号
	//  -------------------------------------------------------------------------------------
	assign	enable	= start_full_frame_int & i_start_quick;
	
	//  -------------------------------------------------------------------------------------
	//	使能信号 边沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		enable_dly	<= enable;
	end	
	assign	enable_rise	= (enable_dly==1'b0 && enable==1'b1) ? 1'b1 : 1'b0;
	
	//	===============================================================================================
	//	ref ***FIFO MCB 操作***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	读命令
	//	1.当处于读命令状态的时候，才可以发出读命令
	//	2.发出读命令的条件：
	//	--使能关闭或者一帧结束时，不发命令
	//	--其他情况下，当 地址不会叠加 且 p3 cmd fifo 不满 时，可以发命令
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_CMD) begin
			if(enable==1'b0 || frame_done_reg==1'b1) begin
				rd_cmd_reg	<= 1'b0;
			end
			else if(addr_less_int==1'b1 && i_p3_cmd_full==1'b0) begin
				rd_cmd_reg	<= 1'b1;
			end
			else begin
				rd_cmd_reg	<= 1'b0;
			end
		end
		else begin
			rd_cmd_reg	<= 1'b0;
		end
	end
	assign	o_p3_cmd_en		= rd_cmd_reg;

	//	-------------------------------------------------------------------------------------
	//	读长度
	//	1.每次读的长度固定为64
	//	2.帧尾最后一个burst，会多读出来数据，需要对这部分数据做处理
	//	-------------------------------------------------------------------------------------
	assign	ov_p3_cmd_bl 	= 6'b111111;

	//	-------------------------------------------------------------------------------------
	//	读指令
	//	1.根据参数定义，可以有2种命令方式
	//	-------------------------------------------------------------------------------------
	assign	ov_p3_cmd_instr	= RD_CMD_INSTR;

	//  -------------------------------------------------------------------------------------
	//	读地址
	//	1.UG388 pg63 对地址分布有详细的描述
	//	2.地址分布只与ddr3的大小有关
	//	3.每次读写的长度是256yte，因此，低8bit固定为0
	//	4.512Mb的大小，地址要减一位
	//	5.当帧存深度不一样时，每一帧可以缓存的最大容量是不同的
	//  -------------------------------------------------------------------------------------
	//	-------------------------------------------------------------------------------------
	//	最大帧存深度是2帧
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==1 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==1'd0) ? {{4'b0},rd_addr[17:0],{8'b0}} : 	//单帧
			{{4'b0},rd_frame_ptr[0],rd_addr[16:0],{8'b0}}	;			//2帧
		end
		else if(PTR_WIDTH==1 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==1'd0) ? {{3'b0},rd_addr[18:0],{8'b0}} : 	//单帧
			{{3'b0},rd_frame_ptr[0],rd_addr[17:0],{8'b0}}	;			//2帧
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	最大帧存深度是4帧
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==2 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==2'd0) ? {{4'b0},rd_addr[17:0],{8'b0}} : 					//单帧
			(frame_depth_reg==2'd1) ? {{4'b0},rd_frame_ptr[0],rd_addr[16:0],{8'b0}} : 	//2帧
			{{4'b0},rd_frame_ptr[1:0],rd_addr[15:0],{8'b0}}	;							//3 4 帧
		end
		else if(PTR_WIDTH==2 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==2'd0) ? {{3'b0},rd_addr[18:0],{8'b0}} : 					//单帧
			(frame_depth_reg==2'd1) ? {{3'b0},rd_frame_ptr[0],rd_addr[17:0],{8'b0}} : 	//2帧
			{{3'b0},rd_frame_ptr[1:0],rd_addr[16:0],{8'b0}}	;							//3 4 帧
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	最大帧存深度是8帧
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==3 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==3'd0) ? {{4'b0},rd_addr[17:0],{8'b0}} : 												//单帧
			(frame_depth_reg==3'd1) ? {{4'b0},rd_frame_ptr[0],rd_addr[16:0],{8'b0}} : 								//2帧
			(frame_depth_reg==3'd2 || frame_depth_reg==3'd3) ? {{4'b0},rd_frame_ptr[1:0],rd_addr[15:0],{8'b0}} :	//3 4 帧
			{{4'b0},rd_frame_ptr[2:0],rd_addr[14:0],{8'b0}};														//5 - 8 帧
		end
		else if(PTR_WIDTH==3 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==3'd0) ? {{3'b0},rd_addr[18:0],{8'b0}} : 												//单帧
			(frame_depth_reg==3'd1) ? {{3'b0},rd_frame_ptr[0],rd_addr[17:0],{8'b0}} : 								//2帧
			(frame_depth_reg==3'd2 || frame_depth_reg==3'd3) ? {{3'b0},rd_frame_ptr[1:0],rd_addr[16:0],{8'b0}} :	//3 4 帧
			{{3'b0},rd_frame_ptr[2:0],rd_addr[15:0],{8'b0}};														//5 - 8 帧
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	最大帧存深度是16帧
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==4 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==4'd0) ? {{4'b0},rd_addr[17:0],{8'b0}} : 												//单帧
			(frame_depth_reg==4'd1) ? {{4'b0},rd_frame_ptr[0],rd_addr[16:0],{8'b0}} : 								//2帧
			(frame_depth_reg==4'd2 || frame_depth_reg==4'd3) ? {{4'b0},rd_frame_ptr[1:0],rd_addr[15:0],{8'b0}} :	//3 4 帧
			(frame_depth_reg>=4'd4 && frame_depth_reg<=4'd7) ? {{4'b0},rd_frame_ptr[2:0],rd_addr[14:0],{8'b0}} :	//5 - 8 帧
			{{4'b0},rd_frame_ptr[3:0],rd_addr[13:0],{8'b0}};														//9 - 16 帧
		end
		else if(PTR_WIDTH==4 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==4'd0) ? {{3'b0},rd_addr[18:0],{8'b0}} : 												//单帧
			(frame_depth_reg==4'd1) ? {{3'b0},rd_frame_ptr[0],rd_addr[17:0],{8'b0}} : 								//2帧
			(frame_depth_reg==4'd2 || frame_depth_reg==4'd3) ? {{3'b0},rd_frame_ptr[1:0],rd_addr[16:0],{8'b0}} :	//3 4 帧
			(frame_depth_reg>=4'd4 && frame_depth_reg<=4'd7) ? {{3'b0},rd_frame_ptr[2:0],rd_addr[15:0],{8'b0}} :	//5 - 8 帧
			{{3'b0},rd_frame_ptr[3:0],rd_addr[14:0],{8'b0}};														//9 - 16 帧
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	最大帧存深度是32帧
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==5 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==5'd0) ? {{4'b0},rd_addr[17:0],{8'b0}} : 												//单帧
			(frame_depth_reg==5'd1) ? {{4'b0},rd_frame_ptr[0],rd_addr[16:0],{8'b0}} : 								//2帧
			(frame_depth_reg==5'd2 || frame_depth_reg==5'd3) ? {{4'b0},rd_frame_ptr[1:0],rd_addr[15:0],{8'b0}} :	//3 4 帧
			(frame_depth_reg>=5'd4 && frame_depth_reg<=5'd7) ? {{4'b0},rd_frame_ptr[2:0],rd_addr[14:0],{8'b0}} :	//5 - 8 帧
			(frame_depth_reg>=5'd8 && frame_depth_reg<=5'd15) ? {{4'b0},rd_frame_ptr[3:0],rd_addr[13:0],{8'b0}} :	//9 - 16 帧
			{{4'b0},rd_frame_ptr[4:0],rd_addr[12:0],{8'b0}};														//17 - 32 帧
		end
		else if(PTR_WIDTH==5 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p3_cmd_byte_addr	=
			(frame_depth_reg==5'd0) ? {{3'b0},rd_addr[18:0],{8'b0}} : 												//单帧
			(frame_depth_reg==5'd1) ? {{3'b0},rd_frame_ptr[0],rd_addr[17:0],{8'b0}} : 								//2帧
			(frame_depth_reg==5'd2 || frame_depth_reg==5'd3) ? {{3'b0},rd_frame_ptr[1:0],rd_addr[16:0],{8'b0}} :	//3 4 帧
			(frame_depth_reg>=5'd4 && frame_depth_reg<=5'd7) ? {{3'b0},rd_frame_ptr[2:0],rd_addr[15:0],{8'b0}} :	//5 - 8 帧
			(frame_depth_reg>=5'd8 && frame_depth_reg<=5'd15) ? {{3'b0},rd_frame_ptr[3:0],rd_addr[14:0],{8'b0}} :	//9 - 16 帧
			{{3'b0},rd_frame_ptr[4:0],rd_addr[13:0],{8'b0}};														//17 - 32 帧
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	mcb rd fifo 读条件
	//	1.处于rd状态
	//	2.mcb rd fifo 不空，后端fifo不满
	//	-------------------------------------------------------------------------------------
//	assign	fifo_rd_int		= (current_state==S_RD && i_p3_rd_empty==1'b0 && i_buf_full==1'b0) ? 1'b1 : 1'b0;
	assign	fifo_rd_int		= (current_state==S_RD && i_buf_full==1'b0) ? 1'b1 : 1'b0;
	assign	o_p3_rd_en		= fifo_rd_int;

	//  -------------------------------------------------------------------------------------
	//  MCB fifo 写信号
	//	1.与 mcb rd FIFO 读信号同源
	//	2.mcb rd FIFO具有 first word fall through的特点，当不空的时候，第一个数据已经放到端口上了
	//	3.由于最后一个burst有可能会有多余的数据读出来，因此要将多余的数据屏蔽，不能写入后端fifo中
	//	4.此外，还要写入控制位，以标识帧头帧尾
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((fifo_rd_int==1'b1 && frame_done_reg==1'b0) || ctrl_bit[1]==1'b1) begin
			back_buf_wr_en	<= 1'b1;
		end
		else begin
			back_buf_wr_en	<= 1'b0;
		end
	end
	assign	o_buf_wr_en	= back_buf_wr_en;

	//	-------------------------------------------------------------------------------------
	//	帧头帧尾的控制字符
	//	1.在一帧开始的时候，ctrl_bit=2'b11，表示帧头
	//	2.在一帧结尾的时候，ctrl_bit=2'b10，表示帧尾
	//	-------------------------------------------------------------------------------------
	assign	ctrl_bit		= (current_state==S_REQ && i_rd_ack==1'b1 && able_to_read==1'b1) ? 2'b11 :
	(current_state==S_CMD && (enable==1'b0 || frame_done_reg==1'b1)) ? 2'b10 : 2'b00;

	//	-------------------------------------------------------------------------------------
	//	后级FIFO数据
	//	1.位宽32+1，最高位是 image_valid. 1-图像数据 0-控制数据
	//	2.如果ctrl_bit[1]==1，说明是帧头帧尾的标志。
	//	--写入的数据的bit0表示帧头帧尾，bit0=1 - 帧头；bit0=0 - 帧尾
	//	3.如果ctrl_bit[1]==0，说明是像素数据。
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(ctrl_bit[1]) begin
			back_buf_din	<= {1'b0,{(DATA_WIDTH-1){1'b0}},ctrl_bit[0]};
		end
		else begin
			back_buf_din	<= {1'b1,iv_p3_rd_data};
		end
	end
	assign	ov_buf_din	= back_buf_din;

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
	//	assign	o_reset_back_buf	= (~frame_en_int & back_buf_empty_dly1 & buf_dout32_sync) | reset;

	//	//	**************方法2**************
	//	//	不理会后级FIFO的状态，在空闲状态判断到使能取消，就会将后级FIFO清空
	//	assign	o_reset_back_buf	= ~frame_en_int;

	//	**************方法3**************
	assign	o_reset_back_buf	= reset | enable_rise;

	//	===============================================================================================
	//	ref ***交互信号***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  读请求
	//	1.当处于req状态，且读允许=0时，发出读请求
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_REQ && i_rd_ack==1'b0) begin
			rd_req_reg	<= 1'b1;
		end
		else begin
			rd_req_reg	<= 1'b0;
		end
	end
	assign	o_rd_req	= rd_req_reg;

	//  -------------------------------------------------------------------------------------
	//  正在读
	//	1.当处于idle状态时，正在读信号清零
	//	2.当读允许时，读信号拉高
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			reading_reg	<= 1'b0;
		end
		else if(i_rd_ack==1'b1 && able_to_read==1'b1) begin
			reading_reg	<= 1'b1;
		end
	end
	assign	o_reading	= reading_reg;

	//	===============================================================================================
	//	ref ***帧追赶策略***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	减去4之后的写地址
	//	1.写 cmd fifo最多能缓冲4个命令，因此即便写端口发生了阻塞，将当前的写地址-4，读地址就不会超过写地址
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(iv_wr_addr[18:0]<4) begin
			wr_addr_sub	<= 19'b0;
		end
		else begin
			wr_addr_sub	<= iv_wr_addr - 4;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	地址判断
	//	1.当读写在同一帧的时候，读地址要小于写地址
	//	2.p2口空，说明已经把当前的读地址发送出去了
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(rd_addr[18:0] < wr_addr_sub[18:0]) begin
			addr_less	<= 1'b1;
		end
		else begin
			addr_less	<= 1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	处理后的地址判断
	//	1.当读写指针相同时，如果正在写，则addr_less_int更新
	//	2.当读写指针相同时，如果没在写，则可以任意读
	//	3.当读写指针不同时，则可以任意读
	//	-------------------------------------------------------------------------------------
	always @ ( * ) begin
		if(rd_frame_ptr==iv_wr_frame_ptr) begin
			if(i_writing) begin
				addr_less_int	<= addr_less;
			end
			else begin
				addr_less_int	<= 1'b1;
			end
		end
		else begin
			addr_less_int	<= 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  单帧倒换逻辑中，当前帧是否有效信号。
	//	1.当使能关闭或者帧存深度不是1帧时，fresh_frame清零
	//	2.其他情况下，在writing上升沿时，fresh_frame=1，表示有数据可读
	//	3.其他情况下，在reading上升沿时，fresh_frame=0，表示已经读取当前帧
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!enable || frame_depth_reg!=0) begin
			fresh_frame	<= 1'b0;
		end
		else begin
			if(writing_rise == 1'b1) begin
				fresh_frame	<= 1'b1;
			end
			else if(reading_rise == 1'b1) begin
				fresh_frame	<= 1'b0;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	当定义了严重拥堵时，不能同时读写同一帧
	//	-------------------------------------------------------------------------------------
	generate
		if(TERRIBLE_TRAFFIC=="TRUE") begin
			//	-------------------------------------------------------------------------------------
			//	读允许信号
			//	1.当帧存深度是单帧时，fresh_frame控制是否可以读新的一帧
			//	2.当帧存深度是多帧的时候，如果读指针!=写指针且读指针!=写指针-1，说明有新的数据可以读，并且不会进入到写指针中
			//	-------------------------------------------------------------------------------------
			always @ ( * ) begin
				if(frame_depth_reg==0) begin
					able_to_read		<= fresh_frame;
				end
				else begin
					if(rd_frame_ptr!=iv_wr_frame_ptr && rd_frame_ptr!=(iv_wr_frame_ptr-1'b1)) begin
						able_to_read	<= 1'b1;
					end
					else begin
						able_to_read	<= 1'b0;
					end
				end
			end
		end
		else begin
			//	-------------------------------------------------------------------------------------
			//	读允许信号
			//	1.当帧存深度是单帧时，fresh_frame控制是否可以读新的一帧
			//	2.当帧存深度是多帧的时候，如果读指针!=写指针，说明有新的数据可以读，就可以读新的一帧
			//	-------------------------------------------------------------------------------------
			always @ ( * ) begin
				if(frame_depth_reg==0) begin
					able_to_read		<= fresh_frame;
				end
				else begin
					if(rd_frame_ptr!=iv_wr_frame_ptr) begin
						able_to_read	<= 1'b1;
					end
					else begin
						able_to_read	<= 1'b0;
					end
				end
			end
		end
	endgenerate

	//	===============================================================================================
	//	ref ***数据、地址计数器***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	word_cnt 一组burst计数器
	//	1.一组burst的计数器，计满64个
	//	2.不需要再判断reset，因为reset=1，就会进入idle状态
	//	3.在一帧开始的时候，清空计数器。与rd_adddr一同清零。
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			word_cnt	<= 6'b111111;
		end
		else if(fifo_rd_int == 1'b1) begin
			word_cnt	<= word_cnt + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	一帧完成信号
	//	1.当处于idle时，frame_done_reg=0
	//	2.当所有数据都读完时，frame_done_reg=1
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			frame_done_reg	<= 1'b0;
		end
		else if(|frame_size_reg==1'b0 && fifo_rd_int==1'b1) begin
			frame_done_reg	<= 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  RD ADDR
	//	1.当处于idle时，读地址复位
	//	2.每当发出1个读命令，读地址累加
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			rd_addr	<= 19'b0;
		end
		else if(rd_cmd_reg==1'b1) begin
			rd_addr	<= rd_addr + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	读指针逻辑
	//	1.当帧存深度是1帧或者复位信号有效或者使能无效时，读指针复位
	//	2.其他情况下，当写允许=1且可以读(读写指针不一样)，读指针自增
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(frame_depth_reg==0 || reset==1'b1 || enable==1'b0) begin
			rd_frame_ptr	<= RD_FRAME_PTR_RESET_VALUE;
		end
		else begin
			if(i_rd_ack==1'b1 && able_to_read==1'b1) begin
				if(rd_frame_ptr==frame_depth_reg) begin
					rd_frame_ptr	<= 0;
				end
				else begin
					rd_frame_ptr	<= rd_frame_ptr + 1'b1;
				end
			end
		end
	end
	assign	ov_rd_frame_ptr		= rd_frame_ptr;

	//  -------------------------------------------------------------------------------------
	//	ref FSM 状态机逻辑
	//  -------------------------------------------------------------------------------------
	//FSM Sequential Logic
	always @ (posedge clk) begin
		if(reset==1'b1) begin
			current_state	<= S_IDLE;
		end
		else begin
			current_state	<= next_state;
		end
	end

	//FSM Conbinatial Logic
	always @ ( * ) begin
		case(current_state)
			//	-------------------------------------------------------------------------------------
			//	IDLE状态
			//	1.开始一帧写操作的程序，需要满足一下三个条件
			//	--使能打开
			//	--后级fifo不满
			//	--DDR3校正完成了
			//	--able_to_read 允许读，加上这一条的原因是避免在 IDLE状态和REQ状态频繁跳转
			//	2.进入读状态之后，只有一帧读完了或者复位，才能回到IDLE状态
			//	-------------------------------------------------------------------------------------
			S_IDLE :
			if(enable==1'b1 && i_buf_full==1'b0 && calib_done_shift[1]==1'b1 && able_to_read==1'b1) begin
				next_state	<= S_REQ;
			end
			else begin
				next_state	<= S_IDLE;
			end
			//	-------------------------------------------------------------------------------------
			//	请求状态
			//	1.为了避免读写同时进入工作状态，需要JUDGE模块做处理
			//	2.在ACK的1clk周期内作判断，根据当前的读写状态和帧倒换策略，看是否有可读帧
			//	3.当不使能时，返回idle
			//	4.当使能允许时
			//	--如果可以读，则进入CMD状态
			//	--如果不能读，则返回idle
			//	5.如果judge没有反馈，则继续等待
			//	-------------------------------------------------------------------------------------
			S_REQ :
			if(!enable) begin
				next_state	<= S_IDLE;
			end
			else begin
				if(i_rd_ack==1'b1 && able_to_read==1'b1) begin
					next_state	<= S_CMD;
				end
				else if(i_rd_ack==1'b1 && able_to_read==1'b0) begin
					next_state	<= S_IDLE;
				end
				else begin
					next_state	<= S_REQ;
				end
			end
			//	-------------------------------------------------------------------------------------
			//	命令状态
			//	1.当使能关闭或者一帧结束的时候，不要发出读命令，返回到idle状态
			//	2.当使能打开时，发出命令的条件
			//	--如果读写在同一帧，读地址要小于写地址(addr_less_int)
			//	--p3 cmd fifo 不满
			//	-------------------------------------------------------------------------------------
			S_CMD :
			if(enable==1'b0 || frame_done_reg==1'b1) begin
				next_state	<= S_IDLE;
			end
			else begin
				if(addr_less_int==1'b1 && i_p3_cmd_full==1'b0) begin
					next_state	<= S_RD;
				end
				else begin
					next_state	<= S_CMD;
				end
			end
			//	-------------------------------------------------------------------------------------
			//	读状态
			//	1.当把MCB中的数据都读走了之后，返回cmd状态
			//	2.如果没有读完，则继续读
			//	3.不在rd状态判断一帧是否读完，只在cmd状态判断
			//	-------------------------------------------------------------------------------------
			S_RD :
			if(word_cnt==6'b111110 && fifo_rd_int==1'b1) begin
				next_state	<= S_CMD;
			end
			else begin
				next_state	<= S_RD;
			end
			default :
			next_state	<= S_IDLE;
		endcase
	end


endmodule