//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : bfm_spi_cmd
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/9/24 9:14:45	:|  ��ʼ�汾
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

module bfm_spi_cmd ();

	//	ref signals



	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***���õ����Ĵ���***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	�� fpga id
	//	-------------------------------------------------------------------------------------
	task rd_fpga_id;
		begin
			//�� reg 0
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h181,9'h00,9'h00,9'h00,9'h00);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	д ���ظ�ʽ
	//	-------------------------------------------------------------------------------------
	task wr_pixel_format_mono8;
		begin
			//���� pixel format
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h33,9'h01,9'h08);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h34,9'h00,9'h01);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
		end
	endtask

	task wr_pixel_format_mono10;
		begin
			//���� pixel format
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h33,9'h01,9'h10);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h34,9'h00,9'h03);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
		end
	endtask

	task wr_pixel_format_mono12;
		begin
			//���� pixel format
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h33,9'h01,9'h10);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h34,9'h00,9'h05);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
		end
	endtask

	task wr_pixel_format_gr8;
		begin
			//���� pixel format
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h33,9'h01,9'h08);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h34,9'h00,9'h08);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
		end
	endtask

	task wr_pixel_format_gr10;
		begin
			//���� pixel format
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h33,9'h01,9'h10);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h34,9'h00,9'h0c);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();

		end
	endtask

	task wr_pixel_format_gr12;
		begin
			//���� pixel format
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h33,9'h01,9'h10);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h34,9'h00,9'h10);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();

		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	д payload size
	//	-------------------------------------------------------------------------------------
	task wr_payload_size;
		//		input	[63:0]	payload_size;
		input	[31:0]	payload_size;
		begin
			//���� payload size 64*64+52+32=4180=0x1054
			//			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h35,{1'b0,payload_size[63:56]},{1'b0,payload_size[55:48]});
			//			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			//			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h36,{1'b0,payload_size[47:40]},{1'b0,payload_size[39:32]});
			//			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h37,{1'b0,payload_size[31:24]},{1'b0,payload_size[23:16]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h38,{1'b0,payload_size[15:8]},{1'b0,payload_size[7:0]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	д roi
	//	-------------------------------------------------------------------------------------
	task wr_roi;
		input	[15:0]	roi_offset_x;
		input	[15:0]	roi_offset_y;
		input	[15:0]	roi_pic_width;
		input	[15:0]	roi_pic_height;
		begin
			//���� roi
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h40,{1'b0,roi_offset_x[15:8]},{1'b0,roi_offset_x[7:0]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h41,{1'b0,roi_offset_y[15:8]},{1'b0,roi_offset_y[7:0]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h42,{1'b0,roi_pic_width[15:8]},{1'b0,roi_pic_width[7:0]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h43,{1'b0,roi_pic_height[15:8]},{1'b0,roi_pic_height[7:0]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	д si transfer size
	//	-------------------------------------------------------------------------------------
	task wr_si_size;
		input	[31:0]	si_payload_transfer_size;
		input	[31:0]	si_payload_transfer_count;
		input	[31:0]	si_payload_final_transfer1_size;
		input	[31:0]	si_payload_final_transfer2_size;

		begin
			//����si
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'hb4,{1'b0,si_payload_transfer_size[31:24]},{1'b0,si_payload_transfer_size[23:16]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'hb5,{1'b0,si_payload_transfer_size[15:8]},{1'b0,si_payload_transfer_size[7:0]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'hb6,{1'b0,si_payload_transfer_count[31:24]},{1'b0,si_payload_transfer_count[23:16]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'hb7,{1'b0,si_payload_transfer_count[15:8]},{1'b0,si_payload_transfer_count[7:0]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'hb8,{1'b0,si_payload_final_transfer1_size[31:24]},{1'b0,si_payload_final_transfer1_size[23:16]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'hb9,{1'b0,si_payload_final_transfer1_size[15:8]},{1'b0,si_payload_final_transfer1_size[7:0]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'hba,{1'b0,si_payload_final_transfer2_size[31:24]},{1'b0,si_payload_final_transfer2_size[23:16]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'hbb,{1'b0,si_payload_final_transfer2_size[15:8]},{1'b0,si_payload_final_transfer2_size[7:0]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	д dna
	//	-------------------------------------------------------------------------------------
	task wr_dna;
		input	[63:0]	dna_value;
		begin
			//����dna
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h01,9'h64,{1'b0,dna_value[63:56]},{1'b0,dna_value[55:48]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h01,9'h65,{1'b0,dna_value[47:40]},{1'b0,dna_value[39:32]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h01,9'h66,{1'b0,dna_value[31:24]},{1'b0,dna_value[23:16]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h01,9'h67,{1'b0,dna_value[15:8]},{1'b0,dna_value[7:0]});
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	д ������Ч
	//	-------------------------------------------------------------------------------------
	task wr_group_en;
		begin
			//���ó����Ч
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h20,9'h00,9'h01);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	д ����ģʽ
	//	-------------------------------------------------------------------------------------
	task wr_trigger_mode_on;
		begin
			//���� trigger mode
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h50,9'h00,9'h01);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
		end
	endtask

	task wr_trigger_mode_off;
		begin
			//���� trigger mode
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h50,9'h00,9'h00);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	д ��������
	//	-------------------------------------------------------------------------------------
	task wr_trigger_soft;
		begin
			//���� trigger soft
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h52,9'h00,9'h01);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	д sensor��ʼ�����
	//	-------------------------------------------------------------------------------------
	task wr_sensor_init_done;
		begin
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h3b,9'h00,9'h01);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
		end
	endtask



	//	===============================================================================================
	//	ref ***���õ�������***
	//	���������Ĵ���
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	���ÿ�������
	//	-------------------------------------------------------------------------------------
	task set_transit_on;
		begin
			//���� ����
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h30,9'h00,9'h01);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h32,9'h00,9'h01);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
		end
	endtask

	//	-------------------------------------------------------------------------------------
	//	����ͣ������
	//	-------------------------------------------------------------------------------------
	task set_transit_off;
		begin
			//���� ͣ��
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h32,9'h00,9'h00);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
			driver_spi_master.bfm_spi_master.spi_wr_cmd_5byte(9'h180,9'h00,9'h30,9'h00,9'h00);
			driver_spi_master.bfm_spi_master.spi_rd_cmd_5byte();
		end
	endtask



endmodule
