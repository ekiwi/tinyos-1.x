// $Id: TimerC.nc,v 1.1 2005/09/23 12:59:40 palfrey Exp $

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
 * Authors:  Su Ping,  (converted to nesC by Sam Madden)
 *           David Gay,      Intel Research Berkeley Lab
 *           Phil Levis
 *           Tom Parker <T.E.V.Parker@ewi.tudelft.nl> (TNOde modifications)
 * Date:     4/12/2002
 * NesC conversion: 6/28/2002
 * interface cleanup: 7/16/2002
 * Configuration:     8/12/2002
 */

/**
 * @author Su Ping
 * @author (converted to nesC by Sam Madden)
 * @author David Gay
 * @author Intel Research Berkeley Lab
 * @author Phil Levis
 * @author Tom Parker (TNOde modifications)
 */



configuration TimerC
{
	provides 
	{
		interface Timer[uint8_t id];
		interface StdControl;
	}
}

implementation
{
	components TimerM, ClockMSM;

	TimerM.ClockMS ->ClockMSM.Clock[unique("ClockMSM")];
	TimerM.ClockControl -> ClockMSM;

	StdControl = TimerM;
	Timer = TimerM;
}
