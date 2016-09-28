//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : file_read
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/3/25 10:01:37	:|  初始版本
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

module file_read # (
	parameter	DATA_WIDTH		= 8					,	//数据宽度
	parameter	FILE_PATH		= "source_file/"		//产生的数据要写入的路径
	)
	(
	input								clk			,	//时钟
	input								reset		,	//复位
	input								i_fval		,	//场信号
	input								i_lval		,	//行信号
	output	[DATA_WIDTH-1:0]			ov_dout			//数据输出
	);

	//	ref signals
	reg		[7:0]				file_name_low 			= 8'h30;	//0
	reg		[7:0]				file_name_high 			= 8'h30;	//0
	reg		[31:0]				file_handle				= 32'b0;
	wire	[399:0]				file_name_str			;

	reg		[DATA_WIDTH-1:0]		file_data			= {DATA_WIDTH{1'b0}};

	//	ref ARCHITECTURE


	//  ===============================================================================================
	//	切换图像源文件，文件名从 00.raw ~ ff.raw ，共256个文件。如果到达ff.raw，就不会再增加了，输出报警信息
	//	1.如果是 文件模式，图像源是文件，从文件中读取数据
	//	2.如果是 其他模式，图像源在tb中产生，并写入到文件当中
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	文件名低字节
	//	1.当复位有效时，是0
	//	2.当增加到9时，下一个是a
	//	3.当增加到f时，如果高字节也是f，那打印错误
	//	4.当增加到f时，如果高字节不是f，复位为0
	//	5.其他数值时，自增
	//  -------------------------------------------------------------------------------------
	always @ (negedge i_fval or posedge reset) begin
		if(reset) begin
			file_name_low	<= 8'h30;	//0
		end else begin
			if(file_name_low==8'h39) begin	//9
				file_name_low	<= 8'h61;	//a
			end
			else if(file_name_low==8'h66) begin	//f
				if(file_name_high==8'h66) begin	//f
					$display ("%m:time is %t,file num is reaching 0xff,can not increase",$time);
				end
				else begin
					file_name_low	<= 8'h30;	//0
				end
			end
			else begin
				file_name_low	<= file_name_low + 1'b1;
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	文件名高字节
	//	1.当复位有效时，是0
	//	2.当低字节增加到f时
	//	--1.当增加到9时，下一个是a
	//	--2.当增加到f时，do not care
	//	--3.其他数值时，自增
	//  -------------------------------------------------------------------------------------
	always @ (negedge i_fval or posedge reset) begin
		if(reset) begin
			file_name_high	<= 8'h30;	//30
		end else begin
			if(file_name_low==8'h66) begin	//f
				if(file_name_high==8'h39) begin	//9
					file_name_high	<= 8'h61;	//a
				end
				else if(file_name_high==8'h66) begin	//f
					//错误状态，在low的进程中报错
				end
				else begin
					file_name_high	<= file_name_high + 1'b1;
				end
			end

		end
	end
	assign	file_name_str		= {FILE_PATH,file_name_high,file_name_low,".raw"};

	//  -------------------------------------------------------------------------------------
	//	文件处理，以写模式打开
	//  -------------------------------------------------------------------------------------
	always @ (posedge i_fval) begin
		$fclose(file_handle);
		file_handle	<= $fopen(file_name_str,"rb");
	end

	always @ (posedge i_fval) begin
		#20
		if(file_handle=='b0) begin
			$display("%m: at time %t ERROR: open file fail.file name is \"%0s\".", $time,file_name_str);
			$stop;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	将生成的数据写入到文件中，当图像源不是file时，将数据也写入到file中
	//	1.位宽为8bit 每个像素占用1个字节
	//	2.位宽为168bit 每个像素占用2个字节，先写低字节，再写高字节
	//  -------------------------------------------------------------------------------------
	generate
		//8bit 每个像素占用1个字节
		if(DATA_WIDTH==8) begin
			always @ (posedge clk) begin
				if(i_lval == 1'b1) begin
					file_data[7:0]	<= $fgetc(file_handle);
				end
			end
		end
		// 16bit 每个像素占用2个字节
		else if(DATA_WIDTH==16) begin
			always @ (posedge clk) begin
				if(i_lval == 1'b1) begin
					file_data[7:0]	<= $fgetc(file_handle);
					file_data[15:8]	<= $fgetc(file_handle);
				end
			end
		end
		// 24bit 每个像素占用3个字节
		else if(DATA_WIDTH==24) begin
			always @ (posedge clk) begin
				if(i_lval == 1'b1) begin
					file_data[7:0]		<= $fgetc(file_handle);
					file_data[15:8]		<= $fgetc(file_handle);
					file_data[23:16]	<= $fgetc(file_handle);
				end
			end
		end
		// 32bit 每个像素占用4个字节
		else if(DATA_WIDTH==32) begin
			always @ (posedge clk) begin
				if(i_lval == 1'b1) begin
					file_data[7:0]		<= $fgetc(file_handle);
					file_data[15:8]		<= $fgetc(file_handle);
					file_data[23:16]	<= $fgetc(file_handle);
					file_data[31:24]	<= $fgetc(file_handle);
				end
			end
		end
	endgenerate

	assign	ov_dout	= file_data[DATA_WIDTH-1:0];

endmodule
