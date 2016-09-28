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
-- $Id: design#hdl#model#src#vita_adc.vhd,v 1.2 2012-12-06 03:11:33-07 ffynvr Exp $
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

library lib_vita_hdl;
  use lib_vita_hdl.pck_vita_model.all;

entity vita_adc is
  generic (
    G_SENSOR: t_sensor_prop
  );
  port (
    ----- MUX Interface -----
    mux_afe_signal:      in t_real_array(G_SENSOR.kernel_size - 1 downto 0);

    ----- ADC Interface -----
    afe_db_data:        out t_db_data_array(G_SENSOR.kernel_size - 1 downto 0);

    ----- System -----
    cgen_afe_clk:        in std_logic;
    rgen_afe_reset_n:    in std_logic

  );
end vita_adc;

architecture model of vita_adc is

begin

  MAIN: process(rgen_afe_reset_n, cgen_afe_clk)
  begin
    if rgen_afe_reset_n = '0' then
      afe_db_data <= (others => (others => '0'));

    elsif cgen_afe_clk'event and cgen_afe_clk = '1' then

      for db_channel in G_SENSOR.kernel_size - 1 downto 0 loop
        afe_db_data(db_channel) <= (others => '0');
        if mux_afe_signal(db_channel) >= 0.0 then
          afe_db_data(db_channel) <=
            to_unsigned(integer(mux_afe_signal(db_channel)*1023.0),
                        C_DB_DATA_WIDTH);
        end if;
      end loop;

    end if;

  end process;

end model;

