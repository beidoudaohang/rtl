//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : rd_back_buf
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/4/2 10:04:30	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module rd_back_buf # (
	parameter	MROI_MAX_NUM 			= 8			,	//Multi-ROI的最大个数
	parameter	REG_WD  				= 32		,	//寄存器位宽
	parameter	DATA_WIDTH				= 8				//数据位宽
	)
	(
	input										clk						,
	input										i_stream_enable			,
	input	[MROI_MAX_NUM*REG_WD-1:0]			iv_image_size_mroi		,	//Multi-ROI image size 集合
	input										i_empty					,
	input	[DATA_WIDTH:0]						iv_pix_data				,
	output										o_rd					,
	output										o_fval					,
	output										o_lval					,
	output										o_lval_leader			,
	output										o_lval_trailer			,
	output	[DATA_WIDTH-1:0]					ov_pix_data
	);

	//	ref signals
	//FSM Parameter Define
	parameter	S_IDLE			= 3'd0;
	parameter	S_WAIT			= 3'd1;
	parameter	S_LEADER		= 3'd2;
	parameter	S_IMAGE			= 3'd3;
	parameter	S_CHUNK			= 3'd4;
	parameter	S_TRAILER		= 3'd5;
	parameter	S_DELAY			= 3'd6;

	reg		[2:0]	current_state	= S_IDLE;
	reg		[2:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	reg		[127:0]			state_ascii;
	always @ ( * ) begin
		case(current_state)
			3'd0 :	state_ascii	<= "S_IDLE";
			3'd1 :	state_ascii	<= "S_WAIT";
			3'd2 :	state_ascii	<= "S_LEADER";
			3'd3 :	state_ascii	<= "S_IMAGE";
			3'd4 :	state_ascii	<= "S_CHUNK";
			3'd5 :	state_ascii	<= "S_TRAILER";
			3'd6 :	state_ascii	<= "S_DELAY";
		endcase
	end
	// synthesis translate_on

	wire	[REG_WD-1:0]				image_size_ch[MROI_MAX_NUM-1:0]		;	//重新划分通道
	wire	[7:0]						leader_size			;
	wire	[7:0]						trailer_size		;
	wire	[7:0]						chunk_size			;
	wire	[31:0]						image_size			;
	wire								fifo_rd_en			;
	reg		[7:0]						leader_num_cnt		= 'b0;
	reg		[7:0]						trailer_num_cnt		= 'b0;
	reg		[7:0]						chunk_num_cnt		= 'b0;
	reg		[31:0]						image_num_cnt		= 'b0;
	wire								leader_done			;
	wire								trailer_done		;
	wire								chunk_done			;
	wire								image_done			;
	reg		[3:0]						roi_num				='b0;
	reg		[7:0]						delay_cnt			= 8'b0;

	//	ref ARCHITECTURE
	//	===============================================================================================
	//	ref ***div roi***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	划分image_size
	//	-------------------------------------------------------------------------------------
	genvar	k;
	generate
		for(k=0;k<MROI_MAX_NUM;k=k+1) begin
			assign	image_size_ch[k]	= iv_image_size_mroi[REG_WD*(k+1)-1:REG_WD*k];
		end
	endgenerate

	//	===============================================================================================
	//	ref ***size***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	leader 52byte
	//	-------------------------------------------------------------------------------------
	assign	leader_size		= 13;
	//	-------------------------------------------------------------------------------------
	//	trailer
	//	1.chunk en 36byte
	//	2.chunk off 32byte
	//	-------------------------------------------------------------------------------------
	assign	trailer_size	= (harness.frame_buffer_inst.wrap_rd_logic_inst.chunk_mode_active==1'b1) ? 9 : 8;
	//	-------------------------------------------------------------------------------------
	//	chunk
	//	the same with frame buffer
	//	-------------------------------------------------------------------------------------
	assign	chunk_size		= harness.frame_buffer_inst.wrap_rd_logic_inst.chunk_size>>2;
	//	-------------------------------------------------------------------------------------
	//	image
	//	分通道
	//	-------------------------------------------------------------------------------------
	assign	image_size		= image_size_ch[roi_num]>>2;

	//	===============================================================================================
	//	ref ***rd back fifo***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	fifo_rd_en
	//	-------------------------------------------------------------------------------------
	assign	fifo_rd_en	= (current_state!=S_IDLE && current_state!=S_WAIT && current_state!=S_DELAY && i_empty==1'b0) ? 1'b1 : 1'b0;
	assign	o_rd	= fifo_rd_en;

	//	===============================================================================================
	//	ref ***flag done***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	leader done
	//	表示 leader 结束
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			leader_num_cnt	<= 0;
		end
		if(current_state==S_LEADER && fifo_rd_en==1'b1 && iv_pix_data[DATA_WIDTH]==1'b0) begin
			leader_num_cnt	<= leader_num_cnt + 1'b1;
		end
	end
	assign	leader_done	= (current_state==S_LEADER && leader_num_cnt==leader_size-1 && fifo_rd_en) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	chunk done
	//	表示 chunk 结束
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			chunk_num_cnt	<= 0;
		end
		if(current_state==S_CHUNK && fifo_rd_en==1'b1 && iv_pix_data[DATA_WIDTH]==1'b0) begin
			chunk_num_cnt	<= chunk_num_cnt + 1'b1;
		end
	end
	assign	chunk_done	= (current_state==S_CHUNK && chunk_num_cnt==chunk_size-1 && fifo_rd_en) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	image done
	//	表示 image 结束
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			image_num_cnt	<= 0;
		end
		if(current_state==S_IMAGE && fifo_rd_en==1'b1 && iv_pix_data[DATA_WIDTH]==1'b0) begin
			image_num_cnt	<= image_num_cnt + 1'b1;
		end
	end
	assign	image_done	= (current_state==S_IMAGE && image_num_cnt==image_size-1 && fifo_rd_en) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	trailer done
	//	表示 trailer 结束
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			trailer_num_cnt	<= 0;
		end
		if(current_state==S_TRAILER && fifo_rd_en==1'b1 && iv_pix_data[DATA_WIDTH]==1'b0) begin
			trailer_num_cnt	<= trailer_num_cnt + 1'b1;
		end
	end
	assign	trailer_done	= (current_state==S_TRAILER && trailer_num_cnt==trailer_size-1 && fifo_rd_en) ? 1'b1 : 1'b0;

	//	===============================================================================================
	//	ref ***leader info***
	//	===============================================================================================
	always @ (posedge clk) begin
		if(current_state==S_IMAGE && image_num_cnt==0 && fifo_rd_en==1'b1 && iv_pix_data[DATA_WIDTH]==1'b1) begin
			roi_num	<= iv_pix_data[3:0];
		end
	end


	always @ (posedge clk) begin
		if(current_state==S_IDLE || current_state==S_LEADER) begin
			delay_cnt	<= 0;
		end
		else if(current_state==S_DELAY || current_state==S_WAIT) begin
			delay_cnt	<= delay_cnt + 1'b1;
		end
	end

	//	===============================================================================================
	//	ref ***output***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	图像数据
	//	-------------------------------------------------------------------------------------
	reg			fval_reg	= 1'b0;
	always @ (posedge clk) begin
		if(current_state==S_WAIT && delay_cnt==8'h7f) begin
			fval_reg	<= 1'b1;
		end
		else if(current_state==S_DELAY && delay_cnt==8'h7f) begin
			fval_reg	<= 1'b0;
		end
	end
	assign	o_fval	= fval_reg;

	reg			lval_reg	= 1'b0;
	always @ (posedge clk) begin
		if(current_state==S_IMAGE && fifo_rd_en==1'b1 && iv_pix_data[DATA_WIDTH]==1'b0) begin
			lval_reg	<= 1'b1;
		end
		else begin
			lval_reg	<= 1'b0;
		end
	end
	assign	o_lval	= lval_reg;

	reg		[DATA_WIDTH-1:0]		pix_data_reg	= 'b0;
	always @ (posedge clk) begin
			pix_data_reg	<= iv_pix_data;
	end
	assign	ov_pix_data	= pix_data_reg;

	//	-------------------------------------------------------------------------------------
	//	leader
	//	-------------------------------------------------------------------------------------
	reg			lval_leader_reg	= 1'b0;
	always @ (posedge clk) begin
		if(current_state==S_LEADER && fifo_rd_en==1'b1 && iv_pix_data[DATA_WIDTH]==1'b0) begin
			lval_leader_reg	<= 1'b1;
		end
		else begin
			lval_leader_reg	<= 1'b0;
		end
	end
	assign	o_lval_leader	= lval_leader_reg;

	//	-------------------------------------------------------------------------------------
	//	leader
	//	-------------------------------------------------------------------------------------
	reg			lval_trailer_reg	= 1'b0;
	always @ (posedge clk) begin
		if(current_state==S_TRAILER && fifo_rd_en==1'b1 && iv_pix_data[DATA_WIDTH]==1'b0) begin
			lval_trailer_reg	<= 1'b1;
		end
		else begin
			lval_trailer_reg	<= 1'b0;
		end
	end
	assign	o_lval_trailer	= lval_trailer_reg;


	//	===============================================================================================
	//	ref ***FSM***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	FSM Sequential Logic
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		current_state	<= next_state;
	end

	//	-------------------------------------------------------------------------------------
	//	FSM Conbinatial Logic
	//	-------------------------------------------------------------------------------------
	always @ ( * ) begin
		if(!i_stream_enable) begin
			next_state	= S_IDLE;
		end
		else begin
			case(current_state)
				S_IDLE	:
				if(i_empty==1'b0) begin
					next_state	= S_WAIT;
				end
				else begin
					next_state	= S_IDLE;
				end
				S_WAIT	:
				if(delay_cnt==8'hff) begin
					next_state	= S_LEADER;
				end
				else begin
					next_state	= S_WAIT;
				end
				S_LEADER	:
				if(leader_done==1'b1) begin
					next_state	= S_IMAGE;
				end
				else begin
					next_state	= S_LEADER;
				end
				S_IMAGE	:
				if(image_done==1'b1) begin
					if(chunk_size==0) begin
						next_state	= S_TRAILER;
					end
					else begin
						next_state	= S_CHUNK;
					end
				end
				else begin
					next_state	= S_IMAGE;
				end
				S_CHUNK	:
				if(chunk_done==1'b1) begin
					next_state	= S_TRAILER;
				end
				else begin
					next_state	= S_CHUNK;
				end
				S_TRAILER	:
				if(trailer_done==1'b1) begin
					next_state	= S_DELAY;
				end
				else begin
					next_state	= S_TRAILER;
				end
				S_DELAY	:
				if(delay_cnt==8'hff) begin
					next_state	= S_IDLE;
				end
				else begin
					next_state	= S_DELAY;
				end
				default	:
				next_state	= S_IDLE;
			endcase
		end
	end



endmodule
