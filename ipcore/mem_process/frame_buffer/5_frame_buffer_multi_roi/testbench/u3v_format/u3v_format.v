//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : u3v_format
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/10/21 15:25:14	:|  初始版本
//  -- 邢海涛       :| 2016/4/25 17:40:31	:|  1.添加 FVAL_TS_STABLE_NS 参数
//												2.解决时钟超过60MHz时，chunk中的时间戳采不稳的问题
//	-- 张少强		:| 2016/9/20 15:25:14	:|  1.重新整理布局代码格式
//												2.添加多roi解决方案
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : 兼容例化方案，以1810为例
//			u3v_format # (
//			.PIX_CLK_FREQ_KHZ			(PIX_CLK_FREQ_KHZ			),
//			.FVAL_TS_STABLE_NS			(FVAL_TS_STABLE_NS			),
//			.DATA_WD					(DATA_WD					),
//			.SHORT_REG_WD				(SHORT_REG_WD				),
//			.REG_WD						(REG_WD						),
//			.LONG_REG_WD				(LONG_REG_WD				),
//			.MROI_MAX_NUM				(16							)
//			)
//			u3v_format_inst (
//			.clk						(clk						),
//			.reset						(reset						),
//			.i_fval						(i_fval						),
//			.i_data_valid				(i_data_valid				),
//			.iv_data					(iv_data					),
//			.i_stream_enable			(i_stream_enable			),
//			.i_acquisition_start		(i_acquisition_start		),
//			.iv_pixel_format			(iv_pixel_format			),
//			.i_chunk_mode_active		(i_chunk_mode_active		),
//			.i_chunkid_en_ts			(i_chunkid_en_ts			),
//			.i_chunkid_en_fid			(i_chunkid_en_fid			),
//			.iv_timestamp				(iv_timestamp				),
//			.iv_chunk_size_img			(iv_chunk_size_img			),
//			.i_multi_roi_global_en				(i_multi_roi_global_en				),
//			.iv_multi_roi_single_en			(iv_multi_roi_single_en			),
//			.iv_chunk_size_img_mroi		(iv_chunk_size_img_mroi		),
//			.iv_offset_x_mroi			(iv_offset_x_mroi			),
//			.iv_offset_y_mroi			(iv_offset_y_mroi			),
//			.iv_size_x_mroi				(iv_size_x_mroi				),
//			.iv_size_y_mroi				(iv_size_y_mroi				),
//			.iv_trailer_size_y_mroi		(iv_trailer_size_y_mroi		),
//			.o_fval						(o_fval						),
//			.o_data_valid				(o_data_valid				),
//			.o_leader_flag				(o_leader_flag				),
//			.o_image_flag				(o_image_flag				),
//			.o_chunk_flag				(o_chunk_flag				),
//			.o_trailer_flag				(o_trailer_flag				),
//			.ov_data					(ov_data					)
//			);
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module u3v_format # (
	parameter	PIX_CLK_FREQ_KHZ	= 72000	,	//像素时钟的频率，以khz为单位
	parameter	FVAL_TS_STABLE_NS	= 95	,	//从fval发出到稳定接收时间戳的时间
	parameter	DATA_WD				= 64	,	//输入输出数据位宽，这里使用同一宽度
	parameter	SHORT_REG_WD 		= 16	,	//短寄存器位宽
	parameter	REG_WD 				= 32	,	//寄存器位宽
	parameter	LONG_REG_WD 		= 64	,	//长寄存器位宽
	parameter	MROI_MAX_NUM 		= 8			//Multi-ROI的最大个数,最大支持2^8
	)
	(
	//  ===============================================================================================
	//  第一部分：时钟复位
	//  ===============================================================================================
	input											clk						,	//时钟信号，像素时钟时钟域，同内部像素时钟
	input											reset					,	//复位信号，暂不使用,高电平有效，像素时钟时钟域
	//  ===============================================================================================
	//  第二部分：行、场、数据、数据有效
	//  ===============================================================================================
	input											i_fval					,	//数据通路输出的场信号，像素时钟时钟域,fval的信号是经过数据通道加宽过的场信号，场头可以添加leader、并包含有效的图像数据，停采期间保持低电平
	input											i_data_valid			,	//数据通路输出的数据有效信号，标志32位数据为有效数据
	input	[DATA_WD-1:0]							iv_data					,	//数据通路拼接好的32bit数据，与数据有效对齐，与像素时钟对齐
	//  ===============================================================================================
	//  第三部分：控制寄存器、chunk信息
	//  ===============================================================================================
	input											i_stream_enable			,	//流使能信号，像素时钟时钟域，=0，后端流立即停止，chunk中的BLOCK ID为0
	input											i_acquisition_start     ,	//开采信号，暂不使用，像素时钟时钟域，=0，标志完整帧，需等添加完尾包后才能停止
	input	[REG_WD-1:0]							iv_pixel_format         ,	//像素格式，用于添加在leader中,数据通路已做生效时机控制，本模块不需再进行生效时机控制
	input											i_chunk_mode_active     ,	//chunk总开关，开关打开Payload Type使用为image extend chunk 类型，chunk关闭为image类型
	input											i_chunkid_en_ts         ,	//时间戳chunk使能
	input											i_chunkid_en_fid        ,	//frame id chunk使能
	input	[LONG_REG_WD-1:0]						iv_timestamp			,	//头包中的时间戳字段,由控制通道传送过来
	//  ===============================================================================================
	//  第四部分：总体信息2
	//  ===============================================================================================
	input	[REG_WD-1:0]							iv_chunk_size_img		,	//图像长度，以字节为单位，当pixel format为8bit时，一个像素占一个字节，当pixel format 10 bit时，一个像素占用两个字节。
	//  ===============================================================================================
	//  第五部分：多roi信息
	//  ===============================================================================================
	input											i_multi_roi_global_en			,	//roi总开关
	input	[MROI_MAX_NUM-1:0]						iv_multi_roi_single_en		,	//每个roi的使能信号，例如bit0对应roi0的使能
	input	[REG_WD*MROI_MAX_NUM-1:0]				iv_chunk_size_img_mroi	,	//图像长度，以字节为单位，当pixel format为8bit时，一个像素占一个字节，当pixel format 10 bit时，一个像素占用两个字节。
	input	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_offset_x_mroi		,	//头包中的水平偏移
	input	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_offset_y_mroi		,	//头包中的垂直便宜
	input	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_size_x_mroi			,	//头包中的窗口宽度
	input	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_size_y_mroi			,	//头包中的窗口高度
	input	[SHORT_REG_WD*MROI_MAX_NUM-1:0]			iv_trailer_size_y_mroi	,	//尾包中的有效高度字段
	//  ===============================================================================================
	//  第六部分：行、数据有效、数据
	//  ===============================================================================================
	output											o_fval					,	//添加完头尾的场信号，且需要场信号的上升沿领先第一个有效10个clk，下降沿要滞后于最后一个有效数据10个时钟以上，以保证帧存正常工作。
	output											o_data_valid			,	//添加完头尾的数据有效信号
	output											o_leader_flag			,	//头包标志
	output											o_image_flag			,	//图像标志
	output											o_chunk_flag			,	//chunk标志
	output											o_trailer_flag			,	//尾包标志，在imag_flag前
	output											o_trailer_final_flag	,	//最后一个roi的尾包标志,在image_flag后
	output	[DATA_WD-1:0]							ov_data						//输出数据
	);

//	===============================================================================================
//	functions
//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	取对数，上取整
	//	-------------------------------------------------------------------------------------
	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction
	//	-------------------------------------------------------------------------------------
	//	取最大值
	//	-------------------------------------------------------------------------------------
	function integer max(input integer n1, input integer n2);
		max = (n1 > n2) ? n1 : n2;
	endfunction
//	===============================================================================================
//	宏定义
//	===============================================================================================
	//像素时钟周期，以 ns 为单位
	localparam						CLK_PERIOD_NS		= 1000000/PIX_CLK_FREQ_KHZ;
	localparam						PAYLOAD_SHIFT_NUM	= log2(DATA_WD/8);//有效payload数相对于像素时钟数的移位
	//	-------------------------------------------------------------------------------------
	//	状态机各状态停留时间
	//	-------------------------------------------------------------------------------------
	localparam						TIMESTAMP_DELAY		= (FVAL_TS_STABLE_NS/CLK_PERIOD_NS)+1; //在fval上升沿或者下降沿后，时间戳需要稳定下来的时间
	localparam						LEADER_SIZE			= 7;//单roi在S_LEADER状态的clk数
	localparam						CHUNK_SIZE			= 5;//单roi在S_CHUNK状态的clk数
	localparam						TRAILER_SIZE		= 5;
	localparam						EXT_SIZE			= 10;	//fval lval 下降沿延时
	//	-------------------------------------------------------------------------------------
	//	一些包中需要传递的数据信息
	//	-------------------------------------------------------------------------------------
	localparam						FID_LENTH			= 32'h8	;	//frameid 长度
	localparam						TS_LENTH			= 32'h8	;	//timestamp 长度
	//	-------------------------------------------------------------------------------------
	//	一些计数器的位宽
	//	-------------------------------------------------------------------------------------
	localparam						MROI_NUM_WD = log2(MROI_MAX_NUM)+1;//roi个数计数器位宽
	localparam						PER_ROI_CNT_WD	= log2( max(max(max(max(TIMESTAMP_DELAY,LEADER_SIZE),CHUNK_SIZE),TRAILER_SIZE),EXT_SIZE) )+1;
	//	-------------------------------------------------------------------------------------
	//	FSM Parameter Define
	//	-------------------------------------------------------------------------------------
	parameter						S_IDLE			= 8'b0000_0000;	//IDLE状态
	parameter						S_TIMESTAMP		= 8'b0000_0001;	//S_TIMESTAMP1状态用于在i_fval上升沿后等待时间戳稳定
	parameter						S_LEADER		= 8'b0000_0010;	//S_LEADER状态用于传输头包
	parameter						S_CHUNK			= 8'b0000_0100;	//S_CHUNK状态用于传输chunk信息；当chunk不使能时，输出数据中不包括chunk数据，但S_CHUNK状态仍然存在，输出空数据
	parameter						S_TRAILER		= 8'b0000_1000;	//S_TRAILER状态用于传输尾包信息
	parameter						S_IMAGE			= 8'b0001_0000;	//S_IMAGE状态用于传输像素数据
	parameter						S_F_TRAILER		= 8'b0010_0000;	//S_F_TRAILER状态用于在帧尾传输最后一个有效roi地trailer包
	parameter						S_EXT			= 8'b0100_0000;	//S_EXT状态用于延时fval下降沿
//	===============================================================================================
//	wirs and regs
//	===============================================================================================
	reg									chunk_mode_active_dly	;	//i_chunk_mode_active信号打拍
	reg									chunkid_en_ts_dly		;	//i_chunkid_en_ts信号打拍
	reg									chunkid_en_fid_dly		;	//i_chunkid_en_fid信号打拍
	reg									fval_dly				;	//i_fval信号打拍
	wire								fval_rise				;	//fval上升沿
	wire								fval_fall				;	//fval下降沿
//	reg									enable					;	//i_stream_enable & i_acquisition_start
	reg		[MROI_MAX_NUM-1:0]			multi_roi_single_en_reg = 'b0;	//经过生效时机后的iv_per_roi_enable
	reg		[MROI_MAX_NUM-1:0]			multi_roi_single_en_shift= 'b0;	//移位寄存器，用于判断当前是否为最后一个有效roi
	reg		[MROI_NUM_WD-1:0]			last_roi_num		=	{MROI_NUM_WD{1'b1}};	//记录最后一个有效roi标号
	wire								is_last_roi				;	//当前roi是最末有效roi为1，否则为0
	reg									stream_enable_reg		;	//将i_stream_enable低电平延长直到i_fval上升沿
	reg		[7:0]						current_state	= S_IDLE;	//当前状态
	reg		[7:0]						next_state		= S_IDLE;	//下一状态
	reg		[PER_ROI_CNT_WD-1:0]		per_roi_cnt		= 'b0	;	//多roi模式下，每个状态对于某个roi的计数；单roi模式下，每个状态的计数
	reg		[MROI_NUM_WD-1:0]			roi_num_cnt		= 'b0	;	//状态机的每个状态，计数roi
	//	-------------------------------------------------------------------------------------
	//	输出信号寄存器
	//	-------------------------------------------------------------------------------------
	reg									data_valid_reg			;	//o_data_valid=data_valid_reg
	reg		[DATA_WD-1:0]				data_reg				;	//ov_data=data_reg
	reg									fval_reg				;	//o_fval = fval_reg
	reg									leader_flag_reg			;	//o_leader_flag = leader_flag_reg
	reg									image_flag_reg			;	//o_image_flag = image_flag_reg
	reg									chunk_flag_reg			;	//o_chunk_flag = chunk_flag_reg
	reg									trailer_flag_reg		;	//o_trailer_flag = trailer_flag_reg
	reg									trailer_final_flag_reg	;	//o_trailer_final_flag = trailer_final_flag_reg

	//	-------------------------------------------------------------------------------------
	//	adder
	//	-------------------------------------------------------------------------------------
	reg		[46:0]		adder_a		= 47'b0;
	reg					adder_b		= 1'b0;
	reg					adder_ce	= 1'b0;
	wire	[46:0]		adder_sum	;
	reg					adder_clr	;
	//	-------------------------------------------------------------------------------------
	//	blockid
	//	-------------------------------------------------------------------------------------
	reg		[46:0]						blockid_low47_acc	= 'b0	;	//每帧过后累加器增加n，n为roi数
	reg		[46:0]						blockid_low47_roi	= 'b0	;	//多roi blockid的低47位
	reg 	[REG_WD-1:0]				chunk_size_img_reg		;	//根据单roi或者多roi的情况得到iv_chunk_size_img或者iv_chunk_size_img_mroi[REG_WD-1:0]

	//	-------------------------------------------------------------------------------------
	//	status/valid_payload
	//	-------------------------------------------------------------------------------------
	reg 	[REG_WD-1:0]							act_payload_cnt			;
	reg		[REG_WD-1:0]							valid_payload_size		;
	reg		[15 :     0]							status			= 'b0	;
	//	-------------------------------------------------------------------------------------
	//	chunk_layout_id
	//	-------------------------------------------------------------------------------------
	reg		[7:0]						chunk_layout_id			= 8'h0;
	//	-------------------------------------------------------------------------------------
	//	从端口中分解出各roi信息
	//	-------------------------------------------------------------------------------------
	wire	[REG_WD-1 : 0]				per_chunk_size_img_mroi	[MROI_MAX_NUM-1:0]	;
	wire	[SHORT_REG_WD-1:0]			per_offset_x_mroi		[MROI_MAX_NUM-1:0]	;
	wire	[SHORT_REG_WD-1:0]			per_offset_y_mroi		[MROI_MAX_NUM-1:0]	;
	wire	[SHORT_REG_WD-1:0]			per_size_x_mroi			[MROI_MAX_NUM-1:0]	;
	wire	[SHORT_REG_WD-1:0]			per_size_y_mroi			[MROI_MAX_NUM-1:0]	;
	wire	[SHORT_REG_WD-1:0]			per_trailer_size_y_mroi	[MROI_MAX_NUM-1:0]	;
	wire	[REG_WD-1 : 0]				valid_payload_size_mroi	[MROI_MAX_NUM-1:0]	;
//	===============================================================================================
//	输入的roi信息是整合在一起的，下面的逻辑可以将其分开
//	===============================================================================================
	genvar	i;
	generate
		for(i=0;i<MROI_MAX_NUM;i=i+1) begin
			assign per_chunk_size_img_mroi[i] = iv_chunk_size_img_mroi[(i+1)*REG_WD-1:i*REG_WD];
			assign per_offset_x_mroi[i]		=	iv_offset_x_mroi[(i+1)*SHORT_REG_WD-1:i*SHORT_REG_WD];
			assign per_offset_y_mroi[i]		=	iv_offset_y_mroi[(i+1)*SHORT_REG_WD-1:i*SHORT_REG_WD];
			assign per_size_x_mroi[i]		=	iv_size_x_mroi[(i+1)*SHORT_REG_WD-1:i*SHORT_REG_WD];
			assign per_size_y_mroi[i]		=	iv_size_y_mroi[(i+1)*SHORT_REG_WD-1:i*SHORT_REG_WD];
			assign per_trailer_size_y_mroi[i]	=	iv_trailer_size_y_mroi[(i+1)*REG_WD-1:i*REG_WD];
			assign valid_payload_size_mroi[i]	= iv_chunk_size_img_mroi[(i+1)*REG_WD-1:i*REG_WD];
		end
	endgenerate
//	===============================================================================================
//	打拍及边沿提取
//	===============================================================================================
	always @ (posedge clk) begin
		fval_dly <= i_fval;
	end
	assign fval_rise = {fval_dly,i_fval} == 2'b01 ? 1'b1 : 1'b0;
	assign fval_fall = {fval_dly,i_fval} == 2'b10 ? 1'b1 : 1'b0;

	//	对chunk使能信号打拍
	always @ (posedge clk) begin
		chunk_mode_active_dly	<= i_chunk_mode_active	;
		chunkid_en_ts_dly		<= i_chunkid_en_ts		;
		chunkid_en_fid_dly		<= i_chunkid_en_fid		;
	end
//	===============================================================================================
//	生效时机以及数据选择
//	===============================================================================================

	//roi 位使能在i_fval上升沿生效
	always @ (posedge clk) begin
		if(fval_rise) begin
			multi_roi_single_en_reg <= iv_multi_roi_single_en;
		end
		else begin
			multi_roi_single_en_reg <= multi_roi_single_en_reg;
		end
	end


	//将i_stream_enable低电平延长直到i_fval上升沿
	always @ (posedge clk) begin
		if(!i_stream_enable) begin
			stream_enable_reg <= 1'b0;
		end
		else if(fval_rise) begin
			stream_enable_reg <= 1'b1;
		end
	end

	always @ (posedge clk) begin
		if(i_multi_roi_global_en) begin //多roi打开情况下，得到总chunk值
			chunk_size_img_reg <= iv_chunk_size_img;
		end
		else begin //单roi情况下，将roi0的chunk给总的
			chunk_size_img_reg <= per_chunk_size_img_mroi[0];
		end
	end
	//	-------------------------------------------------------------------------------------
	//	instantiate adder
	//	有效像素数和blockid的统计都在加法器内完成，加法器采用分时复用的方法
	//	-------------------------------------------------------------------------------------
	u3v_adder_47 u3v_adder_47_inst (
	.clk	(clk				),
	.ce		(adder_ce			),
	.sclr	(adder_clr			),
	.a		(adder_a			),
	.b		(adder_b			),
	.s		(adder_sum			)
	);

	// adder_clr
	always @ (posedge clk) begin
		if(!stream_enable_reg) begin //停留时复位加法器，本模块加了时机控制，停留时间一定会持续到S_IDLE状态，加法器被复位后，blockid_acc也会同步清0
			adder_clr <= 1'b1;
		end
		else if(fval_rise)begin //每帧的上升沿复位加法器，清除掉上一帧锁存的adder_sum信息
			adder_clr <= 1'b1;
		end
		else if((current_state == S_CHUNK)&&(per_roi_cnt == CHUNK_SIZE - 1)&&(roi_num_cnt == MROI_MAX_NUM - 1)) begin//这个时间点是统计blockid和统计像素数的分界点，加法器应被清0
			adder_clr <= 1'b1;
		end
		else begin
			adder_clr <= 1'b0;
		end
	end
	// adder_ce
	always @ (posedge clk) begin
		case(current_state)
			S_IMAGE:	//加法器处于统计有效像素时钟阶段
				adder_ce <= i_data_valid;
			S_LEADER, S_CHUNK, S_TRAILER: //加法器处于统计blockid阶段
				//有效条件
				// 1. 当前roi被选中
				// 2. per_roi_cnt==2时已经过了每个roi传递blockid的阶段，此时执行累加
				adder_ce <= (per_roi_cnt==2);
			default:
				adder_ce <= 1'b0;
		endcase
	end

	 // adder_a
	always @ (*) begin
		case(current_state)
			S_IMAGE: begin	//加法器处于统计有效像素时钟阶段
				adder_a <= adder_sum; //在S_IMAGE之前会清0加法器，因此从0开始累加
			end

			S_LEADER, S_CHUNK, S_TRAILER: begin //加法器处于统计blockid阶段
				if(roi_num_cnt == 0) begin //第一个roi，加法器从blockid_low47_acc得到初始值
					adder_a <= blockid_low47_acc;
				end
				else begin //之后的周期开始累加，blockid_low47_roi就是每个roi需要输出的blockid
					adder_a <= blockid_low47_roi;
				end
			end

			default: begin
				adder_a <= 'b0;
			end
		endcase
	end

	// adder_b
	always @ (posedge clk) begin
		case(current_state)
			S_IMAGE: begin	//加法器处于统计有效像素时钟阶段
				adder_b <= 1'b1; //在S_IMAGE之前会清0加法器，因此从0开始累加
			end

			S_LEADER, S_CHUNK, S_TRAILER: begin //加法器处于统计blockid阶段
				adder_b <= multi_roi_single_en_reg[roi_num_cnt];
			end

			default: begin
				adder_b <= 'b0;
			end
		endcase
	end
	//	-------------------------------------------------------------------------------------
	//	-ref blockid_low47_roi
	//
	//				leader		| chunk		| trailer  	||leader		| chunk		| trailer
	// 				|roi0---roi1|roi0---roi1|roi0---roi1| roi0---roi1|roi0---roi1|roi0---roi1|
	//	low47_roi	|0------1---|0------1---|0------1---| 2------3---|2------3---|2------3---|
	//	low47_acc	0									|2
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case(current_state)
			S_LEADER, S_CHUNK, S_TRAILER: begin
				if(per_roi_cnt == 'b0) begin  //更新blockid_low47_roi的阶段在每个roi的第一个周期，保证包传输blockid时已经完成更新
					if(roi_num_cnt == 0) begin
						blockid_low47_roi <= blockid_low47_acc;//第一个roi从blockid_low47_acc处取到初值
					end
					else begin
						blockid_low47_roi <= adder_sum;//加法器累加值储存在blockid_low47_roi中供包取走
					end
				end
			end
			default:
				blockid_low47_roi <= blockid_low47_roi;
		endcase
	end

	always @ (posedge clk) begin
		if((current_state == S_IDLE) && (!stream_enable_reg)) begin //S_IDLE期间如果se拉低，blockid_low47_acc需要被清0
			blockid_low47_acc <= 'b0;
		end
		else if((current_state == S_CHUNK)&&(per_roi_cnt == CHUNK_SIZE - 1)&&(roi_num_cnt == MROI_MAX_NUM - 1)) begin//trailer包的倒数第二个周期更新blockid_low47_acc。因为之后加法器会被清零用于统计像素数，所以加法器的累计值应及时取出
			blockid_low47_acc <= adder_sum;
		end
	end
	//	-------------------------------------------------------------------------------------
	//	-ref  status
	//	-------------------------------------------------------------------------------------

	//	统计image_flag期间的数据有效个数
	always @ (posedge clk) begin
		if(fval_rise) begin
			act_payload_cnt	<= 0;
		end
		else if(fval_fall) begin
			act_payload_cnt	<= adder_sum<<PAYLOAD_SHIFT_NUM;
		end
	end

	// 统计payload和给定payload比较，根据比较结果确定status
	always @ (posedge clk) begin
		if(act_payload_cnt[REG_WD-1:3]>chunk_size_img_reg[REG_WD-1:3]) begin
			status	<= 16'hA101;
			valid_payload_size <= act_payload_cnt;
		end
		else if(act_payload_cnt[REG_WD-1:3]<chunk_size_img_reg[REG_WD-1:3]) begin
			status	<= 16'hA100;
			valid_payload_size <= act_payload_cnt;
		end
		else begin
			status	<= 16'h0000;
			valid_payload_size <= valid_payload_size_mroi[last_roi_num];
		end
	end

	//	-------------------------------------------------------------------------------------
	//	-ref valid_payload_size_mroi
	//	-------------------------------------------------------------------------------------


	//	-------------------------------------------------------------------------------------
	//	-ref chunk_layoutid
	//	--当chunk使能信号有改变的时候， id++
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(chunk_mode_active_dly^i_chunk_mode_active || chunkid_en_ts_dly^i_chunkid_en_ts || chunkid_en_fid_dly^i_chunkid_en_fid) begin
			chunk_layout_id	<= chunk_layout_id + 1'b1;
		end
	end

	//	===============================================================================================
	//	寻找最后一个roi
	//	===============================================================================================
	// 在leader包传输阶段：
	//	1.每个roi的第2个周期将roi位使能寄存器右移一位
	//	2.每个roi的第3个周期判断roi位使能寄存器是否为0，如果为0，则当前roi为最后一个有效roi
	always @ (posedge clk) begin
		if(fval_rise) begin
			multi_roi_single_en_shift <= iv_multi_roi_single_en;
		end
		else if((current_state == S_LEADER) && (per_roi_cnt == 1)) begin
			multi_roi_single_en_shift <= multi_roi_single_en_shift >> 1;
		end
	end

	always @ (posedge clk) begin
		if(fval_rise) begin
			last_roi_num <= {MROI_NUM_WD{1'b1}};
		end
		if((current_state == S_LEADER) && (per_roi_cnt == 2)) begin
			if(multi_roi_single_en_shift == 0) begin
				last_roi_num <= roi_num_cnt;
			end
		end
	end

	assign is_last_roi = (last_roi_num == roi_num_cnt) ? 1'b1 : 1'b0;
//	===============================================================================================
//	状态机设计
//	===============================================================================================
	//	===============================================================================================
	//	ref ***FSM***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	-ref FSM Sequential Logic
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			current_state	<= S_IDLE;
		end
		else begin
			current_state	<= next_state;
		end
	end
	//	===============================================================================================
	//	-ref FSM pipeline
	//	===============================================================================================

	//	roi_num_cnt	0---------------1---------------2……………………--M-1-------------0
	//	per_roi_cnt 0--1--2……--N-1--0--1--2……--N-1--0……………………--0--1--2……--N-1--0
	//	其中 M=MROI_MAX_NUM   N=XXX_SIZE

	//	per_roi_cnt
	always @ (posedge clk) begin
		case(current_state)
			S_IDLE, S_IMAGE: begin
				per_roi_cnt <= 'b0;
			end

			S_TIMESTAMP : begin
				if(per_roi_cnt == TIMESTAMP_DELAY - 1) begin
					per_roi_cnt <= 'b0;
				end
				else begin
					per_roi_cnt <= per_roi_cnt + 1'b1;
				end
			end

			S_LEADER: begin
				if(per_roi_cnt == LEADER_SIZE - 1) begin
					per_roi_cnt <= 'b0;
				end
				else begin
					per_roi_cnt <= per_roi_cnt + 1'b1;
				end
			end

			S_CHUNK: begin
				if(per_roi_cnt == CHUNK_SIZE - 1) begin
					per_roi_cnt <= 'b0;
				end
				else begin
					per_roi_cnt <= per_roi_cnt + 1'b1;
				end
			end

			S_TRAILER, S_F_TRAILER: begin
				if(per_roi_cnt == TRAILER_SIZE - 1) begin
					per_roi_cnt <= 'b0;
				end
				else begin
					per_roi_cnt <= per_roi_cnt + 1'b1;
				end
			end

			S_EXT: begin
				if(per_roi_cnt == EXT_SIZE - 1) begin
					per_roi_cnt <= 'b0;
				end
				else begin
					per_roi_cnt <= per_roi_cnt + 1'b1;
				end
			end

			default: begin
				per_roi_cnt <= 'b0;
			end
		endcase
	end

	//	roi_num_cnt
	//	每个状态下，随roi窗口递加
	always @ (posedge clk) begin
		case(current_state)
			S_IDLE, S_TIMESTAMP, S_IMAGE, S_F_TRAILER, S_EXT: begin
				roi_num_cnt <= 'b0;
			end

			S_LEADER: begin
				if(per_roi_cnt == LEADER_SIZE - 1) begin
					if(roi_num_cnt == MROI_MAX_NUM - 1) begin
						roi_num_cnt <= 'b0;
					end
					else begin
						roi_num_cnt <= roi_num_cnt + 1'b1;
					end
				end
			end

			S_TRAILER: begin
				if(per_roi_cnt == TRAILER_SIZE - 1) begin
					if(roi_num_cnt == MROI_MAX_NUM - 1) begin
						roi_num_cnt <= 'b0;
					end
					else begin
						roi_num_cnt <= roi_num_cnt + 1'b1;
					end
				end
			end

			S_CHUNK: begin
				if(per_roi_cnt == CHUNK_SIZE - 1) begin
					if(roi_num_cnt == MROI_MAX_NUM - 1) begin
						roi_num_cnt <= 'b0;
					end
					else begin
						roi_num_cnt <= roi_num_cnt + 1'b1;
					end
				end
			end

			default: begin
				roi_num_cnt <= 'b0;
			end
		endcase
	end


	//	-------------------------------------------------------------------------------------
	//	-ref FSM Conbinatial Logic
	//	-------------------------------------------------------------------------------------
	always @ ( * ) begin
		case(current_state)
			S_IDLE: begin //i_fval的上升沿时S_IDLE跳转到S_TIMESTAMP的条件
				if(fval_rise) begin
					next_state = S_TIMESTAMP;
				end
				else begin
					next_state = S_IDLE;
				end
			end

			S_TIMESTAMP: begin
				//在S_TIMESTAMP状态停留一段时间，使时间戳稳定下来，再跳转到S_LEADER状态
				if(per_roi_cnt == TIMESTAMP_DELAY - 1) begin
					next_state = S_LEADER;
				end
				else begin
					next_state = S_TIMESTAMP;
				end
			end

			S_LEADER: begin
				//跳转条件是1.每个roi发送完成leader包 2.遍历所有roi
				if((per_roi_cnt == LEADER_SIZE - 1)&&(roi_num_cnt == MROI_MAX_NUM - 1)) begin
					next_state = S_TRAILER;
				end

				else begin
					next_state = S_LEADER;
				end
			end

			S_TRAILER: begin
				//跳转条件是1.每个roi发送完成trailer包 2.遍历所有roi
				if((per_roi_cnt == TRAILER_SIZE - 1)&&(roi_num_cnt == MROI_MAX_NUM - 1)) begin
					next_state = S_CHUNK;
				end

				else begin
					next_state = S_TRAILER;
				end
			end

			S_CHUNK: begin
				//跳转条件是1.每个roi发送完成CHUNK包 2.遍历所有roi
				if((per_roi_cnt == CHUNK_SIZE - 1)&&(roi_num_cnt == MROI_MAX_NUM - 1)) begin
					next_state = S_IMAGE;
				end

				else begin
					next_state = S_CHUNK;
				end
			end

			S_IMAGE: begin //跳转条件是i_fval下降沿
				if(fval_fall) begin
					next_state = S_F_TRAILER;
				end
				else begin
					next_state = S_IMAGE;
				end
			end

			S_F_TRAILER: begin
				//跳转条件是1.每个roi发送完成trailer包 2.遍历所有roi
				if(per_roi_cnt == TRAILER_SIZE - 1) begin
					next_state = S_EXT;
				end

				else begin
					next_state = S_F_TRAILER;
				end
			end



			S_EXT: begin
				//在S_EXT停留一段时间，将fval下降沿延迟一段时间再跳转
				if(per_roi_cnt == EXT_SIZE - 1) begin
					next_state = S_IDLE;
				end
				else begin
					next_state = S_EXT;
				end
			end

			default: begin
				next_state = S_IDLE;
			end
		endcase
	end

	//	-------------------------------------------------------------------------------------
	//	-ref FSM Output Logic
	//	-------------------------------------------------------------------------------------
	//	--ref o_data_valid
	always @ (posedge clk) begin
		case(current_state)
			S_IDLE, S_TIMESTAMP, S_EXT: begin
				data_valid_reg <= 1'b0;
			end

			S_LEADER, S_TRAILER: begin
				if(multi_roi_single_en_reg[roi_num_cnt]) begin//只有当前roi被选中才有效
					data_valid_reg <= 1'b1;
				end
				else begin
					data_valid_reg <= 1'b0;
				end
			end

			S_CHUNK: begin
				if(multi_roi_single_en_reg[roi_num_cnt]) begin//只有当前roi被选中才有效
					case(per_roi_cnt)
						//image id length
						0 : data_valid_reg	<= i_chunk_mode_active;
						//frameid
						1 : data_valid_reg	<= i_chunk_mode_active&i_chunkid_en_fid;
						//frameid id length
						2 : data_valid_reg	<= i_chunk_mode_active&i_chunkid_en_fid;
						//timestamp
						3 : data_valid_reg	<= i_chunk_mode_active&i_chunkid_en_ts;
						//timestamp id length
						4 : data_valid_reg	<= i_chunk_mode_active&i_chunkid_en_ts;
						default	: data_valid_reg	<= 1'b0;
					endcase
				end
				else begin
					data_valid_reg <= 1'b0;
				end
			end

			S_IMAGE: begin
				data_valid_reg <= i_data_valid;
			end

			S_F_TRAILER: begin
				data_valid_reg <= 1'b1;
			end

			default: begin
				data_valid_reg <= 1'b0;
			end
		endcase
	end
	assign o_data_valid = data_valid_reg;

	//	--ref ov_data


	always @ (posedge clk) begin
		case(current_state)
			S_IDLE, S_TIMESTAMP, S_EXT: begin
				data_reg <= 'b0;
			end

			S_LEADER: begin
				case(per_roi_cnt)
					//{{leader_size,reserved},magic_key}=={{leader_size,0},LV3U}
					0		: data_reg	<= {{16'd52,16'd0},32'h4c563355};
					//blockid
					1		: data_reg	<= {17'b0,blockid_low47_roi[46:0]};
					//{timestamp[31:0],payload_type,reserved} payload_type-这里只支持Image（0x0001）和Image Extended Chunk（0x4001）
					2		: data_reg	<= {iv_timestamp[31:0],{1'b0,i_chunk_mode_active,{14'h0001},16'h0000}};
					//{pixel_format,timestamp[63:32]}
					3		: data_reg	<= {iv_pixel_format,iv_timestamp[63:32]};
					//{size_y,size_x}
					4		: data_reg	<= {{16'h00,per_size_y_mroi[roi_num_cnt]},{16'h00,per_size_x_mroi[roi_num_cnt]}};
					//{offset_y,offset_x}
					5		: data_reg	<= {{16'h00,per_offset_y_mroi[roi_num_cnt]},{16'h00,per_offset_x_mroi[roi_num_cnt]}};
					//{reserved_byte,reserved_byte,(当前roi为最后一个roi时输出1),roi号,padding_x}
					6		: data_reg	<= {16'h0,{7'h0,is_last_roi},{{(8-MROI_NUM_WD){1'h0}},roi_num_cnt},32'h0};
					default	: data_reg	<= {32'h0,32'h0};
				endcase
			end

			S_TRAILER: begin
				case(per_roi_cnt)
					//{{trailer_size,reserved},magic_key}=={{trailer_size,0},TV3U} //利用使能位做了一个拼接，当i_chunk_mode_active使能，长度为36，否则为32
					0		: data_reg	<= {{13'h4,i_chunk_mode_active,2'b00,16'd0},32'h54563355};
					//blockid
					1		: data_reg	<= {17'b0,blockid_low47_roi};
					//{valid_payload_size[31:0],{reserved,status}} status为0，valid_payload_size为每个roi的chunk_size_img
					2		: data_reg	<= {valid_payload_size_mroi[roi_num_cnt],{16'h00,16'b0}}	;
					//{size_y,valid_payload_size[63:32]}
					3		: data_reg	<= {{16'h00,per_trailer_size_y_mroi[roi_num_cnt]},32'h0};
					//{dummy_word_by_dh,chunk_layout_id} chunk_layout_id为0 dummy_word_by_dh是dh自己添加的数据，为了填充8byte的空间
					4		: data_reg	<= {32'h0,{24'h0,chunk_layout_id}};
					default	: data_reg	<= {32'h0,32'h0};
				endcase
			end

			S_CHUNK: begin
				case(per_roi_cnt)
					//image id length
					0		: data_reg	<= {per_chunk_size_img_mroi[roi_num_cnt],32'h1};
					//frameid
					1		: data_reg	<= {17'b0,blockid_low47_roi[46:0]};
					//frameid id length
					2		: data_reg	<= {FID_LENTH,32'h2};
					//timestamp
					3		: data_reg	<= iv_timestamp[63:0];
					//timestamp id length
					4		: data_reg	<= {TS_LENTH,32'h3};
					default	: data_reg	<= {32'h0,32'h0};
					//				default	: data_reg	<= iv_data;
				endcase
			end

			S_IMAGE: begin
				data_reg <= iv_data;
			end

			S_F_TRAILER: begin
				case(per_roi_cnt)
					//{{trailer_size,reserved},magic_key}=={{trailer_size,0},TV3U} //利用使能位做了一个拼接，当i_chunk_mode_active使能，长度为36，否则为32
					0		: data_reg	<= {{13'h4,i_chunk_mode_active,2'b00,16'd0},32'h54563355};
					//blockid
					1		: data_reg	<= {17'b0,(blockid_low47_acc - 1)};//blockid_low47_acc储存的是下一帧的第一个有效roi的blockid，于是本帧的最后一个有效roi的blokcid应减1
					//{valid_payload_size[31:0],{reserved,status}} status-这里只支持Image（0x0001）和Image Extended Chunk（0x4001）
					2		: data_reg	<= {valid_payload_size,{16'h00,status}};
					//{size_y,valid_payloasd_size[63:32]}
					3		: data_reg	<= {{16'h00,per_trailer_size_y_mroi[last_roi_num]},32'h0};
					//{dummy_word_by_dh,chunk_layout_id} chunk_layout_id为0 dummy_word_by_dh是dh自己添加的数据，为了填充8byte的空间
					4		: data_reg	<= {32'h0,{24'h0,chunk_layout_id}};
					default	: data_reg	<= {32'h0,32'h0};
				endcase
			end

			default: begin
				data_reg <= 'b0;
			end
		endcase
	end

	assign ov_data = data_reg;

	// --ref o_fval
	always @ (posedge clk) begin
		if(current_state == S_TIMESTAMP) begin
			fval_reg <= 1'b1;
		end
		else if(current_state == S_IDLE) begin
			fval_reg <= 1'b0;
		end
	end
	assign o_fval = fval_reg;

	// --ref o_leader_flag / o_image_flag / o_chunk_flag / o_trailer_flag / o_trailer_final_flag
	always @ (posedge clk) begin
		if(current_state == S_LEADER) begin
			leader_flag_reg <= 1'b1;
		end
		else begin
			leader_flag_reg <= 1'b0;
		end
	end
	assign o_leader_flag = leader_flag_reg;

	always @ (posedge clk) begin
		if(current_state == S_IMAGE) begin
			image_flag_reg <= 1'b1;
		end
		else begin
			image_flag_reg <= 1'b0;
		end
	end
	assign o_image_flag = image_flag_reg;

	always @ (posedge clk) begin
		if(current_state == S_TRAILER) begin
			trailer_flag_reg <= 1'b1;
		end
		else begin
			trailer_flag_reg <= 1'b0;
		end
	end
	assign o_trailer_flag = trailer_flag_reg;

	always @ (posedge clk) begin
		if(current_state == S_CHUNK) begin
			chunk_flag_reg <= 1'b1;
		end
		else begin
			chunk_flag_reg <= 1'b0;
		end
	end
	assign o_chunk_flag = chunk_flag_reg;

	always @ (posedge clk) begin
		if(current_state == S_F_TRAILER) begin
			trailer_final_flag_reg <= 1'b1;
		end
		else begin
			trailer_final_flag_reg <= 1'b0;
		end
	end
	assign o_trailer_final_flag = trailer_final_flag_reg;

endmodule