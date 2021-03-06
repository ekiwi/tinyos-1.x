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
 * Date last modified:  8/12/02
 *
 * The robot should perform a figure8.  This is open-loop only - there
 * are no guarantees that the figure8 will actually look like one.  In
 * fact, this will depend very heavily on battery voltage and timing.
 *
 */

configuration Figure8C {
  provides interface StdControl;
  provides interface Figure8Calibration;
}
implementation {
  components Figure8M, RobotC, TimerC, LedsC;

  StdControl = Figure8M.StdControl;
  Figure8Calibration = Figure8M.Figure8Calibration;

  Figure8M.Robot -> RobotC;
  Figure8M.Timer -> TimerC.Timer[unique("Timer")];
  Figure8M.TimerControl -> TimerC;

  Figure8M.Leds -> LedsC;
}
