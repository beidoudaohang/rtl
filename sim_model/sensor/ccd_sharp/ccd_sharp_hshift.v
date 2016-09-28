//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : ccd_sharp_hshift
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/8/10 14:17:57	:|  ��ʼ�汾
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

module ccd_sharp_hshift # (
	parameter	DATA_WIDTH			= 14				,	//��������λ��
	parameter	IMAGE_WIDTH			= 1320				,	//ͼ����
	parameter	BLACK_VFRONT		= 8					,	//��ͷ���и���
	parameter	BLACK_VREAR			= 2					,	//��β���и���
	parameter	BLACK_HFRONT		= 12				,	//��ͷ�����ظ���
	parameter	BLACK_HREAR			= 40				,	//��β�����ظ���
	parameter	DUMMY_VFRONT		= 2					,	//��ͷ���и���
	parameter	DUMMY_VREAR			= 0					,	//��β���и���
	parameter	DUMMY_HFRONT		= 4					,	//��ͷ�����ظ���
	parameter	DUMMY_HREAR			= 0					,	//��β�����ظ���
	parameter	DUMMY_INIT_VALUE	= 16				,	//DUMMY��ʼֵ
	parameter	BLACK_INIT_VALUE	= 32				,	//BLACK��ʼֵ
	parameter	IMAGE_SOURCE		= "RANDOM"			,	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC" or "PIX_INC"
	parameter	SOURCE_FILE_PATH	= "source_file/"		//����Դ�ļ�·��
	)
	(
	input							i_line_change	,	//��ֱ��ת����
	input							i_frame_change	,	//xsg��ת����
	input							hl				,	//ˮƽ����
	input							h1				,	//ˮƽ����
	input							h2				,	//ˮƽ����
	input							rs				,	//ˮƽ����
	output	[DATA_WIDTH-1:0]		ov_pix_data			//�����������
	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	һ�����������أ�����ǰ���dummy��black
	//	-------------------------------------------------------------------------------------
	localparam	ALLPIX_PER_LINE	= DUMMY_HFRONT+BLACK_HFRONT+IMAGE_WIDTH+BLACK_HREAR+DUMMY_HREAR;

	reg		[DATA_WIDTH-1:0]		h_shifter	[ALLPIX_PER_LINE-1:0]		;	//ˮƽ��λ�Ĵ���������λ���ˮƽ��λ�Ĵ����ĳ��ȶ����ɲ���ȷ��
	reg		[DATA_WIDTH-1:0]		pix_data_latch	= 'b0;
	reg		[DATA_WIDTH-1:0]		shift_out_pix	= 'b0;
	wire	[DATA_WIDTH-1:0]		h_shifter_init	[ALLPIX_PER_LINE-1:0]	;	//ˮƽ��λ�Ĵ����ĳ�ʼ�����ݣ�Ŀǰ�����г�ʼ�����ݶ�����ͬ��

	//	ref ARCHITECTURE
	//	===============================================================================================
	//	ref ***��ʼ��***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	����ģ��Դ洢���ڵ������س�ʼ��
	//	-------------------------------------------------------------------------------------
	ccd_sharp_data_pattern # (
	.DATA_WIDTH			(DATA_WIDTH			),
	.IMAGE_WIDTH		(IMAGE_WIDTH		),
	.BLACK_VFRONT		(BLACK_VFRONT		),
	.BLACK_VREAR		(BLACK_VREAR		),
	.BLACK_HFRONT		(BLACK_HFRONT		),
	.BLACK_HREAR		(BLACK_HREAR		),
	.DUMMY_VFRONT		(DUMMY_VFRONT		),
	.DUMMY_VREAR		(DUMMY_VREAR		),
	.DUMMY_HFRONT		(DUMMY_HFRONT		),
	.DUMMY_HREAR		(DUMMY_HREAR		),
	.DUMMY_INIT_VALUE	(DUMMY_INIT_VALUE	),
	.BLACK_INIT_VALUE	(BLACK_INIT_VALUE	),
	.ALLPIX_PER_LINE	(ALLPIX_PER_LINE	),
	.IMAGE_SOURCE		(IMAGE_SOURCE		),
	.SOURCE_FILE_PATH	(SOURCE_FILE_PATH	)
	)
	ccd_sharp_data_pattern_inst (
	.i_line_change		(i_line_change	),
	.i_frame_change		(i_frame_change	)
	);

	//	-------------------------------------------------------------------------------------
	//	ˮƽ��λ�Ĵ�����ʼ����ˮƽ��ʼ�Ĵ���ӳ��
	//	-------------------------------------------------------------------------------------
	genvar	i;
	generate
		for(i=0;i<=(ALLPIX_PER_LINE-1);i=i+1) begin
			initial begin
				h_shifter[i]	<= {DATA_WIDTH{1'b0}};
			end
			assign	h_shifter_init[i]	= ccd_sharp_data_pattern_inst.h_shifter_init[i];
		end
	endgenerate

	//	===============================================================================================
	//	ref ***��λ����***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	ˮƽ��λ��0���������Ƴ�
	//	-------------------------------------------------------------------------------------
	genvar	j;
	generate
		for(j=0;j<(ALLPIX_PER_LINE-1);j=j+1) begin
			always @ (posedge hl or posedge i_line_change) begin
				if(i_line_change) begin
					h_shifter[j]	<= h_shifter[j] + h_shifter_init[j];
				end
				else begin
					h_shifter[j]	<= h_shifter[j+1];
				end
			end
		end
	endgenerate

	always @ (posedge hl or posedge i_line_change) begin
		if(i_line_change) begin
			h_shifter[ALLPIX_PER_LINE-1]	<= h_shifter[ALLPIX_PER_LINE-1] + h_shifter_init[ALLPIX_PER_LINE-1];
		end
		else begin
			h_shifter[ALLPIX_PER_LINE-1]	<= {DATA_WIDTH{1'b0}};
		end
	end

	//	-------------------------------------------------------------------------------------
	//	��λ����Ĵ�������hl������֮�󣬲��������һ������
	//	--��һ����λ��Ҫ�����bit���ȥ
	//	-------------------------------------------------------------------------------------
	always @ (posedge hl) begin
		shift_out_pix	<= h_shifter[0];
	end

	//	-------------------------------------------------------------------------------------
	//	�������
	//	--��rs��Ч��ʱ�����������Ҫ����
	//	-------------------------------------------------------------------------------------
	always @ ( * ) begin
		if(rs) begin
			pix_data_latch	<= {DATA_WIDTH{1'b0}}	;
		end
		else begin
			pix_data_latch	<= shift_out_pix	;
		end
	end

	assign	ov_pix_data	= pix_data_latch;

endmodule
