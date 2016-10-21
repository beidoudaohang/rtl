//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : i2c_ctrl
//  -- 设计者       : 周金剑
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 周金剑       :| 2015/10/20 13:26:32	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module  i2c_ctrl
	(
	input				reset		    	,//clk_pix时钟域，复位信号
	input				clk			    	,//时钟，clk_pix，55MHz
	//trigger
	input				i_trigger	    	,//clk_pix时钟域，触发信号，持续1个周期的高电平
	//trigger_mode下降沿
	input				i_trigger_mode_fall	,//clk_pix时钟域，trigger_mode下降沿
	//fifo控制信号
	output	reg			o_fifo_rden	    	,//clk_pix时钟域，FIFO读信号
	input		[31:0]	iv_fifo_q	    	,//clk_pix时钟域，FIFO输出
	input				i_fifo_rdy	    	,//clk_pix时钟域，FIFO非空时该信号为1，空时为0
	//ram控制信号
	output	reg	[4:0]	ov_ram_addr	    	,//clk_pix时钟域，RAM读地址
	input		[31:0]	iv_ram_q	    	,//clk_pix时钟域，RAM输出

	//i2c master控制信号
	output	reg	[2:0]	ov_wb_adr	    	,//clk_pix时钟域，i2c内部寄存器地址
	output	reg	[7:0]	ov_wb_dat	    	,//clk_pix时钟域，i2c内部寄存器待写入数据
	output	reg			o_wb_we		    	,//clk_pix时钟域，i2c内部寄存器写使能
	output				o_wb_stb	    	,//clk_pix时钟域，固定输出1
	output				o_wb_cyc	    	,//clk_pix时钟域，固定输出1
	input				i_done          	,//clk_pix时钟域，i2c操作完成标志，1完成，0未完成
	output				o_state_idle		,//clk_pix时钟域，i2c状态机空闲
	output	reg			o_trigger_start		 //clk_pix时钟域，i2c命令开始发送
	);

	//  ===============================================================================================
	//	 ref ***变量定义***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ref 状态机定义
	//  -------------------------------------------------------------------------------------
	localparam	[2:0]	IDLE	=	3'd0;//空闲状态
	localparam	[2:0]	RD_RAM	=	3'd1;//读取RAM里的i2c参数
	localparam	[2:0]	RD_FIFO	=	3'd2;//读取FIFO里的i2c参数
	localparam	[2:0]	I2C_WR_0=	3'd3;//发送slave器件地址
	localparam	[2:0]	I2C_WR_1=	3'd4;//发送器件内部地址高8bit
	localparam	[2:0]	I2C_WR_2=	3'd5;//发送器件内部地址低8bit
	localparam	[2:0]	I2C_WR_3=	3'd6;//发送数据高8bit
	localparam	[2:0]	I2C_WR_4=	3'd7;//发送数据低8bit
	reg			[2:0]	current_state	;
	reg			[2:0]	next_state		;
	//  -------------------------------------------------------------------------------------
	//	ref 变量定义
	//  -------------------------------------------------------------------------------------
	reg			[15:0]	fs_reset_cnt	;//状态机复位计数器，计数到0x8000，大概596us
	wire				fs_reset		;//状态机复位信号

	reg			[31:0]	fifo_q_reg		;//FIFO输出锁存，防止i2c发送中数据改变

	reg			[2:0]	cnt				;//计数器
	reg					cnt_ena			;//计数器使能，1-可以计数，0-不能计数
	reg					trigger_status	;//触发状态标志，1-处于触发状态，0-不在触发状态
	reg			[7:0]	ov_wb_adr_0		;//
	reg			[7:0]	ov_wb_dat_0		;//
	reg			[7:0]	ov_wb_adr_1		;//
	reg			[7:0]	ov_wb_dat_1		;//


	//  -------------------------------------------------------------------------------------
	//	ref 输出赋值
	//  -------------------------------------------------------------------------------------
	assign	o_wb_stb		=1;
	assign	o_wb_cyc		=1;
	assign	o_state_idle	=(current_state==3'd0);
	//  -------------------------------------------------------------------------------------
	//	ref 检测状态机的状态，除IDLE外，停留在其他状态时间超过596us(0x8000)即跳转到IDLE。
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset)
			fs_reset_cnt	<=	16'd0;
		else if(current_state==IDLE)
			fs_reset_cnt	<=	16'd0;
		else if(current_state==next_state)begin
			if(fs_reset_cnt[15])
				fs_reset_cnt	<=	16'd0;
			else
				fs_reset_cnt	<=	fs_reset_cnt	+	1'd1;
		end
		else
			fs_reset_cnt	<=	16'd0;
	end
	assign	fs_reset	=	fs_reset_cnt[15];
	//  ===============================================================================================
	//	ref ***状态机***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	时序逻辑
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset | fs_reset)
			current_state	<=	IDLE;
		else
			current_state	<=	next_state;
	end
	//  -------------------------------------------------------------------------------------
	//	组合逻辑
	//  -------------------------------------------------------------------------------------
	always @ (*)begin
		case(current_state)
			IDLE	:begin
				if(i_trigger)
					next_state	=	RD_RAM;
				else if(i_trigger_mode_fall)
					next_state	=	RD_RAM;
				else if(i_fifo_rdy)
					next_state	=	RD_FIFO;
				else
					next_state	=	IDLE;
			end
			RD_RAM	:begin
				next_state	=	I2C_WR_0;
				if(ov_ram_addr==5'd18)
					next_state	=	IDLE;
				else
					next_state	=	I2C_WR_0;
			end
			RD_FIFO	:begin
				next_state	=	I2C_WR_0;
			end
			//开始i2c数据的发送，先发起始位
			//发送slave器件地址，0x6e
			I2C_WR_0:begin
				if(i_done)
					next_state	=	I2C_WR_1;
				else
					next_state	=	I2C_WR_0;
			end
			//发送slave器件内部地址高8bit
			I2C_WR_1:begin
				if(i_done)
					next_state	=	I2C_WR_2;
				else
					next_state	=	I2C_WR_1;
			end
			//发送slave器件内部地址低8bit
			I2C_WR_2:begin
				if(i_done)
					next_state	=	I2C_WR_3;
				else
					next_state	=	I2C_WR_2;
			end
			//发送slave器件数据高8bit
			I2C_WR_3:begin
				if(i_done)
					next_state	=	I2C_WR_4;
				else
					next_state	=	I2C_WR_3;
			end
			//发送slave器件数据低8bit
			I2C_WR_4:begin
				if(i_done)begin
					if(trigger_status)
						next_state	=	RD_RAM;
					else
						next_state	=	IDLE;
				end
				else
					next_state	=	I2C_WR_4;
			end
			default:next_state	=	IDLE;
		endcase
	end

	//  -------------------------------------------------------------------------------------
	//	ref 状态机动作
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset)begin
			o_fifo_rden	<=	1'b0;
			ov_ram_addr	<=	5'd0;
			cnt_ena		<=	1'b0;
		end
		else begin
			case(current_state)
				IDLE	:begin
					cnt_ena			<=	1'b0;
					ov_ram_addr		<=	5'd0;
					trigger_status	<=	1'b0;
					if(i_trigger)
						o_fifo_rden	<=	1'b0;
					else if(i_fifo_rdy)
						o_fifo_rden	<=	1'b1;
					else
						o_fifo_rden	<=	1'b0;
				end
				RD_RAM	:begin
					cnt_ena			<=	1'b0;
					trigger_status	<=	1'b1;	//trigger_status=1表示是在触发模式下
					if(ov_ram_addr==5'd18)begin
						ov_ram_addr			<=	5'd0;
					end
					else begin
						ov_ram_addr			<=	ov_ram_addr	+	1'd1;
					end
				end
				RD_FIFO	:begin
					cnt_ena		<=	1'b0;
					o_fifo_rden	<=	1'b0;
				end
				//开始i2c数据的发送，先发起始位
				//发送slave器件地址，0x6e
				I2C_WR_0:begin
					cnt_ena		<=	1'b1;
					fifo_q_reg	<=	iv_fifo_q;
					ov_wb_adr_0	<=	8'h03;//transmit register address
					ov_wb_dat_0	<=	8'h6e;//transmit data
					ov_wb_adr_1	<=	8'h04;//command register address
					ov_wb_dat_1	<=	8'h90;//command
				end
				//发送slave器件内部地址高8bit
				I2C_WR_1:begin
					cnt_ena		<=	1'b1;
					if(trigger_status)begin
						ov_wb_adr_0	<=	8'h03;//transmit register address
						ov_wb_dat_0	<=	iv_ram_q[31:24];//transmit data
						ov_wb_adr_1	<=	8'h04;//command register address
						ov_wb_dat_1	<=	8'h10;//command
					end
					else begin
						ov_wb_adr_0	<=	8'h03;//transmit register address
						ov_wb_dat_0	<=	fifo_q_reg[31:24];//transmit data
						ov_wb_adr_1	<=	8'h04;//command register address
						ov_wb_dat_1	<=	8'h10;//command
					end
				end
				//发送slave器件内部地址低8bit
				I2C_WR_2:begin
					cnt_ena		<=	1'b1;
					if(trigger_status)begin
						ov_wb_adr_0	<=	8'h03;//transmit register address
						ov_wb_dat_0	<=	iv_ram_q[23:16];//transmit data
						ov_wb_adr_1	<=	8'h04;//command register address
						ov_wb_dat_1	<=	8'h10;//command
					end
					else begin
						ov_wb_adr_0	<=	8'h03;//transmit register address
						ov_wb_dat_0	<=	fifo_q_reg[23:16];//transmit data
						ov_wb_adr_1	<=	8'h04;//command register address
						ov_wb_dat_1	<=	8'h10;//command
					end
				end
				//发送slave器件数据高8bit
				I2C_WR_3:begin
					cnt_ena		<=	1'b1;
					if(trigger_status)begin
						ov_wb_adr_0	<=	8'h03;//transmit register address
						if(ov_ram_addr==5'd17)//地址17发送的数据固定为0x8006.17地址是可以修改的，在连续模式下开采，是会修改这个寄存器的
							ov_wb_dat_0	<=	8'h80;//transmit data，set restart bit to 1
						else
							ov_wb_dat_0	<=	iv_ram_q[15:8];//transmit data
						ov_wb_adr_1	<=	8'h04;//command register address
						ov_wb_dat_1	<=	8'h10;//command
					end
					else begin
						ov_wb_adr_0	<=	8'h03;//transmit register address
						ov_wb_dat_0	<=	fifo_q_reg[15:8];//transmit data
						ov_wb_adr_1	<=	8'h04;//command register address
						ov_wb_dat_1	<=	8'h10;//command
					end
				end
				//发送slave器件内部地址低8bit
				//数据发送完成后发送一个停止位
				I2C_WR_4:begin
					cnt_ena		<=	1'b1;
					if(trigger_status)begin
						ov_wb_adr_0	<=	8'h03;//transmit register address
						if(ov_ram_addr==5'd17)//地址17发送的数据固定为0x8006
							ov_wb_dat_0	<=	8'h06;//transmit data，set restart bit to 1
						else
							ov_wb_dat_0	<=	iv_ram_q[7:0];//transmit data
						ov_wb_adr_1	<=	8'h04;//command register address
						ov_wb_dat_1	<=	8'h50;//command
					end
					else begin
						ov_wb_adr_0	<=	8'h03;//transmit register address
						ov_wb_dat_0	<=	fifo_q_reg[7:0];//transmit data
						ov_wb_adr_1	<=	8'h04;//command register address
						ov_wb_dat_1	<=	8'h50;//command
					end
				end
			endcase
		end
	end
	//  -------------------------------------------------------------------------------------
	//	ref 产生触发模式i2c命令发送完成标志
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset)
			o_trigger_start	<=	1'b0;
		else begin
			if(i_trigger==1'b1)
				o_trigger_start	<=	1'b1;
			else if(ov_ram_addr==5'd16)		//17地址，要写restart寄存器。此处开始早一个寄存器。
				o_trigger_start	<=	1'b0;
		end
	end
	//  ===============================================================================================
	//	ref 控制i2c命令和数据的写操作
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ref 计数器
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset)
			cnt	<=	0;
		else if(cnt_ena)begin
			if(i_done)
				cnt	<=	0;
			else if(cnt	< 7)
				cnt	<=	cnt	+	1'd1;
		end
		else
			cnt	<=	0;
	end
	//  -------------------------------------------------------------------------------------
	//	ref 产生i2c命令、数据和写使能
	//  -------------------------------------------------------------------------------------
	always @ (*)begin
		case(cnt)
			1,2:begin
				ov_wb_adr	<=	ov_wb_adr_0;//transmit register address
				ov_wb_dat	<=	ov_wb_dat_0;//transmit data
				o_wb_we		<=	1'b1;
			end
			5,6:begin
				ov_wb_adr	<=	ov_wb_adr_1;//command register address
				ov_wb_dat	<=	ov_wb_dat_1;//command
				o_wb_we		<=	1'b1;
			end
			default:begin
				ov_wb_adr	<=	3'h7;
				ov_wb_dat	<=	8'haf;
				o_wb_we		<=	1'b0;
			end
		endcase
	end

endmodule