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
-- $Id: design#hdl#model#src#vita_db_sync.vhd,v 1.3 2012-12-06 03:11:33-07 ffynvr Exp $
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

entity vita_db_sync is
  port (
    ----- Register Interface -----
    reg_log_enable:               in std_logic;
    reg_db_8bit_mode:             in std_logic;
    reg_db_bl_frame_valid_enable: in std_logic;
    reg_db_bl_line_valid_enable:  in std_logic;
    reg_db_frame_sync:
      in unsigned(C_DB_DATA_WIDTH - C_DB_SYNC_WIDTH - 1 downto 0);

    reg_db_tr:                in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    reg_db_img:               in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    reg_db_bl:                in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    reg_db_crc:               in unsigned(C_DB_DATA_WIDTH - 1 downto 0);

    ----- Control Path -----
    seq_db_frame_valid:       in std_logic;
    seq_db_line_valid:        in std_logic;
    seq_db_black:             in std_logic;
    seq_db_sync:              in t_sync;
    seq_db_roi_id:            in natural;

    ----- DB Interface -----
    db_ser_frame_valid:      out std_logic;
    db_ser_line_valid:       out std_logic;
    db_ser_sync:             out t_db_data;

    ----- System -----
    cgen_log_clk:             in std_logic;
    rgen_log_reset_n:         in std_logic
  );
end vita_db_sync;

architecture model of vita_db_sync is

begin

  MAIN: process(rgen_log_reset_n, cgen_log_clk)

    ----------------
    -- Frame Control
    ----------------
    variable insert_roi_id:       boolean;

    --------
    -- Delay
    --------
    variable seq_db_line_valid_q: std_logic;

  begin

    if rgen_log_reset_n = '0' then
      insert_roi_id       := false;
      seq_db_line_valid_q := '0';
      db_ser_frame_valid  <= '0';
      db_ser_line_valid   <= '0';
      db_ser_sync         <= (others => '0');

    elsif cgen_log_clk'event and cgen_log_clk = '1' then

      if reg_log_enable = '1' then

        db_ser_sync  <= reg_db_tr;

        if seq_db_line_valid = '1' or seq_db_line_valid_q = '1' then

          db_ser_sync(C_DB_DATA_WIDTH - C_DB_SYNC_WIDTH - 1 downto 0) <=
            reg_db_frame_sync;

          case seq_db_sync is
            when SYNC_NONE =>
              db_ser_sync <= reg_db_tr;

            when SYNC_FS =>
              db_ser_sync(C_DB_DATA_WIDTH - 1 downto
                        C_DB_DATA_WIDTH - C_DB_SYNC_WIDTH) <= C_DB_SYNC_FS;

            when SYNC_FE =>
              db_ser_sync(C_DB_DATA_WIDTH - 1 downto
                        C_DB_DATA_WIDTH - C_DB_SYNC_WIDTH) <= C_DB_SYNC_FE;


            when SYNC_LS =>
              db_ser_sync(C_DB_DATA_WIDTH - 1 downto
                        C_DB_DATA_WIDTH - C_DB_SYNC_WIDTH) <= C_DB_SYNC_LS;

            when SYNC_LE =>
              db_ser_sync(C_DB_DATA_WIDTH - 1 downto
                        C_DB_DATA_WIDTH - C_DB_SYNC_WIDTH) <= C_DB_SYNC_LE;

            when SYNC_IMG =>
              db_ser_sync <= reg_db_img;

            when SYNC_BL  =>
              db_ser_sync <= reg_db_bl;

            when SYNC_ROI_ID =>
              db_ser_sync <= to_unsigned(seq_db_roi_id, C_DB_DATA_WIDTH);
              if reg_db_8bit_mode = '1' then
                db_ser_sync <= to_unsigned(seq_db_roi_id*16, C_DB_DATA_WIDTH);
              end if;

            when SYNC_CRC =>
              db_ser_sync <= reg_db_crc;

          end case;
        end if;

        db_ser_frame_valid <= seq_db_frame_valid;
        db_ser_line_valid  <= seq_db_line_valid;

        if seq_db_black = '1' then
          if reg_db_bl_frame_valid_enable = '0' then
            db_ser_frame_valid <= '0';
          end if;
          if reg_db_bl_line_valid_enable = '0' then
            db_ser_line_valid <= '0';
          end if;
        end if;

      end if;

      --------
      -- Delay
      --------
      seq_db_line_valid_q := seq_db_line_valid;

    end if;

  end process;

end model;

