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

module MicaHighSpeedRadioM
{
  provides {
    interface StdControl as Control;
    interface TofListenControl;
    interface TofChirpControl;
    interface BareSendMsg as Send;
    interface ReceiveMsg as Receive;
  }
  uses {
    interface RadioEncoding as Code;
    interface Random;
    interface SpiByteFifo;
    interface ChannelMon;
    interface RadioTiming;
    interface MicInterrupt;
    interface StdControl as MicControl;
    interface StdControl as Sounder;
  }
}
implementation
{
  enum { //states
    IDLE_STATE,
    SEND_WAITING,
    RX_STATE,
    TRANSMITTING,
    WAITING_FOR_ACK,
    SENDING_STRENGTH_PULSE,
    TRANSMITTING_START,
    RX_DONE_STATE,
    ACK_SEND_STATE
  };

  enum {
    ACK_CNT = 4,
    ENCODE_PACKET_LENGTH_DEFAULT  = MSG_DATA_SIZE*3
  };


  //static char start[3] = {0xab, 0x34, 0xd5}; //10 Kbps
  //static char start[6] = {0xcc, 0xcf, 0x0f, 0x30, 0xf3, 0x33}; //20 Kbps
  // The C attribute is used here because we are not currently supporting
  // intialisers on module variables (because tossim makes it tricky)
  char TOSH_MHSR_start[12] __attribute((C)) = 
    {0xf0, 0xf0, 0xf0, 0xff, 0x00, 0xff, 0x0f, 0x00, 0xff, 0x0f, 0x0f, 0x0f}; //40 Kbps

  char state;
  char send_state;
  char tx_count;
  short calc_crc;
  uint8_t ack_count;
  char rec_count;
  TOS_Msg buffer;
  TOS_Msg* rec_ptr;
  TOS_Msg* send_ptr;
  unsigned char rx_count;
  char msg_length;
  char buf_head;
  char buf_end;
  char encoded_buffer[4];
  char enc_count;
  char decode_byte;
  char code_count;
  uint8_t sounderLength;
  uint8_t toneTimestampEnabled;

  short add_crc_byte(char new_byte, short crc);

  task void packetReceived(){
    TOS_MsgPtr tmp;
    state = IDLE_STATE;
    tmp = signal Receive.receive((TOS_Msg*)rec_ptr);
    if(tmp != 0) rec_ptr = tmp;
    call ChannelMon.startSymbolSearch();
  }

  task void packetSent(){
    send_state = IDLE_STATE;
    state = IDLE_STATE;
    signal Send.sendDone((TOS_MsgPtr)send_ptr, SUCCESS);
  }


  command result_t Send.send(TOS_MsgPtr msg) {
    if(send_state == IDLE_STATE){
      send_ptr = msg;
      send_state = SEND_WAITING;
      tx_count = 1;
      return call ChannelMon.macDelay();
    }else{
      return FAIL;
    }
  }

  /* Initialization of this component */
  command result_t Control.init() {
    rec_ptr = &buffer;
    send_state = IDLE_STATE;
    state = IDLE_STATE;
    sounderLength=0;
    toneTimestampEnabled=FALSE;
    call Sounder.init();
    return rcombine(call ChannelMon.init(), call Random.init());
    // TODO:  TOSH_RF_COMM_ADC_INIT();
  } 

  /* Command to control the power of the network stack */
  command result_t Control.start() {
    return SUCCESS;
  }

  /* Command to control the power of the network stack */
  command result_t Control.stop() {
    return SUCCESS;
  }



  // Handles the latest decoded byte propagated by the Byte Level component
  event result_t ChannelMon.startSymDetect() {
    uint16_t tmp;
    ack_count = 0;
    rec_count = 0;
    state = RX_STATE;
    tmp = call RadioTiming.getTiming();
    call SpiByteFifo.startReadBytes(tmp);
    msg_length = MSG_DATA_SIZE - 2;
    calc_crc = 0;
    rec_ptr->time = tmp;
    rec_ptr->toneTime = 0;
    rec_ptr->strength = 0;
    if(toneTimestampEnabled){
	call MicInterrupt.enable();
    }
    return SUCCESS;
  }


  event result_t ChannelMon.idleDetect() {
    if(send_state == SEND_WAITING){
      char first = ((char*)send_ptr)[0];
      buf_end = buf_head = 0;
      enc_count = 0;
      call Code.encode(first);
      rx_count = 0;
      msg_length = (unsigned char)(send_ptr->length) + MSG_DATA_SIZE - DATA_LENGTH - 2;
      send_state = IDLE_STATE;
      state = TRANSMITTING_START;
      call SpiByteFifo.send(TOSH_MHSR_start[0]);
      send_ptr->time = call RadioTiming.currentTime();
      calc_crc = add_crc_byte(first, 0x00);
      if(sounderLength>0){
	call Sounder.start();
      }
    }
    return 1;
  }

  event result_t Code.decodeDone(char data, char error){
    if(state == IDLE_STATE){
      return 0;
    }else if(state == RX_STATE){
      ((char*)rec_ptr)[(int)rec_count] = data;
      rec_count++;
      if(rec_count >= MSG_DATA_SIZE){
	// TODO:  TOSH_RF_COMM_ADC_GET_DATA(0);
	if(calc_crc == rec_ptr->crc){
	  rec_ptr->crc = 1;
	  if(rec_ptr->addr == TOS_LOCAL_ADDRESS ||
	     rec_ptr->addr == TOS_BCAST_ADDR){
	    call SpiByteFifo.send(0x55);
	  }
	}else{
	  rec_ptr->crc = 0;
	}
	state = ACK_SEND_STATE;
	return 0;
      }else if(rec_count <= MSG_DATA_SIZE-2){
	calc_crc = add_crc_byte(data, calc_crc);
      }
      if(rec_count == LENGTH_BYTE_NUMBER){
	if(((unsigned char)data) < DATA_LENGTH){
	  msg_length = ((unsigned char)data) + MSG_DATA_SIZE - DATA_LENGTH - 2;
	}
      }
      if(rec_count == msg_length){
	rec_count = MSG_DATA_SIZE-2;
      }
    }
    return SUCCESS;
  }

  event result_t Code.encodeDone(char data1){
    encoded_buffer[(int)buf_end] = data1;
    buf_end ++;
    buf_end &= 0x3;
    enc_count += 1;
    return SUCCESS;
  }

  event result_t SpiByteFifo.dataReady(uint8_t data) {
    if(state == TRANSMITTING_START){
      call SpiByteFifo.send(TOSH_MHSR_start[(int)tx_count]);
      tx_count ++;
      if(tx_count == sizeof(TOSH_MHSR_start)){
	state = TRANSMITTING;
	tx_count = 1;
      }
    }else if(state == TRANSMITTING){
      call SpiByteFifo.send(encoded_buffer[(int)buf_head]);
      buf_head ++;
      buf_head &= 0x3;
      enc_count --;
      //now check if that was the last byte.

      if(enc_count >= 2){
	;
      }else if(tx_count < MSG_DATA_SIZE){ 
	char next_data = ((char*)send_ptr)[(int)tx_count];
	call Code.encode(next_data);
	tx_count ++;
	if(tx_count>=sounderLength){
	  call Sounder.stop();
          sounderLength=0;
	}
	if(tx_count <= msg_length){
	  calc_crc = add_crc_byte(next_data, calc_crc);
	}
	if(tx_count == msg_length){
	  //the last 2 bytes must be the CRC and are
	  //transmitted regardless of the length.
	  tx_count = MSG_DATA_SIZE - 2;
	  send_ptr->crc = calc_crc;
	  call Sounder.stop();  //do it again just in case
          sounderLength=0;
       }
      }else if(buf_head != buf_end){
	call Code.encode_flush();
      }else{
	state = SENDING_STRENGTH_PULSE;
	tx_count = 0;
      }
    }else if(state == SENDING_STRENGTH_PULSE){
      tx_count ++;
      if(tx_count == 3){
	state = WAITING_FOR_ACK;
	call SpiByteFifo.phaseShift();
	tx_count = 1;
	call SpiByteFifo.send(0x00);
	
      }else{
	call SpiByteFifo.send(0xff);

      }
    }else if(state == WAITING_FOR_ACK){
      data &= 0x7f;
      call SpiByteFifo.send(0x00);
      if(tx_count == 1) 
	call SpiByteFifo.rxMode();
      tx_count ++;  
      if(tx_count == ACK_CNT + 2) {
	send_ptr->ack = (data == 0x55);
	state = IDLE_STATE;
	call SpiByteFifo.idle();
	call ChannelMon.startSymbolSearch();
	post packetSent();
      }
    }else if(state == RX_STATE){
      call Code.decode(data);
    }else if(state == ACK_SEND_STATE){
      ack_count ++;
      if(ack_count > ACK_CNT + 1){
	state = RX_DONE_STATE;
	call SpiByteFifo.idle();
	post packetReceived();
      }else{
	 call SpiByteFifo.txMode();
      }
    }
	
    return 1; 
  }

#if 0
  char SIG_STRENGTH_READING(short data){
    rec_ptr->strength = data;
    return 1;
  }
#endif


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

  command result_t TofChirpControl.enable(uint8_t lengthInBytes)
  {
	sounderLength=lengthInBytes;
	return SUCCESS;
  }

  command result_t TofChirpControl.disable()
  {
	sounderLength=0;
	return SUCCESS;
  }

  command result_t TofListenControl.enable()
  {
	toneTimestampEnabled=TRUE;
	call MicControl.start();
	return SUCCESS;
  }

  command result_t TofListenControl.disable()
  {
	toneTimestampEnabled=FALSE;
	call MicControl.stop();
	return SUCCESS;
  }

  event result_t MicInterrupt.toneDetected()
  {
	if(rec_ptr->toneTime-rec_ptr->time>700)//filter obvious false positives
		rec_ptr->toneTime = call RadioTiming.currentTime();
	return SUCCESS;
  }


}
