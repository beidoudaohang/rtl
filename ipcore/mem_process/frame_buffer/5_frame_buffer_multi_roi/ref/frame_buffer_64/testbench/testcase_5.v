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

module testcase_5 ;


//harness inst_harness ();
//  ===============================================================================================
//  ����ͼ���С
//  ===============================================================================================
	integer			i					;
	integer			j					;
	integer			k					;
	integer			i_chunkmodeactive	;
	integer			iv_frame_depth		;
	integer			iv_size_x			;
	integer			iv_size_y			;
	integer			iv_offset_x			;
	integer			iv_offset_y			;
	integer			iv_h_period 		;
	integer			iv_v_petiod 		;

	parameter						S_IDLE				= 6'b000000;
	parameter						S_REQ_WAIT			= 6'b000001;
	parameter						S_REQ				= 6'b000010;
	parameter						S_CMD_WAIT			= 6'b000100;
	parameter						S_CMD				= 6'b001000;
	parameter						S_RD				= 6'b010000;
	parameter						S_CHK				= 6'b100000;

//  ===============================================================================================
//	����֡�����
//	1�����д��Ƶ�ʲ��ԣ��ı�д��ʱ�����ڣ����ǰ��fifo�Ƿ��������֡���������ݺ���������Ƿ���ͬ
//	2��д��Ƶ��100Mhz������Ƶ��100Mhz��MCBʱ��125Mhz
//  ===============================================================================================
	parameter	CLK_IN_PERIOD 							= 10.000;
	parameter	CLK_OUT_PERIOD							= 10;
	parameter	CLK_FRAME_BUF_PERIOD					= 8;


	always # 12.5 						harness.sys_clk 		= ~harness.sys_clk;
	always # (CLK_IN_PERIOD/2)			harness.clk_vin 		= ~harness.clk_vin;
	always # (CLK_OUT_PERIOD/2)			harness.clk_vout 		= ~harness.clk_vout;
	always # (CLK_FRAME_BUF_PERIOD/2)	harness.clk_frame_buf 	= ~harness.clk_frame_buf;

//harness inst_harness ();
//  ===============================================================================================
//
//  ===============================================================================================
	initial
	begin
		i_chunkmodeactive	=	1;
		iv_frame_depth		=	2;
		iv_size_x			=	2592;
		iv_size_y			=	1944;
		iv_offset_x			=	10;
		iv_offset_y			=	10;
		iv_h_period 		=	2700;
		iv_v_petiod 		=	2100;

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
		#3000
		harness.i_stream_en					= 1'b1;
		harness.i_stream_en_clk_in			= 1'b1;
		harness.rd_enbable					= 1'b1;

	end


//  ===============================================================================================
//  �������ź�
//  ===============================================================================================
//  -------------------------------------------------------------------------------------
//	check�������������Ƿ���ͬ
//  -------------------------------------------------------------------------------------

	reg	[7:0]fval_count;
	always @ ( posedge harness.w_fval or  posedge harness.reset	)
		begin
			if ( harness.reset )
				fval_count <= 8'h0;
			else
				fval_count <= fval_count + 8'h1;
		end
//  -------------------------------------------------------------------------------------
//	���ǰ��fifo�Ƿ������
//  -------------------------------------------------------------------------------------

	always @ ( posedge harness.frame_buffer_inst.wrap_wr_logic_inst.fifo_full_nc )
		$display("%m: at time %t ERROR: front fifo is full ", $time);
endmodule
