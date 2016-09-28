//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : tb_top
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/6/5 16:16:13	:|  初始版本
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
`include			"frame_buffer_def.v"
`include			"pattern_model_def.v"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module tb_top ();

	//	ref signals


	reg									clk_osc 	= 1'b0;

	`ifdef	DDR3_16_DQ_MCB_8_DQ
		wire	[15:0]					mcb3_dram_dq;
	`else
		wire	[`NUM_DQ_PINS-1:0]		mcb3_dram_dq;
	`endif


	wire	[`MEM_ADDR_WIDTH-1:0]		mcb3_dram_a;
	wire	[`MEM_BANKADDR_WIDTH-1:0]	mcb3_dram_ba;
	wire								mcb3_dram_ras_n;
	wire								mcb3_dram_cas_n;
	wire								mcb3_dram_we_n;
	wire								mcb3_dram_odt;
	wire								mcb3_dram_reset_n;
	wire								mcb3_dram_cke;
	wire								mcb3_dram_dm;
	wire								mcb3_dram_udqs;
	wire								mcb3_dram_udqs_n;
	wire								mcb3_rzq;
	wire								mcb3_zio;
	wire								mcb3_dram_udm;
	wire								mcb3_dram_dqs;
	wire								mcb3_dram_dqs_n;
	wire								mcb3_dram_ck;
	wire								mcb3_dram_ck_n;


	wire			[4:0]	ov_fpga_sw	;
	wire			[4:0]	ov_fpga_led	;



	reg		[23:0]						DDR3_CMD;
	reg		[7:0]						rd_wr_cmd;
	wire	[2:0]						ddr_cmd_int;

	reg									bank [7:0];
	reg		[12:0]						row [7:0];
	genvar								i;
	reg		[12:0]						current_wr_row_addr;
	reg		[2:0]						current_wr_bank_addr;
	reg		[12:0]						current_rd_row_addr;
	reg		[2:0]						current_rd_bank_addr;

	//	ref ARCHITECTURE

	top_frame_buffer top_frame_buffer_inst (
	.clk_osc				(clk_osc			),
	`ifdef	DDR3_16_DQ
		.mcb3_dram_dq				(mcb3_dram_dq[15:0]	),
	`elsif	DDR3_8_DQ
		.mcb3_dram_dq				(mcb3_dram_dq[7:0]	),
	`endif
	.mcb3_dram_a			(mcb3_dram_a		),
	.mcb3_dram_ba			(mcb3_dram_ba		),
	.mcb3_dram_ras_n		(mcb3_dram_ras_n	),
	.mcb3_dram_cas_n		(mcb3_dram_cas_n	),
	.mcb3_dram_we_n			(mcb3_dram_we_n		),
	.mcb3_dram_odt			(mcb3_dram_odt		),
	.mcb3_dram_reset_n		(mcb3_dram_reset_n	),
	.mcb3_dram_cke			(mcb3_dram_cke		),
	.mcb3_dram_dm			(mcb3_dram_dm		),
		`ifdef	DDR3_16_DQ
		.mcb3_dram_udqs		(mcb3_dram_udqs		),
		.mcb3_dram_udqs_n	(mcb3_dram_udqs_n	),
	`endif
	.mcb3_rzq				(mcb3_rzq			),
	//	.mcb3_zio			(mcb3_zio			),

	`ifdef	DDR3_16_DQ
		.mcb3_dram_udm		(mcb3_dram_udm		),
	`endif
	.mcb3_dram_dqs			(mcb3_dram_dqs		),
	.mcb3_dram_dqs_n		(mcb3_dram_dqs_n	),
	.mcb3_dram_ck			(mcb3_dram_ck		),
	.mcb3_dram_ck_n			(mcb3_dram_ck_n		),
	.ov_fpga_sw				(ov_fpga_sw			),
	.ov_fpga_led			(ov_fpga_led		)
	);

	//  -------------------------------------------------------------------------------------
	//  DDR3 MODEL
	//  -------------------------------------------------------------------------------------
	PULLDOWN zio_pulldown3 (.O(mcb3_zio));   PULLDOWN rzq_pulldown3 (.O(mcb3_rzq));

	`ifdef	DDR3_16_DQ_MCB_8_DQ
		PULLDOWN mcb3_dram_dq_8 (.O(mcb3_dram_dq[8]));
		PULLDOWN mcb3_dram_dq_9 (.O(mcb3_dram_dq[9]));
		PULLDOWN mcb3_dram_dq_10 (.O(mcb3_dram_dq[10]));
		PULLDOWN mcb3_dram_dq_11 (.O(mcb3_dram_dq[11]));
		PULLDOWN mcb3_dram_dq_12 (.O(mcb3_dram_dq[12]));
		PULLDOWN mcb3_dram_dq_13 (.O(mcb3_dram_dq[13]));
		PULLDOWN mcb3_dram_dq_14 (.O(mcb3_dram_dq[14]));
		PULLDOWN mcb3_dram_dq_15 (.O(mcb3_dram_dq[15]));

		ddr3_model_c3 ddr3_model_c3_inst (
		.ck         		(mcb3_dram_ck					),
		.ck_n       		(mcb3_dram_ck_n					),
		.cke        		(mcb3_dram_cke					),
		.cs_n       		(1'b0							),
		.ras_n      		(mcb3_dram_ras_n				),
		.cas_n      		(mcb3_dram_cas_n				),
		.we_n       		(mcb3_dram_we_n					),
		.dm_tdqs    		({mcb3_dram_udm,mcb3_dram_dm}	),
		.ba         		(mcb3_dram_ba					),
		.addr       		(mcb3_dram_a					),
		.dq         		(mcb3_dram_dq					),
		.dqs      	  		({mcb3_dram_udqs,mcb3_dram_dqs}	),
		.dqs_n      		({mcb3_dram_udqs_n,mcb3_dram_dqs_n}),
		.tdqs_n     		(								),
		.odt        		(mcb3_dram_odt					),
		.rst_n      		(mcb3_dram_reset_n				)
		);

	`else
		ddr3_model_c3 ddr3_model_c3_inst (
		.ck         		(mcb3_dram_ck					),
		.ck_n       		(mcb3_dram_ck_n					),
		.cke        		(mcb3_dram_cke					),
		.cs_n       		(1'b0							),
		.ras_n      		(mcb3_dram_ras_n				),
		.cas_n      		(mcb3_dram_cas_n				),
		.we_n       		(mcb3_dram_we_n					),
		`ifdef	DDR3_16_DQ
			.dm_tdqs    		({mcb3_dram_udm,mcb3_dram_dm}	),
		`elsif	DDR3_8_DQ
			.dm_tdqs    		(mcb3_dram_dm					),
		`endif
		.ba         		(mcb3_dram_ba					),
		//仿真模型只有1Gb和2Gb两种容量，没有512Mb的容量，在仿真512Mb时，只能用1Gb的模型。因此高位地址需要填0
		`ifdef	DDR3_MEM_DENSITY_512Mb
			.addr       	({1'b0,mcb3_dram_a}				),
		`else
			.addr       	(mcb3_dram_a					),
		`endif
		.dq         		(mcb3_dram_dq					),
		`ifdef	DDR3_16_DQ
			.dqs        	({mcb3_dram_udqs,mcb3_dram_dqs}	),
		`elsif	DDR3_8_DQ
			.dqs        	(mcb3_dram_dqs					),
		`endif
		`ifdef	DDR3_16_DQ
			.dqs_n      	({mcb3_dram_udqs_n,mcb3_dram_dqs_n}),
		`elsif	DDR3_8_DQ
			.dqs_n      	(mcb3_dram_dqs_n				),
		`endif
		.tdqs_n     		(								),
		.odt        		(mcb3_dram_odt					),
		.rst_n      		(mcb3_dram_reset_n				)
		);
	`endif



	assign	ddr_cmd_int	= {mcb3_dram_ras_n,mcb3_dram_cas_n,mcb3_dram_we_n};
	always @ ( * ) begin
		case(ddr_cmd_int)
			3'b000 : begin
				DDR3_CMD	= "MRS";
			end
			3'b001 : begin
				DDR3_CMD	= "REF";
			end
			3'b010 : begin
				DDR3_CMD	= "PRE";
			end
			3'b011 : begin
				DDR3_CMD	= "ACT";
			end
			3'b100 : begin
				DDR3_CMD	= "WR";
			end
			3'b101 : begin
				DDR3_CMD	= "RD";
			end
			3'b110 : begin
				DDR3_CMD	= "ZQ";
			end
			3'b111 : begin
				DDR3_CMD	= "NOP";
			end
			default : begin

			end
		endcase
	end


	generate
		for(i = 0; i <= 7; i = i + 1) begin
			always @ (negedge mcb3_dram_reset_n or posedge mcb3_dram_ck) begin
				if(!mcb3_dram_reset_n) begin
					bank[i]	<= 1'b0;
					row[i]	<= 13'b0;
				end else begin
					if((DDR3_CMD == "ACT")&&(mcb3_dram_ba == i)) begin
						bank[i]	<= 1'b1;
						row[i]	<= mcb3_dram_a;
					end else if((DDR3_CMD == "PRE")&&(mcb3_dram_a[10] == 1'b0)&&(mcb3_dram_ba == i)) begin
						bank[i]	<= 1'b0;
					end else if((DDR3_CMD == "PRE")&&(mcb3_dram_a[10] == 1'b1)) begin
						bank[i]	<= 1'b0;
					end
				end
			end
		end
	endgenerate

	always @ (negedge mcb3_dram_reset_n or posedge mcb3_dram_ck) begin
		if(!mcb3_dram_reset_n) begin
			rd_wr_cmd	<= "N";
		end else begin
			if(DDR3_CMD == "RD") begin
				rd_wr_cmd	<= "R";
			end else if(DDR3_CMD == "WR") begin
				rd_wr_cmd	<= "W";
			end else if(DDR3_CMD == "PRE") begin
				rd_wr_cmd	<= "N";
			end else if(DDR3_CMD == "ACT") begin
				rd_wr_cmd	<= "A";
			end
		end
	end

	always @ (negedge mcb3_dram_reset_n or posedge mcb3_dram_ck) begin
		if(!mcb3_dram_reset_n) begin
			current_wr_bank_addr	<= 3'b0;
		end else begin
			if(DDR3_CMD == "WR") begin
				current_wr_bank_addr	<= mcb3_dram_ba;
			end
		end
	end

	always @ (negedge mcb3_dram_reset_n or posedge mcb3_dram_ck) begin
		if(!mcb3_dram_reset_n) begin
			current_wr_row_addr	<= 13'b0;
		end else begin
			if(DDR3_CMD == "WR") begin
				current_wr_row_addr	<= row[mcb3_dram_ba];
			end
		end
	end

	always @ (negedge mcb3_dram_reset_n or posedge mcb3_dram_ck) begin
		if(!mcb3_dram_reset_n) begin
			current_rd_bank_addr	<= 3'b0;
		end else begin
			if(DDR3_CMD == "RD") begin
				current_rd_bank_addr	<= mcb3_dram_ba;
			end
		end
	end

	always @ (negedge mcb3_dram_reset_n or posedge mcb3_dram_ck) begin
		if(!mcb3_dram_reset_n) begin
			current_rd_row_addr	<= 13'b0;
		end else begin
			if(DDR3_CMD == "RD") begin
				current_rd_row_addr	<= row[mcb3_dram_ba];
			end
		end
	end





	//  ===============================================================================================
	//	ref 时钟信号
	//  ===============================================================================================
	always # 12.5	clk_osc	= ~clk_osc;


	//  ===============================================================================================
	//	ref 仿真时间控制
	//  ===============================================================================================
	initial begin
		#100
		@(posedge top_frame_buffer_inst.wv_image_dout[32])
		#100
		@(posedge top_frame_buffer_inst.wv_image_dout[32])
		#1000
		$stop;
	end


endmodule
