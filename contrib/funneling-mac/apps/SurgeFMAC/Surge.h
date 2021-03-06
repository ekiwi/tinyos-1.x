// $Id: Surge.h,v 1.1.1.1 2007/07/06 03:44:07 ahngang Exp $

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


int INITIAL_TIMER_RATE = 250;
int FOCUS_TIMER_RATE = 1000;
int FOCUS_NOTME_TIMER_RATE = 1000;
 



enum {
  SURGE_TYPE_SENSORREADING = 0,
  SURGE_TYPE_ROOTBEACON = 1,
  SURGE_TYPE_SETRATE = 2,
  SURGE_TYPE_SLEEP = 3,
  SURGE_TYPE_WAKEUP = 4,
  SURGE_TYPE_FOCUS = 5,
  SURGE_TYPE_UNFOCUS = 6
}; 


typedef struct SurgeMsg {
  uint8_t type;
  uint16_t reading;
  uint16_t parentaddr;
  uint8_t reserved[9];
} __attribute__ ((packed)) SurgeMsg;

enum {
  AM_SURGEMSG = 17
};




