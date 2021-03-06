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
/** 
 * Configuration for SimpleCmd module.
 *
 * Author/Contact: tinyos-help@millennium.berkeley.edu
 * 
 * Description:
 *
 * SimpleCmd module demonstrates a simple command interpreter for TinyOS tutorial 
 * (Lesson 8 in particular).  It receives a command message from its RF interface,
 * which triggers a command interpreter task to execute the command.
 * When the command is finished executing, the component signals the upper 
 * layers with the received message and the status indicating whether the message
 * should be further processed. 
 *
 * As a simple version,  it can only interpret the follwoing commands:
 * Led_on (1), Led_off(2), radio_quieter(3), radio_louder(4), 
 * start_sensing(5), and read_log(6). Start sensing commands will trigger 
 * the Sensing.start interface while read log will read the EEPROM with 
 * a specific log line and broadcast the line over the radio when read is done.
 */
includes SimpleCmdMsg;

configuration SimpleCmd {
  provides interface ProcessCmd;
}
implementation {
  components Main, SimpleCmdM, AclLZToLog, Logger,
    GenericComm as Comm, PotC, LedsC;

  Main.StdControl -> SimpleCmdM;
  SimpleCmdM.Leds -> LedsC;

  ProcessCmd = SimpleCmdM.ProcessCmd;

  SimpleCmdM.CommControl -> Comm;

  SimpleCmdM.ReceiveCmdMsg -> Comm.ReceiveMsg[AM_SIMPLECMDMSG];
  SimpleCmdM.SendLogMsg -> Comm.SendMsg[AM_LOGMSG];
  SimpleCmdM.LoggerRead -> Logger;
  SimpleCmdM.Pot -> PotC;
  SimpleCmdM.Sensing -> AclLZToLog.Sensing;
}

