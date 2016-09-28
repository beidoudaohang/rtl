//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : file_write
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

module file_write # (
	parameter	DATA_WIDTH		= 8				,	//数据宽度
	parameter	CHANNEL_NUM		= 4				,	//通道数
	parameter	FILE_PATH		= "gen_file/"		//产生的数据要写入的路径
	)
	(
	input										clk		,	//时钟
	input										reset	,	//复位
	input										i_fval	,	//场信号
	input										i_lval	,	//行信号
	input	[DATA_WIDTH*CHANNEL_NUM-1:0]		iv_din		//数据输入

	);

	//	ref signals
	localparam	PIX_WIDTH	= (DATA_WIDTH%8 == 0) ? DATA_WIDTH : (DATA_WIDTH + 8 - DATA_WIDTH%8);

	reg							fval_dly				= 1'b0;
	wire						fval_rise				;
	wire						fval_fall				;
	reg		[7:0]				file_name_low 			= 8'h30;	//0
	reg		[7:0]				file_name_high 			= 8'h30;	//0
	reg		[31:0]				file_handle				= 32'b0;
	wire	[399:0]				file_name_str			;
	wire	[PIX_WIDTH-1:0]		din_comb		[CHANNEL_NUM-1:0]		;

	//	ref ARCHITECTURE

	//	//	-------------------------------------------------------------------------------------
	//	//	取边沿
	//	//	-------------------------------------------------------------------------------------
	//	always @ (posedge clk) begin
	//		fval_dly	<= i_fval;
	//	end
	//	assign	fval_fall	= (fval_dly==1'b1 && i_fval==1'b0) ? 1'b1 : 1'b0;

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
		end
		else begin
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
	initial begin
		forever begin
			@(posedge i_fval)
			$fclose(file_handle);
			file_handle	<= $fopen(file_name_str,"wb");
		end
	end

	genvar ch;
	genvar i;
	generate
		for(ch=0;ch<CHANNEL_NUM;ch=ch+1) begin
			//	-------------------------------------------------------------------------------------
			//	输入写入之前，拼接为8的整数倍
			//	-------------------------------------------------------------------------------------
			assign	din_comb[ch]	= {{(PIX_WIDTH-DATA_WIDTH){1'b0}},iv_din[DATA_WIDTH*(ch+1)-1:DATA_WIDTH*ch]};

			//  -------------------------------------------------------------------------------------
			//	将生成的数据写入到文件中，当图像源不是file时，将数据也写入到file中
			//	1.位宽为1-8bit 每个像素占用1个字节
			//	2.位宽为9-16bit 每个像素占用2个字节，先写低字节，再写高字节
			//	3.位宽为17-24bit 每个像素占用3个字节，先写低字节，再写高字节
			//	4.位宽为25-32bit 每个像素占用4个字节，先写低字节，再写高字节
			//  -------------------------------------------------------------------------------------
			for(i=0;i<PIX_WIDTH/8;i=i+1) begin
				always @ (posedge clk) begin
					if(i_lval == 1'b1) begin
						$fwrite (file_handle,"%c",din_comb[ch][((i+1)*8-1):(i*8)]);
					end
				end
			end
		end
	endgenerate





endmodule
