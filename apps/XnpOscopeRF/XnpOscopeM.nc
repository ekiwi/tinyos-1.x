// $Id: XnpOscopeM.nc,v 1.4 2003/10/07 21:45:27 idgay Exp $

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
 * Authors:   Jason Hill
 * History:   created 10/5/2001
 * 
 */

/**
 * @author Jason Hill
 */

includes OscopeMsg;

/**
 * This module implements the XnpOscopeM component, which
 * periodically takes sensor readings and sends a group of readings 
 * over the UART. BUFFER_SIZE defines the number of readings sent
 * in a single packet. The Yellow LED is toggled whenever a new
 * packet is sent, and the red LED is turned on when the sensor
 * reading is above some constant value.
 */
module XnpOscopeM
{
  provides interface StdControl;
  uses {
    interface Timer;
    interface Leds;
    interface StdControl as SensorControl;
    interface ADC;
    interface StdControl as CommControl;
    interface SendMsg as DataMsg;
    interface ReceiveMsg as ResetCounterMsg;
    interface Xnp;
  }
}
implementation
{
  uint8_t packetReadingNumber;
  uint16_t readingNumber;
  TOS_Msg msg[2];
  uint8_t currentMsg;

  /**
   * Used to initialize this component.
   */
  command result_t StdControl.init() {
    call Xnp.NPX_SET_IDS();

    call Leds.init();
    call Leds.yellowOff(); call Leds.redOff(); call Leds.greenOff();

    //turn on the sensors so that they can be read.
    call SensorControl.init();

    call CommControl.init();
    
    atomic {
      currentMsg = 0;
      packetReadingNumber = 0;
      readingNumber = 0;
    }
    
    dbg(DBG_BOOT, "OSCOPE initialized\n");
    return SUCCESS;
  }

  /**
   * Starts the SensorControl and CommControl components.
   * @return Always returns SUCCESS.
   */
  command result_t StdControl.start() {
    call SensorControl.start();
    call Timer.start(TIMER_REPEAT, 125);
    call CommControl.start();
    return SUCCESS;
  }

  /**
   * Stops the SensorControl and CommControl components.
   * @return Always returns SUCCESS.
   */
  command result_t StdControl.stop() {
    call SensorControl.stop();
    call Timer.stop();
    call CommControl.stop();
    return SUCCESS;
  }

  task void dataTask() {
    struct OscopeMsg *pack;
    atomic {
      pack = (struct OscopeMsg *)msg[currentMsg].data;
      packetReadingNumber = 0;
      pack->lastSampleNumber = readingNumber;
    }

    pack->channel = 1;
    pack->sourceMoteID = TOS_LOCAL_ADDRESS;
    
    /* Try to send the packet. Note that this will return
     * failure immediately if the packet could not be queued for
     * transmission.
     */
    if (call DataMsg.send(TOS_BCAST_ADDR, sizeof(struct OscopeMsg),
			      &msg[currentMsg]))
      {
	atomic {
	  currentMsg ^= 0x1;
	}
	call Leds.yellowToggle();
      }
  }
  
  /**
   * Signalled when data is ready from the ADC. Stuffs the sensor
   * reading into the current packet, and sends off the packet when
   * BUFFER_SIZE readings have been taken.
   * @return Always returns SUCCESS.
   */
  async event result_t ADC.dataReady(uint16_t data) {
    struct OscopeMsg *pack;
    atomic {
      pack = (struct OscopeMsg *)msg[currentMsg].data;
      pack->data[packetReadingNumber++] = data;
      readingNumber++;
      dbg(DBG_USR1, "data_event\n");
      if (packetReadingNumber == BUFFER_SIZE) {
	post dataTask();
      }
    }
    if (data > 0x0300)
      call Leds.redOn();
    else
      call Leds.redOff();

    return SUCCESS;
  }

  /**
   * Signalled when the previous packet has been sent.
   * @return Always returns SUCCESS.
   */
  event result_t DataMsg.sendDone(TOS_MsgPtr sent, result_t success) {
    return SUCCESS;
  }

  /**
   * Signalled when the clock ticks.
   * @return The result of calling ADC.getData().
   */
  event result_t Timer.fired() {
    return call ADC.getData();
  }

  /**
   * Signalled when the reset message counter AM is received.
   * @return The free TOS_MsgPtr. 
   */
  event TOS_MsgPtr ResetCounterMsg.receive(TOS_MsgPtr m) {
    atomic {
      readingNumber = 0;
    }
    return m;
  }

/*****************************************************************************
 NPX_DOWNLOAD_REQ
NetProgramming service module has received a request from the network to
download a program srec image. Our choices are:
-Release EEPROM resource and acknowledge OK
-Acknowledge with NO

*****************************************************************************/
  event result_t Xnp.NPX_DOWNLOAD_REQ(uint16_t wProgramID, uint16_t wEEStartP, uint16_t wEENofP){


//Acknowledge NPX
    call Xnp.NPX_DOWNLOAD_ACK(SUCCESS);
    call Timer.stop();
    return SUCCESS;
  }

  event result_t Xnp.NPX_DOWNLOAD_DONE(uint16_t wProgramID, uint8_t bRet,uint16_t wEENofP){
    if (bRet == TRUE)
       call Timer.start(TIMER_REPEAT, 125);

    return SUCCESS;
  }

}
