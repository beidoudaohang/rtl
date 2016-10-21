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
//  -- �ܽ�       :| 2015/10/20 13:26:32	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module  i2c_ctrl
	(
	input				reset		    	,//clk_pixʱ���򣬸�λ�ź�
	input				clk			    	,//ʱ�ӣ�clk_pix��55MHz
	//trigger
	input				i_trigger	    	,//clk_pixʱ���򣬴����źţ�����1�����ڵĸߵ�ƽ
	//trigger_mode�½���
	input				i_trigger_mode_fall	,//clk_pixʱ����trigger_mode�½���
	//fifo�����ź�
	output	reg			o_fifo_rden	    	,//clk_pixʱ����FIFO���ź�
	input		[31:0]	iv_fifo_q	    	,//clk_pixʱ����FIFO���
	input				i_fifo_rdy	    	,//clk_pixʱ����FIFO�ǿ�ʱ���ź�Ϊ1����ʱΪ0
	//ram�����ź�
	output	reg	[4:0]	ov_ram_addr	    	,//clk_pixʱ����RAM����ַ
	input		[31:0]	iv_ram_q	    	,//clk_pixʱ����RAM���

	//i2c master�����ź�
	output	reg	[2:0]	ov_wb_adr	    	,//clk_pixʱ����i2c�ڲ��Ĵ�����ַ
	output	reg	[7:0]	ov_wb_dat	    	,//clk_pixʱ����i2c�ڲ��Ĵ�����д������
	output	reg			o_wb_we		    	,//clk_pixʱ����i2c�ڲ��Ĵ���дʹ��
	output				o_wb_stb	    	,//clk_pixʱ���򣬹̶����1
	output				o_wb_cyc	    	,//clk_pixʱ���򣬹̶����1
	input				i_done          	,//clk_pixʱ����i2c������ɱ�־��1��ɣ�0δ���
	output				o_state_idle		,//clk_pixʱ����i2c״̬������
	output	reg			o_trigger_start		 //clk_pixʱ����i2c���ʼ����
	);

	//  ===============================================================================================
	//	 ref ***��������***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ref ״̬������
	//  -------------------------------------------------------------------------------------
	localparam	[2:0]	IDLE	=	3'd0;//����״̬
	localparam	[2:0]	RD_RAM	=	3'd1;//��ȡRAM���i2c����
	localparam	[2:0]	RD_FIFO	=	3'd2;//��ȡFIFO���i2c����
	localparam	[2:0]	I2C_WR_0=	3'd3;//����slave������ַ
	localparam	[2:0]	I2C_WR_1=	3'd4;//���������ڲ���ַ��8bit
	localparam	[2:0]	I2C_WR_2=	3'd5;//���������ڲ���ַ��8bit
	localparam	[2:0]	I2C_WR_3=	3'd6;//�������ݸ�8bit
	localparam	[2:0]	I2C_WR_4=	3'd7;//�������ݵ�8bit
	reg			[2:0]	current_state	;
	reg			[2:0]	next_state		;
	//  -------------------------------------------------------------------------------------
	//	ref ��������
	//  -------------------------------------------------------------------------------------
	reg			[15:0]	fs_reset_cnt	;//״̬����λ��������������0x8000�����596us
	wire				fs_reset		;//״̬����λ�ź�

	reg			[31:0]	fifo_q_reg		;//FIFO������棬��ֹi2c���������ݸı�

	reg			[2:0]	cnt				;//������
	reg					cnt_ena			;//������ʹ�ܣ�1-���Լ�����0-���ܼ���
	reg					trigger_status	;//����״̬��־��1-���ڴ���״̬��0-���ڴ���״̬
	reg			[7:0]	ov_wb_adr_0		;//
	reg			[7:0]	ov_wb_dat_0		;//
	reg			[7:0]	ov_wb_adr_1		;//
	reg			[7:0]	ov_wb_dat_1		;//


	//  -------------------------------------------------------------------------------------
	//	ref �����ֵ
	//  -------------------------------------------------------------------------------------
	assign	o_wb_stb		=1;
	assign	o_wb_cyc		=1;
	assign	o_state_idle	=(current_state==3'd0);
	//  -------------------------------------------------------------------------------------
	//	ref ���״̬����״̬����IDLE�⣬ͣ��������״̬ʱ�䳬��596us(0x8000)����ת��IDLE��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset)
			fs_reset_cnt	<=	16'd0;
		else if(current_state==IDLE)
			fs_reset_cnt	<=	16'd0;
		else if(current_state==next_state)begin
			if(fs_reset_cnt[15])
				fs_reset_cnt	<=	16'd0;
			else
				fs_reset_cnt	<=	fs_reset_cnt	+	1'd1;
		end
		else
			fs_reset_cnt	<=	16'd0;
	end
	assign	fs_reset	=	fs_reset_cnt[15];
	//  ===============================================================================================
	//	ref ***״̬��***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ʱ���߼�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset | fs_reset)
			current_state	<=	IDLE;
		else
			current_state	<=	next_state;
	end
	//  -------------------------------------------------------------------------------------
	//	����߼�
	//  -------------------------------------------------------------------------------------
	always @ (*)begin
		case(current_state)
			IDLE	:begin
				if(i_trigger)
					next_state	=	RD_RAM;
				else if(i_trigger_mode_fall)
					next_state	=	RD_RAM;
				else if(i_fifo_rdy)
					next_state	=	RD_FIFO;
				else
					next_state	=	IDLE;
			end
			RD_RAM	:begin
				next_state	=	I2C_WR_0;
				if(ov_ram_addr==5'd18)
					next_state	=	IDLE;
				else
					next_state	=	I2C_WR_0;
			end
			RD_FIFO	:begin
				next_state	=	I2C_WR_0;
			end
			//��ʼi2c���ݵķ��ͣ��ȷ���ʼλ
			//����slave������ַ��0x6e
			I2C_WR_0:begin
				if(i_done)
					next_state	=	I2C_WR_1;
				else
					next_state	=	I2C_WR_0;
			end
			//����slave�����ڲ���ַ��8bit
			I2C_WR_1:begin
				if(i_done)
					next_state	=	I2C_WR_2;
				else
					next_state	=	I2C_WR_1;
			end
			//����slave�����ڲ���ַ��8bit
			I2C_WR_2:begin
				if(i_done)
					next_state	=	I2C_WR_3;
				else
					next_state	=	I2C_WR_2;
			end
			//����slave�������ݸ�8bit
			I2C_WR_3:begin
				if(i_done)
					next_state	=	I2C_WR_4;
				else
					next_state	=	I2C_WR_3;
			end
			//����slave�������ݵ�8bit
			I2C_WR_4:begin
				if(i_done)begin
					if(trigger_status)
						next_state	=	RD_RAM;
					else
						next_state	=	IDLE;
				end
				else
					next_state	=	I2C_WR_4;
			end
			default:next_state	=	IDLE;
		endcase
	end

	//  -------------------------------------------------------------------------------------
	//	ref ״̬������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset)begin
			o_fifo_rden	<=	1'b0;
			ov_ram_addr	<=	5'd0;
			cnt_ena		<=	1'b0;
		end
		else begin
			case(current_state)
				IDLE	:begin
					cnt_ena			<=	1'b0;
					ov_ram_addr		<=	5'd0;
					trigger_status	<=	1'b0;
					if(i_trigger)
						o_fifo_rden	<=	1'b0;
					else if(i_fifo_rdy)
						o_fifo_rden	<=	1'b1;
					else
						o_fifo_rden	<=	1'b0;
				end
				RD_RAM	:begin
					cnt_ena			<=	1'b0;
					trigger_status	<=	1'b1;	//trigger_status=1��ʾ���ڴ���ģʽ��
					if(ov_ram_addr==5'd18)begin
						ov_ram_addr			<=	5'd0;
					end
					else begin
						ov_ram_addr			<=	ov_ram_addr	+	1'd1;
					end
				end
				RD_FIFO	:begin
					cnt_ena		<=	1'b0;
					o_fifo_rden	<=	1'b0;
				end
				//��ʼi2c���ݵķ��ͣ��ȷ���ʼλ
				//����slave������ַ��0x6e
				I2C_WR_0:begin
					cnt_ena		<=	1'b1;
					fifo_q_reg	<=	iv_fifo_q;
					ov_wb_adr_0	<=	8'h03;//transmit register address
					ov_wb_dat_0	<=	8'h6e;//transmit data
					ov_wb_adr_1	<=	8'h04;//command register address
					ov_wb_dat_1	<=	8'h90;//command
				end
				//����slave�����ڲ���ַ��8bit
				I2C_WR_1:begin
					cnt_ena		<=	1'b1;
					if(trigger_status)begin
						ov_wb_adr_0	<=	8'h03;//transmit register address
						ov_wb_dat_0	<=	iv_ram_q[31:24];//transmit data
						ov_wb_adr_1	<=	8'h04;//command register address
						ov_wb_dat_1	<=	8'h10;//command
					end
					else begin
						ov_wb_adr_0	<=	8'h03;//transmit register address
						ov_wb_dat_0	<=	fifo_q_reg[31:24];//transmit data
						ov_wb_adr_1	<=	8'h04;//command register address
						ov_wb_dat_1	<=	8'h10;//command
					end
				end
				//����slave�����ڲ���ַ��8bit
				I2C_WR_2:begin
					cnt_ena		<=	1'b1;
					if(trigger_status)begin
						ov_wb_adr_0	<=	8'h03;//transmit register address
						ov_wb_dat_0	<=	iv_ram_q[23:16];//transmit data
						ov_wb_adr_1	<=	8'h04;//command register address
						ov_wb_dat_1	<=	8'h10;//command
					end
					else begin
						ov_wb_adr_0	<=	8'h03;//transmit register address
						ov_wb_dat_0	<=	fifo_q_reg[23:16];//transmit data
						ov_wb_adr_1	<=	8'h04;//command register address
						ov_wb_dat_1	<=	8'h10;//command
					end
				end
				//����slave�������ݸ�8bit
				I2C_WR_3:begin
					cnt_ena		<=	1'b1;
					if(trigger_status)begin
						ov_wb_adr_0	<=	8'h03;//transmit register address
						if(ov_ram_addr==5'd17)//��ַ17���͵����ݹ̶�Ϊ0x8006.17��ַ�ǿ����޸ĵģ�������ģʽ�¿��ɣ��ǻ��޸�����Ĵ�����
							ov_wb_dat_0	<=	8'h80;//transmit data��set restart bit to 1
						else
							ov_wb_dat_0	<=	iv_ram_q[15:8];//transmit data
						ov_wb_adr_1	<=	8'h04;//command register address
						ov_wb_dat_1	<=	8'h10;//command
					end
					else begin
						ov_wb_adr_0	<=	8'h03;//transmit register address
						ov_wb_dat_0	<=	fifo_q_reg[15:8];//transmit data
						ov_wb_adr_1	<=	8'h04;//command register address
						ov_wb_dat_1	<=	8'h10;//command
					end
				end
				//����slave�����ڲ���ַ��8bit
				//���ݷ�����ɺ���һ��ֹͣλ
				I2C_WR_4:begin
					cnt_ena		<=	1'b1;
					if(trigger_status)begin
						ov_wb_adr_0	<=	8'h03;//transmit register address
						if(ov_ram_addr==5'd17)//��ַ17���͵����ݹ̶�Ϊ0x8006
							ov_wb_dat_0	<=	8'h06;//transmit data��set restart bit to 1
						else
							ov_wb_dat_0	<=	iv_ram_q[7:0];//transmit data
						ov_wb_adr_1	<=	8'h04;//command register address
						ov_wb_dat_1	<=	8'h50;//command
					end
					else begin
						ov_wb_adr_0	<=	8'h03;//transmit register address
						ov_wb_dat_0	<=	fifo_q_reg[7:0];//transmit data
						ov_wb_adr_1	<=	8'h04;//command register address
						ov_wb_dat_1	<=	8'h50;//command
					end
				end
			endcase
		end
	end
	//  -------------------------------------------------------------------------------------
	//	ref ��������ģʽi2c�������ɱ�־
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset)
			o_trigger_start	<=	1'b0;
		else begin
			if(i_trigger==1'b1)
				o_trigger_start	<=	1'b1;
			else if(ov_ram_addr==5'd16)		//17��ַ��Ҫдrestart�Ĵ������˴���ʼ��һ���Ĵ�����
				o_trigger_start	<=	1'b0;
		end
	end
	//  ===============================================================================================
	//	ref ����i2c��������ݵ�д����
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ref ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset)
			cnt	<=	0;
		else if(cnt_ena)begin
			if(i_done)
				cnt	<=	0;
			else if(cnt	< 7)
				cnt	<=	cnt	+	1'd1;
		end
		else
			cnt	<=	0;
	end
	//  -------------------------------------------------------------------------------------
	//	ref ����i2c������ݺ�дʹ��
	//  -------------------------------------------------------------------------------------
	always @ (*)begin
		case(cnt)
			1,2:begin
				ov_wb_adr	<=	ov_wb_adr_0;//transmit register address
				ov_wb_dat	<=	ov_wb_dat_0;//transmit data
				o_wb_we		<=	1'b1;
			end
			5,6:begin
				ov_wb_adr	<=	ov_wb_adr_1;//command register address
				ov_wb_dat	<=	ov_wb_dat_1;//command
				o_wb_we		<=	1'b1;
			end
			default:begin
				ov_wb_adr	<=	3'h7;
				ov_wb_dat	<=	8'haf;
				o_wb_we		<=	1'b0;
			end
		endcase
	end

endmodule