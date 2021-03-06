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
 *
 * Authors:  Lama Nachman
 */


/*
 * A module that enables the watch dog and feed it periodically based on
 * a timer value.  This basically validates that the timer is running OK
 * and we are not blocked. More specialized checking will be needed for
 * most applications.
 */

#ifndef WDT_INTERVAL
#define WDT_INTERVAL 30000	// 30 seconds
#endif

module SimpleWDTM {
  provides{
    interface StdControl;
  }
  uses {
    interface PXA27XWatchdog;
    interface Reset;
    interface Timer;
  }
}

implementation {
  
  command result_t StdControl.init(){
    call PXA27XWatchdog.init();
    return SUCCESS;
  }

  command result_t StdControl.start(){
    call Timer.start(TIMER_REPEAT, WDT_INTERVAL>>2); // have margin
    call PXA27XWatchdog.enableWDT(3250 * WDT_INTERVAL);
    return SUCCESS;
  }
  
  command result_t StdControl.stop(){
    // can't stop WDT once started
    return FAIL;
  }

  event result_t Timer.fired() {
    call PXA27XWatchdog.feedWDT(3250 * WDT_INTERVAL);
  }

}
