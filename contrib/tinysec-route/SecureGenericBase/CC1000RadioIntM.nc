// $Id: CC1000RadioIntM.nc,v 1.1 2003/12/03 02:53:33 ckarlof Exp $

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
 *  Authors: Philip Buonadonna, Jaein Jeong, Joe Polastre, Chris Karlof
 *  Date last modified: $Revision: 1.1 $
 *
 * This module provides the layer2 functionality for the mica2 radio.
 * While the internal architecture of this module is not CC1000 specific,
 * It does make some CC1000 specific calls via CC1000Control.
 *
 *
 * This makes use of TinySec. WARNING: Beware of using RadioCoordinators
 * with this stack. Length and group byte are switched.
 * 
 * $Id: CC1000RadioIntM.nc,v 1.1 2003/12/03 02:53:33 ckarlof Exp $
 */

/**
 * @author Philip Buonadonna
 * @author Jaein Jeong
 * @author Joe Polastre
 * @author Chris Karlof
 */

#define backoffBase 0
#define backoffMask 0

includes crc;
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
    interface RadioCoordinator as RadioSendCoordinator;
    interface RadioCoordinator as RadioReceiveCoordinator;
    interface TinySecRadio;
  }
  uses {
    interface PowerManagement;
    interface StdControl as CC1000StdControl;
    interface CC1000Control;
    interface Random;
    interface ADCControl;
    interface ADC as RSSIADC;
    interface SpiByteFifo;
    interface StdControl as TimerControl;
    interface Timer as WakeupTimer;
    // TinySec
    interface TinySec;
    interface Leds;
  }
}
implementation {
  enum {
    TX_STATE,
    DISABLED_STATE,
    IDLE_STATE,
    PRETX_STATE,
    SYNC_STATE,
    HEADER_RX_STATE,
    RX_STATE,
    RX_STATE_TINYSEC,
    POWER_DOWN_STATE,
  };

  enum {
    TXSTATE_WAIT,
    TXSTATE_START,
    TXSTATE_PREAMBLE,
    TXSTATE_SYNC,
    TXSTATE_DATA,
    TXSTATE_DATA_TINYSEC,
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
  /**** TinySec ****/
  TOS_Msg_TinySecCompat* txbufptr;  // pointer to transmit buffer
  TOS_Msg_TinySecCompat* rxbufptr;  // pointer to receive buffer
  TOS_Msg_TinySecCompat RxBuf;	// save received messages
  /**** TinySec ****/
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
  // and, thus doesn't need it.  HOWEVER, some set-mote-id versions
  // break if this symbol is missing from the binary.
  // Thus, I put this LocalAddr here and set it to TOS_LOCAL_ADDRESS
  // to keep things happy for now.
  volatile uint16_t LocalAddr;

  ///**********************************************************
  //* local function definitions
  //**********************************************************/

  /**** TinySec ****/
  void swapLengthAndGroup(TOS_Msg* buf) {
    uint8_t tmp = buf->group;

    ((TOS_Msg_TinySecCompat*) buf)->length = buf->length;
    ((TOS_Msg_TinySecCompat*) buf)->group = tmp;

  }
  /**** TinySec ****/
  
  task void PacketRcvd() {
    TOS_MsgPtr pBuf;

    atomic {
      rxbufptr->time = 0;
      /**** TinySec ****/
      pBuf = (TOS_MsgPtr) rxbufptr;
      swapLengthAndGroup(pBuf);
      /**** TinySec ****/
      // EWMA to determin squelch values
      usSquelchVal = (((5*pBuf->strength) + (3*usSquelchVal)) >> 3);
    }
    pBuf = signal Receive.receive((TOS_MsgPtr)pBuf);
    atomic {
      if (pBuf)
	rxbufptr = (TOS_Msg_TinySecCompat*) pBuf;
      rxbufptr->length = 0;
      //RadioState = IDLE_STATE;
    }
    call SpiByteFifo.enableIntr();
  }
  
  task void PacketSent() {
    TOS_MsgPtr pBuf; //store buf on stack 
    atomic {
      txbufptr->time = 0;
      pBuf = (TOS_Msg*) txbufptr;
      /**** TinySec ****/
      swapLengthAndGroup(pBuf);
      /**** TinySec ****/
    }
    signal Send.sendDone((TOS_MsgPtr)pBuf,SUCCESS);
    atomic bTxBusy = FALSE;
  }

  ///**********************************************************
  //* Exported interface functions
  //**********************************************************/
  
  command result_t StdControl.init() {
    bool temp;

    atomic {
      RadioState = DISABLED_STATE;
      RadioTxState = TXSTATE_PREAMBLE;
      rxbufptr = &RxBuf;
      rxbufptr->length = 0;
      rxlength = TINYSEC_MSG_DATA_SIZE-TINYSEC_MAC_LENGTH;
      RxBitOffset = 0;
      
      PreambleCount = 0;
      RSSISampleFreq = 0;
      RxShiftBuf.W = 0;
      bTxPending = FALSE;
      bTxBusy = FALSE;
      bRSSIValid = FALSE;
      sMacDelay = -1;
      usRSSIVal = -1;
      lplpower = lplpowertx = 0;
      usSquelchVal = PRG_RDB(&CC1K_LPL_SquelchInit[lplpower]);
    }

    call SpiByteFifo.initSlave(); // set spi bus to slave mode
    call CC1000StdControl.init();
    call CC1000Control.SelectLock(0x9);		// Select MANCHESTER VIOLATION
    temp = call CC1000Control.GetLOStatus();  //Do we need to invert Rcvd Data?
    atomic bInvertRxData = temp;

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
    uint8_t oldRadioState;
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
        oldRadioState = RadioState;
        if ((RadioState == IDLE_STATE) || (RadioState == POWER_DOWN_STATE)) {
          RadioState = DISABLED_STATE;
        }
      }

      // if successful, change power here
      if (oldRadioState == IDLE_STATE) {
	//RadioState = DISABLED_STATE;
	call StdControl.stop();
	call StdControl.start();
      }
      if (oldRadioState == POWER_DOWN_STATE) {
	//RadioState = DISABLED_STATE;
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
    uint8_t  oldRadioState;
    uint16_t sleeptime;
    bool bStayAwake;

    if (lplpower == 0)
      return SUCCESS;

    atomic {
      oldRadioState = RadioState;
      bStayAwake = bTxPending;
    }

    switch(oldRadioState) {
    case IDLE_STATE:
      sleeptime = ((PRG_RDB(&CC1K_LPL_SleepTime[lplpower*2]) << 8) |
		   PRG_RDB(&CC1K_LPL_SleepTime[(lplpower*2)+1]));
      if (!bStayAwake) {
        atomic RadioState = POWER_DOWN_STATE;
        call WakeupTimer.start(TIMER_ONE_SHOT, sleeptime);
        call CC1000StdControl.stop();
	call SpiByteFifo.disableIntr();
      }
      else {
        call WakeupTimer.start(TIMER_ONE_SHOT, CC1K_LPL_PACKET_TIME*2);
      }
      break;

    case POWER_DOWN_STATE:
      sleeptime = PRG_RDB(&CC1K_LPL_SleepPreamble[lplpower]);
      atomic RadioState = IDLE_STATE;
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
    return SUCCESS;
  }

  command result_t StdControl.start() {
    uint8_t chkRadioState;

    atomic chkRadioState = RadioState;

    if (chkRadioState == DISABLED_STATE) {
      atomic {
        rxbufptr->length = 0;
        RadioState  = IDLE_STATE;
        bTxPending = bTxBusy = FALSE;
        sMacDelay = -1;
        preamblelen = ((PRG_RDB(&CC1K_LPL_PreambleLength[lplpowertx*2]) << 8) |
                       PRG_RDB(&CC1K_LPL_PreambleLength[(lplpowertx*2)+1]));
      }
      if (lplpower == 0) {
        // all power on, captain!
        call CC1000StdControl.start();
        call CC1000Control.BIASOn();
        call SpiByteFifo.rxMode();		// SPI to miso
        call CC1000Control.RxMode();
        call SpiByteFifo.enableIntr(); // enable spi interrupt
      }
      else {
        uint16_t sleeptime = ((PRG_RDB(&CC1K_LPL_SleepTime[lplpower*2]) << 8) |
	                      PRG_RDB(&CC1K_LPL_SleepTime[(lplpower*2)+1]));
        atomic RadioState = POWER_DOWN_STATE;
        call TimerControl.start();
        call WakeupTimer.start(TIMER_ONE_SHOT, sleeptime);
      }
    }
    return SUCCESS;
  }

  /*** TinySec ****/
  async event result_t TinySec.sendDone(result_t result) {
    atomic {
      TxByteCnt = 0;
      RadioTxState = TXSTATE_FLUSH;
    }
    return result;
  }

  async event result_t TinySec.receiveInitDone(result_t result, uint16_t length,
					       bool ts_enabled) {
    atomic {
      rxlength = length;
      if(result == SUCCESS) {
        if(ts_enabled) 
          RadioState = RX_STATE_TINYSEC;
        else
          RadioState = RX_STATE;
      } else {
        rxbufptr->length = 0;
        RadioState = IDLE_STATE;
      }
    }
    return SUCCESS;
  }

  async event result_t TinySec.receiveDone(result_t result ) {
    if (!(post PacketRcvd())) {
      // If there are insufficient resources to process the incoming packet
      // we drop it
      atomic {
        RadioState = IDLE_STATE;
        rxbufptr->length = 0;
      }
      call SpiByteFifo.enableIntr();
    }
    
    return SUCCESS;
  }
  /**** TinySec ****/
  
  command result_t Send.send(TOS_MsgPtr pMsg) {
    result_t Result = SUCCESS;

    atomic {
      if (bTxBusy) {
	Result = FAIL;
      }
      else {
	bTxBusy = TRUE;
        /**** TinySec ****/
        // swap TOS_Msg into TOS_Msg_TinySecCompat
        // don't reference pMsg after here
        swapLengthAndGroup(pMsg);
	txbufptr = (TOS_Msg_TinySecCompat*) pMsg;
        /**** TinySec ****/
	// initially back off a message + [0,127] radio bytes
        sMacDelay = backoffBase + (call Random.rand() & backoffMask);
	bTxPending = TRUE;
        /****** TinySec *****/
	// bad form to call a command in atomic, but sendInit is short.
	// easiest way to lock txbufptr
	if(txbufptr->length & TINYSEC_ENABLED_BIT) {
	  txlength = call TinySec.sendInit(txbufptr);
	} else {
	  txlength = txbufptr->length + (MSG_DATA_SIZE - DATA_LENGTH - 2);
	}
        /****** TinySec *****/
      }
    }

    if (Result) {
      uint8_t tmpState;
      atomic tmpState = RadioState;
      // if we're off, start the radio
      if (tmpState == POWER_DOWN_STATE) {
        // disable wakeup timer
        call WakeupTimer.stop();
        call CC1000StdControl.start();
        call CC1000Control.BIASOn();
        call CC1000Control.RxMode();
        call SpiByteFifo.rxMode();		// SPI to miso
        call SpiByteFifo.enableIntr(); // enable spi interrupt
        call WakeupTimer.start(TIMER_ONE_SHOT, CC1K_LPL_PACKET_TIME*2);
        atomic RadioState = IDLE_STATE;
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

  async event result_t SpiByteFifo.dataReady(uint8_t data_in) {

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
          /**** TinySec ****/
          if(txbufptr->length & TINYSEC_ENABLED_BIT)
            RadioTxState = TXSTATE_DATA_TINYSEC;
          else
            RadioTxState = TXSTATE_DATA;
          /**** TinySec ****/
	  TxByteCnt = -1;
	  signal RadioSendCoordinator.startSymbol(); // for Time Sync
	  break;

	case TXSTATE_DATA:
	  if ((uint8_t)(TxByteCnt) < txlength) {
	    NextTxByte = ((uint8_t *)txbufptr)[(TxByteCnt)];
	    usRunningCRC = crcByte(usRunningCRC,NextTxByte);
	    signal RadioSendCoordinator.byte((TOS_MsgPtr) txbufptr,
					     (uint8_t)TxByteCnt); // Time Sync
	  }
	  else {
	    NextTxByte = (uint8_t)(usRunningCRC);
	    RadioTxState = TXSTATE_CRC;
	  }
	  break;

          /**** TinySec ****/
	case TXSTATE_DATA_TINYSEC:
          signal RadioSendCoordinator.byte((TOS_MsgPtr) txbufptr,
					   (uint8_t)TxByteCnt); // Time Sync
          NextTxByte = signal TinySecRadio.getTransmitByte();
	  break;
          /**** TinySec ****/
                  
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
            /**** TinySec ****/
            call TinySec.receiveInit(rxbufptr);
            /**** TinySec ****/
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
	  //sMacDelay = G_Config.backoffBase + (call Random.rand() & G_Config.backoffMask);
	  RadioState = IDLE_STATE;
	}
	else if (bRSSIValid) {
	  if (usRSSIVal > PRG_RDB(&CC1K_LPL_SquelchInit[lplpower])) {
	    // ROCK AND ROLL!!!!!
	    call CC1000Control.TxMode();
	    call SpiByteFifo.txMode();
	    TxByteCnt = 0;
	    usRunningCRC = 0;
	    RadioState = TX_STATE;
	    RadioTxState = TXSTATE_PREAMBLE;
	    NextTxByte = 0xaa;
	    call SpiByteFifo.writeByte(0xaa);
            // start encrypting packet - re-enables interrupts
            // check if encrypt enabled bit is set
            /**** TinySec ****/
            if(txbufptr->length & TINYSEC_ENABLED_BIT) {
              call TinySec.send();
            }
            /**** TinySec ****/
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
                if (rxbufptr->length !=0) {
		  RadioState = IDLE_STATE;
                }
                else {
                  RadioState = HEADER_RX_STATE;
                  call RSSIADC.getData();
                  RxBitOffset = 7-i;
                  signal RadioReceiveCoordinator.startSymbol(); // Time sync
                }
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
	}

      }
      break;

      /**** TinySec ****/
    case HEADER_RX_STATE:
      {
  	char Byte;
        
	RxShiftBuf.W <<=8;
	RxShiftBuf.LSB = data_in;
        
	Byte = (RxShiftBuf.W >> RxBitOffset);
	((char*)rxbufptr)[(int)RxByteCnt] = Byte;      
	RxByteCnt++;

	signal RadioReceiveCoordinator.byte((TOS_MsgPtr) rxbufptr,
					    (uint8_t)RxByteCnt);
        
        usRunningCRC = crcByte(usRunningCRC,Byte);
        signal TinySecRadio.byteReceived(Byte);
        
      }
      break;

      
    case RX_STATE_TINYSEC:
      {
	char Byte;

	RxShiftBuf.W <<=8;
	RxShiftBuf.LSB = data_in;

	Byte = (RxShiftBuf.W >> RxBitOffset);

	RxByteCnt++;

	signal RadioReceiveCoordinator.byte((TOS_MsgPtr) rxbufptr,
					    (uint8_t)RxByteCnt);
        
        if(RxByteCnt == rxlength + TINYSEC_MAC_LENGTH) {
	  call SpiByteFifo.disableIntr();
	  RadioState = IDLE_STATE;
	  rxbufptr->strength = usRSSIVal;
#if 0
	  if (bTxPending) {
	    sMacDelay = (((call Random.rand() & 0xf) +1 ) * (MSG_DATA_SIZE));
	  }
#endif    
        }        
        signal TinySecRadio.byteReceived(Byte);   
      }         
      break;
      /**** TinySec ****/
      
      
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

	signal RadioReceiveCoordinator.byte((TOS_MsgPtr) rxbufptr,
					    (uint8_t)RxByteCnt);
	
	if (RxByteCnt < rxlength) {
	  usRunningCRC = crcByte(usRunningCRC,Byte);
	}
	else if (RxByteCnt == rxlength) {
	  usRunningCRC = crcByte(usRunningCRC,Byte);
	  // Shift index ahead to the crc field.
	  RxByteCnt = offsetof(struct TOS_Msg,crc);
	}
	else if (RxByteCnt >= MSG_DATA_SIZE) { 

	  // Packet filtering based on bad CRC's is done at higher layers.
	  // So sayeth the TOS weenies.
	  if (rxbufptr->crc == usRunningCRC) {
	    rxbufptr->crc = 1;
	  }
	  else {
	    rxbufptr->crc = 0;
	  }

	  call SpiByteFifo.disableIntr();
	  
	  RadioState = IDLE_STATE; //DISABLED_STATE;
	  rxbufptr->strength = usRSSIVal;
	  if (!(post PacketRcvd())) {
	    // If there are insufficient resources to process the incoming packet
	    // we drop it
            rxbufptr->length = 0;
	    RadioState = IDLE_STATE;
	    call SpiByteFifo.enableIntr();
	  }

#if 0
	  if (bTxPending) {
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

async event result_t RSSIADC.dataReady(uint16_t data) {
  //rxbufptr->strength = data;
  atomic {
    usRSSIVal = data;
    bRSSIValid = TRUE;
  }
  return SUCCESS;
}

// Default events for radio send/receive coordinators do nothing.
// Be very careful using these, you'll break the stack.
default async event void RadioSendCoordinator.startSymbol() { }
default async event void RadioSendCoordinator.byte(TOS_MsgPtr msg, uint8_t byteCount) { }
default async event void RadioReceiveCoordinator.startSymbol() { }
default async event void RadioReceiveCoordinator.byte(TOS_MsgPtr msg, uint8_t byteCount) { }
}





