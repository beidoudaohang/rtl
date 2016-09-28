//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : spi_slave
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/3/2 17:55:38	:|  ��ʼ�汾
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

module spi_slave # (
	parameter			SPI_CMD_LENGTH		= 8			,	//spi ����ĳ���
	parameter			SPI_CMD_WR			= 8'h80		,	//spi д����
	parameter			SPI_CMD_RD			= 8'h81		,	//spi ������
	parameter			SPI_ADDR_LENGTH		= 16		,	//spi ��ַ�ĳ���
	parameter			SPI_DATA_LENGTH		= 16			//spi ���ݵĳ���
	)
	(
	input							clk_spi_sample		,	//spi ����ʱ��
	//spiʱ����
	input							i_spi_clk			,	//spiʱ�ӣ������ز����� ʱ�ӵĸߵ�ƽ��������� ��ʱ������ ��3��
	input							i_spi_cs_n			,	//spiƬѡ������Ч
	input							i_spi_mosi			,	//spi��������
	output							o_spi_miso_data		,	//spi�������
	output							o_spi_miso_data_en	,	//spi miso��Ч�źţ�0-spi����mosi ��̬ 1-�������
	//����������ݣ���ʱ����
	output							o_wr_en				,	//дʹ��
	output							o_rd_en				,	//��ʹ��
	output							o_cmd_is_rd			,	//�������
	output	[SPI_ADDR_LENGTH-1:0]	ov_addr				,	//��д��ַ������
	output	[SPI_DATA_LENGTH-1:0]	ov_wr_data			,	//д����
	input							i_pix_sel			,	//pixʱ����ѡ��
	input	[SPI_DATA_LENGTH-1:0]	iv_pix_rd_data		,	//pixʱ����Ķ�����
	input							i_frame_buf_sel		,	//frame bufʱ����ѡ��
	input	[SPI_DATA_LENGTH-1:0]	iv_frame_buf_rd_data,	//frame bufʱ����Ķ�����
	input							i_gpif_sel			,	//gpifʱ����ѡ��
	input	[SPI_DATA_LENGTH-1:0]	iv_gpif_rd_data		,	//gpifʱ����Ķ�����
	input							i_osc_bufg_sel		,	//40MHzʱ����ѡ��
	input	[SPI_DATA_LENGTH-1:0]	iv_osc_bufg_rd_data	,	//40MHzʱ����Ķ�����
	input							i_fix_sel			,	//�̶���ƽ��ѡ��
	input	[SPI_DATA_LENGTH-1:0]	iv_fix_rd_data			//�̶���ƽ�Ķ�����
	);

	//	ref signals

	//�� cmd length�� addr length�� data length��ѡһ�����ĳ�������Ϊshifter�ĳ���
	localparam	SPI_SHFITER_LENGTH	= (SPI_CMD_LENGTH>=SPI_ADDR_LENGTH && SPI_CMD_LENGTH>=SPI_DATA_LENGTH) ? SPI_CMD_LENGTH :
	((SPI_ADDR_LENGTH>=SPI_CMD_LENGTH && SPI_ADDR_LENGTH>=SPI_DATA_LENGTH) ? SPI_ADDR_LENGTH :
	SPI_DATA_LENGTH);



	reg		[1:0]							spi_cs_shift		= 2'b00;
	reg		[2:0]							spi_clk_shift		= 3'b000;
	wire									spi_clk_rise		;
	wire									spi_clk_fall		;
	reg		[1:0]							spi_mosi_shift		= 2'b00;
	reg		[6:0]							sck_rising_cnt		= 7'b0;
	reg		[SPI_SHFITER_LENGTH-1:0]		spi_data_shifter	= {SPI_SHFITER_LENGTH{1'b0}};
	reg										cmd_wr				= 1'b0;
	reg										cmd_rd				= 1'b0;
	reg		[SPI_ADDR_LENGTH-1:0]			addr_reg			= {SPI_ADDR_LENGTH{1'b0}};
	reg		[SPI_DATA_LENGTH-1:0]			wr_data_reg			= {SPI_DATA_LENGTH{1'b0}};
	reg										wr_en				= 1'b0;
	reg		[5:0]							wr_en_extend		= 6'b0;
	reg										rd_en				= 1'b0;
	reg		[SPI_DATA_LENGTH-1:0]			rd_data_reg			= {SPI_DATA_LENGTH{1'b0}};
	reg										rd_data_shift_ena	= 1'b0;


	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***��spi ���� ����***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	spi cs ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_spi_sample) begin
		spi_cs_shift	<= {spi_cs_shift[0],i_spi_cs_n};
	end

	//  -------------------------------------------------------------------------------------
	//	spi clk ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_spi_sample) begin
		spi_clk_shift	<= {spi_clk_shift[1:0],i_spi_clk};
	end
	assign	spi_clk_rise	= (spi_clk_shift[2:1]==2'b01) ? 1'b1 : 1'b0;
	assign	spi_clk_fall	= (spi_clk_shift[2:1]==2'b10) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	spi mosi ���β���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_spi_sample) begin
		spi_mosi_shift	<= {spi_mosi_shift[0],i_spi_mosi};
	end

	//  ===============================================================================================
	//	ref ***����mosi����***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	sck_rising_cnt ��spi clk�������ؼ���
	//	sck�ĸ�������������spi������״̬
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_spi_sample) begin
		if(spi_cs_shift[1]) begin
			sck_rising_cnt	<= 7'b0;
		end
		else if(spi_clk_rise) begin
			if(sck_rising_cnt==7'd40) begin
				sck_rising_cnt	<= sck_rising_cnt;
			end
			else begin
				sck_rising_cnt	<= sck_rising_cnt + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	spi_data_shifter ������λ�Ĵ���������=�����ַ�����ݵ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_spi_sample) begin
		if(spi_cs_shift[1]) begin
			spi_data_shifter	<= {SPI_SHFITER_LENGTH{1'b0}};
		end
		else begin
			if(spi_clk_rise) begin
				spi_data_shifter	<= {spi_data_shifter[SPI_SHFITER_LENGTH-2:0],spi_mosi_shift[1]};
			end
		end
	end

	//  ===============================================================================================
	//	ref ***���� �����ַ***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	cmd_wr cmd_rd ��������Ĵ���
	//	1.��cs=1ʱ������Ĵ�������
	//	2.��cs=0ʱ��sck������=�����ʱ���������=д�����д������Ч
	//	3.��cs=0ʱ��sck������=�����ʱ���������=��������������Ч
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_spi_sample) begin
		if(spi_cs_shift[1]) begin
			cmd_wr	<= 1'b0;
			cmd_rd	<= 1'b0;
		end
		else begin
			if(sck_rising_cnt==SPI_CMD_LENGTH) begin
				case(spi_data_shifter[SPI_CMD_LENGTH-1:0])
					SPI_CMD_WR : begin
						cmd_wr	<= 1'b1;
						cmd_rd	<= 1'b0;
					end
					SPI_CMD_RD : begin
						cmd_wr	<= 1'b0;
						cmd_rd	<= 1'b1;
					end
					default : begin
						cmd_wr	<= 1'b0;
						cmd_rd	<= 1'b0;
					end
				endcase
			end
		end
	end
	assign	o_cmd_is_rd	= cmd_rd;
	
	//  -------------------------------------------------------------------------------------
	//	addr_reg ��д���ã��ڽ������ַ֮������
	//	1.��sck��������ַʱ����ȡ����ַ
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_spi_sample) begin
		if(sck_rising_cnt==SPI_CMD_LENGTH+SPI_ADDR_LENGTH-1 && spi_clk_rise==1'b1) begin
			addr_reg	<= {spi_data_shifter[SPI_ADDR_LENGTH-2:0],spi_mosi_shift[1]};
		end
	end
	assign	ov_addr	= addr_reg;

	//  ===============================================================================================
	//	ref ***д��������***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	wr data
	//	1.��sck���������ʱ����ȡ��д����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_spi_sample) begin
		if(sck_rising_cnt==SPI_CMD_LENGTH+SPI_ADDR_LENGTH+SPI_DATA_LENGTH) begin
			wr_data_reg	<= spi_data_shifter[SPI_DATA_LENGTH-1:0];
		end
	end
	assign	ov_wr_data	= wr_data_reg;

	//  -------------------------------------------------------------------------------------
	//	wr en
	//	1.��spi��д�����sck���������һ��ʱ��дʹ��=1
	//	2.��дչ���źŵ����λ=1ʱ��дʹ��=0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_spi_sample) begin
		if(cmd_wr) begin
			if(sck_rising_cnt==SPI_CMD_LENGTH+SPI_ADDR_LENGTH+SPI_DATA_LENGTH) begin
				wr_en	<= 1'b1;
			end
		end
		else if(wr_en_extend[5]) begin
			wr_en	<= 1'b0;
		end
	end
	assign	o_wr_en	= wr_en;

	//  -------------------------------------------------------------------------------------
	//	wr en extend
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_spi_sample) begin
		if(!wr_en) begin
			wr_en_extend	<= 6'b0;
		end
		else begin
			if(wr_en_extend[5]) begin
				wr_en_extend	<= wr_en_extend;
			end
			else begin
				wr_en_extend	<= wr_en_extend + 1'b1;
			end
		end
	end

	//  ===============================================================================================
	//	ref ***����������***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	rd en
	//	1.cs=1ʱ����ʹ��=0
	//	2.��spi�Ƕ������sck��������ַʱ����ʹ��=1
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_spi_sample) begin
		if(spi_cs_shift[1]) begin
			rd_en	<= 1'b0;
		end
		else if(cmd_rd) begin
			if(sck_rising_cnt==SPI_CMD_LENGTH+SPI_ADDR_LENGTH-1 && spi_clk_rise==1'b1) begin
				rd_en	<= 1'b1;
			end
		end
	end
	assign	o_rd_en	= rd_en;

	//  -------------------------------------------------------------------------------------
	//	ѡ������ļĴ�������
	//	1.��sck�����ؼ���Ϊ cmd + addr ʱ����sck���½��أ��ӼĴ���ģ���ȡ����
	//	2.�Ĵ���ģ����������ݶ��Ǹ���ʱ����ģ���spi����ʱ����������첽�ģ���Ҫ��֤�ڲ���ʱ�������Ѿ��ȶ�����һ��Ҫ��ʱ��Լ����֤
	//	3.����ѡ���������ȼ��ģ���Ϊһ���Ĵ������ܴ����ڶ��ʱ������
	//	4.����������λʹ�ܴ򿪣���sck�½���ʱ�������ݼĴ�����λ
	//
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_spi_sample) begin
		if(sck_rising_cnt==SPI_CMD_LENGTH+SPI_ADDR_LENGTH && spi_clk_fall==1'b1) begin
			if(i_fix_sel) begin
				rd_data_reg	<= iv_fix_rd_data	;
			end
			else if(i_pix_sel) begin
				rd_data_reg	<= iv_pix_rd_data	;
			end
			else if(i_gpif_sel) begin
				rd_data_reg	<= iv_gpif_rd_data	;
			end
			else if(i_frame_buf_sel) begin
				rd_data_reg	<= iv_frame_buf_rd_data	;
			end
			else if(i_osc_bufg_sel) begin
				rd_data_reg	<= iv_osc_bufg_rd_data	;
			end
			else begin
				rd_data_reg	<= {SPI_DATA_LENGTH{1'b0}}	;
			end
		end
		else if(rd_data_shift_ena) begin
			if(spi_clk_fall) begin
				rd_data_reg	<= {rd_data_reg[SPI_DATA_LENGTH-2:0],rd_data_reg[SPI_DATA_LENGTH-1]};
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	�����ݼĴ�����λʹ�ܣ�Ҳ��Ϊmiso����̬ʹ�ܱ�־
	//	1.��sck�����ؼ���Ϊ cmd + addr ʱ����sck���½��أ������ݼĴ�����λʹ�ܴ�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_spi_sample) begin
		if(spi_cs_shift[1]) begin
			rd_data_shift_ena	<= 1'b0;
		end
		else if(sck_rising_cnt==SPI_CMD_LENGTH+SPI_ADDR_LENGTH && spi_clk_fall==1'b1) begin
			rd_data_shift_ena	<= 1'b1;
		end
	end

	//  ===============================================================================================
	//	ref ***����miso����***
	//  ===============================================================================================
	assign	o_spi_miso_data_en	= rd_data_shift_ena&cmd_rd;
	assign	o_spi_miso_data		= rd_data_reg[SPI_DATA_LENGTH-1];
	
	//Ҫ�ڶ���ģ����������̬�߼�
	//	assign	o_spi_miso	= o_spi_miso_data_en ? o_spi_miso_data : 1'bz;










endmodule


