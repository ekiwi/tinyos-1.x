// $Id: ReadData.nc,v 1.1.1.1 2007/11/05 19:09:03 jpolastre Exp $

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
 * Authors:		David Gay, Philip Levis, Nelson Lee
 * Date last modified:  8/13/02
 *
 *
 */

/**
 * General interface to read n bytes of data from a particular offset.
 * @author David Gay
 * @author Philip Levis
 * @author Nelson Lee
 */
interface ReadData
{ 
  /**
   * Read data.
   * @param offset Offset at which to read.
   * @param data Where to place read data
   * @param numBytesRead number of bytes to read
   * @return FAIL if the read request is refused. If the result is SUCCESS, 
   *   the <code>readDone</code> event will be signaled.
   */
  command result_t read(uint32_t offset, uint8_t* buffer, uint32_t numBytesRead);

  /**
   * Signal read completion
   * @param data Address where read data was placed
   * @param numBytesRead Number of bytes read
   * @param success SUCCESS if read was successful, FAIL otherwise
   * @return Ignored.
   */
  event result_t readDone(uint8_t* buffer, uint32_t numBytesRead, result_t success);
}
