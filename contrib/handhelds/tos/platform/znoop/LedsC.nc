// $Id: LedsC.nc,v 1.1 2005/07/29 18:29:31 adchristian Exp $

/*									tab:4
 * "Copyright (c) 2000-2003 The Regents of the University  of California.  
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
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */
/*
 *
 * Authors:		Jason Hill, David Gay, Philip Levis
 * Date last modified:  6/2/03
 *
 */

/**
 * @author Jason Hill
 * @author David Gay
 * @author Philip Levis
 * @author Jamey Hicks
 */

module LedsC {
  provides interface Leds;
}
implementation
{
  uint8_t ledsOn;

  enum {
    RED_BIT = 1,
    YELLOW_BIT = 2
  };

  async command result_t Leds.init() {
    atomic {
      ledsOn = 0;
      dbg(DBG_BOOT, "LEDS: initialized.\n");
      TOSH_MAKE_RED_LED_OUTPUT();
      TOSH_CLR_RED_LED_PIN();
      TOSH_MAKE_YELLOW_LED_OUTPUT();
      TOSH_CLR_YELLOW_LED_PIN();
    }
    return SUCCESS;
  }

  async command result_t Leds.redOn() {
    atomic {
      TOSH_SET_RED_LED_PIN();
      ledsOn |= RED_BIT;
    }
    return SUCCESS;
  }

  async command result_t Leds.redOff() {
    atomic {
      TOSH_CLR_RED_LED_PIN();
      ledsOn &= ~RED_BIT;
    }
     return SUCCESS;
  }

  async command result_t Leds.redToggle() {
    result_t rval;
    atomic {
      if (ledsOn & RED_BIT)
	rval = call Leds.redOff();
      else
	rval = call Leds.redOn();
    }
   return rval;
  }

  async command result_t Leds.greenOn() {
    return SUCCESS;
  }

  async command result_t Leds.greenOff() {
    return SUCCESS;
  }

  async command result_t Leds.greenToggle() {
    return 0;
  }

  async command result_t Leds.yellowOn() {
    dbg(DBG_LED, "LEDS: Yellow on.\n");
    atomic {
      TOSH_SET_YELLOW_LED_PIN();
      ledsOn |= YELLOW_BIT;
    }
    return SUCCESS;
  }

  async command result_t Leds.yellowOff() {
    dbg(DBG_LED, "LEDS: Yellow off.\n");
    atomic {
      TOSH_CLR_YELLOW_LED_PIN();
      ledsOn &= ~YELLOW_BIT;
    }
    return SUCCESS;
  }

  async command result_t Leds.yellowToggle() {
    result_t rval;
    atomic {
      if (ledsOn & YELLOW_BIT)
	rval = call Leds.yellowOff();
      else
	rval = call Leds.yellowOn();
    }
    return rval;
  }
  
  async command uint8_t Leds.get() {
    uint8_t rval;
    atomic {
      rval = ledsOn;
    }
    return rval;
  }
  
  async command result_t Leds.set(uint8_t ledsNum) {
    atomic {
      ledsOn = (ledsNum & 0x7);
      if (ledsOn & RED_BIT) 
	TOSH_CLR_RED_LED_PIN();
      else
	TOSH_SET_RED_LED_PIN();
      if (ledsOn & YELLOW_BIT ) 
	TOSH_CLR_YELLOW_LED_PIN();
      else 
	TOSH_SET_YELLOW_LED_PIN();
    }
    return SUCCESS;
  }
}
