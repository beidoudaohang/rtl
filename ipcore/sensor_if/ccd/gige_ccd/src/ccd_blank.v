//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : blank_run
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2014/1/10 11:22:23	:|  ��ʼ�汾
//  -- �Ϻ���       :| 2015/12/7 10:10:59	:|  ��ֲ��u3��
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

module ccd_blank # (
	parameter	XV_WIDTH						= 4				,
	parameter	XV_DEFAULT_VALUE				= 4'b1100		,
	parameter	XV_VALUE1						= 4'b1100		,
	parameter	XV_VALUE2						= 4'b1000		,
	parameter	XV_VALUE3						= 4'b1001		,
	parameter	XV_VALUE4						= 4'b0001		,
	parameter	XV_VALUE5						= 4'b0011		,
	parameter	XV_VALUE6						= 4'b0010		,
	parameter	XV_VALUE7						= 4'b0110		,
	parameter	XV_VALUE8						= 4'b0100		,
	parameter	LINE_START_POS					= 40			,	//ÿһ�п�ʼ��ת��ʱ���
	parameter	LINE_PERIOD						= 1532			,	//������
	parameter	ONE_LINE_BLANK_NUM				= 4				,	//ÿһ�п췭������
	parameter	ONE_BLANK_STATE_NUM				= 8					//ÿһ�ο췭��״̬����
	)
	(
	input							clk					,	//ʱ��
	input							reset				,	//��λ
	input		[12:0]				iv_hcount			,	//�м�����
	input							i_blank_flag		,	//�췭ʹ�ܱ�־
	input       [12:0]				iv_blank_num		,	//��ͷ���ܸ����Ĵ�����ָ�������б��췭���еĸ���
	output		[XV_WIDTH-1:0]		ov_xv					//xv�ź�
	);

	//	ref signals

	//	-------------------------------------------------------------------------------------
	//	��������
	//	-------------------------------------------------------------------------------------
	localparam	ONE_STATE_CLK_NUM		= ((LINE_PERIOD-LINE_START_POS*2)/(ONE_LINE_BLANK_NUM*ONE_BLANK_STATE_NUM))	;	//ÿ���췭״̬��ʱ�Ӹ���
	localparam	CLK_CNT_WIDTH			= log2(ONE_STATE_CLK_NUM-1);
	localparam	STATE_CNT_WIDTH			= log2(ONE_BLANK_STATE_NUM-1);
	localparam	BLANK_CNT_WIDTH			= log2(ONE_LINE_BLANK_NUM);	//����Ҫ�����ֵ��һ��

	localparam	LINE_END_POS			= LINE_PERIOD-LINE_START_POS;	//ÿһ�н�����ת��ʱ���

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

	//	-------------------------------------------------------------------------------------
	//	�źŶ���
	//	-------------------------------------------------------------------------------------
	reg									blank_flag_int	= 1'b0;
	reg		[CLK_CNT_WIDTH-1:0]			clk_cnt			= 'b0;
	reg		[STATE_CNT_WIDTH-1:0]		state_cnt		= 'b0;
	reg		[BLANK_CNT_WIDTH-1:0]		blank_cnt		= 'b0;
	reg		[XV_WIDTH-1	:0]				xv_reg			= XV_DEFAULT_VALUE;



	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***��ת������***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	blank_flag_int �ڲ������췭��ʹ�ܱ�־
	//	--��i_blank_flag=0ʱ���ڲ���־����
	//	--�Ѿ������Ŀ췭����С��Ҫ��Ŀ췭����ʱ����ÿһ�еĿ�ʼ�ͽ�β���������ڲ��ڲ���־
	//	--���Ѿ������Ŀ췭��������Ҫ��Ŀ췭����ʱ��˵���Ѿ��������㹻�Ŀ췭����ʱ�ڲ���־����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_blank_flag) begin
			blank_flag_int	<= 1'b0;
		end
		else begin
			if(blank_cnt<iv_blank_num) begin
				if(iv_hcount==LINE_START_POS) begin
					blank_flag_int	<= 1'b1;
				end
				else if(iv_hcount==LINE_END_POS) begin
					blank_flag_int	<= 1'b0;
				end
			end
			else begin
				blank_flag_int	<= 1'b1;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	clk_cnt ÿ��״̬��ʱ�Ӹ���������
	//	--��blank_flag_int=0ʱ��clk_cnt����
	//	--��clk_cnt=���ֵʱ����0��ʼ����
	//	--��������£��ۼ�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!blank_flag_int) begin
			clk_cnt	<= 'b0;
		end
		else begin
			if(clk_cnt==(ONE_STATE_CLK_NUM-1)) begin
				clk_cnt	<= 'b0;
			end
			else begin
				clk_cnt	<= clk_cnt + 1'b1;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	state_cnt һ���췭��״̬����������
	//	--��blank_flag_int=0ʱ��state_cnt����
	//	--��clk_cnt���������ֵʱ�����state_cntҲΪ���ֵ��˵��һ��blank�����ˣ�state_cntҪ����
	//	--���state_cntû�дﵽ���ֵ��state_cnt�ۼ�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!blank_flag_int) begin
			state_cnt	<= 'b0;
		end
		else begin
			if(clk_cnt==(ONE_STATE_CLK_NUM-1)) begin
				if(state_cnt==(ONE_BLANK_STATE_NUM-1)) begin
					state_cnt	<= 'b0;
				end
				else begin
					state_cnt	<= state_cnt + 1'b1;
				end
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	blank_cnt �췭����
	//	--��i_blank_flag=0ʱ��blank_cnt����
	//	--��clk_cnt���������ֵ��state_cntҲΪ���ֵ��˵��һ��blank�����ˣ�blank_cnt�ۼ�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(!i_blank_flag) begin
			blank_cnt	<= 'b0;
		end
		else begin
			if(clk_cnt==(ONE_STATE_CLK_NUM-1) && state_cnt==(ONE_BLANK_STATE_NUM-1)) begin
				blank_cnt	<= blank_cnt + 1'b1;
			end
		end
	end

	//	===============================================================================================
	//	ref ***���***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	xv��� ����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(blank_flag_int) begin
			case(blank_cnt)
				0 : begin
					xv_reg	<= XV_VALUE1;
				end
				1 : begin
					xv_reg	<= XV_VALUE2;
				end
				2 : begin
					xv_reg	<= XV_VALUE3;
				end
				3 : begin
					xv_reg	<= XV_VALUE4;
				end
				4 : begin
					xv_reg	<= XV_VALUE5;
				end
				5 : begin
					xv_reg	<= XV_VALUE6;
				end
				6 : begin
					xv_reg	<= XV_VALUE7;
				end
				7 : begin
					xv_reg	<= XV_VALUE8;
				end
			endcase
		end
		else begin
			xv_reg	<= XV_DEFAULT_VALUE;
		end
	end
	assign	ov_xv	= xv_reg;

endmodule
