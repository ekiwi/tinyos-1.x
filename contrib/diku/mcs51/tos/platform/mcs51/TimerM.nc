// $Id: TimerM.nc,v 1.1 2006/04/07 12:49:54 mleopold Exp $

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

/* Authors:          Su Ping <sping@intel-research.net>
 *
 * Ported to 8051 by Sidsel Jensen & Anders Egeskov Petersen, 
 *                   Dept of Computer Science, University of Copenhagen
 * Date last modified: Nov 2005
 */

module TimerM {
  provides {
    interface Timer[uint8_t id];
    interface StdControl;
  }
  uses {
    interface Leds;
    interface Clock;
    interface PowerManagement;
    interface StdControl as ClockControl;
  }
}

implementation {
  uint32_t mState;		// each bit represent a timer state 
  uint32_t mInterval;		// Wider interface
  uint8_t  setIntervalFlag; 
  uint8_t mScale;
  int8_t queue_head;
  int8_t queue_tail;
  uint8_t queue_size;
  uint8_t queue[NUM_TIMERS];

  struct timer_s {
    uint8_t type;		// one-short or repeat timer
    int32_t ticks;		// clock ticks for a repeat timer 
    int32_t ticksLeft;		// ticks left before the timer expires
  } mTimerList[NUM_TIMERS];
  
  enum {
    maxTimerInterval = 0xFFFFU	// Maximum timer-ticks per interrupt (max 16 bit)
  };

  command result_t StdControl.init() {
    atomic {
      mState=0;
      setIntervalFlag = 0;
      queue_head = queue_tail = -1;
      queue_size = 0;
      mScale = DEFAULT_SCALE;
      mInterval = maxTimerInterval;
      mInterval &= 0xFFFF;		// Typecast workaround
    }
    call ClockControl.init();
    return call Clock.setRate((uint16_t)mInterval, mScale);
  }

  command result_t StdControl.start() {
    return call ClockControl.start();
  }

  command result_t StdControl.stop() {
    mState=0;
    mInterval = maxTimerInterval;
    mInterval &= 0xFFFF;		// Typecast workaround
    setIntervalFlag = 0;
    return SUCCESS;
  }

  static void adjustInterval() {
    uint8_t i;
    uint32_t val = maxTimerInterval;
    val &= 0xFFFF;			// Typecast workaround
    if (mState) {
      for (i=0;i<NUM_TIMERS;i++) {
        if ((mState&(0x1L<<i)) && (mTimerList[i].ticksLeft < val)) {
          val = mTimerList[i].ticksLeft;
        }
      }
      atomic {
        mInterval = val;
        call Clock.setInterval(mInterval);
        setIntervalFlag = 0;
      }
    } else {
      atomic {
        mInterval = maxTimerInterval;
        mInterval &= 0xFFFF;		// Typecast workaround
        call Clock.setInterval(mInterval);
        setIntervalFlag = 0;
      }
    }
//    call PowerManagement.adjustPower();
  }

  command result_t Timer.start[uint8_t id](char type, uint32_t interval) {
    uint16_t pos;
    if (id >= NUM_TIMERS) return FAIL;
    if (type>1) return FAIL;
    interval *= TICKS_PER_MILIS;
    mTimerList[id].ticks = interval;
    mTimerList[id].ticksLeft = interval;
    mTimerList[id].type = type;

    atomic {
      pos = call Clock.readCounter();
      mInterval -= (2^16) - pos;		// Timer travel sence last interrupt
      mState |= (0x1L<<id);
    } 
    adjustInterval();
    return SUCCESS;
  }

    command result_t Timer.stop[uint8_t id]() {
      if (id>=NUM_TIMERS) return FAIL;
      if (mState&(0x1L<<id)) {		// if the timer is running 
        atomic mState &= ~(0x1L<<id);
        if (!mState) {
          setIntervalFlag = 1;
        }
        return SUCCESS;
      }
      if(mState == 0) TR2 = 0;
      return FAIL; //timer not running
    }

    default event result_t Timer.fired[uint8_t id]() {
        return SUCCESS;
    }

    void enqueue(uint8_t value) {
      if (queue_tail == NUM_TIMERS - 1)
        queue_tail = -1;
      queue_tail++;
      queue_size++;
      queue[(uint8_t)queue_tail] = value;
    }

    uint8_t dequeue() {
      if (queue_size == 0)
        return NUM_TIMERS;
      if (queue_head == NUM_TIMERS - 1)
        queue_head = -1;
      queue_head++;
      queue_size--;
      return queue[(uint8_t)queue_head];
    }

    task void signalOneTimer() {
      uint8_t itimer = dequeue();
      if (itimer < NUM_TIMERS)
        signal Timer.fired[itimer]();
    }

    task void HandleFire() {
      uint8_t i;
      setIntervalFlag = 1;
      if (mState) {
        for (i=0; i<NUM_TIMERS; i++)  {
          if (mState & (0x1L<<i)) {
            mTimerList[i].ticksLeft -= (mInterval+1);
            if (mTimerList[i].ticksLeft<=2) {
              if (mTimerList[i].type==TIMER_REPEAT) {
                mTimerList[i].ticksLeft += mTimerList[i].ticks;
              } else {                       // one shot timer 
                mState &=~(0x1L<<i); 
              }
              enqueue(i);
              post signalOneTimer();
            }
          }
        }
      }
      adjustInterval();
    }

    async event result_t Clock.fire() {
      post HandleFire();
      return SUCCESS;
    }
  
}
