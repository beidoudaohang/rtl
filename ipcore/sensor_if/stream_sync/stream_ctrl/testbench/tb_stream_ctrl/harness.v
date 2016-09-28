//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : harness
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/9 17:18:50	:|  初始版本
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
`define		TESTCASE	testcase1
module harness ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	parameter	REG_WD				= `TESTCASE.REG_WD			;

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	输入
	//	-------------------------------------------------------------------------------------
	wire								clk_pix	;
	wire								i_fval	;
	wire								i_acquisition_start	;
	wire								i_stream_enable	;
	wire	[REG_WD-1:0]				iv_pixel_format	;
	wire	[2:0]						iv_test_image_sel	;
	wire								i_encrypt_state	;
	//	-------------------------------------------------------------------------------------
	//	输出
	//	-------------------------------------------------------------------------------------
	wire								o_enable	;
	wire								o_full_frame_state	;
	wire	[REG_WD-1:0]				ov_pixel_format		;
	wire	[2:0]						ov_test_image_sel	;
	//	-------------------------------------------------------------------------------------
	//	debug
	//	-------------------------------------------------------------------------------------
	wire				o_fval	;

	//	ref ARCHITECTURE
	//	-------------------------------------------------------------------------------------
	//	引入输入信号
	//	-------------------------------------------------------------------------------------
	assign	clk_pix				= `TESTCASE.clk_pix_sensor	;
	assign	i_fval				= `TESTCASE.o_fval_sensor	;

	assign	i_acquisition_start	= bfm_se_acq.i_acquisition_start	;
	assign	i_stream_enable		= bfm_se_acq.i_stream_enable	;
	assign	iv_pixel_format		= bfm_reg_common.iv_pixel_format	;
	assign	iv_test_image_sel	= bfm_reg_common.iv_test_image_sel	;
	assign	i_encrypt_state		= bfm_reg_common.i_encrypt_state	;

	//	-------------------------------------------------------------------------------------
	//	例化 bfm 模块
	//	-------------------------------------------------------------------------------------
	bfm_se_acq		bfm_se_acq();

	bfm_reg_common # (
	.REG_WD		(`TESTCASE.REG_WD	)
	)
	bfm_reg_common ();

	wire				w_fval_sync	;
	reg		[19:0]		fval_shift	= 20'b0;
	always @ (posedge clk_pix) begin
		fval_shift	<= {fval_shift[18:0],i_fval};
	end
	assign	w_fval_sync	= i_fval | fval_shift[19];

	//	-------------------------------------------------------------------------------------
	//	例化 stream_ctrl 模型
	//	-------------------------------------------------------------------------------------
	stream_ctrl # (
	.REG_WD					(REG_WD	)
	)
	stream_ctrl_inst (
	.clk_pix				(clk_pix				),
	.i_fval					(i_fval					),
	.i_fval_sync			(w_fval_sync			),
	.i_acquisition_start	(i_acquisition_start	),
	.i_stream_enable		(i_stream_enable		),
	.i_encrypt_state		(i_encrypt_state		),
	.iv_pixel_format		(iv_pixel_format		),
	.iv_test_image_sel		(iv_test_image_sel		),
	.o_enable				(o_enable				),
	.o_full_frame_state		(o_full_frame_state		),
	.ov_pixel_format		(ov_pixel_format		),
	.ov_test_image_sel		(ov_test_image_sel		)
	);

	//generate vcd file
	//initial begin
	//$dumpfile("test.vcd");
	//$dumpvars(1,top_frame_buffer_inst);
	//end

	//for lattice simulation
	//GSR   GSR_INST (.GSR (1'b1)); //< global reset sig>
	//PUR   PUR_INST (.PUR (1'b1)); //<powerup reset sig>



endmodule
