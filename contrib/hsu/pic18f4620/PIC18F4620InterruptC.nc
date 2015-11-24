// $Id: PIC18F4620InterruptC.nc,v 1.3 2005/12/07 18:59:19 hjkoerber Exp $

/* 
 * Copyright (c) Helmut-Schmidt-University, Hamburg
 *		 Dpt.of Electrical Measurement Engineering  
 *		 All rights reserved
 *
 * Redistribution and use in source and binary forms, with or without 
 * modification, are permitted provided that the following conditions 
 * are met:
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright 
 *   notice, this list of conditions and the following disclaimer in the 
 *   documentation and/or other materials provided with the distribution.
 * - Neither the name of the Helmut-Schmidt-University nor the names 
 *   of its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
 * OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY 
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* @author Hans-Joerg Koerber 
 *         <hj.koerber@hsu-hh.de>
 *	   (+49)40-6541-2638/2627
 * 
 * $Date: 2005/12/07 18:59:19 $
 * $Revision: 1.3 $
 */


configuration PIC18F4620InterruptC
{
  provides {
     interface PIC18F4620Interrupt as TIMER1_Overflow;
     interface PIC18F4620Interrupt as ADC_Interrupt;
     interface PIC18F4620Interrupt as UART_Transmit_Interrupt;
     interface PIC18F4620Interrupt as UART_Receive_Interrupt;
     interface PIC18F4620Interrupt as MSSP_Interrupt;
     interface PIC18F4620Interrupt as EnOceanRF_Receive_Interrupt;
  }
 
          
}

implementation
{
  components PIC18F4620InterruptM;

  TIMER1_Overflow = PIC18F4620InterruptM.TIMER1_Overflow;
  ADC_Interrupt = PIC18F4620InterruptM.ADC_Interrupt;
  UART_Transmit_Interrupt =  PIC18F4620InterruptM.UART_Transmit_Interrupt;
  UART_Receive_Interrupt =  PIC18F4620InterruptM.UART_Receive_Interrupt;
  MSSP_Interrupt = PIC18F4620InterruptM.MSSP_Interrupt;
  EnOceanRF_Receive_Interrupt = PIC18F4620InterruptM.EnOceanRF_Receive_Interrupt;
}

 
