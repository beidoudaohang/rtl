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
-- $Id: design#hdl#model#src#vita_ser.vhd,v 1.4 2012-12-06 03:11:32-07 ffynvr Exp $
-- Author         : $Author: ffynvr $
-- Department     : CISP
-- Date           : $Date: 2012-12-06 03:11:32-07 $
-- Revision       : $Revision: 1.4 $
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

entity vita_ser is
  generic (
    G_SENSOR: t_sensor_prop
  );
  port (
    ----- Register Interface -----
    reg_cgen_adc_mode:        in std_logic;
    reg_ser_parallel:         in std_logic;
    reg_lvds_clock_out_pwd_n: in std_logic;
    reg_lvds_sync_pwd_n:      in std_logic;
    reg_lvds_data_pwd_n:      in std_logic;

    ----- DB Interface -----
    db_ser_frame_valid:  in std_logic;
    db_ser_line_valid:   in std_logic;
    db_ser_clock:        in t_db_data;
    db_ser_sync:         in t_db_data;
    db_ser_data:         in t_db_data_array(G_SENSOR.kernel_size/2-1 downto 0);

    ----- Serializer Interface -----
    lvdstx_pad_clock:   out t_lvds;
    lvdstx_pad_sync:    out t_lvds;
    lvdstx_pad_data:    out t_lvds_array(G_SENSOR.kernel_size/2-1 downto 0);

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
end vita_ser;

architecture model of vita_ser is

  component vita_ser_channel is
  port (
    ----- Register Interface -----
    reg_cgen_adc_mode:    in std_logic;
    reg_lvds_pwd_n:       in std_logic;

    ----- Data Path -----
    db_ser_data:          in t_db_data;
    lvdstx_pad_data:     out t_lvds;

    ----- Cascade -----
    ser_ser_data:       in std_logic;
    ser_ser_data_next: out std_logic;

    ----- System -----
    cgen_ser_clk:         in std_logic;
    cgen_ser_load:        in std_logic;
    rgen_ser_reset_n:     in std_logic
  );
  end component;

  component vita_ser_par_mux is
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
    cgen_ser_clk:      in std_logic;
    cgen_ser_load:     in std_logic;
    rgen_ser_reset_n:  in std_logic
  );
  end component;

  signal serc_serc_data: std_logic;
  signal sers_sers_data: std_logic;
  signal serd_serd_data: unsigned(G_SENSOR.kernel_size/2 downto 0);

begin

  vita_ser_channel_clock: vita_ser_channel
  port map (
    reg_cgen_adc_mode => reg_cgen_adc_mode,
    reg_lvds_pwd_n    => reg_lvds_clock_out_pwd_n,
    db_ser_data       => db_ser_clock,
    lvdstx_pad_data   => lvdstx_pad_clock,
    ser_ser_data      => serc_serc_data,
    ser_ser_data_next => serc_serc_data,
    cgen_ser_clk      => cgen_ser_clk,
    cgen_ser_load     => cgen_ser_load,
    rgen_ser_reset_n  => rgen_ser_reset_n
  );

  vita_ser_channel_sync: vita_ser_channel
  port map (
    reg_cgen_adc_mode => reg_cgen_adc_mode,
    reg_lvds_pwd_n    => reg_lvds_sync_pwd_n,
    db_ser_data       => db_ser_sync,
    lvdstx_pad_data   => lvdstx_pad_sync,
    ser_ser_data      => sers_sers_data,
    ser_ser_data_next => sers_sers_data,
    cgen_ser_clk      => cgen_ser_clk,
    cgen_ser_load     => cgen_ser_load,
    rgen_ser_reset_n  => rgen_ser_reset_n
  );

  serd_serd_data(0) <= '0';

  GEN_VITA_SER_CHANNEL_DATA:
  for db_channel in G_SENSOR.kernel_size/2-1 downto 0 generate
    vita_ser_channel_data: vita_ser_channel
    port map (
      reg_cgen_adc_mode => reg_cgen_adc_mode,
      reg_lvds_pwd_n    => reg_lvds_data_pwd_n,
      db_ser_data       => db_ser_data(db_channel),
      lvdstx_pad_data   => lvdstx_pad_data(db_channel),
      ser_ser_data      => serd_serd_data(db_channel),
      ser_ser_data_next => serd_serd_data(db_channel + 1),
      cgen_ser_clk      => cgen_ser_clk,
      cgen_ser_load     => cgen_ser_load,
      rgen_ser_reset_n  => rgen_ser_reset_n
    );
  end generate;

  vita_ser_par_mux_0: vita_ser_par_mux
  generic map (
    G_SENSOR => G_SENSOR
  )
  port map (
    reg_ser_parallel    => reg_ser_parallel,
    db_ser_frame_valid  => db_ser_frame_valid,
    db_ser_line_valid   => db_ser_line_valid,
    db_ser_data         => db_ser_data,
    ser_io_pdata        => ser_io_pdata,
    ser_io_frame_valid  => ser_io_frame_valid,
    ser_io_line_valid   => ser_io_line_valid,
    ser_io_clk          => ser_io_clk,
    cgen_ser_clk        => cgen_ser_clk,
    cgen_ser_load       => cgen_ser_load,
    rgen_ser_reset_n    => rgen_ser_reset_n
  );

end model;

configuration cfg_vita_ser_model of vita_ser is

  for model

    for vita_ser_channel_clock: vita_ser_channel
      use entity lib_vita_hdl.vita_ser_channel(model);
    end for;

    for vita_ser_channel_sync: vita_ser_channel
      use entity lib_vita_hdl.vita_ser_channel(model);
    end for;

    for GEN_VITA_SER_CHANNEL_DATA
      for vita_ser_channel_data: vita_ser_channel
        use entity lib_vita_hdl.vita_ser_channel(model);
      end for;
    end for;

    for vita_ser_par_mux_0: vita_ser_par_mux
      use entity lib_vita_hdl.vita_ser_par_mux(model);
    end for;

  end for;

end cfg_vita_ser_model;

