// $Id: LoggerWrite.nc,v 1.1 2005/09/06 08:27:59 lnachman Exp $

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
 * Authors:		Jason Hill, David Gay, Philip Levis
 * Date last modified:  6/25/02
 *
 * $Id: LoggerWrite.nc,v 1.1 2005/09/06 08:27:59 lnachman Exp $
 */

/**
 * @author Jason Hill
 * @author David Gay
 * @author Philip Levis
 */


//includes EEPROM;

/**
 * Implements a circular log interface.
 * Allows a line at a time to be written, automatically 
 * maintaining a current line pointer. The pointer wraps around to the 
 * beginning of the log.
 */
interface LoggerWrite {

  /**
   * Writes data to the current line in the EEPROM. If the call
   * does not return <code>FAIL</code>, the next call to append will write to 
   * (current line + 1).
   * <p>
   * <code>writeDone()</code> will be signaled if result 
   * is not <code>FAIL</code>
   *
   * @param data the data to be appended to the log
   *
   * @return FAIL if the write cannot occur, SUCCESS otherwise
   */
  command result_t append(uint8_t *data);

  /**
   * Reset the current line pointer to the beginning of the log.
   *
   * @return SUCCESS if the line pointer can be moved and no other operations
   *         are pending.
   */
  command result_t resetPointer();

  /**
   * Set the current line pointer to the value of 'line'.
   * Not all line values are valid.
   *
   * @param line The address of the line to set the current pointer to.
   *
   * @return FAIL if the line is invalid, SUCCESS otherwise.
   */
  command result_t setPointer(uint16_t line);

  /**
   * Write a specified line to the log.
   * <p>
   * Sets the current line to the input <code>line</code>
   * and then behaves as <code>append(data)</code>.
   * <p>
   * Equivalent to calling <code>setPointer(line)</code>
   * followed by <code>append(data)</code>
   *
   * @param line the address of the line
   * @param data the data to be written to the log
   *
   * @return FAIL if the write cannot occur, SUCCESS otherwise
   */
  command result_t write(uint16_t line, uint8_t *data);

  /**
   * Notification that a write command has been completed.
   * Signaled by both <code>write()</code>
   * and <code>append()</code>.
   *
   * @param success SUCCESS if the write was successfully written to the log
   *
   * @return SUCCESS to notify the logger to keep its bookmark
   *         (current line) in the log
   */
  event result_t writeDone(result_t success);

}

