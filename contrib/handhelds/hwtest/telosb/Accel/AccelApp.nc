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
 * Authors: Andrew Christian
 *          February 2005
 */

includes Accel;

configuration AccelApp {
}
implementation {
  components Main, 
    AccelAppM,
    AccelM, 
    TelnetM,
    SIPLiteServerM,
    IPCLIENT as IPClientC,
    ParamViewM,
    LedsC,
    TimerC,
    ADCC;

  Main.StdControl->AccelAppM;
  Main.StdControl->TimerC;

  AccelAppM.IPStdControl      -> IPClientC;
  AccelAppM.SIPLiteStdControl -> SIPLiteServerM;
  AccelAppM.TelnetStdControl  -> TelnetM;
  AccelAppM.PVStdControl      -> ParamViewM;
  AccelAppM.SIPLiteServer     -> SIPLiteServerM;
  AccelAppM.AccelStdControl   -> AccelM.StdControl;

  AccelAppM.UIP               -> IPClientC;
  AccelAppM.Client            -> IPClientC;
  AccelAppM.Leds              -> LedsC;
  AccelAppM.Accel             -> AccelM;

  AccelM.XADC                 -> ADCC.ADC[TOS_ADC_ACCEL_X_PORT];
  AccelM.YADC                 -> ADCC.ADC[TOS_ADC_ACCEL_Y_PORT];
  AccelM.ADCControl           -> ADCC.ADCControl;
  AccelM.Timer                -> TimerC.Timer[unique("Timer")];

  ParamViewM.TelnetShow         -> TelnetM.Telnet[unique("Telnet")];
  ParamViewM.ParamView          -> AccelM.ParamView;
  ParamViewM.ParamView          -> IPClientC.ParamView;
  ParamViewM.ParamView          -> SIPLiteServerM.ParamView;

  TelnetM.TCPServer             -> IPClientC.TCPServer[unique("TCPServer")];

  SIPLiteServerM.UDPMaster      -> IPClientC.UDPClient[unique("UDPClient")];
  SIPLiteServerM.UDPStream      -> IPClientC.UDPClient[unique("UDPClient")];
  SIPLiteServerM.TimerMaster   -> TimerC.Timer[unique("Timer")];
}
