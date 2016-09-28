//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : u3_interface
//  -- �����       : ��ǿ
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- ��ǿ         :| 2014/11/28 17:40:36	:|  ���ݼ���Ԥ������
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module	u3_interface # (
	parameter								DATA_WD      		=32		,		//GPIF���ݿ��
	parameter								REG_WD 				=32		,		//�Ĵ���λ��
//	parameter								DMA_SIZE			=14'H2000		//DMA SIZE��С
	parameter								DMA_SIZE			=14'H1000		//DMA SIZE��С
	)

	(
	//  ===============================================================================================
	//  ��һ���֣�ʱ�Ӹ�λ�ź�
	//  ===============================================================================================

	input									clk							,		//u3�ӿں�framebuffer���ʱ��,��o_clk_usb_pclkͬƵ����ͬ��
	input									reset						,		//��λ�źţ�clk_gpifʱ���򣬸���Ч
	//  ===============================================================================================
	//  �ڶ����֣������������ź�
	//  ===============================================================================================

	input									i_data_valid				,		//֡���������������Ч�źţ�clk_gpifʱ���򣬸���Ч
	input		[DATA_WD-1:0]				iv_data						,		//֡�������32λ���ݣ�clk_gpifʱ����
	input									i_framebuffer_empty			,		//framebuffer���FIFO�ձ�־���ߵ�ƽ��Ч��clk_gpifʱ����,
	output									o_fifo_rd					,		//��ȡ֡����FIFO�źţ�clk_gpifʱ����,��i_data_valid�źŹ�ָͬʾ������Ч

	//  ===============================================================================================
	//  �������֣����ƼĴ���
	//  ===============================================================================================
	input		[REG_WD-1:0]				iv_payload_size				,		//clkʱ�����źţ�paylod��С,4�ֽ�Ϊ��λ������ͨ����������ֽ�Ϊ��λ��ֵ����Ҫ����4
	input									i_chunkmodeactive			,		//clkʱ�����źţ�chunk�ܿ��أ�chunk����Ӱ��leader��trailer�Ĵ�С��ͨ���ж�chunk���ؿ���֪��leader��trailer����
	input		[REG_WD-1:0]				iv_transfer_count			,		//�������ݿ����
	input		[REG_WD-1:0]				iv_transfer_size			,		//�������ݿ��С
	input		[REG_WD-1:0]				iv_transfer1_size			,       //transfer1��С
	input		[REG_WD-1:0]				iv_transfer2_size			,       //transfer2��С

	//  ===============================================================================================
	//  ���Ĳ��֣�GPIF�ӿ��ź�
	//  ===============================================================================================

	input									i_usb_flagb					,		//�첽ʱ����USB���źţ�������32k�ֽ����ݺ�3��ʱ�ӻ����ͣ��л�DMA��ַ���־ָʾ��ǰFIFO״̬�������ǰFIFO��û������FLAGB�����ߣ����PC��������ǰFIFO��û�ж������ñ�־���ܳ�ʱ������
	output		[1:0]						ov_usb_fifoaddr				,		//clk_gpifʱ����,GPIF �̵߳�ַ 2bit����ַ�л�˳��Ҫ�͹̼�����һ�£�ĿǰԼ��Ϊ2'b00,2'b11�л�
	output		[1:0]						ov_usb_fifoaddr_reg			,		//clk_gpifʱ����,GPIF �̵߳�ַ 2bit����ַ�л�˳��Ҫ�͹̼�����һ�£�ĿǰԼ��Ϊ2'b00,2'b11�л� �м�ֵ
	output									o_usb_slwr_n				,		//clk_gpifʱ����,GPIF д�ź�
	output		[DATA_WD-1:0]				ov_usb_data					,		//clk_gpifʱ����,GPIF �����ź�
	output									o_usb_pktend_n				,		//clk_gpifʱ����,GPIF �������ź�
	output									o_usb_pktend_n_for_test		,		//GPIF �������źţ��������������
	output									o_usb_wr_for_led					//GPIF д�ź� - ��led_ctrlģ��

	);

	wire									w_leader_flag				;
	wire									w_trailer_flag              ;
	wire									w_payload_flag              ;
	wire									w_change_flag              	;
	wire		[REG_WD-1:0]				wv_packet_size              ;

	//  ===============================================================================================
	//  u3_transfer����
	//  ===============================================================================================
	u3_transfer # (
	.DATA_WD      				(DATA_WD      		),	//GPIF���ݿ��
	.REG_WD 					(REG_WD 			),	//�Ĵ���λ��
	.DMA_SIZE					(DMA_SIZE			)	//DMA SIZE��С
	)
	u3_transfer_inst (
	.clk						(clk				),	//u3�ӿں�framebuffer���ʱ��,clk_usb_pclk
	.reset						(reset				),	//��λ�źţ�clk_usb_pclkʱ���򣬸���Ч
	.o_fifo_rd					(o_fifo_rd			),	//��ȡ֡����FIFO�źţ�clk_gpifʱ����,��i_data_valid�źŹ�ָͬʾ������Ч��framebuffer��ģ���ʹ�ܣ�����Ч
	.i_data_valid				(i_data_valid		),	//֡���������������Ч�źţ�clk_usb_pclkʱ���򣬸���Ч
	.iv_data					(iv_data			),	//֡�������32λ���ݣ�clk_usb_pclkʱ����
	.i_framebuffer_empty		(i_framebuffer_empty),	//���FIFO�ձ�־�������ݶ��룬clk_usb_pclkʱ����
	.i_leader_flag				(w_leader_flag		),	//leader����־,clk_usb_pclkʱ����
	.i_trailer_flag				(w_trailer_flag		),	//trailer����־,clk_usb_pclkʱ����
	.i_payload_flag				(w_payload_flag		),	//payload����־,clk_usb_pclkʱ����
	.o_change_flag				(w_change_flag		),	//leader��payload��trailer���л���־��ÿ����������ɺ��л�,�����ڿ��
	.iv_packet_size				(wv_packet_size		),	//��ǰ����Ӧ����������С�����ڶ���framebuffer�е����ݰ���leader+payload+trailer���̼���Ϊ64λ��FPGA�ڲ�ֻʹ�õ�32λ
	.iv_transfer_count			(iv_transfer_count	),	//�������ݿ����
	.iv_transfer_size			(iv_transfer_size	),	//�������ݿ��С
	.iv_transfer1_size			(iv_transfer1_size	),	//transfer1��С
	.iv_transfer2_size			(iv_transfer2_size	),	//transfer2��С
	.i_usb_flagb				(i_usb_flagb		),	//USB���źţ�������32k�ֽ����ݺ�3��ʱ�ӻ����ͣ��л�DMA��ַ���־ָʾ��ǰFIFO״̬�������ǰFIFO��û������FLAGB�����ߣ����PC��������ǰFIFO��û�ж������ñ�־���ܳ�ʱ������
	.ov_usb_fifoaddr			(ov_usb_fifoaddr	),	//GPIF �̵߳�ַ 2bit����ַ�л�˳��Ҫ�͹̼�����һ�£�ĿǰԼ��Ϊ2'b00,2'b11�л�
	.ov_usb_fifoaddr_reg		(ov_usb_fifoaddr_reg),	//GPIF �̵߳�ַ 2bit����ַ�л�˳��Ҫ�͹̼�����һ�£�ĿǰԼ��Ϊ2'b00,2'b11�л� �м�ֵ
	.o_usb_slwr_n				(o_usb_slwr_n		),	//GPIF д�ź�
	.ov_usb_data				(ov_usb_data		),	//GPIF �����ź�
	.o_usb_pktend_n				(o_usb_pktend_n		),	//GPIF �������ź�
	.o_usb_pktend_n_for_test	(o_usb_pktend_n_for_test),	//GPIF �������źţ��������������
	.o_usb_wr_for_led			(o_usb_wr_for_led	)	//GPIF д�ź� - ��led_ctrlģ��
	);

	//  ===============================================================================================
	//  packet_switchr����
	//  ===============================================================================================
	packet_switch # (
	.REG_WD 					(REG_WD 			)	//�Ĵ���λ��
	)
	packet_switch_inst(
	.clk						(clk				),	//ʱ���źţ�clk_usb_pclkʱ����
	.reset						(reset				),	//��λ�źţ��ߵ�ƽ��Ч��clk_usb_pclkʱ����
	.i_chunkmodeactive			(i_chunkmodeactive	),	//????��Чʱ������//chunk�ܿ��أ�δͬ����δ������Чʱ�����ƣ�0)leader��52  trailer��32     1)leader��52  trailer��36
	.i_framebuffer_empty		(i_framebuffer_empty),	////framebuffer���FIFO�ձ�־���ߵ�ƽ��Ч��clk_gpifʱ����
	.iv_payload_size			(iv_payload_size	),	//payload_size��С�Ĵ�����δͬ����δ������Чʱ������
	.i_change_flag				(w_change_flag		),	//leader��payload��trailer���л���־��ÿ����������ɺ��л�
	.o_leader_flag				(w_leader_flag		),	//ͷ����־
	.o_trailer_flag				(w_trailer_flag		),	//β����־
	.o_payload_flag				(w_payload_flag		),	//���ذ���־
	.ov_packet_size				(wv_packet_size		)	//��ǰ������Ӧ�İ���С
	);
endmodule