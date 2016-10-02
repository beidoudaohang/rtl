//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : tb_frame_buffer
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2013/6/14 14:04:48	:|  ��ʼ�汾
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

module harness ();

	parameter	BUF_DEPTH_WD				= 3						;	//֡�����λ��,�������֧��4֡��ȣ���һλ��λλ
	parameter	NUM_DQ_PINS					= 16					;	//DDR3���ݿ��
	parameter	MEM_BANKADDR_WIDTH			= 3						;	//DDR3bank���
	parameter	MEM_ADDR_WIDTH				= 13					;	//DDR3��ַ���
	parameter	DDR3_MEMCLK_FREQ			= 320					;	//DDR3ʱ��Ƶ��
	parameter	MEM_ADDR_ORDER				= "ROW_BANK_COLUMN"		;	//DDR3��ַ�Ų�˳��
	parameter 	DDR3_RST_ACT_LOW          	= 0						;   // # = 1 for active low reset,# = 0 for active high reset.
	parameter 	DDR3_INPUT_CLK_TYPE       	= "SINGLE_ENDED"		;   // input clock type DIFFERENTIAL or SINGLE_ENDED
	parameter	SKIP_IN_TERM_CAL			= 1						;	//��У׼������裬��ʡ����
	parameter	DDR3_MEM_DENSITY			= "1Gb"					;	//DDR3����
	parameter	DDR3_TCK_SPEED				= "15E"					;	//DDR3���ٶȵȼ�
//	parameter	DDR3_SIMULATION				= "FALSE"				;	//�򿪷�����Լ��ٷ����ٶȣ�����ʵ�ʲ��ֲ���ʱ�����ܴ򿪷��档
	parameter	DDR3_SIMULATION				= "TRUE"				;	//�򿪷�����Լ��ٷ����ٶȣ�����ʵ�ʲ��ֲ���ʱ�����ܴ򿪷��档
	parameter	DDR3_CALIB_SOFT_IP			= "TRUE"				;	//����ʱ�����Բ�ʹ��У׼�߼�
	parameter	DDR3_P0_MASK_SIZE			= 8						;	//p0��mask size
	parameter	DDR3_P1_MASK_SIZE			= 8						;	//p1��mask size
	parameter	DATA_WD						= 64					;	//��������λ��
	parameter	GPIF_DAT_WIDTH				= 32					;	//�������λ��
	parameter	FSIZE_WD					= 25					;	//֡��С��ȶ���
	parameter	BSIZE_WD					= 9						;	//һ��BURST ������ռ��λ��
	parameter	REG_WD   					= 32                    ;
	//  -------------------------------------------------------------------------------------
	//	---- ref 2.2.1 PLL �궨��
	//  -------------------------------------------------------------------------------------
	parameter	DDR3_PLL_CLKIN_PERIOD		= 25000				;//PLL����Ƶ�ʣ���λ��ps
	parameter	DDR3_PLL_CLKOUT0_DIVIDE		= 1					;//ddr3 2��Ƶ 640MHz
	parameter	DDR3_PLL_CLKOUT1_DIVIDE		= 1					;//ddr3 2��Ƶ 640MHz ��λ�෴
	parameter	DDR3_PLL_CLKOUT2_DIVIDE		= 8					;//mcb drp ʱ�� 80MHz
	parameter	DDR3_PLL_CLKOUT3_DIVIDE		= 7					;//֡���湤��ʱ�� 91.428MHz
	parameter	DDR3_PLL_CLKFBOUT_MULT		= 16            	;
	parameter	DDR3_PLL_DIVCLK_DIVIDE		= 1             	;


	//	ref signals

	reg								clk_vin				;	//��������ʱ�ӣ�72Mhz
	wire[DATA_WD-1				:0]	iv_image_din		;	//clk_pixʱ����ͼ������
	reg								i_stream_en_clk_in	;
	wire							w_trailer_flag		;	//
//  ===============================================================================================
//  ��Ƶ���ʱ����
//  ===============================================================================================
	reg								clk_vout			;	//gpif ʱ�ӣ�100MHz
	wire							i_buf_rd			;   //clk_gpifʱ���򣬺�ģ���ʹ��
	wire							o_back_buf_empty	;
	wire[GPIF_DAT_WIDTH-1		:0]	ov_frame_dout		;   //clk_gpifʱ���򣬺�FIFO������������32bit
	wire							o_frame_valid		;	//clk_gpifʱ����֡�����������Ч
//  ===============================================================================================
//  ֡���湤��ʱ��
//  ===============================================================================================
	reg								clk_frame_buf		;	//֡��ʱ��
	reg								reset_frame_buf		;	//֡��ʱ�ӵĸ�λ�ź�
//  ===============================================================================================
//  ��������
//  ===============================================================================================
	reg								i_stream_en			;	//clk_frame_bufʱ������ʹ���źţ�SE=1�ȴ�����֡��SE=0����ֹͣ������ǰ������д��
	reg	[BUF_DEPTH_WD-1			:0]	wv_frame_depth		;   //clk_frame_bufʱ����֡�������
	reg	[FSIZE_WD-1				:0]	iv_payload_size_frame_buf;   //clk_frame_bufʱ����payload��С������֡���С��֧��16M����ͼ���С
	reg	[FSIZE_WD-1				:0]	iv_payload_size_pix	;
	reg								w_chunkmodeactive	;	//clk_frame_bufʱ����chunk�ܿ��أ�chunk����Ӱ��leader��trailer�Ĵ�С��ͨ���ж�chunk���ؿ���֪��leader��trailer����
//  ===============================================================================================
//  MCB Status
//  ===============================================================================================
	wire							o_calib_done		;	//clk_frame_bufʱ����DDR3У׼����źţ�����Ч
	wire							o_wr_error			;	//MCBд�˿ڳ��ִ��󣬸���Ч
	wire							o_rd_error			;	//MCB���˿ڳ��ִ��󣬸���Ч

//  ===============================================================================================
//  External Memory
//  ===============================================================================================
	wire[NUM_DQ_PINS-1			:0]	mcb1_dram_dq		;	//�����ź�
	wire[MEM_ADDR_WIDTH-1		:0]	mcb1_dram_a         ;	//��ַ�ź�
	wire[MEM_BANKADDR_WIDTH-1	:0]	mcb1_dram_ba        ;	//Bank��ַ�ź�
	wire							mcb1_dram_ras_n     ;	//�е�ַѡͨ
	wire							mcb1_dram_cas_n     ;	//�е�ַѡͨ
	wire							mcb1_dram_we_n      ;	//д�ź�
	wire							mcb1_dram_odt       ;	//�迹ƥ���ź�
	wire							mcb1_dram_reset_n   ;	//��λ�ź�
	wire							mcb1_dram_cke       ;	//ʱ��ʹ���ź�
	wire							mcb1_dram_dm        ;	//���ֽ����������ź�
	wire							mcb1_dram_udqs      ;	//���ֽڵ�ַѡͨ�ź���
	wire							mcb1_dram_udqs_n    ;	//���ֽڵ�ַѡͨ�źŸ�
	wire							mcb1_rzq            ;	//����У׼
	wire							mcb1_dram_udm       ;	//���ֽ����������ź�
	wire							mcb1_dram_dqs       ;	//���ֽ�	����ѡͨ�ź���
	wire							mcb1_dram_dqs_n     ;	//���ֽ�����ѡͨ�źŸ�
	wire							mcb1_dram_ck        ;	//ʱ����
	wire							mcb1_dram_ck_n      ;	//ʱ�Ӹ�


	reg								reset = 1'b0		;
	reg								sys_clk = 1'b0		;
	wire							async_rst			;
	wire							sysclk_2x			;
	wire							sysclk_2x_180		;
	wire							pll_ce_0			;
	wire							pll_ce_90			;
	wire							pll_lock			;
	wire							mcb_drp_clk			;
	wire							bufpll_mcb_lock		;
	reg	[7	:0]						count				;

	wire							w_dval	  			;
	wire							w_fval	            ;
	wire							w_href	 	        ;
	wire							w_vsync 	        ;

	reg					[15		:0]	wv_size_x			; 		//ͷ���еĴ��ڿ��
	reg					[15		:0]	wv_size_y			; 		//ͷ���еĴ��ڸ߶�
	reg					[15		:0]	wv_offset_x			; 		//ͷ���е�ˮƽƫ��
	reg					[15		:0]	wv_offset_y			; 		//ͷ���еĴ�ֱ����
	reg					[15		:0]	wv_h_period 		;
	reg					[15		:0]	wv_v_petiod 		;
	wire							w_vend				;
	wire							w_hend              ;
	wire							w_full				;
	reg								reset_timing		;
	reg					[15:0]		wv_u3v_size			;
	reg 							rd_enbable			;


	//	ref ARCHITECTURE
	bfm1	bfm1_inst();

	// Infrastructure-3 instantiation
	infrastructure #(
	.C_INCLK_PERIOD    	(DDR3_PLL_CLKIN_PERIOD			),
	.C_RST_ACT_LOW     	(0								),
	.C_INPUT_CLK_TYPE  	("SINGLE_ENDED"					),
	.C_CLKOUT0_DIVIDE  	(DDR3_PLL_CLKOUT0_DIVIDE		),
	.C_CLKOUT1_DIVIDE  	(DDR3_PLL_CLKOUT1_DIVIDE		),
	.C_CLKOUT2_DIVIDE  	(DDR3_PLL_CLKOUT2_DIVIDE		),
	.C_CLKOUT3_DIVIDE  	(DDR3_PLL_CLKOUT3_DIVIDE		),
	.C_CLKFBOUT_MULT   	(DDR3_PLL_CLKFBOUT_MULT			),
	.C_DIVCLK_DIVIDE   	(DDR3_PLL_DIVCLK_DIVIDE			)
   	)
	infrastructure_inst
	(
	.sys_clk_p			(                 				),
	.sys_clk_n			(                 				),
	.sys_clk			(sys_clk          				),
	.sys_rst_i			(reset          				),
	.clk0				(                 				),
	.rst0				(        						),
	.async_rst			(async_rst        				),
	.sysclk_2x			(sysclk_2x        				),
	.sysclk_2x_180		(sysclk_2x_180    				),
	.mcb_drp_clk		(mcb_drp_clk      				),
	.pll_ce_0			(pll_ce_0 						),
	.pll_ce_90			(pll_ce_90  					),
	.pll_lock           (bufpll_mcb_lock   				)
	);

	frame_buffer # (
	.BUF_DEPTH_WD		(BUF_DEPTH_WD					),
	.NUM_DQ_PINS		(NUM_DQ_PINS			        ),
	.MEM_BANKADDR_WIDTH	(MEM_BANKADDR_WIDTH	            ),
	.MEM_ADDR_WIDTH		(MEM_ADDR_WIDTH		            ),
	.DDR3_MEMCLK_FREQ	(DDR3_MEMCLK_FREQ	            ),
	.MEM_ADDR_ORDER		(MEM_ADDR_ORDER		            ),
	.DDR3_RST_ACT_LOW   (DDR3_RST_ACT_LOW               ),
	.DDR3_INPUT_CLK_TYPE(DDR3_INPUT_CLK_TYPE            ),
	.SKIP_IN_TERM_CAL	(SKIP_IN_TERM_CAL	            ),
	.DDR3_MEM_DENSITY	(DDR3_MEM_DENSITY	            ),
	.DDR3_TCK_SPEED		(DDR3_TCK_SPEED		            ),
	.DDR3_SIMULATION	(DDR3_SIMULATION		        ),
    .DDR3_CALIB_SOFT_IP	(DDR3_CALIB_SOFT_IP	            ),
    .DATA_WD			(DATA_WD				        ),
    .REG_WD   			(REG_WD   			            )
	)
	frame_buffer_inst (
	.clk_vin				(clk_vin					),		//��������ʱ�ӣ�72Mhz
	.i_fval					(w_vsync					),		//clk_pixʱ���򣬳���Ч�ź�
	.i_dval					(w_href						),		//clk_pixʱ����������Ч�ź�
	.i_trailer_flag			(w_trailer_flag				),		//β����־
	.iv_image_din			(iv_image_din				),		//clk_pixʱ����ͼ������
	.i_stream_en_clk_in		(i_stream_en_clk_in			),
	.clk_vout				(clk_vout					),		//gpif ʱ�ӣ�100MHz
	.i_buf_rd				(i_buf_rd					),   	//clk_gpifʱ���򣬺�ģ���ʹ��
	.o_back_buf_empty		(o_back_buf_empty			),
	.ov_frame_dout			(ov_frame_dout				),   	//clk_gpifʱ���򣬺�FIFO������������32bit
	.o_frame_valid			(o_frame_valid				),		//clk_gpifʱ����֡�����������Ч
	.clk_frame_buf			(clk_frame_buf				),		//֡��ʱ��
	.reset_frame_buf		(reset_frame_buf			),		//֡��ʱ�ӵĸ�λ�ź�
	.i_stream_en			(i_stream_en				),		//clk_frame_bufʱ������ʹ���źţ�SE=1�ȴ�����֡��SE=0����ֹͣ������ǰ������д��
	.iv_frame_depth			(wv_frame_depth				),   	//clk_frame_bufʱ����֡�������
	.iv_payload_size_frame_buf	(iv_payload_size_frame_buf	),  //clk_frame_bufʱ����payload��С������֡���С��֧��16M����ͼ���С
	.iv_payload_size_pix		(iv_payload_size_pix		),
	.i_chunkmodeactive		(w_chunkmodeactive			),		//clk_frame_bufʱ����chunk�ܿ��أ�chunk����Ӱ��leader��trailer�Ĵ�С��ͨ���ж�chunk���ؿ���֪��leader��trailer����
	.i_async_rst			(async_rst					),		//MCB ��λ�źţ�����Ч
	.i_sysclk_2x			(sysclk_2x					),		//MCB ����ʱ��
	.i_sysclk_2x_180		(sysclk_2x_180				),		//MCB ����ʱ��
	.i_pll_ce_0				(pll_ce_0					),		//MCB ��λʹ���ź�
	.i_pll_ce_90			(pll_ce_90					),		//MCB ��λʹ���ź�
	.i_mcb_drp_clk			(mcb_drp_clk				),		//MCB DRP ʱ�ӣ�
	.i_bufpll_mcb_lock		(bufpll_mcb_lock			),		//BUFPLL_MCB �����ź�
	.o_calib_done			(o_calib_done				),		//clk_frame_bufʱ����DDR3У׼����źţ�����Ч
	.o_wr_error				(o_wr_error					),		//MCBд�˿ڳ��ִ��󣬸���Ч
	.o_rd_error				(o_rd_error					),		//MCB���˿ڳ��ִ��󣬸���Ч
	.mcb1_dram_dq			(mcb1_dram_dq				),		//�����ź�
	.mcb1_dram_a         	(mcb1_dram_a        		),		//��ַ�ź�
	.mcb1_dram_ba        	(mcb1_dram_ba       		),		//Bank��ַ�ź�
	.mcb1_dram_ras_n     	(mcb1_dram_ras_n    		),		//�е�ַѡͨ
	.mcb1_dram_cas_n     	(mcb1_dram_cas_n    		),		//�е�ַѡͨ
	.mcb1_dram_we_n      	(mcb1_dram_we_n     		),		//д�ź�
	.mcb1_dram_odt       	(mcb1_dram_odt      		),		//�迹ƥ���ź�
	.mcb1_dram_reset_n   	(mcb1_dram_reset_n  		),		//��λ�ź�
	.mcb1_dram_cke       	(mcb1_dram_cke      		),		//ʱ��ʹ���ź�
	.mcb1_dram_dm        	(mcb1_dram_dm       		),		//���ֽ����������ź�
	.mcb1_dram_udqs      	(mcb1_dram_udqs     		),		//���ֽڵ�ַѡͨ�ź���
	.mcb1_dram_udqs_n    	(mcb1_dram_udqs_n   		),		//���ֽڵ�ַѡͨ�źŸ�
	.mcb1_rzq            	(mcb1_rzq           		),		//����У׼
	.mcb1_dram_udm       	(mcb1_dram_udm      		),		//���ֽ����������ź�
	.mcb1_dram_dqs       	(mcb1_dram_dqs      		),		//���ֽ�	����ѡͨ�ź���
	.mcb1_dram_dqs_n     	(mcb1_dram_dqs_n    		),		//���ֽ�����ѡͨ�źŸ�
	.mcb1_dram_ck        	(mcb1_dram_ck       		),		//ʱ����
	.mcb1_dram_ck_n      	(mcb1_dram_ck_n     		)		//ʱ�Ӹ�
	);

	//  ===============================================================================================
	//	ref ʱ���ź�
	//  ===============================================================================================
//	parameter	CLK_IN_PERIOD 							= 14;
//	parameter	CLK_OUT_PERIOD							= 10;
//	parameter	CLK_FRAME_BUF_PERIOD					= 10;
//
//
//	always # 12.5 						sys_clk 		= ~sys_clk;
//	always # (CLK_IN_PERIOD/2)			clk_vin 		= ~clk_vin;
//	always # (CLK_OUT_PERIOD/2)			clk_vout 		= ~clk_vout;
//	always # (CLK_FRAME_BUF_PERIOD/2)	clk_frame_buf 	= ~clk_frame_buf;

	initial begin
		sys_clk 			= 1'b1;
		clk_vin 		    = 1'b1;
		clk_vout 		    = 1'b1;
		clk_frame_buf 	    = 1'b1;
		reset 				= 1'b1;
		reset_timing		= 1'b1;
		reset_frame_buf 	= 1'b1;
		i_stream_en			= 1'b0;
		i_stream_en_clk_in	= 1'b0;
		rd_enbable			= 1'b1;
		#1000
		reset = 1'b0;
		reset_frame_buf 	= 1'b0;
		#10000
		reset_timing		= 1'b0;		// leave enough time to ddr calibration

	end

	assign  i_buf_rd = ~o_back_buf_empty&&rd_enbable;

	timing	timing_inst(
    .clk					(clk_vin				),
    .reset_n				(!reset_timing			),
	.iv_h_period 			(wv_h_period/8 			),
	.iv_v_petiod 			(wv_v_petiod 			),
	.iv_dval_start			(wv_offset_x			),
	.iv_with				(wv_size_x/8			),
	.iv_fval_start			(wv_offset_y			),
	.iv_hight				(wv_size_y				),
	.iv_u3v_size			(wv_u3v_size			),		//��Ҫ��ע
	.i_pause				(1'b0					),
	.o_trailer_flag			(o_trailer_flag			),
    .o_hend					(w_hend					),
	.o_fval					(w_fval					),
	.o_dval					(w_dval					),
	.o_vend     			(w_vend		 			)
    );

	hv_data 	#(
	.DS_DAT_WD 				(64						)
	)
	hv_data_inst
	(
	.clk					(clk_vin				),
	.reset_n				(!reset_timing			),
	.i_dval					(w_dval	    			),
	.i_fval					(w_fval	    			),
	.i_trailer_flag			(o_trailer_flag			),
	.o_dval					(w_href	 				),
	.o_fval					(w_vsync 				),
	.o_trailer_flag			(w_trailer_flag			),
	.ov_data    			(iv_image_din  			)
	);

//  -------------------------------------------------------------------------------------
//  DDR3 MODEL
//  -------------------------------------------------------------------------------------
	PULLDOWN zio_pulldown3 (.O(mcb3_zio));   PULLDOWN rzq_pulldown3 (.O(mcb3_rzq));

     ddr3_model_c1 u_mem_c1(
      .ck         (mcb1_dram_ck),
      .ck_n       (mcb1_dram_ck_n),
      .cke        (mcb1_dram_cke),
      .cs_n       (1'b0),
      .ras_n      (mcb1_dram_ras_n),
      .cas_n      (mcb1_dram_cas_n),
      .we_n       (mcb1_dram_we_n),
      .dm_tdqs    ({mcb1_dram_udm,mcb1_dram_dm}),
      .ba         (mcb1_dram_ba),
      .addr       (mcb1_dram_a),
      .dq         (mcb1_dram_dq),
      .dqs        ({mcb1_dram_udqs,mcb1_dram_dqs}),
      .dqs_n      ({mcb1_dram_udqs_n,mcb1_dram_dqs_n}),
      .tdqs_n     (),
      .odt        (mcb1_dram_odt),
      .rst_n      (mcb1_dram_reset_n)
      );


endmodule
