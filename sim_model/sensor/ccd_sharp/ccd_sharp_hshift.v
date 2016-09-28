//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : ccd_sharp_hshift
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/8/10 14:17:57	:|  初始版本
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

module ccd_sharp_hshift # (
	parameter	DATA_WIDTH			= 14				,	//像素数据位宽
	parameter	IMAGE_WIDTH			= 1320				,	//图像宽度
	parameter	BLACK_VFRONT		= 8					,	//场头黑行个数
	parameter	BLACK_VREAR			= 2					,	//场尾黑行个数
	parameter	BLACK_HFRONT		= 12				,	//行头黑像素个数
	parameter	BLACK_HREAR			= 40				,	//行尾黑像素个数
	parameter	DUMMY_VFRONT		= 2					,	//场头哑行个数
	parameter	DUMMY_VREAR			= 0					,	//场尾哑行个数
	parameter	DUMMY_HFRONT		= 4					,	//行头哑像素个数
	parameter	DUMMY_HREAR			= 0					,	//行尾哑像素个数
	parameter	DUMMY_INIT_VALUE	= 16				,	//DUMMY初始值
	parameter	BLACK_INIT_VALUE	= 32				,	//BLACK初始值
	parameter	IMAGE_SOURCE		= "RANDOM"			,	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC" or "PIX_INC"
	parameter	SOURCE_FILE_PATH	= "source_file/"		//数据源文件路径
	)
	(
	input							i_line_change	,	//垂直翻转结束
	input							i_frame_change	,	//xsg翻转结束
	input							hl				,	//水平驱动
	input							h1				,	//水平驱动
	input							h2				,	//水平驱动
	input							rs				,	//水平驱动
	output	[DATA_WIDTH-1:0]		ov_pix_data			//输出像素数据
	);

	//	ref signals
	//	-------------------------------------------------------------------------------------
	//	一行中所有像素，包括前后的dummy和black
	//	-------------------------------------------------------------------------------------
	localparam	ALLPIX_PER_LINE	= DUMMY_HFRONT+BLACK_HFRONT+IMAGE_WIDTH+BLACK_HREAR+DUMMY_HREAR;

	reg		[DATA_WIDTH-1:0]		h_shifter	[ALLPIX_PER_LINE-1:0]		;	//水平移位寄存器，像素位宽和水平移位寄存器的长度都是由参数确定
	reg		[DATA_WIDTH-1:0]		pix_data_latch	= 'b0;
	reg		[DATA_WIDTH-1:0]		shift_out_pix	= 'b0;
	wire	[DATA_WIDTH-1:0]		h_shifter_init	[ALLPIX_PER_LINE-1:0]	;	//水平移位寄存器的初始化数据，目前所有行初始化数据都是相同的

	//	ref ARCHITECTURE
	//	===============================================================================================
	//	ref ***初始化***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	利用模块对存储区内的行像素初始化
	//	-------------------------------------------------------------------------------------
	ccd_sharp_data_pattern # (
	.DATA_WIDTH			(DATA_WIDTH			),
	.IMAGE_WIDTH		(IMAGE_WIDTH		),
	.BLACK_VFRONT		(BLACK_VFRONT		),
	.BLACK_VREAR		(BLACK_VREAR		),
	.BLACK_HFRONT		(BLACK_HFRONT		),
	.BLACK_HREAR		(BLACK_HREAR		),
	.DUMMY_VFRONT		(DUMMY_VFRONT		),
	.DUMMY_VREAR		(DUMMY_VREAR		),
	.DUMMY_HFRONT		(DUMMY_HFRONT		),
	.DUMMY_HREAR		(DUMMY_HREAR		),
	.DUMMY_INIT_VALUE	(DUMMY_INIT_VALUE	),
	.BLACK_INIT_VALUE	(BLACK_INIT_VALUE	),
	.ALLPIX_PER_LINE	(ALLPIX_PER_LINE	),
	.IMAGE_SOURCE		(IMAGE_SOURCE		),
	.SOURCE_FILE_PATH	(SOURCE_FILE_PATH	)
	)
	ccd_sharp_data_pattern_inst (
	.i_line_change		(i_line_change	),
	.i_frame_change		(i_frame_change	)
	);

	//	-------------------------------------------------------------------------------------
	//	水平移位寄存器初始化，水平初始寄存器映射
	//	-------------------------------------------------------------------------------------
	genvar	i;
	generate
		for(i=0;i<=(ALLPIX_PER_LINE-1);i=i+1) begin
			initial begin
				h_shifter[i]	<= {DATA_WIDTH{1'b0}};
			end
			assign	h_shifter_init[i]	= ccd_sharp_data_pattern_inst.h_shifter_init[i];
		end
	endgenerate

	//	===============================================================================================
	//	ref ***移位操作***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	水平移位，0像素首先移出
	//	-------------------------------------------------------------------------------------
	genvar	j;
	generate
		for(j=0;j<(ALLPIX_PER_LINE-1);j=j+1) begin
			always @ (posedge hl or posedge i_line_change) begin
				if(i_line_change) begin
					h_shifter[j]	<= h_shifter[j] + h_shifter_init[j];
				end
				else begin
					h_shifter[j]	<= h_shifter[j+1];
				end
			end
		end
	endgenerate

	always @ (posedge hl or posedge i_line_change) begin
		if(i_line_change) begin
			h_shifter[ALLPIX_PER_LINE-1]	<= h_shifter[ALLPIX_PER_LINE-1] + h_shifter_init[ALLPIX_PER_LINE-1];
		end
		else begin
			h_shifter[ALLPIX_PER_LINE-1]	<= {DATA_WIDTH{1'b0}};
		end
	end

	//	-------------------------------------------------------------------------------------
	//	移位输出寄存器，在hl上升沿之后，才能输出第一个数据
	//	--第一次移位，要把最低bit打出去
	//	-------------------------------------------------------------------------------------
	always @ (posedge hl) begin
		shift_out_pix	<= h_shifter[0];
	end

	//	-------------------------------------------------------------------------------------
	//	输出像素
	//	--当rs有效的时候，输出的数据要清零
	//	-------------------------------------------------------------------------------------
	always @ ( * ) begin
		if(rs) begin
			pix_data_latch	<= {DATA_WIDTH{1'b0}}	;
		end
		else begin
			pix_data_latch	<= shift_out_pix	;
		end
	end

	assign	ov_pix_data	= pix_data_latch;

endmodule
