//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : testcase
//  -- �����       : ��ǿ
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- ��ǿ         :| 2015/4/8 16:46:01	:|
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module testcase_1 ;


//harness inst_harness ();
//  ===============================================================================================
//  ����ͼ���С
//  ===============================================================================================
	integer			j					;
	integer			i_chunkmodeactive	;
	integer			iv_frame_depth		;
	integer			iv_size_x			;
	integer			iv_size_y			;
	integer			iv_offset_x			;
	integer			iv_offset_y			;
	integer			iv_h_period 		;
	integer			iv_v_petiod 		;

	parameter		S_IDLE		= 5'b00000	;
	parameter		S_REQ		= 5'b00001	;
	parameter		S_WR		= 5'b00010	;
	parameter		S_CMD_CHK	= 5'b00100	;
	parameter		S_CMD		= 5'b01000	;
	parameter		S_CHK		= 5'b10000	;

	parameter	CLK_IN_PERIOD 							= 14;
	parameter	CLK_OUT_PERIOD							= 10;
	parameter	CLK_FRAME_BUF_PERIOD					= 10;


	always # 12.5 						harness.sys_clk 		= ~harness.sys_clk;
	always # (CLK_IN_PERIOD/2)			harness.clk_vin 		= ~harness.clk_vin;
	always # (CLK_OUT_PERIOD/2)			harness.clk_vout 		= ~harness.clk_vout;
	always # (CLK_FRAME_BUF_PERIOD/2)	harness.clk_frame_buf 	= ~harness.clk_frame_buf;

//harness inst_harness ();

//  ===============================================================================================
//	ͣ��λ��
//	1����д��״̬���ĸ����׶�ֹͣ�ɼ�����һ֡�Ƿ��ܹ��ָ���
//	S_IDLE		������״̬
//	S_REQ		������״̬
//	S_WR		��д������״̬
//	S_CMD_CHK	��������״̬
//	S_CMD		����������״̬
//	S_CHK		�������֡�Ƿ�д��״̬
//	1������֡д����������Ƿ���ͬ
//  ===============================================================================================
	initial
	begin
//��С����
		i_chunkmodeactive	=	1;
		iv_frame_depth		=	2;
		iv_size_x			=	64;
		iv_size_y			=	64;
		iv_offset_x			=	10;
		iv_offset_y			=	10;
		iv_h_period 		=	164;
		iv_v_petiod 		=	120;

	    harness.bfm1_inst.config_imagesize
	    (
		i_chunkmodeactive				,
		iv_frame_depth					,
		iv_size_x						,
		iv_size_y						,
		iv_offset_x						,
		iv_offset_y						,
		iv_h_period 					,
		iv_v_petiod 					,

		harness.w_chunkmodeactive 		,
		harness.wv_frame_depth			,
		harness.wv_h_period 			,
		harness.wv_v_petiod 			,
		harness.wv_size_x				, 		//���ڿ��
		harness.wv_size_y				, 		//���ڸ߶�
		harness.wv_offset_x				, 		//ˮƽƫ��
		harness.wv_offset_y				, 		//��ֱ����
		harness.iv_payload_size_frame_buf	,
		harness.iv_payload_size_pix			,
		harness.wv_u3v_size
 		);
		#1000
		harness.i_stream_en					= 1'b1;
		harness.i_stream_en_clk_in			= 1'b1;

		for( j=0;j<=12;j=j+1	)
			begin
				@( posedge harness.w_vend );
				if( j==3 )
				begin
					//repeat ( 1500 )		//stop @ wr
					repeat ( 1300 )		//stop @ rd
						@ ( posedge harness.frame_buffer_inst.wrap_wr_logic_inst.clk);
					harness.reset		=1'b1;
					#1000
					harness.reset		=1'b0;
				end
			end

	end
//  ===============================================================================================
//  �������ź�
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	check�������������Ƿ���ͬ
//  -------------------------------------------------------------------------------------

	save_to_file1
		#(
		.DATA_WD		(32				)
		)
		save_to_file1_inst(
		.clk			(harness.clk_vin							),
		.reset			(harness.reset								),
		.iv_data		(harness.frame_buffer_inst.iv_image_din		),
		.i_data_en  	(harness.frame_buffer_inst.i_fval && harness.frame_buffer_inst.i_dval )
		);

	save_to_file2
		#(
		.DATA_WD		(32				)
		)
		save_to_file2_inst(
		.clk			(harness.clk_vout									),
		.reset			(harness.reset										),
		.iv_data		(harness.frame_buffer_inst.ov_frame_dout			),
		.i_data_en  	(harness.frame_buffer_inst.o_frame_valid && harness.frame_buffer_inst.i_buf_rd )
		);
endmodule
