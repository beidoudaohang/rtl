//--------------------------------s-----------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : wrap_rd_logic
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2013/6/14 13:40:52	:|  初始版本
//  -- 张强         :| 2014/11/27 10:16:54	:|  移植到MER-U3V工程，根据产品要求适当修改
//  -- 张强         :| 2015/10/15 17:22:35	:|  将port口扩展为64bit宽度
//  -- 邢海涛       :| 2016/9/14 16:25:07	:|  多ROI版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :	读逻辑顶层
//              1)  : 完成帧图像从MCBP3口读出，写入后端FIFO，并供后端FIFO读出的逻辑，
//              2)  : 完成读出数据统计，保证读出数据和u3v协议要求数据相等
//              3)  : 完成读指针（图像计数）地址变换、读地址（字节计数）变换以及其他控制命令生成
//
//-------------------------------------------------------------------------------------------------

//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module wrap_rd_logic # (
	//	parameter						WORD_FACTOR			= 3					,	//DATA_WD对应的一个字所对应的字节数
	parameter	DATA_WD								= 64			,	//输出数据位宽，这里使用同一宽度
	parameter	BACK_DATA_WD						= 32			,	//后端输出数据位宽
	parameter	ADDR_WD   							= 19			,	//帧内地址位宽 19=30-2-9,9bit由64位宽864深度决定，128M对应27位，wr_frame_ptr含一个进位bit所以-2
	parameter	PTR_WIDTH							= 2				,	//读写指针的位宽，1-最大2帧 2-最大4帧 3-最大8帧 4-最大16帧 5-最大32帧
	parameter	BURST_SIZE							= 32			,	//BURST_SIZE大小
	parameter	DDR3_MASK_SIZE						= 8				,	//mask size
	parameter	ADDR_DUMMY_BIT						= 9				,	//MCB BYTE ADDR 低位为0的个数
	parameter	DDR3_MEM_DENSITY					= "1Gb"			,	//DDR3 容量 "2Gb" "1Gb" "512Mb"
	parameter	REG_WD  							= 32				//寄存器位宽
	)
	(
	//	===============================================================================================
	//	图像输出时钟域
	//	===============================================================================================
	input							clk_vout						,	//后级时钟，同U3_ITERFACE 模块时钟域
	input							i_buf_rd						,	//后级模块读使能，高有效，clk_vout时钟域
	output							o_buf_empty						,	//后级FIFO空信号，高有效，clk_vout时钟域
	output	[BACK_DATA_WD-1:0]		ov_dout							,	//后级FIFO数据输出，宽度32bit
	//	===============================================================================================
	//	帧缓存工作时钟域
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  与 wrap_wr_logic 交互
	//  -------------------------------------------------------------------------------------
	input							clk								,	//MCB 工作时钟
	input							reset							,	//clk时钟域复位信号
	input	[PTR_WIDTH-1:0]			iv_wr_ptr						,	//写指针
	input	[ADDR_WD-1:0]			iv_wr_addr						,	//写地址,应该是命令生效之后的写地址
	output	[PTR_WIDTH-1:0]			ov_rd_ptr						,	//读指针
	//  -------------------------------------------------------------------------------------
	//  控制数据
	//  -------------------------------------------------------------------------------------
	input							i_se_2_fvalrise					,	//停采到下一帧场信号上升信号，停采期间为低，开采为高，为了避免一帧之内的重同步，将信号展宽后传给读模块，clk时钟域，低电平标志停采
	input	[PTR_WIDTH-1:0]			iv_frame_depth					,	//帧缓存深度，已同步,wrap_wr_logic模块已做生效时机控制
	input	[BYTE_ADDR_WD-1:0]		iv_payload_size					,	//帧缓存大小，以Byte为单位
	input							i_wr_ptr_changing				,	//写指针正在变化信号，此时读指针不能变化
	input							i_chunk_mode_active				,	//chunk总开关，chunk开关影响leader和trailer的大小，通过判断chunk开关可以知道leader和trailer长度
	//  -------------------------------------------------------------------------------------
	//  MCB端口
	//  -------------------------------------------------------------------------------------
	input							i_calib_done					,	//MCB校准完成，高有效
	input							i_rd_cmd_empty					,	//MCB CMD 空，高有效
	output							o_rd_cmd_en						,	//MCB CMD 写使能，高有效
	output	[2:0]					ov_rd_cmd_instr					,	//MCB CMD 指令
	output	[5:0]					ov_rd_cmd_bl					,	//MCB CMD 突发长度
	output	[29:0]					ov_rd_cmd_byte_addr				,	//MCB CMD 起始地址
	input	[DATA_WD-1:0]			iv_rd_data						,	//MCB RD FIFO 数据输出
	input							i_rd_empty						,	//MCB RD FIFO 空，高有效
	output							o_rd_en								//MCB RD FIFO 读使能，高有效
	);






	//  ===============================================================================================
	//  第二部分：辅助逻辑
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	帧存中有数据，允许读出标志:
	//	设计需要保证以下两个前提条件：
	//	1）写指针、写地址必须先于读指针、读地址变化
	//	2）写指针、写地址要同时变化，一个时钟内变化
	//	1、当帧地址指针不同时，且读指针地址不为零时可以读出
	//	2、当帧地址指针相同时，读地址小于写地址时可以读出
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)
	begin
		se_2_fvalrise_shift <= {se_2_fvalrise_shift[0],i_se_2_fvalrise};
	end

	always @ (posedge clk)
	begin
		if( iv_wr_frame_ptr != ov_rd_frame_ptr )
		begin
			if( iv_wr_addr == 0)
			begin
				able_to_read <= 1'b0;
			end
			else
			begin
				able_to_read <= 1'b1;
			end
		end
		else if ( rd_addr < iv_wr_addr  )
		begin
			able_to_read <= 1'b1;
		end
		else
		begin
			able_to_read <= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	信号移位
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk )
	begin
		calib_done_shift	<= {calib_done_shift[0],i_calib_done};
	end

	//  -------------------------------------------------------------------------------------
	//	计算帧存写入数据量frame_size=leader size + payload size + trailer size
	//	且只能在停采期间更新
	//	chunk是否打开头长度不同
	//  -------------------------------------------------------------------------------------

	always @ (posedge clk)
	begin
		if( ~se_2_fvalrise_shift[1] )
		begin
			frame_size_leader_payload <= iv_payload_size + 'h34;	//payload + leader
		end
	end

	always @ (posedge clk)
	begin
		if( ~se_2_fvalrise_shift[1] )
		begin
			if ( i_chunkmodeactive )								//chunk使能
			begin
				trailer_length <= 'h24;
			end
			else													//chunk不使能
			begin
				trailer_length <= 'h20;
			end
		end
	end

	always @ (posedge clk)
	begin
		if( ~se_2_fvalrise_shift[1] )
		begin
			if ( frame_size_leader_payload[BSIZE_WD-1:0] == 0  )	//能被512整除，也就是一次burst的字节数
			frame_size <= frame_size_leader_payload + trailer_length;
			else
			frame_size <= {frame_size_leader_payload[FSIZE_WD-1:BSIZE_WD],{BSIZE_WD{1'b0}}} + {{2'b10},{BSIZE_WD{1'b0}}};	//有余数时，余数和trailer分别独占一次burst，所以+2倍的burst长度
		end
	end

	//需要读出的数据的值，如果frame_size_leader_payload值不是8的倍数则需要上取整
	always @ ( posedge clk  )
	begin
		if ( frame_size_leader_payload[WORD_FACTOR-1] )		//图像大小是4的倍数，如果不是8的倍数，则阈值需要+1，多读出一个8bytes
		begin
			read_data_word	<=	frame_size_leader_payload[FSIZE_WD-1:WORD_FACTOR]+1;
		end
		else
		begin
			read_data_word	<=	frame_size_leader_payload[FSIZE_WD-1:WORD_FACTOR];
		end
	end


	//需要读出的数据的值，如果frame_size_leader_payload值不是8的倍数则需要上取整
	always @ ( posedge clk  )
	begin
		if ( frame_size[WORD_FACTOR-1] )					//图像大小是4的倍数，如果不是8的倍数，则阈值需要+1，多读出一个8bytes
		begin
			fram_size_word	<=	frame_size[FSIZE_WD-1:WORD_FACTOR]+1;
		end
		else
		begin
			fram_size_word	<=	frame_size[FSIZE_WD-1:WORD_FACTOR];
		end
	end
	//
	always @ ( posedge clk  )
	begin
		if ( trailer_length[WORD_FACTOR-1] )				//图像大小是4的倍数，如果不是8的倍数，则阈值需要+1，多读出一个8bytes
		begin
			trailer_length_word	<=	trailer_length[6:WORD_FACTOR]+1;
		end
		else
		begin
			trailer_length_word	<=	trailer_length[6:WORD_FACTOR];
		end
	end

	//  ===============================================================================================
	//  第二部分：状态机设计
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
	//  -------------------------------------------------------------------------------------
	always @  *
	begin
		next_state = S_IDLE;
		case( current_state )
			S_IDLE	:
			begin											//DDR校验完成，可以读取，后端fifo可编程标志不满，开采
				if ( calib_done_shift[1] && able_to_read && ~fifo_prog_full && se_2_fvalrise_shift[1] )
				begin
					next_state = S_REQ_WAIT;
				end
				else
				begin
					next_state = S_IDLE;
				end
			end
			S_REQ_WAIT:										//流停采
			begin
				if (~se_2_fvalrise_shift[1] )
				begin
					next_state = S_IDLE;
				end
				else if(i_wr_frame_ptr_changing)
				begin
					next_state = S_REQ_WAIT;
				end
				else
				begin
					next_state = S_REQ;
				end
			end
			S_REQ	:
			begin											//非写读指针变化时读指针累加
				next_state = S_CMD_WAIT;
			end
			S_CMD_WAIT	:
			begin
				if (~se_2_fvalrise_shift[1] )				//流停采
				begin
					next_state = S_IDLE;
				end
				else if ( i_p_out_cmd_empty && ~fifo_prog_full && able_to_read)		//命令FIFO空且后端fifo未满且数据可读，跳转到读状态
				begin
					next_state = S_CMD;
				end
				else										//命令FIFO不空，继续等待，这样是为了保证命令和DDR实际读地址对应正确
				begin
					next_state = S_CMD_WAIT;
				end
			end
			S_CMD	:
			begin
				next_state = S_RD;
			end
			S_RD	:
			begin
				if (word_cnt == BURST_SIZE)							//1）读出数据量累计达burst
				begin
					next_state = S_CHK;
				end
				else if (~se_2_fvalrise_shift[1] && (word_cnt == BURST_SIZE) )
				begin
					next_state = S_IDLE;
				end
				else												//2）有数据读出，但不足burst数据量
				begin
					next_state = S_RD;
				end
			end
			S_CHK	:
			begin
				if ( frame_size_cnt >= fram_size_word )
				begin
					next_state = S_IDLE;
				end
				else
				begin
					next_state = S_CMD_WAIT;
				end
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
			o_p_out_cmd_en			<=	1'b0					;
			rd_addr					<=	{ADDR_WD{1'b0}}			;
			frame_size_cnt			<=	{(FSIZE_WD-4){1'b0}	}	;
			word_cnt				<=	7'h0					;
			ov_rd_frame_ptr			<= {BUF_DEPTH_WD{1'b0}}		;
			reading_trailer			<= 1'b0						;
		end
		else
		begin
			begin
				o_p_out_cmd_en		<=	1'b0					;
			end
			case( next_state )
				S_IDLE	:
				begin
					o_p_out_cmd_en	<=	1'b0					;
					frame_size_cnt	<=	{(FSIZE_WD-4){1'b0}	}	;
					word_cnt		<=	7'h0					;
					reading_trailer	<=  1'b0					;
					if(~se_2_fvalrise_shift[1])
					begin												//停止采集指针复位
						ov_rd_frame_ptr	<= {BUF_DEPTH_WD{1'b0}};
						rd_addr			<=	{ADDR_WD{1'b0}}	;
					end
				end
				S_REQ	:
				begin
					rd_addr					<=	{ADDR_WD{1'b0}}	;
					if ( ov_rd_frame_ptr != iv_wr_frame_ptr )
					begin
						if ( ov_rd_frame_ptr == iv_frame_depth-1 )
						begin
							ov_rd_frame_ptr	<=	{BUF_DEPTH_WD{1'b0}};
						end
						else
						begin
							ov_rd_frame_ptr <= ov_rd_frame_ptr + 1;
						end
					end
				end
				S_CMD_WAIT	:
				begin
					o_p_out_cmd_en			<=  1'b0			;
				end
				S_CMD	:
				begin
					word_cnt			<=	7'h0			;
					o_p_out_cmd_en			<=	1'b1			;
					if ( rd_addr ==	 {{(ADDR_WD-1){1'b1}},1'b0})
					begin
						reading_trailer <= 1'b1;
					end
				end
				S_RD	:
				begin
					o_p_out_cmd_en			<=	1'b0			;
					if ( o_p_out_rd_en )
					begin
						word_cnt		<=	word_cnt + 1;
						frame_size_cnt	<=	frame_size_cnt + 1;
					end
					if ( o_p_out_cmd_en )
					begin
						if ( rd_addr == frame_size_leader_payload[FSIZE_WD-1:BSIZE_WD] )	//当数据量累加到leader和payload结束时，将地址赋为次最大值，准备写尾包
						rd_addr		<=	{{(ADDR_WD-1){1'b1}},1'b0};
						else
						rd_addr		<=	rd_addr + 1;
					end
				end
				S_CHK	:
				begin
					word_cnt			<=	7'h0;
					reading_trailer 	<= 	1'b0;
				end
			endcase
		end
	end
	//  ===============================================================================================
	//  第三部分：P3口和后端FIFO间的控制逻辑
	//  ===============================================================================================

	assign	o_p_out_rd_en 			= (~i_p_out_rd_empty) && (~fifo_full) &&(word_cnt < BURST_SIZE);	//非空即读,累计不超过BURST_SIZE
	assign	w_wr_leader_payload_en  = (frame_size_cnt < read_data_word) && o_p_out_rd_en ;
	assign	w_wr_trailer_en			= (reading_trailer && word_cnt < trailer_length_word) && o_p_out_rd_en ;
	assign	w_wr_en					= (w_wr_leader_payload_en || w_wr_trailer_en ) && (!reset_fifo);
	assign	ov_p_out_cmd_instr		= 3'b001;															//不带预充电的读，因为控制器已配置预充电
	assign	ov_p_out_cmd_bl			= 6'h3f;															//burstlenth 64*4
	assign	ov_p_out_cmd_byte_addr  = {{2'b00},ov_rd_frame_ptr,rd_addr,{BSIZE_WD{1'b0}}};				//地址指针拼接：帧指针+读地址+BSIZE_WD'h00
	assign	w_buf_rd				= i_buf_rd &&(!reset_fifo);
	//  ===============================================================================================
	//  第四部分：FIFO例化
	//  ===============================================================================================
	//	系统复位和流停采
	assign  reset_fifo = reset || !se_2_fvalrise_shift[1];
	//	FIFO 64bit转为32bit，高32位先输出，所以交换高低32bit输入
	fifo_w64d256_pf180_pe6 fifo_w64d256_pf180_pe6_inst (
	.rst			(reset_fifo			),
	.wr_clk			(clk	            ),
	.rd_clk			(clk_vout           ),
	.din			({iv_p_out_rd_data[GPIF_DAT_WIDTH-1:0],iv_p_out_rd_data[DATA_WD-1:GPIF_DAT_WIDTH]}),
	.wr_en			(w_wr_en			),
	.rd_en			(w_buf_rd			),
	.dout			(ov_frame_dout		),
	.full			(fifo_full		    ),
	.empty			(o_back_buf_empty   ),
	.valid			(o_frame_valid		),
	.prog_full		(fifo_prog_full	    ),
	.prog_empty		(fifo_prog_empty	)
	);
endmodule
