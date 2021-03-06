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
 * Authors:  Dmitriy Korovkin
 *           LUXOFT Inc.
 * Date:     10/7/2003
 *
 * $Id: ChanQM.nc,v 1.2 2003/12/26 11:38:46 korovkin Exp $
 */
/*
 * Module provides the channel quality information collection from
 * various sources and sending it over the network
 */
includes ChanQ;

// debug mode to be used for this module
#define DBG_CQ DBG_USR1

module ChanQM
{
  provides
  {
    interface StdControl;
    interface Send as SndData[uint8_t id];
    interface Receive as RecvRequest[uint8_t id];
  }
  uses
  {
    interface Send[uint8_t id];
    interface Receive[uint8_t id];
    interface Intercept[uint8_t id];
    command result_t gimme(ChanQMsg* data);
  }
}

implementation
{
  /*
   * StdControl interface functions
   */
  command result_t StdControl.init()
  {
    return SUCCESS; 
  }

  command result_t StdControl.start()
  {
    return SUCCESS; 
  }

  command result_t StdControl.stop()
  {
    return SUCCESS; 
  }

  /*
   * Intercept interface functions
   */
  event result_t Intercept.intercept[uint8_t id](TOS_MsgPtr msg, void* payload, 
    uint16_t payloadLen)
  {
    ChanQMsg* pCQMsg = (ChanQMsg*)payload; 
    uint16_t localAddress; //local address variable
    
    atomic
    {
      localAddress = TOS_LOCAL_ADDRESS;
    }

    if (pCQMsg->addr == localAddress)
      return FAIL;
      
    dbg(DBG_CQ, "CQ: Forward message %p %d: %d -> %d\n",
     msg, pCQMsg->cnt, pCQMsg->addr, pCQMsg->id);

    return SUCCESS;
  }

  /*
   * Send interface functions
   */
  event result_t Send.sendDone[uint8_t id](TOS_MsgPtr msg, result_t success)
  {
    if (success != SUCCESS)
    {
      dbg(DBG_CQ, "CQ: Message sending FAILED\n");
    }
    else
    {
      dbg(DBG_CQ, "CQ: Message sending OK\n");
    }
    return success;
  }

 /*
  * Receive interface functions
  */
  event TOS_MsgPtr Receive.receive[uint8_t id](TOS_MsgPtr msg, void* payload, 
    uint16_t payloadLen)
  {
    ChanQMsg* pCQMsg = (ChanQMsg*)payload; 
    call gimme(pCQMsg);
    return signal RecvRequest.receive[id](msg, payload, payloadLen);
  }

  /*
   * default gimme command implementation
   */
  default  command result_t gimme(ChanQMsg* data)
  {
    return FAIL;
  }

  /*
   * SndData interface functions
   */
  command result_t SndData.send[uint8_t id](TOS_MsgPtr msg, 
    uint16_t length)
  {
    return call Send.send[id](msg, length);
  }
  
  command void* SndData.getBuffer[uint8_t id](TOS_MsgPtr msg, 
    uint16_t* length)
  {
    return call Send.getBuffer[id](msg, length);
  }

  default event result_t SndData.sendDone[uint8_t id](TOS_MsgPtr msg, 
    result_t success)
  {
    return SUCCESS;
  }

  /* 
   * RecvRequest interface functions
   */
  default event TOS_MsgPtr RecvRequest.receive[uint8_t id](TOS_MsgPtr msg, 
    void* payload, uint16_t payloadLen)
  {
    return msg;
  }
  /*
   * Send interface default funxctions
   */
  default command result_t Send.send[uint8_t id](TOS_MsgPtr msg, uint16_t length)
  {
    return FAIL; //Sure, we didn't send anything
  }
  
  default command void* Send.getBuffer[uint8_t id](TOS_MsgPtr msg, uint16_t* length)
  {
    //FIXME: better ideas?
    *length = TOSH_DATA_LENGTH;
    return msg->data;
  }
}

//eof
