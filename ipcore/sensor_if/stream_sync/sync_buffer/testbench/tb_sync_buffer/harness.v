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
	parameter	SENSOR_DAT_WIDTH	= `TESTCASE.SENSOR_DAT_WIDTH	;
	parameter	CHANNEL_NUM			= `TESTCASE.CHANNEL_NUM	;
	parameter	REG_WD				= `TESTCASE.REG_WD			;

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	输入
	//	-------------------------------------------------------------------------------------
	wire											clk_sensor_pix	;
	wire											i_fval	;
	wire											i_lval	;
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data	;
	wire											clk_pix	;
	wire											i_acquisition_start	;
	wire											i_stream_enable	;
	wire											i_encrypt_state	;
	//	-------------------------------------------------------------------------------------
	//	输出
	//	-------------------------------------------------------------------------------------
	wire											o_fval				;
	wire											o_lval				;
	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data			;



	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	引入输入信号
	//	-------------------------------------------------------------------------------------
	assign	clk_sensor_pix		= `TESTCASE.clk_sensor_pix	;
	assign	i_clk_en			= `TESTCASE.i_clk_en	;
	assign	i_fval				= `TESTCASE.o_fval_sensor	;
	assign	i_lval				= `TESTCASE.o_lval_sensor	;
	assign	iv_pix_data			= `TESTCASE.ov_pix_data_sensor	;
	assign	clk_pix				= `TESTCASE.clk_pix	;

	assign	i_acquisition_start	= bfm_se_acq.i_acquisition_start	;
	assign	i_stream_enable		= bfm_se_acq.i_stream_enable	;
	assign	i_encrypt_state		= bfm_reg_common.i_encrypt_state	;

	//	-------------------------------------------------------------------------------------
	//	例化 bfm 模块
	//	-------------------------------------------------------------------------------------
	bfm_se_acq		bfm_se_acq();

	bfm_reg_common # (
	.REG_WD		(`TESTCASE.REG_WD	)
	)
	bfm_reg_common ();

	//	-------------------------------------------------------------------------------------
	//	例化sync buffer模型
	//	-------------------------------------------------------------------------------------
	sync_buffer # (
	.SENSOR_DAT_WIDTH		(SENSOR_DAT_WIDTH		),
	.CHANNEL_NUM			(CHANNEL_NUM			),
	.REG_WD					(REG_WD					)
	)
	sync_buffer_inst (
	.clk_sensor_pix			(clk_sensor_pix			),
	.i_clk_en				(i_clk_en				),
	.i_fval					(i_fval					),
	.i_lval					(i_lval					),
	.iv_pix_data			(iv_pix_data			),
	.i_enable				(1'b1					),
	.clk_pix				(clk_pix				),
	.o_fval					(o_fval					),
	.o_lval					(o_lval					),
	.ov_pix_data			(ov_pix_data			)
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
