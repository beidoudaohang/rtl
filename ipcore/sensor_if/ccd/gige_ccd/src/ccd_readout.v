
//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : ccd_readout.v
//  -- 设计者       : 禹剑
//-------------------------------------------------------------------------------------------------
//
//  --修改记录  :
//
//  -- 作者         :| 修改日期     :|  修改说明
//---------------------------------------------------------------------------------------
//  -- 禹剑       	:| 09/16/2013   :|  初始版本
//  -- 陈小平      	:| 04/29/2015   :|  进行修改，适应于ICX445 sensor
//  -- 邢海涛     	:| 2015/12/10   :|  移植到u3上
//---------------------------------------------------------------------------------------
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
`timescale      1ns/100ps
//-------------------------------------------------------------------------------------------------

module ccd_readout # (
	parameter		XSG_LINE_NUM		//XSG需要占用多少行
	)
	(
	input	            		clk      			,   //时钟
	input						reset				,	//复位，高有效
	input	[12:0]				iv_frame_period		,   //帧周期寄存器
	input						i_ccd_stop_flag		,	//
	input						i_exp_line_end		,	//完成行曝光的时间点，一个周期，
	input						i_line_end			,	//
	output						o_readout_flag		,	//读出标志，此标志有效下，不能打断hcount
	output						o_xsg_flag			,	//
	output	[12:0]				ov_vcount				//
	);


	//	ref signals
	//FSM Parameter Define
	parameter	S_IDLE				= 2'd0;
	parameter	S_XSG_PHASE			= 2'd1;
	parameter	S_READOUT_PHASE		= 2'd2;

	reg		[1:0]	current_state	= S_IDLE;
	reg		[1:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	integer			state_ascii;
	always @ ( * ) begin
		case(current_state)
			2'd0 :	state_ascii	<= "S_IDLE";
			2'd1 :	state_ascii	<= "S_XSG_PHASE";
			2'd2 :	state_ascii	<= "S_READOUT_PHASE";
		endcase
	end
	// synthesis translate_on


	reg					ccd_stop_flag_dly	= 1'b0;
	wire				ccd_stop_flag_rise	;
	reg					xsg_flag			= 1'b0;
	reg					readout_flag		= 1'b0;
	reg		[12:0]		vcount_reg			= 13'b0;


	//	ref ARCHITECTURE
	//	===============================================================================================
	//	ref ***取边沿***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  i_ccd_stop_flag 取沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		ccd_stop_flag_dly	<= i_ccd_stop_flag;
	end
	assign	ccd_stop_flag_rise	= (ccd_stop_flag_dly==1'b0 && i_ccd_stop_flag==1'b1) ? 1'b1 : 1'b0;

	//	===============================================================================================
	//	ref ***状态信号***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  xsg状态信号
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_XSG_PHASE) begin
			xsg_flag	<= 1'b1;
		end
		else begin
			xsg_flag	<= 1'b0;
		end
	end
	assign	o_xsg_flag	= xsg_flag;

	//	-------------------------------------------------------------------------------------
	//	readout状态信号
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			readout_flag 	<= 	1'b0;
		end
		else begin
			readout_flag 	<= 	1'b1;
		end
	end
	assign	o_readout_flag	= readout_flag;

	//  -------------------------------------------------------------------------------------
	//  功能说明：生成 ov_vcount 计数器，以行为单位
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			vcount_reg	<= 'b0;
		end
		else begin
			if(i_line_end) begin
				vcount_reg	<= vcount_reg + 1'b1;
			end
		end
	end
	assign	ov_vcount	= vcount_reg;

	//	===============================================================================================
	//	ref ***FSM***
	//	===============================================================================================
	//FSM Sequential Logic
	always @ (posedge clk) begin
		current_state <= next_state;
	end

	//FSM Conbinatial Logic
	always @ ( * ) begin
		case(current_state)
			S_IDLE	: begin
				if(i_exp_line_end) begin
					next_state	= S_XSG_PHASE;
				end
				else begin
					next_state	= S_IDLE;
				end
			end
			S_XSG_PHASE	: begin
				if(vcount_reg==(XSG_LINE_NUM-1) && i_line_end==1'b1) begin
					next_state	= S_READOUT_PHASE;
				end
				else begin
					next_state	= S_XSG_PHASE;
				end
			end
			S_READOUT_PHASE	: begin
				if((vcount_reg==iv_frame_period && i_line_end==1'b1) || ccd_stop_flag_rise==1'b1) begin
					next_state	= S_IDLE;
				end
				else begin
					next_state	= S_READOUT_PHASE;
				end
			end
			default	: begin
				next_state = S_IDLE;
			end
		endcase
	end

endmodule
