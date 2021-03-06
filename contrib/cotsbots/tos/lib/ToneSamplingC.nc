/*                                                                      tab:4
 *
 *
 * "Copyright (c) 2002 and The Regents of the University
 * of California.  All rights reserved.
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
 * Authors:             Sarah Bergbreiter
 * Date last modified:  10/22/2003
 *
 * This component sends a series of beeps using the sounder and timing
 * information provided by the component calling ToneSampling.
 *
 */

includes OscopeMsg;

configuration ToneSamplingC {
  provides interface StdControl;
  provides interface AcousticSampling;
}
implementation {
  components ToneSamplingM, TimerC, MicC, LedsC;

  StdControl = ToneSamplingM.StdControl;
  AcousticSampling = ToneSamplingM.AcousticSampling;

  ToneSamplingM.TimerControl -> TimerC;
  ToneSamplingM.SampleTimer -> TimerC.Timer[unique("Timer")];
  ToneSamplingM.ClockTimer -> TimerC.Timer[unique("Timer")];
  ToneSamplingM.MicControl -> MicC;
  ToneSamplingM.Mic -> MicC;

  ToneSamplingM.Leds -> LedsC;
}
