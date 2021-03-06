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
 *  Authors: Philip Buonadonna, Jaein Jeong, Joe Polastre
 *  Date last modified: Revision: 1.13 
 *
 * This module provides the layer2 functionality for the mica2 radio.
 * While the internal architecture of this module is not CC1000 specific,
 * It does make some CC1000 specific calls via CC1000Control.
 * 
 * $Id: CC1000RadioIntM.nc,v 1.3 2003/06/09 18:27:01 mmaroti Exp $
 * TimeSync code added by Brano Kusy & Miklos Marioti, Vanderbilt University 
 * branislav.kusy@vanderbilt.edu, miklos.maroti@vanderbilt.edu
 */

// make this the default
#define VANDERBILT_TIMESYNC

#ifdef VANDERBILT_TIMESYNC
	includes TimeSyncMsg;
#endif
#ifdef VANDERBILT_TIMESYNC_DEBUGGER
	includes TestTimeSyncPollerMsg;
#endif

module CC1000RadioIntM {
  provides {
    interface StdControl;
    interface BareSendMsg as Send;
    interface ReceiveMsg as Receive;
    command result_t EnableRSSI();
    command result_t DisableRSSI();
    command result_t SetListeningMode(uint8_t power);
    command uint8_t GetListeningMode();
    command result_t SetTransmitMode(uint8_t power);
    command uint8_t GetTransmitMode();
  }
  uses {
      interface PowerManagement;
    interface StdControl as CC1000StdControl;
    interface CC1000Control;
    interface Random;
    interface ADCControl;
    interface ADC as RSSIADC;
    interface SpiByteFifo;
    //    interface SysTime;
    interface StdControl as TimerControl;
    interface Timer as WakeupTimer;
#ifdef VANDERBILT_TIMESYNC
	interface LocalTime;
#endif
  }
}
implementation {
  enum {
    TX_STATE,
    DISABLED_STATE,
    IDLE_STATE,
    PRETX_STATE,
    SYNC_STATE,
    RX_STATE,
    POWER_DOWN_STATE,
  };

  enum {
    TXSTATE_WAIT,
    TXSTATE_START,
    TXSTATE_PREAMBLE,
    TXSTATE_SYNC,
    TXSTATE_DATA,
    TXSTATE_CRC,
    TXSTATE_FLUSH,
    TXSTATE_DONE
  };

  enum {
    SYNC_BYTE =		0x33,
    NSYNC_BYTE =	0xcc,
    SYNC_WORD =		0x33cc,
    NSYNC_WORD =	0xcc33
  };

  uint8_t RadioState;
  uint8_t RadioTxState;
  uint16_t txlength;
  uint16_t rxlength;
  TOS_MsgPtr txbufptr;  // pointer to transmit buffer
  TOS_MsgPtr rxbufptr;  // pointer to receive buffer
  TOS_Msg RxBuf;	// save received messages
  uint8_t NextTxByte;

  uint8_t lplpower;        //  low power listening mode
  uint8_t lplpowertx;      //  low power listening transmit mode

  uint16_t preamblelen;    //  current length of the preamble
 
  uint16_t PreambleCount;   //  found a valid preamble
  uint8_t SOFCount;
  union {
    uint16_t W;
    struct {
      uint8_t LSB;
      uint8_t MSB;
    };
  } RxShiftBuf;
  uint8_t RxBitOffset;	// bit offset for spibus
  uint16_t RxByteCnt;	// received byte counter
  uint16_t TxByteCnt;
  uint16_t RSSISampleFreq; // in Bytes rcvd per sample
  bool bInvertRxData;	// data inverted
  bool bTxPending;
  bool bTxBusy;
  bool bRSSIValid;
  uint16_t usRunningCRC; // Running CRC variable
  uint16_t usRSSIVal;
  uint16_t usSquelchVal;
  int16_t sMacDelay;    // MAC delay for the next transmission
  // XXX-PB:
  // Here's the deal, the mica (RFM) radio stacks used TOS_LOCAL_ADDRESS
  // to determine if an L2 ack was reqd.  This stack doesn't do L2 acks
  // and, thus doesn't need it.  HOWEVER, set-mote-id breaks if it 
  // compiles a program that doesn't have the symbol TOS_LOCAL_ADDRESS in
  // the binary.  This occurs in programs such as GenericBase.
  // Thus, I put this LocalAddr here and set it to TOS_LOCAL_ADDRESS
  // to keep things happy for now.
  volatile uint16_t LocalAddr;

#ifdef VANDERBILT_TIMESYNC
    uint32_t timeStamp;	// used for both sending and receiving messages

    // one bit is 1.65 jiffy, 49 jiffy offset between tx sync and rx data
    // magic number for bitOffset 0. - this worked only for 1.2 version of this file
    //int8_t bitOffset2jiffy[8] __attribute__((C)) = { 56, 51, 52, 54, 56, 57, 59, 61 };
	int8_t bitOffset2jiffy[8] __attribute__((C)) = { 45, 47, 48, 50, 52, 53, 55, 58 };
#endif

  ///**********************************************************
  //* local function definitions
  //**********************************************************/

  task void PacketRcvd() {
    TOS_MsgPtr pBuf;
    //    call SysTime.get(&ulSysTime.L);
    atomic {
	rxbufptr->time = 0;//ulSysTime.LSW;
      pBuf = rxbufptr;
      // EWMA to determin squelch values
      usSquelchVal = (((5*rxbufptr->strength) + (3*usSquelchVal)) >> 3);
    }
#ifdef VANDERBILT_TIMESYNC
	if (rxbufptr->type == AM_TIMESYNCMSG)
		((TimeSyncMsg*)(rxbufptr->data))->arrivalTime = timeStamp;
#endif
#ifdef VANDERBILT_TIMESYNC_DEBUGGER
	else if (rxbufptr->type == AM_TIMESYNCPOLL)
		((TimeSyncPoll*)(rxbufptr->data))->arrivalTime = timeStamp;
#endif
    pBuf = signal Receive.receive((TOS_MsgPtr)pBuf);
    atomic {
      if (pBuf) 
	rxbufptr = pBuf;
      RadioState = IDLE_STATE;
    }
    call SpiByteFifo.enableIntr();
  }
  
  task void PacketSent() {
    TOS_MsgPtr pBuf; //store buf on stack 
    //    call SysTime.get(&ulSysTime.L);
    atomic {
	txbufptr->time = 0;//ulSysTime.LSW;
      pBuf = txbufptr;
    }
// VANDY: set busy FALSE before signaling, this allows RadioSuspend.suspend from sendDone
    atomic bTxBusy = FALSE;
    signal Send.sendDone((TOS_MsgPtr)pBuf,SUCCESS);
  }

  short add_crc_byte(char new_byte, short crc){
    uint8_t i;
    crc = crc ^ (int) new_byte << 8;
    i = 8;
    do
      {
	if (crc & 0x8000)
	  crc = crc << 1 ^ 0x1021;
	else
	  crc = crc << 1;
      } while(--i);
    return crc;
  }


  ///**********************************************************
  //* Exported interface functions
  //**********************************************************/
  
  command result_t StdControl.init() {

    atomic {
      RadioState = DISABLED_STATE;
      RadioTxState = TXSTATE_PREAMBLE;
      rxbufptr = &RxBuf;
      rxlength = MSG_DATA_SIZE-2;
      RxBitOffset = 0;
      
      PreambleCount = 0;
      RSSISampleFreq = 0;
      RxShiftBuf.W = 0;
      bTxPending = FALSE;
      bTxBusy = FALSE;
      bRSSIValid = FALSE;
      sMacDelay = -1;
      usRSSIVal = -1;
      usSquelchVal = PRG_RDB(&CC1K_LPL_SquelchInit);
      lplpower = lplpowertx = 0;
    }

    //    call SysTime.init();
    call SpiByteFifo.initSlave(); // set spi bus to slave mode
    call CC1000StdControl.init();
    call CC1000Control.SelectLock(0x9);		// Select MANCHESTER VIOLATION
    bInvertRxData = call CC1000Control.GetLOStatus();  //Do we need to invert Rcvd Data?

    call ADCControl.bindPort(TOS_ADC_CC_RSSI_PORT,TOSH_ACTUAL_CC_RSSI_PORT);
    call ADCControl.init();

    call Random.init();
    call TimerControl.init();

    // don't enable SPI interrupts until the radio is running
    //call SpiByteFifo.enableIntr(); // enable spi and spi interrupt
 
    LocalAddr = TOS_LOCAL_ADDRESS;

    return SUCCESS;
  }
  

  command result_t EnableRSSI() {

    return SUCCESS;
  }

  command result_t DisableRSSI() {

    return SUCCESS;
  }

  command uint8_t GetTransmitMode() {
     return lplpowertx;
  }

  /**
   * Set the state of low power transmit on the chipcon radio.
   * The transmit mode of the sender *must* match the receiver in
   * order for the receiver to successfully get the packet.
   * <p>
   * The default power up state is 0 (radio always on).
   * See CC1000Const.h for low power duty cycles and bandwidth
   */
  command result_t SetTransmitMode(uint8_t power) {
     if ((power >= CC1K_LPL_STATES) || (power == lplpowertx))
	return FAIL;

     // check if the radio is currently doing something
     if ((!bTxPending) && ((RadioState == POWER_DOWN_STATE) || 
         (RadioState == IDLE_STATE) ||
         (RadioState == DISABLED_STATE))) {

         atomic {
         lplpowertx = power;
         preamblelen = ((PRG_RDB(&CC1K_LPL_PreambleLength[lplpowertx*2]) << 8)
                       | PRG_RDB(&CC1K_LPL_PreambleLength[(lplpowertx*2)+1]));
         }
         return SUCCESS;
     }
     return FAIL;
  }

  /**
   * Set the state of low power listening on the chipcon radio.
   * <p>
   * The default power up state is 0 (radio always on).
   * See CC1000Const.h for low power duty cycles and bandwidth
   */
  command result_t SetListeningMode(uint8_t power) {
     // valid low power listening values are 0 to 3
     // 0 is "always on" and 3 is lowest duty cycle
     // 1 and 2 are in the middle
     if ((power >= CC1K_LPL_STATES) || (power == lplpower))
	return FAIL;

     // check if the radio is currently doing something
     if ((!bTxPending) && ((RadioState == POWER_DOWN_STATE) || 
         (RadioState == IDLE_STATE) ||
         (RadioState == DISABLED_STATE))) {

       // change receiving function in CC1000Radio
       call WakeupTimer.stop();
       atomic {
         if (lplpower == lplpowertx) {
           lplpowertx = power;
         }
         lplpower = power;
       }

       // if successful, change power here
       if (RadioState == IDLE_STATE) {
         RadioState = DISABLED_STATE;
         call StdControl.stop();
         call StdControl.start();
       }
       if (RadioState == POWER_DOWN_STATE) {
         RadioState = DISABLED_STATE;
         call StdControl.start();
	 call PowerManagement.adjustPower();
       }
     }
     else {
       return FAIL;
     }
     return SUCCESS;
  }

  /**
   * Gets the state of low power listening on the chipcon radio.
   * <p>
   * @return Current low power listening state value
   */
  command uint8_t GetListeningMode() {
    return lplpower;
  } 

  event result_t WakeupTimer.fired() {
    uint16_t sleeptime;
    if (lplpower == 0)
	return SUCCESS;

    switch(RadioState) {
    case IDLE_STATE:
      sleeptime = ((PRG_RDB(&CC1K_LPL_SleepTime[lplpower*2]) << 8) |
	                      PRG_RDB(&CC1K_LPL_SleepTime[(lplpower*2)+1]));
      if (!bTxPending) {
        RadioState = POWER_DOWN_STATE;
        call CC1000StdControl.stop();
	call SpiByteFifo.disableIntr();
        call WakeupTimer.start(TIMER_ONE_SHOT, sleeptime);
      }
      else {
        call WakeupTimer.start(TIMER_ONE_SHOT, CC1K_LPL_PACKET_TIME*2);
      }
      break;

    case POWER_DOWN_STATE:
      sleeptime = PRG_RDB(&CC1K_LPL_SleepPreamble[lplpower]);
      RadioState = IDLE_STATE;
      call CC1000StdControl.start();
      call CC1000Control.BIASOn();
      call SpiByteFifo.rxMode();		// SPI to miso
      call CC1000Control.RxMode();
      call SpiByteFifo.enableIntr(); // enable spi interrupt
      call WakeupTimer.start(TIMER_ONE_SHOT, sleeptime);
      break;

    default:
      call WakeupTimer.start(TIMER_ONE_SHOT, CC1K_LPL_PACKET_TIME*2);
    }
    return SUCCESS;
  }

  command result_t StdControl.stop() {
    atomic RadioState = DISABLED_STATE;

    call WakeupTimer.stop();
    call CC1000StdControl.stop();
    call SpiByteFifo.disableIntr(); // disable spi interrupt
// VANDY: This is needed for radio suspend
    if (bTxBusy) {
      atomic bTxBusy = FALSE;
      signal Send.sendDone((TOS_MsgPtr)txbufptr, FAIL);
    }

    return SUCCESS;
  }

  command result_t StdControl.start() {

    if (RadioState == DISABLED_STATE) {
      atomic {
        RadioState  = IDLE_STATE;
        bTxPending = bTxBusy = FALSE;
        sMacDelay = -1;
      }
      preamblelen = ((PRG_RDB(&CC1K_LPL_PreambleLength[lplpowertx*2]) << 8) |
	              PRG_RDB(&CC1K_LPL_PreambleLength[(lplpowertx*2)+1]));
      if (lplpower == 0) {
        // all power on, captain!
        RadioState = IDLE_STATE;
        call CC1000StdControl.start();
        call CC1000Control.BIASOn();
        call SpiByteFifo.rxMode();		// SPI to miso
        call CC1000Control.RxMode();
        call SpiByteFifo.enableIntr(); // enable spi interrupt
      }
      else {
        uint16_t sleeptime = ((PRG_RDB(&CC1K_LPL_SleepTime[lplpower*2]) << 8) |
	                      PRG_RDB(&CC1K_LPL_SleepTime[(lplpower*2)+1]));
        RadioState = POWER_DOWN_STATE;
        call TimerControl.start();
        call WakeupTimer.start(TIMER_ONE_SHOT, sleeptime);
      }
    }
    return SUCCESS;
  }

  command result_t Send.send(TOS_MsgPtr pMsg) {
    result_t Result = SUCCESS;

    atomic {
// VANDY: This is needed for radio suspend
      if (bTxBusy || RadioState == DISABLED_STATE) {
	Result = FAIL;
      }
      else {
	bTxBusy = TRUE;
	txbufptr = pMsg;
	txlength = pMsg->length + (MSG_DATA_SIZE - DATA_LENGTH - 2); 
	// initially back off a message + [0,95] radio bytes
        sMacDelay = MSG_DATA_SIZE + (call Random.rand() & 0x5F);
//	sMacDelay = MSG_DATA_SIZE;
	bTxPending = TRUE;
      }
    }

    if (Result) {

      // if we're off, start the radio
      if (RadioState == POWER_DOWN_STATE) {
        // disable wakeup timer
        call WakeupTimer.stop();
        call CC1000StdControl.start();
        call CC1000Control.BIASOn();
        call CC1000Control.RxMode();
        call SpiByteFifo.rxMode();		// SPI to miso
        call SpiByteFifo.enableIntr(); // enable spi interrupt
        call WakeupTimer.start(TIMER_ONE_SHOT, CC1K_LPL_PACKET_TIME*2);
        RadioState = IDLE_STATE;
      }
    }

    return Result;
  }
  
  /**********************************************************
   * make a spibus interrupt handler
   * needs to handle interrupts for transmit delay
   * and then go into byte transmit mode with
   *   timer1 baudrate delay as interrupt handler
   * else
   * needs to handle interrupts for byte read and detect preamble
   *  then handle reading a packet
   * PB - We can use this interrupt handler as a transmit scheduler
   * because the CC1000 continuously clocks in data, regarless
   * of whether it's good or not.  Thus, this routine will be called
   * on every 8 ticks of DCLK. 
   **********************************************************/

  event result_t SpiByteFifo.dataReady(uint8_t data_in) {

    if (bInvertRxData) 
      data_in = ~data_in;
#ifdef ENABLE_UART_DEBUG
    UARTPutChar(RadioState);
#endif
    switch (RadioState) {

    case TX_STATE:
      {
	call SpiByteFifo.writeByte(NextTxByte);
	TxByteCnt++;
	switch (RadioTxState) {

	case TXSTATE_PREAMBLE:
	  if (!(TxByteCnt < preamblelen)) {
	    NextTxByte = SYNC_BYTE;
	    RadioTxState = TXSTATE_SYNC;
	  }
	  break;

	case TXSTATE_SYNC:
	  NextTxByte = NSYNC_BYTE;
	  RadioTxState = TXSTATE_DATA;
	  TxByteCnt = -1;
#ifdef VANDERBILT_TIMESYNC
	  if (txbufptr->type == AM_TIMESYNCMSG){
	    timeStamp = call LocalTime.read();
	    ((TimeSyncMsg *)txbufptr->data)->sendingTime += timeStamp;
	  }
#endif
	  break;

	case TXSTATE_DATA:
	  if ((uint8_t)(TxByteCnt) < txlength) {
	    NextTxByte = ((uint8_t *)txbufptr)[(TxByteCnt)];
	    usRunningCRC = add_crc_byte(NextTxByte,usRunningCRC);
	  }
	  else {
	    NextTxByte = (uint8_t)(usRunningCRC);
	    RadioTxState = TXSTATE_CRC;
	  }
	  break;

	case TXSTATE_CRC:
	  NextTxByte = (uint8_t)(usRunningCRC>>8);
	  RadioTxState = TXSTATE_FLUSH;
	  TxByteCnt = 0;
	  break;

	case TXSTATE_FLUSH:
	  if (TxByteCnt > 3) {
	    RadioTxState = TXSTATE_DONE;
	  }
	  break;

	case TXSTATE_DONE:
	default:
	  call SpiByteFifo.rxMode();
	  call CC1000Control.RxMode();
	  bTxPending = FALSE;
	  if (post PacketSent()) {
	    // If the post operation succeeds, goto Idle
	    // otherwise, we'll try again.
	    RadioState = IDLE_STATE;
	  }
	  break;
	}
      }
      break;

    case DISABLED_STATE:
      break;

    case IDLE_STATE: 
      {
	if (((data_in == (0xaa)) || (data_in == (0x55)))) {
	  PreambleCount++;
	  if (PreambleCount > PRG_RDB(&CC1K_LPL_ValidPrecursor[lplpower])) {
	    PreambleCount = SOFCount = 0;
	    RxBitOffset = RxByteCnt = 0;
	    usRunningCRC = 0;
	    rxlength = MSG_DATA_SIZE-2;
	    RadioState = SYNC_STATE;
	  }
	}
	else if (bTxPending && (--sMacDelay <= 0)) {
	  bRSSIValid = FALSE;
	  call RSSIADC.getData();
	  PreambleCount = 0;
	  RadioState = PRETX_STATE;
#if 0
	  call CC1000Control.TxMode();
	  call SpiByteFifo.txMode();
	  TxByteCnt = 0;
	  usRunningCRC = 0;
	  RadioState = TX_STATE;
	  RadioTxState = TXSTATE_PREAMBLE;
	  NextTxByte = 0xaa;
	  call SpiByteFifo.writeByte(0xaa);
#endif
	}
      }
      break;

    case PRETX_STATE:
      {
	if (((data_in == (0xaa)) || (data_in == (0x55)))) {
	  // Back to the penalty box.
	  sMacDelay = (((call Random.rand() & 0xf) + 1) * (MSG_DATA_SIZE));
	  RadioState = IDLE_STATE;
	}
	else if (bRSSIValid) {
	  if (usRSSIVal > PRG_RDB(&CC1K_LPL_SquelchInit)) {
	    // ROCK AND ROLL!!!!!
	    call CC1000Control.TxMode();
	    call SpiByteFifo.txMode();
	    TxByteCnt = 0;
	    usRunningCRC = 0;
	    RadioState = TX_STATE;
	    RadioTxState = TXSTATE_PREAMBLE;
	    NextTxByte = 0xaa;
	    call SpiByteFifo.writeByte(0xaa);
	  }
	  else {
	    // Russin frussin freakin frick o frack
	    sMacDelay = (((call Random.rand() & 0xf) + 1) * (MSG_DATA_SIZE));
	    RadioState = IDLE_STATE;
	  }
	}
      }
      break;

    case SYNC_STATE:
      {
	// draw in the preamble bytes and look for a sync byte
	// save the data in a short with last byte received as msbyte
	//    and current byte received as the lsbyte.
	// use a bit shift compare to find the byte boundary for the sync byte
	// retain the shift value and use it to collect all of the packet data
	// check for data inversion, and restore proper polarity XXX-PB: Don't do this.
	uint8_t i;

	if ((data_in == 0xaa) || (data_in == 0x55)) {
	  // It is actually possible to have the LAST BIT of the incoming
	  // data be part of the Sync Byte.  SO, we need to store that
	  // However, the next byte should definitely not have this pattern.
	  // XXX-PB: Do we need to check for excessive preamble?
	  RxShiftBuf.MSB = data_in;
	
	}
	else {
	  // TODO: Modify to be tolerant of bad bits in the preamble...
	  uint16_t usTmp;
	  switch (SOFCount) {
	  case 0:
	    RxShiftBuf.LSB = data_in;
	    break;
	  
	  case 1:
	  case 2: 
	    // bit shift the data in with previous sample to find sync
	    usTmp = RxShiftBuf.W;
	    RxShiftBuf.W <<= 8;
	    RxShiftBuf.LSB = data_in;

	    for(i=0;i<8;i++) {
	      usTmp <<= 1;
	      if(data_in & 0x80)
		usTmp  |=  0x1;
	      data_in <<= 1;
	      // check for sync bytes
	      if (usTmp == SYNC_WORD) {
		RadioState = RX_STATE;
		call RSSIADC.getData();
		RxBitOffset = 7-i;
		break;
	      }
#if 0
	      else if (usTmp == NSYNC_WORD) {
		RadioState = RX_STATE;
		RxBitOffset = 7-i;
		bInvertRxData = TRUE;
		break;
	      }
#endif
	    }
	    break;

	  default:
	    // We didn't find it after a reasonable number of tries, so....
	    RadioState = IDLE_STATE;  // Ensures we wait till the end of the transmission
	    break;
	  }
	  SOFCount++;
#ifdef VANDERBILT_TIMESYNC
	  if (RadioState==RX_STATE) {
	      timeStamp = call LocalTime.read();
	      timeStamp -= bitOffset2jiffy[RxBitOffset];
	  }
#endif
	}

      }
      break;
      //  collect the data and shift into double buffer
      //  shift out data by correct offset
      //  invert the data if necessary
      //  stop after the correct packet length is read
      //  return notification to upper levels
      //  go back to idle state
    case RX_STATE:
      {
	char Byte;

	RxShiftBuf.W <<=8;
	RxShiftBuf.LSB = data_in;

	Byte = (RxShiftBuf.W >> RxBitOffset);
	((char*)rxbufptr)[(int)RxByteCnt] = Byte;
	RxByteCnt++;

	if (RxByteCnt < rxlength) {
	  usRunningCRC = add_crc_byte(Byte,usRunningCRC);

	  if (RxByteCnt == (offsetof(struct TOS_Msg,length) + 
			    sizeof(((struct TOS_Msg *)0)->length))) {
	    rxlength = rxbufptr->length;
	    if (rxlength > TOSH_DATA_LENGTH) {
	      // The packet's screwed up, so just dump it
	      RadioState = IDLE_STATE;  // Waits till end of transmission
	      return SUCCESS;
	    }
	    //Add in the header size
	    rxlength += offsetof(struct TOS_Msg,data);
	  }
	}
	else if (RxByteCnt == rxlength) {
	  usRunningCRC = add_crc_byte(Byte,usRunningCRC);
	  // Shift index ahead to the crc field.
	  RxByteCnt = offsetof(struct TOS_Msg,crc);
	}
	else if (RxByteCnt >= MSG_DATA_SIZE) { 
	  
	  if (rxbufptr->crc == usRunningCRC) {
	    //rxbufptr = signal Receive.receive((TOS_Msg*)rxbufptr); // signal rfcomm
	    call SpiByteFifo.disableIntr();

	    RadioState = DISABLED_STATE;
	    rxbufptr->strength = usRSSIVal;
	    if (!(post PacketRcvd())) {
	      // If there are insufficient resources to process the incoming packet
	      // we drop it
	      RadioState = IDLE_STATE;
	      call SpiByteFifo.enableIntr();
	    }
	  }
	  else {
	    RadioState = IDLE_STATE;
	  }
#if 0
	  if (bTxPending) {
	    //sMacDelay = ((call Random.rand() & 0x3ff) + (MSG_DATA_SIZE/8));// >> 3;
	    sMacDelay = (((call Random.rand() & 0xf) +1 ) * (MSG_DATA_SIZE));
	  }
#endif
	}
      }

      break;
	  
    default:
      break;
    }
#if 0
    // Sample the RSSI value at least twice the maximum possible packet rate
    // The maximum message rate will be the total number of bytes per packet including
    // the preamble, sync, TOS_Msg header, 1 byte payload and CRC.  
    // Divide that sum by two to sample at double the packet rate.
    RSSISampleFreq++; 
    RSSISampleFreq %= (preamblelen + 2 + offsetof(struct TOS_Msg,data) + 3) >> 1);
    if ((RSSISampleFreq == 0) && (bTxPending || (RadioState == RX_STATE))) {
      call RSSIADC.getData();
    }
#endif
    return SUCCESS;
  }

  event result_t RSSIADC.dataReady(uint16_t data) {
    //rxbufptr->strength = data;
    usRSSIVal = data;
    bRSSIValid = TRUE;
    return SUCCESS;
  }
}





