/*									tab:4
 *
 *
 * "Copyright (c) 2000-2002 The Regents of the University  of California.  
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
 */
/*									tab:4
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
 *	Redistributions of source code must retain the above copyright
 *  notice, this list of conditions and the following disclaimer.
 *	Redistributions in binary form must reproduce the above copyright
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
/*
 * Author:	Wei Hong
 *
 */


/* Routing component for TinyDB.  Can receive and send
   data and query messages.  Data messages are tuples
   or aggregate values.  Queries represent portions
   of queries being injected into the network.

   In the TAG world, query messages flood down the routing tree,
   and data messages are sent up the network (to the node's) parent
   towards the root.  Obviously, there are other routing mechanisms
   that might make sense,  but the routing system needs to be careful
   to do duplicate elimination -- which may be hard since this API
   doesn't export the contents of the data messages.

   The routing in this module will be based on the standard interfaces
   Send, Receive, Intercept and Bcast.
*/

includes MultiHop;

configuration NetworkMultiHop 
{
	provides 
	{
		interface Network;
		interface StdControl;
		interface NetworkMonitor;
	}
}
implementation
{
	components NetworkMultiHopM, GENERICCOMM as Comm, MultiHopRouter as MultiHopSnoopRtr, TinyDBCommand, 
#ifdef kSUPPORTS_EVENTS
	TinyDBEvent, 
#endif
	TupleRouterM, /* NoLeds as */ LedsC, QueuedSend, LogicalTime;

	NetworkMultiHopM.SendQueryRequest -> QueuedSend.SendMsg[kQUERY_REQUEST_MESSAGE_ID];
	NetworkMultiHopM.RcvQueryMsg -> Comm.ReceiveMsg[kQUERY_MESSAGE_ID];
#ifdef kQUERY_SHARING
	NetworkMultiHopM.RcvRequestMsg -> Comm.ReceiveMsg[kQUERY_REQUEST_MESSAGE_ID];
#endif
	NetworkMultiHopM.SendQueryMsg -> QueuedSend.SendMsg[kQUERY_MESSAGE_ID];
	NetworkMultiHopM.SendDataMsg -> QueuedSend.SendMsg[kDATA_MESSAGE_ID];
	NetworkMultiHopM.SendCommandMsg -> QueuedSend.SendMsg[kCOMMAND_MESSAGE_ID];
	NetworkMultiHopM.RcvCommandMsg -> Comm.ReceiveMsg[kCOMMAND_MESSAGE_ID];
#ifdef kSUPPORTS_EVENTS
	NetworkMultiHopM.SendEventMsg -> QueuedSend.SendMsg[kEVENT_MESSAGE_ID];
	NetworkMultiHopM.RcvEventMsg -> Comm.ReceiveMsg[kEVENT_MESSAGE_ID];
#endif
#ifdef kSTATUS
	NetworkMultiHopM.SendStatusMsg -> QueuedSend.SendMsg[kSTATUS_MESSAGE_ID];
	NetworkMultiHopM.RcvStatusMessage -> Comm.ReceiveMsg[kSTATUS_MESSAGE_ID];
	NetworkMultiHopM.QueryProcessor -> TupleRouterM;
#endif

	NetworkMultiHopM.Leds -> LedsC;

	NetworkMultiHopM.CommandUse -> TinyDBCommand;
#ifdef kSUPPORTS_EVENTS
	NetworkMultiHopM.EventUse -> TinyDBEvent;
#endif
	NetworkMultiHopM.Intercept -> MultiHopSnoopRtr.Intercept[kDATA_MESSAGE_ID];
	NetworkMultiHopM.Send -> MultiHopSnoopRtr.Send[kDATA_MESSAGE_ID];
	NetworkMultiHopM.Snoop -> MultiHopSnoopRtr.Snoop[kDATA_MESSAGE_ID];
	NetworkMultiHopM.MultiHopControl -> MultiHopSnoopRtr;
	NetworkMultiHopM.MultiHopStdControl -> MultiHopSnoopRtr;
	NetworkMultiHopM.QueueControl -> QueuedSend;
		/*
        NetworkMultiHopM.RcvRTCTime -> Comm.ReceiveMsg[AM_RTCMSG];
        NetworkMultiHopM.Time -> LogicalTime;
		*/
    StdControl = NetworkMultiHopM;
	Network = NetworkMultiHopM;
	NetworkMonitor = NetworkMultiHopM;
	MultiHopSnoopRtr.ReceiveMsg[kDATA_MESSAGE_ID] -> Comm.ReceiveMsg[kDATA_MESSAGE_ID];
	MultiHopSnoopRtr.ReceiveMsg[AM_MULTIHOPMSG] -> Comm.ReceiveMsg[AM_MULTIHOPMSG];
}
