/* "Copyright (c) 2000-2002 The Regents of the University of California.  
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
 */

// Authors: Cory Sharp
// $Id: BerkeleyNullRouting2M.nc,v 1.1 2003/10/09 01:14:14 cssharp Exp $

includes Routing;

module BerkeleyNullRouting2M
{
  provides interface Routing;
  provides interface StdControl;
  uses interface Routing as BottomRouting;
}
implementation
{
  TOS_MsgPtr m_msg;

  void sendDone( result_t success )
  {
    if( m_msg != 0 )
    {
      TOS_MsgPtr msg = m_msg;
      m_msg = 0;
      signal Routing.sendDone( msg, success );
    }
  }

  task void send()
  {
    sendDone( SUCCESS );
  }

  command result_t StdControl.init()
  {
    m_msg = 0;
    return SUCCESS;
  }

  command result_t StdControl.start()
  {
    return SUCCESS;
  }

  command result_t StdControl.stop()
  {
    sendDone( FAIL );
    return SUCCESS;
  }

  command result_t Routing.send( RoutingDestination_t dst, TOS_MsgPtr msg )
  {
    if( m_msg == 0 )
    {
      m_msg = msg;
      if( post send() )
	return SUCCESS;
      m_msg = 0;
    }
    return FAIL;
  }

  event result_t BottomRouting.sendDone( TOS_MsgPtr msg, result_t success )
  {
    return SUCCESS;
  }

  event TOS_MsgPtr BottomRouting.receive( TOS_MsgPtr msg )
  {
    return msg;
  }
}

