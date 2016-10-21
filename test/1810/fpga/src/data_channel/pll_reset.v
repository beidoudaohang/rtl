//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : pll_reset
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/10/27 15:28:59	:|  ��ʼ�汾
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

module pll_reset # (
	parameter	PLL_CHECK_CLK_PERIOD_NS		= 25		,	//pll���ʱ�ӵ�����
	parameter	PLL_RESET_SIMULATION		= "FALSE"		//�⴮PLL��λ��ʹ�ܷ���ģʽ����λʱ���̣����ٷ���
	)
	(
	input			clk					,
	input			i_pll_lock			,
	input			i_sensor_init_done	,
	output			o_pll_reset
	);

	//	ref signals

	localparam	WAIT_TIME_NS	= 2000000	;//��λ�����ʱ�� NS
	localparam	RESET_TIME_NS	= 500000	;//��λʱ�� NS
	localparam	WAIT_CNT_NUM	= WAIT_TIME_NS/PLL_CHECK_CLK_PERIOD_NS;
	localparam	WAIT_CNT_WIDTH	= log2(WAIT_CNT_NUM+1);
	localparam	RESET_CNT_NUM	= (PLL_RESET_SIMULATION=="TRUE") ? 10 : (RESET_TIME_NS/PLL_CHECK_CLK_PERIOD_NS);
	localparam	RESET_CNT_WIDTH	= log2(RESET_CNT_NUM+1);

	reg		[WAIT_CNT_WIDTH-1:0]		wait_cnt		= 'b0;
	reg		[RESET_CNT_WIDTH-1:0]		reset_cnt		= 'b0;
	reg									pll_lock_dly0	= 1'b1;
	reg									pll_lock_dly1	= 1'b1;
	reg									state			= 1'b0;
	reg									reset_reg		= 1'b0;

	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction

	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	refer to ds162 v1.2 Table 52: PLL Specification
	//	-------------------------------------------------------------------------------------
	//	Symbol      | Description                | Device | Speed Grade     | Units
	//	                                         |           -3 -3N -2 -1L
	//	TLOCKMAX    | PLL Maximum Lock Time      | All    | 100 100 100 100 | ��s
	//	RSTMINPULSE | Minimum Reset Pulse Width  | All    | 5   5   5   5   | ns
	//	-------------------------------------------------------------------------------------

	//	-------------------------------------------------------------------------------------
	//	���β���pll lock
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		pll_lock_dly0	<= i_pll_lock;
		pll_lock_dly1	<= pll_lock_dly0;
	end

	//	-------------------------------------------------------------------------------------
	//	״̬�Ĵ���
	//	-- 0 ������״̬���������lock�ź�Ϊ�ͣ���������λ״̬
	//	-- 1 ����λ״̬��������ּ������������ҵ�ǰpllû���������򷢳���λ�ź�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(state==1'b0) begin
			if(pll_lock_dly1==1'b0) begin
				state	<= 1'b1;
			end
		end
		else begin
			if(wait_cnt==WAIT_CNT_NUM-1) begin
				state	<= 1'b0;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	��λwait������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(state==1'b1) begin
			if(wait_cnt==WAIT_CNT_NUM-1) begin
				wait_cnt	<= 'b0;
			end
			else begin
				wait_cnt	<= wait_cnt + 1'b1;
			end
		end
		else begin
			wait_cnt	<= 'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	reset������
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(state==1'b1) begin
			if(reset_cnt>=RESET_CNT_NUM-1) begin
				reset_cnt	<= RESET_CNT_NUM;
			end
			else begin
				reset_cnt	<= reset_cnt + 1'b1;
			end
		end
		else begin
			reset_cnt	<= 'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	�����λ�ź�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(state==1'b1) begin
			if(reset_cnt<=RESET_CNT_NUM-1) begin
				reset_reg	<= 1'b1;
			end
			else begin
				reset_reg	<= 1'b0;
			end
		end
		else begin
			reset_reg	<= 'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	���sensor��ʼ��û����ɣ���λ
	//	-------------------------------------------------------------------------------------
	assign	o_pll_reset	= reset_reg | !i_sensor_init_done;

endmodule
