
//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : ccd_xsg.v
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  --修改记录  :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛      	:| 2015/12/23 10:51:52	:|  初始版本，在mv_ccd上修改
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

module ccd_xsg # (
	parameter	XV_WIDTH		= 4		,	//XV宽度
	parameter	XSG_WIDTH		= 1			//XSG宽度
	)
	(
	input								clk					,   //时钟
	input								reset				,	//复位，高有效
	input								i_xsg_flag			,	//xsg开始标志
	input		[`EXP_WD-1:0]			iv_xsg_width		,	//XSG宽度
	input		[`EXP_WD-1:0]			iv_exp_xsg_reg		,	//
	output								o_exposure_end		,	//
	output		[XSG_WIDTH-1:0]			ov_xsg		        ,	//XSG阶段XSG信号
	output		[XV_WIDTH-1:0]			ov_xv_xsg		    	//XSG阶段XV信号
	);



	reg			[  			 `XSG_LINE_WD - 1 : 0]  xsg_count			;

	//  ===============================================================================================
	//  第二部分：XSG逻辑
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  功能说明：产生帧翻转阶段计数器 xsg_count
	//  -------------------------------------------------------------------------------------

	always @ ( posedge clk )
	begin
		if(reset)
		begin
			xsg_count <= `XSG_LINE_WD'b0;
		end
		else if(i_xsg_flag)
		begin
			xsg_count <= xsg_count + `XSG_LINE_WD'b1;
		end
		else
		begin
			xsg_count <= `XSG_LINE_WD'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	bug修正
	//	1.当xsg的宽度+1=行周期倍数时，iv_exp_xsg_reg==xsg_count的时刻，i_xsg_flag却是低电平，导致无法输出o_exposure_end
	//	2.将判断条件改为((iv_exp_xsg_reg-1) <= xsg_count)，当xsg的宽度+1=行周期倍数时，也可以输出o_exposure_end
	//	-------------------------------------------------------------------------------------
	//		assign o_exposure_end 	= 	(iv_exp_xsg_reg == xsg_count) && i_xsg_flag;
	assign o_exposure_end 	= 	((iv_exp_xsg_reg-1) <= xsg_count) && i_xsg_flag;


	always @ (posedge clk) begin
		if(reset) begin
			ov_xv_xsg	<= `XV_XSG_DEFAULT;
		end
		else if(i_xsg_flag==1'b1 && xsg_count==0) begin
			ov_xv_xsg	<= `V_XSG_VALUE1;
		end
		else if(xsg_count==(iv_exp_xsg_reg - iv_xsg_width + `XV_XSG_POSITION1)) begin
			ov_xv_xsg	<= `V_XSG_VALUE2;
		end
	end

	always @ (posedge clk) begin
		if(reset) begin
			ov_xsg	<= `XSG_VALUE2;
		end
		else if(xsg_count==(iv_exp_xsg_reg - iv_xsg_width + `XSG1_RISING)) begin
			ov_xsg	<= `XSG_VALUE1;
		end
		else if(xsg_count==(iv_exp_xsg_reg - iv_xsg_width + `XSG1_FALLING)) begin
			ov_xsg	<= `XSG_VALUE2;
		end
	end


endmodule