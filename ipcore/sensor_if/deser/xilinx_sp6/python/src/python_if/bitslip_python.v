
//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : bitslip_python.v
//  -- 设计者       : 禹剑
//-------------------------------------------------------------------------------------------------
//
//  --修改记录  :
//
//  -- 作者         :| 修改日期     :|  修改说明
//---------------------------------------------------------------------------------------
//  -- 禹剑       	:| 02/25/2013   :|  初始版本
//
//---------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : 发送bitslip功能信号
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale      1ns/100ps
//-------------------------------------------------------------------------------------------------

module  bitslip_python # (
	parameter	SER_FIRST_BIT			= "MSB"				,	//"LSB" or "MSB" , first bit to the receiver
	parameter	CHANNEL_NUM				= 4					,	//差分通道个数
	parameter	DESER_WIDTH				= 5						//每个通道解串宽度 2-8
	)
	(
	input												clk				,	//恢复时钟
	input												reset			,	//高有效复位
	input		[DESER_WIDTH*(CHANNEL_NUM+1)-1:0]		iv_data			,	//解串后并行数据
	output												o_clk_en		,	//时钟使能信号
	input												i_bitslip_en	,	//bitslip信号使能
	output												o_bitslip_done	,	//对齐信号
	output												o_bitslip		,	//bitslip信号
	output		[2*DESER_WIDTH*CHANNEL_NUM-1:0]			ov_data			,	//输出数据
	output		[2*DESER_WIDTH-1:0]						ov_ctrl				//输出数据
	);

	//ref signals

	//  -------------------------------------------------------------------------------------
	//  参数
	//	--当sensor处于消隐期间的时候，数据通道、控制通道都是发送的同步字
	//	--每5拍判断一次是否对齐
	//  -------------------------------------------------------------------------------------
	localparam		SYNC_WORD			= (DESER_WIDTH==5) ? 10'h3a6 : 8'he9;
	localparam		BITSLIP_CNT_LENGTH	= 5	;

	//FSM Parameter Define
	parameter	S_IDLE		= 2'd0;
	parameter	S_CHK		= 2'd1;
	parameter	S_SLIP		= 2'd2;
	parameter	S_DONE		= 2'd3;

	reg		[1:0]	current_state	= S_IDLE;
	reg		[1:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	integer			state_ascii;
	always @ ( * ) begin
		case(current_state)
			2'd0 :	state_ascii	<= "S_IDLE";
			2'd1 :	state_ascii	<= "S_CHK";
			2'd2 :	state_ascii	<= "S_SLIP";
			2'd3 :	state_ascii	<= "S_DONE";
		endcase
	end
	// synthesis translate_on

	reg		[1:0]									bitslip_en_shift		;	//对位使能打两拍
	wire											bitslip_en_int	;
	wire	[DESER_WIDTH-1:0]						wv_data_lane[CHANNEL_NUM:0]	;	//重新组合的通道1的数据
	reg		[2*DESER_WIDTH-1:0]						data_lane_align[CHANNEL_NUM:0]	;	//重新组合的通道1的数据
	reg												div_cnt					= 1'b0	;	//分频计数器
	reg		[DESER_WIDTH*2-1:0]						data_lane0_shift		= 'b0	;	//lan0通道移位寄存器
	reg		[2:0]									dly_cnt	= 3'b0;
	reg												bitslip_done	= 1'b0;
	reg												bitslip_reg	= 1'b0;

	//ref ARCHITECTURE
	//	===============================================================================================
	//	ref ***异步时钟域处理***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	i_bitslip_en为clk_pix时钟域，转换到i_clk_parallel时钟域
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		bitslip_en_shift	<=	{bitslip_en_shift[0],i_bitslip_en};
	end

	//	-------------------------------------------------------------------------------------
	//	当已经对齐之后，禁止再次对位
	//	-------------------------------------------------------------------------------------
	assign	bitslip_en_int	= bitslip_done ? 1'b0 : bitslip_en_shift[1];

	//	===============================================================================================
	//	ref ***检测同步字***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	划分通道
	//	--每个通道的位宽是 DESER_WIDTH 个bit
	//	--大端，最高的通道在低byte。小端，最低的通道在低byte。
	//	-------------------------------------------------------------------------------------
	genvar	i;
	generate
		for(i=0;i<CHANNEL_NUM+1;i=i+1) begin
			assign	wv_data_lane[i]	= iv_data[DESER_WIDTH*(i+1)-1:DESER_WIDTH*i];
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	对lan0移位，每次移动 DESER_WIDTH 个bit
	//	--目前的检测方法是只对lane0检测同步字。其他通道不检测
	//	--lan0的 DESER_WIDTH bit数据每次移位。注意，此处无论是LSB MSB ，都是将数据从最低端移到最高端
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(SER_FIRST_BIT=="LSB") begin
			data_lane0_shift	<= {wv_data_lane[0],data_lane0_shift[DESER_WIDTH*2-1:DESER_WIDTH]};
		end
		else if(SER_FIRST_BIT=="MSB") begin
			data_lane0_shift	<= {data_lane0_shift[DESER_WIDTH*2-1:0],wv_data_lane[0]};
		end
	end

	//	-------------------------------------------------------------------------------------
	//	以LSB为例，说明data lock与拼接逻辑
	//	-------------------------------------------------------------------------------------
	//	-------------------------------------------------------------------------------------
	//			  	  ____   ____   ____   ____   ____   ____   ____   ____   ____   ____   ____   ____   ____   ____
	//	clk_2x		__|  |___|  |___|  |___|  |___|  |___|  |___|  |___|  |___|  |___|  |___|  |___|  |___|  |___|  |___
	//
	//	byte in		--<H0    ><L0   ><H1   ><L1   ><H2   ><L2   ><H3   ><L3   ><H4   ><L4   ><H5   ><L5   ><H6   ><L6   >
	//
	//									                 ______________________________________________________________________
	//	data lock	_____________________________________|
	//
	//	byte shift	-----------------<H0L0 ><L0H1 ><H1L2 ><H2L1 >
	//
	//	data align	--------------------------------------<L1H2 ><H2L2 ><L2H3 ><H3L3 ><L3H4 ><H4L4 ><L4H5 ><H5L5 ><L5H6 >
	//						    								________      ________      ________      ________
	//	clk en		____________________________________________|      |______|      |______|      |______|      |______
	//
	//
	//	-------------------------------------------------------------------------------------

	//	===============================================================================================
	//	ref ***拼接数据***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	每个通道各延时1拍
	//	--2个 DESER_WIDTH bit，拼成一个word
	//	--LSB模式，先接收到的 DESER_WIDTH bit是低位。MSB模式，先接收到的 DESER_WIDTH bit是高位
	//	-------------------------------------------------------------------------------------
	genvar	j;
	generate
		for(j=0;j<CHANNEL_NUM+1;j=j+1) begin
			if(SER_FIRST_BIT=="LSB") begin
				always @ (posedge clk) begin
					data_lane_align[j]	= {wv_data_lane[j],data_lane_align[j][2*DESER_WIDTH-1:DESER_WIDTH]};
				end
			end
			else if(SER_FIRST_BIT=="MSB") begin
				always @ (posedge clk) begin
					data_lane_align[j]	= {data_lane_align[j][DESER_WIDTH-1:0],wv_data_lane[j]};
				end
			end
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	div_cnt 分频计数器
	//	--只在 data_lock == 1的时候才开始计数
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!bitslip_done) begin
			div_cnt	<= 'b0;
		end
		else begin
			div_cnt	<= !div_cnt;
		end
	end
	assign	o_clk_en	= div_cnt;

	//	===============================================================================================
	//	ref ***bitslip 输出逻辑***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	dly_cnt延时信号
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			dly_cnt	<= 'b0;
		end
		else begin
			if(current_state==S_SLIP || current_state==S_DONE) begin
				dly_cnt	<= dly_cnt + 1'b1;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	在一行之中没有检测到同步字，则移位
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_SLIP && dly_cnt==3'd0) begin
			bitslip_reg	<= 1'b1;
		end
		else begin
			bitslip_reg	<= 1'b0;
		end
	end
	assign	o_bitslip	= bitslip_reg	;

	//	-------------------------------------------------------------------------------------
	//	输出对齐信号
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			bitslip_done	<= 1'b0;
		end
		else begin
			if(current_state==S_SLIP) begin
				bitslip_done	<= 1'b0;
			end
			else if(current_state==S_DONE && dly_cnt==3'd7) begin
				bitslip_done	<= 1'b1;
			end
		end
	end
	assign	o_bitslip_done	= bitslip_done;

	//	-------------------------------------------------------------------------------------
	//	输出对齐后的数据，区分大小端
	//	-------------------------------------------------------------------------------------
	genvar	l;
	generate
		for(l=0;l<CHANNEL_NUM;l=l+1) begin
			assign	ov_data[(l+1)*(2*DESER_WIDTH)-1:l*(2*DESER_WIDTH)]	= data_lane_align[l+1];
		end
	endgenerate
	assign	ov_ctrl[(2*DESER_WIDTH)-1:0]	= data_lane_align[0];

	//	===============================================================================================
	//	ref FSM
	//	===============================================================================================
	//FSM Sequential Logic
	always @ (posedge clk) begin
		if(reset) begin
			current_state	<= S_IDLE;
		end
		else begin
			current_state	<= next_state;
		end
	end

	//FSM Conbinatial Logic
	always @ ( * ) begin
		case(current_state)
			S_IDLE	:
			if(bitslip_en_int) begin
				next_state	= S_CHK;
			end
			else begin
				next_state	= S_IDLE;
			end
			S_CHK	:
			if(data_lane0_shift==SYNC_WORD) begin
				next_state	= S_DONE;
			end
			else begin
				next_state	= S_SLIP;
			end
			S_SLIP	:
			if(dly_cnt==6) begin
				next_state	= S_IDLE;
			end
			else begin
				next_state	= S_SLIP;
			end
			S_DONE	:
			if(dly_cnt==7) begin
				next_state	= S_IDLE;
			end
			else begin
				next_state	= S_DONE;
			end
			default	:
			next_state	= S_IDLE;
		endcase
	end


endmodule