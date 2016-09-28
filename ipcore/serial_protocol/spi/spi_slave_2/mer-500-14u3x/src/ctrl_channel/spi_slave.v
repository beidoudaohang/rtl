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

	//��bitλ����Ϊbyteλ��
	localparam	SPI_CMD_BYTE_LENGTH		= SPI_CMD_LENGTH/8;
	localparam	SPI_ADDR_BYTE_LENGTH	= SPI_ADDR_LENGTH/8;
	localparam	SPI_DATA_BYTE_LENGTH	= SPI_DATA_LENGTH/8;
	localparam	ONCE_CNT_WIDTH			= log2(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH+SPI_DATA_BYTE_LENGTH+1);
	localparam	CONTINUE_CNT_WIDTH		= log2(SPI_DATA_BYTE_LENGTH);

	//  ===============================================================================================
	//	ref ***����***
	//  ===============================================================================================
	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction


	wire									spi_clk_inv			;
	reg		[2:0]							sck_rising_cnt		= 3'b0;
	reg		[ONCE_CNT_WIDTH-1:0]			once_byte_cnt		= {ONCE_CNT_WIDTH{1'b0}};
	reg		[CONTINUE_CNT_WIDTH-1:0]		continue_byte_cnt	= {CONTINUE_CNT_WIDTH{1'b0}};
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
	//	ref ***����ʱ��***
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	ʱ�ӷ���
	//	-------------------------------------------------------------------------------------
	assign	spi_clk_inv	= !i_spi_clk;

	//  ===============================================================================================
	//	ref ***����mosi����***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	sck_rising_cnt ��spi clk�������ؼ���
	//	cs��Чʱ��cnt�����ۼӣ�0-7����ѭ��
	//  -------------------------------------------------------------------------------------
	always @ (posedge i_spi_clk or posedge i_spi_cs_n) begin
		if(i_spi_cs_n) begin
			sck_rising_cnt	<= 3'b0;
		end
		else begin
			sck_rising_cnt	<= sck_rising_cnt + 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	once_byte_cnt
	//	cs��Чʱ��ÿ8��sclk rising edge��������+1
	//	��cmd �� addr �׶μ���
	//  -------------------------------------------------------------------------------------
	always @ (posedge i_spi_clk or posedge i_spi_cs_n) begin
		if(i_spi_cs_n) begin
			once_byte_cnt	<= 'b0;
		end
		else begin
			if(sck_rising_cnt==3'd7) begin
				if(once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH+SPI_DATA_BYTE_LENGTH+1)) begin
					once_byte_cnt	<= once_byte_cnt;
				end
				else begin
					once_byte_cnt	<= once_byte_cnt + 1'b1;
				end
			end
		end
	end

	reg			once_cnt_over_flow	= 1'b0;
	always @ (posedge i_spi_clk or posedge i_spi_cs_n) begin
		if(i_spi_cs_n) begin
			once_cnt_over_flow	<= 1'b0;
		end
		else begin
			if(once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH+SPI_DATA_BYTE_LENGTH)) begin
				once_cnt_over_flow	<= 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	data_cnt
	//	cs��Чʱ��ÿ8��sclk rising edge��������+1
	//	��data�׶μ���
	//  -------------------------------------------------------------------------------------
	always @ (posedge i_spi_clk or posedge i_spi_cs_n) begin
		if(i_spi_cs_n) begin
			continue_byte_cnt	<= 'b0;
		end
		else begin
			if(sck_rising_cnt==3'd7) begin
				if(once_cnt_over_flow==1'b1) begin
					if(continue_byte_cnt==(SPI_DATA_BYTE_LENGTH-1)) begin
						continue_byte_cnt	<= 'b0;
					end
					else begin
						continue_byte_cnt	<= continue_byte_cnt + 1'b1;
					end
				end
				else begin
					continue_byte_cnt	<= 'b0;
				end
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	spi_data_shifter ������λ�Ĵ���������=�����ַ�����ݵ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge i_spi_clk or posedge i_spi_cs_n) begin
		if(i_spi_cs_n) begin
			spi_data_shifter	<= {SPI_SHFITER_LENGTH{1'b0}};
		end
		else begin
			spi_data_shifter	<= {spi_data_shifter[SPI_SHFITER_LENGTH-2:0],i_spi_mosi};
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
	always @ (posedge i_spi_clk or posedge i_spi_cs_n) begin
		if(i_spi_cs_n) begin
			cmd_wr	<= 1'b0;
			cmd_rd	<= 1'b0;
		end
		else begin
			if(sck_rising_cnt==3'd0 && once_byte_cnt==SPI_CMD_BYTE_LENGTH) begin
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
	always @ (posedge i_spi_clk) begin
		if(sck_rising_cnt==3'd7 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH-1)) begin
			addr_reg	<= {spi_data_shifter[SPI_ADDR_LENGTH-2:0],i_spi_mosi};
		end
		else if(cmd_wr==1'b1) begin
			if(once_cnt_over_flow==1'b1 && sck_rising_cnt==3'd0 && continue_byte_cnt==0) begin
				addr_reg	<= addr_reg + 1'b1;
			end
		end
		else if(cmd_rd==1'b1) begin
			if(sck_rising_cnt==3'd7 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH+SPI_DATA_BYTE_LENGTH-1)) begin
				addr_reg	<= addr_reg + 1'b1;
			end
			else if(once_cnt_over_flow==1'b1 && sck_rising_cnt==3'd7 && continue_byte_cnt==(SPI_DATA_BYTE_LENGTH-1)) begin
				addr_reg	<= addr_reg + 1'b1;
			end
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
	always @ (posedge i_spi_clk) begin
		if(sck_rising_cnt==3'd0 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH+SPI_DATA_BYTE_LENGTH)) begin
			wr_data_reg	<= spi_data_shifter[SPI_DATA_LENGTH-1:0];
		end
		else if(once_cnt_over_flow==1'b1 && sck_rising_cnt==3'd0 && continue_byte_cnt==0) begin
			wr_data_reg	<= spi_data_shifter[SPI_DATA_LENGTH-1:0];
		end
	end
	assign	ov_wr_data	= wr_data_reg;

	//  -------------------------------------------------------------------------------------
	//	wr en
	//	1.��spi������4�����ݵ�ʱ��дʹ��ȡ������ʱ����һ��spi�������յ�����ֽڵ�ʱ��
	//	2.��spi��д�����sck���������һ��ʱ��дʹ��=1
	//  -------------------------------------------------------------------------------------
	always @ (posedge i_spi_clk) begin
		if(sck_rising_cnt==4) begin
			wr_en	<= 1'b0;
		end
		else if(sck_rising_cnt==3'd0 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH+SPI_DATA_BYTE_LENGTH)) begin
			wr_en	<= cmd_wr;
		end
		else if(once_cnt_over_flow==1'b1 && sck_rising_cnt==3'd0 && continue_byte_cnt==0) begin
			wr_en	<= cmd_wr;
		end
	end
	assign	o_wr_en	= wr_en;

	//  ===============================================================================================
	//	ref ***����������***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	rd en
	//	1.cs=1ʱ����ʹ��=0
	//	2.��spi�Ƕ������sck��������ַʱ����ʹ��=1
	//  -------------------------------------------------------------------------------------
	always @ (posedge i_spi_clk) begin
		if(sck_rising_cnt==3) begin
			rd_en	<= 1'b0;
		end
		else if(sck_rising_cnt==3'd7 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH-1)) begin
			rd_en	<= cmd_rd;
		end
		else if(sck_rising_cnt==3'd7 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH+SPI_DATA_BYTE_LENGTH-1)) begin
			rd_en	<= cmd_rd;
		end
		else if(once_cnt_over_flow==1'b1 && sck_rising_cnt==3'd7 && continue_byte_cnt==(SPI_DATA_BYTE_LENGTH-1)) begin
			rd_en	<= cmd_rd;
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
	always @ (posedge spi_clk_inv) begin
		if((sck_rising_cnt==3'd0 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH))
		||(sck_rising_cnt==3'd0 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH+SPI_DATA_BYTE_LENGTH))
		||(once_cnt_over_flow==1'b1 && sck_rising_cnt==3'd0 && continue_byte_cnt==0)
		) begin

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
//		else if(rd_data_shift_ena) begin
		else begin
			rd_data_reg	<= {rd_data_reg[SPI_DATA_LENGTH-2:0],rd_data_reg[SPI_DATA_LENGTH-1]};
		end
	end

	//  -------------------------------------------------------------------------------------
	//	�����ݼĴ�����λʹ�ܣ�Ҳ��Ϊmiso����̬ʹ�ܱ�־
	//	1.��sck�����ؼ���Ϊ cmd + addr ʱ����sck���½��أ������ݼĴ�����λʹ�ܴ�
	//  -------------------------------------------------------------------------------------
	always @ (posedge spi_clk_inv or posedge i_spi_cs_n) begin
		if(i_spi_cs_n) begin
			rd_data_shift_ena	<= 1'b0;
		end
		//		else if(sck_rising_cnt==(SPI_CMD_LENGTH+SPI_ADDR_LENGTH) && cmd_rd==1'b1) begin
		else if(sck_rising_cnt==3'd0 && once_byte_cnt==(SPI_CMD_BYTE_LENGTH+SPI_ADDR_BYTE_LENGTH) && cmd_rd==1'b1) begin
			rd_data_shift_ena	<= 1'b1;
		end
	end

	//  ===============================================================================================
	//	ref ***����miso����***
	//  ===============================================================================================
	assign	o_spi_miso_data_en	= rd_data_shift_ena;
	assign	o_spi_miso_data		= rd_data_reg[SPI_DATA_LENGTH-1];

	//Ҫ�ڶ���ģ����������̬�߼�
	//	assign	o_spi_miso	= o_spi_miso_data_en ? o_spi_miso_data : 1'bz;







endmodule

