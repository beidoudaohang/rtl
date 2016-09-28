//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : monitor_ddr3
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2015/4/3 15:12:55	:|  初始版本
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

module monitor_ddr3 ();

	//	ref signals
	wire	[harness.DRAM_DQ_WIRE_WIDTH-1:0]		mcb3_dram_dq		;
	wire	[harness.MEM_ADDR_WIDTH-1:0]			mcb3_dram_a			;
	wire	[harness.MEM_BANKADDR_WIDTH-1:0]		mcb3_dram_ba		;
	wire										mcb3_dram_ras_n		;
	wire										mcb3_dram_cas_n		;
	wire										mcb3_dram_we_n		;
	wire										mcb3_dram_odt		;
	wire										mcb3_dram_reset_n	;
	wire										mcb3_dram_cke		;
	wire										mcb3_dram_udm		;
	wire										mcb3_dram_dm		;
	wire										mcb3_dram_ck		;
	wire										mcb3_dram_ck_n		;
	wire										mcb3_dram_udqs		;
	wire										mcb3_dram_udqs_n	;
	wire										mcb3_dram_dqs		;
	wire										mcb3_dram_dqs_n		;
	wire										mcb3_rzq			;
	wire										mcb3_zio			;

	reg		[23:0]								DDR3_CMD			;
	reg		[7:0]								rd_wr_cmd			;
	wire	[2:0]								ddr_cmd_int			;
	reg											bank [7:0]			;
	reg		[12:0]								row [7:0]			;
	genvar										i					;
	reg		[12:0]								current_wr_row_addr	;
	reg		[2:0]								current_wr_bank_addr;
	reg		[12:0]								current_rd_row_addr	;
	reg		[2:0]								current_rd_bank_addr;



	//	ref ARCHITECTURE


	assign	mcb3_dram_dq		= harness.mcb3_dram_dq     ;
	assign	mcb3_dram_a         = harness.mcb3_dram_a      ;
	assign	mcb3_dram_ba        = harness.mcb3_dram_ba     ;
	assign	mcb3_dram_ras_n     = harness.mcb3_dram_ras_n  ;
	assign	mcb3_dram_cas_n     = harness.mcb3_dram_cas_n  ;
	assign	mcb3_dram_we_n      = harness.mcb3_dram_we_n   ;
	assign	mcb3_dram_odt       = harness.mcb3_dram_odt    ;
	assign	mcb3_dram_reset_n   = harness.mcb3_dram_reset_n;
	assign	mcb3_dram_cke       = harness.mcb3_dram_cke    ;
	assign	mcb3_dram_udm       = harness.mcb3_dram_udm    ;
	assign	mcb3_dram_dm        = harness.mcb3_dram_dm     ;
	assign	mcb3_dram_ck        = harness.mcb3_dram_ck     ;
	assign	mcb3_dram_ck_n      = harness.mcb3_dram_ck_n   ;
	assign	mcb3_dram_udqs      = harness.mcb3_dram_udqs   ;
	assign	mcb3_dram_udqs_n    = harness.mcb3_dram_udqs_n ;
	assign	mcb3_dram_dqs       = harness.mcb3_dram_dqs    ;
	assign	mcb3_dram_dqs_n     = harness.mcb3_dram_dqs_n  ;
	assign	mcb3_rzq            = harness.mcb3_rzq         ;
	assign	mcb3_zio            = harness.mcb3_zio         ;

	//	-------------------------------------------------------------------------------------
	//	DDR3 CMD
	//	-------------------------------------------------------------------------------------
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
				rd_wr_cmd	<= "P";
			end else if(DDR3_CMD == "ACT") begin
				rd_wr_cmd	<= "A";
			end else if(DDR3_CMD == "REF") begin
				rd_wr_cmd	<= "R";
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





endmodule
