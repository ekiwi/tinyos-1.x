// $Id: HPLFlashC.nc,v 1.1 2005/07/29 18:29:29 adchristian Exp $

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
 * HPLFlashC.nc - Driver for AT45DB041 flash on telos. 
 * 
 * This driver is intended to force as little change as possible to
 * the existing PageEEPROM implementation for Micas. 
 *
 * @author Jonathan Hui <jwhui@cs.berkeley.edu>
 */

configuration HPLFlashC {
  provides {
    interface StdControl as FlashControl;
    interface FastSPI as FlashSPI;
    interface BusArbitration as FlashSelect;
    interface ReadData;
    interface WriteData;
    interface ParamView;
    
  }
}
implementation
{
  components HPLFlashM, HPLUSART1M, BusArbitrationC, TimerC;

  ParamView  = HPLFlashM;
  FlashControl = HPLFlashM;
  FlashSPI = HPLFlashM;
  FlashSelect = HPLFlashM;
  ReadData = HPLFlashM;
  WriteData = HPLFlashM;

  HPLFlashM.USARTControl -> HPLUSART1M;
  HPLFlashM.BusArbitration -> BusArbitrationC.BusArbitration[unique("BusArbitration")];

  HPLFlashM.TimerWrite -> TimerC.Timer[unique("Timer")];

}

