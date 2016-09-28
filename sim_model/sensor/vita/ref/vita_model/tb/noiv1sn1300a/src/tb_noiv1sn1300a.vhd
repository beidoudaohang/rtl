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
-- $Id: design#hdl#model#tb#noiv1sn1300a#src#tb_noiv1sn1300a.vhd,v 1.3 2012-12-06 03:14:30-07 ffynvr Exp $
-- Author         : $Author: ffynvr $
-- Department     : CISP
-- Date           : $Date: 2012-12-06 03:14:30-07 $
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

library lib_tb_vita_hdl;
  use lib_tb_vita_hdl.pck_spi_upload_model.all;

library lib_tb_vita_tc;

entity tb_noiv1sn1300a is
  generic(
    G_COLOR:    boolean       := false;
    G_IMG_NAME: string        := "input"
  );
end tb_noiv1sn1300a;

architecture model of tb_noiv1sn1300a is

  constant C_COLOR:    boolean := false;
  constant C_IMG_NAME: string := "input";

  component noiv1sn1300a is
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
  end component;

  component spi_upload_model is
  port (
    ----- Test bench Interface -----
    spi_command:    in t_spi_command;
    spi_ready:     out boolean;

    ----- SPI Interface -----
    mosi:          out std_logic;
    ss_n:          out std_logic;
    sck:           out std_logic;
    miso:           in std_logic
  );
  end component;

  component stimuli is
  port (
    ----- SPI Model Interface -----
    spi_command:      out t_spi_command;
    spi_ready:         in boolean;

    ----- Sensor Interface -----
    trigger0:         out std_logic;
    trigger1:         out std_logic;
    trigger2:         out std_logic;

    ------ System -----
    clk:               in std_logic;
    reset_n:           in std_logic
  );
  end component;

  constant C_CLOCK_PERIOD: time := 16 ns;
  constant C_RESET_TIME:   time := 200 ns;

  signal mosi:           std_logic;
  signal sck:            std_logic;
  signal ss_n:           std_logic;
  signal miso:           std_logic;
  signal trigger0:       std_logic;
  signal trigger1:       std_logic;
  signal trigger2:       std_logic;
  signal monitor0:       std_logic;
  signal monitor1:       std_logic;
  signal clock_outp:     std_logic;
  signal clock_outn:     std_logic;

  signal doutp:          unsigned(C_SENSOR_VITA1300.kernel_size/2-1 downto 0);
  signal doutn:          unsigned(C_SENSOR_VITA1300.kernel_size/2-1 downto 0);

  signal syncp:          std_logic;
  signal syncn:          std_logic;

  signal reset_n:        std_logic;
  signal spi_command:    t_spi_command;
  signal spi_ready:      boolean;

  signal clk_pll:        std_logic;
  signal lvds_clock_inp: std_logic;
  signal lvds_clock_inn: std_logic;

begin

  lvds_clock_inp <= '0';
  lvds_clock_inn <= '1';

  CLK_GEN: process
  begin
    clk_pll <= '0','1' after C_CLOCK_PERIOD/2;
    wait for C_CLOCK_PERIOD;
  end process;

  RESET_GEN: process
  begin
    reset_n <= '0','1' after C_RESET_TIME;
    wait;
  end process;

  noiv1sn1300a_1: noiv1sn1300a
  generic map(
    G_COLOR     => C_COLOR,
    G_IMG_NAME  => C_IMG_NAME
  )
  port map(
    mosi           => mosi,
    sck            => sck,
    ss_n           => ss_n,
    miso           => miso,
    trigger0       => trigger0,
    trigger1       => trigger1,
    trigger2       => trigger2,
    clock_outp     => clock_outp,
    clock_outn     => clock_outn,
    doutp          => doutp,
    doutn          => doutn,
    syncp          => syncp,
    syncn          => syncn,
    monitor0       => monitor0,
    monitor1       => monitor1,
    reset_n        => reset_n,
    clk_pll        => clk_pll,
    lvds_clock_inp => lvds_clock_inp,
    lvds_clock_inn => lvds_clock_inn
  );

  spi_upload_model_1: spi_upload_model
  port map (
    spi_command   => spi_command,
    spi_ready     => spi_ready,
    mosi          => mosi,
    ss_n          => ss_n,
    sck           => sck,
    miso          => miso
  );

  stimuli_1: stimuli
  port map (
    spi_command      => spi_command,
    spi_ready        => spi_ready,
    trigger0         => trigger0,
    trigger1         => trigger1,
    trigger2         => trigger2,
    clk              => clk_pll,
    reset_n          => reset_n
  );

end model;

configuration cfg_tb_noiv1sn1300a_model of tb_noiv1sn1300a is
  for model

    for noiv1sn1300a_1: noiv1sn1300a
      use configuration lib_vita_hdl.cfg_noiv1sn1300a_model;
    end for;

    for spi_upload_model_1: spi_upload_model
      use entity lib_tb_vita_hdl.spi_upload_model(model);
    end for;

    for stimuli_1: stimuli
      use entity lib_tb_vita_tc.stimuli(model);
    end for;

  end for;
end cfg_tb_noiv1sn1300a_model;

