// $Id: AccelDriverM.nc,v 1.4 2005/08/04 21:59:18 jpolastre Exp $
/*
 * "Copyright (c) 2000-2005 The Regents of the University  of California.
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
 * Copyright (c) 2005 Moteiv Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached MOTEIV-LICENSE     
 * file. If you do not find these files, copies can be found at
 * http://www.moteiv.com/MOTEIV-LICENSE.txt and by emailing info@moteiv.com.
 */

/**
 * @author Joe Polastre <info@moteiv.com>
 * Revision:  $Revision: 1.4 $
 *
 */

includes Accel;

module AccelDriverM
{
  provides {
    interface SplitControl;
    interface TSBInterrupt as AccelInterrupt;
    interface Potentiometer as AccelInterruptSettings;
  }
  uses {
    interface AD524X;
    interface ADCControl;
    interface StdControl as ADCStdControl;
    interface StdControl as PotControl;
    interface StdControl as AD524XControl;
    interface MSP430Interrupt as AccelInt;
    interface Leds;
  }
}

implementation
{

  enum {
    OFF = 0,
    IDLE,
    START,
    START_O,
    STOP,
    STOP_O,
    GAIN,
  };

  uint8_t state;
  uint8_t gain;

  task void initDone() {
    signal SplitControl.initDone();
  }

  command result_t SplitControl.init() {
    atomic {
      // state is off
      state = OFF;
    }
    call ADCStdControl.init();
    call AD524XControl.init();
    return post initDone();
  }

  command result_t SplitControl.start() {
    uint8_t _state = OFF;
    atomic {
      if (state == OFF) {
	state = START;
	_state = state;
      }
    }
    if (_state == START) {
      call ADCStdControl.start();
      call ADCControl.init();
      if (!call ADCControl.bindPort(TOS_ADC_ACCELX_PORT, 
				    TOSH_ACTUAL_ADC_ACCELX_PORT) ||
	  !call ADCControl.bindPort(TOS_ADC_ACCELY_PORT,
				    TOSH_ACTUAL_ADC_ACCELY_PORT)) {
	state = OFF;
	return FAIL;
      }
      TOSH_SEL_ADC0_MODFUNC();
      TOSH_SEL_ADC1_MODFUNC();
      call AD524XControl.start();
      return call AD524X.start(ACCEL_ADDR, ACCEL_TYPE);
    }
    return FAIL;
  }

  event void AD524X.startDone(uint8_t addr, result_t result, ad524x_type_t type) {
    uint8_t _state = OFF;
    atomic {
      if (state == START) {
	state = START_O;
	_state = state;
      }
    }
    if (_state == START_O) {
      if (!(call AD524X.setOutput(ACCEL_ON_ADDR, ACCEL_ON_OUTPUT, TRUE, ACCEL_ON_TYPE))) {
	atomic state = IDLE;
	signal SplitControl.startDone();
      }
    }
  }

  command result_t SplitControl.stop() {
    uint8_t _state = OFF;
    atomic {
      if (state == IDLE) {
	state = STOP;
	_state = state;
      }
    }
    if (_state == STOP) {
      return call AD524X.stop(ACCEL_ADDR, ACCEL_TYPE);
    }
    return FAIL;
  }
  
  event void AD524X.stopDone(uint8_t addr, result_t result, ad524x_type_t type) {
    uint8_t _state = OFF;
    atomic {
      if (state == STOP) {
	state = STOP_O;
	_state = state;
      }
    }
    if (_state == STOP_O) {
      if (!(call AD524X.setOutput(ACCEL_ON_ADDR, ACCEL_ON_OUTPUT, FALSE, ACCEL_ON_TYPE))) {
	atomic state = IDLE;
	signal SplitControl.stopDone();
      }
    }
  }

  event void AD524X.setPotDone(uint8_t addr, bool rdac, result_t _result, ad524x_type_t type) {
    uint8_t _state = OFF;
    atomic {
      if (state == GAIN) {
        _state = state;
        state = IDLE;
      }
    }

    if (_state == GAIN) {
      signal AccelInterruptSettings.setDone(gain, _result);
    }
  }
  
  event void AD524X.setOutputDone(uint8_t addr, bool output, result_t result, ad524x_type_t type) {
    uint8_t _state = OFF;
    atomic {
      if ((state == START_O) || (state == STOP_O)) {
	_state = state;
	state = IDLE;
      }
    }

    if (_state == START_O) 
      signal SplitControl.startDone();
    else if (_state == STOP_O) {
      call AD524XControl.stop();
      signal SplitControl.stopDone();
    }
  }

  event void AD524X.getPotDone(uint8_t addr, bool rdac, uint8_t value, result_t result, ad524x_type_t type) { }

  command result_t AccelInterruptSettings.set(uint8_t _gain) {
    uint8_t _state = OFF;
    atomic {
      if (state == IDLE) {
        state = GAIN;
        _state = state;
      }
    }
    if (_state == GAIN) {
      atomic gain = _gain;
      if (call AD524X.setPot(ACCEL_INT_THRESH_ADDR, ACCEL_INT_THRESH_RDAC, gain, ACCEL_INT_THRESH_TYPE) == FAIL) {
	state = IDLE;
      }
    }
    return FAIL;
  }

  default event void AccelInterruptSettings.setDone(uint8_t _gain, result_t _result) { }

  command uint8_t AccelInterruptSettings.get() {
    return gain;
  }

  async command result_t AccelInterrupt.enable() {
    atomic {
      TOSH_MAKE_ACCEL_INT_INPUT();
      call AccelInt.disable();
      call AccelInt.clear();
      call AccelInt.edge(FALSE);
      call AccelInt.enable();
    }
    return SUCCESS;
  }

  async command result_t AccelInterrupt.disable() {
    atomic {
      call AccelInt.disable();
      call AccelInt.clear();
      TOSH_MAKE_ACCEL_INT_OUTPUT();
    }
    return SUCCESS;
  }

  default async event void AccelInterrupt.fired() { }

  async event void AccelInt.fired() {
    signal AccelInterrupt.fired();
    call AccelInt.clear();
  }

}
