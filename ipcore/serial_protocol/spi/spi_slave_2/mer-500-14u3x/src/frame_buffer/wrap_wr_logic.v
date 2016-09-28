//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : frame_buffer
//  -- 设计者       : 邢海涛、张强
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2013/6/14 14:00:40	:|  初始版本
//  -- 张强         :| 2014/11/27 10:16:54	:|  移植到MER-U3V工程，根据产品要求适当修改
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :	帧缓存模块顶层
//						1）完成帧图像经前端FIFO数据写入和读出，MCBP2口数据写入的过程
//						2）完成写指针（图像计数）地址变换、写地址（字节计数）变换以及其他控制命令生成
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
module wrap_wr_logic # (
	parameter						DATA_WD				= 32			,	//输出数据位宽，这里使用同一宽度
	parameter						BUF_DEPTH_WD		= 4				,	//帧存深度位宽,包含进位位,我们使用1G bit sDDR最大支持8帧深度，宏定义不能超过4
	parameter						ADDR_WD   			= 20-BUF_DEPTH_WD,	//帧内地址位宽
	parameter						BURST_SIZE			= 7'h40			,	//BURST_SIZE大小
	parameter						REG_WD   			= 32				//寄存器位宽
	)
	(
//  -------------------------------------------------------------------------------------
//  视频输入时钟域
//  -------------------------------------------------------------------------------------
	input							clk_vin								,	//前端FIFO写入数据时钟
	input							i_fval								,	//场有效信号，高有效，clk_vin时钟域,i_fval的上升沿要比i_dval的上升沿提前，i_fval的下降沿要比i_dval的下降沿滞后；i_fval和i_dval上升沿之间要有足够的空隙，最小值是MAX(6*clk_vin,6*clk_frame_buf)；i_fval和i_dval下降沿之间要有足够的空隙，最小值是1*clk_vin + 7*clk_frame_buf
	input							i_dval								,	//数据有效信号，高有效，clk_vin时钟域，数据有效不向行信号一样连续，可以是断续的信号
	input							i_trailer_flag						,	//尾包标志
	input		[DATA_WD-1		:0]	iv_image_din						,	//图像数据，32位宽，clk_vin时钟域
	input							i_stream_en_clk_in					,	//流停止信号，clk_in时钟域，信号有效时允许数据完整帧写入帧存，无效时立即停止写入，并复位读写地址指针，清帧存
//  -------------------------------------------------------------------------------------
//  控制数据
//  -------------------------------------------------------------------------------------
	input							i_stream_en							,	//流停止信号，clk时钟域，信号有效时允许数据完整帧写入帧存，无效时立即停止写入，并复位读写地址指针，清帧存
	input		[BUF_DEPTH_WD-1	:0]	iv_frame_depth						,	//帧缓存深度，clk时钟域，可设置为 2-8任意值，具体深度可以停止采集才能更新帧存深度。
	input		[6				:0]	iv_p2_wr_count						,	//mig_core输出，clk_frame_buf时钟域，mcb p2 口数据fifo数据个数
	output	reg	[BUF_DEPTH_WD-1	:0]	ov_frame_depth						,	//帧缓存深度，clk时钟域，可设置为 2-8任意值，具体深度可以停止采集才能更新帧存深度,经过停采生效时机控制。
//  -------------------------------------------------------------------------------------
//  帧缓存工作时钟域
//  -------------------------------------------------------------------------------------
	input							clk									,	//MCB P2工作时钟
	input							reset								,	//
	output	reg	[BUF_DEPTH_WD-1	:0]	ov_wr_frame_ptr						,	//写指针,以帧为单位
	output	reg	[ADDR_WD-1		:0]	ov_wr_addr							,	//clk_frame_buf时钟域，P2口命令使能信号，标志写地址已经生效，在仲裁保证下，数据能够写入DDR，此信号对地址判断非常重要
	output	reg						o_wr_frame_ptr_changing				,	//clk_frame_buf时钟域，写指针正在变化信号，输出给读模块，此时读指针不能变化
	input		[BUF_DEPTH_WD-1 :0]	iv_rd_frame_ptr						,	//读指针,以帧为单位
	output	reg						o_se_2_fvalrise						,	//停采到下一帧场信号上升沿，为了避免一帧之内的重同步，将信号展宽后传给读模块，clk时钟域，低电平标志停采
//  -------------------------------------------------------------------------------------
//  MCB端口
//  -------------------------------------------------------------------------------------
	input							i_calib_done						,	//MCB校准完成信号，高有效
	output	reg						o_p2_cmd_en							,	//MCB CMD FIFO 写信号，高有效
	output		[2				:0]	ov_p2_cmd_instr						,	//MCB CMD FIFO 指令
	output	reg	[5				:0]	ov_p2_cmd_bl						,	//MCB CMD FIFO 突发长度
	output		[29				:0]	ov_p2_cmd_byte_addr					,	//MCB CMD FIFO 起始地址
	input							i_p2_cmd_empty						,	//MCB CMD FIFO 空信号，高有效
	output							o_p2_wr_en							,	//MCB WR FIFO 写信号，高有效
	output		[3				:0]	ov_p2_wr_mask						,	//MCB WR 屏蔽信号
	output		[DATA_WD-1		:0]	ov_p2_wr_data						,	//MCB WR FIFO 写数据
	input							i_p2_wr_full							//MCB WR FIFO 满信号，高有效
	);
//  ===============================================================================================
//  第一部分：参数、线网和寄存器定义
//  ===============================================================================================

	parameter						S_IDLE					= 5'b00000	;
	parameter						S_REQ					= 5'b00001	;
	parameter						S_WR					= 5'b00010	;
	parameter						S_CMD_CHK				= 5'b00100	;
	parameter						S_CMD					= 5'b01000	;
	parameter						S_CHK					= 5'b10000	;

	reg			[4				:0]	current_state						;	//current_state
	reg			[4				:0]	next_state							;	//next_state
	wire							data_valid							;	//数据有效
	wire							reset_fifo							;	//front FIFO reset,once per frame
	reg								fval_rise_edge_clk_vin	=1'b0		;	//the rising edge of fval in clk_vin timing
	reg			[1				:0]	calib_done_shift		=2'b00    	;	//the shift registers of i_calib_done
	reg			[2				:0]	favl_shift_clk_vin		=3'b000     ;	//the shift registers of i_fval in clk_vin timing
	reg			[2				:0]	favl_shift_clk			=3'b000     ;	//the shift registers of i_fval
	reg								cmd_en_reg				=1'b0		;	//command enable register
	reg			[6				:0]	word_cnt				=BURST_SIZE	;	//the number of datas that are writed into MCB data fifo
	reg								fifo_rd_leader_payload_en			;	//front fifo leader payload read enable
	wire		[DATA_WD-1		:0]	wv_p2_wr_data						;	//front fifo readout data
	wire							fifo_full_nc						;	//front fifo full flag
	wire		                    fifo_empty					        ;	//front fifo empty flag
	wire		                    fifo_valid					        ;	//front fifo data valid flag
	wire		                    fifo_prog_full_nc			        ;	//front fifo prog_full
	wire		                    fifo_prog_empty				        ;	//front fifo prog_empty
	reg			[7				:0]	pipeline_shift			=8'h1		;	//pipeline counter
	reg			[ADDR_WD-1		:0]	wr_addr_reg							;	//writing address
	reg								ptr_judge1							;	//frame point judge 1
	reg								ptr_judge2							;	//frame point judge 2
	reg			[BUF_DEPTH_WD-1 :0]	inc_value							;	//frame point increase value
	reg								first_frame_flag		=1'b0		;	//the flag of the first frame
	reg			[1				:0]	p2_cmd_empty_shfit					;
	reg			[1				:0]	cmden_2_cmdfempty_shift				;
	reg								cmden_2_cmdfempty					;
	wire							addr_valid							;
	reg			[BUF_DEPTH_WD-1	:0]	wr_frame_ptr						;
	reg								se_2_fvalrise_clk_in				;
	wire		[DATA_WD 		:0]	fifo_din							;	//fifo数据输入33bits
	wire		[DATA_WD 		:0]	fifo_dout							;	//fifo数据输出33bits
	wire							trailer_flag_fifoout				;
	reg      	[3				:0]	trailer_flag_fifoout_shift			;
	reg								wr_flag	=1'b0						;
	reg			[1				:0]	wr_flag_shift	=2'b0				;
	reg								trailer_wr_en_flag	=1'b0			;	//mask the writing to fifo
//  -------------------------------------------------------------------------------------
//	FSM for sim
//  -------------------------------------------------------------------------------------
// synthesis translate_off
	integer			state_ascii;
	always @ ( * ) begin
		case(current_state)
			5'b00000 :	state_ascii	<= "S_IDLE";
			5'b00001 :	state_ascii	<= "S_REQ";
			5'b00010 :	state_ascii	<= "S_WR";
			5'b00100 :	state_ascii	<= "S_CMD_CHK";
			5'b01000 :	state_ascii	<= "S_CMD";
			5'b10000 :	state_ascii	<= "S_CHK";
		endcase
	end
// synthesis translate_on

//  ===============================================================================================
//  第二部分：clk_vin时钟域辅助逻辑：
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	对信号进行移位处理
//  -------------------------------------------------------------------------------------
	always @ (posedge clk_vin)
	begin
		favl_shift_clk_vin	<= {favl_shift_clk_vin[1:0],i_fval};
	end

	always @ (posedge clk )
	begin
		trailer_flag_fifoout_shift	<= {trailer_flag_fifoout_shift[3:0],trailer_flag_fifoout};
	end

	always @ (posedge clk )
	begin
		wr_flag_shift	<= {wr_flag_shift[0],wr_flag};
	end

//  -------------------------------------------------------------------------------------
//	取场信号的上升沿/下降沿，上升沿/下降沿标志较实际上升沿/下降沿延时3个时钟
//  -------------------------------------------------------------------------------------
	always @ (posedge clk_vin)
	begin
		if ( favl_shift_clk_vin[2:1] == 2'b01 ) begin
			fval_rise_edge_clk_vin	=	1'b1;
		end
		else begin
			fval_rise_edge_clk_vin	=	1'b0;
		end
	end
//  -------------------------------------------------------------------------------------
//	对i_stream_en进行时钟域同步，同步到clk_vin
//  -------------------------------------------------------------------------------------

	always @ (posedge clk)
	begin
		if( ~i_stream_en )								//流停采期间一直复位
		begin
			o_se_2_fvalrise	<= 1'b0;
		end
		else if ( favl_shift_clk[2:1] == 2'b01 )		//直到场信号上升沿到来
		begin
			o_se_2_fvalrise	<= 1'b1;
		end
	end


	always @ (posedge clk_vin)
	begin
		if( ~i_stream_en_clk_in )				//流停采期间一直复位
		begin
			se_2_fvalrise_clk_in	<= 1'b0;
		end
		else if ( favl_shift_clk_vin[2:1] == 2'b01 )	//直到场信号上升沿到来
		begin
			se_2_fvalrise_clk_in	<= 1'b1;
		end
	end
//  -------------------------------------------------------------------------------------
//	使用场信号的上升沿和停采作为fifo复位信号：停采复位和周期复位结合
//	行场同时有效时数据有效
//	复位期间不能写入，否则空信号会异常
//  -------------------------------------------------------------------------------------
	assign	reset_fifo = fval_rise_edge_clk_vin	|| (~se_2_fvalrise_clk_in);
	assign	data_valid = i_fval & i_dval & (!reset_fifo);

//  ===============================================================================================
//  第三部分FIFO例化：FIFO宽32深256,可编程满180，可编程空6,fisrt word fall through
//  ===============================================================================================

	assign	fifo_din 		= {i_trailer_flag,iv_image_din};
	assign	wv_p2_wr_data	= fifo_dout[DATA_WD-1:0];
	assign	trailer_flag_fifoout	= fifo_dout[DATA_WD];


	fifo_w33d256_pf180_pe6 fifo_w33d256_pf180_pe6_inst (
	.rst			(reset_fifo			), 	// input rst
	.wr_clk			(clk_vin            ), 	// input wr_clk
	.rd_clk			(clk                ), 	// input rd_clk
	.din			(fifo_din       	), 	// input [31 : 0] din
	.wr_en			(data_valid         ), 	// input wr_en
	.rd_en			(fifo_rd_en         ), 	// input rd_en
	.dout			(fifo_dout      	), 	// output [31 : 0] dout
	.full			(fifo_full_nc	    ), 	// output full
	.empty			(fifo_empty		    ), 	// output empty
	.valid			(fifo_valid		    ), 	// output valid
	.prog_full		(fifo_prog_full_nc  ), 	// output prog_full
	.prog_empty		(fifo_prog_empty	) 	// output prog_empty
	);


//  ===============================================================================================
//  第四部分：clk时钟域辅助逻辑：
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	停止采集时才能切换帧存深度
//  -------------------------------------------------------------------------------------
	always @ (posedge clk )
	begin
		if(reset)
		begin
			ov_frame_depth	<=	{{(BUF_DEPTH_WD-2){1'b0}},2'b10};
		end
		else if ( ~i_stream_en )
		begin
			ov_frame_depth	<=	iv_frame_depth;
		end
	end
//  -------------------------------------------------------------------------------------
//	对信号进行移位处理
//  -------------------------------------------------------------------------------------
	always @ (posedge clk )
	begin
		calib_done_shift	<= {calib_done_shift[0],i_calib_done};
	end
	always @ (posedge clk )
	begin
		p2_cmd_empty_shfit	<= {p2_cmd_empty_shfit[0],i_p2_cmd_empty};
	end
	always @ (posedge clk)
	begin
		favl_shift_clk	<= {favl_shift_clk[1:0],i_fval};
	end
//  -------------------------------------------------------------------------------------
//	生成地址生效标志：从命零执行到FIFO为空
//  -------------------------------------------------------------------------------------

	always @ (posedge clk)
	begin
		if( o_p2_cmd_en )
		begin
			cmden_2_cmdfempty <= 1'b1;
		end
		else if ( p2_cmd_empty_shfit== 2'b01 )
		begin
			cmden_2_cmdfempty <= 1'b0;
		end
	end
//	信号移位
	always @ (posedge clk)
	begin
		cmden_2_cmdfempty_shift	<= {cmden_2_cmdfempty_shift[0],cmden_2_cmdfempty};
	end
//	命令由发出到命令fifo空信号的下降沿标志参数已生效
	assign  addr_valid = ( cmden_2_cmdfempty_shift == 2'b10 )? 1'b1: 1'b0;
//  ===============================================================================================
//  第四部分：三段式状态机
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	第一段
//  -------------------------------------------------------------------------------------
	always @ (posedge clk )
	begin
		if(reset)
		begin
			current_state	<=	S_IDLE;
		end
		else
		begin
			current_state	<=	next_state;
		end
	end
//  -------------------------------------------------------------------------------------
//	第二段
//	前端FIFO为开环设计，写入多少数据就需要及时取走多少数据，前端FIFO原则上不能满，否则
//	超出设计容限
//  -------------------------------------------------------------------------------------
	always @  *
	begin
		next_state = S_IDLE;
		case( current_state )
		S_IDLE	:
			begin											//DDR校验完成，场有效为高，FIFO中有数，开采
				if ( calib_done_shift[1] && favl_shift_clk[1] && ~fifo_prog_empty && o_se_2_fvalrise )
				begin
					next_state = S_REQ;
				end
				else
				begin
					next_state = S_IDLE;
				end
			end
		S_REQ	:
			begin
				if ( pipeline_shift==8'h80 )				//延迟7拍
				begin
					next_state = S_WR;
				end
				else
				begin
					next_state = S_REQ;
				end
			end
		S_WR	:											//word_cnt有几种情况
			begin
				if(wr_flag_shift[1:0] == 2'b10)				//将跳转条件合并为一个条件wr_flag的下降沿控制条件跳转
				begin
					next_state = S_CMD_CHK;
				end
				else										//4）有数据写入，但不足burst数据量
				begin
					next_state = S_WR;
				end
			end
		S_CMD_CHK:
			begin
				if ( i_p2_cmd_empty )						//命令FIFO空，可以发出命令，转到命令状态
				begin
					next_state = S_CMD;
				end
				else										//命令FIFO非空，继续等待
				begin
					next_state = S_CMD_CHK;
				end
			end
		S_CMD	:											//命令状态单周期宽度，之后跳转到查询
			begin
					next_state = S_CHK;
			end
		S_CHK	:
			begin
				if ( ~favl_shift_clk[1] && fifo_empty)		//1）检查一帧图像是否结束且前端FIFO无数据，如果是这样则返回空闲状态
				begin
					next_state = S_IDLE;
				end
				else										//2) 否则还有数据继续写入
				begin
					next_state = S_WR;
				end
			end
		default	:											//添加默认状态
				begin
					next_state = S_IDLE;
				end
		endcase
	end
//  -------------------------------------------------------------------------------------
//	第三段
//  -------------------------------------------------------------------------------------
	always @ ( posedge clk  )
	begin
		if ( reset )
		begin
			o_p2_cmd_en					<= 1'b0			;
			word_cnt					<= 7'h0			;
			wr_addr_reg					<= {ADDR_WD{1'b0}}	;
			pipeline_shift				<= 8'h01		;
			fifo_rd_leader_payload_en 	<= 1'b0			;
			ov_p2_cmd_bl				<= 6'h3f		;
			trailer_wr_en_flag			<= 1'b0			;
		end
		else
		begin
			o_p2_cmd_en					<= 1'b0			;
			case( next_state )
				S_IDLE	:
				begin
					word_cnt			<= 7'h0			;
					pipeline_shift		<= 8'h01		;
					ov_p2_cmd_bl		<= 6'h3f		;
					wr_flag				<= 1'b0			;
					trailer_wr_en_flag	<= 1'b0			;
					if( !o_se_2_fvalrise )
						begin
							wr_addr_reg	<=	{ADDR_WD{1'b0}}		;		//重同步保证地址归零
						end
				end
				S_REQ	:
				begin
					pipeline_shift		<= pipeline_shift << 1	;
					wr_addr_reg			<= {ADDR_WD{1'b0}}		;
					fifo_rd_leader_payload_en <= 1'b1			;
					trailer_wr_en_flag	<= 1'b0					;
				end
//读到尾包标志时拉低wr_flag，检测到场消隐和前端FIFO空信号标志时拉低wr_flag，继而跳出写状态
				S_WR	:
				begin
					if( {trailer_flag_fifoout_shift[3],trailer_flag_fifoout} == 2'b01 )
						begin
							wr_flag <=1'b0;
						end
					else if ( ~favl_shift_clk[1] && fifo_empty)
						begin
							wr_flag <=1'b0;
						end
					else if(word_cnt>=BURST_SIZE-1)
						begin
							if(o_p2_wr_en)
								wr_flag <=1'b0;
							else
								wr_flag <=1'b1;
						end
					else
						begin
							wr_flag <=1'b1;
						end
					if ( o_p2_wr_en)									//对有效的数据进行统计只统计写入部分。
						begin
							word_cnt<=  word_cnt + 1	;
						end
					if ( trailer_flag_fifoout && wr_flag &&( ~i_p2_wr_full ) && ( ~fifo_empty ) )
						begin
							trailer_wr_en_flag	<= 1'b1	;
						end
				end
				S_CMD_CHK:
				begin
					wr_flag 		<=	1'b0;
				end
				S_CMD	:
				begin
					o_p2_cmd_en		<=	1'b1			;
					if( !o_se_2_fvalrise )
						begin
							ov_p2_cmd_bl	<=  6'h3f;		//停止采集时将P2口fifo中剩余的数据量作为burst lenth发出，或者使用
						end
					else
						begin
							ov_p2_cmd_bl	<=  word_cnt-1		;		//burst lenth长度
						end
				end
				S_CHK	:
				begin
					word_cnt		<=	7'h00			;				//计数复位
					wr_flag 		<=	1'b0			;
					if( trailer_flag_fifoout )							//计到帧尾，地址直接赋值
						begin
							wr_addr_reg <= {{(ADDR_WD-1){1'b1}},1'b0};	//trailer地址在帧地址最末端
						end
					else
						begin
							wr_addr_reg	<=	wr_addr_reg + 1	;		//每一次写命令累加1
						end
				end
			endcase
		end
	end


//  ===============================================================================================
//  第五部分：MCB P2端口控制信号
//  ===============================================================================================
//	o_p2_wr_en最好使用组合逻辑，否则P2口的满信号会有延时，导致不能立即感知P2口FIFO满信号，
//	如果必须使用时序逻辑，需待P2 FIFO空之后再写入，并对写入数据计数，记到FIFO深度
	assign	ov_p2_wr_mask		= 4'b0000		;
//	assign	ov_p2_cmd_bl		= 6'h3f			;	//此处一直是 6'h3f，当图像帧尾的时候，保证P2口能被有效清空
	assign	ov_p2_cmd_instr		= 3'b000		;	//MCB使能了自动预充电，所以命令不带
	assign	ov_p2_cmd_byte_addr	= {{2'b00},wr_frame_ptr,wr_addr_reg,8'h00};	//地址指针拼接：帧指针+写地址+8'h00
	assign	ov_p2_wr_data 		= wv_p2_wr_data;	//组合逻辑，FIFO输出的数据直接写入P2 FIFO
//	P2口写条件：处于写状态、P2	FIFO不满、计数不足BURST_SIZE、前端FIFO非空、前端数据有效（为保证多读出的数据不被写入）
//	assign	fifo_rd_en			= (next_state == S_WR) &&(~i_p2_wr_full) && (word_cnt < BURST_SIZE) && (~fifo_empty);//
	assign	fifo_rd_en			= wr_flag &&( ~i_p2_wr_full ) && ( ~fifo_empty ) && o_se_2_fvalrise ;	//2015/8/7 17:30:58只有在开采状态下才允许读和写
	assign	o_p2_wr_en			= fifo_rd_en && ( (~trailer_flag_fifoout) || trailer_wr_en_flag);	//会写入一个多余的数据，有后端读控制不读出


//  ===============================================================================================
//  第六部分：写指针和写地址的计算与生效控制
//  ===============================================================================================
//	写地址需考虑以下几点：
//  1、设备重同步，重同步地址需要归零
//	2、写地址和写指针需保证同时更新
//	3、写地址需要先于读地址变化
//	4、写指针要将变化及时传递给帧存读出侧，否则可能导致读出侧误判，导致误读，且在变化时保证读出侧读指针不能变化
	always @ (posedge clk)
	begin
		if (reset)
		begin
			ov_wr_addr 		<= {ADDR_WD{1'b0}};
		end
		else if (~o_se_2_fvalrise)					//添加流停采复位，当o_se_2_fvalrise为低时写地址需先于读地址变化，才能保证追赶正确
		begin
			ov_wr_addr 		<= {ADDR_WD{1'b0}};
		end
		else if ( addr_valid || pipeline_shift[4] )	//命令被执行后生效,帧地址更新的时候写地址也需要更新
		begin
			ov_wr_addr 		<= wr_addr_reg;
		end
	end

//	读指针变化完成后一排控制指针生效
	always @ (posedge clk)
	begin
		if (reset)
		begin
			ov_wr_frame_ptr	<= {(BUF_DEPTH_WD){1'b0}};
		end
		else if (~o_se_2_fvalrise)					//添加流停采复位，当o_se_2_fvalrise为低时写地址需先于读地址变化，才能保证追赶正确
		begin
			ov_wr_frame_ptr	<= {(BUF_DEPTH_WD){1'b0}};
		end
		else if ( pipeline_shift[4] )
		begin
			ov_wr_frame_ptr	<= wr_frame_ptr;
		end
	end

//	写指针变化期间和生效时读指针均不能变化
	always @ (posedge clk )
	begin
		if( pipeline_shift[4:1]!=0 )
			o_wr_frame_ptr_changing <= 1'b1;
		else
			o_wr_frame_ptr_changing <= 1'b0;
	end
//  -------------------------------------------------------------------------------------
//	帧指针逻辑：默认写指针优先读指针变化，所以当写指针大于读指针时，如果写指针下一个
//	地址不是读指针，写指针+1，如果是则+2；
//	同理当读指针大于写指针时，意味着写指针已经进位，同样如果写指针下一个地址不是
//	读指针，写指针+1，如果是则+2；
//	iv_rd_frame_ptr + ov_frame_depth - wr_frame_ptr = 1 用来判断写指针是否要追上读指针
//  -------------------------------------------------------------------------------------
//  此逻辑控制开采后第一帧地址不累加，直到第一帧开始写之后标志才有效。这样第一次写的指针是从0开始而不是1开始
	always @ (posedge clk)
	begin
		if(~o_se_2_fvalrise)
		begin
			first_frame_flag <= 1'b0;
		end
		else if(pipeline_shift[5])
		begin
			first_frame_flag <= 1'b1;
		end
	end
//  -------------------------------------------------------------------------------------
//	帧指针逻辑三拍流水设计：
//	第一拍：先判断写指针下一个目标位是否就是读指针，如果是则需要越过读指针，否则累加即可
//	第二拍：确定累加值，是加1还是加2
//	第三排：考虑进位情况，确定最终指针
//  -------------------------------------------------------------------------------------
//  此逻辑控制开采后第一帧地址不累加，直到第一帧开始写之后标志才有效。这样第一次写的指针是从0开始而不是1开始
	always @ (posedge clk)
	begin
		if(!(o_se_2_fvalrise &&first_frame_flag))
		begin										//停止采集指针复位
			wr_frame_ptr	<= {(BUF_DEPTH_WD){1'b0}};
			ptr_judge1		<= 1'b0;
			ptr_judge2		<= 1'b0;
			inc_value		<= {{(BUF_DEPTH_WD-1){1'b0}},{1'b1}};
		end
		else if(pipeline_shift[1])
		begin
			if ( iv_rd_frame_ptr + ov_frame_depth - wr_frame_ptr == 1   )
			begin
				ptr_judge1	<=1'b1;
			end
			else
			begin
				ptr_judge1	<=1'b0;
			end
			if ( iv_rd_frame_ptr - wr_frame_ptr == 1   )
			begin
				ptr_judge2	<=1'b1;
			end
			else
			begin
				ptr_judge2	<=1'b0;
			end
		end
		else if(pipeline_shift[2])						//在写允许的cycle内移动写指针
		begin
			if ( wr_frame_ptr >= iv_rd_frame_ptr  )
			begin
				if ( ptr_judge1 )
				begin
					inc_value	<= {{(BUF_DEPTH_WD-2){1'b0}},{2'b10}}	;		//2
				end
				else
				begin
					inc_value	<= {{(BUF_DEPTH_WD-1){1'b0}},{1'b1}}	;		//1
				end
			end
			else
			begin
				if ( ptr_judge2)
				begin
					inc_value	<= {{(BUF_DEPTH_WD-2){1'b0}},{2'b10}}	;		//2
				end
				else
				begin
					inc_value	<= {{(BUF_DEPTH_WD-1){1'b0}},{1'b1}}	;		//1
				end
			end
		end
		//如果写指针超过了帧存深度，需要减去深度部分
		else if(pipeline_shift[3])
		begin
			if ( wr_frame_ptr + inc_value > ov_frame_depth -1 )
			begin
				wr_frame_ptr <=	wr_frame_ptr + inc_value - ov_frame_depth;
			end
			else
			begin
				wr_frame_ptr <= wr_frame_ptr + inc_value;
			end
		end
	end

endmodule