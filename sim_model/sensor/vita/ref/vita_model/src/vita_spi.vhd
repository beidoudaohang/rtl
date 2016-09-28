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
-- $Id: design#hdl#model#src#vita_spi.vhd,v 1.6 2013-01-31 18:56:38+01 ffynvr Exp $
-- Author         : $Author: ffynvr $
-- Department     : CISP
-- Date           : $Date: 2013-01-31 18:56:38+01 $
-- Revision       : $Revision: 1.6 $
-- *********************************************************************
-- Modification History Summary
-- Date        By   Version  Change Description
-- *********************************************************************
-- See logs
--
-- *********************************************************************
-- Description
-- Note: this model is only meant for model simulation.  No Clock domain
-- crossing synchronization is foreseen.
-- *********************************************************************

library ieee;
  use ieee.numeric_std.all;
  use ieee.std_logic_1164.all;

library lib_vita_hdl;
  use lib_vita_hdl.pck_vita_model.all;
  use lib_vita_hdl.pck_vita_spi.all;

entity vita_spi is
  generic (
    G_SENSOR: t_sensor_prop
  );
  port (
    ----- SPI Interface -----
    io_spi_ss_n:               in std_logic;
    io_spi_sck:                in std_logic;
    io_spi_mosi:               in std_logic;
    spi_io_miso:              out std_logic;

    ----- Register Interface -----
    reg_mux_color:            out std_logic;
    reg_ser_parallel:         out std_logic;

    reg_pll_pwd_n:            out std_logic;
    reg_pll_en:               out std_logic;
    reg_pll_bypass:           out std_logic;
    reg_pll_mdiv:             out integer;
    reg_pll_ndiv:             out integer;
    reg_pll_pdiv:             out integer;
    pll_reg_lock:              in std_logic;

    reg_cgen_enable_analog:   out std_logic;
    reg_cgen_enable_log:      out std_logic;
    reg_cgen_select_pll:      out std_logic;
    reg_cgen_adc_mode:        out std_logic;

    reg_log_enable:           out std_logic;

    reg_imc_pwd_n:            out std_logic;
    reg_mux_pwd_n:            out std_logic;

    reg_lvds_clock_out_pwd_n: out std_logic;
    reg_lvds_sync_pwd_n:      out std_logic;
    reg_lvds_data_pwd_n:      out std_logic;

    reg_db_crc_seed:             out std_logic;
    reg_db_auto_blackcal_enable: out std_logic;
    reg_db_black_offset:         out natural;
    reg_db_blackcal_offset:      out natural;
    reg_db_blackcal_offset_dec:  out std_logic;
    reg_db_8bit_mode:            out std_logic;
    reg_db_bl_frame_valid_enable:out std_logic;
    reg_db_bl_line_valid_enable: out std_logic;

    reg_db_trainingpattern:   out unsigned(C_DB_DATA_WIDTH - 1 downto 0);

    reg_db_frame_sync:
      out unsigned(C_DB_DATA_WIDTH - C_DB_SYNC_WIDTH - 1 downto 0);

    reg_db_bl:                out unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    reg_db_img:               out unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    reg_db_crc:               out unsigned(C_DB_DATA_WIDTH - 1 downto 0);
    reg_db_tr:                out unsigned(C_DB_DATA_WIDTH - 1 downto 0);

    reg_db_testpattern_en:    out std_logic;
    reg_db_prbs_en:           out std_logic;
    reg_db_inc_testpattern:   out std_logic;
    reg_db_frame_testpattern: out std_logic;

    reg_db_testpattern:
      out t_db_data_array(G_SENSOR.kernel_size/2-1 downto 0);

    reg_seq_enable:                 out std_logic;
    reg_seq_rolling_shutter_enable: out std_logic;
    reg_seq_triggered_mode:         out std_logic;
    reg_seq_slave_mode:             out std_logic;
    reg_seq_subsampling:            out std_logic;
    reg_seq_binning:                out std_logic;
    reg_seq_fr_mode:                out std_logic;
    reg_seq_subsampling_mode:       out std_logic;
    reg_seq_binning_mode:           out std_logic;
    reg_seq_black_lines:            out natural;
    reg_seq_gate_first_line:        out natural;
    reg_seq_dummy_lines:            out natural;
    reg_seq_mult_timer:             out natural;
    reg_seq_fr_length:              out natural;
    reg_seq_exposure:               out natural;
    reg_seq_roi:                    out t_roi_configuration_array
                                       (G_SENSOR.rois - 1 downto 0);
    reg_seq_roi_active:             out unsigned(G_SENSOR.rois - 1 downto 0);
    reg_seq_sync_roi:               out std_logic;
    reg_seq_sync_exposure:          out std_logic;

    ----- System -----
    cgen_log_clk:              in std_logic;
    rgen_log_reset_n:          in std_logic;
    io_sys_reset_n:            in std_logic
  );
end vita_spi;

architecture model of vita_spi is
    type t_spi_state is (SPI_IDLE, SPI_RECEIVE_ADDRESS,
                         SPI_RECEIVE_RW, SPI_READ, SPI_WRITE);

    signal registers: t_vita_reg_array := (others => (others => '0'));
    signal reg_log_enable_int: boolean;
    signal enable_post_40:     boolean;

begin

  MAIN: process(rgen_log_reset_n, cgen_log_clk)
  begin
    if rgen_log_reset_n = '0' then
      enable_post_40 <= false;
    elsif cgen_log_clk'event and cgen_log_clk = '1' then
      -- Addresses >= 40 are only accessible when log_clk is running
      -- and reg_log_enable = '1'
      enable_post_40 <= reg_log_enable_int;
    end if;
  end process;

  MAIN_SPI: process(io_sys_reset_n, io_spi_ss_n, io_spi_sck)
    variable spi_state:     t_spi_state;
    variable address:       t_spi_address;
    variable data:          t_spi_data;
    variable spi_count:     natural;
    variable spi_completed: boolean;
  begin

    if io_sys_reset_n = '0' then
      registers     <= C_SPI_DEFAULT(G_SENSOR);
      spi_state     := SPI_RECEIVE_ADDRESS;
      address       := (others => '0');
      data          := (others => '0');
      spi_count     := 0;
      spi_completed := false;
      spi_io_miso   <= 'Z';

    elsif io_spi_ss_n = '1' then
      spi_io_miso <= 'Z';

      if spi_completed then
        registers(to_integer(address)) <= data;
      end if;

      -- PLL Status register
      registers(24)(0) <= pll_reg_lock;

      address       := (others => '0');
      data          := (others => '0');
      spi_count     := 0;
      spi_completed := false;
      spi_state     := SPI_RECEIVE_ADDRESS;

    elsif io_spi_sck'event and io_spi_sck = '1' then
      spi_io_miso <= 'Z';

      case spi_state is
        when SPI_IDLE =>
          null;

        when SPI_RECEIVE_ADDRESS =>
          address(C_SPI_ADDRESS_WIDTH - 1 downto 1) :=
            address(C_SPI_ADDRESS_WIDTH - 2 downto 0);
          address(0) := io_spi_mosi;

          spi_count := spi_count + 1;

          if spi_count = C_SPI_ADDRESS_WIDTH then
            spi_count := 0;
            spi_state := SPI_RECEIVE_RW;
          end if;

        when SPI_RECEIVE_RW =>
          if to_integer(address) < 40 or enable_post_40 then
            data      := registers(to_integer(address));
            spi_state := SPI_READ;
            if io_spi_mosi = '1' then
              spi_state := SPI_WRITE;
              if to_integer(address) < 2 then
                -- RO registers
                spi_state := SPI_IDLE;
              end if;
            end if;
          else
            spi_state := SPI_IDLE;
          end if;

        when SPI_WRITE =>
          data(C_SPI_DATA_WIDTH - 1 downto 1) :=
            data(C_SPI_DATA_WIDTH - 2 downto 0);
          data(0) := io_spi_mosi;

          spi_count := spi_count + 1;

          if spi_count = C_SPI_DATA_WIDTH then
            spi_completed := true;
            spi_state     := SPI_IDLE;
          end if;

        when SPI_READ =>
          spi_io_miso <= data(C_SPI_DATA_WIDTH - 1);
          data(C_SPI_DATA_WIDTH - 1 downto 1) :=
            data(C_SPI_DATA_WIDTH - 2 downto 0);
          data(0) := '0';

      end case;

    end if;

  end process;

  reg_mux_color            <= registers(2)(0);
  reg_ser_parallel         <= registers(2)(1);

  reg_pll_pwd_n            <= registers(16)(0);
  reg_pll_en               <= registers(16)(1);
  reg_pll_bypass           <= registers(16)(2);

  reg_pll_mdiv             <= to_integer(registers(17)( 7 downto  0));
  reg_pll_ndiv             <= to_integer(registers(17)(12 downto  8));
  reg_pll_pdiv             <= to_integer(registers(17)(14 downto 13));

  reg_cgen_enable_analog   <= registers(32)(0);
  reg_cgen_enable_log      <= registers(32)(1);
  reg_cgen_select_pll      <= registers(32)(2);
  reg_cgen_adc_mode        <= registers(32)(3);

  reg_log_enable_int       <= (registers(34)(0) = '1');
  reg_log_enable           <= registers(34)(0);

  reg_imc_pwd_n            <= registers(40)(0);
  reg_mux_pwd_n            <= registers(40)(1);

  reg_lvds_clock_out_pwd_n <= registers(112)(0);
  reg_lvds_sync_pwd_n      <= registers(112)(1);
  reg_lvds_data_pwd_n      <= registers(112)(2);

  reg_db_crc_seed          <= registers(128)(15);
  reg_db_black_offset      <= to_integer(registers(128)(7 downto 0));

  reg_db_auto_blackcal_enable <= registers(129)(0);
  reg_db_blackcal_offset      <= to_integer(registers(129)(9 downto 1));
  reg_db_blackcal_offset_dec  <= registers(129)(10);
  reg_db_8bit_mode            <= registers(129)(13);
  reg_db_bl_frame_valid_enable<= registers(129)(14);
  reg_db_bl_line_valid_enable <= registers(129)(15);

  reg_db_trainingpattern   <= registers(130)(C_DB_DATA_WIDTH-1 downto 0);

  reg_db_frame_sync        <=
    registers(131)(C_DB_DATA_WIDTH-C_DB_SYNC_WIDTH-1 downto 0);

  reg_db_bl                <= registers(132)(C_DB_DATA_WIDTH-1 downto 0);
  reg_db_img               <= registers(133)(C_DB_DATA_WIDTH-1 downto 0);
  reg_db_crc               <= registers(134)(C_DB_DATA_WIDTH-1 downto 0);
  reg_db_tr                <= registers(135)(C_DB_DATA_WIDTH-1 downto 0);

  reg_db_testpattern_en    <= registers(144)(0);
  reg_db_prbs_en           <= registers(144)(2);
  reg_db_inc_testpattern   <= registers(144)(1);
  reg_db_frame_testpattern <= registers(144)(3);

  reg_seq_enable                 <= registers(192)(0);
  reg_seq_rolling_shutter_enable <= registers(192)(1);
  reg_seq_triggered_mode         <= registers(192)(4);
  reg_seq_slave_mode             <= registers(192)(5);
  reg_seq_subsampling            <= registers(192)(7);
  reg_seq_binning                <= registers(192)(8);
  reg_seq_fr_mode                <= registers(194)(2);
  reg_seq_subsampling_mode       <= registers(194)(8);
  reg_seq_binning_mode           <= registers(194)(9);

  reg_seq_roi_active(7 downto 0) <= registers(195)(7 downto 0);
  GEN_VITA25K: if G_SENSOR.id = VITA25k generate
    reg_seq_roi_active(15 downto  0) <= registers(195);
    reg_seq_roi_active(31 downto 16) <= registers(196);
  end generate;

  reg_seq_black_lines            <=
    to_integer(registers(197)(C_REG_BLACK_LINES_WIDTH-1 downto 0));
  reg_seq_gate_first_line        <=
    to_integer(registers(197)(C_SPI_DATA_WIDTH - 1 downto
                              C_REG_BLACK_LINES_WIDTH));
  reg_seq_dummy_lines            <=
    to_integer(registers(198)(C_REG_DUMMY_LINES_WIDTH-1 downto 0));

  reg_seq_mult_timer             <= to_integer(registers(199));
  reg_seq_fr_length              <= to_integer(registers(200));
  reg_seq_exposure               <= to_integer(registers(201));

  GEN_ROIS:
  for roi_index in 0 to G_SENSOR.rois - 1 generate
    reg_seq_roi(roi_index).x_start <=
      to_integer(registers(C_REG_SEQ_ROI_OFFSET +
                           roi_index*C_REG_SEQ_ROI_REGS +
                           C_REG_SEQ_ROI_X_START_RELOFFSET)
                           (C_X_RES_BITS - 1 downto 0)
                );

    reg_seq_roi(roi_index).x_end <=
      to_integer(registers(C_REG_SEQ_ROI_OFFSET +
                           roi_index*C_REG_SEQ_ROI_REGS +
                           C_REG_SEQ_ROI_X_END_RELOFFSET)(15 downto 8)
                           (2*C_X_RES_BITS - 1 downto C_X_RES_BITS)
                );

    reg_seq_roi(roi_index).y_start <=
      to_integer(registers(C_REG_SEQ_ROI_OFFSET +
                           roi_index*C_REG_SEQ_ROI_REGS +
                           C_REG_SEQ_ROI_Y_START_RELOFFSET)
                           (C_Y_RES_BITS - 1 downto 0)
                );

    reg_seq_roi(roi_index).y_end <=
      to_integer(registers(C_REG_SEQ_ROI_OFFSET +
                           roi_index*C_REG_SEQ_ROI_REGS +
                           C_REG_SEQ_ROI_Y_END_RELOFFSET)
                           (C_Y_RES_BITS - 1 downto 0)
                );

  end generate;

  reg_seq_sync_roi      <= registers(206)(5);
  reg_seq_sync_exposure <= registers(206)(3);

  GEN_TESTPATTERN_LSB:
    for db_index in G_SENSOR.kernel_size/2/2-1 downto 0 generate
    -- channels 0..7
    GEN_CH0_7: if db_index < 4 generate
      -- Even channels
      reg_db_testpattern(db_index*2)(7 downto 0)
        <= registers(C_REG_DB_TESTPATTERN_OFFSET+db_index)(7 downto 0);

      -- Odd channels
      reg_db_testpattern(db_index*2+1)(7 downto 0)
        <= registers(C_REG_DB_TESTPATTERN_OFFSET+db_index)(15 downto 8);
    end generate;

    -- channels 8 .. 15
    GEN_CH8_15: if db_index >= 4 and db_index < 8 generate
      -- Even channels
      reg_db_testpattern(db_index*2)(7 downto 0)
        <= registers(C_REG_DB_TESTPATTERN_OFFSET+db_index-4)(7 downto 0);

      -- Odd channels
      reg_db_testpattern(db_index*2+1)(7 downto 0)
        <= registers(C_REG_DB_TESTPATTERN_OFFSET+db_index-4)(15 downto 8);
    end generate;

    -- channels 16 .. 23
    GEN_CH16_23: if db_index >= 8 and db_index < 12 generate
      -- Even channels
      reg_db_testpattern(db_index*2)(7 downto 0)
        <= registers(C_REG_DB_TESTPATTERN_OFFSET+db_index-8)(7 downto 0);

      -- Odd channels
      reg_db_testpattern(db_index*2+1)(7 downto 0)
        <= registers(C_REG_DB_TESTPATTERN_OFFSET+db_index-8)(15 downto 8);
    end generate;

    -- channels 24 .. 31
    GEN_CH24_31: if db_index >= 12 and db_index < 16 generate
      -- Even channels
      reg_db_testpattern(db_index*2)(7 downto 0)
        <= registers(C_REG_DB_TESTPATTERN_OFFSET+db_index-12)(7 downto 0);

      -- Odd channels
      reg_db_testpattern(db_index*2+1)(7 downto 0)
        <= registers(C_REG_DB_TESTPATTERN_OFFSET+db_index-12)(15 downto 8);
    end generate;

  end generate;

  GEN_TESTPATTERN_MSB:
  for pos in 0 to G_SENSOR.kernel_size/2 - 1 generate
    GEN_MSB_CH0_7: if pos < 8 generate
      reg_db_testpattern(pos)(9 downto 8)
        <= registers(C_REG_DB_TESTPATTERN_OFFSET_MSB)(pos*2+1 downto pos*2);
    end generate;

    GEN_MSB_CH8_16: if pos >= 8 and pos < 16 generate
      reg_db_testpattern(pos)(9 downto 8)
        <= registers(C_REG_DB_TESTPATTERN_OFFSET_MSB)((pos-8)*2+1 downto
                                                         (pos-8)*2);
    end generate;

    GEN_MSB_CH16_24: if pos >= 16 and pos < 24 generate
      reg_db_testpattern(pos)(9 downto 8)
        <= registers(C_REG_DB_TESTPATTERN_OFFSET_MSB)((pos-16)*2+1 downto
                                                         (pos-16)*2);
    end generate;

    GEN_MSB_CH24_32: if pos >= 24 and pos < 32 generate
      reg_db_testpattern(pos)(9 downto 8)
        <= registers(C_REG_DB_TESTPATTERN_OFFSET_MSB)((pos-24)*2+1 downto
                                                         (pos-24)*2);
    end generate;

  end generate;

end model;

