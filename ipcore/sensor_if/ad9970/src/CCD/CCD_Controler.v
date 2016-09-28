/**********************************************************************************************
-- Module		: CCD_Controler
-- File 		: CCD_Controler.v
-- Description 	: It is one module of the CCD_Top
-- Simulator 	: Modelsim 6.2c / Windows XP2
-- Synthesizer 	: Synplify8.0 / Windows XP2
-- Author / Designer 	: Song Weiming (songwm@daheng-image.com)
-- Copyright (c) notice : Daheng image Vision 2007-2010
--------------------------------------------------------------------
--------------------------------------------------------------------
-- Revision Number 	: 1
-- Modifier 		: LuDawei (ludw@daheng-image.com)
-- Description 		: Initial Design
//----------------------------------------------------------------------------
// Modification history :
// 2007-
// 2008-01-18 : LuDawei: finished
***********************************************************************************************/
`timescale 1ns/1ns
`include "RJ33J3DEF.v"
/**********************************************************************************************
1��ģ��ʵ�弰�˿ڶ���
Pixclk                         : ����ʱ��
Reset                          : ȫ�ָ�λ�ź�
HD,VD                          : �����AD����ͬ����֡ͬ���źţ��½�����Ч
XV,XSUB                    	: �������ֱ����оƬ��Vϵ���źš�֡��ת�źź�SUB�źţ�������3400��
HBLK,PBLK,CLPOB,CLPDM          : �����AD��ǯλ�źţ�����AD�Ĵ�ģʽ
Frame_period                   : ֡���ڣ����ϲ�CPU����
HeadBlank_number               : ��ͷ���ܴ����Ĵ��������ϲ�CPU����
Exp_start,Exp_end              : �ع⿪ʼ���ع�����Ĵ��������ϲ�CPU����
HeadBlank_start                ����ͷ���ܿ�ʼ�Ĵ��������ϲ�CPU����
Vsync_start                    : ����Ч��ʼ(��ͷ���ܽ���)�Ĵ��������ϲ�CPU����
TailBlank_start                : ��β���ܿ�ʼ(����Ч����)�Ĵ��������ϲ�CPU����
Exposure_flag                  : �ع��־�ź�
Hcount                         : ˮƽ������
Vcount                         ����ֱ���������ɶ���ģ�鴫��
Href_start                     ������Ч��ʼ�Ĵ������ɶ���ģ�鴫��
Href_end                       ������Ч�����Ĵ������ɶ���ģ�鴫��
Href                           : ����Ч�źţ�����ź�
Vsync                          : ����Ч�źţ�����ź�
Hend                           ���н�����־�ź�
***********************************************************************************************/
module       ccd_controler (
	input                       pixclk                 		,		//����ʱ��
	input                       reset                		,       //��λ
	input                       i_exposure_flag        		,       //�ع��־
	input                       i_waitflag             		,       //�ȴ���־
	input                       i_xsg_start            		,       //֡��ת�׶ο�ʼ��־
	input						i_xsub_last                 ,       //����SUB�ź�
	input       [`REG_WD-1:0]   iv_href_start          		,       //����Ч��ʼ�Ĵ���
	input       [`REG_WD-1:0]   iv_href_end            		,       //����Ч�����Ĵ���
	input       [`REG_WD-1:0]   iv_frame_period        		,       //֡���ڼĴ���
	input		[`REG_WD-1:0]	iv_hperiod					,       //�����ڼĴ���
	input       [`REG_WD-1:0]   iv_headblank_number    		,       //��ͷ���ܸ����Ĵ���
	input       [`REG_WD-1:0]   iv_headblank_start     		,       //��ͷ���ܿ�ʼ�Ĵ���
	input       [`REG_WD-1:0]   iv_vsync_start 	        	,       //����Ч��ʼ�Ĵ���
	input       [`REG_WD-1:0]   iv_vsync_fpga_start     	,       //����Ч�����ʼ�Ĵ���
	input       [`REG_WD-1:0]   iv_tailblank_start     		,       //��β������ʼ�Ĵ���
	input       [`REG_WD-1:0]   iv_tailblank_number    		,       //��β���ܸ���
	input       [`REG_WD-1:0]   iv_tailblank_end    		,       //��β���ܽ����Ĵ���
	input       [`REG_WD-1:0]   iv_vcount              		,       //�м�����
	input						i_triggersel				,		//����ģʽ
	
	input						i_xsb_falling_direc			,		//xsub�½��ز����ķ���0��ǰ��1�ͺ�
	input       [`REG_WD-1:0]   iv_xsb_falling_compensation ,		//xsub��������ֵ
	input						i_xsb_rising_direc			,		//xsub�����ز����ķ���0��ǰ��1�ͺ�
	input       [`REG_WD-1:0]   iv_xsb_rising_compensation	,		//xsub��������ֵ
	
	
	output                      o_xsub						,       //SUB�ź�
	output  reg                	o_hd                        ,       //AD�����ź�HD
	output  reg                	o_vd       			        ,       //AD�����ź�VD
	output	reg [`XSG_WD-1:0]	ov_xsg       				,       //֡��ת�ź�
	output  reg           		o_hend						,       //��β�ź�
	output	reg					o_href						,       //����Ч
	output						o_vsync       				,       //����Ч
	output      [`V_WIDTH-1:0]	ov_xv                       ,       //��ֱ��ת�ź�
	output	reg					o_xsg_flag                  ,      //֡��ת��־
	output	reg					o_xsg_clear					,
	output		[`REG_WD-1:0]	ov_hcount
	);

	/**********************************************************************************************
	2���Ĵ�������������
	***********************************************************************************************/
	reg                         headblank_flag          ;
	reg                         tailblank_flag          ;
	reg                         tailline_flag			;
	reg                         vsync_flag				;
	reg                         vsync_fpga_flag			;
	reg         [`V_WIDTH-1:0]  xv_line					;
	reg         [`V_WIDTH-1:0]  xv_xsg					;
	wire        [`V_WIDTH-1:0]  xv_headblank			;
	wire        [`V_WIDTH-1:0]  xv_tailblank			;
	wire        [`REG_WD-1:0]	xsgcount				;
	reg			[2:0]			triggersel_shift		;
	reg                         xsub_line      			;
	reg							hclear					;
	wire		[`REG_WD-1:0]	hcount					;
	reg							vsync_mask				;

	reg							vsync_flag_dly 		= 1'b0;
	reg		[1:0]				exposure_flag_shift = 2'b11;
	/***************************************************************************************************************
	3����������ģ��,��ģ�鶨�����£�
	Counter_HeadBlank����ͷ���ܼ�����ģ��
	Counter_TailBlank����β���ܼ�����ģ��
	Counter_H        ��ˮƽ������ģ��
	Counter_V        ����ֱ������ģ��
	Counter_Xsg      ��֡��ת������ģ��
	Head_BlankRun    ����ͷ����ģ��
	Tail_BlankRun    ����β����ģ��
	ע������ģ�����ϸ�˿ڶ��������ģ���ļ�˵��
	****************************************************************************************************************/
	counter  counter_h_inst (
	.clk		(pixclk				),
	.hend		(1'b1				),
	.i_clk_en	(1'b1				),
	.i_aclr		(hclear				),
	.ov_q       (hcount				)
	);

	counter  counter_xsg_inst (
	.clk		(pixclk				),
	.hend		(1'b1				),
	.i_clk_en	(1'b1				),
	.i_aclr		(!o_xsg_flag		),
	.ov_q       (xsgcount			)
	);

	blank_run # (
	.LINE_START_POSITION	(`HEADBLANK_LINE_START_POSITION	),
	.LINE_END_POSITION		(`HEADBLANK_LINE_END_POSITION	),
	.STATE_WIDTH			(`HEADBLANK_STATE_WIDTH			),
	.XV_DEFAULT_VALUE		(`XV_BLANKHEAD_DEFAULTVALUE		),
	.XV_VALUE1				(`V_BLANKHEAD_VALUE1			),
	.XV_VALUE2				(`V_BLANKHEAD_VALUE2			),
	.XV_VALUE3				(`V_BLANKHEAD_VALUE3			),
	.XV_VALUE4				(`V_BLANKHEAD_VALUE4			),
	.XV_VALUE5				(`V_BLANKHEAD_VALUE5			),
	.XV_VALUE6				(`V_BLANKHEAD_VALUE6			),
	.XV_VALUE7				(`V_BLANKHEAD_VALUE7			),
	.XV_VALUE8				(`V_BLANKHEAD_VALUE8			)
	)
	headblank_inst (
	.clk					(pixclk							),
	.reset					(reset							),
	.iv_hcount				(hcount							),
	.i_blank_flag			(headblank_flag					),
	.iv_blank_number		(iv_headblank_number			),
	.ov_xv					(xv_headblank					)
	);

	blank_run # (
	.LINE_START_POSITION	(`TAILBLANK_LINE_START_POSITION	),
	.LINE_END_POSITION		(`TAILBLANK_LINE_END_POSITION	),
	.STATE_WIDTH			(`TAILBLANK_STATE_WIDTH			),
	.XV_DEFAULT_VALUE		(`XV_BLANKTAIL_DEFAULTVALUE		),
	.XV_VALUE1				(`V_BLANKTAIL_VALUE1			),
	.XV_VALUE2				(`V_BLANKTAIL_VALUE2			),
	.XV_VALUE3				(`V_BLANKTAIL_VALUE3			),
	.XV_VALUE4				(`V_BLANKTAIL_VALUE4			),
	.XV_VALUE5				(`V_BLANKTAIL_VALUE5			),
	.XV_VALUE6				(`V_BLANKTAIL_VALUE6			),
	.XV_VALUE7				(`V_BLANKTAIL_VALUE7			),
	.XV_VALUE8				(`V_BLANKTAIL_VALUE8			)
	)
	tailblank_inst (
	.clk					(pixclk					),
	.reset					(reset				),
	.iv_hcount				(hcount					),
	.i_blank_flag			(tailblank_flag			),
	.iv_blank_number		(iv_tailblank_number	),
	.ov_xv					(xv_tailblank			)
	);

	/***************************************************************************************************************
	4��ˮƽ��������
	Hend       :ˮƽ��������λ�ź� 1-reset
	****************************************************************************************************************/
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			hclear	<= 1'b1;
		end
		else begin
			if(hcount == iv_hperiod) begin
				hclear	<= 1'b1;
			end
			else begin
				hclear	<= 1'b0;
			end
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_hend	<= 1'b1;
		end
		else begin
			//if (hcount==`REG_WD'h30)
			if(hcount == `REG_WD'h1) begin
				o_hend	<= 1'b1;
			end
			else begin
				o_hend	<= 1'b0;
			end
		end
	end
	assign	ov_hcount	= hcount;
	/***************************************************************************************************************
	6�����ɳ�ͷ��β���ܡ��������Լ�֡��ת�ı�־�źţ�
	****************************************************************************************************************/
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			triggersel_shift <=	3'b000;
		end
		else begin
			triggersel_shift <=	{triggersel_shift[1:0],i_triggersel};
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			vsync_mask	<= 1'b1;
		end
		else if(triggersel_shift == 3'b100) begin		//�ɴ����л�������ģʽ�������α�־����
			vsync_mask	<= 1'b0;
		end
		else if(o_xsg_clear) begin						//����һ�������ع�󣨻���һ֡ʱ���ȥ������
			vsync_mask	<= 1'b1;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	���vsync_flag_dly�źţ�ԭ����֮ǰ��hend����hcount��0x30�Ĳ���������hend��hcount����0x1��ʱ�����
	//	��0x1-0x30��ʱ�򣬲���sub�źţ�Ϊ��ʹvsyncԭ��sub�źţ���Ҫ�ӳ�vsync�źŲ�����ʱ��
	//  -------------------------------------------------------------------------------------
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			vsync_flag_dly	<= 1'b0;
		end
		//	else if((vsync_flag == 1'b1)&&(hcount==`REG_WD'h30)) begin
//		else if((vsync_fpga_flag == 1'b1)&&(hcount==`REG_WD'h30)) begin
		else if((vsync_fpga_flag == 1'b1)&&(hcount==`REG_WD'h64)) begin
			vsync_flag_dly	<= 1'b1;
		end
		//	else if(!vsync_flag) begin
//		else if((!vsync_fpga_flag)&&(hcount==`REG_WD'h30)) begin
		else if((!vsync_fpga_flag)&&(hcount==`REG_WD'h64)) begin
			vsync_flag_dly	<=	1'b0;
		end
	end

	//assign  o_vsync= vsync_flag & vsync_mask;
	assign  o_vsync	= vsync_flag_dly & vsync_mask;

//	always@(posedge pixclk or posedge reset) begin
//		if(reset) begin
//			headblank_flag	<= 1'b0;
//			tailblank_flag	<= 1'b0;
//			vsync_flag    	<= 1'b0;
//			vsync_fpga_flag	<= 1'b0;
//			tailblank_flag	<= 1'b0;
//			tailline_flag	<= 1'b0;
//		end
//		else if(o_hend) begin
//			case(iv_vcount)
//				iv_headblank_start			:	begin	headblank_flag	<=1'b1;	end
//				iv_vsync_start				:	begin	headblank_flag	<=1'b0;
//														vsync_flag		<=1'b1;	end
//				iv_vsync_fpga_start			:	begin	vsync_fpga_flag	<=1'b1;	end
//	
//				iv_tailblank_start			:	begin	vsync_flag    	<=1'b0;
//														vsync_fpga_flag	<=1'b0;
//				tailblank_flag	<=1'b1;	end
//				iv_tailblank_end			:	begin	tailblank_flag	<=1'b0;
//														tailline_flag	<=1'b1;
//				end
//				iv_frame_period-16'h0001	:	begin	tailline_flag	<=1'b0;	end
//				default:	;
//			endcase
//		end
//	end
	
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			headblank_flag	<= 1'b0;
		end
		else if(o_hend) begin
			if(iv_vcount == iv_headblank_start) begin
				headblank_flag	<= 1'b1;
			end
			else if(iv_vcount == iv_vsync_start) begin
				headblank_flag	<= 1'b0;
			end
		end
	end
	
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			tailblank_flag	<= 1'b0;
		end
		else if(o_hend) begin
			if(iv_vcount == iv_tailblank_start) begin
				tailblank_flag	<= 1'b1;
			end
			else if(iv_vcount == iv_tailblank_end) begin
				tailblank_flag	<= 1'b0;
			end
		end
	end
	
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			vsync_flag    	<= 1'b0;
		end
		else if(o_hend) begin
			if(iv_vcount == iv_vsync_start) begin
				vsync_flag	<= 1'b1;
			end
			else if(iv_vcount == iv_tailblank_start) begin
				vsync_flag	<= 1'b0;
			end
		end
	end
	
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			vsync_fpga_flag	<= 1'b0;
		end
		else if(o_hend) begin
			if(iv_vcount == iv_vsync_fpga_start) begin
				vsync_fpga_flag	<= 1'b1;
			end
			else if(iv_vcount == iv_tailblank_start) begin
				vsync_fpga_flag	<= 1'b0;
			end
		end
	end
	
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			tailline_flag	<= 1'b0;
		end
		else if(o_hend) begin
			if(iv_vcount == iv_tailblank_end) begin
				tailline_flag	<= 1'b1;
			end
			else if(iv_vcount == (iv_frame_period-16'h0001)) begin
				tailline_flag	<= 1'b0;
			end
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_vd	<= 1'b1;
		end
		else begin
			if(iv_vcount == `VD_RISING) begin
				o_vd	<= 1'b1;
			end
			else if(iv_vcount == `VD_FALLING) begin
				o_vd	<= 1'b0;
			end
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_hd	<= 1'b1;
		end
		else begin
			if(hcount == `HD_RISING) begin
				o_hd	<= 1'b1;
			end
			else if(hcount == `HD_FALLING) begin
				o_hd	<= 1'b0;
			end
		end
	end
	
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			xv_line	<= `XV_LINE_DEFAULTVALUE;
			
		end
		else begin
			case(hcount)
				`XV_LINE_POSITION1	: xv_line	<= `V_LINE_VALUE1;
				`XV_LINE_POSITION2	: xv_line	<= `V_LINE_VALUE2;
				`XV_LINE_POSITION3	: xv_line	<= `V_LINE_VALUE3;
				`XV_LINE_POSITION4	: xv_line	<= `V_LINE_VALUE4;
				`XV_LINE_POSITION5	: xv_line	<= `V_LINE_VALUE5;
				`XV_LINE_POSITION6	: xv_line	<= `V_LINE_VALUE6;
				`XV_LINE_POSITION7	: xv_line	<= `V_LINE_VALUE7;
				`XV_LINE_POSITION8	: xv_line	<= `V_LINE_VALUE8;
				default	:	;
			endcase
		end
	end
	
//	always@(posedge pixclk or posedge reset) begin
//		if(reset) begin
//			xsub_line	<= 1'b1;
//		end
//		else begin
//			case(hcount)
//				`SUB_FALLING	: xsub_line	<= 1'b0;
//				`SUB_RISING		: xsub_line	<= 1'b1;
//				default	:	;
//			endcase
//		end
//	end	
	
	//xsub ������
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			xsub_line	<= 1'b1;
		end
		else begin
			if(i_xsb_falling_direc == 1'b0) begin	//xsub �½��ص�λ����ǰ�ƶ�
				if(iv_xsb_falling_compensation == `REG_WD'b0) begin	//������������ֵʱ0ʱ���������õ���ֵʱ1513��hount�����������ֵ
					if(hcount == `SUB_FALLING) begin
						xsub_line	<= 1'b0;
					end
				end
				else begin
					if(hcount == `LINE_PIX - iv_xsb_falling_compensation) begin	//������������ֵ��0ʱ��1513-reg��Ϊxsub�½��ص�λ��
						xsub_line	<= 1'b0;
					end
				end
			end
			else begin								//xsub �½��ص�λ�������ƶ�
				if(hcount == `SUB_FALLING + iv_xsb_falling_compensation) begin
					xsub_line	<= 1'b0;
				end
			end
			
			if(i_xsb_rising_direc == 1'b0) begin	//xsub �����ص�λ����ǰ�ƶ�
				if(hcount == `SUB_RISING - iv_xsb_rising_compensation) begin
					xsub_line	<= 1'b1;
				end
			end
			else begin								//xsub �����ص�λ�������ƶ�
				if(hcount == `SUB_RISING + iv_xsb_rising_compensation) begin
					xsub_line	<= 1'b1;
				end
			end
		end
	end	
	
	
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_href	<= 1'b0;
		end
		else begin
			if(hcount == iv_href_start) begin
				o_href	<= 1'b1;
			end
			else if(hcount == iv_href_end) begin
				o_href	<= 1'b0;
			end
		end
	end
	/***************************************************************************************************************
	10��֡��ת��
	****************************************************************************************************************/
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_xsg_flag	<= 1'b0;
		end
		else if(o_xsg_clear) begin
			o_xsg_flag	<= 1'b0;
		end
		else if(i_xsg_start) begin
			o_xsg_flag	<= 1'b1;
		end
	end

//	always@(posedge pixclk or posedge reset) begin
//		if(reset) begin
//			xv_xsg		<= `XV_XSG_DEFAULTVALUE;
//			ov_xsg		<= {`XSG_WD{1'B1}};
//			o_xsg_clear	<= 1'b0;
//		end
//		else begin
//			case(xsgcount)
//				`XV_XSG_POSITION1   :	xv_xsg 		<= `V_XSG_VALUE1;
//				`XV_XSG_POSITION2   :	xv_xsg  	<= `V_XSG_VALUE2;
//				`XSG1_RISING    	:	ov_xsg		<= `XSG_VALUE1;
//				`XSG1_FALLING    	:	ov_xsg		<= `XSG_VALUE2;
//				`XSGCOUNT_LENGTH    :	o_xsg_clear	<= 1'b0;
//				default				:   o_xsg_clear	<= 1'b1;
//			endcase
//		end
//	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			xv_xsg	<= `XV_XSG_DEFAULTVALUE;
		end
		else begin
			if(xsgcount == `XV_XSG_POSITION1) begin
				xv_xsg	<= `V_XSG_VALUE1;
			end
			else if(xsgcount == `XV_XSG_POSITION2) begin
				xv_xsg	<= `V_XSG_VALUE2;
			end
		end
	end

	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			ov_xsg	<= {`XSG_WD{1'B1}};
		end
		else begin
			if(xsgcount == `XSG1_RISING) begin
				ov_xsg	<= `XSG_VALUE1;
			end
			else if(xsgcount == `XSG1_FALLING) begin
				ov_xsg	<= `XSG_VALUE2;
			end
		end
	end
	
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			o_xsg_clear	<= 1'b0;
		end
		else begin
			if(xsgcount == `XSGCOUNT_LENGTH) begin
				o_xsg_clear	<= 1'b1;
			end
			else begin
				o_xsg_clear	<= 1'b0;
			end
		end
	end

	/***************************************************************************************************************
	11���ع��߼���
	�ع��Ϊ���ع��С���ع⣬����һ�е��ع�ʱ����С���ع�����ʾ
	****************************************************************************************************************/
	always@(posedge pixclk or posedge reset) begin
		if(reset) begin
			exposure_flag_shift	<= 2'b11;
		end
		else begin
			exposure_flag_shift	<= {exposure_flag_shift[0],i_exposure_flag};
		end
	end

	assign o_xsub =	(exposure_flag_shift[1]	== 1'b1) ? i_xsub_last:
	(o_xsg_flag	== 1'b1) ? 1'b1:
	xsub_line ;

	/***************************************************************************************************************
	12������Vϵ���źź�SUB�ź������
	****************************************************************************************************************/
	assign ov_xv   =(headblank_flag	== 1'b1)     ?  xv_headblank	:
	(vsync_flag        	== 1'b1)     ?  xv_line     	:
	(o_xsg_flag         == 1'b1)     ?  xv_xsg			:
	(tailblank_flag    	== 1'b1)     ?  xv_tailblank	:
	(i_waitflag      	== 1'b1)     ?  xv_line			:
	(tailline_flag     	== 1'b1)     ?  xv_line			:
	`XV_DEFVALUE;




endmodule