//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2016 -2020.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : width_cut
//  -- �����       : ������
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- ������       :| 2016/3/28 9:48:27	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ns
//-------------------------------------------------------------------------------------------------
module width_cut #(
	parameter			SENSOR_DAT_WIDTH			= 10					,	//sensor ���ݿ��
	parameter			CHANNEL_NUM					= 8						,	//��������ͨ������
	parameter			SENSOR_MAX_WIDTH			= 1920					,	//Sensor��������Ч��ȣ�������ʱ��Ϊ��λ
	parameter			SHORT_REG_WD				= 16						//�̼Ĵ���λ��
	)
	(
	input											clk						,	//ʱ��
	input											i_fval					,	//���볡�ź�
	input											i_lval					,	//�������ź�
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_data					,	//��������
	input	[SHORT_REG_WD-1:0]						iv_offset_x				,	//ROI��ʼx
	input	[SHORT_REG_WD-1:0]						iv_offset_width			,	//ROI���
	output											o_fval					,	//�������Ч�ź�
	output											o_lval					,	//�������Ч�ź�
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data					//�����������
	);

	//	-------------------------------------------------------------------------------------
	//
	//	-------------------------------------------------------------------------------------
	localparam			SHIFT_WIDTH					= log2(CHANNEL_NUM)		;
	localparam			CNT_WIDTH					= log2(SENSOR_MAX_WIDTH+1);

	reg		[CNT_WIDTH-1:0]							width_cnt	= 'b0		;	//�п�ȼ���
	wire	[CNT_WIDTH-1:0]							offset_x_start			;
	wire	[CNT_WIDTH-1:0]							offset_width			;

	reg		[1:0]									fval_shift	= 'b0		;
	reg												lval_reg	= 'b0		;
	reg		[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		pix_data	= 'b0		;

	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction


	//	===============================================================================================
	//	���ź���ʱ
	//	===============================================================================================
	always @ (posedge clk) begin
		fval_shift <= {fval_shift[0],i_fval};
	end

	assign	o_fval = fval_shift[0];


	//	===============================================================================================
	//	ref ���д���
	//	===============================================================================================
	assign	offset_x_start	= (iv_offset_x >> SHIFT_WIDTH);
	assign	offset_width	= (iv_offset_width >> SHIFT_WIDTH);

	always @ (posedge clk) begin
		if (i_lval==1'b1) begin
			width_cnt <= width_cnt + 1;
		end
		else begin
			width_cnt <= 0;
		end
	end

	always @ (posedge clk) begin
		if (i_fval==1'b1) begin
			if (i_lval==1'b1) begin
				if (width_cnt==(offset_x_start+offset_width)) begin
					lval_reg <= 1'b0;
				end
				else if (width_cnt==offset_x_start) begin
					lval_reg <= 1'b1;
				end
			end
			else begin
				lval_reg <= 1'b0;
			end
		end
		else begin
			lval_reg <= 1'b0;
		end
	end

	assign	o_lval	= lval_reg;


	//	===============================================================================================
	//	������ʱ
	//	===============================================================================================
	always @ (posedge clk) begin
		pix_data <= iv_data;
	end

	assign	ov_pix_data	= pix_data;



endmodule