// $Id: Surge.h,v 1.1 2004/03/17 03:48:19 gtolle Exp $

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


enum {
  INITIAL_TIMER_RATE = 1024 * 4,
  INITIAL_SLOT_LENGTH = 512,
  INITIAL_NUM_SLOTS = 8,
  FOCUS_TIMER_RATE = 1000,
  FOCUS_NOTME_TIMER_RATE = 1000
};


enum {
  SURGE_TYPE_SENSORREADING = 0,
  SURGE_TYPE_ROOTBEACON = 1,
  SURGE_TYPE_SETRATE = 2,
  SURGE_TYPE_SLEEP = 3,
  SURGE_TYPE_WAKEUP = 4,
  SURGE_TYPE_FOCUS = 5,
  SURGE_TYPE_UNFOCUS = 6,
  SURGE_TYPE_BEEP = 7,
  SURGE_TYPE_BEEPOFF = 8,
  SURGE_TYPE_RADIOPOWER = 9,
  SURGE_TYPE_DARKTHRESHHOLD = 10,
  SURGE_TYPE_EASYMODE = 11,
  SURGE_TYPE_HARDMODE = 12,
}; 


typedef struct SurgeDemoMsg {
  uint8_t type;
  uint8_t depth;
  uint32_t seq_no;
  uint8_t light;
  uint8_t goodRound;
  uint8_t goodRounds;
} __attribute__ ((packed)) SurgeDemoMsg;

enum {
  AM_SURGEDEMOMSG = 20
};



