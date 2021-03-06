/*									tab:4
 * "Copyright (c) 2000-2005 The Regents of the University  of California.  
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

/**
 * This interface allows a component to enable or disable acknowledgments
 * on per-packet basis.
 *
 * @author Jonathan Hui
 * @author Philip Levis
 * @author Joe Polastre
 * @author David Moss
 * @date   October 10 2005
 */
interface PacketAcknowledgements {

  /**
   * Enable acknowledgments on this packet.
   *
   * @return SUCCESS if acknowledgements are enabled, EBUSY
   * if the communication layer cannot enable them at this time, FAIL
   * if it does not support them.
   */
  async command result_t requestAck(TOS_Msg *msg);

  /**
   * Disable acknowledgments on this packet. 
   *
   * @return SUCCESS if acknowledgements are disabled, EBUSY
   * if the communication layer cannot disable them at this time, FAIL
   * if it cannot support unacknowledged communication.
   */
  async command result_t noAck(TOS_Msg *msg);

  /**
   * Whether or not a given packet was acknowledged. If a packet
   * layer does not support acknowledgements, this must return always
   * return FALSE.
   *
   * @return Whether the packet was acknowledged.
   *
   */
  async command bool wasAcked(TOS_Msg *msg);
  
}
