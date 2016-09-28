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
-- $Id: design#hdl#model#tb#src#pck_tb_vita_model.vhd,v 1.1 2012-07-02 08:54:07-07 ffynvr Exp $
-- Author         : $Author: ffynvr $
-- Department     : CISP
-- Date           : $Date: 2012-07-02 08:54:07-07 $
-- Revision       : $Revision: 1.1 $
-- *********************************************************************
-- Modification History Summary
-- Date        By   Version  Change Description
-- *********************************************************************
-- See SVN logs
--
-- *********************************************************************
-- Description
--
-- *********************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pck_tb_vita_model is

  type t_roi_configuration is record
    y_start: natural;
    y_end:   natural;
    x_start: natural;
    x_end:   natural;
  end record;

  type t_roi_configuration_array is array(integer range <>) of
    t_roi_configuration;

  constant C_ROI_CONFIGURATION_RESET: t_roi_configuration :=
    (y_start => 0,
     y_end   => 0,
     x_start => 0,
     x_end   => 0
    );

end pck_tb_vita_model;

package body pck_tb_vita_model is

end pck_tb_vita_model;

