// $Id: MLME_SCAN.nc,v 1.3 2004/03/09 01:10:34 jpolastre Exp $

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
 * Authors:		Joe Polastre
 */

includes IEEE802154;

/**
 * The MLME-SAP scan primitives define how a device can determine the energy
 * usage or the presence or absence of PANs in a communications channel.
 *
 * @author Joe Polastre
 */

interface MLME_SCAN {

  /**
   * Used to initiate a channel scan over a given list of channels.
   * A device can use a channel scan to measure the energy on the channel,
   * search for the coordinator with which it is associated, or search
   * for all coordinators transmitting beacon frames within the POS
   * of the scanning device.
   * 
   * @param ScanType The type of scan performed
   * @param ScanChannels The 27 LSBs indicate which channels are to be
   *                     scanned (1 = scan)
   * @param ScanDuration Value used to calculate the length of time to
   *                     spend scanning each channel for ED, active, and
   *                     passive scans.  This parameter is ignored for
   *                     orphan scans.
   */
  command void request  (
                          uint8_t ScanType,
                          uint32_t ScanChannels,
                          uint8_t ScanDuration
                        );

  /**
   * Reports the results of the channel scan request
   *
   * @param status The status of the scan request
   * @param ScanType The type of scan performed
   * @param UnscannedChannels The 27 LSBs indicate which channels are not
   *                          scanned (1 = not scanned)
   * @param ResultListSize The number of elements reterned in the 
   *                       appropriate results list
   * @param EnergyDetectList The list of energy measurements, one for 
   *                         each channel searched during an ED scan
   * @param PANDescriptorList The list of PAN descriptors, one for each
   *                          beacon found during an active or passive scan
   */
  event void confirm    (
                          IEEE_status status,
                          uint8_t ScanType,
                          uint32_t UnscannedChannels,
                          uint8_t ResultListSize,
                          uint8_t* EnergyDetectList,
                          PANDescriptor_t* PANDescriptorList
                        );

}
