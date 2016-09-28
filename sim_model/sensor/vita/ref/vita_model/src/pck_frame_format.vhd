-- *********************************************************************
-- Copyright 2005, Cypress Semiconductor Corporation.
--
-- This software is owned by Cypress Semiconductor Corporation (Cypress)
-- and is protected by United States copyright laws and international
-- treaty provisions.  Therefore, you must treat this software like any
-- other copyrighted material (e.g., book, or musical recording), with
-- the exception that one copy may be made for personal use or
-- evaluation.  Reproduction, modification, translation, compilation, or
-- representation of this software in any other form (e.g., paper,
-- magnetic, optical, silicon, etc.) is prohibited without the express
-- written permission of Cypress.
--
-- Disclaimer: Cypress makes no warranty of any kind, express or
-- implied, with regard to this material, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular
-- purpose. Cypress reserves the right to make changes without further
-- notice to the materials described herein. Cypress does not assume any
-- liability arising out of the application or use of any product or
-- circuit described herein. Cypress' products described herein are not
-- authorized for use as components in life-support devices.
--
-- This software is protected by and subject to worldwide patent
-- coverage, including U.S. and foreign patents. Use may be limited by
-- and subject to the Cypress Software License Agreement.
--
-- *********************************************************************
-- File          : $RCSfile: is_modeling#tb_support#vhdl#pck_frame_format.vhd,v $
-- Author        : $Author: ffynvr $
-- Author's Email: fpd@cypress.com
-- Department    : MPD_BE
-- Date          : $Date: 2012-09-06 07:42:20-07 $
-- Revision      : $Revision: 1.1 $
-- *********************************************************************
--
-- $Log: is_modeling#tb_support#vhdl#pck_frame_format.vhd,v $
-- Revision 1.1  2012-09-06 07:42:20-07  ffynvr
-- ...No comments entered during checkin...
--
-- 
--  Revision: 1.3 Fri Jan 25 14:24:06 2008 fec
--  {added resize_frame procedures}
-- 
--  Revision: 1.2 Mon Sep 17 16:11:39 2007 fpd
--  update
--  d
-- 
--  Revision: 1.1 Mon Apr 23 11:35:27 2007 fhw
--  Check in of all data from original is_common DDC in sync://sync1.bsdc.cypress.com:3003/Projects/is_common.
-- 
--  Revision: 1.2 Tue Mar 21 08:00:22 2006 fpd
--  changed gray -> grey
-- 
--  Revision: 1.1 Tue Mar  7 09:33:30 2006 fpd
--  initial checkin
--
-- *********************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


package pck_frame_format is

  -- This package contains a general, image format independant definition of
  -- a color image and a greyscale image + some elementary functions.

  -- color images
  ---------------

  type T_color_pixel is record
    r: real;
    g: real;
    b: real;
  end record;

  type T_color_line is array(integer range <>) of T_color_pixel;
  type T_color_line_ptr is access T_color_line;
  type T_color_frame_array is
    array (integer range <>, integer range <>) of T_color_pixel;
  type T_color_frame_ptr is access T_color_frame_array;

  type T_color_frame is record
    m: T_color_frame_ptr;     -- array
    x: integer;               -- pixels on a line
    y: integer;               -- lines
    d: integer;               -- color depth (max pixel value)
  end record;

  function init_frame(x, y, d: integer) return T_color_frame;
  function init_frame(x, y, d, pix_value: integer) return T_color_frame;

  procedure resize_frame(im1: inout T_color_frame; x, y: integer);

  procedure copy(im1,im2: inout T_color_frame);

  -- greyscale images
  -------------------

  type T_grey_pixel is record
    g: real;
  end record;

  type T_grey_line is array(integer range <>) of T_grey_pixel;
  type T_grey_line_ptr is access T_grey_line;
  type T_grey_frame_array is
    array(integer range <>,integer range <>) of T_grey_pixel;
  type T_grey_frame_ptr is access T_grey_frame_array;

  type T_grey_frame is record
    m: T_grey_frame_ptr;     -- array
    x: integer;              -- pixels on a line
    y: integer;              -- lines
    d: integer;              -- color depth (max pixel value)
  end record;

  function init_frame(x, y, d: integer) return T_grey_frame;
  function init_frame(x, y, d, pix_value: integer) return T_grey_frame;

  procedure resize_frame(im1: inout T_grey_frame; x, y: integer);

  procedure copy(im1,im2: inout T_grey_frame);


end pck_frame_format;


package body pck_frame_format is

  function init_frame(x, y, d: integer) return T_color_frame is
    variable f: T_color_frame;
  begin
    f.m := new T_color_frame_array(y-1 downto 0, x-1 downto 0);
    f.x := x;
    f.y := y;
    f.d := d;
    return f;
  end init_frame;

  function init_frame(x, y, d, pix_value: integer) return T_color_frame is
    variable f: T_color_frame;
  begin
    f.m := new T_color_frame_array(y-1 downto 0, x-1 downto 0);
    f.x := x;
    f.y := y;
    f.d := d;
    for i in 0 to y-1 loop
      for j in 0 to x-1 loop
        f.m(i,j).r := real(pix_value)/real(d+1);
        f.m(i,j).g := real(pix_value)/real(d+1);
        f.m(i,j).b := real(pix_value)/real(d+1);
      end loop;
    end loop;
    return f;
  end init_frame;

  procedure resize_frame(im1: inout T_color_frame; x, y: integer) is
  begin
    im1.x := x;
    im1.y := y;
  end resize_frame;

  procedure copy(im1,im2: inout T_color_frame) is
  begin
    im2 := init_frame(im1.x, im1.y, im1.d);
    for i in 0 to im1.y loop
      for j in 0 to im1.x loop
        im2.m(i,j) := im1.m(i,j);
      end loop;
    end loop;
  end copy;

  function init_frame(x, y, d: integer) return T_grey_frame is
    variable f: T_grey_frame;
  begin
    f.m := new T_grey_frame_array(y-1 downto 0, x-1 downto 0);
    f.x := x;
    f.y := y;
    f.d := d;
    return f;
  end init_frame;

  function init_frame(x, y, d, pix_value: integer) return T_grey_frame is
    variable f: T_grey_frame;
  begin
    f.m := new T_grey_frame_array(y-1 downto 0, x-1 downto 0);
    f.x := x;
    f.y := y;
    f.d := d;
    for i in 0 to y-1 loop
      for j in 0 to x-1 loop
        f.m(i,j).g := real(pix_value)/real(d+1);
      end loop;
    end loop;
    return f;
  end init_frame;

  procedure resize_frame(im1: inout T_grey_frame; x, y: integer) is
  begin
    im1.x := x;
    im1.y := y;
  end resize_frame;

  procedure copy(im1,im2: inout T_grey_frame) is
  begin
    im2 := init_frame(im1.x, im1.y, im1.d);
    for i in 0 to im1.y loop
      for j in 0 to im1.x loop
        im2.m(i,j) := im1.m(i,j);
      end loop;
    end loop;
  end copy;


end pck_frame_format;

