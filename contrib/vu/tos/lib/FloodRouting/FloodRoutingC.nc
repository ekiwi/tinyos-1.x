/*
 * Copyright (c) 2003, Vanderbilt University
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE VANDERBILT UNIVERSITY BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE VANDERBILT
 * UNIVERSITY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE VANDERBILT UNIVERSITY SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE VANDERBILT UNIVERSITY HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 **/
 /** @author Miklos Maroti
 *   @author Brano Kusy, kusy@isis.vanderbilt.edu
 *   @modified Jan05 doc fix
 */

includes FloodRoutingMsg;

configuration FloodRoutingC
{
	provides
	{
		interface StdControl;
		interface FloodRouting[uint8_t id];
	}
	uses
	{
		interface FloodingPolicy[uint8_t id];
	}
}

implementation
{
	components FloodRoutingM, TimerC, GenericComm, NoLeds as LedsC;

	StdControl = FloodRoutingM;
	FloodRouting = FloodRoutingM;
	FloodingPolicy = FloodRoutingM;

	FloodRoutingM.SendMsg -> GenericComm.SendMsg[AM_FLOODROUTING];
	FloodRoutingM.ReceiveMsg -> GenericComm.ReceiveMsg[AM_FLOODROUTING];
	FloodRoutingM.Timer -> TimerC.Timer[unique("Timer")];

	FloodRoutingM.SubControl -> GenericComm;
	FloodRoutingM.SubControl -> TimerC;

	FloodRoutingM.Leds -> LedsC;
}
