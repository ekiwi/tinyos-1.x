/*
 * Copyright (c) 2004,2005 Hewlett-Packard Company
 * All rights reserved
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:

 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 *       copyright notice, this list of conditions and the following
 *       disclaimer in the documentation and/or other materials provided
 *       with the distribution.
 *     * Neither the name of the Hewlett-Packard Company nor the names of its
 *       contributors may be used to endorse or promote products derived
 *       from this software without specific prior written permission.

 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 *
 * Authors: Andrew Christian
 *          16 December 2004
 */

configuration ClientC {
  provides {
    interface StdControl;
    interface Message;
    interface Client;
    interface ParamView;
  }
}
implementation {
  components ClientM, CC2420HighLevelC, LedsC, MessagePoolM, TimerC, IEEEUtilityM;

  StdControl             = ClientM;
  Message                = ClientM;
  Client                 = ClientM;
  ParamView              = CC2420HighLevelC;
  ParamView              = ClientM;

  ClientM.Leds           -> LedsC;
  ClientM.MessagePool    -> MessagePoolM;
  ClientM.Timer          -> TimerC.Timer[unique("Timer")];
  ClientM.AutoReScanTimer-> TimerC.Timer[unique("Timer")];

  ClientM.RadioStdControl -> CC2420HighLevelC;
  ClientM.Radio           -> CC2420HighLevelC;
  ClientM.CC2420Control   -> CC2420HighLevelC;

  ClientM.IEEEUtility     -> IEEEUtilityM;
}
