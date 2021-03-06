//$Id: VirtualizeTimerC.nc,v 1.1.1.1 2007/11/05 19:11:29 jpolastre Exp $

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

// @author Cory Sharp <cssharp@eecs.berkeley.edu>

// See TEP 102 Timers.

generic module VirtualizeTimerC( typedef precision_tag, int max_timers )
{
  provides interface StdControl as Init;
  provides interface Timer2<precision_tag> as Timer[ uint8_t num ];
  uses interface Timer2<precision_tag> as TimerFrom;
}
implementation
{
  typedef result_t error_t;

  enum
  {
    NUM_TIMERS = max_timers,
    END_OF_LIST = 255,
  };

  typedef struct
  {
    uint32_t t0;
    uint32_t dt;
  } Timer_t;

  typedef struct
  {
    bool isoneshot : 1;
    bool isrunning : 1;
    bool _reserved : 6;
  } Flags_t;

  Timer_t m_timers[NUM_TIMERS];
  Flags_t m_flags[NUM_TIMERS];

  command error_t Init.init()
  {
    memset( m_timers, 0, sizeof(m_timers) );
    memset( m_flags, 0, sizeof(m_flags) );
    return SUCCESS;
  }

  command result_t Init.start() { return SUCCESS; }
  command result_t Init.stop() { return SUCCESS; }

  task void executeTimersNow();

  void executeTimers( uint32_t then )
  {
    int32_t min_remaining = (1UL<<31)-1; //max signed int32_t
    bool min_remaining_isset = FALSE;
    int num;

    for( num=0; num<NUM_TIMERS; num++ )
    {
      Flags_t* flags = &m_flags[num];

      if( flags->isrunning )
      {
	// Calculate "remaining" before the timer is fired.  If a timer
	// restarts itself in a fired event, then we 1) need a consistent
	// "remaining" value to work with, and no worries because 2) all
	// start commands post executeTimersNow, so the timer will be
	// recomputed later, anyway.

	Timer_t* timer = &m_timers[num];
	int32_t elapsed = then - timer->t0;
	int32_t remaining = timer->dt - elapsed;
	bool compute_min_remaining = TRUE;

	// If the elapsed time is negative, then t0 is in the future, so
	// don't process it.  This implies:
	//   1) t0 in the future is okay
	//   2) dt can be at most maxval(uint32_t)/2

	if( (elapsed >= 0) && (timer->dt <= (uint32_t)elapsed) )
	{
	  if( flags->isoneshot )
	  {
	    flags->isrunning = FALSE;
	    compute_min_remaining = FALSE;
	  }
	  else
	  {
	    // The remaining time is non-positive (the timer had fired).
	    // So add dt to convert it to remaining for the next event.
	    timer->t0 += timer->dt;
	    remaining += timer->dt; 
	  }

	  signal Timer.fired[num]();
	}

	// check isrunning in case the timer was stopped in the fired event

	if( compute_min_remaining && flags->isrunning )
	{
          if( remaining < 0 )
            min_remaining = 0;
	  else if( remaining < min_remaining )
	    min_remaining = remaining;
	  min_remaining_isset = TRUE;
	}
      }
    }

    if( min_remaining_isset )
    {
      uint32_t now = call TimerFrom.getNow();
      uint32_t elapsed = now - then;
      if( min_remaining <= elapsed )
	post executeTimersNow();
      else
	call TimerFrom.startOneShotAt( now, min_remaining - elapsed );
    }
  }
  

  event void TimerFrom.fired()
  {
    executeTimers( call TimerFrom.gett0() + call TimerFrom.getdt() );
  }

  task void executeTimersNow()
  {
    call TimerFrom.stop();
    executeTimers( call TimerFrom.getNow() );
  }

  void startTimer( uint8_t num, uint32_t t0, uint32_t dt, bool isoneshot )
  {
    m_timers[num].t0 = t0;
    m_timers[num].dt = dt;
    m_flags[num].isoneshot = isoneshot;
    m_flags[num].isrunning = TRUE;
    post executeTimersNow();
  }

  command void Timer.startPeriodic[ uint8_t num ]( uint32_t dt )
  {
    startTimer( num, call TimerFrom.getNow(), dt, FALSE );
  }

  command void Timer.startOneShot[ uint8_t num ]( uint32_t dt )
  {
    startTimer( num, call TimerFrom.getNow(), dt, TRUE );
  }

  command void Timer.stop[ uint8_t num ]()
  {
    m_flags[num].isrunning = FALSE;
  }

  command bool Timer.isRunning[ uint8_t num ]()
  {
    return m_flags[num].isrunning;
  }

  command bool Timer.isOneShot[ uint8_t num ]()
  {
    return m_flags[num].isoneshot;
  }

  command void Timer.startPeriodicAt[ uint8_t num ]( uint32_t t0, uint32_t dt )
  {
    startTimer( num, t0, dt, FALSE );
  }

  command void Timer.startOneShotAt[ uint8_t num ]( uint32_t t0, uint32_t dt )
  {
    startTimer( num, t0, dt, TRUE );
  }

  command uint32_t Timer.getNow[ uint8_t num ]()
  {
    return call TimerFrom.getNow();
  }

  command uint32_t Timer.gett0[ uint8_t num ]()
  {
    return m_timers[num].t0;
  }

  command uint32_t Timer.getdt[ uint8_t num ]()
  {
    return m_timers[num].dt;
  }

  default event void Timer.fired[ uint8_t num ]()
  {
  }
}

