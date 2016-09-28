
//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : ccd_flag.v
//  -- �����       : ��
//-------------------------------------------------------------------------------------------------
//
//  --�޸ļ�¼  :
//
//  -- ����         :| �޸�����     :|  �޸�˵��
//---------------------------------------------------------------------------------------
//  -- ��       	:| 09/16/2013   :|  ��ʼ�汾
//  -- ��Сƽ      	:| 04/29/2015   :|  �����޸ģ���Ӧ��ICX445 sensor
//  -- �Ϻ���      	:| 2015/12/8    :|  ��ֲ��u3��
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

module ccd_flag # (
	parameter	iv_href_start	= 26		,	//����Ч��ʼ
	parameter	iv_href_end		= 1398		,	//����Ч����
	parameter	iv_hd_rising	= 88		,   //hd��Ч��ʼ�Ĵ���
	parameter	SUB_WIDTH		= 30		,   //sub��Ч�źſ��
	parameter	iv_hd_falling		,   //hd��Ч�����Ĵ���


	parameter	iv_vd_rising	= 3		,   //vd��Ч��ʼ�Ĵ���
	parameter	iv_vd_falling	= 1		,   //vd��Ч�����Ĵ���

	parameter	iv_sub_rising	= 31	,   //sub��Ч��ʼ�Ĵ���
	parameter	iv_sub_falling	= 1		,   //sub��Ч�����Ĵ���

	parameter	XV_LINE_POS1	= 34		,
	parameter	XV_LINE_POS2	= 48		,
	parameter	XV_LINE_POS3	= 62		,
	parameter	XV_LINE_POS4	= 76		,
	parameter	XV_LINE_POS5	= 93		,
	parameter	XV_LINE_POS6	= 107		,
	parameter	XV_LINE_POS7	= 121		,
	parameter	XV_LINE_POS8	= 135		,
	parameter	XV_WIDTH		= 4			,
	parameter 	XV_LINE_DEFAULT	= 4'b1100	,	// XV�ź��������ڼ��Ĭ��ֵ
	parameter	XV_LINE_VALUE1	= 4'b1000	,
	parameter	XV_LINE_VALUE2	= 4'b1001	,
	parameter	XV_LINE_VALUE3	= 4'b0001	,
	parameter	XV_LINE_VALUE4	= 4'b0011	,
	parameter	XV_LINE_VALUE5	= 4'b0010	,
	parameter	XV_LINE_VALUE6	= 4'b0110	,
	parameter	XV_LINE_VALUE7	= 4'b0100	,
	parameter	XV_LINE_VALUE8	= 4'b1100	,



	)
	(
	input						clk      			,   //ʱ��
	input						reset				,	//ʱ�Ӹ�λ������Ч
	//�Ĵ���
	input	[12:0]				iv_headblank_start	,   //
	input	[12:0]				iv_headblank_end	,   //
	input	[12:0]				iv_vref_start		,   //ROI��ʼ����
	input	[12:0]				iv_tailblank_start	,   //ROI��������
	input	[12:0]				iv_tailblank_end	,   //
	input	[12:0]				iv_vcount			,	//
	input	[12:0]				iv_hcount			,   //
	//�ڲ��ź�
	input						i_ad_parm_valid		,	//
	input						i_readout_flag		,	//
	input	[12:0]				iv_xv_headblank		,	//
	input	[12:0]				iv_xv_tailblank		,	//
	input	[12:0]				iv_xv_xsg			,	//
	input						i_xsg_flag			,	//
	input						i_integration		,	//
	output						o_href				,   //����Ч�ź�
	output						o_vref				,   //����Ч�ź�
	output						o_headblank_flag	,   //����Ч�ź�
	output						o_tailblank_flag	,   //����Ч�ź�
	//AD �ӿ��ź�
	output						o_hd				,   //AD�����ź�HD
	output						o_vd				,   //AD�����ź�VD
	//CCD �ӿ��ź�
	output						o_sub				,	//
	output	[XV_WIDTH-1:0]		ov_xv					//��ֱ��ת�ź�
	);


	//  ===============================================================================================
	//  ��һ���֣�ģ�������Ҫ�õ����ź�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  �Ĵ�������������
	//  -------------------------------------------------------------------------------------

	reg			href_reg	= 1'b0;

	reg			[			       `XV_WD - 1 : 0]	xv_line				;
	reg												sub_line 			;

	reg												vd_reg				;
	reg												ad_parm_valid_flag	;
	reg			[  			     `LINE_WD - 1 : 0]	ad_parm_valid_cnt	;

	//  ===============================================================================================
	//  �ڶ����� ����� o_href��o_vref
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  ���ɸ�����ͨ��������Ч��־ ��� o_href
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(iv_hcount==iv_href_end) begin
			href_reg	<= 1'b0;
		end
		else if(iv_hcount==iv_href_start) begin
			href_reg	<= 1'b1;
		end
	end
	assign	o_href	= href_reg;

	//  -------------------------------------------------------------------------------------
	//  ���ɸ�����ͨ���ĳ���Ч��־ ��� o_vref
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_readout_flag) begin
			if(iv_vcount==iv_tailblank_start) begin
				vref_reg <= 1'b0;
			end
			else if(iv_vcount==iv_vref_start) begin
				vref_reg <= 1'b1;
			end
		end
		else begin
			vref_reg	<=	1'b0;
		end
	end
	assign	o_vref	= vref_reg;

	//  -------------------------------------------------------------------------------------
	//  ���ɸ�����ͨ���ĳ�ͷ���ٷ�ת��־ o_headblank_flag
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_readout_flag) begin
			if(iv_vcount==iv_headblank_end) begin
				headblank_flag <= 1'b0;
			end
			else if(iv_vcount==iv_headblank_start) begin
				headblank_flag <= 1'b1;
			end
		end
		else begin
			headblank_flag <= 1'b0;
		end
	end
	assign	o_headblank_flag	= headblank_flag;

	//  -------------------------------------------------------------------------------------
	//  ���ɸ�����ͨ���ĳ�β���ٷ�ת��־ o_tailblank_flag
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_readout_flag) begin
			if(iv_vcount==iv_tailblank_end) begin
				tailblank_flag <= 1'b0;
			end
			else if(iv_vcount==iv_tailblank_start) begin
				tailblank_flag <= 1'b1;
			end
		end
		else begin
			tailblank_flag	<=	1'b0;
		end
	end
	assign	o_tailblank_flag	= tailblank_flag;

	//  ===============================================================================================
	//  �������� �����o_vd��o_hd
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	i_ad_parm_valid ��Чʱvd����
	//  -------------------------------------------------------------------------------------
	always @ ( posedge clk )
	begin
		if(reset)
		ad_parm_valid_flag	<=	1'b0;
		else if(ad_parm_valid_cnt == `LINE_PERIOD)
		ad_parm_valid_flag	<=	1'b0;
		else if(i_ad_parm_valid)
		ad_parm_valid_flag	<=  1'b1;
	end

	//  -------------------------------------------------------------------------------------
	//	ά��1��������: ad_parm_valid_cnt
	//  -------------------------------------------------------------------------------------

	always @ ( posedge clk )
	begin
		if(reset)
		ad_parm_valid_cnt	<=	`LINE_WD'b0;
		else if(ad_parm_valid_flag)
		ad_parm_valid_cnt	<=	ad_parm_valid_cnt + `LINE_WD'b1;
		else
		ad_parm_valid_cnt 	<=  `LINE_WD'b0;
	end

	//  -------------------------------------------------------------------------------------
	//  ����AD��ֱͬ����־
	//	i_ad_parm_valid��Чʱvd����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_readout_flag) begin
			if(iv_vcount==iv_vd_falling) begin
				vd_reg	<= 1'b0;
			end
			else if(iv_vcount==iv_vd_rising) begin
				vd_reg	<= 1'b1;
			end
		end
		else begin
			vd_reg	<= 1'b1;
		end
	end
	assign o_vd = vd_reg &&  !ad_parm_valid_flag;

	//  -------------------------------------------------------------------------------------
	//	����ADˮƽͬ���ź�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_readout_flag) begin
			if(iv_hcount==iv_hd_falling) begin
				hd_reg	<= 1'b0;
			end
			else if(iv_hcount==iv_hd_rising) begin
				hd_reg	<= 1'b1;
			end
		end
		else begin
			hd_reg	<= 1'b1;
		end
	end
	assign	o_hd	= hd_reg;

	//  ===============================================================================================
	//  ���Ĳ��� ����� o_xv
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	����˵��������������xvʱ��
	//	�ؼ��㣺Ҫ����CCDʱ���ֲ�����xvʱ��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		case (iv_hcount)
			XV_LINE_POS1	: xv_line	<= XV_LINE_VALUE1;
			XV_LINE_POS2	: xv_line	<= XV_LINE_VALUE2;
			XV_LINE_POS3	: xv_line	<= XV_LINE_VALUE3;
			XV_LINE_POS4	: xv_line	<= XV_LINE_VALUE4;
			XV_LINE_POS5	: xv_line	<= XV_LINE_VALUE5;
			XV_LINE_POS6	: xv_line	<= XV_LINE_VALUE6;
			XV_LINE_POS7	: xv_line	<= XV_LINE_VALUE7;
			XV_LINE_POS8	: xv_line	<= XV_LINE_VALUE8;
			default			: xv_line	<= xv_line;
		endcase
	end

	//  -------------------------------------------------------------------------------------
	//	����˵�������ɸ��׶�XVϵ���ź�
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_xsg_flag) begin
			xv_reg	<= iv_xv_xsg;
		end
		else if(o_headblank_flag) begin
			xv_reg	<= iv_xv_headblank;
		end
		else if(o_tailblank_flag) begin
			xv_reg	<= iv_xv_tailblank;
		end
		else begin
			xv_reg	<= xv_line;
		end
	end
	assign	ov_xv	= xv_reg;

	//  ===============================================================================================
	//  ���岿�֣�sub�ź������߼�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	����˵��������������sub��־
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(iv_hcount==iv_sub_rising) begin
			sub_line <= 1'b1;
		end
		else if(iv_hcount==iv_sub_falling) begin
			sub_line <= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	����˵������� o_sub
	//	�ؼ��㣺�ع⡢xsg�׶�û�� o_sub
	//	BUG,ID2713��102us�����ع�ʱ�侫�ȳ���1us.(102us�����ع�ʱ�侫�ȳ���1us��)
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset)
		o_sub		<=	1'b1;
		else if(i_integration | ((iv_vcount != `FRAME_WD'd0) & i_xsg_flag))	//С�ع�ʱ������0�п��Դ���sub������xsg�е�sub�ź�û��
		o_sub		<=	1'b1;
		else
		o_sub		<=	sub_line;
	end


endmodule