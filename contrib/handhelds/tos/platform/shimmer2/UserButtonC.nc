//$Id: UserButtonC.nc,v 1.1 2008/01/22 20:26:11 ayer1 Exp $

/* "Copyright (c) 2000-2003 The Regents of the University of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement
 * is hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY
 * OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 */

/**
 * Init/start/stop the user button with StdControl and get interrupt events
 * when the button is released with MSP430Event.
 *
 * @author Cory Sharp <cssharp@eecs.berkeley.edu>
 * @author Andrew Redfern <aredfern@kingkong.me.berkeley.edu>
 */

/**
 * SHIMMER doesn't have a userbutton on the device itself, but the
 * programming board does have a user button which can be accessed
 * when the SHIMMER is docked.
 */

configuration UserButtonC
{
  provides interface StdControl;
  provides interface MSP430Event as UserButton;
}
implementation
{
  components UserButtonM, 
    MSP430GeneralIOC, 
    MSP430InterruptC, 
    TimerC;

  // TimerC must be initialized!

  StdControl = UserButtonM;
  UserButton = UserButtonM;

  UserButtonM.MSP430Interrupt -> MSP430InterruptC.Port20;
  UserButtonM.MSP430GeneralIO -> MSP430GeneralIOC.Port20;
  UserButtonM -> TimerC.Timer[unique("Timer")];
}
