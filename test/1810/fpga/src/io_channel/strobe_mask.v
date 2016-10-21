//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : strobe_mask
//  -- �����       : ����ǿ
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- ����ǿ       :| 2016/07/19 16:49:40	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : ��ģ����רΪAR1820 sensor��Ƶ�������źŹ���ģ�飬���������sensor���й�����
//						��ʱ��ͬ����������ź�
//              1)  :
//
//              2)  :
//
//              3)  :
//
//-------------------------------------------------------------------------------------------------
//`include			"strobe_mask_def.v"
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module strobe_mask # (
	parameter					PIX_CLK_FREQ_KHZ	= 55000			,//����ʱ��Ƶ�ʣ���KhzΪ��λ
	parameter					SHORT_LINE_LENGTH_PCK	=	5568	,//sensor������������ֵ�����ֵ��д��sensor�Ĵ�����ʮ���Ʊ�ʾ
	parameter					PHY_NUM				= 2				,//phy����
	parameter					PHY_CH_NUM			= 4				,//ÿ��Phyͨ����
	parameter					SIMULATION			= "FALSE"
	)
	(
	input						clk								,//����ʱ�ӣ�clk_pixʱ����55Mhz
	input						i_strobe						,//�첽�źţ�����������źţ�sensor���
	input						i_acquisition_start				,//clk_pixʱ���򣬿����źţ�0-ͣ�ɣ�1-����
	input						i_stream_enable					,//clk_pixʱ������ʹ���źţ�0-ͣ�ɣ�1-����
	input						i_trigger						,//clk_pixʱ���򣬳���1��ʱ�����ڵ����壬��ʾ������ʼ,�����崥��
	input						i_pll_lock						,//�첽�źţ��⴮pll�����źţ��⴮ģ��������͵�ƽʱʧ��
	input						i_fval							,//�첽�źţ��⴮ʱ����֡�ź�
	input						i_lval							,//�첽�źţ��⴮ʱ�������ź�
	input						i_trigger_mode					,//clk_pixʱ����data_mask�����trigger_mode�źţ�0���� 1����
	output						o_strobe						 //��ģ��������ź����
	);

	//  ===============================================================================================
	//	-ref : wires and regs
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	�ڲ��궨��
	//	-------------------------------------------------------------------------------------
	localparam					LONG_LINE_LENGTH_PCK		=	2 * SHORT_LINE_LENGTH_PCK											;
	localparam					FIX_TIME					=	(SIMULATION == "TRUE") ? 10 : (30 * PIX_CLK_FREQ_KHZ / 1000)		;//����ʱ���̶̹�ʱ��Ϊ10clk
	localparam					LPERIOD_LENGTH_COMPARE		=	(LONG_LINE_LENGTH_PCK + SHORT_LINE_LENGTH_PCK) / (2 * 8)			;//ȡ�����������ڵ�ƽ������Ϊ�Ƚ���ֵ
	localparam					LONG_LENGTH					=	(LONG_LINE_LENGTH_PCK * 7) / (PHY_NUM * PHY_CH_NUM) - FIX_TIME		;//�ӳ�ʱ��=7*������-30us
	localparam					SHORT_LENGTH				=	(SHORT_LINE_LENGTH_PCK * 7) / (PHY_NUM * PHY_CH_NUM) - FIX_TIME		;//�ӳ�ʱ��=7*������-30us
	localparam					LPERIOD_WIDTH				=	log2(LONG_LINE_LENGTH_PCK/8 + 1)									;//�����ڼ�����λ����������ھ���
	localparam					EXTEND_WIDTH				=	log2(LONG_LENGTH + 1)												;

	//	-------------------------------------------------------------------------------------
	//	���ļĴ漰������ȡ
	//	-------------------------------------------------------------------------------------
	reg		[2:0]				fval_shift					=	3'b0	;//�첽�źţ���Ҫ�ӳ����ģ�[1]��[2]������ȡ����
	wire						w_fval_rise								;//֡������
	wire						w_fval_fall								;//֡�½���
	reg		[2:0]				lval_shift					=	3'b0	;//�첽�źţ��˴���fval���ӳ�һ�ģ�������fval�����غ����ж�
	wire						w_lval_rise								;//��������
	reg							lval_rise_dly				=	1'b0	;//������������ʱһ��
	reg		[2:0]				pll_lock_shift				=	3'b0	;//i_pll_lock���첽�źţ���Ҫ���Ĵ���
	wire						w_pll_lock_rise							;
	reg		[2:0]				strobe_shift				=	3'b0	;//sensor�����������ź�Ϊ�첽�źţ���Ҫ����
	wire						w_strobe_rise							;
	//	-------------------------------------------------------------------------------------
	//	������
	//	-------------------------------------------------------------------------------------
	reg		[LPERIOD_WIDTH-1:0]	lperiod_cnt					=	'b0		;//�����ڼ�����
	reg		[1:0]				lval_rise_cnt				=	2'b0	;//�����и���
	reg		[EXTEND_WIDTH:0]	extend_cnt					=	'b0		;	//չ���ȼ�����,λ���rv_extend_length��1λ�������Ƿ�ֹ�������Ϊ������Ҫ������rv_extend_length+1�Ż�ֹͣ��
	//	-------------------------------------------------------------------------------------
	//	others
	//	-------------------------------------------------------------------------------------
	reg							lperiod_length_upload					;//	ͳ�������ڸ���ʱ���Ĵ�����Ϊ1ʱ������ֵ���µ������ڼĴ���
	reg		[LPERIOD_WIDTH-1:0]	lperiod_length				=	'b0		;//�����ڼĴ���
	reg							fval_extend					=	1'b0	;//fvalչ�����ź�
	reg		[EXTEND_WIDTH-1:0]	extend_length				=	LONG_LENGTH;//չ���ȣ���ʼֵΪ�ϴ��ֵ�����Է�ֹ������
	wire						w_extend_timeup							;//չ��ʱ�䵽��־λ
	reg							trigger_status				=	1'b0	;//��־���ڴ����׶�
	reg							first_enable				=	1'b0	;//����ģʽ�£��������Ч����׶�
	reg							strobe_enable				= 	1'b0	;//�����ʹ��
	reg							strobe_reg					=	1'b0	;
	//	===============================================================================================
	//	function
	//	===============================================================================================
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
	//	===============================================================================================
	//	 The Detail Design
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	���ļĴ漰������ȡ
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_shift <= {fval_shift[1:0],i_fval};
	end
	assign w_fval_rise = (fval_shift[2:1] == 2'b01)? 1'b1 : 1'b0;
	assign w_fval_fall = (fval_shift[2:1] == 2'b10)? 1'b1 : 1'b0;

	always @ (posedge clk) begin
		lval_shift <= {lval_shift[1:0],i_lval};
	end
	assign w_lval_rise = (lval_shift[2:1] == 2'b01)? 1'b1 : 1'b0;
	always @ (posedge clk) begin
		lval_rise_dly <= w_lval_rise;
	end

	always @ (posedge clk) begin
		pll_lock_shift <= {pll_lock_shift[1:0],i_pll_lock};
	end
	assign w_pll_lock_rise = (pll_lock_shift[2:1] == 2'b01)? 1'b1 : 1'b0;

	always @ (posedge clk) begin
		strobe_shift <= {strobe_shift[1:0],i_strobe};
	end
	assign w_strobe_rise = (strobe_shift[2:1] == 2'b01)? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	-ref 1. catch lval period
	//	-------------------------------------------------------------------------------------
	//	-------------------------------------------------------------------------------------
	//	��¼����
	//	1.֡������0
	//	2.ÿ�п�ʼ++
	//	3.ͳ�Ƶ���2��ֹͣ
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_shift[1]==1'b0) begin
			lval_rise_cnt <= 2'd0;
		end
		else begin
			if(lval_rise_cnt >= 2'd2) begin
				lval_rise_cnt <= lval_rise_cnt;
			end
			else if(lval_rise_dly) begin
				lval_rise_cnt <= lval_rise_cnt + 1'b1;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	ͳ�Ƶ�1�е������ڣ�û�е�0�У�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(lval_rise_cnt == 2'd0) begin
			lperiod_cnt <= 'b0;
		end
		else if(lval_rise_cnt == 2'd1) begin
			if(lperiod_cnt == {LPERIOD_WIDTH{1'b1}}) begin
				lperiod_cnt <= lperiod_cnt		;//��������ֹ�������
			end
			else begin
				lperiod_cnt <= lperiod_cnt + 1'b1;
			end
		end
	end
	//	-------------------------------------------------------------------------------------
	//	����ͳ�Ƶ�������
	//	ÿ��upload��־λΪ�ߵ�ƽʱ������������ֵ���Ĵ���
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if((lval_rise_cnt == 2'd1) && (lval_rise_dly == 1'b1)) begin//ָʾ�ڵ�2���г�����
			lperiod_length_upload <= 1'b1;
		end
		else begin
			lperiod_length_upload <= 1'b0;
		end
	end

	always @ (posedge clk) begin
		if(lperiod_length_upload) begin
			lperiod_length <= lperiod_cnt	;
		end
	end
	//	===============================================================================================
	//	-ref 2.extend fval
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	չ��fval
	//	1.ʹ�ô��ĺ���ź�չ��:fval_shift[1]
	//	2.fval��������1
	//	3.չ��ʱ�䵽��w_extend_timeup����Ź�0
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(w_fval_rise) begin
			fval_extend <= 1'b1;
		end
		else if(w_extend_timeup) begin
			fval_extend <= 1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	w_extend_timeup
	//	-------------------------------------------------------------------------------------
	assign w_extend_timeup = (extend_cnt == {1'b0,extend_length})? 1'b1 : 1'b0;
	//	-------------------------------------------------------------------------------------
	//	extend_length
	//	1.�����ڼĴ����롰����ں�������ڵ�ƽ��ֵ���Ƚϣ�����fval�ӳ��ĳ���
	//	2.����ʱ��Ϊfval�½���
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(w_fval_fall) begin
			if(lperiod_length > LPERIOD_LENGTH_COMPARE) begin
				extend_length <= LONG_LENGTH;
			end
			else begin
				extend_length <= SHORT_LENGTH;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	extend_cnt
	//	��չ��������fval���½��ؿ�ʼ��0������ֱ���պô���չ����ʱֹͣ��
	//	��չ��������fval��Ч�ڼ��0
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_shift[1]) begin
			extend_cnt <= 'b0;
		end
		else begin
			if(extend_cnt > {1'b0,extend_length}) begin
				extend_cnt <= extend_cnt;
			end
			else begin
				extend_cnt <= extend_cnt + 1'b1;
			end
		end
	end

	//	===============================================================================================
	//	-ref 3.o_strobe
	//	���������߼�
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	srobe_enable
	//	��ͣ������i_stream_enable	����ͣ�ɣ���i_acquisition_start��ʱ�����������ź�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_stream_enable & i_acquisition_start) begin
			strobe_enable	 <= 1'b1;
		end
		else begin
			strobe_enable	 <= 1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	����ģʽ�µ�һЩ��־λ
	//	trigger_status
	//	ָʾ����״̬���ӽ��յ�i_trigger�źſ�ʼ����pll_lock�ָ����������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(strobe_enable	) begin
			if(i_trigger) begin
				trigger_status <= 1'b1;
			end
			else if(w_pll_lock_rise) begin
				trigger_status <= 1'b0;
			end
		end
		else begin
			trigger_status <= 1'b0;
		end
	end
	//	-------------------------------------------------------------------------------------
	//	first_enable
	//	first_enable�������Ǳ�־�ڴ���ģʽ�µ��������Ч����׶�
	//	1.����״̬�£�i_pll������ʱ��1
	//	2.fval�����غ��0
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(strobe_enable	) begin
			if(trigger_status & w_pll_lock_rise) begin
				first_enable <= 1'b1;
			end
			else if(w_fval_rise) begin
				first_enable <= 1'b0;
			end
		end
		else begin
			first_enable <= 1'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	strobe_reg
	//	����������Ϊ����ģʽ�ʹ���ģʽ�������
	//	1.r_strobe_enableΪ1ʱ����ƲŻ������
	//	2.����ģʽ��
	//		a.pllʧ��ʱ��û�����
	//		b.r_fval_extend�ߵ�ƽʱ��ֹͣ���
	//		c.����֡����(fval_extend=0)�ڼ�i_strobe�������أ���ʼ���
	//	3.����ģʽ��
	//		a.����r_first_enable�ڼ�Ż������
	//		b.fval������ʱ��ֹͣ���
	//		c.����֡�����ڼ�i_strobe�������أ���ʼ���
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(strobe_enable	) begin
			if(i_trigger_mode == 1'b0) begin //����ģʽ��
				if(!pll_lock_shift[1]) begin
					strobe_reg <= 1'b0;
				end
				else if(fval_extend) begin
					strobe_reg <= 1'b0;
				end
				else if(!fval_extend && w_strobe_rise) begin
					strobe_reg <= 1'b1;
				end
			end
			else begin //����ģʽ��
				if(first_enable) begin
					if(w_fval_rise) begin
						strobe_reg <= 1'b0;
					end
					else if(!fval_shift[1] && w_strobe_rise) begin
						strobe_reg <= 1'b1;
					end
				end
				else begin
					strobe_reg <= 1'b0;
				end
			end
		end
		else begin
			strobe_reg <= 1'b0;
		end
	end
	assign o_strobe = strobe_reg;
endmodule
