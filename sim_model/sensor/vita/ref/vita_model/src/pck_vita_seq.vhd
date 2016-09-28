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
-- $Id: design#hdl#model#src#pck_vita_seq.vhd,v 1.6 2013-01-31 18:50:08+01 ffynvr Exp $
-- Author         : $Author: ffynvr $
-- Department     : CISP
-- Date           : $Date: 2013-01-31 18:50:08+01 $
-- Revision       : $Revision: 1.6 $
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

package pck_vita_seq is

  constant C_FOT_TIME:    integer := 2880;
  constant C_ROT_TIME_SS: integer := 62;
  constant C_ROT_TIME_RS: integer := 96;

  constant C_MAX_Y_ADDRESS_WIDTH: integer := 13;
  constant C_MAX_X_ADDRESS_WIDTH: integer := 8;

  type t_ys_type is (YS_BLACK, YS_IMG, YS_DUMMY);

  type t_frame_state is (FR_IDLE, FR_WAIT_TRIGGER0, FR_WAIT_EXP, FR_FOT,
                         FR_CALC_YS, FR_ROT, FR_WAIT_ROT, FR_X_READ);

  type t_frame_prop is record
    color:         boolean;
    subsampling_y: boolean;
    subsampling_x: boolean;
    binning_y:     boolean;
    binning_x:     boolean;
    exposure:      integer;
    reset_length:  integer;
  end record;

  type t_y_prop is record
    ys:             natural;
    ys_valid:       boolean;
    ys_type:        t_ys_type;
    overhead_count: natural;
    roi_id:         natural;
  end record;

  type t_x_prop is record
    xs:       natural;
    xs_valid: boolean;
    roi_id:   natural;
    sync:     t_sync;
  end record;

  constant C_Y_PROP_RESET: t_y_prop :=
    (ys             => 0,
     ys_valid       => false,
     ys_type        => YS_BLACK,
     overhead_count => 0,
     roi_id         => 0
    );

  constant C_X_PROP_RESET: t_x_prop :=
    (xs       => 0,
     xs_valid => false,
     roi_id   => 0,
     sync     => SYNC_NONE
    );

  constant C_FRAME_PROP_RESET: t_frame_prop :=
    (color         => false,
     subsampling_y => false,
     subsampling_x => false,
     binning_y     => false,
     binning_x     => false,
     exposure      => 0,
     reset_length  => 0
    );

  function or_reduce(a: unsigned) return std_logic;

  function round_y_start(y_address:   natural;
                         subsampling: boolean;
                         color:       boolean)
    return natural;

  function round_y_end(y_address:   natural;
                       subsampling: boolean;
                       color:       boolean)
    return natural;

  function round_x_start(x_address:   natural;
                         subsampling: boolean;
                         color:       boolean)
    return natural;

  function round_x_end(x_address:   natural;
                       subsampling: boolean;
                       color:       boolean)
    return natural;

  function round_roi(roi:           t_roi_configuration;
                     subsampling_y: boolean;
                     subsampling_x: boolean;
                     color:         boolean)
    return t_roi_configuration;

  function round_roi(roi:           t_roi_configuration_array;
                     subsampling_y: boolean;
                     subsampling_x: boolean;
                     color:         boolean)
    return t_roi_configuration_array;

  function inc_pointer(pointer:     natural;
                       subsampling: boolean;
                       color:       boolean)
    return natural;

  function active_line(roi: t_roi_configuration; ys: natural) return boolean;
  function active_pixel(roi: t_roi_configuration; xs: natural) return boolean;

end pck_vita_seq;

package body pck_vita_seq is

  function or_reduce(a: unsigned) return std_logic is
    variable result: std_logic;
  begin
    result := '0';
    for index in a'range loop
      result := result or a(index);
    end loop;
    return result;
  end or_reduce;

  function round_y_start(y_address:   natural;
                         subsampling: boolean;
                         color:       boolean)
    return natural is
    variable y_address_uns: unsigned(C_MAX_Y_ADDRESS_WIDTH - 1 downto 0);

  begin

    y_address_uns := to_unsigned(y_address, C_MAX_Y_ADDRESS_WIDTH);
    if subsampling then
      y_address_uns(0) := '0';
      if color then
        y_address_uns(1) := '0';
      end if;
    end if;

    return to_integer(y_address_uns);

  end round_y_start;

  function round_y_end(y_address:   natural;
                       subsampling: boolean;
                       color:       boolean)
    return natural is
    variable y_address_uns: unsigned(C_MAX_Y_ADDRESS_WIDTH - 1 downto 0);

  begin

    y_address_uns := to_unsigned(y_address, C_MAX_Y_ADDRESS_WIDTH);
    if subsampling then
      y_address_uns(0) := '0';
      if color then
        y_address_uns(1 downto 0) := "01";
      end if;
    end if;

    return to_integer(y_address_uns);

  end round_y_end;

  function round_x_start(x_address:   natural;
                         subsampling: boolean;
                         color:       boolean)
    return natural is
    variable x_address_uns: unsigned(C_MAX_X_ADDRESS_WIDTH - 1 downto 0);
  begin
    x_address_uns := to_unsigned(x_address, C_MAX_X_ADDRESS_WIDTH);
    if subsampling then
      x_address_uns(0) := '0';
    end if;

    return to_integer(x_address_uns);

  end round_x_start;

  function round_x_end(x_address:   natural;
                       subsampling: boolean;
                       color:       boolean)
    return natural is
    variable x_address_uns: unsigned(C_MAX_X_ADDRESS_WIDTH - 1 downto 0);
  begin
    x_address_uns := to_unsigned(x_address, C_MAX_X_ADDRESS_WIDTH);
    if subsampling then
      x_address_uns(0) := '0';
    end if;

    return to_integer(x_address_uns);

  end round_x_end;

  function round_roi(roi:           t_roi_configuration;
                     subsampling_y: boolean;
                     subsampling_x: boolean;
                     color:         boolean)
    return t_roi_configuration is
    variable result: t_roi_configuration;
  begin
    result := roi;
    result.y_start := round_y_start(roi.y_start, subsampling_y, color);
    result.y_end   := round_y_end(roi.y_end,     subsampling_y, color);
    result.x_start := round_x_start(roi.x_start, subsampling_x, color);
    result.x_end   := round_x_end(roi.x_end,     subsampling_x, color);
    return result;
  end round_roi;

  function round_roi(roi:           t_roi_configuration_array;
                     subsampling_y: boolean;
                     subsampling_x: boolean;
                     color:         boolean)
    return t_roi_configuration_array is
    variable result: t_roi_configuration_array(roi'range);
  begin
    for roi_index in roi'range loop
      result(roi_index) :=
        round_roi(roi => roi(roi_index),
                  subsampling_y => subsampling_y,
                  subsampling_x => subsampling_x,
                  color         => color
                 );
    end loop;
    return result;
  end round_roi;

  function inc_pointer(pointer:     natural;
                       subsampling: boolean;
                       color:       boolean)
    return natural is
    variable result: natural;
  begin
    result := pointer + 1;

    if subsampling then
      case color is
        when false =>
          result := pointer + 2;
        when true =>
          if pointer mod 2 = 0 then
            result := pointer + 1;
          else
            result := pointer + 3;
          end if;
      end case;
    end if;
    return result;
  end inc_pointer;

  function active_line(roi: t_roi_configuration; ys: natural) return boolean is
  begin
    return (ys >= roi.y_start and ys <= roi.y_end);
  end active_line;

  function active_pixel(roi: t_roi_configuration; xs: natural) return boolean is
  begin
    return (xs >= roi.x_start and xs <= roi.x_end);
  end active_pixel;

end pck_vita_seq;

