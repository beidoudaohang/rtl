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
-- $Id: design#hdl#model#src#vita_pll.vhd,v 1.3 2012-12-06 03:11:33-07 ffynvr Exp $
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

entity vita_pll is
  port (
    ----- Registers -----
    reg_pll_pwd_n:        in std_logic;
    reg_pll_en:           in std_logic;
    reg_pll_bypass:       in std_logic;
    reg_pll_mdiv:         in integer;
    reg_pll_ndiv:         in integer;
    reg_pll_pdiv:         in integer;

    pll_reg_lock:        out std_logic;

    ----- Generated Clock -----
    pll_cgen_clk:        out std_logic;

    ----- System -----
    io_pll_clk:           in std_logic;
    io_sys_reset_n:       in std_logic
  );
end vita_pll;

architecture model of vita_pll is

  signal pll_en:               boolean;
  signal lock:                 boolean;
  signal lock_q:               boolean;
  signal lock_qq:              boolean;
  signal generated_clk_period: time := C_PLL_GEN_CLOCK_PERIOD;
  signal generated_clk:        std_logic;
  signal reg_pll_bypass_qq:    std_logic;
  signal reg_pll_bypass_q:     std_logic;

begin

  pll_en <= (reg_pll_en = '1') and (reg_pll_pwd_n = '1');

  MAIN: process(io_pll_clk)
    variable previous_tick:       time := 0 ns;
    variable pll_clk_period:      time;
    variable prev_pll_clk_period: time := 0 ns;
    variable lock_count:          integer := 0;
  begin
    if io_sys_reset_n = '0' or not pll_en then
      reg_pll_bypass_qq <= '0';
      reg_pll_bypass_q  <= '0';
      lock              <= false;
      previous_tick     := now;
    elsif io_pll_clk'event and io_pll_clk = '1' then

      pll_clk_period := now - previous_tick;

      case lock is
        when false =>
          if pll_clk_period = prev_pll_clk_period then
            lock_count := lock_count + 1;
          else
            lock_count := 0;
          end if;

          if lock_count >= C_PLL_LOCK_COUNT then
            lock_count := 0;
            lock       <= true;
          end if;

          prev_pll_clk_period := pll_clk_period;

        when true =>
          if pll_clk_period /= prev_pll_clk_period then
            lock_count := lock_count + 1;
          else
            lock_count := 0;
          end if;

          if lock_count >= C_PLL_UNLOCK_COUNT then
            lock_count := 0;
            lock       <= false;
          end if;

      end case;

      previous_tick := now;

      generated_clk_period <= pll_clk_period / 5;
      if reg_pll_mdiv = C_PLL_MDIV_8BIT then
        generated_clk_period <= pll_clk_period / 4;
      end if;

      reg_pll_bypass_qq <= reg_pll_bypass_q;
      reg_pll_bypass_q  <= reg_pll_bypass;

    end if;
  end process;

  CLK_GEN: process
  begin
    generated_clk <= '0','1' after generated_clk_period/2;
    wait for generated_clk_period;
  end process;

  SYNC_LOCK: process(generated_clk, io_sys_reset_n)
  begin
    if io_sys_reset_n = '0' then
      lock_qq <= false;
      lock_q  <= false;
    elsif generated_clk'event and generated_clk = '1' then
      lock_qq <= lock_q;
      lock_q  <= lock;
    end if;
  end process;

  pll_cgen_clk <= '0'           when not pll_en                else
                  io_pll_clk    when (reg_pll_bypass_qq = '1') else
                  generated_clk when lock_qq                   else
                  '0';

  pll_reg_lock <= '1' when lock_qq else
                  '0';

end model;
