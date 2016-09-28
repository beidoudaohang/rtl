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
-- $Id: design#hdl#model#src#vita.vhd,v 1.6 2013-01-31 18:56:38+01 ffynvr Exp $
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
--
-- File Creation Date: Mon, 24 Oct 2011-18:02:20
-- *********************************************************************

library std;
  use std.textio.all;

library ieee;
  use ieee.numeric_std.all;
  use ieee.std_logic_1164.all;

library lib_vita_hdl;
  use lib_vita_hdl.pck_vita_model.all;
  use lib_vita_hdl.pck_vita_seq.all;
  use lib_vita_hdl.pck_vita_spi.all;

library lib_model;
  use lib_model.pck_ppm.all;
  use lib_model.pck_frame_format.all;

entity vita is
  generic(G_SENSOR:   t_sensor_prop;
          G_COLOR:    boolean := false;
          G_IMG_NAME: string := "input"
         );
  port(clk_pll:        in std_logic;
       lvds_clk_in:    in t_lvds;
       mosi:           in std_logic;
       reset_n:        in std_logic;
       sck:            in std_logic;
       ss_n:           in std_logic;
       adc_mode:       in std_logic;
       trigger0:       in std_logic;
       trigger1:       in std_logic;
       trigger2:       in std_logic;
       clock_out:     out t_lvds;
       dout:          out t_lvds_array(G_SENSOR.kernel_size/2-1 downto 0);
       pdata:         out unsigned(C_DB_DATA_WIDTH - 1 downto 0);
       frame_valid:   out std_logic;
       line_valid:    out std_logic;
       clk_out:       out std_logic;
       miso:          out std_logic;
       monitor0:      out std_logic;
       monitor1:      out std_logic;
       monitor2:      out std_logic;
       sync:          out t_lvds
      );
end vita;

architecture model of vita is

  -- component declarations
  -------------------------

  component vita_mux is
    generic(G_SENSOR: t_sensor_prop
           );
    port(reg_mux_color:            in std_logic;
         reg_mux_pwd_n:            in std_logic;
         seq_mux_address:          in integer range 0 to G_SENSOR.kernels - 1;
         seq_mux_address_valid:    in std_logic;
         seq_mux_subsampling:      in std_logic;
         seq_mux_binning:          in std_logic;
         imc_mux_column:           in t_real_array(G_SENSOR.x_width - 1 downto 0);
         mux_afe_signal:          out t_real_array(G_SENSOR.kernel_size - 1 downto 0)
        );
  end component;

  component vita_spi is
    generic(G_SENSOR: t_sensor_prop
           );
    port(io_spi_ss_n:                       in std_logic;
         io_spi_sck:                        in std_logic;
         io_spi_mosi:                       in std_logic;
         spi_io_miso:                      out std_logic;
         reg_mux_color:                    out std_logic;
         reg_ser_parallel:                 out std_logic;
         reg_pll_pwd_n:                    out std_logic;
         reg_pll_en:                       out std_logic;
         reg_pll_bypass:                   out std_logic;
         reg_pll_mdiv:                     out integer;
         reg_pll_ndiv:                     out integer;
         reg_pll_pdiv:                     out integer;
         pll_reg_lock:                      in std_logic;
         reg_cgen_enable_analog:           out std_logic;
         reg_cgen_enable_log:              out std_logic;
         reg_cgen_select_pll:              out std_logic;
         reg_cgen_adc_mode:                out std_logic;
         reg_log_enable:                   out std_logic;
         reg_imc_pwd_n:                    out std_logic;
         reg_mux_pwd_n:                    out std_logic;
         reg_lvds_clock_out_pwd_n:         out std_logic;
         reg_lvds_sync_pwd_n:              out std_logic;
         reg_lvds_data_pwd_n:              out std_logic;
         reg_db_crc_seed:                  out std_logic;
         reg_db_auto_blackcal_enable:      out std_logic;
         reg_db_black_offset:              out natural;
         reg_db_blackcal_offset:           out natural;
         reg_db_blackcal_offset_dec:       out std_logic;
         reg_db_8bit_mode:                 out std_logic;
         reg_db_bl_frame_valid_enable:     out std_logic;
         reg_db_bl_line_valid_enable:      out std_logic;
         reg_db_trainingpattern:           out unsigned(C_DB_DATA_WIDTH - 1 downto 0);
         reg_db_frame_sync:                out unsigned(C_DB_DATA_WIDTH - C_DB_SYNC_WIDTH - 1 downto 0);
         reg_db_bl:                        out unsigned(C_DB_DATA_WIDTH - 1 downto 0);
         reg_db_img:                       out unsigned(C_DB_DATA_WIDTH - 1 downto 0);
         reg_db_crc:                       out unsigned(C_DB_DATA_WIDTH - 1 downto 0);
         reg_db_tr:                        out unsigned(C_DB_DATA_WIDTH - 1 downto 0);
         reg_db_testpattern_en:            out std_logic;
         reg_db_prbs_en:                   out std_logic;
         reg_db_inc_testpattern:           out std_logic;
         reg_db_frame_testpattern:         out std_logic;
         reg_db_testpattern:               out t_db_data_array(G_SENSOR.kernel_size/2-1 downto 0);
         reg_seq_enable:                   out std_logic;
         reg_seq_rolling_shutter_enable:   out std_logic;
         reg_seq_triggered_mode:           out std_logic;
         reg_seq_slave_mode:               out std_logic;
         reg_seq_subsampling:              out std_logic;
         reg_seq_binning:                  out std_logic;
         reg_seq_fr_mode:                  out std_logic;
         reg_seq_subsampling_mode:         out std_logic;
         reg_seq_binning_mode:             out std_logic;
         reg_seq_black_lines:              out natural;
         reg_seq_gate_first_line:          out natural;
         reg_seq_dummy_lines:              out natural;
         reg_seq_mult_timer:               out natural;
         reg_seq_fr_length:                out natural;
         reg_seq_exposure:                 out natural;
         reg_seq_roi:                      out t_roi_configuration_array
                                       (G_SENSOR.rois - 1 downto 0);
         reg_seq_roi_active:               out unsigned(G_SENSOR.rois - 1 downto 0);
         reg_seq_sync_roi:                 out std_logic;
         reg_seq_sync_exposure:            out std_logic;
         cgen_log_clk:                      in std_logic;
         rgen_log_reset_n:                  in std_logic;
         io_sys_reset_n:                    in std_logic
        );
  end component;

  component vita_adc is
    generic(G_SENSOR: t_sensor_prop
           );
    port(mux_afe_signal:      in t_real_array(G_SENSOR.kernel_size - 1 downto 0);
         afe_db_data:        out t_db_data_array(G_SENSOR.kernel_size - 1 downto 0);
         cgen_afe_clk:        in std_logic;
         rgen_afe_reset_n:    in std_logic
        );
  end component;

  component vita_rgen is
    port(rgen_log_reset_n:   out std_logic;
         rgen_afe_reset_n:   out std_logic;
         rgen_ser_reset_n:   out std_logic;
         cgen_log_clk:        in std_logic;
         cgen_afe_clk:        in std_logic;
         cgen_ser_clk:        in std_logic;
         io_sys_reset_n:      in std_logic
        );
  end component;

  component vita_ser is
    generic(G_SENSOR: t_sensor_prop
           );
    port(reg_cgen_adc_mode:           in std_logic;
         reg_ser_parallel:            in std_logic;
         reg_lvds_clock_out_pwd_n:    in std_logic;
         reg_lvds_sync_pwd_n:         in std_logic;
         reg_lvds_data_pwd_n:         in std_logic;
         db_ser_frame_valid:          in std_logic;
         db_ser_line_valid:           in std_logic;
         db_ser_clock:                in t_db_data;
         db_ser_sync:                 in t_db_data;
         db_ser_data:                 in t_db_data_array(G_SENSOR.kernel_size/2-1 downto 0);
         lvdstx_pad_clock:           out t_lvds;
         lvdstx_pad_sync:            out t_lvds;
         lvdstx_pad_data:            out t_lvds_array(G_SENSOR.kernel_size/2-1 downto 0);
         ser_io_pdata:               out unsigned(C_DB_DATA_WIDTH - 1 downto 0);
         ser_io_frame_valid:         out std_logic;
         ser_io_line_valid:          out std_logic;
         ser_io_clk:                 out std_logic;
         cgen_ser_clk:                in std_logic;
         cgen_ser_load:               in std_logic;
         rgen_ser_reset_n:            in std_logic
        );
  end component;

  component vita_clkgen is
    generic(G_SENSOR: t_sensor_prop
           );
    port(adc_mode:                  in std_logic;
         reg_cgen_enable_analog:    in std_logic;
         reg_cgen_enable_log:       in std_logic;
         reg_cgen_select_pll:       in std_logic;
         reg_cgen_adc_mode:         in std_logic;
         cgen_log_clk:             out std_logic;
         cgen_afe_clk:             out std_logic;
         cgen_ser_clk:             out std_logic;
         cgen_ser_load:            out std_logic;
         pll_cgen_clk:              in std_logic;
         lvds_cgen_clk:             in t_lvds;
         io_sys_reset_n:            in std_logic
        );
  end component;

  component vita_seq is
    generic(G_SENSOR: t_sensor_prop
           );
    port(io_seq_trigger0:                   in std_logic;
         io_seq_trigger1:                   in std_logic;
         io_seq_trigger2:                   in std_logic;
         reg_mux_color:                     in std_logic;
         reg_seq_enable:                    in std_logic;
         reg_seq_rolling_shutter_enable:    in std_logic;
         reg_seq_triggered_mode:            in std_logic;
         reg_seq_slave_mode:                in std_logic;
         reg_seq_subsampling:               in std_logic;
         reg_seq_binning:                   in std_logic;
         reg_seq_fr_mode:                   in std_logic;
         reg_seq_subsampling_mode:          in std_logic;
         reg_seq_binning_mode:              in std_logic;
         reg_seq_black_lines:               in natural;
         reg_seq_gate_first_line:           in natural;
         reg_seq_dummy_lines:               in natural;
         reg_seq_mult_timer:                in natural;
         reg_seq_fr_length:                 in natural;
         reg_seq_exposure:                  in natural;
         reg_seq_roi:                       in t_roi_configuration_array
                                       (G_SENSOR.rois - 1 downto 0);
         reg_seq_roi_active:                in unsigned(G_SENSOR.rois - 1 downto 0);
         reg_seq_sync_roi:                  in std_logic;
         reg_seq_sync_exposure:             in std_logic;
         seq_mux_address:                  out integer range 0 to G_SENSOR.kernels - 1;
         seq_mux_address_valid:            out std_logic;
         seq_mux_binning:                  out std_logic;
         seq_mux_subsampling:              out std_logic;
         seq_imc_select:                   out std_logic;
         seq_imc_black:                    out std_logic;
         seq_imc_y_address:                out natural;
         seq_db_black:                     out std_logic;
         seq_db_frame_valid:               out std_logic;
         seq_db_line_valid:                out std_logic;
         seq_db_sync:                      out t_sync;
         seq_db_roi_id:                    out natural;
         seq_io_monitor0:                  out std_logic;
         seq_io_monitor1:                  out std_logic;
         seq_io_monitor2:                  out std_logic;
         cgen_log_clk:                      in std_logic;
         cgen_afe_clk:                      in std_logic;
         rgen_log_reset_n:                  in std_logic
        );
  end component;

  component vita_imc is
    generic(G_SENSOR:   t_sensor_prop;
            G_IMG_NAME: string := "input";
            G_COLOR:    boolean := false
           );
    port(reg_imc_pwd_n:        in std_logic;
         reg_db_8bit_mode:     in std_logic;
         seq_imc_select:       in std_logic;
         seq_imc_black:        in std_logic;
         seq_imc_y_address:    in natural;
         imc_mux_column:      out t_real_array(G_SENSOR.x_width-1 downto 0)
        );
  end component;

  component vita_io is
    generic(G_SENSOR: t_sensor_prop
           );
    port(mosi:                in std_logic;
         sck:                 in std_logic;
         ss_n:                in std_logic;
         miso:               out std_logic;
         trigger0:            in std_logic;
         trigger1:            in std_logic;
         trigger2:            in std_logic;
         monitor0:           out std_logic;
         monitor1:           out std_logic;
         monitor2:           out std_logic;
         clock_out:          out t_lvds;
         dout:               out t_lvds_array(G_SENSOR.kernel_size/2-1 downto 0);
         sync:               out t_lvds;
         pdata:              out unsigned(C_DB_DATA_WIDTH - 1 downto 0);
         frame_valid:        out std_logic;
         line_valid:         out std_logic;
         clk_out:            out std_logic;
         clk_pll:             in std_logic;
         lvds_clk_in:         in t_lvds;
         reset_n:             in std_logic;
         io_spi_mosi:        out std_logic;
         io_spi_sck:         out std_logic;
         io_spi_ss_n:        out std_logic;
         spi_io_miso:         in std_logic;
         io_seq_trigger0:    out std_logic;
         io_seq_trigger1:    out std_logic;
         io_seq_trigger2:    out std_logic;
         seq_io_monitor0:     in std_logic;
         seq_io_monitor1:     in std_logic;
         seq_io_monitor2:     in std_logic;
         lvdstx_pad_clock:    in t_lvds;
         lvdstx_pad_data:     in t_lvds_array(G_SENSOR.kernel_size/2-1 downto 0);
         lvdstx_pad_sync:     in t_lvds;
         ser_io_pdata:        in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
         ser_io_frame_valid:  in std_logic;
         ser_io_line_valid:   in std_logic;
         ser_io_clk:          in std_logic;
         io_pll_clk:         out std_logic;
         lvds_cgen_clk:      out t_lvds;
         io_sys_reset_n:     out std_logic
        );
  end component;

  component vita_pll is
    port(reg_pll_pwd_n:     in std_logic;
         reg_pll_en:        in std_logic;
         reg_pll_bypass:    in std_logic;
         reg_pll_mdiv:      in integer;
         reg_pll_ndiv:      in integer;
         reg_pll_pdiv:      in integer;
         pll_reg_lock:     out std_logic;
         pll_cgen_clk:     out std_logic;
         io_pll_clk:        in std_logic;
         io_sys_reset_n:    in std_logic
        );
  end component;

  component vita_db is
    generic(G_SENSOR: t_sensor_prop
           );
    port(reg_log_enable:                 in std_logic;
         reg_db_8bit_mode:               in std_logic;
         reg_db_bl_frame_valid_enable:   in std_logic;
         reg_db_bl_line_valid_enable:    in std_logic;
         reg_db_auto_blackcal_enable:    in std_logic;
         reg_db_black_offset:            in natural;
         reg_db_blackcal_offset:         in natural;
         reg_db_blackcal_offset_dec:     in std_logic;
         reg_db_crc_seed:                in std_logic;
         reg_db_testpattern_en:          in std_logic;
         reg_db_prbs_en:                 in std_logic;
         reg_db_inc_testpattern:         in std_logic;
         reg_db_frame_testpattern:       in std_logic;
         reg_db_testpattern:             in t_db_data_array(G_SENSOR.kernel_size/2-1 downto 0);
         reg_db_trainingpattern:         in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
         reg_db_frame_sync:              in unsigned(C_DB_DATA_WIDTH - C_DB_SYNC_WIDTH - 1 downto 0);
         reg_db_tr:                      in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
         reg_db_img:                     in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
         reg_db_bl:                      in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
         reg_db_crc:                     in unsigned(C_DB_DATA_WIDTH - 1 downto 0);
         seq_db_frame_valid:             in std_logic;
         seq_db_line_valid:              in std_logic;
         seq_db_black:                   in std_logic;
         seq_db_sync:                    in t_sync;
         seq_db_roi_id:                  in natural;
         afe_db_data:                    in t_db_data_array(G_SENSOR.kernel_size - 1 downto 0);
         db_ser_frame_valid:            out std_logic;
         db_ser_line_valid:             out std_logic;
         db_ser_clock:                  out t_db_data;
         db_ser_sync:                   out t_db_data;
         db_ser_data:                   out t_db_data_array(G_SENSOR.kernel_size/2 - 1 downto 0);
         cgen_log_clk:                   in std_logic;
         rgen_log_reset_n:               in std_logic
        );
  end component;

  -- signal declarations
  ----------------------

  signal afe_db_data:                     t_db_data_array(G_SENSOR.kernel_size - 1 downto 0);
  signal cgen_afe_clk:                    std_logic;
  signal cgen_log_clk:                    std_logic;
  signal cgen_ser_clk:                    std_logic;
  signal cgen_ser_load:                   std_logic;
  signal db_ser_frame_valid:              std_logic;
  signal db_ser_line_valid:               std_logic;
  signal db_ser_clock:                    t_db_data;
  signal db_ser_data:                     t_db_data_array(G_SENSOR.kernel_size/2 - 1 downto 0);
  signal db_ser_sync:                     t_db_data;
  signal imc_mux_column:                  t_real_array(G_SENSOR.x_width-1 downto 0);
  signal io_pll_clk:                      std_logic;
  signal io_seq_trigger0:                 std_logic;
  signal io_seq_trigger1:                 std_logic;
  signal io_seq_trigger2:                 std_logic;
  signal io_spi_mosi:                     std_logic;
  signal io_spi_sck:                      std_logic;
  signal io_spi_ss_n:                     std_logic;
  signal io_sys_reset_n:                  std_logic;
  signal lvds_cgen_clk:                   t_lvds;
  signal lvdstx_pad_clock:                t_lvds;
  signal lvdstx_pad_data:                 t_lvds_array(G_SENSOR.kernel_size/2-1 downto 0);
  signal lvdstx_pad_sync:                 t_lvds;
  signal ser_io_pdata:                    unsigned(C_DB_DATA_WIDTH - 1 downto 0);
  signal ser_io_frame_valid:              std_logic;
  signal ser_io_line_valid:               std_logic;
  signal ser_io_clk:                      std_logic;
  signal mux_afe_signal:                  t_real_array(G_SENSOR.kernel_size - 1 downto 0);
  signal pll_cgen_clk:                    std_logic;
  signal pll_reg_lock:                    std_logic;
  signal reg_cgen_adc_mode:               std_logic;
  signal reg_cgen_enable_analog:          std_logic;
  signal reg_cgen_enable_log:             std_logic;
  signal reg_cgen_select_pll:             std_logic;
  signal reg_db_8bit_mode:                std_logic;
  signal reg_db_bl_frame_valid_enable:    std_logic;
  signal reg_db_bl_line_valid_enable:     std_logic;
  signal reg_db_auto_blackcal_enable:     std_logic;
  signal reg_db_bl:                       unsigned(C_DB_DATA_WIDTH - 1 downto 0);
  signal reg_db_black_offset:             natural;
  signal reg_db_blackcal_offset:          natural;
  signal reg_db_blackcal_offset_dec:      std_logic;
  signal reg_db_crc:                      unsigned(C_DB_DATA_WIDTH - 1 downto 0);
  signal reg_db_crc_seed:                 std_logic;
  signal reg_db_frame_sync:               unsigned(C_DB_DATA_WIDTH - C_DB_SYNC_WIDTH - 1 downto 0);
  signal reg_db_frame_testpattern:        std_logic;
  signal reg_db_img:                      unsigned(C_DB_DATA_WIDTH - 1 downto 0);
  signal reg_db_inc_testpattern:          std_logic;
  signal reg_db_prbs_en:                  std_logic;
  signal reg_db_testpattern:              t_db_data_array(G_SENSOR.kernel_size/2-1 downto 0);
  signal reg_db_testpattern_en:           std_logic;
  signal reg_db_tr:                       unsigned(C_DB_DATA_WIDTH - 1 downto 0);
  signal reg_db_trainingpattern:          unsigned(C_DB_DATA_WIDTH - 1 downto 0);
  signal reg_imc_pwd_n:                   std_logic;
  signal reg_log_enable:                  std_logic;
  signal reg_lvds_clock_out_pwd_n:        std_logic;
  signal reg_lvds_data_pwd_n:             std_logic;
  signal reg_lvds_sync_pwd_n:             std_logic;
  signal reg_mux_color:                   std_logic;
  signal reg_ser_parallel:                std_logic;
  signal reg_mux_pwd_n:                   std_logic;
  signal reg_pll_bypass:                  std_logic;
  signal reg_pll_en:                      std_logic;
  signal reg_pll_mdiv:                    integer;
  signal reg_pll_ndiv:                    integer;
  signal reg_pll_pdiv:                    integer;
  signal reg_pll_pwd_n:                   std_logic;
  signal reg_seq_binning:                 std_logic;
  signal reg_seq_binning_mode:            std_logic;
  signal reg_seq_black_lines:             natural;
  signal reg_seq_gate_first_line:         natural;
  signal reg_seq_dummy_lines:             natural;
  signal reg_seq_enable:                  std_logic;
  signal reg_seq_exposure:                natural;
  signal reg_seq_fr_length:               natural;
  signal reg_seq_fr_mode:                 std_logic;
  signal reg_seq_mult_timer:              natural;
  signal reg_seq_roi:                     t_roi_configuration_array
                                       (G_SENSOR.rois - 1 downto 0);
  signal reg_seq_roi_active:              unsigned(G_SENSOR.rois - 1 downto 0);
  signal reg_seq_sync_roi:                std_logic;
  signal reg_seq_sync_exposure:           std_logic;
  signal reg_seq_rolling_shutter_enable:  std_logic;
  signal reg_seq_slave_mode:              std_logic;
  signal reg_seq_subsampling:             std_logic;
  signal reg_seq_subsampling_mode:        std_logic;
  signal reg_seq_triggered_mode:          std_logic;
  signal rgen_afe_reset_n:                std_logic;
  signal rgen_log_reset_n:                std_logic;
  signal rgen_ser_reset_n:                std_logic;
  signal seq_db_black:                    std_logic;
  signal seq_db_frame_valid:              std_logic;
  signal seq_db_line_valid:               std_logic;
  signal seq_db_roi_id:                   natural;
  signal seq_db_sync:                     t_sync;
  signal seq_imc_black:                   std_logic;
  signal seq_imc_select:                  std_logic;
  signal seq_imc_y_address:               natural;
  signal seq_io_monitor0:                 std_logic;
  signal seq_io_monitor1:                 std_logic;
  signal seq_io_monitor2:                 std_logic;
  signal seq_mux_address:                 integer range 0 to G_SENSOR.kernels - 1;
  signal seq_mux_address_valid:           std_logic;
  signal seq_mux_binning:                 std_logic;
  signal seq_mux_subsampling:             std_logic;
  signal spi_io_miso:                     std_logic;

begin


  vita_mux_1: vita_mux
    generic map(G_SENSOR => G_SENSOR
               )
    port map(reg_mux_color         => reg_mux_color,
             reg_mux_pwd_n         => reg_mux_pwd_n,
             seq_mux_address       => seq_mux_address,
             seq_mux_address_valid => seq_mux_address_valid,
             seq_mux_subsampling   => seq_mux_subsampling,
             seq_mux_binning       => seq_mux_binning,
             imc_mux_column        => imc_mux_column,
             mux_afe_signal        => mux_afe_signal
            );

  vita_spi_1: vita_spi
    generic map(G_SENSOR => G_SENSOR
               )
    port map(io_spi_ss_n                    => io_spi_ss_n,
             io_spi_sck                     => io_spi_sck,
             io_spi_mosi                    => io_spi_mosi,
             spi_io_miso                    => spi_io_miso,
             reg_mux_color                  => reg_mux_color,
             reg_ser_parallel               => reg_ser_parallel,
             reg_pll_pwd_n                  => reg_pll_pwd_n,
             reg_pll_en                     => reg_pll_en,
             reg_pll_bypass                 => reg_pll_bypass,
             reg_pll_mdiv                   => reg_pll_mdiv,
             reg_pll_ndiv                   => reg_pll_ndiv,
             reg_pll_pdiv                   => reg_pll_pdiv,
             pll_reg_lock                   => pll_reg_lock,
             reg_cgen_enable_analog         => reg_cgen_enable_analog,
             reg_cgen_enable_log            => reg_cgen_enable_log,
             reg_cgen_select_pll            => reg_cgen_select_pll,
             reg_cgen_adc_mode              => reg_cgen_adc_mode,
             reg_log_enable                 => reg_log_enable,
             reg_imc_pwd_n                  => reg_imc_pwd_n,
             reg_mux_pwd_n                  => reg_mux_pwd_n,
             reg_lvds_clock_out_pwd_n       => reg_lvds_clock_out_pwd_n,
             reg_lvds_sync_pwd_n            => reg_lvds_sync_pwd_n,
             reg_lvds_data_pwd_n            => reg_lvds_data_pwd_n,
             reg_db_crc_seed                => reg_db_crc_seed,
             reg_db_auto_blackcal_enable    => reg_db_auto_blackcal_enable,
             reg_db_black_offset            => reg_db_black_offset,
             reg_db_blackcal_offset         => reg_db_blackcal_offset,
             reg_db_blackcal_offset_dec     => reg_db_blackcal_offset_dec,
             reg_db_8bit_mode               => reg_db_8bit_mode,
             reg_db_bl_frame_valid_enable   => reg_db_bl_frame_valid_enable,
             reg_db_bl_line_valid_enable    => reg_db_bl_line_valid_enable,
             reg_db_trainingpattern         => reg_db_trainingpattern,
             reg_db_frame_sync              => reg_db_frame_sync,
             reg_db_bl                      => reg_db_bl,
             reg_db_img                     => reg_db_img,
             reg_db_crc                     => reg_db_crc,
             reg_db_tr                      => reg_db_tr,
             reg_db_testpattern_en          => reg_db_testpattern_en,
             reg_db_prbs_en                 => reg_db_prbs_en,
             reg_db_inc_testpattern         => reg_db_inc_testpattern,
             reg_db_frame_testpattern       => reg_db_frame_testpattern,
             reg_db_testpattern             => reg_db_testpattern,
             reg_seq_enable                 => reg_seq_enable,
             reg_seq_rolling_shutter_enable => reg_seq_rolling_shutter_enable,
             reg_seq_triggered_mode         => reg_seq_triggered_mode,
             reg_seq_slave_mode             => reg_seq_slave_mode,
             reg_seq_subsampling            => reg_seq_subsampling,
             reg_seq_binning                => reg_seq_binning,
             reg_seq_fr_mode                => reg_seq_fr_mode,
             reg_seq_subsampling_mode       => reg_seq_subsampling_mode,
             reg_seq_binning_mode           => reg_seq_binning_mode,
             reg_seq_black_lines            => reg_seq_black_lines,
             reg_seq_gate_first_line        => reg_seq_gate_first_line,
             reg_seq_dummy_lines            => reg_seq_dummy_lines,
             reg_seq_mult_timer             => reg_seq_mult_timer,
             reg_seq_fr_length              => reg_seq_fr_length,
             reg_seq_exposure               => reg_seq_exposure,
             reg_seq_roi                    => reg_seq_roi,
             reg_seq_roi_active             => reg_seq_roi_active,
             reg_seq_sync_roi               => reg_seq_sync_roi,
             reg_seq_sync_exposure          => reg_seq_sync_exposure,
             cgen_log_clk                   => cgen_log_clk,
             rgen_log_reset_n               => rgen_log_reset_n,
             io_sys_reset_n                 => io_sys_reset_n
            );

  vita_adc_1: vita_adc
    generic map(G_SENSOR => G_SENSOR
               )
    port map(mux_afe_signal   => mux_afe_signal,
             afe_db_data      => afe_db_data,
             cgen_afe_clk     => cgen_afe_clk,
             rgen_afe_reset_n => rgen_afe_reset_n
            );

  vita_rgen_1: vita_rgen

    port map(rgen_log_reset_n => rgen_log_reset_n,
             rgen_afe_reset_n => rgen_afe_reset_n,
             rgen_ser_reset_n => rgen_ser_reset_n,
             cgen_log_clk     => cgen_log_clk,
             cgen_afe_clk     => cgen_afe_clk,
             cgen_ser_clk     => cgen_ser_clk,
             io_sys_reset_n   => io_sys_reset_n
            );

  vita_ser_1: vita_ser
    generic map(G_SENSOR => G_SENSOR
               )
    port map(reg_cgen_adc_mode        => reg_cgen_adc_mode,
             reg_ser_parallel         => reg_ser_parallel,
             reg_lvds_clock_out_pwd_n => reg_lvds_clock_out_pwd_n,
             reg_lvds_sync_pwd_n      => reg_lvds_sync_pwd_n,
             reg_lvds_data_pwd_n      => reg_lvds_data_pwd_n,
             db_ser_frame_valid       => db_ser_frame_valid,
             db_ser_line_valid        => db_ser_line_valid,
             db_ser_clock             => db_ser_clock,
             db_ser_sync              => db_ser_sync,
             db_ser_data              => db_ser_data,
             lvdstx_pad_clock         => lvdstx_pad_clock,
             lvdstx_pad_sync          => lvdstx_pad_sync,
             lvdstx_pad_data          => lvdstx_pad_data,
             ser_io_pdata             => ser_io_pdata,
             ser_io_frame_valid       => ser_io_frame_valid,
             ser_io_line_valid        => ser_io_line_valid,
             ser_io_clk               => ser_io_clk,
             cgen_ser_clk             => cgen_ser_clk,
             cgen_ser_load            => cgen_ser_load,
             rgen_ser_reset_n         => rgen_ser_reset_n
            );

  vita_clkgen_1: vita_clkgen
    generic map(G_SENSOR => G_SENSOR
               )
    port map(adc_mode               => adc_mode,
             reg_cgen_enable_analog => reg_cgen_enable_analog,
             reg_cgen_enable_log    => reg_cgen_enable_log,
             reg_cgen_select_pll    => reg_cgen_select_pll,
             reg_cgen_adc_mode      => reg_cgen_adc_mode,
             cgen_log_clk           => cgen_log_clk,
             cgen_afe_clk           => cgen_afe_clk,
             cgen_ser_clk           => cgen_ser_clk,
             cgen_ser_load          => cgen_ser_load,
             pll_cgen_clk           => pll_cgen_clk,
             lvds_cgen_clk          => lvds_cgen_clk,
             io_sys_reset_n         => io_sys_reset_n
            );

  vita_seq_1: vita_seq
    generic map(G_SENSOR => G_SENSOR
               )
    port map(io_seq_trigger0                => io_seq_trigger0,
             io_seq_trigger1                => io_seq_trigger1,
             io_seq_trigger2                => io_seq_trigger2,
             reg_mux_color                  => reg_mux_color,
             reg_seq_enable                 => reg_seq_enable,
             reg_seq_rolling_shutter_enable => reg_seq_rolling_shutter_enable,
             reg_seq_triggered_mode         => reg_seq_triggered_mode,
             reg_seq_slave_mode             => reg_seq_slave_mode,
             reg_seq_subsampling            => reg_seq_subsampling,
             reg_seq_binning                => reg_seq_binning,
             reg_seq_fr_mode                => reg_seq_fr_mode,
             reg_seq_subsampling_mode       => reg_seq_subsampling_mode,
             reg_seq_binning_mode           => reg_seq_binning_mode,
             reg_seq_black_lines            => reg_seq_black_lines,
             reg_seq_gate_first_line        => reg_seq_gate_first_line,
             reg_seq_dummy_lines            => reg_seq_dummy_lines,
             reg_seq_mult_timer             => reg_seq_mult_timer,
             reg_seq_fr_length              => reg_seq_fr_length,
             reg_seq_exposure               => reg_seq_exposure,
             reg_seq_roi                    => reg_seq_roi,
             reg_seq_roi_active             => reg_seq_roi_active,
             reg_seq_sync_roi               => reg_seq_sync_roi,
             reg_seq_sync_exposure          => reg_seq_sync_exposure,
             seq_mux_address                => seq_mux_address,
             seq_mux_address_valid          => seq_mux_address_valid,
             seq_mux_binning                => seq_mux_binning,
             seq_mux_subsampling            => seq_mux_subsampling,
             seq_imc_select                 => seq_imc_select,
             seq_imc_black                  => seq_imc_black,
             seq_imc_y_address              => seq_imc_y_address,
             seq_db_black                   => seq_db_black,
             seq_db_frame_valid             => seq_db_frame_valid,
             seq_db_line_valid              => seq_db_line_valid,
             seq_db_sync                    => seq_db_sync,
             seq_db_roi_id                  => seq_db_roi_id,
             seq_io_monitor0                => seq_io_monitor0,
             seq_io_monitor1                => seq_io_monitor1,
             seq_io_monitor2                => seq_io_monitor2,
             cgen_log_clk                   => cgen_log_clk,
             cgen_afe_clk                   => cgen_afe_clk,
             rgen_log_reset_n               => rgen_log_reset_n
            );

  vita_imc_1: vita_imc
    generic map(G_SENSOR   => G_SENSOR,
                G_IMG_NAME => G_IMG_NAME,
                G_COLOR    => G_COLOR
               )
    port map(reg_imc_pwd_n     => reg_imc_pwd_n,
             reg_db_8bit_mode  => reg_db_8bit_mode,
             seq_imc_select    => seq_imc_select,
             seq_imc_black     => seq_imc_black,
             seq_imc_y_address => seq_imc_y_address,
             imc_mux_column    => imc_mux_column
            );

  vita_io_1: vita_io
    generic map(G_SENSOR => G_SENSOR
               )
    port map(mosi               => mosi,
             sck                => sck,
             ss_n               => ss_n,
             miso               => miso,
             trigger0           => trigger0,
             trigger1           => trigger1,
             trigger2           => trigger2,
             monitor0           => monitor0,
             monitor1           => monitor1,
             monitor2           => monitor2,
             clock_out          => clock_out,
             dout               => dout,
             sync               => sync,
             pdata              => pdata,
             frame_valid        => frame_valid,
             line_valid         => line_valid,
             clk_out            => clk_out,
             clk_pll            => clk_pll,
             lvds_clk_in        => lvds_clk_in,
             reset_n            => reset_n,
             io_spi_mosi        => io_spi_mosi,
             io_spi_sck         => io_spi_sck,
             io_spi_ss_n        => io_spi_ss_n,
             spi_io_miso        => spi_io_miso,
             io_seq_trigger0    => io_seq_trigger0,
             io_seq_trigger1    => io_seq_trigger1,
             io_seq_trigger2    => io_seq_trigger2,
             seq_io_monitor0    => seq_io_monitor0,
             seq_io_monitor1    => seq_io_monitor1,
             seq_io_monitor2    => seq_io_monitor2,
             lvdstx_pad_clock   => lvdstx_pad_clock,
             lvdstx_pad_data    => lvdstx_pad_data,
             lvdstx_pad_sync    => lvdstx_pad_sync,
             ser_io_pdata       => ser_io_pdata,
             ser_io_frame_valid => ser_io_frame_valid,
             ser_io_line_valid  => ser_io_line_valid,
             ser_io_clk         => ser_io_clk,
             io_pll_clk         => io_pll_clk,
             lvds_cgen_clk      => lvds_cgen_clk,
             io_sys_reset_n     => io_sys_reset_n
            );

  vita_pll_1: vita_pll

    port map(reg_pll_pwd_n  => reg_pll_pwd_n,
             reg_pll_en     => reg_pll_en,
             reg_pll_bypass => reg_pll_bypass,
             reg_pll_mdiv   => reg_pll_mdiv,
             reg_pll_ndiv   => reg_pll_ndiv,
             reg_pll_pdiv   => reg_pll_pdiv,
             pll_reg_lock   => pll_reg_lock,
             pll_cgen_clk   => pll_cgen_clk,
             io_pll_clk     => io_pll_clk,
             io_sys_reset_n => io_sys_reset_n
            );

  vita_db_1: vita_db
    generic map(G_SENSOR => G_SENSOR
               )
    port map(reg_log_enable              => reg_log_enable,
             reg_db_8bit_mode            => reg_db_8bit_mode,
             reg_db_bl_frame_valid_enable=> reg_db_bl_frame_valid_enable,
             reg_db_bl_line_valid_enable => reg_db_bl_line_valid_enable,
             reg_db_auto_blackcal_enable => reg_db_auto_blackcal_enable,
             reg_db_black_offset         => reg_db_black_offset,
             reg_db_blackcal_offset      => reg_db_blackcal_offset,
             reg_db_blackcal_offset_dec  => reg_db_blackcal_offset_dec,
             reg_db_crc_seed             => reg_db_crc_seed,
             reg_db_testpattern_en       => reg_db_testpattern_en,
             reg_db_prbs_en              => reg_db_prbs_en,
             reg_db_inc_testpattern      => reg_db_inc_testpattern,
             reg_db_frame_testpattern    => reg_db_frame_testpattern,
             reg_db_testpattern          => reg_db_testpattern,
             reg_db_trainingpattern      => reg_db_trainingpattern,
             reg_db_frame_sync           => reg_db_frame_sync,
             reg_db_tr                   => reg_db_tr,
             reg_db_img                  => reg_db_img,
             reg_db_bl                   => reg_db_bl,
             reg_db_crc                  => reg_db_crc,
             seq_db_frame_valid          => seq_db_frame_valid,
             seq_db_line_valid           => seq_db_line_valid,
             seq_db_black                => seq_db_black,
             seq_db_sync                 => seq_db_sync,
             seq_db_roi_id               => seq_db_roi_id,
             afe_db_data                 => afe_db_data,
             db_ser_frame_valid          => db_ser_frame_valid,
             db_ser_line_valid           => db_ser_line_valid,
             db_ser_clock                => db_ser_clock,
             db_ser_sync                 => db_ser_sync,
             db_ser_data                 => db_ser_data,
             cgen_log_clk                => cgen_log_clk,
             rgen_log_reset_n            => rgen_log_reset_n
            );

end model;


library lib_vita_hdl;

configuration cfg_vita_model of vita is
  for model
    for vita_mux_1: vita_mux
      use entity lib_vita_hdl.vita_mux(model);
    end for;
    for vita_spi_1: vita_spi
      use entity lib_vita_hdl.vita_spi(model);
    end for;
    for vita_adc_1: vita_adc
      use entity lib_vita_hdl.vita_adc(model);
    end for;
    for vita_rgen_1: vita_rgen
      use entity lib_vita_hdl.vita_rgen(model);
    end for;
    for vita_ser_1: vita_ser
      use configuration lib_vita_hdl.cfg_vita_ser_model;
    end for;
    for vita_clkgen_1: vita_clkgen
      use entity lib_vita_hdl.vita_clkgen(model);
    end for;
    for vita_seq_1: vita_seq
      use entity lib_vita_hdl.vita_seq(model);
    end for;
    for vita_imc_1: vita_imc
      use entity lib_vita_hdl.vita_imc(model);
    end for;
    for vita_io_1: vita_io
      use entity lib_vita_hdl.vita_io(model);
    end for;
    for vita_pll_1: vita_pll
      use entity lib_vita_hdl.vita_pll(model);
    end for;
    for vita_db_1: vita_db
      use configuration lib_vita_hdl.cfg_vita_db_model;
    end for;
  end for;
end cfg_vita_model;
