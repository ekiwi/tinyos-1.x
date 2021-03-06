// $Id: VoltageM.nc,v 1.1.1.1 2005/05/10 23:37:06 rsto99 Exp $

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
 * Authors:	Wei Hong
 *
 */

/**
 * @author Wei Hong
 */


module VoltageM {
  provides interface StdControl;
  uses {
    interface ADCControl;
  }
}
implementation {

  command result_t StdControl.init() {
    call ADCControl.bindPort(TOS_ADC_VOLTAGE_PORT, TOSH_ACTUAL_VOLTAGE_PORT);
    dbg(DBG_BOOT, "Voltage initialized.\n");
    return call ADCControl.init();
  }
  command result_t StdControl.start() {
#if (defined(PLATFORM_MICA2) || defined(PLATFORM_MICA2DOT))
#ifndef PLATFORM_XSM
	TOSH_MAKE_BAT_MON_OUTPUT();
	TOSH_SET_BAT_MON_PIN();
#endif	
#endif
    return SUCCESS;
  }

  command result_t StdControl.stop() {
#if (defined(PLATFORM_MICA2) || defined(PLATFORM_MICA2DOT))
#ifndef PLATFORM_XSM
	TOSH_CLR_BAT_MON_PIN();
#endif	
#endif
      return SUCCESS;
  }
}
