`timescale 1ns/1ns
`include "RJ33J3DEF.v"

module ccd_exp(

	input						pixclk				,		//����ʱ��
	input						reset				,       //��λ
	input						i_triggersel_m		,       //�ɼ�ģʽ
	input						i_exposure_start	,       //�ع⿪ʼ
	input						i_waitflag			,       //�ȴ��׶α�־
	input	[`EXP_WD-1 :0]		iv_exposure_reg_m	,       //�ع�ʱ��Ĵ���
	input	[`REG_WD-1:0]		iv_vcount			,       //��ֱ������

	output	reg					o_xsub_last_m		,       //�����SUB�ź�
	output	reg					o_xsg_start			,       //֡��ת�׶ο�ʼ�ź�
	output	reg					o_strobe			,       //�����
	output	reg					o_exposure_preflag	,       //�ع�׶α�־������SUB
	output	reg             	o_exp_over			,       //�ع����
	output	reg					o_integration               //�����ź�

	);


	reg			[`EXP_WD-1 :0]	exposure_count		= {`EXP_WD{1'b1}};
	reg							xsub_last			;
	reg							exposure_flag		;
	reg			[1:0]			exposure_flag_shift	;
	reg			[`EXP_WD-1 :0]	exposure_reg		= {`EXP_WD{1'b0}};			//SUB��� + �ع�ʱ��
	reg			[1:0]			exposure_start_shift;


	//--------------------------------------------------------
	//4-2-1
	//���һ��SUB�źţ�xsub_last_m
	//Ϊ��ʵ�־�ȷ�ع⣬�ع���ʼʱ�̣���һ��sub�źţ�ֻ�������ɺʹ���ģʽ�ĵȴ��׶βŲ���ˮƽ���̲�sub��Ӱ��ͼ��
	//--------------------------------------------------------
	//�����ź�����������һ��sub�źţ�������ع⾫��
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_xsub_last_m	<= 1'b1;
		end
		else if(i_triggersel_m ==1'b0) begin
			o_xsub_last_m	<= 1'b1;
		end
		else if(i_waitflag) begin
			o_xsub_last_m	<= xsub_last;
		end
		else begin
			o_xsub_last_m	<= 1'b1;
		end
	end

	// =================================================================================================
	//4-2-2
	//��ȷ�ع����
	//���۴���ģʽ��������ģʽ����exposure_start�źź����������ع�
	// =================================================================================================
	//�����ع�ʱ�䣬��ʼ����
	always@(posedge pixclk) begin
		if(iv_exposure_reg_m < (`XSG1_FALLING -`XSUB_WIDTH + 32'h1)) begin
			exposure_reg <= `XSG1_FALLING + 32'h1;
		end
		else begin
			exposure_reg <=	`XSUB_WIDTH + iv_exposure_reg_m;
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			exposure_start_shift <=  2'b00;
		end
		else begin
			exposure_start_shift <= {exposure_start_shift[0],i_exposure_start};
		end
	end

	always@(posedge pixclk ) begin
		if(exposure_start_shift[1:0] == 2'b01) begin				//�ع⿪ʼ
			exposure_count	<=	{`EXP_WD{1'b0}};					//�ع���������㿪ʼ����
		end
		else if (exposure_count >= exposure_reg) begin
			exposure_count	<=	exposure_count;						//�Ƶ��ع�ֵ�󱣳�
		end
		else begin
			exposure_count	<=	exposure_count + 1'b1;
		end
	end

	//============================================================================================
	//�����м��־������sub,�ع��־,֡��ת��ʼ��־
	//============================================================================================
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			xsub_last	<= 1'b1;
		end
		else begin
			if(exposure_count == `EXP_WD'h000000) begin	//�ع⿪ʼ
				xsub_last	<= 1'b0;
			end
			else if(exposure_count == (`EXP_WD'h000000 + `XSUB_WIDTH)) begin
				xsub_last	<= 1'b1;
			end
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			exposure_flag	<=1'b0;
		end
		else begin
			if(exposure_count == (`EXP_WD'h000000 + `XSUB_WIDTH)) begin	//�ع⿪ʼ
				exposure_flag		<=	1'b1;
			end
			else if(exposure_count == exposure_reg) begin
				exposure_flag		<=	1'b0;
			end
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_xsg_start	<= 1'b0;
		end
		else begin
			if(exposure_count == (exposure_reg - `XSG1_FALLING)) begin
				o_xsg_start	<= 1'b1;
			end
			else begin
				o_xsg_start	<= 1'b0;
			end
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_exposure_preflag	<= 1'b0;
		end
		else begin
			if(exposure_count == `EXP_WD'h000000) begin
				o_exposure_preflag	<= 1'b1;
			end
			else if(exposure_count == exposure_reg) begin
				o_exposure_preflag	<= 1'b0;
			end
		end
	end

	//--------------------------------------------------------
	//4-2-3
	//�ع������־��exposure_flag_m
	//�ع����ʱ��exposure_flag_m��1��triggeren���½��ر���0��������źŵ������ظ�����ģʽ��vcount��0����������ģʽ�Ĵ��䡣
	//--------------------------------------------------------
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			exposure_flag_shift	<= 2'b00;
		end
		else begin
			exposure_flag_shift	<= {exposure_flag_shift[0],exposure_flag};
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_exp_over	<= 1'b0;
		end
		else if(exposure_flag_shift[1:0] == 2'b10) begin
			o_exp_over	<= 1'b1;
		end
		else begin
			o_exp_over	<= 1'b0;
		end
	end
	//--------------------------------------------------------
	//4-2-4
	//������ź�	��Strobe   �ߵ�ƽ��Ч�����ع⿪ʼʱ����Ч�������俪ʼʱ����Ч��
	//�����ź����  ��Integration
	//--------------------------------------------------------
	//ԭ�����Ƿִ���������ģʽ�ģ������Ϊ���ع������ź�ͳһ��
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_strobe	<= 1'b0;
		end
		else if(iv_vcount==`REG_WD'h0001) begin
			o_strobe	<= 1'b0;
		end
		else if(exposure_start_shift == 2'b01) begin
			o_strobe	<= 1'b1;
		end
	end

	//Integration
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_integration <= 1'b0;
		end
		else begin
			o_integration <= exposure_flag;
		end
	end

endmodule