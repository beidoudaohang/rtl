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
//	-- �ܽ�		��
//	-- ����ǿ		��2016/8/1 14:24:51		��| 1.�޸Ķ�ʹ���źţ���ֹ���� 2.����ע��
//	-- ����ǿ		��2016/8/2 9:58:38		��| 1.Դ�����У��и���i_fval�ߵ;�������fifo�������Ƿ���Ч��ѡ����ƣ��Դ�������ë�̣����������i_fval��Ϊfifoдʹ�ܵı�־λ���������ѡ����ƿ���ȥ����
//											  | 2.�������ָʾ��־wrong_status
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
	parameter					SENSOR_DAT_WIDTH	= 12	,	//sensor ���ݿ��
	parameter					PHY_CH_NUM			= 4		,	//ÿ·HiSPi PHY����ͨ��������
	parameter					PHY_NUM				= 2			//HiSPi PHY������
	)
	(
	//Sensorʱ����
	input	[PHY_NUM-1:0]								clk_recover			,	//sensor�ָ�ʱ��
	input	[PHY_NUM-1:0]								reset_recover		,	//sensor�ָ�ʱ�ӵĸ�λ�ź�
	input	[PHY_NUM-1:0]								iv_clk_en			,	//ʱ��ʹ���ź�
	input	[PHY_NUM-1:0]								iv_fval				,	//sensor����ĳ���Ч�źţ���clk_sensor_pix�����ض��룬iv_fval��������iv_lval�½��ض��룬iv_fval�½�������iv_lval�½��ض���
	input	[PHY_NUM-1:0]								iv_lval				,	//sensor���������Ч�źţ���clk_sensor_pix�����ض��룬iv_fval��������iv_lval�½��ض��룬iv_fval�½�������iv_lval�½��ض��룬iv_fval��Ч�ڼ�Ҳ�п������
	input	[SENSOR_DAT_WIDTH*PHY_NUM*PHY_CH_NUM-1:0]	iv_pix_data			,	//sensor�����ͼ�����ݣ���clk_sensor_pix�����ض���
	//�����ź�
	input												i_fifo_reset		,	//�ڲ�fifo��λ�ź�
	//����ʱ����
	input												clk_pix				,	//����ʱ����
	output												o_fval				,	//����Ч��չ��o_fval��o_fval��ǰ���ذ�סl_fvalԼ20����ʱ��
	output												o_lval				,	//����Ч
	output	[SENSOR_DAT_WIDTH*PHY_NUM*PHY_CH_NUM-1:0]	ov_pix_data			,	//ͼ������
	output												o_sync_buffer_error			//����������ţ�����ͬ��phy��������lval��ͬʱ��������1
	);


	//	-------------------------------------------------------------------------------------
	//	���ز���
	//	-------------------------------------------------------------------------------------
	localparam			CHANNEL_NUM					=	PHY_NUM*PHY_CH_NUM			;
	localparam			FVAL_EXTEND_VALUE			= 	50							;	//FVAL�ܹ�Ҫչ��Ŀ�ȣ�������ʱ��Ϊ��λ
	localparam			EXT_WIDTH					= 	log2(FVAL_EXTEND_VALUE-1+1)	;	//fvalչ��������ܹ���Ҫ��λ��

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


	wire	[SENSOR_DAT_WIDTH*PHY_CH_NUM-1:0]		pix_data_wr		[PHY_NUM-1:0]			;//��д��fifo����������
	wire	[PHY_NUM-1:0]							lval_wr									;//��д��fifo�����ź�

	reg		[2:0]									fval_shift		= 3'b0					;//֡�źŴ��ļĴ�
	wire											fval_rise								;//֡�ź������ر�־λ
	wire											fval_fall								;//֡�ź��½��ر�־λ
	reg												fval_reg		= 1'b0					;//չ����֡�ź�
	reg		[EXT_WIDTH-1:0]							fval_ext_cnt	= (FVAL_EXTEND_VALUE-1)	;//֡�ź�չ�������
	wire											fval_extend								;//֡�ź�չ����
	wire	[PHY_NUM-1:0]							reset_fifo								;//fifo��λ�ź�
	wire	[PHY_NUM-1:0]							fifo_wr_en								;//fifoдʹ��
	wire	[SENSOR_DAT_WIDTH*PHY_CH_NUM:0]			fifo_din		[PHY_NUM-1:0]			;//fifo�������ݣ������������ݺ�lval�ϲ�����ź�
	reg												fifo_rd_en		= 1'b0					;//fifo���ź�
	wire											w_fifo_rd_en							;//w_fifo_rd_en��fifo_rd_en��ǰһ���������ͣ���ֹ����
	reg		[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		pix_data_reg	= 'b0					;//����·phy �ܹ�8·���ݺϲ�����ź�{pix0 pix1����pix7}
	reg												lval_reg		= 1'b0					;//��fifo����������ź�
	wire	[PHY_NUM-1:0]							fifo_full								;//fifo����־λ����Fifo�ڲ����ɣ��ڶ�����ʱ����0���ܻ����ͺ�
	wire	[PHY_NUM-1:0]							fifo_prog_empty							;//fifo��̿ձ�־λ��д����ʱ����0���ܻ����ͺ�
	wire	[PHY_NUM-1:0]							fifo_empty								;//fifo�ձ�־λ��д����ʱ����0���ܻ����ͺ�
	wire	[SENSOR_DAT_WIDTH*PHY_CH_NUM:0]			fifo_dout		[PHY_NUM-1:0]			;//fifo������ݣ������������ݺ�lval�ϲ�����ź�
	wire	[PHY_NUM-1:0]							lval_mul								;//fifo�����ÿ��Phy��lval
	reg												wrong_status	= 1'b0					;//����ָʾ��־

	//  ===============================================================================================
	//	ref ***fval �߼�***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	fval ȡ����
	//	1.�첽ʱ�����䣬��Ҫ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		fval_shift	<= {fval_shift[1:0],iv_fval[0]};
	end
	assign	fval_rise	= (fval_shift[2:1] == 2'b01) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_shift[2:1] == 2'b10) ? 1'b1 : 1'b0;

	//  -------------------------------------------------------------------------------------
	//	fval_reg
	//	1.չ��fval���߼�����fval�½�������ʱ��չ��50��ʱ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
		if(fval_rise) begin
			fval_reg	<= 1'b1;
		end
		else if(!fval_shift[2]) begin
			fval_reg	<= fval_extend;
		end
	end
	assign	o_fval	= fval_reg;

	//  -------------------------------------------------------------------------------------
	//	fval_ext_cnt
	//	fval�½��ظ�λ������ʱ�̼�����FVAL_EXTEND_VALUE
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk_pix) begin
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

	//	-------------------------------------------------------------------------------------
	//	��������С�����ֵʱ�� fval_extend ���1
	//	-------------------------------------------------------------------------------------
	assign	fval_extend	= (fval_ext_cnt<(FVAL_EXTEND_VALUE-1)) ? 1'b1 : 1'b0;

	//  ===============================================================================================
	//	ref ***FIFO ����***
	//  ===============================================================================================
	genvar	i;
	generate
		for(i=0;i<PHY_NUM;i=i+1)begin
			//  -------------------------------------------------------------------------------------
			//	-ref FIFO ��λ
			//	1.���ָ�ʱ�Ӹ�λ����ǿ�Ƹ�λ��ʱ�򣬸�λ�ڲ�fifo
			//  -------------------------------------------------------------------------------------
			assign	reset_fifo[i]	= reset_recover[i] | i_fifo_reset;
			//  -------------------------------------------------------------------------------------
			//	-ref FIFO дʹ��
			//	д��Ҫ�߱���������
			//	1.fifo���� 2.����i_fval��Ч 3.�⴮ʱ����Ч
			//  -------------------------------------------------------------------------------------
			assign	fifo_wr_en[i]	= !fifo_full[i] & iv_fval[i] & iv_clk_en[i];
			//	-------------------------------------------------------------------------------------
			//	-ref FIFO ��������
			//	1.FIFO �����ݿ����49bit
			//	2.��lval����bit0��ʣ���bit�����ݸ�λ
			//	-------------------------------------------------------------------------------------
			assign	pix_data_wr[i]	= iv_pix_data[SENSOR_DAT_WIDTH*PHY_CH_NUM*(i+1)-1:SENSOR_DAT_WIDTH*PHY_CH_NUM*i];
			assign	lval_wr[i]		= iv_lval[i] ;
			assign	fifo_din[i]		= {pix_data_wr[i],lval_wr[i]};
			//  -------------------------------------------------------------------------------------
			//	����FIFO
			//	1.BRAM��ʾBlock Ram
			//	2.fifo�����49bit�������64
			//	3.FIFO����Ϊfirst-word fall-through
			//	4.fifo��дʱ���� clk_recover ��fifo�Ķ�ʱ���� clk_pix ��������ʱ��ͬԴ����
			//  -------------------------------------------------------------------------------------
			sync_buffer_fifo_bram_w49d64_pe20 sync_buffer_fifo_bram_w49d64_pe20_inst (
			.rst			(reset_fifo[i]				),
			.wr_clk			(clk_recover[i]				),
			.wr_en			(fifo_wr_en[i]				),
			.full			(fifo_full[i]				),
			.din			(fifo_din[i]				),
			.rd_clk			(clk_pix					),
			.rd_en			(w_fifo_rd_en				),
			.empty			(fifo_empty[i]				),
			.prog_empty		(fifo_prog_empty[i]			),
			.dout			(fifo_dout[i]				)
			);
		end
	endgenerate
			//  -------------------------------------------------------------------------------------
			//	FIFO ��
			//	ʱ������
			//	pix_clk			:__|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|_|-|
			//	fifo_empty		:------|_________________________|----
			//	fifo_prog_empty	:--------------|_________|-----------
			//	fifo_rd_en		:__________________|-----------------|________
			//	w_fifo_rd_en	:__________________|-------------|____________
			//	o_lval			:______________________|-------------|________
			//	ov_pix_data		:______________________|vvvvvvvvvvvvv|________
			//  -------------------------------------------------------------------------------------
			//	-ref fifo��ʹ��
			//	1.��fifo���۵��Ǳ�̿�ʱ��ʼ������Ϊ��д������������ʱ�������ӳ٣����Դ�ʱ��ʵ���������Ѿ����ڷǱ�̿յ��趨ֵ��������20��
			//	2.��FIFO��ʱ������������Ϊ��дʱ���ٶ���ͬ������fifo���ֿգ�˵��д�����Ѿ�ֹͣ���������ˣ���ʱfifo�ձ�־λָʾ׼ȷ��fifo���Ѿ�û�������ˣ�
			//	3.����־λ����always��ֵ��fifo_rd_en���empty�ź��Ӻ�һ�����ڣ�����ֶ������⣬��Ҫ��fifo_rd_en��ǿ��ź�����
			//  -------------------------------------------------------------------------------------
			always @ (posedge clk_pix) begin
				//ÿ��phy�����۵��㹻�������ʼ��
				if(fifo_prog_empty == {PHY_NUM{1'b0}}) begin
					fifo_rd_en	<= 1'b1;
				end
				//����phy����ʱ�Ž�����
				else if(fifo_empty == {PHY_NUM{1'b1}})begin
					fifo_rd_en	<= 1'b0;
				end
			end
			assign	w_fifo_rd_en = fifo_rd_en && (fifo_empty != {PHY_NUM{1'b1}});//�˴���fifo_rd_en��"����һ���ǿ�"�ź����룬ʹ����ǰһ���������ͣ���ֹ���ղ���

			//  -------------------------------------------------------------------------------------
			//	-ref ���ź����
			//	1.��fifo��������lval��Ч
			//	2.����fifo������������Ϊ0
			//	3.ȡphy0��lval���
			//  -------------------------------------------------------------------------------------
			always @ (posedge clk_pix) begin
				if(w_fifo_rd_en==1'b1) begin
					lval_reg	<= lval_mul[0];//��phy0��lval
				end
				else begin
					lval_reg	<= 1'b0;
				end
			end
			assign	o_lval	= lval_reg ;
			//  -------------------------------------------------------------------------------------
			//	-ref �������־
			//	1.���ĳ��ʱ������ͨ�������lval��һ������ָʾ����
			//  -------------------------------------------------------------------------------------
			always @ (posedge clk_pix) begin
				if(w_fifo_rd_en==1'b1) begin
					if(lval_mul == {PHY_NUM{1'b0}}) begin
						wrong_status <= wrong_status;
					end
					else if(lval_mul == {PHY_NUM{1'b1}}) begin
						wrong_status <= wrong_status;
					end
					else begin
						wrong_status <= 1'b1;
					end
				end
			end
			assign o_sync_buffer_error = wrong_status;
	genvar j;
	generate
		for(j=0;j<PHY_NUM;j=j+1) begin
		//  -------------------------------------------------------------------------------------
		//	-ref �������
		//	1.��fifo��������������Ч
		//	2.����fifo������������Ϊ0
		//	3.��·phy���ϲ�����
		//  -------------------------------------------------------------------------------------
			always @ (posedge clk_pix) begin
				if(w_fifo_rd_en==1'b1) begin
					pix_data_reg[(j+1)*SENSOR_DAT_WIDTH*PHY_CH_NUM-1:j*(SENSOR_DAT_WIDTH*PHY_CH_NUM)]	<= fifo_dout[j][SENSOR_DAT_WIDTH*PHY_CH_NUM:1];
				end
				else begin
					pix_data_reg[(j+1)*SENSOR_DAT_WIDTH*PHY_CH_NUM-1:j*(SENSOR_DAT_WIDTH*PHY_CH_NUM)]	<= {(SENSOR_DAT_WIDTH*PHY_CH_NUM){1'b0}};
				end
			end
			assign	ov_pix_data	= pix_data_reg;
			assign lval_mul[j]	= fifo_dout[j][0];
		end
	endgenerate

endmodule