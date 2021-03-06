/*
 * Copyright (c) 2006, Intel Corporation
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
 *     * Neither the name of Intel Corporation nor the names of its
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
 * App to test SD module
 *
 * Authors:  Steve Ayer
 *           May 2006
 */

//includes SD;

configuration SDApp {
}
implementation {
  components Main, 
    SDAppM,
    SD_M, 
    TelnetM,
    IPCLIENT as IPClientC,
    SDC,
    ParamViewM,
    //    NTPClientM,
    LedsC,
    TimerC;

  Main.StdControl->SDAppM;
  Main.StdControl->TimerC;

  SDAppM.IPStdControl      -> IPClientC;
  SDAppM.TelnetStdControl  -> TelnetM;
  SDAppM.PVStdControl      -> ParamViewM;
  SDAppM.SDStdControl      -> SDC;
  //  SDAppM.Timer             -> TimerC.Timer[unique("Timer")];

  SDAppM.TCPServer         -> IPClientC.TCPServer[unique("TCPServer")];

  SDAppM.UIP               -> IPClientC;
  SDAppM.Client            -> IPClientC;
  SDAppM.Leds              -> LedsC;
  SDAppM.SD                -> SD_M;
  SDAppM.TelnetRun         -> TelnetM.Telnet[unique("Telnet")];

  //  SDAppM.NTPClient          -> NTPClientM;
  
  //  SD_M.Leds                -> SDC;
  //  SD_M.USARTControl        -> SDC;
  /*
  NTPClientM.UDPClient       -> IPClientC.UDPClient[unique("UDPClient")];
  NTPClientM.Timer           -> TimerC.Timer[unique("Timer")];
  NTPClientM.Client          -> IPClientC;
  */
  ParamViewM.TelnetShow         -> TelnetM.Telnet[unique("Telnet")];
  ParamViewM.ParamView          -> SDAppM.ParamView;
  ParamViewM.ParamView          -> IPClientC.ParamView;
  
  TelnetM.TCPServer             -> IPClientC.TCPServer[unique("TCPServer")];
}
