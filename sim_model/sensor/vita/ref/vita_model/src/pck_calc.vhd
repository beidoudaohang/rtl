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
-- File          : $RCSfile: is_modeling#tb_support#vhdl#pck_calc.vhd,v $
-- Author        : $Author: ffynvr $
-- Author's Email: fpd@cypress.com
-- Department    : MPD_BE
-- Date          : $Date: 2012-09-06 07:42:20-07 $
-- Revision      : $Revision: 1.1 $
-- *********************************************************************
--
-- $Log: is_modeling#tb_support#vhdl#pck_calc.vhd,v $
-- Revision 1.1  2012-09-06 07:42:20-07  ffynvr
-- ...No comments entered during checkin...
--
-- 
--  Revision: 1.1 Mon Apr 23 11:35:28 2007 fhw
--  Check in of all data from original is_common DDC in sync://sync1.bsdc.cypress.com:3003/Projects/is_common.
-- 
--  Revision: 1.2 Tue Mar 21 07:59:48 2006 fpd
--  added log2 function
-- 
--  Revision: 1.1 Tue Mar  7 09:33:30 2006 fpd
--  initial checkin
--
-- *********************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pck_calc is

  -- This package contains some general purpose functions that can be used in
  -- image processing algorithms

  procedure swap(a,b: inout integer);

  function clip(value, bits: integer) return integer;

  function min(a,b: in integer) return integer;
  function max(a,b: in integer) return integer;
  function average(a,b: in integer) return integer;

  function median(a,b,c: in integer) return integer;
  function average(a,b,c: in integer) return integer;

  -- Calculate Log2, can be used to calculate address bus widths
  function log2 (arg: positive) return natural;

end pck_calc;


package body pck_calc is

  procedure swap(a,b: inout integer) is
    variable z: integer;
  begin
    z := a;
    a := b;
    b := z;
  end swap;

  function clip(value, bits: integer) return integer is
  begin
    if (value < 0) then
      return 0;
    elsif (value > 2**bits-1) then
      return 2**bits-1;
    else
      return value;
    end if;
  end clip;

  function min(a,b: in integer) return integer is
  begin
    if (a<b) then
      return(a);
    else
      return(b);
    end if;
  end min;

  function max(a,b: in integer) return integer is
  begin
    if (a>b) then
      return(a);
    else
      return(b);
    end if;
  end max;

  function average(a,b: in integer) return integer is
  begin
    return (a+b)/2;
  end average;


  function median(a,b,c: in integer) return integer is
    variable x,y,z: integer;
  begin
    x := a; y := b; z := c;
    if (x>y) then
      swap(x,y);
    end if;
    if (y>z) then
      swap(y,z);
    end if;
    if(x>y) then
      swap(x,y);
    end if;
    return(y);
  end median;


  function average(a,b,c: in integer) return integer is
  begin
    return (a+b+c)/3;
  end average;

  function log2 (arg: positive) return natural is
  begin
    for i in 1 to 30 loop
      if arg <= 2**i then
        return i;
      end if;
    end loop;
  end log2;


end pck_calc;
