//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : sensor_reset
//  -- �����       : �ܽ�
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �ܽ�       :| 2016/03/25 17:47:33	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :
//              1)  :
//
//              2)  :
//
//              3)  :
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module sensor_reset # (
	parameter			CLOCL_FREQ_MHZ				= 40	,	//ʱ�ӵ�Ƶ�ʣ�Mhz
	parameter			SENSOR_HARD_RESET_TIME		= 1000	,	//senosrӲ����λʱ�䣬us
	parameter			SENSOR_CLK_DELAY_TIME		= 200	,	//Ӳ����λ����֮��sensorʱ�ӵĵȴ�ʱ�䣬us
	parameter			SENSOR_INITIAL_DONE_TIME	= 2950		//Ӳ����λ����֮��ĵȴ�ʱ�䣬us
	)
	(
	//�����ź�
	input					clk							,	//����ʱ��
	input					reset						,	//��λ�ź�
	input					i_sensor_reset				,	//�̼����ĸ�λ����
	//����ź�
	output					o_sensor_reset_n			,	//�����sensorӲ����λ�ź�
	output					o_clk_sensor_ouput_reset	,	//ʱ�����ʹ��
	output	reg				o_sensor_initial_done			//�����sensor�ڲ���ʼ������ź�
	);

	//	-------------------------------------------------------------------------------------
	//	���س���
	//	-------------------------------------------------------------------------------------
	localparam	SENSOR_HARD_RESET_CNT			=	CLOCL_FREQ_MHZ*SENSOR_HARD_RESET_TIME;
	localparam	SENSOR_CLK_DELAY_CNT			=	CLOCL_FREQ_MHZ*SENSOR_CLK_DELAY_TIME;
	localparam	SENSOR_INITIAL_DONE_CNT			=	CLOCL_FREQ_MHZ*SENSOR_INITIAL_DONE_TIME;
	localparam	SENSOR_HARD_RESET_CNT_WIDTH		=	log2(SENSOR_HARD_RESET_CNT+1);
	localparam	SENSOR_CLK_DELAY_CNT_WIDTH		=	log2(SENSOR_CLK_DELAY_CNT+1);
	localparam	SENSOR_INITIAL_DONE_CNT_WIDTH	=	log2(SENSOR_INITIAL_DONE_CNT+1);

	//	-------------------------------------------------------------------------------------
	//	��������
	//	-------------------------------------------------------------------------------------
	reg	[SENSOR_HARD_RESET_CNT_WIDTH-1:0]			reset_cnt_sensor		= 0;
	reg	[SENSOR_CLK_DELAY_CNT_WIDTH-1:0]			clk_delay_cnt			= 0;
	reg	[SENSOR_INITIAL_DONE_CNT_WIDTH-1:0]			internal_init_cnt		= 0;


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




	//  -------------------------------------------------------------------------------------
	//	Ӳ����λ
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_sensor_reset==1'b1 || reset==1'b1) begin
			reset_cnt_sensor	<= 'b0;
		end
		else if(reset_cnt_sensor == SENSOR_HARD_RESET_CNT-1'b1) begin
			reset_cnt_sensor	<= reset_cnt_sensor;
		end
		else begin
			reset_cnt_sensor	<= reset_cnt_sensor + 1'b1;
		end
	end
	assign	o_sensor_reset_n	= (reset_cnt_sensor==SENSOR_HARD_RESET_CNT-1'b1);

	//  -------------------------------------------------------------------------------------
	//	Ӳ����λ
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(o_sensor_reset_n==1'b0) begin
			clk_delay_cnt	<= 'b0;
		end
		else if(clk_delay_cnt == SENSOR_CLK_DELAY_CNT-1'b1) begin
			clk_delay_cnt	<= clk_delay_cnt;
		end
		else begin
			clk_delay_cnt	<= clk_delay_cnt + 1'b1;
		end
	end
	assign	o_clk_sensor_ouput_reset	= (clk_delay_cnt == SENSOR_CLK_DELAY_CNT-1'b1) ? 1'b0 : 1'b1;

	//  -------------------------------------------------------------------------------------
	//	sensor��Ӳ����λ�����󣬱���ȴ�����2950us�󣬹̼����ܿ�ʼ����sensor
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(o_sensor_reset_n==1'b0)begin
			internal_init_cnt		<=	16'd0;							//internal_init_cnt���㣬��������ʼ����
			o_sensor_initial_done	<=	1'b0;
		end
		else if(internal_init_cnt == SENSOR_INITIAL_DONE_CNT-1)begin		//������2950usʱֹͣ����
			internal_init_cnt		<=	internal_init_cnt;				//���������ֲ���
			o_sensor_initial_done	<=	1'b1;							//sensor�ڲ���ʼ�����
		end
		else begin
			internal_init_cnt		<=	internal_init_cnt	+	1'd1;	//δ�Ƶ�10800ʱ��������ÿ��ʱ���Լ�1
			o_sensor_initial_done	<=	1'b0;							//sensor�ڲ���ʼ��δ���
		end
	end

endmodule
