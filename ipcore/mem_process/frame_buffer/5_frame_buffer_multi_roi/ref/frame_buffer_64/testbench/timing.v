/**********************************************************************************
timingģ����Ҫ���������г��źţ��Լ��г������źţ�����ģ��ʱ���ⲿ����ͨ������
��ͬ�Ĳ�����ʵ�ֵ����г���λ��Ч����
**********************************************************************************/
`timescale 1ns / 1ps
`define		U3V_FORMAT
module timing
(
	input				clk				,
	input				reset_n			,
	input		[15:0]	iv_h_period 	,
	input		[15:0]	iv_v_petiod 	,
	input		[15:0]	iv_dval_start	,
	input		[15:0]	iv_with			,
	input		[15:0]	iv_fval_start	,
	input		[15:0]	iv_hight		,
	input		[15:0]	iv_u3v_size		,
	input				i_pause			,
	output	reg			o_trailer_flag	,
	output	reg			o_hend			,
	output	reg			o_fval			,
	output	reg			o_dval			,
	output	reg			o_vend
    );

	reg			  [15:0]vcount			;
	reg			  [15:0]hcount			;
	wire			[15:0]sum			;
//==============================================================================
//�м���
//==============================================================================
always@(posedge clk or negedge reset_n)
    begin
        if (!reset_n)
        	begin
	            o_hend<=1'b0;
	            hcount<=16'h0000;
        	end
        else if (hcount==iv_h_period)
        	begin
				o_hend<=1'b1;
				hcount<=16'h0000;
			end
        else if ( !i_pause )
            begin
				o_hend<=1'b0;
				hcount<=hcount+16'h0001;
			end
    end
//==============================================================================
//������
//==============================================================================
always@(posedge clk or negedge reset_n)
    begin
        if (!reset_n)
        	begin
	            o_vend<=1'b0;
	            vcount<=16'h0000;
        	end
        else if ((hcount==iv_h_period) && (!i_pause))
        	begin
	            if (vcount==iv_v_petiod)
	            	begin
						o_vend<=1'b1;
						vcount<=16'h0000;
					end
	            else
	                begin
						o_vend<=1'b0;
						vcount<=vcount+16'h0001;
					end
			end
    end

//==============================================================================
//��������Ч��FVAL��
//==============================================================================
always@(posedge clk or negedge reset_n)
    begin
        if (!reset_n)
            o_fval<=1'b0;
        else if (hcount==iv_h_period)
        	begin
	        	`ifdef U3V_FORMAT
		            if (vcount==iv_fval_start-1)
						o_fval<=1'b1;
		            else if(vcount==(iv_fval_start+iv_hight+1))
						o_fval<=1'b0;
				`else
		            if (vcount==iv_fval_start-2)			//ģ��u3���ʹ��
						o_fval<=1'b1;
		            else if(vcount==(iv_fval_start+iv_hight-1))
						o_fval<=1'b0;
				`endif

			end
    end

//==============================================================================
//��������Ч��DVAL��
//  ===============================================================================================
//  Ϊ��frame_bufferģ��ʶ��β��,��Ч��־ǰ�����һ��������
//	w_trailer_flag  _________|��������������������������������������������������������������������|_____________
//	β��������Ч     _________|��������������������������������������������������������������������|_____________
//	β������	     ____________X=============================X_______________
//  ===============================================================================================
//==============================================================================
`ifdef  U3V_FORMAT
always@(posedge clk or negedge reset_n)
    begin
        if (!reset_n)
        	begin
            	o_dval			<=1'b0;
            end
        else if (!i_pause && ( vcount>= iv_fval_start)&& ( vcount<= (iv_fval_start+iv_hight+1)))
        	begin
	            if (hcount==iv_dval_start)
					o_dval<=1'b1;
	            else if((vcount!=iv_fval_start) && hcount==(iv_dval_start+iv_with))
					o_dval<=1'b0;
				else if ((vcount==iv_fval_start) && hcount == (iv_dval_start+7) )
					o_dval<=1'b0;
				else if ((vcount==iv_fval_start+iv_hight+1) && hcount == (iv_dval_start+6) )
					o_dval<=1'b0;

			end
        else
        	begin
        		o_dval<=1'b0;
        	end
    end

always@(posedge clk or negedge reset_n)
    begin
        if (!reset_n)
            o_trailer_flag	<=1'b0;
        else if ((vcount==iv_fval_start+iv_hight+1) && (hcount>=iv_dval_start-1) && (hcount<=iv_dval_start+4))
			o_trailer_flag	<=1'b1;
	    else
	        o_trailer_flag	<=1'b0;
    end

`else
always@(posedge clk or negedge reset_n)
    begin
        if (!reset_n)
            o_dval<=1'b0;
        else if (!i_pause && ( vcount>= iv_fval_start)&& ( vcount< (iv_fval_start+iv_hight)))
			begin
	            if (hcount==iv_dval_start)
					o_dval<=1'b1;
	            else if(hcount==(iv_dval_start+iv_with))
					o_dval<=1'b0;
			end
        else
        	begin
        		o_dval<=1'b0;
        	end
    end
`endif

endmodule
