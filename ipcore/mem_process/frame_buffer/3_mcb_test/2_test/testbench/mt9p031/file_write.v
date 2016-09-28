//-------------------------------------------------------------------------------------------------
//  -- ��Ȩ������   : �й���㣨���ţ����޹�˾����ͼ���Ӿ������ֹ�˾, 2010 -2015.
//  -- ���ܼ���     ������.
//  -- ����         : Ӳ������FPGA������
//  -- ģ����       : file_write
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

module file_write # (
	parameter	DATA_WIDTH		= 8				,	//���ݿ��
	parameter	FILE_PATH		= "gen_file/"		//����������Ҫд���·��
	)
	(
	input								clk		,	//ʱ��
	input								reset	,	//��λ
	input								i_fval	,	//���ź�
	input								i_lval	,	//���ź�
	input	[DATA_WIDTH-1:0]			iv_din		//��������

	);

	//	ref signals
	reg							fval_dly				= 1'b0;
	wire						fval_rise				;
	wire						fval_fall				;
	reg		[7:0]				file_name_low 			= 8'h30;	//0
	reg		[7:0]				file_name_high 			= 8'h30;	//0
	reg		[31:0]				file_handle				= 32'b0;
	wire	[399:0]				file_name_str			;


	//	ref ARCHITECTURE

	//	-------------------------------------------------------------------------------------
	//	ȡ����
	//	-------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		fval_dly	<= i_fval;
	end
	assign	fval_rise	= (fval_dly==1'b0 && i_fval==1'b1) ? 1'b1 : 1'b0;
	assign	fval_fall	= (fval_dly==1'b1 && i_fval==1'b0) ? 1'b1 : 1'b0;

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
	always @ (posedge clk or posedge reset) begin
		if(reset) begin
			file_name_low	<= 8'h30;	//0
		end
		else begin
			if(fval_fall) begin
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
	end

	//  -------------------------------------------------------------------------------------
	//	�ļ������ֽ�
	//	1.����λ��Чʱ����0
	//	2.�����ֽ����ӵ�fʱ
	//	--1.�����ӵ�9ʱ����һ����a
	//	--2.�����ӵ�fʱ��do not care
	//	--3.������ֵʱ������
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk or posedge reset) begin
		if(reset) begin
			file_name_high	<= 8'h30;	//30
		end else begin
			if(fval_fall) begin
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
	end
	assign	file_name_str		= {FILE_PATH,file_name_high,file_name_low,".raw"};

	//  -------------------------------------------------------------------------------------
	//	�ļ�������дģʽ��
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(fval_rise) begin
			$fclose(file_handle);
			file_handle	<= $fopen(file_name_str,"wb");
		end
	end

	//  -------------------------------------------------------------------------------------
	//	�����ɵ�����д�뵽�ļ��У���ͼ��Դ����fileʱ��������Ҳд�뵽file��
	//	1.λ��Ϊ1-8bit ÿ������ռ��1���ֽ�
	//	2.λ��Ϊ9-16bit ÿ������ռ��2���ֽڣ���д���ֽڣ���д���ֽ�
	//	3.λ��Ϊ17-24bit ÿ������ռ��3���ֽڣ���д���ֽڣ���д���ֽ�
	//	4.λ��Ϊ25-32bit ÿ������ռ��4���ֽڣ���д���ֽڣ���д���ֽ�
	//  -------------------------------------------------------------------------------------
	generate
		//8bit ÿ������ռ��1���ֽ�
		if(DATA_WIDTH<=8) begin
			always @ (posedge clk) begin
				if(i_lval == 1'b1) begin
					$fwrite (file_handle,"%c",{{(8-DATA_WIDTH){1'b0}},iv_din[DATA_WIDTH-1:0]});
				end
			end
		end
		//16bit ÿ������ռ��2���ֽ�
		else if(DATA_WIDTH<=16) begin
			always @ (posedge clk) begin
				if(i_lval == 1'b1) begin
					$fwrite (file_handle,"%c",iv_din[7:0]);
					$fwrite (file_handle,"%c",{{(16-DATA_WIDTH){1'b0}},iv_din[DATA_WIDTH-1:8]});
				end
			end
		end
		//24bit ÿ������ռ��3���ֽ�
		else if(DATA_WIDTH<=24) begin
			always @ (posedge clk) begin
				if(i_lval == 1'b1) begin
					$fwrite (file_handle,"%c",iv_din[7:0]);
					$fwrite (file_handle,"%c",iv_din[15:8]);
					$fwrite (file_handle,"%c",{{(24-DATA_WIDTH){1'b0}},iv_din[DATA_WIDTH-1:16]});
				end
			end
		end
		//32bit ÿ������ռ��4���ֽ�
		else if(DATA_WIDTH<=32) begin
			always @ (posedge clk) begin
				if(i_lval == 1'b1) begin
					$fwrite (file_handle,"%c",iv_din[7:0]);
					$fwrite (file_handle,"%c",iv_din[15:8]);
					$fwrite (file_handle,"%c",iv_din[23:16]);
					$fwrite (file_handle,"%c",{{(32-DATA_WIDTH){1'b0}},iv_din[DATA_WIDTH-1:24]});
				end
			end
		end
	endgenerate



endmodule
