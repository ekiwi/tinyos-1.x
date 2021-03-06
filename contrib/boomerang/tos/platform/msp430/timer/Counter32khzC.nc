//$Id: Counter32khzC.nc,v 1.1.1.1 2007/11/05 19:11:33 jpolastre Exp $

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
 * The TinyOS Timer interfaces are discussed in TEP 102.
 * Counter32khzC is the counter to be used for all 32khzs.
 * Use Counter to get the current time of the mote in 32khz resolution.
 *
 * @author Cory Sharp, Moteiv Corporation <info@moteiv.com>
 */
configuration Counter32khzC
{
  provides interface Counter<T32khz,uint16_t> as Counter32khz16;
  provides interface Counter<T32khz,uint32_t> as Counter32khz32;
  provides interface LocalTime<T32khz> as LocalTime32khz;
}
implementation
{
  components MSP430TimerC
	   , MSP430Counter32khzC
	   , new TransformCounterC(T32khz,uint32_t,T32khz,uint16_t,0,uint16_t) as Transform
	   , new CounterToLocalTimeC(T32khz)
	   ;
  
  Counter32khz16 = MSP430Counter32khzC;
  Counter32khz32 = Transform.Counter;
  LocalTime32khz = CounterToLocalTimeC;

  CounterToLocalTimeC.Counter -> Transform;
  Transform.CounterFrom -> MSP430Counter32khzC;
}

