/*                                                                      tab:4
 * 
 *
 * "Copyright (c) 2000 and The Regents of the University 
 * of California.  All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice and the following
 * two paragraphs appear in all copies of this software.
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
 * Authors:             Jason Hill, Philip Levis, Nelson Lee, David Gay
 *
 * Modified for btnode2_2 hardware by Mads Bondo Dydensborg
 * <madsdyd@diku.dk>, 2002-2003
 *
 */

#ifndef TOSH_HARDWARE_H
#define TOSH_HARDWARE_H

// Makes io.h include io128.h instead...
#define __AVR_ATmega128__ 1

#include <avrhardware.h>

TOSH_ASSIGN_PIN(YELLOW_LED, B, 5);
TOSH_ASSIGN_PIN(GREEN_LED, B, 6);
TOSH_ASSIGN_PIN(RED_LED, B, 7);
TOSH_ASSIGN_PIN(EXTRA_LED, B, 4);

#ifdef THIS_USED_TO_BE_SET_IN_MICA
/* This I do not understand - has to do with a potentiometer, I think */
TOSH_ASSIGN_PIN(UD, A, 1);
TOSH_ASSIGN_PIN(INC, A, 2);
TOSH_ASSIGN_PIN(POT_SELECT, D, 5);
TOSH_ASSIGN_PIN(POT_POWER, E, 7);
TOSH_ASSIGN_PIN(BOOST_ENABLE, E, 4);

TOSH_ASSIGN_PIN(FLASH_SELECT,  B, 0);
TOSH_ASSIGN_PIN(FLASH_CLK,  A, 3);
TOSH_ASSIGN_PIN(FLASH_OUT,  A, 7);
TOSH_ASSIGN_PIN(FLASH_IN,  A, 6);

TOSH_ASSIGN_PIN(INT1, D, 1);
TOSH_ASSIGN_PIN(INT2, D, 2);
TOSH_ASSIGN_PIN(INT3, D, 3);

TOSH_ASSIGN_PIN(RFM_RXD,  B, 2);
TOSH_ASSIGN_PIN(RFM_TXD,  B, 3);
TOSH_ASSIGN_PIN(RFM_CTL0, D, 7);
TOSH_ASSIGN_PIN(RFM_CTL1, D, 6);

TOSH_ASSIGN_OUTPUT_ONLY_PIN(PW0, C, 0);
TOSH_ASSIGN_OUTPUT_ONLY_PIN(PW1, C, 1);
TOSH_ASSIGN_OUTPUT_ONLY_PIN(PW2, C, 2);
TOSH_ASSIGN_OUTPUT_ONLY_PIN(PW3, C, 3);
TOSH_ASSIGN_OUTPUT_ONLY_PIN(PW4, C, 4);
TOSH_ASSIGN_OUTPUT_ONLY_PIN(PW5, C, 5);
TOSH_ASSIGN_OUTPUT_ONLY_PIN(PW6, C, 6);
TOSH_ASSIGN_OUTPUT_ONLY_PIN(PW7, C, 7);

TOSH_ASSIGN_PIN(OLD_I2C_BUS1_SCL, A, 4);
TOSH_ASSIGN_PIN(OLD_I2C_BUS1_SDA, A, 5);

TOSH_ASSIGN_PIN(LITTLE_GUY_RESET, E, 6);

TOSH_ASSIGN_PIN(ONE_WIRE, E, 5);

#endif


/* The uart. Uart0 is connected to the bluetooth module
   via pe0 and pe1. Uart1 is external, via pd2 and pd3. */
TOSH_ASSIGN_PIN(UART_RXD0, E, 0);
TOSH_ASSIGN_PIN(UART_TXD0, E, 1);

TOSH_ASSIGN_PIN(UART_RXD1, D, 2);
TOSH_ASSIGN_PIN(UART_TXD1, D, 3);


void TOSH_SET_PIN_DIRECTIONS(void)
{
  outp(0x00, DDRA);
  outp(0x00, DDRB);
  outp(0x00, DDRD);
  outp(0x02, DDRE);
  outp(0x02, PORTE);
  TOSH_MAKE_RED_LED_OUTPUT();
  TOSH_MAKE_YELLOW_LED_OUTPUT();
  TOSH_MAKE_GREEN_LED_OUTPUT();
  TOSH_MAKE_EXTRA_LED_OUTPUT();
  /* I think we will stop here 

  TOSH_MAKE_POT_SELECT_OUTPUT();
  TOSH_MAKE_POT_POWER_OUTPUT();
    
  TOSH_MAKE_PW7_OUTPUT();
  TOSH_MAKE_PW6_OUTPUT();
  TOSH_MAKE_PW5_OUTPUT();
  TOSH_MAKE_PW4_OUTPUT();
  TOSH_MAKE_PW3_OUTPUT();
  TOSH_MAKE_PW2_OUTPUT();
  TOSH_MAKE_PW1_OUTPUT();
  TOSH_MAKE_PW0_OUTPUT();
    
  TOSH_MAKE_RFM_CTL0_OUTPUT();
  TOSH_MAKE_RFM_CTL1_OUTPUT();
  TOSH_MAKE_RFM_TXD_OUTPUT();
  TOSH_SET_POT_POWER_PIN();

  TOSH_MAKE_FLASH_SELECT_OUTPUT();
  TOSH_MAKE_FLASH_OUT_OUTPUT();
  TOSH_MAKE_FLASH_CLK_OUTPUT();
  TOSH_SET_FLASH_SELECT_PIN();
    
  */

  TOSH_SET_RED_LED_PIN();
  TOSH_SET_YELLOW_LED_PIN();
  TOSH_SET_GREEN_LED_PIN();
  TOSH_SET_EXTRA_LED_PIN();

  /*
  TOSH_MAKE_BOOST_ENABLE_OUTPUT();
  TOSH_SET_BOOST_ENABLE_PIN();

  TOSH_MAKE_ONE_WIRE_INPUT();
  TOSH_SET_ONE_WIRE_PIN();
  */
}

// define the voltage port here because it's not associated with any sensorboards 

/*
enum 
{ 
  TOSH_ACTUAL_VOLTAGE_PORT = 7 
}; 
enum 
{ 
  TOS_ADC_VOLTAGE_PORT = 7 
}; 
*/
#endif //TOSH_HARDWARE_H
