// $Id: Chirp.nc,v 1.2 2005/09/23 12:59:39 palfrey Exp $

/*                                                                      tab:4
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

includes ChirpMsg;

/**
 * The Chirp application periodically sends a broadcast packet over the
 * radio using a timer.  The packet contains the current photo sensor
 * reading.
 */
configuration Chirp { }
implementation {
  components Main, ChirpM, GenericComm as Comm, DemoSensorC, TimerC, UARTDebugC;
  components LedsC;
  //components NoLeds as LedsC;

  Main.StdControl -> DemoSensorC;
  Main.StdControl -> Comm;
  Main.StdControl -> TimerC;
  Main.StdControl -> ChirpM;
  ChirpM.Leds -> LedsC;

  ChirpM.ADC -> DemoSensorC;
  ChirpM.ADCControl -> DemoSensorC;

  ChirpM.CommControl -> Comm;
  ChirpM.SendChirpMsg -> Comm.SendMsg[AM_CHIRPMSG];
  ChirpM.ReceiveChirpMsg -> Comm.ReceiveMsg[AM_CHIRPMSG];

  ChirpM.Timer -> TimerC.Timer[unique("Timer")];
  ChirpM.Debug -> UARTDebugC;
}
