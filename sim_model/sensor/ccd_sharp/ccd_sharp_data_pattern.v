//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : ccd_sharp_data_pattern
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/8/25 10:46:08	:|  初始版本
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

module ccd_sharp_data_pattern # (
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
	parameter	ALLPIX_PER_LINE		= 1376				,	//一行所有像素
	parameter	IMAGE_SOURCE		= "RANDOM"			,	//"RANDOM" or "FILE" or "LINE_INC" or "FRAME_INC" or "PIX_INC"
	parameter	SOURCE_FILE_PATH	= "source_file/"		//数据源文件路径
	)
	(
	input							i_line_change		,	//垂直翻转结束
	input							i_frame_change			//xsg翻转结束
	);

	//	ref signals
	localparam	PIX_WIDTH	= (DATA_WIDTH<=8)	? 8 :
	(DATA_WIDTH<=16)	? 16 :
	(DATA_WIDTH<=24)	? 24 :
	(DATA_WIDTH<=32)	? 32 :
	32
	;

	reg								reset_file		= 1'b1;
	reg		[31:0]					file_handle		;
	reg		[DATA_WIDTH-1:0]		line_value		= 'b0;
	reg		[DATA_WIDTH-1:0]		frame_value		= 'b0;
	reg		[DATA_WIDTH-1:0]		h_shifter_init	[ALLPIX_PER_LINE-1:0]	;	//水平移位寄存器的初始化数据，目前所有行初始化数据都是相同的


	//	ref ARCHITECTURE

	//	===============================================================================================
	//	ref ***文件操作***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//读文件复位信号
	//	-------------------------------------------------------------------------------------
	initial begin
		reset_file	= 1'b1;
		#200
		reset_file	= 1'b0;
	end

	generate
		if(IMAGE_SOURCE=="FILE") begin
			//	-------------------------------------------------------------------------------------
			//	读文件，file_read 模块只负责打开文件，具体的读数据在外面做
			//	-------------------------------------------------------------------------------------
			file_read # (
			.DATA_WIDTH	(PIX_WIDTH			),
			.FILE_PATH	(SOURCE_FILE_PATH	)
			)
			file_read_inst (
			.clk		(1'b0			),
			.reset		(reset_file		),
			.i_fval		(!i_frame_change),
			.i_lval		(1'b0			),
			.ov_dout	(				)
			);

			//  -------------------------------------------------------------------------------------
			//	文件处理，以读模式打开
			//  -------------------------------------------------------------------------------------
			initial begin
				forever begin
					@(posedge i_frame_change)
					#1
					$fclose(file_handle);
					file_handle	<= $fopen(file_read_inst.file_name_str,"rb");

					if(file_handle=='b0) begin
						$display("%m: at time %t ERROR: open file fail.file name is \"%0s\".", $time,file_read_inst.file_name_str);
						$stop;
					end
					else begin
						$display("file open ok!file name is \"%0s\".",file_read_inst.file_name_str);
					end
				end
			end
		end
	endgenerate

	//	===============================================================================================
	//	ref ***初始化***
	//	===============================================================================================
	//	-------------------------------------------------------------------------------------
	//	LINE_INC的数值，每次xv翻转之后，加1
	//	--xsg的上升沿认为是一帧结束的信号，此时line_value复位
	//	-------------------------------------------------------------------------------------
	always @ (posedge i_line_change or posedge i_frame_change) begin
		if(i_frame_change) begin
			line_value	<= 'b0;
		end
		else begin
			line_value	<= line_value + 1'b1;
		end
	end

	//	-------------------------------------------------------------------------------------
	//	FRAME_INC的数值，每次xsg上升沿之后，加1
	//	-------------------------------------------------------------------------------------
	always @ (posedge i_frame_change) begin
		frame_value	<= frame_value + 1'b1;
	end

	//	-------------------------------------------------------------------------------------
	//	行数据初始化
	//	-------------------------------------------------------------------------------------
	genvar	k;
	generate
		for(k=0;k<=(ALLPIX_PER_LINE-1);k=k+1) begin
			if(k>=0 && k<DUMMY_HFRONT) begin
				initial begin
					forever begin
						h_shifter_init[k]	= DUMMY_INIT_VALUE;
						@(posedge i_line_change);
					end
				end
			end
			else if(k>=DUMMY_HFRONT && k<(DUMMY_HFRONT+BLACK_HFRONT)) begin
				initial begin
					forever begin
						h_shifter_init[k]	= BLACK_INIT_VALUE;
						@(posedge i_line_change);
					end
				end
			end
			else if(k>=(DUMMY_HFRONT+BLACK_HFRONT) && k<(DUMMY_HFRONT+BLACK_HFRONT+IMAGE_WIDTH)) begin
				if(IMAGE_SOURCE=="RANDOM") begin
					initial begin
						forever begin
							h_shifter_init[k]	= $random();
							@(posedge i_line_change);
						end
					end
				end
				else if(IMAGE_SOURCE=="PIX_INC") begin
					initial begin
						forever begin
							h_shifter_init[k]	= h_shifter_init[k-1]+1'b1;
							@(posedge i_line_change);
						end
					end
				end
				else if(IMAGE_SOURCE=="LINE_INC") begin
					initial begin
						forever begin
							h_shifter_init[k]	= line_value;
							@(posedge i_line_change);
						end
					end
				end
				else if(IMAGE_SOURCE=="FRAME_INC") begin
					initial begin
						forever begin
							h_shifter_init[k]	= frame_value;
							@(posedge i_line_change);
						end
					end
				end
				else if(IMAGE_SOURCE=="FILE") begin
					//8bit 每个像素占用1个字节
					if(PIX_WIDTH==8) begin
						initial begin
							#10
							@(negedge i_frame_change);
							forever begin
								h_shifter_init[k][DATA_WIDTH-1:0]	= $fgetc(file_handle);
								@(posedge i_line_change);
							end
						end
					end
					else if(PIX_WIDTH==16) begin
						initial begin
							#10
							@(negedge i_frame_change);
							forever begin
								h_shifter_init[k][7:0]				<= $fgetc(file_handle);
								h_shifter_init[k][DATA_WIDTH-1:8]	<= $fgetc(file_handle);
								@(posedge i_line_change);
							end
						end
					end
					else if(PIX_WIDTH==24) begin
						initial begin
							#10
							@(negedge i_frame_change);
							forever begin
								h_shifter_init[k][7:0]				= $fgetc(file_handle);
								h_shifter_init[k][15:8]				= $fgetc(file_handle);
								h_shifter_init[k][DATA_WIDTH-1:16]	= $fgetc(file_handle);
								@(posedge i_line_change);
							end
						end
					end
					else if(PIX_WIDTH==32) begin
						initial begin
							#10
							@(negedge i_frame_change);
							forever begin
								h_shifter_init[k][7:0]				= $fgetc(file_handle);
								h_shifter_init[k][15:8]				= $fgetc(file_handle);
								h_shifter_init[k][23:16]			= $fgetc(file_handle);
								h_shifter_init[k][DATA_WIDTH-1:24]	= $fgetc(file_handle);
								@(posedge i_line_change);
							end
						end
					end
				end
			end
			else if(k>=(DUMMY_HFRONT+BLACK_HFRONT+IMAGE_WIDTH) && k<(DUMMY_HFRONT+BLACK_HFRONT+IMAGE_WIDTH+BLACK_HREAR)) begin
				initial begin
					forever begin
						h_shifter_init[k]	= BLACK_INIT_VALUE;
						@(posedge i_line_change);
					end
				end
			end
			else if(k>=(DUMMY_HFRONT+BLACK_HFRONT+IMAGE_WIDTH+BLACK_HREAR) && k<(DUMMY_HFRONT+BLACK_HFRONT+IMAGE_WIDTH+BLACK_HREAR+DUMMY_HREAR)) begin
				initial begin
					forever begin
						h_shifter_init[k]	= DUMMY_INIT_VALUE;
						@(posedge i_line_change);
					end
				end
			end
		end
	endgenerate




endmodule
