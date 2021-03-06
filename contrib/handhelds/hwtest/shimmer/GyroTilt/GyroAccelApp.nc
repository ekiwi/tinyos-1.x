/*
 * Copyright (c) 2006 Intel Corporation
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
 *     * Neither the name of the Intel Corporation nor the names of its
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
 * Authors: Steve Ayer
 *          August 2006
 */

configuration GyroAccelApp {
}
implementation {
  components 
    Main, 
    GyroAccelAppM, 
    DMA_M, 
    MMA7260_AccelM,
    TimerC, 
    LedsC, 	
    IPCLIENT as IPClientC,
    TelnetM,
    DS2411LiteM,
    ParamViewM;

  Main.StdControl->GyroAccelAppM;
  Main.StdControl->TimerC;

  /* have to fix compile time channel limitation */
  GyroAccelAppM.DMA0         -> DMA_M.DMA[0];
  GyroAccelAppM.DMA1         -> DMA_M.DMA[1];
  GyroAccelAppM.DMA2         -> DMA_M.DMA[2];
  GyroAccelAppM.Leds         -> LedsC;
  GyroAccelAppM.yTimer       -> TimerC.Timer[unique("Timer")];
 
  //  GyroAccelAppM.SDStdControl      -> SDC;
  //  GyroAccelAppM.SD                -> SD_M;

  GyroAccelAppM.AccelStdControl   -> MMA7260_AccelM;
  GyroAccelAppM.Accel             -> MMA7260_AccelM;

  /* telnet stuff */
  GyroAccelAppM.IPStdControl  -> IPClientC;
  GyroAccelAppM.UIP           -> IPClientC;
  GyroAccelAppM.Client        -> IPClientC;
  GyroAccelAppM.TCPClient     -> IPClientC.TCPClient[unique("TCPClient")];
  //  GyroAccelAppM.UDPClient     -> IPClientC.UDPClient[unique("UDPClient")];

  GyroAccelAppM.TelnetRun         -> TelnetM.Telnet[unique("Telnet")];

  GyroAccelAppM.ClientStdControl   -> IPClientC.StdControl;

  GyroAccelAppM.PVStdControl      -> ParamViewM;
  GyroAccelAppM.TelnetStdControl  -> TelnetM;

  TelnetM.TCPServer            -> IPClientC.TCPServer[unique("TCPServer")];

  ParamViewM.TelnetShow         -> TelnetM.Telnet[unique("Telnet")];
  ParamViewM.ParamView          -> IPClientC.ParamView;
  ParamViewM.ParamView          -> GyroAccelAppM.ParamView;
  /* end telnet stuff */
}
