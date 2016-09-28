//************************************************************************************************/
//**     ####### #     #                                                                        **/
//**     #     # ##    #                                                                        **/
//**     #     # # #   #                                                                        **/
//**     #     # #  #  #                                                                        **/
//**     #     # #   # #                                                                        **/
//**     #     # #    ##                                                                        **/
//**     ####### #     #                                                                        **/
//**                                                                                            **/
//**      #####                                                                                 **/
//**     #     #  ######  #    #     #     ####    ####   #    #                                **/
//**     #        #       ##  ##     #    #    #  #    #  ##   #                                **/
//**      #####   #####   # ## #     #    #       #    #  # #  #                                **/
//**           #  #       #    #     #    #       #    #  #  # #                                **/
//**     #     #  #       #    #     #    #    #  #    #  #   ##                                **/
//**      #####   ######  #    #     #     ####    ####   #    #                                **/
//**                                                                                            **/
//**                                                                                            **/
//**                       1-1, Sakata, Oizumi, Gunma, 370-0596 JAPAN                           **/
//************************************************************************************************/
//**                                                                                            **/
//**   LE25S81A          8M-bit Flash Memory                                                    **/
//**                                                                (VDD = 1.65V to 1.95V)      **/
//**                                                                                            **/
//**    File Name    : LE25S81A.v                                                               **/
//**    Rev          : 1.11                                                                     **/
//**    Top Module   : LE25S81A                                                                 **/
//**                                                                                            **/
//**    Feature      :                                                                          **/
//**                Serial interface    SPI Mode0 & Mode3                                       **/
//************************************************************************************************/
//**    Notes:                                                                                  **/
//**                                                                                            **/
//**    If you set up Initail data (Init_data_flash.hex) for 'LE25S81A',                        **/
//**    you execute simulation under condition.                                                 **/
//**        " verilog xxxxx.v +define+INITIAL_DAT_MODE "                                        **/
//**            Initial data(Flash data) file is  "Init_data_flash.hex"                         **/
//**                                                                                            **/
//************************************************************************************************/
//**    History:                                                                                **/
//**      Rev         Date          Author      Affected Sections            Description        **/
//**    --------------------------------------------------------------------------------------- **/
//**    Rev 1.00    Dec/10/2013      Y.K        All                    Initial release          **/
//**    Rev 1.10    Feb/24/2014      Y.K        RSTEN/RST              Added                    **/
//**                                            Software Reset         Added                    **/
//**                                            ID_AB Read Timing      Modified                 **/
//**    Rev 1.11    May/22/2015      Y.K        Update AC-Spec         Modified                 **/
//************************************************************************************************/
//**                                                                                            **/
//**                                                                                            **/
//**   input                CS_L    :chip select    - active low                                **/
//**   inout                SI      :serial data input (I/O @DualMode)                          **/
//**   input                SCK     :serial data clock                                          **/
//**                                                                                            **/
//**   inout                SO      :serial data output (I/O @DualMode)                         **/
//**                                                                                            **/
//**   input                WP_L    :write protect for the status registor -active low          **/
//**   input                HOLD_L  :serial communication suspend -active low                   **/
//************************************************************************************************/

`timescale 1ns/10ps

module LE25S81A(SI, SO, SCK, CS_L, WP_L, HOLD_L);

   inout                SI;                             // serial data input (I/O @DualMode)
   input                SCK;                            // serial data clock

   input                CS_L;                           // chip select - active low
   input                WP_L;                           // write protect pin - active low

   input                HOLD_L;                         // interface suspend - active low


   inout                SO;                             // serial data output (I/O @DualMode)


//-------- Case: No PAD(Fix Setting) -------
/*
wire                    WP_L;
wire                    HOLD_L;


assign                  WP_L=1;
assign                  HOLD_L=1;
*/


//************************************************************************************************/
//**    Parameter for LE25S81A                                                                  **/
//************************************************************************************************/
`define f_SIZE          8*1024*1024                     // 8M-bit (A0-A19)
`define f_MSB           19                              // A0-A19
`define f_PAGE_SIZE     256                             // 256-byte page size (A0-A7)
`define f_PAGE_MSB      7                               // A0-A7
`define f_PAGE_MSB_1P   8                               // PAGE_MSB +1   Page=128Byte:7, Page=256Byte:8
`define SE_SIZE         64*1024                         // Sector Erase: 64K-Byte (A0-A15)
`define SE_MSB          15                              // A0-A15
`define SSE_SIZE        4*1024                          // Small Sector Erase: 4K-Byte (A0-A11)
`define SSE_MSB         11                              // A0-A11
`define SPE_SIZE        2*1024                          // Small Sector Erase: 2K-Byte (A0-A10)
`define SPE_MSB         10                              // A0-A10
`define PRADD_UP16      24'h0F0000                      // 8M:   Upper 1/16 --> 0F0000 - 0FFFFF
`define PRADD_UP8       24'h0E0000                      // 8M:   Upper 1/8  --> 0E0000 - 0FFFFF
`define PRADD_UP4       24'h0C0000                      // 8M:   Upper 1/4  --> 0C0000 - 0FFFFF
`define PRADD_UP2       24'h080000                      // 8M:   Upper 1/2  --> 080000 - 0FFFFF
`define PRADD_LO16      24'h00FFFF                      // 8M:   Upper 1/16 --> 000000 - 00FFFF
`define PRADD_LO8       24'h01FFFF                      // 8M:   Upper 1/8  --> 000000 - 01FFFF
`define PRADD_LO4       24'h03FFFF                      // 8M:   Upper 1/4  --> 000000 - 03FFFF
`define PRADD_LO2       24'h07FFFF                      // 8M:   Upper 1/4  --> 000000 - 07FFFF
`define f_MSB_ADD       24'h0FFFFF                      // 8M:                  000000 - 0FFFFF
//------------------------------------------------------------------------------------------------
/*
`define e_SIZE          64*1024                         // 64K-bit (A0-A12)
`define e_MSB           12                              // A0-A12
`define e_PAGE_SIZE     32                              // 32-byte page size (A0-A4)
`define e_PAGE_MSB      4                               // A0-A4
`define e_PAGE_MSB_1P   5                               // PAGE_MSB +1   Page=32Byte:5, Page=128Byte:7
*/

//************************************************************************************************/
//**    Specify for LE25S81A      Timming Parameter (Output)                                    **/
//************************************************************************************************/
parameter               tCHE= 120000000-1000000;        //         Chip   Erase Cycle, typ=120[ms]
parameter               tSE =  15000000- 100000;        //         Sector Erase Cycle, typ=15[ms]
parameter               tSSE=  10000000- 100000;        // Small   Sector Erase Cycle, typ=10[ms]

parameter               tSPE= 150000000-1000000;        // Special Sector Erase Cycle

parameter               tPP =   500000-1000;            // Normal    Page Program Cycle, max=0.5[ms]
parameter               tPPL=  1000000-1000;            // Low-power Page Program Cycle, max=1.0[ms]

//parameter             tPW = 800000000-1000000;        // Write to EEPROM Cycle       800[ms]
parameter               tPW = 400000000-1000000;        // Write to EEPROM Cycle       400[ms]

parameter               tWRSR= 8000000- 100000;        // Status Registor Write Cycle  8[ms]

parameter               tV1=8-1;                        // f-70MHz: Output valid from SCK
parameter               tV2=9-1;                        // f-50MHz: Output valid from SCK
parameter               tV3=12-1;                       // f-33MHz: Output valid from SCK

parameter               tHLz=10-1;                      // HOLD_L low to output valid
parameter               tHHz=10-1;                      // HOLD_L high to output High-Z
parameter               tCHZ=8-1;                       // CS_L high to output High-Z

parameter               tRSUS= 40000-1000;              // Recovery time from suspend
parameter               tRDP = 20000-1000;              // Recovery time from deep power down
parameter               tRST = 40000-1000;              // Internal reset time
//************************************************************************************************/
//**    Specify for LE25S81A      Timming Parameter (Input)                                     **/
//************************************************************************************************/
`define                 tCLHI1   6                      // f-70MHz: SCK high pulse wudth
`define                 tCLLO1   6                      // f-70MHz: SCK low  pulse wudth time
`define                 tCLHI2   9                      // f-50MHz: SCK high pulse wudth
`define                 tCLLO2   9                      // f-50MHz: SCK low  pulse wudth time

`define                 tCSS     8                      // CS_L setup time
`define                 tDS      3                      // Data setup time
`define                 tDH      3                      // Data hold time
`define                 tCSH     3                      // CS_L hold time

`define                 tCPH    20                      // CS_L stanby pulse width

`define                 tWPS    20                      // WP_L setup time
`define                 tWPH    20                      // WP_L hold time
`define                 tHS      6                      // HOLD_L setup time
`define                 tHH      6                      // HOLD_L hold time


//ID
`define ID_9F_0  8'h62                                  // Manufactual code (62h)
`define ID_9F_1  8'h16                                  // Memory type      (16h)
`define ID_9F_2  8'h14                                  // Memory capacity  (14h)
`define ID_9F_3  8'h00                                  //                  (00h)

`define ID_AB    8'h87                                  // LE25S81A         (87h)

//************************************************************************************************/
// `include "/san/usr/group/flash_sf8/SF8_012/1e25s81a/Model/Verilog_Model/Model/SPI_Lgc_SerialFlash_LRev110.v"
//************************************************************************************************/
//**                                                                                            **/
//**    SPI Commpn Logic:  Flash & EEP Memory                                                   **/
//**                                                                                            **/
//**                                                                                            **/
//**   Revision         : 1.10 (6.10)                                                           **/
//**   Release          : 06/Jan/2014                                                           **/
//**   Modified Date    : xx/xxx/20xx                                                           **/
//**   Revision History : 24/Feb/2014                                                           **/
//************************************************************************************************/
//**   C.01:  Internal Reset Logic                                                              **/
//**   C.02:  Input Data Shifter                                                                **/
//**   C.03:  Bit Clock Counter                                                                 **/
//**   C.04:  Command Register                                                                  **/
//**   C.05:  Address Register                                                                  **/
//**   C.06:  Block Protect Bits                                                                **/
//**   C.07:  Write Protect Enable                                                              **/
//**   F.08:  Write Data Buffer     to FlashMemory                                              **/
//**   C.10:  Write Enable Bit                                                                  **/
//**   C.11:  Status Registor Write                                                             **/
//**   F.12:  Flash Memory Erase Cycle Processor                                                **/
//**   F.13:  Flash Memory Program Cycle Processor                                              **/
//**   C.15:  Read Cycle Processor (Flash, EEPROM)                                              **/
//**   C.16:  Output Data Buffer                                                                **/
//**   C.17:  Status Register                                                                   **/
//**   C.18:  Suspend & Resume (Suspend Cancel)                                                 **/
//**   C.19:  Deep Power Down                                                                   **/
//**   C.20:  Software Reset                                                                    **/
//**                                                                                            **/
//************************************************************************************************/

   reg  [23:0]          Store_Reg;          // Store Register (Input)
   reg  [7:0]           OUT_Reg;            // Output Register(Output for SO)
   reg  [31:0]          BitCounter;         // serial input bit counter
   reg  [7:0]           State_Reg;          // state register

//Common
   wire                 State_WREN;         // State WREN
   wire                 State_WRDI;         // State WRDI
   wire                 State_RDSR;         // State RDSR
   wire                 State_WRSR;         // State WRSR

//FlashMemory
   wire                 State_RDLP;         // Low-power  Read
   wire                 State_RDHS;         // High-speed Read
   wire                 State_RDDO;         // Dual OutputRead
   wire                 State_RDIO;         // Dual I/O   Read

   wire                 State_SPE;          // Special Sector Erase ( 2KB)
   wire                 State_SSE;          // Small   Sector Erase ( 4KB)
   wire                 State_SE;           //         Sector Erase (64KB)
   wire                 State_CHE1;         //         Chip   Erase (  8M)
   wire                 State_CHE2;         //         Chip   Erase (  8M)

   wire                 State_PPL;          // Low-power Page Program
   wire                 State_PP;           // Normal    Page Program
   wire                 State_PW;           // Page Write(EEPROM)

   wire                 State_SUS;          // Write suspend(SSE/SE/CHE/PP/PPL)
   wire                 State_RESM;         // Resume

   wire                 State_ID_9F;        // ID_9F(JEDEC ID)
   wire                 State_ID_AB;        // ID_AF(Device Code)

   wire                 State_RSFDP;        // Read SFDP

   wire                 State_DP;           // Deep Power down

   wire                 State_RSTEN;        // Reset Enable
   wire                 State_RST;          // Reset

//[FlashMemory]
   reg  [23:0]          f_Add_Reg;                      // address register
   reg  [7:0]           f_WrtBuff [0:`f_PAGE_SIZE-1];   // page write buffer
   reg  [`f_PAGE_MSB:0]   f_WritePointer;               // page buffer pointer
   reg  [`f_PAGE_MSB+1:0] f_WriteCounter;               // byte write counter

   reg  [`f_PAGE_MSB:0] f_Page_Add;                     // page buffer address
   reg  [`f_MSB:0]      f_Base_Add;                     // memory write base address
   reg  [`f_MSB:0]      f_Write_Add;                    // memory write address
   reg  [`f_MSB:0]      f_Read_Add;                     // memory read address

   reg  [7:0]           FLASH_data [0:`f_SIZE/8-1];     // FlashMemory data memory array

   reg  [7:0]           f_WrtBuff1,f_WrtBuff2,f_CRENTDAT; //Temporary WriteBuffer (for Verilog-XL)

   reg  [7:0]           SFDP_data [0:4095];             // SFDPF data (Read Only)

   reg                  WriteEnable;                    // memory write enable bit
   wire                 SetWriteEnable;                 // register set
   wire                 ClrWriteEnable;                 // register clear

   reg                  WRT;                            // write operation in progress
   reg                  BUSY_CHE,BUSY_SE,BUSY_SSE;      // write operation in progress
   reg                  BUSY_PPL,BUSY_PP,BUSY_PW;       // write operation in progress

   reg                  BP0;                            // memory block write protect
   reg                  BP1;                            // memory block write protect
   reg                  BP2;                            // memory block write protect
   reg                   TB;                            // memory block write protect
   reg                  BP0_New;                        // memory data to be written
   reg                  BP1_New;                        // memory data to be written
   reg                  BP2_New;                        // memory data to be written
   reg                   TB_New;                        // memory data to be written

   reg                  WP_Enable;                      // write protect pin enable
   reg                  WP_Enable_New;                  // memory data to be written
   wire                 SRWP;                           // status register write protected


   reg  [7:0]           SREG_Data [0:0];                // Status Registor

// Protect Level
    wire        PLEVEL_0, PLEVEL_T1, PLEVEL_T2, PLEVEL_T3, PLEVEL_T4,
                      PLEVEL_B1, PLEVEL_B2, PLEVEL_B3, PLEVEL_B4,
            PLEVEL_5;

   reg                  SO_DO;                          // serial output data - data
   wire                 SO_OE;                          // serial output data - output enable

   reg                  SI_DO;                          // serial output data - data          (SI)
   wire                 SI_OE;                          // serial output data - output enable (SI)

   reg                  SO_Enable;                      // serial data output enable (SO)
   reg                  SIO_Enable;                     // serial data output enable (SI)

   wire                 OutputEnable1;                  // timing accurate output enable
   wire                 OutputEnable2;                  // timing accurate output enable
   wire                 OutputEnable3;                  // timing accurate output enable

   integer              LoopIndex;                      // iterative loop index
   integer              t;                              // iterative loop index
   reg  [7:0]           y;                              // iterative loop index

//HOLD
   reg          HOLD_L_ACT;                             // Holding

// Suspending
   reg                  SUS_ACT;                        // Suspending
   reg                  RESUME;                         // RESUME
   reg                  SUS_CHE,SUS_SE,SUS_SSE;         // Suspending
   reg                  SUS_PP,SUS_PPL;                 // Suspending
   reg  [23:0]          SUS_Add;                        // Suspend address
   reg  [`f_PAGE_MSB+1:0] SUS_WCounter;                 // byte write counter

// DeepPowerDown
   reg          DPDown;                                 // Deep PowrDown state
   wire         SetDPDownEnable;
   wire         ClrDPDownEnable;

// DeepPowerDown
   reg          Softrstenb;                             // Software Reset enable

//Etc
   reg          Recovery;                               // Recovery timming for Power-ON etc
//************************************************************************************************/
//**    Command Decorde                                                                         **/
//************************************************************************************************/
//Common
`define WREN  8'h06                 // Write Enable Command
`define WRDI  8'h04                 // Write Disable Command
`define RDSR  8'h05                 // Read Status Register Command
`define WRSR  8'h01                 // Write Status Register Command


//FlashMemory
`define RDLP  8'h03                 // Low-power  Read
`define RDHS  8'h0B                 // High-speed Read
`define RDDO  8'h3B                 // Dual OutputRead
`define RDIO  8'hBB                 // Dual I/O   Read

//`define SPE   8'h10               // Special Sector Erase ( 2KB)
`define SSE   8'h20                 // Small   Sector Erase ( 4KB)
`define  SE   8'hD8                 //         Sector Erase (64KB)
`define CHE1  8'h60                 //         Chip   Erase (  8M)
`define CHE2  8'hC7                 //         Chip   Erase (  8M)

`define  PP   8'h02                 // Normal    Page Program
`define PPL   8'h0A                 // Low-power Page Program

`define  PW   8'h2A                 // Page Write (EEPROM)

//Suspend&Resume
`define WSUS  8'hB0                 // Write suspend(SSE/SE/CHE/PP/PPL)
`define RESM  8'h30                 // Resume

//Deep Power Down
`define DP    8'hB9                 // Deep Power down

//Software Reset
`define RSTEN 8'h66                 // Reset Enable
`define RST   8'h99                 // Reset
//************************************************************************************************/
//**    INITIALIZATION                                                                          **/
//************************************************************************************************/
   initial begin
      State_Reg =0;

      BP0 = 0;
      BP1 = 0;
      BP2 = 0;
       TB = 0;

      WP_Enable = 0;

      WRT = 0;
      BUSY_CHE = 0;
      BUSY_SE  = 0;
      BUSY_SSE = 0;
      BUSY_PPL = 0;
      BUSY_PP  = 0;
      BUSY_PW  = 0;
      WriteEnable = 0;

      SREG_Data[0] =0;

      HOLD_L_ACT=0;

      SUS_ACT=0;
      SUS_CHE=0;
      SUS_SE=0;
      SUS_SSE=0;
      SUS_PPL=0;
      SUS_PP=0;
      RESUME=0;

      DPDown=0;

      Recovery=0;
      Softrstenb=0;
   end

   initial begin
    `ifdef INITIAL_DAT_MODE
                $readmemh( "Init_data_flash.hex", FLASH_data);

    `endif
         $readmemh( "Init_sfdp_mem.hex", SFDP_data);
   end
//************************************************************************************************/
//**    LOGIC                                                                                   **/
//************************************************************************************************/
//------------------------------------------------------------------------------------------------
//      C.01:  Internal Reset Logic
//------------------------------------------------------------------------------------------------

   always @(negedge CS_L) begin
    BitCounter   <= 0;
    SO_Enable    <= 0;
    SIO_Enable   <= 0;
    if (!WRT) begin
        f_WritePointer <= 0;
        f_WriteCounter <= 0;
    end
   end

   always @(HOLD_L or negedge SCK) begin
    if(!SCK) HOLD_L_ACT=HOLD_L;
   end
//------------------------------------------------------------------------------------------------
//      C.02:  Input Data Shifter
//------------------------------------------------------------------------------------------------

   always @(posedge SCK) begin
      if ((HOLD_L_ACT == 1) && (Recovery== 0)) begin
         if (CS_L == 0)         Store_Reg <= {Store_Reg[22:0],SI};
      end
   end

//------------------------------------------------------------------------------------------------
//      C.03:  Bit Clock Counter
//------------------------------------------------------------------------------------------------

   always @(posedge SCK) begin
      if ((HOLD_L_ACT == 1) && (Recovery== 0)) begin
         if (CS_L == 0)         BitCounter <= BitCounter + 1;
      end
   end

//------------------------------------------------------------------------------------------------
//      C.04:  Command Register
//------------------------------------------------------------------------------------------------

   always @(posedge SCK) begin
      if (HOLD_L_ACT == 1) begin
         if (BitCounter == 7)   State_Reg <= {Store_Reg[6:0],SI};
      end
   end

   assign State_WREN  = (State_Reg[7:0] == `WREN) && !DPDown;
   assign State_WRDI  = (State_Reg[7:0] == `WRDI) && !DPDown;
   assign State_RDSR  = (State_Reg[7:0] == `RDSR) && !DPDown;
   assign State_WRSR  = (State_Reg[7:0] == `WRSR) && !DPDown;

   assign State_RDLP  = (State_Reg[7:0] == `RDLP) && !DPDown;
   assign State_RDHS  = (State_Reg[7:0] == `RDHS) && !DPDown;
   assign State_RDDO  = (State_Reg[7:0] == `RDDO) && !DPDown;
   assign State_RDIO  = (State_Reg[7:0] == `RDIO) && !DPDown;
// assign State_SPE   = (State_Reg[7:0] == `SPE) && !DPDown;
   assign State_SSE   = (State_Reg[7:0] == `SSE) && !DPDown;
   assign State_SE    = (State_Reg[7:0] == `SE) && !DPDown;
   assign State_CHE1  = (State_Reg[7:0] == `CHE1) && !DPDown;
   assign State_CHE2  = (State_Reg[7:0] == `CHE2) && !DPDown;
   assign State_PPL   = (State_Reg[7:0] == `PPL) && !DPDown;
   assign State_PP    = (State_Reg[7:0] == `PP) && !DPDown;
// assign State_PW    = (State_Reg[7:0] == `PW) && !DPDown;
   assign State_PW    = 0;

   assign State_SUS   = (State_Reg[7:0] == `WSUS) && !DPDown;
   assign State_RESM  = (State_Reg[7:0] == `RESM) && !DPDown;

   assign State_ID_9F = (State_Reg[7:0] == 8'h9F) && !DPDown;
   assign State_ID_AB = (State_Reg[7:0] == 8'hAB);

   assign State_RSFDP = (State_Reg[7:0] == 8'h5A) && !DPDown;

   assign State_DP    = (State_Reg[7:0] == `DP);

   assign State_RSTEN = (State_Reg[7:0] == `RSTEN) && !DPDown;
   assign State_RST   = (State_Reg[7:0] == `RST)   && !DPDown;
//------------------------------------------------------------------------------------------------
//      C.05:  Address Register
//------------------------------------------------------------------------------------------------

   always @(posedge SCK) begin
      if (HOLD_L_ACT == 1) begin
         if(State_RDIO) begin   //Dual IO
           if      ((BitCounter == 8) & !WRT)  f_Add_Reg[23:22] <= {SO,SI};
           else if ((BitCounter == 9) & !WRT)  f_Add_Reg[21:20] <= {SO,SI};
           else if ((BitCounter ==10) & !WRT)  f_Add_Reg[19:18] <= {SO,SI};
           else if ((BitCounter ==11) & !WRT)  f_Add_Reg[17:16] <= {SO,SI};
           else if ((BitCounter ==12) & !WRT)  f_Add_Reg[15:14] <= {SO,SI};
           else if ((BitCounter ==13) & !WRT)  f_Add_Reg[13:12] <= {SO,SI};
           else if ((BitCounter ==14) & !WRT)  f_Add_Reg[11:10] <= {SO,SI};
           else if ((BitCounter ==15) & !WRT)  f_Add_Reg[ 9: 8] <= {SO,SI};
           else if ((BitCounter ==16) & !WRT)  f_Add_Reg[ 7: 6] <= {SO,SI};
           else if ((BitCounter ==17) & !WRT)  f_Add_Reg[ 5: 4] <= {SO,SI};
           else if ((BitCounter ==18) & !WRT)  f_Add_Reg[ 3: 2] <= {SO,SI};
           else if ((BitCounter ==19) & !WRT)  f_Add_Reg[ 1: 0] <= {SO,SI};
         end
         else if ((BitCounter == 31) & !WRT) f_Add_Reg <= {Store_Reg[22:0],SI};
      end
   end

//------------------------------------------------------------------------------------------------
//      C.06:  Block Protect Bits
//------------------------------------------------------------------------------------------------

   always @(posedge SCK) begin
      if (HOLD_L_ACT == 1) begin
         if ((BitCounter == 15) & State_WRSR & WriteEnable & !WRT & !SRWP) begin
             TB_New <= Store_Reg[4];
            BP2_New <= Store_Reg[3];
            BP1_New <= Store_Reg[2];
            BP0_New <= Store_Reg[1];
         end
      end
   end

//------------------------------------------------------------------------------------------------
//      C.07:  Write Protect Enable
//------------------------------------------------------------------------------------------------

   always @(posedge SCK) begin
      if (HOLD_L_ACT == 1) begin
         if ((BitCounter == 15) & State_WRSR & WriteEnable & !WRT & !SRWP) begin
            WP_Enable_New <= Store_Reg[6];
         end
      end
   end

   assign SRWP = WP_Enable & (WP_L == 0);

//------------------------------------------------------------------------------------------------
//      F.08:  Write Data Buffer
//------------------------------------------------------------------------------------------------

   always @(posedge SCK) begin
      if (HOLD_L_ACT == 1) begin
         if ((BitCounter >= 39) & (BitCounter[2:0] == 7) & (State_PP | State_PPL | State_PW) & WriteEnable & !WRT) begin
            f_WrtBuff[f_WritePointer] <= {Store_Reg[6:0],SI};

            f_WritePointer <= f_WritePointer + 1;
            if (f_WriteCounter < `f_PAGE_SIZE) f_WriteCounter <= f_WriteCounter + 1;
         end
      end
   end

//------------------------------------------------------------------------------------------------
//      C.10:  Write Enable Bit
//------------------------------------------------------------------------------------------------

   always @(posedge CS_L ) begin
      if (SetWriteEnable)  WriteEnable <= 1;
      else if (ClrWriteEnable)  WriteEnable <= 0;
   end


   assign SetWriteEnable = (BitCounter == 8) & State_WREN & !WRT;
   assign ClrWriteEnable = (BitCounter == 8) & State_WRDI & !WRT;

//------------------------------------------------------------------------------------------------
//      C.11:  Status Registor Write
//------------------------------------------------------------------------------------------------

    always @(posedge CS_L) begin
      if ((BitCounter == 16) & (BitCounter[2:0] == 0) & State_WRSR  & WriteEnable & !WRT & !SUS_ACT) begin
         if (!SRWP) begin
            WRT = 1;
            #(tWRSR);

            BP2 = BP2_New;
            BP1 = BP1_New;
            BP0 = BP0_New;
             TB =  TB_New;
            WP_Enable = WP_Enable_New;
            WriteEnable = 0;        //ver2.1
         end

         WRT = 0;
     $writememh ("flash_data_model.hex",  FLASH_data);
//       WriteEnable = 0;           //ver2.1
      end
    end

    assign PLEVEL_0  =       !BP2 & !BP1 & !BP0;
    assign PLEVEL_T1 = !TB & !BP2 & !BP1 &  BP0;
    assign PLEVEL_T2 = !TB & !BP2 &  BP1 & !BP0;
    assign PLEVEL_T3 = !TB & !BP2 &  BP1 &  BP0;
    assign PLEVEL_T4 = !TB &  BP2 & !BP1 & !BP0;
    assign PLEVEL_B1 =  TB & !BP2 & !BP1 &  BP0;
    assign PLEVEL_B2 =  TB & !BP2 &  BP1 & !BP0;
    assign PLEVEL_B3 =  TB & !BP2 &  BP1 &  BP0;
    assign PLEVEL_B4 =  TB &  BP2 & !BP1 & !BP0;
    assign PLEVEL_5  =      ((BP2 & !BP1 &  BP0) | (BP2 & BP1));

//------------------------------------------------------------------------------------------------
//      F.12:  Flash Memory Erase Cycle Processor
//------------------------------------------------------------------------------------------------

// always @(posedge CS_L) begin
always @(posedge CS_L or posedge RESUME) begin

//CHE
      if (((BitCounter == 8) & (State_CHE1 | State_CHE2) & WriteEnable & !WRT)
                                                         | (RESUME & SUS_CHE)) begin
         if (PLEVEL_0) begin
            WRT = 1;
         end
         if (WRT) begin
            BUSY_CHE=1;

//          #(tCHE);
            for(t=0; t<tCHE; t=t+200) begin
              #200;
//            if(SUS_ACT) break;
              if(SUS_ACT) t=tCHE;
            end

//          if(PLEVEL_0) begin
            if(PLEVEL_0 & !SUS_ACT) begin
              for (LoopIndex = 0; LoopIndex < (`f_SIZE/8); LoopIndex = LoopIndex + 1) begin
                 FLASH_data[LoopIndex[`f_MSB:0]] = 8'hFF;
             WriteEnable = 0;
              end
            end
         end
         WRT=0;
         BUSY_CHE=0;
     $writememh ("flash_data_model.hex",  FLASH_data);
       end

//SE,SSE
      if (((BitCounter == 32) & (State_SE | State_SSE)& WriteEnable & !WRT)
                                           | (RESUME & (SUS_SE | SUS_SSE))) begin

         if(RESUME)    f_Add_Reg = SUS_Add;
         f_Write_Add = f_Add_Reg;

         if (PLEVEL_0) begin
           WRT = 1;
         end
         if (PLEVEL_T1) begin
           if ((f_Write_Add >= `PRADD_UP16) && (f_Write_Add <= `f_MSB_ADD)) begin
               // write protected region
           end
           else begin
               WRT = 1;
           end
         end
         if (PLEVEL_T2) begin
           if ((f_Write_Add >= `PRADD_UP8) && (f_Write_Add <= `f_MSB_ADD)) begin
               // write protected region
           end
           else begin
               WRT = 1;
           end
         end
         if (PLEVEL_T3) begin
           if ((f_Write_Add >= `PRADD_UP4) && (f_Write_Add <= `f_MSB_ADD)) begin
               // write protected region
           end
           else begin
               WRT = 1;
           end
         end
         if (PLEVEL_T4) begin
           if ((f_Write_Add >= `PRADD_UP2) && (f_Write_Add <= `f_MSB_ADD)) begin
               // write protected region
            end
           else begin
               WRT = 1;
           end
         end
         if (PLEVEL_B1) begin
           if ((f_Write_Add >= 0) && (f_Write_Add <= `PRADD_LO16)) begin
               // write protected region
           end
           else begin
               WRT = 1;
           end
         end
         if (PLEVEL_B2) begin
           if ((f_Write_Add >= 0) && (f_Write_Add <= `PRADD_LO8)) begin
               // write protected region
           end
           else begin
               WRT = 1;
           end
         end
         if (PLEVEL_B3) begin
           if ((f_Write_Add >= 0) && (f_Write_Add <= `PRADD_LO4)) begin
               // write protected region
           end
           else begin
               WRT = 1;
           end
         end
         if (PLEVEL_B4) begin
           if ((f_Write_Add >= 0) && (f_Write_Add <= `PRADD_LO2)) begin
               // write protected region
           end
           else begin
               WRT = 1;
           end
         end
         if (PLEVEL_5) begin
               // write protected region
         end

         if (WRT) begin
            if(State_SE | (SUS_SE & RESUME))  begin
              BUSY_SE=1;

//            #(tSE);
              for(t=0; t<tSE; t=t+200) begin
                #200;
//              if(SUS_ACT) break;
                if(SUS_ACT) t=tSE;
              end

              if(!SUS_ACT) begin
                for (LoopIndex = 0; LoopIndex < `SE_SIZE; LoopIndex = LoopIndex + 1) begin
                  f_Write_Add = {f_Add_Reg[`f_MSB:`SE_MSB+1],LoopIndex[`SE_MSB:0]};
                  FLASH_data[f_Write_Add[`f_MSB:0]] = 8'hFF;
                  WriteEnable = 0;
                end
              end
            end
            if(State_SSE | (SUS_SSE & RESUME))  begin
              BUSY_SSE=1;

//            #(tSSE);
              for(t=0; t<tSSE; t=t+200) begin
                #200;
//              if(SUS_ACT) break;
                if(SUS_ACT) t=tSSE;
              end

              if(!SUS_ACT) begin
                for (LoopIndex = 0; LoopIndex < `SSE_SIZE; LoopIndex = LoopIndex + 1) begin
                  f_Write_Add = {f_Add_Reg[`f_MSB:`SSE_MSB+1],LoopIndex[`SSE_MSB:0]};
                  FLASH_data[f_Write_Add[`f_MSB:0]] = 8'hFF;
                  WriteEnable = 0;
                end
              end
            end
         end
         WRT=0;
         BUSY_SE=0;
         BUSY_SSE=0;
     $writememh ("flash_data_model.hex",  FLASH_data);
      end

//SPE
/*
      if ((BitCounter == 32) & State_SPE & WriteEnable & !WRT) begin

         f_Write_Add = f_Add_Reg;

         if (PLEVEL_0 | PLEVEL_T1 | PLEVEL_T2 | PLEVEL_T3 | PLEVEL_T4) begin
           if ((f_Write_Add >= 0) && (f_Write_Add <= 'h3FFF)) begin
               WRT = 1;
           end
           else begin
        //No Area Special Sector
           end
         end

         if (WRT) begin
           #(tSPE);
           for (LoopIndex = 0; LoopIndex < `SPE_SIZE; LoopIndex = LoopIndex + 1) begin
             f_Write_Add = {f_Add_Reg[`f_MSB:`SPE_MSB+1],LoopIndex[`SPE_MSB:0]};
             FLASH_data[f_Write_Add[`f_MSB:0]] = 8'hFF;
             WriteEnable = 0;
           end
           WRT = 0;
         end
         WRT=0;
     $writememh ("flash_data_model.hex",  FLASH_data);
      end
*/

   end


//------------------------------------------------------------------------------------------------
//      F.13:  Flash Memory Program Cycle Processor
//------------------------------------------------------------------------------------------------

   always @(posedge CS_L or posedge RESUME) begin

//PPL,PP
//PW
      if (((BitCounter >= 40) & (BitCounter[2:0] == 0)
            & (State_PPL | State_PP | State_PW)& WriteEnable & !WRT)
                                    | (RESUME & (SUS_PP | SUS_PPL))) begin

        if(RESUME)   begin
             f_Add_Reg = SUS_Add;
             f_WriteCounter = SUS_WCounter;
        end

        for (LoopIndex = 0; LoopIndex < f_WriteCounter; LoopIndex = LoopIndex + 1) begin

            f_Base_Add = {f_Add_Reg[`f_MSB:`f_PAGE_MSB_1P],`f_PAGE_MSB_1P'd0};
            f_Page_Add = (f_Add_Reg[`f_PAGE_MSB:0] + LoopIndex);
            f_Write_Add = {f_Base_Add[`f_MSB:`f_PAGE_MSB_1P],f_Page_Add[`f_PAGE_MSB:0]};


           if (PLEVEL_0) begin
             WRT = 1;
           end
           if (PLEVEL_T1) begin
             if ((f_Write_Add >= `PRADD_UP16) && (f_Write_Add <= `f_MSB_ADD)) begin
                 // write protected region
             end
             else begin
                 WRT = 1;
             end
           end
           if (PLEVEL_T2) begin
             if ((f_Write_Add >= `PRADD_UP8) && (f_Write_Add <= `f_MSB_ADD)) begin
                 // write protected region
             end
             else begin
                 WRT = 1;
             end
           end
           if (PLEVEL_T3) begin
             if ((f_Write_Add >= `PRADD_UP4) && (f_Write_Add <= `f_MSB_ADD)) begin
                 // write protected region
             end
             else begin
                 WRT = 1;
             end
           end
           if (PLEVEL_T4) begin
             if ((f_Write_Add >= `PRADD_UP2) && (f_Write_Add <= `f_MSB_ADD)) begin
                 // write protected region
             end
             else begin
                 WRT = 1;
             end
           end
           if (PLEVEL_B1) begin
             if ((f_Write_Add >= 0) && (f_Write_Add <= `PRADD_LO16)) begin
                 // write protected region
             end
             else begin
                 WRT = 1;
             end
           end
           if (PLEVEL_B2) begin
             if ((f_Write_Add >= 0) && (f_Write_Add <= `PRADD_LO8)) begin
                 // write protected region
             end
             else begin
                 WRT = 1;
             end
           end
           if (PLEVEL_B3) begin
             if ((f_Write_Add >= 0) && (f_Write_Add <= `PRADD_LO4)) begin
                 // write protected region
             end
             else begin
                 WRT = 1;
             end
           end
           if (PLEVEL_B4) begin
             if ((f_Write_Add >= 0) && (f_Write_Add <= `PRADD_LO2)) begin
                 // write protected region
             end
             else begin
                 WRT = 1;
             end
           end
           if (PLEVEL_5) begin
                 // write protected region
           end
       end

       if (WRT) begin
             if(State_PPL | (SUS_PPL && RESUME))  begin
                BUSY_PPL=1;

//              #(tPPL);
                for(t=0; t<tPPL; t=t+200) begin
                  #200;
//                if(SUS_ACT) break;
                  if(SUS_ACT) t=tPPL;
                end

             end
             else if(State_PP | (SUS_PP && RESUME))  begin
                BUSY_PP=1;

//              #(tPP);
                for(t=0; t<tPP; t=t+200) begin
                  #200;
//                if(SUS_ACT) break;
                  if(SUS_ACT) t=tPP;
                end

             end
             else if(State_PW)   begin
                BUSY_PW=1;
                #(tPW);
             end

                if(!SUS_ACT) begin
                  for (LoopIndex = 0; LoopIndex < f_WriteCounter; LoopIndex = LoopIndex + 1) begin
                     f_Base_Add = {f_Add_Reg[`f_MSB:`f_PAGE_MSB_1P],`f_PAGE_MSB_1P'd0};
                     f_Page_Add = (f_Add_Reg[`f_PAGE_MSB:0] + LoopIndex);

                     f_Write_Add = {f_Base_Add[`f_MSB:`f_PAGE_MSB_1P],f_Page_Add[`f_PAGE_MSB:0]};
//                   FLASH_data[f_Write_Add[`f_MSB:0]] = f_WrtBuff[LoopIndex];
                     f_WrtBuff1 = f_WrtBuff[LoopIndex];
                     f_CRENTDAT =  FLASH_data[f_Write_Add[`f_MSB:0]];
                     for(y=0; y<8; y=y+1) begin
                        if(!f_WrtBuff1[y]) f_WrtBuff2[y] = f_WrtBuff1[y];
                        else               f_WrtBuff2[y] = f_CRENTDAT[y];
                     end
                     if(BUSY_PW)   FLASH_data[f_Write_Add[`f_MSB:0]] = f_WrtBuff[LoopIndex];
             else      FLASH_data[f_Write_Add[`f_MSB:0]] = f_WrtBuff2;

                     WriteEnable = 0;
                  end
                end
         end

         WRT=0;
         BUSY_PPL=0;
         BUSY_PP=0;
         BUSY_PW=0;
         $writememh ("flash_data_model.hex",  FLASH_data);
      end
   end


//------------------------------------------------------------------------------------------------
//      C.15:  Read Cycle Processor
//------------------------------------------------------------------------------------------------

   always @(negedge SCK) begin
      if (HOLD_L_ACT == 1) begin
//Flash
         if ((BitCounter >= 32) & (BitCounter[2:0] == 0) & State_RDLP & !WRT) begin
            if (BitCounter == 32) begin
               OUT_Reg <= FLASH_data[f_Add_Reg[`f_MSB:0]];
               f_Read_Add <= f_Add_Reg + 1;
               SO_Enable    <= 1;
            end
            else begin
               OUT_Reg <= FLASH_data[f_Read_Add[`f_MSB:0]];
               f_Read_Add <= f_Read_Add + 1;
            end
         end
         else if ((BitCounter >= 40) & (BitCounter[2:0] == 0) & State_RDHS & !WRT) begin
            if (BitCounter == 40) begin
               OUT_Reg <= FLASH_data[f_Add_Reg[`f_MSB:0]];
               f_Read_Add <= f_Add_Reg + 1;
               SO_Enable    <= 1;
            end
            else begin
               OUT_Reg <= FLASH_data[f_Read_Add[`f_MSB:0]];
               f_Read_Add <= f_Read_Add + 1;
            end
         end
//Flash_Dual
         else if ((BitCounter >= 40) & (BitCounter[1:0] == 0) & State_RDDO & !WRT) begin
            if (BitCounter == 40) begin
               OUT_Reg <= FLASH_data[f_Add_Reg[`f_MSB:0]];
               f_Read_Add <= f_Add_Reg + 1;
               SO_Enable    <= 1;
               SIO_Enable   <= 1;
            end
            else begin
               OUT_Reg <= FLASH_data[f_Read_Add[`f_MSB:0]];
               f_Read_Add <= f_Read_Add + 1;
            end
         end
         else if ((BitCounter >= 24) & (BitCounter[1:0] == 0) & State_RDIO & !WRT) begin
            if (BitCounter == 24) begin
               OUT_Reg <= FLASH_data[f_Add_Reg[`f_MSB:0]];
               f_Read_Add <= f_Add_Reg + 1;
               SO_Enable    <= 1;
               SIO_Enable   <= 1;
            end
            else begin
               OUT_Reg <= FLASH_data[f_Read_Add[`f_MSB:0]];
               f_Read_Add <= f_Read_Add + 1;
            end
         end
//SREG
         else if ((BitCounter > 7) & (BitCounter[2:0] == 3'b000) & State_RDSR) begin
            OUT_Reg <= SREG_Data[0];
            SO_Enable    <= 1;
         end
//ID
         else if ((BitCounter > 7) & (BitCounter[2:0] == 3'b000) & State_ID_9F) begin
            if(BitCounter[4:3] == 2'b01 )       OUT_Reg <= `ID_9F_0;
            else if(BitCounter[4:3] == 2'b10 )  OUT_Reg <= `ID_9F_1;
            else if(BitCounter[4:3] == 2'b11 )  OUT_Reg <= `ID_9F_2;
            else                                OUT_Reg <= `ID_9F_3;
            SO_Enable    <= 1;
         end
//       else if ((BitCounter > 7) & (BitCounter[2:0] == 3'b000) & State_ID_AB) begin
         else if ((BitCounter > 31) & (BitCounter[2:0] == 3'b000) & State_ID_AB) begin
            OUT_Reg <= `ID_AB;
            SO_Enable    <= 1;
         end
//SFDP
         else if ((BitCounter >= 40) & (BitCounter[2:0] == 0) & State_RSFDP & !WRT) begin
            if (BitCounter == 40) begin
               OUT_Reg <= SFDP_data[f_Add_Reg[11:0]];
               f_Read_Add <= f_Add_Reg + 1;
               SO_Enable    <= 1;
            end
            else begin
               OUT_Reg <= SFDP_data[f_Read_Add[11:0]];
               f_Read_Add <= f_Read_Add + 1;
            end
         end
//Common
         else begin
       if(State_RDDO | State_RDIO) begin
                 OUT_Reg <= OUT_Reg << 2;
           end
           else  OUT_Reg <= OUT_Reg << 1;
         end
      end
   end


//------------------------------------------------------------------------------------------------
//      C.16:  Output Data Buffer
//------------------------------------------------------------------------------------------------

   bufif1 (SO, SO_DO, SO_OE);
   bufif1 (SI, SI_DO, SI_OE);

   always @(OUT_Reg or State_RDDO or State_RDIO) begin
    if(State_RDDO | State_RDIO) begin
          SO_DO <= #(tV1) OUT_Reg[7];
          SI_DO <= #(tV1) OUT_Reg[6];
        end
        else if (State_RDLP) SO_DO <= #(tV2) OUT_Reg[7];    //33MHz(Max)
        else                 SO_DO <= #(tV1) OUT_Reg[7];        //50MHz(Max)
   end

//SO
   bufif1 #(tV2,0)    (OutputEnable1A,  SO_Enable,  State_RDLP); //33MHz(Max)
   bufif1 #(tV1,0)    (OutputEnable1A,  SO_Enable, ~State_RDLP); //50MHz(Max)
//SI(Dual)
   bufif1 #(tV1,0)    (OutputEnable1B, SIO_Enable, 1);
   notif1 #(tCHZ)    (OutputEnable2, CS_L,   1);
   bufif1 #(tHLz,tHHz) (OutputEnable3, HOLD_L_ACT, 1);

   assign  SO_OE = OutputEnable1A & OutputEnable2 & OutputEnable3;
   assign  SI_OE = OutputEnable1B & OutputEnable2 & OutputEnable3;

//------------------------------------------------------------------------------------------------
//      C.17:  Status Register
//------------------------------------------------------------------------------------------------

   always @(WP_Enable or SUS_ACT or TB or BP2 or BP1 or BP0 or WriteEnable or WRT) begin
     SREG_Data[0] = {WP_Enable,SUS_ACT,TB,BP2,BP1,BP0,WriteEnable,WRT}; //Non Blocking script <=NG
     $writememh ("sreg_data.hex",SREG_Data);
   end


//------------------------------------------------------------------------------------------------
//      C.18:  Suspend & Resume (Suspend Cancel)
//------------------------------------------------------------------------------------------------

    always @(posedge CS_L) begin
      if ((BitCounter == 8) & State_SUS  & WRT) begin
     SUS_Add=f_Add_Reg;
     SUS_WCounter=f_WriteCounter;

         #(tRSUS);

         if(BUSY_CHE) begin
           SUS_ACT=1;
           SUS_CHE=1;
           BUSY_CHE=0;
           WRT=0;
         end
         else if(BUSY_SE) begin
           SUS_ACT=1;
           SUS_SE=1;
           BUSY_SE=0;
           WRT=0;
         end
         else if(BUSY_SSE) begin
           SUS_ACT=1;
           SUS_SSE=1;
           BUSY_SSE=0;
           WRT=0;
         end
         else if(BUSY_PPL) begin
           SUS_ACT=1;
           SUS_PPL=1;
           BUSY_PPL=0;
           WRT=0;
         end
         else if(BUSY_PP) begin
           SUS_ACT=1;
           SUS_PP=1;
           BUSY_PP=0;
           WRT=0;
         end
      end

      if ((BitCounter == 8) & State_RESM  & !WRT & SUS_ACT) begin
       #100;
           RESUME=1;
      end

    end

    always @(posedge WRT) begin     //cancel
      #100;
           RESUME=0;
           SUS_ACT=0;
           SUS_CHE=0;
           SUS_SE=0;
           SUS_SSE=0;
           SUS_PP=0;
           SUS_PPL=0;
     end

//------------------------------------------------------------------------------------------------
//      C.19:  Deep Power Down
//------------------------------------------------------------------------------------------------

   always @(posedge CS_L ) begin
      if (SetDPDownEnable)       DPDown <= 1;
      else if (ClrDPDownEnable && DPDown)  begin
            Recovery <=1;
        BitCounter <= 0;
            State_Reg <=0;
       #tRDP;
            Recovery <=0;
            DPDown <= 0;
      end
   end

   assign SetDPDownEnable = (BitCounter == 8) & State_DP & !WRT;
   assign ClrDPDownEnable = State_ID_AB & !WRT;

//------------------------------------------------------------------------------------------------
//      C.12:  Software Reset
//------------------------------------------------------------------------------------------------

   always @(posedge CS_L ) begin
      if (State_RSTEN)      Softrstenb <= 1;
      else if (State_RST && Softrstenb)      begin

           RESUME=0;
           SUS_ACT=0;
           SUS_CHE=0;
           SUS_SE=0;
           SUS_SSE=0;
           SUS_PP=0;
           SUS_PPL=0;

         if(WRT)  #(tRST);

           State_Reg =0;
       BitCounter = 0;

           WRT = 0;
           BUSY_CHE = 0;
           BUSY_SE  = 0;
           BUSY_SSE = 0;
           BUSY_PPL = 0;
           BUSY_PP  = 0;
           BUSY_PW  = 0;
           WriteEnable = 0;

           SREG_Data[0] =0;

           SUS_ACT=0;
           SUS_CHE=0;
           SUS_SE=0;
           SUS_SSE=0;
           SUS_PPL=0;
           SUS_PP=0;
           RESUME=0;

           DPDown<=0;

           Recovery<=0;
           Softrstenb<=0;
       end
       else Softrstenb <= 0;
   end

//************************************************************************************************/
// `include "/san/usr/group/flash_sf8/SF8_012/1e25s81a/Model/Verilog_Model/Model/SPI_TMCHK_SerialFlash_TRev110.v"
//************************************************************************************************/
//**                                                                                            **/
//**    TIMING CHECKS   :                                                                       **/
//**                                                                                            **/
//**                                                                                            **/
//**   TMC Revision     : 1.10 (6.10)                                                           **/
//**   Release          : 07/Nov/2011                                                           **/
//**   Modified Date    : 11/Sep/2012                                                           **/
//**   Revision History : 24/Feb/2014                                                           **/
//************************************************************************************************/

   wire   SCK_RDLP;
   assign SCK_RDLP = State_RDLP & SCK;

`ifdef NO_EEPSPECIFY
`else
   specify

//------------------------------------------------------------------------------------------------
//      S.01:  SCK width & Frequency
//------------------------------------------------------------------------------------------------
      $width (posedge SCK,       `tCLHI1);      //80MHz
      $width (negedge SCK,       `tCLLO1);      //80MHz

      $width (posedge SCK_RDLP,  `tCLHI2);      //50MHz
      $width (negedge SCK_RDLP,  `tCLLO2);      //50MHz
//------------------------------------------------------------------------------------------------
//      S.02:  Setup & hold time at CS_L low
//------------------------------------------------------------------------------------------------
//    $setup (negedge CS_L, posedge SCK &&& ~CS_L, `tCSS);
//    $hold  (posedge SCK, negedge CS_L, `tCLS);

//------------------------------------------------------------------------------------------------
//      S.03:  Setup & hold time at CS_L hi
//------------------------------------------------------------------------------------------------
//    $hold  (posedge SCK    &&& ~CS_L, posedge CS_L, `tCSH);
//    $setup (posedge CS_L, posedge SCK, `tCLH);

//------------------------------------------------------------------------------------------------
//      S.04:  Setup & hold time for SI
//------------------------------------------------------------------------------------------------
      $setup (SI, posedge SCK &&& ~CS_L, `tDS);
      $hold  (posedge SCK    &&& ~CS_L, SI,   `tDH);

//------------------------------------------------------------------------------------------------
//      S.05:  CS_L Stanby pulse width
//------------------------------------------------------------------------------------------------
      $width (posedge CS_L, `tCPH);

//------------------------------------------------------------------------------------------------
//      S.06:  Setup & hold time for WP_L
//------------------------------------------------------------------------------------------------
/*
      $setup (negedge SCK, negedge WP_L &&& ~CS_L, `tWPS);
      $hold  (posedge WP_L &&& ~CS_L, posedge SCK,  `tWPH);
*/
      $setup (WP_L, negedge CS_L, `tWPS);
      $hold  (posedge CS_L, WP_L, `tWPH);

      $setup (WP_L, posedge SCK &&& ~CS_L, `tWPS);
      $hold  (posedge SCK &&& ~CS_L, WP_L, `tWPH);

//------------------------------------------------------------------------------------------------
//      S.07:  Setup & hold time for HOLD_L
//------------------------------------------------------------------------------------------------
/*
      $setup (negedge SCK, negedge HOLD_L &&& ~CS_L, `tHH);
      $hold  (posedge HOLD_L &&& ~CS_L, posedge SCK,  `tHS);
*/
      $setup (HOLD_L, posedge SCK &&& ~CS_L, `tHS);
      $hold  (negedge SCK &&& ~CS_L, HOLD_L, `tHH);

  endspecify
`endif


endmodule
