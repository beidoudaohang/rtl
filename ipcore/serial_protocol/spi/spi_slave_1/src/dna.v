//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : dna
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/12/12 16:10:44	:|  初始版本
//-------------------------------------------------------------------------------------------------
//
//  -- 模块描述     :
//              1)  : 模块的主时钟是clk_osc_bufg 40MHz。DNA模块最大只能支持到2MHz的频率，因此在dna模块内部
//					将clk_osc_bufg分频为1MHz的时钟-clk_dna，用clk_dna驱动FPGA内部的dna模块。
//              2)  : ... ...
//
//              3)  : ... ...
//
//-------------------------------------------------------------------------------------------------
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module dna # (
	parameter		LONG_REG_WD				= 64	,	//长寄存器位宽
	parameter		REG_INIT_VALUE			= "TRUE"	//寄存器是否有初始值
	)
	(
	input						clk					,	//40MHz
	input						reset				,	//40MHz复位信号
	output	[LONG_REG_WD-1:0]	ov_dna_reg			,	//clk_dna时钟域，读到dna之后，稳定不变
	input	[LONG_REG_WD-1:0]	iv_encrypt_reg		,	//clk_osc_bufg时钟域
	output						o_encrypt_state			//clk_dna时钟域，加密状态。1-加密成功，0-加密失败
	);

	//	ref signals
	reg		[4:0]		clk_div_cnt		= 5'b0;
	wire				clk_dna			;
	reg		[6:0]		flow_cnt		= 7'b0;
	reg					dna_read		= 1'b0;
	reg					dna_shift		= 1'b0;
	reg		[56:0]		dna_reg			= 57'b0;
	reg		[55:0]		dna_enc_reg0	= 56'b0;
	wire	[63:0]		dna_enc_reg1	;
	reg					encrypt_state_reg	= 1'b0;


	//	ref ARCHITECTURE

	//  ===============================================================================================
	//	ref ***例化 DNA 模块***
	//	1.bit56固定是1，bit55固定是0，但仿真模型里面只把bit56固定为0了
	//	2.当read=1时，把内部数据转移到移位寄存器上，同时dout=bit56=1。当shift=1时，把bit55移到dout上。因此要移位出57bit数据，shift只需56个时钟。
	//	3.ug380规定，理想情况下，SHIFT在clk=0或者在clk下降沿，由0变为1
	//  ===============================================================================================
	DNA_PORT # (
	.SIM_DNA_VALUE	(57'h043210000001234	)  // Specifies the Pre-programmed factory ID value
	)
	DNA_PORT_inst (
	.DOUT		(dna_dout	),	// 1-bit output: DNA output data
	.CLK		(clk_dna	),	// 1-bit input: Clock input
	.DIN		(1'b0		),	// 1-bit input: User data input pin
	.READ		(dna_read	),	// 1-bit input: Active high load DNA, active low read input
	.SHIFT		(dna_shift	)	// 1-bit input: Active high shift enable input
	);

	//  ===============================================================================================
	//	ref ***读DNA_PORT的逻辑***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	分频计数器
	//	1.40MHz 32 分频，1.25MHz
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			clk_div_cnt	<= 5'b0;
		end
		else begin
			clk_div_cnt	<= clk_div_cnt + 1'b1;
		end
	end
	assign	clk_dna	= clk_div_cnt[4];

	//  -------------------------------------------------------------------------------------
	//	读 dna 流程控制的计数器
	//	1.在clk dna下降沿的时候，flow cnt自增
	//	2.当flow cnt bit6=1 ，即加到64时，停止
	//  ------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(reset) begin
			flow_cnt	<= 7'b0;
		end
		else begin
			//此时clk dna产生下降沿
			if(clk_div_cnt==5'h1f) begin
				if(flow_cnt[6]) begin
					flow_cnt	<= flow_cnt;
				end
				else begin
					flow_cnt	<= flow_cnt + 1'b1;
				end
			end
		end
	end

	//  -------------------------------------------------------------------------------------
	//	发出读信号，使 dna_port 中的数据转移到移位寄存器当中
	//	1.read信号与clk dna的下降沿对齐，参考ug382对shift的约束
	//  ------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(flow_cnt==7'd2) begin
			dna_read	<= 1'b1;
		end
		else begin
			dna_read	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	发出移位信号
	//	1.shift信号与clk dna的下降沿对齐，为的是符合ug380的规定
	//	2.shift信号宽度是56个时钟周期
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(flow_cnt>=7'd3 && flow_cnt<=7'd58) begin
			dna_shift	<= 1'b1;
		end
		else begin
			dna_shift	<= 1'b0;
		end
	end

	//  -------------------------------------------------------------------------------------
	//	接收 dna 模块输出的数据
	//	1.当read=1时，dou输出1，即dna_data的最高bit
	//	2.当read=0 shift=1时，开始移位
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(flow_cnt>=7'd2 && flow_cnt<=7'd58) begin
			//此时clk dna产生下降沿
			if(clk_div_cnt==5'h1f) begin
				dna_reg	<= {dna_reg[55:0],dna_dout};
			end
		end
	end
	assign	ov_dna_reg	= {7'b0,dna_reg};

	//  ===============================================================================================
	//	ref ***加密算法***
	//  ===============================================================================================
	//  -------------------------------------------------------------------------------------
	//	生成加密字
	//	1.当dna读到之后，低7个字节按位与上0xaa
	//	2.最高字节用0x47代替
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(flow_cnt[6]) begin
			dna_enc_reg0	<= dna_reg[55:0] & 56'haaaaaa_aaaaaaaa;
		end
		else begin
			dna_enc_reg0	<= 56'h0;
		end
	end
	assign	dna_enc_reg1	= {8'h47,dna_enc_reg0};

	//  -------------------------------------------------------------------------------------
	//	判断加密状态
	//	1.如果固件设置的加密字与fpga读到的加密字一样，则加密通过
	//  -------------------------------------------------------------------------------------
	always @ (posedge clk) begin
		if(dna_enc_reg1==iv_encrypt_reg) begin
			encrypt_state_reg	<= 1'b1;
		end
		else begin
			encrypt_state_reg	<= 1'b0;
		end
	end

	generate
		if(REG_INIT_VALUE=="TRUE") begin
			assign	o_encrypt_state	= 1'b1;
		end
		else begin
			assign	o_encrypt_state	= encrypt_state_reg;
		end
	endgenerate





endmodule