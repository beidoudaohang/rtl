//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : ccd_sharp_data_pattern
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/8/25 10:46:08	:|  ��ʼ�汾
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

module ccd_sharp_data_pattern # (
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
	parameter	ALLPIX_PER_LINE		= 1376				,	//һ����������
	parameter	IMAGE_SOURCE		= "RANDOM"			,	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC" or "PIX_INC"
	parameter	SOURCE_FILE_PATH	= "source_file/"		//����Դ�ļ�·��
	)
	(
	input							i_line_change		,	//��ֱ��ת����
	input							i_frame_change			//xsg��ת����
	);

	//	ref signals
	localparam	PIX_WIDTH	= (DATA_WIDTH<=8)	? 8 :
	(DATA_WIDTH<=16)	? 16 :
	(DATA_WIDTH<=24)	? 24 :
	(DATA_WIDTH<=32)	? 32 :
	32
	;

	reg								reset_file		= 1'b1;
	reg		[31:0]					file_handle		;
	reg		[DATA_WIDTH-1:0]		line_value		= 'b0;
	reg		[DATA_WIDTH-1:0]		frame_value		= 'b0;
	reg		[DATA_WIDTH-1:0]		h_shifter_init	[ALLPIX_PER_LINE-1:0]	;	//ˮƽ��λ�Ĵ����ĳ�ʼ�����ݣ�Ŀǰ�����г�ʼ�����ݶ�����ͬ��


	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***�ļ�����***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//���ļ���λ�ź�
	//	-------------------------------------------------------------------------------------
	initial begin
		reset_file	= 1'b1;
		#200
		reset_file	= 1'b0;
	end

	generate
		if(IMAGE_SOURCE=="FILE") begin
			//	-------------------------------------------------------------------------------------
			//	���ļ���file_read ģ��ֻ������ļ�������Ķ�������������
			//	-------------------------------------------------------------------------------------
			file_read # (
			.DATA_WIDTH	(PIX_WIDTH			),
			.FILE_PATH	(SOURCE_FILE_PATH	)
			)
			file_read_inst (
			.clk		(1'b0			),
			.reset		(reset_file		),
			.i_fval		(!i_frame_change),
			.i_lval		(1'b0			),
			.ov_dout	(				)
			);

			//  -------------------------------------------------------------------------------------
			//	�ļ������Զ�ģʽ��
			//  -------------------------------------------------------------------------------------
			initial begin
				forever begin
					@(posedge i_frame_change)
					#1
					$fclose(file_handle);
					file_handle	<= $fopen(file_read_inst.file_name_str,"rb");

					if(file_handle=='b0) begin
						$display("%m: at time %t ERROR: open file fail.file name is \"%0s\".", $time,file_read_inst.file_name_str);
						$stop;
					end
					else begin
						$display("file open ok!file name is \"%0s\".",file_read_inst.file_name_str);
					end
				end
			end
		end
	endgenerate

	//	===============================================================================================
	//	ref ***��ʼ��***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	LINE_INC����ֵ��ÿ��xv��ת֮�󣬼�1
	//	--xsg����������Ϊ��һ֡�������źţ���ʱline_value��λ
	//	-------------------------------------------------------------------------------------
	always @ (posedge i_line_change or posedge i_frame_change) begin
		if(i_frame_change) begin
			line_value	<= 'b0;
		end
		else begin
			line_value	<= line_value + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	FRAME_INC����ֵ��ÿ��xsg������֮�󣬼�1
	//	-------------------------------------------------------------------------------------
	always @ (posedge i_frame_change) begin
		frame_value	<= frame_value + 1'b1;
	end

	//	-------------------------------------------------------------------------------------
	//	�����ݳ�ʼ��
	//	-------------------------------------------------------------------------------------
	genvar	k;
	generate
		for(k=0;k<=(ALLPIX_PER_LINE-1);k=k+1) begin
			if(k>=0 && k<DUMMY_HFRONT) begin
				initial begin
					forever begin
						h_shifter_init[k]	= DUMMY_INIT_VALUE;
						@(posedge i_line_change);
					end
				end
			end
			else if(k>=DUMMY_HFRONT && k<(DUMMY_HFRONT+BLACK_HFRONT)) begin
				initial begin
					forever begin
						h_shifter_init[k]	= BLACK_INIT_VALUE;
						@(posedge i_line_change);
					end
				end
			end
			else if(k>=(DUMMY_HFRONT+BLACK_HFRONT) && k<(DUMMY_HFRONT+BLACK_HFRONT+IMAGE_WIDTH)) begin
				if(IMAGE_SOURCE=="RANDOM") begin
					initial begin
						forever begin
							h_shifter_init[k]	= $random();
							@(posedge i_line_change);
						end
					end
				end
				else if(IMAGE_SOURCE=="PIX_INC") begin
					initial begin
						forever begin
							h_shifter_init[k]	= h_shifter_init[k-1]+1'b1;
							@(posedge i_line_change);
						end
					end
				end
				else if(IMAGE_SOURCE=="LINE_INC") begin
					initial begin
						forever begin
							h_shifter_init[k]	= line_value;
							@(posedge i_line_change);
						end
					end
				end
				else if(IMAGE_SOURCE=="FRAME_INC") begin
					initial begin
						forever begin
							h_shifter_init[k]	= frame_value;
							@(posedge i_line_change);
						end
					end
				end
				else if(IMAGE_SOURCE=="FILE") begin
					//8bit ÿ������ռ��1���ֽ�
					if(PIX_WIDTH==8) begin
						initial begin
							#10
							@(negedge i_frame_change);
							forever begin
								h_shifter_init[k][DATA_WIDTH-1:0]	= $fgetc(file_handle);
								@(posedge i_line_change);
							end
						end
					end
					else if(PIX_WIDTH==16) begin
						initial begin
							#10
							@(negedge i_frame_change);
							forever begin
								h_shifter_init[k][7:0]				<= $fgetc(file_handle);
								h_shifter_init[k][DATA_WIDTH-1:8]	<= $fgetc(file_handle);
								@(posedge i_line_change);
							end
						end
					end
					else if(PIX_WIDTH==24) begin
						initial begin
							#10
							@(negedge i_frame_change);
							forever begin
								h_shifter_init[k][7:0]				= $fgetc(file_handle);
								h_shifter_init[k][15:8]				= $fgetc(file_handle);
								h_shifter_init[k][DATA_WIDTH-1:16]	= $fgetc(file_handle);
								@(posedge i_line_change);
							end
						end
					end
					else if(PIX_WIDTH==32) begin
						initial begin
							#10
							@(negedge i_frame_change);
							forever begin
								h_shifter_init[k][7:0]				= $fgetc(file_handle);
								h_shifter_init[k][15:8]				= $fgetc(file_handle);
								h_shifter_init[k][23:16]			= $fgetc(file_handle);
								h_shifter_init[k][DATA_WIDTH-1:24]	= $fgetc(file_handle);
								@(posedge i_line_change);
							end
						end
					end
				end
			end
			else if(k>=(DUMMY_HFRONT+BLACK_HFRONT+IMAGE_WIDTH) && k<(DUMMY_HFRONT+BLACK_HFRONT+IMAGE_WIDTH+BLACK_HREAR)) begin
				initial begin
					forever begin
						h_shifter_init[k]	= BLACK_INIT_VALUE;
						@(posedge i_line_change);
					end
				end
			end
			else if(k>=(DUMMY_HFRONT+BLACK_HFRONT+IMAGE_WIDTH+BLACK_HREAR) && k<(DUMMY_HFRONT+BLACK_HFRONT+IMAGE_WIDTH+BLACK_HREAR+DUMMY_HREAR)) begin
				initial begin
					forever begin
						h_shifter_init[k]	= DUMMY_INIT_VALUE;
						@(posedge i_line_change);
					end
				end
			end
		end
	endgenerate




endmodule
