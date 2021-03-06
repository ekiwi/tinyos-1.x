/*
 * Copyright (c) 2004, Technische Universitat Berlin
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions 
 * are met:
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright 
 *   notice, this list of conditions and the following disclaimer in the 
 *   documentation and/or other materials provided with the distribution.
 * - Neither the name of the Technische Universitat Berlin nor the names 
 *   of its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY 
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * - Description ----------------------------------------------------------
 * Interface for sending and receiving bytes of data over the TDA5250 Radio 
 * - Revision -------------------------------------------------------------
 * $Revision: 1.2 $
 * $Date: 2005/03/01 14:18:12 $
 * @author: Kevin Klues (klues@tkn.tu-berlin.de)
 * ========================================================================
 */
 
interface HPLTDA5250Data {

 /**
   * Transmit a byte of data. 
   * After the first call to <code>tx</code>, any subsequent calls 
   * should only be done after receiving a <code>txReady</code> event
   * Only then can a new byte be transmitted, otherwise the previous 
   * byte will be overwritten.
   */
  async command result_t tx(uint8_t data);

  /**
   * Signalled when the next byte can be made ready to transmit
   * Receiving such an event does not guarantee that the previous
   * byte has already been transmitted, just that the next one can
   * now be handed over for transmission.
   */
  async event void txReady();
  
  /**
   * Command for querying whether any bytes are still waiting to be transmitted
   */  
  async command bool isTxDone();
  
  /**
   * Signaled when a byte of data has been received from the radio. 
   */
  async event void rxDone(uint8_t data);
  
  /**
   * Commands for enabling and disabling Transmitting and Receiving 
   *  over the radio
  */  
  async command result_t enableTx();
  async command result_t disableTx();
  async command result_t enableRx();
  async command result_t disableRx();
}

