`timescale 100ps/100ps
module hispi_stim #(
parameter c_HISPI_MODE = "Packetized-SP",//"Packetized-SP" or "Streaming-SP" or "Streaming-S" or "ActiveStart-SP8"
parameter c_WORD_WIDTH = 12,
parameter c_LANE_WIDTH = 4
)
(
 input [11:0] vd_active_width,
 input [11:0] vd_blank_width,
 input [11:0] vd_active_height,
 input [11:0] vd_blank_height,

 input  rstn,
 input  sclk,
 output reg sclk_o,
 output reg [3:0] sdata_o
);

reg pix_clk;
reg idle_sel;
reg [4:0] clk_cnt;
reg [11:0] pix_cnt;
reg hor_valid;
reg lin_valid;
reg [11:0] lin_cnt;
wire [c_WORD_WIDTH-1:0] data_idle;
reg [c_WORD_WIDTH-1:0] pdata;
reg pdata_valid;
reg [c_WORD_WIDTH-3:0] data_pattern;
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
      pix_clk <= 1'b0;
   end
   else begin
      if (clk_cnt == c_WORD_WIDTH - 1) begin
         clk_cnt <= 0;
         pix_clk <= 1'b0;
      end   
      else begin
         clk_cnt <= clk_cnt + 1;
         if (clk_cnt == 3) pix_clk <= 1'b1;
      end
   end
//*************************************************************************************************************************************************************
assign data_idle = (c_HISPI_MODE == "Streaming-S") ? (idle_sel ? {{(c_WORD_WIDTH-1){1'b0}}, 1'b1}: {{(c_WORD_WIDTH-1){1'b1}}, 1'b0}) : (
                   (c_HISPI_MODE == "ActiveStart-SP8") ? {c_WORD_WIDTH{1'b0}} : {c_WORD_WIDTH{1'b1}});
always @(posedge pix_clk or negedge rstn)
   if (!rstn) begin
      idle_sel <= 1'b0;
   end
   else begin
      if (pidle)
         idle_sel <= ~ idle_sel;
      else
         idle_sel <= 1'b0;
   end


always @(posedge pix_clk or negedge rstn)
   if (!rstn) begin
      pix_cnt   <= 1;
      hor_valid <= 0;
      lin_valid <= 0;
      lin_cnt   <= 0;
   end
   else begin
      pix_cnt <= 1;
      if (hor_valid) begin
         if (pix_cnt == vd_active_width) begin
            hor_valid <= 1'b0;
            pix_cnt <= 1;
         end
         else
            pix_cnt <= pix_cnt + 1;
      end
      else begin
         if (pix_cnt == vd_blank_width) begin
            hor_valid <= 1'b1;
            pix_cnt <= 1;
         end
         else
            pix_cnt <= pix_cnt + 1;
      end      
      
      if ((~ hor_valid) && (pix_cnt == vd_blank_width)) begin
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
   
always @(*) begin
   pdata = 0;
   pidle = 0;
   pdata_valid = 0;
   if (c_HISPI_MODE == "Packetized-SP") begin
      //*************************************************************************************************************************
      if (lin_valid) begin
         if (hor_valid) begin
            case (pix_cnt)
               1:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b1}} ;end
               2:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
               3:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
               4:       begin pdata_valid = 1'b0; pdata[4:0] = (lin_cnt == 1) ? 5'b00011 : 5'b00001; end
               default: begin pdata_valid = 1'b1; pdata = 5; end
            endcase
         end
         else begin
            case (pix_cnt)
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
   else if (c_HISPI_MODE == "Streaming-SP") begin
      //*************************************************************************************************************************
      if (lin_valid) begin
         if (hor_valid) begin
            case (pix_cnt)
               1:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b1}} ;end
               2:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
               3:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
               4:       begin pdata_valid = 1'b0; pdata[4:0] = (lin_cnt == 1) ? 5'b00011 : 5'b00001; end
               default: begin pdata_valid = 1'b1; pdata = 5; end
            endcase
         end
         else begin
            pdata_valid = 1'b0;
            pdata       = data_idle;         
         end
      end
      else begin
         if (hor_valid) begin
            case (pix_cnt)
               1:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b1}} ;end
               2:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
               3:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
               4:       begin pdata_valid = 1'b0; pdata[4:0] = 5'b01001; end
               default: begin pdata_valid = 1'b1; pdata = 5; end
            endcase
         end
         else begin
            pdata_valid = 1'b0;
            pdata       = data_idle;         
         end
      end
      //*************************************************************************************************************************
   end
   else if ((c_HISPI_MODE == "Streaming-S") && (c_LANE_WIDTH == 4)) begin
      //*************************************************************************************************************************
      if (lin_valid) begin
         if (hor_valid) begin
            case (pix_cnt)
               1:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b1}} ;end
//               2:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
//               3:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
//               4:       begin pdata_valid = 1'b0; pdata[4:0] = 5'b00001; end
               default: begin pdata_valid = 1'b1; pdata = 5; end
            endcase
         end
         else begin
            pdata_valid = 1'b0;
            pdata       = data_idle;
            pidle       = 1'b1;         
         end
      end
      else begin
         if (hor_valid) begin
            case (pix_cnt)
               1:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b1}} ;end
//               2:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
//               3:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
//               4:       begin pdata_valid = 1'b0; pdata[4:0] = 5'b01001; end
               default: begin 
                  pdata_valid = 1'b0;
                  pdata       = data_idle;         
                  pidle       = 1'b1;               
               end   
            endcase
         end
         else begin
            pdata_valid = 1'b0;
            pdata       = data_idle;         
            pidle       = 1'b1;
         end
      end      
      //*************************************************************************************************************************
   end
   else if ((c_HISPI_MODE == "Streaming-S") && (c_LANE_WIDTH == 2)) begin
      //*************************************************************************************************************************
      if (lin_valid) begin
         if (hor_valid) begin
            case (pix_cnt)
               1:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b1}} ;end
               2:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
//               3:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
//               4:       begin pdata_valid = 1'b0; pdata[4:0] = 5'b00001; end
               default: begin pdata_valid = 1'b1; pdata = 5; end
            endcase
         end
         else begin
            pdata_valid = 1'b0;
            pdata       = data_idle;
            pidle       = 1'b1;         
         end
      end
      else begin
         if (hor_valid) begin
            case (pix_cnt)
               1:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b1}} ;end
               2:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
//               3:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
//               4:       begin pdata_valid = 1'b0; pdata[4:0] = 5'b01001; end
               default: begin pdata_valid = 1'b1; pdata = 5; end
            endcase
         end
         else begin
            pdata_valid = 1'b0;
            pdata       = data_idle;
            pidle       = 1'b1;         
         end
      end            
      //*************************************************************************************************************************
      //*************************************************************************************************************************
   end
   else if ((c_HISPI_MODE == "Streaming-S") && (c_LANE_WIDTH == 1)) begin
      //*************************************************************************************************************************
      if (lin_valid) begin
         if (hor_valid) begin
            case (pix_cnt)
               1:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b1}} ;end
               2:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
               3:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
               4:       begin pdata_valid = 1'b0; pdata[4:0] = 5'b00001; end
               default: begin pdata_valid = 1'b1; pdata = 5; end
            endcase
         end
         else begin
            pdata_valid = 1'b0;
            pdata       = data_idle;
            pidle       = 1'b1;         
         end
      end
      else begin
         if (hor_valid) begin
            case (pix_cnt)
               1:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b1}} ;end
               2:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
               3:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
               4:       begin pdata_valid = 1'b0; pdata[4:0] = 5'b01001; end
               default: begin pdata_valid = 1'b1; pdata = 5; end
            endcase
         end
         else begin
            pdata_valid = 1'b0;
            pdata       = data_idle;
            pidle       = 1'b1;         
         end
      end            
      //*************************************************************************************************************************      
   end
   else if (c_HISPI_MODE == "ActiveStart-SP8") begin
      //*************************************************************************************************************************
      if (lin_valid) begin
         if (hor_valid) begin
            case (pix_cnt)
               1:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b1}} ;end
               2:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
               3:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b1}} ;end
               4:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b0}} ;end
               5:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b1}} ;end
               6:       begin pdata_valid = 1'b0; pdata = (lin_cnt == 1) ? {c_WORD_WIDTH{1'b1}} : {c_WORD_WIDTH{1'b0}} ;end
               7:       begin pdata_valid = 1'b0; pdata = {c_WORD_WIDTH{1'b1}} ;end
               8:       begin pdata_valid = 1'b0; pdata = (lin_cnt == 1) ? {c_WORD_WIDTH{1'b1}} : {c_WORD_WIDTH{1'b0}} ;end               
               default: begin pdata_valid = 1'b1; pdata = 5; end
            endcase
         end
         else begin
            pdata_valid = 1'b0;
            pdata       = data_idle;
            pidle       = 1'b1;         
         end
      end
      else begin
        pdata_valid = 1'b0;
        pdata       = data_idle;
        pidle       = 1'b1;         
      end
      //*************************************************************************************************************************
   end
end

wire [c_WORD_WIDTH-3:0] data_pattern_tmp = (& data_pattern) ? {data_pattern[c_WORD_WIDTH-3:1], 1'b0} : ((| data_pattern) ? data_pattern : {data_pattern[c_WORD_WIDTH-3:1], 1'b1});
always @(posedge pix_clk or negedge rstn)
   if (!rstn) begin
      data_pattern <= 0;
   end
   else begin
      if (lin_valid) begin
         if (pdata_valid)
            data_pattern <= data_pattern + 1;
      end
      else
         data_pattern <= 0;
   end
   
always @(posedge pix_clk or negedge rstn)
   if (!rstn) begin
      data_lane0 <= 0;
      data_lane1 <= 0;
      data_lane2 <= 0;
      data_lane3 <= 0;
   end
   else begin
      if (pdata_valid) begin
         data_lane0 <= {data_pattern_tmp, 2'b00};
         data_lane1 <= {data_pattern_tmp, 2'b01};
         data_lane2 <= {data_pattern_tmp, 2'b10};
         data_lane3 <= {data_pattern_tmp, 2'b11};
      end   
      else begin
         if ((c_HISPI_MODE == "Streaming-S") && (c_LANE_WIDTH == 4)) begin
            if (pdata == {c_WORD_WIDTH{1'b1}}) begin
               data_lane0 <= {c_WORD_WIDTH{1'b1}} ;
               data_lane1 <= {c_WORD_WIDTH{1'b0}} ;
               data_lane2 <= {c_WORD_WIDTH{1'b0}};
               data_lane3 <= lin_valid ? {{(c_WORD_WIDTH-5){1'b0}}, 5'b00001} : {{(c_WORD_WIDTH-5){1'b0}}, 5'b01001};
            end
            else begin
               data_lane0 <= pdata;            
               data_lane1 <= pdata;            
               data_lane2 <= pdata;            
               data_lane3 <= pdata;            
            end
         end
         else if ((c_HISPI_MODE == "Streaming-S") && (c_LANE_WIDTH == 2)) begin
            if (pdata == {c_WORD_WIDTH{1'b1}}) begin
               data_lane0 <= {c_WORD_WIDTH{1'b1}} ;
               data_lane1 <= {c_WORD_WIDTH{1'b0}} ;
               data_lane2 <= {c_WORD_WIDTH{1'b0}};
               data_lane3 <= lin_valid ? {{(c_WORD_WIDTH-5){1'b0}}, 5'b00001} : {{(c_WORD_WIDTH-5){1'b0}}, 5'b01001};
            end
            else if (pdata == {c_WORD_WIDTH{1'b0}}) begin
               data_lane0 <= {c_WORD_WIDTH{1'b0}} ;
               data_lane1 <= lin_valid ? {{(c_WORD_WIDTH-5){1'b0}}, 5'b00001} : {{(c_WORD_WIDTH-5){1'b0}}, 5'b01001} ;
               data_lane2 <= {c_WORD_WIDTH{1'b0}};
               data_lane3 <= lin_valid ? {{(c_WORD_WIDTH-5){1'b0}}, 5'b00001} : {{(c_WORD_WIDTH-5){1'b0}}, 5'b01001};            
            end
            else begin
               data_lane0 <= pdata;            
               data_lane1 <= pdata;            
               data_lane2 <= pdata;            
               data_lane3 <= pdata;            
            end         
         end
         else begin
            data_lane0 <= pdata;         
            data_lane1 <= pdata;         
            data_lane2 <= pdata;         
            data_lane3 <= pdata;         
         end   
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