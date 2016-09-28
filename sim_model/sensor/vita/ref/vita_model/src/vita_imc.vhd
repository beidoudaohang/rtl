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
-- $Id: design#hdl#model#src#vita_imc.vhd,v 1.3 2012-12-06 03:11:33-07 ffynvr Exp $
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

library std;
  use std.textio.all;

library lib_model;
  use lib_model.pck_ppm.all;
  use lib_model.pck_frame_format.all;

library lib_vita_hdl;
  use lib_vita_hdl.pck_vita_model.all;

entity vita_imc is
  generic (
    G_SENSOR:      t_sensor_prop;
    G_IMG_NAME:    string   := "input";
    G_COLOR:       boolean  := false
  );
  port (
    ----- Register Interface -----
    reg_imc_pwd_n:     in std_logic;
    reg_db_8bit_mode:  in std_logic;

    ----- Control Path -----
    seq_imc_select:    in std_logic;
    seq_imc_black:     in std_logic;
    seq_imc_y_address: in natural;

    ----- IMC Interface -----
    imc_mux_column:   out t_real_array(G_SENSOR.x_width-1 downto 0)
  );
end vita_imc;

architecture model of vita_imc is

begin

  MAIN: process(seq_imc_select, seq_imc_y_address)

    ----------------------
    -- Enable & Power down
    ----------------------
    variable enable:          boolean;

    -------------------
    -- Image Containers
    -------------------
    variable image_grey:      t_grey_frame;
    variable image_color:     t_color_frame;
    file image_file:          text;
    variable imc_initialized: boolean := false;

    -----------------
    -- Row Addressing
    -----------------
    variable row_index:       integer;

  begin

    enable := (reg_imc_pwd_n = '1') or (G_SENSOR.id = VITA25k);

    if not imc_initialized then

      if G_COLOR = false then

        image_grey := init_frame(G_SENSOR.x_width, G_SENSOR.y_width, 255);
        read_image(image_grey, image_file, G_IMG_NAME & ".ppm");

      elsif G_COLOR = true then

        image_color := init_frame(G_SENSOR.x_width, G_SENSOR.y_width, 255);
        read_image(image_color, image_file, G_IMG_NAME & ".ppm");
      end if;

      imc_initialized := true;
    end if;

    if enable and seq_imc_select = '1' then

      row_index := seq_imc_y_address;

      for col_index in G_SENSOR.x_width - 1 downto 0 loop

        if G_COLOR = false then
          imc_mux_column(col_index) <=
            image_grey.m(row_index, col_index).g;
        else
          imc_mux_column(col_index) <=
            image_color.m(row_index, col_index).g;
          if row_index mod 2 = 0 and col_index mod 2 = 0 then
            imc_mux_column(col_index) <=
              image_color.m(row_index, col_index).r;
          end if;
          if row_index mod 2 = 1 and col_index mod 2 = 1 then
            imc_mux_column(col_index) <=
              image_color.m(row_index, col_index).b;
          end if;
        end if;

        if seq_imc_black = '1' then
          imc_mux_column(col_index) <= C_IMC_BLACK_LEVEL;
        end if;

      end loop;

    end if;

  end process;

end model;

