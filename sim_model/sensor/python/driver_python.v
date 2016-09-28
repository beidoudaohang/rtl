//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : driver_python
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
module driver_python ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	parameter	IMAGE_SRC				= `TESTCASE.PYTHON_IMAGE_SRC			;
	parameter	DATA_WIDTH				= `TESTCASE.PYTHON_DATA_WIDTH			;
	parameter	SOURCE_FILE_PATH		= `TESTCASE.PYTHON_SOURCE_FILE_PATH		;
	parameter	GEN_FILE_EN				= `TESTCASE.PYTHON_GEN_FILE_EN			;
	parameter	GEN_FILE_PATH			= `TESTCASE.PYTHON_GEN_FILE_PATH		;
	parameter	NOISE_EN				= `TESTCASE.PYTHON_NOISE_EN				;

	localparam	CHANNEL_NUM				= 4	;

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	输入
	//	-------------------------------------------------------------------------------------
	wire							clk_python	;
	wire							o_fval_bfm	;

	//	-------------------------------------------------------------------------------------
	//	输出
	//	-------------------------------------------------------------------------------------
	wire								o_clk_p	;
	wire								o_clk_n	;
	wire	[CHANNEL_NUM-1:0]			ov_data_p	;
	wire	[CHANNEL_NUM-1:0]			ov_data_n	;
	wire								o_ctrl_p	;
	wire								o_ctrl_n	;

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


	//	ref ARCHITECTURE
	//	-------------------------------------------------------------------------------------
	//	引用
	//	-------------------------------------------------------------------------------------
	//  ===============================================================================================
	//	ref ***引用***
	//  ===============================================================================================
	assign	clk_python		= `TESTCASE.clk_python	;
	assign	o_fval_bfm		= w_fval	;

	//  -------------------------------------------------------------------------------------
	//	调用 bfm 模型
	//  -------------------------------------------------------------------------------------
	bfm_python # (
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
	bfm_python (
	.clk						(clk_para		),
	.o_fval						(o_fval_bfm		)
	);

	//  -------------------------------------------------------------------------------------
	//	产生时钟
	//  -------------------------------------------------------------------------------------
	dcm_python # (
	.DATA_WIDTH	(DATA_WIDTH		)
	)
	dcm_python_inst (
	.clk_in		(clk_python		),
	.dcm_reset	(pwr_reset	|	!bfm_python.pll_init_done	),
	.clk0_out	(clk_para		),
	.clk_fx_out	(clk_ser		),
	.locked		(locked			)
	);

	//  -------------------------------------------------------------------------------------
	//	上电复位逻辑
	//	1.fpga 加载成功之后，会对 dcm pll产生复位信号，复位信号宽度是8个时钟周期
	//  -------------------------------------------------------------------------------------
	reg		[3:0]		pwr_cnt	= 4'b0;
	always @ (posedge clk_python) begin
		if(pwr_cnt[3] == 1'b0) begin
			pwr_cnt	<= pwr_cnt + 1'b1;
		end
	end
	assign	pwr_reset	= !pwr_cnt[3];

	//	-------------------------------------------------------------------------------------
	//	分频器
	//	--串行时钟频率是并行时钟频率的10倍 8倍
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
	.reset						(bfm_python.reset				),
	.i_pause_en					(bfm_python.i_pause_en			),
	.i_continue_lval			(bfm_python.i_continue_lval	),
	.iv_width					(bfm_python.iv_width			),
	.iv_line_hide				(bfm_python.iv_line_hide		),
	.iv_height					(bfm_python.iv_height			),
	.iv_frame_hide				(bfm_python.iv_frame_hide		),
	.iv_front_porch				(bfm_python.iv_front_porch		),
	.iv_back_porch				(bfm_python.iv_back_porch		),
	.o_clk_pix					(clk_sensor_pix					),
	.o_fval						(w_fval							),
	.o_lval						(w_lval							),
	.ov_dout					(wv_pix_data					)
	);

	//	-------------------------------------------------------------------------------------
	//	python 仿真模型
	//	-------------------------------------------------------------------------------------
	python_module # (
	.DATA_WIDTH		(DATA_WIDTH		),
	.CHANNEL_NUM	(CHANNEL_NUM	)
	)
	python_module_inst (
	.clk_para		(clk_para		),
	.clk_ser		(clk_ser		),
	.i_init_done	(bfm_python.data_init_done	),
	.i_clk_en		(clk_en			),
	.i_fval			(w_fval			),
	.i_lval			(w_lval			),
	.iv_pix_data	(wv_pix_data	),
	.o_clk_p		(o_clk_p		),
	.o_clk_n		(o_clk_n		),
	.ov_data_p		(ov_data_p		),
	.ov_data_n		(ov_data_n		),
	.o_ctrl_p		(o_ctrl_p		),
	.o_ctrl_n		(o_ctrl_n		)
	);


endmodule
