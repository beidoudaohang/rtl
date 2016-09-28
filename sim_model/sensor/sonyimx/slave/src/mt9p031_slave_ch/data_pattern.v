//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : data_pattern
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/16 15:44:34	:|  初始版本
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
//`timescale 1ns/1ps
`timescale 1ns/1ns
//-------------------------------------------------------------------------------------------------

module data_pattern # (
	parameter	IMAGE_SRC				= "RANDOM"			,	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC" or "FRAME_INC_NO_RST" or "PIX_INC_NO_FVAL" or "PIX_INC"
	parameter	CHANNEL_NUM				= 4					,	//通道数
	parameter	SOURCE_FILE_PATH		= "source_file/"	,	//数据源文件路径
	parameter	DATA_WIDTH				= 12				,	//8 10 12 max is 32
	parameter	FRAME_INFO_LINE			= 1					,	//Frame information line
	parameter	IGNORE_OB_LINE			= 6					,	//Ignored OB
	parameter	VEFFECT_OB_LINE			= 4						//Vertical effective OB
	)
	(
	input										clk		,
	input										reset	,
	input										i_fval	,
	input										i_lval	,
	output										o_fval	,
	output										o_lval	,
	output	[DATA_WIDTH*CHANNEL_NUM-1:0]		ov_dout
	);

	//	ref signals
	localparam	LINE_CNT_WIDTH	= log2(FRAME_INFO_LINE+IGNORE_OB_LINE+VEFFECT_OB_LINE);

	reg		[7:0]							file_name_low 	= 8'h30;	//0
	reg		[7:0]							file_name_high 	= 8'h30;	//0
	reg		[31:0]							file_input		= 32'b0;
	reg		[319:0]							input_path		= "mt9p031_input_file/";
	wire	[399:0]							input_file_name_str	;
	reg		[DATA_WIDTH-1:0]				src_value 	[CHANNEL_NUM-1:0];
	wire	[DATA_WIDTH*CHANNEL_NUM-1:0]	file_data		;

	reg										fval_dly0 	= 1'b0;
	reg										fval_dly1 	= 1'b0;
	reg										lval_dly0 	= 1'b0;
	reg										lval_dly1 	= 1'b0;
	wire									dval_rise	;
	wire									dval_fall	;
	wire									fval_rise	;
	wire									fval_fall	;
	reg		[LINE_CNT_WIDTH-1:0]			line_cnt	= 'b0;
	reg										fval_mask	= 1'b0;


	//	-------------------------------------------------------------------------------------
	//	取对数，上取整
	//	-------------------------------------------------------------------------------------
	function integer log2 (input integer xx);
		integer x;
		begin
			x	= xx-1 ;
			for (log2=0;x>0;log2=log2+1) begin
				x	= x >> 1;
			end
		end
	endfunction

	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***提取边沿***
	//  ===============================================================================================
	always @ (posedge clk) begin
		fval_dly0	<= i_fval;
		fval_dly1	<= fval_dly0;
	end

	always @ (posedge clk) begin
		lval_dly0	<= i_lval;
		lval_dly1	<= lval_dly0;
	end

	assign	dval_rise	= (lval_dly1==1'b0 && lval_dly0==1'b1) ? 1'b1 : 1'b0;
	assign	dval_fall	= (lval_dly1==1'b1 && lval_dly0==1'b0) ? 1'b1 : 1'b0;
	assign	fval_rise	= (fval_dly1==1'b0 && fval_dly0==1'b1) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_dly1==1'b1 && fval_dly0==1'b0) ? 1'b1 : 1'b0;

	//	-------------------------------------------------------------------------------------
	//	行计数器
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_rise) begin
			line_cnt	<= 'b0;
		end
		else if(dval_fall) begin
			if(line_cnt=={LINE_CNT_WIDTH{1'b1}}) begin
				line_cnt	<= line_cnt;
			end
			else begin
				line_cnt	<= line_cnt + 1'b1;
			end
		end
	end

	//	-------------------------------------------------------------------------------------
	//	选择有效数据
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(line_cnt>=(FRAME_INFO_LINE+IGNORE_OB_LINE+VEFFECT_OB_LINE)) begin
			fval_mask	<= i_fval;
		end
		else begin
			fval_mask	<= 1'b0;
		end
	end

	//  ===============================================================================================
	//	ref ***产生图像数据***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	根据paramter参数，选择电路
	//  -------------------------------------------------------------------------------------
	genvar	ch;
	generate
		for(ch=0;ch<CHANNEL_NUM;ch=ch+1) begin
			//  -------------------------------------------------------------------------------------
			//	1.随机模式，产生随机数，并将数据写入文件当中
			//  -------------------------------------------------------------------------------------
			if(IMAGE_SRC=="RANDOM") begin
				//产生数据
				always @ (posedge clk) begin
					if(reset) begin
						src_value[ch]	<= 'b0;
					end
					else begin
						if(lval_dly0==1'b1 && fval_mask==1'b1) begin
							src_value[ch]	<= $random();
						end
					end
				end
			end

			//  -------------------------------------------------------------------------------------
			//	2.行自增模式，低4bit递增，高bit每行递增
			//  -------------------------------------------------------------------------------------
			else if(IMAGE_SRC=="LINE_INC") begin
				//产生数据 - 高字节
				always @ (posedge clk) begin
					if(reset) begin
						src_value[ch][DATA_WIDTH-1:4]	<= 'b0;
					end
					else begin
						if(!i_fval) begin
							src_value[ch][DATA_WIDTH-1:4]	<= 'b0;
						end
						else if(dval_fall==1'b1 && fval_mask==1'b1) begin
							src_value[ch][DATA_WIDTH-1:4]	<= src_value[ch][DATA_WIDTH-1:4] + 1'b1;
						end
					end
				end
				//产生数据 - 低字节
				always @ (posedge clk) begin
					if(reset) begin
						src_value[ch][3:0]	<= 'b0;
					end
					else begin
						if(!lval_dly1) begin
							src_value[ch][3:0]	<= 'b0;
						end
						else begin
							src_value[ch][3:0]	<= src_value[ch][3:0] + 1'b1;
						end
					end
				end
			end

			//  -------------------------------------------------------------------------------------
			//	3.帧自增模式，全体像素，每帧递增
			//  -------------------------------------------------------------------------------------
			else if(IMAGE_SRC=="FRAME_INC") begin
				always @ (posedge clk) begin
					if(reset) begin
						src_value[ch]	<= 'b0;
					end
					else begin
						if(fval_fall) begin
							src_value[ch]	<= src_value[ch] + 1'b1;
						end
					end
				end
			end

			//  -------------------------------------------------------------------------------------
			//	4.帧自增模式，全体像素，每帧递增，复位不起作用
			//  -------------------------------------------------------------------------------------
			else if(IMAGE_SRC=="FRAME_INC_NO_RST") begin
				always @ (posedge clk) begin
					if(fval_fall) begin
						src_value[ch]	<= src_value[ch] + 1'b1;
					end
				end
			end

			//  -------------------------------------------------------------------------------------
			//	5.从文件中读数，此处不要打拍
			//  -------------------------------------------------------------------------------------
			else if(IMAGE_SRC=="FILE") begin
				always @ (*) begin
					src_value[ch]	<= file_data[DATA_WIDTH*(ch+1)-1:DATA_WIDTH*ch];
				end
			end

			//  -------------------------------------------------------------------------------------
			//	6.像素自增模式，行消隐不会复位数值
			//  -------------------------------------------------------------------------------------
			else if(IMAGE_SRC=="PIX_INC_NO_FVAL") begin
				always @ (posedge clk) begin
					if(reset) begin
						src_value[ch]	<= 'b0;
					end
					else begin
						if(lval_dly1==1'b1 && fval_mask==1'b1) begin
							src_value[ch]	<= src_value[ch] + 1'b1;
						end
					end
				end
			end

			//  -------------------------------------------------------------------------------------
			//	7.像素自增模式，行消隐会复位数值
			//  -------------------------------------------------------------------------------------
			else if(IMAGE_SRC=="PIX_INC") begin
				always @ (posedge clk) begin
					if(reset) begin
						src_value[ch]	<= 'b0;
					end
					else begin
						if(!i_fval) begin
							src_value[ch]	<= 'b0;
						end
						else if(lval_dly1==1'b1 && fval_mask==1'b1) begin
							src_value[ch]	<= src_value[ch] + 1'b1;
						end
					end
				end
			end
		end

	endgenerate

	//  -------------------------------------------------------------------------------------
	//	如果定义了是从文件中读数据，则需要例化读文件的模块
	//  -------------------------------------------------------------------------------------
	generate
		if(IMAGE_SRC=="FILE") begin
			file_read # (
			.DATA_WIDTH		(DATA_WIDTH			),
			.CHANNEL_NUM	(CHANNEL_NUM		),
			.FILE_PATH		(SOURCE_FILE_PATH	)
			)
			file_read_inst (
			.clk			(clk			),
			.reset			(reset			),
			.i_fval			(fval_mask		),
			.i_lval			(lval_dly0		),
			.ov_dout		(file_data		)
			);
		end
	endgenerate

	//  ===============================================================================================
	//	ref ***输出数据***
	//  ===============================================================================================
	assign	o_fval		= fval_dly1;
	assign	o_lval		= lval_dly1;
	genvar	ch_cnt;
	generate
		for(ch_cnt=0;ch_cnt<CHANNEL_NUM;ch_cnt=ch_cnt+1) begin
			assign	ov_dout[DATA_WIDTH*(ch_cnt+1)-1:DATA_WIDTH*ch_cnt]		= lval_dly1 ? src_value[ch_cnt] : {DATA_WIDTH{1'b0}};
		end
	endgenerate



endmodule
