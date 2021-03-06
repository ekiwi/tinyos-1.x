// $Id: ReceiverCoordinatorI.nc,v 1.3 2006/05/18 19:58:40 chien-liang Exp $

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

interface ReceiverCoordinatorI {

  /**
   * Returns SUCCESS if the specified agent is arriving, FAIL 
   * otherwise.
   */
  command result_t isArriving(AgillaAgentID *id);
  
  /**
   * Allocates a buffer for an incomming agent.   
   *
   * @param id The incomming agent's ID.
   * @param codeSize The number of bytes of code the agent carries.
   */
  command result_t allocateBuffer(AgillaAgentID *id, uint16_t codeSize);

  /**
   * Frees up the buffer being used to store the partial state of the incomming
   * agent.  Also frees up the agent's context.
   */  
  command result_t resetBuffer(AgillaAgentID* id);

  /**
   * Returns a pointer to the buffer holding the incomming
   * agent, or NULL if no such buffer exists.
   *
   * @param id The ID of the incomming agent.
   * @return The pointer.
   */
  command AgillaAgentInfo* getBuffer(AgillaAgentID *id);
  
  /**
   * Restarts the abort timer associated with the 
   * specified agent.
   */
  command result_t restartTimer(AgillaAgentID* id);
  
  /**
   * Starts the timer for aborting an incomming agent specified
   * by i.  If this timer fires and the incomming agent hasn't
   * completed arrived, message loss is assumed and the partial
   * agent data is discarded.
   */
  command result_t startAbortTimer(AgillaAgentID* id);

  /**
   * Starts a timer that ensures the agent has completely migrated
   * to this host.  If another message for the agent arrives during this
   * time, this FIN timer is restarted.  This ensures that the sender
   * received the last ACK.  Note that
   * AGILLA_RCVR_FIN_TIMER < AGILLA_SNDR_RXMIT_TIMER
   */
  command result_t startFinTimer(AgillaAgentID *id);

  /**
   * Launches an agent without going through a FIN stage.  This is
   * used when the medium over which the migration operation occurs
   * is reliable enough to assume that the sender received the last
   * acknowledgement.
   */
  //command result_t launchAgent(AgillAgentID *id);

  /**
   * Cancels the timer associated with the specified agent.
   */
  command result_t stopTimer(AgillaAgentID *id);
  
  /**
   * Check whether the agent with the specified ID has arrived.
   * If it has, run it!
   *
   * @return SUCCESS if the agent has arrived, FALSE otherwise.
   */
  //command result_t checkAgentArrived(AgillaAgentID* id);
}
