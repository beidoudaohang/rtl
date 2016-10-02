//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : dcm_python
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

module dcm_python # (
	parameter	DATA_WIDTH		= 10	//λ��
	)
	(
	input			clk_in		,
	input			dcm_reset	,
	output			clk0_out	,
	output			clk_fx_out	,
	output			locked
	);

	//	ref signals
	localparam	CLKFX_MULTIPLY	= DATA_WIDTH*2	;

	wire 		[7:0]  	status_int		;
	wire 				clkfb			;
	wire 				clk0			;
	wire 				clkfx			;




	//	ref ARCHITECTURE

	//  -------------------------------------------------------------------------------------
	//	dcm_python ����
	//  -------------------------------------------------------------------------------------
	DCM_SP # (
	.CLKDV_DIVIDE          (2.000				),
	.CLKFX_DIVIDE          (2					),
	.CLKFX_MULTIPLY        (CLKFX_MULTIPLY		),
	.CLKIN_DIVIDE_BY_2     ("FALSE"				),
	.CLKIN_PERIOD          (13.888				),
	.CLKOUT_PHASE_SHIFT    ("NONE"				),
	.CLK_FEEDBACK          ("1X"				),
	.DESKEW_ADJUST         ("SYSTEM_SYNCHRONOUS"),
	.PHASE_SHIFT           (0					),
	.STARTUP_WAIT          ("FALSE"				)
	)
	dcm_sp_inst (
	// Input clocks
	.CLKIN                 (clk_in	),
	.CLKFB                 (clkfb	),
	// Output clocks
	.CLK0                  (clk0	),
	.CLK90                 (),
	.CLK180                (),
	.CLK270                (),
	.CLK2X                 (),
	.CLK2X180              (),
	.CLKFX                 (clkfx	),
	.CLKFX180              (),
	.CLKDV                 (),
	// Ports for dynamic phase shift
	.PSCLK                 (1'b0	),
	.PSEN                  (1'b0	),
	.PSINCDEC              (1'b0	),
	.PSDONE                (),
	// Other control and status signals
	.LOCKED                (locked		),
	.STATUS                (status_int	),
	.RST                   (dcm_reset	),
	// Unused pin- tie low
	.DSSEN                 (1'b0		)
	);



	//  -------------------------------------------------------------------------------------
	//	ʱ��
	//  -------------------------------------------------------------------------------------
	BUFG clkf_buf (
	.I		(clk0	),
	.O		(clkfb	)
	);
	assign	clk0_out	= clkfb;

	BUFG clkout1_buf (
	.I		(clkfx		),
	.O		(clk_fx_out	)
	);



endmodule