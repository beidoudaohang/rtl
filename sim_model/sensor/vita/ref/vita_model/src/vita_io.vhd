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
-- $Id: design#hdl#model#src#vita_io.vhd,v 1.3 2012-12-06 03:11:33-07 ffynvr Exp $
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
  use ieee.numeric_std.all;
  use ieee.std_logic_1164.all;

library lib_vita_hdl;
  use lib_vita_hdl.pck_vita_model.all;

entity vita_io is
  generic (
    G_SENSOR: t_sensor_prop
  );
  port (
    ------------------------------------------------------------------------
    -- Chip Pins
    ------------------------------------------------------------------------
    ----- SPI Interface -----
    mosi:                in std_logic;
    sck:                 in std_logic;
    ss_n:                in std_logic;
    miso:               out std_logic;

    ----- Triggers -----
    trigger0:            in std_logic;
    trigger1:            in std_logic;
    trigger2:            in std_logic;

    ----- Monitors -----
    monitor0:           out std_logic;
    monitor1:           out std_logic;
    monitor2:           out std_logic;

    ----- LVDS Interface -----
    clock_out:          out t_lvds;
    dout:               out t_lvds_array(G_SENSOR.kernel_size/2-1 downto 0);
    sync:               out t_lvds;

    ----- CMOS Interface -----
    pdata:              out unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    frame_valid:        out std_logic;
    line_valid:         out std_logic;
    clk_out:            out std_logic;

    ----- System -----
    clk_pll:             in std_logic;
    lvds_clk_in:         in t_lvds;
    reset_n:             in std_logic;

    ------------------------------------------------------------------------
    -- Internal Ports
    ------------------------------------------------------------------------
    ----- SPI IO Boundaries -----
    io_spi_mosi:        out std_logic;
    io_spi_sck:         out std_logic;
    io_spi_ss_n:        out std_logic;
    spi_io_miso:         in std_logic;

    ----- Chip Input Ports -----
    io_seq_trigger0:    out std_logic;
    io_seq_trigger1:    out std_logic;
    io_seq_trigger2:    out std_logic;

    ----- Chip Monitor -----
    seq_io_monitor0:     in std_logic;
    seq_io_monitor1:     in std_logic;
    seq_io_monitor2:     in std_logic;

    ----- Device LVDS I/O -----
    lvdstx_pad_clock:    in t_lvds;
    lvdstx_pad_data:     in t_lvds_array(G_SENSOR.kernel_size/2-1 downto 0);
    lvdstx_pad_sync:     in t_lvds;

    ----- CMOS I/O -----
    ser_io_pdata:        in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    ser_io_frame_valid:  in std_logic;
    ser_io_line_valid:   in std_logic;
    ser_io_clk:          in std_logic;

    ----- System -----
    io_pll_clk:         out std_logic;
    lvds_cgen_clk:      out t_lvds;
    io_sys_reset_n:     out std_logic
  );
end vita_io;

architecture model of vita_io is
begin

    -- SPI --
    io_spi_mosi         <= mosi;
    io_spi_sck          <= sck;
    io_spi_ss_n         <= ss_n;
    miso                <= spi_io_miso;

    -- Triggers --
    io_seq_trigger0     <= trigger0;
    io_seq_trigger1     <= trigger1;
    io_seq_trigger2     <= trigger2;

    -- Monitors --
    monitor0            <= seq_io_monitor0;
    monitor1            <= seq_io_monitor1;
    monitor2            <= seq_io_monitor2;

    -- LVDS Interface --
    clock_out           <= lvdstx_pad_clock;
    dout                <= lvdstx_pad_data;
    sync                <= lvdstx_pad_sync;

    -- CMOS Interface --
    pdata               <= ser_io_pdata;
    frame_valid         <= ser_io_frame_valid;
    line_valid          <= ser_io_line_valid;
    clk_out             <= ser_io_clk;

    -- System --
    io_pll_clk          <= clk_pll;
    lvds_cgen_clk       <= lvds_clk_in;
    io_sys_reset_n      <= reset_n;

end model;

