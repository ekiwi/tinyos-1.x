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
/*									tab:4
 *  IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.  By
 *  downloading, copying, installing or using the software you agree to
 *  this license.  If you do not agree to this license, do not download,
 *  install, copy or use the software.
 *
 *  Intel Open Source License 
 *
 *  Copyright (c) 2002 Intel Corporation 
 *  All rights reserved. 
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 * 
 *	Redistributions of source code must retain the above copyright
 *  notice, this list of conditions and the following disclaimer.
 *	Redistributions in binary form must reproduce the above copyright
 *  notice, this list of conditions and the following disclaimer in the
 *  documentation and/or other materials provided with the distribution.
 *      Neither the name of the Intel Corporation nor the names of its
 *  contributors may be used to endorse or promote products derived from
 *  this software without specific prior written permission.
 *  
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 *  PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE INTEL OR ITS
 *  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 *  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * 
 */
/*
 * Authors:   Philip Levis
 * History:   July 19, 2002
 *	     
 *
 */

includes Bombilla;

module BSynch {
  provides interface BombillaSynch as Synch;
  uses {
    interface BombillaError;
    interface BombillaLocks as Locks;
  }
}


implementation {
	
  command bool Synch.isRunnable(BombillaContext* context, 
				BombillaLock* locks) {
    int8_t i;
    uint16_t neededLocks = (context->acquireSet);
    dbg(DBG_USR2, "VM: Checking whether context %i runnable: ", (int)context->which);

    for (i = 0; i < BOMB_HEAPSIZE; i++) {
      if (neededLocks & (1 << i)) {
	if (call Locks.isLocked(locks, i)) {
	  dbg_clear(DBG_USR2, "no\n");
	  return FALSE;
	}
      }
    }
    dbg_clear(DBG_USR2, "yes\n");
    return TRUE;
  }

  command result_t Synch.obtainLocks(BombillaContext* caller, 
				     BombillaContext* obtainer, 
				     BombillaLock* locks) {
    int8_t i;
    uint16_t neededLocks = (obtainer->acquireSet);
    dbg(DBG_USR2, "VM: Attempting to obtain necessary locks for context %i.\n", obtainer->which);
    for (i = 0; i < BOMB_HEAPSIZE; i++) {
      if (neededLocks & (1 << i)) {
	call Locks.lock(obtainer, locks, i);
      }
    }
    obtainer->acquireSet = 0;
    return SUCCESS;		
  }

  command result_t Synch.releaseLocks(BombillaContext* caller, 
				      BombillaContext* releaser, 
				      BombillaLock* locks) {
    int8_t i;
    uint16_t lockSet = (releaser->releaseSet);
    dbg(DBG_USR2, "VM: Attempting to release specified locks for context %i.\n", releaser->which);
    for (i = 0; i < BOMB_HEAPSIZE; i++) {
      if (lockSet & (1 << i)) {
	call Locks.unlock(releaser, locks, i);
      }
    }
    releaser->releaseSet = 0;
    return SUCCESS;		
  }

  command result_t Synch.releaseAllLocks(BombillaContext* caller,
					 BombillaContext* releaser, 
					 BombillaLock* locks) {
    int8_t i;
    uint16_t lockSet = (releaser->heldSet);
    dbg(DBG_USR2, "VM: Attempting to release all locks for context %i.\n", releaser->which);
    for (i = 0; i < BOMB_HEAPSIZE; i++) {
      if (lockSet & (1 << i)) {
	call Locks.unlock(releaser, locks, i);
      }
    }
    releaser->releaseSet = 0;
    return SUCCESS;
  }
}    
  
  

  
  




