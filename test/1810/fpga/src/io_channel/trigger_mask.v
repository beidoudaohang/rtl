//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : trigger_mask
//  -- �����       : �ܽ�
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �ܽ�       :| 2015/10/28 16:36:04	:|  ��ʼ�汾
//  -- �ܽ�       :| 2015/11/17 14:09:07	:|  ���ݹ̼����õļ��������trigger�ź�
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :trigger�ź�����
//
//-------------------------------------------------------------------------------------------------
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module  trigger_mask # (
    parameter   PIX_CLK_FREQ_KHZ    = 55000
    )
	(
	input				clk					,//ʱ�ӣ�clk_pix��55MHz
	input				i_trigger			,//clk_pixʱ�������봥���ź�
	input				i_stream_enable		,//clk_pixʱ������ʹ���ź�
	input				i_acquisition_start	,//clk_pixʱ���򣬿����źţ�0-ͣ�ɣ�1-����
	input   [31:0]      iv_trigger_interval ,//clk_pixʱ���򣬴���ģʽ��С���
	input				i_trigger_mode		,//clk_pixʱ���򣬴���ģʽ��0-����ģʽ��1-����ģʽ
	output				o_trigger			,//clk_pixʱ������������ź�
	input				i_fval				,//�⴮ʱ����110MHz,���볡�ź�
	input				i_trigger_status	 //�⴮ʱ����1-�д����ź��Ҵ���֡δ�����ϣ�0-�޴����źŻ򴥷�֡������
	);
    //  -------------------------------------------------------------------------------------
	//	ref ���س���
	//  -------------------------------------------------------------------------------------
	localparam  [7:0]  CNT_1US =   PIX_CLK_FREQ_KHZ/1000;
	//  -------------------------------------------------------------------------------------
	//	ref ��������
	//  -------------------------------------------------------------------------------------
	reg			enable					;
	reg [1:0]   fval_shift              ;

	reg			trigger_mode_shift		;
	reg			trigger_mode			;
	wire		trigger_mode_rise		;

	reg			trigger_reg				;

	reg [7:0]   timer_cnt_1us           ;
	reg         timer_1us_flag          ;
	reg	[31:0]	trigger_interval_cnt	;
	reg [31:0]  trigger_interval_cnt_lock=32'd100000;//���븳��ֵ����ֹ���ϵ�֮���л����ⴥ��ģʽʱ������

	reg			tigger_filter=0			;//1-����i_trigger�źţ�0-���i_tigger�ź�
    reg	[1:0]	trigger_status_shift;
	wire		trigger_status;
	//  -------------------------------------------------------------------------------------
	//	ref �첽�źŴ�����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		trigger_status_shift	<=	{trigger_status_shift[0],i_trigger_status};
	end
	assign	trigger_status	=	trigger_status_shift[1];
	//  -------------------------------------------------------------------------------------
	//	ref ʹ���ź�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		enable	<= i_stream_enable & i_acquisition_start;
	end
	//  -------------------------------------------------------------------------------------
	//	ref �첽�źŴ�����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
	    fval_shift  <=  {fval_shift[0],i_fval};
	end
    //  -------------------------------------------------------------------------------------
	//	ref ����i_trigger_mode��������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		trigger_mode_shift	<=	i_trigger_mode;
		if(!fval_shift[1])
			trigger_mode	<=	i_trigger_mode;
	end
	assign	trigger_mode_rise	=	({trigger_mode_shift,i_trigger_mode}==2'b01);

	//  -------------------------------------------------------------------------------------
	//	ref 1us������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
	    if(timer_cnt_1us>=CNT_1US-1)begin
	        timer_cnt_1us	<=	8'd0;
	        timer_1us_flag	<=	1'b1;
	    end
	    else begin
	        timer_cnt_1us	<=	timer_cnt_1us	+	1'd1;
	        timer_1us_flag	<=	1'b0;
	    end
	end
	//  -------------------------------------------------------------------------------------
	//	ref ��¼�����ź�֮���ʱ�䣬��λus
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
	    if(trigger_reg | trigger_mode_rise)begin
	        trigger_interval_cnt	<=	32'd0;
	    end
	    else if(timer_1us_flag)begin
	        trigger_interval_cnt	<=	trigger_interval_cnt	+	1'd1;
	    end
	end
	//  -------------------------------------------------------------------------------------
	//	ref �����ν׶β���������trigger�ź�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(enable & (!(tigger_filter | trigger_status)) & trigger_mode)
			trigger_reg	<=	i_trigger & i_trigger_mode;
		else
			trigger_reg	<=	1'b0;
	end
	//  -------------------------------------------------------------------------------------
	//	ref trigger_regΪ1ʱ����iv_trigger_interval
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(trigger_reg)
			trigger_interval_cnt_lock	<=	iv_trigger_interval;
		else
		    trigger_interval_cnt_lock	<=	trigger_interval_cnt_lock;
	end
	//  -------------------------------------------------------------------------------------
	//	ref ����tigger_filter�ź�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk)begin
		if(trigger_reg | trigger_mode_rise)
			tigger_filter	<=	1'b1;
		else if(trigger_interval_cnt>trigger_interval_cnt_lock)
			tigger_filter	<=	1'b0;
	end

	//  -------------------------------------------------------------------------------------
	//	ref ���o_trigger�ź�
	//  -------------------------------------------------------------------------------------
	assign	o_trigger	=	trigger_reg;

endmodule