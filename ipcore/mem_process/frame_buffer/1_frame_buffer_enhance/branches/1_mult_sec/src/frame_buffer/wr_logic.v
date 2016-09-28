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
//  -- 邢海涛       :| 2015/3/30 18:29:05	:|  1.修改注释
//												2.帧存深度可变，1帧-32帧，且每一帧最大容量跟随深度而变
//												3.添加使能信号，分别是完整帧停开采和立即停开采
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
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wr_logic # (
	parameter		DATA_WIDTH			= 32		,	//数据宽度
	parameter		PTR_WIDTH			= 2			,	//读写指针的位宽，1-最大2帧 2-最大4帧 3-最大8帧 4-最大16帧 5-最大32帧
	parameter		RD_WR_WITH_PRE		= "FALSE"	,	//read write command end with precharge command
	parameter		DDR3_MEM_DENSITY	= "1Gb"		,	//DDR3 容量 "1Gb" "512Mb"
	parameter		TERRIBLE_TRAFFIC	= "TRUE"		//读写最差的情况，TRUE-同时读写不同帧的同一地址，FALSE-同时读写同一帧的同一地址
	)
	(
	//	===============================================================================================
	//	图像输入时钟域
	//	===============================================================================================
	input						i_fval				,	//场有效信号，高有效，异步信号
	//	===============================================================================================
	//	帧存时钟域
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  帧缓存工作时钟
	//  -------------------------------------------------------------------------------------
	input						clk					,	//时钟输入
	input						reset				,	//复位
	//	-------------------------------------------------------------------------------------
	//	每一段的起始地址
	//	-------------------------------------------------------------------------------------
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec0	,	//固定数，0段的起始地址
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec1	,	//固定数，1段的起始地址
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec2	,	//固定数，2段的起始地址
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec3	,	//固定数，3段的起始地址
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec4	,	//固定数，4段的起始地址
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec5	,	//固定数，5段的起始地址
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec6	,	//固定数，6段的起始地址
	input	[SECTION_ADDR_WIDTH-1:0]				iv_start_addr_sec7	,	//固定数，7段的起始地址
	//	-------------------------------------------------------------------------------------
	//	每一段的大小
	//	-------------------------------------------------------------------------------------
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec0		,	//0段的大小
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec1		,	//1段的大小
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec2		,	//2段的大小
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec3		,	//3段的大小
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec4		,	//4段的大小
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec5		,	//5段的大小
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec6		,	//6段的大小
	input	[SECTION_SIZE_WIDTH-1:0]				iv_size_sec7		,	//7段的大小
	//  -------------------------------------------------------------------------------------
	//  控制数据
	//  -------------------------------------------------------------------------------------
	input	[PTR_WIDTH-1:0]		iv_frame_depth		,	//帧缓存深度 可设置为 0 - 31，设为0表示1帧，设为1时表示2帧
	input						i_start_full_frame	,	//使能开关，保证一帧完整操作
	input						i_start_quick		,	//使能开关，立即停
	//  -------------------------------------------------------------------------------------
	//  前级FIFO
	//  -------------------------------------------------------------------------------------
	input	[DATA_WIDTH-1:0]	iv_buf_dout			,	//前级FIFO数据输出
	output						o_buf_rd_en			,	//前级FIFO读使能，高有效
	input						i_buf_pe			,	//前级FIFO编程空标志位，高有效
	input						i_buf_empty			,	//前级FIFO空标志位，高有效
	//  -------------------------------------------------------------------------------------
	//  wr logic
	//  -------------------------------------------------------------------------------------
	output	[PTR_WIDTH-1:0]		ov_wr_frame_ptr		,	//写指针
	output	[18:0]				ov_wr_addr			,	//写地址
	output						o_writing			,	//正在写，高有效
	//  -------------------------------------------------------------------------------------
	//  judge
	//  -------------------------------------------------------------------------------------
	output						o_wr_req			,	//写请求，高有效
	input						i_wr_ack			,	//写允许，高有效
	//  -------------------------------------------------------------------------------------
	//  rd logic
	//  -------------------------------------------------------------------------------------
	input	[PTR_WIDTH-1:0]		iv_rd_frame_ptr		,	//读指针
	input						i_reading			,	//正在读，高有效
	//  -------------------------------------------------------------------------------------
	//  MCB FIFO
	//  -------------------------------------------------------------------------------------
	input						i_calib_done		,	//MCB校准完成信号，高有效
	output						o_p2_cmd_en			,	//MCB CMD FIFO 写信号，高有效
	output	[2:0]				ov_p2_cmd_instr		,	//MCB CMD FIFO 指令
	output	[5:0]				ov_p2_cmd_bl		,	//MCB CMD FIFO 突发长度
	output	[29:0]				ov_p2_cmd_byte_addr	,	//MCB CMD FIFO 起始地址
	input						i_p2_cmd_empty		,	//MCB CMD FIFO 空信号，高有效
	input						i_p2_cmd_full		,	//MCB CMD FIFO 满信号，高有效

	output						o_p2_wr_en			,	//MCB WR FIFO 写信号，高有效
	output	[3:0]				ov_p2_wr_mask		,	//MCB WR 屏蔽信号
	output	[DATA_WIDTH-1:0]	ov_p2_wr_data		,	//MCB WR FIFO 写数据
	input						i_p2_wr_full		,	//MCB WR FIFO 满信号，高有效
	input						i_p2_wr_empty			//MCB WR FIFO 空信号，高有效
	);

	//ref signals

	//FSM Parameter Define
	parameter	S_IDLE		= 2'd0;
	parameter	S_REQ		= 2'd1;
	parameter	S_WR		= 2'd2;
	parameter	S_CMD		= 2'd3;

	reg		[1:0]	current_state	= S_IDLE;
	reg		[1:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	reg		[127:0]		state_ascii;
	always @ ( * ) begin
		case(current_state)
			2'd0 :	state_ascii	<= "S_IDLE";
			2'd1 :	state_ascii	<= "S_REQ";
			2'd2 :	state_ascii	<= "S_WR";
			2'd3 :	state_ascii	<= "S_CMD";
		endcase
	end
	// synthesis translate_on

	//	-------------------------------------------------------------------------------------
	//	固定参数
	//	1.写指针复位值。
	//	--当模拟最差环境时，写指针的复位值是1。否则写指针的复位值是0。
	//	2.MCB写命令
	//	--默认不带precharge，会节省一些电量消耗
	//	-------------------------------------------------------------------------------------
	localparam	WR_FRAME_PTR_RESET_VALUE	= (TERRIBLE_TRAFFIC=="TRUE") ? 1 : 0;
	localparam	WR_CMD_INSTR				= (RD_WR_WITH_PRE=="TRUE") ? 3'b010 : 3'b000;

	reg		[1:0]				calib_done_shift 		= 2'b0;
	reg		[2:0]				fval_shift 				= 3'b100;
	wire						fval_rise				;
	wire						fval_fall				;
	reg		[2:0]				sval_shift 				= 3'b100;
	wire						sval_rise				;
	wire						sval_fall				;
	reg							buf_rd_reg 				= 1'b0;
	wire						buf_rd_int				;
	reg		[5:0]				word_cnt 				= 6'b111111;
	reg							cmd_en_reg 				= 1'b0;
	reg		[PTR_WIDTH-1:0]		wr_frame_ptr 			= WR_FRAME_PTR_RESET_VALUE;
	reg		[18:0]				wr_addr 				= 19'b0;
	reg							able_to_write 			= 1'b0;
	reg							wr_req_reg 				= 1'b0;
	reg		[PTR_WIDTH-1:0]		frame_depth_reg 		= 1;
	reg							start_full_frame_int	= 1'b0;
	wire						enable					;
	reg							fval_rise_reg 			= 1'b0;
	reg							writing_reg 			= 1'b0;
	reg							wr_cmd_reg 				= 1'b0;


	//ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***延时 提取边沿***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  calib_done 属于 mcb drp clk 时钟域
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		calib_done_shift	<= {calib_done_shift[0],i_calib_done};
	end

	//  -------------------------------------------------------------------------------------
	//  提取场有效上升沿
	//	1.i_fval是异步时钟域
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_shift	<= {fval_shift[1:0],i_fval};
	end
	assign	fval_rise	= (fval_shift[2:1] == 2'b01) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_shift[2:1] == 2'b10) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//  提取场有效上升沿
	//	1.i_sval是异步时钟域
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		sval_shift	<= {sval_shift[1:0],i_sval};
	end
	assign	sval_rise	= (sval_shift[2:1] == 2'b01) ? 1'b1 : 1'b0;
	assign	sval_fall	= (sval_shift[2:1] == 2'b10) ? 1'b1 : 1'b0;

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

	//	===============================================================================================
	//	ref ***控制寄存器***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	场有效保持寄存器
	//	1.当使能无效时， fval_rise_reg=0 ，这样做可以保证使能信号=1时，如果i_fval还是1，不会误操作
	//	2.当使能有效时
	//	--2.1当i_fval上升沿的时候，fval_rise_reg=1
	//	--2.2当i_fval下降沿的时候，fval_rise_reg=0
	//	3.目的是为了保持住开始的状态，好让idle可以判断一帧已经开始了
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!enable) begin
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

	//	===============================================================================================
	//	ref ***FIFO MCB 操作***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  前级FIFO读信号
	//	1.当处在写状态时，如果前级fifo不空，后级fifo不满，读信号有效
	//	2.用组合逻辑来做，否则会导致多读出数据
	//  -------------------------------------------------------------------------------------
	assign	buf_rd_int		= (current_state==S_WR) ? (~i_buf_empty & ~i_p2_wr_full) : 1'b0;
	assign	o_buf_rd_en		= buf_rd_int;

	//  -------------------------------------------------------------------------------------
	//  MCB fifo 写信号
	//	1.与前级FIFO读信号同源
	//	2.前级FIFO具有 first word fall through的特点，当不空的时候，第一个数据已经放到端口上了
	//  -------------------------------------------------------------------------------------
	assign	o_p2_wr_en		= buf_rd_int;

	//  -------------------------------------------------------------------------------------
	//  MCB fifo 写数据
	//	1.前级FIFO输出直接送到MCB的fifo中
	//	2.前级FIFO具有 first word fall through的特点，当不空的时候，第一个数据已经放到端口上了
	//	3.在前级FIFO和MCB WR FIFO之间没有加流水线，目的是减少资源。33 FFs。实际上这里并不会是关键路径。
	//  -------------------------------------------------------------------------------------
	assign	ov_p2_wr_data	= iv_buf_dout;

	//	-------------------------------------------------------------------------------------
	//	写数据mask信号
	//	1.无需mask
	//	-------------------------------------------------------------------------------------
	assign	ov_p2_wr_mask	= 4'b0000;

	//	-------------------------------------------------------------------------------------
	//	MCB CMD FIFO 写信号
	//	1.当处于 CMD 状态时，如果cmd fifo不满，就可以写入一个新的命令
	//	2.也可以是，cmd fifo空的时候，才写入。这样的话，写操作就是串行的数据流，保证读写在同一帧时，读不会超过写。
	//		但是，当mcb 位宽很宽时，帧存控制器的写速度有可能超多ddr3，这样就会减小帧存控制器的效率
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((current_state==S_CMD)) begin
			wr_cmd_reg	<= ~i_p2_cmd_full;
		end
		else begin
			wr_cmd_reg	<= 1'b0;
		end
	end
	assign	o_p2_cmd_en	= wr_cmd_reg;

	//	-------------------------------------------------------------------------------------
	//	写指令
	//	1.根据参数定义，可以有2种命令方式
	//	-------------------------------------------------------------------------------------
	assign	ov_p2_cmd_instr	= WR_CMD_INSTR;

	//  -------------------------------------------------------------------------------------
	//	写地址
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
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==1'd0) ? {{4'b0},wr_addr[17:0],{8'b0}} : 	//单帧
			{{4'b0},wr_frame_ptr[0],wr_addr[16:0],{8'b0}}	;			//2帧
		end
		else if(PTR_WIDTH==1 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==1'd0) ? {{3'b0},wr_addr[18:0],{8'b0}} : 	//单帧
			{{3'b0},wr_frame_ptr[0],wr_addr[17:0],{8'b0}}	;			//2帧
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	最大帧存深度是4帧
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==2 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==2'd0) ? {{4'b0},wr_addr[17:0],{8'b0}} : 					//单帧
			(frame_depth_reg==2'd1) ? {{4'b0},wr_frame_ptr[0],wr_addr[16:0],{8'b0}} : 	//2帧
			{{4'b0},wr_frame_ptr[1:0],wr_addr[15:0],{8'b0}}	;							//3 4 帧
		end
		else if(PTR_WIDTH==2 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==2'd0) ? {{3'b0},wr_addr[18:0],{8'b0}} : 					//单帧
			(frame_depth_reg==2'd1) ? {{3'b0},wr_frame_ptr[0],wr_addr[17:0],{8'b0}} : 	//2帧
			{{3'b0},wr_frame_ptr[1:0],wr_addr[16:0],{8'b0}}	;							//3 4 帧
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	最大帧存深度是8帧
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==3 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==3'd0) ? {{4'b0},wr_addr[17:0],{8'b0}} : 												//单帧
			(frame_depth_reg==3'd1) ? {{4'b0},wr_frame_ptr[0],wr_addr[16:0],{8'b0}} : 								//2帧
			(frame_depth_reg==3'd2 || frame_depth_reg==3'd3) ? {{4'b0},wr_frame_ptr[1:0],wr_addr[15:0],{8'b0}} :	//3 4 帧
			{{4'b0},wr_frame_ptr[2:0],wr_addr[14:0],{8'b0}};														//5 - 8 帧
		end
		else if(PTR_WIDTH==3 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==3'd0) ? {{3'b0},wr_addr[18:0],{8'b0}} : 												//单帧
			(frame_depth_reg==3'd1) ? {{3'b0},wr_frame_ptr[0],wr_addr[17:0],{8'b0}} : 								//2帧
			(frame_depth_reg==3'd2 || frame_depth_reg==3'd3) ? {{3'b0},wr_frame_ptr[1:0],wr_addr[16:0],{8'b0}} :	//3 4 帧
			{{3'b0},wr_frame_ptr[2:0],wr_addr[15:0],{8'b0}};														//5 - 8 帧
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	最大帧存深度是16帧
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==4 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==4'd0) ? {{4'b0},wr_addr[17:0],{8'b0}} : 												//单帧
			(frame_depth_reg==4'd1) ? {{4'b0},wr_frame_ptr[0],wr_addr[16:0],{8'b0}} : 								//2帧
			(frame_depth_reg==4'd2 || frame_depth_reg==4'd3) ? {{4'b0},wr_frame_ptr[1:0],wr_addr[15:0],{8'b0}} :	//3 4 帧
			(frame_depth_reg>=4'd4 && frame_depth_reg<=4'd7) ? {{4'b0},wr_frame_ptr[2:0],wr_addr[14:0],{8'b0}} :	//5 - 8 帧
			{{4'b0},wr_frame_ptr[3:0],wr_addr[13:0],{8'b0}};														//9 - 16 帧
		end
		else if(PTR_WIDTH==4 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==4'd0) ? {{3'b0},wr_addr[18:0],{8'b0}} : 												//单帧
			(frame_depth_reg==4'd1) ? {{3'b0},wr_frame_ptr[0],wr_addr[17:0],{8'b0}} : 								//2帧
			(frame_depth_reg==4'd2 || frame_depth_reg==4'd3) ? {{3'b0},wr_frame_ptr[1:0],wr_addr[16:0],{8'b0}} :	//3 4 帧
			(frame_depth_reg>=4'd4 && frame_depth_reg<=4'd7) ? {{3'b0},wr_frame_ptr[2:0],wr_addr[15:0],{8'b0}} :	//5 - 8 帧
			{{3'b0},wr_frame_ptr[3:0],wr_addr[14:0],{8'b0}};														//9 - 16 帧
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	最大帧存深度是32帧
	//	-------------------------------------------------------------------------------------
	generate
		if(PTR_WIDTH==5 && DDR3_MEM_DENSITY=="512Mb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==5'd0) ? {{4'b0},wr_addr[17:0],{8'b0}} : 												//单帧
			(frame_depth_reg==5'd1) ? {{4'b0},wr_frame_ptr[0],wr_addr[16:0],{8'b0}} : 								//2帧
			(frame_depth_reg==5'd2 || frame_depth_reg==5'd3) ? {{4'b0},wr_frame_ptr[1:0],wr_addr[15:0],{8'b0}} :	//3 4 帧
			(frame_depth_reg>=5'd4 && frame_depth_reg<=5'd7) ? {{4'b0},wr_frame_ptr[2:0],wr_addr[14:0],{8'b0}} :	//5 - 8 帧
			(frame_depth_reg>=5'd8 && frame_depth_reg<=5'd15) ? {{4'b0},wr_frame_ptr[3:0],wr_addr[13:0],{8'b0}} :	//9 - 16 帧
			{{4'b0},wr_frame_ptr[4:0],wr_addr[12:0],{8'b0}};														//17 - 32 帧
		end
		else if(PTR_WIDTH==5 && DDR3_MEM_DENSITY=="1Gb") begin
			assign	ov_p2_cmd_byte_addr	=
			(frame_depth_reg==5'd0) ? {{3'b0},wr_addr[18:0],{8'b0}} : 												//单帧
			(frame_depth_reg==5'd1) ? {{3'b0},wr_frame_ptr[0],wr_addr[17:0],{8'b0}} : 								//2帧
			(frame_depth_reg==5'd2 || frame_depth_reg==5'd3) ? {{3'b0},wr_frame_ptr[1:0],wr_addr[16:0],{8'b0}} :	//3 4 帧
			(frame_depth_reg>=5'd4 && frame_depth_reg<=5'd7) ? {{3'b0},wr_frame_ptr[2:0],wr_addr[15:0],{8'b0}} :	//5 - 8 帧
			(frame_depth_reg>=5'd8 && frame_depth_reg<=5'd15) ? {{3'b0},wr_frame_ptr[3:0],wr_addr[14:0],{8'b0}} :	//9 - 16 帧
			{{3'b0},wr_frame_ptr[4:0],wr_addr[13:0],{8'b0}};														//17 - 32 帧
		end
	endgenerate

	//	===============================================================================================
	//	ref ***交互信号***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  写请求
	//	1.当处于req状态，且写允许=0时，发出写请求
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_REQ && i_wr_ack==1'b0) begin
			wr_req_reg	<= 1'b1;
		end
		else begin
			wr_req_reg	<= 1'b0;
		end
	end
	assign	o_wr_req	= wr_req_reg;

	//  -------------------------------------------------------------------------------------
	//  正在写
	//	1.当处于idle状态时，正在写信号清零
	//	2.当写允许时，写信号拉高
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			writing_reg	<= 1'b0;
		end
		else if(i_wr_ack==1'b1 && able_to_write==1'b1) begin
			writing_reg	<= 1'b1;
		end
	end
	assign	o_writing	= writing_reg;

	//	===============================================================================================
	//	ref ***帧追赶策略***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  允许写信号--只用于单帧
	//	1.此处必须是组合逻辑，必须在REQ状态中输出
	//	2.只在单帧时，该信号才是有效的。当一帧正在读时，就不允许写，把这一帧丢弃。
	//	3.在多帧时，是无效的，因为写可以跨越读，不会丢掉写数据
	//  -------------------------------------------------------------------------------------
	always @ ( * ) begin
		if(frame_depth_reg==0) begin
			able_to_write	<= !i_reading;
		end
		else begin
			able_to_write	<= 1'b1;
		end
	end

	//	===============================================================================================
	//	ref ***数据、地址计数器***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	word_cnt 一组burst计数器
	//	1.一组burst的计数器，计满64个
	//	2.不需要再判断reset，因为reset=1，就会进入idle状态
	//	3.在一帧开始的时候，清空计数器。与wr_adddr一同清零。
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			word_cnt	<= 6'b111111;
		end
		else if(buf_rd_int==1'b1) begin
			word_cnt	<= word_cnt + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	写长度
	//	1.burst_length=word_cnt，当图像有残包的时候，不会将多余的数据写入DDR
	//	-------------------------------------------------------------------------------------
	assign	ov_p2_cmd_bl	= word_cnt;

	//  -------------------------------------------------------------------------------------
	//  写地址逻辑
	//	1.在idle状态下，地址清零
	//	2.无需判断reset，因为reset=1，就会进入idle
	//	3.每次写命令之后，地址加1
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			wr_addr	<= 19'b0;
		end
		else if(wr_cmd_reg == 1'b1) begin
			wr_addr	<= wr_addr + 1'b1;
		end
	end
	assign	ov_wr_addr	= wr_addr;

	//	-------------------------------------------------------------------------------------
	//	写指针逻辑
	//	1.当帧存深度是1帧或者复位信号有效或者使能无效时，写指针复位
	//	2.其他情况下：
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(frame_depth_reg==0 || reset==1'b1 || enable==1'b0) begin
			wr_frame_ptr	<= WR_FRAME_PTR_RESET_VALUE;
		end
		else begin
			//	-------------------------------------------------------------------------------------
			//	1.当写允许=1时，才能允许移动写指针。当写允许=0时，不允许移动写指针。
			//	2.当写允许=1且正在读=0时，说明读模块没有占用任何内存，写指针可以任意进入
			//	3.当写允许=1且正在读=1时，说明读模块已经占据了一块内存，写指针要根据读指针的状态做出判断
			//	--3.1当写指针已经达到最大值时
			//	----如果读模块正在读0号内存，那么写指针要跳过读指针，实现写跨越
			//	----如果读模块没有在读0号内存，那么写指针写0号地址
			//	--3.2当写指针没有达到最大值，但是读指针到达最大值时
			//	----如果写指针+1=读指针，那么写指针写0号地址
			//	----如果写指针+1!=读指针，那么写指针自增
			//	--3.3其他情况，读写指针都不是最大值
			//	----如果写指针+1=读指针，那么写指针要跳过读指针，实现写跨越
			//	----如果写指针+1!=读指针，那么写指针自增
			//	-------------------------------------------------------------------------------------
			if(i_wr_ack==1'b1) begin
				if(i_reading==1'b1) begin
					if(wr_frame_ptr==frame_depth_reg) begin
						if(iv_rd_frame_ptr==0) begin
							wr_frame_ptr	<= iv_rd_frame_ptr + 1'b1;
						end
						else begin
							wr_frame_ptr	<= 0;
						end
					end
					else if(iv_rd_frame_ptr==frame_depth_reg) begin
						if((wr_frame_ptr+1'b1)==iv_rd_frame_ptr) begin
							wr_frame_ptr	<= 0;
						end
						else begin
							wr_frame_ptr	<= wr_frame_ptr + 1'b1;
						end
					end
					else begin
						if((wr_frame_ptr+1'b1)==iv_rd_frame_ptr) begin
							wr_frame_ptr	<= iv_rd_frame_ptr + 1'b1;
						end
						else begin
							wr_frame_ptr	<= wr_frame_ptr + 1'b1;
						end
					end
				end
				else begin
					if(wr_frame_ptr==frame_depth_reg) begin
						wr_frame_ptr	<= 0;
					end
					else begin
						wr_frame_ptr	<= wr_frame_ptr + 1'b1;
					end
				end
			end
		end
	end
	assign	ov_wr_frame_ptr		= wr_frame_ptr;

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
			//	--fval上升沿有效
			//	--前端FIFO中的数据不是很多，如果进入的数据很多，那么就有帧存就有可能写不过来了。
			//	--开关已经打开
			//	--DDR3校正完成
			//	--able_to_write 允许写，加上这一条的原因是避免在 IDLE状态和REQ状态频繁跳转
			//	2.进入写状态之后，只有一帧写完了或者复位，才能回到IDLE状态
			//	-------------------------------------------------------------------------------------
			S_IDLE :
			if(fval_rise_reg==1'b1 && i_buf_pe==1'b1 && enable==1'b1 && calib_done_shift[1]==1'b1 && able_to_write==1'b1) begin
				next_state	= S_REQ;
			end
			else begin
				next_state	= S_IDLE;
			end
			//	-------------------------------------------------------------------------------------
			//	请求状态
			//	1.为了避免读写同时进入工作状态，需要JUDGE模块做处理
			//	2.在ACK的1clk周期内作判断，根据当前的读写状态和帧追赶策略，看是否有可读帧
			//	3.当不使能时，返回idle
			//	4.当使能允许时
			//	--如果可以写，则进入CMD状态
			//	--如果不能写，则返回idle
			//	5.如果judge没有反馈，则继续等待2
			//	-------------------------------------------------------------------------------------
			S_REQ :
			if(!enable) begin
				next_state	= S_IDLE;
			end
			else begin
				if(i_wr_ack==1'b1 && able_to_write==1'b1) begin
					next_state	= S_WR;
				end
				else if(i_wr_ack==1'b1 && able_to_write==1'b0) begin
					next_state	= S_IDLE;
				end
				else begin
					next_state	= S_REQ;
				end
			end
			//	-------------------------------------------------------------------------------------
			//	写状态
			//	1.当立即停采的时候，不管写了多少数据，立即进入cmd状态。此处用enable
			//	2.当没有立即停采的时候：
			//	--当写了63组数据的时候
			//	----如果再写一个数据，则MCB WR FIFO满，进入CMD状态
			//	----如果没有写信号，则在WR状态等待
			//	--计数器没有计数
			//	----如果一帧结束了，说明没有残包，返回空闲状态，不需要发送cmd
			//	----如果一帧没有结束，则还在WR状态等待
			//	--计数器已经计数，但没有计数到次大值
			//	----如果一帧结束了，进入cmd状态，将残包写到MCB中
			//	----如果一段结束了，进入cmd状态，将一段写入MCB中
			//	----其他，则停留在WR状态
			//	-------------------------------------------------------------------------------------
			S_WR :
			if(!enable) begin
				next_state	= S_CMD;
			end
			else begin
				if(word_cnt==6'b111110) begin
					if(buf_rd_int==1'b1) begin
						next_state	= S_CMD;
					end
					else begin
						next_state	= S_WR;
					end
				end
				else if(word_cnt==6'b111111) begin
					if(fval_shift[1]==1'b0 && i_buf_empty==1'b1) begin
						next_state	= S_IDLE;
					end
					else begin
						next_state	= S_WR;
					end
				end
				else begin
					if(fval_shift[1]==1'b0 && i_buf_empty==1'b1) begin
						next_state	= S_CMD;
					end
					else if(sval_fall==1'b1) begin
						next_state	= S_CMD;
					end
					else begin
						next_state	= S_WR;
					end
				end
			end
			//	-------------------------------------------------------------------------------------
			//	命令状态
			//	1.当立即停采的时候，不管写了多少数据，立即进入cmd状态。此处用enable
			//	2.当没有立即停采的时候：
			//	--当cmd fifo不满的时候，可以写命令。
			//	----如果前端fifo空了，且fval=0，说明一帧已经结束，回到idle
			//	----如果一帧没有结束，回到wr，继续写
			//	--当cmd fifo满的时候，等待
			//	-------------------------------------------------------------------------------------
			S_CMD :
			if(!enable) begin
				next_state	= S_IDLE;
			end
			else begin
				if(i_p2_cmd_full==1'b0) begin
					if(fval_shift[1]==1'b0 && i_buf_empty==1'b1) begin
						next_state	= S_IDLE;
					end
					else begin
						next_state	= S_WR;
					end
				end
				else begin
					next_state	= S_CMD;
				end
			end
			default :
			next_state	= S_IDLE;
		endcase
	end



endmodule