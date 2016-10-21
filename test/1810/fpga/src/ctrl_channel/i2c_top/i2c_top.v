//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : i2c_ctrl
//  -- �����       : �ܽ�
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �ܽ�       :| 2015/10/20 16:43:05	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :i2c����ģ�飬��ģ��ֻ��ִ��д����
//					��ģ��:
//					1��trigger_cmd_ram���洢����ģʽ�£�����sensor�Ĵ����ĵ�ַ������
//					2��continuous_cmd_fifo����������ģʽ�´����µĲ���
//					3��i2c_ctrl��i2c�Ķ�д����ģ�飬ֻ֧�̶ֹ���16λ��ַ��16λ���ݣ�i2c������ַ�̶�Ϊ0x20
//					4��i2c_master_wb_top��i2c masterģ�飬��sensor�Ĵ����ĵ�ַ��������i2c��Э�鷢�͵�sensor
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------
module i2c_top # (
	parameter	I2C_MASTER_CLOCK_FREQ_KHZ	= 55000	,
	parameter	I2C_CLOCK_FREQ_KHZ			= 400
	)
	(
	input				reset				,//��λ�ź�
	input				clk					,//ʱ�ӣ�clk_pix,55MHz
	input				i_trigger_mode		,//�⴮ʱ����110MHz
	//trigger
	input				i_trigger			,//clk_pixʱ���򣬴����ź�
	//�������ýӿ�
	input		[ 4:0]	iv_i2c_ram_addr		,//clk_pixʱ����RAMд��ַ
	input		[15:0]	iv_i2c_cmd_addr		,//clk_pixʱ����RAM���ݵĸ�16bit������sensor�ڲ��Ĵ�����ַ
	input		[15:0]	iv_i2c_cmd_data		,//clk_pixʱ����RAM���ݵĵ�16bit������sensor�ڲ��Ĵ�������
	input				i_i2c_ram_wren		,//clk_pixʱ����RAMд�ź�
	//i2c�������ʼ����
	output				o_state_idle		,//clk_pixʱ����i2c״̬������
	output				o_trigger_start		,//clk_pixʱ����1-��ʾi2c��ʼ����
	//i2c�ź�
	input        		i_scl_pad			,//clk_pixʱ����scl�����ź�
	output       		o_scl_pad			,//clk_pixʱ����scl����ź�
	output       		o_scl_padoen		,//clk_pixʱ����scl���ʹ��
	input        		i_sda_pad			,//clk_pixʱ����sda�����ź�
	output       		o_sda_pad			,//clk_pixʱ����sda����ź�
	output       		o_sda_padoen		 //clk_pixʱ����sda���ʹ��
	);
	//  -------------------------------------------------------------------------------------
	//	��������
	//  -------------------------------------------------------------------------------------
	reg		[2:0]   trigger_mode;
	wire            trigger_mode_rise;
	wire            trigger_mode_fall;
	wire            fifo_reset  ;
	//�����ɼ�FIFO
	wire	[31:0]	w_fifo_data	;
	wire			w_fifo_wren	;
	wire			w_fifo_full	;
	wire			w_fifo_empty;
	wire			w_fifo_rden	;
	wire	[31:0]	w_fifo_q	;
	wire			w_fifo_rdy	;
	//�����ɼ�RAM
	wire	[4:0]	w_ram_addr	;
	wire	[31:0]	w_ram_data	;
	wire			w_ram_wren	;
	wire	[4:0]	w_ram_rdaddr;
	wire	[31:0]	w_ram_q		;
	//i2c_top����ź�
	wire	[2:0]	w_wb_adr	;
	wire	[7:0]	w_wb_wdat	;
	wire			w_wb_we		;
	wire			w_wb_stb	;
	wire			w_wb_cyc	;
	wire			w_done		;//1-��ʾ����һ���ֽ�����
	//  -------------------------------------------------------------------------------------
	//	RAM��FIFO�źſ���
	//  -------------------------------------------------------------------------------------
	assign	w_fifo_data	=	{iv_i2c_cmd_addr,iv_i2c_cmd_data};						//����ƴ��
	assign	w_fifo_wren	=	i_i2c_ram_wren & (!w_fifo_full) & (!trigger_mode[1]);	//������ģʽʱ��fifo��������д

	assign	w_ram_addr	=	iv_i2c_ram_addr;										//RAMд��ַ
	assign	w_ram_data	=	{iv_i2c_cmd_addr,iv_i2c_cmd_data};						//RAMд����
	assign	w_ram_wren	=	i_i2c_ram_wren ;										//RAMдʹ��

	assign	w_fifo_rdy	=	trigger_mode[1] ? 1'b0 : (!w_fifo_empty);				//����ģʽʱ��fifo��rdy�ź���0������ģʽ�Ż��ж�rdy�ź�

    //  -------------------------------------------------------------------------------------
	//	�л�������ģʽʱ����λFIFO
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
	    trigger_mode    <=  {trigger_mode[1:0],i_trigger_mode}	;
	end
	assign	trigger_mode_rise   =   (trigger_mode[2:1]==2'b01)	;//i_trigger_mode��������
	assign  trigger_mode_fall   =   (trigger_mode[2:1]==2'b10)	;//i_trigger_mode���½���
	assign  fifo_reset          =   trigger_mode_rise | reset	;//��i_trigger_mode�������ظ�λFIFO


	//  -------------------------------------------------------------------------------------
	//	RAM��������RAM������ʼ���ļ�
	//  -------------------------------------------------------------------------------------
	trigger_cmd_ram_w32d32 trigger_cmd_ram_w32d32_inst(
  	.clka				(clk				),
  	.addra				(w_ram_addr			),
  	.dina				(w_ram_data			),
  	.wea				(w_ram_wren			),
  	.clkb				(clk				),
  	.addrb				(w_ram_rdaddr		),
  	.doutb				(w_ram_q			)
	);

	//  -------------------------------------------------------------------------------------
	//	�����ɼ�ģʽFIFO����
	//  -------------------------------------------------------------------------------------
	continuous_cmd_fifo continuous_cmd_fifo_inst(
  	.rst				(fifo_reset         ),
  	.clk				(clk				),
  	.din				(w_fifo_data		),
  	.wr_en				(w_fifo_wren		),
  	.full				(w_fifo_full		),
  	.rd_en				(w_fifo_rden		),
  	.dout				(w_fifo_q			),
  	.empty				(w_fifo_empty		)
	);

	//  -------------------------------------------------------------------------------------
	//	i2c_ctrl����
	//  -------------------------------------------------------------------------------------
	i2c_ctrl i2c_ctrl_inst (
	.reset				(reset				),
	.clk				(clk				),
	//trigger
	.i_trigger			(i_trigger 			),
	//i_trigger_mode�½���
	.i_trigger_mode_fall(trigger_mode_fall	),
	//fifo�����ź�
	.o_fifo_rden		(w_fifo_rden		),
	.iv_fifo_q			(w_fifo_q			),
	.i_fifo_rdy			(w_fifo_rdy			),
	//ram�����ź�
	.ov_ram_addr		(w_ram_rdaddr		),
	.iv_ram_q			(w_ram_q			),
	//i2c master�����ź�
	.ov_wb_adr			(w_wb_adr			),
	.ov_wb_dat			(w_wb_wdat			),
	.o_wb_we			(w_wb_we			),
	.o_wb_stb			(w_wb_stb			),
	.o_wb_cyc			(w_wb_cyc			),
	.i_done				(w_done				),
	.o_state_idle		(o_state_idle		),
	.o_trigger_start	(o_trigger_start	)
	);

	//  -------------------------------------------------------------------------------------
	//	i2c_master_wb_top����
	//  -------------------------------------------------------------------------------------
	i2c_master_wb_top #(
	.I2C_MASTER_CLOCK_FREQ_KHZ	(I2C_MASTER_CLOCK_FREQ_KHZ	),
	.I2C_CLOCK_FREQ_KHZ			(I2C_CLOCK_FREQ_KHZ			)
	)
	i2c_master_wb_top_inst (
	.wb_clk_i					(clk						),
	.wb_rst_i					(reset						),
	.arst_i						(reset						),
	.wb_adr_i					(w_wb_adr					),
	.wb_dat_i					(w_wb_wdat					),
	.wb_dat_o					(							),
	.wb_we_i					(w_wb_we					),
	.wb_stb_i					(w_wb_stb					),
	.wb_cyc_i					(w_wb_cyc					),
	.wb_ack_o					(							),
	.wb_inta_o					(							),
	.done						(w_done						),
	.scl_pad_i					(i_scl_pad					),
	.scl_pad_o					(o_scl_pad					),
	.scl_padoen_o				(o_scl_padoen				),
	.sda_pad_i					(i_sda_pad					),
	.sda_pad_o					(o_sda_pad					),
	.sda_padoen_o				(o_sda_padoen				)
	);


endmodule
