//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : tb_frame_buffer
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2013/6/14 14:04:48	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : ... ...
//
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module harness ();

	parameter	BUF_DEPTH_WD				= 3						;	//帧存深度位宽,我们最大支持4帧深度，多一位进位位
	parameter	NUM_DQ_PINS					= 16					;	//DDR3数据宽度
	parameter	MEM_BANKADDR_WIDTH			= 3						;	//DDR3bank宽度
	parameter	MEM_ADDR_WIDTH				= 13					;	//DDR3地址宽度
	parameter	DDR3_MEMCLK_FREQ			= 320					;	//DDR3时钟频率
	parameter	MEM_ADDR_ORDER				= "ROW_BANK_COLUMN"		;	//DDR3地址排布顺序
	parameter 	DDR3_RST_ACT_LOW          	= 0						;   // # = 1 for active low reset,# = 0 for active high reset.
	parameter 	DDR3_INPUT_CLK_TYPE       	= "SINGLE_ENDED"		;   // input clock type DIFFERENTIAL or SINGLE_ENDED
	parameter	SKIP_IN_TERM_CAL			= 1						;	//不校准输入电阻，节省功耗
	parameter	DDR3_MEM_DENSITY			= "1Gb"					;	//DDR3容量
	parameter	DDR3_TCK_SPEED				= "15E"					;	//DDR3的速度等级
//	parameter	DDR3_SIMULATION				= "FALSE"				;	//打开仿真可以加速仿真速度，但是实际布局布线时，不能打开仿真。
	parameter	DDR3_SIMULATION				= "TRUE"				;	//打开仿真可以加速仿真速度，但是实际布局布线时，不能打开仿真。
	parameter	DDR3_CALIB_SOFT_IP			= "TRUE"				;	//仿真时，可以不使能校准逻辑
	parameter	DDR3_P0_MASK_SIZE			= 8						;	//p0口mask size
	parameter	DDR3_P1_MASK_SIZE			= 8						;	//p1口mask size
	parameter	DATA_WD						= 64					;	//输入数据位宽，
	parameter	GPIF_DAT_WIDTH				= 32					;	//输出数据位宽，
	parameter	FSIZE_WD					= 25					;	//帧大小宽度定义
	parameter	BSIZE_WD					= 9						;	//一次BURST 操作所占的位宽
	parameter	REG_WD   					= 32                    ;
	//  -------------------------------------------------------------------------------------
	//	---- ref 2.2.1 PLL 宏定义
	//  -------------------------------------------------------------------------------------
	parameter	DDR3_PLL_CLKIN_PERIOD		= 25000				;//PLL输入频率，单位是ps
	parameter	DDR3_PLL_CLKOUT0_DIVIDE		= 1					;//ddr3 2倍频 640MHz
	parameter	DDR3_PLL_CLKOUT1_DIVIDE		= 1					;//ddr3 2倍频 640MHz 相位相反
	parameter	DDR3_PLL_CLKOUT2_DIVIDE		= 8					;//mcb drp 时钟 80MHz
	parameter	DDR3_PLL_CLKOUT3_DIVIDE		= 7					;//帧缓存工作时钟 91.428MHz
	parameter	DDR3_PLL_CLKFBOUT_MULT		= 16            	;
	parameter	DDR3_PLL_DIVCLK_DIVIDE		= 1             	;


	//	ref signals

	reg								clk_vin				;	//本地像素时钟，72Mhz
	wire[DATA_WD-1				:0]	iv_image_din		;	//clk_pix时钟域，图像数据
	reg								i_stream_en_clk_in	;
	wire							w_trailer_flag		;	//
//  ===============================================================================================
//  视频输出时钟域
//  ===============================================================================================
	reg								clk_vout			;	//gpif 时钟，100MHz
	wire							i_buf_rd			;   //clk_gpif时钟域，后级模块读使能
	wire							o_back_buf_empty	;
	wire[GPIF_DAT_WIDTH-1		:0]	ov_frame_dout		;   //clk_gpif时钟域，后级FIFO数据输出，宽度32bit
	wire							o_frame_valid		;	//clk_gpif时钟域，帧存输出数据有效
//  ===============================================================================================
//  帧缓存工作时钟
//  ===============================================================================================
	reg								clk_frame_buf		;	//帧存时钟
	reg								reset_frame_buf		;	//帧存时钟的复位信号
//  ===============================================================================================
//  控制数据
//  ===============================================================================================
	reg								i_stream_en			;	//clk_frame_buf时钟域，流使能信号，SE=1等待完整帧，SE=0立即停止，屏蔽前端数据写入
	reg	[BUF_DEPTH_WD-1			:0]	wv_frame_depth		;   //clk_frame_buf时钟域，帧缓存深度
	reg	[FSIZE_WD-1				:0]	iv_payload_size_frame_buf;   //clk_frame_buf时钟域，payload大小，不是帧存大小，支持16M以下图像大小
	reg	[FSIZE_WD-1				:0]	iv_payload_size_pix	;
	reg								w_chunkmodeactive	;	//clk_frame_buf时钟域，chunk总开关，chunk开关影响leader和trailer的大小，通过判断chunk开关可以知道leader和trailer长度
//  ===============================================================================================
//  MCB Status
//  ===============================================================================================
	wire							o_calib_done		;	//clk_frame_buf时钟域，DDR3校准完成信号，高有效
	wire							o_wr_error			;	//MCB写端口出现错误，高有效
	wire							o_rd_error			;	//MCB读端口出现错误，高有效

//  ===============================================================================================
//  External Memory
//  ===============================================================================================
	wire[NUM_DQ_PINS-1			:0]	mcb1_dram_dq		;	//数据信号
	wire[MEM_ADDR_WIDTH-1		:0]	mcb1_dram_a         ;	//地址信号
	wire[MEM_BANKADDR_WIDTH-1	:0]	mcb1_dram_ba        ;	//Bank地址信号
	wire							mcb1_dram_ras_n     ;	//行地址选通
	wire							mcb1_dram_cas_n     ;	//列地址选通
	wire							mcb1_dram_we_n      ;	//写信号
	wire							mcb1_dram_odt       ;	//阻抗匹配信号
	wire							mcb1_dram_reset_n   ;	//复位信号
	wire							mcb1_dram_cke       ;	//时钟使能信号
	wire							mcb1_dram_dm        ;	//低字节数据屏蔽信号
	wire							mcb1_dram_udqs      ;	//高字节地址选通信号正
	wire							mcb1_dram_udqs_n    ;	//高字节地址选通信号负
	wire							mcb1_rzq            ;	//驱动校准
	wire							mcb1_dram_udm       ;	//高字节数据屏蔽信号
	wire							mcb1_dram_dqs       ;	//低字节	数据选通信号正
	wire							mcb1_dram_dqs_n     ;	//低字节数据选通信号负
	wire							mcb1_dram_ck        ;	//时钟正
	wire							mcb1_dram_ck_n      ;	//时钟负


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

	reg					[15		:0]	wv_size_x			; 		//头包中的窗口宽度
	reg					[15		:0]	wv_size_y			; 		//头包中的窗口高度
	reg					[15		:0]	wv_offset_x			; 		//头包中的水平偏移
	reg					[15		:0]	wv_offset_y			; 		//头包中的垂直便宜
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
	.clk_vin				(clk_vin					),		//本地像素时钟，72Mhz
	.i_fval					(w_vsync					),		//clk_pix时钟域，场有效信号
	.i_dval					(w_href						),		//clk_pix时钟域，数据有效信号
	.i_trailer_flag			(w_trailer_flag				),		//尾包标志
	.iv_image_din			(iv_image_din				),		//clk_pix时钟域，图像数据
	.i_stream_en_clk_in		(i_stream_en_clk_in			),
	.clk_vout				(clk_vout					),		//gpif 时钟，100MHz
	.i_buf_rd				(i_buf_rd					),   	//clk_gpif时钟域，后级模块读使能
	.o_back_buf_empty		(o_back_buf_empty			),
	.ov_frame_dout			(ov_frame_dout				),   	//clk_gpif时钟域，后级FIFO数据输出，宽度32bit
	.o_frame_valid			(o_frame_valid				),		//clk_gpif时钟域，帧存输出数据有效
	.clk_frame_buf			(clk_frame_buf				),		//帧存时钟
	.reset_frame_buf		(reset_frame_buf			),		//帧存时钟的复位信号
	.i_stream_en			(i_stream_en				),		//clk_frame_buf时钟域，流使能信号，SE=1等待完整帧，SE=0立即停止，屏蔽前端数据写入
	.iv_frame_depth			(wv_frame_depth				),   	//clk_frame_buf时钟域，帧缓存深度
	.iv_payload_size_frame_buf	(iv_payload_size_frame_buf	),  //clk_frame_buf时钟域，payload大小，不是帧存大小，支持16M以下图像大小
	.iv_payload_size_pix		(iv_payload_size_pix		),
	.i_chunkmodeactive		(w_chunkmodeactive			),		//clk_frame_buf时钟域，chunk总开关，chunk开关影响leader和trailer的大小，通过判断chunk开关可以知道leader和trailer长度
	.i_async_rst			(async_rst					),		//MCB 复位信号，高有效
	.i_sysclk_2x			(sysclk_2x					),		//MCB 工作时钟
	.i_sysclk_2x_180		(sysclk_2x_180				),		//MCB 工作时钟
	.i_pll_ce_0				(pll_ce_0					),		//MCB 移位使能信号
	.i_pll_ce_90			(pll_ce_90					),		//MCB 移位使能信号
	.i_mcb_drp_clk			(mcb_drp_clk				),		//MCB DRP 时钟，
	.i_bufpll_mcb_lock		(bufpll_mcb_lock			),		//BUFPLL_MCB 锁定信号
	.o_calib_done			(o_calib_done				),		//clk_frame_buf时钟域，DDR3校准完成信号，高有效
	.o_wr_error				(o_wr_error					),		//MCB写端口出现错误，高有效
	.o_rd_error				(o_rd_error					),		//MCB读端口出现错误，高有效
	.mcb1_dram_dq			(mcb1_dram_dq				),		//数据信号
	.mcb1_dram_a         	(mcb1_dram_a        		),		//地址信号
	.mcb1_dram_ba        	(mcb1_dram_ba       		),		//Bank地址信号
	.mcb1_dram_ras_n     	(mcb1_dram_ras_n    		),		//行地址选通
	.mcb1_dram_cas_n     	(mcb1_dram_cas_n    		),		//列地址选通
	.mcb1_dram_we_n      	(mcb1_dram_we_n     		),		//写信号
	.mcb1_dram_odt       	(mcb1_dram_odt      		),		//阻抗匹配信号
	.mcb1_dram_reset_n   	(mcb1_dram_reset_n  		),		//复位信号
	.mcb1_dram_cke       	(mcb1_dram_cke      		),		//时钟使能信号
	.mcb1_dram_dm        	(mcb1_dram_dm       		),		//低字节数据屏蔽信号
	.mcb1_dram_udqs      	(mcb1_dram_udqs     		),		//高字节地址选通信号正
	.mcb1_dram_udqs_n    	(mcb1_dram_udqs_n   		),		//高字节地址选通信号负
	.mcb1_rzq            	(mcb1_rzq           		),		//驱动校准
	.mcb1_dram_udm       	(mcb1_dram_udm      		),		//高字节数据屏蔽信号
	.mcb1_dram_dqs       	(mcb1_dram_dqs      		),		//低字节	数据选通信号正
	.mcb1_dram_dqs_n     	(mcb1_dram_dqs_n    		),		//低字节数据选通信号负
	.mcb1_dram_ck        	(mcb1_dram_ck       		),		//时钟正
	.mcb1_dram_ck_n      	(mcb1_dram_ck_n     		)		//时钟负
	);

	//  ===============================================================================================
	//	ref 时钟信号
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
	.iv_u3v_size			(wv_u3v_size			),		//需要关注
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
