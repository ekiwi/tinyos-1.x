// $Id: EWMAMultiHopRouter.nc,v 1.2 2005/01/14 01:25:22 jdprabhu Exp $
/*
 * Copyright (c) 2005 Crossbow Technology, Inc.
 *
 * All rights reserved.
 *
 * Permission to use, copy, modify and distribute, this software and
 * documentation is granted, provided the following conditions are met:
 * 
 * 1. The above copyright notice and these conditions, along with the
 * following disclaimers, appear in all copies of the software.
 * 
 * 2. When the use, copying, modification or distribution is for COMMERCIAL
 * purposes (i.e., any use other than academic research), then the software
 * (including all modifications of the software) may be used ONLY with
 * hardware manufactured by and purchased from Crossbow Technology, unless
 * you obtain separate written permission from, and pay appropriate fees
 * to, Crossbow. For example, no right to copy and use the software on
 * non-Crossbow hardware, if the use is commercial in nature, is permitted
 * under this license. 
 *
 * 3. When the use, copying, modification or distribution is for
 * NON-COMMERCIAL PURPOSES (i.e., academic research use only), the software
 * may be used, whether or not with Crossbow hardware, without any fee to
 * Crossbow. 
 * 
 * IN NO EVENT SHALL CROSSBOW TECHNOLOGY OR ANY OF ITS LICENSORS BE LIABLE
 * TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
 * DAMAGES ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
 * EVEN IF CROSSBOW OR ITS LICENSOR HAS BEEN ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE. CROSSBOW TECHNOLOGY AND ITS LICENSORS SPECIFICALLY DISCLAIM
 * ALL WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE
 * PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND NEITHER CROSSBOW NOR ANY
 * LICENSOR HAS ANY OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
 * ENHANCEMENTS, OR MODIFICATIONS. 
 * 
 */

includes MultiHop;

configuration EWMAMultiHopRouter {
  
  provides {
    interface StdControl;
    // The interface are as parameterised by the active message id
	// only the 10 active message ids defined MultiHop.h are supported.
    interface Receive[uint8_t id];
    interface Intercept[uint8_t id];
    interface Intercept as Snoop[uint8_t id];
    interface Send[uint8_t id];
    interface RouteControl;
  }

  uses {
    interface ReceiveMsg[uint8_t id];
    interface ReceiveMsg as ReceiveDownstreamMsg[uint8_t id];
  }

}

implementation {
  
  // Uncomment for use with mh6
  components MultiHopEngineM, MultiHopEWMA, GenericCommPromiscuous as Comm, 
    QueuedSend, RadioCRCPacket,
#ifdef USE_WATCHDOG
	WDTC,
#endif
	TimerC;

  StdControl = MultiHopEngineM;
  Receive = MultiHopEngineM.ReceiveDataMsg;
  Send = MultiHopEngineM;
  Intercept = MultiHopEngineM.Intercept;
  Snoop = MultiHopEngineM.Snoop;
  RouteControl = MultiHopEngineM;

  ReceiveMsg = MultiHopEngineM.ReceiveMsg;
  ReceiveDownstreamMsg = MultiHopEngineM.ReceiveDownstreamMsg;

  MultiHopEngineM.SubControl -> QueuedSend.StdControl;
  MultiHopEngineM.SubControl -> MultiHopEWMA.StdControl;
  MultiHopEngineM.CommStdControl -> Comm;
  MultiHopEngineM.CommControl -> Comm;
  MultiHopEngineM.RouteSelectCntl -> MultiHopEWMA.RouteControl;
  MultiHopEngineM.RouteSelect -> MultiHopEWMA;


  MultiHopEngineM.SendMsg -> QueuedSend.SendMsg;
  
  MultiHopEWMA.Timer -> TimerC.Timer[unique("Timer")];  
  MultiHopEWMA.ReceiveMsg -> Comm.ReceiveMsg[AM_MULTIHOPMSG];
  MultiHopEWMA.Snoop -> MultiHopEngineM.Snoop;
  MultiHopEWMA.SendMsg -> QueuedSend.SendMsg[AM_MULTIHOPMSG];
  MultiHopEWMA.DebugSendMsg -> MultiHopEngineM.Send[AM_DEBUGPACKET];
  MultiHopEngineM.ReceiveMsg[AM_DEBUGPACKET] -> Comm.ReceiveMsg[AM_DEBUGPACKET];
#ifdef USE_WATCHDOG
  MultiHopEWMA.PoochHandler -> WDTC.StdControl;
  MultiHopEWMA.WDT -> WDTC.WDT;
#endif
  MultiHopEngineM.ReceiveDownstreamMsg[248] -> Comm.ReceiveMsg[248];
  MultiHopEngineM.ReceiveMsg[249] -> Comm.ReceiveMsg[249];
  MultiHopEngineM.Timer -> TimerC.Timer[unique("Timer")];
  MultiHopEngineM.RadioPower -> RadioCRCPacket;
  MultiHopEngineM.set_power_mode -> MultiHopEWMA;
}
