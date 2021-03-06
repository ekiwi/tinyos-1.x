/*									tab:4
 * "Copyright (c) 2000-2003 The Regents of the University  of California.  
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
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */
/*
 * Authors:  Jason Hill  Su Ping
 * Date:     $Id: Mica2HWVerifyM.nc,v 1.2 2003/10/07 21:44:52 idgay Exp $
 *
 *
 *
 * This component checks the functionality of the device and sends a
 * report message over both the UART and the radio.  It should be run
 * with the java program hardware_check.java, which interprets the
 * report messages. To test the radio, program a second mote with
 * generic_base_high_speed, which will forward the received radio
 * packets to the java program for interpretation.  This program also
 * prints out he serial_ID for the ID chip of the mote.
 */

/**
 * @author Jason Hill
 * @author Su Ping
 */


includes HardwareId;
includes HWVerifyMsg;
module Mica2HWVerifyM {
  provides interface StdControl;
  uses {
    interface Leds;
    interface SendMsg as Send;
    interface ReceiveMsg;
    interface Timer;
    interface HardwareId;
    interface SlavePin as FlashSelect;
    interface FastSPI as FlashSPI;
  }
}

implementation {
  uint8_t gfSendBusy;
  uint8_t count;
  TOS_Msg diag;

  enum {
    HWVERIFY_MSGRATE = 1024
  };

  void checkFlash();

  task void TimerTask() {
    struct DiagMsg *pack = (struct DiagMsg *)diag.data;
    uint16_t dest;
    
    if ((pack->sendType ^= 1))
      dest = TOS_UART_ADDR;
    else
      dest = 0xffff;
    
    call Leds.set(++count);
    call Send.send(dest, sizeof(struct DiagMsg), &diag);

  }

  task void IdReadDone() {
    checkFlash();
    call Timer.start(TIMER_REPEAT, HWVERIFY_MSGRATE); 
    dbg(DBG_BOOT, ("MicaHWVerify initialized\n"));

  }

  command result_t StdControl.init() {
    struct DiagMsg *pack = (struct DiagMsg *)diag.data;
    count = 0;
    atomic gfSendBusy = FALSE;
    call Leds.init();

    pack->SPIFix = 0x5;
    pack->flashComm = 1;


    return SUCCESS;
  }

  event result_t HardwareId.readDone(uint8_t *id, result_t success) {
    struct DiagMsg *pack = (struct DiagMsg *)diag.data;
    if (!success) {
      int i;
      for (i = 0;i < HARDWARE_ID_LEN;i++)
	pack->serialId[i] = 0xff;
    }
    post IdReadDone();
    return SUCCESS;
  }

  command result_t StdControl.start() {
    struct DiagMsg *pack = (struct DiagMsg *)diag.data;

    call HardwareId.read(pack->serialId);

    return SUCCESS;
  }

  command result_t StdControl.stop() {
    return SUCCESS;
  }

  event result_t Send.sendDone(TOS_MsgPtr msg, result_t success) {
    atomic gfSendBusy = FALSE;
    return SUCCESS;
  }

  event result_t Timer.fired() {
    
    atomic {
      if (!gfSendBusy) {
	gfSendBusy = TRUE;
	post TimerTask();
      }
    }
    return SUCCESS;
  }

  event TOS_MsgPtr ReceiveMsg.receive(TOS_MsgPtr msg) {
    struct DiagMsg *pack = (struct DiagMsg *)diag.data;
    pack->rxTest = ((struct RxTestMsg *)msg->data)->value;
    return msg;
  }

  void checkFlash() {
    struct DiagMsg *pack = (struct DiagMsg *)diag.data;
    

    call FlashSelect.low();
    call FlashSPI.txByte(0x84);
    call FlashSPI.txByte(0x0);
    call FlashSPI.txByte(0x0);
    call FlashSPI.txByte(0x0);
    call FlashSPI.txByte(0x1);
    call FlashSPI.txByte(0x8f);
    call FlashSPI.txByte(0x9);
    call FlashSelect.high(FALSE);

    TOSH_uwait(100);

    call FlashSelect.low();
    call FlashSPI.txByte(0xD4);
    call FlashSPI.txByte(0x0);
    call FlashSPI.txByte(0x0);
    call FlashSPI.txByte(0x0);
    call FlashSPI.txByte(0x0);
    pack->flashCheck[0] = call FlashSPI.txByte(0x0);
    pack->flashCheck[1] = call FlashSPI.txByte(0x0);
    pack->flashCheck[2] = call FlashSPI.txByte(0x0);
    call FlashSelect.high(FALSE);

    
  }

  event result_t FlashSelect.notifyHigh() {
    return SUCCESS;
  }
}
