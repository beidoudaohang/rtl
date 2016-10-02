//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : sync_buffer
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/12/4 16:54:58	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : ���3��������
//              1)  : Sensor���� ��ʱ����ͬ��
//						������ͬƵ�����ʱ��֮����ͬ������
//              2)  : Sensor �г���������
//						Sensor������г��ź��Ǳ��ض���ģ�����������ͨ������������֮��fval���סlval��ǰ�����10��ʱ��
//              3)  : �Ĵ�����Чʱ��
//						����ͨ�����õļĴ�������Ҫ�����ģ��������Чʱ�����������fval������ʱ�������Ĵ���
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module sync_buffer # (
	parameter					SENSOR_DAT_WIDTH	= 10	,	//sensor ���ݿ���
	parameter					REG_WD				= 32		//�Ĵ���λ��
	)
	(
	//Sensorʱ����
	input								clk_sensor_pix		,	//sensor���������ʱ��,72Mhz,�뱾��72MhzͬƵ����ͬ�࣬����Ϊ��ȫ�첽�������źţ����sensor��λ��sensorʱ�ӿ���ֹͣ��������ڲ�ʱ�Ӳ�ֹͣ
	input								i_fval				,	//sensor����ĳ���Ч�źţ���clk_sensor_pix�����ض��룬i_fval��������i_lval�½��ض��룬i_fval�½�������i_lval�½��ض���
	input								i_lval				,	//sensor���������Ч�źţ���clk_sensor_pix�����ض��룬i_fval��������i_lval�½��ض��룬i_fval�½�������i_lval�½��ض��룬i_fval��Ч�ڼ�Ҳ�п������
	input	[SENSOR_DAT_WIDTH-1:0]		iv_pix_data			,	//sensor�����ͼ�����ݣ���clk_sensor_pix�����ض��룬��·����10��������
	//�Ĵ�������
	input								i_acquisition_start	,	//�����źţ�0-ͣ�ɣ�1-����
	input								i_stream_enable		,	//��ʹ���ź�
	input								i_encrypt_state		,	//����ͨ·�����dna ʱ���򣬼���״̬�����ܲ�ͨ���������ͼ��
	input	[REG_WD-1:0]				iv_pixel_format		,	//���ظ�ʽ�Ĵ���
	input	[2:0]						iv_test_image_sel	,	//����ͼѡ��Ĵ���,000:��ʵͼ,001:����ͼ��1�Ҷ�ֵ֡����,110:����ͼ��2��ֹ��б����,010:����ͼ��3������б����
	output								o_full_frame_state	,	//����֡״̬,�üĴ���������֤ͣ��ʱ�������֡,0:ͣ��ʱ���Ѿ�������һ֡����,1:ͣ��ʱ�����ڴ���һ֡����
	output	[REG_WD-1:0]				ov_pixel_format		,	//��sync buffer������Чʱ������
	output	[2:0]						ov_test_image_sel	,	//��sync buffer������Чʱ������
	//����ʱ����
	input								clk_pix				,	//����ʱ����
	output								o_fval				,	//����Ч��չ��o_fval��o_fval��ǰ���ذ�סl_fvalԼ10��ʱ��
	output								o_lval				,	//����Ч
	output	[SENSOR_DAT_WIDTH-1:0]		ov_pix_data				//ͼ������
	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	���ز���
	//	1.Sensor��������Ĭ�ϲ�ʹ��idelay���ڣ���Ϊ�ⲿ��·��ʱ�Ѿ����úܺ�
	//	2.Sensor��������idelay ��ֵĬ��Ϊ0
	//	3.��ʱ����ת����FIFO������ѡ��BRAM����DRAM������18�����16��
	//	-------------------------------------------------------------------------------------
	localparam			SENSOR_DAT_IDELAY_EN		= 0		;	//idelayʹ��
	localparam			SENSOR_DAT_IDELAY_VALUE		= 0		;	//idelay��ʱֵ
	localparam			FIFO_BUFFER_TYPE			= "BRAM";	//"BRAM" or "DRAM"��block ram���߷ֲ�ʽram


	wire	[SENSOR_DAT_WIDTH-1:0]			wv_pix_data_delay	;
	wire									w_fval_delay	;
	wire									w_lval_delay	;
	wire									clk_sensor_pix_bufg_inv	;

	reg		[SENSOR_DAT_WIDTH-1:0]			pix_data_iob	= 8'b0;
	reg										fval_iob		= 1'b0;
	reg										lval_iob		= 1'b0;
	wire	[SENSOR_DAT_WIDTH-1:0]			pix_data_iob_wr	;
	wire									lval_iob_wr		;

	reg		[2:0]							fval_shift		= 3'b0;
	wire									fval_rise		;
	wire									fval_fall		;
	reg										fval_reg		= 1'b0;
	reg		[4:0]							delay_20_cnt	= 5'd19;
	wire									fval_extend		;
	reg										enable			= 1'b0;
	reg										encrypt_state_dly0	= 1'b0;
	reg										encrypt_state_dly1	= 1'b0;
	wire									reset_fifo		;
	wire									fifo_wr_en		;
	wire	[17:0]							fifo_din		;
	reg										fifo_rd_en		= 1'b0;
	reg		[SENSOR_DAT_WIDTH-1:0]			pix_data_reg	= 8'b0;
	reg										lval_reg		= 1'b0;
	wire									fifo_full		;
	wire									fifo_prog_empty	;
	wire	[17:0]							fifo_dout		;

	reg										full_frame_state	= 1'b0;
	reg		[REG_WD-1:0]					pixel_format_reg	= {REG_WD{1'b0}};
	reg		[2:0]							test_image_sel_reg	= 3'b000;




	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***����Sensor����***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	�����ʱ�� ���� ͬ���ź� ��idelay��ʱ ѡ���Ա����ģ��
	//  -------------------------------------------------------------------------------------
	idelay_top # (
	.SENSOR_DAT_WIDTH			(SENSOR_DAT_WIDTH			),
	.SENSOR_DAT_IDELAY_EN		(SENSOR_DAT_IDELAY_EN		),
	.SENSOR_DAT_IDELAY_VALUE	(SENSOR_DAT_IDELAY_VALUE	)
	)
	idelay_top_inst (
	.iv_pix_data				(iv_pix_data		),
	.i_fval						(i_fval				),
	.i_lval						(i_lval				),
	.ov_pix_data_delay			(wv_pix_data_delay	),
	.o_fval_delay				(w_fval_delay		),
	.o_lval_delay				(w_lval_delay		)
	);

	//  -------------------------------------------------------------------------------------
	//	��·ʱ����ȫ��ʱ����Դ���壬ȫ�ֻ�����֮�������������Է���ʱ���������źŵ�skew
	//  -------------------------------------------------------------------------------------
	BUFG bufg_inst (
	.I	(clk_sensor_pix			),
	.O	(clk_sensor_pix_bufg	)
	);
	assign	clk_sensor_pix_bufg_inv	= !clk_sensor_pix_bufg;

	//  -------------------------------------------------------------------------------------
	//	��IOB��ʹ��register���������԰���ʱ���������������λ��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_sensor_pix_bufg_inv) begin
		pix_data_iob	<= wv_pix_data_delay;
		fval_iob		<= w_fval_delay;
		lval_iob		<= w_lval_delay;
	end

	//  ===============================================================================================
	//	ref ***fval �߼�***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	fval ȡ����
	//	1.�첽ʱ�����䣬��Ҫ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		fval_shift	<= {fval_shift[1:0],fval_iob};
	end
	assign	fval_rise	= (fval_shift[2]==1'b0 && fval_shift[1]==1'b1) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_shift[2]==1'b1 && fval_shift[1]==1'b0) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	fval_reg
	//	1.չ��fval���߼�����fval�½�������ʱ��չ��20��ʱ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(enable) begin
			if(fval_rise) begin
				fval_reg	<= 1'b1;
			end
			else if(!fval_shift[2]) begin
				fval_reg	<= fval_extend;
			end
		end
		else begin
			fval_reg	<= 1'b0;
		end
	end
	assign	o_fval	= fval_reg;

	//  -------------------------------------------------------------------------------------
	//	delay_20_cnt
	//	fval�½���֮����ʱ20��ʱ�����ڵļ�����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(enable==1'b0) begin
			delay_20_cnt<=5'd19;
		end
		else begin
			if(fval_fall==1'b1) begin
				delay_20_cnt	<= 5'b0;
			end
			else begin
				if(delay_20_cnt==5'd19) begin
					delay_20_cnt	<= delay_20_cnt;
				end
				else begin
					delay_20_cnt	<= delay_20_cnt + 1'b1;
				end
			end
		end
	end
	assign	fval_extend	= (delay_20_cnt<5'd19) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	enable ����֡ʹ�ܿ����ź�
	//	1.��o_fval��fval_shift[1]���ǵ͵�ƽʱ������enable�Ĵ�����enable=���������ź������״̬������
	//	2.��o_fval��fval_shift[1]������1���ߵ�ƽʱ������enable�Ĵ�������֤����֡
	//	3.fval_shift[1]=1 o_fval=0ʱ����һ��ʱ�����ڣ�o_fval=1����ʱ������������֡�жϣ���Ϊ��һ�����ڿ϶������fval
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(fval_shift[1]==1'b0 && fval_reg==1'b0) begin
			enable	<= i_stream_enable & i_acquisition_start & encrypt_state_dly1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	����״̬ͬ��
	//	1.i_encrypt_state�� osc bufgʱ������źţ����β���ͨ����pixʱ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		encrypt_state_dly0	<= i_encrypt_state;
		encrypt_state_dly1	<= encrypt_state_dly0;
	end

	//  ===============================================================================================
	//	ref ***FIFO ����***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref FIFO ����д����λ������
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	FIFO ��λ
	//	1.��ʹ����Чʱ����λfifo
	//  -------------------------------------------------------------------------------------
	assign	reset_fifo	= !enable;

	//  -------------------------------------------------------------------------------------
	//	FIFO д
	//	1.��������ʱ���ʱ�򣬾Ϳ���һֱд��
	//	2.fifo��λ��ʱ��fifo������״̬����fifo���븴λ��ʱ�����ź�����
	//  -------------------------------------------------------------------------------------
	assign	fifo_wr_en	= !fifo_full;

	//	-------------------------------------------------------------------------------------
	//	д��fifo������Ҫ�����볡��Ч���ж�
	//	1.��Ҫ����fvalΪ�ߵ������������fvalΪ��ʱ��lval��ë�̣���ë�̺ܿ���fval���ͻ���ɶ����������
	//	-------------------------------------------------------------------------------------
	assign	pix_data_iob_wr	= (fval_iob==1'b1) ? pix_data_iob : {SENSOR_DAT_WIDTH{1'b0}};
	assign	lval_iob_wr		= (fval_iob==1'b1) ? lval_iob : 1'b0;
	
	//  -------------------------------------------------------------------------------------
	//	FIFO ��������
	//	1.FIFO �����ݿ�����18bit
	//	2.��lval����bit0��ʣ���bit������
	//  -------------------------------------------------------------------------------------
	assign	fifo_din	= {{(18-SENSOR_DAT_WIDTH-1){1'b0}},pix_data_iob_wr,lval_iob_wr};

	//  -------------------------------------------------------------------------------------
	//	FIFO ��
	//	1.��ʹ����Чʱ������ź���Ч֮��,�Ϳ���һֱ��
	//	2.��ʹ����Чʱ�����ź�����Ϊ0
	//	3.����ź�֮��ſ�ʼ������Ϊ�˱�֤�̶�����ʱ���ǵ�fval��lval֮��ľ��뱣����10��ʱ����������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(enable) begin
			if(fifo_prog_empty == 1'b0) begin
				fifo_rd_en	<= 1'b1;
			end
		end
		else begin
			fifo_rd_en	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	FIFO �������
	//	1.��fval��Ч�ڼ䣬���������Ǵ�fifo�ж���������
	//	2.��fval��Ч�ڼ䣬������������Ϊ0
	//	3.fval_reg�ź���ʹ���ź�(enable)���ƣ��������������enable���߼�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(fval_reg==1'b1 && fifo_rd_en==1'b1) begin
			pix_data_reg	<= fifo_dout[SENSOR_DAT_WIDTH:1];
		end
		else begin
			pix_data_reg	<= {SENSOR_DAT_WIDTH{1'b0}};
		end
	end
	assign	ov_pix_data	= pix_data_reg;

	//  -------------------------------------------------------------------------------------
	//	���ź����
	//	1.��fval��Ч�ڼ䣬lval�Ǵ�fifo�ж���������
	//	2.��fval��Ч�ڼ䣬lval����Ϊ0
	//	3.fval_reg�ź���ʹ���ź�(enable)���ƣ��������������enable���߼�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(fval_reg==1'b1 && fifo_rd_en==1'b1) begin
			lval_reg	<= fifo_dout[0];
		end
		else begin
			lval_reg	<= 1'b0;
		end
	end
	assign	o_lval	= lval_reg;

	//  -------------------------------------------------------------------------------------
	//	--ref ����FIFO
	//	1.BRAM��ʾBlock Ram��DRAM��ʾDistributed Ram
	//	2.fifo������18bit�������16��BRAM DRAM ������ˡ�û���õ�18bit�Ŀ��ȣ����ֲ��߽׶λ��Զ��Ż��������˷���Դ��
	//	3.fifo��дʱ���� clk_sensor_pix_bufg_inv ��fifo�Ķ�ʱ���� clk_pix ��������ʱ��ͬԴ����
	//  -------------------------------------------------------------------------------------
	generate
		if(FIFO_BUFFER_TYPE=="BRAM") begin
			sync_buffer_fifo_bram_w18d16 sync_buffer_fifo_bram_w18d16_inst (
			.rst			(reset_fifo					),
			.wr_clk			(clk_sensor_pix_bufg_inv	),
			.wr_en			(fifo_wr_en					),
			.full			(fifo_full					),
			.din			(fifo_din					),
			.rd_clk			(clk_pix					),
			.rd_en			(fifo_rd_en					),
			.empty			(					),
			.prog_empty		(fifo_prog_empty			),
			.dout			(fifo_dout					)
			);
		end
		else if(FIFO_BUFFER_TYPE=="DRAM") begin
			sync_buffer_fifo_dram_w18d16 sync_buffer_fifo_dram_w18d16_inst (
			.rst			(reset_fifo					),
			.wr_clk			(clk_sensor_pix_bufg_inv	),
			.wr_en			(fifo_wr_en					),
			.full			(fifo_full					),
			.din			(fifo_din					),
			.rd_clk			(clk_pix					),
			.rd_en			(fifo_rd_en					),
			.empty			(					),
			.prog_empty		(fifo_prog_empty			),
			.dout			(fifo_dout					)
			);
		end
	endgenerate

	//  ===============================================================================================
	//	ref ***��־���Ĵ�������***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	-- ref ����֡��־
	//	1.�� i_stream_enable=0ʱ����������֡��־
	//	2.�� o_fval=0ʱ����������֡��־
	//	3.�� o_fval=1��i_acquisition_start=0ʱ����������֡��λ
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(!i_stream_enable) begin
			full_frame_state	<= 1'b0;
		end
		else if(!fval_reg) begin
			full_frame_state	<= 1'b0;
		end
		else begin
			if(fval_reg==1'b1 && i_acquisition_start==1'b0) begin
				full_frame_state	<= 1'b1;
			end
		end
	end
	assign	o_full_frame_state	= full_frame_state;

	//  -------------------------------------------------------------------------------------
	//	-- ref �Ĵ�����Чʱ������
	//	1.��fval_rise=1����һ֡����ʱ�����¼Ĵ���
	//	2.����ʱ�̣��������ظ�ʽ�Ĵ���
	//	3.��Щ�Ĵ�������������ͨ���в�ֹһ��ģ��ʹ�ã����Ҫ������ͨ������ǰ�˿���
	//  -------------------------------------------------------------------------------------
	//  -------------------------------------------------------------------------------------
	//	���ظ�ʽ�Ĵ���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(fval_rise) begin
			pixel_format_reg	<= iv_pixel_format;
		end
	end
	assign	ov_pixel_format		= pixel_format_reg;

	//  -------------------------------------------------------------------------------------
	//	����ͼѡ��Ĵ���
	//	���д����ǷǷ�ֵ��������һ�εĽ��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(fval_rise) begin
			if(iv_test_image_sel==3'b000 || iv_test_image_sel==3'b001 || iv_test_image_sel==3'b110 || iv_test_image_sel==3'b010) begin
				test_image_sel_reg	<= iv_test_image_sel;
			end
		end
	end
	assign	ov_test_image_sel		= test_image_sel_reg;


endmodule