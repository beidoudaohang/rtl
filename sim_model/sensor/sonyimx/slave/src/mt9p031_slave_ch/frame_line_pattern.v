//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : frame_line_pattern
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2013/5/24 10:08:24	:|  ��ʼ�汾
//  -- �Ϻ���       :| 2014/6/9 14:52:56	:|  ��������Ϊ�˿ڣ�������Ե�ʱ��ı�֡��
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     :	���� fval �� lval ʱ��
//              1)  : ����parameter�Ķ��巽ʽ����define
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//		�궨��˵�����£�
//
//																				|<--iv_frame_hide	  ->|
//					_____________________________________________________________						______
//	fval	________|															|_______________________|
//							_________		_________		   	_________
//	lval	________________|		|_______|		|____****___|		|________________________________
//
//					|<-	  ->|		|<-	  ->|<-   ->|					|<-   ->|
//						|				|		|							|
//				iv_front_porch 			|		|							|
//								iv_line_hide	|							|
//											iv_width					iv_back_porch

//-------------------------------------------------------------------------------------------------
//���浥λ/����
//-------------------------------------------------------------------------------------------------

module frame_line_pattern # (
	parameter			VBLANK_LINE			= 22	,	//Vertical blanking period
	parameter			FRAME_INFO_LINE		= 1		,	//Frame information line
	parameter			IGNORE_OB_LINE		= 6		,	//Ignored OB
	parameter			VEFFECT_OB_LINE		= 4			//Vertical effective OB
	)
	(
	//ϵͳ����
	input				clk							,	//ʱ��
	input				reset						,	//��λ
	input				i_xtrig						,	//�����źţ�������֮���µ�һ֡��ʼ����
	input				i_xhs						,	//����Ч�źţ�������֮���µ�һ�п�ʼ����
	input				i_xvs						,	//����Ч�źţ�û���õ�
	input				i_xclr						,	//��λ�źţ�����Ч
	//��������
	input				i_pause_en					,	//1:��ͣ��������ͣ 0:�ָ�
	input				i_continue_lval				,	//1:������ʱ��Ҳ�����ź������0:������ʱ��û�����ź����
	input	[15:0]		iv_width					,	//����Ч�����ظ������п����64k
	input	[15:0]		iv_line_hide				,	//�����������ظ��������������64k
	input	[15:0]		iv_height					,	//һ֡�е��������������64k
	input	[15:0]		iv_frame_hide				,	//֡�������������������64k
	input	[15:0]		iv_front_porch				,	//ǰ�أ�fval�����غ�lval������֮��ľ��룬ǰ�غ���֮���ܳ���������
	input	[15:0]		iv_back_porch				,	//���أ�fval�½��غ�lval�½���֮��ľ���
	//���
	output				o_fval						,	//���ź�
	output				o_lval							//���ź�
	);

	//ref signals
	reg		[2:0]		xtrig_shift					= 3'b000;
	wire				xtrig_rise					;
	wire				xtrig_fall					;
	reg		[2:0]		xhs_shift					= 3'b000;
	wire				xhs_rise					;
	wire				xhs_fall					;
	reg					xtrig_rise_reg				= 1'b0;

	reg		[16:0]		allpix_cnt_per_line 		= 17'h10000	;	//һ�������е�pix�����������ڼ�ġ����ֵ��128k��pix���㹻��
	reg		[16:0]		line_cnt 					= 17'h10000	;	//�м�����
	reg					fval_reg					= 1'b0	;	//���ź�
	reg					lval_reg					= 1'b0	;	//���ź�
	reg					fval_reg1					= 1'b0	;	//���ź�
	reg					lval_reg1					= 1'b0	;	//���ź�


	//ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***edge***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	xtrig ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		xtrig_shift	<= {xtrig_shift[1:0],i_xtrig};
	end
	assign	xtrig_rise	= (xtrig_shift[2:1]==2'b01) ? 1'b1 : 1'b0;
	assign	xtrig_fall	= (xtrig_shift[2:1]==2'b10) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	xhs ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		xhs_shift	<= {xhs_shift[1:0],i_xhs};
	end
	assign	xhs_rise	= (xhs_shift[2:1]==2'b01) ? 1'b1 : 1'b0;
	assign	xhs_fall	= (xhs_shift[2:1]==2'b10) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	��ͷ��һ���ź�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(xhs_rise) begin
			xtrig_rise_reg	<= 1'b0;
		end
		else if(xtrig_rise) begin
			xtrig_rise_reg	<= 1'b1;
		end
	end

	//	===============================================================================================
	//	ref ***compute***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	allpix_cnt_per_line
	//	1.����ͣ��Ч��ʱ�����в�������Ч
	//	2.����ͣ��Ч��ʱ��
	//	--2.1��xhs�����ص�ʱ�򣬼�������λ
	//	--2.2�����λ=1��ʱ�򣬼���������
	//	--2.3�������������ۼ�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			allpix_cnt_per_line	<=17'h10000;
		end
		else begin
			if(!i_pause_en) begin
				if(xhs_rise) begin
					allpix_cnt_per_line	<= 17'b0;
				end
				else if(allpix_cnt_per_line[16]) begin
					allpix_cnt_per_line	<= allpix_cnt_per_line;
				end
				else begin
					allpix_cnt_per_line	<= allpix_cnt_per_line + 1'b1;
				end
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	line_cnt
	//	1.�и�������������������ʱ��Ҳ�ǰ����м�����
	//	2.����ͣ��ʱ�򣬲����ۼ�
	//	3.������ͣ��ʱ���ڼ�����һ�е����ֵʱ
	//	--��line_cnt���������ֵʱ������
	//	--�����ۼ�
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			line_cnt	<= 17'h10000;
		end
		else begin
			if(!i_pause_en) begin
				if(xhs_rise) begin
					if(xtrig_rise_reg) begin
						line_cnt	<= 17'b0;
					end
					else if(line_cnt[16]) begin
						line_cnt	<= line_cnt;
					end
					else begin
						line_cnt	<= line_cnt + 1'b1;
					end
				end
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	fval_reg
	//	1.���ź�
	//	2.����ͣ��ʱ�򣬱���
	//	3.������ͣ��ʱ��
	//	--��line_cnt������������ʱ�����allpix_cnt_per_line�ﵽǰ�ص�ʱ�򣬳���Ч=1
	//	--��line_cnt������0ʱ�����allpix_cnt_per_line�ﵽ���ص�ʱ�򣬳���Ч=0
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			fval_reg	<= 1'b0;
		end
		else begin
			if(!i_pause_en) begin
				if(line_cnt==VBLANK_LINE) begin
					if(allpix_cnt_per_line==(iv_line_hide-iv_front_porch-1)) begin
						fval_reg	<= 1'b1;
					end
				end
				else if(line_cnt==(VBLANK_LINE+FRAME_INFO_LINE+IGNORE_OB_LINE+VEFFECT_OB_LINE+iv_height)) begin
					if(allpix_cnt_per_line==(iv_back_porch-1)) begin
						fval_reg	<= 1'b0;
					end
				end
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	lval_reg
	//	1.���ź�
	//	2.����ͣ��ʱ�򣬱���
	//	3.������ͣ��ʱ��
	//	--��allpix_cnt_per_line������������ʱ������Ч=1
	//	--��allpix_cnt_per_line������һ�н�βʱ������Ч=0
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			lval_reg	<= 1'b0;
		end
		else begin
			if(!i_pause_en) begin
				if(allpix_cnt_per_line==(iv_line_hide-1)) begin
					lval_reg	<= 1'b1;
				end
				else if(allpix_cnt_per_line==(iv_width+iv_line_hide-1)) begin
					lval_reg	<= 1'b0;
				end
			end
		end
	end

	//  ===============================================================================================
	//	ref ***���***
	//  ===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	fval����
	//	1.lval��Ҫ���ģ����fvalҪ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			fval_reg1	<= 1'b0;
		end
		else begin
			fval_reg1	<= fval_reg;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	lval����
	//	1.����λ����pause��ʱ�򣬲������lval
	//	2.������fval��ʱ���ڳ������׶�Ҫ���lval
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset==1'b1 || i_pause_en==1'b1) begin
			lval_reg1	<= 1'b0;
		end
		else begin
			if(i_continue_lval) begin
				lval_reg1	<= lval_reg;
			end
			else begin
				if(fval_reg) begin
					lval_reg1	<= lval_reg;
				end
				else begin
					lval_reg1	<= 1'b0;
				end
			end

		end
	end

	//	-------------------------------------------------------------------------------------
	//	����г��ź�
	//	-------------------------------------------------------------------------------------
	assign	o_fval		= fval_reg1;
	assign	o_lval		= lval_reg1;


endmodule
