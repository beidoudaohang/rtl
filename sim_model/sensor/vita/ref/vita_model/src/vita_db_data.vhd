-- *********************************************************************
-- Copyright 2011, ON Semiconductor Corporation.
--
-- This software is owned by ON Semiconductor Corporation (ON)
-- and is protected by United States copyright laws and international
-- treaty provisions.  Therefore, you must treat this software like any
-- other copyrighted material (e.g., book, or musical recording), with
-- the exception that one copy may be made for personal use or
-- evaluation.  Reproduction, modification, translation, compilation, or
-- representation of this software in any other form (e.g., paper,
-- magnetic, optical, silicon, etc.) is prohibited without the express
-- written permission of ON.
--
-- Disclaimer: ON makes no warranty of any kind, express or
-- implied, with regard to this material, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular
-- purpose. ON reserves the right to make changes without further
-- notice to the materials described herein. ON does not assume any
-- liability arising out of the application or use of any product or
-- circuit described herein. ON's products described herein are not
-- authorized for use as components in life-support devices.
--
-- This software is protected by and subject to worldwide patent
-- coverage, including U.S. and foreign patents. Use may be limited by
-- and subject to the ON Software License Agreement.
--
-- *********************************************************************
-- $Id: design#hdl#model#src#vita_db_data.vhd,v 1.3 2012-12-06 03:11:33-07 ffynvr Exp $
-- Author         : $Author: ffynvr $
-- Department     : CISP
-- Date           : $Date: 2012-12-06 03:11:33-07 $
-- Revision       : $Revision: 1.3 $
-- *********************************************************************
-- Modification History Summary
-- Date        By   Version  Change Description
-- *********************************************************************
-- See logs
--
-- *********************************************************************
-- Description
--
-- *********************************************************************

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library lib_vita_hdl;
  use lib_vita_hdl.pck_vita_model.all;
  use lib_vita_hdl.pck_crc.all;

entity vita_db_data is
  port (
    ----- Register Interface -----
    reg_log_enable:              in std_logic;
    reg_db_8bit_mode:            in std_logic;
    reg_db_auto_blackcal_enable: in std_logic;
    reg_db_black_offset:         in natural;
    reg_db_blackcal_offset:      in natural;
    reg_db_blackcal_offset_dec:  in std_logic;
    reg_db_crc_seed:             in std_logic;
    reg_db_testpattern_en:       in std_logic;
    reg_db_prbs_en:              in std_logic;
    reg_db_inc_testpattern:      in std_logic;
    reg_db_frame_testpattern:    in std_logic;
    reg_db_testpattern:          in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    reg_db_trainingpattern:      in unsigned(C_DB_DATA_WIDTH - 1 downto 0);

    ----- Control Path -----
    seq_db_line_valid:           in std_logic;
    seq_db_black:                in std_logic;

    ----- ADC Interface -----
    afe_db_data:                 in t_db_data_array(1 downto 0);

    ----- DB Interface -----
    db_ser_data:                out t_db_data;

    ----- System -----
    cgen_log_clk:                in std_logic;
    rgen_log_reset_n:            in std_logic
  );
end vita_db_data;

architecture model of vita_db_data is

begin

  MAIN: process(rgen_log_reset_n, cgen_log_clk)
    -----------------------
    -- Test Pattern Related
    -----------------------
    variable testpattern_request:     boolean;
    variable testpattern_sat:         boolean;
    variable db_testpattern:          unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    variable db_inc:                  unsigned(C_DB_DATA_WIDTH - 1 downto 0);

    -----------
    -- Datapath
    -----------
    variable db_data:                 unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    variable db_crc:                  unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    variable sample_even:             boolean;

    --------
    -- Delay
    --------
    variable seq_db_line_valid_q:     std_logic;
    variable reg_db_testpattern_en_q: std_logic;
    variable reg_db_prbs_en_q:        std_logic;

  begin

    if rgen_log_reset_n = '0' then
      db_inc                  := (others => '0');
      db_crc                  := (others => '0');
      sample_even             := false;
      seq_db_line_valid_q     := '0';
      reg_db_testpattern_en_q := '0';
      reg_db_prbs_en_q        := '0';

      db_ser_data             <= (others => '0');

    elsif cgen_log_clk'event and cgen_log_clk = '1' then

      if reg_log_enable = '1' then

        db_data := reg_db_trainingpattern;

        ------------------------
        -- Odd/Even Selection --
        ------------------------
        if (seq_db_line_valid = '1') then
          sample_even := not sample_even;
          if (seq_db_line_valid_q = '0') then
            sample_even := true;
          end if;

          db_data := afe_db_data(0);
          if not sample_even then
            db_data := afe_db_data(1);
          end if;
        end if;

        ------------------------------------------
        -- (Incremental) Testpattern Generation --
        ------------------------------------------
        -- Ignore MSBs of reg_db_testpattern in 8 bit mode.
        db_testpattern := reg_db_testpattern;
        if reg_db_8bit_mode = '1' then
          db_testpattern(C_DB_DATA_WIDTH - 1 downto 8) := (others => '0');
        end if;

        testpattern_request := false;
        if (reg_db_testpattern_en = '1') or (reg_db_prbs_en = '1') then
          testpattern_request := (seq_db_line_valid = '1');
          if (reg_db_frame_testpattern = '0') then
            testpattern_request := true;
          end if;
        end if;

        if testpattern_request then
          if (reg_db_inc_testpattern = '1') then
            testpattern_sat := (db_inc = 2**10 - 1);
            if reg_db_8bit_mode = '1' then
              testpattern_sat := (db_inc = 2**8 - 1);
            end if;

            if not testpattern_sat then
              db_inc := db_inc + 1;
            else
              db_inc := db_testpattern;
            end if;

            -- Initialize when enabling test pattern and upon new line start
            -- when framed.
            if (reg_db_testpattern_en_q = '0') or
               ((reg_db_frame_testpattern = '1') and
                (seq_db_line_valid = '1') and (seq_db_line_valid_q ='0')
               ) then
              db_inc := db_testpattern;
            end if;
          else
            db_inc := db_testpattern;
          end if;

          db_data := db_inc;

        end if;

        ------------------------------------------------------------
        -- CRC/PRBS Generation
        --    Note: CRC generator is reused to generate PRBS data
        -- CRC Initializations
        -- a. Normal: initialize to first data word or
        --            to all '1' (reg_db_crc_seed = '1')
        -- b. PRBS: initialize to reg_db_testpattern
        ------------------------------------------------------------
        if (reg_db_prbs_en = '1') then
          db_data := (others => '0');
          if not (reg_db_prbs_en_q = '1') then
            db_crc := db_testpattern;
          end if;
        else
          if not ((seq_db_line_valid='1') or (seq_db_line_valid_q='1')) then
            db_crc := (others => '0');
            if reg_db_crc_seed = '1' then
              db_crc := (others => '1');
            end if;
          end if;
        end if;

        -- Request new CRC in the following cases:
        -- 1. Normal mode and framed testmode: for each data sample
        -- 2. PRBS:
        --    a. Framed: all pixels where valid data needs to be replaced
        --    b. non Framed: constantly.
        --    Note: The latter information is given by testpattern_request
        if ( (reg_db_prbs_en = '1') and testpattern_request
           ) or
           (seq_db_line_valid = '1') then

          if (reg_db_8bit_mode = '0') then
            db_crc := nextCRC10_D10(data => db_data, crc  => db_crc);
          else
            db_crc(C_DB_DATA_WIDTH-1 downto 2) :=
              nextCRC8_D8(data => db_data(C_DB_DATA_WIDTH-1 downto 2),
                          crc  => db_crc(C_DB_DATA_WIDTH-1 downto 2)
                         );
          end if;

        end if;

        -- Send CRC code when line_valid is falling (end of line)
        -- Send PRBS when requested
        if ( ((seq_db_line_valid='0') and (seq_db_line_valid_q='1')) and
             (reg_db_testpattern_en='0' or reg_db_frame_testpattern='1')
           ) or
           ((reg_db_prbs_en = '1') and testpattern_request) then
          db_data := db_crc;
        end if;

        ---------------------------
        -- Format and Assign Output
        ---------------------------
        db_ser_data <= db_data;

        -- Black Calibration
        if seq_db_black = '1' and
           not (reg_db_testpattern_en='1' or reg_db_prbs_en='1') then
          if reg_db_auto_blackcal_enable = '1' then
            db_ser_data <= to_unsigned(reg_db_black_offset, C_DB_DATA_WIDTH);
          else
            if reg_db_blackcal_offset_dec = '0' and
               (to_integer(db_data)+reg_db_blackcal_offset <= 1023) then
              db_ser_data <= db_data + to_unsigned(reg_db_blackcal_offset,
                                                   C_DB_DATA_WIDTH);
            end if;
            if reg_db_blackcal_offset_dec = '1' and
               (to_integer(db_data) >= reg_db_blackcal_offset) then
              db_ser_data <= db_data - to_unsigned(reg_db_blackcal_offset,
                                                   C_DB_DATA_WIDTH);
            end if;
          end if;
        end if;

      end if;

      --------
      -- Delay
      --------
      seq_db_line_valid_q     := seq_db_line_valid;
      reg_db_testpattern_en_q := reg_db_testpattern_en;
      reg_db_prbs_en_q        := reg_db_prbs_en;

    end if;

  end process;

end model;

