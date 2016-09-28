//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : file_read
//  -- �����       : �Ϻ���
//-------------------------------------------------------------------------------------------------
//
//  -- �汾��¼ :
//
//  -- ����         :| �޸�����				:|  �޸�˵��
//-------------------------------------------------------------------------------------------------
//  -- �Ϻ���       :| 2015/3/25 10:01:37	:|  ��ʼ�汾
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
//`timescale 1ns/1ps
`timescale 1ns/1ns
//-------------------------------------------------------------------------------------------------

module file_read # (
	parameter	DATA_WIDTH		= 8					,	//���ݿ��
	parameter	FILE_PATH		= "source_file/"		//����������Ҫд���·��
	)
	(
	input								clk			,	//ʱ��
	input								reset		,	//��λ
	input								i_fval		,	//���ź�
	input								i_lval		,	//���ź�
	output	[DATA_WIDTH-1:0]			ov_dout			//�������
	);

	//	ref signals
	reg		[7:0]				file_name_low 			= 8'h30;	//0
	reg		[7:0]				file_name_high 			= 8'h30;	//0
	reg		[31:0]				file_handle				= 32'b0;
	wire	[399:0]				file_name_str			;

	reg		[DATA_WIDTH-1:0]		file_data			= {DATA_WIDTH{1'b0}};

	//	ref ARCHITECTURE


	//  ===============================================================================================
	//	�л�ͼ��Դ�ļ����ļ����� 00.raw ~ ff.raw ����256���ļ����������ff.raw���Ͳ����������ˣ����������Ϣ
	//	1.����� �ļ�ģʽ��ͼ��Դ���ļ������ļ��ж�ȡ����
	//	2.����� ����ģʽ��ͼ��Դ��tb�в�������д�뵽�ļ�����
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	�ļ������ֽ�
	//	1.����λ��Чʱ����0
	//	2.�����ӵ�9ʱ����һ����a
	//	3.�����ӵ�fʱ��������ֽ�Ҳ��f���Ǵ�ӡ����
	//	4.�����ӵ�fʱ��������ֽڲ���f����λΪ0
	//	5.������ֵʱ������
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
	//	�ļ������ֽ�
	//	1.����λ��Чʱ����0
	//	2.�����ֽ����ӵ�fʱ
	//	--1.�����ӵ�9ʱ����һ����a
	//	--2.�����ӵ�fʱ��do not care
	//	--3.������ֵʱ������
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
					//����״̬����low�Ľ����б���
				end
				else begin
					file_name_high	<= file_name_high + 1'b1;
				end
			end

		end
	end
	assign	file_name_str		= {FILE_PATH,file_name_high,file_name_low,".raw"};

	//  -------------------------------------------------------------------------------------
	//	�ļ�������дģʽ��
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
	//	�����ɵ�����д�뵽�ļ��У���ͼ��Դ����fileʱ��������Ҳд�뵽file��
	//	1.λ��Ϊ8bit ÿ������ռ��1���ֽ�
	//	2.λ��Ϊ168bit ÿ������ռ��2���ֽڣ���д���ֽڣ���д���ֽ�
	//  -------------------------------------------------------------------------------------
	generate
		//8bit ÿ������ռ��1���ֽ�
		if(DATA_WIDTH==8) begin
			always @ (posedge clk) begin
				if(i_lval == 1'b1) begin
					file_data[7:0]	<= $fgetc(file_handle);
				end
			end
		end
		// 16bit ÿ������ռ��2���ֽ�
		else if(DATA_WIDTH==16) begin
			always @ (posedge clk) begin
				if(i_lval == 1'b1) begin
					file_data[7:0]	<= $fgetc(file_handle);
					file_data[15:8]	<= $fgetc(file_handle);
				end
			end
		end
		// 24bit ÿ������ռ��3���ֽ�
		else if(DATA_WIDTH==24) begin
			always @ (posedge clk) begin
				if(i_lval == 1'b1) begin
					file_data[7:0]		<= $fgetc(file_handle);
					file_data[15:8]		<= $fgetc(file_handle);
					file_data[23:16]	<= $fgetc(file_handle);
				end
			end
		end
		// 32bit ÿ������ռ��4���ֽ�
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
