//$Id: sensorboard.h,v 1.1 2005/08/23 17:31:33 jwhui Exp $
/*
 * Copyright (c) 2000-2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 */

/**
 * Header file for the Trio sensorboard. <p>
 *
 * @modified 5/22/05
 *
 * @author Jaein Jeong
 */

// instances for PCA9555
enum {
  IOSWITCH1 = 0,
  IOSWITCH2 = 1,
};

enum {
  PWSWITCH = 0,
};

// Port 0 bits for IOSwitch 1
enum {
  IOSWITCH1_PWR_SW      = 0x01,
  IOSWITCH1_CHARGE_SW   = 0x02,
  IOSWITCH1_PW_ACOUSTIC = 0x04,
  IOSWITCH1_PW_MAG      = 0x08,
  IOSWITCH1_PW_PIR      = 0x10,
  IOSWITCH1_PW_SOUNDER  = 0x20,
  //IOSWITCH1_PWM_SOUNDER = 0x40, // not used
  IOSWITCH1_MAG_SR      = 0x80,
};

// Port 1 bits for IOSwitch 1
enum {
  IOSWITCH1_INT_ACOUSTIC  = 0x01,
  IOSWITCH1_INT_PIR       = 0x02,
  IOSWITCH1_INT_PIR0      = 0x04,
  IOSWITCH1_INT_PIR1      = 0x08,
  IOSWITCH1_INT_PIR2      = 0x10,
  IOSWITCH1_INT_PIR3      = 0x20,
};

// Port 0 bits for IOSwitch 2
enum {
  IOSWITCH2_I2C_SW      = 0x01,
  IOSWITCH2_MCU_RESET   = 0x02,
  IOSWITCH2_GRENADE_CK  = 0x04,
};

// Port 1 bits for IOSwitch 1
enum {
  IOSWITCH2_INT_EXP0      = 0x01,
  IOSWITCH2_INT_EXP1      = 0x02,
  IOSWITCH2_INT_EXP2      = 0x04,
  IOSWITCH2_INT_EXP3      = 0x08,
};

// Input terminals for PW switch
enum {
  // D1: not used
  // D2: not used
  PWSWITCH_V_CAP = 0x04, // D3
  PWSWITCH_ADC_EXP2 = 0x08, // D4
  // D5: not used
  // D6: not used
  PWSWITCH_V_BAT = 0x40, // D7
  PWSWITCH_ADC_EXP1 = 0x80, // D8
};

enum
{
  AD5242_ADDR_MIC_ADJUST = 0x01,
  AD5242_ADDR_MIC_HPF = 0x02,
  AD5242_ADDR_MIC_LPF = 0x03,
  AD5242_ADDR_MAG_ADJUST = 0x00,
  AD5242_ADDR_PIR_ADJUST = 0x01,
};


enum
{
  TOS_ADC_ACOUSTIC_PORT = unique("ADCPort"),
  TOS_ADC_PIR_PORT = unique("ADCPort"),
  TOS_ADC_MAG0_PORT = unique("ADCPort"),
  TOS_ADC_MAG1_PORT = unique("ADCPort"),

  TOSH_ACTUAL_ADC_ACOUSTIC_PORT = ASSOCIATE_ADC_CHANNEL(
    INPUT_CHANNEL_A0,
    REFERENCE_VREFplus_AVss,
    REFVOLT_LEVEL_2_5
  ),
  TOSH_ACTUAL_ADC_PIR_PORT = ASSOCIATE_ADC_CHANNEL(
    INPUT_CHANNEL_A1,
    REFERENCE_VREFplus_AVss,
    REFVOLT_LEVEL_2_5
  ),
  TOSH_ACTUAL_ADC_MAG0_PORT = ASSOCIATE_ADC_CHANNEL(
    INPUT_CHANNEL_A2,
    REFERENCE_VREFplus_AVss,
    REFVOLT_LEVEL_2_5
  ),
  TOSH_ACTUAL_ADC_MAG1_PORT = ASSOCIATE_ADC_CHANNEL(
    INPUT_CHANNEL_A3,
    REFERENCE_VREFplus_AVss,
    REFVOLT_LEVEL_2_5
  ),
};

