//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : dcm_sonyimx
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/5/12 14:40:14	:|  ��ʼ�汾
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
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module dcm_sonyimx # (
	parameter	DATA_WIDTH		= 10		,	//λ��
	parameter	CLKIN_PERIOD 	= 27.778		//���� ns
	)
	(
	input			clk_in		,
	input			dcm_reset	,
	output			clk0_out	,
	output			clk1_out	,
	output			locked
	);

	//	ref signals
	localparam	CLKFX_MULTIPLY	= 2*DATA_WIDTH	;	//2*sensorwidth

	wire 		[7:0]  	status_int		;
	wire 				clkfb			;
	wire 				clk0			;
	wire				clk0_buf		;
	wire 				clk1			;
	wire				clk1_buf		;
	wire 				clkfx			;
	wire				clkfx_180		;




	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	dcm_sonyimx ����
	//  -------------------------------------------------------------------------------------

   PLL_BASE #(
      .BANDWIDTH("OPTIMIZED"),             // "HIGH", "LOW" or "OPTIMIZED"
      .CLKFBOUT_MULT(16),      // Multiply value for all CLKOUT clock outputs (1-64)
      .CLKFBOUT_PHASE(0.0),                // Phase offset in degrees of the clock feedback output (0.0-360.0).
      .CLKIN_PERIOD(CLKIN_PERIOD),         // Input clock period in ns to ps resolution (i.e. 33.333 is 30
                                           // MHz).
      // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT# clock output (1-128)
      .CLKOUT0_DIVIDE(1),
      .CLKOUT1_DIVIDE(DATA_WIDTH),		//
      .CLKOUT2_DIVIDE(1),
      .CLKOUT3_DIVIDE(1),
      .CLKOUT4_DIVIDE(1),
      .CLKOUT5_DIVIDE(1),
      // CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT# clock output (0.01-0.99).
      .CLKOUT0_DUTY_CYCLE(0.5),
      .CLKOUT1_DUTY_CYCLE(0.5),
      .CLKOUT2_DUTY_CYCLE(0.5),
      .CLKOUT3_DUTY_CYCLE(0.5),
      .CLKOUT4_DUTY_CYCLE(0.5),
      .CLKOUT5_DUTY_CYCLE(0.5),
      // CLKOUT0_PHASE - CLKOUT5_PHASE: Output phase relationship for CLKOUT# clock output (-360.0-360.0).
      .CLKOUT0_PHASE(0.0),
      .CLKOUT1_PHASE(0.0),
      .CLKOUT2_PHASE(0.0),
      .CLKOUT3_PHASE(0.0),
      .CLKOUT4_PHASE(0.0),
      .CLKOUT5_PHASE(0.0),
      .CLK_FEEDBACK("CLKFBOUT"),           // Clock source to drive CLKFBIN ("CLKFBOUT" or "CLKOUT0")
      .COMPENSATION("SYSTEM_SYNCHRONOUS"), // "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "EXTERNAL"
      .DIVCLK_DIVIDE(1),                   // Division value for all output clocks (1-52)
      .REF_JITTER(0.1),                    // Reference Clock Jitter in UI (0.000-0.999).
      .RESET_ON_LOSS_OF_LOCK("FALSE")      // Must be set to FALSE
   )
   PLL_BASE_inst (
      .CLKFBOUT(clkfb), // 1-bit output: PLL_BASE feedback output
      // CLKOUT0 - CLKOUT5: 1-bit (each) output: Clock outputs
      .CLKOUT0(clk0),
      .CLKOUT1(clk1),
      .CLKOUT2(),
      .CLKOUT3(),
      .CLKOUT4(),
      .CLKOUT5(),
      .LOCKED(locked),     	// 1-bit output: PLL_BASE lock status output
      .CLKFBIN(clkfb),   	// 1-bit input: Feedback clock input
      .CLKIN(clk_in),       // 1-bit input: Clock input
      .RST(dcm_reset)   	// 1-bit input: Reset input
   );



	//  -------------------------------------------------------------------------------------
	//	ʱ��
	//  -------------------------------------------------------------------------------------
	BUFG clkf_buf (
	.I		(clk1	),
	.O		(clk1_buf	)
	);
	assign	clk1_out	= clk1_buf;

	BUFG clkout1_buf (
	.I		(clk0		),
	.O		(clk0_out	)
	);



endmodule
