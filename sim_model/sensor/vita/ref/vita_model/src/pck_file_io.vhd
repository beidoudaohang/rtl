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
-- File          : $RCSfile: is_modeling#tb_support#vhdl#pck_file_io.vhd,v $
-- Author        : $Author: ffynvr $
-- Author's Email: fpd@cypress.com
-- Department    : MPD_BE
-- Date          : $Date: 2012-09-06 07:42:20-07 $
-- Revision      : $Revision: 1.1 $
-- *********************************************************************
--
-- $Log: is_modeling#tb_support#vhdl#pck_file_io.vhd,v $
-- Revision 1.1  2012-09-06 07:42:20-07  ffynvr
-- ...No comments entered during checkin...
--
-- 
--  Revision: 1.1 Mon Apr 23 11:35:27 2007 fhw
--  Check in of all data from original is_common DDC in sync://sync1.bsdc.cypress.com:3003/Projects/is_common.
-- 
--  Revision: 1.2 Tue Dec  5 10:56:46 2006 fpd
--  added functions string_to_int and int_to_string
-- 
--  Revision: 1.1 Tue Mar  7 09:33:30 2006 fpd
--  initial checkin
--
-- *********************************************************************

library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package pck_file_io is

  -- This package contains some general file io functions.

  subtype S_digit_chars is character range '0' to '9';
  subtype S_digits      is integer   range  0  to  9 ; 
  type T_digit_chars_map is array(S_digit_chars) of S_digits; 
  constant C_DIGIT_CHARS_MAP: T_digit_chars_map 
    := (0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
  type T_digits_map is array(S_digits) of S_digit_chars; 
  constant C_DIGITS_MAP: T_digits_map  
    := ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9');

  type T_char_file is file of character;

  function int_to_char(s: in integer) return character;
  function char_to_int(c: in character) return integer;

  function string_to_int(s: in string) return integer;
  procedure int_to_string(input: in integer; output: out string);
  procedure int_to_string(input:    in integer;
                          default:  in string;
                          output:  out string);

  -- Takes a line, ignores the first spaces, reads
  -- the word until it sees a space or the end of line.
  procedure read_word(in_line: inout line;
                      word: out string);

  -- Read Word of N characters (N <= 4) and convert to integer value
  procedure read_word(file F: T_char_file;
                      N: in integer;
                      W: out integer);
  -- Write integer value to file as word of N characters (N <= 4)
  procedure write_word(file F: T_char_file;
                       N: in integer;
                       W: in integer);

end pck_file_io;


package body pck_file_io is

  function int_to_char(S: in integer) return character is
    variable c: character;
  begin
    for cc in character'left to character'right loop
      if character'pos(cc)=s then
        c := cc;
        exit;
      end if;
    end loop;
    return(c);
  end int_to_char;


  function char_to_int(c: in character) return integer is
  begin
    return integer'(character'pos(c));
  end char_to_int;

  function string_to_int(s: in string) return integer is
    variable r: integer := 0;
    variable index: integer := 1;
  begin
    while (s(index) /= ' ') loop
      r := r*10 + C_DIGIT_CHARS_MAP(s(index));
      index := index+1;
    end loop;
    return r;
  end string_to_int;

  procedure int_to_string(input:   in integer;
                          output: out string) is
    variable arg: integer := input;
    variable result: string(1 to output'length) := (others => ' '); 
    variable sign: character := ' ';
  begin
    if (arg < 0) and (arg /= integer'low) then
      sign := '-';
      arg := -arg;
    end if;
    for i in result'reverse_range loop 
      result(i) := C_DIGITS_MAP(arg mod 10); 
      arg := arg / 10;
      exit when (arg = 0);
    end loop;
    if (sign = '-') then
      output := sign & result(2 to output'length);
    else
      output := result;
    end if;
  end int_to_string;

  procedure int_to_string(input:   in integer;
                          default: in string;
                          output: out string) is
    variable arg: integer := input;
    variable result: string(1 to output'length) := default;
    variable sign: character := ' ';
  begin
    if (arg < 0) and (arg /= integer'low) then
      sign := '-';
      arg := -arg;
    end if;
    for i in result'reverse_range loop 
      result(i) := C_DIGITS_MAP(arg mod 10); 
      arg := arg / 10;
      exit when (arg = 0);
    end loop;
    if (sign = '-') then
      output := sign & result(2 to output'length);
    else
      output := result;
    end if;
  end int_to_string;

  procedure read_word(in_line: inout line;
                      word: out string) is
    variable c: character;
    variable index: integer := 1;
  begin
    -- Default is all spaces
    for i in 1 to word'length loop
      word(i) := ' ';
    end loop;

    if (in_line'length /= 0) then
      -- Read first character, either lettter or space
      read(in_line, c);

      -- If space, remove spaces in the beginning of the line
      while ((in_line'length /= 0) and (c = ' ')) loop
        read(in_line, c);
      end loop;

      word(index) := c;
      index := index + 1;

      -- Read the word, until the end of line or until a space is detected
      -- or until the word is filled completely
      while ((in_line'length /= 0) and
         (c /= ' ') and
         (index <= word'length)) loop
        read(in_line, c);
        word(index) := c;
        index := index + 1;
      end loop;
    end if;
  end read_word;

  procedure read_word(file F: T_char_file;
                      N: in integer;
                      W: out integer) is
    variable C: character;
    variable V: integer;
    variable WW: integer;
  begin
    WW := 0;
    for i in 0 to N-1 loop
      read(F, C);
      V := char_to_int(C);
      WW := WW+V*256**i;
    end loop;
    W := WW;
  end read_word;


  procedure write_word(file F: T_char_file;
                       N: in integer;
                       W: in integer) is
    variable S, WW: integer;
  begin
    WW := W;
    for i in 0 to N-1 loop
      S := (WW/(256**i)) mod 256;
      write(F, int_to_char(S));
      WW := WW-S*256**i;
    end loop;
  end write_word;

end pck_file_io;
