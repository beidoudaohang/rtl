`timescale 100ps/100ps
module hispi_hdr_stim #(
parameter c_PER_LANE_WIDTH = 10,
parameter c_WORD_WIDTH = 20,
parameter c_LANE_WIDTH = 4
)
(
 input [11:0] vd_active_width,
 input [11:0] vd_blank_width,
 input [11:0] vd_active_height,
 input [11:0] vd_blank_height,
 input  ail_msb_1st,
 input  rstn,
 input  sclk,
 output reg sclk_o,
 output reg [3:0] sdata_o
);
//  c_HDR_MODE_0 => c_WORD_WIDTH==20; c_LANE_WIDTH==4; c_PER_LANE_WIDTH==10
//  c_HDR_MODE_1 => c_WORD_WIDTH==14; c_LANE_WIDTH==3; c_PER_LANE_WIDTH==10
//  c_HDR_MODE_2 => c_WORD_WIDTH==12; c_LANE_WIDTH==3; c_PER_LANE_WIDTH==10
//  c_HDR_MODE_3 => c_WORD_WIDTH==14; c_LANE_WIDTH==2; c_PER_LANE_WIDTH==14
//  c_HDR_MODE_4 => c_WORD_WIDTH==12; c_LANE_WIDTH==2; c_PER_LANE_WIDTH==12

reg wd_clk;
reg [4:0] clk_cnt;
reg [11:0] wd_cnt;
reg hor_valid;
reg lin_valid;
reg [11:0] lin_cnt;
wire [c_WORD_WIDTH-1:0] data_idle;
reg [c_WORD_WIDTH-1:0] pdata;
reg pdata_valid;
reg [20-1:0] data_pattern;
reg [c_WORD_WIDTH-1:0] data_lane0;
reg [c_WORD_WIDTH-1:0] data_lane1;
reg [c_WORD_WIDTH-1:0] data_lane2;
reg [c_WORD_WIDTH-1:0] data_lane3;
reg [c_WORD_WIDTH-1:0] data_lane0_d;
reg [c_WORD_WIDTH-1:0] data_lane1_d;
reg [c_WORD_WIDTH-1:0] data_lane2_d;
reg [c_WORD_WIDTH-1:0] data_lane3_d;
reg pidle;


   

always @(posedge sclk or negedge rstn)
   if (!rstn) begin
      clk_cnt <= 0;
      wd_clk <= 1'b0;
   end
   else begin
      if (clk_cnt == c_PER_LANE_WIDTH - 1) begin
         clk_cnt <= 0;
         wd_clk <= 1'b0;
      end   
      else begin
         clk_cnt <= clk_cnt + 1;
         if (clk_cnt == 3) wd_clk <= 1'b1;
      end
   end
//*************************************************************************************************************************************************************
assign data_idle = {c_WORD_WIDTH{1'b1}};

always @(posedge wd_clk or negedge rstn)
   if (!rstn) begin
      wd_cnt   <= 1;
      hor_valid <= 0;
      lin_valid <= 0;
      lin_cnt   <= 0;
   end
   else begin
      wd_cnt <= 1;
      if (hor_valid) begin
         if (wd_cnt == vd_active_width) begin
            hor_valid <= 1'b0;
            wd_cnt <= 1;
         end
         else
            wd_cnt <= wd_cnt + 1;
      end
      else begin
         if (wd_cnt == vd_blank_width) begin
            hor_valid <= 1'b1;
            wd_cnt <= 1;
         end
         else
            wd_cnt <= wd_cnt + 1;
      end      
      
      if ((~ hor_valid) && (wd_cnt == vd_blank_width)) begin
         if (lin_valid) begin
            if (lin_cnt == vd_active_height) begin
               lin_valid <= 1'b0;
               lin_cnt   <= 1;
            end
            else
               lin_cnt   <= lin_cnt + 1;
         end
         else begin
            if (lin_cnt == vd_blank_height) begin
               lin_valid <= 1'b1;
               lin_cnt   <= 1;
            end
            else
               lin_cnt   <= lin_cnt + 1;
         end
      end
   end

wire embeded_data = 1'b0;
always @(*) begin
   pdata = 0;
   pidle = 0;
   pdata_valid = 0;
   //*************************************************************************************************************************
   if (lin_valid) begin
      if (hor_valid) begin
         case (wd_cnt)
            1:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b1}} ;end
            2:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
            3:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
            4:       begin pdata_valid = 1'b0; pdata[4:0] = (lin_cnt == 1) ? 5'b00011 : 5'b00001; end
            default: begin pdata_valid = 1'b1; pdata = 5; end
         endcase
      end
      else begin
         case (wd_cnt)
            1:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b1}} ; end
            2:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ; end
            3:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ; end
            4:       begin pdata_valid = 1'b0; pdata[4:0] = (lin_cnt == vd_active_height) ? 5'b00111 : 5'b00101; end
            default: begin pdata_valid = 1'b0; pdata = data_idle; end
         endcase         
      end
   end
   else begin
      pdata_valid = 1'b0;
      pdata       = data_idle;
   end
   //*************************************************************************************************************************
end

always @(posedge wd_clk or negedge rstn)
   if (!rstn) begin
      data_pattern <= 0;
   end
   else begin
      if (lin_valid) begin
         if (pdata_valid)
            data_pattern <= data_pattern + 2;
      end
      else
         data_pattern <= 0;
   end

wire [20-1:0] data_pattern_pix_n        = data_pattern;
wire [20-1:0] data_pattern_pix_n_Plus_1 = {data_pattern[20-1:1], 1'b1};
reg [14-1:0] data_pattern_lane_0;
reg [14-1:0] data_pattern_lane_1;
reg [14-1:0] data_pattern_lane_2;
reg [14-1:0] data_pattern_lane_3;

always @(*) begin
   data_pattern_lane_0 = 0;
   data_pattern_lane_1 = 0;
   data_pattern_lane_2 = 0;
   data_pattern_lane_3 = 0;
   
   if ((c_WORD_WIDTH == 20) && (c_LANE_WIDTH == 4)) begin
      data_pattern_lane_0 = {data_pattern_pix_n[19], data_pattern_pix_n[17], data_pattern_pix_n[15], data_pattern_pix_n[13], data_pattern_pix_n[11],
                             data_pattern_pix_n[9],  data_pattern_pix_n[7],  data_pattern_pix_n[5],  data_pattern_pix_n[3],  data_pattern_pix_n[1]};
      data_pattern_lane_1 = {data_pattern_pix_n[18], data_pattern_pix_n[16], data_pattern_pix_n[14], data_pattern_pix_n[12], data_pattern_pix_n[10],
                             data_pattern_pix_n[8],  data_pattern_pix_n[6],  data_pattern_pix_n[4],  data_pattern_pix_n[2],  data_pattern_pix_n[0]};
      data_pattern_lane_2 = {data_pattern_pix_n_Plus_1[19], data_pattern_pix_n_Plus_1[17], data_pattern_pix_n_Plus_1[15], data_pattern_pix_n_Plus_1[13], data_pattern_pix_n_Plus_1[11],
                             data_pattern_pix_n_Plus_1[9],  data_pattern_pix_n_Plus_1[7],  data_pattern_pix_n_Plus_1[5],  data_pattern_pix_n_Plus_1[3],  data_pattern_pix_n_Plus_1[1]};
      data_pattern_lane_3 = {data_pattern_pix_n_Plus_1[18], data_pattern_pix_n_Plus_1[16], data_pattern_pix_n_Plus_1[14], data_pattern_pix_n_Plus_1[12], data_pattern_pix_n_Plus_1[10],
                             data_pattern_pix_n_Plus_1[8],  data_pattern_pix_n_Plus_1[6],  data_pattern_pix_n_Plus_1[4],  data_pattern_pix_n_Plus_1[2],  data_pattern_pix_n_Plus_1[0]};                             
   end
   else if ((c_WORD_WIDTH == 14) && (c_LANE_WIDTH == 3)) begin
      data_pattern_lane_0 = {data_pattern_pix_n[13:5], 1'b1};
      data_pattern_lane_1 = {data_pattern_pix_n_Plus_1[13:5], 1'b1};
      data_pattern_lane_2 = {data_pattern_pix_n_Plus_1[4:0], data_pattern_pix_n[4:0]};
   end
   else if ((c_WORD_WIDTH == 12) && (c_LANE_WIDTH == 3)) begin
      data_pattern_lane_0 = {data_pattern_pix_n[11:4], 2'b01};
      data_pattern_lane_1 = {data_pattern_pix_n_Plus_1[11:4], 2'b01};
      data_pattern_lane_2 = {data_pattern_pix_n_Plus_1[3:0], data_pattern_pix_n[3:0], 2'b01};
   end
   else begin
      data_pattern_lane_0 = data_pattern_pix_n;
      data_pattern_lane_1 = data_pattern_pix_n_Plus_1;
   end
end

wire [13:0] data_pattern_lane_0_tmp; 
wire [13:0] data_pattern_lane_1_tmp;
wire [13:0] data_pattern_lane_2_tmp;
wire [13:0] data_pattern_lane_3_tmp;

ail_reorder #(.c_PER_LANE_WIDTH (c_PER_LANE_WIDTH))
I0_ail_reorder (.data_pattern (data_pattern_lane_0), .ail_msb_1st (ail_msb_1st), .data_pattern_reorder(data_pattern_lane_0_tmp));
ail_reorder #(.c_PER_LANE_WIDTH (c_PER_LANE_WIDTH))
I1_ail_reorder (.data_pattern (data_pattern_lane_1), .ail_msb_1st (ail_msb_1st), .data_pattern_reorder(data_pattern_lane_1_tmp));
ail_reorder #(.c_PER_LANE_WIDTH (c_PER_LANE_WIDTH))
I2_ail_reorder (.data_pattern (data_pattern_lane_2), .ail_msb_1st (ail_msb_1st), .data_pattern_reorder(data_pattern_lane_2_tmp));
ail_reorder #(.c_PER_LANE_WIDTH (c_PER_LANE_WIDTH))
I3_ail_reorder (.data_pattern (data_pattern_lane_3), .ail_msb_1st (ail_msb_1st), .data_pattern_reorder(data_pattern_lane_3_tmp));

always @(posedge wd_clk or negedge rstn)
   if (!rstn) begin
      data_lane0 <= 0;
      data_lane1 <= 0;
      data_lane2 <= 0;
      data_lane3 <= 0;
   end
   else begin
      if (pdata_valid) begin
         data_lane0 <= (data_pattern_lane_0_tmp == 0) ? 1 : data_pattern_lane_0_tmp;
         data_lane1 <= (data_pattern_lane_1_tmp == 0) ? 1 : data_pattern_lane_1_tmp;
         data_lane2 <= (data_pattern_lane_2_tmp == 0) ? 1 : data_pattern_lane_2_tmp;
         data_lane3 <= (data_pattern_lane_3_tmp == 0) ? 1 : data_pattern_lane_3_tmp;
      end
      else begin
         data_lane0 <= pdata;         
         data_lane1 <= pdata;         
         data_lane2 <= pdata;         
         data_lane3 <= pdata;         
      end
   end
//*************************************************************************************************************************   
always @(posedge sclk or negedge rstn)
   if (!rstn) begin
      data_lane0_d <= 0;
      data_lane1_d <= 0;
      data_lane2_d <= 0;
      data_lane3_d <= 0;

   end
   else begin
      if (clk_cnt == 4) begin
         data_lane0_d <= data_lane0;
         data_lane1_d <= data_lane1;
         data_lane2_d <= data_lane2;
         data_lane3_d <= data_lane3;
      end
      else begin
         data_lane0_d <= {1'b0, data_lane0_d[c_WORD_WIDTH-1:1]};       
         data_lane1_d <= {1'b0, data_lane1_d[c_WORD_WIDTH-1:1]};       
         data_lane2_d <= {1'b0, data_lane2_d[c_WORD_WIDTH-1:1]};       
         data_lane3_d <= {1'b0, data_lane3_d[c_WORD_WIDTH-1:1]};       
      end
   end

wire [3:0] sdata_o_pre = {data_lane3_d[0], data_lane2_d[0], data_lane1_d[0], data_lane0_d[0]};
wire [1:0] sel_0 = 0;         
wire [1:0] sel_1 = 0;         
wire [1:0] sel_2 = 0;         
wire [1:0] sel_3 = 0;         
reg  [3:0] sdata_o_pre_d1;
reg  [3:0] sdata_o_pre_d2;
reg  [3:0] sdata_o_pre_d3;

always @(posedge sclk or negedge rstn)
   if (!rstn) begin
      sdata_o_pre_d1 <= 0;
      sdata_o_pre_d2 <= 0;
      sdata_o_pre_d3 <= 0;
   end
   else begin
      sdata_o_pre_d1 <= sdata_o_pre;
      sdata_o_pre_d2 <= sdata_o_pre_d1;
      sdata_o_pre_d3 <= sdata_o_pre_d2;
   end

always @(*) begin
   case (sel_0)
      2'd0: sdata_o[0] = sdata_o_pre[0];
      2'd1: sdata_o[0] = sdata_o_pre_d1[0];
      2'd2: sdata_o[0] = sdata_o_pre_d2[0];
      2'd3: sdata_o[0] = sdata_o_pre_d3[0];
   endcase
end
always @(*) begin
   case (sel_1)
      2'd0: sdata_o[1] = sdata_o_pre[1];
      2'd1: sdata_o[1] = sdata_o_pre_d1[1];
      2'd2: sdata_o[1] = sdata_o_pre_d2[1];
      2'd3: sdata_o[1] = sdata_o_pre_d3[1];
   endcase
end
always @(*) begin
   case (sel_2)
      2'd0: sdata_o[2] = sdata_o_pre[2];
      2'd1: sdata_o[2] = sdata_o_pre_d1[2];
      2'd2: sdata_o[2] = sdata_o_pre_d2[2];
      2'd3: sdata_o[2] = sdata_o_pre_d3[2];
   endcase
end
always @(*) begin
   case (sel_3)
      2'd0: sdata_o[3] = sdata_o_pre[3];
      2'd1: sdata_o[3] = sdata_o_pre_d1[3];
      2'd2: sdata_o[3] = sdata_o_pre_d2[3];
      2'd3: sdata_o[3] = sdata_o_pre_d3[3];
   endcase
end

//assign sdata_o[0] = data_lane0_d[0];
//assign sdata_o[1] = data_lane1_d[0];
//assign sdata_o[2] = data_lane2_d[0];
//assign sdata_o[3] = data_lane3_d[0];
//assign #1 sclk_o = sclk;
always @(negedge sclk or negedge rstn)
   if (!rstn) begin
      sclk_o       <= 0;   
   end
   else begin
      sclk_o       <= ~ sclk_o;   
   end
endmodule

module ail_reorder #(
parameter c_PER_LANE_WIDTH = 10
)(
input [13:0] data_pattern,
input ail_msb_1st,
output [13:0] data_pattern_reorder
);

wire [13:0] data_pattern_shift  = (c_PER_LANE_WIDTH == 10) ? {data_pattern[9:0], 4'd0} : (
                                  (c_PER_LANE_WIDTH == 12) ? {data_pattern[11:0], 2'd0} : data_pattern);
wire [13:0] data_pattern_revert = {data_pattern_shift[0],  data_pattern_shift[1], data_pattern_shift[2],  data_pattern_shift[3],
                                   data_pattern_shift[4],  data_pattern_shift[5], data_pattern_shift[6],  data_pattern_shift[7],
                                   data_pattern_shift[8],  data_pattern_shift[9], data_pattern_shift[10], data_pattern_shift[11],
                                   data_pattern_shift[12], data_pattern_shift[13]};
assign data_pattern_reorder = ail_msb_1st ? data_pattern_revert : data_pattern;

endmodule                                   