//$Id: HalTimerMilliC.nc,v 1.1.1.1 2007/11/05 19:11:33 jpolastre Exp $

/* "Copyright (c) 2000-2003 The Regents of the University of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement
 * is hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY
 * OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 */

//@author Cory Sharp <cssharp@eecs.berkeley.edu>

// The TinyOS Timer interfaces are discussed in TEP 102.

// TimerMilliC is the TinyOS TimerMilli component.  OSKI will expect
// TimerMilliC to exist.  It's in the platform directory so that the platform
// can directly manage how it chooses to implement the timer.  It is fully
// expected that the standard TinyOS MultiplexTimerM component will be used for
// all platforms, and that this configuration only specifies (implicitly or
// explicitly) how precisely to use the hardware resources.

configuration HalTimerMilliC
{
  provides interface StdControl as Init;
  provides interface Timer2<TMilli> as TimerMilli[ uint8_t num ];
}
implementation
{
  enum { NUM_TIMERS = uniqueCount("Timer") + uniqueCount("TimerMilli") };

  components MainTimerMilliC;
  components new AlarmMilliC()
	   , new AlarmToTimerC(TMilli)
	   , new VirtualizeTimerC(TMilli,NUM_TIMERS)
	   ;

  Init = AlarmMilliC;
  Init = VirtualizeTimerC;
  TimerMilli = VirtualizeTimerC;

  VirtualizeTimerC.TimerFrom -> AlarmToTimerC;
  AlarmToTimerC.Alarm -> AlarmMilliC;
}

