//$Id: ZapInterruptC.nc,v 1.1 2005/07/29 18:29:30 adchristian Exp $

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

//@author Joe Polastre
//@author Jamey Hicks

configuration ZapInterruptC
{
  provides interface ZapInterrupt as Eth;
  provides interface ZapInterrupt as FIFOP;
  provides interface ZapInterrupt as CCA;
  provides interface ZapInterrupt as SFD;
}
implementation
{
  components ZapInterruptM;

  Eth = ZapInterruptM.Eth;
  FIFOP = ZapInterruptM.FIFOP;
  CCA = ZapInterruptM.CCA;
  SFD = ZapInterruptM.SFD;
}

