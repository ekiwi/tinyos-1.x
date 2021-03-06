// $Id: LedsC.nc,v 1.2 2010/06/17 19:48:03 ayer1 Exp $

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
 */


module LedsC {
  provides interface Leds;
}
implementation
{
  uint8_t ledsOn;

  enum {
    RED_BIT = 1,
    GREEN_BIT = 2,
    YELLOW_BIT = 4
  };

  async command result_t Leds.init() {
    atomic {
      ledsOn = 0;
      dbg(DBG_BOOT, "LEDS: initialized.\n");
      /*
      TOSH_MAKE_RED_LED_OUTPUT();
      TOSH_MAKE_YELLOW_LED_OUTPUT();
      */
      TOSH_MAKE_GREEN_LED_OUTPUT();
      /*
      TOSH_SET_RED_LED_PIN();
      TOSH_SET_YELLOW_LED_PIN();
      */
      TOSH_SET_GREEN_LED_PIN();
    }
    return SUCCESS;
  }

  async command result_t Leds.redOn() {
    return SUCCESS;
  }

  async command result_t Leds.redOff() {
     return SUCCESS;
  }

  async command result_t Leds.redToggle() {
    return SUCCESS;
  }

  async command result_t Leds.greenOn() {
    dbg(DBG_LED, "LEDS: Green on.\n");
    atomic {
      TOSH_CLR_GREEN_LED_PIN();
      ledsOn |= GREEN_BIT;
    }
    return SUCCESS;
  }

  async command result_t Leds.greenOff() {
    dbg(DBG_LED, "LEDS: Green off.\n");
    atomic {
      TOSH_SET_GREEN_LED_PIN();
      ledsOn &= ~GREEN_BIT;
    }
    return SUCCESS;
  }

  async command result_t Leds.greenToggle() {
    result_t rval;
    atomic {
      if (ledsOn & GREEN_BIT)
	rval = call Leds.greenOff();
      else
	rval = call Leds.greenOn();
    }
    return rval;
  }

  async command result_t Leds.yellowOn() {
    return SUCCESS;
  }

  async command result_t Leds.yellowOff() {
    return SUCCESS;
  }

  async command result_t Leds.yellowToggle() {
    return SUCCESS;
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
      if (ledsOn & GREEN_BIT) 
	TOSH_CLR_GREEN_LED_PIN();
      else
	TOSH_SET_GREEN_LED_PIN();
    }
    return SUCCESS;
  }
}
