//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : pattern_model
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2013/5/24 10:08:24	:|  ��ʼ�汾
//  -- �Ϻ���       :| 2014/6/9 14:52:56	:|  ��������Ϊ�˿ڣ�������Ե�ʱ��ı�֡��
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :	���� fval �� dval ʱ��
//              1)  : ����parameter�Ķ��巽ʽ����define
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//		�궨��˵�����£�
//
//					|<-------	FRAME_ACTIVE_PIX_NUM					------->|<--FRAME_HIDE_PIX_NUM->|
//					_____________________________________________________________						______
//	fval	________|															|_______________________|
//							_________		_________		   	_________
//	dval	________________|		|_______|		|____****___|		|________________________________
//
//					|<-	  ->|		|<-	  ->|<-   ->|					|<-   ->|
//						|				|		|							|
//			FRAME_TO_LINE_PIX_NUM <-----|-------|----------------------------
//							LINE_HIDE_PIX_NUM	|
//								LINE_ACTIVE_PIX_NUM

//-------------------------------------------------------------------------------------------------
//`include        "pattern_model_def.v"
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

//module pattern_model # (
//	parameter		LINE_ACTIVE_PIX_NUM		= 100,
//	parameter		LINE_HIDE_PIX_NUM		= 20,
//	parameter		LINE_ACTIVE_NUMBER		= 4,
//	parameter		FRAME_HIDE_PIX_NUM		= 100,
//	parameter		FRAME_TO_LINE_PIX_NUM	= 10
//	)

module pattern_model (
	input			clk,
	input			reset,

	input	[15:0]	iv_line_active_pix_num		,//����Ч�����ظ���
	input	[15:0]	iv_line_hide_pix_num		,//�����������ظ���
	input	[15:0]	iv_line_active_num			,//һ֡�е�����
	input	[15:0]	iv_frame_hide_pix_num		,//֡���������ظ���
	input	[7:0]	iv_frame_to_line_pix_num	,//��֡��ʼ���п�ʼ�����ظ��������н�����֡���������ظ���

	output			o_fval,
	output			o_dval
	);

	//ref signals


	reg		[31:0]		pix_per_frame = 0;
	reg					fval = 1'b0;
	reg		[7:0]		pix_between_frame_line 	= 8'b0;
	reg		[16:0]		pix_per_whole_line 		= 17'b0;
	reg					dval 		= 1'b0;
	reg		[15:0]		line_num 	= 0;
	wire				line_num_less;
	reg					gap_between_frame_line = 1'b0;
	reg					gap_between_frame_line_d = 1'b0;

	//	parameter 			FRAME_ACTIVE_PIX_NUM = LINE_ACTIVE_PIX_NUM * LINE_ACTIVE_NUMBER + LINE_HIDE_PIX_NUM * (LINE_ACTIVE_NUMBER - 1) + FRAME_TO_LINE_PIX_NUM * 2;

	wire			[31:0]	total_active_pix_num	;
	wire			[31:0]	total_hide_pix_num		;
	reg				[31:0]	frame_active_pix_num	;
	reg				[31:0]	whole_frame_pix_num	;
	reg				[15:0]	whole_line_pix_num	;

	//  -------------------------------------------------------------------------------------
	//
	//  -------------------------------------------------------------------------------------


	//ref ARCHITECTURE

	//  ===============================================================================================
	//	���
	//  ===============================================================================================
	assign	o_fval		= fval;
	assign	o_dval		= dval;

	//  ===============================================================================================
	//	��������
	//  ===============================================================================================
	mult_pattern mult_pattern_inst (
	.clk	(clk						),
	.a		(iv_line_active_num			),
	.b		(iv_line_active_pix_num		),
	.p		(total_active_pix_num		)
	);

	mult_pattern mult_pattern_inst1 (
	.clk	(clk						),
	.a		(iv_line_active_num-1'b1	),
	.b		(iv_line_hide_pix_num		),
	.p		(total_hide_pix_num			)
	);

	always @ (posedge clk) begin
		frame_active_pix_num	<= total_active_pix_num + total_hide_pix_num + {iv_frame_to_line_pix_num,1'b0};
	end

	always @ (posedge clk) begin
		whole_frame_pix_num		<= frame_active_pix_num + iv_frame_hide_pix_num - 1'b1;
	end

	always @ (posedge clk) begin
		whole_line_pix_num		<= iv_line_active_pix_num + iv_line_hide_pix_num - 1'b1;
	end




	//  ===============================================================================================
	//	��������
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  ֡��Ч fval ����
	//	pix per frame ��¼��һ��֡��pix��Ŀ
	//  -------------------------------------------------------------------------------------
	always @ (posedge reset or posedge clk) begin
		if(reset) begin
			pix_per_frame	<= 'b0;
		end else begin
			if(pix_per_frame == whole_frame_pix_num) begin
				pix_per_frame	<= 'b0;
			end else begin
				pix_per_frame	<= pix_per_frame + 1'b1;
			end
		end
	end

	//����������������ֵʱ��fval��Ч
	//��λ֮���Ƚ���������
	always @ (posedge clk) begin
		if(pix_per_frame < iv_frame_hide_pix_num) begin
			fval	<= 1'b0;
		end else begin
			fval	<= 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  ֡��Ч fval ��������Ч dval ֮��Ŀ�϶
	//	pix between frame line ָ����֡��Ч�ı��غ�����Ч�ı���֮��ľ���
	//  -------------------------------------------------------------------------------------
	always @ (posedge reset or posedge clk) begin
		if(reset) begin
			pix_between_frame_line	<= 'b0;
		end else begin
			if(fval == 1'b1) begin
				if(pix_between_frame_line != (iv_frame_to_line_pix_num - 2'b10)) begin
					pix_between_frame_line	<= pix_between_frame_line + 1'b1;
				end
			end else begin
				pix_between_frame_line	<= 'b0;
			end
		end
	end

	always @ (posedge clk) begin
		if(pix_between_frame_line == (iv_frame_to_line_pix_num - 2'b10)) begin
			gap_between_frame_line	<= 1'b1;
		end else begin
			gap_between_frame_line	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  �����ؼ�����
	//	pix per whole line ��¼����һ����(����Чʱ�� + ������ʱ��)���ص���
	//	������С��ָ����������֡��Ч����������Ч���ص���������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(line_num < iv_line_active_num) begin
			if(fval&gap_between_frame_line) begin
				if(pix_per_whole_line	== whole_line_pix_num) begin
					pix_per_whole_line	<= 0;
				end else begin
					pix_per_whole_line	<= pix_per_whole_line + 1;
				end
			end
		end else begin
			pix_per_whole_line	<= 0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//  �и���������
	//  -------------------------------------------------------------------------------------
	always @ (posedge reset or posedge clk) begin
		if(reset) begin
			line_num	<= 0;
		end else begin
			if(gap_between_frame_line == 1'b0) begin
				line_num	<= 0;
			end else begin
				if(pix_per_whole_line == iv_line_active_pix_num - 1'b1) begin
					line_num	<= line_num + 1;
				end
			end
		end
	end

	assign	line_num_less	= (line_num < iv_line_active_num) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//  ������Ч dval ���߼�
	//  -------------------------------------------------------------------------------------
	//--1 ֡��Ч��������Ч֮��ļ��
	//--2 ��������Ч����

	always @ (posedge clk) begin
		//		if((gap_between_frame_line == 1'b1)&&(pix_per_whole_line < LINE_ACTIVE_PIX_NUM )&&(line_num < LINE_ACTIVE_NUMBER)) begin
		//		if((gap_between_frame_line == 1'b1)&&(pix_per_whole_line < LINE_ACTIVE_PIX_NUM )&&(line_num_d < LINE_ACTIVE_NUMBER)) begin
		if((gap_between_frame_line == 1'b1)&&(pix_per_whole_line < iv_line_active_pix_num )&&(line_num_less == 1'b1)) begin
			dval	<= 1'b1;
		end else begin
			dval	<= 1'b0;
		end
	end



endmodule
