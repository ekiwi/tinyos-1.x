// $Id: CC2420RadioC.nc,v 1.1 2006/03/09 23:33:09 binetude Exp $

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
 * Authors: Joe Polastre
 * Date last modified: $Revision: 1.1 $
 *
 */

/**
 * @author Joe Polastre
 */

configuration CC2420RadioC
{
  provides {
    interface StdControl;
    interface SplitControl;
    interface SendSP as Send;
    interface ReceiveSP as Receive;
    interface CC2420Control;
    //interface MacControl;
    //interface MacBackoff;
    //interface RadioCoordinator as RadioReceiveCoordinator;
    //interface RadioCoordinator as RadioSendCoordinator;
    interface SPLinkAdaptor;
  }
}
implementation
{
  components CC2420RadioM, CC2420ControlM, HPLCC2420C, 
    RandomLFSR, 
    TimerJiffyAsyncC,
    CC2420RadioSPM as SPM,
    SPC,
    LedsC;

  StdControl = CC2420RadioM;
  SplitControl = SPM;
  Send = SPM;
  Receive = SPM;
  //MacControl = CC2420RadioM;
  //MacBackoff = CC2420RadioM;
  CC2420Control = CC2420ControlM;
  //RadioReceiveCoordinator = CC2420RadioM.RadioReceiveCoordinator;
  //RadioSendCoordinator = CC2420RadioM.RadioSendCoordinator;
  SPLinkAdaptor = SPM;

  SPM.RadioControl -> CC2420RadioM.SplitControl;
  SPM.LowerSend -> CC2420RadioM.Send;
  SPM.LowerReceive -> CC2420RadioM.Receive;
  SPM.LowerMacControl -> CC2420RadioM.MacControl;
  //SPM.LowerMacBackoff -> CC2420RadioM.MacBackoff;
  SPM.SPNeighbor -> SPC;

  CC2420RadioM.CC2420SplitControl -> CC2420ControlM;
  CC2420RadioM.CC2420Control -> CC2420ControlM;
  CC2420RadioM.Random -> RandomLFSR;
  CC2420RadioM.TimerControl -> TimerJiffyAsyncC.StdControl;
  CC2420RadioM.BackoffTimerJiffy -> TimerJiffyAsyncC.TimerJiffyAsync;
  CC2420RadioM.HPLChipcon -> HPLCC2420C.HPLCC2420;
  CC2420RadioM.HPLChipconFIFO -> HPLCC2420C.HPLCC2420FIFO;
  CC2420RadioM.FIFOP -> HPLCC2420C.InterruptFIFOP;
  CC2420RadioM.SFD -> HPLCC2420C.CaptureSFD;

  CC2420ControlM.HPLChipconControl -> HPLCC2420C.StdControl;
  CC2420ControlM.HPLChipcon -> HPLCC2420C.HPLCC2420;
  CC2420ControlM.HPLChipconRAM -> HPLCC2420C.HPLCC2420RAM;
  CC2420ControlM.CCA -> HPLCC2420C.InterruptCCA;

  CC2420RadioM.Leds -> LedsC;
}