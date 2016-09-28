`timescale 1ns/1ns
`include "RJ33J3DEF.v"

module	ccd_vclear(

	input						pixclk				,		//����ʱ��
	input						reset				,       //��λ
	input		[`REG_WD-1:0]	iv_frame_period_m	,       //֡���ڼĴ���
	input		[`REG_WD-1:0]	iv_vcount			,       //��ֱ������
	input		            	i_xsg_start   		,       //�ع��־
	input						i_xsg_clear			,
	input						i_triggersel_m		,       //�ɼ�ģʽ
	input						i_hend				,       //��β��־

	output	reg					o_vcount_clear		,       //��ֱ��������λ��־
	output	reg					o_waitflag                  //�ȴ��׶α�־

	);


	reg							convcount_clear			;
	reg							trivcount_clear			;
	reg							triwaitflag				;
	reg			[2:0]			trivcount_clear_shift	;
	reg							exposure_end			;		//�ع������hend����
	reg							exposure_end_ext		;		//Ϊ�˷�ֹexposure_end��խ�ӿ���ź�
	reg							xsg_start2vcount1		;		//Ϊ����wait_flag���õı�־


	//--------------------------------------------------------
	//4-3-1
	//Vcount�����������źţ�Vcount_clear
	//--------------------------------------------------------
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			convcount_clear	<= 1'b1;	//1-clear
		end
		else begin
			if(iv_vcount >= iv_frame_period_m + 1'b1) begin
				convcount_clear	<= 1'b1;
			end
			else begin
				convcount_clear	<= 1'b0;
			end
		end
	end

	//�ع�����źŵ�hend�����ź���С���1clk����С���ʱ���ܸ�λvcount��
	//Ϊ�˱�֤�ܹ��ȶ���λvcount�����źżӿ�
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			exposure_end <= 1'b0;
		end
		else if(i_xsg_clear) begin
			exposure_end <= 1'b1;
		end
		else if(i_hend) begin
			exposure_end <= 1'b0;
		end
	end
	//�ӿ�exposure_end��ͬʱ��Ҫ��֤�ӿ����ź���i_hend���룬����trivcount_clear�Ͳ���i_hend����
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			exposure_end_ext <= 1'b0;
		end
		else if(exposure_end && i_hend) begin	//���i_hend���治����֡
			exposure_end_ext <= 1'b1;
		end
		else if(i_hend) begin
			exposure_end_ext <= 1'b0;
		end
	end
	//exposure_end_ext��������û�м�����iv_frame_period_m����������ά��
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			trivcount_clear <= 1'b1;
		end
		else begin
			if(exposure_end_ext || ((iv_vcount > 0)&&(iv_vcount <= iv_frame_period_m))) begin		//û�еȺ�С���ع����֡
				trivcount_clear <= 1'b0;
			end
			else begin
				trivcount_clear <= 1'b1;
			end
		end
	end

	//����ģʽ������ģʽ�ļ����������ź��ڴ�ͳһ0
	always@(posedge pixclk) begin
		if(i_triggersel_m) begin
			o_vcount_clear	<= trivcount_clear;
		end
		else begin
			o_vcount_clear	<= convcount_clear;
		end
	end
	//--------------------------------------------------------
	//4-4
	//�ȴ��׶Σ�
	//	 (1)�����źŵĵ�����ʱ���Ͼ��кܴ������ԣ�������Ƶ�ʺܵ͵�ʱ��������кܴ�һ����ʱ�䴦��
	//		�����ȴ���ʱ��
	//	 (2)�ڴ����ȴ������ʱ����������滥��ì�ܵ�������Ҫ���ǣ����ĺʹ�ֱ�Ĵ����ķ�ת��
	//	 (3)�����ȴ���־��TriVcount_clear_shift�����ص���һ֡�ع⿪ʼ�׶Σ�Ϊ�˱�֤֡��תЧ�����ع⵽vcount=1�׶�������
	//--------------------------------------------------------
	//	�������ع������iv_vcount == 16'h0001�ı�־
	always@(posedge pixclk or posedge reset) begin
		if (reset) begin
			xsg_start2vcount1 <= 1'b0;
		end
		else if(i_xsg_start) begin
			xsg_start2vcount1 <= 1'b1;
		end
		else if (iv_vcount == 16'h0001) begin
			xsg_start2vcount1 <= 1'b0;
		end
	end
	//��trivcount_clear��λ��ȡ������
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			trivcount_clear_shift <= 3'b000;
		end
		else if(i_hend) begin						//ʹ��hendͬ����֤��λ�ź���hend����	һ�������ڿ��
			trivcount_clear_shift <= {trivcount_clear_shift[1:0],trivcount_clear};
		end
	end
	//��TriVcount_clear_shift�����ص���һ֡�ع⿪ʼ�׶Σ�Ϊ�����ȴ���־
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triwaitflag	<= 1'b0;
		end
		else if(xsg_start2vcount1) begin
			triwaitflag	<= 1'b0;
		end
		else if(trivcount_clear_shift == 3'b001) begin
			triwaitflag	<= 1'b1;
		end
	end
	//ֻ�ڴ���ģʽ�����
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_waitflag <= 1'b0;
		end
		else if (i_triggersel_m == 1'b0) begin
			o_waitflag <= 1'b0;
		end
		else begin
			o_waitflag <= triwaitflag;
		end
	end

endmodule