// $Id: HPLCC2420RAM.nc,v 1.1.1.1 2007/11/05 19:11:24 jpolastre Exp $
/*
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

/**
 * RAM access to the CC2420 transceiver.
 *
 * @author Joe Polastre, Moteiv Corporation <info@moteiv.com>
 */
interface HPLCC2420RAM {

  /**
   * Transmit data to RAM
   *
   * @param rh either RESOURCE_NONE for automatic resource scheduling or a
   * resource handle acquired by CC2420ResourceC
   * @param addr 16-bit address
   * @param length 8-bit count of bytes to write
   * @param buffer data buffer to write from
   *
   * @return SUCCESS if the request was accepted
   */
  async command result_t write(uint8_t rh, uint16_t addr, uint8_t length, uint8_t* buffer);

  async event result_t writeDone(uint16_t addr, uint8_t length, uint8_t* buffer);

  /**
   * Read data from RAM
   *
   * @param rh either RESOURCE_NONE for automatic resource scheduling or a
   * resource handle acquired by CC2420ResourceC
   * @param addr 16-bit address
   * @param length 8-bit count of bytes to read
   * @param buffer data buffer to read to
   *
   * @return SUCCESS if the request was accepted
   */
  async command result_t read(uint8_t rh, uint16_t addr, uint8_t length, uint8_t* buffer);

  async event result_t readDone(uint16_t addr, uint8_t length, uint8_t* buffer);
  

}
