/* "Copyright (c) 2000-2003 The Regents of the University of California.  
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
// $Id: SystemCommandM.perl.nc,v 1.1 2003/10/09 01:14:12 cssharp Exp $


includes ${Command};

module ${Command}M
{
  provides interface ${Command};
  provides interface StdControl;
  uses interface ${Neighborhood}_private;
  uses interface NeighborhoodComm as CallComm;
  uses interface NeighborhoodComm as ReturnComm;
  uses interface MsgBuffers;
}
implementation
{
  command result_t StdControl.init()
  {
    call MsgBuffers.init();
    return SUCCESS;
  }

  command result_t StdControl.start()
  {
    return SUCCESS;
  }

  command result_t StdControl.stop()
  {
    return SUCCESS;
  }

  // ---
  // --- Call
  // ---

  command result_t ${Command}.sendCall( nodeID_t id, ${Command}Args_t args )
  {
    TOS_MsgPtr msg = call MsgBuffers_alloc();
    if( msg != 0 )
    {
      ${ArgsType}* data = (${ArgsType}*)initRoutingMsg( msg, sizeof(${ArgsType}) );
      if( data != 0 )
      {
	*data = args;
	if( call CallComm.send( id, msg ) == SUCCESS )
	  return SUCCESS;
      }
      call MsgBuffers.free( msg );
    }
    return FAIL;
  }

  event result_t CallComm.sendDone( TOS_MsgPtr msg, result_t success )
  {
    call MsgBuffers.free( msg );
    return SUCCESS;
  }

  TOS_MsgPtr receiveCall( RoutingDestination_t src, TOS_MsgPtr msg )
  {
    ${ArgsType}* args = (${ArgsType}*)popFromRoutingMsg( msg, sizeof(${ArgsType}) );
    if( args != NULL )
      signal ${Command}.receiveCall( *args );
    return msg;
  }

  event TOS_MsgPtr CallComm.receive( nodeID_t src, TOS_MsgPtr msg )
  {
    return receiveCall( call CallComm.getRoutingDestination(src), msg );
  }

  event TOS_MsgPtr CallComm.receiveNAN( RoutingDestination_t src, TOS_MsgPtr msg )
  {
    return receiveCall( src, msg );
  }


  // ---
  // --- Return
  // ---

  command result_t ${Command}.sendReturn( ${Command}Return_t rets )
  {
    if( sizeof(${Command}Return_t) == 0 )
    {
      return SUCCESS;
    }
    else
    {
      TOS_MsgPtr msg = call MsgBuffers_alloc();
      RoutingDestination_t src = { address:TOS_BCAST_ADDR };

      if( msg != NULL )
      {
	${ReturnType}* data = (${ReturnType}*)initRoutingMsg( msg, sizeof(${ReturnType}) );
	if( data != NULL )
	{
	  *data = rets;
	  if( call ReturnComm.sendNAN( src, msg ) == SUCCESS )
	    return SUCCESS;
	}
	call MsgBuffers.free( msg );
      }
    }
    return FAIL;
  }

  command result_t ${Command}.dropReturn()
  {
    return SUCCESS;
  }

  event result_t ReturnComm.sendDone( TOS_MsgPtr msg, result_t success )
  {
    call MsgBuffers.free( msg );
    return SUCCESS;
  }

  event TOS_MsgPtr ReturnComm.receive( nodeID_t src, TOS_MsgPtr msg )
  {
    ${ReturnType}* data = (${ReturnType}*)popFromRoutingMsg( msg, sizeof(${ReturnType}) );
    if( data != NULL )
      signal ${Command}.receiveReturn( src, *data );
    return msg;
  }

  event TOS_MsgPtr ReturnComm.receiveNAN( RoutingDestination_t src, TOS_MsgPtr msg )
  {
    return msg;
  }
}

