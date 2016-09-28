
//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : ccd_xsg.v
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  --�޸ļ�¼  :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���      	:| 2015/12/23 10:51:52	:|  ��ʼ�汾����mv_ccd���޸�
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

module ccd_xsg # (
	parameter	XV_WIDTH		= 4		,	//XV���
	parameter	XSG_WIDTH		= 1			//XSG���
	)
	(
	input								clk					,   //ʱ��
	input								reset				,	//��λ������Ч
	input								i_xsg_flag			,	//xsg��ʼ��־
	input		[`EXP_WD-1:0]			iv_xsg_width		,	//XSG���
	input		[`EXP_WD-1:0]			iv_exp_xsg_reg		,	//
	output								o_exposure_end		,	//
	output		[XSG_WIDTH-1:0]			ov_xsg		        ,	//XSG�׶�XSG�ź�
	output		[XV_WIDTH-1:0]			ov_xv_xsg		    	//XSG�׶�XV�ź�
	);



	reg			[  			 `XSG_LINE_WD - 1 : 0]  xsg_count			;

	//  ===============================================================================================
	//  �ڶ����֣�XSG�߼�
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//  ����˵��������֡��ת�׶μ����� xsg_count
	//  -------------------------------------------------------------------------------------

	always @ ( posedge clk )
	begin
		if(reset)
		begin
			xsg_count <= `XSG_LINE_WD'b0;
		end
		else if(i_xsg_flag)
		begin
			xsg_count <= xsg_count + `XSG_LINE_WD'b1;
		end
		else
		begin
			xsg_count <= `XSG_LINE_WD'b0;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	bug����
	//	1.��xsg�Ŀ��+1=�����ڱ���ʱ��iv_exp_xsg_reg==xsg_count��ʱ�̣�i_xsg_flagȴ�ǵ͵�ƽ�������޷����o_exposure_end
	//	2.���ж�������Ϊ((iv_exp_xsg_reg-1) <= xsg_count)����xsg�Ŀ��+1=�����ڱ���ʱ��Ҳ�������o_exposure_end
	//	-------------------------------------------------------------------------------------
	//		assign o_exposure_end 	= 	(iv_exp_xsg_reg == xsg_count) && i_xsg_flag;
	assign o_exposure_end 	= 	((iv_exp_xsg_reg-1) <= xsg_count) && i_xsg_flag;


	always @ (posedge clk) begin
		if(reset) begin
			ov_xv_xsg	<= `XV_XSG_DEFAULT;
		end
		else if(i_xsg_flag==1'b1 && xsg_count==0) begin
			ov_xv_xsg	<= `V_XSG_VALUE1;
		end
		else if(xsg_count==(iv_exp_xsg_reg - iv_xsg_width + `XV_XSG_POSITION1)) begin
			ov_xv_xsg	<= `V_XSG_VALUE2;
		end
	end

	always @ (posedge clk) begin
		if(reset) begin
			ov_xsg	<= `XSG_VALUE2;
		end
		else if(xsg_count==(iv_exp_xsg_reg - iv_xsg_width + `XSG1_RISING)) begin
			ov_xsg	<= `XSG_VALUE1;
		end
		else if(xsg_count==(iv_exp_xsg_reg - iv_xsg_width + `XSG1_FALLING)) begin
			ov_xsg	<= `XSG_VALUE2;
		end
	end


endmodule