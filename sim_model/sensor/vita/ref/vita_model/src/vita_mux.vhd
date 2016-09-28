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
-- $Id: design#hdl#model#src#vita_mux.vhd,v 1.3 2012-12-06 03:11:33-07 ffynvr Exp $
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

entity vita_mux is
  generic (
    G_SENSOR: t_sensor_prop
  );
  port (
    ----- Register Interface -----
    reg_mux_color:         in std_logic;
    reg_mux_pwd_n:         in std_logic;

    ----- Control Path -----
    seq_mux_address:       in integer range 0 to G_SENSOR.kernels - 1;
    seq_mux_address_valid: in std_logic;
    seq_mux_subsampling:   in std_logic;
    seq_mux_binning:       in std_logic;

    ----- IMC Interface -----
    imc_mux_column:        in t_real_array(G_SENSOR.x_width - 1 downto 0);

    ----- MUX Interface -----
    mux_afe_signal:       out t_real_array(G_SENSOR.kernel_size - 1 downto 0)
  );
end vita_mux;

architecture model of vita_mux is

begin

  MAIN: process(seq_mux_address, seq_mux_address_valid,
                seq_mux_subsampling, seq_mux_binning,
                reg_mux_color, reg_mux_pwd_n)

    variable kernel_even: t_real_array(G_SENSOR.kernel_size - 1 downto 0);
    variable kernel_odd:  t_real_array(G_SENSOR.kernel_size - 1 downto 0);
    variable sel:         unsigned(2 * G_SENSOR.kernel_size - 1 downto 0);

  begin
    if (reg_mux_pwd_n = '0') then
      mux_afe_signal <= (others => -1.0);

    else
      kernel_even := (others => -1.0);
      kernel_odd  := (others => -1.0);
      mux_afe_signal <= (others => -1.0);

      if (seq_mux_address_valid = '1') then
        if (seq_mux_subsampling = '0' and seq_mux_binning = '0') then
          if (seq_mux_address mod 2 = 0) then
            -- Even kernels
            for col in G_SENSOR.kernel_size-1 downto 0 loop
              mux_afe_signal(col) <=
                imc_mux_column((seq_mux_address) * G_SENSOR.kernel_size + col);
            end loop;

          else
            -- Odd kernels
            for col in G_SENSOR.kernel_size-1 downto 0 loop
              mux_afe_signal(col) <=
                imc_mux_column((seq_mux_address+1)*G_SENSOR.kernel_size-1-col);
            end loop;
          end if;

        else

          for col in G_SENSOR.kernel_size-1 downto 0 loop
            kernel_even(col) :=
              imc_mux_column((seq_mux_address) * G_SENSOR.kernel_size + col);

            kernel_odd(col) :=
              imc_mux_column((seq_mux_address+1+1)*G_SENSOR.kernel_size-1-col);
          end loop;

          sel := (others => '0');
          for mux_index in 0 to 2 * G_SENSOR.kernel_size - 1 loop
            case reg_mux_color is
              when '0' =>
                if mux_index mod 2 = 0 then
                  sel(mux_index) := '1';
                end if;
              when others =>
                if (mux_index mod 4 = 0) or (mux_index mod 4 = 1) then
                  sel(mux_index) := '1';
                end if;
            end case;
          end loop;

          for col in 0 to G_SENSOR.kernel_size - 1 loop
            if sel(col) = '1' then
              -- Selection from even kernel
              mux_afe_signal(col) <= kernel_even(col);
            end if;

            if sel(2 * G_SENSOR.kernel_size - 1 - col) = '1' then
              -- Selection from odd kernel
              mux_afe_signal(col) <= kernel_odd(col);
            end if;
          end loop;

        end if;

      end if;

    end if;
  end process;
end model;

