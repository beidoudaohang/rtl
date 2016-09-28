//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : tb_sine
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/5/21 13:42:13	:|  初始版本
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
//`include			"tb_sine_def.v"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module tb_sine ();

	//	ref signals

	reg		clk					= 1'b0;
	reg		[9:0]	address		= 10'b0;
	wire	[12:0]	ov_data_out	;

	//	ref ARCHITECTURE


	top_sine top_sine_inst (
	.clk			(clk			),
	.address		(address		),
	.ov_data_out	(ov_data_out	)
	);



	initial begin
		//$display($time, "Starting the Simulation...");
		//$monitor($time, "count1 is %d,count2 is %b,count3 is %h",cnt1,cnt2,cnt3);

		#10000
		$stop;

	end

	always #5 clk = ~clk;

	always @ (posedge clk) begin
		if(address == 10'd631) begin
			address	<= 10'h0;
		end
		else begin
			address	<= address + 1'b1;
		end
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
