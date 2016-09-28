//--------------------------------------------------------
//4-1
//�����׶�
//�׶������������׶δӴ����ź�����ʼ��������CCD�ع�����������ź���TriggerIn����������ź�Exposure_start����Ϊ������һ�׶ε��ź�
//--------------------------------------------------------
`timescale 1ns/1ns
`include "RJ33J3DEF.v"

module ccd_trig(

	input						pixclk				,		//����ʱ��
	input						reset				,       //��λ
	input                       i_triggerin			,       //��������
	input						i_hend				,       //��β��־
	input						i_triggersel_m		,       //�ɼ�ģʽ
	input		[`REG_WD-1:0]	iv_vcount			,       //�м���
	input		[`REG_WD-1:0]	iv_hcount			,       //�м���
	input		[`REG_WD-1 :0]	iv_triggerenreg_m	,       //��������λ�üĴ���
	input		[`REG_WD-1 :0]	iv_frame_period_m	,		//
	input		[`REG_WD-1 :0]	iv_contlineexp_start,       //����ģʽ���ع⿪ʼλ�üĴ���
	output						o_exposure_start	,       //�ع⿪ʼ��־
	output		reg				o_triggerready              //���������־

	);

	reg							contexp_trigger		;
	reg							triexp_trigger		;
	reg							triggeren			;
	reg         [ 2        :0]  triggerin_shift     ;
	reg			[ 2        :0]	triggeren_shift		;
	reg			[ 2        :0]	triggersel_m_shift	;
	reg							tri_mask			;
	reg			[`REG_WD-1:0]	mask_count			;
	reg							triggeren_m			;
	reg			[ 2        :0]	triggeren_m_shift	;
	//--------------------------------------------------------
	//4-1-1
	//��ȡ�����źţ������ź�TriggerIn�ı�Ե
	//--------------------------------------------------------
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triggerin_shift	<= 3'b0;
		end
		else begin
			triggerin_shift	<= {triggerin_shift[1:0],i_triggerin};
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triggersel_m_shift	<= 3'b0;
		end
		else begin
			triggersel_m_shift	<= {triggersel_m_shift[1:0],i_triggersel_m};
		end
	end
	//--------------------------------------------------------
	//4-1-2
	//���ɴ��������źţ�TriggerEn
	//����������ȼ������ⴥ��
	//--------------------------------------------------------
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triggeren_m	<= 1'b1;
		end
		else if((iv_vcount > 0)&&(iv_vcount < iv_triggerenreg_m)) begin			//zhangq 2014/1/28 15:50:59
			triggeren_m	<= 1'b0;
		end
		else begin
			triggeren_m	<= 1'b1;
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triggeren_m_shift	<= 3'b0;
		end
		else begin
			triggeren_m_shift	<= {triggeren_m_shift[1:0],triggeren_m};
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triggeren	<= 1'b0;
		end
		else if((i_triggersel_m == 1'b0)||(tri_mask==1'b0)) begin
			triggeren	<= 1'b0;
		end
		else if(triggeren_m_shift[2:1] == 2'b01) begin
			triggeren	<= 1'b0;
		end
		else if(triggerin_shift[2:1] == 2'b01) begin
			triggeren	<= 1'b1;
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triggeren_shift	<= 3'b0;
		end
		else begin
			triggeren_shift	<= {triggeren_shift[1:0],triggeren};
		end
	end

	//--------------------------------------------------------
	//4-1-3
	//���ɸ����źţ�TriggerReady�����ź�ֱ��������������ã�û���������ܡ�
	//--------------------------------------------------------
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_triggerready <= 1'b0;
		end
		else begin
			o_triggerready <= triggeren;
		end
	end

	//--------------------------------------------------------
	//4-1-4
	//����ģʽ�������ع���źţ�TriExp_Trigger
	//ȡ���������źŵ������أ���Ϊ����ģʽ�µ��ع���ʼ�ź�
	//--------------------------------------------------------
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triexp_trigger	<= 1'b0;
		end
		else if(triggeren_shift[2:1] == 2'b01) begin
			triexp_trigger	<= 1'b1;
		end
		else begin
			triexp_trigger	<= 1'b0;
		end
	end

	always @ (posedge pixclk) begin
		if(triggersel_m_shift[2:1] == 2'b01) begin
			mask_count	<=	`REG_WD'b0;
		end
		else if(mask_count > iv_frame_period_m) begin
			mask_count	<=	iv_frame_period_m + 1'b1;
		end
		else if(i_hend) begin
			mask_count	<=	mask_count + 1'b1;
		end
	end

	always @ (posedge pixclk) begin
		if(mask_count > iv_frame_period_m) begin
			tri_mask	<= 1'b1;
		end
		else begin
			tri_mask	<= 1'b0;
		end
	end
	//--------------------------------------------------------
	//4-1-5
	//����ģʽ�£��ع������źţ�ContExp_Trigger
	//--------------------------------------------------------

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			contexp_trigger	<= 1'b0;
		end
		else begin
			if((iv_vcount == iv_contlineexp_start)&&(iv_hcount == `XSUB_WIDTH)) begin	//sub����֮��������ʼ�ع�
				contexp_trigger	<= 1'b1;
			end
			else begin
				contexp_trigger	<= 1'b0;
			end
		end
	end

	//--------------------------------------------------------
	//4-1-6
	//�ع������źţ�Exposure_start
	//�ع������źš�����ģʽ�ʹ���ģʽ���ع�׶����ն�������ź�����
	//--------------------------------------------------------
	assign o_exposure_start	= (i_triggersel_m == 1'b0) ? contexp_trigger : triexp_trigger;

endmodule