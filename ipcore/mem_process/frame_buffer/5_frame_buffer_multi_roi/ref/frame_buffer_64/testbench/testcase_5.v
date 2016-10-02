//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : testcase
//  -- 设计者       : 张强
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 张强         :| 2015/4/8 16:46:01	:|
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module testcase_5 ;


//harness inst_harness ();
//  ===============================================================================================
//  配置图像大小
//  ===============================================================================================
	integer			i					;
	integer			j					;
	integer			k					;
	integer			i_chunkmodeactive	;
	integer			iv_frame_depth		;
	integer			iv_size_x			;
	integer			iv_size_y			;
	integer			iv_offset_x			;
	integer			iv_offset_y			;
	integer			iv_h_period 		;
	integer			iv_v_petiod 		;

	parameter						S_IDLE				= 6'b000000;
	parameter						S_REQ_WAIT			= 6'b000001;
	parameter						S_REQ				= 6'b000010;
	parameter						S_CMD_WAIT			= 6'b000100;
	parameter						S_CMD				= 6'b001000;
	parameter						S_RD				= 6'b010000;
	parameter						S_CHK				= 6'b100000;

//  ===============================================================================================
//	测试帧存深度
//	1、最大写入频率测试，改变写入时钟周期，检查前端fifo是否出现满，帧存输入数据和输出数据是否相同
//	2、写入频率100Mhz，读出频率100Mhz，MCB时钟125Mhz
//  ===============================================================================================
	parameter	CLK_IN_PERIOD 							= 10.000;
	parameter	CLK_OUT_PERIOD							= 10;
	parameter	CLK_FRAME_BUF_PERIOD					= 8;


	always # 12.5 						harness.sys_clk 		= ~harness.sys_clk;
	always # (CLK_IN_PERIOD/2)			harness.clk_vin 		= ~harness.clk_vin;
	always # (CLK_OUT_PERIOD/2)			harness.clk_vout 		= ~harness.clk_vout;
	always # (CLK_FRAME_BUF_PERIOD/2)	harness.clk_frame_buf 	= ~harness.clk_frame_buf;

//harness inst_harness ();
//  ===============================================================================================
//
//  ===============================================================================================
	initial
	begin
		i_chunkmodeactive	=	1;
		iv_frame_depth		=	2;
		iv_size_x			=	2592;
		iv_size_y			=	1944;
		iv_offset_x			=	10;
		iv_offset_y			=	10;
		iv_h_period 		=	2700;
		iv_v_petiod 		=	2100;

	    harness.bfm1_inst.config_imagesize
	    (
		i_chunkmodeactive				,
		iv_frame_depth					,
		iv_size_x						,
		iv_size_y						,
		iv_offset_x						,
		iv_offset_y						,
		iv_h_period 					,
		iv_v_petiod 					,

		harness.w_chunkmodeactive 		,
		harness.wv_frame_depth			,
		harness.wv_h_period 			,
		harness.wv_v_petiod 			,
		harness.wv_size_x				, 		//窗口宽度
		harness.wv_size_y				, 		//窗口高度
		harness.wv_offset_x				, 		//水平偏移
		harness.wv_offset_y				, 		//垂直便宜
		harness.iv_payload_size_frame_buf	,
		harness.iv_payload_size_pix			,
		harness.wv_u3v_size
 		);
		#3000
		harness.i_stream_en					= 1'b1;
		harness.i_stream_en_clk_in			= 1'b1;
		harness.rd_enbable					= 1'b1;

	end


//  ===============================================================================================
//  检测输出信号
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	check输入和输出数据是否相同
//  -------------------------------------------------------------------------------------

	reg	[7:0]fval_count;
	always @ ( posedge harness.w_fval or  posedge harness.reset	)
		begin
			if ( harness.reset )
				fval_count <= 8'h0;
			else
				fval_count <= fval_count + 8'h1;
		end
//  -------------------------------------------------------------------------------------
//	检测前端fifo是否有溢出
//  -------------------------------------------------------------------------------------

	always @ ( posedge harness.frame_buffer_inst.wrap_wr_logic_inst.fifo_full_nc )
		$display("%m: at time %t ERROR: front fifo is full ", $time);
endmodule
