// $Id: HPLCC2420Capture.nc,v 1.1.1.1 2007/11/05 19:09:07 jpolastre Exp $

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
 */
/*
 * Authors:		Joe Polastre
 */

/**
 * @author Joe Polastre
 */


interface HPLCC2420Capture {

  /** 
   * Enable an edge based timer capture
   *
   * @param low_to_high TRUE if the edge capture should occur on
   *        a low to high transition, FALSE for high to low.
   *
   * @return SUCCESS if the timer capture has been enabled
   */
  async command result_t enableCapture(bool low_to_high);

  /**
   * Fired when an edge interrupt occurs.
   *
   * @param val the raw value of the timer captured
   *
   * @return SUCCESS to keep the interrupt enabled, FAIL to disable
   *         the interrupt
   */
  async event result_t captured(uint16_t val);

  /**
   * Diables a capture interrupt
   * 
   * @return SUCCESS if the interrupt has been disabled
   */ 
  async command result_t disable();
}
