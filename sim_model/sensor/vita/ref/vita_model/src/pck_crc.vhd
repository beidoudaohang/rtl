--------------------------------------------------------------------------------
-- Copyright (C) 1999-2008 Easics NV.
-- This source file may be used and distributed without restriction
-- provided that this copyright statement is not removed from the file
-- and that any derivative work contains the original copyright notice
-- and the associated disclaimer.
--
-- THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
-- WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
--
-- Purpose : synthesizable CRC function
--   * polynomial: (0 1 2 3 6 9 10)
--   * data width: 10
--
-- Info : tools@easics.be
--        http://www.easics.com
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package pck_crc is

  -- polynomial: (0 1 2 3 6 9 10)
  -- data width: 10
  -- convention: the first serial data bit is D(9)
  function nextCRC10_D10
    ( Data:  unsigned(9 downto 0);
      CRC:   unsigned(9 downto 0) )
    return unsigned;

  -- polynomial: (0 2 3 6 8)
  -- data width: 8
  -- convention: the first serial bit is D[7]
  function nextCRC8_D8
    (data: unsigned(7 downto 0);
     crc:  unsigned(7 downto 0))
    return unsigned;

end pck_crc;

package body pck_crc is

  -- polynomial: (0 1 2 3 6 9 10)
  -- data width: 10
  -- convention: the first serial data bit is D(9)
  function nextCRC10_D10
    ( Data:  unsigned(9 downto 0);
      CRC:   unsigned(9 downto 0) )
    return unsigned is

    variable D: unsigned(9 downto 0);
    variable C: unsigned(9 downto 0);
    variable NewCRC: unsigned(9 downto 0);

  begin

    D := Data;
    C := CRC;

    NewCRC(0) := D(5) xor D(3) xor D(2) xor D(1) xor D(0) xor C(0) xor
                 C(1) xor C(2) xor C(3) xor C(5);
    NewCRC(1) := D(6) xor D(5) xor D(4) xor D(0) xor C(0) xor C(4) xor
                 C(5) xor C(6);
    NewCRC(2) := D(7) xor D(6) xor D(3) xor D(2) xor D(0) xor C(0) xor
                 C(2) xor C(3) xor C(6) xor C(7);
    NewCRC(3) := D(8) xor D(7) xor D(5) xor D(4) xor D(2) xor D(0) xor
                 C(0) xor C(2) xor C(4) xor C(5) xor C(7) xor C(8);
    NewCRC(4) := D(9) xor D(8) xor D(6) xor D(5) xor D(3) xor D(1) xor
                 C(1) xor C(3) xor C(5) xor C(6) xor C(8) xor C(9);
    NewCRC(5) := D(9) xor D(7) xor D(6) xor D(4) xor D(2) xor C(2) xor
                 C(4) xor C(6) xor C(7) xor C(9);
    NewCRC(6) := D(8) xor D(7) xor D(2) xor D(1) xor D(0) xor C(0) xor
                 C(1) xor C(2) xor C(7) xor C(8);
    NewCRC(7) := D(9) xor D(8) xor D(3) xor D(2) xor D(1) xor C(1) xor
                 C(2) xor C(3) xor C(8) xor C(9);
    NewCRC(8) := D(9) xor D(4) xor D(3) xor D(2) xor C(2) xor C(3) xor
                 C(4) xor C(9);
    NewCRC(9) := D(4) xor D(2) xor D(1) xor D(0) xor C(0) xor C(1) xor
                 C(2) xor C(4);

    return NewCRC;

  end nextCRC10_D10;

  -- polynomial: (0 2 3 6 8)
  -- data width: 8
  -- convention: the first serial bit is D[7]
  function nextCRC8_D8
    (data: unsigned(7 downto 0);
     crc:  unsigned(7 downto 0))
    return unsigned is

    variable d:      unsigned(7 downto 0);
    variable c:      unsigned(7 downto 0);
    variable newcrc: unsigned(7 downto 0);

  begin
    d := data;
    c := crc;

    newcrc(0) := d(5) xor d(4) xor d(2) xor d(0) xor c(0) xor c(2) xor
                 c(4) xor c(5);

    newcrc(1) := d(6) xor d(5) xor d(3) xor d(1) xor c(1) xor c(3) xor
                 c(5) xor c(6);

    newcrc(2) := d(7) xor d(6) xor d(5) xor d(0) xor c(0) xor c(5) xor
                 c(6) xor c(7);

    newcrc(3) := d(7) xor d(6) xor d(5) xor d(4) xor d(2) xor d(1) xor
                 d(0) xor c(0) xor c(1) xor c(2) xor c(4) xor c(5) xor
                 c(6) xor c(7);

    newcrc(4) := d(7) xor d(6) xor d(5) xor d(3) xor d(2) xor d(1) xor
                 c(1) xor c(2) xor c(3) xor c(5) xor c(6) xor c(7);

    newcrc(5) := d(7) xor d(6) xor d(4) xor d(3) xor d(2) xor c(2) xor
                 c(3) xor c(4) xor c(6) xor c(7);

    newcrc(6) := d(7) xor d(3) xor d(2) xor d(0) xor c(0) xor c(2) xor
                 c(3) xor c(7);

    newcrc(7) := d(4) xor d(3) xor d(1) xor c(1) xor c(3) xor c(4);

    return newcrc;

  end nextCRC8_D8;

end pck_crc;

