/*
 * Copyright (c) 2004, Technische Universitaet Berlin
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
 * - Neither the name of the Technische Universitaet Berlin nor the names
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
 * - Revision -------------------------------------------------------------
 * $Revision: 1.1 $
 * $Date: 2005/01/26 14:14:00 $
 * @author: Kevin Klues (klues@tkn.tu-berlin.de)
 * ========================================================================
 */

/**
 * Commands and event provided by the Radio Interface
 * to communicate with upper layers about the status of a 
 * packet that is being transmitted
 *
 * @author Kevin Klues (klues@tkn.tu-berlin.de)
 * @modified 12/11/2003 Added Meaningful Documentation 
 */  
 
interface PacketTx {
  /**
   * Start sending a packet.
   * Begins by sending all necessary preamble and synchronization
   * bytes.
   * Signals when it is actually ready for byte transmission
   * via the ByteComm interface   
   *
   * @param numPreambles The number of preamble bytes to be sent 
   * at the start of the packet
   * @return <code>SUCCESS</code> or <code>FAIL</code> depending on 
   * whether the Preamble and Synchronization bytes could be 
   * successfully transmitted or not
   **/  
  async command result_t start(uint16_t numPreambles);
  /**
   * Signals the radio that the last byte of the packet has 
   * been made ready for transmission
   *
   * @return Always returns <code>SUCCESS</code>
   **/    
  async command result_t stop();
  /**
   * Signals the event that the last byte of the packet has 
   * now been completely transmitted
   *
   * @return Always expects a <code>SUCCESS</code> to be returned
   **/   
  async event result_t done();
}
