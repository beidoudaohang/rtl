//-------------------------------------------------------------------------------------------------
//  -- 版权所有者   : 中国大恒（集团）有限公司北京图像视觉技术分公司, 2010 -2015.
//  -- 保密级别     ：绝密.
//  -- 部门         : 硬件部，FPGA工作组
//  -- 模块名       : tb_example
//  -- 设计者       : 邢海涛
//-------------------------------------------------------------------------------------------------
//
//  -- 版本记录 :
//
//  -- 作者         :| 修改日期				:|  修改说明
//-------------------------------------------------------------------------------------------------
//  -- 邢海涛       :| 2014/5/20 15:40:35	:|  初始版本
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
`include			"testbench_def.v"
//仿真单位/精度
`timescale 1ns/1ps
//-------------------------------------------------------------------------------------------------

module tb_example ();

	//	ref signals

	wire	[`NUM_DQ_PINS-1:0]			mcb3_dram_dq;
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

	reg									sys_rst = 1'b0;
	reg									sys_clk = 1'b0;
	wire								o_test_out	;
	wire	[4:0]						ov_fpga_sw	;
	wire	[4:0]						ov_fpga_led	;


	integer								file_frame_log = 0;
	integer								file_wr_data_log = 0;
	integer								file_rd_data_log = 0;

	wire								rst_pattern;


	reg									frame_en_d = 1'b0;
	reg									frame_en_chk = 1'b0;

	reg		[23:0]						DDR3_CMD;
	reg		[7:0]						rd_wr_cmd;
	wire	[2:0]						ddr_cmd_int;

	reg									bank [7:0];
	reg		[12:0]						row [7:0];
	genvar								i;

	//	ref ARCHITECTURE
	top_frame_buffer top_frame_buffer_inst (
	.o_test_out			(o_test_out			),
	.sys_clk			(sys_clk			),
	.sys_rst			(sys_rst			),
	.mcb3_dram_dq		(mcb3_dram_dq		),
	.mcb3_dram_a		(mcb3_dram_a		),
	.mcb3_dram_ba		(mcb3_dram_ba		),
	.mcb3_dram_ras_n	(mcb3_dram_ras_n	),
	.mcb3_dram_cas_n	(mcb3_dram_cas_n	),
	.mcb3_dram_we_n		(mcb3_dram_we_n		),
	.mcb3_dram_odt		(mcb3_dram_odt		),
	.mcb3_dram_reset_n	(mcb3_dram_reset_n	),
	.mcb3_dram_cke		(mcb3_dram_cke		),
	.mcb3_dram_dm		(mcb3_dram_dm		),
	.mcb3_dram_udqs		(mcb3_dram_udqs		),
	.mcb3_dram_udqs_n	(mcb3_dram_udqs_n	),
	.mcb3_rzq			(mcb3_rzq			),
	.mcb3_zio			(mcb3_zio			),
	.mcb3_dram_udm		(mcb3_dram_udm		),
	.mcb3_dram_dqs		(mcb3_dram_dqs		),
	.mcb3_dram_dqs_n	(mcb3_dram_dqs_n	),
	.mcb3_dram_ck		(mcb3_dram_ck		),
	.mcb3_dram_ck_n		(mcb3_dram_ck_n		),
	.ov_fpga_sw			(ov_fpga_sw			),
	.ov_fpga_led		(ov_fpga_led		)
	);


	//  -------------------------------------------------------------------------------------
	//  DDR3 MODEL
	//  -------------------------------------------------------------------------------------
	PULLDOWN zio_pulldown3 (.O(zio3));   PULLDOWN rzq_pulldown3 (.O(rzq3));

	ddr3_model_c3 ddr3_model_c3_inst (
	.ck         		(mcb3_dram_ck),
	.ck_n       		(mcb3_dram_ck_n),
	.cke        		(mcb3_dram_cke),
	.cs_n       		(1'b0),
	.ras_n      		(mcb3_dram_ras_n),
	.cas_n      		(mcb3_dram_cas_n),
	.we_n       		(mcb3_dram_we_n),
	.dm_tdqs    		({mcb3_dram_udm,mcb3_dram_dm}),
	.ba         		(mcb3_dram_ba),
	.addr       		(mcb3_dram_a),
	.dq         		(mcb3_dram_dq),
	.dqs        		({mcb3_dram_udqs,mcb3_dram_dqs}),
	.dqs_n      		({mcb3_dram_udqs_n,mcb3_dram_dqs_n}),
	.tdqs_n     		(),
	.odt        		(mcb3_dram_odt),
	.rst_n      		(mcb3_dram_reset_n)
	);

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
				end
				else begin
					if((DDR3_CMD == "ACT")&&(mcb3_dram_ba == i)) begin
						bank[i]	<= 1'b1;
						row[i]	<= mcb3_dram_a;
					end
					else if((DDR3_CMD == "PRE")&&(mcb3_dram_a[10] == 1'b0)&&(mcb3_dram_ba == i)) begin
						bank[i]	<= 1'b0;
					end
					else if((DDR3_CMD == "PRE")&&(mcb3_dram_a[10] == 1'b1)) begin
						bank[i]	<= 1'b0;
					end
				end
			end
		end
	endgenerate

	always @ (negedge mcb3_dram_reset_n or posedge mcb3_dram_ck) begin
		if(!mcb3_dram_reset_n) begin
			rd_wr_cmd	<= "N";
		end
		else begin
			if(DDR3_CMD == "RD") begin
				rd_wr_cmd	<= "R";
			end
			else if(DDR3_CMD == "WR") begin
				rd_wr_cmd	<= "W";
			end
			else if(DDR3_CMD == "PRE") begin
				rd_wr_cmd	<= "N";
			end
		end
	end




	//  ===============================================================================================
	//	ref 复位信号
	//  ===============================================================================================
	//产生复位和时钟信号
	`ifdef	SIM_CHANGE_RST
		initial begin
			sys_rst = 1'b1;
			#200
			sys_rst = 1'b0;
			#504100
			sys_rst = 1'b1;
			#1000000
			sys_rst = 1'b0;
		end
	`else
		initial begin
			sys_rst = 1'b1;
			#200
			sys_rst = 1'b0;
		end
	`endif




	//  ===============================================================================================
	//	ref 时钟信号
	//  ===============================================================================================
	always # 12.5 						sys_clk 		= ~sys_clk;


//	initial begin
//		$dumpfile("test.vcd");						//打开一个VCD数据库用于记录
//		$dumpvars(1,top_frame_buffer_inst);		//选择要记录的信号
//	end






endmodule
