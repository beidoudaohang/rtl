
//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : ccd_readout.v
//  -- �����       : ��
//-------------------------------------------------------------------------------------------------
//
//  --�޸ļ�¼  :
//
//  -- ����         :| �޸�����     :|  �޸�˵��
//---------------------------------------------------------------------------------------
//  -- ��       	:| 09/16/2013   :|  ��ʼ�汾
//  -- ��Сƽ      	:| 04/29/2015   :|  �����޸ģ���Ӧ��ICX445 sensor
//  -- �Ϻ���     	:| 2015/12/10   :|  ��ֲ��u3��
//---------------------------------------------------------------------------------------
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
`timescale      1ns/100ps
//-------------------------------------------------------------------------------------------------

module ccd_readout # (
	parameter		XSG_LINE_NUM		//XSG��Ҫռ�ö�����
	)
	(
	input	            		clk      			,   //ʱ��
	input						reset				,	//��λ������Ч
	input	[12:0]				iv_frame_period		,   //֡���ڼĴ���
	input						i_ccd_stop_flag		,	//
	input						i_exp_line_end		,	//������ع��ʱ��㣬һ�����ڣ�
	input						i_line_end			,	//
	output						o_readout_flag		,	//������־���˱�־��Ч�£����ܴ��hcount
	output						o_xsg_flag			,	//
	output	[12:0]				ov_vcount				//
	);


	//	ref signals
	//FSM Parameter Define
	parameter	S_IDLE				= 2'd0;
	parameter	S_XSG_PHASE			= 2'd1;
	parameter	S_READOUT_PHASE		= 2'd2;

	reg		[1:0]	current_state	= S_IDLE;
	reg		[1:0]	next_state		= S_IDLE;

	//FSM for sim
	// synthesis translate_off
	integer			state_ascii;
	always @ ( * ) begin
		case(current_state)
			2'd0 :	state_ascii	<= "S_IDLE";
			2'd1 :	state_ascii	<= "S_XSG_PHASE";
			2'd2 :	state_ascii	<= "S_READOUT_PHASE";
		endcase
	end
	// synthesis translate_on


	reg					ccd_stop_flag_dly	= 1'b0;
	wire				ccd_stop_flag_rise	;
	reg					xsg_flag			= 1'b0;
	reg					readout_flag		= 1'b0;
	reg		[12:0]		vcount_reg			= 13'b0;


	//	ref ARCHITECTURE
	//	===============================================================================================
	//	ref ***ȡ����***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  i_ccd_stop_flag ȡ��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		ccd_stop_flag_dly	<= i_ccd_stop_flag;
	end
	assign	ccd_stop_flag_rise	= (ccd_stop_flag_dly==1'b0 && i_ccd_stop_flag==1'b1) ? 1'b1 : 1'b0;

	//	===============================================================================================
	//	ref ***״̬�ź�***
	//	===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  xsg״̬�ź�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_XSG_PHASE) begin
			xsg_flag	<= 1'b1;
		end
		else begin
			xsg_flag	<= 1'b0;
		end
	end
	assign	o_xsg_flag	= xsg_flag;

	//	-------------------------------------------------------------------------------------
	//	readout״̬�ź�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			readout_flag 	<= 	1'b0;
		end
		else begin
			readout_flag 	<= 	1'b1;
		end
	end
	assign	o_readout_flag	= readout_flag;

	//  -------------------------------------------------------------------------------------
	//  ����˵�������� ov_vcount ������������Ϊ��λ
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(current_state==S_IDLE) begin
			vcount_reg	<= 'b0;
		end
		else begin
			if(i_line_end) begin
				vcount_reg	<= vcount_reg + 1'b1;
			end
		end
	end
	assign	ov_vcount	= vcount_reg;

	//	===============================================================================================
	//	ref ***FSM***
	//	===============================================================================================
	//FSM Sequential Logic
	always @ (posedge clk) begin
		current_state <= next_state;
	end

	//FSM Conbinatial Logic
	always @ ( * ) begin
		case(current_state)
			S_IDLE	: begin
				if(i_exp_line_end) begin
					next_state	= S_XSG_PHASE;
				end
				else begin
					next_state	= S_IDLE;
				end
			end
			S_XSG_PHASE	: begin
				if(vcount_reg==(XSG_LINE_NUM-1) && i_line_end==1'b1) begin
					next_state	= S_READOUT_PHASE;
				end
				else begin
					next_state	= S_XSG_PHASE;
				end
			end
			S_READOUT_PHASE	: begin
				if((vcount_reg==iv_frame_period && i_line_end==1'b1) || ccd_stop_flag_rise==1'b1) begin
					next_state	= S_IDLE;
				end
				else begin
					next_state	= S_READOUT_PHASE;
				end
			end
			default	: begin
				next_state = S_IDLE;
			end
		endcase
	end

endmodule
