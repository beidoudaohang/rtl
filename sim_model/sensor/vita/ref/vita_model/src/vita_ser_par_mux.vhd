-- *********************************************************************
-- Copyright 2012, ON Semiconductor Corporation.
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
-- File           : $RCSfile: design#hdl#model#src#vita_ser_par_mux.vhd,v $
-- Author         : $Author: ffynvr $
-- Department     : CISP
-- Date           : $Date: 2012-12-06 03:11:32-07 $
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

entity vita_ser_par_mux is
  generic (
    G_SENSOR: t_sensor_prop
  );
  port (
    ----- Register Interface -----
    reg_ser_parallel:    in std_logic;

    ----- Control/Data Path -----
    db_ser_frame_valid:  in std_logic;
    db_ser_line_valid:   in std_logic;
    db_ser_data:         in t_db_data_array(G_SENSOR.kernel_size/2-1 downto 0);

    ----- Parallel Output Interface -----
    ser_io_pdata:       out unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    ser_io_frame_valid: out std_logic;
    ser_io_line_valid:  out std_logic;
    ser_io_clk:         out std_logic;

    ----- System -----
    cgen_ser_clk:        in std_logic;
    cgen_ser_load:       in std_logic;
    rgen_ser_reset_n:    in std_logic
  );
end vita_ser_par_mux;

architecture model of vita_ser_par_mux is

begin

  MAIN: process(cgen_ser_clk, rgen_ser_reset_n)
    variable mux_select: integer range 0 to G_SENSOR.kernel_size/2 - 1;
  begin

    if rgen_ser_reset_n = '0' then

      mux_select         := 0;
      ser_io_pdata       <= (others => '0');
      ser_io_frame_valid <= '0';
      ser_io_line_valid  <= '0';

    elsif cgen_ser_clk'event and cgen_ser_clk = '1' then

      if reg_ser_parallel = '1' then

        ser_io_pdata       <= db_ser_data(mux_select);
        ser_io_frame_valid <= db_ser_frame_valid;
        ser_io_line_valid  <= db_ser_line_valid;

        if (mux_select = G_SENSOR.kernel_size/2 - 1) or
           (cgen_ser_load = '1') then
          mux_select := 0;
        else
          mux_select := mux_select + 1;
        end if;

      end if;

    end if;
  end process;

  ser_io_clk <= cgen_ser_clk when reg_ser_parallel = '1' else
                '0';

end model;

