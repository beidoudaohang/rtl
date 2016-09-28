-- ****************end if;****************************************************
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
-- $Id: design#hdl#model#src#vita_seq.vhd,v 1.7 2013-01-31 18:54:32+01 ffynvr Exp $
-- Author         : $Author: ffynvr $
-- Department     : CISP
-- Date           : $Date: 2013-01-31 18:54:32+01 $
-- Revision       : $Revision: 1.7 $
-- *********************************************************************
-- Modification History Summary
-- Date        By   Version  Change Description
-- *********************************************************************
-- See logs
--
-- *********************************************************************
-- Description
--
-- *********************************************************************

library ieee;
  use ieee.numeric_std.all;
  use ieee.std_logic_1164.all;

library lib_vita_hdl;
  use lib_vita_hdl.pck_vita_model.all;
  use lib_vita_hdl.pck_vita_seq.all;
  use lib_vita_hdl.pck_vita_spi.all;

entity vita_seq is
  generic (
    G_SENSOR: t_sensor_prop
  );
  port (
    ----- External Interface -----
    io_seq_trigger0:                in std_logic;
    io_seq_trigger1:                in std_logic;
    io_seq_trigger2:                in std_logic;

    ----- Register Interface -----
    reg_mux_color:                  in std_logic;
    reg_seq_enable:                 in std_logic;
    reg_seq_rolling_shutter_enable: in std_logic;
    reg_seq_triggered_mode:         in std_logic;
    reg_seq_slave_mode:             in std_logic;
    reg_seq_subsampling:            in std_logic;
    reg_seq_binning:                in std_logic;
    reg_seq_fr_mode:                in std_logic;
    reg_seq_subsampling_mode:       in std_logic;
    reg_seq_binning_mode:           in std_logic;
    reg_seq_black_lines:            in natural;
    reg_seq_gate_first_line:        in natural;
    reg_seq_dummy_lines:            in natural;
    reg_seq_mult_timer:             in natural;
    reg_seq_fr_length:              in natural;
    reg_seq_exposure:               in natural;
    reg_seq_roi:                    in t_roi_configuration_array
                                       (G_SENSOR.rois - 1 downto 0);
    reg_seq_roi_active:             in unsigned(G_SENSOR.rois - 1 downto 0);
    reg_seq_sync_roi:               in std_logic;
    reg_seq_sync_exposure:          in std_logic;

    ----- MUX Control -----
    seq_mux_address:               out integer range 0 to G_SENSOR.kernels - 1;
    seq_mux_address_valid:         out std_logic;
    seq_mux_binning:               out std_logic;
    seq_mux_subsampling:           out std_logic;

    ----- IMC Control -----
    seq_imc_select:                out std_logic;
    seq_imc_black:                 out std_logic;
    seq_imc_y_address:             out natural;

    ----- DB Control -----
    seq_db_black:                  out std_logic;
    seq_db_frame_valid:            out std_logic;
    seq_db_line_valid:             out std_logic;
    seq_db_sync:                   out t_sync;
    seq_db_roi_id:                 out natural;

    ----- Monitor Interface -----
    seq_io_monitor0:               out std_logic;
    seq_io_monitor1:               out std_logic;
    seq_io_monitor2:               out std_logic;

    ----- System -----
    cgen_log_clk:                   in std_logic;
    cgen_afe_clk:                   in std_logic;
    rgen_log_reset_n:               in std_logic
  );
end vita_seq;

architecture model of vita_seq is

begin

  MAIN: process(cgen_log_clk, rgen_log_reset_n)

    ------------------
    -- State Variables
    ------------------
    variable frame_state:         t_frame_state;
    variable request_fot:         boolean;

    ------------------------
    -- Frame Synchronization
    ------------------------
    variable trigger0_falling:        boolean;
    variable trigger0_rising:         boolean;
    variable trigger0_rising_latched: boolean;
    variable trigger0_falling_latched:boolean;
    variable roi_sync:                boolean;
    variable roi_latch:
      t_roi_configuration_array(G_SENSOR.rois - 1 downto 0);

    variable roi_active_latch:        unsigned(G_SENSOR.rois - 1 downto 0);

    --------------------------
    -- Frame & Line Properties
    --------------------------
    variable frame_prop:          t_frame_prop;
    variable y_prop:              t_y_prop;
    variable x_prop:              t_x_prop;
    variable active_rs_roi:       natural;
    variable gate_first_line:     natural;

    ----------------------------
    -- Frame & Line Calculations
    ----------------------------
    variable afe_clk_high:        boolean;
    variable rot_expired:         boolean;
    variable first_roi_found:     boolean;
    variable next_roi_id:         integer;
    variable next_roi_found:      boolean;
    variable init_xs:             boolean;
    variable black_x_start:       natural;
    variable black_x_end:         natural;
    variable frame_end_latch:     boolean;

    -----------
    -- Counters
    -----------
    variable cycle_counter:       natural;
    variable init_cycle_counter:  boolean;
    variable frame_cycle_counter: natural;
    variable slave_exp_active:    boolean;

    --------
    -- Delay
    --------
    variable reg_seq_enable_q:    std_logic;
    variable io_seq_trigger0_q:   std_logic;
    variable y_prop_qq:           t_y_prop;
    variable y_prop_q:            t_y_prop;
    variable x_prop_qqq:          t_x_prop;
    variable x_prop_qq:           t_x_prop;
    variable x_prop_q:            t_x_prop;

  begin
    if rgen_log_reset_n = '0' then
      frame_state              := FR_IDLE;
      request_fot              := false;
      trigger0_rising_latched  := false;
      trigger0_falling_latched := false;
      roi_sync                 := false;
      roi_latch                := (others => (others => 0));
      roi_active_latch         := (others => '0');
      frame_prop               := C_FRAME_PROP_RESET;
      y_prop                   := C_Y_PROP_RESET;
      x_prop                   := C_X_PROP_RESET;
      rot_expired              := false;
      first_roi_found          := false;
      next_roi_id              := 0;
      next_roi_found           := false;
      init_xs                  := false;
      black_x_start            := 0;
      black_x_end              := 0;
      frame_end_latch          := false;
      cycle_counter            := 0;
      init_cycle_counter       := true;
      frame_cycle_counter      := 0;
      slave_exp_active         := false;
      reg_seq_enable_q         := '0';
      io_seq_trigger0_q        := '0';
      y_prop_qq                := C_Y_PROP_RESET;
      y_prop_q                 := C_Y_PROP_RESET;
      x_prop_qqq               := C_X_PROP_RESET;
      x_prop_qq                := C_X_PROP_RESET;
      x_prop_q                 := C_X_PROP_RESET;
      seq_mux_address          <= 0;
      seq_mux_address_valid    <= '0';
      seq_mux_binning          <= '0';
      seq_mux_subsampling      <= '0';
      seq_imc_select           <= '0';
      seq_imc_black            <= '0';
      seq_imc_y_address        <= 0;
      seq_db_black             <= '0';
      seq_db_frame_valid       <= '0';
      seq_db_line_valid        <= '0';
      seq_db_sync              <= SYNC_NONE;
      seq_db_roi_id            <= 0;
      seq_io_monitor0          <= '0';
      seq_io_monitor1          <= '0';
      seq_io_monitor2          <= '0';

    elsif cgen_log_clk'event and cgen_log_clk = '1' then

      seq_imc_select        <= '0';
      seq_mux_address_valid <= '0';
      init_cycle_counter    := false;
      request_fot           := false;
      rot_expired           := false;
      afe_clk_high          := (cgen_afe_clk = '1');

      gate_first_line := reg_seq_gate_first_line;
      if G_SENSOR.family = VITA then
        gate_first_line := 0;
        if reg_seq_gate_first_line mod 2 = 1 then
          gate_first_line := 1;
        end if;
      end if;

      if reg_seq_enable = '1' then

        if ((frame_state = FR_IDLE) or roi_sync) then
          if (reg_seq_sync_roi = '1') then

            frame_prop.color         := (reg_mux_color = '1');
            frame_prop.subsampling_y := (reg_seq_subsampling = '1') or
                                        (reg_seq_binning     = '1');
            frame_prop.subsampling_x := (reg_seq_subsampling = '1') or
                                        (reg_seq_binning     = '1');
            if not frame_prop.color then
              frame_prop.binning_y     := (reg_seq_binning = '1');
              frame_prop.binning_x     := (reg_seq_binning = '1');
            end if;

            roi_latch := round_roi(roi           => reg_seq_roi,
                                   subsampling_y => frame_prop.subsampling_y,
                                   subsampling_x => frame_prop.subsampling_x,
                                   color         => frame_prop.color
                                  );

            roi_active_latch := reg_seq_roi_active;
          end if;

          if (reg_seq_sync_exposure = '1') then
            frame_prop.exposure     := reg_seq_exposure;
            frame_prop.reset_length := reg_seq_fr_length;
            if reg_seq_fr_mode = '1' then
              frame_prop.reset_length := 0;
              if reg_seq_fr_length > reg_seq_exposure then
                frame_prop.reset_length := reg_seq_fr_length-reg_seq_exposure;
              end if;
            end if;
            if reg_seq_mult_timer > 0 then
              frame_prop.exposure     := frame_prop.exposure *
                                         reg_seq_mult_timer;
              frame_prop.reset_length := frame_prop.reset_length *
                                         reg_seq_mult_timer;
            end if;
          end if;

        end if;
        roi_sync := false;

        for roi_index in 0 to G_SENSOR.rois-1 loop
          if (reg_seq_roi_active(roi_index) = '1') then
            active_rs_roi := roi_index;
            assert roi_latch(roi_index).y_end < G_SENSOR.y_width
              report "ROI Configuration: y-end too large"
              severity error;
            assert roi_latch(roi_index).x_end < G_SENSOR.kernels
              report "ROI Configuration: x-end too large"
              severity error;
          end if;
        end loop;

        trigger0_falling :=
          (io_seq_trigger0 = '0' and io_seq_trigger0_q = '1');

        trigger0_rising :=
          (io_seq_trigger0 = '1' and io_seq_trigger0_q = '0');

        if trigger0_rising then
          trigger0_rising_latched := true;
          if reg_seq_triggered_mode = '1' and reg_seq_slave_mode = '0' then
            frame_cycle_counter := frame_prop.exposure;
            slave_exp_active    := true;
          end if;
        end if;
        if trigger0_falling then
          trigger0_falling_latched := true;
        end if;

        case frame_state is

          when FR_IDLE =>
            init_cycle_counter := true;
            if reg_seq_enable_q = '0' then
              if (or_reduce(roi_active_latch) = '0') then
                assert false
                  report "Note: Sequencer enabled without active windows"
                  severity note;
              else
                frame_state := FR_ROT;
                if reg_seq_rolling_shutter_enable = '0' then
                  frame_state := FR_FOT;
                  if reg_seq_triggered_mode = '1' then
                    frame_state := FR_WAIT_TRIGGER0;
                  end if;
                end if;
              end if;
            end if;

          when FR_WAIT_TRIGGER0 =>
            if (reg_seq_slave_mode = '1' and
                (trigger0_falling or trigger0_falling_latched)
               ) or
               (reg_seq_slave_mode = '0' and
                (frame_cycle_counter = 0 and slave_exp_active)
               ) then
              trigger0_rising_latched  := false;
              trigger0_falling_latched := false;
              slave_exp_active         := false;
              init_cycle_counter       := true;
              frame_state              := FR_FOT;
            end if;

          when FR_WAIT_EXP =>
            if frame_cycle_counter = 0 then
              init_cycle_counter := true;
              frame_state        := FR_FOT;
            end if;

          when FR_FOT =>
            roi_sync := true;
            slave_exp_active := false;
            if cycle_counter = C_FOT_TIME then
              frame_cycle_counter := frame_prop.exposure +
                                     frame_prop.reset_length;
              init_cycle_counter := true;
              frame_state        := FR_ROT;
            end if;

          when FR_CALC_YS =>

            y_prop.overhead_count := y_prop.overhead_count + 1;

            case y_prop.ys_type is

              when ys_BLACK =>
                if y_prop.overhead_count >= reg_seq_black_lines then
                  y_prop.ys := 0;
                  y_prop.ys_valid := false;
                  first_roi_found := false;
                  for roi_index in 0 to G_SENSOR.rois-1 loop
                    if roi_active_latch(roi_index) = '1' then
                      if not first_roi_found or
                         y_prop.ys >= roi_latch(roi_index).y_start then
                        y_prop.roi_id  := roi_index;
                        y_prop.ys      := roi_latch(roi_index).y_start;
                        y_prop.ys_valid:= true;
                        y_prop.ys_type := YS_IMG;
                        first_roi_found:= true;
                      end if;
                    end if;
                  end loop;
                end if;

              when YS_DUMMY =>
                if y_prop.overhead_count >= reg_seq_dummy_lines then
                  roi_sync              := true;
                  y_prop.overhead_count := 0;
                  y_prop.ys_type        := YS_BLACK;
                end if;

              when YS_IMG =>
                y_prop.ys :=
                  inc_pointer(pointer     => y_prop.ys,
                              subsampling => frame_prop.subsampling_y,
                              color       => frame_prop.color
                             );

                y_prop.ys_valid := false;
                next_roi_id     := 0;
                next_roi_found  := false;

                for roi_index in roi_latch'range loop
                  if roi_active_latch(roi_index) = '1' then
                    if active_line(roi_latch(roi_index), y_prop.ys) then
                      y_prop.ys_valid := true;
                      y_prop.roi_id   := roi_index;
                    end if;

                    if roi_latch(roi_index).y_start > y_prop.ys then
                      if (not next_roi_found) or
                         (next_roi_found and
                          roi_latch(roi_index).y_start <=
                          roi_latch(next_roi_id).y_start) then
                        next_roi_id    := roi_index;
                        next_roi_found := true;
                      end if;
                    end if;
                  end if;
                end loop;

                if not y_prop.ys_valid then
                  if next_roi_found then
                    y_prop.ys       := roi_latch(next_roi_id).y_start;
                    y_prop.roi_id   := next_roi_id;
                    y_prop.ys_valid := true;
                  else
                    frame_end_latch := true;
                    if reg_seq_rolling_shutter_enable = '1' and
                       reg_seq_dummy_lines > 0 then
                      y_prop.ys_type := YS_DUMMY;
                    else
                      y_prop.ys_type := YS_BLACK;
                      roi_sync       := true;
                      request_fot    := (reg_seq_rolling_shutter_enable = '0');
                    end if;
                    y_prop.overhead_count := 0;
                  end if;
                end if;

            end case;

            init_cycle_counter := true;

            frame_state := FR_ROT;
            if request_fot then
              frame_state := FR_FOT;
              if frame_cycle_counter /= 0 then
                frame_state := FR_WAIT_EXP;
              end if;
              if reg_seq_triggered_mode = '1' then
                frame_state := FR_WAIT_TRIGGER0;
                if trigger0_rising_latched and io_seq_trigger0 = '0' then
                  trigger0_rising_latched := false;
                end if;
              end if;
            end if;

          when FR_ROT =>
            if y_prop.ys_valid then
              seq_imc_y_address <= y_prop.ys;
            end if;

            seq_imc_black <= '0';
            if y_prop.ys_type = YS_BLACK then
              seq_imc_black <= '1';
            end if;

            seq_imc_select    <= '1';
            frame_state       := FR_WAIT_ROT;

          when FR_WAIT_ROT =>
            rot_expired := (cycle_counter >= C_ROT_TIME_SS);
            if reg_seq_rolling_shutter_enable = '1' then
              rot_expired := (cycle_counter >= C_ROT_TIME_RS);
            end if;

            if rot_expired and not afe_clk_high then
              if (y_prop.ys_type /= YS_DUMMY) then
                seq_db_frame_valid <= '1';
              end if;
              init_cycle_counter := true;
              init_xs            := true;
              frame_state        := FR_X_READ;
            end if;

          when FR_X_READ =>
            if afe_clk_high then
              if not init_xs then
                x_prop.xs :=
                  inc_pointer(pointer     => x_prop.xs,
                              subsampling => frame_prop.subsampling_x,
                              color       => false
                             );
              end if;

              next_roi_found  := false;
              x_prop.xs_valid := false;

              case reg_seq_rolling_shutter_enable is

                -- Global Shutter
                when '0' =>

                  black_x_start  := 0;
                  black_x_end    := G_SENSOR.kernels - 1;

                  if y_prop.ys_type = YS_BLACK then

                    if init_xs then
                      x_prop.xs := black_x_start;
                      init_xs   := false;
                    end if;
                    x_prop.xs_valid := (x_prop.xs <= black_x_end);
                    x_prop.roi_id   := 0;

                  else

                    for roi_index in 0 to G_SENSOR.rois - 1 loop
                      if roi_active_latch(roi_index) = '1' and
                         active_line(roi_latch(roi_index), y_prop.ys) then

                        if init_xs then
                          x_prop.xs       := roi_latch(roi_index).x_start;
                          x_prop.xs_valid := true;
                          init_xs         := false;
                        end if;

                        if active_pixel(roi_latch(roi_index), x_prop.xs) then
                          x_prop.xs_valid := true;
                          x_prop.roi_id   := roi_index;
                        end if;

                        if not next_roi_found and
                           roi_latch(roi_index).x_start >= x_prop.xs then
                          next_roi_id    := roi_index;
                          next_roi_found := true;
                        end if;
                      end if;
                    end loop;

                    if not x_prop.xs_valid and next_roi_found then
                      x_prop.xs       := roi_latch(next_roi_id).x_start;
                      x_prop.roi_id   := next_roi_id;
                      x_prop.xs_valid := true;
                    end if;

                  end if;

                -- Rolling Shutter
                when others =>
                  black_x_start := roi_latch(active_rs_roi).x_start;
                  black_x_end   := roi_latch(active_rs_roi).x_end;

                  x_prop.roi_id := active_rs_roi;

                  if init_xs then
                    x_prop.xs := roi_latch(active_rs_roi).x_start;
                    init_xs   := false;
                  end if;

                  if (y_prop.ys_type = YS_BLACK) or
                     (y_prop.ys_type = YS_DUMMY) then
                    x_prop.xs_valid := (x_prop.xs <= black_x_end);
                  else
                    x_prop.xs_valid :=
                      (active_line(roi_latch(active_rs_roi), y_prop.ys) and
                       active_pixel(roi_latch(active_rs_roi), x_prop.xs)
                      );
                  end if;

              end case;

            end if;

            if x_prop.xs_valid then
              seq_mux_subsampling <= '0';
              if frame_prop.subsampling_x then
                seq_mux_subsampling <= '1';
              end if;

              seq_mux_binning <= '0';
              if frame_prop.binning_x then
                seq_mux_binning <= '1';
              end if;

              seq_mux_address       <= x_prop.xs;
              seq_mux_address_valid <= '1';

              case y_prop.ys_type is
                when YS_BLACK =>
                  x_prop.sync := SYNC_BL;

                  -- Insert LS/LE on even cycles, window ID odd cycles
                  if afe_clk_high then
                    if x_prop.xs = black_x_start then
                      x_prop.sync := SYNC_LS;
                    end if;
                    if x_prop.xs = black_x_end then
                      x_prop.sync := SYNC_LE;
                    end if;

                  else

                    if x_prop.xs = black_x_start or
                       x_prop.xs = black_x_end then
                      x_prop.sync := SYNC_ROI_ID;
                    end if;

                  end if;

                when YS_IMG =>

                  x_prop.sync := SYNC_IMG;

                  if afe_clk_high then
                    if (x_prop.xs = roi_latch(x_prop.roi_id).x_start) then
                      x_prop.sync := SYNC_LS;
                      if (y_prop.ys = roi_latch(x_prop.roi_id).y_start) then
                        x_prop.sync := SYNC_FS;
                      end if;
                    end if;
                    if (x_prop.xs = roi_latch(x_prop.roi_id).x_end) then
                      x_prop.sync := SYNC_LE;
                      if (y_prop.ys = roi_latch(x_prop.roi_id).y_end) then
                        x_prop.sync := SYNC_FE;
                      end if;
                    end if;

                  else

                    if (x_prop.xs = roi_latch(x_prop.roi_id).x_start) or
                       (x_prop.xs = roi_latch(x_prop.roi_id).x_end) then
                      x_prop.sync := SYNC_ROI_ID;
                    end if;

                  end if;

                when others =>
                  x_prop.sync := SYNC_NONE;

              end case;

            else
              x_prop.sync  := SYNC_CRC;
              frame_state  := FR_CALC_YS;
            end if;

        end case;

        -- DB Control --
        seq_db_line_valid <= '0';
        seq_db_black      <= '0';

        if x_prop_qq.xs_valid then
          seq_db_roi_id     <= x_prop_qq.roi_id;
          if y_prop_qq.ys_type /= YS_DUMMY then
            seq_db_line_valid <= '1';
            if (y_prop_qq.ys_type = YS_BLACK) and
               (y_prop_qq.overhead_count < reg_seq_gate_first_line) then
              seq_db_line_valid <= '0';
            end if;
          end if;
          if y_prop_qq.ys_type = YS_BLACK then
            seq_db_black <= '1';
          end if;
        else
          if frame_end_latch then
            seq_db_frame_valid <= '0';
            frame_end_latch    := false;
          end if;
        end if;

        seq_db_sync <= x_prop_qq.sync;

        cycle_counter := cycle_counter + 1;
        if init_cycle_counter then
          cycle_counter := 0;
        end if;

        if frame_cycle_counter /= 0 then
          frame_cycle_counter := frame_cycle_counter - 1;
        end if;

      else

        y_prop              := C_Y_PROP_RESET;
        x_prop              := C_X_PROP_RESET;
        frame_state         := FR_IDLE;

      end if;

      --------
      -- Delay
      --------
      reg_seq_enable_q    := reg_seq_enable;
      io_seq_trigger0_q   := io_seq_trigger0;
      y_prop_qq           := y_prop_q;
      y_prop_q            := y_prop;
      x_prop_qqq          := x_prop_qq;
      x_prop_qq           := x_prop_q;
      x_prop_q            := x_prop;

    end if;

  end process;

end model;

