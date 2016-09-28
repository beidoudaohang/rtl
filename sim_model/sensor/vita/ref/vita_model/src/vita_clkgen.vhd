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
-- $Id: design#hdl#model#src#vita_clkgen.vhd,v 1.3 2012-12-06 03:11:33-07 ffynvr Exp $
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

entity vita_clkgen is
    generic(
      G_SENSOR:                     t_sensor_prop
    );
    port (
      ----- Configuration Pins -----
      adc_mode:                   in std_logic;

      ----- Configuration Registers -----
      reg_cgen_enable_analog:     in std_logic;
      reg_cgen_enable_log:        in std_logic;
      reg_cgen_select_pll:        in std_logic;
      reg_cgen_adc_mode:          in std_logic;

      ----- Generated Clocks -----
      cgen_log_clk:              out std_logic;
      cgen_afe_clk:              out std_logic;
      cgen_ser_clk:              out std_logic;
      cgen_ser_load:             out std_logic;

      ----- System -----
      pll_cgen_clk:               in std_logic;
      lvds_cgen_clk:              in t_lvds;
      io_sys_reset_n:             in std_logic
  );
end vita_clkgen;

architecture model of vita_clkgen is

  signal reset_n_qq:                std_logic;
  signal reset_n_q:                 std_logic;
  signal clk:                       std_logic;
  signal log_clk:                   std_logic;
  signal afe_clk:                   std_logic;
  signal ser_load:                  std_logic;
  signal reg_cgen_enable_analog_qq: std_logic;
  signal reg_cgen_enable_analog_q:  std_logic;
  signal reg_cgen_enable_log_qq:    std_logic;
  signal reg_cgen_enable_log_q:     std_logic;

begin

  clk <=
    (lvds_cgen_clk.p and not lvds_cgen_clk.n) when G_SENSOR.id = VITA25K else
    pll_cgen_clk when reg_cgen_select_pll = '1' else
    (lvds_cgen_clk.p and not lvds_cgen_clk.n);

  RESET_SYNC: process(clk, io_sys_reset_n)
  begin
    if io_sys_reset_n = '0' then
      reset_n_qq <= '0';
      reset_n_q  <= '0';
    elsif clk'event and clk = '1' then
      reset_n_qq <= reset_n_q;
      reset_n_q  <= '1';
    end if;
  end process;

  MAIN: process(clk, reset_n_qq)
    variable phase_count:      integer;
    variable modulo_count:     integer;
  begin
    if reset_n_qq = '0' then
      log_clk                   <= '0';
      afe_clk                   <= '0';
      ser_load                  <= '0';
      reg_cgen_enable_analog_qq <= '0';
      reg_cgen_enable_analog_q  <= '0';
      reg_cgen_enable_log_qq    <= '0';
      reg_cgen_enable_log_q     <= '0';
      phase_count               := 0;
      cgen_log_clk              <= '0';
      cgen_afe_clk              <= '0';
      cgen_ser_load             <= '0';

    elsif clk'event then

      log_clk  <= '0';
      ser_load <= '0';

      modulo_count := 10;
      if (G_SENSOR.id  = VITA25K and adc_mode = '1') or
         (G_SENSOR.id /= VITA25K and reg_cgen_adc_mode = '1') then
        modulo_count := 8;
      end if;

      ----------
      -- log_clk
      ----------
      if phase_count < modulo_count/2 then
        log_clk <= '1';
      end if;

      ----------
      -- afe_clk
      ----------
      if reg_cgen_enable_analog_qq = '1' then
        if phase_count = 0 then
          afe_clk <= not afe_clk;
        end if;
      end if;

      -----------
      -- ser_load
      -----------
      if phase_count < 2 then
        ser_load <= '1';
      end if;

      phase_count := phase_count + 1;
      if phase_count = modulo_count then
        phase_count := 0;
      end if;

      cgen_log_clk <= '0';
      if reg_cgen_enable_log_qq = '1' then
        cgen_log_clk <= log_clk;
      end if;

      cgen_afe_clk <= afe_clk;

      cgen_ser_load <= ser_load;

      ------------------
      -- Synchronization
      ------------------
      reg_cgen_enable_log_qq    <= reg_cgen_enable_log_q;
      reg_cgen_enable_log_q     <= reg_cgen_enable_log;

      reg_cgen_enable_analog_qq <= reg_cgen_enable_analog_q;
      reg_cgen_enable_analog_q  <= reg_cgen_enable_analog;

    end if;

  end process;

  cgen_ser_clk <= clk;

end model;

