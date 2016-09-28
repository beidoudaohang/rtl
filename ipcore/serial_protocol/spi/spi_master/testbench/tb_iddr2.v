//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : tb_iddr2
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/9 13:38:52	:|  初始版本
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
//`include			"tb_iddr2_def.v"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module tb_iddr2 ();

	//	ref signals

	reg			clk		= 1'b0;
	wire		clk_180	;
	reg			reset	= 1'b0;
	reg			data_reg	= 1'b0;
	wire		ddr_q0	;
	wire		ddr_q1	;


	//	ref ARCHITECTURE


	IDDR2 # (
	.DDR_ALIGNMENT	("C1"	),	// Sets output alignment to "NONE", "C0" or "C1"
	.INIT_Q0		(1'b0	),	// Sets initial state of the Q0 output to 1'b0 or 1'b1
	.INIT_Q1		(1'b0	),	// Sets initial state of the Q1 output to 1'b0 or 1'b1
	.SRTYPE			("SYNC"	)	// Specifies "SYNC" or "ASYNC" set/reset
	) IDDR2_inst (
	.Q0				(ddr_q0		),	// 1-bit output captured with C0 clock
	.Q1				(ddr_q1		),	// 1-bit output captured with C1 clock
	.C0				(clk_180	),	// 1-bit clock input
	.C1				(clk		),	// 1-bit clock input
	.CE				(1'b1		),	// 1-bit clock enable input
	.D				(data_reg	),	// 1-bit DDR data input
	.R				(1'b0		),	// 1-bit reset input
	.S				(1'b0		)	// 1-bit set input
	);





	initial begin
		//$display($time, "Starting the Simulation...");
		//$monitor($time, "count1 is %d,count2 is %b,count3 is %h",cnt1,cnt2,cnt3);
		reset = 1'b1;
		#200
		reset = 1'b0;
		#10000
		$stop;

	end

	always #5 clk = ~clk;
	assign	clk_180	= !clk;

	always @ (posedge clk) begin
		data_reg	<= $random();
	end



	//generate vcd file
	//initial begin
	//$dumpfile("test.vcd");
	//$dumpvars(1,top_frame_buffer_inst);
	//end

	//for lattice simulation
	//GSR   GSR_INST (.GSR (1'b1)); //< global reset sig>
	//PUR   PUR_INST (.PUR (1'b1)); //<powerup reset sig>



endmodule
