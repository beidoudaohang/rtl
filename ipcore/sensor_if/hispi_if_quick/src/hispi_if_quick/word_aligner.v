//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : word_aligner
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/10/26 16:54:06	:|  ��ʼ�汾
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

module word_aligner # (
	parameter		SER_FIRST_BIT			= "LSB"		,	//"LSB" or "MSB" , first bit to the receiver
	parameter		DESER_WIDTH				= 6				//�⴮����
	)
	(
	input									clk			,	//���벢��ʱ��
	input									reset		,	//����ʱ����λ�ź�
	input	[DESER_WIDTH-1:0]				iv_data		,	//���벢������
	output									o_clk_en	,	//ʱ��ʹ���ź�
	output									o_sync		,	//�������ݱ�ʶ
	output	[2*DESER_WIDTH-1:0]				ov_data			//�Ѿ�����������
	);

	//	ref signals
	localparam	SYNC_WORD	= {{4*DESER_WIDTH{1'b0}},{2*DESER_WIDTH{1'b1}}};

	reg		[6*DESER_WIDTH-1:0]				din_shift		= {(3*DESER_WIDTH){2'b10}};
	wire	[6*DESER_WIDTH-1:0]				window_0		;
	wire	[6*DESER_WIDTH-1:0]				window_1		;
	wire	[6*DESER_WIDTH-1:0]				window_2		;
	wire	[6*DESER_WIDTH-1:0]				window_3		;
	wire	[6*DESER_WIDTH-1:0]				window_4		;
	wire	[6*DESER_WIDTH-1:0]				window_5		;
	reg										div_cnt			= 1'b0;
	reg										div_cnt_lock	= 1'b0;
	reg										sync_reg		= 1'b0;
	reg										sync_reg_dly0	= 1'b0;
	reg										sync_reg_dly1	= 1'b0;
	reg		[2:0]							window_num		= 3'b0;
	reg		[2*DESER_WIDTH-1:0]				word_align_reg	= {(2*DESER_WIDTH){1'b1}};

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	ʱ�ӷ�Ƶ�����������ڲ���ʱ��ʹ���ź�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			div_cnt	<= 1'b0;
		end
		else begin
			div_cnt	<= div_cnt + 1'b1;
		end
	end
	assign	o_clk_en	= div_cnt;

	//	-------------------------------------------------------------------------------------
	//	24bit��λ�Ĵ���
	//	--����2��word����
	//	--����������lsb�ķ�ʽ�����Ƚ����������ǵ͵��ֽڣ���λ�Ĵ���Ҫ���������ƶ�
	//	--��ü��ϸ�λ�źţ����ͨ��֮�䣬��ͬһʱ�̿�ʼ��λ����λ�ź�Ҫ��clkʱ�����ͬ���ź�
	//	--��λ֮����ȫ1
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			din_shift	<= {(3*DESER_WIDTH){2'b10}};
		end
		else begin
			din_shift	<= {iv_data,din_shift[6*DESER_WIDTH-1:DESER_WIDTH]};
		end
	end

	//	-------------------------------------------------------------------------------------
	//	�ֽڱ߽細��
	//	--�⴮ģ��ÿ�����6bit���ݣ����ֻ��6������
	//	--ʹ���ź� �� �� �ڼ䣬����6�����ڣ���˹���12������
	//	-------------------------------------------------------------------------------------
	assign	window_0	= {iv_data[DESER_WIDTH-1:0],din_shift[6*DESER_WIDTH-1:DESER_WIDTH]};
	assign	window_1	= {iv_data[DESER_WIDTH-2:0],din_shift[6*DESER_WIDTH-1:DESER_WIDTH-1]};
	assign	window_2	= {iv_data[DESER_WIDTH-3:0],din_shift[6*DESER_WIDTH-1:DESER_WIDTH-2]};
	assign	window_3	= {iv_data[DESER_WIDTH-4:0],din_shift[6*DESER_WIDTH-1:DESER_WIDTH-3]};
	assign	window_4	= {iv_data[DESER_WIDTH-5:0],din_shift[6*DESER_WIDTH-1:DESER_WIDTH-4]};
	assign	window_5	= {iv_data[DESER_WIDTH-6:0],din_shift[6*DESER_WIDTH-1:DESER_WIDTH-5]};

	//	-------------------------------------------------------------------------------------
	//	�ж�ͬ����
	//	--ֻҪ��һ��������ͬ����һ����˵��������ھ�������ֱ߽�
	//	--����ô��ڱ�ź͵�ǰ��en״̬
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			window_num		<= 3'd0;
			div_cnt_lock	<= 1'b0;
		end
		else begin
			if(window_0==SYNC_WORD) begin
				window_num		<= 3'd0;
				div_cnt_lock	<= div_cnt;
			end
			else if(window_1==SYNC_WORD) begin
				window_num		<= 3'd1;
				div_cnt_lock	<= div_cnt;
			end
			else if(window_2==SYNC_WORD) begin
				window_num		<= 3'd2;
				div_cnt_lock	<= div_cnt;
			end
			else if(window_3==SYNC_WORD) begin
				window_num		<= 3'd3;
				div_cnt_lock	<= div_cnt;
			end
			else if(window_4==SYNC_WORD) begin
				window_num		<= 3'd4;
				div_cnt_lock	<= div_cnt;
			end
			else if(window_5==SYNC_WORD) begin
				window_num		<= 3'd5;
				div_cnt_lock	<= div_cnt;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	ͬ����֮���ǿ�����
	//	--������ͬ����֮�󣬿���˳��ѿ����ֵ�λ��Ҳ�̶���
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(window_0==SYNC_WORD) begin
			sync_reg		<= 1'b1;
		end
		else if(window_1==SYNC_WORD) begin
			sync_reg		<= 1'b1;
		end
		else if(window_2==SYNC_WORD) begin
			sync_reg		<= 1'b1;
		end
		else if(window_3==SYNC_WORD) begin
			sync_reg		<= 1'b1;
		end
		else if(window_4==SYNC_WORD) begin
			sync_reg		<= 1'b1;
		end
		else if(window_5==SYNC_WORD) begin
			sync_reg		<= 1'b1;
		end
		else if(div_cnt==div_cnt_lock) begin
			sync_reg		<= 1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	��ʱ2��֮�󣬿����ֵ�λ�ú��������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(div_cnt==div_cnt_lock) begin
			sync_reg_dly0	<= sync_reg;
			sync_reg_dly1	<= sync_reg_dly0;
		end
	end
	assign o_sync	= sync_reg_dly1;

	//	-------------------------------------------------------------------------------------
	//	�������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(div_cnt==div_cnt_lock) begin
			case(window_num)
				0		: word_align_reg	<= window_0[4*DESER_WIDTH-1:2*DESER_WIDTH];
				1		: word_align_reg	<= window_1[4*DESER_WIDTH-1:2*DESER_WIDTH];
				2		: word_align_reg	<= window_2[4*DESER_WIDTH-1:2*DESER_WIDTH];
				3		: word_align_reg	<= window_3[4*DESER_WIDTH-1:2*DESER_WIDTH];
				4		: word_align_reg	<= window_4[4*DESER_WIDTH-1:2*DESER_WIDTH];
				5		: word_align_reg	<= window_5[4*DESER_WIDTH-1:2*DESER_WIDTH];
				default	: word_align_reg	<= window_0[4*DESER_WIDTH-1:2*DESER_WIDTH];
			endcase
		end
	end
	assign	ov_data	= word_align_reg;

endmodule
