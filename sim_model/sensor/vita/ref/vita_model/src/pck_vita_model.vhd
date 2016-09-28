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
-- $Id: design#hdl#model#src#pck_vita_model.vhd,v 1.3 2012-12-06 03:11:33-07 ffynvr Exp $
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

package pck_vita_model is

  ---------------------
  -- Sensor Definitions
  ---------------------
  type t_id_enum is (VITA1300, VITA2000, VITA5000, VITA25k);
  type t_family_enum is (VITA);

  type t_sensor_prop is record
    id:          t_id_enum;
    family:      t_family_enum;
    x_width:     natural;
    y_width:     natural;
    kernel_size: natural;
    kernels:     natural;
    rois:        natural;
  end record;

  constant C_SENSOR_VITA1300: t_sensor_prop :=
    (id          => VITA1300,
     family      => VITA,
     x_width     => 1280,
     y_width     => 1024,
     kernel_size => 8,
     kernels     => 160,
     rois        => 8
    );

  constant C_SENSOR_VITA2000: t_sensor_prop :=
    (id          => VITA2000,
     family      => VITA,
     x_width     => 1920,
     y_width     => 1200,
     kernel_size => 8,
     kernels     => 240,
     rois        => 8
    );

  constant C_SENSOR_VITA5000: t_sensor_prop :=
    (id          => VITA5000,
     family      => VITA,
     x_width     => 2592,
     y_width     => 2048,
     kernel_size => 16,
     kernels     => 162,
     rois        => 8
    );

  constant C_SENSOR_VITA25K: t_sensor_prop :=
    (id          => VITA25k,
     family      => VITA,
     x_width     => 5120,
     y_width     => 5120,
     kernel_size => 64,
     kernels     => 80,
     rois        => 32
    );

  ------------------------
  -- PLL / Clock Generation
  ------------------------
  -- Generated PLL clock period
  constant C_PLL_GEN_CLOCK_PERIOD: time := 3226 ps;
  constant C_PLL_LOCK_COUNT:       integer := 10;
  constant C_PLL_UNLOCK_COUNT:     integer := 15;
  constant C_PLL_MDIV_8BIT:        integer := 16#0F#;
  constant C_PLL_MDIV_10BIT:       integer := 16#13#;

  -- C_PLL_IN_PERIOD is the expected input frequency,
  -- C_PLL_IN_MARGIN is the allowable deviation within the pll model
  -- generates a lock.
  constant C_PLL_IN_PERIOD: time := 16629 ps;
  constant C_PLL_IN_MARGIN: time := 5000 ps;

  ----------
  -- General
  ----------
  type t_real_array is array(integer range <>) of real;

  ----------------
  -- ROI / Windows
  ----------------
  type t_roi_configuration is record
    y_start: natural;
    y_end:   natural;
    x_start: natural;
    x_end:   natural;
  end record;

  type t_roi_configuration_array is array(integer range <>) of
    t_roi_configuration;

  -------------
  -- Image Core
  -------------
  constant C_IMC_BLACK_LEVEL: real := 0.0;

  ---------------------------
  -- Datablock / Frame Format
  ---------------------------
  type t_sync is (SYNC_NONE,
                  SYNC_FS, SYNC_FE,
                  SYNC_LS, SYNC_LE,
                  SYNC_IMG, SYNC_BL,
                  SYNC_ROI_ID,
                  SYNC_CRC);

  constant C_DB_SYNC_WIDTH: integer := 3;
  constant C_DB_SYNC_NONE:  unsigned(C_DB_SYNC_WIDTH - 1 downto 0) := "000";
  constant C_DB_SYNC_LS:    unsigned(C_DB_SYNC_WIDTH - 1 downto 0) := "001";
  constant C_DB_SYNC_LE:    unsigned(C_DB_SYNC_WIDTH - 1 downto 0) := "010";
  constant C_DB_SYNC_FS:    unsigned(C_DB_SYNC_WIDTH - 1 downto 0) := "101";
  constant C_DB_SYNC_FE:    unsigned(C_DB_SYNC_WIDTH - 1 downto 0) := "110";

  constant C_DB_DATA_WIDTH: integer := 10;
  subtype t_db_data       is unsigned(C_DB_DATA_WIDTH - 1 downto 0);
  type    t_db_data_array is array(integer range <>) of t_db_data;
  subtype t_db_data_range is integer range 0 to 2**C_DB_DATA_WIDTH - 1;

  ---------------------
  -- LVDS / Serializers
  ---------------------
  type t_lvds is record
    p: std_logic;
    n: std_logic;
  end record;

  type t_lvds_array is array(integer range <>) of t_lvds;

end pck_vita_model;

package body pck_vita_model is

end pck_vita_model;

