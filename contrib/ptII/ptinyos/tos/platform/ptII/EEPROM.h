// $Id: EEPROM.h,v 1.1 2005/04/19 01:16:12 celaine Exp $

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
 *
 * Authors:		David Gay, Philip Levis
 * Date last modified:  6/25/02
 *
 */

/**
 * @author David Gay
 * @author Philip Levis
 */


#ifndef TOS_EEPROM_H
#define TOS_EEPROM_H

// EEPROM characteristics
enum {
  TOS_EEPROM_LOG2_LINE_SIZE = 4,
  TOS_EEPROM_LINE_SIZE = 1 << TOS_EEPROM_LOG2_LINE_SIZE,
  TOS_EEPROM_MAX_LINES = DEFAULT_EEPROM_SIZE >> TOS_EEPROM_LOG2_LINE_SIZE,
  TOS_EEPROM_BYTE_ADDR_BYTE_MASK = 0xf
};

// EEPROM allocation
enum {
  EEPROM_LOGGER_APPEND_START = 16,
  EEPROM_LOGGER_APPEND_END = TOS_EEPROM_MAX_LINES
};

// EEPROM component IDs
enum {
  BYTE_EEPROM_EEPROM_ID
};

#endif
