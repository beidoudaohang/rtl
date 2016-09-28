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
-- $Id: design#hdl#model#src#noiv1sn1300a.vhd,v 1.2 2012-11-30 07:22:05-07 ffynvr Exp $
-- Author         : $Author: ffynvr $
-- Department     : CISP
-- Date           : $Date: 2012-11-30 07:22:05-07 $
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
-- VITA1300 Model, LVDS Output Interface
--
-- Generics:
-- ---------
-- . G_COLOR:    selects monochrome or colour input file.
--
-- . G_IMG_NAME: Name of image input file, without extension (.ppm).
--               Without path it is assumed that the file is located
--               in the directory from which the simulator is invoked.
--
-- *********************************************************************

library ieee;
  use ieee.numeric_std.all;
  use ieee.std_logic_1164.all;

library lib_vita_hdl;
  use lib_vita_hdl.pck_vita_model.all;

entity noiv1sn1300a is
  generic(
    G_COLOR:    boolean := false;
    G_IMG_NAME: string := "input"
  );
  port(
    ----- SPI Interface -----
    mosi:            in std_logic;
    sck:             in std_logic;
    ss_n:            in std_logic;
    miso:           out std_logic;

    ----- Triggers -----
    trigger0:        in std_logic;
    trigger1:        in std_logic;
    trigger2:        in std_logic;

    ----- LVDS Interface -----
    clock_outp:     out std_logic;
    clock_outn:     out std_logic;

    doutp:          out unsigned(C_SENSOR_VITA1300.kernel_size/2-1 downto 0);
    doutn:          out unsigned(C_SENSOR_VITA1300.kernel_size/2-1 downto 0);

    syncp:          out std_logic;
    syncn:          out std_logic;

    ----- Monitor Outputs -----
    monitor0:       out std_logic;
    monitor1:       out std_logic;

    ----- System -----
    reset_n:         in std_logic;
    clk_pll:         in std_logic;
    lvds_clock_inp:  in std_logic;
    lvds_clock_inn:  in std_logic
  );
end noiv1sn1300a;

architecture model of noiv1sn1300a is

  component vita is
  generic(
    G_SENSOR:       t_sensor_prop;
    G_COLOR:        boolean;
    G_IMG_NAME:     string
  );
  port(
    ----- SPI Interface -----
    mosi:         in std_logic;
    sck:          in std_logic;
    ss_n:         in std_logic;
    miso:        out std_logic;

    ----- Configurations -----
    adc_mode:     in std_logic;

    ----- Triggers -----
    trigger0:     in std_logic;
    trigger1:     in std_logic;
    trigger2:     in std_logic;

    ----- Monitors -----
    monitor0:    out std_logic;
    monitor1:    out std_logic;
    monitor2:    out std_logic;

    ----- LVDS Interface -----
    clock_out:   out t_lvds;
    dout:        out t_lvds_array(G_SENSOR.kernel_size/2-1 downto 0);
    sync:        out t_lvds;

    ----- CMOS Interface -----
    pdata:       out unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    frame_valid: out std_logic;
    line_valid:  out std_logic;
    clk_out:     out std_logic;

    ----- System -----
    clk_pll:      in std_logic;
    lvds_clk_in:  in t_lvds;
    reset_n:      in std_logic
  );
  end component;

  signal clock_out:   t_lvds;
  signal dout:        t_lvds_array(C_SENSOR_VITA1300.kernel_size/2-1 downto 0);
  signal sync:        t_lvds;
  signal lvds_clk_in: t_lvds;
  signal adc_mode:    std_logic;

begin

  vita_1: vita
  generic map (
    G_SENSOR    => C_SENSOR_VITA1300,
    G_COLOR     => G_COLOR,
    G_IMG_NAME  => G_IMG_NAME
  )
  port map (
    mosi        => mosi,
    sck         => sck,
    ss_n        => ss_n,
    miso        => miso,
    adc_mode    => adc_mode,
    trigger0    => trigger0,
    trigger1    => trigger1,
    trigger2    => trigger1,
    monitor0    => monitor0,
    monitor1    => monitor1,
    monitor2    => open,
    clock_out   => clock_out,
    dout        => dout,
    sync        => sync,
    pdata       => open,
    frame_valid => open,
    line_valid  => open,
    clk_out     => open,
    clk_pll     => clk_pll,
    lvds_clk_in => lvds_clk_in,
    reset_n     => reset_n
  );

  clock_outp    <= clock_out.p;
  clock_outn    <= clock_out.n;
  syncp         <= sync.p;
  syncn         <= sync.n;

  GEN_DOUT:
  for dout_index in C_SENSOR_VITA1300.kernel_size/2-1 downto 0 generate
    doutp(dout_index) <= dout(dout_index).p;
    doutn(dout_index) <= dout(dout_index).n;
  end generate;

  lvds_clk_in.p <= lvds_clock_inp;
  lvds_clk_in.n <= lvds_clock_inn;

  adc_mode <= '0';

end model;

configuration cfg_noiv1sn1300a_model of noiv1sn1300a is
  for model
    for vita_1: vita
      use configuration lib_vita_hdl.cfg_vita_model;
    end for;
  end for;
end cfg_noiv1sn1300a_model;

