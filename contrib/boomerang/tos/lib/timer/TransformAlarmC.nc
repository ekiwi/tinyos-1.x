//$Id: TransformAlarmC.nc,v 1.1.1.1 2007/11/05 19:11:29 jpolastre Exp $

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

generic module TransformAlarmC( 
  typedef to_precision_tag,
  typedef to_size_type @integer(),
  typedef from_precision_tag,
  typedef from_size_type @integer(),
  uint8_t bit_shift_right )
{
  provides interface Alarm<to_precision_tag,to_size_type> as Alarm;
  uses interface Counter<to_precision_tag,to_size_type> as Counter;
  uses interface Alarm<from_precision_tag,from_size_type> as AlarmFrom;
}
implementation
{
  to_size_type m_t0;
  to_size_type m_dt;

  enum
  {
    MAX_DELAY_LOG2 = 8 * sizeof(from_size_type) - 1 - bit_shift_right,
    MAX_DELAY = ((to_size_type)1) << MAX_DELAY_LOG2,
  };

  async command to_size_type Alarm.getNow()
  {
    return call Counter.get();
  }

  async command to_size_type Alarm.getAlarm()
  {
    atomic return m_t0 + m_dt;
    //return m_t0 + m_dt;
  }

  async command bool Alarm.isRunning()
  {
    return call AlarmFrom.isRunning();
  }

  async command void Alarm.stop()
  {
    call AlarmFrom.stop();
  }

  void set_alarm()
  {
    to_size_type now = call Counter.get();
    from_size_type now_from = now << bit_shift_right;
    to_size_type elapsed = now - m_t0;
    if( elapsed >= m_dt )
    {
      m_t0 += m_dt;
      m_dt = 0;
      call AlarmFrom.startAt( now_from, 0 );
    }
    else
    {
      to_size_type remaining = m_dt - elapsed;
      from_size_type remaining_from = remaining;
      if( remaining > MAX_DELAY )
      {
	m_t0 = now + MAX_DELAY;
	m_dt = remaining - MAX_DELAY;
	call AlarmFrom.startAt( now_from, ((from_size_type)MAX_DELAY) << bit_shift_right );
      }
      else
      {
	m_t0 += m_dt;
	m_dt = 0;
	call AlarmFrom.startAt( now_from, remaining_from << bit_shift_right );
      }
    }
  }

  async command void Alarm.startAt( to_size_type t0, to_size_type dt )
  {
    atomic
    {
      m_t0 = t0;
      m_dt = dt;
      set_alarm();
    }
  }

  async command void Alarm.start( to_size_type dt )
  {
    call Alarm.startAt( call Alarm.getNow(), dt );
  }

  async event void AlarmFrom.fired()
  {
    atomic
    {
      if( m_dt == 0 )
      {
	signal Alarm.fired();
      }
      else
      {
	set_alarm();
      }
    }
  }

  async event void Counter.overflow()
  {
  }

  default async event void Alarm.fired()
  {
  }
}

