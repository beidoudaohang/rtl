//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : pulse_filter_1d
//  -- �����       : ��ϣ��
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- ��ϣ��       :| 2016/8/17 18:52:08	:|  ��ʼ�汾
//-------------------------------------------------------------------------------------------------
//
//  -- ģ������     : �������ģ��
//              1)  : һά�����㷨
//
//              2)  : �����Ǳ߽�ֵ��Ӱ��
//
//              3)  : ֻȥ������
//
//-------------------------------------------------------------------------------------------------
//`include			"pulse_filter_1d_def.v"
//���浥λ/����
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module pulse_filter_1d # (
	parameter	SENSOR_DAT_WIDTH	= 8	,//sensor ���ݿ��
	parameter 	CHANNEL_NUM 		= 8	,//sensor ͨ������
	parameter 	SHORT_REG_WD		= 16 //�̼Ĵ���λ��
	)
	(
	//Sensor�����ź�
	input												clk					,//����ʱ��
	input												i_fval				,//clkʱ�������볡�ź�
	input												i_lval				,//clkʱ�����������ź�
	input		[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		iv_pix_data			,//clkʱ�������������ź�
	//�Ĵ�������
	input												i_pulse_filter_en	,//clkʱ�����˲�ʹ���ź�
	input		[SHORT_REG_WD				 -1:0]		iv_roi_pic_width	,//clkʱ����roi�п�
	//���
	output												o_fval				,//clkʱ����������ź�
	output												o_lval				,//clkʱ����������ź�
	output		[SENSOR_DAT_WIDTH*CHANNEL_NUM-1:0]		ov_pix_data			,//clkʱ�����������
	output		[SHORT_REG_WD				 -1:0]		ov_pulse_num		 //clkʱ����ͳ��һ֡���������ÿ֡����
	);

	//	ref signals
	//	LOG2���� 
	function integer log2 (input integer xx);
		integer x;
		begin
			x    = xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x    = x >> 1;
			end
		end
	endfunction
	//	�̶�����
	localparam	SHIFT_NUM		=	log2(CHANNEL_NUM);					 						//��ȡͨ����λ��
	localparam  SHIFT_LENTH 	= 	(CHANNEL_NUM==1)?(9>>SHIFT_NUM    )	: ((9>>SHIFT_NUM)+ 1);	//��λ�Ĵ�����ȣ���Ϊ9��clk���ܽ���һ�����㣬������9����ͨ������������ȡ������
	localparam  LATCH_LENTH 	= 	(CHANNEL_NUM==8)?((4>>SHIFT_NUM)+1)	: (4>>SHIFT_NUM		);	//����Ĵ�����ȣ���Ϊǰ�����Ҫ����4�����ݣ�������4����ͨ������������ȡ������
	localparam  THRESHOLD		= 	(SENSOR_DAT_WIDTH 	== 8)  	  ? 				25  	 : 	//���������ֵ��8λ��Ӧ25��10λ��Ӧ100��12λ��Ӧ400
									(SENSOR_DAT_WIDTH 	== 10) 	  ? 				100 	 :
									(SENSOR_DAT_WIDTH 	== 12) 	  ? 				400 	 :
														   	   	    				400 	 ;
	localparam	DELAY_LENTH		=	(CHANNEL_NUM 		== 1)  	  ? (SHIFT_LENTH	 )		 :	//�г��ź��ӳٿ�ȣ���ͨ�������й�
									(CHANNEL_NUM 		== 2)  	  ? (SHIFT_LENTH +  2)		 :
									(CHANNEL_NUM 		== 4)  	  ? (SHIFT_LENTH +  3)		 :
									(CHANNEL_NUM 		== 8)  	  ? (SHIFT_LENTH +  4)		 :
																  	(SHIFT_LENTH +  4)		 ; 
									 			   	   	
	reg[DELAY_LENTH						-1:0] fval_shift		  =	{SHIFT_LENTH					{1'b0}} ;//���ź���λ�Ĵ��������ڽ����ź��ӳ����
	reg[DELAY_LENTH						-1:0] lval_shift		  =	{SHIFT_LENTH					{1'b0}} ;//���ź���λ�Ĵ��������ڽ����ź��ӳ����
	reg 									  dataout_flag		  =									 1'b0	;//������ݱ�־�Ĵ��������ڿ���cnt_out����
	reg 									  dataout_flag_dly	  =									 1'b0	;//������ݱ�־�ӳټĴ�����������8ͨ��ʱ����cnt_out����
	reg										  pulse_filter_en_int =									 1'b0	;//�ڲ��ж��˲�ʹ�ܼĴ�������������ʱ����
	reg[SHORT_REG_WD					-1:0] cnt_pix			  =	{SHORT_REG_WD					{1'b0}}	;//���������ؼ���������¼һ����������ظ�������������߽����ݡ�
	reg[SHORT_REG_WD					-1:0] cnt_out			  =	{SHORT_REG_WD					{1'b0}}	;//��������ؼ���������¼һ����������ظ��������ڿ������ص������
	reg[SHORT_REG_WD					-1:0] roi_data_lenth	  =	{SHORT_REG_WD					{1'b0}} ;//ͨ����roi�п���λ�õ���ͨ������Ӧ�������п�
	reg[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] pix_data_dly		  =	{SENSOR_DAT_WIDTH*CHANNEL_NUM	{1'b0}} ;//�˲�ʹ����Чʱ�����������ֵ
	reg[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] pix_data_dly1		  =	{SENSOR_DAT_WIDTH*CHANNEL_NUM	{1'b0}} ;//data_shift�������һ�������ӳ�1�ģ���Ӧ2ͨ��ʱ���˲�ʹ����Чʱ���������
	reg[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] pix_data_dly2		  =	{SENSOR_DAT_WIDTH*CHANNEL_NUM	{1'b0}} ;//data_shift�������һ�������ӳ�2�ģ���Ӧ4ͨ��ʱ���˲�ʹ����Чʱ���������
	reg[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] pix_data_dly3		  =	{SENSOR_DAT_WIDTH*CHANNEL_NUM	{1'b0}} ;//data_shift�������һ�������ӳ�3�ģ���Ӧ8ͨ��ʱ���˲�ʹ����Чʱ���������
	reg[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] pix_data_reg		  =	{SENSOR_DAT_WIDTH*CHANNEL_NUM	{1'b0}} ;//����λ�ô�����㲢ƴ�Ӻõ����ݻ��߽߱�����ֵ
	reg[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] data_shift			[SHIFT_LENTH					 -1:0]	;//������λ�Ĵ��������ڴ��һ��clk����Ҫ���м���������������
	reg[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] data_front_latch		[LATCH_LENTH			 		 -1:0]	;//����ÿ��ǰ4�����������ý��м��㣬������Ҫ�������棬֮��ԭ�������
	wire[SENSOR_DAT_WIDTH				-1:0] data_split	  		[SHIFT_LENTH*CHANNEL_NUM 		 -1:0]	;//��������λ�Ĵ����е����ݲ�ֳɿ��Ϊsensor���ݿ�ȵ����ݣ����������������У�Ϊ�˷���֮��ļ���
	reg[SENSOR_DAT_WIDTH				-1:0] data_split_dly		[CHANNEL_NUM			 		 -1:0]	;//����ŷָ����ݵ������ӳ�һ��
	reg[SENSOR_DAT_WIDTH				-1:0] data_split_dly2		[CHANNEL_NUM			 		 -1:0]	;//����ŷָ����ݵ��������ӳ�һ��
	reg[SENSOR_DAT_WIDTH				  :0] data_m				[CHANNEL_NUM			 		 -1:0]	;//�����м�ֵ����Ӧ�㷨�ĵ��е�M
	reg[SENSOR_DAT_WIDTH				  :0] data_n				[CHANNEL_NUM			 		 -1:0]	;//�����м�ֵ����Ӧ�㷨�ĵ��е�N
	reg[SENSOR_DAT_WIDTH				  :0] data_th 				[CHANNEL_NUM			 		 -1:0]	;//�����м�ֵ����Ӧ�㷨�ĵ��е�Th
	reg[SENSOR_DAT_WIDTH				-1:0] data_temp				[CHANNEL_NUM			 		 -1:0]	;//�������ؼ���֮���ֵ
	reg[SENSOR_DAT_WIDTH				-1:0] data_temp_dly			[CHANNEL_NUM			 		 -1:0]	;//���������ؼ���֮���ֵ�ӳ�һ�ģ�����8ͨ�����ݵ�ƴ��
	wire[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] data_cal												 		;//���л����������֮�󣬲���ƴ����ɵ�ֵ
	reg[SENSOR_DAT_WIDTH*CHANNEL_NUM	-1:0] data_tail_latch 		[LATCH_LENTH	 		 		 -1:0]	;//����ÿ�к�4�����������ý��м��㣬������Ҫ�������棬֮��ԭ�������
	reg[SHORT_REG_WD					-1:0] pulse_num_reg			[CHANNEL_NUM					 -1:0]	;//ͳ�ƶ�ͨ����������У�������Ļ�����������볡�ź���������0					  
	reg[SHORT_REG_WD					-1:0] pulse_num_latch	  =	{SHORT_REG_WD					{1'b0}}	;//����һ֡ͼ���еĻ�������������볡�ź��½�������					  
	wire 									  fval_rise														;//���ź������أ�����ͳ�ƻ������ 
	wire 									  fval_fall														;//���ź��½��أ���������һ֡�Ļ������
	
	//	ref ARCHITECTURE
	//  ===============================================================================================
	//	ref ***���ġ�ȡ���ء���λ***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	���ź���λ�Ĵ��������ڽ����ź��ӳ����
	//	�ӳٳ��ȸ���ͨ�������� 
	//	��ȡ���볡�źű���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_shift <= {fval_shift[DELAY_LENTH-2:0],i_fval}; 
	end
	assign o_fval 	 = fval_shift[DELAY_LENTH-1]; 
	assign fval_rise = i_fval & ~fval_shift[0];
	assign fval_fall = ~i_fval & fval_shift[0];
	//  -------------------------------------------------------------------------------------
	//	���ź���λ�Ĵ��������ڽ����ź��ӳ����
	//	�ӳٳ��ȸ���ͨ��������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		lval_shift <= {lval_shift[DELAY_LENTH-2:0],i_lval}; 
	end
	assign o_lval = lval_shift[DELAY_LENTH-1];
	//  -------------------------------------------------------------------------------------
	//	�������ݴ��ģ�Ϊ��֧�ֶ�ͨ��ʱ��ʹ���ź���Чʱ���ӳ������ʹ���ź���Чʱ��ͬ��ʱ��
	//	Ϊ��ʹ֡���޶���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		pix_data_dly1 <= data_shift[SHIFT_LENTH-1];
		pix_data_dly2 <= pix_data_dly1;
		pix_data_dly3 <= pix_data_dly2;
	end 
	//  -------------------------------------------------------------------------------------
	//	ͨ����roi�п���λ�õ���ͨ������Ӧ�������п�
	//	��Ϊ֮ǰ��ģ���Ѿ���roi����Чʱ�����˱��������ﲻ���ظ�����
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		roi_data_lenth <= iv_roi_pic_width>>SHIFT_NUM;
	end
	//  ===============================================================================================
	//	ref ***��Чʱ��***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	pulse_filter_en_int ʹ���źţ���֤����֡
	//	1.pulse_filter_en_int=o_fval 
	//	2.��o_fval=0ʱ��pulse_filter_en_int=i_pulse_filter_en
	//	2.��o_fval=1ʱ��pulse_filter_en_int���ֲ���
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(i_fval|o_fval) begin
			pulse_filter_en_int <= pulse_filter_en_int;
		end
		else begin
			pulse_filter_en_int <= i_pulse_filter_en;
		end
	end
	//  ===============================================================================================
	//	ref ***������***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	cnt_pix ��¼һ����������ظ���
	// 	1.i_lval����Ч�ڼ�����������ó��źŽ��б���
	//	2.������roi�п����0
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(cnt_pix == roi_data_lenth) begin
			cnt_pix <= {SHORT_REG_WD{1'b0}};
		end
		else if(i_lval&i_fval) begin
			cnt_pix <= cnt_pix + 1'b1;
		end
		else begin
			cnt_pix <= {SHORT_REG_WD{1'b0}};
		end
	end
	//  -------------------------------------------------------------------------------------
	//	dataout_flag ���������־λ
	// 	1.���ݵ���λ��Ҫ SHIFT_LENTH ��clk
	//	2.���ݵļ�����Ҫ3��clk
	//	3.����֮��ĵ�һ���������֮ǰ������Ҫ���֮ǰ4���߽�����
	//	4.����1ͨ�����ݣ��� cnt_pix ������ SHIFT_LENTH-3 ʱ��dataout_flag ��1��cnt_out��ʼ����
	//	  ����2ͨ�����ݣ��� cnt_pix ������ SHIFT_LENTH-1 ʱ��dataout_flag ��1��cnt_out��ʼ����
	//	  ����4ͨ�����ݣ��� cnt_pix ������ SHIFT_LENTH   ʱ��dataout_flag ��1��cnt_out��ʼ����
	//	  ����8ͨ�����ݣ��� cnt_pix ������ SHIFT_LENTH   ʱ��dataout_flag_dly ��1��cnt_out��ʼ����
	//	5.��cnt_out ������ roi_data_lenth ʱ��0����ʾһ������������
	//  -------------------------------------------------------------------------------------
	genvar i; 
	generate
		if(CHANNEL_NUM == 1) begin
			always @ (posedge clk) begin
				if(cnt_out == roi_data_lenth) begin
					dataout_flag <= 1'b0;
				end
				else if(cnt_pix == (SHIFT_LENTH - 3)) begin
					dataout_flag <= 1'b1;
				end
			end 
		end
		if(CHANNEL_NUM == 2) begin
			always @ (posedge clk) begin
				if(cnt_out == roi_data_lenth) begin
					dataout_flag <= 1'b0;
				end
				else if(cnt_pix == (SHIFT_LENTH - 1)) begin
					dataout_flag <= 1'b1;
				end
			end
		end
		if(CHANNEL_NUM == 4) begin
			always @ (posedge clk) begin
				if(cnt_out == roi_data_lenth) begin
					dataout_flag <= 1'b0;
				end
				else if(cnt_pix == SHIFT_LENTH) begin
					dataout_flag <= 1'b1;
				end
			end
		end
		if(CHANNEL_NUM == 8) begin
			always @ (posedge clk) begin
				if(cnt_out == roi_data_lenth) begin
					dataout_flag <= 1'b0;
				end
				else if(cnt_pix == SHIFT_LENTH) begin
					dataout_flag <= 1'b1; 
				end
			end
			always @ (posedge clk) begin
				if(cnt_out == roi_data_lenth) begin
					dataout_flag_dly <= 1'b0;
				end
				else if(dataout_flag) begin 
					dataout_flag_dly <= 1'b1;		
				end
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	cnt_out ������ݼ�����
	// 	1.dataout_flagΪ1ʱ��ʼ����
	//	2.��cnt_out ������ roi_data_lenth ʱ��0����ʾһ������������
	//  -------------------------------------------------------------------------------------
	generate
		if((CHANNEL_NUM == 1)|(CHANNEL_NUM == 2)|(CHANNEL_NUM == 4)) begin
			always @ (posedge clk) begin
				if(cnt_out == roi_data_lenth) begin
					cnt_out <= {SHORT_REG_WD{1'b0}};
				end
				else if(dataout_flag) begin
					cnt_out <= cnt_out + 1'b1;
				end
			end
		end
		else if(CHANNEL_NUM == 8) begin
			always @ (posedge clk) begin
				if(cnt_out == roi_data_lenth) begin
					cnt_out <= {SHORT_REG_WD{1'b0}};
				end
				else if(dataout_flag_dly) begin
					cnt_out <= cnt_out + 1'b1;
				end
			end	
		end			
	endgenerate
	
	//  ===============================================================================================
	//	ref ***����߽�ֵ***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	data_front_latch ������ͷ4������ֵ
	// 		����1ͨ�� cnt_pix = 1ʱ������ÿ�п�ʼ4�����ݣ���Ϊ��ͷ4���߽�����ֵ
	//	  	����1ͨ�� cnt_pix = 2ʱ������ÿ�п�ʼ2�����ݣ���Ϊ��ͷ4���߽�����ֵ
	//	  	����1ͨ�� cnt_pix = 4ʱ������ÿ�п�ʼ1�����ݣ���Ϊ��ͷ4���߽�����ֵ
	//	  	����1ͨ�� cnt_pix = 8ʱ������ÿ�п�ʼ1�����ݵĵ�4�����ݣ���Ϊ��ͷ4���߽�����ֵ
	//						___________________________
	//		lval_dly	____|                         |_	
	//						____________________	 
	//  	data_shift[0]	|d0||d1||d2||d3||d4|.....
	//  					��������������������     
	//					____________________			
	//		cnt_pix		 00||01||02||03||04|.........
	//					��������������������			
	//  -------------------------------------------------------------------------------------
	generate
		for(i=0;i<LATCH_LENTH;i=i+1) begin
			always @ (posedge clk) begin
				if(cnt_pix == i+1) begin
					data_front_latch[i] <=  data_shift[0];
				end
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	data_tail_latch ������β4������ֵ
	//		����1ͨ�� cnt_out = roi_data_lenth -3 ʱ������ÿ�����4�����ݣ���Ϊ��β4���߽�����ֵ
	//	  	����2ͨ�� cnt_out = roi_data_lenth -1 ʱ������ÿ�����2�����ݣ���Ϊ��β4���߽�����ֵ
	//	  	����4ͨ�� cnt_out = roi_data_lenth    ʱ������ÿ�����1�����ݣ���Ϊ��β4���߽�����ֵ
	//	  	����8ͨ�� cnt_out = roi_data_lenth    ʱ������ÿ�����1�����ݵĸ�4�����ݣ���Ϊ��β4���߽�����ֵ
	//						_________________________________________________
	//		lval_dly	____|                                               |_	
	//						   	     ________________________________________
	//  	data_shift[0]	   ......|droi_data_lenth-2| |droi_data_lenth-1 |
	//  					   	     ����������������������������������������
	//						   	     ________________________________________
	//		cnt_pix			   ......| roi_data_lenth-1| |  roi_data_lenth  | 
	//						   	     ����������������������������������������
	//  -------------------------------------------------------------------------------------
	generate
		for(i=LATCH_LENTH;i>0;i=i-1) begin
			always @ (posedge clk) begin
				if(cnt_pix == roi_data_lenth - (i-1)) begin
					data_tail_latch[LATCH_LENTH-i] <=  data_shift[0];
				end
			end
		end
	endgenerate
	
	//  ===============================================================================================
	//	ref ***�������***
	//	1.����λ�Ĵ����������㹻����������
	//	2.����λ�Ĵ����ж�ͨ�������ݽ��в�֣�ʹ��ֺ����ݵ�λ����sensorλ����ͬ��֮��˳�����������
	//	3.����ʽ���бȽ� M=p1+abs(p1-p0) �� N=p3+abs(p3-p4)
	//	4.����ʽ���бȽ� Th=max(M,N)
	//	5.�����ж� p2�Ƿ����Th+THRESHOLD������Ϊ���㣬���Th������Ϊ���㣬���p2
	//	6.���岽�����ж�ʱ����Ҫ�õ�p2�����ж�ʱ�Ѿ�����2��clk������Ҫ����Ҫ���л��������ֵ�ӳ�2��
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	data_shift ������λ
	// 	1ͨ��ʱ����Ҫ��9��
	//	2ͨ��ʱ����Ҫ��5��
	//	4ͨ��ʱ����Ҫ��3��
	//	8ͨ��ʱ����Ҫ��2��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		data_shift[0] <= iv_pix_data ;
	end
	generate
		for(i=1;i<SHIFT_LENTH;i=i+1) begin	
			always @ (posedge clk) begin
				data_shift[i] <= data_shift[i-1];
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	data_split ��� data_shift ��λ�Ĵ��������ݣ�ʹ��ֺ�����ݾ�����sensor���ݳ���
	// 	��˳�򽫲�ֺ�����ݴ�������
	//	���鳤��Ϊ SHIFT_LENTH*CHANNEL_NUM
	//  -------------------------------------------------------------------------------------	
	genvar	j;
	generate
		for(i=SHIFT_LENTH;i>0;i=i-1) begin
			for(j=0;j<CHANNEL_NUM;j=j+1) begin
				assign data_split[(SHIFT_LENTH-i)*CHANNEL_NUM+j] = data_shift[i-1][SENSOR_DAT_WIDTH*(j+1)-1:SENSOR_DAT_WIDTH*j];
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	��data_split����Ҫ���л�����������ֵ�ӳ�һ�����ڣ�Ŀ����֮����л������ʱ����ͬ��
	// 	����ע��ֻ��Ҫ��������Ҫ���л��������������ݽ����ӳ�
	//  -------------------------------------------------------------------------------------
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			always @ (posedge clk) begin
				data_split_dly[i] <= data_split[i+4];
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	��data_split����Ҫ���л�����������ֵ���ӳ�һ�����ڣ�Ŀ����֮����л������ʱ����ͬ��
	// 	����ע��ֻ��Ҫ��������Ҫ���л��������������ݽ����ӳ�
	//  -------------------------------------------------------------------------------------
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			always @ (posedge clk) begin
				data_split_dly2[i] <= data_split_dly[i];
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	����ʽ���бȽ�  M=p1+abs(p1-p0)
	//  -------------------------------------------------------------------------------------
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			always @ (posedge clk) begin
				if(data_split[i]>=data_split[i+2]) begin
					data_m[i] <= data_split[i+2] + data_split[i] - data_split[i+2];
				end
				else begin
					data_m[i] <= data_split[i+2] + data_split[i+2] - data_split[i];
				end
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	����ʽ���бȽ�  N=p3+abs(p3-p4)
	//  -------------------------------------------------------------------------------------
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			always @ (posedge clk) begin
				if(data_split[i+6]>=data_split[i+8]) begin
					data_n[i] <= data_split[i+6] + data_split[i+6] - data_split[i+8];
				end
				else begin
					data_n[i] <= data_split[i+6] + data_split[i+8] - data_split[i+6];
				end
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	����ʽ���бȽ� Th=max(M,N)
	//  -------------------------------------------------------------------------------------
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			always @ (posedge clk) begin
				if(data_m[i]>=data_n[i]) begin
					data_th[i] <= data_m[i];
				end
				else begin
					data_th[i] <= data_n[i];
				end
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	�����ж� p2�Ƿ����Th+THRESHOLD������Ϊ���㣬���Th������Ϊ���㣬���p2
	//  -------------------------------------------------------------------------------------
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			always @ (posedge clk) begin
				if(data_split_dly2[i]>(data_th[i]+THRESHOLD)) begin
					data_temp[i] <= data_th[i][SENSOR_DAT_WIDTH-1:0];
				end
				else begin
					data_temp[i] <= data_split_dly2[i];
				end
			end
		end
	endgenerate
	//  ===============================================================================================
	//	ref ***�������ͳ��***
	//	1.���볡�ź�������ʱ����0��ͨ��������������ʼ�����������
	//	2.�����볡�ź��½���ʱ�������������������棬�����
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	�жϳ�һ�����㣬���������1���������ڳ��ź���������0������Чʱ����
	//  -------------------------------------------------------------------------------------
	generate
		for(i=0;i<CHANNEL_NUM;i=i+1) begin
			always @ (posedge clk) begin
				if(fval_rise) begin
					pulse_num_reg[i] <= {SHORT_REG_WD{1'b0}};
				end
				else if(i_fval) begin
					if(data_split_dly2[i]>(data_th[i]+THRESHOLD)) begin
						pulse_num_reg[i] <= pulse_num_reg[i] + 1'b1; 
					end
				end
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	���ź��½���ʱ�����������ͳ�Ƽ������е���������
	//  ------------------------------------------------------------------------------------- 
	generate
		if(CHANNEL_NUM == 1) begin
			always @ (posedge clk) begin
				if(fval_fall) begin
					pulse_num_latch = pulse_num_reg[0];
				end
			end		
		end
		else if(CHANNEL_NUM == 2) begin
			always @ (posedge clk) begin
				if(fval_fall) begin
					pulse_num_latch = pulse_num_reg[0] + pulse_num_reg[1];
				end
			end		
		end
		else if(CHANNEL_NUM == 4) begin
			always @ (posedge clk) begin
				if(fval_fall) begin
					pulse_num_latch = pulse_num_reg[0] + pulse_num_reg[1] +pulse_num_reg[2] + pulse_num_reg[3];
				end
			end	
		end
		else if(CHANNEL_NUM == 8) begin
			always @ (posedge clk) begin
				if(fval_fall) begin
					pulse_num_latch = pulse_num_reg[0] + pulse_num_reg[1] +pulse_num_reg[2] + pulse_num_reg[3]+
									  pulse_num_reg[4] + pulse_num_reg[5] +pulse_num_reg[6] + pulse_num_reg[7];
				end
			end	
		end
	endgenerate 
	assign ov_pulse_num = pulse_filter_en_int ? pulse_num_latch : {SHORT_REG_WD{1'b0}};
	//  ===============================================================================================
	//	ref ***�������***
	//	1.�����ݽ���ƴ��
	//		����1ͨ��������Ҫƴ��
	//		����2ͨ����ֻ�轫һ�μ������2����ֵƴ�ӵ�һ��
	//		����4ͨ����ֻ�轫һ�μ������4����ֵƴ�ӵ�һ��
	//		����8ͨ����ֻ�轫�ϸ�clk������ĺ�4�����������clk�������ǰ4��clkƴ�ӵ�һ��
	//			����8ͨ����Ҫ���ϸ�clk�������ֵ�ӳ�һ��
	//	3.�˲�ʹ����Чʱ��������������ݣ����򲻾������������ֱ�ӽ�������������
	//	4.�������ʱ��ÿ�еĿ�ͷ�ͽ�β�������4���߽��������ݣ��м��Ǽ��������ݣ�ͨ��cnt_out������
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	8ͨ��ʱ��ƴ�����ݵ���Ҫ����Ҫ�� data_temp �ӳ�һ�ģ�ֻ��8ͨ��ʱ��Ч
	//  -------------------------------------------------------------------------------------
	generate
		if(CHANNEL_NUM == 8) begin
			for(i=0;i<CHANNEL_NUM;i=i+1) begin
				always @ (posedge clk) begin
					data_temp_dly[i] <=  data_temp[i];
				end
			end
		end
	endgenerate 
	//  -------------------------------------------------------------------------------------
	//	����ƴ��
	//  -------------------------------------------------------------------------------------
	generate
		if(CHANNEL_NUM == 1) begin
			assign data_cal = data_temp[0];
		end
		else if(CHANNEL_NUM == 2) begin
			assign data_cal = {data_temp[1],data_temp[0]};
		end
		else if(CHANNEL_NUM == 4) begin
			assign data_cal = {data_temp[3],data_temp[2],data_temp[1],data_temp[0]};
		end
		else if(CHANNEL_NUM == 8) begin
			assign data_cal = {data_temp[3],data_temp[2],data_temp[1],data_temp[0],
			data_temp_dly[7],data_temp_dly[6],data_temp_dly[5],data_temp_dly[4]};
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	���������������cnt_out����
	//	�˲�ʹ����Чʱ���ӳ����˲�ʹ����Чʱ��ͬ��ʱ����������ݣ�����ʹ֡���޶���
	//	�˲�ʹ����Чʱ��
	//		cnt_out = 0ʱ����ʾû��������Ч�ڼ䣬�������Ϊ0
	//		����1ͨ�����ֱ��ж�cnt_outǰ�����Ե��4��ֵ��Ȼ���������ֵ������ʱ���������ֵ
	//		����2ͨ�����ֱ��ж�cnt_outǰ�����Ե��2��ֵ��Ȼ���������ֵ������ʱ���������ֵ
	//		����4ͨ�����ֱ��ж�cnt_outǰ�����Ե��1��ֵ��Ȼ���������ֵ������ʱ���������ֵ
	//		����8ͨ�����ֱ��ж�cnt_outǰ�����Ե��1��ֵ���ó�ǰ1��ֵ�еĿ�ͷ4�����������Լ�
	//		���1��ֵ�еĽ�β4���������ݣ��ֱ�������������ݽ���ƴ�Ӻ����	
	//  -------------------------------------------------------------------------------------
	generate
		if(CHANNEL_NUM == 1) begin
			always @ (posedge clk) begin 
				if(cnt_out == 16'd0) begin
					pix_data_reg <= {SENSOR_DAT_WIDTH*CHANNEL_NUM{1'b0}};	
				end
				else if(cnt_out == 16'd1) begin
					pix_data_reg <= data_front_latch[0];
				end
				else if(cnt_out == 16'd2) begin
					pix_data_reg <= data_front_latch[1];
				end
				else if(cnt_out == 16'd3) begin
					pix_data_reg <= data_front_latch[2];
				end
				else if(cnt_out == 16'd4) begin
					pix_data_reg <= data_front_latch[3];
				end
				else if(cnt_out == (roi_data_lenth-3)) begin
					pix_data_reg <= data_tail_latch[0];
				end
				else if(cnt_out == (roi_data_lenth-2)) begin
					pix_data_reg <= data_tail_latch[1];
				end
				else if(cnt_out == (roi_data_lenth-1)) begin
					pix_data_reg <= data_tail_latch[2]; 
				end
				else if(cnt_out == roi_data_lenth) begin
					pix_data_reg <= data_tail_latch[3];
				end
				else begin
					pix_data_reg <= data_cal;
				end
			end 
		end
		else if(CHANNEL_NUM == 2) begin
			always @ (posedge clk) begin
				if(cnt_out == 16'd0) begin
					pix_data_reg <= {SENSOR_DAT_WIDTH*CHANNEL_NUM{1'b0}};	
				end
				else if(cnt_out == 16'd1) begin
					pix_data_reg <= data_front_latch[0];
				end
				else if(cnt_out == 16'd2) begin
					pix_data_reg <= data_front_latch[1];
				end
				else if(cnt_out == (roi_data_lenth-1)) begin
					pix_data_reg <= data_tail_latch[0];
				end
				else if(cnt_out == roi_data_lenth) begin
					pix_data_reg <= data_tail_latch[1];
				end
				else begin
					pix_data_reg <= data_cal;
				end
			end
		end
		else if(CHANNEL_NUM == 4) begin
			always @ (posedge clk) begin
				if(cnt_out == 16'd0) begin
					pix_data_reg <= {SENSOR_DAT_WIDTH*CHANNEL_NUM{1'b0}};	
				end
				else if(cnt_out == 16'd1) begin
					pix_data_reg <= data_front_latch[0];
				end
				else if(cnt_out == roi_data_lenth) begin
					pix_data_reg <= data_tail_latch[0];
				end
				else begin
					pix_data_reg <= data_cal;
				end
			end
		end
		else if(CHANNEL_NUM == 8) begin
			always @ (posedge clk) begin
				if(cnt_out == 16'd0) begin
					pix_data_reg <= {SENSOR_DAT_WIDTH*CHANNEL_NUM{1'b0}};	
				end
				else if(cnt_out == 16'd1) begin
					pix_data_reg <= {data_cal[SENSOR_DAT_WIDTH*8-1:SENSOR_DAT_WIDTH*4],data_front_latch[0][SENSOR_DAT_WIDTH*4-1:0]};
				end
				else if(cnt_out == roi_data_lenth) begin
					pix_data_reg <= {data_tail_latch[0][SENSOR_DAT_WIDTH*8-1:SENSOR_DAT_WIDTH*4],data_cal[SENSOR_DAT_WIDTH*4-1:0]};
				end
				else begin
					pix_data_reg <= data_cal;
				end
			end
		end
	endgenerate
	//  -------------------------------------------------------------------------------------
	//	�˲�ʹ����Чʱ�����������ֵ
	//  -------------------------------------------------------------------------------------
	generate
		always @ (posedge clk) begin
			if(CHANNEL_NUM == 1) begin
				pix_data_dly <= data_shift[SHIFT_LENTH-2];
			end
			else if(CHANNEL_NUM == 2) begin
				pix_data_dly <= pix_data_dly1;
			end
			else if(CHANNEL_NUM == 4) begin
				pix_data_dly <= pix_data_dly2;
			end
			else if(CHANNEL_NUM == 8) begin
				pix_data_dly <= pix_data_dly3;
			end
		end
	endgenerate
	assign	ov_pix_data = pulse_filter_en_int ? pix_data_reg : pix_data_dly;

endmodule
  