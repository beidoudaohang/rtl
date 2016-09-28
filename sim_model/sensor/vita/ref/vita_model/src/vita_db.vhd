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
-- $Id: design#hdl#model#src#vita_db.vhd,v 1.3 2012-12-06 03:11:33-07 ffynvr Exp $
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

entity vita_db is
  generic (
    G_SENSOR: t_sensor_prop
  );
  port (
    ----- Register Interface -----
    reg_log_enable:               in std_logic;
    reg_db_8bit_mode:             in std_logic;
    reg_db_bl_frame_valid_enable: in std_logic;
    reg_db_bl_line_valid_enable:  in std_logic;
    reg_db_auto_blackcal_enable:  in std_logic;
    reg_db_black_offset:          in natural;
    reg_db_blackcal_offset:       in natural;
    reg_db_blackcal_offset_dec:   in std_logic;
    reg_db_crc_seed:              in std_logic;
    reg_db_testpattern_en:        in std_logic;
    reg_db_prbs_en:               in std_logic;
    reg_db_inc_testpattern:       in std_logic;
    reg_db_frame_testpattern:     in std_logic;

    reg_db_testpattern:
      in t_db_data_array(G_SENSOR.kernel_size/2-1 downto 0);

    reg_db_trainingpattern:   in unsigned(C_DB_DATA_WIDTH - 1 downto 0);

    reg_db_frame_sync:
      in unsigned(C_DB_DATA_WIDTH - C_DB_SYNC_WIDTH - 1 downto 0);

    reg_db_tr:                in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    reg_db_img:               in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    reg_db_bl:                in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    reg_db_crc:               in unsigned(C_DB_DATA_WIDTH - 1 downto 0);

    ----- Control Path -----
    seq_db_frame_valid:       in std_logic;
    seq_db_line_valid:        in std_logic;
    seq_db_black:             in std_logic;
    seq_db_sync:              in t_sync;
    seq_db_roi_id:            in natural;

    ----- ADC Interface -----
    afe_db_data:
      in t_db_data_array(G_SENSOR.kernel_size - 1 downto 0);

    ----- DB Interface -----
    db_ser_frame_valid:   out std_logic;
    db_ser_line_valid:    out std_logic;
    db_ser_clock:         out t_db_data;
    db_ser_sync:          out t_db_data;
    db_ser_data:
      out t_db_data_array(G_SENSOR.kernel_size/2 - 1 downto 0);

    ----- System -----
    cgen_log_clk:          in std_logic;
    rgen_log_reset_n:      in std_logic
  );
end vita_db;

architecture model of vita_db is

  component vita_db_sync is
  port (
    ----- Register Interface -----
    reg_log_enable:               in std_logic;
    reg_db_8bit_mode:             in std_logic;
    reg_db_bl_frame_valid_enable: in std_logic;
    reg_db_bl_line_valid_enable:  in std_logic;
    reg_db_frame_sync:
      in unsigned(C_DB_DATA_WIDTH - C_DB_SYNC_WIDTH - 1 downto 0);

    reg_db_tr:                in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    reg_db_img:               in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    reg_db_bl:                in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    reg_db_crc:               in unsigned(C_DB_DATA_WIDTH - 1 downto 0);

    ----- Control Path -----
    seq_db_frame_valid:       in std_logic;
    seq_db_line_valid:        in std_logic;
    seq_db_black:             in std_logic;
    seq_db_sync:              in t_sync;
    seq_db_roi_id:            in natural;

    ----- DB Interface -----
    db_ser_frame_valid:      out std_logic;
    db_ser_line_valid:       out std_logic;
    db_ser_sync:             out t_db_data;

    ----- System -----
    cgen_log_clk:             in std_logic;
    rgen_log_reset_n:         in std_logic
  );
  end component;

  component vita_db_data is
  port (
    ----- Register Interface -----
    reg_log_enable:              in std_logic;
    reg_db_8bit_mode:            in std_logic;
    reg_db_auto_blackcal_enable: in std_logic;
    reg_db_black_offset:         in natural;
    reg_db_blackcal_offset:      in natural;
    reg_db_blackcal_offset_dec:  in std_logic;
    reg_db_crc_seed:             in std_logic;
    reg_db_testpattern_en:       in std_logic;
    reg_db_prbs_en:              in std_logic;
    reg_db_inc_testpattern:      in std_logic;
    reg_db_frame_testpattern:    in std_logic;
    reg_db_testpattern:          in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    reg_db_trainingpattern:      in unsigned(C_DB_DATA_WIDTH - 1 downto 0);

    ----- Control Path -----
    seq_db_line_valid:        in std_logic;
    seq_db_black:             in std_logic;

    ----- ADC Interface -----
    afe_db_data:              in t_db_data_array(1 downto 0);

    ----- DB Interface -----
    db_ser_data:             out t_db_data;

    ----- System -----
    cgen_log_clk:             in std_logic;
    rgen_log_reset_n:         in std_logic
  );
  end component;

begin

  db_ser_clock <= to_unsigned(16#2AA#, C_DB_DATA_WIDTH);

  vita_db_sync_1: vita_db_sync
  port map (
    reg_log_enable               => reg_log_enable,
    reg_db_8bit_mode             => reg_db_8bit_mode,
    reg_db_bl_frame_valid_enable => reg_db_bl_frame_valid_enable,
    reg_db_bl_line_valid_enable  => reg_db_bl_line_valid_enable,
    reg_db_frame_sync            => reg_db_frame_sync,
    reg_db_tr                    => reg_db_tr,
    reg_db_img                   => reg_db_img,
    reg_db_bl                    => reg_db_bl,
    reg_db_crc                   => reg_db_crc,
    seq_db_frame_valid           => seq_db_frame_valid,
    seq_db_line_valid            => seq_db_line_valid,
    seq_db_black                 => seq_db_black,
    seq_db_sync                  => seq_db_sync,
    seq_db_roi_id                => seq_db_roi_id,
    db_ser_frame_valid           => db_ser_frame_valid,
    db_ser_line_valid            => db_ser_line_valid,
    db_ser_sync                  => db_ser_sync,
    cgen_log_clk                 => cgen_log_clk,
    rgen_log_reset_n             => rgen_log_reset_n
  );

  GEN_VITA_DB_DATA: for db_channel in G_SENSOR.kernel_size/2-1 downto 0 generate
    vita_db_data_1: vita_db_data
    port map (
      reg_log_enable              => reg_log_enable,
      reg_db_8bit_mode            => reg_db_8bit_mode,
      reg_db_auto_blackcal_enable => reg_db_auto_blackcal_enable,
      reg_db_black_offset         => reg_db_black_offset,
      reg_db_blackcal_offset      => reg_db_blackcal_offset,
      reg_db_blackcal_offset_dec  => reg_db_blackcal_offset_dec,
      reg_db_crc_seed             => reg_db_crc_seed,
      reg_db_testpattern_en       => reg_db_testpattern_en,
      reg_db_prbs_en              => reg_db_prbs_en,
      reg_db_inc_testpattern      => reg_db_inc_testpattern,
      reg_db_frame_testpattern    => reg_db_frame_testpattern,
      reg_db_testpattern          => reg_db_testpattern(db_channel),
      reg_db_trainingpattern      => reg_db_trainingpattern,
      seq_db_line_valid           => seq_db_line_valid,
      seq_db_black                => seq_db_black,
      afe_db_data                 =>
        afe_db_data(db_channel*2+1 downto db_channel*2),
      db_ser_data                 => db_ser_data(db_channel),
      cgen_log_clk                => cgen_log_clk,
      rgen_log_reset_n            => rgen_log_reset_n
    );
  end generate;

end model;

configuration cfg_vita_db_model of vita_db is
  for model
    for vita_db_sync_1: vita_db_sync
      use entity lib_vita_hdl.vita_db_sync(model);
    end for;

    for GEN_VITA_DB_DATA
      for all: vita_db_data
        use entity lib_vita_hdl.vita_db_data(model);
      end for;
    end for;

  end for;
end cfg_vita_db_model;

