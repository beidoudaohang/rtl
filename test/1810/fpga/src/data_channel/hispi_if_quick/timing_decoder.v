//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : timing_decoder
//  -- �����       : �ܽ�
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �ܽ�       :| 2015/08/11 13:46:45	:|  ��ʼ�汾
//  -- �Ϻ���       :| 2015/10/27 13:13:44	:|  ��Ϊ��һ֡�ܹ���ͼ�İ汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : HiSPi���ݴ���ģ��
//              1)  : ���ͬ����
//
//              2)  : ����fval��lval��pixel_data�ź�,fval��lval��ʱ�����Ǳ��ض����
//				fval:____|--------------------------------------------|_____
//				lval:____|----|____|----|____|----|____|----|____|----|_____
//				data:____|<-->|____|<-->|____|<-->|____|<-->|____|<-->|_____
//
//				3)	: ģ�鲻���ǲ�֡�����������Ч���ݱ�����4�ı���
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ns
//-------------------------------------------------------------------------------------------------
module timing_decoder #(
	parameter		SER_FIRST_BIT			= "LSB"				,	//"LSB" or "MSB" , first bit to the receiver
	parameter		SENSOR_DAT_WIDTH		= 12				,
	parameter		CHANNEL_NUM				= 4					,
	//ADD
	parameter		TD_OFFSET_WIDTH			= 13
	//
	)
	(
	input												clk					,	//ʱ��
	input												reset				,	//��λ�ź�
	input												i_clk_en			,	//ʱ��
	input												i_sync				,	//���������ǿ�����
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]			iv_data				,	//ͨ��1��������
	output												o_first_frame_detect,	//��⵽��һ������֡
	output												o_clk_en			,
	output												o_fval				,	//�������Ч�ź�
	output												o_lval				,	//�������Ч�ź�
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]			ov_pix_data		 		//�����������
	);

	//	-------------------------------------------------------------------------------------
	//	hispi �Ĺؼ���
	//	-------------------------------------------------------------------------------------
	localparam					SOF	= {{(SENSOR_DAT_WIDTH-4){1'b0}},4'b0011};
	localparam					SOL	= {{(SENSOR_DAT_WIDTH-4){1'b0}},4'b0001};
	localparam					EOF	= {{(SENSOR_DAT_WIDTH-4){1'b0}},4'b0111};
	localparam					EOL	= {{(SENSOR_DAT_WIDTH-4){1'b0}},4'b0101};

	localparam					SHIFT_WIDTH	= log2(CHANNEL_NUM)	;

	wire	[SENSOR_DAT_WIDTH-1:0]				wv_data_lane[CHANNEL_NUM-1:0]	;	//������ϵ�ͨ��1������
	reg		[SENSOR_DAT_WIDTH*3-1:0]			data_lane0_shift		= 'b0	;	//lan0ͨ����λ�Ĵ���
	reg											first_frame_detect		= 1'b0	;//��һ�μ�⵽֡ͷ��־

	reg											lval_reg				= 1'b0	;
	reg											fval_reg				= 1'b0	;
	reg											clk_en_dly				= 1'b0	;
	wire										sof_flag				;//SOF��־
	wire										eol_flag				;//EOL��־
	wire										sol_flag				;//SOL��־
	wire										eof_flag				;//EOF��־
	reg		[SENSOR_DAT_WIDTH-1:0]				data_lane_output_dly0[CHANNEL_NUM-1:0]	;	//������ϵ�ͨ��1������
	reg		[SENSOR_DAT_WIDTH-1:0]				data_lane_output_dly1[CHANNEL_NUM-1:0]	;	//������ϵ�ͨ��1������
	reg		[SENSOR_DAT_WIDTH-1:0]				data_lane_output_dly2[CHANNEL_NUM-1:0]	;	//������ϵ�ͨ��1������
	reg		[SENSOR_DAT_WIDTH-1:0]				data_lane_output_dly3[CHANNEL_NUM-1:0]	;	//������ϵ�ͨ��1������


	//ADD
	reg											lval_roi				= 1'b0	;	//����Ч�����ź�
	reg		[TD_OFFSET_WIDTH-1:0]				width_cnt				=  'b0	;	//�п�ȼ���
	reg		[TD_OFFSET_WIDTH-1:0]				td_offset_x_start		=  'b0	;
	reg		[TD_OFFSET_WIDTH-1:0]				td_offset_width			=  'b0	;
	//

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
	//	ref ***�첽ʱ������***
	//	===============================================================================================
	//	===============================================================================================
	//	ref ***���ؼ���***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	����ͨ��
	//	--ÿ��ͨ����λ���� RATIO ��bit
	//	--��ˣ���ߵ�ͨ���ڵ�byte��С�ˣ���͵�ͨ���ڵ�byte��
	//	-------------------------------------------------------------------------------------
	genvar	i;
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			assign	wv_data_lane[i]	= iv_data[SENSOR_DAT_WIDTH*(i+1)-1:SENSOR_DAT_WIDTH*i];
		end
	endgenerate

	//----------------------------------------------------------------------------------------
	//���SOF��SOL��EOF��EOL��־
	//----------------------------------------------------------------------------------------
	assign	sof_flag	= (wv_data_lane[0]==SOF && i_sync==1'b1) ? 1'b1 : 1'b0;
	assign	sol_flag	= (wv_data_lane[0]==SOL && i_sync==1'b1) ? 1'b1 : 1'b0;
	assign	eof_flag	= (wv_data_lane[0]==EOF && i_sync==1'b1) ? 1'b1 : 1'b0;
	assign	eol_flag	= (wv_data_lane[0]==EOL && i_sync==1'b1) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	��⵽ sof
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(reset) begin
			first_frame_detect	<=	1'b0;
		end
		else if(!first_frame_detect)begin
			if(sof_flag) begin
				first_frame_detect	<=	1'b1;
			end
		end
	end
	assign	o_first_frame_detect	= first_frame_detect;

	//	===============================================================================================
	//	ref ***���***
	//	===============================================================================================

	reg		[3:0]		sof_flag_shift	= 4'b0;
	reg		[3:0]		sol_flag_shift	= 4'b0;
	always @ (posedge clk) begin
		if(i_clk_en==1'b1) begin
			sof_flag_shift	<= {sof_flag_shift[2:0],sof_flag};
			sol_flag_shift	<= {sol_flag_shift[2:0],sol_flag};
		end
	end





	//	-------------------------------------------------------------------------------------
	//	�������ź�		//CHANGED
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			lval_reg	<=	1'b0;
		end
		else begin
			if(i_clk_en==1'b1) begin
				if(sof_flag_shift[3] | sol_flag_shift[3]) begin	//CHANGED
					lval_reg	<=	1'b1;
				end
				else if(eof_flag | eol_flag) begin	//CHANGED
					lval_reg	<=	1'b0;
				end
			end
		end
	end


	assign	o_lval	= lval_reg;

	//	-------------------------------------------------------------------------------------
	//	�������ź�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			fval_reg	<=	1'b0;
		end
		else begin
			if(i_clk_en==1'b1) begin
				if(sof_flag_shift[3]) begin
					fval_reg	<=	1'b1;
				end
				else if(eof_flag)
				fval_reg	<=	1'b0;
			end
		end
	end
	assign	o_fval	= fval_reg;

	//	-------------------------------------------------------------------------------------
	//	ʱ�ӷ�Ƶʹ��
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		clk_en_dly	<= i_clk_en;
	end
	assign	o_clk_en	= clk_en_dly;

	//	-------------------------------------------------------------------------------------
	//	δ����ʱ���������Ϊȫ1
	//	-------------------------------------------------------------------------------------
	genvar	j;
	generate
		for(j=0;j<CHANNEL_NUM;j=j+1) begin
			always @ (posedge clk)begin
				if(i_clk_en==1'b1) begin
					data_lane_output_dly0[j]	<= wv_data_lane[j];
					data_lane_output_dly1[j]	<= data_lane_output_dly0[j];
					data_lane_output_dly2[j]	<= data_lane_output_dly1[j];
					data_lane_output_dly3[j]	<= data_lane_output_dly2[j];
				end
			end
		end
	endgenerate

	//	-------------------------------------------------------------------------------------
	//	������������ݣ����ִ�С��
	//	-------------------------------------------------------------------------------------
	genvar	l;
	generate
		for(l=0;l<CHANNEL_NUM;l=l+1) begin
			assign	ov_pix_data[(l+1)*SENSOR_DAT_WIDTH-1:l*SENSOR_DAT_WIDTH]	= data_lane_output_dly3[l];
		end
	endgenerate

endmodule