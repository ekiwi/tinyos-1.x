// $Id: StorageManagerC.nc,v 1.1.1.1 2007/11/05 19:11:27 jpolastre Exp $

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
 */

/*
 * @author: Jonathan Hui <jwhui@cs.berkeley.edu>
 */

#include "HALSTM25P.h"

configuration StorageManagerC {
  provides {
    interface SectorStorage[volume_t volume];
    interface Mount[volume_t volume];
    interface StdControl;
    interface StorageRemap[volume_t volume];
    interface StorageManager[volume_t volume];
  }
}

implementation {

  components CrcC, HALSTM25PC, StorageManagerM, LedsC;
  components new STM25PResourceC() as CmdMountC;
  
  StdControl = StorageManagerM;
  
  SectorStorage = StorageManagerM.SectorStorage;
  Mount = StorageManagerM;
  StorageRemap = StorageManagerM;
  StorageManager = StorageManagerM;
  
  StorageManagerM.Crc -> CrcC;
  StorageManagerM.HALSTM25P -> HALSTM25PC.HALSTM25P[unique("HALSTM25P")];
  StorageManagerM.Leds -> LedsC;
  StorageManagerM.CmdMount -> CmdMountC;

}
