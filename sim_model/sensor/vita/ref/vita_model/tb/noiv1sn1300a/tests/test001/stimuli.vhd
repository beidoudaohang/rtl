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
-- $Id: design#hdl#model#tb#noiv1sn1300a#tests#test001#stimuli.vhd,v 1.2 2012-12-06 03:14:30-07 ffynvr Exp $
-- Author         : $Author: ffynvr $
-- Department     : CISP
-- Date           : $Date: 2012-12-06 03:14:30-07 $
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

library lib_tb_vita_hdl;
  use lib_tb_vita_hdl.pck_tb_vita_model.all;
  use lib_tb_vita_hdl.pck_spi_upload_model.all;

entity stimuli is
  port (
    ----- SPI Model Interface -----
    spi_command:   out t_spi_command;
    spi_ready:      in boolean;

    ----- Sensor Interface -----
    trigger0:      out std_logic;
    trigger1:      out std_logic;
    trigger2:      out std_logic;

    ------ System -----
    clk:            in std_logic;
    reset_n:        in std_logic
  );
end stimuli;

architecture model of stimuli is

  signal roi_active: unsigned(7 downto 0);
  signal roi_config: t_roi_configuration_array(7 downto 0);

begin

  MAIN: process

  begin

    trigger0    <= '0';
    trigger1    <= '0';
    trigger2    <= '0';

    roi_active  <= (others => '0');
    roi_config  <= (others => C_ROI_CONFIGURATION_RESET);
    spi_command <= C_SPI_COMMAND_RESET;

    wait until reset_n = '1';
    wait for 1 us;

    -- ROI Configurations
    roi_config(1).y_start <= 312;
    roi_config(1).y_end   <= 503;
    roi_config(1).x_start <= 1;
    roi_config(1).x_end   <= 45;
    roi_active(1)         <= '1';

    roi_config(7).y_start <= 800;
    roi_config(7).y_end   <= 1000;
    roi_config(7).x_start <= 0;
    roi_config(7).x_end   <= 159;
    roi_active(7)         <= '1';

    -- Enable Clock Managment - Part 1
    -----------------------------------
    -- 1. Configure Sensor Type
    spi_write(spi_command, 2, 16#0000#);
    wait until spi_ready;

    -- 2. Configure Clock Management
    spi_write(spi_command, 32, 16#2004#);
    wait until spi_ready;

    -- 3. Configure Clock Management
    spi_write(spi_command, 20, 16#0000#);
    wait until spi_ready;

    -- 4. Configure PLL
    spi_write(spi_command, 17, 16#2113#);
    wait until spi_ready;

    -- 5. Configure PLL Lock Detect
    spi_write(spi_command, 26, 16#2280#);
    wait until spi_ready;

    -- 6. Configure PLL Lock Detect
    spi_write(spi_command, 27, 16#3D2D#);
    wait until spi_ready;

    -- 7. Release PLL Soft Reset
    spi_write(spi_command, 8, 16#0000#);
    wait until spi_ready;

    -- 8. Enable PLL
    spi_write(spi_command, 16, 16#0003#);
    wait until spi_ready;

    -- Enable Clock Management - Part 2
    -----------------------------------
    -- 1. Release CGEN soft reset
    spi_write(spi_command, 9, 16#0000#);
    wait until spi_ready;

    -- 2. Enable Logic Clock
    spi_write(spi_command, 32, 16#2006#);
    wait until spi_ready;

    -- 3. Enable Logic
    spi_write(spi_command, 34, 16#0001#);
    wait until spi_ready;

    -- Required Register Upload
    ---------------------------
    -- Omitted from this model

    -- Soft Power Up
    ----------------
    -- 1. Enable Clock Distribution
    spi_write(spi_command, 32, 16#2007#);
    wait until spi_ready;

    -- 2. Release Soft Reset
    spi_write(spi_command, 10, 16#0000#);
    wait until spi_ready;

    -- 3. Enable Bias
    spi_write(spi_command, 64, 16#0001#);
    wait until spi_ready;

    -- 4. Enable CP
    spi_write(spi_command, 72, 16#0203#);
    wait until spi_ready;

    -- 5. Enable Column Multiplexer
    spi_write(spi_command, 40, 16#0003#);
    wait until spi_ready;

    -- 6. Enable AFE
    spi_write(spi_command, 48, 16#0001#);
    wait until spi_ready;

    -- 7. Enable LVDS outputs
    spi_write(spi_command, 112, 16#0007#);
    wait until spi_ready;

    -- Configure for Image Grabbing
    -------------------------------
    -- Integration control
    spi_write(spi_command, 194, 16#0000#);
    wait until spi_ready;

    -- ROI Configurations (defined by roi_config and roi_active)
    for roi_index in 7 downto 0 loop
      if roi_active(roi_index)='1' then
        -- x_start/x_end
        spi_write(spi_command,
                  256 + roi_index*3,
                  roi_config(roi_index).x_start +
                  roi_config(roi_index).x_end*2**8
                 );
        wait until spi_ready;

        -- y_start
        spi_write(spi_command,
                  257 + roi_index*3,
                  roi_config(roi_index).y_start
                 );
        wait until spi_ready;

        -- y_end
        spi_write(spi_command,
                  258 + roi_index*3,
                  roi_config(roi_index).y_end
                 );
        wait until spi_ready;
      end if;
    end loop;

    -- ROI Active Configuration
    spi_write(spi_command, 195, to_integer(roi_active));
    wait until spi_ready;

    -- Mult Timer
    spi_write(spi_command, 199, 106);
    wait until spi_ready;

    -- Reset Time
    spi_write(spi_command, 200, 700);
    wait until spi_ready;

    -- Integration Time
    spi_write(spi_command, 201, 30);
    wait until spi_ready;

    -- Enable Sequencer in Global shutter mode
    spi_write(spi_command, 192, 1);
    wait until spi_ready;

    wait for 13 us;

    wait;

  end process;

end model;

