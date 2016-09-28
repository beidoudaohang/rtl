//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : frame_line_pattern
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2013/5/24 10:08:24	:|  初始版本
//  -- 邢海涛       :| 2014/6/9 14:52:56	:|  将参数改为端口，方便调试的时候改变帧率
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :	产生 fval 和 lval 时序
//              1)  : 采用parameter的定义方式而非define
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//		宏定义说明如下：
//
//																				|<--iv_frame_hide	  ->|
//					_____________________________________________________________						______
//	fval	________|															|_______________________|
//							_________		_________		   	_________
//	lval	________________|		|_______|		|____****___|		|________________________________
//
//					|<-	  ->|		|<-	  ->|<-   ->|					|<-   ->|
//						|				|		|							|
//				iv_front_porch 			|		|							|
//								iv_line_hide	|							|
//											iv_width					iv_back_porch

//-------------------------------------------------------------------------------------------------
//仿真单位/精度
//-------------------------------------------------------------------------------------------------

module frame_line_pattern # (
	parameter			FVAL_LVAL_ALIGN		= "FALSE"	//"TRUE" - fval 与 lval 之间的距离固定为3个时钟。"FALSE" - fval 与 lval 之间的距离自由设定
	)
	(
	//系统输入
	input				clk							,	//时钟
	input				reset						,	//复位
	//控制输入
	input				i_pause_en					,	//1:暂停，立刻暂停 0:恢复
	input				i_continue_lval				,	//1:消隐的时候也有行信号输出，0:消隐的时候没有行信号输出
	input	[15:0]		iv_width					,	//行有效的像素个数，行宽最大64k
	input	[15:0]		iv_line_hide				,	//行消隐的像素个数，行消隐最大64k
	input	[15:0]		iv_height					,	//一帧中的行数，行数最多64k
	input	[15:0]		iv_frame_hide				,	//帧消隐的行数，行数最多64k
	input	[15:0]		iv_front_porch				,	//前沿，fval上升沿和lval上升沿之间的距离，前沿后沿之后不能超过行消隐
	input	[15:0]		iv_back_porch				,	//后沿，fval下降沿和lval下降沿之间的距离
	//输出
	output				o_fval						,	//场信号
	output				o_lval							//行信号
	);

	//ref signals

	wire	[15:0]		wv_front_porch				;
	wire	[15:0]		wv_back_porch				;
	reg		[16:0]		allpix_cnt_per_line 		= 17'b0	;	//一行中所有的pix，包括消隐期间的。最大值是128k个pix，足够了
	reg		[16:0]		line_cnt 					= 17'b0	;	//行计数器
	reg					fval_reg					= 1'b0	;	//场信号
	reg					lval_reg					= 1'b0	;	//行信号
	reg					fval_reg1					= 1'b0	;	//场信号
	reg					lval_reg1					= 1'b0	;	//行信号


	//ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***准备过程***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	如果定义了 FVAL_LVAL_ALIGN ，则前沿和后沿都保持为3个
	//	-------------------------------------------------------------------------------------
	generate
		if(FVAL_LVAL_ALIGN=="TRUE") begin
			assign	wv_front_porch	= 16'h3;
			assign	wv_back_porch	= 16'h3;
		end
		else begin
			assign	wv_front_porch	= iv_front_porch;
			assign	wv_back_porch	= iv_back_porch;
		end
	endgenerate

	//	===============================================================================================
	//	ref ***计算过程***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	allpix_cnt_per_line
	//	1.一行中所有pix的计数器，包括行消隐
	//	2.当暂停的时候，不会累加
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			allpix_cnt_per_line	<=17'b0;
		end
		else begin
			if(!i_pause_en) begin
				if(allpix_cnt_per_line==(iv_width+iv_line_hide-1)) begin
					allpix_cnt_per_line	<= 17'b0;
				end
				else begin
					allpix_cnt_per_line	<= allpix_cnt_per_line + 1'b1;
				end
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	line_cnt
	//	1.行个数计数器，场消隐的时候，也是按照行计数的
	//	2.当暂停的时候，不会累加
	//	3.当不暂停的时候，在计数到一行的最大值时
	//	--当line_cnt计数到最大值时，清零
	//	--否则，累加
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			line_cnt	<= 16'b0;
		end
		else begin
			if(!i_pause_en) begin
				if(allpix_cnt_per_line==(iv_width+iv_line_hide-1)) begin
					if(line_cnt==(iv_height+iv_frame_hide-1)) begin
						line_cnt	<= 17'b0;
					end
					else begin
						line_cnt	<= line_cnt + 1'b1;
					end
				end
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	fval_reg
	//	1.场信号
	//	2.当暂停的时候，保持
	//	3.当不暂停的时候
	//	--当line_cnt计数到行消隐时，如果allpix_cnt_per_line达到前沿的时候，场有效=1
	//	--当line_cnt计数到0时，如果allpix_cnt_per_line达到后沿的时候，场有效=0
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			fval_reg	<= 1'b0;
		end
		else begin
			if(!i_pause_en) begin
				if(line_cnt==iv_frame_hide) begin
					if(allpix_cnt_per_line==(iv_line_hide-wv_front_porch-1)) begin
						fval_reg	<= 1'b1;
					end
				end
				else if(line_cnt==17'b0) begin
					if(allpix_cnt_per_line==(wv_back_porch-1)) begin
						fval_reg	<= 1'b0;
					end
				end
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	lval_reg
	//	1.行信号
	//	2.当暂停的时候，保持
	//	3.当不暂停的时候
	//	--当allpix_cnt_per_line计数到行消隐时，行有效=1
	//	--当allpix_cnt_per_line计数到一行结尾时，行有效=0
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			lval_reg	<= 1'b0;
		end
		else begin
			if(!i_pause_en) begin
				if(allpix_cnt_per_line==(iv_line_hide-1)) begin
					lval_reg	<= 1'b1;
				end
				else if(allpix_cnt_per_line==(iv_width+iv_line_hide-1)) begin
					lval_reg	<= 1'b0;
				end
			end
		end
	end

	//  ===============================================================================================
	//	ref ***输出***
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	fval打拍
	//	1.lval需要打拍，因此fval要跟随
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			fval_reg1	<= 1'b0;
		end
		else begin
			fval_reg1	<= fval_reg;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	lval处理
	//	1.当复位或者pause的时候，不能输出lval
	//	2.当连续fval的时候，在场消隐阶段要输出lval
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset==1'b1 || i_pause_en==1'b1) begin
			lval_reg1	<= 1'b0;
		end
		else begin
			if(i_continue_lval) begin
				lval_reg1	<= lval_reg;
			end
			else begin
				if(fval_reg) begin
					lval_reg1	<= lval_reg;
				end
				else begin
					lval_reg1	<= 1'b0;
				end
			end

		end
	end

	//	-------------------------------------------------------------------------------------
	//	输出行场信号
	//	-------------------------------------------------------------------------------------
	assign	o_fval		= fval_reg1;
	assign	o_lval		= lval_reg1;


endmodule
