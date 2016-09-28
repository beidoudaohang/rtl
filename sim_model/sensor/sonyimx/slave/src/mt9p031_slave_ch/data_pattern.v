//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : data_pattern
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/3/16 15:44:34	:|  ��ʼ�汾
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
//`timescale 1ns/1ps
`timescale 1ns/1ns
//-------------------------------------------------------------------------------------------------

module data_pattern # (
	parameter	IMAGE_SRC				= "RANDOM"			,	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC" or "FRAME_INC_NO_RST" or "PIX_INC_NO_FVAL" or "PIX_INC"
	parameter	CHANNEL_NUM				= 4					,	//ͨ����
	parameter	SOURCE_FILE_PATH		= "source_file/"	,	//����Դ�ļ�·��
	parameter	DATA_WIDTH				= 12				,	//8 10 12 max is 32
	parameter	FRAME_INFO_LINE			= 1					,	//Frame information line
	parameter	IGNORE_OB_LINE			= 6					,	//Ignored OB
	parameter	VEFFECT_OB_LINE			= 4						//Vertical effective OB
	)
	(
	input										clk		,
	input										reset	,
	input										i_fval	,
	input										i_lval	,
	output										o_fval	,
	output										o_lval	,
	output	[DATA_WIDTH*CHANNEL_NUM-1:0]		ov_dout
	);

	//	ref signals
	localparam	LINE_CNT_WIDTH	= log2(FRAME_INFO_LINE+IGNORE_OB_LINE+VEFFECT_OB_LINE);

	reg		[7:0]							file_name_low 	= 8'h30;	//0
	reg		[7:0]							file_name_high 	= 8'h30;	//0
	reg		[31:0]							file_input		= 32'b0;
	reg		[319:0]							input_path		= "mt9p031_input_file/";
	wire	[399:0]							input_file_name_str	;
	reg		[DATA_WIDTH-1:0]				src_value 	[CHANNEL_NUM-1:0];
	wire	[DATA_WIDTH*CHANNEL_NUM-1:0]	file_data		;

	reg										fval_dly0 	= 1'b0;
	reg										fval_dly1 	= 1'b0;
	reg										lval_dly0 	= 1'b0;
	reg										lval_dly1 	= 1'b0;
	wire									dval_rise	;
	wire									dval_fall	;
	wire									fval_rise	;
	wire									fval_fall	;
	reg		[LINE_CNT_WIDTH-1:0]			line_cnt	= 'b0;
	reg										fval_mask	= 1'b0;


	//	-------------------------------------------------------------------------------------
	//	ȡ��������ȡ��
	//	-------------------------------------------------------------------------------------
	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***��ȡ����***
	//  ===============================================================================================
	always @ (posedge clk) begin
		fval_dly0	<= i_fval;
		fval_dly1	<= fval_dly0;
	end

	always @ (posedge clk) begin
		lval_dly0	<= i_lval;
		lval_dly1	<= lval_dly0;
	end

	assign	dval_rise	= (lval_dly1==1'b0 && lval_dly0==1'b1) ? 1'b1 : 1'b0;
	assign	dval_fall	= (lval_dly1==1'b1 && lval_dly0==1'b0) ? 1'b1 : 1'b0;
	assign	fval_rise	= (fval_dly1==1'b0 && fval_dly0==1'b1) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_dly1==1'b1 && fval_dly0==1'b0) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	�м�����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_rise) begin
			line_cnt	<= 'b0;
		end
		else if(dval_fall) begin
			if(line_cnt=={LINE_CNT_WIDTH{1'b1}}) begin
				line_cnt	<= line_cnt;
			end
			else begin
				line_cnt	<= line_cnt + 1'b1;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	ѡ����Ч����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(line_cnt>=(FRAME_INFO_LINE+IGNORE_OB_LINE+VEFFECT_OB_LINE)) begin
			fval_mask	<= i_fval;
		end
		else begin
			fval_mask	<= 1'b0;
		end
	end

	//  ===============================================================================================
	//	ref ***����ͼ������***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	����paramter������ѡ���·
	//  -------------------------------------------------------------------------------------
	genvar	ch;
	generate
		for(ch=0;ch<CHANNEL_NUM;ch=ch+1) begin
			//  -------------------------------------------------------------------------------------
			//	1.���ģʽ���������������������д���ļ�����
			//  -------------------------------------------------------------------------------------
			if(IMAGE_SRC=="RANDOM") begin
				//��������
				always @ (posedge clk) begin
					if(reset) begin
						src_value[ch]	<= 'b0;
					end
					else begin
						if(lval_dly0==1'b1 && fval_mask==1'b1) begin
							src_value[ch]	<= $random();
						end
					end
				end
			end

			//  -------------------------------------------------------------------------------------
			//	2.������ģʽ����4bit��������bitÿ�е���
			//  -------------------------------------------------------------------------------------
			else if(IMAGE_SRC=="LINE_INC") begin
				//�������� - ���ֽ�
				always @ (posedge clk) begin
					if(reset) begin
						src_value[ch][DATA_WIDTH-1:4]	<= 'b0;
					end
					else begin
						if(!i_fval) begin
							src_value[ch][DATA_WIDTH-1:4]	<= 'b0;
						end
						else if(dval_fall==1'b1 && fval_mask==1'b1) begin
							src_value[ch][DATA_WIDTH-1:4]	<= src_value[ch][DATA_WIDTH-1:4] + 1'b1;
						end
					end
				end
				//�������� - ���ֽ�
				always @ (posedge clk) begin
					if(reset) begin
						src_value[ch][3:0]	<= 'b0;
					end
					else begin
						if(!lval_dly1) begin
							src_value[ch][3:0]	<= 'b0;
						end
						else begin
							src_value[ch][3:0]	<= src_value[ch][3:0] + 1'b1;
						end
					end
				end
			end

			//  -------------------------------------------------------------------------------------
			//	3.֡����ģʽ��ȫ�����أ�ÿ֡����
			//  -------------------------------------------------------------------------------------
			else if(IMAGE_SRC=="FRAME_INC") begin
				always @ (posedge clk) begin
					if(reset) begin
						src_value[ch]	<= 'b0;
					end
					else begin
						if(fval_fall) begin
							src_value[ch]	<= src_value[ch] + 1'b1;
						end
					end
				end
			end

			//  -------------------------------------------------------------------------------------
			//	4.֡����ģʽ��ȫ�����أ�ÿ֡��������λ��������
			//  -------------------------------------------------------------------------------------
			else if(IMAGE_SRC=="FRAME_INC_NO_RST") begin
				always @ (posedge clk) begin
					if(fval_fall) begin
						src_value[ch]	<= src_value[ch] + 1'b1;
					end
				end
			end

			//  -------------------------------------------------------------------------------------
			//	5.���ļ��ж������˴���Ҫ����
			//  -------------------------------------------------------------------------------------
			else if(IMAGE_SRC=="FILE") begin
				always @ (*) begin
					src_value[ch]	<= file_data[DATA_WIDTH*(ch+1)-1:DATA_WIDTH*ch];
				end
			end

			//  -------------------------------------------------------------------------------------
			//	6.��������ģʽ�����������Ḵλ��ֵ
			//  -------------------------------------------------------------------------------------
			else if(IMAGE_SRC=="PIX_INC_NO_FVAL") begin
				always @ (posedge clk) begin
					if(reset) begin
						src_value[ch]	<= 'b0;
					end
					else begin
						if(lval_dly1==1'b1 && fval_mask==1'b1) begin
							src_value[ch]	<= src_value[ch] + 1'b1;
						end
					end
				end
			end

			//  -------------------------------------------------------------------------------------
			//	7.��������ģʽ���������Ḵλ��ֵ
			//  -------------------------------------------------------------------------------------
			else if(IMAGE_SRC=="PIX_INC") begin
				always @ (posedge clk) begin
					if(reset) begin
						src_value[ch]	<= 'b0;
					end
					else begin
						if(!i_fval) begin
							src_value[ch]	<= 'b0;
						end
						else if(lval_dly1==1'b1 && fval_mask==1'b1) begin
							src_value[ch]	<= src_value[ch] + 1'b1;
						end
					end
				end
			end
		end

	endgenerate

	//  -------------------------------------------------------------------------------------
	//	����������Ǵ��ļ��ж����ݣ�����Ҫ�������ļ���ģ��
	//  -------------------------------------------------------------------------------------
	generate
		if(IMAGE_SRC=="FILE") begin
			file_read # (
			.DATA_WIDTH		(DATA_WIDTH			),
			.CHANNEL_NUM	(CHANNEL_NUM		),
			.FILE_PATH		(SOURCE_FILE_PATH	)
			)
			file_read_inst (
			.clk			(clk			),
			.reset			(reset			),
			.i_fval			(fval_mask		),
			.i_lval			(lval_dly0		),
			.ov_dout		(file_data		)
			);
		end
	endgenerate

	//  ===============================================================================================
	//	ref ***�������***
	//  ===============================================================================================
	assign	o_fval		= fval_dly1;
	assign	o_lval		= lval_dly1;
	genvar	ch_cnt;
	generate
		for(ch_cnt=0;ch_cnt<CHANNEL_NUM;ch_cnt=ch_cnt+1) begin
			assign	ov_dout[DATA_WIDTH*(ch_cnt+1)-1:DATA_WIDTH*ch_cnt]		= lval_dly1 ? src_value[ch_cnt] : {DATA_WIDTH{1'b0}};
		end
	endgenerate



endmodule
