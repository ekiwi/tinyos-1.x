// $Id: TestDimmer.nc,v 1.2 2004/10/21 16:32:19 jwhui Exp $

/*									tab:4
 *
 *
 * "Copyright (c) 2000-2004 The Regents of the University  of California.  
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

/**
 * @author Jonathan Hui <jwhui@cs.berkeley.edu>
 */

includes TestDimmer;

configuration TestDimmer {
}
implementation {

  components Main,
    GenericComm as Comm,
    LedsC as Leds,
    TestDimmerM,
    TelosDimmerC,
    TimerC;

  Main.StdControl -> TestDimmerM;
  Main.StdControl -> TimerC;
  Main.StdControl -> Comm;
  Main.StdControl -> TelosDimmerC;

  TestDimmerM.Leds -> Leds;
  TestDimmerM.DimmerControl -> TelosDimmerC.DimmerControl;
  TestDimmerM.ReceiveMsg -> Comm.ReceiveMsg[AM_DIMMERMSG];
  TestDimmerM.Timer -> TimerC.Timer[unique("Timer")];

}
