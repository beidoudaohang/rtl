
//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : ccd_exp.v
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  --修改记录  :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛      	:| 2015/12/23 10:51:52	:|  初始版本，在mv_ccd上修改
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : ccd_exp 产生曝光各种标志
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale      1ns/100ps
//-------------------------------------------------------------------------------------------------

module ccd_exp # (
	parameter	LINE_PERIOD		= 1532		,	//行周期
	parameter	LINE_CNT_WIDTH	= 13			//行计数器宽度
	)
	(
	input									clk      			,   //时钟
	input									reset				,	//复位，高有效
	input		[`EXP_WD-1:0]				iv_exp_reg			,   //曝光时钟个数寄存器
	input		[`EXP_WD-1:0]				iv_exp_line_reg		,	//曝光整行时钟个数寄存器
	input		[`FRAME_WD-1:0]				iv_exp_start_reg	,	//
	input  		[`FRAME_WD-1:0]				iv_vcount			,	//
	input									i_readout_flag		,	//
	input                       			i_start_acquisit	,   //给CCD模块的开采信号
	input									i_triggermode		,   //给CCD模块的采集模式信号
	input									i_trigger			,   //给CCD模块的触发信号
	input									i_xsg_flag			,	//
	input									i_exposure_end		,	//
	output									o_reg_active		,	//
	output		[LINE_CNT_WIDTH-1:0]		ov_hcount			,	//行计数器
	output  								o_line_end			,	//行结束标志，与行计数器的最大值对齐
	output									o_exp_line_end		,	//曝光行结束标志
	output									o_trigger_mask		,	//屏蔽标志
	output									o_integration       	//积分信号
	);

	//	ref signals
	wire							hcount_reset				;
	reg			[3:0]				start_acquisit_shift		;
	reg			[1:0]				triggermode_shift			;
	reg			[1:0]				exp_start_line_flag_shift	;
	wire							exp_start_line_flag			;
	reg								trigger_reg					;
	reg								trigger_reg_dly_0			;
	reg								trigger_reg_dly_1			;
	reg								trigger2hend				;
	wire							exp_start_tri				;
	wire							exp_start_con				;
	wire							exp_start					;
	reg								exp_flag 					;
	reg		[`EXP_WD-1:0]			exp_count					;
	wire							integration_start			;
	reg								trig_2_cont_wt_hend			;
	reg		[1:0]					xsg_flag_shift				;

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//  第二部分：模块实例化
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  ccd_count		: ccd周期计数器
	//  -------------------------------------------------------------------------------------
	ccd_count # (
	.LINE_PERIOD	(LINE_PERIOD	),
	.LINE_CNT_WIDTH	(LINE_CNT_WIDTH	)
	)
	ccd_count_inst (
	.clk			(clk			),
	.reset			(hcount_reset	),
	.o_line_end		(o_line_end		),
	.ov_count		(ov_hcount		)
	);

	//  ===============================================================================================
	//  第三部分：曝光起始逻辑
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	i_start_acquisit 取沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		start_acquisit_shift	<= {start_acquisit_shift[2:0],i_start_acquisit};
	end

	//  -------------------------------------------------------------------------------------
	//	i_triggermode 取沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		triggermode_shift	<= {triggermode_shift[0],i_triggermode};
	end

	//  -------------------------------------------------------------------------------------
	//	exp_start_line_flag 取沿
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		exp_start_line_flag_shift	<= {exp_start_line_flag_shift[0],exp_start_line_flag};
	end

	//  -------------------------------------------------------------------------------------
	//	功能说明：生成曝光开始行标志
	//  -------------------------------------------------------------------------------------
	assign exp_start_line_flag	= (iv_exp_start_reg==iv_vcount) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//  触发模式曝光非屏蔽阶段
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			trigger_reg	<= 1'b0;
		end
		else if(!o_trigger_mask && i_triggermode && i_start_acquisit) begin
			trigger_reg <= i_trigger;
		end
		else begin
			trigger_reg	<= 1'b0;
		end
	end

	always @ (posedge clk) begin
		trigger_reg_dly_0	<= trigger_reg;
		trigger_reg_dly_1	<= trigger_reg_dly_0;
	end

	//  -------------------------------------------------------------------------------------
	//  触发模式曝光发生在i_readout_flag有效时,触发找hend
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			trigger2hend	<=	1'b0;
		end
		else if(trigger_reg_dly_1 && i_readout_flag) begin
			trigger2hend	<=	1'b1;
		end
		else if(o_line_end) begin
			trigger2hend	<=	1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	// 触发切连续时（非readout阶段）,触发找hend，在下一行开始处进行曝光
	//  -------------------------------------------------------------------------------------

	always @ ( posedge clk )
	begin
		if(reset)
		begin
			trig_2_cont_wt_hend	<=	1'b0;
		end
		else if((triggermode_shift == 2'b10) && !o_trigger_mask)
		begin
			trig_2_cont_wt_hend	<=	1'b1;
		end
		else if(o_line_end)
		begin
			trig_2_cont_wt_hend	<=	1'b0;
		end
	end
	//  -------------------------------------------------------------------------------------
	//  区分不同曝光模式开始信号
	//	连续模式时：1、开采上升沿
	//				2、到达曝光起始行标志
	//
	//	触发模式时：1、开采且触发且曝光非屏蔽阶段
	//
	//	触发模式切换到连续模式且!i_readout_flag时
	//		触发切连续时（非屏蔽阶段），将曝光起始阶段，延迟到行hend时，再开始曝光（陈小平）。
	//  -------------------------------------------------------------------------------------

	assign	exp_start_tri 	= (trigger2hend && o_line_end) || (trigger_reg_dly_1 && !i_readout_flag)											;
	assign	exp_start_con 	= ((start_acquisit_shift == 4'b0111) || (exp_start_line_flag && o_line_end)) || (trig_2_cont_wt_hend & o_line_end)		;
	assign	exp_start 		= i_start_acquisit ? (i_triggermode ? exp_start_tri : exp_start_con) : 1'b0										;

	//  -------------------------------------------------------------------------------------
	//  功能说明：w_hcount_set
	//	区分条件：
	//		1、曝光发生在i_readout_flag无效时	：	复位hcount
	//  -------------------------------------------------------------------------------------
	assign	hcount_reset 	= (!i_readout_flag & exp_start) ;

	//  ===============================================================================================
	//  第四部分：计算曝光计数器
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  功能说明：生成曝光周期计数器，以像素时钟为单位
	//  -------------------------------------------------------------------------------------

	always @ ( posedge clk )
	begin
		if(reset)
		begin
			exp_flag	<=	1'b0;
		end
		else if((exp_count == iv_exp_reg) || !i_start_acquisit)
		begin
			exp_flag	<=	1'b0;
		end
		else if(exp_start)
		begin
			exp_flag	<=	1'b1;
		end
	end

	always @ ( posedge clk )
	begin
		if(reset)
		begin
			exp_count	<=	`EXP_WD'h0;
		end
		else if(exp_flag)
		begin
			exp_count	<=	exp_count + `EXP_WD'h1;
		end
		else
		begin
			exp_count	<=	`EXP_WD'h0;
		end
	end

	//  ===============================================================================================
	//  第五部分：输出曝光相关标志
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  功能说明： 曝光启动
	//  -------------------------------------------------------------------------------------

	assign	integration_start	= ((exp_count == `SUB_PER_WIDTH) && exp_flag && i_start_acquisit) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//  功能说明： 行曝光结束，启动XSG阶段
	//  -------------------------------------------------------------------------------------

	assign	o_exp_line_end		= ((exp_count == iv_exp_line_reg) && exp_flag && i_start_acquisit) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//  功能说明：积分标志
	//  -------------------------------------------------------------------------------------

	always @ ( posedge clk )
	begin
		if(reset)
		begin
			o_integration	<= 1'b0;
		end
		else if(i_exposure_end || !i_start_acquisit)
		begin
			o_integration 	<= 1'b0;
		end
		else if(integration_start)
		begin
			o_integration 	<= 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  功能说明：曝光屏蔽标志
	//  -------------------------------------------------------------------------------------

	always @ ( posedge clk )
	begin
		if(reset)
		begin
			o_trigger_mask	<= 1'b0;
		end
		else if((exp_start_line_flag_shift == 2'b01) || !i_start_acquisit)
		begin
			o_trigger_mask 	<= 1'b0;
		end
		else if(exp_start || trigger_reg)
		begin
			o_trigger_mask 	<= 1'b1;
		end
	end

	//  ===============================================================================================
	//  第六部分：寄存器生效时机
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	xsg_flag_shift 取沿
	//  -------------------------------------------------------------------------------------

	always @ ( posedge clk )
	begin
		xsg_flag_shift	<=	{xsg_flag_shift[0],i_xsg_flag};
	end

	//  -------------------------------------------------------------------------------------
	//	功能说明：
	//		1、连续模式下开采时
	//		2、曝光结束开始新的传输帧时
	//		3、触发模式时，传输完整帧后再触发时
	//  -------------------------------------------------------------------------------------

	assign	o_reg_active =  (start_acquisit_shift == 4'b0001) || (i_triggermode && !i_readout_flag && trigger_reg) || (xsg_flag_shift == 2'b10);

endmodule