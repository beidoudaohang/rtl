//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : testcase_5
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/4/10 16:50:28	:|  ��ʼ�汾
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
//`timescale 1ns/1ps
`timescale 1ns/100ps
//-------------------------------------------------------------------------------------------------

module testcase_5 ();

	//	ref signals
	//	===============================================================================================
	//	--ref parameter
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	TESTCASE
	//	-------------------------------------------------------------------------------------
	parameter	TESTCASE_NUM			= "testcase_5"			;	//����ģ����Ҫʹ���ַ���
	//	-------------------------------------------------------------------------------------
	//	spi master parameter
	//	-------------------------------------------------------------------------------------
	parameter				SPI_FIRST_DATA	= "MSB"	;	//"MSB" or "LSB"
	parameter				SPI_CS_POL		= "LOW"	;	//"HIGH" or "LOW" ��cs��Чʱ�ĵ�ƽ
	parameter				SPI_LEAD_TIME	= 1		;	//��ʼʱ��CS �� CLK �ľ��룬��λ��ʱ�����ڣ���ѡ 1 2 3
	parameter				SPI_LAG_TIME	= 1		;	//����ʱ��CS �� CLK �ľ��룬��λ��ʱ�����ڣ���ѡ 1 2 3

	//	-------------------------------------------------------------------------------------
	//	dut paramter
	//	-------------------------------------------------------------------------------------
	parameter				WB_OFFSET_WIDTH			= 12		;	//��ƽ��ģ��ƫ��λ�üĴ������
	parameter				WB_GAIN_WIDTH			= 11		;	//��ƽ��ģ������Ĵ������
	parameter				WB_STATIS_WIDTH			= 31		;	//��ƽ��ģ��ͳ��ֵ���
	parameter				GREY_OFFSET_WIDTH		= 12		;	//�Ҷ�ͳ��ģ��ƫ��λ�üĴ���
	parameter				GREY_STATIS_WIDTH		= 48		;	//�Ҷ�ͳ��ģ��ͳ��ֵ���
	parameter				TRIG_FILTER_WIDTH		= 19		;	//�����ź��˲�ģ��Ĵ������
	parameter				TRIG_DELAY_WIDTH		= 28		;	//�����ź���ʱģ��Ĵ������
	parameter				LED_CTRL_WIDTH			= 5			;	//LED CTRL �Ĵ������
	parameter				SHORT_REG_WD			= 16		;	//�̼Ĵ���λ��
	parameter				REG_WD					= 32		;	//�Ĵ���λ��
	parameter				LONG_REG_WD				= 64		;	//���Ĵ���λ��
	parameter				BUF_DEPTH_WD			= 4			;	//֡�����λ��,�������֧��8֡��ȣ���һλ��λλ
	parameter				REG_INIT_VALUE			= "TRUE"	;	//�Ĵ����Ƿ��г�ʼֵ

	//	-------------------------------------------------------------------------------------
	//	testcase parameter
	//	-------------------------------------------------------------------------------------
	parameter	CLK_PERIOD_FIFO			= 10	;	//100MHz
	parameter	CLK_PERIOD_SPI			= 10	;	//100MHz
	parameter	CLK_PERIOD_OSCBUFG		= 25	;	//40MHz
	parameter	CLK_PERIOD_PIX			= 14	;	//71MHz
	parameter	CLK_PERIOD_GPIF			= 10	;	//100MHz

	//	===============================================================================================
	//	--ref signal
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	reg wire
	//	-------------------------------------------------------------------------------------
	reg			spi_master_clk_fifo		= 1'b0;
	reg			spi_master_spi_clk		= 1'b0;
	reg			spi_master_reset_fifo	= 1'b0;
	reg			reset_osc_bufg			= 1'b0;
	reg			reset_pix				= 1'b0;
	reg			reset_frame_buf			= 1'b0;
	reg			reset_gpif				= 1'b0;
	reg			clk_osc_bufg			= 1'b0;
	reg			clk_pix					= 1'b0;
	reg			clk_frame_buf			= 1'b0;
	reg			clk_gpif				= 1'b0;
	wire		spi_master_i_spi_miso	;

	//	-------------------------------------------------------------------------------------
	//	harness �������ź�
	//	-------------------------------------------------------------------------------------
	reg								i_fval	= 1'b0;
	reg								i_sensor_reset_done	= 1'b0;
	reg		[3:0]					iv_line_status	= 4'b0;
	reg								i_full_frame_state	= 1'b0;
	reg		[1:0]					iv_interrupt_state	= 2'b0;
	reg		[WB_STATIS_WIDTH-1:0]	iv_wb_statis_r	= 'b0;
	reg		[WB_STATIS_WIDTH-1:0]	iv_wb_statis_g	= 'b0;
	reg		[WB_STATIS_WIDTH-1:0]	iv_wb_statis_b	= 'b0;
	reg		[WB_OFFSET_WIDTH-1:0]	iv_wb_offset_width	= 'b0;
	reg		[WB_OFFSET_WIDTH-1:0]	iv_wb_offset_height	= 'b0;
	reg		[GREY_STATIS_WIDTH-1:0]	iv_grey_statis_sum		= 'b0;
	reg		[GREY_OFFSET_WIDTH-1:0]	iv_grey_offset_width	= 'b0;
	reg		[GREY_OFFSET_WIDTH-1:0]	iv_grey_offset_height	= 'b0;
	reg								i_ddr_init_done	= 1'b0;
	reg								i_ddr_error	= 1'b0;



	//	ref ARCHITECTURE
	//	===============================================================================================
	//	ref ***tb ��ģ�鼤��***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	ʱ�Ӹ�λ
	//	-------------------------------------------------------------------------------------
	always	#(CLK_PERIOD_FIFO/2.0)	spi_master_clk_fifo		= !spi_master_clk_fifo;
	always	#(CLK_PERIOD_SPI/2.0)	spi_master_spi_clk		= !spi_master_spi_clk;

	always	#(CLK_PERIOD_OSCBUFG/2.0)	clk_osc_bufg		= !clk_osc_bufg;
	always	#(CLK_PERIOD_PIX/2.0)		clk_pix				= !clk_pix;
	always	#(CLK_PERIOD_GPIF/2.0)		clk_frame_buf		= !clk_frame_buf;
	always	#(CLK_PERIOD_GPIF/2.0)		clk_gpif			= !clk_gpif;

	initial begin
		spi_master_reset_fifo	= 1'b1;
		reset_osc_bufg			= 1'b1;
		reset_pix				= 1'b1;
		reset_frame_buf			= 1'b1;
		reset_gpif				= 1'b1;
		#200;
		spi_master_reset_fifo	= 1'b0;
		reset_osc_bufg			= 1'b0;
		reset_pix				= 1'b0;
		reset_frame_buf			= 1'b0;
		reset_gpif				= 1'b0;
	end

	//	-------------------------------------------------------------------------------------
	//	spi master ����
	//	-------------------------------------------------------------------------------------
	assign	spi_master_i_spi_miso	= harness.o_spi_miso;

	//	-------------------------------------------------------------------------------------
	//	--ref ����ʱ��
	//	-------------------------------------------------------------------------------------
	initial begin
		//$display("** ");
		#30000
		$stop;
	end

	//	===============================================================================================
	//	ref ***����bfm task***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	--ref spi master д����
	//	-------------------------------------------------------------------------------------
	initial begin
		//�� reg 0
		driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h181,9'h00,9'h00,9'h00,9'h00);
		@(posedge driver_spi_master.o_spi_cs);
		repeat(10) @ (posedge spi_master_spi_clk);
		//д reg 55
		driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h55,9'hab,9'h56);
		@(posedge driver_spi_master.o_spi_cs);
		repeat(10) @ (posedge spi_master_spi_clk);
		//�� reg 55
		driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h181,9'h00,9'h55,9'h00,9'h00);
		@(posedge driver_spi_master.o_spi_cs);
		repeat(10) @ (posedge spi_master_spi_clk);
		//д reg b4
		driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'hb4,9'hd8,9'h36);
		@(posedge driver_spi_master.o_spi_cs);
		repeat(10) @ (posedge spi_master_spi_clk);
		//�� reg b4
		driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h181,9'h00,9'hb4,9'hd7,9'h90);
		@(posedge driver_spi_master.o_spi_cs);
		repeat(10) @ (posedge spi_master_spi_clk);
		//д reg 40
		driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h40,9'h48,9'h21);
		@(posedge driver_spi_master.o_spi_cs);
		repeat(10) @ (posedge spi_master_spi_clk);
		//�� reg 40
		driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h181,9'h00,9'h40,9'hd7,9'h90);
		@(posedge driver_spi_master.o_spi_cs);
		repeat(10) @ (posedge spi_master_spi_clk);
		//д reg 164
		driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h01,9'h64,9'h74,9'h88);
		@(posedge driver_spi_master.o_spi_cs);
		repeat(10) @ (posedge spi_master_spi_clk);
		//�� reg 164
		driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h181,9'h01,9'h64,9'hd7,9'h90);
		@(posedge driver_spi_master.o_spi_cs);
		repeat(10) @ (posedge spi_master_spi_clk);

	end

	//	-------------------------------------------------------------------------------------
	//	--ref spi master ������
	//	-------------------------------------------------------------------------------------
	initial begin
		forever begin
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
		end
	end



endmodule
