// $Id: FileStorageUtil.nc,v 1.2 2007/03/05 00:06:06 lnachman Exp $

/*									tab:2
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
 */

/**
 * @author Junaith Ahemed Shahabdeen
 * 
 */

includes Storage;

interface FileStorageUtil
{
  /**
   * FileStorageUtil.updateMountStatus
   *
   * The function updates the current mount status of a file in
   * its metadata. The mount status is a boolean set to TRUE
   * when mounted and FALSE when unmounted.
   * 
   */
  command result_t updateMountStatus(volume_id_t id, volume_id_t bid, bool status);

  /**
   * FileStorageUtil.filedeleted
   *
   * Event which is signaled after a successfull file delete. This event
   * is usedful to notify the storage manager after a file delete.
   *
   * @param filename Name of the file that was deleted.
   */
  event void filedeleted (volume_id_t id, const uint8_t* filename);
}
