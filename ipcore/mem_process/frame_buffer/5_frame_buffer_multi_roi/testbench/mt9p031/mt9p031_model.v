//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : mt9p031_model
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

module mt9p031_model # (
	parameter			IMAGE_SRC				= "RANDOM"			,	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC" or "FRAME_INC_NO_RST"
	parameter			DATA_WIDTH				= 12				,	//���ݿ��
	parameter			SENSOR_CLK_DELAY_VALUE	= 0					,	//Sensor оƬ�ڲ���ʱ ��λns
	parameter			CLK_DATA_ALIGN			= "RISING"			,	//"RISING" - ���ʱ�ӵ������������ݶ��롣"FALLING" - ���ʱ�ӵ��½��������ݶ���
	parameter			FVAL_LVAL_ALIGN			= "FALSE"			,	//"TRUE" - fval �� lval ֮��ľ���̶�Ϊ3��ʱ�ӡ�"FALSE" - fval �� lval ֮��ľ��������趨
	parameter			SOURCE_FILE_PATH		= "source_file/"	,	//����Դ�ļ�·��
	parameter			GEN_FILE_EN				= 0					,	//0-���ɵ�ͼ��д���ļ���1-���ɵ�ͼ��д���ļ�
	parameter			GEN_FILE_PATH			= "gen_file/"		,	//����������Ҫд���·��
	parameter			NOISE_EN				= 0						//0-������������1-��������
	)
	(
	input								clk							,	//ʱ��
	input								reset						,	//��λ
	input								i_pause_en					,	//1:��ͣ��������ͣ 0:�ָ�
	input								i_continue_lval				,	//1:������ʱ��Ҳ�����ź������0:������ʱ��û�����ź����
	input	[15:0]						iv_width					,	//����Ч�����ظ������п����64k
	input	[15:0]						iv_line_hide				,	//�����������ظ��������������64k
	input	[15:0]						iv_height					,	//һ֡�е��������������64k
	input	[15:0]						iv_frame_hide				,	//֡�������������������64k
	input	[15:0]						iv_front_porch				,	//ǰ�أ�fval�����غ�lval������֮��ľ��룬ǰ�غ���֮���ܳ���������
	input	[15:0]						iv_back_porch				,	//���أ�fval�½��غ�lval�½���֮��ľ���
	output								o_clk_pix					,	//�����ʱ��
	output								o_fval						,	//����Ч
	output								o_lval						,	//����Ч
	output	[DATA_WIDTH-1:0]			ov_dout							//����
	);

	//	ref signals
	wire						w_fval			;
	wire						w_lval			;
	wire						clk_int			;
	wire						w_fval_data		;
	wire						w_lval_data		;
	wire	[DATA_WIDTH-1:0]	wv_pix_data		;
	wire						w_fval_noise	;
	wire						w_lval_noise	;
	wire	[DATA_WIDTH-1:0]	wv_pix_data_noise		;

	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref ***�����ź�Ԥ����***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	ʱ���ӳ�
	//  -------------------------------------------------------------------------------------
	assign	#SENSOR_CLK_DELAY_VALUE	clk_int	= clk;

	//  -------------------------------------------------------------------------------------
	//	ʱ�����
	//  -------------------------------------------------------------------------------------
	generate
		if(CLK_DATA_ALIGN=="RISING") begin
			assign	o_clk_pix	= clk_int;
		end
		else begin
			assign	o_clk_pix	= !clk_int;
		end
	endgenerate

	//  ===============================================================================================
	//	ref ***�����г�ʱ��***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	���� fval �� lval ʱ��
	//  -------------------------------------------------------------------------------------
	frame_line_pattern # (
	.FVAL_LVAL_ALIGN	(FVAL_LVAL_ALIGN	)
	)
	frame_line_pattern_inst (
	.clk				(clk_int			),
	.reset				(reset				),
	.i_pause_en			(i_pause_en			),
	.i_continue_lval	(i_continue_lval	),
	.iv_width			(iv_width			),
	.iv_line_hide		(iv_line_hide		),
	.iv_height			(iv_height			),
	.iv_frame_hide		(iv_frame_hide		),
	.iv_front_porch		(iv_front_porch		),
	.iv_back_porch		(iv_back_porch		),
	.o_fval				(w_fval				),
	.o_lval				(w_lval				)
	);

	//  -------------------------------------------------------------------------------------
	//	���� ����
	//  -------------------------------------------------------------------------------------
	data_pattern # (
	.IMAGE_SRC			(IMAGE_SRC			),
	.SOURCE_FILE_PATH	(SOURCE_FILE_PATH	),
	.DATA_WIDTH			(DATA_WIDTH			)
	)
	data_pattern_inst (
	.clk				(clk_int			),
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
			.DATA_WIDTH				(DATA_WIDTH				)
			)
			sensor_noise_inst (
			.clk					(clk_int				),
			.iv_line_active_pix_num	(iv_line_active_pix_num	),
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
	generate
		if(FVAL_LVAL_ALIGN=="TRUE")begin
			fval_lval_phase # (
			.DATA_WIDTH	(DATA_WIDTH		)
			)
			fval_lval_phase_inst (
			.clk		(clk_int		),
			.reset		(reset			),
			.i_fval		(w_fval_noise	),
			.i_lval		(w_lval_noise	),
			.iv_din		(wv_pix_data_noise	),
			.o_fval		(o_fval			),
			.o_lval		(o_lval			),
			.ov_dout	(ov_dout		)
			);
		end
		else begin
			assign	o_fval	= w_fval_noise;
			assign	o_lval	= w_lval_noise;
			assign	ov_dout	= wv_pix_data_noise;
		end
	endgenerate

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
			.FILE_PATH		(GEN_FILE_PATH	)
			)
			file_write_inst (
			.clk			(clk_int		),
			.reset			(1'b0			),
			.i_fval			(o_fval			),
			.i_lval			(o_lval			),
			.iv_din			(ov_dout		)
			);
		end
	endgenerate


endmodule
