//************************************************************************************************/
//**                                                                                            **/
//**                                                                                            **/
//**                                                                                            **/
//**                                                                                            **/
//**                                                                                            **/
//**                                                                                            **/
//**                                                                                            **/
//**                                                                                            **/
//**                                    SANYO Semiconductor Co., Ltd.                           **/
//**                                       1-1, Sakata, Oizumi, Gunma, 370-0596 JAPAN           **/
//************************************************************************************************/
//**                                                                                            **/
//**   LE2416RLB  16K bit I2C EEPROM (VDD = 1.7V to 3.6V)                                      	**/
//**                                                                                            **/
//**   File Name        : LE2416RLB.v                                                          	**/
//**   Top Module       : LE2416RLB                                                            	**/
//**                                                                                            **/
//**    Feature         :                                                                       **/
//**                            Capacity                        16Kbit(2K x 8bit)               **/
//**                            Serial interface                I2C 				**/
//**                            Clock frequency                 400KHz                          **/
//**                            Automatic page write mode       16 Bytes                        **/
//************************************************************************************************/
//**    Notese:                                                                                 **/
//**    If you set up Initail data for EEPROM, you run Verilog_Simulation under condition.      **/
//**            " verilog xxxxx.v +define+INITIAL_DAT_MODE "                                	**/
//**                    Initial data(EEP ROM data) file is  "Init_data_eep.hex".                **/
//**                                                                                            **/
//************************************************************************************************/
//**                                                                                            **/
//**            ______________                                                                  **/
//**    NC   ==|1 @          8|== VDD                                                           **/
//**    NC   ==|2            7|== WP(Pull up)                                                  	**/
//**    NC   ==|3            6|== SCL                                                           **/
//**    GND  ==|4____________5|== SDA                                                           **/
//**                                                                                            **/
//**                                                                                            **/
//**   inout                SDA         :serial data input/output                               **/
//**   input                SCL         :serial data clock                                      **/
//**   input                WP          :write protect(1 or Z -->protect)                       **/
//**                                                                                            **/
//************************************************************************************************/
//**                                                                                            **/
//**   Revision         : 2.00                                                                  **/
//**   Release          : 18/Jan/2011                                                           **/
//**   Modified Date    : 18/Jan/2011                                                           **/
//**   Revision History :                                                                       **/
//**                                                                                            **/
//**   18/Jan/2011(Rev2.00)  :  renewal from Rev1.30 						**/
//**                                                                                            **/
//**                                                                                            **/
//**                                                                                            **/
//**                                                                                            **/
//**                                                                                            **/
//************************************************************************************************/
//**  LOGIC                                                                                     **/
//************************************************************************************************/
// **   L.01:  START Bit Detection								**/
// **   L.02:  STOP Bit Detection								**/
// **   L.03:  Input Shift Register								**/
// **   L.04:  Input Bit Counter								**/
// **   L.05:  Byte Cycle1 Register								**/
// **   L.06:  Address Setup									**/
// **   L.07:  Write Data Buffer								**/
// **   L.08:  Acknowledge Generator(Output)							**/
// **   L.09:  Acknowledge Detect								**/
// **   L.10:  Write Cycle Timer								**/
// **   L.11:  Write Cycle Processor								**/
// **   L.12:  Read Data									**/
// **   L.13:  Output Data									**/
// **   L.14:  SDA Data I/O Buffer (Open Drain)							**/
//**                                                                                            **/
//************************************************************************************************/
//**   TIMING CHECKS                                                                            **/
//************************************************************************************************/
//**   S.01: SCK width & Frequency              (tHIGH, tLOW)                                  	**/
//**   S.02: Start Condition			(tSU_STA, tHD_STA)                              **/
//**   S.03: Setup & hold time for SDA 		(tSU_DAT, tHD_DAT)                              **/
//**   S.04: Stop Condition			(tSU_STO, tHD_STO)                              **/
//**   S.05: Bus release time			(tBUF)                                          **/
//**   S.06: Noise suppression time		(tSP)                                   	**/
//**                                                                                            **/
//************************************************************************************************/


`timescale 1ns/10ps

module LE2416RLB (SDA, SCL, WP);

   inout		SDA;				// serial data I/O
   input		SCL;				// serial data clock


   wire			slave0_enb, slave1_enb, slave2_enb;
//************************************************************************************************/
//**    Parameter for LE2416RLB (Slave-Pin, WP-Pin Infomation)                                   **/
//************************************************************************************************/

//--------- Case: PAD-Setting  ------------
/*
   input 		S0;				// slave address S0
   input 		S1;				// slave address S1
   input 		S2;				// slave address S2
*/
   input		WP;				// write protect pin  "1"-->protect


//-------- Case: No PAD(Fix Setting) -------
wire			S0,S1,S2;
wire			WP;


assign			S0=0;
assign 			S1=0;
assign 			S2=0;

//assign 		WP=0;


//--------- Pull Up ------------
//pullup Ipull_up(SDA);
  pullup Ipull_upwp(WP);


//************************************************************************************************/
//**    Parameter for LE2416RLB                                                                 **/
//************************************************************************************************/
`define Memory_SIZE     16*1024                        	// 16K-bit (A0-A10)
`define Memory_MSB      10                             	// A0-A10
`define PAGE_SIZE_e     16                              // 16-byte page size (A0-A3)
`define PAGE_MSB_e      3                               // A0-A3

`define Dev_ADD      	4'b1010                         // Device Address(1010)
assign 			slave0_enb=0;			//2K=S0-S2,4K=S1-S2,8K=S2,16K=No 
assign 			slave1_enb=0;
assign 			slave2_enb=0;


//************************************************************************************************/
//**    Specify for LE2416RLB   Timming Parameter (Output)					**/
//************************************************************************************************/
parameter               tWC=5000000-1;                    // Write Cycle 5ms
parameter               tAA=900-1;                        // Output valid from SCL

//************************************************************************************************/
//**    Specify Cheack for LE2416RLB   Timming Parameter (Input)                               	**/
//************************************************************************************************/
`define tLOW    	1200				// SCL pulse width - low
`define tHIGH   	600				// SCL pulse width - high
`define tSU_STA 	600				// Start Condition setup time
`define tHD_STA 	600				// Start Condition hold time
`define tSU_DAT 	100				// Data-Input setup time
`define tHD_DAT 	0				// Data-Input hold time
`define tSU_STO 	600				// Stop Condition setup time
`define tBUF    	1200				// Bus release time
`define tSP    		100				// Noise suppression time

`define tSU_STA_act     250                             // Start Condition setup JITURYOKU
`define tHD_STA_act     200                             // Start Condition hold JITURYOKU
`define tSU_STO_act     250                             // Stop Condition setup JITURYOKU
`define tHD_STO_act     200                             // Stop Condition hold JITURYOKU


//************************************************************************************************/
//**                                                                                            **/
//**    I2C Commpn Logic:  2K,4K,8K,16K                                                         **/
//**                                                                                            **/
//**                                                                                            **/
//**   Revision         : 2.00                                                                  **/
//**   Release          : 18/Jan/2011                                                           **/
//**   Modified Date    : 18/Jan/2011                                                           **/
//**   Revision History :                                                                       **/
//************************************************************************************************/

   reg			SDA_DO;				// serial data - output
   reg			SDA_OE;				// serial data - output enable

   wire			SDA_DriveEnable;		// serial data output enable
   reg			SDA_DriveEnableDlyd;		// serial data output enable - delayed

   reg	[3:0]		BitCounter;			// bit counter (0,1-8,9)

   reg			START_FLAG;			// START Condition
   reg			STOP_FLAG;			// STOP bit received flag
   reg			BCYCLE_1;			// Bus Cycle 1 (1010+S2+S1+A8+RW)
   reg			BCYCLE_2;			// Bus Cycle 2 (A7+A6+A5+A4+A3+A2+A1+A0)
   reg			ACK_Rcv;			// acknowledge received from CPU

   reg			Write_Com;			// Write command
   reg			Read;				// Read cycle
   reg			WRT;				// Write cycle

   reg	[7:0]		Store_Reg;			// input data store register
   reg  [7:0]		BCYCLE1_Reg;			// Bus Cycle 1 register
   wire			RW_bit;				// read/write bit

   wire			Slave_dec;			// Slave Address  Decorder
   wire			Slave0_dec;			// Slave Address0 Decorder
   wire			Slave1_dec;			// Slave Address1 Decorder
   wire			Slave2_dec;			// Slave Address2 Decorder

   reg	[`PAGE_MSB_e:0]	Page_Add;			// page address
   reg	[`PAGE_MSB_e:0]	Next_Page_Add;			// page address + 1
   reg	[`PAGE_MSB_e:0]	WrPointer;			// write buffer pointer

   reg	[7:0]		WriteBuffer [0:`PAGE_SIZE_e-1];	// page write buffer
   wire	[7:0]		OUT_Reg;			// Output Register(Output for SDA)


   reg	[`Memory_MSB:0]	Start_Add;			// start address(Address SetUP)
   reg	[`Memory_MSB:0]	Read_Add;			// read address pointer


   reg  [7:0]           Memory_data [0:`Memory_SIZE/8-1]; // EEPROM data memory array

   integer		Write_Count;			// write data input counter
   integer		LoopIndex;			// iterative loop index


   reg			ACK_Out_Flag;			// ACK Output timming
   reg                  BitC_WRT_OK;                    // WRT for Bitcount

   wire			SDA_DL,SCL_DL;
   assign #`tSU_STA_act         SDA_DL=SDA;
   assign #`tSU_STA_act         SCL_DL=SCL;
//************************************************************************************************/
//**    INITIALIZATION                                                                          **/
//************************************************************************************************/
   initial begin
      SDA_DO = 0;
      SDA_OE = 0;
   end

   initial begin
      START_FLAG = 0;
      STOP_FLAG  = 0;
      BCYCLE_1  = 0;
      BCYCLE_2  = 0;
      ACK_Rcv  = 0;
      ACK_Out_Flag = 0;
      BitC_WRT_OK = 0;
   end

   initial begin
      BitCounter  = 0;
      BCYCLE1_Reg = 0;
   end

   initial begin
      Write_Com = 0;
      Read = 0;

      WRT = 0;
   end

  initial begin
        `ifdef INITIAL_DAT_MODE
		$readmemh( "Init_data_eep.hex", Memory_data);
        `endif
   end
//************************************************************************************************/
//**    LOGIC                                                                                   **/
//************************************************************************************************/
//------------------------------------------------------------------------------------------------
//      L.01:  START Condition
//------------------------------------------------------------------------------------------------

   always @(negedge SDA) begin
// always @(negedge SDA_DL) begin
//    if (SCL == 1) begin
      if ((SCL_DL == 1)&&(SCL == 1)) begin
        #`tHD_STA_act;
                if(SCL == 1)    begin
         		START_FLAG <= 1;
         		STOP_FLAG  <= 0;
         		BCYCLE_1  <= 0;
         		BCYCLE_2  <= 0;
         		ACK_Rcv  <= 0;

         		Write_Com <= #1 0;
         		Read <= #1 0;

         		BitCounter <= 0;
		end
      end
   end

//------------------------------------------------------------------------------------------------
//      L.02:  STOP Condition
//------------------------------------------------------------------------------------------------

   always @(posedge SDA) begin
// always @(posedge SDA_DL) begin
//    if (SCL == 1) begin
      if ((SCL_DL == 1)&&(SCL == 1)) begin
        #`tHD_STO_act;
                if(SCL == 1)    begin
         		START_FLAG <= 0;
         		STOP_FLAG  <= 1;
         		BCYCLE_1  <= 0;
         		BCYCLE_2  <= 0;
         		ACK_Rcv  <= 0;

         		Write_Com <= #1 0;
         		Read <= #1 0;

                        if(BitCounter == 1)  BitC_WRT_OK=1;
                        else                 BitC_WRT_OK=0;
         		BitCounter <= 10;
		end
      end
   end

//------------------------------------------------------------------------------------------------
//      L.03:  Input Shift Register
//------------------------------------------------------------------------------------------------

   always @(posedge SCL) begin
      Store_Reg[0] <= SDA;
      Store_Reg[1] <= Store_Reg[0];
      Store_Reg[2] <= Store_Reg[1];
      Store_Reg[3] <= Store_Reg[2];
      Store_Reg[4] <= Store_Reg[3];
      Store_Reg[5] <= Store_Reg[4];
      Store_Reg[6] <= Store_Reg[5];
      Store_Reg[7] <= Store_Reg[6];
   end

//------------------------------------------------------------------------------------------------
//      L.04:  Input Bit Counter
//------------------------------------------------------------------------------------------------

   always @(posedge SCL) begin
      if (BitCounter < 10) BitCounter <= BitCounter + 1;
   end

//------------------------------------------------------------------------------------------------
//      L.05:  Byte Cycle1 Register
//------------------------------------------------------------------------------------------------

   assign  Slave2_dec   = (~slave2_enb) | (Store_Reg[3] == S2);
   assign  Slave1_dec   = (~slave1_enb) | (Store_Reg[2] == S1);
   assign  Slave0_dec   = (~slave0_enb) | (Store_Reg[1] == S0);
   assign  Slave_dec    = Slave2_dec & Slave1_dec & Slave0_dec;


   always @(negedge SCL) begin
      if (START_FLAG & (BitCounter == 8)) begin
         if (!WRT & (Store_Reg[7:4] == `Dev_ADD) & Slave_dec) begin
            if (Store_Reg[0] == 0) Write_Com <= 1;
            if (Store_Reg[0] == 1) Read <= 1;

            BCYCLE1_Reg <= Store_Reg;

            BCYCLE_1 <= 1;
         end

         START_FLAG <= 0;
      end
   end

   assign RW_bit     = BCYCLE1_Reg[0];

//------------------------------------------------------------------------------------------------
//      L.06:  Address Setup
//------------------------------------------------------------------------------------------------

   always @(negedge SCL) begin
      if (BCYCLE_1 & (BitCounter == 8)) begin
         if (RW_bit == 0) begin
            Start_Add <= {BCYCLE1_Reg[`Memory_MSB-7:1],Store_Reg[7:0]};
            Read_Add <= {BCYCLE1_Reg[`Memory_MSB-7:1],Store_Reg[7:0]};
/*
            Start_Add <= Store_Reg[7:0];		//2K-bit
            Read_Add <= Store_Reg[7:0];			//2K-bit
*/

            BCYCLE_2 <= 1;
         end

         Write_Count <= 0;
         WrPointer <= 0;

         BCYCLE_1 <= 0;
      end
   end

//------------------------------------------------------------------------------------------------
//      L.07:  Write Data Buffer
//------------------------------------------------------------------------------------------------

   always @(negedge SCL) begin
      if (BCYCLE_2 & (BitCounter == 8)) begin
//       if ((WP == 0) & (RW_bit == 0)) begin
         if (RW_bit == 0) begin
            WriteBuffer[WrPointer] <= Store_Reg[7:0];

            Write_Count <= Write_Count + 1;
            WrPointer <= WrPointer + 1;
         end
      end
   end

//------------------------------------------------------------------------------------------------
//      L.08:  Acknowledge Generator(Output)
//------------------------------------------------------------------------------------------------

   always @(negedge SCL) begin
      if (!WRT) begin
         if (BitCounter == 8) begin
            if (Write_Com | (START_FLAG & (Store_Reg[7:4] == `Dev_ADD) & Slave_dec)) begin
	       ACK_Out_Flag <= 1;			//ACK Output (for moniter)
               SDA_DO <= 0;
               SDA_OE <= 1;
            end 
         end
         if (BitCounter == 9) begin
            BitCounter <= 0;

            if (!Read) begin
	       ACK_Out_Flag <= 0;			//ACK Output (for moniter)
               SDA_DO <= 0;
               SDA_OE <= 0;
            end
         end
      end

      if(Read)	ACK_Out_Flag <=0;		//ACK Output (for moniter)
   end 

//------------------------------------------------------------------------------------------------
//      L.09:  Acknowledge Detect
//------------------------------------------------------------------------------------------------

   always @(posedge SCL) begin
      if (Read & (BitCounter == 8)) begin
         if ((SDA == 0) & (SDA_OE == 0)) ACK_Rcv <= 1;		//ACK
	 else if ((SDA == 1) & (SDA_OE == 0)) begin		//No ACK
		ACK_Rcv <=0;
		Read <=0;
	end
      end
   end

   always @(negedge SCL) ACK_Rcv <= 0;

//------------------------------------------------------------------------------------------------
//      L.10:  Write Cycle Timer
//------------------------------------------------------------------------------------------------

   always @(posedge STOP_FLAG) begin
//    if (Write_Com & (WP == 0) & (Write_Count > 0)) begin
      if (Write_Com & (WP == 0) & (Write_Count > 0) & (BitC_WRT_OK == 1)) begin
         WRT = 1;
         #(tWC);
         WRT = 0;
      end
      else if(!WRT) begin
         Write_Count <=0;
      end
   end

   always @(posedge STOP_FLAG) begin
      #(1.0);
      STOP_FLAG = 0;
      BitC_WRT_OK = 0;
   end

//------------------------------------------------------------------------------------------------
//      L.11:  Write Cycle Processor
//------------------------------------------------------------------------------------------------

   always @(negedge WRT) begin
      for (LoopIndex = 0; LoopIndex < Write_Count; LoopIndex = LoopIndex + 1) begin
         Page_Add = Start_Add[`PAGE_MSB_e:0] + LoopIndex;
//       Memory_data[{Start_Add[`Memory_MSB:`PAGE_MSB_1P],Page_Add[`PAGE_MSB_e:0]}] = WriteBuffer[LoopIndex[3:0]];
         Memory_data[{Start_Add[`Memory_MSB:(`PAGE_MSB_e + 1)],Page_Add[`PAGE_MSB_e:0]}] = WriteBuffer[LoopIndex[3:0]];
      end

      Next_Page_Add[`PAGE_MSB_e:0] = Page_Add[`PAGE_MSB_e:0] + 1;
//    Read_Add <= {Start_Add[`Memory_MSB:`PAGE_MSB_1P],Next_Page_Add[`PAGE_MSB_e:0]};
      Read_Add <= {Start_Add[`Memory_MSB:(`PAGE_MSB_e + 1)],Next_Page_Add[`PAGE_MSB_e:0]};

      $writememh ("eep_data_model.hex",  Memory_data);
   end

//------------------------------------------------------------------------------------------------
//      L.12:  Read Data
//------------------------------------------------------------------------------------------------

   always @(negedge SCL) begin
      if (BitCounter == 8) begin
         if (Read) begin
            Read_Add <= Read_Add + 1;
         end
         if (Write_Com & BCYCLE_2) begin
            Page_Add  = Start_Add[`PAGE_MSB_e:0] + Write_Count[`PAGE_MSB_e:0];
            Next_Page_Add[`PAGE_MSB_e:0] = Page_Add[`PAGE_MSB_e:0] + 1;
//          Read_Add <= {Start_Add[`Memory_MSB:`PAGE_MSB_1P],Next_Page_Add[`PAGE_MSB_e:0]};
            Read_Add <= {Start_Add[`Memory_MSB:(`PAGE_MSB_e + 1)],Next_Page_Add[`PAGE_MSB_e:0]};
         end
      end
   end

   assign OUT_Reg = Memory_data[Read_Add];

//------------------------------------------------------------------------------------------------
//      L.13:  Output Data
//------------------------------------------------------------------------------------------------

   always @(negedge SCL) begin
      if (Read) begin
         if (BitCounter == 8) begin
            SDA_DO <= 0;
            SDA_OE <= 0;
         end
         else if (BitCounter == 9) begin
            SDA_DO <= OUT_Reg[7];

            if (ACK_Rcv) SDA_OE <= 1;		//ACK Recive
         end
         else begin
            SDA_DO <= OUT_Reg[7-BitCounter];
         end
      end
   end

//------------------------------------------------------------------------------------------------
//      L.14:  SDA Data I/O Buffer(Open Drain)
//------------------------------------------------------------------------------------------------

   bufif1 (SDA, 1'b0, SDA_DriveEnableDlyd);

   assign SDA_DriveEnable = !SDA_DO & SDA_OE;
   always @(SDA_DriveEnable) SDA_DriveEnableDlyd <= #(tAA) SDA_DriveEnable;





//************************************************************************************************/
//**                                                                                            **/
//**    TIMING CHECKS   :                                                                       **/
//**                                                                                            **/
//**                                                                                            **/
//**   TMC Revision     : 2.00                                                                  **/
//**   Release          : 18/Jan/2011                                                           **/
//**   Modified Date    : 18/Jan/2011                                                           **/
//**   Revision History :                                                                       **/
//************************************************************************************************/

`ifdef NO_EEPSPECIFY
`else
   specify

//------------------------------------------------------------------------------------------------
//      S.01:  SCK width & Frequency
//------------------------------------------------------------------------------------------------
      $width (negedge SCL, `tLOW);
      $width (posedge SCL, `tHIGH);

//------------------------------------------------------------------------------------------------
//      S.02:  Start Condition
//------------------------------------------------------------------------------------------------
      $setup (posedge SCL, negedge SDA, `tSU_STA);
      $hold  (negedge SDA, negedge SCL, `tHD_STA);

//------------------------------------------------------------------------------------------------
//      S.03:  Setup & hold time for SDA (Data Input)
//------------------------------------------------------------------------------------------------
      $setup (SDA, posedge SCL &&& ~SDA_OE, `tSU_DAT);
      $hold  (negedge SCL &&& ~SDA_OE, SDA, `tHD_DAT);

      $setup (WP, posedge SCL, `tSU_DAT);
      $hold  (negedge SCL, WP, `tHD_DAT);

//------------------------------------------------------------------------------------------------
//      S.04:  Stop Condition
//------------------------------------------------------------------------------------------------
      $setup (posedge SCL, posedge SDA, `tSU_STO);

//------------------------------------------------------------------------------------------------
//      S.05:  Bus release time
//------------------------------------------------------------------------------------------------
      $width (posedge SDA &&& SCL, `tBUF);

//------------------------------------------------------------------------------------------------
//      S.06:  Noise suppression time
//------------------------------------------------------------------------------------------------
      $width (posedge SDA &&& ~SDA_OE, `tSP);
      $width (posedge SCL, `tSP);
      $width (posedge WP, `tSP);
      $width (negedge SDA &&& ~SDA_OE, `tSP);
      $width (negedge SCL, `tSP);
      $width (negedge WP, `tSP);


   endspecify
`endif


endmodule