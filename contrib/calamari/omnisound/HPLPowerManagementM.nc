/*
 * @(#)HPLPowerManagementM.nc
 *
 * "Copyright (c) 2003 and The Regents of the University 
 * of California.  All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice and the following
 * two paragraphs appear in all copies of this software.
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
 * Author:  Robert Szewczyk
 *
 * $Id: HPLPowerManagementM.nc,v 1.1 2004/02/20 08:08:02 kaminw Exp $
 */

module HPLPowerManagementM {
    provides {
      interface PowerManagement;
      command result_t Enable();
      command result_t Disable();
    }
}
implementation{  

    async command uint8_t PowerManagement.adjustPower() {
		return 0;
    }
	
    command result_t Enable() {
		return SUCCESS;
    }
	
    command result_t Disable() {
		return SUCCESS;
    }
}


