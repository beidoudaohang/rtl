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
-- $Id: design#hdl#model#src#vita_rgen.vhd,v 1.2 2012-12-06 03:11:33-07 ffynvr Exp $
-- Author         : $Author: ffynvr $
-- Department     : CISP
-- Date           : $Date: 2012-12-06 03:11:33-07 $
-- Revision       : $Revision: 1.2 $
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

entity vita_rgen is

    port (
      ----- Resets -----
      rgen_log_reset_n:          out std_logic;
      rgen_afe_reset_n:          out std_logic;
      rgen_ser_reset_n:          out std_logic;

      ----- System -----
      cgen_log_clk:               in std_logic;
      cgen_afe_clk:               in std_logic;
      cgen_ser_clk:               in std_logic;
      io_sys_reset_n:             in std_logic
  );
end vita_rgen;

architecture model of vita_rgen is

  signal log_reset_n_qq: std_logic;
  signal log_reset_n_q:  std_logic;
  signal afe_reset_n_qq: std_logic;
  signal afe_reset_n_q:  std_logic;
  signal ser_reset_n_qq: std_logic;
  signal ser_reset_n_q:  std_logic;

begin

  MAIN_LOG: process(cgen_log_clk, io_sys_reset_n)
  begin

    if io_sys_reset_n = '0' then
      log_reset_n_qq <= '0';
      log_reset_n_q  <= '0';
    elsif cgen_log_clk'event and cgen_log_clk='1' then
      log_reset_n_qq <= log_reset_n_q;
      log_reset_n_q  <= '1';
    end if;

  end process;

  MAIN_AFE: process(cgen_afe_clk, io_sys_reset_n)
  begin

    if io_sys_reset_n = '0' then
      afe_reset_n_qq <= '0';
      afe_reset_n_q  <= '0';
    elsif cgen_afe_clk'event and cgen_afe_clk='1' then
      afe_reset_n_qq <= afe_reset_n_q;
      afe_reset_n_q  <= '1';
    end if;

  end process;

  MAIN_SER: process(cgen_ser_clk, io_sys_reset_n)
  begin

    if io_sys_reset_n = '0' then
      ser_reset_n_qq <= '0';
      ser_reset_n_q  <= '0';
    elsif cgen_ser_clk'event and cgen_ser_clk='1' then
      ser_reset_n_qq <= ser_reset_n_q;
      ser_reset_n_q  <= '1';
    end if;

  end process;

  rgen_log_reset_n <= log_reset_n_qq;
  rgen_afe_reset_n <= afe_reset_n_qq;
  rgen_ser_reset_n <= ser_reset_n_qq;

end model;

