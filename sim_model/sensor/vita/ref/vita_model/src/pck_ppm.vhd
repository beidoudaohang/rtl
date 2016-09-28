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
-- File          : $RCSfile: is_modeling#tb_support#vhdl#pck_ppm.vhd,v $
-- Author        : $Author: ffynvr $
-- Author's Email: fpd@cypress.com
-- Department    : MPD_BE
-- Date          : $Date: 2012-09-06 07:42:20-07 $
-- Revision      : $Revision: 1.1 $
-- *********************************************************************
--
-- $Log: is_modeling#tb_support#vhdl#pck_ppm.vhd,v $
-- Revision 1.1  2012-09-06 07:42:20-07  ffynvr
-- ...No comments entered during checkin...
--
-- 
--  Revision: 1.4 Mon Feb  8 10:57:18 2010 ulc
--  {changed range of written pixels to 0 to im.d instead of im.d+1
--  for an input range of 0.0 to 1.0 this caused pixel values greater then im.d}
-- 
--  Revision: 1.3 Fri Jun  6 10:05:20 2008 ulc
--  {added grey P2 format
--  replaced assert with writeline for cleaner appereance}
--
--  Revision: 1.2 Thu Jan 24 10:05:38 2008 fec
--  {updated comment when writing image file}
--
--  Revision: 1.1 Tue Mar  7 09:33:32 2006 fpd
--  initial checkin
--
-- *********************************************************************

library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_model;
use lib_model.pck_file_io.all;
use lib_model.pck_calc.all;
use lib_model.pck_frame_format.all;

package pck_ppm is

  -- This package includes some general ppm file handling functions

  procedure read_header(file f: text;
                        ppm_type: out string;
                        x,y,d: out integer);
  procedure write_header(file f: text;
                         ppm_type: in string;
                         x,y,d: in integer);

  procedure read_image(im: inout T_color_frame;
                       file in_file: text;
                       file_name: in string);
  procedure write_image(im: inout T_color_frame;
                        file out_file: text;
                        file_name: in string);

  procedure read_image(im: inout T_grey_frame;
                       file in_file: text;
                       file_name: in string);
  procedure write_image(im: inout T_grey_frame;
                        file out_file: text;
                        file_name: in string);




end pck_ppm;



package body pck_ppm is


  procedure read_header(file f: text;
                        ppm_type: out string;
                        x,y,d: out integer) is
    variable l: line;
  begin
    readline(f, l);
    read(l, ppm_type);
    readline(f, l);
    read(l, x);
    read(l, y);
    readline(f, l);
    read(l, d);
  end read_header;

  procedure write_header(file f: text;
                         ppm_type: in string;
                         x,y,d: in integer) is
    variable l: line;
  begin
    write(l, ppm_type);
    writeline(f, l);
    write(l, x);
    write(l, ' ');
    write(l, y);
    writeline(f, l);
    write(l, d);
    writeline(f, l);
  end write_header;

  procedure read_image(im: inout T_color_frame;
                       file in_file: text;
                       file_name: in string) is
    variable i,j: integer;
    variable ppm_type: string(1 to 2);
    variable x,y,d: integer;
    variable l: line;
    variable pix_value: integer;
    variable c_cntr, x_cntr, y_cntr: integer := 0;
    variable end_of_line: boolean := TRUE;
    variable separator: character;
  begin
    file_open(in_file, file_name, READ_MODE);
    read_header(in_file, ppm_type, x, y, d);
    im := init_frame(x, y, d);

    -- read out all pixels
    while not endfile(in_file) loop
      readline(in_file, l);
      end_of_line := TRUE;
      while end_of_line loop
        read(l, pix_value, end_of_line);
        read(l, separator, end_of_line);
        case c_cntr is
          when 0 => im.m(y_cntr, x_cntr).r := real(pix_value)/real(im.d);
          when 1 => im.m(y_cntr, x_cntr).g := real(pix_value)/real(im.d);
          when 2 => im.m(y_cntr, x_cntr).b := real(pix_value)/real(im.d);
          when others =>
        end case;
        c_cntr := c_cntr+1;
        if (c_cntr >= 3) then
          c_cntr := 0;
          x_cntr := x_cntr+1;
          if (x_cntr >= im.x) then
            x_cntr := 0;
            y_cntr := y_cntr+1;
          end if;
        end if;
      end loop;
    end loop;
    file_close(in_file);
  end read_image;

  procedure write_image(im: inout T_color_frame;
                        file out_file: text;
                        file_name: in string) is
    variable l: line;
  begin
    --put something on the screen
    write(l,string'("--------------------------------------"));
    writeline(output,l);
    write(l,string'("writing Color PPM file----------------"));
    writeline(output,l);
    write(l,string'("--------------------------------------"));
    writeline(output,l);


    file_open(out_file, file_name, WRITE_MODE);
    write_header(out_file, "P3", im.x, im.y, im.d);
    for i in 0 to im.y-1 loop
      for j in 0 to im.x-1 loop
        write(l, integer(im.m(i, j).r*real(im.d)));
        write(l, ' ');
        write(l, integer(im.m(i, j).g*real(im.d)));
        write(l, ' ');
        write(l, integer(im.m(i, j).b*real(im.d)));
        writeline(out_file, l);
      end loop;
    end loop;
    file_close(out_file);

  end write_image;

  procedure read_image(im: inout T_grey_frame;
                       file in_file: text;
                       file_name: in string) is
    variable i,j: integer;
    variable ppm_type: string(1 to 2);
    variable x,y,d: integer;
    variable l: line;
    variable pix_value: integer;
    variable x_cntr, y_cntr: integer := 0;
    variable end_of_line: boolean := TRUE;
    variable separator: character;
  begin
    file_open(in_file, file_name, READ_MODE);
    read_header(in_file, ppm_type, x, y, d);
    im := init_frame(x, y, d);

    -- read out all pixels
    while not endfile(in_file) loop
      readline(in_file, l);
      end_of_line := TRUE;
      while end_of_line loop
        read(l, pix_value, end_of_line);
        read(l, separator, end_of_line);
        im.m(y_cntr, x_cntr).g := real(pix_value)/real(im.d);
        x_cntr := x_cntr+1;
        if (x_cntr >= im.x) then
          x_cntr := 0;
          y_cntr := y_cntr+1;
        end if;
      end loop;
    end loop;
    file_close(in_file);
  end read_image;

  procedure write_image(im: inout T_grey_frame;
                        file out_file: text;
                        file_name: in string) is
    variable l: line;
  begin
    --put something on the screen
    write(l,string'("--------------------------------------"));
    writeline(output,l);
    write(l,string'("writing grey PPM file-----------------"));
    writeline(output,l);
    write(l,string'("--------------------------------------"));
    writeline(output,l);

    file_open(out_file, file_name, WRITE_MODE);
    write_header(out_file, "P2", im.x, im.y, im.d);
    for i in 0 to im.y-1 loop
      for j in 0 to im.x-1 loop
        write(l, integer(im.m(i, j).g*real(im.d)));
        writeline(out_file, l);
      end loop;
    end loop;
    file_close(out_file);

  end write_image;

end pck_ppm;
