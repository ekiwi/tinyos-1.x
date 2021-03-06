/**
 * Copyright (c) 2008 - George Mason University
 * All rights reserved. 
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs, and the author attribution appear in all copies of this
 * software. 
 *
 * IN NO EVENT SHALL GEORGE MASON UNIVERSITY BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF GEORGE MASON
 * UNIVERSITY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *      
 * GEORGE MASON UNIVERSITY SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND GEORGE MASON UNIVERSITY HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
 **/

/**
 * @author Leijun Huang <lhuang2@gmu.edu>
 **/

configuration TimeCalib {
}

implementation {
    components Main, GenericComm as Comm, LedsC, 
               TimerC, SystemTimeC, TimeCalibM;

    Main.StdControl -> TimeCalibM;

    TimeCalibM.Leds -> LedsC;
    TimeCalibM.CommControl -> Comm;
    TimeCalibM.SendTimeCalibMsg -> Comm.SendMsg[11];
    TimeCalibM.SystemTime -> SystemTimeC;
    TimeCalibM.TimerControl -> TimerC;
    TimeCalibM.Timer -> TimerC.Timer[unique("Timer")];
}
