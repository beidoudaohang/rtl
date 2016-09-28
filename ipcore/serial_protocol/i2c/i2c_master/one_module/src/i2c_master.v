//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : i2c_master
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/11/10 17:43:32	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : ov_status[3:0]	bit0-i2c done bit1-slave addr nack bit2-reg addr nack bit3-wr data nack
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module i2c_master # (
	parameter	P_REG_ADDR_WIDTH	= 8		,	//8 or 16
	parameter	P_DATA_WIDTH 		= 16	,	//8 or 16
	parameter	P_I2C_FIRST_DATA	= "MSB"		//"MSB" or "LSB"
	)
	(
	//	-------------------------------------------------------------------------------------
	//	系统信号
	//	-------------------------------------------------------------------------------------
	input							clk				,	//时钟
	input							i_nwr_prd		,	//读写信号，0-写，1-读
	input							i_trig			,	//触发信号
	input	[3:0]					iv_rd_num		,	//读的数据量
	input	[7:0]					iv_slave_addr	,	//从器件地址
	input	[P_REG_ADDR_WIDTH-1:0]	iv_reg_addr		,	//寄存器地址
	input	[P_DATA_WIDTH-1:0]		iv_wr_data		,	//要写入的数据
	output	[P_DATA_WIDTH-1:0]		ov_rd_data		,	//读出的数据
	output							o_rd_valid		,	//读出完成
	output	[3:0]					ov_status		,	//当前状态
	//  -------------------------------------------------------------------------------------
	//	I2C 接口信号
	//  -------------------------------------------------------------------------------------
	input							clk_i2c			,	//i2c时钟
	output							slave_exp		,	//从器件忙
	inout							scl				,	//i2c 时钟
	inout							sda					//i2c 数据
	);

	//	ref signals
	//FSM Parameter Define
	parameter	S_IDLE			= 4'd0;
	parameter	S_START_READY	= 4'd1;
	parameter	S_ISSUE_START	= 4'd2;
	parameter	S_SLAVE_ADDR	= 4'd3;
	parameter	S_REG_ADDR		= 4'd4;
	parameter	S_WR_DATA		= 4'd5;
	parameter	S_STOP			= 4'd6;
	parameter	S_ERROR			= 4'd7;
	parameter	S_RD_DATA		= 4'd8;


	reg		[3:0]	current_state	= S_IDLE;
	reg		[3:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	reg		[127:0]			state_ascii;
	always @ ( * ) begin
		case(current_state)
			4'd0 :	state_ascii	<= "IDLE";
			4'd1 :	state_ascii	<= "START_READY";
			4'd2 :	state_ascii	<= "ISSUE_START";
			4'd3 :	state_ascii	<= "SLAVE_ADDR";
			4'd4 :	state_ascii	<= "REG_ADDR";
			4'd5 :	state_ascii	<= "WR_DATA";
			4'd6 :	state_ascii	<= "STOP";
			4'd7 :	state_ascii	<= "ERROR";
			4'd8 :	state_ascii	<= "RD_DATA";
		endcase
	end
	// synthesis translate_on

	parameter	P_REG_ADDR_BYTE_NUM	= P_REG_ADDR_WIDTH/8;
	parameter	P_DATA_BYTE_NUM		= P_DATA_WIDTH/8;




	reg		[2:0]						clk_i2c_shift		= 3'b0;
	wire								clk_i2c_rise		;
	wire								clk_i2c_fall		;
	reg		[3:0]						clk_i2c_cnt			= 4'b0;
	reg		[3:0]						clk_i2c_fall_cnt	= 4'b0;
	reg									nwr_prd_reg			= 1'b0;
	reg		[3:0]						rd_num_reg			= 4'b0;
	reg		[7:0]						slave_addr_reg		= 8'b0;
	reg		[P_REG_ADDR_WIDTH-1:0]		reg_addr_reg		= {P_REG_ADDR_WIDTH{1'b0}};
	reg		[P_DATA_WIDTH-1:0]			wr_data_reg			= {P_DATA_WIDTH{1'b0}};
	reg									rd_first_cycle		= 1'b0;
	reg									second_byte			= 1'b0;
	reg		[8:0]						data_shifter		= 9'b0;
	reg									rd_valid_reg		= 1'b0;
	reg		[P_DATA_WIDTH-1:0]			rd_data_reg			= {P_DATA_WIDTH{1'b0}};

	reg									slave_addr_nack_reg	= 1'b0;
	reg									reg_addr_nack_reg	= 1'b0;
	reg									wr_data_nack_reg	= 1'b0;
	reg									i2c_done_reg		= 1'b0;
	wire								scl_in				;
	wire								sda_in				;
	reg									scl_out				=1'b1;
	reg									sda_out				=1'b1;
	reg		[3:0]						rd_num_cnt			= 4'b0;


	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref 异步信号处理
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	提取 clk_i2c 的边沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		clk_i2c_shift[2:0]	<= {clk_i2c_shift[1:0],clk_i2c};
	end
	assign	clk_i2c_rise	= (clk_i2c_shift[2:1]==2'b01) ? 1'b1 : 1'b0;
	assign	clk_i2c_fall	= (clk_i2c_shift[2:1]==2'b10) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	clk_i2c 计数器 在上升沿或下降沿的时候复位，其他时候累加。累加到最大值时，停止累加
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(clk_i2c_rise|clk_i2c_fall) begin
			clk_i2c_cnt	<= 4'b0;
		end
		else begin
			if(clk_i2c_cnt==4'hf) begin
				clk_i2c_cnt	<= clk_i2c_cnt;
			end
			else begin
				clk_i2c_cnt	<= clk_i2c_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	clk i2c的下降沿计数器
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((current_state==S_SLAVE_ADDR)||(current_state==S_REG_ADDR)||(current_state==S_WR_DATA)||(current_state==S_RD_DATA)) begin
			if((clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'hf)) begin
				clk_i2c_fall_cnt	<= 'b0;
			end
			else if(clk_i2c_fall) begin
				clk_i2c_fall_cnt	<= clk_i2c_fall_cnt + 1'b1;
			end
		end
		else if(current_state==S_IDLE) begin
			clk_i2c_fall_cnt	<= 'b0;
		end
	end

	//  ===============================================================================================
	//	ref 标志寄存器
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	保存参数
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((current_state==S_IDLE)&&(i_trig==1'b1)) begin
			nwr_prd_reg		<= i_nwr_prd;
			rd_num_reg		<= iv_rd_num;
			slave_addr_reg	<= iv_slave_addr;
			reg_addr_reg	<= iv_reg_addr;
			wr_data_reg		<= iv_wr_data;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	读命令处于哪个过程中，读命令需要两次start
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			rd_first_cycle	<= 1'b0;
		end
		else if((current_state==S_START_READY)&&(clk_i2c_rise==1'b1)) begin
			rd_first_cycle	<= !rd_first_cycle;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	reg addr、wr data 和 rd data 都可能有2个byte
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(current_state)
			S_IDLE : begin
				second_byte	<= 1'b0;
			end
			S_REG_ADDR : begin
				if((clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'hf)) begin
					if(second_byte==P_REG_ADDR_BYTE_NUM-1) begin
						second_byte	<= 1'b0;
					end
					else begin
						second_byte	<= !second_byte;
					end
				end
			end
			S_WR_DATA , S_RD_DATA : begin
				if((clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'hf)) begin
					if(second_byte==P_DATA_BYTE_NUM-1) begin
						second_byte	<= 1'b0;
					end
					else begin
						second_byte	<= !second_byte;
					end
				end
			end
		endcase
	end
	//  -------------------------------------------------------------------------------------
	//	读出了多少个数据
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			rd_num_cnt	<= 4'b0;
		end
		else if((current_state==S_RD_DATA)&&(clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'hf)&&(second_byte==P_DATA_BYTE_NUM-1)) begin
			rd_num_cnt	<= rd_num_cnt + 1'b1;
		end
	end

	//  ===============================================================================================
	//	ref 与移位相关
	//  ===============================================================================================
	always @ (posedge clk) begin
		if(current_state==S_SLAVE_ADDR) begin
			if(clk_i2c_fall_cnt==4'b0) begin
				if(nwr_prd_reg==1'b1) begin
					if(rd_first_cycle==1'b1) begin
						data_shifter[8:0]	<= {slave_addr_reg[7:1],1'b0,1'b1};
					end
					else begin
						data_shifter[8:0]	<= {slave_addr_reg[7:1],1'b1,1'b1};
					end
				end
				else begin
					data_shifter[8:0]	<= {slave_addr_reg[7:1],nwr_prd_reg,1'b1};
				end
			end
			else begin
				if((scl_in==1'b0)&&(clk_i2c_cnt==4'he)) begin
					data_shifter[8:0]	<= {data_shifter[7:0],1'b1};
				end
			end
		end

		else if(current_state==S_REG_ADDR) begin
			if(clk_i2c_fall_cnt==4'b0) begin
				if(second_byte==1'b0) begin
					data_shifter[8:0]	<= {reg_addr_reg[P_REG_ADDR_WIDTH-1:P_REG_ADDR_WIDTH-8],1'b1};
				end
				else begin
					//					data_shifter[8:0]	<= {reg_addr_reg[P_REG_ADDR_WIDTH-9:P_REG_ADDR_WIDTH-16],1'b1};		//ISE 不能综合这一句
					data_shifter[8:0]	<= {reg_addr_reg[P_REG_ADDR_WIDTH-1:P_REG_ADDR_WIDTH-8],1'b1};
				end
			end
			else begin
				if((scl_in==1'b0)&&(clk_i2c_cnt==4'he)) begin
					data_shifter[8:0]	<= {data_shifter[7:0],1'b1};
				end
			end
		end

		else if(current_state==S_WR_DATA) begin
			if(clk_i2c_fall_cnt==4'b0) begin
				if((second_byte==1'b0)) begin
					data_shifter[8:0]	<= {wr_data_reg[P_DATA_WIDTH-1:P_DATA_WIDTH-8],1'b1};
				end
				else begin
					data_shifter[8:0]	<= {wr_data_reg[P_DATA_WIDTH-9:P_DATA_WIDTH-16],1'b1};
				end
			end
			else begin
				if((scl_in==1'b0)&&(clk_i2c_cnt==4'he)) begin
					data_shifter[8:0]	<= {data_shifter[7:0],1'b1};
				end
			end
		end

		else if(current_state==S_RD_DATA) begin
			if((scl_in==1'b1)&&(clk_i2c_cnt==4'he)) begin
				data_shifter[8:0]	<= {data_shifter[7:0],sda_in};
			end
		end


	end

	//  -------------------------------------------------------------------------------------
	//	读出数据有效信号
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_RD_DATA) begin
			if((clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'he)) begin
				rd_valid_reg	<= 1'b1;
			end
			else begin
				rd_valid_reg	<= 1'b0;
			end
		end
		else begin
			rd_valid_reg	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	拼接输出数据
	//  -------------------------------------------------------------------------------------
	generate
		if(P_DATA_BYTE_NUM==1) begin
			always @ (posedge clk) begin
				if(rd_valid_reg==1'b1) begin
					rd_data_reg	<= data_shifter[8:1];
				end
			end

		end
		else if(P_DATA_BYTE_NUM==2) begin
			always @ (posedge clk) begin
				if(rd_valid_reg==1'b1) begin
					if(second_byte==1'b1) begin
						rd_data_reg[7:0]	<= data_shifter[8:1];
					end
					else begin
						rd_data_reg[15:8]	<= data_shifter[8:1];
					end
				end
			end
		end

	endgenerate

	//  -------------------------------------------------------------------------------------
	//	读结果输出
	//  -------------------------------------------------------------------------------------
	assign	ov_rd_data	= rd_data_reg;
	assign	o_rd_valid	= rd_valid_reg;


	//  ===============================================================================================
	//	ref 命令结束和错误处理
	//  ===============================================================================================

	//  -------------------------------------------------------------------------------------
	//	slave addr 没有ack
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_SLAVE_ADDR) begin
			if((clk_i2c_fall_cnt==4'h8)&&(clk_i2c_shift[2]==1'b1)&&(clk_i2c_cnt==4'hf)) begin
				if(sda_in==1'b1) begin
					slave_addr_nack_reg	<= 1'b1;
				end
			end
		end
		else if(current_state==S_START_READY) begin
			slave_addr_nack_reg	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	reg addr 没有ack
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_REG_ADDR) begin
			if((clk_i2c_fall_cnt==4'h8)&&(clk_i2c_shift[2]==1'b1)&&(clk_i2c_cnt==4'hf)) begin
				if(sda_in==1'b1) begin
					reg_addr_nack_reg	<= 1'b1;
				end
			end
		end
		else if(current_state==S_START_READY) begin
			reg_addr_nack_reg	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	reg addr 没有ack
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_WR_DATA) begin
			if((clk_i2c_fall_cnt==4'h8)&&(clk_i2c_shift[2]==1'b1)&&(clk_i2c_cnt==4'hf)) begin
				if(sda_in==1'b1) begin
					wr_data_nack_reg	<= 1'b1;
				end
			end
		end
		else if(current_state==S_START_READY) begin
			wr_data_nack_reg	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	I2C 命令结束
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((current_state==S_STOP)||(current_state==S_ERROR)) begin
			i2c_done_reg	<= 1'b1;
		end
		else if(current_state==S_START_READY) begin
			i2c_done_reg	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	状态位输出
	//  -------------------------------------------------------------------------------------
	assign		ov_status	= {wr_data_nack_reg,reg_addr_nack_reg,slave_addr_nack_reg,i2c_done_reg};

	//  ===============================================================================================
	//	ref 输出
	//  ===============================================================================================
	assign	scl		= (scl_out==1'b0) ? 1'b0 : 1'bz;
	assign	sda		= (sda_out==1'b0) ? 1'b0 : 1'bz;

	assign	scl_in	= scl;
	assign	sda_in	= sda;

	always @ (posedge clk) begin
		case(current_state)
			S_IDLE , S_START_READY , S_ERROR : begin
				sda_out	<= 1'b1;
			end
			S_ISSUE_START , S_STOP : begin
				sda_out	<= 1'b0;
			end
			S_SLAVE_ADDR , S_REG_ADDR , S_WR_DATA : begin
				sda_out	<= data_shifter[8];
			end
			S_RD_DATA : begin
				if(clk_i2c_fall_cnt==4'h8) begin
					if(clk_i2c_cnt==4'hf) begin
						sda_out	<= 1'b0;
					end
				end
				else if(clk_i2c_fall_cnt==4'h0) begin
					sda_out	<= 1'b1;
				end
			end
		endcase
	end

	always @ (posedge clk) begin
		case(current_state)
			S_IDLE : begin
				scl_out	<= 1'b1;
			end
			S_START_READY : begin
				scl_out	<= 1'b1;
			end
			default : begin
				scl_out	<= clk_i2c;
			end
		endcase
	end


	//  -------------------------------------------------------------------------------------
	//	未用到
	//  -------------------------------------------------------------------------------------
	assign	slave_exp	= 1'b0;



	//  ===============================================================================================
	//	ref 状态机
	//  ===============================================================================================
	//FSM Sequential Logic
	always @ (posedge clk) begin
		current_state	<= next_state;
	end

	//FSM Conbinatial Logic
	always @ ( * ) begin
		case(current_state)
			//  -------------------------------------------------------------------------------------
			//	当触发信号来的时候，根据读写信号，判读是读还是写
			//  -------------------------------------------------------------------------------------
			S_IDLE :
			if(i_trig==1'b1) begin
				next_state	= S_START_READY;
			end
			else begin
				next_state	= S_IDLE;
			end

			//  -------------------------------------------------------------------------------------
			//	clk_i2c 的上升沿来了，进入 start 信号发出的状态
			//  -------------------------------------------------------------------------------------
			S_START_READY :
			if(clk_i2c_rise==1'b1) begin
				next_state	= S_ISSUE_START;
			end
			else begin
				next_state	= S_START_READY;
			end

			//  -------------------------------------------------------------------------------------
			//	发出 start 信号
			//  -------------------------------------------------------------------------------------
			S_ISSUE_START :
			if((clk_i2c_shift[2]==1'b0)&&(clk_i2c_cnt==4'hf)) begin
				next_state	= S_SLAVE_ADDR;
			end
			else begin
				next_state	= S_ISSUE_START;
			end

			//  -------------------------------------------------------------------------------------
			//	发出 slave addr
			//	1. ack 不响应，退出到error状态
			//	2. 如果是读命令，且在第2次读的过程中，写完slave addr 之后，要进入读数据的状态
			//	3. 其他情况下，进入写 reg addr 的状态
			//  -------------------------------------------------------------------------------------
			S_SLAVE_ADDR :
			if((clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'hf)) begin
				if(slave_addr_nack_reg==1'b1) begin
					next_state	= S_ERROR;
				end
				else begin
					if((nwr_prd_reg==1'b1)&&(rd_first_cycle==1'b0)) begin
						next_state	= S_RD_DATA;
					end
					else begin
						next_state	= S_REG_ADDR;
					end
				end
			end
			else begin
				next_state	= S_SLAVE_ADDR;
			end

			//  -------------------------------------------------------------------------------------
			//	发出 reg addr
			//	1. ack 不响应，退出到error状态
			//	2. 如果是读命令，那么肯定是在第一次的过程中，写完 reg addr 之后，要重发 start
			//	3. 其他情况下，进入写 数据 的状态
			//  -------------------------------------------------------------------------------------
			S_REG_ADDR :
			if((clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'hf)) begin
				if(reg_addr_nack_reg==1'b1) begin
					next_state	= S_ERROR;
				end
				else begin
					if(second_byte==P_REG_ADDR_BYTE_NUM-1) begin
						if(nwr_prd_reg==1'b1) begin
							next_state	= S_START_READY;
						end
						else begin
							next_state	= S_WR_DATA;
						end
					end
					else begin
						next_state	= S_REG_ADDR;
					end
				end
			end
			else begin
				next_state	= S_REG_ADDR;
			end

			//  -------------------------------------------------------------------------------------
			//	写数据
			//	1. 每次写的数据量是1byte，如果数据宽度大于8，要写多次
			//	2. ACK之后，要检查是否到了数据量，到达数据量，退出。目前不支持连续写的方式
			//  -------------------------------------------------------------------------------------
			S_WR_DATA :
			if((clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'hf)) begin
				if(wr_data_nack_reg==1'b1) begin
					next_state	= S_ERROR;
				end
				else begin
					if(second_byte==P_DATA_BYTE_NUM-1) begin
						next_state	= S_STOP;
					end
					else begin
						next_state	= S_WR_DATA;
					end
				end
			end
			else begin
				next_state	= S_WR_DATA;
			end

			//  -------------------------------------------------------------------------------------
			//	结束
			//  -------------------------------------------------------------------------------------
			S_STOP :
			if((clk_i2c_shift[2]==1'b1)&&(clk_i2c_cnt==4'hf)) begin
				next_state	= S_IDLE;
			end
			else begin
				next_state	= S_STOP;
			end

			//  -------------------------------------------------------------------------------------
			//	出错
			//  -------------------------------------------------------------------------------------
			S_ERROR :
			next_state	= S_IDLE;

			//  -------------------------------------------------------------------------------------
			//	读数据
			//	1. 每次读的数据量是1byte，如果数据宽度大于8，要写多次
			//	2. ACK之后，要检查是否到了数据量:到达数据量，退出。未到达数据量，继续读。
			//  -------------------------------------------------------------------------------------
			S_RD_DATA :
			if((clk_i2c_fall_cnt==4'h9)&&(clk_i2c_cnt==4'hf)) begin
				if(second_byte==P_DATA_BYTE_NUM-1) begin
					if(rd_num_cnt==rd_num_reg) begin
						next_state	= S_STOP;
					end
					else begin
						next_state	= S_RD_DATA;
					end
				end
				else begin
					next_state	= S_RD_DATA;
				end
			end
			else begin
				next_state	= S_RD_DATA;
			end
			default :
			next_state	= S_IDLE;
		endcase
	end



endmodule
