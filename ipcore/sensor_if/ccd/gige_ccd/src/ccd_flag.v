
//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : ccd_flag.v
//  -- 设计者       : 禹剑
//-------------------------------------------------------------------------------------------------
//
//  --修改记录  :
//
//  -- 作者         :| 修改日期     :|  修改说明
//---------------------------------------------------------------------------------------
//  -- 禹剑       	:| 09/16/2013   :|  初始版本
//  -- 陈小平      	:| 04/29/2015   :|  进行修改，适应于ICX445 sensor
//  -- 邢海涛      	:| 2015/12/8    :|  移植到u3上
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

module ccd_flag # (
	parameter	iv_href_start	= 26		,	//行有效开始
	parameter	iv_href_end		= 1398		,	//行有效结束
	parameter	iv_hd_rising	= 88		,   //hd有效开始寄存器
	parameter	SUB_WIDTH		= 30		,   //sub有效信号宽度
	parameter	iv_hd_falling		,   //hd有效结束寄存器


	parameter	iv_vd_rising	= 3		,   //vd有效开始寄存器
	parameter	iv_vd_falling	= 1		,   //vd有效结束寄存器

	parameter	iv_sub_rising	= 31	,   //sub有效开始寄存器
	parameter	iv_sub_falling	= 1		,   //sub有效结束寄存器

	parameter	XV_LINE_POS1	= 34		,
	parameter	XV_LINE_POS2	= 48		,
	parameter	XV_LINE_POS3	= 62		,
	parameter	XV_LINE_POS4	= 76		,
	parameter	XV_LINE_POS5	= 93		,
	parameter	XV_LINE_POS6	= 107		,
	parameter	XV_LINE_POS7	= 121		,
	parameter	XV_LINE_POS8	= 135		,
	parameter	XV_WIDTH		= 4			,
	parameter 	XV_LINE_DEFAULT	= 4'b1100	,	// XV信号行正程期间的默认值
	parameter	XV_LINE_VALUE1	= 4'b1000	,
	parameter	XV_LINE_VALUE2	= 4'b1001	,
	parameter	XV_LINE_VALUE3	= 4'b0001	,
	parameter	XV_LINE_VALUE4	= 4'b0011	,
	parameter	XV_LINE_VALUE5	= 4'b0010	,
	parameter	XV_LINE_VALUE6	= 4'b0110	,
	parameter	XV_LINE_VALUE7	= 4'b0100	,
	parameter	XV_LINE_VALUE8	= 4'b1100	,



	)
	(
	input						clk      			,   //时钟
	input						reset				,	//时钟复位，高有效
	//寄存器
	input	[12:0]				iv_headblank_start	,   //
	input	[12:0]				iv_headblank_end	,   //
	input	[12:0]				iv_vref_start		,   //ROI开始行数
	input	[12:0]				iv_tailblank_start	,   //ROI结束行数
	input	[12:0]				iv_tailblank_end	,   //
	input	[12:0]				iv_vcount			,	//
	input	[12:0]				iv_hcount			,   //
	//内部信号
	input						i_ad_parm_valid		,	//
	input						i_readout_flag		,	//
	input	[12:0]				iv_xv_headblank		,	//
	input	[12:0]				iv_xv_tailblank		,	//
	input	[12:0]				iv_xv_xsg			,	//
	input						i_xsg_flag			,	//
	input						i_integration		,	//
	output						o_href				,   //场有效信号
	output						o_vref				,   //场有效信号
	output						o_headblank_flag	,   //场有效信号
	output						o_tailblank_flag	,   //场有效信号
	//AD 接口信号
	output						o_hd				,   //AD驱动信号HD
	output						o_vd				,   //AD驱动信号VD
	//CCD 接口信号
	output						o_sub				,	//
	output	[XV_WIDTH-1:0]		ov_xv					//垂直翻转信号
	);


	//  ===============================================================================================
	//  第一部分：模块设计中要用到的信号
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  寄存器、线网定义
	//  -------------------------------------------------------------------------------------

	reg			href_reg	= 1'b0;

	reg			[			       `XV_WD - 1 : 0]	xv_line				;
	reg												sub_line 			;

	reg												vd_reg				;
	reg												ad_parm_valid_flag	;
	reg			[  			     `LINE_WD - 1 : 0]	ad_parm_valid_cnt	;

	//  ===============================================================================================
	//  第二部分 ：输出 o_href、o_vref
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  生成给数据通道的行有效标志 输出 o_href
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(iv_hcount==iv_href_end) begin
			href_reg	<= 1'b0;
		end
		else if(iv_hcount==iv_href_start) begin
			href_reg	<= 1'b1;
		end
	end
	assign	o_href	= href_reg;

	//  -------------------------------------------------------------------------------------
	//  生成给数据通道的场有效标志 输出 o_vref
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_readout_flag) begin
			if(iv_vcount==iv_tailblank_start) begin
				vref_reg <= 1'b0;
			end
			else if(iv_vcount==iv_vref_start) begin
				vref_reg <= 1'b1;
			end
		end
		else begin
			vref_reg	<=	1'b0;
		end
	end
	assign	o_vref	= vref_reg;

	//  -------------------------------------------------------------------------------------
	//  生成给数据通道的场头快速翻转标志 o_headblank_flag
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_readout_flag) begin
			if(iv_vcount==iv_headblank_end) begin
				headblank_flag <= 1'b0;
			end
			else if(iv_vcount==iv_headblank_start) begin
				headblank_flag <= 1'b1;
			end
		end
		else begin
			headblank_flag <= 1'b0;
		end
	end
	assign	o_headblank_flag	= headblank_flag;

	//  -------------------------------------------------------------------------------------
	//  生成给数据通道的场尾快速翻转标志 o_tailblank_flag
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_readout_flag) begin
			if(iv_vcount==iv_tailblank_end) begin
				tailblank_flag <= 1'b0;
			end
			else if(iv_vcount==iv_tailblank_start) begin
				tailblank_flag <= 1'b1;
			end
		end
		else begin
			tailblank_flag	<=	1'b0;
		end
	end
	assign	o_tailblank_flag	= tailblank_flag;

	//  ===============================================================================================
	//  第三部分 ：输出o_vd、o_hd
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	i_ad_parm_valid 有效时vd拉低
	//  -------------------------------------------------------------------------------------
	always @ ( posedge clk )
	begin
		if(reset)
		ad_parm_valid_flag	<=	1'b0;
		else if(ad_parm_valid_cnt == `LINE_PERIOD)
		ad_parm_valid_flag	<=	1'b0;
		else if(i_ad_parm_valid)
		ad_parm_valid_flag	<=  1'b1;
	end

	//  -------------------------------------------------------------------------------------
	//	维持1个行周期: ad_parm_valid_cnt
	//  -------------------------------------------------------------------------------------

	always @ ( posedge clk )
	begin
		if(reset)
		ad_parm_valid_cnt	<=	`LINE_WD'b0;
		else if(ad_parm_valid_flag)
		ad_parm_valid_cnt	<=	ad_parm_valid_cnt + `LINE_WD'b1;
		else
		ad_parm_valid_cnt 	<=  `LINE_WD'b0;
	end

	//  -------------------------------------------------------------------------------------
	//  生成AD垂直同步标志
	//	i_ad_parm_valid有效时vd拉低
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_readout_flag) begin
			if(iv_vcount==iv_vd_falling) begin
				vd_reg	<= 1'b0;
			end
			else if(iv_vcount==iv_vd_rising) begin
				vd_reg	<= 1'b1;
			end
		end
		else begin
			vd_reg	<= 1'b1;
		end
	end
	assign o_vd = vd_reg &&  !ad_parm_valid_flag;

	//  -------------------------------------------------------------------------------------
	//	生成AD水平同步信号
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_readout_flag) begin
			if(iv_hcount==iv_hd_falling) begin
				hd_reg	<= 1'b0;
			end
			else if(iv_hcount==iv_hd_rising) begin
				hd_reg	<= 1'b1;
			end
		end
		else begin
			hd_reg	<= 1'b1;
		end
	end
	assign	o_hd	= hd_reg;

	//  ===============================================================================================
	//  第四部分 ：输出 o_xv
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	功能说明：生成正常行xv时序
	//	关键点：要按照CCD时序手册生成xv时序
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case (iv_hcount)
			XV_LINE_POS1	: xv_line	<= XV_LINE_VALUE1;
			XV_LINE_POS2	: xv_line	<= XV_LINE_VALUE2;
			XV_LINE_POS3	: xv_line	<= XV_LINE_VALUE3;
			XV_LINE_POS4	: xv_line	<= XV_LINE_VALUE4;
			XV_LINE_POS5	: xv_line	<= XV_LINE_VALUE5;
			XV_LINE_POS6	: xv_line	<= XV_LINE_VALUE6;
			XV_LINE_POS7	: xv_line	<= XV_LINE_VALUE7;
			XV_LINE_POS8	: xv_line	<= XV_LINE_VALUE8;
			default			: xv_line	<= xv_line;
		endcase
	end

	//  -------------------------------------------------------------------------------------
	//	功能说明：生成各阶段XV系列信号
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_xsg_flag) begin
			xv_reg	<= iv_xv_xsg;
		end
		else if(o_headblank_flag) begin
			xv_reg	<= iv_xv_headblank;
		end
		else if(o_tailblank_flag) begin
			xv_reg	<= iv_xv_tailblank;
		end
		else begin
			xv_reg	<= xv_line;
		end
	end
	assign	ov_xv	= xv_reg;

	//  ===============================================================================================
	//  第五部分：sub信号生成逻辑
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	功能说明：生成正常行sub标志
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(iv_hcount==iv_sub_rising) begin
			sub_line <= 1'b1;
		end
		else if(iv_hcount==iv_sub_falling) begin
			sub_line <= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	功能说明：输出 o_sub
	//	关键点：曝光、xsg阶段没有 o_sub
	//	BUG,ID2713，102us以下曝光时间精度超过1us.(102us以下曝光时间精度超过1us）)
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset)
		o_sub		<=	1'b1;
		else if(i_integration | ((iv_vcount != `FRAME_WD'd0) & i_xsg_flag))	//小曝光时，除第0行可以存在sub，其他xsg行的sub信号没有
		o_sub		<=	1'b1;
		else
		o_sub		<=	sub_line;
	end


endmodule