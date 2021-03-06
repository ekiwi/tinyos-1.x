// $Id: ReceiverCoordinatorM.nc,v 1.9 2006/05/18 19:58:40 chien-liang Exp $

/* Agilla - A middleware for wireless sensor networks.
 * Copyright (C) 2004, Washington University in Saint Louis 
 * By Chien-Liang Fok.
 * 
 * Washington University states that Agilla is free software; 
 * you can redistribute it and/or modify it under the terms of 
 * the current version of the GNU Lesser General Public License 
 * as published by the Free Software Foundation.
 * 
 * Agilla is distributed in the hope that it will be useful, but 
 * THERE ARE NO WARRANTIES, WHETHER ORAL OR WRITTEN, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO, IMPLIED WARRANTIES OF 
 * MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.
 *
 * YOU UNDERSTAND THAT AGILLA IS PROVIDED "AS IS" FOR WHICH NO 
 * WARRANTIES AS TO CAPABILITIES OR ACCURACY ARE MADE. THERE ARE NO 
 * WARRANTIES AND NO REPRESENTATION THAT AGILLA IS FREE OF 
 * INFRINGEMENT OF THIRD PARTY PATENT, COPYRIGHT, OR OTHER 
 * PROPRIETARY RIGHTS.  THERE ARE NO WARRANTIES THAT SOFTWARE IS 
 * FREE FROM "BUGS", "VIRUSES", "TROJAN HORSES", "TRAP DOORS", "WORMS", 
 * OR OTHER HARMFUL CODE.  
 *
 * YOU ASSUME THE ENTIRE RISK AS TO THE PERFORMANCE OF SOFTWARE AND/OR 
 * ASSOCIATED MATERIALS, AND TO THE PERFORMANCE AND VALIDITY OF 
 * INFORMATION GENERATED USING SOFTWARE. By using Agilla you agree to 
 * indemnify, defend, and hold harmless WU, its employees, officers and 
 * agents from any and all claims, costs, or liabilities, including 
 * attorneys fees and court costs at both the trial and appellate levels 
 * for any loss, damage, or injury caused by your actions or actions of 
 * your officers, servants, agents or third parties acting on behalf or 
 * under authorization from you, as a result of using Agilla. 
 *
 * See the GNU Lesser General Public License for more details, which can 
 * be found here: http://www.gnu.org/copyleft/lesser.html
 */

includes Agilla;
includes MigrationMsgs;

module ReceiverCoordinatorM {
  provides {
    interface StdControl;
    interface AgentReceiverI;  
    interface ReceiverCoordinatorI as CoordinatorI;
  } 
  uses {
    interface AgentMgrI;
    interface Timer as RecvTimeout0;
    interface Timer as RecvTimeout1;
    interface Timer as RecvTimeout2;
    interface Leds; // debug
  }
}
implementation {  
  /**
   * An array that holds bookeeping information about incomming agents.
   * This includes the number of code, heap, and operand stack
   * blocks, and the integrity of the agent.
   */
  AgillaAgentInfo inBuf[AGILLA_RCVR_BUFF_SIZE];  // holds the partial state of incomming agents;  
 
  /**
   * Memory allocated to store outgoing messages.
   */
  TOS_Msg _msg;  
  
  inline result_t rTimeout(uint8_t i);
  
  command result_t StdControl.init() {
    int i;
    for (i = 0; i < AGILLA_RCVR_BUFF_SIZE; i++) {
      inBuf[i].integrity = AGILLA_RECEIVED_NOTHING;
    }
    return SUCCESS;
  }

  command result_t StdControl.start() {
    return SUCCESS;
  }

  command result_t StdControl.stop() {
    return SUCCESS;
  } 

  /**
   * Returns the index of a the buffer holding the incomming
   * agent with the specified agent ID, or -1 if no buffer exists.
   */
  inline int getIndexOf(AgillaAgentID* id) 
  {
    int i;
    for (i = 0; i < AGILLA_RCVR_BUFF_SIZE; i++) {
      if (inBuf[i].integrity != AGILLA_RECEIVED_NOTHING &&
          inBuf[i].context->id.id == id->id)
        return i;
    }
    return -1;
  } // getIndexOf()
  
  /**
   * Cancels the timer associated with the specified agent.
   */
  command result_t CoordinatorI.stopTimer(AgillaAgentID* id) 
  {
    int i = getIndexOf(id);
    
    #if DEBUG_AGENT_RECEIVER
      dbg(DBG_USR1, "ReceiverCoordinatorM: CoordinatorI.stopTimer %i\n", i);
    #endif
    
    switch(i) {
      case 0:
        call RecvTimeout0.stop();
        break;
      case 1:
        call RecvTimeout1.stop();
        break;
      case 2:
        call RecvTimeout2.stop();
        break;
      default:
        return FAIL;        
    }
    return SUCCESS;
  } // stopTimer()

  /**
   * Starts the timer for aborting an incomming agent specified
   * by i.  If this timer fires and the incomming agent hasn't
   * completed arrived, message loss is assumed and the partial
   * agent data is discarded.
   */
  command result_t CoordinatorI.startAbortTimer(AgillaAgentID* id) 
  {
    int i = getIndexOf(id);
    
    #if DEBUG_AGENT_RECEIVER
      dbg(DBG_USR1, "ReceiverCoordinatorM: CoordinatorI.startAbortTimer %i\n", i);
    #endif
    
    switch(i) {
      case 0:
        call RecvTimeout0.start(TIMER_ONE_SHOT, AGILLA_RCVR_ABORT_TIMER);
        break;
      case 1:
        call RecvTimeout1.start(TIMER_ONE_SHOT, AGILLA_RCVR_ABORT_TIMER);
        break;
      case 2:
        call RecvTimeout2.start(TIMER_ONE_SHOT, AGILLA_RCVR_ABORT_TIMER);
        break;
      default:
        return FAIL;
    }
    return SUCCESS;
  } // startAbortTimer()

  /**
   * Starts a timer that ensures the agent has completely migrated
   * to this host.  If another message for the agent arrives during this
   * time, this FIN timer is restarted.  This ensures that the sender
   * received the last ACK.  Note that
   * AGILLA_RCVR_FIN_TIMER < AGILLA_SNDR_RXMIT_TIMER
   */
  command result_t CoordinatorI.startFinTimer(AgillaAgentID *id) 
  {
    int i = getIndexOf(id);
    
    /** The serial port is reliable enough to assume that the
        last acknowledgement is not lost **/
    if (inBuf[i].reply == TOS_UART_ADDR)
      return rTimeout(i);
      
    #if DEBUG_AGENT_RECEIVER
      dbg(DBG_USR1, "ReceiverCoordinatorM: CoordinatorI.startFinTimer %i\n", i);
    #endif
    
    switch(i) {
      case 0:
        call RecvTimeout0.start(TIMER_ONE_SHOT, AGILLA_RCVR_FIN_TIMER);
        break;
      case 1:
        call RecvTimeout1.start(TIMER_ONE_SHOT, AGILLA_RCVR_FIN_TIMER);
        break;
      case 2:
        call RecvTimeout2.start(TIMER_ONE_SHOT, AGILLA_RCVR_FIN_TIMER);
        break;
      default:
        return FAIL;        
    }
    return SUCCESS;
  } // startFinTimer()

  /**
   * Allocates a buffer for an incomming agent.  If no room is available,
   * return FAIL.
   *
   * @param id The incomming agent's ID.
   * @param codeSize The number of bytes of code the agent carries.
   * @return SUCCESS if the buffer was allocated, FAIL otherwise.
   */
  command result_t CoordinatorI.allocateBuffer(AgillaAgentID *id, 
    uint16_t codeSize) 
  {      
    int i;
    for (i = 0; i < AGILLA_RCVR_BUFF_SIZE; i++) 
    {
      if (inBuf[i].integrity == AGILLA_RECEIVED_NOTHING) 
      {
        inBuf[i].context = call AgentMgrI.getFreeContext(id, codeSize);
        if (inBuf[i].context != NULL)
        {
          inBuf[i].id = *id;
          inBuf[i].integrity = AGILLA_RECEIVED_STATE;
          return SUCCESS;
        } else
        {
          dbg(DBG_USR1, "ReceiverCoordinatorM: ERROR: Unable to allocate agent context.\n");
        }
      }
    }
    return FAIL;
  } // allocateBuffer()

  /**
   * Returns a pointer to the buffer holding the incomming
   * agent, or NULL if no such buffer exists.
   *
   * @param id The ID of the incomming agent.
   * @return The pointer.
   */
  command AgillaAgentInfo* CoordinatorI.getBuffer(AgillaAgentID *id) 
  {
    int i = getIndexOf(id);
    if (i != -1)
      return &inBuf[i];
    else
      return NULL;  
  }
   
  /**
   * Returns SUCCESS if the specified agent is arriving, FAIL 
   * otherwise.
   */
  command result_t CoordinatorI.isArriving(AgillaAgentID *id) 
  {
    int i = getIndexOf(id);
    return i != -1;
  }
  
  /**
   * Restarts the abort timer associated with the specified agent.
   */
  command result_t CoordinatorI.restartTimer(AgillaAgentID* id) 
  {  
    #if DEBUG_AGENT_RECEIVER
      dbg(DBG_USR1, "ReceiverCoordinatorM: CoordinatorI.restartTimer(): Restarting timer for agent %i\n", id->id);
    #endif    
    
    if (call CoordinatorI.stopTimer(id)) {
      if (call CoordinatorI.startAbortTimer(id))              
        return SUCCESS;    
    } 
    return FAIL;
  }
  
  /**
   * Frees up the buffer being used to store the partial state of the incomming
   * agent.  Also frees up the agent's context.
   */
  command result_t CoordinatorI.resetBuffer(AgillaAgentID* id) 
  {
    int i = getIndexOf(id);

    #if DEBUG_AGENT_RECEIVER
    dbg(DBG_USR1, "ReceiverCoordinatorM: CoordinatorI.resetBuffer(): Resettinng agent id %i\n", id->id);
    #endif    
    
    if (i != -1) {    
      inBuf[i].integrity = AGILLA_RECEIVED_NOTHING;
      call AgentMgrI.reset(inBuf[i].context);
      return SUCCESS;
    } else
      return FAIL;
  }
  
  /**
   * Handles a timeout.  If a timeout occurs during FIN mode,
   * start the agent.  Otherwise, clear the incomming buffer.
   */
  inline result_t rTimeout(uint8_t i)
  {      
    #if DEBUG_AGENT_RECEIVER
      dbg(DBG_USR1, "ReceiverCoordinatorM: rTimeout called.\n");
    #endif
    
    if (inBuf[i].integrity == AGILLA_AGENT_READY)  // in FIN mode
    { 
      inBuf[i].integrity = AGILLA_RECEIVED_NOTHING;  // Free up the buffer
      inBuf[i].context->state = AGILLA_STATE_READY;  // Start running the agent!      
      
      #if DEBUG_AGENT_RECEIVER
        dbg(DBG_USR1, "ReceiverCoordinatorM.rTimeout(%i): Received an agent with id %i!\n", i, inBuf[i].context->id.id);
      #endif
      inBuf[i].context->condition = 1;
      signal AgentReceiverI.receivedAgent(inBuf[i].context, inBuf[i].dest);      
    } else if (inBuf[i].integrity != AGILLA_RECEIVED_NOTHING) 
    {      

      #if DEBUG_AGENT_RECEIVER
        dbg(DBG_USR1, "ReceiverCoordinatorM: rTimeout(%i): agent timed out while arriving.\n", i);
      #endif        
      
      call AgentMgrI.reset(inBuf[i].context);
      inBuf[i].integrity = AGILLA_RECEIVED_NOTHING;  // timeout agent, clear resources
    }
    return SUCCESS;
  }
  
  event result_t RecvTimeout0.fired() { return rTimeout(0); }
  event result_t RecvTimeout1.fired() { return rTimeout(1); }
  event result_t RecvTimeout2.fired() { return rTimeout(2); }    
}
