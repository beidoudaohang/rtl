//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : tb_sine
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/5/21 13:42:13	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//`include			"tb_sine_def.v"
//���浥λ/����
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
