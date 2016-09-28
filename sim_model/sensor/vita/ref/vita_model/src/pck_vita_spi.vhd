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
-- $Id: design#hdl#model#src#pck_vita_spi.vhd,v 1.3 2012-12-06 03:11:33-07 ffynvr Exp $
-- Author         : $Author: ffynvr $
-- Department     : CISP
-- Date           : $Date: 2012-12-06 03:11:33-07 $
-- Revision       : $Revision: 1.3 $
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
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lib_vita_hdl;
  use lib_vita_hdl.pck_vita_model.all;

package pck_vita_spi is

  constant C_CHIP_ID_VITA1300:  integer := 16#560D#;
  constant C_CHIP_ID_VITA2000:  integer := 16#5614#;
  constant C_CHIP_ID_VITA5000:  integer := 16#5632#;
  constant C_CHIP_ID_VITA25K:   integer := 16#56FA#;

  constant C_SPI_ADDRESS_WIDTH: integer := 9;
  constant C_SPI_DATA_WIDTH:    integer := 16;

  subtype t_spi_address       is unsigned(C_SPI_ADDRESS_WIDTH - 1 downto 0);
  type    t_spi_address_array is array(integer range <>) of t_spi_address;
  subtype t_spi_address_range is integer range 0 to 2**C_SPI_ADDRESS_WIDTH - 1;

  subtype t_spi_data       is unsigned(C_SPI_DATA_WIDTH - 1 downto 0);
  type    t_spi_data_array is array(integer range <>) of t_spi_data;
  subtype t_spi_data_range is integer range 0 to 2**C_SPI_DATA_WIDTH - 1;

  subtype t_vita_reg_array is
    t_spi_data_array(2**C_SPI_ADDRESS_WIDTH - 1 downto 0);

  ---------------------------
  -- SPI / Register Constants
  ---------------------------
  constant C_REG_BLACK_LINES_WIDTH:          integer := 8;
  constant C_REG_DUMMY_LINES_WIDTH:          integer := 12;

  constant C_Y_RES_BITS:                     integer := 13;
  constant C_X_RES_BITS:                     integer := 8;

  constant C_REG_SEQ_ROI_AEC_OFFSET:         integer := 253;
  constant C_REG_SEQ_ROI_OFFSET:             integer := 256;

  constant C_REG_SEQ_ROI_REGS:               integer := 3;
  constant C_REG_SEQ_ROI_X_START_RELOFFSET:  integer := 0;
  constant C_REG_SEQ_ROI_X_END_RELOFFSET:    integer := 0;
  constant C_REG_SEQ_ROI_Y_START_RELOFFSET:  integer := 1;
  constant C_REG_SEQ_ROI_Y_END_RELOFFSET:    integer := 2;

  constant C_REG_DB_TESTPATTERN_OFFSET:      integer := 146;
  constant C_REG_DB_TESTPATTERN_OFFSET_MSB:  integer := 150;
  constant C_REG_DB_TESTCH_SELECT_OFFSET:    integer := 154;

  --------------------
  -- Register Defaults
  --------------------
  function C_SPI_DEFAULT(sensor: t_sensor_prop) return t_vita_reg_array;

end pck_vita_spi;

package body pck_vita_spi is

  function C_SPI_DEFAULT(sensor: t_sensor_prop) return t_vita_reg_array is
    variable regs: t_vita_reg_array;
  begin
    regs      := (others => (others => '0'));

    regs(  1) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(  2) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(  3) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(  4) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(  5) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(  6) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(  7) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(  8) := to_unsigned(16#0099#, C_SPI_DATA_WIDTH);
    regs(  9) := to_unsigned(16#0009#, C_SPI_DATA_WIDTH);
    regs( 10) := to_unsigned(16#0999#, C_SPI_DATA_WIDTH);
    regs( 11) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 12) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 13) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 14) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 15) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 16) := to_unsigned(16#0004#, C_SPI_DATA_WIDTH);
    regs( 17) := to_unsigned(16#2113#, C_SPI_DATA_WIDTH);
    regs( 18) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 19) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 20) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 21) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 22) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 23) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 24) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 25) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 26) := to_unsigned(16#2280#, C_SPI_DATA_WIDTH);
    regs( 27) := to_unsigned(16#3D2D#, C_SPI_DATA_WIDTH);
    regs( 28) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 29) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 30) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 31) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 32) := to_unsigned(16#0004#, C_SPI_DATA_WIDTH);
    regs( 33) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 34) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 35) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 36) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 37) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 38) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 39) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 40) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 41) := to_unsigned(16#0B5A#, C_SPI_DATA_WIDTH);
    regs( 42) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 43) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 44) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 45) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 46) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 47) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 48) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 49) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 50) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 51) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 52) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 53) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 54) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 55) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 56) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 57) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 58) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 59) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 60) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 61) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 62) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 63) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 64) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 65) := to_unsigned(16#888B#, C_SPI_DATA_WIDTH);
    regs( 66) := to_unsigned(16#53C8#, C_SPI_DATA_WIDTH);
    regs( 67) := to_unsigned(16#8888#, C_SPI_DATA_WIDTH);
    regs( 68) := to_unsigned(16#0088#, C_SPI_DATA_WIDTH);
    regs( 69) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 70) := to_unsigned(16#8888#, C_SPI_DATA_WIDTH);
    regs( 71) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 72) := to_unsigned(16#1200#, C_SPI_DATA_WIDTH);
    regs( 73) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 74) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 75) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 76) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 77) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 78) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 79) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 80) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 81) := to_unsigned(16#8881#, C_SPI_DATA_WIDTH);
    regs( 82) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 83) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 84) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 85) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 86) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 87) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 88) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 89) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 90) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 91) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 92) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 93) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 94) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 95) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 96) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 97) := to_unsigned(16#0063#, C_SPI_DATA_WIDTH);
    regs( 98) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs( 99) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(100) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(101) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(102) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(103) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(104) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(105) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(106) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(107) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(108) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(109) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(110) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(111) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(112) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(113) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(114) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(115) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(116) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(117) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(118) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(119) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(120) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(121) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(122) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(123) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(124) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(125) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(126) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(127) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(128) := to_unsigned(16#4008#, C_SPI_DATA_WIDTH);
    regs(129) := to_unsigned(16#C001#, C_SPI_DATA_WIDTH);
    regs(130) := to_unsigned(16#03A6#, C_SPI_DATA_WIDTH);
    regs(131) := to_unsigned(16#002A#, C_SPI_DATA_WIDTH);
    regs(132) := to_unsigned(16#0015#, C_SPI_DATA_WIDTH);
    regs(133) := to_unsigned(16#0035#, C_SPI_DATA_WIDTH);
    regs(134) := to_unsigned(16#0059#, C_SPI_DATA_WIDTH);
    regs(135) := to_unsigned(16#03A6#, C_SPI_DATA_WIDTH);
    regs(136) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(137) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(138) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(139) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(140) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(141) := to_unsigned(16#FFFF#, C_SPI_DATA_WIDTH);
    regs(142) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(143) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(144) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(145) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(146) := to_unsigned(16#0100#, C_SPI_DATA_WIDTH);
    regs(147) := to_unsigned(16#0302#, C_SPI_DATA_WIDTH);
    regs(148) := to_unsigned(16#0504#, C_SPI_DATA_WIDTH);
    regs(149) := to_unsigned(16#0706#, C_SPI_DATA_WIDTH);
    regs(150) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(151) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(152) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(153) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(154) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(155) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(156) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(157) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(158) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(159) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(160) := to_unsigned(16#0010#, C_SPI_DATA_WIDTH);
    regs(161) := to_unsigned(16#60B8#, C_SPI_DATA_WIDTH);
    regs(162) := to_unsigned(16#0080#, C_SPI_DATA_WIDTH);
    regs(163) := to_unsigned(16#0080#, C_SPI_DATA_WIDTH);
    regs(164) := to_unsigned(16#0080#, C_SPI_DATA_WIDTH);
    regs(165) := to_unsigned(16#0080#, C_SPI_DATA_WIDTH);
    regs(166) := to_unsigned(16#03FF#, C_SPI_DATA_WIDTH);
    regs(167) := to_unsigned(16#0800#, C_SPI_DATA_WIDTH);
    regs(168) := to_unsigned(16#0001#, C_SPI_DATA_WIDTH);
    regs(169) := to_unsigned(16#0800#, C_SPI_DATA_WIDTH);
    regs(170) := to_unsigned(16#03FF#, C_SPI_DATA_WIDTH);
    regs(171) := to_unsigned(16#100D#, C_SPI_DATA_WIDTH);
    regs(172) := to_unsigned(16#0083#, C_SPI_DATA_WIDTH);
    regs(173) := to_unsigned(16#2824#, C_SPI_DATA_WIDTH);
    regs(174) := to_unsigned(16#2A96#, C_SPI_DATA_WIDTH);
    regs(175) := to_unsigned(16#0080#, C_SPI_DATA_WIDTH);
    regs(176) := to_unsigned(16#0100#, C_SPI_DATA_WIDTH);
    regs(177) := to_unsigned(16#0100#, C_SPI_DATA_WIDTH);
    regs(178) := to_unsigned(16#0080#, C_SPI_DATA_WIDTH);
    regs(179) := to_unsigned(16#00AA#, C_SPI_DATA_WIDTH);
    regs(180) := to_unsigned(16#0100#, C_SPI_DATA_WIDTH);
    regs(181) := to_unsigned(16#0155#, C_SPI_DATA_WIDTH);
    regs(182) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(183) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(184) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(185) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(186) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(187) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(188) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(189) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(190) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(191) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(192) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(193) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(194) := to_unsigned(16#0004#, C_SPI_DATA_WIDTH);
    regs(195) := to_unsigned(16#0001#, C_SPI_DATA_WIDTH);
    regs(196) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(197) := to_unsigned(16#0102#, C_SPI_DATA_WIDTH);
    regs(198) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(199) := to_unsigned(16#0001#, C_SPI_DATA_WIDTH);
    regs(200) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(201) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(202) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(203) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(204) := to_unsigned(16#01E2#, C_SPI_DATA_WIDTH);
    regs(205) := to_unsigned(16#0080#, C_SPI_DATA_WIDTH);
    regs(206) := to_unsigned(16#033F#, C_SPI_DATA_WIDTH);
    regs(207) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(208) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(209) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(210) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(211) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(212) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(213) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(214) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(215) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(216) := to_unsigned(16#7F00#, C_SPI_DATA_WIDTH);
    regs(217) := to_unsigned(16#261E#, C_SPI_DATA_WIDTH);
    regs(218) := to_unsigned(16#160E#, C_SPI_DATA_WIDTH);
    regs(219) := to_unsigned(16#3E2E#, C_SPI_DATA_WIDTH);
    regs(220) := to_unsigned(16#6750#, C_SPI_DATA_WIDTH);
    regs(221) := to_unsigned(16#0008#, C_SPI_DATA_WIDTH);
    regs(222) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(223) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(224) := to_unsigned(16#3E01#, C_SPI_DATA_WIDTH);
    regs(225) := to_unsigned(16#5EF1#, C_SPI_DATA_WIDTH);
    regs(226) := to_unsigned(16#6000#, C_SPI_DATA_WIDTH);
    regs(227) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(228) := to_unsigned(16#FFFF#, C_SPI_DATA_WIDTH);
    regs(229) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(230) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(231) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(232) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(233) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(234) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(235) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(236) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(237) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(238) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(239) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(240) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(241) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(242) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(243) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(244) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(245) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(246) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(247) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(248) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(249) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(250) := to_unsigned(16#0422#, C_SPI_DATA_WIDTH);
    regs(251) := to_unsigned(16#030F#, C_SPI_DATA_WIDTH);
    regs(252) := to_unsigned(16#0601#, C_SPI_DATA_WIDTH);
    regs(253) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(254) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(255) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(384) := to_unsigned(16#1010#, C_SPI_DATA_WIDTH);
    regs(385) := to_unsigned(16#549F#, C_SPI_DATA_WIDTH);
    regs(386) := to_unsigned(16#549F#, C_SPI_DATA_WIDTH);
    regs(387) := to_unsigned(16#541F#, C_SPI_DATA_WIDTH);
    regs(388) := to_unsigned(16#541F#, C_SPI_DATA_WIDTH);
    regs(389) := to_unsigned(16#101F#, C_SPI_DATA_WIDTH);
    regs(390) := to_unsigned(16#101F#, C_SPI_DATA_WIDTH);
    regs(391) := to_unsigned(16#1110#, C_SPI_DATA_WIDTH);
    regs(392) := to_unsigned(16#1010#, C_SPI_DATA_WIDTH);
    regs(393) := to_unsigned(16#111F#, C_SPI_DATA_WIDTH);
    regs(394) := to_unsigned(16#111F#, C_SPI_DATA_WIDTH);
    regs(395) := to_unsigned(16#111F#, C_SPI_DATA_WIDTH);
    regs(396) := to_unsigned(16#111F#, C_SPI_DATA_WIDTH);
    regs(397) := to_unsigned(16#1010#, C_SPI_DATA_WIDTH);
    regs(398) := to_unsigned(16#1010#, C_SPI_DATA_WIDTH);
    regs(399) := to_unsigned(16#549F#, C_SPI_DATA_WIDTH);
    regs(400) := to_unsigned(16#549F#, C_SPI_DATA_WIDTH);
    regs(401) := to_unsigned(16#541F#, C_SPI_DATA_WIDTH);
    regs(402) := to_unsigned(16#541F#, C_SPI_DATA_WIDTH);
    regs(403) := to_unsigned(16#101F#, C_SPI_DATA_WIDTH);
    regs(404) := to_unsigned(16#101F#, C_SPI_DATA_WIDTH);
    regs(405) := to_unsigned(16#1110#, C_SPI_DATA_WIDTH);
    regs(406) := to_unsigned(16#0010#, C_SPI_DATA_WIDTH);
    regs(407) := to_unsigned(16#741F#, C_SPI_DATA_WIDTH);
    regs(408) := to_unsigned(16#741F#, C_SPI_DATA_WIDTH);
    regs(409) := to_unsigned(16#741A#, C_SPI_DATA_WIDTH);
    regs(410) := to_unsigned(16#701A#, C_SPI_DATA_WIDTH);
    regs(411) := to_unsigned(16#711F#, C_SPI_DATA_WIDTH);
    regs(412) := to_unsigned(16#7114#, C_SPI_DATA_WIDTH);
    regs(413) := to_unsigned(16#7110#, C_SPI_DATA_WIDTH);
    regs(414) := to_unsigned(16#0010#, C_SPI_DATA_WIDTH);
    regs(415) := to_unsigned(16#741F#, C_SPI_DATA_WIDTH);
    regs(416) := to_unsigned(16#741F#, C_SPI_DATA_WIDTH);
    regs(417) := to_unsigned(16#741A#, C_SPI_DATA_WIDTH);
    regs(418) := to_unsigned(16#701A#, C_SPI_DATA_WIDTH);
    regs(419) := to_unsigned(16#713F#, C_SPI_DATA_WIDTH);
    regs(420) := to_unsigned(16#7134#, C_SPI_DATA_WIDTH);
    regs(421) := to_unsigned(16#7130#, C_SPI_DATA_WIDTH);
    regs(422) := to_unsigned(16#0010#, C_SPI_DATA_WIDTH);
    regs(423) := to_unsigned(16#741F#, C_SPI_DATA_WIDTH);
    regs(424) := to_unsigned(16#741F#, C_SPI_DATA_WIDTH);
    regs(425) := to_unsigned(16#741A#, C_SPI_DATA_WIDTH);
    regs(426) := to_unsigned(16#701A#, C_SPI_DATA_WIDTH);
    regs(427) := to_unsigned(16#715F#, C_SPI_DATA_WIDTH);
    regs(428) := to_unsigned(16#7154#, C_SPI_DATA_WIDTH);
    regs(429) := to_unsigned(16#7150#, C_SPI_DATA_WIDTH);
    regs(430) := to_unsigned(16#0100#, C_SPI_DATA_WIDTH);
    regs(431) := to_unsigned(16#03F1#, C_SPI_DATA_WIDTH);
    regs(432) := to_unsigned(16#03C5#, C_SPI_DATA_WIDTH);
    regs(433) := to_unsigned(16#0341#, C_SPI_DATA_WIDTH);
    regs(434) := to_unsigned(16#0141#, C_SPI_DATA_WIDTH);
    regs(435) := to_unsigned(16#214F#, C_SPI_DATA_WIDTH);
    regs(436) := to_unsigned(16#2145#, C_SPI_DATA_WIDTH);
    regs(437) := to_unsigned(16#0141#, C_SPI_DATA_WIDTH);
    regs(438) := to_unsigned(16#0101#, C_SPI_DATA_WIDTH);
    regs(439) := to_unsigned(16#0B86#, C_SPI_DATA_WIDTH);
    regs(440) := to_unsigned(16#0381#, C_SPI_DATA_WIDTH);
    regs(441) := to_unsigned(16#0181#, C_SPI_DATA_WIDTH);
    regs(442) := to_unsigned(16#218F#, C_SPI_DATA_WIDTH);
    regs(443) := to_unsigned(16#2185#, C_SPI_DATA_WIDTH);
    regs(444) := to_unsigned(16#0181#, C_SPI_DATA_WIDTH);
    regs(445) := to_unsigned(16#0100#, C_SPI_DATA_WIDTH);
    regs(446) := to_unsigned(16#0100#, C_SPI_DATA_WIDTH);
    regs(447) := to_unsigned(16#1BF1#, C_SPI_DATA_WIDTH);
    regs(448) := to_unsigned(16#1BC3#, C_SPI_DATA_WIDTH);
    regs(449) := to_unsigned(16#0BC2#, C_SPI_DATA_WIDTH);
    regs(450) := to_unsigned(16#0341#, C_SPI_DATA_WIDTH);
    regs(451) := to_unsigned(16#0141#, C_SPI_DATA_WIDTH);
    regs(452) := to_unsigned(16#214F#, C_SPI_DATA_WIDTH);
    regs(453) := to_unsigned(16#2145#, C_SPI_DATA_WIDTH);
    regs(454) := to_unsigned(16#0141#, C_SPI_DATA_WIDTH);
    regs(455) := to_unsigned(16#0101#, C_SPI_DATA_WIDTH);
    regs(456) := to_unsigned(16#0B86#, C_SPI_DATA_WIDTH);
    regs(457) := to_unsigned(16#0381#, C_SPI_DATA_WIDTH);
    regs(458) := to_unsigned(16#0181#, C_SPI_DATA_WIDTH);
    regs(459) := to_unsigned(16#218F#, C_SPI_DATA_WIDTH);
    regs(460) := to_unsigned(16#2185#, C_SPI_DATA_WIDTH);
    regs(461) := to_unsigned(16#0181#, C_SPI_DATA_WIDTH);
    regs(462) := to_unsigned(16#0100#, C_SPI_DATA_WIDTH);
    regs(463) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
    regs(464) := to_unsigned(16#0100#, C_SPI_DATA_WIDTH);
    regs(465) := to_unsigned(16#0BE6#, C_SPI_DATA_WIDTH);
    regs(466) := to_unsigned(16#0381#, C_SPI_DATA_WIDTH);
    regs(467) := to_unsigned(16#0181#, C_SPI_DATA_WIDTH);
    regs(468) := to_unsigned(16#218F#, C_SPI_DATA_WIDTH);
    regs(469) := to_unsigned(16#2185#, C_SPI_DATA_WIDTH);
    regs(470) := to_unsigned(16#0181#, C_SPI_DATA_WIDTH);
    regs(471) := to_unsigned(16#0101#, C_SPI_DATA_WIDTH);
    regs(472) := to_unsigned(16#1346#, C_SPI_DATA_WIDTH);
    regs(473) := to_unsigned(16#0341#, C_SPI_DATA_WIDTH);
    regs(474) := to_unsigned(16#0141#, C_SPI_DATA_WIDTH);
    regs(475) := to_unsigned(16#214F#, C_SPI_DATA_WIDTH);
    regs(476) := to_unsigned(16#2145#, C_SPI_DATA_WIDTH);
    regs(477) := to_unsigned(16#0141#, C_SPI_DATA_WIDTH);
    regs(478) := to_unsigned(16#0101#, C_SPI_DATA_WIDTH);
    regs(479) := to_unsigned(16#8101#, C_SPI_DATA_WIDTH);
    regs(480) := to_unsigned(16#8D0A#, C_SPI_DATA_WIDTH);
    regs(481) := to_unsigned(16#8505#, C_SPI_DATA_WIDTH);
    regs(482) := to_unsigned(16#8101#, C_SPI_DATA_WIDTH);
    regs(483) := to_unsigned(16#C101#, C_SPI_DATA_WIDTH);
    regs(484) := to_unsigned(16#CD0A#, C_SPI_DATA_WIDTH);
    regs(485) := to_unsigned(16#C505#, C_SPI_DATA_WIDTH);
    regs(486) := to_unsigned(16#C100#, C_SPI_DATA_WIDTH);
    regs(487) := to_unsigned(16#0100#, C_SPI_DATA_WIDTH);
    regs(488) := to_unsigned(16#0FE4#, C_SPI_DATA_WIDTH);
    regs(489) := to_unsigned(16#0BC2#, C_SPI_DATA_WIDTH);
    regs(490) := to_unsigned(16#0381#, C_SPI_DATA_WIDTH);
    regs(491) := to_unsigned(16#0181#, C_SPI_DATA_WIDTH);
    regs(492) := to_unsigned(16#218F#, C_SPI_DATA_WIDTH);
    regs(493) := to_unsigned(16#2185#, C_SPI_DATA_WIDTH);
    regs(494) := to_unsigned(16#0181#, C_SPI_DATA_WIDTH);
    regs(495) := to_unsigned(16#0101#, C_SPI_DATA_WIDTH);
    regs(496) := to_unsigned(16#0B46#, C_SPI_DATA_WIDTH);
    regs(497) := to_unsigned(16#0341#, C_SPI_DATA_WIDTH);
    regs(498) := to_unsigned(16#0141#, C_SPI_DATA_WIDTH);
    regs(499) := to_unsigned(16#214F#, C_SPI_DATA_WIDTH);
    regs(500) := to_unsigned(16#2145#, C_SPI_DATA_WIDTH);
    regs(501) := to_unsigned(16#0141#, C_SPI_DATA_WIDTH);
    regs(502) := to_unsigned(16#0101#, C_SPI_DATA_WIDTH);
    regs(503) := to_unsigned(16#8101#, C_SPI_DATA_WIDTH);
    regs(504) := to_unsigned(16#8D0A#, C_SPI_DATA_WIDTH);
    regs(505) := to_unsigned(16#8505#, C_SPI_DATA_WIDTH);
    regs(506) := to_unsigned(16#8101#, C_SPI_DATA_WIDTH);
    regs(507) := to_unsigned(16#C101#, C_SPI_DATA_WIDTH);
    regs(508) := to_unsigned(16#CD0A#, C_SPI_DATA_WIDTH);
    regs(509) := to_unsigned(16#C505#, C_SPI_DATA_WIDTH);
    regs(510) := to_unsigned(16#C100#, C_SPI_DATA_WIDTH);
    regs(511) := to_unsigned(16#0010#, C_SPI_DATA_WIDTH);

    -- ROI Configurations
    for roi_index in 0 to sensor.rois - 1 loop
      -- ROI x-start/x-end
      regs(C_REG_SEQ_ROI_OFFSET +
           roi_index*C_REG_SEQ_ROI_REGS +
           C_REG_SEQ_ROI_X_START_RELOFFSET) :=
        to_unsigned((sensor.kernels - 1) * (2**C_X_RES_BITS),
                    C_SPI_DATA_WIDTH
                   );

      -- ROI y-start
      regs(C_REG_SEQ_ROI_OFFSET +
           roi_index*C_REG_SEQ_ROI_REGS +
           C_REG_SEQ_ROI_Y_START_RELOFFSET) :=
        to_unsigned(0, C_SPI_DATA_WIDTH);

      -- ROI y-end
      regs(C_REG_SEQ_ROI_OFFSET +
           roi_index*C_REG_SEQ_ROI_REGS +
           C_REG_SEQ_ROI_Y_END_RELOFFSET) :=
        to_unsigned(sensor.y_width - 1, C_SPI_DATA_WIDTH);

    end loop;

    case sensor.id is
      when VITA1300 =>
        regs(  0) := to_unsigned(C_CHIP_ID_VITA1300, C_SPI_DATA_WIDTH);
        regs(  1) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
        regs( 26) := to_unsigned(16#2182#, C_SPI_DATA_WIDTH);
        regs( 41) := to_unsigned(16#1B5A#, C_SPI_DATA_WIDTH);
        regs( 81) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
        regs(221) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);

      when VITA2000 =>
        regs(  0) := to_unsigned(C_CHIP_ID_VITA2000, C_SPI_DATA_WIDTH);
        regs(  1) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
        regs( 26) := to_unsigned(16#2280#, C_SPI_DATA_WIDTH);
        regs( 41) := to_unsigned(16#0B5A#, C_SPI_DATA_WIDTH);
        regs( 81) := to_unsigned(16#8881#, C_SPI_DATA_WIDTH);
        regs(221) := to_unsigned(16#0008#, C_SPI_DATA_WIDTH);

      when VITA5000 =>
        regs(  0) := to_unsigned(C_CHIP_ID_VITA5000, C_SPI_DATA_WIDTH);
        regs(  1) := to_unsigned(16#0000#, C_SPI_DATA_WIDTH);
        regs( 26) := to_unsigned(16#2280#, C_SPI_DATA_WIDTH);
        regs( 41) := to_unsigned(16#0B5A#, C_SPI_DATA_WIDTH);
        regs( 81) := to_unsigned(16#8881#, C_SPI_DATA_WIDTH);
        regs(221) := to_unsigned(16#0008#, C_SPI_DATA_WIDTH);

      when VITA25k =>
        regs(  0) := to_unsigned(C_CHIP_ID_VITA25K, C_SPI_DATA_WIDTH);
        regs(  1) := to_unsigned(16#0001#, C_SPI_DATA_WIDTH);
        regs( 26) := to_unsigned(16#2280#, C_SPI_DATA_WIDTH);
        regs( 41) := to_unsigned(16#0B5A#, C_SPI_DATA_WIDTH);
        regs( 81) := to_unsigned(16#8881#, C_SPI_DATA_WIDTH);
        regs(221) := to_unsigned(16#0008#, C_SPI_DATA_WIDTH);

      when others =>
        assert false
          report "Unsupported Sensor"
          severity failure;
    end case;

    return regs;

  end C_SPI_DEFAULT;

end pck_vita_spi;
