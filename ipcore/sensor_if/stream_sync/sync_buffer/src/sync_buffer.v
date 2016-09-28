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
//  -- �Ϻ���       :| 2015/10/20 16:59:27	:|  ������ buffer ���ܣ�ȥ��sensor�ӿڲ��ֺͼĴ������Ʋ���
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : ���2��������
//              1)  : Sensor���� ��ʱ����ͬ��
//						������ͬƵ�����ʱ��֮����ͬ������
//              2)  : Sensor �г���������
//						Sensor������г��ź��Ǳ��ض���ģ�����������ͨ����������֮��fval���סlval��ǰ�����10��ʱ��
//              3)  :
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module sync_buffer # (
	parameter					SENSOR_DAT_WIDTH	= 10	,	//sensor ���ݿ��
	parameter					CHANNEL_NUM			= 4		,	//��������ͨ������
	parameter					REG_WD				= 32		//�Ĵ���λ��
	)
	(
	//Sensorʱ����
	input											clk_sensor_pix		,	//sensor���������ʱ��,72Mhz,�뱾��72MhzͬƵ����ͬ�࣬����Ϊ��ȫ�첽�������źţ����sensor��λ��sensorʱ�ӿ���ֹͣ��������ڲ�ʱ�Ӳ�ֹͣ
	input											i_clk_en			,
	input											i_fval				,	//sensor����ĳ���Ч�źţ���clk_sensor_pix�����ض��룬i_fval��������i_lval�½��ض��룬i_fval�½�������i_lval�½��ض���
	input											i_lval				,	//sensor���������Ч�źţ���clk_sensor_pix�����ض��룬i_fval��������i_lval�½��ض��룬i_fval�½�������i_lval�½��ض��룬i_fval��Ч�ڼ�Ҳ�п������
	input	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data			,	//sensor�����ͼ�����ݣ���clk_sensor_pix�����ض��룬��·����10��������
	//�����ź�
	input											i_enable			,	//ʹ���źţ�0-fifo��ʹ�ܣ�1-fifoʹ�ܣ��Ѿ�����������֡����
	//����ʱ����
	input											clk_pix				,	//����ʱ����
	output											o_fval				,	//����Ч��չ��o_fval��o_fval��ǰ���ذ�סl_fvalԼ10��ʱ��
	output											o_lval				,	//����Ч
	output	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data				//ͼ������
	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	���ز���
	//	-------------------------------------------------------------------------------------
	//	localparam			FIFO_BUFFER_TYPE			= "BRAM";	//"BRAM" or "DRAM"��block ram���߷ֲ�ʽram
	localparam			FIFO_BUFFER_TYPE			= "DRAM";	//"BRAM" or "DRAM"��block ram���߷ֲ�ʽram
	localparam			FVAL_EXTEND_VALUE			= 20	;	//FVAL�ܹ�Ҫչ��Ŀ�ȣ�������ʱ��Ϊ��λ
	localparam			EXT_WIDTH					= log2(FVAL_EXTEND_VALUE-1)	;	//fvalչ��������ܹ���Ҫ��λ��

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


	wire	[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		pix_data_wr	;
	wire											lval_wr		;

	reg		[2:0]									fval_shift		= 3'b0;
	wire											fval_rise		;
	wire											fval_fall		;
	reg												fval_reg		= 1'b0;
	reg		[EXT_WIDTH-1:0]							fval_ext_cnt	= (FVAL_EXTEND_VALUE-1);
	wire											fval_extend		;
	wire											reset_fifo		;
	wire											fifo_wr_en		;
	wire	[71:0]									fifo_din		;
	reg												fifo_rd_en		= 1'b0;
	reg		[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		pix_data_reg	= 'b0;
	reg												lval_reg		= 1'b0;
	wire											fifo_full		;
	wire											fifo_prog_empty	;
	wire	[71:0]									fifo_dout		;

	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref ***fval �߼�***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	fval ȡ����
	//	1.�첽ʱ�����䣬��Ҫ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		fval_shift	<= {fval_shift[1:0],i_fval};
	end
	assign	fval_rise	= (fval_shift[2]==1'b0 && fval_shift[1]==1'b1) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_shift[2]==1'b1 && fval_shift[1]==1'b0) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	fval_reg
	//	1.չ��fval���߼�����fval�½�������ʱ��չ��20��ʱ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(i_enable) begin
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
	//	fval_ext_cnt
	//	--��ʹ�ܵ�ʱ�򣬼����������ֵ����������ʼ��֮��Ҳ�����ֵ
	//	--fval�½���֮�󣬼���������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(i_enable==1'b0) begin
			fval_ext_cnt<=FVAL_EXTEND_VALUE-1;
		end
		else begin
			if(fval_fall==1'b1) begin
				fval_ext_cnt	<= 'b0;
			end
			else begin
				if(fval_ext_cnt==(FVAL_EXTEND_VALUE-1)) begin
					fval_ext_cnt	<= fval_ext_cnt;
				end
				else begin
					fval_ext_cnt	<= fval_ext_cnt + 1'b1;
				end
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	��������С�����ֵʱ�� fval_extend ���1
	//	-------------------------------------------------------------------------------------
	assign	fval_extend	= (fval_ext_cnt<(FVAL_EXTEND_VALUE-1)) ? 1'b1 : 1'b0;

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
	assign	reset_fifo	= !i_enable;

	//  -------------------------------------------------------------------------------------
	//	FIFO д
	//	1.��������ʱ���ʱ�򣬾Ϳ���һֱд��
	//	2.fifo��λ��ʱ��fifo������״̬����fifo���븴λ��ʱ�����ź�����
	//  -------------------------------------------------------------------------------------
	assign	fifo_wr_en	= !fifo_full & i_clk_en;

	//	-------------------------------------------------------------------------------------
	//	д��fifo������Ҫ�����볡��Ч���ж�
	//	1.��Ҫ���fvalΪ�ߵ������������fvalΪ��ʱ��lval��ë�̣���ë�̺ܿ���fval���ͻ���ɶ����������
	//	-------------------------------------------------------------------------------------
	assign	pix_data_wr	= (i_fval==1'b1) ? iv_pix_data : {SENSOR_DAT_WIDTH*CHANNEL_NUM{1'b0}};
	assign	lval_wr		= (i_fval==1'b1) ? i_lval : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	FIFO ��
	//	1.��ʹ����Чʱ������ź���Ч֮��,�Ϳ���һֱ��
	//	2.��ʹ����Чʱ�����ź�����Ϊ0
	//	3.����ź�֮��ſ�ʼ������Ϊ�˱�֤�̶�����ʱ���ǵ�fval��lval֮��ľ��뱣����10��ʱ����������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(i_enable) begin
			if(fifo_prog_empty == 1'b0) begin
				fifo_rd_en	<= 1'b1;
			end
		end
		else begin
			fifo_rd_en	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	FIFO ��������
	//	1.FIFO �����ݿ����18bit
	//	2.��lval����bit0��ʣ���bit������
	//  -------------------------------------------------------------------------------------
	assign	fifo_din	= {{(72-SENSOR_DAT_WIDTH*CHANNEL_NUM-1){1'b0}},pix_data_wr[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0],lval_wr};

	//  -------------------------------------------------------------------------------------
	//	���ź����
	//	1.��fval��Ч�ڼ䣬lval�Ǵ�fifo�ж���������
	//	2.��fval��Ч�ڼ䣬lval����Ϊ0
	//	3.fval_reg�ź���ʹ���ź�(i_enable)���ƣ�������������enable���߼�
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
	//	FIFO �������
	//	1.��fval��Ч�ڼ䣬���������Ǵ�fifo�ж���������
	//	2.��fval��Ч�ڼ䣬������������Ϊ0
	//	3.fval_reg�ź���ʹ���ź�(i_enable)���ƣ�������������enable���߼�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(fval_reg==1'b1 && fifo_rd_en==1'b1) begin
			pix_data_reg[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	<= fifo_dout[SENSOR_DAT_WIDTH*CHANNEL_NUM:1];
		end
		else begin
			pix_data_reg[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]	<= {(SENSOR_DAT_WIDTH*CHANNEL_NUM){1'b0}};
		end
	end

	generate
		//  -------------------------------------------------------------------------------------
		//	����FIFO
		//	1.BRAM��ʾBlock Ram��DRAM��ʾDistributed Ram
		//	2.fifo�����18bit�������16��BRAM DRAM ������ˡ�û���õ�18bit�Ŀ�ȣ����ֲ��߽׶λ��Զ��Ż��������˷���Դ��
		//	3.fifo��дʱ���� clk_sensor_pix ��fifo�Ķ�ʱ���� clk_pix ��������ʱ��ͬԴ����
		//  -------------------------------------------------------------------------------------
		if(FIFO_BUFFER_TYPE=="BRAM") begin
			sync_buffer_fifo_bram_w72d32 sync_buffer_fifo_bram_w72d32_inst (
			.rst			(reset_fifo					),
			.wr_clk			(clk_sensor_pix				),
			.wr_en			(fifo_wr_en					),
			.full			(fifo_full					),
			.din			(fifo_din					),
			.rd_clk			(clk_pix					),
			.rd_en			(fifo_rd_en					),
			.empty			(							),
			.prog_empty		(fifo_prog_empty			),
			.dout			(fifo_dout					)
			);
		end
		else if(FIFO_BUFFER_TYPE=="DRAM") begin
			sync_buffer_fifo_dram_w72d32 sync_buffer_fifo_dram_w72d32_inst (
			.rst			(reset_fifo					),
			.wr_clk			(clk_sensor_pix				),
			.wr_en			(fifo_wr_en					),
			.full			(fifo_full					),
			.din			(fifo_din					),
			.rd_clk			(clk_pix					),
			.rd_en			(fifo_rd_en					),
			.empty			(							),
			.prog_empty		(fifo_prog_empty			),
			.dout			(fifo_dout					)
			);
		end
	endgenerate

	assign	ov_pix_data	= pix_data_reg;


endmodule