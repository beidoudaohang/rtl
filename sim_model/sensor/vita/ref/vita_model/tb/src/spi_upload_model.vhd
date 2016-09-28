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
-- $Id: design#hdl#model#tb#src#spi_upload_model.vhd,v 1.1 2012-07-02 08:54:07-07 ffynvr Exp $
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
  use ieee.std_logic_unsigned.all;

library lib_tb_vita_hdl;
  use lib_tb_vita_hdl.pck_spi_upload_model.all;

entity spi_upload_model is
  port (
    ----- Test bench Interface -----
    spi_command:    in t_spi_command;
    spi_ready:     out boolean;

    ----- SPI Interface -----
    mosi:          out std_logic;
    ss_n:          out std_logic;
    sck:           out std_logic;
    miso:           in std_logic
  );
end spi_upload_model;

architecture model of spi_upload_model is

  signal mosi_sys: std_logic;
  signal sck_sys:  std_logic;

  procedure spi_upload(
    address:              natural;
    data:                 natural;
    write_enable:         boolean;
    signal mosi:      out std_logic;
    signal ss_n:      out std_logic;
    signal sck:       out std_logic;
    signal miso:       in std_logic;
    read_data:        out unsigned(C_MODEL_SPI_DATA_WIDTH - 1 downto 0);
    sck_period:          time) is

    variable upload_vector: unsigned(C_MODEL_SPI_WIDTH - 1 downto 0);
    variable cycle:         integer := 0;
    variable read_data_int: unsigned(C_MODEL_SPI_DATA_WIDTH - 1 downto 0);

  begin

    -- Address Field
    upload_vector(C_MODEL_SPI_WIDTH - 1 downto
                  C_MODEL_SPI_WIDTH - C_MODEL_SPI_ADDR_WIDTH) :=
      to_unsigned(address, C_MODEL_SPI_ADDR_WIDTH);

    -- R/W bit
    upload_vector(C_MODEL_SPI_DATA_WIDTH):= '0';
    if write_enable then
      upload_vector(C_MODEL_SPI_DATA_WIDTH):= '1';
    end if;

    -- Data Field
    upload_vector(C_MODEL_SPI_DATA_WIDTH-1 downto 0) :=
      to_unsigned(data, C_MODEL_SPI_DATA_WIDTH);

    read_data     := (others => '0');
    read_data_int := (others => '0');

    cycle := C_MODEL_SPI_DATA_WIDTH + C_MODEL_SPI_ADDR_WIDTH;

    ss_n <= '1';
    sck  <= '0';
    mosi <= '0';
    wait for sck_period;
    ss_n <= '0';
    wait for sck_period;

    while cycle >= 0 loop
      mosi <= upload_vector(cycle);
      sck <= '0';
      read_data_int(C_MODEL_SPI_DATA_WIDTH - 1 downto 1) :=
        read_data_int(C_MODEL_SPI_DATA_WIDTH-2 downto 0);
      read_data_int(0) := miso;
      wait for sck_period/2;
      sck <= '1';
      wait for sck_period/2;
      cycle := cycle - 1;
    end loop;

    sck <= '0';

    read_data_int(C_MODEL_SPI_DATA_WIDTH - 1 downto 1) :=
      read_data_int(C_MODEL_SPI_DATA_WIDTH-2 downto 0);
    read_data_int(0) := miso;

    read_data := read_data_int;

    wait for sck_period;
    ss_n <= '1';
    wait for sck_period;

  end procedure;

begin

  MAIN: process
    variable read_data: unsigned(C_MODEL_SPI_DATA_WIDTH - 1 downto 0);
  begin

    spi_ready <= true;
    ss_n      <= '1';
    sck_sys   <= '0';
    mosi_sys  <= '0';

    while true loop
      wait until spi_command.request = true;
      spi_ready <= false;
      spi_upload(
        address       => spi_command.address,
        data          => spi_command.data,
        write_enable  => spi_command.write_enable,
        mosi          => mosi_sys,
        ss_n          => ss_n,
        sck           => sck_sys,
        miso          => miso,
        read_data     => read_data,
        sck_period    => spi_command.sck_period
      );

      spi_ready <= true;

    end loop;

  end process;

  sck <= sck_sys;

  mosi <= mosi_sys after 2 ns;

end model;
