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
-- $Id: design#hdl#model#tb#src#pck_spi_upload_model.vhd,v 1.1 2012-07-02 08:54:07-07 ffynvr Exp $
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

package pck_spi_upload_model is

  constant C_SPI_SCK_NOM_PERIOD:   time    := 100 ns;
  constant C_MODEL_SPI_ADDR_WIDTH: integer := 9;
  constant C_MODEL_SPI_DATA_WIDTH: integer := 16;
  constant C_MODEL_SPI_WIDTH:      integer := C_MODEL_SPI_ADDR_WIDTH +
                                              C_MODEL_SPI_DATA_WIDTH + 1;

  type t_spi_command is record
    request:      boolean;
    write_enable: boolean;
    address:      natural;
    data:         natural;
    sck_period:   time;
  end record;

  constant C_SPI_COMMAND_RESET: t_spi_command :=
    (request      => false,
     write_enable => false,
     address      => 0,
     data         => 0,
     sck_period   => C_SPI_SCK_NOM_PERIOD
    );

  procedure spi_write(signal spi_command: out t_spi_command;
                      address:                natural;
                      data:                   natural;
                      sck_period:             time
                     );

  procedure spi_write(signal spi_command: out t_spi_command;
                      address:         natural;
                      data:            natural
                     );

  procedure spi_read(signal spi_command: out t_spi_command;
                      address:        natural;
                      sck_period:     time
                     );

  procedure spi_read(signal spi_command: out t_spi_command;
                      address:        natural
                     );

end pck_spi_upload_model;

package body pck_spi_upload_model is

  procedure spi_write(signal spi_command: out t_spi_command;
                      address:                natural;
                      data:                   natural;
                      sck_period:             time
                     ) is
  begin
    spi_command.request      <= true;
    spi_command.write_enable <= true;
    spi_command.address      <= address;
    spi_command.data         <= data;
    spi_command.sck_period   <= sck_period;

    wait for sck_period;
    spi_command.request <= false;

  end spi_write;

  procedure spi_write(signal spi_command: out t_spi_command;
                      address:         natural;
                      data:            natural
                     ) is
  begin
    spi_write(
      spi_command => spi_command,
      address     => address,
      data        => data,
      sck_period  => C_SPI_SCK_NOM_PERIOD
    );
  end spi_write;

  procedure spi_read(signal spi_command: out t_spi_command;
                     address:         natural;
                     sck_period:      time
                    ) is
  begin
    spi_command.request      <= true;
    spi_command.write_enable <= false;
    spi_command.address      <= address;
    spi_command.data         <= 0;
    spi_command.sck_period   <= sck_period;

    wait for sck_period;
    spi_command.request <= false;

  end spi_read;

  procedure spi_read(signal spi_command: out t_spi_command;
                     address:         natural
                    ) is
  begin
    spi_read(
      spi_command => spi_command,
      address     => address,
      sck_period  => C_SPI_SCK_NOM_PERIOD
    );
  end spi_read;

end pck_spi_upload_model;

