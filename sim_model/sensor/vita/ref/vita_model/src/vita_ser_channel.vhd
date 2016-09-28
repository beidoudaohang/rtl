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
-- $Id: design#hdl#model#src#vita_ser_channel.vhd,v 1.3 2012-12-06 03:11:32-07 ffynvr Exp $
-- Author         : $Author: ffynvr $
-- Department     : CISP
-- Date           : $Date: 2012-12-06 03:11:32-07 $
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

entity vita_ser_channel is
  port (
    ----- Register Interface -----
    reg_cgen_adc_mode:  in std_logic;
    reg_lvds_pwd_n:     in std_logic;

    ----- Data Path -----
    db_ser_data:        in t_db_data;
    lvdstx_pad_data:   out t_lvds;

    ----- Cascade -----
    ser_ser_data:       in std_logic;
    ser_ser_data_next: out std_logic;

    ----- System -----
    cgen_ser_clk:       in std_logic;
    cgen_ser_load:      in std_logic;
    rgen_ser_reset_n:   in std_logic
  );
end vita_ser_channel;

architecture model of vita_ser_channel is

  signal par_data: t_db_data;
  signal ser_data: std_logic;

begin

  MAIN: process(cgen_ser_clk, rgen_ser_reset_n)
  begin
    if rgen_ser_reset_n = '0' then
      par_data <= (others => '0');
      ser_data <= '0';
    elsif cgen_ser_clk'event then
      ser_data <= par_data(C_DB_DATA_WIDTH - 1);
      par_data <= par_data sll 1;
      if cgen_ser_load = '1' and cgen_ser_clk = '0' then
        par_data <= db_ser_data;
      else
        par_data(0) <= ser_ser_data;
        if reg_cgen_adc_mode = '1' then
          par_data(2) <= ser_ser_data;
        end if;
      end if;
    end if;
  end process;

  lvdstx_pad_data.p <= ser_data when reg_lvds_pwd_n = '1' else
                       'Z';
  lvdstx_pad_data.n <= not ser_data when reg_lvds_pwd_n = '1' else
                       'Z';

  ser_ser_data_next <= ser_data;

end model;

