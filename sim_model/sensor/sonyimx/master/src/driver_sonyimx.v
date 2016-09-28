//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : driver_sonyimx
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/4/3 15:06:43	:|  初始版本
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
`define		TESTCASE	testcase_1
module driver_sonyimx ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	parameter	IMAGE_SRC				= `TESTCASE.SONYIMX_IMAGE_SRC			;
	parameter	DATA_WIDTH				= `TESTCASE.SONYIMX_DATA_WIDTH			;
	parameter	SOURCE_FILE_PATH		= `TESTCASE.SONYIMX_SOURCE_FILE_PATH		;
	parameter	GEN_FILE_EN				= `TESTCASE.SONYIMX_GEN_FILE_EN			;
	parameter	GEN_FILE_PATH			= `TESTCASE.SONYIMX_GEN_FILE_PATH		;
	parameter	NOISE_EN				= `TESTCASE.SONYIMX_NOISE_EN				;
	parameter	CHANNEL_NUM				= `TESTCASE.SONYIMX_CHANNEL_NUM				;

	localparam	CLKIN_PERIOD			= 27.778;	//需要和FPGA输出给sensor的频率一致

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	输入
	//	-------------------------------------------------------------------------------------
	wire							clk_sonyimx	;
	wire							o_fval_bfm	;

	//	-------------------------------------------------------------------------------------
	//	输出
	//	-------------------------------------------------------------------------------------
	wire								o_clk_p	;
	wire								o_clk_n	;
	wire	[CHANNEL_NUM-1:0]			ov_data_p	;
	wire	[CHANNEL_NUM-1:0]			ov_data_n	;

	//	-------------------------------------------------------------------------------------
	//	交互
	//	-------------------------------------------------------------------------------------

	wire									pwr_reset	;
	wire									locked	;
	wire									clk_ser	;
	wire									clk_para	;
	reg		[3:0]							clk_divx_cnt	= 4'b0;
	wire									clk_en	;
	wire									w_fval				;
	wire									w_lval				;
	wire	[DATA_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data			;
	wire									o_fval				;
	wire									o_lval				;
	wire									w_clk_p				;
	wire									w_clk_n		        ;
	//	ref ARCHITECTURE
	//	-------------------------------------------------------------------------------------
	//	引用
	//	-------------------------------------------------------------------------------------
	//  ===============================================================================================
	//	ref ***引用***
	//  ===============================================================================================
	assign	clk_sonyimx		= `TESTCASE.clk_sonyimx	;
	assign	o_fval_bfm		= w_fval	;

	//  -------------------------------------------------------------------------------------
	//	调用 bfm 模型
	//  -------------------------------------------------------------------------------------
	bfm_sonyimx # (
	.IMAGE_SRC					(IMAGE_SRC					),
	.DATA_WIDTH					(DATA_WIDTH					),
	.SENSOR_CLK_DELAY_VALUE		(0							),
	.CLK_DATA_ALIGN				("FALLING"					),
	.FVAL_LVAL_ALIGN			("TRUE"						),
	.SOURCE_FILE_PATH			(SOURCE_FILE_PATH			),
	.GEN_FILE_EN				(GEN_FILE_EN				),
	.GEN_FILE_PATH				(GEN_FILE_PATH				),
	.NOISE_EN					(NOISE_EN					)
	)
	bfm_sonyimx (
	.clk						(clk_para		),
	.o_fval						(o_fval_bfm		)
	);

	//  -------------------------------------------------------------------------------------
	//	产生时钟
	//  -------------------------------------------------------------------------------------
	dcm_sonyimx # (
	.DATA_WIDTH		(DATA_WIDTH		),
	.CLKIN_PERIOD	(CLKIN_PERIOD	)
	)
	dcm_sonyimx_inst (
	.clk_in		(clk_sonyimx		),
	.dcm_reset	(pwr_reset	|	!bfm_sonyimx.pll_init_done	),
	.clk0_out	(clk_ser		),
	.clk1_out	(clk_para		),
	.locked		(locked			)
	);

	//  -------------------------------------------------------------------------------------
	//	上电复位逻辑
	//	1.fpga 加载成功之后，会对 dcm pll产生复位信号，复位信号宽度是8个时钟周期
	//  -------------------------------------------------------------------------------------
	reg		[3:0]		pwr_cnt	= 4'b0;
	always @ (posedge clk_sonyimx) begin
		if(pwr_cnt[3] == 1'b0) begin
			pwr_cnt	<= pwr_cnt + 1'b1;
		end
	end
	assign	pwr_reset	= !pwr_cnt[3];

	//	-------------------------------------------------------------------------------------
	//	分频器
	//	--串行时钟频率是并行时钟频率的8倍
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk_ser) begin
		if(clk_divx_cnt==DATA_WIDTH-1) begin
			clk_divx_cnt	<= 4'd0;
		end
		else begin
			clk_divx_cnt	<= clk_divx_cnt + 1'b1;
		end
	end
	assign	clk_en	= (clk_divx_cnt==DATA_WIDTH-1) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	例化Sensor模型
	//  -------------------------------------------------------------------------------------
	mt9p031_model # (
	.IMAGE_SRC					(IMAGE_SRC				),
	.DATA_WIDTH					(DATA_WIDTH				),
	.CHANNEL_NUM				(CHANNEL_NUM			),
	.SENSOR_CLK_DELAY_VALUE		(0						),
	.CLK_DATA_ALIGN				("FALLING"				),
	.FVAL_LVAL_ALIGN			("TRUE"					),
	.SOURCE_FILE_PATH			(SOURCE_FILE_PATH		),
	.GEN_FILE_EN				(GEN_FILE_EN			),
	.GEN_FILE_PATH				(GEN_FILE_PATH			),
	.NOISE_EN					(NOISE_EN				)
	)
	mt9p031_model_inst (
	.clk						(clk_para						),
	.reset						(bfm_sonyimx.reset				),
	.i_pause_en					(bfm_sonyimx.i_pause_en			),
	.i_continue_lval			(bfm_sonyimx.i_continue_lval	),
	.iv_width					(bfm_sonyimx.iv_width			),
	.iv_line_hide				(bfm_sonyimx.iv_line_hide		),
	.iv_height					(bfm_sonyimx.iv_height			),
	.iv_frame_hide				(bfm_sonyimx.iv_frame_hide		),
	.iv_front_porch				(bfm_sonyimx.iv_front_porch		),
	.iv_back_porch				(bfm_sonyimx.iv_back_porch		),
	.o_clk_pix					(clk_sensor_pix					),
	.o_fval						(w_fval							),
	.o_lval						(w_lval							),
	.ov_dout					(wv_pix_data					)
	);

	//	-------------------------------------------------------------------------------------
	//	sonyimx 仿真模型
	//	-------------------------------------------------------------------------------------
	sonyimx_module # (
	.DATA_WIDTH		(DATA_WIDTH		),
	.CHANNEL_NUM	(CHANNEL_NUM	),
	.CLKIN_PERIOD	(CLKIN_PERIOD	)
	)
	sonyimx_module_inst (
	.clk_para		(clk_para		),
	.clk_ser		(clk_ser		),
//	.i_init_done	(bfm_sonyimx.data_init_done	),
	.i_clk_en		(clk_en			),
	.i_fval			(w_fval			),
	.i_lval			(w_lval			),
	.iv_pix_data	(wv_pix_data	),
	.o_clk_p		(o_clk_p		),
	.o_clk_n		(o_clk_n		),
	.o_fval			(o_fval			),
	.o_lval			(o_lval			),
	.ov_data_p		(ov_data_p		),
	.ov_data_n		(ov_data_n		)
	);


endmodule
