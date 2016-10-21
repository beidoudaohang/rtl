//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : sensor_reset
//  -- 设计者       : 周金剑
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 周金剑       :| 2016/03/25 17:47:33	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  :
//
//              2)  :
//
//              3)  :
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module sensor_reset # (
	parameter			CLOCL_FREQ_MHZ				= 40	,	//时钟的频率，Mhz
	parameter			SENSOR_HARD_RESET_TIME		= 1000	,	//senosr硬件复位时间，us
	parameter			SENSOR_CLK_DELAY_TIME		= 200	,	//硬件复位结束之后，sensor时钟的等待时间，us
	parameter			SENSOR_INITIAL_DONE_TIME	= 2950		//硬件复位结束之后的等待时间，us
	)
	(
	//输入信号
	input					clk							,	//输入时钟
	input					reset						,	//复位信号
	input					i_sensor_reset				,	//固件给的复位命令
	//输出信号
	output					o_sensor_reset_n			,	//输出的sensor硬件复位信号
	output					o_clk_sensor_ouput_reset	,	//时钟输出使能
	output	reg				o_sensor_initial_done			//输出的sensor内部初始化完成信号
	);

	//	-------------------------------------------------------------------------------------
	//	本地常数
	//	-------------------------------------------------------------------------------------
	localparam	SENSOR_HARD_RESET_CNT			=	CLOCL_FREQ_MHZ*SENSOR_HARD_RESET_TIME;
	localparam	SENSOR_CLK_DELAY_CNT			=	CLOCL_FREQ_MHZ*SENSOR_CLK_DELAY_TIME;
	localparam	SENSOR_INITIAL_DONE_CNT			=	CLOCL_FREQ_MHZ*SENSOR_INITIAL_DONE_TIME;
	localparam	SENSOR_HARD_RESET_CNT_WIDTH		=	log2(SENSOR_HARD_RESET_CNT+1);
	localparam	SENSOR_CLK_DELAY_CNT_WIDTH		=	log2(SENSOR_CLK_DELAY_CNT+1);
	localparam	SENSOR_INITIAL_DONE_CNT_WIDTH	=	log2(SENSOR_INITIAL_DONE_CNT+1);

	//	-------------------------------------------------------------------------------------
	//	参数定义
	//	-------------------------------------------------------------------------------------
	reg	[SENSOR_HARD_RESET_CNT_WIDTH-1:0]			reset_cnt_sensor		= 0;
	reg	[SENSOR_CLK_DELAY_CNT_WIDTH-1:0]			clk_delay_cnt			= 0;
	reg	[SENSOR_INITIAL_DONE_CNT_WIDTH-1:0]			internal_init_cnt		= 0;


	//	-------------------------------------------------------------------------------------
	//	取对数，上取整
	//	-------------------------------------------------------------------------------------
	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction




	//  -------------------------------------------------------------------------------------
	//	硬件复位
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_sensor_reset==1'b1 || reset==1'b1) begin
			reset_cnt_sensor	<= 'b0;
		end
		else if(reset_cnt_sensor == SENSOR_HARD_RESET_CNT-1'b1) begin
			reset_cnt_sensor	<= reset_cnt_sensor;
		end
		else begin
			reset_cnt_sensor	<= reset_cnt_sensor + 1'b1;
		end
	end
	assign	o_sensor_reset_n	= (reset_cnt_sensor==SENSOR_HARD_RESET_CNT-1'b1);

	//  -------------------------------------------------------------------------------------
	//	硬件复位
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(o_sensor_reset_n==1'b0) begin
			clk_delay_cnt	<= 'b0;
		end
		else if(clk_delay_cnt == SENSOR_CLK_DELAY_CNT-1'b1) begin
			clk_delay_cnt	<= clk_delay_cnt;
		end
		else begin
			clk_delay_cnt	<= clk_delay_cnt + 1'b1;
		end
	end
	assign	o_clk_sensor_ouput_reset	= (clk_delay_cnt == SENSOR_CLK_DELAY_CNT-1'b1) ? 1'b0 : 1'b1;

	//  -------------------------------------------------------------------------------------
	//	sensor在硬件复位结束后，必须等待至少2950us后，固件才能开始配置sensor
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(o_sensor_reset_n==1'b0)begin
			internal_init_cnt		<=	16'd0;							//internal_init_cnt清零，计数器开始计数
			o_sensor_initial_done	<=	1'b0;
		end
		else if(internal_init_cnt == SENSOR_INITIAL_DONE_CNT-1)begin		//计数到2950us时停止计数
			internal_init_cnt		<=	internal_init_cnt;				//计数器保持不变
			o_sensor_initial_done	<=	1'b1;							//sensor内部初始化完成
		end
		else begin
			internal_init_cnt		<=	internal_init_cnt	+	1'd1;	//未计到10800时，计数器每个时钟自加1
			o_sensor_initial_done	<=	1'b0;							//sensor内部初始化未完成
		end
	end

endmodule
