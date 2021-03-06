// $Id: ReceiverC.nc,v 1.6 2004/04/16 01:38:33 ckarlof Exp $

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
/* Copyright (c) 2003, UC Berkeley, Intel Corp
 * Author: Fred Jiang, Kamin Whitehouse
 * Date last modified: 06/27/03
 */

includes Omnisound;

configuration ReceiverC {
	provides {
		interface StdControl;
		interface RangingReceiver;
	}
}

implementation {
  components ReceiverM, GenericCommI2C as Comm, SignalToAtmega8DotM, TimedLedsC as Leds,
		CC1000RadioIntM as Radio;
	StdControl = ReceiverM;
        StdControl = Comm;
	RangingReceiver = ReceiverM;
	ReceiverM.ChirpReceive->Comm.ReceiveMsg[AM_CHIRPMSG]; // from Radio
	ReceiverM.Timestamp->Comm.ReceiveMsg[AM_TIMESTAMPMSG]; //from UART <- Atmega8
	ReceiverM.SignalToAtmega8Control -> SignalToAtmega8DotM;
	ReceiverM.SignalToAtmega8->SignalToAtmega8DotM;
	ReceiverM.RadioReceiveCoordinator->Radio.RadioReceiveCoordinator;
	ReceiverM.Leds->Leds;
}


