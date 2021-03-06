/*									tab:4
 *
 *
 * "Copyright (c) 2000-2002 The Regents of the University  of California.  
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
 * Date last modified:  $Revision: 1.1 $
 *
 * Low Power Listening
 */

/**
 * Low Power Listening control interface
 */
interface LowPowerListening
{
  /**
   * Set the current Low Power Listening mode.
   * Setting the LPL mode sets both the check interval and preamble length.
   *
   * Modes include:
   *  0 = Radio full on
   *  1 = 10ms check interval
   *  2 = 25ms check interval
   *  3 = 50ms check interval
   *  4 = 100ms check interval (recommended)
   *  5 = 200ms check interval
   *  6 = 400ms check interval
   *  7 = 800ms check interval
   *  8 = 1600ms check interval
   *
   * @param mode the mode number
   * @return SUCCESS if the mode was successfully changed
   */
  async command result_t SetListeningMode(uint8_t mode);

  /**
   * Get the current Low Power Listening mode
   * @return mode number (see SetListeningMode)
   */
  async command uint8_t GetListeningMode();

  /**
   * Set the transmit mode.  This allows for hybrid schemes where
   * the transmit mode is different than the receive mode.
   * Use SetListeningMode first, then change the mode with SetTransmitMode.
   *
   * @param mode mode number (see SetListeningMode)
   * @return SUCCESS if the mode was successfully changed
   */
  async command result_t SetTransmitMode(uint8_t mode);

  /**
   * Get the current Low Power Listening transmit mode
   * @return mode number (see SetListeningMode)
   */
  async command uint8_t GetTransmitMode();

  /**
   * Set the preamble length of outgoing packets
   *
   * @param bytes length of the preamble in bytes
   * @return SUCCESS if the preamble length was successfully changed
   */
  async command result_t SetPreambleLength(uint16_t bytes);

  /**
   * Get the preamble length of outgoing packets
   *
   * @return length of the preamble in bytes
   */
  async command uint16_t GetPreambleLength();

  /**
   * Set the check interval (time between waking up and sampling
   * the radio for activity in low power listening)
   *
   * @param ms check interval in milliseconds
   * @return SUCCESS if the check interval was successfully changed
   */
  async command result_t SetCheckInterval(uint16_t ms);

  /**
   * Get the check interval currently used by low power listening
   *
   * @return length of the check interval in milliseconds
   */
  async command uint16_t GetCheckInterval();
}
