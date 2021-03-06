// $Id: CC1000Const.h,v 1.1.2.5 2006/01/27 18:46:00 idgay Exp $

/* -*- Mode: C; c-basic-indent: 2; indent-tabs-mode: nil -*- */ 
/*                                    tab:4
 *  IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.  By
 *  downloading, copying, installing or using the software you agree to
 *  this license.  If you do not agree to this license, do not download,
 *  install, copy or use the software.
 *
 *  Intel Open Source License 
 *
 *  Copyright (c) 2002 Intel Corporation 
 *  All rights reserved. 
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 * 
 *    Redistributions of source code must retain the above copyright
 *  notice, this list of conditions and the following disclaimer.
 *    Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in the
 *  documentation and/or other materials provided with the distribution.
 *      Neither the name of the Intel Corporation nor the names of its
 *  contributors may be used to endorse or promote products derived from
 *  this software without specific prior written permission.
 *  
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 *  PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE INTEL OR ITS
 *  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 *  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * 
 */

/**
 * @author Phil Buonadonna
 */

#ifndef CC1000CONST_H
#define CC1000CONST_H

/* Constants defined for CC1K */
/* Register addresses */

enum {
  CC1K_MAIN =           0x00,
  CC1K_FREQ_2A =        0x01,
  CC1K_FREQ_1A =        0x02,
  CC1K_FREQ_0A =        0x03,
  CC1K_FREQ_2B =        0x04,
  CC1K_FREQ_1B =        0x05,
  CC1K_FREQ_0B =        0x06,
  CC1K_FSEP1 =          0x07,
  CC1K_FSEP0 =          0x08,
  CC1K_CURRENT =        0x09,
  CC1K_FRONT_END =      0x0A, //10
  CC1K_PA_POW =         0x0B, //11
  CC1K_PLL =            0x0C, //12
  CC1K_LOCK =           0x0D, //13
  CC1K_CAL =            0x0E, //14
  CC1K_MODEM2 =         0x0F, //15
  CC1K_MODEM1 =         0x10, //16
  CC1K_MODEM0 =         0x11, //17
  CC1K_MATCH =          0x12, //18
  CC1K_FSCTRL =         0x13, //19
  CC1K_FSHAPE7 =        0x14, //20
  CC1K_FSHAPE6 =        0x15, //21
  CC1K_FSHAPE5 =        0x16, //22
  CC1K_FSHAPE4 =        0x17, //23
  CC1K_FSHAPE3 =        0x18, //24
  CC1K_FSHAPE2 =        0x19, //25
  CC1K_FSHAPE1 =        0x1A, //26
  CC1K_FSDELAY =        0x1B, //27
  CC1K_PRESCALER =      0x1C, //28
  CC1K_TEST6 =          0x40, //64
  CC1K_TEST5 =          0x41, //66
  CC1K_TEST4 =          0x42, //67
  CC1K_TEST3 =          0x43, //68
  CC1K_TEST2 =          0x44, //69
  CC1K_TEST1 =          0x45, //70
  CC1K_TEST0 =          0x46, //71

  // MAIN Register Bit Posititions
  CC1K_RXTX =        7,
  CC1K_F_REG =        6,
  CC1K_RX_PD =        5,
  CC1K_TX_PD =        4,
  CC1K_FS_PD =        3,
  CC1K_CORE_PD =    2,
  CC1K_BIAS_PD =    1,
  CC1K_RESET_N =    0,

  // CURRENT Register Bit Positions
  CC1K_VCO_CURRENT =    4,
  CC1K_LO_DRIVE =    2,
  CC1K_PA_DRIVE =    0,

  // FRONT_END Register Bit Positions
  CC1K_BUF_CURRENT =    5,
  CC1K_LNA_CURRENT =    3,
  CC1K_IF_RSSI =    1,
  CC1K_XOSC_BYPASS =    0,

  // PA_POW Register Bit Positions
  CC1K_PA_HIGHPOWER =    4,
  CC1K_PA_LOWPOWER =    0,

  // PLL Register Bit Positions
  CC1K_EXT_FILTER =    7,
  CC1K_REFDIV =        3,
  CC1K_ALARM_DISABLE =    2,
  CC1K_ALARM_H =    1,
  CC1K_ALARM_L =    0,

  // LOCK Register Bit Positions
  CC1K_LOCK_SELECT =        4,
  CC1K_PLL_LOCK_ACCURACY =    3,
  CC1K_PLL_LOCK_LENGTH =    2,
  CC1K_LOCK_INSTANT =        1,
  CC1K_LOCK_CONTINUOUS =    0,

  // CAL Register Bit Positions
  CC1K_CAL_START =    7,
  CC1K_CAL_DUAL =    6,
  CC1K_CAL_WAIT =    5,
  CC1K_CAL_CURRENT =    4,
  CC1K_CAL_COMPLETE =    3,
  CC1K_CAL_ITERATE =    0,

  // MODEM2 Register Bit Positions
  CC1K_PEAKDETECT =        7,
  CC1K_PEAK_LEVEL_OFFSET =    0,

  // MODEM1 Register Bit Positions
  CC1K_MLIMIT =        5,
  CC1K_LOCK_AVG_IN =    4,
  CC1K_LOCK_AVG_MODE =    3,
  CC1K_SETTLING =    1,
  CC1K_MODEM_RESET_N =    0,

  // MODEM0 Register Bit Positions
  CC1K_BAUDRATE =    4,
  CC1K_DATA_FORMAT =    2,
  CC1K_XOSC_FREQ =    0,

  // MATCH Register Bit Positions
  CC1K_RX_MATCH =    4,
  CC1K_TX_MATCH =    0,

  // FSCTLR Register Bit Positions
  CC1K_DITHER1 =    3,
  CC1K_DITHER0 =    2,
  CC1K_SHAPE =        1,
  CC1K_FS_RESET_N =    0,

  // PRESCALER Register Bit Positions
  CC1K_PRE_SWING =    6,
  CC1K_PRE_CURRENT =    4,
  CC1K_IF_INPUT =    3,
  CC1K_IF_FRONT =    2,

  // TEST6 Register Bit Positions
  CC1K_LOOPFILTER_TP1 =    7,
  CC1K_LOOPFILTER_TP2 =    6,
  CC1K_CHP_OVERRIDE =    5,
  CC1K_CHP_CO =        0,

  // TEST5 Register Bit Positions
  CC1K_CHP_DISABLE =    5,
  CC1K_VCO_OVERRIDE =    4,
  CC1K_VCO_AO =        0,

  // TEST3 Register Bit Positions
  CC1K_BREAK_LOOP =    4,
  CC1K_CAL_DAC_OPEN =    0,


  /* 
   * CC1K Register Parameters Table
   *
   * This table follows the same format order as the CC1K register 
   * set EXCEPT for the last entry in the table which is the 
   * CURRENT register value for TX mode.
   *  
   * NOTE: To save RAM space, this table resides in program memory (flash). 
   * This has two important implications:
   *    1) You can't write to it (duh!)
   *    2) You must read it using the PRG_RDB(addr) macro. IT CANNOT BE ACCESSED AS AN ORDINARY C ARRAY.  
   * 
   * Add/remove individual entries below to suit your RF tastes.
   * 
   */
  CC1K_915_998_MHZ =    0x00,
  CC1K_914_077_MHZ =    0x01,

  //#define CC1K_SquelchInit        0x02F8 // 0.90V using the bandgap reference
  CC1K_SquelchInit =        288,
  CC1K_SquelchTableSize =   9,
  CC1K_MaxRSSISamples =     15,
  CC1K_Settling =           1,
  CC1K_ValidPrecursor =     2,
  CC1K_SquelchIntervalFast = 128,
  CC1K_SquelchIntervalSlow = 2560,
  CC1K_SquelchCount =       30,
  CC1K_SquelchBuffer =      10,

  CC1K_LPL_STATES =         9,

  CC1K_LPL_PACKET_TIME =    16
};

#ifdef CC1K_DEFAULT_FREQ
#define CC1K_DEF_PRESET (CC1K_DEFAULT_FREQ)
#endif

#ifdef CC1K_MANUAL_FREQ
#define CC1K_DEF_FREQ (CC1K_MANUAL_FREQ)
#endif

#ifndef CC1K_DEF_PRESET
#define CC1K_DEF_PRESET    (CC1K_914_077_MHZ)
#endif 


static const prog_uchar CC1K_LPL_PreambleLength[CC1K_LPL_STATES*2] = {
    0, 6,       // Always on, 6 byte preamble
    0x0, 48,    // 10ms check interval
    0x0, 60,    // 25ms 
    0x0, 144,   // 50ms 
    0x1, 0x0f,  // 100ms
    0x1, 0xf8,  // 200ms
    0x3, 0xd9,  // 400ms
    0x7, 0x9b,  // 800ms
    0xf, 0x06,  // 1600ms
};

static const prog_uchar CC1K_LPL_SleepTime[CC1K_LPL_STATES*2] = {
    0, 0,       //0
    0x0, 10,    // 10ms
    0x0, 25,    // 25ms
    0x0, 50,    // 50ms
    0x0, 100,   // 100ms
    0x0, 200,   // 200ms
    0x1, 0x90,  // 400ms
    0x3, 0x20,  // 800ms
    0x6, 0x40,  // 1600ms
};


static const prog_uchar CC1K_Params[2][20] = {

  // 0 915.9988 MHz channel, 19.2 Kbps data, Manchester Encoding, High Side LO
  { // MAIN   0x00 
    0x31,
    // FREQ2A,FREQ1A,FREQ0A  0x01-0x03
    0x7c,0x00,0x00,                    
    // FREQ2B,FREQ1B,FREQ0B  0x04-0x06
    0x7b,0xf9,0xae,                    
    // FSEP1, FSEP0     0x07-0x8
    0x02,0x38,
    // CURRENT RX MODE VALUE   0x09 also see below
    8 << CC1K_VCO_CURRENT | 3 << CC1K_LO_DRIVE,
    //0x8C,    
    // FRONT_END  0x0a
    1 << CC1K_BUF_CURRENT | 2 << CC1K_LNA_CURRENT | 1 << CC1K_IF_RSSI,
    //0x32,
    // PA_POW  0x0b
    0x8 << CC1K_PA_HIGHPOWER | 0x0 << CC1K_PA_LOWPOWER, 
    //0xff,
    // PLL  0xc
    8 << CC1K_REFDIV,        
    //0x40,
    // LOCK  0xd
    0x1 << CC1K_LOCK_SELECT,
    //0x10,
    // CAL  0xe
    1 << CC1K_CAL_WAIT | 6 << CC1K_CAL_ITERATE,    
    //0x26,
    // MODEM2  0xf
    1 << CC1K_PEAKDETECT | 33 << CC1K_PEAK_LEVEL_OFFSET,
    //0xA1,
    // MODEM1  0x10
    3 << CC1K_MLIMIT | 1 << CC1K_LOCK_AVG_MODE | CC1K_Settling << CC1K_SETTLING | 1 << CC1K_MODEM_RESET_N, 
    //0x6f, 
    // MODEM0  0x11
    5 << CC1K_BAUDRATE | 1 << CC1K_DATA_FORMAT | 1 << CC1K_XOSC_FREQ,
    //0x55,
    // MATCH 0x12
    0x1 << CC1K_RX_MATCH | 0x0 << CC1K_TX_MATCH,
    // tx current (extra)
    15 << CC1K_VCO_CURRENT | 3 << CC1K_PA_DRIVE,
  },

 
  // 1 914.077 MHz channel, 19.2 Kbps data, Manchester Encoding, High Side LO
  { // MAIN   0x00 
    0x31,
    // FREQ2A,FREQ1A,FREQ0A  0x01-0x03
    0x5c,0xe0,0x00,                    
    // FREQ2B,FREQ1B,FREQ0B  0x04-0x06
    0x5c,0xdb,0x42,                    
    // FSEP1, FSEP0     0x07-0x8
    0x01,0xAA,
    // CURRENT RX MODE VALUE   0x09 also see below
    8 << CC1K_VCO_CURRENT | 3 << CC1K_LO_DRIVE,
    //0x8C,    
    // FRONT_END  0x0a
    1 << CC1K_BUF_CURRENT | 2 << CC1K_LNA_CURRENT | 1 << CC1K_IF_RSSI,
    //0x32,
    // PA_POW  0x0b
    0x8 << CC1K_PA_HIGHPOWER | 0x0 << CC1K_PA_LOWPOWER, 
    //0xff,
    // PLL  0xc
    6 << CC1K_REFDIV,        
    //0x40,
    // LOCK  0xd
    0x1 << CC1K_LOCK_SELECT,
    //0x10,
    // CAL  0xe
    1 << CC1K_CAL_WAIT | 6 << CC1K_CAL_ITERATE,    
    //0x26,
    // MODEM2  0xf
    1 << CC1K_PEAKDETECT | 33 << CC1K_PEAK_LEVEL_OFFSET,
    //0xA1,
    // MODEM1  0x10
    3 << CC1K_MLIMIT | 1 << CC1K_LOCK_AVG_MODE | CC1K_Settling << CC1K_SETTLING | 1 << CC1K_MODEM_RESET_N, 
    //0x6f, 
    // MODEM0  0x11
    5 << CC1K_BAUDRATE | 1 << CC1K_DATA_FORMAT | 1 << CC1K_XOSC_FREQ,
    //0x55,
    // MATCH 0x12
    0x1 << CC1K_RX_MATCH | 0x0 << CC1K_TX_MATCH,
    // tx current (extra)
    15 << CC1K_VCO_CURRENT | 3 << CC1K_PA_DRIVE,
  },


};

#endif /* CC1000CONST_H */
