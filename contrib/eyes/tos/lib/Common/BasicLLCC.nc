/*
 * Copyright (c) 2004, Technische Universitaet Berlin
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions 
 * are met:
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright 
 *   notice, this list of conditions and the following disclaimer in the 
 *   documentation and/or other materials provided with the distribution.
 * - Neither the name of the Technische Universitaet Berlin nor the names 
 *   of its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY 
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * - Description ---------------------------------------------------------
 * 
 * - Revision -------------------------------------------------------------
 * $Revision: 1.5 $
 * $Date: 2005/03/03 19:10:44 $
 * @author: Kevin Klues (klues@tkn.tu-berlin.de)
 * ========================================================================
 */

configuration BasicLLCC {
   provides {
      interface StdControl;
      interface ReceiveMsg as Receive;
      interface BareSendMsg as Send;
   }
   uses {
      interface GenericMsgComm;
      interface MarshallerControl;
      interface PacketRx;
   }
}
implementation
{
   components BasicLLCM as LLC,
              TimerC,
              RandomLFSR,              
              RSSIVccC;
   
   StdControl        = LLC;
   GenericMsgComm    = LLC;
   Receive           = LLC;
   Send              = LLC;
   PacketRx          = LLC;
   MarshallerControl = LLC;
   
   StdControl     =  TimerC;
   StdControl     =  RSSIVccC;
   LLC.Random -> RandomLFSR;      
   LLC.RxPacketTimeout -> TimerC.TimerJiffy[unique("TimerJiffy")];
   LLC.BackOffTimer -> TimerC.TimerJiffy[unique("TimerJiffy")];
   LLC.RSSImV -> RSSIVccC;
 }
