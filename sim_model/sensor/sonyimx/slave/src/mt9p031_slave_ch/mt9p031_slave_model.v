//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : mt9p031_slave_model
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/5/26 16:15:13	:|  ��ʼ�汾
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
`timescale 1ns/100ps
//-------------------------------------------------------------------------------------------------

module mt9p031_slave_model # (
	parameter			IMAGE_SRC				= "RANDOM"			,	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC" or "FRAME_INC_NO_RST" or "PIX_INC_NO_FVAL" or "PIX_INC"
	parameter			DATA_WIDTH				= 12				,	//���ݿ��
	parameter			CHANNEL_NUM				= 4					,	//ͨ����
	parameter			VBLANK_LINE				= 22				,	//Vertical blanking period
	parameter			FRAME_INFO_LINE			= 1					,	//Frame information line
	parameter			IGNORE_OB_LINE			= 6					,	//Ignored OB
	parameter			VEFFECT_OB_LINE			= 4					,	//Vertical effective OB
	parameter			SOURCE_FILE_PATH		= "source_file/"	,	//����Դ�ļ�·��
	parameter			GEN_FILE_EN				= 0					,	//0-���ɵ�ͼ��д���ļ���1-���ɵ�ͼ��д���ļ�
	parameter			GEN_FILE_PATH			= "gen_file/"		,	//����������Ҫд���·��
	parameter			NOISE_EN				= 0						//0-������������1-��������

	)
	(
	input										clk							,	//ʱ��
	input										reset						,	//��λ
	input										i_xtrig						,	//�����źţ�������֮���µ�һ֡��ʼ����
	input										i_xhs						,	//����Ч�źţ�������֮���µ�һ�п�ʼ����
	input										i_xvs						,	//����Ч�źţ�û���õ�
	input										i_xclr						,	//��λ�źţ�����Ч
	input										i_pause_en					,	//1:��ͣ��������ͣ 0:�ָ�
	input										i_continue_lval				,	//1:������ʱ��Ҳ�����ź������0:������ʱ��û�����ź����
	input	[15:0]								iv_width					,	//����Ч�����ظ������п����64k
	input	[15:0]								iv_height					,	//һ֡�е��������������64k
	output										o_fval						,	//����Ч
	output										o_lval						,	//����Ч
	output	[DATA_WIDTH*CHANNEL_NUM-1:0]		ov_dout							//����
	);

	//	ref signals
	wire									w_fval			;
	wire									w_lval			;
	wire									w_fval_data		;
	wire									w_lval_data		;
	wire	[DATA_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data		;
	wire									w_fval_noise	;
	wire									w_lval_noise	;
	wire	[DATA_WIDTH*CHANNEL_NUM-1:0]	wv_pix_data_noise		;

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***�����г�ʱ��***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	���� fval �� lval ʱ��
	//  -------------------------------------------------------------------------------------
	frame_line_pattern # (
	.VBLANK_LINE		(VBLANK_LINE		),
	.FRAME_INFO_LINE	(FRAME_INFO_LINE	),
	.IGNORE_OB_LINE		(IGNORE_OB_LINE		),
	.VEFFECT_OB_LINE	(VEFFECT_OB_LINE	)
	)
	frame_line_pattern_inst (
	.clk				(clk				),
	.reset				(reset				),
	.i_xtrig			(i_xtrig			),
	.i_xhs				(i_xhs				),
	.i_xvs				(i_xvs				),
	.i_xclr				(i_xclr				),
	.i_pause_en			(i_pause_en			),
	.i_continue_lval	(1'b1				),
	.iv_width			(iv_width			),
	.iv_line_hide		(16'd10				),
	.iv_height			(iv_height			),
	.iv_frame_hide		(16'd5				),
	.iv_front_porch		(16'd5				),
	.iv_back_porch		(16'd5				),
	.o_fval				(w_fval				),
	.o_lval				(w_lval				)
	);

	//  -------------------------------------------------------------------------------------
	//	���� ����
	//  -------------------------------------------------------------------------------------
	data_pattern # (
	.IMAGE_SRC			(IMAGE_SRC			),
	.CHANNEL_NUM		(CHANNEL_NUM		),
	.SOURCE_FILE_PATH	(SOURCE_FILE_PATH	),
	.DATA_WIDTH			(DATA_WIDTH			)
	)
	data_pattern_inst (
	.clk				(clk				),
	.reset				(reset				),
	.i_fval				(w_fval				),
	.i_lval				(w_lval				),
	.o_fval				(w_fval_data		),
	.o_lval				(w_lval_data		),
	.ov_dout			(wv_pix_data		)
	);

	//  -------------------------------------------------------------------------------------
	//	��������
	//  -------------------------------------------------------------------------------------
	generate
		if(NOISE_EN==1) begin
			sensor_noise # (
			.DATA_WIDTH				(DATA_WIDTH				),
			.CHANNEL_NUM			(CHANNEL_NUM			)
			)
			sensor_noise_inst (
			.clk					(clk					),
			.i_fval					(w_fval_data			),
			.i_lval					(w_lval_data			),
			.iv_pix_data			(wv_pix_data			),
			.o_fval					(w_fval_noise			),
			.o_lval					(w_lval_noise			),
			.ov_pix_data			(wv_pix_data_noise		)
			);
		end
		else begin
			assign	w_fval_noise		= w_fval_data;
			assign	w_lval_noise		= w_lval_data;
			assign	wv_pix_data_noise	= wv_pix_data;
		end
	endgenerate

	//  -------------------------------------------------------------------------------------
	//	fval lval��λ
	//  -------------------------------------------------------------------------------------
	assign	o_fval	= w_fval_noise;
	assign	o_lval	= w_lval_noise;
	assign	ov_dout	= wv_pix_data_noise;

	//  ===============================================================================================
	//	ref ***�ļ�����***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	���ɵ���������д�뵽�ļ�����
	//  -------------------------------------------------------------------------------------
	generate
		if(GEN_FILE_EN==1) begin
			file_write # (
			.DATA_WIDTH		(DATA_WIDTH		),
			.CHANNEL_NUM	(CHANNEL_NUM	),
			.FILE_PATH		(GEN_FILE_PATH	)
			)
			file_write_inst (
			.clk			(clk			),
			.reset			(1'b0			),
			.i_fval			(o_fval			),
			.i_lval			(o_lval			),
			.iv_din			(ov_dout		)
			);
		end
	endgenerate


endmodule
